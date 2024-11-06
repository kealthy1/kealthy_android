import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kealthy/Orders/Track.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final showMoreProvider = StateProvider<bool>((ref) => false);
final loadingProvider = StateProvider<bool>((ref) => false);
final showStatusProvider = StateProvider<bool>((ref) => false);

class MyOrdersPage extends ConsumerStatefulWidget {
  const MyOrdersPage({super.key});

  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends ConsumerState<MyOrdersPage>
    with SingleTickerProviderStateMixin {
  String phoneNumber = '';
  final FirebaseDatabase database1 = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://kealthy-90c55-dd236.firebaseio.com/',
  );
  List<bool> _expandedStates = [];

  @override
  void initState() {
    super.initState();
    _fetchPhoneNumber();
  }

  Future<void> _fetchPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      phoneNumber = prefs.getString('phoneNumber') ?? '';
    });
  }

  Future<String?> _fetchDeliveryPartnerName(String assignedTo) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('DeliveryUsers')
          .doc(assignedTo)
          .get();

      if (snapshot.exists) {
        return snapshot.data()?['Name'];
      }
    } catch (e) {
      print('Error fetching delivery partner name: $e');
    }
    return null;
  }

  String getLast9Digits(String orderId) {
    if (orderId.length > 9) {
      return orderId.substring(orderId.length - 9);
    }
    return orderId;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(showMoreProvider);
    final isLoading = ref.watch(loadingProvider);
    ref.watch(showStatusProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 1,
      ),
      backgroundColor: Colors.white,
      body: phoneNumber.isEmpty
          ? Center(
              child: LoadingAnimationWidget.discreteCircle(
                color: Colors.orange,
                size: 50,
              ),
            )
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
                  stream: database1
                      .ref()
                      .child('orders')
                      .orderByChild('phoneNumber')
                      .equalTo(phoneNumber)
                      .onValue,
                  builder: (BuildContext context,
                      AsyncSnapshot<DatabaseEvent> snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error fetching orders'));
                    }
                    if (!snapshot.hasData ||
                        snapshot.data!.snapshot.value == null ||
                        (snapshot.data!.snapshot.value as Map).isEmpty) {
                      return const Center(child: Text('No orders found.'));
                    }

                    Map ordersMap = snapshot.data!.snapshot.value as Map;
                    List<Map<String, dynamic>> ordersList = [];

                    ordersMap.forEach((key, value) {
                      ordersList.add(Map<String, dynamic>.from(value));
                    });

                    if (_expandedStates.length != ordersList.length) {
                      _expandedStates =
                          List<bool>.filled(ordersList.length, false);
                    }

                    return FutureBuilder<void>(
                      future: _fetchDeliveryPartners(ordersList),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: LoadingAnimationWidget.discreteCircle(
                              color: Colors.orange,
                              size: 50,
                            ),
                          );
                        }
                        return ListView.builder(
                          itemCount: ordersList.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> order = ordersList[index];
                            String orderId = getLast9Digits(order['orderId']);
                            String status = order['status'];
                            String assignedto = order['assignedto'] ?? '';

                            String selectedSlot = order['selectedSlot'] ?? '';

                            List<dynamic> orderItems =
                                order['orderItems'] ?? [];

                            return FutureBuilder<String?>(
                              future: _fetchDeliveryPartnerName(assignedto),
                              builder: (context, snapshot) {
                                String deliveryPartnerName =
                                    snapshot.data ?? 'Not Assigned';

                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: ExpansionTile(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Order ID: $orderId'),
                                            ],
                                          ),
                                          Text(
                                            status,
                                            style: const TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      initiallyExpanded: _expandedStates[index],
                                      onExpansionChanged: (bool expanded) {
                                        setState(() {
                                          _expandedStates[index] = expanded;
                                        });
                                      },
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Delivery Partner: $deliveryPartnerName',
                                                    style: const TextStyle(
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                  if (status != 'Delivered' &&
                                                      deliveryPartnerName !=
                                                          'Not Assigned')
                                                    IconButton(
                                                      style: ButtonStyle(
                                                          backgroundColor:
                                                              WidgetStateProperty
                                                                  .all(Colors
                                                                          .grey[
                                                                      100])),
                                                      onPressed: () {},
                                                      icon: const Icon(
                                                        Icons.call,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                'Expected Delivery Time: $selectedSlot',
                                                style: const TextStyle(
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              if (status != 'Delivered' &&
                                                  deliveryPartnerName !=
                                                      'Not Assigned')
                                                ...[],
                                              if (isLoading)
                                                Center(
                                                  child: LoadingAnimationWidget
                                                      .bouncingBall(
                                                    color: Colors.green,
                                                    size: 50,
                                                  ),
                                                )
                                              else
                                                ...orderItems
                                                    .take(_expandedStates[index]
                                                        ? orderItems.length
                                                        : 2)
                                                    .map((item) {
                                                  return ListTile(
                                                    leading: const Icon(Icons
                                                        .breakfast_dining_outlined),
                                                    title:
                                                        Text(item['item_name']),
                                                    trailing: Text(
                                                        'Qty: ${item['item_quantity']}'),
                                                  );
                                                }),
                                              if (status != 'Delivered' &&
                                                  deliveryPartnerName !=
                                                      'Not Assigned') ...[
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.green),
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        CupertinoModalPopupRoute(
                                                          builder: (context) =>
                                                              OrderTrackingPage(
                                                                  deliveryUserId:
                                                                      assignedto),
                                                        ));
                                                  },
                                                  child: const Text(
                                                    'Track Order',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(height: 10),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              )
            ]),
    );
  }

  Future<void> _fetchDeliveryPartners(
      List<Map<String, dynamic>> ordersList) async {
    for (var order in ordersList) {
      String assignedTo = order['assignedto'] ?? '';
      String? deliveryPartnerName = await _fetchDeliveryPartnerName(assignedTo);
      order['deliveryPartnerName'] = deliveryPartnerName;
    }
  }
}

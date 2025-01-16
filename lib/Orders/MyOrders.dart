import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:kealthy/LandingPage/Widgets/floating_bottom_navigation_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Track.dart';

final phoneNumberProvider = StateProvider<String>((ref) => '');
final ordersListProvider =
    StateProvider<List<Map<String, dynamic>>>((ref) => []);
final expandedStatesProvider = StateProvider<List<bool>>((ref) => []);
final loadingProvider = StateProvider<bool>((ref) => false);

class MyOrdersPage extends ConsumerStatefulWidget {
  const MyOrdersPage({super.key});

  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends ConsumerState<MyOrdersPage> {
  final FirebaseDatabase database1 = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://kealthy-90c55-dd236.firebaseio.com/',
  );
  late StreamSubscription _ordersSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeState());
  }

  @override
  void dispose() {
    _ordersSubscription.cancel();
    super.dispose();
  }

  Future<void> _initializeState() async {
    await _fetchPhoneNumber();
    await _loadOrders();
  }

  Future<void> _fetchPhoneNumber() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ref.read(phoneNumberProvider.notifier).state =
        prefs.getString('phoneNumber') ?? '';
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    ref.read(loadingProvider.notifier).state = true;

    final phoneNumber = ref.read(phoneNumberProvider);
    if (phoneNumber.isEmpty) {
      if (mounted) ref.read(loadingProvider.notifier).state = false;
      return;
    }

    _ordersSubscription = database1
        .ref()
        .child('orders')
        .orderByChild('phoneNumber')
        .equalTo(phoneNumber)
        .onValue
        .listen((event) async {
      if (!mounted) return;
      final snapshot = event.snapshot.value as Map?;
      if (snapshot == null || snapshot.isEmpty) {
        if (!mounted) return;
        ref.read(ordersListProvider.notifier).state = [];
        ref.read(expandedStatesProvider.notifier).state = [];
        ref.read(loadingProvider.notifier).state = false;
        return;
      }
      List<Map<String, dynamic>> ordersList = [];
      snapshot.forEach((key, value) {
        ordersList.add(Map<String, dynamic>.from(value));
      });

      if (!mounted) return;
      ref.read(ordersListProvider.notifier).state = ordersList;
      ref.read(expandedStatesProvider.notifier).state =
          List<bool>.filled(ordersList.length, true);
      ref.read(loadingProvider.notifier).state = false;
    });
  }

  String getLast9Digits(String orderId) {
    if (orderId.length > 9) {
      return orderId.substring(orderId.length - 9);
    }
    return orderId;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(phoneNumberProvider);
    final ordersList = ref.watch(ordersListProvider);
    final expandedStates = ref.watch(expandedStatesProvider);
    final isLoading = ref.watch(loadingProvider);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => const CustomBottomNavigationBar()),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: 1,
        ),
        backgroundColor: Colors.white,
        body: isLoading
            ? Center(
                child: LoadingAnimationWidget.discreteCircle(
                  color: Color(0xFF273847),
                  size: 50,
                ),
              )
            : ordersList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 100,
                          color: Color(0xFF273847),
                        ),
                        Text(
                          'No orders found',
                          style: TextStyle(
                            color: Color(0xFF273847),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: ordersList.length,
                    itemBuilder: (context, index) {
                      final order = ordersList[index];
                      final orderId = getLast9Digits(order['orderId']);
                      final status = order['status'];
                      final deliveryPartnerName =
                          order['assignedto'] ?? 'Not Assigned';
                      final DAMOBILE = order['DAMOBILE'] ?? 'No value';
                      final DA = order['DA'] ?? "";
                      final address = order['selectedRoad'] ?? '';
                      final orderItems = order['orderItems'] ?? [];
                      final selectedSlot = order['selectedSlot'] ?? '';
                      final expanded = expandedStates[index];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                              bottom: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                              left: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                              right: BorderSide(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.transparent,
                              expansionTileTheme: const ExpansionTileThemeData(
                                backgroundColor: Colors.white,
                                collapsedBackgroundColor: Colors.white,
                              ),
                            ),
                            child: ExpansionTile(
                              iconColor: Color(0xFF273847),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Order ID: $orderId',
                                            style: TextStyle(
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          const SizedBox(width: 5),
                                          Icon(
                                            CupertinoIcons.doc,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      status,
                                      style: const TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 14,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              initiallyExpanded: expanded,
                              onExpansionChanged: (bool expanded) {
                                final updatedStates =
                                    List<bool>.from(expandedStates);
                                updatedStates[index] = expanded;
                                ref
                                    .read(expandedStatesProvider.notifier)
                                    .state = updatedStates;
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
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Icon(
                                                  CupertinoIcons.person,
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                    'Delivery Partner: $DA',
                                                    style: const TextStyle(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (deliveryPartnerName !=
                                              'NotAssigned')
                                            IconButton(
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.black12),
                                              onPressed: () {
                                                FlutterPhoneDirectCaller
                                                    .callNumber(DAMOBILE);
                                              },
                                              icon: const Icon(
                                                Icons.call,
                                                color: Color(0xFF273847),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(
                                            CupertinoIcons.time,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              'Delivery Time: $selectedSlot',
                                              style: const TextStyle(
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      const Divider(
                                        thickness: 1.5,
                                        color: Colors.grey,
                                      ),
                                      ...orderItems
                                          .take(
                                              expanded ? orderItems.length : 2)
                                          .map((item) {
                                        return ListTile(
                                          title: Text(
                                            item['item_name'],
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 12),
                                          ),
                                          trailing: Text(
                                            'Qty: ${item['item_quantity']}',
                                            style: TextStyle(

                                            ),
                                          ),
                                        );
                                      }),
                                      if (deliveryPartnerName != 'NotAssigned')
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF273847),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              CupertinoModalPopupRoute(
                                                builder: (context) =>
                                                    OrderTrackingPage(
                                                  orderid: order['orderId'],
                                                  DeliveryBoy: DA,
                                                  Distance: order[
                                                          'selectedDistance'] ??
                                                      0.0,
                                                  phoneNumber: DAMOBILE,
                                                  Address: address,
                                                ),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Track Order',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

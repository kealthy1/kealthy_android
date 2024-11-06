import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kealthy/Orders/ordersTab.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderItem {
  final String name;
  final String status;

  OrderItem({required this.name, required this.status});
}

class OrdersProvider extends StateNotifier<List<OrderItem>> {
  OrdersProvider() : super([]);

  void listenToOrders(String phoneNumber) {
    final FirebaseDatabase database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://kealthy-90c55-dd236.firebaseio.com/',
    );

    final databaseReference = database.ref('orders');

    databaseReference
        .orderByChild('phoneNumber')
        .equalTo(phoneNumber)
        .onValue
        .listen((event) {
      if (event.snapshot.exists) {
        final orderData = event.snapshot.value as Map<dynamic, dynamic>;
        List<OrderItem> orders = [];

        orderData.forEach((key, value) {
          if (value['status'] != 'Delivered') {
            orders.add(OrderItem(
              name: value['orderId']?.toString() ?? 'Unknown Order ID',
              status: value['status']?.toString() ?? 'Unknown Status',
            ));
          }
        });

        state = orders;
      } else {
        state = [];
      }
    });
  }

  void deleteAllOrders() {
    state = [];
  }
}

final ordersProvider =
    StateNotifierProvider<OrdersProvider, List<OrderItem>>((ref) {
  return OrdersProvider();
});

class OrdersContainer extends ConsumerStatefulWidget {
  const OrdersContainer({super.key});

  @override
  ConsumerState<OrdersContainer> createState() => _OrdersContainerState();
}

class _OrdersContainerState extends ConsumerState<OrdersContainer> {
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _checkPhoneNumber();
  }

  Future<void> _checkPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');
    setState(() {
      _phoneNumber = phoneNumber;
    });

    if (phoneNumber != null) {
      ref.read(ordersProvider.notifier).listenToOrders(phoneNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_phoneNumber == null) {
      return const SizedBox.shrink();
    }

    final orders = ref.watch(ordersProvider);
    if (orders.isEmpty) {
      return const SizedBox.shrink();
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            CupertinoModalPopupRoute(
              builder: (context) => const OrdersTabScreen(),
            ),
          );
        },
        child: Container(
          height: screenHeight * 0.1,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final firstOrderStatus =
                          orders.isNotEmpty ? orders[0].status : 'No Status';
                      final firstOrderId =
                          orders.isNotEmpty ? orders[0].name : 'No ID';
                      final lastFourOrderId = firstOrderId.length >= 4
                          ? firstOrderId.substring(firstOrderId.length - 8)
                          : firstOrderId;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            firstOrderStatus,
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            "Order ID ($lastFourOrderId)",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.30,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoModalPopupRoute(
                          builder: (context) => const OrdersTabScreen(),
                        ),
                      );
                    },
                    child: Consumer(
                      builder: (context, ref, child) {
                        return const Center(
                          child: Text(
                            'Delivering Now',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kealthy/Services/Loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderData {
  final String name;
  final String assignedTo;
  final String distance;
  final String orderId;
  final String phoneNumber;
  final String Date;
  final double totalAmountToPay;
  final List<OrderItem> orderItems;

  OrderData({
    required this.name,
    required this.assignedTo,
    required this.distance,
    required this.orderId,
    required this.phoneNumber,
    required this.totalAmountToPay,
    required this.orderItems,
    required this.Date,
  });
}

class OrderItem {
  final String itemName;
  final double itemPrice;
  final int itemQuantity;

  OrderItem({
    required this.itemName,
    required this.itemPrice,
    required this.itemQuantity,
  });
}

class OrderDataNotifier extends StateNotifier<AsyncValue<List<OrderData>?>> {
  OrderDataNotifier() : super(const AsyncValue.loading());

  Future<void> fetchOrderData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phoneNumber');

      if (phoneNumber == null) {
        state = AsyncValue.error(
            "Phone number not found in preferences.", StackTrace.current);
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('Completed Orders')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (querySnapshot.docs.isEmpty) {
        state = const AsyncValue.data(null);
        return;
      }

      final orders = querySnapshot.docs.map((doc) {
        final data = doc.data();

        List<OrderItem> items = (data['orderItems'] as List<dynamic>)
            .map((item) => OrderItem(
                  itemName: item['item_name'] as String,
                  itemPrice: item['item_price'].toDouble(),
                  itemQuantity: item['item_quantity'] as int,
                ))
            .toList();

        return OrderData(
          name: data['Name'],
          assignedTo: data['assignedTo'],
          distance: data['distance'],
          orderId: data['orderId'],
          Date: data['timestamp'],
          phoneNumber: data['phoneNumber'],
          totalAmountToPay: data['totalAmountToPay'].toDouble(),
          orderItems: items,
        );
      }).toList();

      state = AsyncValue.data(orders);
    } catch (e) {
      state = AsyncValue.error(e.toString(), StackTrace.current);
    }
  }
}

final orderDataProvider =
    StateNotifierProvider<OrderDataNotifier, AsyncValue<List<OrderData>?>>(
        (ref) => OrderDataNotifier());

class OrderCard extends ConsumerWidget {
  const OrderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(orderDataProvider.notifier).fetchOrderData();

    final orderDataAsync = ref.watch(orderDataProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: orderDataAsync.when(
        data: (orders) {
          if (orders == null || orders.isEmpty) {
            return const Center(child: Text("No order data found."));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index];
              final screenSize = MediaQuery.of(context).size;
              final padding = screenSize.width * 0.03;
              final itemHeight = screenSize.height * 0.10;

              return Padding(
                padding: EdgeInsets.all(padding),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Order ${orderData.orderId.length > 10 ? orderData.orderId.substring(orderData.orderId.length - 10) : orderData.orderId}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: "poppins",
                                    overflow: TextOverflow.ellipsis),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                CupertinoIcons.doc,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                          Text(
                            DateFormat('dd-MM-yyyy')
                                .format(DateTime.parse(orderData.Date)),
                            style: const TextStyle(
                                color: Colors.black,
                                fontFamily: "poppins",
                                overflow: TextOverflow.ellipsis),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Total Amount  ₹${orderData.totalAmountToPay.toStringAsFixed(0)}/-",
                        style: TextStyle(
                            fontFamily: "poppins",
                            overflow: TextOverflow.ellipsis),
                      ),
                      const Divider(
                        thickness: 1.5,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Items:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: "poppins",
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text(
                            "Delivered",
                            style: TextStyle(
                                fontFamily: "poppins",
                                color: Colors.green,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: itemHeight,
                        child: ListView.builder(
                          itemCount: orderData.orderItems.length,
                          itemBuilder: (context, itemIndex) {
                            final item = orderData.orderItems[itemIndex];
                            return ListTile(
                              title: Text(
                                item.itemName,
                                style: TextStyle(
                                    fontFamily: "poppins",
                                    overflow: TextOverflow.ellipsis),
                              ),
                              subtitle: Text(
                                "Quantity: ${item.itemQuantity} | Price: ₹${item.itemPrice.toStringAsFixed(0)}/-",
                                style: TextStyle(
                                    fontFamily: "poppins",
                                    overflow: TextOverflow.ellipsis),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
            child: LoadingWidget(
          message: "Pleasw Wait",
        )),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
    );
  }
}

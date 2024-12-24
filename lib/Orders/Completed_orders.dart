import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kealthy/Services/Loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String itemName;
  final double itemPrice;
  final int itemQuantity;

  OrderItem({
    required this.itemName,
    required this.itemPrice,
    required this.itemQuantity,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      itemName: data['item_name']?.toString() ?? 'Unknown Item',
      itemPrice: (data['item_price'] as num?)?.toDouble() ?? 0.0,
      itemQuantity: (data['item_quantity'] as int?) ?? 0,
    );
  }
}

class OrderData {
  final String name;
  final String assignedTo;
  final String distance;
  final String orderId;
  final String phoneNumber;
  final String date;
  final String time;
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
    required this.date,
    required this.time,
  });
  factory OrderData.fromMap(Map<String, dynamic> data) {
    List<OrderItem> items = (data['orderItems'] as List<dynamic>? ?? [])
        .map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
        .toList();

    return OrderData(
      name: data['Name']?.toString() ?? 'Unknown Name',
      assignedTo: data['assignedTo']?.toString() ?? 'Unknown',
      distance: data['distance']?.toString() ?? '0',
      orderId: data['orderId']?.toString() ?? 'Unknown',
      phoneNumber: data['phoneNumber']?.toString() ?? 'Unknown',
      totalAmountToPay: (data['totalAmountToPay'] as num?)?.toDouble() ?? 0.0,
      orderItems: items,
      date: data['date']?.toString() ?? '',
      time: data['time']?.toString() ?? '',
    );
  }
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

      final apiUrl = "https://api-jfnhkjk4nq-uc.a.run.app/orders/$phoneNumber";
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body)['orders'];

        if (responseData.isEmpty) {
          state = const AsyncValue.data([]);
          return;
        }

        final orders = responseData
            .map((data) => OrderData.fromMap(data as Map<String, dynamic>))
            .toList();

        state = AsyncValue.data(orders);
      } else if (response.statusCode == 404) {
        state = const AsyncValue.data([]);
      } else {
        throw Exception("Failed to fetch orders: ${response.body}");
      }
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
            return Center(
              child: const Column(
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
                      fontFamily: "poppins",
                      color: Color(0xFF273847),
                    ),
                  ),
                ],
              ),
            );
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
                          Column(
                            children: [
                              Text(
                                orderData.date,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: "poppins",
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Text(
                                DateFormat('h:mm a').format(
                                  DateFormat('HH:mm:ss').parse(orderData.time),
                                ),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontFamily: "poppins",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
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

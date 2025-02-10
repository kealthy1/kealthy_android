import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
      final phoneNumber = prefs.getString("phoneNumber");

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.cart,
                      size: 50,
                      color: Color(0xFF273847),
                    ),
                    Text(
                      'No orders found',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Color(0xFF273847),
                      ),
                    ),
                  ],
                ),
              );
            }
            orders.sort((a, b) => b.date.compareTo(a.date));
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final orderData = orders[index];
                final screenSize = MediaQuery.of(context).size;
                final padding = screenSize.width * 0.03;

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
                                  overflow: TextOverflow.ellipsis,
                                  "Order ${orderData.orderId.length > 10 ? orderData.orderId.substring(orderData.orderId.length - 10) : orderData.orderId}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
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
                                  overflow: TextOverflow.ellipsis,
                                  orderData.date,
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  overflow: TextOverflow.ellipsis,
                                  DateFormat('h:mm a').format(
                                    DateFormat('HH:mm:ss')
                                        .parse(orderData.time),
                                  ),
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          overflow: TextOverflow.ellipsis,
                          "Total Amount  ₹${orderData.totalAmountToPay.toStringAsFixed(0)}/-",
                          style: GoogleFonts.poppins(),
                        ),
                        const Divider(
                          thickness: 1.5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Items:",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              overflow: TextOverflow.ellipsis,
                              "Delivered",
                              style: GoogleFonts.poppins(
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: orderData.orderItems.length,
                            itemBuilder: (context, itemIndex) {
                              final item = orderData.orderItems[itemIndex];
                              return ListTile(
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${item.itemQuantity}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'x ${item.itemName}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 5),
                                  child: Text(
                                    overflow: TextOverflow.ellipsis,
                                    "₹${item.itemPrice.toStringAsFixed(0)}/-",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
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
          loading: () => Center(
                  child: LoadingAnimationWidget.inkDrop(
                size: 60,
                color: Color(0xFF273847),
              )),
          error: (err, stack) => SizedBox.shrink()),
    );
  }
}

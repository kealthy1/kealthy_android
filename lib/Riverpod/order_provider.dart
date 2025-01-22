import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String backendUrl = 'https://api-jfnhkjk4nq-uc.a.run.app';

class OrderNotifier extends StateNotifier<AsyncValue<String?>> {
  OrderNotifier() : super(const AsyncValue.data(null));

  Future<void> createOrder(double totalAmountToPay) async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();

      final response = await http.post(
        Uri.parse('$backendUrl/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': totalAmountToPay,
          'currency': 'INR',
          'receipt': 'receipt_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String orderId = data['orderId'];

        await prefs.setString('RazorpayorderId', orderId);

        state = AsyncValue.data(orderId);
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      print(e);
    }
  }
}


final orderProvider = StateNotifierProvider<OrderNotifier, AsyncValue<String?>>(
  (ref) => OrderNotifier(),
);

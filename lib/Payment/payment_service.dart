import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  
  double totalToPay = 0.0;

  factory PaymentService() {
    return _instance;
  }

  PaymentService._internal();

  Future<void> updateTotalToPay(double amount) async {
    totalToPay = amount;
        SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('totalToPay', totalToPay);
  }
}

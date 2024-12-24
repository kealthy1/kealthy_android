import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Orders/ordersTab.dart';
import 'package:kealthy/Services/Order_Completed.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/PaymentHandler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RazorPay extends ConsumerStatefulWidget {
  final double totalAmountToPay;

  const RazorPay({
    super.key,
    required this.totalAmountToPay,
  });

  @override
  _RazorPayState createState() => _RazorPayState();
}

class _RazorPayState extends ConsumerState<RazorPay> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentFailure);
    openCheckout();
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      PaymentHandler paymentHandler = PaymentHandler();
      await paymentHandler.saveOrderDetails(ref);
      await paymentHandler.clearCart(ref);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('Rate', 'Your feedback message here');
      prefs.setInt('RateTimestamp', DateTime.now().millisecondsSinceEpoch);
      ReusableCountdownDialog(
        context: context,
        ref: ref,
        message: "Order Placed Successfully",
        imagePath: "assets/Animation - 1731992471934.json",
        onRedirect: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const OrdersTabScreen(),
            ),
          );
        },
      ).show();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving order: $e")),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    ReusableCountdownDialog(
      context: context,
      ref: ref,
      message: "Payment Failed! Returning to the cart",
      imagePath: "assets/Animation - 1731995566846.json",
      onRedirect: () {
        Navigator.pop(context);
      },
    ).show();
  }

  void openCheckout() async {
    String backendUrl = 'https://api-jfnhkjk4nq-uc.a.run.app';

    try {
      final prefs = await SharedPreferences.getInstance();
      final Name = prefs.getString('Name');
      final response = await http.post(
        Uri.parse('$backendUrl/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': widget.totalAmountToPay,
          'currency': 'INR',
          'receipt': 'receipt_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String orderId = data['orderId'];

        var options = {
          'key': 'rzp_live_jA2MRdwkkUcT9v',
          'amount': (widget.totalAmountToPay * 100).toString(),
          'currency': 'INR',
          'name': 'Kealthy',
          'description': 'Kealthy',
          'image':
              'https://firebasestorage.googleapis.com/v0/b/kealthy-90c55.appspot.com/o/final-image-removebg-preview.png?alt=media&token=3184c1f9-2162-45e2-9bea-95519ef1519b',
          'order_id': orderId,
          'prefill': {
            'contact': '+918848673425',
            'email': Name,
          },
          'external': {
            'wallets': ['paytm', 'googlepay'],
          }
        };

        _razorpay.open(options);
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingAnimationWidget.inkDrop(
              color: Color(0xFF273847),
              size: 70,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Loading Payments.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "poppins",
                color: Color(0xFF273847),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

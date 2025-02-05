import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/LandingPage/Widgets/floating_bottom_navigation_bar.dart';
import 'package:kealthy/Orders/ordersTab.dart';
import 'package:kealthy/Services/Order_Completed.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/PaymentHandler.dart';

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
            CupertinoModalPopupRoute(
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
        Navigator.pushReplacement(
            context,
            CupertinoModalPopupRoute(
              builder: (context) => CustomBottomNavigationBar(),
            ));
      },
    ).show();
  }

  void openCheckout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('Name');
      final phoneNumber = prefs.getString('phoneNumber');
      final storedOrderId = prefs.getString('RazorpayorderId');

      final options = {
        'key': 'rzp_live_jA2MRdwkkUcT9v',
        'amount': (widget.totalAmountToPay * 100).toString(),
        'currency': 'INR',
        'name': 'Kealthy',
        'description': 'Kealthy',
        'image':
            'https://firebasestorage.googleapis.com/v0/b/kealthy-90c55.appspot.com/o/final-image-removebg-preview.png?alt=media&token=3184c1f9-2162-45e2-9bea-95519ef1519b',
        if (storedOrderId != null) 'order_id': storedOrderId,
        'prefill': {
          'contact': phoneNumber,
          'email': name,
        },
        'external': {
          'wallets': ['paytm', 'googlepay'],
        },
      };

      _razorpay.open(options);
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
                color: Color(0xFF273847),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

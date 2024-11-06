import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Services/Order_Completed.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../Services/FirestoreCart.dart';
import '../Services/PaymentHandler.dart';

class RazorPay extends ConsumerStatefulWidget {
  final double totalAmountToPay;
  final List<CartItem> cartItems;

  const RazorPay({
    super.key,
    required this.totalAmountToPay,
    required this.cartItems,
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
    setState(() {});

    try {
      PaymentHandler paymentHandler = PaymentHandler();
      await paymentHandler.saveOrderDetails();
      await paymentHandler.clearCart(ref);
      Navigator.pushAndRemoveUntil(
        context,
        CupertinoModalPopupRoute(
          builder: (context) => const Ordersucces(),
        ),
        (Route<dynamic> route) => route.isFirst,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving order: $e")),
      );
    } finally {
      setState(() {});
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void openCheckout() {
    var options = {
      'key': 'rzp_test_GcZZFDPP0jHtC4',
      'amount': (widget.totalAmountToPay * 100).toString(),
      'name': 'KEALTHY',
      'description': 'Payment for your order',
      'prefill': {
        'contact': '1234567890',
        'email': 'customer@example.com',
      },
      'external': {
        'wallets': ['paytm', 'googlepay'],
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.discreteCircle(
        color: Colors.green,
        size: 70,
      ),
    );
  }
}

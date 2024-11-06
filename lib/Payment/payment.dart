import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Payment/COD_Page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentSection extends ConsumerWidget {
  final double totalAmountToPay;

  const PaymentSection({super.key, required this.totalAmountToPay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: ElevatedButton(
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('selectedPaymentMethod');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const OrderConfirmation(
                cartItems: [],
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(
            fontSize: 18,
          ),
        ),
        child: const Text(
          'Checkout',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

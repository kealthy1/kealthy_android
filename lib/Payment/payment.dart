import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/Maps/SelectAdress.dart';
import 'package:kealthy/Payment/COD_Page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Riverpod/order_provider.dart';

final isLoadingProvider = StateProvider<bool>((ref) => false);

class PaymentSection extends ConsumerWidget {
  final double totalAmountToPay;

  const PaymentSection({super.key, required this.totalAmountToPay});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: Color(0xFF273847)),
              ),
            ) 
          : ElevatedButton(
              onPressed: () async {ref.read(orderProvider.notifier).createOrder(totalAmountToPay);
                SharedPreferences prefs = await SharedPreferences.getInstance();
                final selectedRoad = prefs.getString('selectedRoad');

                if (selectedRoad == null || selectedRoad.isEmpty) {
                  Navigator.pushReplacement(
                    context,
                    CupertinoModalPopupRoute(
                      builder: (context) => SelectAdress(
                        totalPrice: totalAmountToPay,
                      ),
                    ),
                  );
                  return;
                }
                // ignore: unused_result
                ref.refresh(paymentMethodProvider);
                ref.read(isLoadingProvider.notifier).state = true;

                try {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.remove('selectedPaymentMethod');
                  Navigator.pushReplacement(
                    context,
                    CupertinoModalPopupRoute(
                      builder: (context) => const OrderConfirmation(
                        cartItems: [],
                      ),
                    ),
                  );
                } finally {
                  ref.read(isLoadingProvider.notifier).state = false;
                }
              },
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                backgroundColor: Color(0xFF273847),
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(
                  fontSize: 18,
                ),
              ),
              child: Text(
                'Checkout',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
            ),
    );
  }
}

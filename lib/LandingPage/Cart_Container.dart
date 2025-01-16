import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/Cart/SlotsBooking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Cart/Cart_Items.dart';
import '../Payment/Bill.dart';
import '../Services/FirestoreCart.dart';

class CartVisibilityNotifier extends StateNotifier<bool> {
  CartVisibilityNotifier() : super(true);

  void setVisible(bool isVisible) {
    state = isVisible;
  }
}

final cartVisibilityProvider =
    StateNotifierProvider<CartVisibilityNotifier, bool>((ref) {
  return CartVisibilityNotifier();
});

final cartItemCountProvider = StateProvider<int>((ref) => 0);

class CartContainer extends ConsumerWidget {
  const CartContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(sharedPreferencesCartProvider.notifier).loadCartItems();
    final cartItems = ref.watch(sharedPreferencesCartProvider);
    final totalItems =
        cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
    if (totalItems == 0) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: Container(
        height: 80,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Color(0xFF273847),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cart',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$totalItems item(s) selected',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                // ignore: unused_result
                ref.refresh(etaTimeProvider);
                // ignore: unused_result
                ref.refresh(distanceProvider);

                await prefs.remove('selectedSlot');
                // ignore: unused_result
                ref.refresh(selectedETAProvider);
                // ignore: unused_result
                ref.refresh(totalDistanceProvider);

                Navigator.push(
                  context,
                  CupertinoModalPopupRoute(
                    builder: (context) => const ShowCart(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF4F4F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Go to Cart',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                size: 15,
                CupertinoIcons.delete,
                color: Colors.white,
              ),
              onPressed: () {
                final cartItems = ref.read(sharedPreferencesCartProvider);
                if (cartItems.isNotEmpty) {
                  ref.read(sharedPreferencesCartProvider.notifier).clearCart();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

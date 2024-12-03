import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';      
import '../Cart/Cart_Items.dart';
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

    return Container(
      height: 95,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.green.shade400,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cart',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              Text(
                '$totalItems item(s) selected',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                CupertinoModalPopupRoute(
                  builder: (context) => const ShowCart(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Go to Cart',
              style: TextStyle(
                color: Colors.green,
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
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
    );
  }
}
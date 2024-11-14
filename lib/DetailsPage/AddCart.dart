import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../MenuPage/menu_item.dart';
import '../Services/FirestoreCart.dart';

class AddToCart extends ConsumerWidget {
  final MenuItem menuItem;

  const AddToCart({required this.menuItem, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(sharedPreferencesCartProvider);
    final cartNotifier = ref.read(sharedPreferencesCartProvider.notifier);

    final isItemInCart = cartItems.any((item) => item.name == menuItem.name);
    final cartItem = isItemInCart
        ? cartItems.firstWhere((item) => item.name == menuItem.name)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "₹ ${menuItem.price.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 24, fontFamily: "Poppins"),
              ),
            ),
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.30,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 223, 240, 224),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green),
              ),
              child: isItemInCart
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.green),
                          onPressed: () {
                            cartNotifier.decreaseItemQuantity(cartItem!.id);
                          },
                        ),
                        Text(
                          cartItem!.quantity.toString(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () {
                            cartNotifier.increaseItemQuantity(cartItem.id);
                          },
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () {
                        final newCartItem = SharedPreferencesCartItem(
                          name: menuItem.name,
                          price: menuItem.price,
                          quantity: 1,
                          id: menuItem.name,
                          imageUrl: menuItem.imageUrl,
                          category: menuItem.category,
                        );
                        cartNotifier.addItemToCart(newCartItem);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "ADD",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            menuItem.name,
            style: const TextStyle(fontSize: 25, fontFamily: "Poppins"),
          ),
        ),
      ],
    );
  }
}

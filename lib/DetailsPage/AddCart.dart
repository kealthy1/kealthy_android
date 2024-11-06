import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Cart/Cart_Items.dart';
import '../MenuPage/menu_item.dart';
import '../Riverpod/AddCart.dart';
import '../Riverpod/Increment.dart';
import '../Services/FirestoreCart.dart';

class AddToCart extends ConsumerWidget {
  final MenuItem menuItem;

  const AddToCart({required this.menuItem, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cartAnimation = ref.watch(cartAnimationProvider.notifier);
    final cartItems = ref.watch(addCartProvider);
    final quantity = ref.watch(quantityProvider);

    final totalPrice = menuItem.price * quantity;
    final isItemAddedToCart =
        cartItems.any((cartItem) => cartItem.name == menuItem.name);
    final buttonText = isItemAddedToCart ? 'Go To Cart' : 'Add to Cart';

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: screenHeight * 0.02),
        SizedBox(
          width: screenWidth * 0.9,
          child: ElevatedButton(
            onPressed: () async {
              if (buttonText == 'Go To Cart') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ShowCart(),
                  ),
                );
              } else {
                final cartItem = CartItem(
                  id: menuItem.name,
                  name: menuItem.name,
                  price: menuItem.price,
                  imageUrl: menuItem.imageUrl,
                  quantity: quantity,
                  category: menuItem.category,
                );

                ref.read(addCartProvider.notifier).addItem(cartItem);
                cartAnimation.state = true;

                Future.delayed(const Duration(milliseconds: 300), () {
                  cartAnimation.state = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.02,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: isItemAddedToCart
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        buttonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        '₹${totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          ref.read(quantityProvider.notifier).decrement();
                        },
                        child: const Icon(
                          Icons.remove,
                          size: 20.0,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$quantity',
                        style: const TextStyle(
                          fontSize: 20.0,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(quantityProvider.notifier).increment();
                        },
                        child: const Icon(
                          Icons.add,
                          size: 20.0,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.03),
                      Text(
                        buttonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                      Text(
                        '₹${totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

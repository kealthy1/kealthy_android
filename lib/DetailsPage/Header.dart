import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Cart/Cart_Items.dart';
import '../MenuPage/menu_item.dart';
import '../Riverpod/AddCart.dart';
import '../Riverpod/CartItems.dart';
import 'CartAnimation.dart';

class ImageHeader extends ConsumerWidget {
  final MenuItem menuItem;

  const ImageHeader({required this.menuItem, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCartAnimationActive = ref.watch(cartAnimationProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      child: Stack(
        children: [
          Center(
            child: Image.network(
              menuItem.imageUrl,
              height: screenHeight * 0.28,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  AddToCartAnimation(
                    isAdded: isCartAnimationActive,
                    child: IconButton(
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        size: 30,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoModalPopupRoute(
                              builder: (context) => const ShowCart(),
                            ));
                      },
                      color:
                          isCartAnimationActive ? Colors.black : Colors.white,
                    ),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final cartItemCount = ref.watch(addCartProvider).length;
                      return Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.only(top: 1),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 15,
                            minHeight: 15,
                          ),
                          child: Center(
                            child: Text(
                              '$cartItemCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

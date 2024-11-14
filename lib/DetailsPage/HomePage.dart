import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../LandingPage/Cart_Container.dart';
import '../MenuPage/menu_item.dart';
import '../Services/FirestoreCart.dart';
import 'AddCart.dart';
import 'Desc.dart';
import 'Header.dart';
import 'NutritionInfo.dart';

class HomePage extends ConsumerWidget {
  final MenuItem menuItem;
  const HomePage({super.key, required this.menuItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(addCartProvider,
        (_, __) => ref.read(addCartProvider.notifier).fetchCartItems());
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cartItems = ref.watch(sharedPreferencesCartProvider);
    final isVisible = ref.watch(cartVisibilityProvider);

    if (cartItems.isEmpty) {
      ref.read(addCartProvider.notifier).fetchCartItems();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 127, 180, 138),
              Color.fromARGB(255, 11, 99, 40),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.center,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
              bottom: isVisible && cartItems.isNotEmpty ? 1.0 : 0.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 231, 236, 232),
                        Color.fromARGB(255, 11, 99, 40),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: screenWidth * 0.05,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ImageHeader(menuItem: menuItem),
                      RedNutritionSection(menuItem: menuItem),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  // padding: EdgeInsets.symmetric(
                  //   vertical: 16.0,
                  //   horizontal: screenWidth * 0.05,
                  // ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: screenHeight * 0.02),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AddToCart(menuItem: menuItem),
                      ),
                      DescriptionSection(menuItem: menuItem),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: cartItems.isNotEmpty && isVisible
          ? AnimatedOpacity(
              opacity: isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const CartContainer(),
            )
          : null,
    );
  }
}

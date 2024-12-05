import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../LandingPage/Cart_Container.dart';
import '../MenuPage/menu_item.dart';
import '../Services/FirestoreCart.dart';
import 'AddCart.dart';
import 'Header.dart';
import 'NutritionInfo.dart';

class HomePage extends ConsumerWidget {
  final MenuItem menuItem;
  const HomePage({super.key, required this.menuItem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cartItems = ref.watch(sharedPreferencesCartProvider);
    final isVisible = ref.watch(cartVisibilityProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ImageHeader(menuItem: menuItem),
                Transform.translate(
                  offset: Offset(0, -screenHeight * 0.05),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 25,
                            ),
                            RedNutritionSection(menuItem: menuItem),
                            SizedBox(height: screenHeight * 0.02),
                            Divider(
                              color: Colors.grey,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            AddToCart(menuItem: menuItem),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

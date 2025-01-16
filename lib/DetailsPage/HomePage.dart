import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/DetailsPage/ProductInfo.dart';
import 'package:kealthy/DetailsPage/Suggetions.dart';
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
                SizedBox(height: screenHeight * 0.03),
                Transform.translate(
                  offset: Offset(0, -screenHeight * 0.05),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RedNutritionSection(menuItem: menuItem),
                            SizedBox(height: screenHeight * 0.02),
                            Divider(
                              thickness: 2,
                              color: Colors.grey,
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Suggestions(
                                  nameFilter: menuItem.name,
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            AddToCart(menuItem: menuItem),
                            SizedBox(height: screenHeight * 0.02),
                            ProductInfoContainer(menuItem: menuItem),
                            SizedBox(height: screenHeight * 0.02),
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

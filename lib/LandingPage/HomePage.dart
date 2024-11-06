import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/LandingPage/Allitems.dart';
import 'package:kealthy/LandingPage/Myprofile.dart';
import 'package:shimmer/shimmer.dart';
import '../Analysis/Calorie.dart';
import '../MenuPage/DietProvider.dart';
import '../MenuPage/ProductList.dart';
import '../Riverpod/NavBar.dart';
import '../Services/DeliveryIn_Kakkanad.dart';
import '../Services/FirestoreCart.dart';
import 'Cart_Container.dart';
import 'Widgets/Appbar.dart';
import 'Widgets/Carousel.dart';
import 'Widgets/Category.dart';
import '../Diet/Receipe.dart';
import 'Widgets/Serach.dart';
import 'Widgets/floating_bottom_navigation_bar.dart';
import 'Widgets/items.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(deliveryLimitProvider);
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final cartItems = ref.watch(addCartProvider);
    final isVisible = ref.watch(cartVisibilityProvider);
    if (cartItems.isEmpty) {
      ref.read(addCartProvider.notifier).fetchCartItems();
    }
    const int profilePageIndex = 2;
    final List<Widget> pages = [
      _buildHomePage(context, ref),
      const CalorieIntakePage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification) {
            ref.read(cartVisibilityProvider.notifier).setVisible(true);
          } else if (scrollInfo.metrics.axis == Axis.vertical) {
            final isScrollingDown =
                scrollInfo.metrics.pixels > scrollInfo.metrics.minScrollExtent;
            ref
                .read(cartVisibilityProvider.notifier)
                .setVisible(!isScrollingDown);
          }
          return true;
        },
        child: Stack(
          children: [
            pages[currentIndex],
            if (cartItems.isNotEmpty && currentIndex != profilePageIndex)
              Positioned(
                left: 1.0,
                right: 1.0,
                bottom: 1.0,
                child: AnimatedOpacity(
                  opacity: isVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 10),
                  child: const CartContainer(),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        navbarItems: [
          FloatingNavbarItem(icon: Icons.home, title: 'Home'),
          FloatingNavbarItem(
              icon: Icons.analytics_outlined, title: 'Caloriemeter'),
          FloatingNavbarItem(icon: Icons.person_2_outlined, title: 'Profile'),
        ],
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).updateIndex(index);
        },
      ),
    );
  }

  Widget _buildHomePage(BuildContext context, WidgetRef ref) {
    final screenHeight = MediaQuery.of(context).size.height;
    final menuItemsAsyncValue = ref.watch(menuProvider);
    ref.watch(dietProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SearchInput(),
          ),
          const CarouselSliderWidget(),
          SizedBox(height: screenHeight * 0.03),
          _buildCenteredTitle('Category'),
          SizedBox(height: screenHeight * 0.03),
          const CategoryGrid(),
          SizedBox(height: screenHeight * 0.03),
          _buildCenteredTitle('Diets For You'),
          SizedBox(height: screenHeight * 0.03),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: RecipeCardList(),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                CupertinoModalPopupRoute(
                    builder: (context) => const AllItemsPage()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text("Menu"),
                IconButton(
                  color: Colors.white,
                  onPressed: () {},
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          menuItemsAsyncValue.when(
            loading: () => Center(
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  color: Colors.grey[300],
                ),
              ),
            ),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (menuItems) {
              final displayedItems = menuItems
                  .where((item) => item.category != 'Food')
                  .take(5)
                  .toList();

              return Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayedItems.length,
                    itemBuilder: (context, index) {
                      return ItemCard(menuItem: displayedItems[index]);
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                  ),
                ],
              );
            },
          )
        ],
      ),
    );
  }
}

Widget _buildCenteredTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(left: 20, right: 20),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "poppins",
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    ),
  );
}

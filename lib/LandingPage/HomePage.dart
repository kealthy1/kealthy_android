import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:kealthy/Cart/Cart_Items.dart';
import 'package:kealthy/LandingPage/Widgets/Appbar.dart';
import 'package:kealthy/LandingPage/Widgets/Carousel.dart';
import 'package:kealthy/LandingPage/Widgets/SideBar.dart';
import 'package:kealthy/LandingPage/Widgets/items.dart';
import '../Riverpod/NavBar.dart';
import 'Widgets/Category.dart';
import 'Widgets/Serach.dart';
import 'Widgets/floating_bottom_navigation_bar.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final List<Widget> pages = [
      _buildHomePage(context),
      const ShowCart(),
      _buildHomePage(context),
      const ShowCart(),         
    ];

    return Scaffold(
      endDrawer: const Sidebar(),
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: pages[currentIndex], 
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        navbarItems: [
          FloatingNavbarItem(icon: Icons.home, title: 'Kealthy Foods'),
          FloatingNavbarItem(icon: Icons.food_bank,title: 'Kealthy Snacks'),
          FloatingNavbarItem(icon: Icons.shopping_cart, title: 'Cart'),
          FloatingNavbarItem(icon: Icons.settings, title: 'Settings'),
        ],
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).updateIndex(index);
        },
      ),
    );
  }

  Widget _buildHomePage(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SearchInput(),
          ),
          CarouselSliderWidget(),
          SizedBox(height: screenHeight * 0.01),
          const Padding(
            padding: EdgeInsets.only(left: 23),
            child: Text(
              'Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const CategoryGrid(),
          SizedBox(height: screenHeight * 0.03),
          ...List.generate(3, (index) {
            return const Center(
              child: ItemCard(
                imagePath: 'assets/pancakes.jpg',
                title: 'Breakfast',
                itemName: 'Pancakes',
                description: 'Delicious pancakes\n with syrup and fresh fruits.',
                AvatarText: '4.4⭐',
              ),
            );
          }),
          SizedBox(height: screenHeight * 0.1),
        ],
      ),
    );
  }
}

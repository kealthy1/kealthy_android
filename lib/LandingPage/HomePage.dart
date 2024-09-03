import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../MenuPage/ProductList.dart';
import '../Riverpod/NavBar.dart';
import 'Allitems.dart';
import 'Widgets/Appbar.dart';
import 'Widgets/Carousel.dart';
import 'Widgets/Category.dart';
import 'Widgets/Serach.dart';
import 'Widgets/SideBar.dart';
import 'Widgets/floating_bottom_navigation_bar.dart';
import 'Widgets/items.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final List<Widget> pages = [
      _buildHomePage(context, ref),
      _buildHomePage(context, ref),
      const SidebarPage()
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: pages[currentIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        navbarItems: [
          FloatingNavbarItem(icon: Icons.home, title: 'Home'),
          FloatingNavbarItem(
              icon: Icons.food_bank_outlined, title: 'My Orders'),
          FloatingNavbarItem(icon: Icons.settings, title: 'Settings'),
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
          menuItemsAsyncValue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (menuItems) {
              final displayedItems = menuItems.take(5).toList();
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
                  if (menuItems.length > 5)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AllItemsPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child: const Text(
                            'View All',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

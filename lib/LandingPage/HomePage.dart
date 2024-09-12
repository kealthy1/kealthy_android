import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:kealthy/Analysis/Calorie.dart';
import 'package:kealthy/Analysis/DietHomePage.dart';
import 'package:kealthy/MenuPage/DietProvider.dart';
import 'package:shimmer/shimmer.dart';
import '../MenuPage/ProductList.dart';
import '../Riverpod/NavBar.dart';
import 'Allitems.dart';
import 'Widgets/Appbar.dart';
import 'Widgets/Carousel.dart';
import 'Widgets/Category.dart';
import 'Widgets/Receipe.dart';
import 'Widgets/Serach.dart';
import 'Widgets/floating_bottom_navigation_bar.dart';
import 'Widgets/items.dart';

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final List<Widget> pages = [
      _buildHomePage(context, ref),
       const DietHomepage(),
      _buildHomePage(context, ref),
      const CalorieIntakePage()
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: pages[currentIndex],
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        navbarItems: [
          FloatingNavbarItem(icon: FeatherIcons.home, title: 'Home'),
          FloatingNavbarItem(icon: FeatherIcons.activity, title: 'Analysis'),
          FloatingNavbarItem(icon: BootstrapIcons.cart, title: 'My Orders'),
          FloatingNavbarItem(icon: Ionicons.person_outline, title: 'Prfoile'),
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
    final dietItemsAsyncValue = ref.watch(dietProvider);

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
          const Padding(
            padding: EdgeInsets.only(left: 23),
            child: Text(
              'Diets For You',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: dietItemsAsyncValue.when(
              loading: () => Center(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                ),
              ),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (dietItems) {
                return RecipeCardList(
                  dietItems: dietItems,
                );
              },
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
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
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("More"),
                          IconButton(
                              color: Colors.white,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  CupertinoModalPopupRoute(
                                      builder: (context) => const AllItemsPage(
                                            searchQuery: '',
                                          )),
                                );
                              },
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black,
                              )),
                        ],
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

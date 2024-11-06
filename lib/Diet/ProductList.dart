import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/DetailsPage/HomePage.dart';
import 'package:kealthy/Diet/Meal_Container.dart';
import 'package:kealthy/Services/Loading.dart';
import '../../LandingPage/Cart_Container.dart';
import '../../Services/FirestoreCart.dart';
import '../MenuPage/ProductList.dart';
import '../MenuPage/Serach.dart';
import '../MenuPage/menu_item.dart';

class DietProducts extends ConsumerStatefulWidget {
  final String dietName;

  const DietProducts({required this.dietName, super.key});

  @override
  _DietProductsState createState() => _DietProductsState();
}

class _DietProductsState extends ConsumerState<DietProducts> {
  final List<String> messages = [
    "Loading fresh goodness...",
    "Wholesome bites on the way...",
    "Nourishing your body...",
  ];
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(searchProvider.notifier).state = '';
      ref.read(searchQueryProvider.notifier).state = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final randomIndex = Random().nextInt(messages.length);
    final menuItemsAsyncValue = ref.watch(searchAndFilter(widget.dietName));
    final cartItems = ref.watch(addCartProvider);
    final isVisible = ref.watch(cartVisibilityProvider);

    if (cartItems.isEmpty) {
      ref.read(addCartProvider.notifier).fetchCartItems();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Menu'),
      ),
      body: Column(
        children: [
          const SearchAndFilter(),
          Expanded(
            child: menuItemsAsyncValue.when(
              data: (menuItems) {
                if (menuItems.isEmpty) {
                  return const Center(
                    child: Text(
                      'No items found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: menuItems.length,
                  itemBuilder: (ctx, i) {
                    final item = menuItems[i];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoModalPopupRoute(
                              builder: (context) => HomePage(
                                menuItem: MenuItem(
                                  name: item.name,
                                  description: item.description,
                                  imageUrl: item.imageUrl,
                                  kcal: item.kcal,
                                  price: item.price,
                                  carbs: item.carbs,
                                  fat: item.fat,
                                  protein: item.protein,
                                  category: item.category,
                                  time: item.time,
                                  delivery: item.delivery,
                                  rating: item.rating,
                                ),
                              ),
                            ));
                      },
                      child: MealContainer(
                        title: item.name,
                        imageUrl: item.imageUrl,
                        kcal: item.kcal.toInt(),
                        description: item.description,
                        price: item.price.toInt(),
                        carbs: item.carbs.toStringAsFixed(0),
                        fat: item.fat.toStringAsFixed(0),
                        protein: item.protein,
                      ),
                    );
                  },
                );
              },
              loading: () =>
                  Center(child: LoadingWidget(message: messages[randomIndex])),
              error: (err, stack) => Center(
                child: Text('Error: $err'),
              ),
            ),
          ),
          if (cartItems.isNotEmpty)
            AnimatedOpacity(
              opacity: isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: const CartContainer(),
            ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

final searchAndFilter =
    FutureProvider.family<List<MenuItem>, String>((ref, dietName) async {
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase().trim();
  final firestore = FirebaseFirestore.instance;

  Query query =
      firestore.collection('Products').where('Diets', isEqualTo: dietName);

  final querySnapshot = await query.get();

  List<MenuItem> allMenuItems = querySnapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MenuItem.fromFirestore(data);
  }).toList();

  if (searchQuery.isEmpty) {
    return allMenuItems;
  }

  List<MenuItem> filteredMenuItems = allMenuItems.where((item) {
    final itemName = item.name.toLowerCase();
    return itemName.contains(searchQuery);
  }).toList();

  return filteredMenuItems;
});

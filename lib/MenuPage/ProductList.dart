import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kealthy/DetailsPage/HomePage.dart';
import 'menu_item.dart';

final menuProvider = FutureProvider<List<MenuItem>>((ref) async {
  final firestore = FirebaseFirestore.instance;
  final querySnapshot = await firestore.collection('Products').get();

  List<MenuItem> menuItems = [];

  for (var doc in querySnapshot.docs) {
    final data = doc.data();
    final menuItem = MenuItem(
      name: data['Name'],
      price: double.tryParse(data['Price'].toString()) ?? 0.0,
      category: data['Category'],
      time: data['Time'],
      delivery: data['Delivery'],
      description: data['Description'],
      protein: _parseNutrient(data['Protein']),
      carbs: _parseNutrient(data['Carbs']),
      kcal: _parseNutrient(data['Kcal']),
      fat: _parseNutrient(data['Fat']),
      rating: double.tryParse(data['Rating'].toString()) ?? 0.0,
      imageUrl: data['ImageUrl'],
    );
    menuItems.add(menuItem);
  }

  return menuItems;
});

double _parseNutrient(dynamic value) {
  if (value is String) {
    final match = RegExp(r'([\d.]+)').firstMatch(value);
    return match != null ? double.tryParse(match.group(0)!) ?? 0.0 : 0.0;
  }
  return double.tryParse(value.toString()) ?? 0.0;
}

class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItemsAsyncValue = ref.watch(menuProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {},
          ),
        ],
      ),
      body: menuItemsAsyncValue.when(
        data: (menuItems) {
          for (var item in menuItems) {
            precacheImage(NetworkImage(item.imageUrl), context);
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: menuItems.length,
            itemBuilder: (ctx, i) => MenuItemCard(menuItems[i]),
          );
        },
        loading: () {
          return const Center(
            child: SpinKitCircle(
              color: Colors.green,
              size: 100.0,
            ),
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class MenuItemCard extends StatelessWidget {
  final MenuItem menuItem;

  const MenuItemCard(this.menuItem, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                CupertinoModalPopupRoute(
                  builder: (context) => HomePage(menuItem: menuItem),
                ));
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white38,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      menuItem.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;

                        return const Center(child: Text(""));
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Text('Error loading image'));
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menuItem.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${menuItem.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
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

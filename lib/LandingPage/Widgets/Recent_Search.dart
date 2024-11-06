import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kealthy/Cart/Cart_Items.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class FoodMenuNotifier extends StateNotifier<List<DocumentSnapshot>> {
  FoodMenuNotifier() : super([]);

  final int _limit = 10;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  Future<void> fetchMenuItems() async {
    if (!_hasMore) return;

    Query query = FirebaseFirestore.instance
        .collection('Products')
        .orderBy('Name')
        .limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
      _hasMore = snapshot.docs.length == _limit;
      state = [...state, ...snapshot.docs];
    } else {
      _hasMore = false;
    }
  }
}

final foodMenuProvider =
    StateNotifierProvider<FoodMenuNotifier, List<DocumentSnapshot>>((ref) {
  return FoodMenuNotifier()..fetchMenuItems();
});

class FoodMenuPages extends ConsumerStatefulWidget {
  const FoodMenuPages({super.key});

  @override
  ConsumerState<FoodMenuPages> createState() => _FoodMenuPagesState();
}

class _FoodMenuPagesState extends ConsumerState<FoodMenuPages> {
  final Map<String, bool> _addedToCartMap = {};

  @override
  Widget build(BuildContext context) {
    final menuItems = ref.watch(foodMenuProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                ref.read(foodMenuProvider.notifier).fetchMenuItems();
              }
              return true;
            },
            child: _buildFoodList(menuItems),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodList(List<DocumentSnapshot> menuItems) {
    if (menuItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final menuItem = menuItems[index];

        String name = menuItem['Name'] ?? 'Unknown Item';
        String imageUrl = menuItem['ImageUrl'] ?? '';

        double price = (menuItem['Price'] is int)
            ? (menuItem['Price'] as int).toDouble()
            : (menuItem['Price'] as double? ?? 0.0);

        // Check if the item is added to the cart
        bool isAddedToCart =
            _addedToCartMap[menuItem.id] ?? false; // Use menu item ID

        double screenWidth = MediaQuery.of(context).size.width;

        return GestureDetector(
          child: Card(
            elevation: 10,
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Container(
              padding: const EdgeInsets.all(10),
              width: screenWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: screenWidth * 0.25,
                    height: screenWidth * 0.25,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        color: Colors.grey[300],
                        width: screenWidth * 0.25,
                        height: screenWidth * 0.25,
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        '₹${price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (isAddedToCart) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ShowCart()));
                      } else {
                        postMenuItemToApi({
                          'Name': name,
                          'Price': price,
                          'Quantity': 1,
                          'Category': menuItem['Category'],
                          'ImageUrl': imageUrl,
                        });

                        setState(() {
                          _addedToCartMap[menuItem.id] = true;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                    child: Text(
                      isAddedToCart ? 'Go to Cart' : 'Add to Cart',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

const String apiUrl = "https://api-jfnhkjk4nq-uc.a.run.app";

Future<void> postMenuItemToApi(Map<String, dynamic> menuItem) async {
  final prefs = await SharedPreferences.getInstance();
  final phoneNumber = prefs.getString('phoneNumber');

  if (phoneNumber == null) {
    return; // Return early if the phone number is not available.
  }

  try {
    // Construct the data to be posted
    final Map<String, dynamic> data = {
      'phoneNumber': phoneNumber, // Use phone number from SharedPreferences
      'productData': {
        'Name': menuItem['Name'] ?? 'Unknown',
        'Price': menuItem['Price'] ?? 0.0,
        'Quantity':
            menuItem['Quantity'] ?? 1, // Default quantity if not provided
        'Category': menuItem['Category'] ?? 'Uncategorized',
        'ImageUrl': menuItem['ImageUrl'] ?? '',
      },
    };

    final response = await http.post(
      Uri.parse('https://api-jfnhkjk4nq-uc.a.run.app/addcart'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      print('Menu item successfully posted to cart!');
    } else {
      print('Failed to post menu item: ${response.statusCode}');
    }
  } catch (e) {
    print('Error posting menu item: $e');
  }
}

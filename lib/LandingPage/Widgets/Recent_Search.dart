import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kealthy/DetailsPage/HomePage.dart';
import 'package:shimmer/shimmer.dart';

import '../../MenuPage/menu_item.dart';

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
        final menuItemDoc = menuItems[index];

        final menuItem =
            MenuItem.fromFirestore(menuItemDoc.data() as Map<String, dynamic>);

        double screenWidth = MediaQuery.of(context).size.width;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              CupertinoModalPopupRoute(
                builder: (context) => HomePage(
                    menuItem: menuItem),
              ),
            );
          },
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
                    imageUrl: menuItem.imageUrl,
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
                        menuItem.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '₹${menuItem.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
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

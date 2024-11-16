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


        return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                CupertinoModalPopupRoute(
                  builder: (context) => HomePage(menuItem: menuItem),
                ),
              );
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: CachedNetworkImage(
                        height: 100,
                        imageUrl: menuItem.imageUrl,
                        width: double.infinity,
                        placeholder: (context, url) => Center(
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              color: Colors.grey[300],
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            menuItem.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('₹ ${menuItem.price.toStringAsFixed(0)}/-',
                              style: const TextStyle(
                                  fontSize: 18, fontFamily: "Poppins")),
                          Row(
                            children: [
                              const Icon(Icons.energy_savings_leaf_rounded,
                                  size: 18, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(menuItem.nutrients,
                                  style: const TextStyle(
                                      fontSize: 13, fontFamily: "Poppins")),
                            ],
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }
}

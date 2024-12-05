import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import '../../MenuPage/menu_item.dart';
import '../../DetailsPage/HomePage.dart';

class FoodMenuNotifier extends StateNotifier<List<DocumentSnapshot>> {
  FoodMenuNotifier() : super([]);

  final int _initialLimit = 15;
  bool _isFetching = false;
  bool _hasFetchedAll = false;

  bool get showLoadAllButton => !_hasFetchedAll;

  Future<void> fetchInitialMenuItems() async {
    if (_isFetching) return;

    _isFetching = true;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Products')
          .orderBy('Name')
          .limit(_initialLimit)
          .where("SOH", isGreaterThan: 0)
          .get();

      state = snapshot.docs;
      _hasFetchedAll = false;
    } catch (e) {
      print("Error fetching initial menu items: $e");
    } finally {
      _isFetching = false;
    }
  }

  Future<void> fetchAllMenuItems() async {
    if (_isFetching || _hasFetchedAll) return;

    _isFetching = true;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Products')
          .orderBy('Name')
          .where("SOH", isGreaterThan: 0)
          .get();

      state = snapshot.docs;
      _hasFetchedAll = true;
    } catch (e) {
      print("Error fetching all menu items: $e");
    } finally {
      _isFetching = false;
    }
  }
}

final foodMenuProvider =
    StateNotifierProvider<FoodMenuNotifier, List<DocumentSnapshot>>((ref) {
  return FoodMenuNotifier()..fetchInitialMenuItems();
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
    final notifier = ref.read(foodMenuProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: menuItems.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: menuItems.length + 1,
                    itemBuilder: (context, index) {
                      if (index == menuItems.length) {
                        return notifier.showLoadAllButton
                            ? Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: notifier._isFetching
                                      ? null
                                      : () {
                                          notifier.fetchAllMenuItems();
                                        },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        notifier._isFetching
                                            ? "Loading..."
                                            : "See all",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey,
                                            fontFamily: "poppins"),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        notifier._isFetching
                                            ? Icons.hourglass_empty
                                            : Icons.arrow_forward_ios,
                                        color: Colors.grey,
                                      ),
                                      if (notifier._isFetching)
                                        const SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            color: Colors.black,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      }

                      final menuItemDoc = menuItems[index];
                      final menuItem = MenuItem.fromFirestore(
                          menuItemDoc.data() as Map<String, dynamic>);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoModalPopupRoute(
                              builder: (context) =>
                                  HomePage(menuItem: menuItem),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 8.0),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      Text(
                                        '₹ ${menuItem.price.toStringAsFixed(0)}/-',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontFamily: "Poppins"),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                              Icons.energy_savings_leaf_rounded,
                                              size: 18,
                                              color: Colors.green),
                                          const SizedBox(width: 4),
                                          Text(menuItem.nutrients,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontFamily: "Poppins")),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

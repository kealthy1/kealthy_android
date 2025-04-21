import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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
                ? SizedBox.shrink()
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.67,
                    ),
                    itemCount:
                        menuItems.length + (notifier.showLoadAllButton ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == menuItems.length &&
                          notifier.showLoadAllButton) {
                        return InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: notifier._isFetching
                              ? null
                              : () {
                                  notifier.fetchAllMenuItems();
                                },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                notifier._isFetching ? "Loading..." : "See all",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Icon(
                                notifier._isFetching
                                    ? Icons.hourglass_empty
                                    : Icons.arrow_forward_ios,
                                color: Colors.grey,
                              ),
                              if (notifier._isFetching)
                                SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: LoadingAnimationWidget.inkDrop(
                                    color: Color(0xFF273847),
                                    size: 30,
                                  ),
                                ),
                            ],
                          ),
                        );
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: CachedNetworkImage(
                                    cacheManager: DefaultCacheManager(),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    imageUrl: menuItem.imageUrls[0],
                                    placeholder: (context, url) =>
                                        Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        menuItem.name,
                                        style: GoogleFonts.montserrat(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '₹ ${menuItem.price.toStringAsFixed(0)}/-',
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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

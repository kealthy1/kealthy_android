import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../LandingPage/Cart_Container.dart';
import '../Services/FirestoreCart.dart';
import 'Card.dart';
import 'menu_item.dart';

final refreshTriggerProvider = StateProvider<bool>((ref) => false);

final veganDietProvider =
    StateNotifierProvider<VeganDietNotifier, List<MenuItem>>(
        (ref) => VeganDietNotifier(ref));
final loadingProvider = StateProvider<bool>((ref) => false);
final cartVisibilityProvider = StateProvider<bool>((ref) => true);
final selectedBrandProvider = StateProvider<String?>((ref) => null);
final brandsProvider =
    FutureProvider.family<List<String>, String>((ref, category) async {
  return ref.read(veganDietProvider.notifier).fetchUniqueBrands(category);
});

class VeganDietNotifier extends StateNotifier<List<MenuItem>> {
  final Ref ref;

  VeganDietNotifier(this.ref) : super([]);

  Future<void> fetchAllMeals(String category) async {
    try {
      ref.read(loadingProvider.notifier).state = true;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Products')
          .where('Subcategory', isEqualTo: category)
          // .where('SOH', isNotEqualTo: 0)
          .get();

      state = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return MenuItem.fromFirestore(data);
      }).toList();
    } catch (e) {
      state = [];
      debugPrint('Error fetching meals: $e');
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  void filterMeals(String searchQuery, String category) async {
    if (searchQuery.isEmpty) {
      fetchAllMeals(category);
      return;
    }

    try {
      ref.read(loadingProvider.notifier).state = true;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Products')
          .where('Subcategory', isEqualTo: category)
          // .where('SOH', isNotEqualTo: 0)
          .get();

      final filteredMeals = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return MenuItem.fromFirestore(data);
      }).where((menuItem) {
        return menuItem.name.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();

      state = filteredMeals;
    } catch (e) {
      debugPrint('Error filtering meals: $e');
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  Future<void> fetchByBrand(String brandName, String category) async {
    try {
      ref.read(loadingProvider.notifier).state = true;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Products')
          .where('Subcategory', isEqualTo: category)
          .where('Brand Name', isEqualTo: brandName)
          .get();

      state = querySnapshot.docs
          .map((doc) => MenuItem.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      state = [];
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  Future<List<String>> fetchUniqueBrands(String category) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Products')
          .where('Subcategory', isEqualTo: category)
          .get();

      return querySnapshot.docs
          .map((doc) => doc.data()['Brand Name'] as String)
          .toSet()
          .toList();
    } catch (e) {
      return [];
    }
  }
}

class MenuPage extends ConsumerStatefulWidget {
  final String categoryName;

  const MenuPage({super.key, required this.categoryName});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(veganDietProvider.notifier).fetchAllMeals(widget.categoryName);
    });

    focusNode.addListener(() async {
      if (!focusNode.hasFocus && searchController.text.isEmpty) {
        ref.read(veganDietProvider.notifier).fetchAllMeals(widget.categoryName);
        await ref.read(brandsProvider(widget.categoryName).future);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuItems = ref.watch(veganDietProvider);
    final cartItems = ref.watch(sharedPreferencesCartProvider);
    final isVisible = ref.watch(cartVisibilityProvider);
    final isLoading = ref.watch(loadingProvider);
    ref.watch(selectedBrandProvider);
    final brandsAsyncValue = ref.watch(brandsProvider(widget.categoryName));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Menu',
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 20,
          ),
          _buildSearchBar(ref),
          SizedBox(
            height: 20,
          ),
          brandsAsyncValue.when(
            data: (brands) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                    alignment: Alignment.topLeft,
                    child: _buildBrandFilter(ref, brands)),
              ],
            ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('...'),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo is UserScrollNotification) {
                  ref.read(cartVisibilityProvider.notifier).state =
                      scrollInfo.direction == ScrollDirection.idle;
                }
                return true;
              },
              child: isLoading
                  ? Center(
                      child: LoadingAnimationWidget.inkDrop(
                        color: Color(0xFF273847),
                        size: 60,
                      ),
                    )
                  : menuItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.exclamationmark_circle,
                                size: 60,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'No items found.',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 0,
                            childAspectRatio: 0.6,
                          ),
                          itemCount: menuItems.length,
                          itemBuilder: (context, index) {
                            final menuItem = menuItems[index];
                            return MenuItemCard(menuItem);
                          },
                        ),
            ),
          ),
          if (cartItems.isNotEmpty && isVisible) const CartContainer(),
        ],
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: TypeAheadField<Map<String, String>>(
        autoFlipDirection: true,
        hideKeyboardOnDrag: true,
        hideWithKeyboard: true,
        suggestionsCallback: (pattern) async {
          if (pattern.isEmpty) {
            return [];
          }
          final querySnapshot = await FirebaseFirestore.instance
              .collection('Products')
              .where('Subcategory', isEqualTo: widget.categoryName)
              // .where('SOH', isNotEqualTo: 0)
              .get();
          print(widget.categoryName);
          return querySnapshot.docs
              .map((doc) {
                final data = doc.data();
                return {
                  'title': data['Name'].toString(),
                  'imageUrl': (data['ImageUrl'] as List).isNotEmpty == true
                      ? data['ImageUrl'][0].toString()
                      : '',
                };
              })
              .where((item) =>
                  item['title']!.toLowerCase().contains(pattern.toLowerCase()))
              .toList();
        },
        itemBuilder: (context, suggestion) {
          final title = suggestion['title'] ?? 'Unknown';
          final imageUrl = suggestion['imageUrl'] ?? '';

          return ListTile(
            contentPadding: EdgeInsets.all(8),
            leading: imageUrl.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          cacheManager: DefaultCacheManager(),
                          imageUrl: imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : const Icon(Icons.image, size: 50),
            title: Text(
              title,
              style: GoogleFonts.poppins(),
            ),
          );
        },
        onSelected: (suggestion) {
          searchController.text = suggestion['title'] ?? '';
          ref
              .read(veganDietProvider.notifier)
              .filterMeals(suggestion['title'] ?? '', widget.categoryName);
        },
        emptyBuilder: (context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No items found',
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.sentiment_dissatisfied_sharp,
                  color: Colors.grey,
                  size: 25,
                ),
              ],
            ),
          );
        },
        decorationBuilder: (context, child) {
          return Material(
            type: MaterialType.card,
            elevation: 4,
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            child: child,
          );
        },
        offset: const Offset(0, 12),
        constraints: const BoxConstraints(maxHeight: 400, maxWidth: 430),
        builder: (context, controller, focusNode) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 1,
                    blurRadius: 2,
                  ),
                ],
              ),
              child: TextField(
                cursorColor: Colors.black,
                controller: controller,
                focusNode: focusNode,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 12.0,
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    border: InputBorder.none,
                    hintText: 'Search For Products',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        controller.clear();
                        ref
                            .read(veganDietProvider.notifier)
                            .fetchAllMeals(widget.categoryName);
                      },
                    ),
                    labelStyle: GoogleFonts.poppins(color: Colors.green)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrandFilter(WidgetRef ref, List<String> brands) {
    final selectedBrand = ref.watch(selectedBrandProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: brands.map((brand) {
            final isSelected = selectedBrand == brand;
            return GestureDetector(
              onTap: () {
                ref.read(selectedBrandProvider.notifier).state = brand;
                ref
                    .read(veganDietProvider.notifier)
                    .fetchByBrand(brand, widget.categoryName);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF273847) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
                child: Text(
                  brand,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

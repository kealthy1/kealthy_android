import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Services/Loading.dart';
import '../../LandingPage/Cart_Container.dart';
import '../../Services/FirestoreCart.dart';
import 'Card.dart';
import 'Search_provider.dart';
import 'Serach.dart';
import 'menu_item.dart';

final searchAndFilterProvider =
    FutureProvider.family<List<MenuItem>, String>((ref, categoryName) async {
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase().trim();
  final firestore = FirebaseFirestore.instance;
  Query query = firestore
      .collection('Products')
      .where('Category', isEqualTo: categoryName);

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

class MenuPage extends ConsumerStatefulWidget {
  final String categoryName;

  const MenuPage({super.key, required this.categoryName});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
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
    final menuItemsAsyncValue =
        ref.watch(searchAndFilterProvider(widget.categoryName));
    final cartItems = ref.watch(sharedPreferencesCartProvider);
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
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo is UserScrollNotification) {
                  if (scrollInfo.direction == ScrollDirection.idle) {
                    ref.read(cartVisibilityProvider.notifier).setVisible(true);
                  } else {
                    ref.read(cartVisibilityProvider.notifier).setVisible(false);
                  }
                }
                return true;
              },
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
                    itemBuilder: (ctx, i) => MenuItemCard(menuItems[i]),
                  );
                },
                loading: () => const Center(
                    child:
                        LoadingWidget(message: "Harvesting health for you...")),
                error: (err, stack) => Center(
                  child: Text('Error: $err'),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
      bottomSheet: cartItems.isNotEmpty && isVisible
          ? AnimatedOpacity(
              opacity: isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const CartContainer(),
            )
          : null,
    );
  }
}

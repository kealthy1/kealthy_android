import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Services/Loading.dart';
import '../../LandingPage/Cart_Container.dart';
import '../../Services/FirestoreCart.dart';
import '../Card.dart';
import '../ProductList.dart';
import '../Serach.dart';

class DrinksMenuPage extends ConsumerStatefulWidget {
  const DrinksMenuPage({super.key});

  @override
  _FoodMenuPageState createState() => _FoodMenuPageState();
}

class _FoodMenuPageState extends ConsumerState<DrinksMenuPage> {
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
    final menuItemsAsyncValue = ref.watch(searchAndFilterProvider);
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
          if (cartItems.isNotEmpty)
            AnimatedOpacity(
              opacity: isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: const CartContainer(),
            ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}

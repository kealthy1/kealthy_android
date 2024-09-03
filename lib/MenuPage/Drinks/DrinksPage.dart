import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../Card.dart';
import '../ProductList.dart';
import '../Serach.dart';

class DrinksMenuPage extends ConsumerWidget {
  const DrinksMenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItemsAsyncValue = ref.watch(menuProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SearchAndFilter(),
          Expanded(
            child: menuItemsAsyncValue.when(
              data: (menuItems) {
                final snacksItems = menuItems
                    .where((item) => item.category == 'Drinks')
                    .toList();

                for (var item in snacksItems) {
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
                  itemCount: snacksItems.length,
                  itemBuilder: (ctx, i) => MenuItemCard(snacksItems[i]),
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
          ),
        ],
      ),
    );
  }
}

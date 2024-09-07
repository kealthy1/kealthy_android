import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/LandingPage/Widgets/Search%20All.dart';
import 'package:shimmer/shimmer.dart';
import 'Widgets/items.dart';
import '../MenuPage/ProductList.dart';

class AllItemsPage extends ConsumerWidget {
  final String searchQuery;

  const AllItemsPage({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allMenuItems = ref.watch(menuProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('All Items'),
        backgroundColor: Colors.green[400],
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 8,
          ),
          SearchBarall(),
          Expanded(
            child: allMenuItems.when(
              loading: () => Center(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    color: Colors.grey[300],
                  ),
                ),
              ),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (items) {
                final filteredItems = items
                    .where((item) => item.name
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ItemCard(menuItem: filteredItems[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'Widgets/items.dart';
import '../MenuPage/ProductList.dart';

class AllItemsPage extends ConsumerWidget {
  const AllItemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allMenuItems = ref.watch(menuProvider);

    return Scaffold(
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
      body: allMenuItems.when(
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
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ItemCard(menuItem: items[index]),
              );
            },
          );
        },
      ),
    );
  }
}

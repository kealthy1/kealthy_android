import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/LandingPage/Widgets/Search%20All.dart';
import 'package:shimmer/shimmer.dart';
import '../MenuPage/ProductList.dart';
import 'Widgets/Recent_Search.dart';
import 'Widgets/items.dart';
import 'Widgets/searchprovider.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

class AllItemsPage extends ConsumerWidget {
  const AllItemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allMenuItems = ref.watch(menuProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final recentSearches = ref.watch(recentSearchesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'All Items',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[400],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 8,
          ),
          SearchBarall(
            onSearch: (query) async {
              if (query.isNotEmpty) {
                ref.read(searchQueryProvider.notifier).state = query;
                await ref
                    .read(recentSearchesProvider.notifier)
                    .addSearch(query);
              } else {
                ref.read(searchQueryProvider.notifier).state = '';
              }
            },
          ),
          const SizedBox(
            height: 10,
          ),
          if (recentSearches.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: "poppins"),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentSearches.length,
                      itemBuilder: (context, index) {
                        final search = recentSearches[index];
                        return GestureDetector(
                          onTap: () {
                            ref.read(searchQueryProvider.notifier).state =
                                search;
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.history,
                                    size: 16, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  search,
                                  style: const TextStyle(color: Colors.green),
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
            ),
          Expanded(
            child: allMenuItems.when(
              loading: () => Center(
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    color: Colors.grey[300],
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (items) {
                if (searchQuery.isEmpty) {
                  return const Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "POPULAR",
                          style: TextStyle(
                              color: Colors.black,
                              fontFamily: "poppins",
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                       Expanded(child: FoodMenuPages())
                    ],
                  );
                }
                final filteredItems = items
                    .where((item) => item.name
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                    .toList();

                if (filteredItems.isEmpty) {
                  return const Center(
                      child: Text('No items match your search'));
                }

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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/LandingPage/HomePage.dart';
import 'package:kealthy/LandingPage/Widgets/Recent_Search.dart';
import '../MenuPage/Search_provider.dart';
import '../MenuPage/menu_item.dart';
import 'Widgets/Search All.dart';
import 'Widgets/items.dart';
import 'Widgets/searchprovider.dart';

final noSuggestionsLoadingProvider = StateProvider<bool>((ref) => true);

class AllItemsPage extends ConsumerStatefulWidget {
  const AllItemsPage({super.key});

  @override
  _AllItemsPageState createState() => _AllItemsPageState();
}

class _AllItemsPageState extends ConsumerState<AllItemsPage> {
  MenuItem? selectedItem;

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);
    final recentSearches = ref.watch(recentSearchesProvider);
    final productSuggestions = ref.watch(productProvider);

    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: () async {
          // ignore: unused_result
          ref.refresh(searchQueryProvider);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
            (route) => false,
          );
          return false;
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: const Text(
                'Search Healthy Recipes',
                style: TextStyle(color: Colors.black, fontFamily: "poppins"),
              ),
            ),
            body: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                FocusScope.of(context).unfocus();
                return false; 
              },
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  SearchBarall(
                    onSearch: (query) async {
                      ref.read(noSuggestionsLoadingProvider.notifier).state =
                          true;
                      ref.read(searchQueryProvider.notifier).state = query;
                      await ref
                          .read(productProvider.notifier)
                          .fetchProductSuggestions(query);
                    },
                  ),
                  const SizedBox(height: 10),
                  if (recentSearches.isNotEmpty && searchQuery.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "poppins",
                            ),
                          ),
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recentSearches.length,
                              itemBuilder: (context, index) {
                                final search = recentSearches[index];
                                return GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(searchQueryProvider.notifier)
                                        .state = search;
                                    ref
                                        .read(productProvider.notifier)
                                        .fetchProductSuggestions(search);
                                  },
                                  onLongPress: () {
                                    _showDeleteConfirmationDialog(
                                      context,
                                      search,
                                      ref,
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8.0),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 8.0,
                                    ),
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
                                          style: const TextStyle(
                                              color: Colors.green),
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
                  Flexible(
                    child: Builder(
                      builder: (context) {
                        if (searchQuery.isEmpty) {
                          return FoodMenuPages();
                        }

                        if (productSuggestions.isEmpty) {
                          return buildNoSuggestionsFallback();
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(4),
                          itemCount: productSuggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion = productSuggestions[index];
                            return GestureDetector(
                              onTap: () async {
                                await ref
                                    .read(recentSearchesProvider.notifier)
                                    .addSearch(suggestion.name);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ItemCard(
                                      menuItem: suggestion.toMenuItem(),
                                      Search: suggestion.name,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 80,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: CachedNetworkImage(
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        imageUrl: suggestion.imageUrl,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            suggestion.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            suggestion.category,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String search, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        title: const Text("Recent Search"),
        content:
            Text("Are you sure you want to delete '$search' from recents?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(recentSearchesProvider.notifier).removeSearch(search);
              Navigator.pop(context);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNoSuggestionsFallback() {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(noSuggestionsLoadingProvider);
        Future.delayed(const Duration(seconds: 5), () {
          if (isLoading) {
            ref.read(noSuggestionsLoadingProvider.notifier).state = false;
          }
        });

        return Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.green)
              : const Text(
                  'No matching options found. Try a different search!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: "poppins",
                  ),
                ),
        );
      },
    );
  }
}

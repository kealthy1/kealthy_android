import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/LandingPage/Widgets/Recent_Search.dart';
import 'package:kealthy/LandingPage/Widgets/floating_bottom_navigation_bar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
import '../MenuPage/Search_provider.dart';
import '../MenuPage/menu_item.dart';
import '../Services/Cache.dart';
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
            MaterialPageRoute(
                builder: (context) => CustomBottomNavigationBar()),
            (route) => false,
          );
          return false;
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.white,
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Text(
                'Search Healthy Products',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 20,
                ),
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
                          Text(
                            'Recent Searches',
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 16,
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
                                        horizontal: 8.0,
                                        vertical: 5.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.history,
                                              size: 16,
                                              color: Color.fromARGB(
                                                  255, 17, 20, 17)),
                                          const SizedBox(width: 4),
                                          Text(
                                            search,
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              _showDeleteConfirmationDialog(
                                                  context, search, ref);
                                            },
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.red,
                                            ),
                                            iconSize: 16,
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            padding: EdgeInsets.zero,
                                          ),
                                        ],
                                      ),
                                    ));
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
                                final recentSearchesNotifier =
                                    ref.read(recentSearchesProvider.notifier);
                                final name = suggestion.name;

                                await recentSearchesNotifier.addSearch(name);

                                if (context.mounted) {
                                  Navigator.push(
                                    context,
                                    CupertinoModalPopupRoute(
                                      builder: (context) => ItemCard(
                                        menuItem: suggestion.toMenuItem(),
                                        Search: name,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            blurRadius: 4.0,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          cacheManager: CustomCacheManager(),
                                          fit: BoxFit.fill,
                                          imageUrl: suggestion.imageUrls[0],
                                          placeholder: (context, url) => Center(
                                            child: Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Container(
                                                height: 100,
                                                color: Colors.grey[300],
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error,
                                                  color: Colors.red),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            suggestion.name,
                                            style: GoogleFonts.poppins(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            suggestion.category,
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey,
                                              fontSize: 12,
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text("Recent Search"),
        content:
            Text("Are you sure you want to delete '$search' from recents?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(recentSearchesProvider.notifier).removeSearch(search);
              Navigator.pop(context);
            },
            child: Text(
              "Delete",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNoSuggestionsFallback() {
    final isLoading = ref.watch(noSuggestionsLoadingProvider);

    if (isLoading) {
      Timer(const Duration(seconds: 5), () {
        if (mounted) {
          ref.read(noSuggestionsLoadingProvider.notifier).state = false;
        }
      });
    }

    return Center(
      child: isLoading
          ? LoadingAnimationWidget.inkDrop(color: Color(0xFF273847), size: 50)
          : Text(
              'No matching options found. Try a different search!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Create a class to hold product suggestion details
class ProductSuggestion {
  final String name;
  final String imageUrl;

  ProductSuggestion({required this.name, required this.imageUrl});
}

// StateNotifierProvider for managing product suggestions
final productProvider =
    StateNotifierProvider<ProductSuggestionsNotifier, List<ProductSuggestion>>(
        (ref) {
  return ProductSuggestionsNotifier(ref);
});

// StateNotifier class for fetching product suggestions
class ProductSuggestionsNotifier
    extends StateNotifier<List<ProductSuggestion>> {
  ProductSuggestionsNotifier(this.ref) : super([]);

  final Ref ref;

  Future<void> fetchProductSuggestions(String query) async {
    if (query.isEmpty) {
      state = [];
      return;
    }

    // Normalize the input query
    final normalizedQuery = query.trim().toLowerCase();

    try {
      // Fetch all products from Firestore
      final snapshot =
          await FirebaseFirestore.instance.collection('Products').get();

      // Map the fetched documents to ProductSuggestion objects
      final filteredProducts = snapshot.docs
          .map((doc) {
            return ProductSuggestion(
              name: doc['Name'] as String,
              imageUrl: doc['ImageUrl'] as String,
            );
          })
          .where(
              (product) => product.name.toLowerCase().contains(normalizedQuery))
          .toList();

      state = filteredProducts;
    } catch (e) {
      print("Error fetching product suggestions: $e");
      state = [];
    }
  }
}


final recentSearchesProvider = StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  return RecentSearchesNotifier();
});

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier() : super([]) {
    loadSearches();
  }

  Future<void> loadSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList('recentSearches') ?? [];
    state = searches;
  }

  Future<void> addSearch(String search) async {
    if (!state.contains(search)) {
      state = [search, ...state];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('recentSearches', state);
    }
  }

  Future<void> clearSearches() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recentSearches');
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../MenuPage/menu_item.dart';

class ProductSuggestion {
  final String name;
  final String id;
  final double price;
  final String category;
  final String time;
  final String delivery;
  final String description;
  final double protein;
  final double carbs;
  final double kcal;
  final double fat;
  final double rating;
  final String imageUrl;
  final String nutrients;

  ProductSuggestion({
    required this.name,
    required this.id,
    required this.price,
    required this.category,
    required this.time,
    required this.delivery,
    required this.description,
    required this.protein,
    required this.carbs,
    required this.kcal,
    required this.fat,
    required this.rating,
    required this.imageUrl,
    required this.nutrients,
  });

  factory ProductSuggestion.fromFirestore(Map<String, dynamic> data) {
    return ProductSuggestion(
      name: data['Name'] ?? '',
      price: _parseDouble(data['Price']),
      category: data['Category'] ?? '',
      time: data['Time'] ?? '',
      delivery: data['Delivery'] ?? '',
      description: data['Description'] ?? '',
      protein: _parseDouble(data['Protein']),
      carbs: _parseDouble(data['Carbs']),
      kcal: _parseDouble(data['Kcal']),
      fat: _parseDouble(data['Fat']),
      rating: _parseDouble(data['Rating']),
      imageUrl: data['ImageUrl'] ?? '',
      nutrients: data['nutrients'] ?? '',
      id: data['Name'],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      String cleanedValue = value.replaceAll('g', '').trim();
      if (cleanedValue.startsWith('.')) {
        cleanedValue = '0$cleanedValue';
      }
      return double.tryParse(cleanedValue) ?? 0.0;
    }
    return 0.0;
  }

  MenuItem toMenuItem() {
    return MenuItem(
      name: name,
      price: price,
      category: category,
      time: time,
      delivery: delivery,
      description: description,
      protein: protein,
      carbs: carbs,
      kcal: kcal,
      fat: fat,
      rating: rating,
      imageUrl: imageUrl,
      nutrients: nutrients,
    );
  }
}

final productProvider =
    StateNotifierProvider<ProductSuggestionsNotifier, List<ProductSuggestion>>(
        (ref) {
  return ProductSuggestionsNotifier(ref);
});
class ProductState {
  final bool isLoading;
  final List<String> suggestions;

  ProductState({this.isLoading = false, this.suggestions = const []});

  ProductState copyWith({bool? isLoading, List<String>? suggestions}) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}
class ProductSuggestionsNotifier
    extends StateNotifier<List<ProductSuggestion>> {
  ProductSuggestionsNotifier(this.ref) : super([]);

  final Ref ref;

  Future<void> fetchProductSuggestions(String query) async {
  if (query.isEmpty) {
    state = [];
    return;
  }

  final normalizedQuery = query.trim().toLowerCase();

  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('Products').get();

    final uniqueProducts = <String, ProductSuggestion>{};

    for (final doc in snapshot.docs) {
      final product = ProductSuggestion.fromFirestore(doc.data());

      if (product.name.toLowerCase().contains(normalizedQuery) ||
          product.category.toLowerCase().contains(normalizedQuery)) {
        uniqueProducts[product.id] = product;
      }
    }

    state = uniqueProducts.values.toList();
  } catch (e) {
    print("Error fetching product suggestions: $e");
    state = [];
  }
}
}

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
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

  Future<void> removeSearch(String search) async {
    state = state.where((item) => item != search).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recentSearches', state);
  }
}

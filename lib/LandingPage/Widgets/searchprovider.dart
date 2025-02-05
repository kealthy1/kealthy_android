import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../MenuPage/menu_item.dart';

class ProductSuggestion {
  final String name;
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
  final List<String> imageUrls;
  final String whatIsIt;
  final String whatIsItUsedFor;
  final List<String> macros;
  final List<String> micros;
  final List<String> ingredients;
  final String addedSugars;
  final String additivesPreservatives;
  final String artificialSweetenersColors;
  final String brandName;
  final String dietaryFiber;
  final String ecoFriendly;
  final String energy;
  final String glutenFree;
  final String kealthyScore;
  final String ketoFriendly;
  final String lowGi;
  final String lowSugar;
  final String productCode;
  final String qty;
  final String recyclablePackaging;
  final String saturatedFat;
  final String subcategory;
  final String sugars;
  final String totalCarbohydrates;
  final String totalFat;
  final String transFat;
  final String unsaturatedFat;
  final String veganFriendly;
  final String vendorName;
  final double SOH;
  final List<String> FSSAI;
  final String EAN;
  final String Orgin;
  final String ManufacturerAddress;
  final String Manufactureddate;
  final String Type;
  final String Expiry;
  final String ImportedMarketedBy;

  ProductSuggestion({
    required this.name,
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
    required this.imageUrls,
    required this.macros,
    required this.micros,
    required this.ingredients,
    required this.whatIsIt,
    required this.whatIsItUsedFor,
    required this.addedSugars,
    required this.additivesPreservatives,
    required this.artificialSweetenersColors,
    required this.brandName,
    required this.dietaryFiber,
    required this.ecoFriendly,
    required this.energy,
    required this.glutenFree,
    required this.kealthyScore,
    required this.ketoFriendly,
    required this.lowGi,
    required this.lowSugar,
    required this.productCode,
    required this.qty,
    required this.recyclablePackaging,
    required this.saturatedFat,
    required this.subcategory,
    required this.sugars,
    required this.totalCarbohydrates,
    required this.totalFat,
    required this.transFat,
    required this.unsaturatedFat,
    required this.veganFriendly,
    required this.vendorName,
    required this.SOH,
    required this.FSSAI,
    required this.EAN,
    required this.Manufactureddate,
    required this.ManufacturerAddress,
    required this.Orgin,
    required this.Type,
    required this.Expiry,
    required this.ImportedMarketedBy,
  });

  factory ProductSuggestion.fromFirestore(Map<String, dynamic> data) {
    return ProductSuggestion(
      name: data['Name'] ?? '',
      price: _parseDouble(data['Price']),
      SOH: _parseDouble(data['SOH']),
      category: data['Category'] ?? '',
      EAN: data['EAN'] ?? '',
      time: data['Time'] ?? '',
      delivery: data['Delivery'] ?? '',
      description: data['Description'] ?? '',
      protein: _parseDouble(data['Protein']),
      carbs: _parseDouble(data['Carbs']),
      kcal: _parseDouble(data['Kcal']),
      fat: _parseDouble(data['Fat']),
      rating: _parseDouble(data['Rating']),
      imageUrls: List<String>.from(data['ImageUrl'] ?? []),
      FSSAI: List<String>.from(data['FSSAI'] ?? []),
      macros: [
        'Protein: ${data['Protein (g)'] ?? 'Not Applicable'}',
        'Total Fat: ${data['Total Fat (g)'] ?? 'Not Applicable'}',
        'Carbohydrates: ${data['Total Carbohydrates (g)'] ?? 'Not Applicable'}',
        'Sugars: ${data['Sugars (g)'] ?? 'Not Applicable'}',
        'Cholesterol: ${data['Cholesterol (mg)'] ?? 'Not Applicable'}',
        'Added Sugars: ${data['Added Sugars (g)'] ?? 'Not Applicable'}',
      ],
      micros: List<String>.from(data['Micronutrients'] ?? []),
      ingredients: List<String>.from(data['Ingredients'] ?? []),
      whatIsIt: data['What is it?'] ?? '',
      whatIsItUsedFor: data['What is it used for?'] ?? '',
      addedSugars: data['Added Sugars (g)'] ?? 'Not Applicable',
      additivesPreservatives:
          data['Additives/Preservatives'] ?? 'Not Applicable',
      artificialSweetenersColors:
          data['Artificial Sweeteners?Colors'] ?? 'Not Applicable',
      brandName: data['Brand Name'] ?? '',
      dietaryFiber: data['Dietary Fiber (g)'] ?? 'Not Applicable',
      ecoFriendly: data['Eco-Friendly'] ?? '',
      energy: data['Energy (kcal)'] ?? 'Not Applicable',
      glutenFree: data['Gluten-free'] ?? 'Not Applicable',
      kealthyScore: data['Kealthy Score'] ?? '',
      ketoFriendly: data['Keto Friendly'] ?? 'Not Applicable',
      lowGi: data['Low GI'] ?? 'Not Applicable',
      lowSugar:
          data['Low Sugar (less than 5g per serving)'] ?? 'Not Applicable',
      productCode: data['Product code'] ?? '',
      qty: data['Qty'] ?? '',
      recyclablePackaging: data['Recyclable Packaging'] ?? '',
      saturatedFat: data['Saturated Fat (g)'] ?? 'Not Applicable',
      subcategory: data['Subcategory'] ?? '',
      sugars: data['Sugars (g)'] ?? 'Not Applicable',
      totalCarbohydrates: data['Total Carbohydrates (g)'] ?? 'Not Applicable',
      totalFat: data['Total Fat (g)'] ?? 'Not Applicable',
      transFat: data['Trans Fat (g)'] ?? 'Not Applicable',
      unsaturatedFat: data['Unsaturated Fat (g)'] ?? 'Not Applicable',
      veganFriendly: data['Vegan-Friendly'] ?? '',
      vendorName: data['Vendor Name'] ?? '',
      Type: data['Type'] ?? '',
      Orgin: data['Orgin'] ?? '',
      ManufacturerAddress: data['Manufacturer Address'] ?? '',
      Manufactureddate: data['Manufactured date'] ?? '',
      Expiry: data['Expiry'] ?? '',
      ImportedMarketedBy: data['Imported&Marketed By'] ?? '',
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
      imageUrls: imageUrls,
      macros: macros,
      ingredients: ingredients,
      micros: micros,
      SOH: SOH,
      whatIsIt: whatIsIt,
      whatIsItUsedFor: whatIsItUsedFor,
      addedSugars: addedSugars,
      additivesPreservatives: additivesPreservatives,
      artificialSweetenersColors: artificialSweetenersColors,
      brandName: brandName,
      dietaryFiber: dietaryFiber,
      ecoFriendly: ecoFriendly,
      energy: energy,
      glutenFree: glutenFree,
      kealthyScore: kealthyScore,
      ketoFriendly: ketoFriendly,
      lowGi: lowGi,
      lowSugar: lowSugar,
      productCode: productCode,
      qty: qty,
      recyclablePackaging: recyclablePackaging,
      saturatedFat: saturatedFat,
      subcategory: subcategory,
      sugars: sugars,
      totalCarbohydrates: totalCarbohydrates,
      totalFat: totalFat,
      transFat: transFat,
      unsaturatedFat: unsaturatedFat,
      veganFriendly: veganFriendly,
      vendorName: vendorName,
      EAN: EAN,
      FSSAI: FSSAI,
      Manufactureddate: Manufactureddate,
      ManufacturerAddress: ManufacturerAddress,
      Orgin: Orgin,
      Type: Type,
      Expiry: Expiry,
      ImportedMarketedBy: ImportedMarketedBy,
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
    final queryTokens = normalizedQuery.split(' ');

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Products')
          .where('SOH', isNotEqualTo: 0)
          .get();

      final uniqueProducts = <String, ProductSuggestion>{};

      for (final doc in snapshot.docs) {
        final product = ProductSuggestion.fromFirestore(doc.data());
        final nameTokens = product.name.toLowerCase().split(' ');
        final categoryTokens = product.category.toLowerCase().split(' ');

        final matches = queryTokens.every((token) =>
            nameTokens.any((nameToken) => nameToken.contains(token)) ||
            categoryTokens
                .any((categoryToken) => categoryToken.contains(token)));

        if (matches) {
          uniqueProducts[product.name] = product;
        }
      }

      state = uniqueProducts.values.toList();
      print("Matched Products: ${state.map((p) => p.name).toList()}");
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

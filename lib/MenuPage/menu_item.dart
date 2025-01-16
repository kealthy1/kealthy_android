import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
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
  final double soh;
  final List<String> macros;
  final List<String> micros;
  final List<String> ingredients;
  final String addedSugars;
  final String additivesPreservatives;
  final String artificialSweetenersColors;
  final String brandName;
  final String hsn;
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

  MenuItem({
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
    required this.soh,
    required this.macros,
    required this.micros,
    required this.ingredients,
    required this.whatIsIt,
    required this.whatIsItUsedFor,
    required this.addedSugars,
    required this.additivesPreservatives,
    required this.artificialSweetenersColors,
    required this.brandName,
    required this.hsn,
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
  });

  factory MenuItem.fromFirestore(Map<String, dynamic> data) {
    return MenuItem(
      name: data['Name'] ?? '',
      price: _parseDouble(data['Price']),
      SOH: _parseDouble(data['Price']),
      category: data['Category'] ?? '',
      time: data['Time'] ?? '',
      delivery: data['Delivery'] ?? '',
      description: data['Description'] ?? '',
      protein: _parseDouble(data['Protein']),
      carbs: _parseDouble(data['Carbs']),
      kcal: _parseDouble(data['Kcal']),
      fat: _parseDouble(data['Fat']),
      rating: _parseDouble(data['Rating']),
      imageUrls: List<String>.from(data['ImageUrl'] ?? []),
      soh: _parseDouble(data['SOH']),
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
      hsn: data['HSN'] ?? '',
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

  static fromDocument(DocumentSnapshot<Object?> menuItem) {}
}

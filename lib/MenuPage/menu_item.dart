import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String name;
  final String EAN;
  final double price;
  final String category;
  final String protein;
  final String kcal;
  final List<String> imageUrls;
  final List<String> FSSAI;
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
  final String Type;
  final String Orgin;
  final String ManufacturerAddress;
  final String Manufactureddate;
  final String Expiry;
  final String ImportedMarketedBy;
  final List<String> ScoredBasedOn;

  MenuItem({
    required this.name,
    required this.price,
    required this.category,
    required this.protein,
    required this.kcal,
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
    required this.ScoredBasedOn,
  });

  factory MenuItem.fromFirestore(Map<String, dynamic> data) {
    return MenuItem(
      name: data['Name'] ?? '',
      ScoredBasedOn: List<String>.from(data['Scored  Based On'] ?? []),
      price: _parseDouble(data['Price']),
      SOH: _parseDouble(data['SOH']),
      category: data['Category'] ?? '',
      protein: data['Protein (g)'],
      kcal: data['Energy (kcal)'],
      imageUrls: List<String>.from(data['ImageUrl'] ?? []),
      FSSAI: List<String>.from(data['FSSAI'] ?? []),
      EAN: data['EAN'] ?? '',
      macros: [
        if (data['Energy (kcal)'] != 'Not Applicable' &&
            data['Energy (kcal)'] != null)
          'Energy: ${data['Energy (kcal)']}',
        if (data['Protein (g)'] != 'Not Applicable' &&
            data['Protein (g)'] != null)
          'Protein: ${data['Protein (g)']}',
        if (data['Total Carbohydrates (g)'] != 'Not Applicable' &&
            data['Total Carbohydrates (g)'] != null)
          'Total Carbohydrates: ${data['Total Carbohydrates (g)']}',
        if (data['Sugars (g)'] != 'Not Applicable' &&
            data['Sugars (g)'] != null)
          'Sugars: ${data['Sugars (g)']}',
        if (data['Added Sugars (g)'] != 'Not Applicable' &&
            data['Added Sugars (g)'] != null)
          'Added Sugars: ${data['Added Sugars (g)']}',
        if (data['Dietary Fiber (g)'] != 'Not Applicable' &&
            data['Dietary Fiber (g)'] != null)
          'Dietary Fiber: ${data['Dietary Fiber (g)']}',
        if (data['Total Fat (g)'] != 'Not Applicable' &&
            data['Total Fat (g)'] != null)
          'Total Fat: ${data['Total Fat (g)']}',
        if (data['Trans Fat (g)'] != 'Not Applicable' &&
            data['Trans Fat (g)'] != null)
          'Trans Fat: ${data['Trans Fat (g)']}',
        if (data['Saturated Fat (g)'] != 'Not Applicable' &&
            data['Saturated Fat (g)'] != null)
          'Saturated Fat: ${data['Saturated Fat (g)']}',
        if (data['Unsaturated Fat (g)'] != 'Not Applicable' &&
            data['Unsaturated Fat (g)'] != null)
          'Unsaturated Fat: ${data['Unsaturated Fat (g)']}',
        if (data['Cholesterol (mg)'] != 'Not Applicable' &&
            data['Cholesterol (mg)'] != null)
          'Cholesterol: ${data['Cholesterol (mg)']}',
        if (data['Caffeine Content (mg)'] != 'Not Applicable' &&
            data['Caffeine Content (mg)'] != null)
          'Caffeine Content: ${data['Caffeine Content (mg)']}',
      ],
      micros: [
        if (data['Sodium (mg)'] != 'Not Applicable' &&
            data['Sodium (mg)'] != null)
          'Sodium: ${data['Sodium (mg)']}',
        if (data['Iron (mg)'] != 'Not Applicable' && data['Iron (mg)'] != null)
          'Iron: ${data['Iron (mg)']}',
        if (data['Calcium (mg)'] != 'Not Applicable' &&
            data['Calcium (mg)'] != null)
          'Calcium: ${data['Calcium (mg)']}',
        if (data['Copper (mg)'] != 'Not Applicable' &&
            data['Copper (mg)'] != null)
          'Copper: ${data['Copper (mg)']}',
        if (data['Magnesium (mg)'] != 'Not Applicable' &&
            data['Magnesium (mg)'] != null)
          'Magnesium: ${data['Magnesium (mg)']}',
        if (data['Phosphorus (mg)'] != 'Not Applicable' &&
            data['Phosphorus (mg)'] != null)
          'Phosphorus: ${data['Phosphorus (mg)']}',
        if (data['Potassium (mg)'] != 'Not Applicable' &&
            data['Potassium (mg)'] != null)
          'Potassium: ${data['Potassium (mg)']}',
        if (data['Zinc (mg)'] != 'Not Applicable' && data['Zinc (mg)'] != null)
          'Zinc: ${data['Zinc (mg)']}',
        if (data['Manganese (mg)'] != 'Not Applicable' &&
            data['Manganese (mg)'] != null)
          'Manganese: ${data['Manganese (mg)']}',
        if (data['Selenium (mcg)'] != 'Not Applicable' &&
            data['Selenium (mcg)'] != null)
          'Selenium: ${data['Selenium (mcg)']}',
      ],
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
      kealthyScore: _parseDouble(data['Kealthy Score']).toString(),
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
      Expiry: data['Best Before'] ?? '',
      ImportedMarketedBy: data['Imported&Marketed By'] ?? '',
    );
  }
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0; // Handle null values safely
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

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
  final String imageUrl;
  final String nutrients;
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
    required this.imageUrl,
    required this.nutrients,
    required this.SOH,
  });

  factory MenuItem.fromFirestore(Map<String, dynamic> data) {
    return MenuItem(
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
      SOH: _parseDouble(data['SOH']),
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

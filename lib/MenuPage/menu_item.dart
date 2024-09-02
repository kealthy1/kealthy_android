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
  });

  // Factory method to create a MenuItem from a Firestore document snapshot
  factory MenuItem.fromFirestore(Map<String, dynamic> data) {
    return MenuItem(
      name: data['Name'],
      price: data['Price'].toDouble(),
      category: data['Category'],
      time: data['Time'],
      delivery: data['Delivery'],
      description: data['Description'],
      protein: data['Protein'].toDouble(),
      carbs: data['Carbs'].toDouble(),
      kcal: data['Kcal'].toDouble(),
      fat: data['Fat'].toDouble(),
      rating: data['Rating'].toDouble(),
      imageUrl: data['ImageUrl'],
    );
  }
}

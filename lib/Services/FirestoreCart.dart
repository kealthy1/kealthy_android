import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String imagePath;
  final String category;
  final double fat;
  final double kcal;
  final double protein;
  final double carbs;

  int quantity;

  CartItem({
    required this.category,
    required this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.fat,
    required this.kcal,
    required this.protein,
    required this.carbs,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  Future<void> fetchCartItems() async {
    try {
      final CollectionReference cartCollection = FirebaseFirestore.instance.collection('Cart');
      final QuerySnapshot snapshot = await cartCollection.get();

      List<CartItem> cartItems = snapshot.docs.map((doc) {
        return CartItem(
          id: doc.id,
          name: doc['Name'] ?? '',
          price: doc['Price']?.toDouble() ?? 0.0,
          imagePath: doc['ImageUrl'] ?? '',
          category: doc['Category'] ?? '',
          fat: doc['Fat']?.toDouble() ?? 0.0,
          kcal: doc['Kcal']?.toDouble() ?? 0.0,
          protein: doc['Protein']?.toDouble() ?? 0.0,
          carbs: doc['Carbs']?.toDouble() ?? 0.0,
          quantity: doc['Quantity']?.toInt() ?? 1,
        );
      }).toList();

      state = cartItems;
    } catch (e) {
      print('Error fetching cart items: $e');
    }
  }

  void addItem(CartItem item) async {
    final index = state.indexWhere((cartItem) => cartItem.id == item.id);
    
    if (index >= 0) {
      state[index].quantity += item.quantity;
      state = [...state];

      await updateItemQuantityInFirestore(item.id, state[index].quantity);
    } else {
      state = [...state, item];

      await FirebaseFirestore.instance.collection('Cart').doc(item.id).set({
        'Name': item.name,
        'Price': item.price,
        'ImageUrl': item.imagePath,
        'Category': item.category,
        'Fat': item.fat,
        'Kcal': item.kcal,
        'Protein': item.protein,
        'Carbs': item.carbs,
        'Quantity': item.quantity,
      }, SetOptions(merge: true));
    }
  }

  void incrementItem(String id) async {
    final index = state.indexWhere((cartItem) => cartItem.id == id);
    if (index >= 0) {
      state[index].quantity++;
      state = [...state];

      await updateItemQuantityInFirestore(id, state[index].quantity);
    }
  }

  void decrementItem(String id) async {
    final index = state.indexWhere((cartItem) => cartItem.id == id);
    if (index >= 0) {
      if (state[index].quantity > 1) {
        state[index].quantity--;
        state = [...state];

        await updateItemQuantityInFirestore(id, state[index].quantity);
      } else {
        removeItem(id);
      }
    }
  }

  Future<void> updateItemQuantityInFirestore(String id, int newQuantity) async {
    try {
      final DocumentReference docRef = FirebaseFirestore.instance.collection('Cart').doc(id);
      await docRef.update({'Quantity': newQuantity});
      print('Item quantity updated in Firestore');
    } catch (e) {
      print('Error updating item quantity in Firestore: $e');
    }
  }

  void removeItem(String id) async {
    state = state.where((cartItem) => cartItem.id != id).toList();
    await deleteItemFromFirestore(id);
  }

  Future<void> deleteItemFromFirestore(String id) async {
    try {
      final DocumentReference docRef = FirebaseFirestore.instance.collection('Cart').doc(id);
      await docRef.delete();
      print('Item with id $id deleted successfully');
    } catch (e) {
      print('Error deleting item with id $id: $e');
    }
  }
}

final addCartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

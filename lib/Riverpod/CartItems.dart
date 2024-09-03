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

  void addItem(CartItem item) {
    final index = state.indexWhere((cartItem) => cartItem.id == item.id);
    if (index >= 0) {
      state[index].quantity += item.quantity;
    } else {
      state = [...state, item];
    }
  }

  void incrementItem(String id) {
    final index = state.indexWhere((cartItem) => cartItem.id == id);
    if (index >= 0) {
      state[index].quantity++;
      state = [...state]; 
    }
  }

  void decrementItem(String id) {
    final index = state.indexWhere((cartItem) => cartItem.id == id);
    if (index >= 0) {
      if (state[index].quantity > 1) {
        state[index].quantity--;
        state = [...state];
      } else {
        removeItem(id);
      }
    }
  }

  void removeItem(String id) {
    state = state.where((cartItem) => cartItem.id != id).toList();
  }
}


final addCartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

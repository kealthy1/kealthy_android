import 'dart:convert';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesCartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String EAN;
  int quantity;

  SharedPreferencesCartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.EAN,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'EAN': EAN,
        'quantity': quantity,
      };

  factory SharedPreferencesCartItem.fromJson(Map<String, dynamic> json) {
    return SharedPreferencesCartItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0) as double,
      imageUrl: json['imageUrl'] ?? '',
      EAN: json['EAN'] ?? '',
      quantity: json['quantity'] ?? 1,
    );
  }
}

class SharedPreferencesCartNotifier
    extends StateNotifier<List<SharedPreferencesCartItem>> {
  SharedPreferencesCartNotifier() : super([]) {
    loadCartItems();
  }

  Future<void> loadCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? cartItemsJson = prefs.getStringList('cartItems');

    if (cartItemsJson != null) {
      state = cartItemsJson.map((itemJson) {
        return SharedPreferencesCartItem.fromJson(jsonDecode(itemJson));
      }).toList();
    } else {
      state = [];
    }
  }

  Future<void> saveCartState() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> cartItemsJson =
        state.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList('cartItems', cartItemsJson);
  }

  void addItemToCart(SharedPreferencesCartItem item) async {
    state = [...state, item];

    await saveCartState();
  }

  void increaseItemQuantity(String id) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index >= 0) {
      state[index].quantity++;
      state = [...state];
      await saveCartState();
    }
  }

  void decreaseItemQuantity(String id) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index >= 0) {
      if (state[index].quantity > 1) {
        state[index].quantity--;
        state = [...state];
        await saveCartState();
      } else {
        removeItemFromCart(id);
      }
    }
  }

  void removeItemFromCart(String id) async {
    state = state.where((item) => item.id != id).toList();
    await saveCartState();
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cartItems');
    state = [];
    print("Cart has been cleared successfully.");
  }
}

final sharedPreferencesCartProvider = StateNotifierProvider<
    SharedPreferencesCartNotifier, List<SharedPreferencesCartItem>>((ref) {
  return SharedPreferencesCartNotifier();
});

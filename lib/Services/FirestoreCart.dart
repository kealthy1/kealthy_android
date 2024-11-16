// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// class CartItem {
//   final String id;
//   final String name;
//   final double price;
//   final String imageUrl;
//   final String category;
//   int quantity;

//   CartItem({
//     required this.id,
//     required this.name,
//     required this.price,
//     required this.imageUrl,
//     required this.category,
//     this.quantity = 1,
//   });

//   double get totalPrice => price * quantity;
// }

// class CartNotifier extends StateNotifier<List<CartItem>> {
//   CartNotifier() : super([]);

//   final String apiUrl = "https://api-jfnhkjk4nq-uc.a.run.app";

//   final Map<String, bool> loadingStates = {};
//   bool isLoading(String id) => loadingStates[id] ?? false;

//   void setLoading(String id, bool isLoading) {
//     loadingStates[id] = isLoading;
//     state = [...state];
//   }

//   Future<void> fetchCartItems() async {
//     final prefs = await SharedPreferences.getInstance();
//     final phoneNumber = prefs.getString('phoneNumber');

//     if (phoneNumber == null) return;

//     try {
//       final normalizedPhoneNumber =
//           phoneNumber.replaceAll(RegExp(r'\s+'), '').replaceFirst('+91', '');
//       final response = await http.get(
//           Uri.parse('$apiUrl/getallcarts?phoneNumber=$normalizedPhoneNumber'));

//       if (response.statusCode == 200) {
//         final cartData = jsonDecode(response.body);
//         if (cartData['success'] == true && cartData['data'] != null) {
//           List<CartItem> items = (cartData['data'] as List).map((item) {
//             return CartItem(
//               id: item['_id'],
//               name: item['Name'],
//               price: item['Price'].toDouble(),
//               imageUrl: item['ImageUrl'],
//               category: item['Category'],
//               quantity: item['Quantity'] ?? 1,
//             );
//           }).toList();
//           state = items;
//         }
//       }
//     } catch (e) {
//       print('Error fetching cart items: $e');
//     }
//   }

//   void addItem(CartItem item) async {
//     final prefs = await SharedPreferences.getInstance();
//     final phoneNumber = prefs.getString('phoneNumber');

//     if (phoneNumber != null) {
//       setLoading(item.id, true);
//       final body = jsonEncode({
//         'phoneNumber': phoneNumber,
//         'productData': {
//           'Name': item.name,
//           'Price': item.price,
//           'Quantity': item.quantity,
//           'Category': item.category,
//           'ImageUrl': item.imageUrl,
//         },
//       });

//       try {
//         final response = await http.post(
//           Uri.parse('$apiUrl/addcart'),
//           headers: {'Content-Type': 'application/json'},
//           body: body,
//         );

//         if (response.statusCode == 200) {
//           state = [...state, item];
//         } else {
//           print('Failed to add item: ${response.statusCode}, ${response.body}');
//         }
//       } catch (e) {
//         print('Error occurred while adding item: $e');
//       } finally {
//         setLoading(item.id, false);
//       }
//     }
//   }

//   void incrementItem(String id) async {
//     final index = state.indexWhere((cartItem) => cartItem.id == id);

//     if (index >= 0) {
//       final previousQuantity = state[index].quantity;
//       setLoading(id, true);

//       try {
//         await updateItemQuantityInAPI(state[index].name, previousQuantity + 1);

//         // Create a new CartItem instance with the incremented quantity
//         final updatedItem = CartItem(
//           id: state[index].id,
//           name: state[index].name,
//           quantity: previousQuantity + 1,
//           price: state[index].price, // Preserving the existing price
//           imageUrl: state[index].imageUrl, // Preserving the existing imageUrl
//           category: state[index].category, // Preserving the existing category
//           // Add any other properties of CartItem here
//         );

//         // Replace the item in the list immutably
//         state = [
//           ...state.sublist(0, index),
//           updatedItem,
//           ...state.sublist(index + 1),
//         ];

//         print('Item quantity incremented successfully');
//       } catch (error) {
//         print('Error incrementing item quantity: $error');
//         showErrorToUser("Failed to increment item quantity. Please try again.");
//       } finally {
//         setLoading(id, false);
//       }
//     } else {
//       print('Item not found in the cart');
//     }
//   }

//   void decrementItem(String id) async {
//     final index = state.indexWhere((cartItem) => cartItem.id == id);

//     if (index >= 0) {
//       final previousQuantity = state[index].quantity;
//       setLoading(id, true);

//       if (previousQuantity > 1) {
//         try {
//           await updateItemQuantityInAPI(
//               state[index].name, previousQuantity - 1);

//           state[index].quantity--;
//           state = [...state];
//           print('Item quantity decremented successfully');
//         } catch (error) {
//           print('Error decrementing item quantity: $error');
//           showErrorToUser(
//               "Failed to decrement item quantity. Please try again.");
//         } finally {
//           setLoading(id, false);
//         }
//       } else {
//         removeItem(id);
//       }
//     } else {
//       print('Item not found in the cart');
//     }
//   }

//   Future<void> updateItemQuantityInAPI(String itemName, int newQuantity) async {
//     final prefs = await SharedPreferences.getInstance();
//     final phoneNumber = prefs.getString('phoneNumber');

//     if (phoneNumber != null) {
//       final normalizedPhoneNumber =
//           phoneNumber.replaceAll(RegExp(r'\s+'), '').replaceFirst('+91', '');

//       try {
//         final response = await http.patch(
//           Uri.parse('$apiUrl/updatecart/$normalizedPhoneNumber'),
//           headers: {'Content-Type': 'application/json'},
//           body: jsonEncode({'itemName': itemName, 'newQuantity': newQuantity}),
//         );

//         if (response.statusCode == 200) {
//           print('Item quantity updated successfully');
//         } else {
//           throw Exception(
//               'Error updating item quantity: ${response.statusCode}, ${response.body}');
//         }
//       } catch (e) {
//         throw Exception('Error updating item quantity in API: $e');
//       }
//     } else {
//       throw Exception('No phone number found in SharedPreferences.');
//     }
//   }

//   void removeItem(String id) async {
//     final index = state.indexWhere((cartItem) => cartItem.id == id);
//     if (index >= 0) {
//       setLoading(id, true);

//       final itemName = state[index].name;
//       await deleteItemFromAPI(itemName);

//       state = state.where((cartItem) => cartItem.id != id).toList();
//       setLoading(id, false);
//     }
//   }

//   Future<void> deleteItemFromAPI(String itemName) async {
//     final prefs = await SharedPreferences.getInstance();
//     final phoneNumber = prefs.getString('phoneNumber');

//     if (phoneNumber != null) {
//       String normalizedPhoneNumber =
//           phoneNumber.replaceAll(' ', '').replaceAll('+91', '');

//       try {
//         final response = await http.delete(
//           Uri.parse('$apiUrl/deletecart/$itemName'),
//           headers: {
//             'Content-Type': 'application/json',
//           },
//           body: jsonEncode({
//             'phoneNumber': normalizedPhoneNumber,
//           }),
//         );

//         if (response.statusCode == 200) {
//           print('Item deleted successfully');
//         } else {
//           print(
//               'Error deleting item: ${response.statusCode}, ${response.body}');
//         }
//       } catch (e) {
//         print('Error deleting item from API: $e');
//       }
//     }
//   }

//   Future<void> deleteAllItemsFromCart() async {
//     final prefs = await SharedPreferences.getInstance();
//     final phoneNumber = prefs.getString('phoneNumber');

//     if (phoneNumber != null) {
//       String normalizedPhoneNumber =
//           phoneNumber.replaceAll(' ', '').replaceAll('+91', '');

//       try {
//         final response = await http.delete(
//           Uri.parse('$apiUrl/deletecart/all'),
//           headers: {
//             'Content-Type': 'application/json',
//           },
//           body: jsonEncode({'phoneNumber': normalizedPhoneNumber}),
//         );

//         if (response.statusCode == 200) {
//           print('All items deleted successfully');
//           state = [];
//         } else {
//           print(
//               'Error deleting all items: ${response.statusCode}, ${response.body}');
//         }
//       } catch (e) {
//         print('Error deleting all items from cart: $e');
//       }
//     }
//   }

//   void showErrorToUser(String message) {
//     print(message);
//   }
// }

// final addCartProvider =
//     StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
//   return CartNotifier();
// });

import 'dart:convert';

import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesCartItem {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  int quantity;

  SharedPreferencesCartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
        'quantity': quantity,
      };

  factory SharedPreferencesCartItem.fromJson(Map<String, dynamic> json) {
    return SharedPreferencesCartItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0) as double,
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
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
    await prefs
        .remove('cartItems');
    state = []; 
    print("Cart has been cleared successfully.");
  }
}

final sharedPreferencesCartProvider = StateNotifierProvider<
    SharedPreferencesCartNotifier, List<SharedPreferencesCartItem>>((ref) {
  return SharedPreferencesCartNotifier();
});

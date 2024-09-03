import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/MenuPage/menu_item.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<MenuItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<MenuItem>> {
  CartNotifier() : super([]);

  void addItem(MenuItem item) {
    state = [...state, item];
  }

}
final cartAnimationProvider = StateProvider<bool>((ref) => false);
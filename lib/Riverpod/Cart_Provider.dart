import 'package:riverpod/riverpod.dart';

class CartItem {
  final double price;
  int quantity;
  final String imagePath;

  CartItem({required this.price, this.quantity = 1, required this.imagePath});

  double get totalPrice => price * quantity;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier()
      : super([
          CartItem(
              price: 100,
              quantity: 1,
              imagePath: 'assets/Chicken Spinach Pasta.jpg'),
          CartItem(price: 200, quantity: 1, imagePath: 'assets/dinner.jpg'),
          CartItem(price: 300, quantity: 1, imagePath: 'assets/Salad.jpg'),
        ]);

  void incrementItem(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          CartItem(
            price: state[i].price,
            quantity: state[i].quantity + 1,
            imagePath: state[i].imagePath,
          )
        else
          state[i],
    ];
  }

  void decrementItem(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          CartItem(
            price: state[i].price,
            quantity: (state[i].quantity > 1)
                ? state[i].quantity - 1
                : state[i].quantity,
            imagePath: state[i].imagePath,
          )
        else
          state[i],
    ];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

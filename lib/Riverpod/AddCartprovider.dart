import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuantityNotifier extends StateNotifier<int> {
  QuantityNotifier() : super(1);

  void increment() {
    state++;
  }

  void decrement() {
    if (state > 1) {
      state--;
    }
  }
}

final quantityProvider = StateNotifierProvider<QuantityNotifier, int>((ref) {
  return QuantityNotifier();
});

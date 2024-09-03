import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchHintNotifier extends StateNotifier<int> {
  SearchHintNotifier() : super(0) {
    _startHintRotation();
  }

  void _startHintRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      nextHint();
      _startHintRotation(); // Repeat the rotation
    });
  }

  void nextHint() {
    state = (state + 1) % hints.length;
  }
}

final searchHintProvider =
    StateNotifierProvider<SearchHintNotifier, int>((ref) {
  return SearchHintNotifier();
});

final hints = ["Salad", "Pasta", "Protein Shake", "Breads", "Potatoes", "Soy"];

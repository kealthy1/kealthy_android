import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarouselIndexNotifier extends StateNotifier<int> {
  CarouselIndexNotifier() : super(0); // Initial index is 0

  void next() {
    state++;
  }

  void previous() {
    if (state > 0) {
      state--;
    }
  }

  void setIndex(int index) {
    state = index;
  }
}

final carouselIndexProvider = StateNotifierProvider<CarouselIndexNotifier, int>((ref) {
  return CarouselIndexNotifier();
});

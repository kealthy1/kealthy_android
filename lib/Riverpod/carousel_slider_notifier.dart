import 'package:flutter_riverpod/flutter_riverpod.dart';

class CarouselSliderNotifier extends StateNotifier<int> {
  CarouselSliderNotifier() : super(0);

  void updateIndex(int newIndex) {
    state = newIndex;
  }
}

final carouselSliderProvider = StateNotifierProvider<CarouselSliderNotifier, int>((ref) {
  return CarouselSliderNotifier();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNavBarNotifier extends StateNotifier<int> {
  BottomNavBarNotifier() : super(0); 

  void setIndex(int index) {
    state = index;
  }
}

final bottomNavBarProvider = StateNotifierProvider<BottomNavBarNotifier, int>((ref) {
  return BottomNavBarNotifier();
});

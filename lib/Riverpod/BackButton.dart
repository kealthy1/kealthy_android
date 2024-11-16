import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackPressNotifier extends StateNotifier<int> {
  BackPressNotifier() : super(0);

  Timer? _resetTimer;

  void onBackPressed() {
    state++;

    _resetTimer?.cancel();
    _resetTimer = Timer(Duration(seconds: 2), () {
      state = 0; 
    });
  }

  bool shouldExitApp() {
    return state >= 2; 
  }
  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }
}






final backPressProvider = StateNotifierProvider<BackPressNotifier, int>((ref) {
  return BackPressNotifier();
});



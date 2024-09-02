import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a StateNotifierProvider for managing bottom navigation index
final bottomNavIndexProvider = StateNotifierProvider<BottomNavIndexNotifier, int>((ref) {
  return BottomNavIndexNotifier();
});

// StateNotifier class to manage the index
class BottomNavIndexNotifier extends StateNotifier<int> {
  BottomNavIndexNotifier() : super(0); // Default to the first index (Home)

  void updateIndex(int newIndex) {
    state = newIndex; // Update the current index
  }
}

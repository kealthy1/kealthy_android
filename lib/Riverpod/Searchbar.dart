import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';

class SearchHintNotifier extends StateNotifier<int> {
  List<String> hints = ["Yogurt"];

  SearchHintNotifier() : super(0) {
    _fetchHints();
    _startHintRotation();
  }

  Future<void> _fetchHints() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('Products').get();

      hints = querySnapshot.docs.map((doc) => doc['Name'] as String).toList();

      state = 0;
    } catch (e) {
      print('Error fetching hints: $e');
    }
  }

  void _startHintRotation() {
    Future.delayed(const Duration(seconds: 3), () {
      nextHint();
      _startHintRotation();
    });
  }
  void nextHint() {
    if (hints.isNotEmpty) {
      state = (state + 1) % hints.length;
    }
  }
}

final searchHintProvider =
    StateNotifierProvider<SearchHintNotifier, int>((ref) {
  return SearchHintNotifier();
});

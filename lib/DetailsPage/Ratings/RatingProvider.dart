import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class RateProductState {
  final bool isExpanded;
  final int selectedRating;
  final String feedback;
  final bool loading;

  const RateProductState({
    this.isExpanded = false,
    this.selectedRating = 0,
    this.feedback = '',
    this.loading = false,
  });

  RateProductState copyWith({
    bool? isExpanded,
    int? selectedRating,
    String? feedback,
    bool? loading,
  }) {
    return RateProductState(
      isExpanded: isExpanded ?? this.isExpanded,
      selectedRating: selectedRating ?? this.selectedRating,
      feedback: feedback ?? this.feedback,
      loading: loading ?? this.loading,
    );
  }
}

class RateProductNotifier extends StateNotifier<RateProductState> {
  RateProductNotifier() : super(const RateProductState());

  double? averageStars;
  void toggleExpanded() {
    state = state.copyWith(isExpanded: !state.isExpanded);
  }

  void updateRating(int rating) {
    state = state.copyWith(selectedRating: rating);
  }

  void updateFeedback(String feedback) {
    state = state.copyWith(feedback: feedback);
  }

  Future<void> submitReview({
    required String productName,
    required String apiUrl,
    required void Function(String message) onSuccess,
    required void Function(String error) onError,
  }) async {
    if (state.selectedRating == 0) {
      onError('Please select a rating');
      return;
    }

    state = state.copyWith(loading: true);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'productName': productName,
          'starCount': state.selectedRating,
          'feedback': state.feedback,
        }),
      );

      if (response.statusCode == 200) {
        onSuccess('Review submitted successfully');
        state = const RateProductState();
      } else {
        print('Failed to submit rating: ${response.body}');
      }
    } catch (e) {
      onError('Error: $e');
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> getAverageStars({
    required String productName,
    required String apiUrl,
    required void Function(String error) onError,
  }) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/$productName'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        averageStars = double.parse(data['averageStars']);
        state = state.copyWith();
      } else {
        print('Failed to fetch average stars: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}

final rateProductProviders =
    StateNotifierProvider<RateProductNotifier, RateProductState>(
  (ref) => RateProductNotifier(),
);


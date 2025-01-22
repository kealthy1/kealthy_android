import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Services/sharedpreferncesname.dart';

class ProductReviewState {
  final List<String> productNames;
  final bool isLoading;

  ProductReviewState({required this.productNames, required this.isLoading});

  ProductReviewState copyWith({
    List<String>? productNames,
    bool? isLoading,
  }) {
    return ProductReviewState(
      productNames: productNames ?? this.productNames,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RateProductState {
  final int selectedRating;
  final String feedback;
  final String customerName;
  final bool isLoading;

  const RateProductState({
    this.selectedRating = 0,
    this.feedback = '',
    this.customerName = '', 
    this.isLoading = false,
  });

  RateProductState copyWith({
    int? selectedRating,
    String? feedback,
    String? customerName, 
    bool? isLoading,
  }) {
    return RateProductState(
      selectedRating: selectedRating ?? this.selectedRating,
      feedback: feedback ?? this.feedback,
      customerName: customerName ?? this.customerName, 
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RateProductNotifier extends StateNotifier<Map<String, RateProductState>> {
  RateProductNotifier() : super({});

  void updateRating(String productName, int rating) {
    state = {
      ...state,
      productName: state[productName]?.copyWith(selectedRating: rating) ??
          RateProductState(selectedRating: rating),
    };
  }

  void updateFeedback(String productName, String feedback) {
    state = {
      ...state,
      productName: state[productName]?.copyWith(feedback: feedback) ??
          RateProductState(feedback: feedback),
    };
  }

  void updateCustomerName(String productName, String customerName) {
    state = {
      ...state,
      productName: state[productName]?.copyWith(customerName: customerName) ??
          RateProductState(customerName: customerName),
    };
  }

  Future<void> submitReview({
    required String productName,
    required String apiUrl,
    required String customerName,
    required void Function(String message) onSuccess,
    required void Function(String error) onError,
  }) async {
    final productState = state[productName] ?? const RateProductState();

    if (productState.selectedRating == 0) {
      onError('Please select a rating');
      return;
    }

    if (customerName.isEmpty) {
      onError('Please provide a customer name');
      return;
    }
    state = {
      ...state,
      productName: productState.copyWith(isLoading: true),
    };

    try {
      final Map<String, dynamic> requestBody = {
        "productName": productName,
        "starCount": productState.selectedRating,
        "feedback": productState.feedback,
        "customerName": customerName, 
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        onSuccess('Review submitted successfully');
      } else {
        onError(
          'Failed to submit review. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      onError('Failed to submit review: $e');
    } finally {
      state = {
        ...state,
        productName: productState.copyWith(isLoading: false),
      };
    }
  }
}


final rateProductProvider =
    StateNotifierProvider<RateProductNotifier, Map<String, RateProductState>>(
  (ref) => RateProductNotifier(),
);


class ProductReviewNotifier extends StateNotifier<ProductReviewState> {
  ProductReviewNotifier()
      : super(ProductReviewState(productNames: [], isLoading: true)) {
    _loadProductNames();
  }

  Future<void> _loadProductNames() async {
    state = state.copyWith(isLoading: true);
    final productNames = await SharedPreferencesHelper.getOrderItemNames();
    state = state.copyWith(productNames: productNames, isLoading: false);
  }

  Future<void> removeProduct(String productName) async {
    state = state.copyWith(isLoading: true);
    await SharedPreferencesHelper.removeOrderItemByName(productName);
    await _loadProductNames();
    print('Removed product: $productName and updated the state.');
  }
}

final productReviewProvider =
    StateNotifierProvider<ProductReviewNotifier, ProductReviewState>(
  (ref) => ProductReviewNotifier(),
);

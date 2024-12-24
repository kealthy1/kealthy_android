import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final updateAddressProvider =
    StateNotifierProvider<UpdateAddressNotifier, bool>(
  (ref) => UpdateAddressNotifier(),
);

class UpdateAddressNotifier extends StateNotifier<bool> {
  UpdateAddressNotifier() : super(false);

  Future<bool> updateSelectedAddress(String phoneNumber, String type) async {
    const String apiUrl = "https://api-jfnhkjk4nq-uc.a.run.app/updateSelectedAddress";

    try {
      state = true; // Set loading state to true

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'type': type}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          print("Address updated successfully!");
          return true;
        }
      }

      print("Failed to update address: ${response.body}");
      return false;
    } catch (e) {
      print("Error updating address: $e");
      return false;
    } finally {
      state = false; // Reset loading state
    }
  }
}

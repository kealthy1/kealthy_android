import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserModel {
  final String name;
  final String email;

  UserModel({required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class UserRepository {
  final Dio _dio = Dio();

  Future<UserModel> fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Fetch phoneNumber from SharedPreferences
    String? phoneNumber = prefs.getString("phoneNumber");
    if (phoneNumber == null) throw Exception("Phone number not found");

    // Check if selectedName exists
    String? selectedName = prefs.getString("selectedName");

    if (selectedName != null) {
      // If selectedName exists, return stored name
      return UserModel(name: selectedName, email: prefs.getString("email") ?? "");
    }

    try {
      // Make API call
      final response = await _dio.post(
        "http://localhost:5000/getUserDetails",
        data: {"phoneNumber": phoneNumber},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        UserModel user = UserModel.fromJson(data);

        // Store values in SharedPreferences
        prefs.setString("selectedName", user.name);
        prefs.setString("email", user.email);

        return user;
      } else {
        throw Exception("Failed to fetch user details");
      }
    } catch (e) {
      throw Exception("Error fetching user details: $e");
    }
  }
}


final userRepositoryProvider = Provider((ref) => UserRepository());

final userProvider = FutureProvider<UserModel>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return await repository.fetchUserDetails();
});

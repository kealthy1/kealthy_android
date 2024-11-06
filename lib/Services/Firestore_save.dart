import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationSaveService {
  final String apiUrl = 'https://api-jfnhkjk4nq-uc.a.run.app/address/location';

  Future<void> saveUserLocation(double latitude, double longitude, String type) async {
    final hasPhoneNumber = await _checkPhoneNumber();
    if (hasPhoneNumber) {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phoneNumber');

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        await storeUserData(phoneNumber, latitude, longitude, type);
      } else {
        print("Phone number is empty.");
      }
    } else {
      print("Phone number is not saved.");
    }
  }

  Future<void> storeUserData(String phoneNumber, double latitude,
      double longitude, String type) async {
    final data = {
      'phoneNumber': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print('Data stored successfully: ${response.body}');
      } else {
        print(
            'Failed to store data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Error storing user data: $e");
    }
  }

  Future<bool> _checkPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');
    return phoneNumber != null && phoneNumber.isNotEmpty;
  }
}

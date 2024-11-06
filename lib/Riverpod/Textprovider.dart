import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TextNotifier extends ChangeNotifier {
  String _savedText = "";

  String get savedText => _savedText;

  TextNotifier() {
    _loadText();
  }

  // Load saved text from SharedPreferences
  Future<void> _loadText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _savedText = prefs.getString('selectedRoad') ?? '';
    notifyListeners();
  }

  // Save text to SharedPreferences and notify listeners
  Future<void> saveText(String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedRoad', text);
    _savedText = text;
    notifyListeners();
  }
}

// Create a Provider for the TextNotifier
final textNotifierProvider = ChangeNotifierProvider((ref) => TextNotifier());
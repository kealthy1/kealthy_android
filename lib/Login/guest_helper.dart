import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Guest_Alert.dart';

class GuestHelper {
  static Future<void> checkAndShowGuestDialog(BuildContext context, Widget navigateTo) async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber') ?? '';

    if (phoneNumber.isEmpty) {
      GuestDialog.show(
        context: context,
        title: "Login Required",
        content: "Please log in to continue.",
        navigateTo: navigateTo,
      );
    }
  }
}

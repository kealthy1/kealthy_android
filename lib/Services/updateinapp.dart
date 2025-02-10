import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppUpdateService {
  static final InAppUpdateService _instance = InAppUpdateService._internal();

  factory InAppUpdateService() => _instance;

  InAppUpdateService._internal();

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();

          final prefs = await SharedPreferences.getInstance();
          prefs.remove('selectedAddressMessage');
          prefs.remove('selectedRoad');
        } else {
          final playStoreVersion = await getPlayStoreVersion();
          final localVersion = await getLocalVersion();
          _showMandatoryUpdateDialog(context, playStoreVersion, localVersion);
        }
      }
    } catch (e) {
      debugPrint("Error checking for update: $e");
    }
  }

  static Future<String> getLocalVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<String> getPlayStoreVersion() async {
    final url = Uri.parse('https://api-jfnhkjk4nq-uc.a.run.app/version');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data['version'];
    } else {
      throw Exception('Failed to fetch version from backend');
    }
  }

  void _showMandatoryUpdateDialog(
      BuildContext context, playStoreVersion, localVersion) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing dialog
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Prevents back button exit
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.info_circle_fill,
                color: Colors.redAccent,
                size: 50,
              ),
              SizedBox(height: 10),
              Text(
                "Update Required",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          content: Text(
            "A new version $playStoreVersion is available!\n\nYour current version is $localVersion.\nYou must update to continue using the app.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
          ),
          actionsAlignment: MainAxisAlignment.center, // Centers the button
          actions: [
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.remove('selectedAddressMessage');
                prefs.remove('selectedRoad');
                launchUrl(Uri.parse(
                    'https://play.google.com/store/apps/details?id=com.COTOLORE.Kealthy'));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                "Update",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class UpdateService {
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

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final localVersion = await getLocalVersion();
      final playStoreVersion = await getPlayStoreVersion();

      print('Local Version: $localVersion');
      print('Play Store Version: $playStoreVersion');

      if (localVersion != playStoreVersion) {
        final bool shouldShowDialog = await shouldShowUpdateDialog();
        if (shouldShowDialog) {
          showUpdateDialog(context);
        }
      }
    } catch (e) {
      print('Error checking for updates: $e');
    }
  }

  static Future<bool> shouldShowUpdateDialog() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? lastShownTimestamp = prefs.getInt('lastUpdateDialogShown');

    final int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    if (lastShownTimestamp == null ||
        (currentTimestamp - lastShownTimestamp) >= 1 * 60 * 60 * 1000) {
      prefs.setInt('lastUpdateDialogShown', currentTimestamp);
      return true;
    }
    return false;
  }

  static void showUpdateDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        title: Column(
          children: [
            Icon(
              Icons.system_security_update_good_outlined,
              size: 50,
              color: Color(0xFF273847),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'Update Available',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          textAlign: TextAlign.center,
          'Time for an upgrade! Please update to the latest version now',
          style: GoogleFonts.poppins(
            fontSize: 16,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              backgroundColor: Color(0xFF273847),
            ),
            onPressed: () {
              launchUrl(Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.COTOLORE.Kealthy'));
            },
            child: Text(
              'Update Now',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

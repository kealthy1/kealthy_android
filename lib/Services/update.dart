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
          showUpdateDialog(context, localVersion, playStoreVersion);
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

  static void showUpdateDialog(
      BuildContext context, String localVersion, String playStoreVersion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        contentPadding: EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF273847),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications,
                color: Colors.white,
                size: 48,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Update Available',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'A new version $playStoreVersion is available!\n\nYour current version $localVersion\n\nUpdate now to enjoy the latest features and improvements.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.remove('selectedAddressMessage');
                prefs.remove('selectedRoad');
                launchUrl(Uri.parse(
                    'https://play.google.com/store/apps/details?id=com.COTOLORE.Kealthy'));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF273847),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                'Update',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

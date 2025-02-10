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
      final prefs = await SharedPreferences.getInstance();

      print('Local Version: $localVersion');
      print('Play Store Version: $playStoreVersion');

      // Skip update check if Play Store version is 1.1.11
      if (playStoreVersion == '1.1.11') {
        print('Play Store version is 1.1.11. Skipping update check.');
        return;
      }

      if (localVersion != playStoreVersion) {
        // Fetch last update alert time from SharedPreferences
        int? lastShownTime = prefs.getInt('update_alert_shown_time');
        int currentTime = DateTime.now().millisecondsSinceEpoch;

        if (lastShownTime == null) {
          // If lastShownTime does NOT exist, set the timestamp but DO NOT show the alert
          print('No previous alert time found. Setting timestamp.');
          await prefs.setInt('update_alert_shown_time', currentTime);
        } else {
          int timeDifference = currentTime - lastShownTime;

          if (timeDifference >= 10800000) {
            // 3 hours in milliseconds
            // If more than 3 hours have passed, show the alert continuously
            print('More than 3 hours passed. Showing update alert.');
            showUpdateDialog(context, localVersion, playStoreVersion);
          } else {
            print(
                'Last alert was shown less than 3 hours ago. No alert shown.');
          }
        }
      }
    } catch (e) {
      print('Error checking for updates: $e');
    }
  }

  static void showUpdateDialog(
      BuildContext context, String localVersion, String playStoreVersion) {
    showDialog(
      barrierDismissible: false, // Alert cannot be dismissed
      context: context,
      builder: (context) => WillPopScope(
        onWillPop: () async => false, // Prevents back button exit
        child: _buildAlertDialog(context, localVersion, playStoreVersion),
      ),
    );
  }

  static Widget _buildAlertDialog(
      BuildContext context, String localVersion, String playStoreVersion) {
    return AlertDialog(
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
            'A new version $playStoreVersion is available!\n\nYour current version is $localVersion\n\nUpdate now to enjoy the latest features and improvements.',
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

              prefs.remove('update_alert_shown_time');

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
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppUpdateService {
  static final InAppUpdateService _instance = InAppUpdateService._internal();

  factory InAppUpdateService() => _instance;

  InAppUpdateService._internal();

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      debugPrint("🔍 Update availability: ${updateInfo.updateAvailability}");
      debugPrint(
          "🔍 Immediate update allowed: ${updateInfo.immediateUpdateAllowed}");

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          try {
            await InAppUpdate.performImmediateUpdate();
          } catch (e) {
            debugPrint("⛔️ performImmediateUpdate failed: $e");
            _showBlockerDialog(context);
          }
        } else {
          debugPrint("⛔️ Immediate update not allowed. Showing custom dialog.");
          _showBlockerDialog(
              context); // <-- show it anyway if update is available
        }
      } else {
        debugPrint("✅ App is up-to-date.");
      }
    } catch (e) {
      debugPrint("❌ In-app update check failed: $e");
      _showBlockerDialog(
          context); // Optional: handle totally failed checks here
    }
  }

  void _showBlockerDialog(BuildContext context) {
    showDialog(
      barrierColor: Colors.white,
      barrierDismissible: false,
      context: context,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: Column(
            children: const [
              Icon(Icons.system_update, color: Colors.redAccent, size: 50),
              SizedBox(height: 10),
              Text(
                "Update Required",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "A new version is available. Please update to continue using the app.",
            textAlign: TextAlign.center,
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await launchUrl(Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.COTOLORE.Kealthy',
                ));
              },
              child: const Text("Update Now"),
            ),
          ],
        ),
      ),
    );
  }

  // static Future<String> getLocalVersion() async {
  //   final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  //   return packageInfo.version;
  // }

  // static Future<String> getPlayStoreVersion() async {
  //   try {
  //     final doc = await FirebaseFirestore.instance
  //         .collection('version')
  //         .doc('android')
  //         .get();

  //     if (doc.exists) {
  //       return doc['latest_version']; // Expects: "1.1.67"
  //     } else {
  //       throw Exception('Version document not found.');
  //     }
  //   } catch (e) {
  //     throw Exception('Error fetching Firestore version: $e');
  //   }
  // }

  // bool _isUpdateAvailable(String local, String remote) {
  //   final localParts = local.split('.').map(int.parse).toList();
  //   final remoteParts = remote.split('.').map(int.parse).toList();

  //   for (int i = 0; i < remoteParts.length; i++) {
  //     final remoteVal = remoteParts[i];
  //     final localVal = i < localParts.length ? localParts[i] : 0;

  //     if (remoteVal > localVal) return true;
  //     if (remoteVal < localVal) return false;
  //   }
  //   return false;
  // }

  // void _showMandatoryUpdateDialog(
  //     BuildContext context, String remoteVersion, String localVersion) {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (_) => WillPopScope(
  //       onWillPop: () async => false,
  //       child: AlertDialog(
  //         backgroundColor: Colors.white,
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
  //         title: Column(
  //           children: [
  //             Icon(CupertinoIcons.info_circle_fill,
  //                 color: Colors.redAccent, size: 50),
  //             SizedBox(height: 10),
  //             Text("Update Required",
  //                 textAlign: TextAlign.center,
  //                 style: GoogleFonts.poppins(
  //                     fontSize: 20,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.black)),
  //           ],
  //         ),
  //         content: Text(
  //           "A new version $remoteVersion is available!\n\nYour current version is $localVersion.\nPlease update to continue.",
  //           textAlign: TextAlign.center,
  //           style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
  //         ),
  //         actionsAlignment: MainAxisAlignment.center,
  //         actions: [
  //           ElevatedButton(
  //             onPressed: () async {
  //               await launchUrl(Uri.parse(
  //                 'https://play.google.com/store/apps/details?id=com.COTOLORE.Kealthy',
  //               ));
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.redAccent,
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(12)),
  //             ),
  //             child: Text("Update",
  //                 style: GoogleFonts.poppins(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.white)),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

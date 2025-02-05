import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermission {
  static Future<void> checkAndShowNotificationSheet(
      BuildContext context) async {
    PermissionStatus status = await Permission.notification.status;

    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      showNotificationBottomSheet(context);
    }
  }

  static Future<void> showNotificationBottomSheet(BuildContext context) async {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_active,
                      color: Color(0xFF273847), size: 28),
                  SizedBox(width: 10),
                  Text(
                    "Enable Notifications",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                "Stay updated with exclusive offers, real-time order alerts, and insightful blog updates. Enable notifications now 🚀",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await requestNotificationPermission(context);
                    openAppSettings();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF273847),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text("Enable Notifications",
                      style: GoogleFonts.poppins(
                          fontSize: 16, color: Colors.white)),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Not Now",
                      style:
                          GoogleFonts.poppins(fontSize: 14, color: Colors.red)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> requestNotificationPermission(
      BuildContext context) async {
    PermissionStatus status = await Permission.notification.request();

    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      showNotificationBottomSheet(context);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> checkAndRequestLocation(BuildContext context) async {
  bool serviceEnabled;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!serviceEnabled) {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/Location.JPG',
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width * 0.4,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Location Access',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Location Denied. Please enable location access to use this feature',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      bool serviceEnabled =
                          await Geolocator.isLocationServiceEnabled();
                      if (!serviceEnabled) {
                        await Geolocator.openLocationSettings();
                      }
                      LocationPermission permission =
                          await Geolocator.checkPermission();

                      if (permission == LocationPermission.denied ||
                          permission == LocationPermission.deniedForever) {
                        openAppSettings();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF273847),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'ENABLE',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  } else {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied.'),
          ),
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permissions are permanently denied, please enable them in the app settings.'),
        ),
      );
      await openAppSettings();
    }
  }
}

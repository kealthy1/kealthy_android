import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationAccessWidget extends StatelessWidget {
  final Function onClose;

  const LocationAccessWidget({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/Location.JPG',
            height: MediaQuery.of(context).size.height * 0.15,
            width: MediaQuery.of(context).size.width * 0.5,
          ),
          const SizedBox(height: 8),
           Text(
            'Location Access',
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
             ),
          ),
          
           Text(
            'Please enable location access to use this feature',
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.grey, ),
            textAlign: TextAlign.center,
          ),
       
          ElevatedButton(
            onPressed: () async {
              bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled) {
                await Geolocator.openLocationSettings();
              } else {
                onClose();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF273847),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child:  Text(
              'ENABLE',
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LocationServiceChecker {
  final BuildContext context;
  Timer? _timer;
  bool _isAlertShown = false;

  LocationServiceChecker(this.context);

  void startChecking() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      bool isEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isEnabled && !_isAlertShown) {
        _showLocationAccessWidget();
      } else if (isEnabled && _isAlertShown) {
        Navigator.of(context).pop();
        _isAlertShown = false;
      }
    });
  }

  void stopChecking() {
    _timer?.cancel();
  }

  void _showLocationAccessWidget() {
    if (!context.mounted) return;

    _isAlertShown = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return LocationAccessWidget(
          onClose: () {
            Navigator.of(context).pop();
            _isAlertShown = false;
          },
        );
      },
    );
  }
}

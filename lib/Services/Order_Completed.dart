import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/LandingPage/Widgets/floating_bottom_navigation_bar.dart';
import 'package:lottie/lottie.dart';

class ReusableCountdownDialog {
  final BuildContext context;
  final WidgetRef ref;
  final String message;
  final String button;
  final Color color;
  final String imagePath;
  final VoidCallback onRedirect;
  final Color buttonColor;
  final Color buttonTextColor;

  ReusableCountdownDialog({
    required this.context,
    required this.ref,
    required this.message,
    required this.imagePath,
    required this.onRedirect,
    required this.button,
    required this.color,
    required this.buttonColor,
    required this.buttonTextColor,
  });

  void show() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            return WillPopScope(
              onWillPop: () async {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CustomBottomNavigationBar()),
                  (route) => false,
                );
                return false;
              },
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        repeat: false,
                        imagePath,
                        height: 200,
                      ),
                      Text(
                        message,
                        style: GoogleFonts.poppins(
                            color: color,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            onRedirect();
                          },
                          child: Text(
                            button,
                            style: TextStyle(color: buttonTextColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

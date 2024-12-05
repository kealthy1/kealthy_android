import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/LandingPage/HomePage.dart';
import 'package:lottie/lottie.dart';

class ReusableCountdownDialog {
  final BuildContext context;
  final WidgetRef ref;
  final String message;
  final String imagePath;
  final VoidCallback onRedirect;

  ReusableCountdownDialog({
    required this.context,
    required this.ref,
    required this.message,
    required this.imagePath,
    required this.onRedirect,
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
                  MaterialPageRoute(builder: (context) => const MyHomePage()),
                  (route) => false,
                );
                return false;
              },
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Lottie.asset(
                        imagePath,
                        height: 300,
                      ),
                      Text(
                        message,
                        style: const TextStyle(
                            fontSize: 22,
                            color: Color(0xFF273847),
                            fontFamily: "poppins"),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF273847)),
                        onPressed: () {
                          Navigator.pop(context);
                          onRedirect();
                        },
                        child: const Text(
                          "My Orders",
                          style: TextStyle(color: Colors.white),
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

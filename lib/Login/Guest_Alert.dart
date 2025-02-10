import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GuestDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String content,
    required Widget navigateTo, // Destination Page
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          content: Text(
            content,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => navigateTo),
                );
              },
              child: Text(
                "Continue",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

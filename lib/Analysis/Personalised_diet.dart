import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/Analysis/Calorie.dart';

class DietTrackingPage extends StatelessWidget {
  const DietTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalorieIntakePage(),
                        ));
                  },
                  child: planCard(
                    icon: Icons.fitness_center,
                    title: "Calorie Calculator",
                    subtitle: "",
                    bgColor: Colors.black,
                    screenWidth: screenWidth,
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: planCard(
                  icon: Icons.directions_run,
                  title: "Foot Steps",
                  subtitle: "120 Steps",
                  bgColor: Colors.pink,
                  screenWidth: screenWidth,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget planCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color bgColor,
    required double screenWidth,
  }) {
    return AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
          ),
          padding: EdgeInsets.all(screenWidth * 0.04),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: Colors.white, size: screenWidth * 0.07),
            SizedBox(height: screenWidth * 0.03),
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              subtitle,
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.04,
                color: Colors.white,
              ),
            ),
          ]),
        ));
  }
}

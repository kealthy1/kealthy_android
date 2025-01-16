import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CircularProgressIndicatorWidget extends StatelessWidget {
  final double kealthyScore;
  final double radius;
  final double lineWidth;

  const CircularProgressIndicatorWidget({
    super.key,
    required this.kealthyScore,
    this.radius = 35.0,
    this.lineWidth = 9.0,
  });

  @override
  Widget build(BuildContext context) {
    String grade;
    Color progressColor;

    if (kealthyScore >= 90) {
      grade = "Excellent Choice";
      progressColor = Colors.green;
    } else if (kealthyScore >= 75) {
      grade = "Good Choice";
      progressColor = Colors.lightGreen;
    } else if (kealthyScore >= 60) {
      grade = "Moderate";
      progressColor = Colors.orange;
    } else if (kealthyScore >= 40) {
      grade = "Needs Improvement";
      progressColor = Colors.yellow.shade700;
    } else {
      grade = "Unhealthy";
      progressColor = Colors.red;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Kealthy Points",
          style: GoogleFonts.poppins(
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 5),
        CircularPercentIndicator(
          radius: radius,
          lineWidth: lineWidth,
          percent: (kealthyScore / 100).clamp(0.0, 1.0),
          center: Text(
            kealthyScore.toStringAsFixed(0),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: progressColor,
            ),
          ),
          progressColor: progressColor,
          backgroundColor: Colors.grey.shade200,
          animation: true,
          animationDuration: 1500,
        ),
        const SizedBox(height: 5),
        Text(
          grade,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: progressColor,
          ),
        ),
      ],
    );
  }
}

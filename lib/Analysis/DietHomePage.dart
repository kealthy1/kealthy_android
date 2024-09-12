import 'package:flutter/material.dart';
import 'Carousel.dart';
import 'Personalised_diet.dart';

class DietHomepage extends StatelessWidget {
  const DietHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Padding(
            //   padding: EdgeInsets.all(16.0),
            //   child: Text(
            //     'Calorie Meter',
            //     style: TextStyle(
            //       fontSize: 24,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            // const SizedBox(
            //   height: 300,
            //   child: WeeklyChart(),
            // ),
            ImageCarousel(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                ' For You',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const DietTrackingPage(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'Personalised_diet.dart';
import 'WeeklyDiagramPage.dart';

class DietHomepage extends StatelessWidget {
  const DietHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: WeeklyChart(),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          SliverFillRemaining(
            child: DietTrackingPage(),
          ),
        ],
      ),
    );
  }
}

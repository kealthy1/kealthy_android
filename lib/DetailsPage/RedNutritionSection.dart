import 'package:flutter/material.dart';

import 'NutritionInfo.dart';

class RedNutritionSection extends StatelessWidget {
  const RedNutritionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NutritionInfo(label: 'Protein', value: '160 g'),
          NutritionInfo(label: 'Carbs', value: '45 g'),
          NutritionInfo(label: 'Kcal', value: '451'),
          NutritionInfo(label: 'Fat', value: '54 g'),
        ],
      ),
    );
  }
}

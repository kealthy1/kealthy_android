import 'package:flutter/material.dart';
import '../MenuPage/menu_item.dart';

class RedNutritionSection extends StatelessWidget {
  final MenuItem menuItem;

  const RedNutritionSection({
    required this.menuItem,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '${menuItem.protein.toStringAsFixed(menuItem.protein.truncateToDouble() == menuItem.protein ? 0 : 1)} g', 
                style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 4.0),
              const Text(
                'Protein',
                style: TextStyle(fontSize: 14.0, color: Colors.white70),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                '${menuItem.carbs.toStringAsFixed(menuItem.carbs.truncateToDouble() == menuItem.carbs ? 0 : 1)} g', 
                style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 4.0),
              const Text(
                'Carbs',
                style: TextStyle(fontSize: 14.0, color: Colors.white70),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                '${menuItem.kcal.toInt()}', 
                style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 4.0),
              const Text(
                'Kcal',
                style: TextStyle(fontSize: 14.0, color: Colors.white70),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                '${menuItem.fat.toStringAsFixed(menuItem.fat.truncateToDouble() == menuItem.fat ? 0 : 1)} g', // Show one decimal place only if needed
                style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 4.0),
              const Text(
                'Fat',
                style: TextStyle(fontSize: 14.0, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

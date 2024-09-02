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
                '${menuItem.protein.toInt()} g', // Display protein value with 'g'
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
                '${menuItem.carbs.toInt()} g', // Display carbs value with 'g'
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
                '${menuItem.kcal.toInt()}', // Display kcal value (commonly kcal doesn't use g)
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
                '${menuItem.fat.toInt()} g', // Display fat value with 'g'
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

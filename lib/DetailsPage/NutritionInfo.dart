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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNutritionCard(
          icon: Icons.energy_savings_leaf,
          value:
              '${menuItem.protein.toStringAsFixed(menuItem.protein.truncateToDouble() == menuItem.protein ? 0 : 1)} g',
          label: 'Protein',
        ),
        _buildNutritionCard(
          icon: Icons.cookie,
          value:
              '${menuItem.carbs.toStringAsFixed(menuItem.carbs.truncateToDouble() == menuItem.carbs ? 0 : 1)} g',
          label: 'Carbs',
        ),
        _buildNutritionCard(
          icon: Icons.local_fire_department,
          value: '${menuItem.kcal.toInt()}',
          label: 'Kcal',
        ),
        _buildNutritionCard(
          icon: Icons.opacity,
          value:
              '${menuItem.fat.toStringAsFixed(menuItem.fat.truncateToDouble() == menuItem.fat ? 0 : 1)} g',
          label: 'Fat',
        ),
      ],
    );
  }

  Widget _buildNutritionCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      width: 80,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.black,
            size: 28.0,
          ),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

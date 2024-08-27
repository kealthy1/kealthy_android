import 'package:flutter/material.dart';

class NutritionInfo extends StatelessWidget {
  final String label;
  final String value;

  const NutritionInfo({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 4.0),
        Text(label, style: const TextStyle(fontSize: 14.0, color: Colors.white70)),
      ],
    );
  }
}
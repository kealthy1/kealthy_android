import 'package:flutter/material.dart';

class DescriptionSection extends StatelessWidget {
  const DescriptionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        'Whole wheat pasta is a nutritious alternative to regular pasta, made from whole grains that retain the bran, germ, and endosperm. It is high in fiber, which aids in digestion and helps maintain stable blood sugar levels. Rich in vitamins, minerals, and antioxidants, whole wheat pasta supports heart health and provides long-lasting energy, making it an excellent choice for a balanced diet.',
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }
}

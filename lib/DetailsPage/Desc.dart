import 'package:flutter/material.dart';
import '../MenuPage/menu_item.dart';

class DescriptionSection extends StatelessWidget {
  final MenuItem menuItem;

  const DescriptionSection({required this.menuItem, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            menuItem.description,
            style: const TextStyle(
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

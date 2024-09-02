import 'package:flutter/material.dart';

class TitleAndRating extends StatelessWidget {
  final MenuItem;
  const TitleAndRating({required this.MenuItem, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${MenuItem.name}',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 8.0),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.orange, size: 20.0),
            Icon(Icons.star, color: Colors.orange, size: 20.0),
            Icon(Icons.star, color: Colors.orange, size: 20.0),
            Icon(Icons.star, color: Colors.orange, size: 20.0),
            Icon(Icons.star_half, color: Colors.orange, size: 20.0),
            SizedBox(width: 8.0),
          ],
        ),
      ],
    );
  }
}

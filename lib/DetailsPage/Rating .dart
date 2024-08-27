import 'package:flutter/material.dart';

class TitleAndRating extends StatelessWidget {
  const TitleAndRating({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Whole Wheat Pasta',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.orange, size: 20.0),
            Icon(Icons.star, color: Colors.orange, size: 20.0),
            Icon(Icons.star, color: Colors.orange, size: 20.0),
            Icon(Icons.star, color: Colors.orange, size: 20.0),
            Icon(Icons.star_half, color: Colors.orange, size: 20.0),
            SizedBox(width: 8.0),
            Text('4/5', style: TextStyle(fontSize: 16.0)),
          ],
        ),
      ],
    );
  }
}
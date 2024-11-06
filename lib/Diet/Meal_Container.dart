import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MealContainer extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final int kcal;
  final int price;
  final String carbs;
  final String fat;
  final double protein;

  const MealContainer({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.kcal,
    required this.price,
    required this.carbs,
    required this.fat,
    required this.protein,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.shade400),
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 5),
                      Text('$kcal Cal'),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.fitness_center,
                          size: 16, color: Colors.green),
                      const SizedBox(width: 5),
                      Text('${protein.toInt()} Protein'),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '₹${price.toString()}/-',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CachedNetworkImage(
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                imageUrl: imageUrl,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

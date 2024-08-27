import 'package:flutter/material.dart';
import 'package:rounded_background_text/rounded_background_text.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.itemName,
    required this.description,
    required this.AvatarText,
  });

  final String imagePath;
  final String title;
  final String itemName;
  final String description;

  final String AvatarText;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    return Container(
      width: screenWidth * 0.90,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: const Border(
            bottom: BorderSide(color: Colors.green),
            left: BorderSide(color: Colors.green),
            right: BorderSide(color: Colors.green),
            top: BorderSide(color: Colors.green)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoundedBackgroundText(
                backgroundColor: const Color.fromARGB(255, 89, 161, 91),
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Text(
                itemName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          Positioned(
            top: -30,
            right: 16,
            child: Column(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(imagePath),
                  radius: 60,
                ),
                const SizedBox(height: 8.0),
                Text(
                  AvatarText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kealthy/MenuPage/Drinks/DrinksPage.dart';
import 'package:kealthy/MenuPage/Food/FoodPage.dart';
import '../../MenuPage/Snacks/SnacksPage.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: screenWidth * 0.06,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoModalPopupRoute(
                    builder: (context) => const SnacksMenuPage(),
                  ));
            },
            child: _buildCategoryAvatar('Kealthy Snacks', 'assets/snacks.greeen_11zon (1).png'),
          ),
          SizedBox(
            width: screenWidth * 0.06,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoModalPopupRoute(
                    builder: (context) => const FoodMenuPage(),
                  ));
            },
            child: _buildCategoryAvatar('  Foods', 'assets/100_11zon (1).png'),
          ),
          SizedBox(
            width: screenWidth * 0.06,
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoModalPopupRoute(
                    builder: (context) => const DrinksMenuPage(),
                  ));
            },
            child: _buildCategoryAvatar(' Drinks', 'assets/102_11zon.jpeg'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryAvatar(String label, String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green,
                width: 2.0,
              ),
            ),
            child: CircleAvatar(
              backgroundImage: AssetImage(imagePath),
              radius: 50,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

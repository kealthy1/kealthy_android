import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kealthy/MenuPage/ProductList.dart';

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
                    builder: (context) => const MenuPage(),
                  ));
            },
            child: _buildCategoryAvatar('SNACKS', 'assets/snacks.greeen.png'),
          ),
          SizedBox(
            width: screenWidth * 0.06,
          ),
          GestureDetector(
            onTap: () {},
            child: _buildCategoryAvatar(' Healthy Meals', 'assets/100.png'),
          ),
          SizedBox(
            width: screenWidth * 0.06,
          ),
          GestureDetector(
            onTap: () {},
            child: _buildCategoryAvatar('Drinks', 'assets/102.jpeg'),
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

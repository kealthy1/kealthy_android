import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kealthy/DetailsPage/HomePage.dart';

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
                    builder: (context) => const HomePage(),
                  ));
            },
            child: _buildCategoryAvatar('Vegetables', 'assets/healthy1.jpg'),
          ),
          SizedBox(
            width: screenWidth * 0.06,
          ),
          GestureDetector(
            onTap: () {},
            child:
                _buildCategoryAvatar('Nuts & Seeds', 'assets/Nuts & Seeds.jpg'),
          ),
          SizedBox(
            width: screenWidth * 0.06,
          ),
          GestureDetector(
            onTap: () {},
            child: _buildCategoryAvatar('Protein', 'assets/Protein.jpg'),
          ),
          SizedBox(
            width: screenWidth * 0.06,
          ),
          GestureDetector(
            onTap: () {},
            child: _buildCategoryAvatar('Snacks', 'assets/snacks.jpg'),
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
              radius: 40,
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

import 'package:flutter/material.dart';

import '../MenuPage/menu_item.dart';

class ImageHeader extends StatelessWidget {
  final MenuItem menuItem;
  const ImageHeader({required this.menuItem, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      child: Stack(
        children: [
          Center(
            child: Image.network(
              menuItem.imageUrl,
              height: screenHeight * 0.28,
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: IconButton(
                icon: const Icon(Icons.share_sharp, color: Colors.white),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../MenuPage/menu_item.dart';
import 'AddCart.dart';
import 'Desc.dart';
import 'Header.dart';
import 'NutritionInfo.dart';
import 'Rating .dart';

class HomePage extends StatelessWidget {
  
  final MenuItem menuItem;
  const HomePage({super.key, required this.menuItem});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 121, 184, 125),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: const Color.fromARGB(255, 121, 184, 125),
              padding: EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: screenWidth * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ImageHeader(menuItem: menuItem),
                  TitleAndRating(MenuItem: menuItem),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: screenWidth * 0.05,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RedNutritionSection(menuItem: menuItem,
                    
                  ),
                  const SizedBox(height: 16.0),
                  const DescriptionSection(),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  AddToCart(menuItem: menuItem),
                  SizedBox(
                    height: screenHeight * 0.1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

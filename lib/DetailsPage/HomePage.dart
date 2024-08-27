import 'package:flutter/material.dart';

import 'AddCart.dart';
import 'Desc.dart';
import 'Header.dart';
import 'Rating .dart';
import 'RedNutritionSection.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ImageHeader(),
                  TitleAndRating(),
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
                  const RedNutritionSection(),
                  const SizedBox(height: 16.0),
                  const DescriptionSection(),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  const AddToCart(pricePerUnit: 120),
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

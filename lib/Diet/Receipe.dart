import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kealthy/Diet/Dieting.dart';
import 'package:kealthy/Diet/Lowcarbdetails.dart';
import 'package:kealthy/Diet/VeganDietDetails.dart';
import 'package:kealthy/Diet/keto_Dietdetails.dart';

class RecipeCard extends StatelessWidget {
  final String imageUrl;
  final String name;

  const RecipeCard({
    super.key,
    required this.imageUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.4,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              imageUrl,
              height: screenWidth * 0.5,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeCardList extends StatelessWidget {
  const RecipeCardList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  CupertinoModalPopupRoute(
                    builder: (context) => const LowCarbDietDetailsPage(),
                  ));
            },
            child: const RecipeCard(
              imageUrl: 'assets/Low-carb-diet.png',
              name: 'Low Carb',
            ),
          ),
          GestureDetector(
            onTap: () {
              {
                Navigator.push(
                    context,
                    CupertinoModalPopupRoute(
                      builder: (context) => const VeganDietDetailsPage(),
                    ));
              }
            },
            child: const RecipeCard(
              imageUrl: 'assets/VEGAN-DIET.jpg',
              name: 'Vegan',
            ),
          ),
          GestureDetector(
            onTap: () {
              {
                Navigator.push(
                    context,
                    CupertinoModalPopupRoute(
                      builder: (context) => const ketoDietDetailsPage(),
                    ));
              }
            },
            child: const RecipeCard(
              imageUrl: 'assets/images.jpeg',
              name: 'Keto',
            ),
          ),
          GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoModalPopupRoute(
                      builder: (context) => const KetogenicDietPage(),
                    ));
              },
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black,
              ))
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:kealthy/LandingPage/Widgets/Appbar.dart';
import 'package:kealthy/LandingPage/Widgets/Carousel.dart';
import 'package:kealthy/LandingPage/Widgets/items.dart';

import 'Widgets/Category.dart';
import 'Widgets/Serach.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SearchInput(),
            ),
            SizedBox(
              height: screenHeight * 0.02,
            ),
            CarouselSliderWidget(
              autoPlay: true,
            ),
            SizedBox(
              height: screenHeight * 0.02,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 23),
              child: Text(
                'Food Category',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const CategoryGrid(),
            SizedBox(
              height: screenHeight * 0.05,
            ),
            const Center(
              child: ItemCard(
                imagePath: 'assets/pancakes.jpg',
                title: 'Breakfast',
                itemName: 'Pancakes',
                description:
                    'Delicious pancakes\n with syrup and fresh fruits.',
                AvatarText: '4.4⭐',
              ),
            ),
            SizedBox(
              height: screenHeight * 0.05,
            ),
            const Center(
              child: ItemCard(
                imagePath: 'assets/Salad.jpg',
                title: 'Lunch',
                itemName: 'Salad',
                description: 'Fresh garden salad with\nvinaigrette.',
                AvatarText: '4.2⭐',
              ),
            ),
            SizedBox(
              height: screenHeight * 0.05,
            ),
            const Center(
              child: ItemCard(
                imagePath: 'assets/Chicken Spinach Pasta.jpg',
                title: 'Dinner',
                itemName: 'Spinach Pasta',
                description:
                    'Cleanup is a breeze with\nthis creamy spinach chicken.',
                AvatarText: '4.2⭐',
              ),
            ),
            SizedBox(
              height: screenHeight * 0.1,
            ),
          ],
        ),
      ),
    );
  }
}

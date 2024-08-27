import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CarouselSliderWidget extends StatefulWidget {
  final List<String> assetImagePaths = [
    'assets/healthy1.jpg',
    'assets/2.png',
    'assets/50%off.png',
    'assets/3.png',
    'assets/4.png',
    'assets/5.png',
    'assets/6.png',
    'assets/7.png',
    'assets/8.png',
  ];

  final bool autoPlay;

  CarouselSliderWidget({
    super.key,
    this.autoPlay = true,
  });

  @override
  _CarouselSliderWidgetState createState() => _CarouselSliderWidgetState();
}

class _CarouselSliderWidgetState extends State<CarouselSliderWidget> {
  int activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final double responsiveHeight = screenHeight * 0.2;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CarouselSlider.builder(
          itemCount: widget.assetImagePaths.length,
          itemBuilder: (context, index, realIndex) {
            final assetImagePath = widget.assetImagePaths[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0), // Circular edges
                child: SizedBox(
                  height: responsiveHeight, // Reduced height
                  child: Image.asset(
                    assetImagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
          options: CarouselOptions(
            viewportFraction: 0.8,
            autoPlay: widget.autoPlay,
            enlargeCenterPage: false,
            aspectRatio: 22 / 9,
            autoPlayCurve: Curves.linear,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            scrollDirection: Axis.horizontal,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) =>
                setState(() => activeIndex = index),
          ),
        ),
        const SizedBox(height: 16.0),
        buildIndicator(),
      ],
    );
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: widget.assetImagePaths.length,
        effect: const ExpandingDotsEffect(
          dotHeight: 10,
          dotWidth: 10,
          activeDotColor: Colors.green,
          dotColor: Colors.grey,
        ),
      );
}

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../Riverpod/carousel_slider_notifier.dart';

class CarouselSliderWidget extends ConsumerWidget {
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

  CarouselSliderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final activeIndex = ref.watch(carouselSliderProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CarouselSlider.builder(
          itemCount: assetImagePaths.length,
          itemBuilder: (context, index, realIndex) {
            final assetImagePath = assetImagePaths[index];
            return Container(
              width: screenWidth * 19,
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  assetImagePath,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
          options: CarouselOptions(
            viewportFraction: 0.8,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 19 / 8,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            scrollDirection: Axis.horizontal,
            enableInfiniteScroll: true,
            onPageChanged: (index, reason) {
              ref.read(carouselSliderProvider.notifier).updateIndex(index);
            },
          ),
        ),
        const SizedBox(height: 16.0),
        buildIndicator(activeIndex),
      ],
    );
  }

  Widget buildIndicator(int activeIndex) => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: 8,
        effect: const ExpandingDotsEffect(
          dotHeight: 10,
          dotWidth: 10,
          activeDotColor: Colors.green,
          dotColor: Colors.grey,
        ),
      );
}

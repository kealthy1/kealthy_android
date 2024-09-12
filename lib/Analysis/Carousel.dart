import 'package:flutter/material.dart';
import 'package:kealthy/Analysis/Calorie.dart';
import 'package:kealthy/Cart/Cart_Items.dart';
import 'package:kealthy/MenuPage/Snacks/SnacksPage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final carouselIndexProvider = StateProvider<int>((ref) => 0);

class ImageCarousel extends ConsumerWidget {
  final List<ImageCarouselData> carouselData = [
    ImageCarouselData(
        imagePath: 'assets/2.png',
        text: 'Calorie Intake',
        subtext: 'Daily Calorie Intake Calculator'),
    ImageCarouselData(
        imagePath: 'assets/2.png',
        text: 'Description for Image 2',
        subtext: ''),
    ImageCarouselData(
        imagePath: 'assets/2.png',
        text: 'Description for Image 3',
        subtext: ''),
  ];

  ImageCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController =
        PageController(initialPage: ref.watch(carouselIndexProvider));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 150,
            child: PageView.builder(
              controller: pageController,
              itemCount: carouselData.length,
              onPageChanged: (index) {
                ref.read(carouselIndexProvider.notifier).state = index;
              },
              itemBuilder: (context, index) {
                final data = carouselData[index];

                return GestureDetector(
                  onTap: () {
                    if (index == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CalorieIntakePage()),
                      );
                    } else if (index == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ShowCart()),
                      );
                    } else if (index == 3) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SnacksMenuPage()),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            data.imagePath,
                          ),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                data.subtext,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                data.text,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        SmoothPageIndicator(
          controller: pageController,
          count: carouselData.length,
          effect: const ExpandingDotsEffect(
            dotHeight: 10,
            dotWidth: 10,
            activeDotColor: Colors.green,
            dotColor: Colors.grey,
            spacing: 4.0,
          ),
        ),
      ],
    );
  }
}

class ImageCarouselData {
  final String imagePath;
  final String text;
  final String subtext;

  ImageCarouselData({
    required this.imagePath,
    required this.text,
    required this.subtext,
  });
}

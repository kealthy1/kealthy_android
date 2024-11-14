import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shimmer/shimmer.dart';
import '../../MenuPage/MenuPage.dart';
import '../../Riverpod/Carousel.dart';
import '../../Services/image_links.dart';

class CarouselSliderWidget extends ConsumerStatefulWidget {
  const CarouselSliderWidget({super.key});

  @override
  _CarouselSliderWidgetState createState() => _CarouselSliderWidgetState();
}

class _CarouselSliderWidgetState extends ConsumerState<CarouselSliderWidget> {
  late PageController _pageController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      final currentIndex = ref.read(carouselIndexProvider);
      final nextIndex = (currentIndex + 1) % ImageLinks.networkImageUrls.length;

      ref.read(carouselIndexProvider.notifier).setIndex(nextIndex);
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(carouselIndexProvider);

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _pageController,
            itemCount: ImageLinks.networkImageUrls.length,
            onPageChanged: (index) {
              ref.read(carouselIndexProvider.notifier).setIndex(index);
            },
            itemBuilder: (context, index) {
              return Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final page = _getDetailPage(index);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => page),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: CachedNetworkImage(
                          imageUrl: ImageLinks.networkImageUrls[index],
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              color: Colors.grey[300],
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          final page = _getDetailPage(index);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => page),
                          );
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.arrow_forward_ios, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Explore',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            ImageLinks.textsForImages[index],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8.0),
        SmoothPageIndicator(
          controller: _pageController,
          count: ImageLinks.networkImageUrls.length,
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

  Widget _getDetailPage(int index) {
    switch (index) {
      case 0:
        return const MenuPage(
          categoryName: '',
        );
      case 1:
        return const MenuPage(
          categoryName: '',
        );
      case 2:
        return const MenuPage(
          categoryName: '',
        );
      // case 3:
      //   return const CalorieIntakePage();
      // case 4:
      //   return ImageDetailPage5();
      default:
        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: Text('  ')),
        );
    }
  }
}

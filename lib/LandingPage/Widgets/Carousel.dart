import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/Services/BMI/Bmi.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Riverpod/Carousel.dart';
import '../../Services/BMI/calorie.dart';
import '../../Services/Blogs/BlogList.dart';
import '../../Services/Cache.dart';

class CarouselItem {
  final String imageUrl;
  final String title;

  CarouselItem({required this.imageUrl, required this.title});
}

final carouselProvider = FutureProvider<List<CarouselItem>>((ref) async {
  final querySnapshot =
      await FirebaseFirestore.instance.collection('Carousel').get();

  return querySnapshot.docs.expand((doc) {
    final data = doc.data();
    final List<String> images = List<String>.from(data['Image'] ?? []);
    final List<String> titles = List<String>.from(data['Title'] ?? []);

    return List<CarouselItem>.generate(images.length, (index) {
      final title = index < titles.length ? titles[index] : "No Title";
      return CarouselItem(imageUrl: images[index], title: title);
    });
  }).toList();
});

class CarouselSliderWidget extends ConsumerStatefulWidget {
  const CarouselSliderWidget({super.key});

  @override
  _CarouselSliderWidgetState createState() => _CarouselSliderWidgetState();
}

class _CarouselSliderWidgetState extends ConsumerState<CarouselSliderWidget> {
  late final PageController _pageController;
  Timer? _timer;
  bool _isAutoScrollInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carouselData = ref.watch(carouselProvider);

    return carouselData.when(
      data: (items) {
        if (items.isEmpty) {
          return Center(
              child: Image.asset(
            "assets/splashscreen.JPG",
            height: 100,
          ));
        }

        _startAutoScroll(items.length);

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: items.length,
                  onPageChanged: (index) {
                    ref.read(carouselIndexProvider.notifier).setIndex(index);
                  },
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () => _navigateToScreen(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                cacheManager: CustomCacheManager(),
                                imageUrl: item.imageUrl,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    height: 150,
                                    color: Colors.grey[300],
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                                fit: BoxFit.fill,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              Container(
                                color: Colors.black.withOpacity(0.2),
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 5),
                                  child: Text(
                                    item.title,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.end,
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
              controller: _pageController,
              count: items.length,
              effect: const ExpandingDotsEffect(
                dotHeight: 10,
                dotWidth: 10,
                activeDotColor: Color(0xFF273847),
                dotColor: Colors.grey,
                spacing: 4.0,
              ),
            ),
          ],
        );
      },
      loading: () => Center(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 150,
            color: Colors.grey[300],
          ),
        ),
      ),
      error: (error, stack) => Center(child: Text("Error: $error")),
    );
  }

  void _startAutoScroll(int itemCount) {
    if (_isAutoScrollInitialized) return;
    _isAutoScrollInitialized = true;

    int currentIndex = 0;
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !_pageController.hasClients) {
        timer.cancel();
        return;
      }

      final nextIndex = (currentIndex + 1) % itemCount;

      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      currentIndex = nextIndex;
      ref.read(carouselIndexProvider.notifier).setIndex(nextIndex);
    });
  }

  void _navigateToScreen(int index) async {
    String url;
    switch (index) {
      case 0:
        Navigator.push(
          context,
          CupertinoModalPopupRoute(builder: (context) => const BlogListPage()),
        );
        break;
      case 1:
        url =
            'https://www.instagram.com/kealthy.life?igsh=MXVqa2hicG4ydzB5cQ==';
        await _launchURL(url);
        break;
      case 2:
        url = 'https://x.com/Kealthy_life/';
        await _launchURL(url);
        break;
      case 3:
        url =
            'https://www.facebook.com/profile.php?id=61571096468965&mibextid=ZbWKwL';
        await _launchURL(url);
        break;
      case 4:
        Navigator.push(
          context,
          CupertinoModalPopupRoute(
              builder: (context) => const CalorieIntakePage()),
        );
        break;
        case 5:
        Navigator.push(
          context,
          CupertinoModalPopupRoute(
              builder: (context) =>  BmiTrackerPage()),
        );
      default:
        break;
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}

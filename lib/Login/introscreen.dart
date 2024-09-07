import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Riverpod/Texanimation.dart';
import 'login_page.dart';

final pageIndexProvider = StateProvider<int>((ref) => 0);

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(); 
    _pageController.addListener(() {
      ref.read(pageIndexProvider.notifier).state =
          _pageController.page?.round() ?? 0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageIndex = ref.watch(pageIndexProvider);

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int index) {
              ref.read(opacityProvider.notifier).state = 0.0;
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  ref.read(opacityProvider.notifier).state = 1.0;
                }
              });
            },
            children: const [
              IntroPage1(),
              IntroPage2(),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      height: 12,
                      width: pageIndex == index ? 24 : 12,
                      decoration: BoxDecoration(
                        color: pageIndex == index
                            ? Colors.greenAccent
                            : Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    );
                  }),
                ),
                IconButton(
                  onPressed: () {
                    if (pageIndex < 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginFields()),
                      );
                    }
                  },
                  icon: const Icon(
                    CupertinoIcons.arrow_right_circle_fill,
                    size: 70,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class IntroPage1 extends ConsumerStatefulWidget {
  const IntroPage1({super.key});

  @override
  _IntroPage1State createState() => _IntroPage1State();
}

class _IntroPage1State extends ConsumerState<IntroPage1> {
  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      ref.read(opacityProvider.notifier).state = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white24,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/1dd0cf5b057eafa743335515fedd60a1.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: 1.0, sigmaY: 1.0), 
            child: Container(
              color: Colors.black.withOpacity(
                  0.3),
            ),
          ),
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 10, top: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInText(
                    text: 'FUEL YOUR DAY WITH',
                    duration: Duration(seconds: 1),
                    color: Colors.white,
                    fontSize: 30.0,
                  ),
                  FadeInText(
                    text: 'FRESHNESS.',
                    duration: Duration(seconds: 1),
                    color: Colors.greenAccent,
                    fontSize: 100.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IntroPage2 extends ConsumerStatefulWidget {
  const IntroPage2({super.key});

  @override
  _IntroPage2State createState() => _IntroPage2State();
}

class _IntroPage2State extends ConsumerState<IntroPage2> {
  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.read(opacityProvider.notifier).state = 1.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white24,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/9ae5cf7d39ac604f9c2fc2cc01e99862.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: 1.0, sigmaY: 1.0),
            child: Container(
              color: Colors.black.withOpacity(
                  0.3), 
            ),
          ),
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 10, top: 100, bottom: 35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInText(
                    text: 'DELICIOUSLY',
                    duration: Duration(seconds: 1),
                    color: Colors.white,
                    fontSize: 30.0,
                  ),
                  FadeInText(
                    text: 'GUILT FREE.',
                    duration: Duration(seconds: 1),
                    color: Colors.yellowAccent,
                    fontSize: 100.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

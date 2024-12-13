import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/LandingPage/Myprofile.dart';
import 'package:kealthy/LandingPage/Widgets/Category.dart';
import '../MenuPage/MenuPage.dart';
import '../MenuPage/Search_provider.dart';
import '../Riverpod/BackButton.dart';
import '../Riverpod/NavBar.dart';
import '../Services/DeliveryIn_Kakkanad.dart';
import '../Services/FirestoreCart.dart';
import '../Services/TimeValidator.dart';
import 'Cart_Container.dart';
import 'Widgets/Appbar.dart';
import 'Widgets/Carousel.dart';
import 'Widgets/Serach.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  void initState() {
    // ignore: unused_result
    ref.refresh(userProfileProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(refreshTriggerProvider.notifier).state =
          !ref.read(refreshTriggerProvider);
    });

    _checkTime();
    super.initState();
  }

  void _checkTime() async {
    bool isTimeValid = await TimeValidator.validateTime();
    if (!isTimeValid) {
      _showErrorAndExit();
    }
  }

  void _showErrorAndExit(
      {String message =
          'Your device time does not match the server time. Please correct it.'}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Icon(
          CupertinoIcons.exclamationmark_circle,
          color: Colors.red,
          size: 80,
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black, fontFamily: "poppins"),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              openDateAndTimeSettings();
            },
            child: const Text(
              'Settings',
              style: TextStyle(fontFamily: "poppins"),
            ),
          ),
        ],
      ),
    );
  }

  void openDateAndTimeSettings() {
    if (Platform.isAndroid) {
      const intent = AndroidIntent(
        action: 'android.settings.DATE_SETTINGS',
      );
      intent.launch();
    } else {
      print('This feature is only available on Android devices.');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(deliveryLimitProvider);
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final cartItems = ref.watch(sharedPreferencesCartProvider);
    final isVisible = ref.watch(cartVisibilityProvider);

    const int profilePageIndex = 1;
    final List<Widget> pages = [
      _buildHomePage(context, ref),
      const ProfilePage(),
    ];

    return WillPopScope(
      onWillPop: () async {
        final notifier = ref.read(backPressProvider.notifier);
        notifier.onBackPressed();

        if (notifier.shouldExitApp()) {
          return Future.value(true);
        } else {
          Fluttertoast.showToast(
            msg: "Press back again to exit",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return Future.value(false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(),
        body: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo is ScrollEndNotification) {
              ref.read(cartVisibilityProvider.notifier).setVisible(true);
            } else if (scrollInfo.metrics.axis == Axis.vertical) {
              final isScrollingDown = scrollInfo.metrics.pixels >
                  scrollInfo.metrics.minScrollExtent;
              ref
                  .read(cartVisibilityProvider.notifier)
                  .setVisible(!isScrollingDown);
            }
            return true;
          },
          child: pages[currentIndex],
        ),
        bottomSheet: cartItems.isNotEmpty &&
                currentIndex != profilePageIndex &&
                isVisible
            ? AnimatedOpacity(
                opacity: isVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const CartContainer(),
              )
            : null,
      ),
    );
  }
}

Widget _buildHomePage(BuildContext context, WidgetRef ref) {
  final screenHeight = MediaQuery.of(context).size.height;
  ref.watch(menuProvider);

  return SingleChildScrollView(
    scrollDirection: Axis.vertical,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: SearchInput(),
        ),
        const CarouselSliderWidget(),
        SizedBox(height: screenHeight * 0.03),
        _buildCenteredTitle('Categories'),
        SizedBox(height: screenHeight * 0.03),
        const CategoryGrid(),
        SizedBox(height: screenHeight * 0.03),
      ],
    ),
  );
}

Widget _buildCenteredTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(left: 20, right: 20),
    child: Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: "poppins",
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    ),
  );
}

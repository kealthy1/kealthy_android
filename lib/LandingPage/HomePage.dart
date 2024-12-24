import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/LandingPage/Myprofile/Myprofile.dart';
import 'package:kealthy/LandingPage/Widgets/Category.dart';
import '../MenuPage/MenuPage.dart';
import '../MenuPage/Search_provider.dart';
import '../Riverpod/NavBar.dart';
import '../Services/DeliveryIn_Kakkanad.dart';
import '../Services/FirestoreCart.dart';
import '../Services/NotificationHandler.dart';
import 'Cart_Container.dart';
import 'Widgets/Appbar.dart';
import 'Widgets/Carousel.dart';
import 'Widgets/Serach.dart';

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

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NotificationHandler.initialize(context, ref);
    ref.watch(deliveryLimitProvider);
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final cartItems = ref.watch(sharedPreferencesCartProvider);
    final isVisible = ref.watch(cartVisibilityProvider);

    const int profilePageIndex = 1;
    final List<Widget> pages = [
      _buildHomePage(context, ref),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification) {
            ref.read(cartVisibilityProvider.notifier).setVisible(true);
          } else if (scrollInfo.metrics.axis == Axis.vertical) {
            final isScrollingDown =
                scrollInfo.metrics.pixels > scrollInfo.metrics.minScrollExtent;
            ref
                .read(cartVisibilityProvider.notifier)
                .setVisible(!isScrollingDown);
          }
          return true;
        },
        child: pages[currentIndex],
      ),
      bottomSheet:
          cartItems.isNotEmpty && currentIndex != profilePageIndex && isVisible
              ? AnimatedOpacity(
                  opacity: isVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const CartContainer(),
                )
              : null,
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

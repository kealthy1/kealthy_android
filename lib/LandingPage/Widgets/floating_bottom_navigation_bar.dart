import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/LandingPage/Myprofile/Myprofile.dart';
import 'package:kealthy/Orders/ordersTab.dart';
import 'package:kealthy/Services/update.dart';
import '../../Riverpod/BackButton.dart';
import '../HomePage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Appbar.dart';

final ordersProvider = StateProvider<bool>((ref) => false);

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class CustomBottomNavigationBar extends ConsumerWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final buttonVisible = ref.watch(movableButtonProvider);

    final List<Widget> pages = [
      const MyHomePage(),
      const ProfilePage(),
      const OrdersTabScreen()
    ];

    final bottomNavItems = [
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.house_fill),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.person),
        label: 'Profile',
      ),
      if (buttonVisible)
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 15,
                  backgroundImage: AssetImage("assets/Delivery Boy (1).gif"),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -7),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Live',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          label: 'Live Orders',
        ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.checkForUpdate(context);
    });

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
        body: pages[currentIndex],
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            highlightColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              ref.read(bottomNavIndexProvider.notifier).state = index;
            },
            type: BottomNavigationBarType.fixed,
            unselectedLabelStyle: GoogleFonts.poppins(),
            selectedLabelStyle: GoogleFonts.poppins(),
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF273847),
            unselectedItemColor: Colors.grey,
            items: bottomNavItems,
          ),
        ),
      ),
    );
  }
}

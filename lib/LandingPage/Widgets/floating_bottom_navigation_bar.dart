// ignore_for_file: unused_result
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/LandingPage/Ai/ai.dart';
import 'package:kealthy/LandingPage/Myprofile/Myprofile.dart';
import 'package:kealthy/Services/update.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:shared_preferences/shared_preferences.dart';
import '../../Riverpod/BackButton.dart';
import '../../Services/Location_Permission.dart';
import '../../Services/NotificationHandler.dart';
import '../../Services/fcm_permission.dart';
import '../Ai/Floating_button.dart';
import '../HomePage.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final ordersProvider = StateProvider<bool>((ref) => false);
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class CustomBottomNavigationBar extends ConsumerStatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState
    extends ConsumerState<CustomBottomNavigationBar> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phoneNumber') ?? '';

      if (phoneNumber.isEmpty) {
        return;
      }
      UpdateService.checkForUpdate(context);

      perm.PermissionStatus status = await perm.Permission.notification.status;
      if (status == perm.PermissionStatus.permanentlyDenied ||
          status == perm.PermissionStatus.denied) {
        NotificationPermission.showNotificationBottomSheet(context);
      }

      final locationServiceChecker = LocationServiceChecker(context);
      locationServiceChecker.startChecking();
      if (mounted && navigatorKey.currentContext != null) {
        NotificationHandler.initialize(navigatorKey.currentContext!, ref);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    final List<Widget> pages = [
      const MyHomePage(),
      const ProfilePage(),
    ];

    final bottomNavItems = [
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.house_fill),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(CupertinoIcons.person),
        label: 'Profile',
      ),
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
        body: Stack(
          children: [
            pages[currentIndex],
            Positioned(
              top: MediaQuery.of(context).size.height * 0.7,
              right: 11.0,
              child: ReusableFloatingActionButton(
                imageUrl: 'assets/nutri (2).png',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatScreen()),
                  );
                },
                label: 'Ask Nutri',
              ),
            ),
          ],
        ),
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

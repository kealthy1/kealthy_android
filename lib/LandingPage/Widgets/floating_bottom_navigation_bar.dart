import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/LandingPage/Myprofile/Myprofile.dart';
import 'package:kealthy/Orders/ordersTab.dart';
import 'package:kealthy/Services/update.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import '../../Riverpod/BackButton.dart';
import '../../Services/Location_Permission.dart';
import '../../Services/fcm_permission.dart';
import '../HomePage.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
      UpdateService.checkForUpdate(context);

      perm.PermissionStatus status = await perm.Permission.notification.status;
      if (status == perm.PermissionStatus.permanentlyDenied ||
          status == perm.PermissionStatus.denied) {
        NotificationPermission.showNotificationBottomSheet(context);
      }

      final locationServiceChecker = LocationServiceChecker(context);
      locationServiceChecker.startChecking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

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

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Login/SplashScreen.dart';
import 'package:kealthy/Services/Connection.dart';
import 'Services/Location_Permission.dart';
import 'Services/location_dialog_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationDialogManager = LocationDialogManager(ref);
      if (navigatorKey.currentContext != null) {
        locationDialogManager
            .fetchAndCheckLocation(navigatorKey.currentContext!);
      }
      final locationServiceChecker =
          LocationServiceChecker(navigatorKey.currentContext!);
      locationServiceChecker.startChecking();
    });
    return MaterialApp(
      theme: ThemeData(
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Kealthy',
      home: const ConnectivityWidget(
        child: SplashScreen(),
      ),
    );
  }
}

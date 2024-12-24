import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Login/SplashScreen.dart';
import 'package:kealthy/Services/Connection.dart';
import 'package:kealthy/Services/NotificationHandler.dart';
import 'Maps/SelectAdress.dart';
import 'Payment/SavedAdress.dart';
import 'Services/Fcm.dart';
import 'Services/Location_Permission.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await NotificationService.instance.initialize();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final container = ProviderContainer();
  try {
    container.read(addressesProvider);
    container.read(selectedAddressProviders);
    print("Addresses prefetched successfully.");
  } catch (e) {
    print("Error prefetching addresses: $e");
  }
     

  runApp(
    ProviderScope(
      parent: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationHandler.initialize(navigatorKey.currentContext!, ref);

      final locationServiceChecker =
          LocationServiceChecker(navigatorKey.currentContext!);
      locationServiceChecker.startChecking();
    });

    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionHandleColor: const Color(0xFF273847),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Kealthy',
      home: const ConnectivityWidget(
        child: SplashScreen(),
      ),
    );
  }
}

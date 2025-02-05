import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/DetailsPage/Ratings/Alert.dart';
import 'package:kealthy/Login/SplashScreen.dart';
import 'package:kealthy/MenuPage/MenuPage.dart';
import 'package:kealthy/Services/Blogs/Blog.dart';
import 'package:kealthy/Services/Connection.dart';
import 'package:kealthy/Services/NotificationHandler.dart';
import 'DetailsPage/NutritionInfo.dart';
import 'DetailsPage/Ratings/Providers.dart';
import 'DetailsPage/Ratings/Show_Review.dart';
import 'LandingPage/Widgets/Carousel.dart';
import 'LandingPage/Widgets/searchprovider.dart';
import 'Maps/SelectAdress.dart';
import 'Maps/fluttermap.dart';
import 'Payment/SavedAdress.dart';
import 'Riverpod/order_provider.dart';
import 'Services/Fcm.dart';
import 'Services/Notifications/FromFirestore.dart';
import 'Services/adresslisten.dart';
import 'Services/updateinapp.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  await NotificationService.instance.initialize();
  await ReviewService.instance.initialize(navigatorKey);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final container = ProviderContainer();

  try {
    container.read(addressesProvider);
    container.read(showAddressProviders);
    container.read(selectedAddressProvider);
    container.read(updateAddressProvider);
    container.read(veganDietProvider);
    container.read(selectedPositionProvider);
    container.read(currentlocationProviders);
    container.read(productProvider);
    container.read(carouselProvider);
    container.read(blogProvider);
    container.read(orderProvider);
    container.read(rateProductProvider);
    container.read(averageStarsProvider(''));
    container.read(orderStatusProvider);
    container.read(firestoreNotificationProvider);
    print("Data prefetched successfully.");
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
      InAppUpdateService().checkForUpdate(context);
      NotificationHandler.initialize(navigatorKey.currentContext!, ref);
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

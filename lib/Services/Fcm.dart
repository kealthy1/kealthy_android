import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:ui' as ui;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNotifications();

  final imageUrl = message.notification?.android?.imageUrl ??
      message.notification?.apple?.imageUrl;

  await NotificationService.instance.showNotification(
    title: message.notification?.title ?? "",
    body: message.notification?.body ?? "",
    imageUrl: imageUrl,
  );
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final imageUrl = message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl;

      showNotification(
        title: message.notification?.title ?? "",
        body: message.notification?.body ?? "",
        imageUrl: imageUrl,
      );
    });

    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token!);

    await setupFlutterNotifications();
  }

  Future<void> setupFlutterNotifications() async {
    if (_isInitialized) return;

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      showBadge: true,
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('mipmap/ic_launcher'),
    );

    await flutterLocalNotificationsPlugin.initialize(settings);
    _isInitialized = true;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    BigPictureStyleInformation? bigPictureStyle;
    ByteArrayAndroidBitmap? largeIcon;
    int calculateResponsiveDimension(int baseSize, double scaleFactor) {
      return (baseSize * scaleFactor).toInt();
    }

    int baseWidth = 400;
    int baseHeight = 350;
    final double devicePixelRatio =
        WidgetsBinding.instance.window.devicePixelRatio;
    int responsiveWidth =
        calculateResponsiveDimension(baseWidth, devicePixelRatio);
    int responsiveHeight =
        calculateResponsiveDimension(baseHeight, devicePixelRatio);

    if (imageUrl != null) {
      try {
        final imageBytes = await _downloadImage(imageUrl,
            width: responsiveWidth, height: responsiveHeight);

        largeIcon = ByteArrayAndroidBitmap(imageBytes);

        bigPictureStyle = BigPictureStyleInformation(
          ByteArrayAndroidBitmap(imageBytes),
          contentTitle: title,
          summaryText: body,
        );
      } catch (e) {
        print('Error loading notification image: $e');
      }
    }

    Int64List vibrationPattern = Int64List.fromList([0, 500, 1000, 500]);

    await _localNotifications.show(
      title.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
          vibrationPattern: vibrationPattern,
          styleInformation: bigPictureStyle,
          enableVibration: true,
          icon: 'drawable/ic_notification',
          largeIcon: largeIcon,
          ledColor: const Color.fromARGB(255, 246, 248, 246),
          ledOnMs: 1000,
          ledOffMs: 500,
        ),
      ),
    );
  }

  Future<Uint8List> _downloadImage(String url,
      {int width = 400, int height = 350}) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final codec = await ui.instantiateImageCodec(
        response.bodyBytes,
        targetWidth: width,
        targetHeight: height,
      );

      final frame = await codec.getNextFrame();
      final resizedImage = frame.image;

      final byteData =
          await resizedImage.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } else {
      throw Exception('Failed to download image from $url');
    }
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Services/Notifications/Home.dart';

class ReviewService {
  ReviewService._();
  static final ReviewService instance = ReviewService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize(GlobalKey<NavigatorState> navigatorKey) async {
    if (_isInitialized) {
      return;
    }

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      showBadge: true,
      enableVibration: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('mipmap/ic_launcher'),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final String? payload = response.payload;

        if (payload == "review_screen") {
          navigatorKey.currentState?.pushReplacement(
            CupertinoModalPopupRoute(
              builder: (context) => NotificationHome(),
            ),
          );
        }
      },
    );

    _isInitialized = true;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  }) async {
    await _deleteSharedPreferenceData(["notification_shown", "order_id"]);
    ByteArrayAndroidBitmap? bigPicture;
    ByteArrayAndroidBitmap? largeIcon;

    if (imageUrl != null) {
      try {
        final Uint8List imageData = await _fetchImage(imageUrl);

        bigPicture = ByteArrayAndroidBitmap(imageData);
        largeIcon = ByteArrayAndroidBitmap(imageData);
      } catch (e) {
        print("Error loading notification image: $e");
      }
    }

    final BigPictureStyleInformation? bigPictureStyle = bigPicture != null
        ? BigPictureStyleInformation(
            bigPicture,
            largeIcon: largeIcon,
            contentTitle: title,
            summaryText: body,
          )
        : null;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails('Alert', 'High Importance Notifications',
            channelDescription: 'This channel is used for Alert',
            importance: Importance.high,
            priority: Priority.high,
            colorized: true,
            autoCancel: false,
            channelShowBadge: true,
            enableVibration: true,
            largeIcon: largeIcon,
            icon: 'drawable/ic_notification',
            styleInformation: bigPictureStyle,
            color: Colors.white);

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotifications.show(
      0,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  Future<void> _deleteSharedPreferenceData(List<String> keys) async {
    final prefs = await SharedPreferences.getInstance();

    for (String key in keys) {
      if (prefs.containsKey(key)) {
        await prefs.remove(key);
        print("✅ SharedPreferences data [$key] deleted successfully");
      } else {
        print("⚠️ No data found for key: $key");
      }
    }
  }

  Future<Uint8List> _fetchImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("Failed to load image from URL");
    }
  }
}

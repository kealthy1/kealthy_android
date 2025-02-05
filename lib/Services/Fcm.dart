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
        carPlay: true,
        announcement: true,
        criticalAlert: true,
        providesAppNotificationSettings: true,
        provisional: true);

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
    Int64List vibrationPattern = Int64List.fromList([0, 500, 1000, 500]);
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      vibrationPattern: vibrationPattern,
      showBadge: true,
      enableVibration: true,
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
    bool playSoundContinuously = false,
  }) async {
    BigPictureStyleInformation? bigPictureStyle;
    BigTextStyleInformation? bigTextStyle;
    ByteArrayAndroidBitmap? largeIcon;

    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final imageBytes =
            await _downloadImage(imageUrl, targetWidth: 800, targetHeight: 400);

        largeIcon = ByteArrayAndroidBitmap(imageBytes);

        bigPictureStyle = BigPictureStyleInformation(
          ByteArrayAndroidBitmap(imageBytes),
          contentTitle: title,
          summaryText: body,
        );
      } else {
        bigTextStyle = BigTextStyleInformation(body);
      }
    } catch (e) {
      print('Error loading notification image: $e');
      bigTextStyle = BigTextStyleInformation(body);
    }

    Int64List vibrationPattern = Int64List.fromList([0, 500, 1000, 500]);

    await _localNotifications.show(
      title.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
            'high_importance_channel', 'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            vibrationPattern: vibrationPattern,
            styleInformation: imageUrl != null ? bigPictureStyle : bigTextStyle,
            enableVibration: true,
            icon: 'drawable/ic_notification',
            largeIcon: largeIcon,
            ledColor: const Color.fromARGB(255, 246, 248, 246),
            ledOnMs: 1000,
            ledOffMs: 500,
            showWhen: true,
            playSound: true,
            onlyAlertOnce: false),
      ),
    );
  }

  Future<Uint8List> _downloadImage(String url,
      {int targetWidth = 400, int targetHeight = 600}) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Uint8List imageBytes = response.bodyBytes;
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final originalImage = frame.image;

      // Get original dimensions
      final int originalWidth = originalImage.width;
      final int originalHeight = originalImage.height;

      // Maintain aspect ratio
      double aspectRatio = originalWidth / originalHeight;
      int newWidth = targetWidth;
      int newHeight = (targetWidth / aspectRatio).toInt();

      if (newHeight > targetHeight) {
        newHeight = targetHeight;
        newWidth = (targetHeight * aspectRatio).toInt();
      }

      // Resize Image
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint()..filterQuality = FilterQuality.high;

      final srcRect = Rect.fromLTWH(
          0, 0, originalWidth.toDouble(), originalHeight.toDouble());
      final dstRect =
          Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble());

      canvas.drawImageRect(originalImage, srcRect, dstRect, paint);
      final picture = recorder.endRecording();
      final img = await picture.toImage(newWidth, newHeight);

      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } else {
      throw Exception('Failed to download image from $url');
    }
  }
}

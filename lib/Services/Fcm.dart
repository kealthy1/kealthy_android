import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.setupFlutterNotifications();
  await NotificationService.instance.showNotification(
    title: message.notification?.title ?? "",
    body: message.notification?.body ?? "",
  );
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(
        title: message.notification?.title ?? "Foreground Notification",
        body: message.notification?.body ?? "No details available",
      );
    });
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    await setupFlutterNotifications();
  }

  Future<void> setupFlutterNotifications() async {
    if (_isInitialized) return;

    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('mipmap/ic_launcher'),
    );
    await _localNotifications.initialize(settings);
    _isInitialized = true;
  }

  Future<void> showNotification(
      {required String title, required String body}) async {
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
          icon: 'drawable/ic_notification',
        ),
      ),
    );
  }
}

class DatabaseListener {
  final _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://kealthy-90c55-dd236.firebaseio.com/',
  );

  void listenForOrderStatusChanges() async {
    // Fetch the phone number from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');

    if (phoneNumber == null) {
      print("No phone number found in SharedPreferences.");
      return;
    }

    final ordersRef = _database.ref('orders');

    // Listen for changes in the orders node
    ordersRef.onChildChanged.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null &&
          data.containsKey('status') &&
          data.containsKey('phoneNumber')) {
        // Filter by phoneNumber
        if (data['phoneNumber'] == phoneNumber) {
          final orderId = event.snapshot.key;
          final status = data['status'] ?? "Unknown";

          print(
              'Order $orderId for phoneNumber $phoneNumber status changed to: $status');

          String notificationTitle = "Order Update";
          String notificationBody;

          switch (status) {
            case "Order Packed":
              notificationTitle = "Out for Delivery";
              notificationBody = "Your order is on the way.";
              break;
            case "Order Reached":
              notificationTitle = "Delivery Partner Arrived";
              notificationBody =
                  "The delivery partner has reached your location.";
              break;
            case "Delivered":
              notificationTitle = "Order Delivered";
              notificationBody = "Your order was delivered successfully.";
              break;
            default:
              notificationBody = "Order #$orderId status updated to: $status.";
          }

          // Trigger a notification
          NotificationService.instance.showNotification(
            title: notificationTitle,
            body: notificationBody,
          );
        }
      }
    });
  }
}

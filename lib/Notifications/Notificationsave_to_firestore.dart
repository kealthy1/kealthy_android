import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
class NotificationData {
  final String title;
  final String body;
  final String payload;
  final String fcm_token;
  final String imageUrl;
  final List<String> productNames;
  final Timestamp timestamp;
  final String orderId;
  final String phoneNumber;

  // Constructor
  NotificationData({
    required this.title,
    required this.body,
    required this.payload,
    required this.fcm_token,
    required this.imageUrl,
    required this.productNames,
    required this.timestamp,
    required this.orderId,
    required this. phoneNumber,
  });

  // Factory constructor to create an instance from a Map (optional)
  factory NotificationData.fromMap(Map<String, dynamic> map) {
    return NotificationData(
      title: map['title'] as String,
      body: map['body'] as String,
      payload: map['payload'] as String,
      fcm_token: map['fcm_token'] as String,
      imageUrl: map['imageUrl'] as String,
      productNames: List<String>.from(map['product_names'] as List<dynamic>),
      timestamp: map['timestamp'] as Timestamp,
      orderId: map['order_id'] as String,
      phoneNumber:map['phoneNumber'] as String,
    );
  }

  // Method to convert the instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'payload': payload,
      'fcm_token': fcm_token,
      'imageUrl': imageUrl,
      'product_names': productNames,
      'timestamp': timestamp,
      'order_id': orderId,
      'phoneNumber':phoneNumber,
    };
  }
}


class FirestoreService {
  // Singleton pattern
  FirestoreService._privateConstructor();
  static final FirestoreService instance = FirestoreService._privateConstructor();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add a notification
  Future<void> addNotification(NotificationData notification) async {
    try {
      await _firestore.collection('Notifications').add(notification.toMap());
      
      
    } catch (e) {
      print('Error saving notification to Firestore: $e');
      rethrow;
      
    }
  }

  // Optional: Method to retrieve notifications (if needed)
  Future<List<NotificationData>> getNotifications() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('Notifications').get();
      return snapshot.docs
          .map((doc) => NotificationData.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error retrieving notifications: $e');
      return [];
    }
  }
}


// Firestore Notifications Provider
final firestoreNotificationsProvider = StreamProvider<List<RemoteMessage>>((ref) {
  final firestore = FirebaseFirestore.instance;

  return firestore.collection('Notifications').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();

      // Ensure 'order_id' is included in data
      Map<String, String> messageData = {};
      if (data['data'] != null && data['data'] is Map) {
        messageData = Map<String, String>.from(data['data'] as Map);
      }
      messageData['order_id'] = data['order_id']?.toString() ?? '';

      return RemoteMessage(
        data: messageData,
        notification: RemoteNotification(
          title: data['title']?.toString() ?? "",
          body: data['body']?.toString() ?? "",
        ),
      );
    }).toList();
  });
});

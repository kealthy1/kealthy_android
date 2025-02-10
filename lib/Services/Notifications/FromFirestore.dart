import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/Services/Cache.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import '../../DetailsPage/Ratings/FetchImage.dart';
import '../../DetailsPage/Ratings/RatingPage.dart';

final isLoadingProvider = StateProvider<bool>((ref) => true);

final firestoreNotificationProvider = StateNotifierProvider<
    FirestoreNotificationNotifier, List<FirestoreNotification>>((ref) {
  return FirestoreNotificationNotifier();
});

class FirestoreNotificationNotifier
    extends StateNotifier<List<FirestoreNotification>> {
  FirestoreNotificationNotifier() : super([]) {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final firestore = FirebaseFirestore.instance;
    final database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://kealthy-90c55-dd236.firebaseio.com/',
    );

    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');

    if (phoneNumber == null) {
      print('No phone number found in SharedPreferences');
      return;
    }

    try {
      final snapshot = await firestore
          .collection('Notifications')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .orderBy('timestamp', descending: true)
          .get();

      List<FirestoreNotification> filteredNotifications = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final notification = FirestoreNotification.fromMap(doc.id, data);

        final orderId = data.containsKey('order_id') ? data['order_id'] : null;

        print(
            '📌 Firestore Notification ID: ${doc.id}, Order ID: ${orderId ?? "No Order ID"}');

        if (orderId != null) {
          final orderRef = database.ref().child('orders').child(orderId);
          final orderRealtimeSnapshot = await orderRef.get();

          if (orderRealtimeSnapshot.exists) {
            print(
                '❌ Skipping Notification: Order ID $orderId found in Realtime Database');
            continue;
          } else {
            print(
                '✅ Showing Notification: Order ID $orderId NOT found in Realtime Database');
          }
        }

        filteredNotifications.add(notification);
      }

      state = filteredNotifications;
      print("✅ Notifications fetched successfully.");
    } catch (e) {
      print('❌ Error fetching notifications: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('Notifications').doc(id).delete();
    fetchNotifications();
  }
}

class FirestoreNotification {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String? orderId;
  final String? payload;
  final List<String>? productNames;
  final Timestamp timestamp;

  FirestoreNotification({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.orderId,
    this.payload,
    this.productNames,
    required this.timestamp,
  });

  factory FirestoreNotification.fromMap(String id, Map<String, dynamic> data) {
    return FirestoreNotification(
      id: id,
      title: data['title'] ?? "No Title",
      body: data['body'] ?? "No Message",
      imageUrl: data['imageUrl'],
      orderId: data['order_id'],
      payload: data['payload'],
      productNames: List<String>.from(data['product_names'] ?? []),
      timestamp: data['timestamp'],
    );
  }
}

class NotificationsScreens extends ConsumerWidget {
  const NotificationsScreens({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(firestoreNotificationProvider);

    return notifications.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.bell_slash,
                  size: 50,
                  color: Color(0xFF273847),
                ),
                SizedBox(height: 10),
                Text(
                  'No Notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF273847),
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final imageProvider = FutureProvider<String?>((ref) async {
                      if (notification.productNames!.isNotEmpty) {
                        return await FirestoreService.instance
                            .fetchImageUrl(notification.productNames![0]);
                      }
                      return null;
                    });

                    return GestureDetector(
                      onTap: () {
                        try {
                          if (notification.productNames!.isNotEmpty) {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ProductReviewWidget(
                                  productNames: notification.productNames ?? [],
                                  orderId: notification.orderId.toString(),
                                ),
                              ),
                            );
                          } else {
                            print(
                                "Error: productNames is empty for notification ${index + 1}");
                          }
                        } catch (e, stackTrace) {
                          print("Navigation error: $e");
                          print("StackTrace: $stackTrace");
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Consumer(
                              builder: (context, ref, child) {
                                final imageUrl = ref.watch(imageProvider);

                                return imageUrl.when(
                                  data: (url) {
                                    if (url != null && url.isNotEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: CachedNetworkImage(
                                            imageUrl: url,
                                            width: 80,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            cacheManager: CustomCacheManager(),
                                            placeholder: (context, url) =>
                                                Shimmer.fromColors(
                                              baseColor: Colors.grey[300]!,
                                              highlightColor: Colors.grey[100]!,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Container(
                                                  width: 80,
                                                  height: 100,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(12),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url,
                                                    error) =>
                                                const Icon(
                                                    Icons.image_not_supported,
                                                    size: 60,
                                                    color: Colors.grey),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return const Icon(Icons.image,
                                          size: 60, color: Colors.grey);
                                    }
                                  },
                                  loading: () => Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      width: 80,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  error: (error, stackTrace) => const Icon(
                                      Icons.image_not_supported,
                                      size: 60,
                                      color: Colors.grey),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification.title,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notification.body,
                                      style: GoogleFonts.poppins(
                                          fontSize: 10, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (index) => const Icon(
                                          Icons.star_border,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Rate This Product Now",
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.grey,
                                size: 15,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    title: Text(
                                      "Delete Notification",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                    ),
                                    content: Text(
                                      "Are you sure you want to delete this notification?",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          ref
                                              .read(
                                                  firestoreNotificationProvider
                                                      .notifier)
                                              .deleteNotification(
                                                  notification.id);
                                          Navigator.pop(context);
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors
                                              .redAccent, // Red delete button
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 5),
                                          child: Text(
                                            "OK",
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors
                                                  .white, // White text on red button
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }
}

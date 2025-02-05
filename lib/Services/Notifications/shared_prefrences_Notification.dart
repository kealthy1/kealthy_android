import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class SavedNotificationService extends StateNotifier<List<RemoteMessage>> {
  SavedNotificationService() : super([]) {
    _initialize();
  }

  void _initialize() async {
    await _loadNotifications();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      _addNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      _addNotification(message);
    });
  }

  Future<void> _addNotification(RemoteMessage message) async {
    state = [...state, message];
    await _saveNotifications();
  }

  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = state.map((message) {
      final imageUrl = message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl ??
          message.data['image'] ??
          "";

      return jsonEncode({
        'data': message.data,
        'title': message.notification?.title ?? "",
        'body': message.notification?.body ?? "",
        'image': imageUrl,
      });
    }).toList();

    await prefs.setStringList('notifications', jsonList);
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList('notifications') ?? [];

    final loadedNotifications = jsonList.map((jsonString) {
      final jsonMap = jsonDecode(jsonString);
      final imageUrl = jsonMap['image'] ?? "";

      return RemoteMessage(
        data: Map<String, String>.from(jsonMap['data']),
        notification: RemoteNotification(
          title: jsonMap['title'],
          body: jsonMap['body'],
          android: AndroidNotification(imageUrl: imageUrl),
          apple: AppleNotification(imageUrl: imageUrl),
        ),
      );
    }).toList();

    state = loadedNotifications;
  }

  Future<void> removeNotification(RemoteMessage message) async {
    state = state
        .where((m) =>
            jsonEncode({
              'data': m.data,
              'title': m.notification?.title ?? "",
              'body': m.notification?.body ?? "",
              'image': m.notification?.android?.imageUrl ??
                  m.notification?.apple?.imageUrl ??
                  m.data['image'] ??
                  ""
            }) !=
            jsonEncode({
              'data': message.data,
              'title': message.notification?.title ?? "",
              'body': message.notification?.body ?? "",
              'image': message.notification?.android?.imageUrl ??
                  message.notification?.apple?.imageUrl ??
                  message.data['image'] ??
                  ""
            }))
        .toList();

    await _saveNotifications();
  }

  Future<void> clearNotifications() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');
  }
}

final notificationProvider =
    StateNotifierProvider<SavedNotificationService, List<RemoteMessage>>(
        (ref) => SavedNotificationService());

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final isLoading = notifications.isEmpty;

    return isLoading
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
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final message = notifications.reversed.toList()[index];

                final imageUrl = message.notification?.android?.imageUrl ??
                    message.notification?.apple?.imageUrl ??
                    message.data['image'];

                return Column(
                  children: [
                    ListTile(
                      leading: imageUrl != null && imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.fill,
                              placeholder: (context, url) => Shimmer.fromColors(
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
                              errorWidget: (context, error, stackTrace) =>
                                  const Icon(Icons.image_not_supported,
                                      color: Colors.red),
                            )
                          : const Icon(Icons.notifications, color: Colors.blue),
                      title: Text(
                        message.notification?.title ?? "No Title",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle:
                          Text(message.notification?.body ?? "No Message"),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 15,
                        ),
                        onPressed: () {
                          ref
                              .read(notificationProvider.notifier)
                              .removeNotification(message);
                        },
                      ),
                    ),
                    Divider()
                  ],
                );
              },
            ),
          );
  }
}

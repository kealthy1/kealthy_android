// ignore_for_file: unused_result

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/Login/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Login/Guest_Alert.dart';
import '../../Maps/fluttermap.dart';
import '../../Maps/functions/Delivery_detailslocationprovider.dart';
import '../../Maps/SelectAdress.dart';
import '../../Orders/ordersTab.dart';
import '../../Notifications/FromFirestore.dart';
import 'package:lottie/lottie.dart';

class SelectedRoadNotifier extends StateNotifier<String?> {
  SelectedRoadNotifier() : super(null) {
    _loadSelectedRoad();
  }

  Future<void> _loadSelectedRoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = prefs.getString('selectedRoad');
  }

  Future<void> refreshSelectedRoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = prefs.getString('selectedRoad');
  }

  Future<void> updateSelectedRoad(String newRoad) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedRoad', newRoad);
    state = newRoad;
  }
}

final selectedRoadProvider =
    StateNotifierProvider<SelectedRoadNotifier, String?>(
        (ref) => SelectedRoadNotifier());

final typeProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('type');
});

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  String extractMainLocation(String fullLocation) {
    final parts = fullLocation.split(',').map((part) => part.trim()).toList();
    return parts.isNotEmpty ? parts[0] : fullLocation;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttonVisible = ref.watch(movableButtonProvider);
    final selectedRoad = ref.watch(selectedRoadProvider);
    final currentLocation = ref.watch(locationProvider);

    final locationParts = currentLocation.split('\n');
    String fullLocation =
        locationParts.isNotEmpty ? locationParts[0].trim() : "Locating";
    String mainLocation = extractMainLocation(fullLocation);

    if (mainLocation.isEmpty && locationParts.length > 1) {
      fullLocation = locationParts.skip(1).firstWhere(
          (part) => part.trim().isNotEmpty,
          orElse: () => "Locating");
      mainLocation = extractMainLocation(fullLocation);
    }

    return AppBar(
      surfaceTintColor: Colors.white,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: GestureDetector(
        onTap: () async {
          ref.refresh(currentlocationProviders);
          ref.refresh(selectedPositionProvider);
          ref.refresh(addressProvider);
          ref.refresh(isFetchingLocationProvider);
          final prefs = await SharedPreferences.getInstance();
          final phoneNumber = prefs.getString('phoneNumber') ?? '';

          if (phoneNumber.isEmpty) {
            GuestDialog.show(
              context: context,
              title: "Login Required",
              content: "Please log in to continue.",
              navigateTo: LoginFields(),
            );
          } else {
            final notifier = ref.read(selectedRoadProvider.notifier);
            final updatedRoad = await Navigator.push(
              context,
              CupertinoModalPopupRoute(
                builder: (context) => const SelectAdress(totalPrice: 0),
              ),
            );

            if (updatedRoad != null) {
              await notifier.updateSelectedRoad(updatedRoad);
            }
          }
        },
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.red, size: 30),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final typeAsyncValue = ref.watch(typeProvider);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            typeAsyncValue.when(
                              data: (type) {
                                if (type == null || type.trim().isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  type,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                );
                              },
                              loading: () => SizedBox.shrink(),
                              error: (error, _) => const SizedBox.shrink(),
                            ),
                            typeAsyncValue.when(
                              data: (type) => Text(
                                selectedRoad ?? mainLocation,
                                style: GoogleFonts.poppins(
                                  color:
                                      type == null ? Colors.black : Colors.grey,
                                  fontSize: type == null ? 20 : 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                              loading: () => const SizedBox.shrink(),
                              error: (error, _) => Text(
                                overflow: TextOverflow.ellipsis,
                                selectedRoad ?? mainLocation,
                                style: GoogleFonts.poppins(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (buttonVisible) Orders(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Help(),
        ),
      ],
    );
  }
}

class MovableButtonNotifier extends StateNotifier<bool> {
  MovableButtonNotifier() : super(false) {
    _startListeningForUpdates();
  }

  final FirebaseDatabase database1 = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://kealthy-90c55-dd236.firebaseio.com/',
  );

  void _startListeningForUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');

    if (phoneNumber != null) {
      final Query ref = database1
          .ref()
          .child('orders')
          .orderByChild('phoneNumber')
          .equalTo(phoneNumber);

      ref.onValue.listen((event) {
        if (event.snapshot.exists) {
          final orders = event.snapshot.children;
          bool orderExists = orders.any((order) {
            final data = order.value as Map<dynamic, dynamic>?;

            return data != null && data['assignedto'] != 'none';
          });

          state = orderExists;
        } else {
          state = false;
        }
      });
    }
  }
}

final movableButtonProvider =
    StateNotifierProvider<MovableButtonNotifier, bool>((ref) {
  return MovableButtonNotifier();
});

class Help extends ConsumerWidget {
  const Help({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notification = ref.watch(firestoreNotificationProvider);
    final totalNotifications = notification.length;
    ref.watch(movableButtonProvider);

    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              CupertinoModalPopupRoute(
                builder: (context) => NotificationsScreens(),
              ));
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300),
              onPressed: () {
                Navigator.push(
                    context,
                    CupertinoModalPopupRoute(
                      builder: (context) => NotificationsScreens(),
                    ));
              },
              icon: buildNotificationIcon(notification.length),
            ),
            if (totalNotifications > 0)
              Transform.translate(
                offset: const Offset(25, -6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Semantics(
                    label: '$totalNotifications',
                    child: Text(
                      totalNotifications > 99
                          ? '99+'
                          : totalNotifications.toString(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ));
  }

  Widget buildNotificationIcon(int notification) {
    if (notification > 0) {
      return Lottie.asset(
        'assets/icons8-notification.json',
        width: 25,
        height: 25,
        fit: BoxFit.fill,
        repeat: true,
      );
    } else {
      return const Icon(
        CupertinoIcons.bell,
        size: 30,
        color: Color(0xFF273847),
      );
    }
  }
}

class Orders extends StatelessWidget {
  const Orders({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                CupertinoModalPopupRoute(
                    builder: (context) => OrdersTabScreen()));
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              backgroundImage: AssetImage("assets/Delivery Boy (1).gif"),
            ),
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -7),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Live',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

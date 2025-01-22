import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/LandingPage/Help&Support/Help&Support_Tab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Maps/functions/Delivery_detailslocationprovider.dart';
import '../../Maps/SelectAdress.dart';

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
                              loading: () => const CircularProgressIndicator(),
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
        Help(),
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
    ref.watch(movableButtonProvider);

    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              CupertinoModalPopupRoute(
                builder: (context) => SupportDeskScreen(),
              ));
        },
        child: Stack(
          children: [
            IconButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300),
              onPressed: () {
                Navigator.push(
                    context,
                    CupertinoModalPopupRoute(
                      builder: (context) => SupportDeskScreen(),
                    ));
              },
              icon: Icon(
                CupertinoIcons.chat_bubble_text,
                size: 25,
                color: Color(0xFF273847),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFF273847),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Help',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ));
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/LandingPage/Help&Support/Help&Support_Tab.dart';
import 'package:kealthy/Orders/ordersTab.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Maps/functions/Delivery_detailslocationprovider.dart';
import '../../Maps/SelectAdress.dart';
import '../../Services/Navigation.dart';

class SelectedRoadNotifier extends StateNotifier<String?> {
  SelectedRoadNotifier() : super(null) {
    _loadSelectedRoad();
  }

  // Load the initial selected road from SharedPreferences
  Future<void> _loadSelectedRoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = prefs.getString('selectedRoad');
  }

  // Refresh the selected road when updated
  Future<void> refreshSelectedRoad() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = prefs.getString('selectedRoad');
  }

  // Update the selected road
  Future<void> updateSelectedRoad(String newRoad) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedRoad', newRoad);
    state = newRoad; // Trigger a rebuild
  }
}

final selectedRoadProvider =
    StateNotifierProvider<SelectedRoadNotifier, String?>(
        (ref) => SelectedRoadNotifier());

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
    final selectedRoad = ref.watch(selectedRoadProvider); // Reactive watch
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
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: GestureDetector(
        onTap: () async {
          final notifier = ref.read(selectedRoadProvider.notifier);
          final updatedRoad = await Navigator.push(
            context,
            MaterialPageRoute(
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
                    child: Text(
                      selectedRoad ?? mainLocation,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_outlined,
                    size: 30,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: MovableButton(),
        ),
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

            return data != null && data['assignedto'] != 'NotAssigned';
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

class MovableButton extends ConsumerWidget {
  const MovableButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttonVisible = ref.watch(movableButtonProvider);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          SeamlessRevealRoute(
            page: const OrdersTabScreen(),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.translationValues(0, buttonVisible ? 0 : 60, 0),
        child: buttonVisible
            ? Stack(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage("assets/Delivery Boy (1).gif"),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Live',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class Help extends ConsumerWidget {
  const Help({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(movableButtonProvider);

    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            SeamlessRevealRoute(
              page: const SupportDeskScreen(),
            ),
          );
        },
        child: Stack(
          children: [
            IconButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300),
              onPressed: () {
                Navigator.push(
                    context, SeamlessRevealRoute(page: SupportDeskScreen()));
              },
              icon: Icon(
                CupertinoIcons.chat_bubble_text,
                size: 25,
                color: Color(0xFF273847),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFF273847),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Help',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

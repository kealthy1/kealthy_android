import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Orders/Review&Feedback.dart';
import 'package:kealthy/Orders/ordersTab.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Maps/functions/Delivery_detailslocationprovider.dart';
import '../../Maps/SelectAdress.dart';
import '../../Services/Navigation.dart';

final selectedRoadProvider = FutureProvider<String?>((ref) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('selectedRoad');
});

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  String extractMainLocation(String fullLocation) {
    final parts = fullLocation.split(',').map((part) => part.trim()).toList();
    return parts.isNotEmpty ? parts[0] : fullLocation;
  }

  Future<String> _getSelectedRoad() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedRoad = prefs.getString('selectedRoad') ?? '';
    return selectedRoad.split(',').first.trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedAddress = ref.watch(selectedAddressProvider);
    final currentLocation = ref.watch(locationProvider);
    final selectedRoadAsyncValue = ref.watch(selectedRoadProvider);

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
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SelectAdress(
                    totalPrice: 0,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 30,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 5,
                            child: selectedRoadAsyncValue.when(
                              data: (selectedRoad) {
                                String displayRoad =
                                    selectedAddress?.road ?? '';

                                if (displayRoad.isEmpty) {
                                  return FutureBuilder<String>(
                                    future: _getSelectedRoad(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return LoadingAnimationWidget
                                            .progressiveDots(
                                                color: Colors.green, size: 20);
                                      } else if (snapshot.hasError) {
                                        return Text(
                                          "Error: ${snapshot.error}",
                                          style: const TextStyle(
                                              color: Colors.red),
                                        );
                                      } else {
                                        displayRoad = snapshot.data!.isNotEmpty
                                            ? snapshot.data!
                                            : mainLocation;

                                        return Text(
                                          displayRoad,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }
                                    },
                                  );
                                }

                                return Text(
                                  displayRoad,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                              loading: () =>
                                  LoadingAnimationWidget.progressiveDots(
                                      color: Colors.green, size: 20),
                              error: (error, stack) => Text(
                                "Error: $error",
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_outlined,
                            size: 30,
                            color: Colors.grey,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: MovableButton(),
        ),
        GestureDetector(
          onTap: () {},
          child: IconButton(
            onPressed: () {
              FeedbackBottomSheet.show(
                context,
                title: 'Give Feedback',
                message: 'What do you think about our app?',
                onSend: () {},
                onCancel: () {
                  Navigator.of(context).pop();
                },
              );
            },
            icon: Icon(Icons.help_outline_sharp),
            color: Colors.black,
            iconSize: 30,
          ),
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

            return data != null && data['status'] != 'Delivered';
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

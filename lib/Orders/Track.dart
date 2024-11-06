import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

final deliveryUserProvider =
    StreamProvider.family<DeliveryUser?, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('DeliveryUsers')
      .doc(userId)
      .snapshots()
      .map((snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data()!;
      final deliveryUser = DeliveryUser(
        name: data['Name'] as String,
        mobile: data['Mobile'] as int,
        location: LatLng(
          (data['currentLocation'] as GeoPoint).latitude,
          (data['currentLocation'] as GeoPoint).longitude,
        ),
      );
      final marker = Marker(
        markerId: MarkerId(userId),
        position: deliveryUser.location,
        infoWindow: InfoWindow(title: deliveryUser.name),
      );
      ref.read(markerProvider.notifier).state = {marker};

      final mapController = ref.read(mapControllerProvider);
      if (mapController != null) {
        mapController.animateCamera(
          CameraUpdate.newLatLng(deliveryUser.location),
        );
      }

      return deliveryUser;
    }
    return null;
  });
});

final mapControllerProvider =
    StateProvider<GoogleMapController?>((ref) => null);

final markerProvider = StateProvider<Set<Marker>>((ref) => {});

class DeliveryUser {
  final String name;
  final int mobile;
  final LatLng location;

  DeliveryUser({
    required this.name,
    required this.mobile,
    required this.location,
  });
}

class OrderTrackingPage extends ConsumerWidget {
  final String deliveryUserId;

  const OrderTrackingPage({required this.deliveryUserId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryUserAsyncValue =
        ref.watch(deliveryUserProvider(deliveryUserId));
    final markers = ref.watch(markerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Tracking"),
        backgroundColor: Colors.green,
      ),
      body: deliveryUserAsyncValue.when(
        data: (deliveryUser) {
          if (deliveryUser == null) {
            return const Center(child: Text("User data not found"));
          }

          return Column(
            children: [
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: deliveryUser.location,
                    zoom: 15.0,
                  ),
                  markers: markers,
                  onMapCreated: (controller) {
                    ref.read(mapControllerProvider.notifier).state = controller;
                    controller.animateCamera(
                      CameraUpdate.newLatLng(deliveryUser.location),
                    );
                  },
                ),
              ),
              ListTile(
                title: Text(deliveryUser.name),
                subtitle: Text(deliveryUser.mobile.toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.message),
                      onPressed: () {
                        
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () {
                        FlutterPhoneDirectCaller.callNumber(
                            deliveryUser.mobile.toString());
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text("Error: $error")),
      ),
    );
  }
}

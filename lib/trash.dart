import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

// Fetch the current location of the delivery agent from Firestore
final currentLocationProvider =
    StreamProvider.family<LatLng?, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('DeliveryUsers')
      .doc(userId)
      .snapshots()
      .map((snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data()!;
      final geoPoint = data['currentLocation'] as GeoPoint;
      return LatLng(geoPoint.latitude, geoPoint.longitude);
    }
    return null;
  });
});

final destinationLocationProvider =
    StreamProvider.family<LatLng?, String>((ref, orderId) {
  final databaseRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://kealthy-90c55-dd236.firebaseio.com',
  ).ref();

  return databaseRef
      .child('orders')
      .orderByChild('orderId')
      .equalTo(orderId)
      .onValue
      .map((event) {
    final snapshot = event.snapshot;

    // Debugging: Print the full snapshot to inspect data structure
    print("Snapshot exists: ${snapshot.exists}");
    print("Snapshot value: ${snapshot.value}");

    if (snapshot.exists) {
      final destination = snapshot.value as Map<dynamic, dynamic>;
      print(
          "Destination Map: $destination"); // Logs the map containing order data

      // Extract the first order's data
      final orderData = destination.values.first as Map<dynamic, dynamic>;
      print("Order Data: $orderData"); // Logs the detailed order data map

      // Check for the latitude and longitude fields
      if (orderData.containsKey('selectedLatitude') &&
          orderData.containsKey('selectedLongitude')) {
        final lat = orderData['selectedLatitude'];
        final lon = orderData['selectedLongitude'];

        print("Latitude: $lat, Longitude: $lon"); // Logs the exact values found

        return LatLng(
          lat as double,
          lon as double,
        );
      } else {
        print(
            "Error: Latitude or Longitude fields are missing in order data."); // Logs if fields are missing
      }
    } else {
      print(
          "Error: No data found for orderId: $orderId"); // Logs if snapshot is empty or null
    }
    return null;
  });
});

class OrderTrackingPage extends ConsumerStatefulWidget {
  final String deliveryUserId;
  final String orderid;

  const OrderTrackingPage({
    required this.deliveryUserId,
    required this.orderid,
    super.key,
  });

  @override
  ConsumerState<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends ConsumerState<OrderTrackingPage> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final currentLocationAsyncValue =
        ref.watch(currentLocationProvider(widget.deliveryUserId));
    final destinationLocationAsyncValue =
        ref.watch(destinationLocationProvider(widget.orderid));

    // Set the restaurant's fixed coordinates as the starting point
    const LatLng restaurantLocation =
        LatLng(10.010279427438405, 76.38426666931349);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 231, 236, 232),
              Color.fromARGB(255, 11, 99, 40),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: currentLocationAsyncValue.when(
          data: (currentLocation) {
            if (currentLocation == null) {
              return const Center(child: Text("Current location not found"));
            }

            // Update map's center with current location whenever it changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _mapController.move(currentLocation, 14.0);
            });

            return destinationLocationAsyncValue.when(
              data: (destinationLocation) {
                if (destinationLocation == null) {
                  return const Center(
                      child: Text("Destination location not found"));
                }

                return Column(
                  children: [
                    Expanded(
                      child: FlutterMap(
                        mapController: _mapController,
                        options: const MapOptions(
                          initialCenter: restaurantLocation,
                          initialZoom: 18.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png",
                          ),
                          MarkerLayer(
                            markers: [
                              const Marker(
                                width: 40.0,
                                height: 40.0,
                                point: restaurantLocation,
                                child: Icon(
                                  Icons.person_pin_circle_outlined,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                              Marker(
                                width: 40.0,
                                height: 40.0,
                                point: currentLocation,
                                child: const Icon(
                                  Icons.delivery_dining,
                                  color: Colors.green,
                                  size: 40,
                                ),
                              ),
                              Marker(
                                width: 40.0,
                                height: 40.0,
                                point: destinationLocation,
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: [
                                  restaurantLocation,
                                  destinationLocation,
                                ],
                                strokeWidth: 4.0,
                                color: Colors.blueAccent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 320,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                    AssetImage("assets/Location.JPG"),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Delivery User",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Rating: 4.8',
                                    style: TextStyle(color: Colors.green[700]),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              IconButton(
                                icon:
                                    const Icon(Icons.call, color: Colors.grey),
                                onPressed: () {
                                  FlutterPhoneDirectCaller.callNumber(
                                      '123456789');
                                },
                              ),
                            ],
                          ),
                          const Divider(),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'To:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('Delivery Location'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text("Error: $error")),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text("Error: $error")),
        ),
      ),
    );
  }
}

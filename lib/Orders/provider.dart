import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:google_maps_flutter/google_maps_flutter.dart' as gm;
import 'package:riverpod/riverpod.dart';
import 'Polymerline.dart';

final destinationLocationProvider =
    StreamProvider.family<ll.LatLng?, String>((ref, orderId) {
  final databaseRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://kealthy-90c55-dd236.firebaseio.com',
  ).ref();

  return databaseRef.child('orders').child(orderId).onValue.map((event) {
    final snapshot = event.snapshot;

    if (snapshot.exists) {
      final orderData = snapshot.value as Map<dynamic, dynamic>;
      if (orderData.containsKey('selectedLatitude') &&
          orderData.containsKey('selectedLongitude')) {
        final lat = orderData['selectedLatitude'] as double;
        final lon = orderData['selectedLongitude'] as double;
        return ll.LatLng(lat, lon);
      } else {}
    } else {}
    return null;
  });
});

final currentLocationProvider =
    StreamProvider.family<ll.LatLng?, String>((ref, String orderId) {
  final databaseRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://kealthy-90c55-dd236.firebaseio.com',
  ).ref();

  return databaseRef
      .child('orders')
      .child(orderId)
      .onValue
      .asyncExpand((event) {
    final snapshot = event.snapshot;

    if (snapshot.exists) {
      final orderData = snapshot.value as Map<dynamic, dynamic>;

      if (orderData.containsKey('assignedto')) {
        final assignedTo = orderData['assignedto'] as String;

        return FirebaseFirestore.instance
            .collection('DeliveryUsers')
            .doc(assignedTo)
            .snapshots()
            .map((docSnapshot) {
          if (docSnapshot.exists) {
            final data = docSnapshot.data();
            if (data != null && data.containsKey('currentLocation')) {
              final geoPoint = data['currentLocation'] as GeoPoint;
              return ll.LatLng(geoPoint.latitude, geoPoint.longitude);
            } else {}
          } else {}
          return null;
        });
      } else {}
    } else {}
    return Stream.value(null);
  });
});

final routeProvider = StreamProvider.family<List<ll.LatLng>, String>(
    (ref, String orderId) async* {
  final destinationLocation =
      await ref.read(destinationLocationProvider(orderId).future);

  if (destinationLocation != null) {
    // Start streaming current location updates
    final currentLocationStream =
        ref.watch(currentLocationProvider(orderId).stream);

    ll.LatLng? lastRecalculatedLocation;
    const deviationThreshold = 100.0; // meters

    await for (final currentLocation in currentLocationStream) {
      if (currentLocation != null) {
        // Check for deviation from last recalculated route
        if (lastRecalculatedLocation == null ||
            _distanceBetween(currentLocation, lastRecalculatedLocation) >
                deviationThreshold) {
          lastRecalculatedLocation = currentLocation;

          // Fetch route points between current location and destination
          final routePoints = await fetchRoute(
            gm.LatLng(currentLocation.latitude, currentLocation.longitude),
            gm.LatLng(
                destinationLocation.latitude, destinationLocation.longitude),
          );

          if (routePoints.isNotEmpty) {
            yield routePoints
                .map((point) => ll.LatLng(point.latitude, point.longitude))
                .toList();
          } else {
            yield [];
          }
        } else {}
      }
    }
  } else {
    yield [];
  }
});

// Helper function to calculate distance between two points
double _distanceBetween(ll.LatLng point1, ll.LatLng point2) {
  const earthRadius = 6371000; // meters
  final lat1Rad = point1.latitude * (3.141592653589793 / 180);
  final lat2Rad = point2.latitude * (3.141592653589793 / 180);
  final deltaLat =
      (point2.latitude - point1.latitude) * (3.141592653589793 / 180);
  final deltaLon =
      (point2.longitude - point1.longitude) * (3.141592653589793 / 180);

  final a = (sin(deltaLat / 2) * sin(deltaLat / 2)) +
      cos(lat1Rad) * cos(lat2Rad) * (sin(deltaLon / 2) * sin(deltaLon / 2));
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

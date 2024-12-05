import 'dart:math';

double calculatesDistance(
    double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
  const earthRadius = 6371; // Earth's radius in kilometers

  final dLat = radians(endLatitude - startLatitude);
  final dLon = radians(endLongitude - startLongitude);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(radians(startLatitude)) *
          cos(radians(endLatitude)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c; // Distance in kilometers
}

double radians(double degrees) {
  return degrees * pi / 180;
}

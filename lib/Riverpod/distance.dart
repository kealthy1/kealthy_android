import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

double calculatesDistance(double startLatitude, double startLongitude,
    double endLatitude, double endLongitude) {
  const earthRadius = 6371;

  final dLat = radians(endLatitude - startLatitude);
  final dLon = radians(endLongitude - startLongitude);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(radians(startLatitude)) *
          cos(radians(endLatitude)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return earthRadius * c;
}

double radians(double degrees) {
  return degrees * pi / 180;
}

Future<double> calculateDrivingDistance({
  required String apiKey,
  required double startLatitude,
  required double startLongitude,
  required double endLatitude,
  required double endLongitude,
}) async {
  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/distancematrix/json?'
    'origins=$startLatitude,$startLongitude&'
    'destinations=$endLatitude,$endLongitude&'
    'mode=walking&'
    'key=$apiKey',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    print('API Response: ${response.body}');

    if (data['rows'] != null &&
        data['rows'].isNotEmpty &&
        data['rows'][0]['elements'] != null &&
        data['rows'][0]['elements'].isNotEmpty) {
      final element = data['rows'][0]['elements'][0];
      if (element['status'] == 'OK') {
        final distanceInMeters = element['distance']['value'];
        return distanceInMeters / 1000;
      } else {
        throw Exception('Distance calculation failed: ${element['status']}');
      }
    } else {
      throw Exception('No data available for the specified locations');
    }
  } else {
    throw Exception(
        'Failed to fetch driving distance: ${response.reasonPhrase}');
  }
}

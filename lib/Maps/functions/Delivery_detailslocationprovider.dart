import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod/riverpod.dart';

class LocationNotifier extends StateNotifier<String> {
  LocationNotifier() : super("...") {
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = "Locating.";
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = "Location permissions are denied.";
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = "Location permissions are permanently denied.";
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;

        String title = placemark.subLocality ??
            placemark.locality ??
            placemark.name ??
            "Location not found";
        String details =
            "${placemark.subLocality ?? ''}, ${placemark.locality ?? ''}, ${placemark.subAdministrativeArea ?? ''}, ${placemark.administrativeArea}, ${placemark.country}";

        details = details
            .split(',')
            .where((part) => part.trim().isNotEmpty)
            .join(', ')
            .trim();

        state = "$title\n$details";
      } else {
        state = "No placemarks found";
      }
    } catch (e) {
      state = "Error fetching location: $e";
    }
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, String>((ref) {
  return LocationNotifier();
});

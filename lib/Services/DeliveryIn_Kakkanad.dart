import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

const double pincodeLatitude = 10.0176;
const double pincodeLongitude = 76.3050;
const double deliveryRadiusInMeters = 8000;

final deliveryLimitProvider =
    StateNotifierProvider<DeliveryLimitNotifier, String>((ref) {
  return DeliveryLimitNotifier();
});

class DeliveryLimitNotifier extends StateNotifier<String> {
  DeliveryLimitNotifier() : super('');

  void updateLocation(String newLocation) {
    state = newLocation;
  }

  Future<void> fetchCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
          // ignore: deprecated_member_use
          desiredAccuracy: LocationAccuracy.best);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String location = [place.subLocality, place.locality, place.postalCode]
            .where((element) => element != null && element.isNotEmpty)
            .join(', ');

        updateLocation(location);

        double distanceInMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          pincodeLatitude,
          pincodeLongitude,
        );

        if (distanceInMeters > deliveryRadiusInMeters) {}
      } else {
        updateLocation('Unable to fetch location');
      }
    } else {
      updateLocation('Location permissions denied');
    }
  }
}

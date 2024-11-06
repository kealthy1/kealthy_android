import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:kealthy/Maps/Delivery_details.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rounded_background_text/rounded_background_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import '../Services/placesuggetions.dart';

final currentlocationProviders =
    StateNotifierProvider<LocationNotifier, Position?>((ref) {
  return LocationNotifier(ref);
});

final mapControllerProvider =
    StateProvider<GoogleMapController?>((ref) => null);

final selectedPositionProvider = StateProvider<LatLng?>((ref) => null);

final isSearchingProvider = StateProvider<bool>((ref) => false);

final addressProvider = StateProvider<String?>((ref) => null);

class LocationNotifier extends StateNotifier<Position?> {
  LatLng? _selectedPosition;
  final Map<String, String> _cache = {};
  final Ref ref;

  LocationNotifier(this.ref) : super(null) {
    getCurrentLocation();
  }

  LatLng? get selectedPosition => _selectedPosition;

  set selectedPosition(LatLng? position) {
    _selectedPosition = position;
  }

  Future<void> getCurrentLocation() async {
    try {
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
      Position position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings);
      LatLng currentPosition = LatLng(position.latitude, position.longitude);
      state = position;
      _selectedPosition = currentPosition;
      await getAddressFromLatLng(currentPosition);
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> getAddressFromLatLng(LatLng position) async {
    final key = "${position.latitude},${position.longitude}";
    print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");

    if (_cache.containsKey(key)) {
      ref.read(addressProvider.notifier).state = _cache[key];
      return;
    }

    final response = await http.get(
      Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyD1MUoakZ0mm8WeFv_GK9k_zAWdGk5r1hA'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['results'].isNotEmpty) {
        final address = data['results'][0]['formatted_address'];

        _cache[key] = address;

        ref.read(addressProvider.notifier).state = address;

        print("Fetched address: $address");
      } else {
        print('No results found for the provided lat/long.');
      }
    } else {
      print('Failed to load address from Google API');
    }
  }

  Future<void> searchLocation(String address) async {
    try {
      ref.read(isSearchingProvider.notifier).state = true;
      _selectedPosition = null;
      ref.read(addressProvider.notifier).state = null;

      final List<Location> locations =
          await locationFromAddress("$address, Kochi, Kerala,");

      if (locations.isNotEmpty) {
        final LatLng position =
            LatLng(locations.first.latitude, locations.first.longitude);
        print('Searched Position: ${position.latitude}, ${position.longitude}');

        _selectedPosition = position;

        final GoogleMapController? controller = ref.read(mapControllerProvider);
        if (controller != null) {
          await controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: position,
              zoom: 18.0,
            ),
          ));
          await _updateAddress(position);
        }
      } else {
        print('No locations found for the address: $address');
      }
    } catch (e) {
      print('Error in searching location: $e');
    } finally {
      ref.read(isSearchingProvider.notifier).state = false;
    }
  }

  Future<void> updateAddressFromCamera(LatLng position) async {
    await _updateAddress(position);
  }

  Future<void> updateAddressOnButtonPress(LatLng position) async {
    await _updateAddress(position);
  }

  Future<void> checkLocationServices() async {
    try {
      bool locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!locationServiceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          return;
        }
      }

      await getCurrentLocation();
    } catch (e) {
      print('Error checking location services: $e');
    }
  }

  Future<void> _updateAddress(LatLng position) async {
    try {
      final List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks.first;
        final address =
            "${placemark.name}, ${placemark.street}, ${placemark.locality}, ${placemark.subAdministrativeArea}, ${placemark.administrativeArea}, ${placemark.postalCode}, ${placemark.country}";

        ref.read(addressProvider.notifier).state = address;

        print(
            "Fetched location: Latitude: ${position.latitude}, Longitude: ${position.longitude}");
      }
    } catch (e) {
      print('Error in reverse geocoding: $e');
    }
  }
}

class SelectLocationPage extends ConsumerStatefulWidget {
  final double totalPrice;
  final String type;
  final String? date;
  final String time;
  const SelectLocationPage({
    super.key,
    required this.totalPrice,
    required this.date,
    required this.time,
    required this.type,
  });

  @override
  ConsumerState<SelectLocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<SelectLocationPage> {
  late TextEditingController _searchController;
  static const LatLng restaurantLocation = LatLng(10.064555, 76.322242);

  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    ref.read(currentlocationProviders.notifier).checkLocationServices();
    ref.read(currentlocationProviders.notifier).getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = ref.watch(currentlocationProviders);
    final selectedPosition = ref.watch(selectedPositionProvider);
    final address = ref.watch(addressProvider);
    final placeSuggestions = ref.watch(placeSuggestionsProvider);

    double? distanceToRestaurant;

    if (currentPosition == null) {
      print(
          'currentPosition is null. Location might still be loading or not available.');
    }

    if (selectedPosition == null) {
      print(
          'selectedPosition is null. The user might not have selected a location yet.');
    }

    if (currentPosition != null && selectedPosition != null) {
      distanceToRestaurant = calculateDistance(
        selectedPosition,
        restaurantLocation,
      );
      print('Distance to restaurant: $distanceToRestaurant meters');
    } else if (currentPosition == null && selectedPosition == null) {
      print('Either currentPosition or selectedPosition is null');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text('Confirm delivery location'),
      ),
      body: currentPosition != null
          ? Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        currentPosition.latitude,
                        currentPosition.longitude,
                      ),
                      zoom: 18.0,
                    ),
                    onMapCreated: (controller) {
                      ref.read(mapControllerProvider.notifier).state =
                          controller;
                    },
                    onCameraMove: (position) {
                      ref.read(selectedPositionProvider.notifier).state =
                          position.target;
                    },
                    onCameraIdle: () {
                      final targetPosition = ref.read(selectedPositionProvider);
                      if (targetPosition != null) {
                        ref
                            .read(currentlocationProviders.notifier)
                            .updateAddressFromCamera(targetPosition);
                      }
                    },
                    myLocationButtonEnabled: false,
                    myLocationEnabled: false,
                    mapType: MapType.terrain,
                    mapToolbarEnabled: true,
                  ),
                ),
                Positioned(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 2.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    ref
                                        .read(currentlocationProviders.notifier)
                                        .searchLocation(value);
                                    ref
                                        .read(placeSuggestionsProvider.notifier)
                                        .fetchPlaceSuggestions(value);
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Search location',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(15),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              ref.watch(isSearchingProvider)
                                  ? SizedBox(
                                      width: 24.0,
                                      height: 24.0,
                                      child:
                                          LoadingAnimationWidget.discreteCircle(
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              const SizedBox(width: 8.0),
                              IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {
                                  final searchValue = _searchController.text;
                                  if (searchValue.isNotEmpty) {
                                    ref
                                        .read(currentlocationProviders.notifier)
                                        .searchLocation(searchValue);
                                    ref
                                        .read(placeSuggestionsProvider.notifier)
                                        .fetchPlaceSuggestions(searchValue);
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          if (placeSuggestions.isNotEmpty)
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                itemCount: placeSuggestions.length,
                                itemBuilder: (context, index) {
                                  final suggestion = placeSuggestions[index];
                                  final suggestionName =
                                      suggestion['description'];

                                  return ListTile(
                                      title: Text(
                                          suggestionName ?? 'Unknown Place'),
                                      onTap: () async {
                                        _searchController.text =
                                            suggestionName ?? '';
                                        ref
                                            .read(placeSuggestionsProvider
                                                .notifier)
                                            .state = [];
                                        final locations =
                                            await locationFromAddress(
                                                suggestionName ?? '');

                                        if (locations.isNotEmpty) {
                                          final position = LatLng(
                                              locations.first.latitude,
                                              locations.first.longitude);
                                          ref
                                              .read(selectedPositionProvider
                                                  .notifier)
                                              .state = position;

                                          final controller =
                                              ref.read(mapControllerProvider);
                                          if (controller != null) {
                                            await controller.animateCamera(
                                                CameraUpdate.newCameraPosition(
                                              CameraPosition(
                                                  target: position, zoom: 18.0),
                                            ));
                                          }
                                          await ref
                                              .read(currentlocationProviders
                                                  .notifier)
                                              .getAddressFromLatLng(position);
                                        } else {
                                          print(
                                              'No location found for the selected suggestion.');
                                        }
                                      });
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.65 / 2 - 25,
                  left: MediaQuery.of(context).size.width / 2 - 25,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RoundedBackgroundText(
                        backgroundColor: Colors.black54,
                        '  Your  Order Will  be  delivered here\n     Move pin to your exact location  ',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                      Image.asset(
                        'assets/location_icon.png',
                        width: 50,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10.0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8.0,
                          offset: Offset(0, -2),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Text(
                            'DELIVERING YOUR ORDER TO',
                            style: TextStyle(
                              color: Colors.blue,
                              fontFamily: 'Poppins',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  side: const BorderSide(
                                      color:
                                          Color.fromARGB(255, 181, 242, 183))),
                              onPressed: () async {
                                await ref
                                    .read(currentlocationProviders.notifier)
                                    .getCurrentLocation();

                                final currentPosition =
                                    ref.read(currentlocationProviders);

                                if (currentPosition != null) {
                                  ref
                                      .read(currentlocationProviders.notifier)
                                      .selectedPosition = LatLng(
                                    currentPosition.latitude,
                                    currentPosition.longitude,
                                  );

                                  final controller =
                                      ref.read(mapControllerProvider);
                                  if (controller != null) {
                                    await controller.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: LatLng(
                                            currentPosition.latitude,
                                            currentPosition.longitude,
                                          ),
                                          zoom: 18.0,
                                        ),
                                      ),
                                    );
                                  }

                                  ref
                                      .read(currentlocationProviders.notifier)
                                      .updateAddressOnButtonPress(LatLng(
                                          currentPosition.latitude,
                                          currentPosition.longitude));
                                }
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.my_location,
                                    color: Colors.green,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Locate Me',
                                    style: TextStyle(color: Colors.green),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        address != null
                            ? Row(
                                children: [
                                  Image.asset(
                                    'assets/location_icon.png',
                                    width: 40,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      address,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'Poppins',
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: double.infinity,
                                  height: 20,
                                  color: Colors.white,
                                ),
                              ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.85,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                final selectedPosition =
                                    ref.watch(selectedPositionProvider);

                                if (selectedPosition != null) {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setDouble(
                                      'latitude', selectedPosition.latitude);
                                  await prefs.setDouble(
                                      'longitude', selectedPosition.longitude);

                                  Navigator.push(
                                      context,
                                      CupertinoModalPopupRoute(
                                        builder: (context) => const AddressForm(
                                          totalPrice: 0,
                                        ),
                                      ));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: const Text(
                                'Add more address details',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: LoadingAnimationWidget.discreteCircle(
                color: Colors.green,
                size: 70,
              ),
            ),
    );
  }
}

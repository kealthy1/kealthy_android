import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';
import '../Riverpod/distance.dart';
import '../Services/placesuggetions.dart';
import 'Delivery_details.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final addressProvider = StateProvider<String?>((ref) => null);
final mapControllerProvider = StateProvider<MapController?>((ref) => null);
final suggestionsProvider = StateProvider<List<String>>((ref) {
  return [];
});
final currentlocationProviders =
    StateNotifierProvider<LocationNotifier, Position?>((ref) {
  return LocationNotifier(ref);
});

final selectedPositionProvider = StateProvider<LatLng?>((ref) => null);
final isFetchingLocationProvider = StateProvider<bool>((ref) => false);
final isSearchingProvider = StateProvider<bool>((ref) => false);

class LocationNotifier extends StateNotifier<Position?> {
  LatLng? _selectedPosition;
  final Ref ref;

  LocationNotifier(this.ref) : super(null) {
    Future.microtask(() => _getCurrentLocation());
  }

  LatLng? get selectedPosition => _selectedPosition;

  set selectedPosition(LatLng? position) {
    _selectedPosition = position;
  }

  Future<void> _getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      state = position;

      final latLngPosition = LatLng(position.latitude, position.longitude);
      ref.read(selectedPositionProvider.notifier).state = latLngPosition;
      await _updateAddress(latLngPosition);
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _updateAddress(LatLng position) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks.first;

        final List<String?> addressComponents = [
          placemark.subLocality,
          placemark.street,
          placemark.postalCode,
          placemark.locality,
          placemark.administrativeArea,
          placemark.country,
        ];
        final address = addressComponents
            .where((component) => component != null && component.isNotEmpty)
            .toSet()
            .join(", ");
        ref.read(addressProvider.notifier).state = address;
      }
    } catch (e) {
      print('Error in reverse geocoding: $e');
    }
  }

  Future<void> fetchPlaceSuggestions(String query) async {
    try {
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=AIzaSyD1MUoakZ0mm8WeFv_GK9k_zAWdGk5r1hA'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final suggestions = (data['predictions'] as List)
              .map((e) => {
                    'description': e['description'],
                    'placeId': e['place_id'],
                  })
              .toList();
          ref.read(placeSuggestionsProvider.notifier).state = suggestions;
        }
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  Future<void> searchLocation(String placeId) async {
    try {
      ref.read(isSearchingProvider.notifier).state = true;

      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeId&key=AIzaSyD1MUoakZ0mm8WeFv_GK9k_zAWdGk5r1hA'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          final position = LatLng(location['lat'], location['lng']);

          ref.read(selectedPositionProvider.notifier).state = position;

          final mapController = ref.read(mapControllerProvider);
          if (mapController != null) {
            mapController.move(position, 18.0);
          }

          await _updateAddress(position);

          ref.read(placeSuggestionsProvider.notifier).state = [];
        }
      }
    } catch (e) {
      print('Error in searching location: $e');
    } finally {
      ref.read(isSearchingProvider.notifier).state = false;
    }
  }
}

class SelectLocationPage extends ConsumerStatefulWidget {
  final String name;
  final String selectedRoad;
  final String landmark;
  final String type;
  final String directions;
  const SelectLocationPage({
    super.key,
    required this.name,
    required this.selectedRoad,
    required this.landmark,
    required this.type,
    required this.directions,
  });

  @override
  ConsumerState<SelectLocationPage> createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends ConsumerState<SelectLocationPage> {
  late TextEditingController _searchController;
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _mapController = MapController();

    Future.microtask(() {
      ref.read(mapControllerProvider.notifier).state = _mapController;
      ref.read(currentlocationProviders.notifier)._getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = ref.watch(currentlocationProviders);
    final selectedPosition = ref.watch(selectedPositionProvider);
    final address = ref.watch(addressProvider);
    final placeSuggestions = ref.watch(placeSuggestionsProvider);
    final isFetchingLoaction = ref.watch(isFetchingLocationProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Confirm Delivery Location',
          style: GoogleFonts.poppins(
            color: Color(0xFF273847),
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: currentPosition != null
          ? Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: selectedPosition ??
                        LatLng(currentPosition.latitude,
                            currentPosition.longitude),
                    initialZoom: 18.0,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture) {
                        ref.read(selectedPositionProvider.notifier).state =
                            position.center;
                      }
                    },
                    onMapEvent: (event) {
                      if (event is MapEventMoveEnd) {
                        final center =
                            ref.read(selectedPositionProvider.notifier).state;
                        if (center != null) {
                          ref
                              .read(currentlocationProviders.notifier)
                              ._updateAddress(center);
                        }
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                  ],
                ),
                const Center(
                  child: Icon(
                    Icons.location_pin,
                    size: 40,
                    color: Colors.red,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8.0,
                          offset: Offset(0, -2),
                        )
                      ],
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'DELIVERING YOUR ORDER TO',
                              style: GoogleFonts.poppins(
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                            ),
                            Spacer(),
                            SizedBox(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    side: const BorderSide(
                                        color: Color(0xFF273847))),
                                onPressed: () async {
                                  try {
                                    ref
                                        .read(
                                            isFetchingLocationProvider.notifier)
                                        .state = true;

                                    await ref
                                        .read(currentlocationProviders.notifier)
                                        ._getCurrentLocation();

                                    final currentPosition = ref
                                        .read(currentlocationProviders.notifier)
                                        // ignore: invalid_use_of_protected_member
                                        .state;

                                    if (currentPosition != null) {
                                      ref
                                          .read(
                                              currentlocationProviders.notifier)
                                          .selectedPosition = LatLng(
                                        currentPosition.latitude,
                                        currentPosition.longitude,
                                      );

                                      _mapController.move(
                                        LatLng(
                                          currentPosition.latitude,
                                          currentPosition.longitude,
                                        ),
                                        18.0,
                                      );
                                    }
                                  } catch (e) {
                                    print('Error fetching location: $e');
                                  } finally {
                                    ref
                                        .read(
                                            isFetchingLocationProvider.notifier)
                                        .state = false;
                                  }
                                },
                                child: isFetchingLoaction
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF273847),
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.my_location,
                                        color: Color(0xFF273847)),
                              ),
                            ),
                          ],
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
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
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
                        SizedBox(
                          height: 20,
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.85,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                final selectedPosition =
                                    ref.watch(selectedPositionProvider);
                                final double restaurantLatitude =
                                    10.010279427438405;
                                final double restaurantLongitude =
                                    76.38426666931349;
                                if (selectedPosition != null) {
                                  final Future<double> drivingDistanceFuture =
                                      calculateDrivingDistance(
                                    apiKey:
                                        "AIzaSyD1MUoakZ0mm8WeFv_GK9k_zAWdGk5r1hA",
                                    startLatitude: selectedPosition.latitude,
                                    startLongitude: selectedPosition.longitude,
                                    endLatitude: restaurantLatitude,
                                    endLongitude: restaurantLongitude,
                                  );

                                  final drivingDistance =
                                      await drivingDistanceFuture;
                                  if (drivingDistance > 10) {
                                    Fluttertoast.showToast(
                                      msg:
                                          "Above 10 km Location is not serviceable.",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                    );
                                    return;
                                  }

                                  _showAddressFormBottomSheet(
                                    context,
                                    widget.name,
                                    widget.selectedRoad,
                                    widget.landmark,
                                    widget.type,
                                    selectedPosition.latitude,
                                    selectedPosition.longitude,
                                    widget.directions,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF273847),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: Text(
                                'Add more address details',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.01,
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
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: TextField(
                                    cursorHeight: 20,
                                    controller: _searchController,
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        ref
                                            .read(currentlocationProviders
                                                .notifier)
                                            .searchLocation(
                                              value,
                                            );
                                        ref
                                            .read(placeSuggestionsProvider
                                                .notifier)
                                            .fetchPlaceSuggestions(value);
                                      } else {
                                        ref
                                            .read(placeSuggestionsProvider
                                                .notifier)
                                            // ignore: invalid_use_of_protected_member
                                            .state = [];
                                      }
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Search location',
                                      hintStyle: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black38,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.only(left: 16),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              ref.watch(isSearchingProvider)
                                  ? const SizedBox(
                                      width: 24.0,
                                      height: 24.0,
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF273847),
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          if (placeSuggestions.isNotEmpty &&
                              _searchController.text.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: placeSuggestions.map((suggestion) {
                                  final suggestionName =
                                      suggestion['description'];

                                  return ListTile(
                                    title:
                                        Text(suggestionName ?? 'Unknown Place'),
                                    onTap: () async {
                                      _searchController.text =
                                          suggestionName ?? '';
                                      ref
                                          .read(
                                              placeSuggestionsProvider.notifier)
                                          // ignore: invalid_use_of_protected_member
                                          .state = [];
                                      final placeId = suggestion['placeId'];
                                      await ref
                                          .read(
                                              currentlocationProviders.notifier)
                                          .searchLocation(
                                            placeId,
                                          );
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: LoadingAnimationWidget.inkDrop(
              color: Color(0xFF273847),
              size: 70,
            )),
    );
  }

  void _showAddressFormBottomSheet(
    BuildContext context,
    String name,
    String selectedRoad,
    String landmark,
    String type,
    double latitude,
    double longitude,
    String directions,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddressForm(
          name: name,
          selectedRoad: selectedRoad,
          landmark: landmark,
          type: type,
          latitude: latitude,
          longitude: longitude,
          directions: directions,
        ),
      ),
    );
  }
}

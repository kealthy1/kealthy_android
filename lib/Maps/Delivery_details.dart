import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kealthy/LandingPage/Widgets/floating_bottom_navigation_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Cart/SlotsBooking.dart';
import '../Payment/SavedAdress.dart';
import 'fluttermap.dart';

final selectedSlotProvider = StateProvider<String?>((ref) => null);
final issavedProvider = StateProvider<bool>((ref) => false);

class AddressForm extends ConsumerStatefulWidget {
  final double latitude;
  final double longitude;
  final String name;
  final String selectedRoad;
  final String landmark;
  final String type;
  final String directions;

  final String? date;

  const AddressForm({
    super.key,
    required this.longitude,
    required this.latitude,
    this.date,
    required this.name,
    required this.selectedRoad,
    required this.landmark,
    required this.type,
    required this.directions,
  });

  @override
  _AddressFormState createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<AddressForm> {
  final TextEditingController houseController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();
  final TextEditingController LandMarkController = TextEditingController();
  final TextEditingController directionsController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    houseController.text = widget.name.isNotEmpty ? widget.name : '';
    apartmentController.text =
        widget.selectedRoad.isNotEmpty ? widget.selectedRoad : '';
    LandMarkController.text = widget.landmark.isNotEmpty ? widget.landmark : '';
    directionsController.text =
        widget.directions.isNotEmpty ? widget.directions : '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.type.isNotEmpty) {
        ref.read(savedValueProvider.notifier).state = widget.type;
        ref.read(buttonPressedProvider.notifier).state = widget.type;
      }
      ref.read(buttonPressedProvider.notifier).state = widget.type;
      final address = ref.read(addressProvider);
      if (address!.isNotEmpty) {
        List<String> addressParts = address.split(',');
        if (addressParts.length > 1) {
          String filteredAddress = addressParts.sublist(0).join(',').trim();
          addressController.text = filteredAddress;
        } else {
          addressController.text = address;
        }
      }
    });
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final issaved = ref.watch(issavedProvider);
    final address = ref.read(addressProvider);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          Center(
            child: Text(
              'Complete Address Details',
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.black26),
                  ),
                  child: address != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  address,
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black45),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                              Flexible(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: const BorderSide(
                                              color: Colors.black45))),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Change',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.black45),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Text('Loading Address...'),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text(
                  'Updated based on your map pin',
                  style: TextStyle(fontSize: 11, color: Colors.black45),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: houseController,
                  decoration: const InputDecoration(
                    hintText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  cursorColor: Colors.black,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: apartmentController,
                  decoration: const InputDecoration(
                    hintText: 'Flat / Room / area',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: LandMarkController,
                  decoration: const InputDecoration(
                    hintText: 'Landmark (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: directionsController,
                  decoration: const InputDecoration(
                    hintText: 'Directions',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  maxLines: 2,
                  keyboardType: TextInputType.multiline,
                  textAlign: TextAlign.start,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Save the address as',
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildSaveButton(Icons.home, 'Home')),
                    const SizedBox(width: 4),
                    Expanded(
                        child: _buildSaveButton(
                            Icons.work_outline_rounded, 'Work')),
                    const SizedBox(width: 4),
                    Expanded(
                        child: _buildSaveButton(Icons.more_horiz, 'Other')),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                issaved
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Color(0xFF273847),
                            strokeWidth: 5,
                          ),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            const double restaurantLatitude =
                                10.010279427438405;
                            const double restaurantLongitude =
                                76.38426666931349;
                            await _calculateDrivingDistanceAndSave(
                                ref, restaurantLatitude, restaurantLongitude);
                            // ignore: unused_result
                            ref.refresh(etaTimeProvider);
                            // ignore: unused_result
                            ref.refresh(distanceProvider);
                            FocusScope.of(context).unfocus();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF273847),
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'SAVE AND PROCEED',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  final buttonPressedProvider = StateProvider<String?>((ref) => null);
  Widget _buildSaveButton(IconData icon, String label) {
    return Consumer(
      builder: (context, ref, _) {
        final selectedButton = ref.watch(buttonPressedProvider);

        final isPressed = selectedButton == label;

        return OutlinedButton.icon(
          onPressed: () {
            ref.read(buttonPressedProvider.notifier).state = label;

            ref.read(savedValueProvider.notifier).state = label;
            print(label);
          },
          icon: Icon(icon, color: isPressed ? Colors.white : Colors.grey),
          label: Text(
            label,
            style: TextStyle(
              color: isPressed ? Colors.white : Colors.grey,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side:
                BorderSide(color: isPressed ? Color(0xFF273847) : Colors.grey),
            backgroundColor: isPressed ? Color(0xFF273847) : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  final savedValueProvider = StateProvider<String>((ref) => '');

  Future<void> _calculateDrivingDistanceAndSave(
      WidgetRef ref, double startLatitude, double startLongitude) async {
    try {
      final double destinationLatitude = widget.latitude;
      final double destinationLongitude = widget.longitude;

      final double drivingDistance = await _calculateDrivingDistance(
        startLatitude,
        startLongitude,
        destinationLatitude,
        destinationLongitude,
      );

      print('Calculated Driving Distance: $drivingDistance km');

      bool isSaved = await _saveAndSelectAddress(
        ref,
      );

      if (isSaved) {
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoModalPopupRoute(
            builder: (context) => const CustomBottomNavigationBar(),
          ),
          (route) => false,
        );
      }

      ref.read(issavedProvider.notifier).state = false;
    } catch (e) {
      print("Error calculating or saving address: $e");
      Fluttertoast.showToast(
        msg: "Failed to save address. Please try again.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      ref.read(issavedProvider.notifier).state = false;
    }
  }

  Future<bool> _saveAndSelectAddress(WidgetRef ref) async {
    ref.read(issavedProvider.notifier).state = true;

    final name = houseController.text.trim();
    final road = apartmentController.text.trim();
    final directions = directionsController.text.trim();
    final savedValue = ref.read(savedValueProvider);
    final landmark = LandMarkController.text.trim();
    final combinedRoad = '$road, ${addressController.text.trim()}';

    List<String> emptyFields = [];
    if (name.isEmpty) emptyFields.add('Name');
    if (road.isEmpty) emptyFields.add('Flat/Room/Area');
    if (directions.isEmpty) emptyFields.add('Directions');
    if (savedValue.isEmpty) emptyFields.add('Type');

    if (emptyFields.isNotEmpty) {
      Fluttertoast.showToast(
        msg: "${emptyFields.join(', ')} is required.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      ref.read(issavedProvider.notifier).state = false;
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phoneNumber');

      if (phoneNumber == null || phoneNumber.isEmpty) {
        Fluttertoast.showToast(
          msg: "Phone number not found. Please log in again.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        ref.read(issavedProvider.notifier).state = false;
        return false;
      }

      const double restaurantLatitude = 10.010279427438405;
      const double restaurantLongitude = 76.38426666931349;

      final double destinationLatitude = widget.latitude;
      final double destinationLongitude = widget.longitude;

      final double drivingDistance = await _calculateDrivingDistance(
        restaurantLatitude,
        restaurantLongitude,
        destinationLatitude,
        destinationLongitude,
      );

      print('Driving Distance: $drivingDistance km');

      final newAddressData = {
        'phoneNumber': phoneNumber,
        'Name': name,
        'road': combinedRoad,
        'directions': directions,
        'type': savedValue,
        'latitude': destinationLatitude,
        'longitude': destinationLongitude,
        'Landmark': landmark,
        'deliveryDate': DateTime.now().toIso8601String(),
        'selected': true,
        'distance': drivingDistance,
      };

      print('New Address Data: $newAddressData');
      const String apiUrl =
          "https://api-jfnhkjk4nq-uc.a.run.app/addselectAddress";
      Dio dio = Dio();
      final response = await dio.post(
        apiUrl,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
        data: newAddressData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          // ignore: unused_result
          ref.refresh(showAddressProviders);
          // ignore: unused_result
          ref.refresh(distanceProvider);
          // ignore: unused_result
          ref.refresh(etaTimeProvider);
          await prefs.setString('selectedRoad', road);
          await prefs.setString('type', savedValue);
          await prefs.setString('name', name);
          await prefs.remove("selectedAddressMessage");
          Fluttertoast.showToast(
            msg: "Address saved successfully",
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          Navigator.pushAndRemoveUntil(
            context,
            CupertinoModalPopupRoute(
              builder: (context) => const CustomBottomNavigationBar(),
            ),
            (route) => false,
          );

          ref.read(issavedProvider.notifier).state = false;
          return true;
        } else {
          Fluttertoast.showToast(
            msg: responseData['message'] ?? "Failed to save address.",
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Error: ${response.statusCode}. Failed to save address.",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }

      ref.read(issavedProvider.notifier).state = false;
      return false;
    } catch (e) {
      print('Error saving address: $e');
      Fluttertoast.showToast(
        msg: "Something went wrong. Please try again.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      ref.read(issavedProvider.notifier).state = false;
      return false;
    }
  }

  Future<double> _calculateDrivingDistance(double startLatitude,
      double startLongitude, double endLatitude, double endLongitude) async {
    const String apiKey = "AIzaSyD1MUoakZ0mm8WeFv_GK9k_zAWdGk5r1hA";
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$startLatitude,$startLongitude&destination=$endLatitude,$endLongitude&mode=walking&key=$apiKey";

    try {
      final dio = Dio();

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        final routes = jsonResponse['routes'] as List;

        if (routes.isNotEmpty) {
          final legs = routes[0]['legs'] as List;
          final distance = legs[0]['distance']['value'] as int;
          return distance / 1000;
        } else {
          throw Exception("No route found between the locations.");
        }
      } else {
        throw Exception(
            "Failed to fetch driving distance: ${response.statusCode}");
      }
    } catch (e) {
      print("Error calculating distance: $e");
      return 5;
    }
  }
}

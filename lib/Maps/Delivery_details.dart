import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kealthy/Maps/SelectAdress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Select Location.dart';
import 'functions/Delivery_detailslocationprovider.dart';
import 'package:fluttertoast/fluttertoast.dart';

final selectedSlotProvider = StateProvider<String?>((ref) => null);

class AddressForm extends ConsumerStatefulWidget {
  final double totalPrice;
  final String? date;

  const AddressForm({
    super.key,
    required this.totalPrice,
    this.date,
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      directionsController.text = "Don't send cutlery, tissues, and straws";
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
    final currentLocation = ref.watch(locationProvider);
    ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, color: Colors.green),
                const SizedBox(width: 1),
                Text(
                  currentLocation.split('\n').first,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                currentLocation,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 22),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: houseController,
                      decoration: const InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'Name',
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 22),
                    TextFormField(
                      controller: apartmentController,
                      decoration: const InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'APARTMENT / ROAD / AREA',
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: LandMarkController,
                      decoration: const InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelText: 'LandMark (OPTIONAL)',
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(enabled: false,
                      controller: addressController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                CupertinoScrollbar.defaultRadius)),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: directionsController,
                      maxLength: 200,
                      decoration: const InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText:
                            ' Instructions to kitchen and Delivery Partner',
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'SAVE THIS ADDRESS AS',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _buildSaveButton(Icons.home, 'Home')),
                        const SizedBox(width: 4),
                        Expanded(child: _buildSaveButton(Icons.work, 'Work')),
                        const SizedBox(width: 4),
                        Expanded(
                            child: _buildSaveButton(Icons.more_horiz, 'Other')),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    bool isSaved = await _saveAddress(ref);
                    ref.read(savedValueProvider);
                    if (isSaved) {
                      Navigator.pushReplacement(
                        context,
                        CupertinoModalPopupRoute(
                          builder: (context) => const SelectAdress(
                            totalPrice: 0,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'SAVE AND PROCEED',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
            side: BorderSide(color: isPressed ? Colors.green : Colors.grey),
            backgroundColor: isPressed ? Colors.green : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  final savedValueProvider = StateProvider<String>((ref) => '');

  Future<bool> _saveAddress(WidgetRef ref) async {
    final Name = houseController.text.trim();
    final road = apartmentController.text.trim();
    final directions = directionsController.text.trim();
    final savedValue = ref.read(savedValueProvider);
    final Landmark = LandMarkController.text.trim();
    final address = addressController.text.trim();
    final combinedRoad = '$road, $address';

    if (Name.isEmpty ||
        road.isEmpty ||
        directions.isEmpty ||
        savedValue.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill all fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 12.0,
      );
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phoneNumber');

      if (phoneNumber == null || phoneNumber.isEmpty) {
        Fluttertoast.showToast(
          msg: "Your Cache Cleared Relogin To Continue",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 12.0,
        );
        return false;
      }

      double? latitude = prefs.getDouble('latitude');
      double? longitude = prefs.getDouble('longitude');

      if (longitude == null) {
        Fluttertoast.showToast(
          msg: "Location data is not available.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 12.0,
        );
        return false;
      }

      print('Phone Number: $phoneNumber');
      print('Latitude: $latitude, Longitude: $longitude');

      final response = await http.post(
        Uri.parse('https://api-jfnhkjk4nq-uc.a.run.app/address'),
        body: jsonEncode({
          'Name': Name,
          'road': combinedRoad,
          'directions': directions,
          'phoneNumber': phoneNumber,
          'deliveryDate': DateTime.now().toIso8601String(),
          'type': savedValue,
          'latitude': latitude,
          'longitude': longitude,
          'Landmark': Landmark,
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Address saved successfully!');
        return true;
      } else {
        print('Failed to save address: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  final selectedSlotProvider = StateProvider<String>((ref) => '');
}

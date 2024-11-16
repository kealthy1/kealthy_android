import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:kealthy/Maps/SelectAdress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Select Location.dart';
import 'package:fluttertoast/fluttertoast.dart';

final selectedSlotProvider = StateProvider<String?>((ref) => null);
final issavedProvider = StateProvider<bool>((ref) => false);

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

    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complete Address Details',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3.0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Save the adress as',
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
                    const SizedBox(
                      height: 20,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                            fontSize: 11,
                                            color: Colors.black45),
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
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: directionsController,
                      maxLength: 200,
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
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: issaved
                          ? const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.green,
                                  strokeWidth: 5,
                                ),
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  ref.read(issavedProvider.notifier);
                                  bool isSaved = await _saveAddress(ref);
                                  ref.read(savedValueProvider);
                                  if (isSaved) {
                                    Navigator.pushReplacement(
                                      context,
                                      CupertinoModalPopupRoute(
                                        builder: (context) =>
                                            const SelectAdress(
                                          totalPrice: 0,
                                        ),
                                      ),
                                    );
                                  }
                                  ref.read(issavedProvider.notifier).state =
                                      false;
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 20.0),
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
    ref.read(issavedProvider.notifier).state = true;
    final Name = houseController.text.trim();
    final road = apartmentController.text.trim();
    final directions = directionsController.text.trim();
    final savedValue = ref.read(savedValueProvider);
    final Landmark = LandMarkController.text.trim();
    final address = addressController.text.trim();
    final combinedRoad = '$road $address';

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
      ref.read(issavedProvider.notifier).state = false;
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
        ref.read(issavedProvider.notifier).state = false;
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
        ref.read(issavedProvider.notifier).state = false;
        return true;
      } else {
        print('Failed to save address: ${response.statusCode}');
        print('Response body: ${response.body}');
        ref.read(issavedProvider.notifier).state = false;
        return false;
      }
    } catch (e) {
      print('Error: $e');
      ref.read(issavedProvider.notifier).state = false;
      return false;
    }
  }

  final selectedSlotProvider = StateProvider<String>((ref) => '');
}

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kealthy/LandingPage/HomePage.dart';
import 'package:kealthy/Maps/SelectAdress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Riverpod/distance.dart';
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
                                  color: Color(0xFF273847),
                                  strokeWidth: 5,
                                ),
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  ref.read(issavedProvider.notifier);
                                  bool isSaved = await _saveAndSelectAddress(ref,0.0);
                                  ref.read(savedValueProvider);
                                  if (isSaved) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      CupertinoModalPopupRoute(
                                        builder: (context) =>
                                            const MyHomePage(
                                          
                                        ),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                  ref.read(issavedProvider.notifier).state =
                                      false;
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF273847),
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

Future<bool> _saveAndSelectAddress(WidgetRef ref, double distance) async {
  ref.read(issavedProvider.notifier).state = true;

  final name = houseController.text.trim();
  final road = apartmentController.text.trim();
  final directions = directionsController.text.trim();
  final savedValue = ref.read(savedValueProvider);
  final landmark = LandMarkController.text.trim();
  final address = addressController.text.trim();
  final combinedRoad = '$road $address';

  if (name.isEmpty || road.isEmpty || directions.isEmpty || savedValue.isEmpty) {
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
    final latitude = prefs.getDouble('latitude');
    final longitude = prefs.getDouble('longitude');

    if (phoneNumber == null || phoneNumber.isEmpty) {
      Fluttertoast.showToast(
        msg: "Your Cache Cleared. Relogin to Continue",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 12.0,
      );
      ref.read(issavedProvider.notifier).state = false;
      return false;
    }

    if (longitude == null || latitude == null) {
      Fluttertoast.showToast(
        msg: "Location data is not available.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 12.0,
      );
      ref.read(issavedProvider.notifier).state = false;
      return false;
    }
 final double restaurantLatitude = 10.010279427438405;
    final double restaurantLongitude = 76.38426666931349;
    final double calculatedDistance = calculatesDistance(
      latitude,
      longitude,
      restaurantLatitude,
      restaurantLongitude,
    );
    final newAddressData = {
      'name': name,
      'road': combinedRoad,
      'directions': directions,
      'phoneNumber': phoneNumber,
      'deliveryDate': DateTime.now().toIso8601String(),
      'type': savedValue,
      'latitude': latitude,
      'longitude': longitude,
      'landmark': landmark,
      'distance': calculatedDistance,
    };

    final savedAddresses = prefs.getStringList('savedAddresses') ?? [];
    List<Map<String, dynamic>> addressList = savedAddresses
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList();

    bool isTypeReplaced = false;
    addressList = addressList.map((address) {
      if (address['type'] == savedValue) {
        isTypeReplaced = true;
        return newAddressData;
      }
      return address;
    }).toList();

    if (!isTypeReplaced) {
      addressList.add(newAddressData);
    }

    await prefs.setStringList(
      'savedAddresses',
      addressList.map((address) => jsonEncode(address)).toList(),
    );

    // Save the selected address as the primary
    final selectedAddress = Address(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      road: combinedRoad,
      directions: directions,
      type: savedValue,
      latitude: latitude,
      longitude: longitude,
      landmark: landmark,
    );

    await prefs.setString('selectedAddressId', selectedAddress.id);
    await prefs.setString('Name', selectedAddress.name);
    await prefs.setString('selectedRoad', selectedAddress.road);
    await prefs.setString('selectedType', selectedAddress.type);
    if (selectedAddress.directions != null) {
      await prefs.setString('selectedDirections', selectedAddress.directions!);
    }
    await prefs.setDouble('selectedLatitude', selectedAddress.latitude);
    await prefs.setDouble('selectedLongitude', selectedAddress.longitude);
    await prefs.setDouble('selectedDistance', calculatedDistance);
    await prefs.setString('landmark', selectedAddress.landmark);

    print('Address saved and selected: ${selectedAddress.name}, Distance: $calculatedDistance');

    ref.read(issavedProvider.notifier).state = false;
    return true;
  } catch (e) {
    print('Error: $e');
    Fluttertoast.showToast(
      msg: "Failed to save address. Please try again.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 12.0,
    );
    ref.read(issavedProvider.notifier).state = false;
    return false;
  }
}

  final selectedSlotProvider = StateProvider<String>((ref) => '');
}

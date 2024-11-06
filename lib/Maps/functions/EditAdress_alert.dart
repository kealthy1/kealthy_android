import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:location/location.dart' as loc;
import '../SelectAdress.dart';

class AddressUtils {
  static Future<void> editAddress(BuildContext context, Address address) async {
    String? newDirections = address.directions;
    String newHouseNo = address.Name;
    String newRoad = address.road;
    String? newLandmark;
    String? newPhoneNumber = address.phoneNumber;

    final prefs = await SharedPreferences.getInstance();
    String? phoneNumberFromPrefs = prefs.getString('phoneNumber') ?? '';

    final TextEditingController directionsController =
        TextEditingController(text: address.directions);
    final TextEditingController houseNoController =
        TextEditingController(text: address.Name);
    final TextEditingController roadController =
        TextEditingController(text: address.road);
    final TextEditingController landmarkController =
        TextEditingController(text: address.Landmark);
    final TextEditingController phoneNumberController =
        TextEditingController(text: phoneNumberFromPrefs);

    await showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Center(
                    child: Text(
                      'Edit Address',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: houseNoController,
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'Name',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: roadController,
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'Road',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: landmarkController,
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'Landmark',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: directionsController,
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      labelText: 'Directions',
                      labelStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        style: ButtonStyle(
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          backgroundColor:
                              WidgetStateProperty.all(Colors.green),
                        ),
                        icon: const Icon(
                          Icons.my_location_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          await fetchCurrentLocation(
                              context, phoneNumberFromPrefs, address.type);
                        },
                        label: const Text(
                          'Locate Me',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black),
                        onPressed: () {
                          newHouseNo = houseNoController.text;
                          newRoad = roadController.text;
                          newLandmark = landmarkController.text;
                          newDirections = directionsController.text;
                          newPhoneNumber = phoneNumberController.text;

                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    const url = 'https://api-jfnhkjk4nq-uc.a.run.app/editaddress';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': address.id,
        'Name': newHouseNo,
        'road': newRoad,
        'Landmark': newLandmark,
        'directions': newDirections,
        'phoneNumber': newPhoneNumber,
        'type': address.type,
      }),
    );

    if (response.statusCode == 200) {
      Fluttertoast.showToast(
        msg: "Address updated successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Failed to update address",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  static Future<void> fetchCurrentLocation(
      BuildContext context, String phoneNumber, String addressType) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: LoadingAnimationWidget.discreteCircle(
            color: Colors.green,
            size: 50,
          ),
        );
      },
    );

    try {
      loc.Location location = loc.Location();

      bool serviceEnabled;
      loc.PermissionStatus permissionGranted;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          Navigator.of(context).pop();
          Fluttertoast.showToast(
            msg: "Location services are disabled",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          return;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          Navigator.of(context).pop();

          return;
        }
      }

      loc.LocationData locationData = await location.getLocation();

      List<Placemark> placemarks = await placemarkFromCoordinates(
          locationData.latitude!, locationData.longitude!);
      String? pincode = placemarks.first.postalCode;
      // const List<String> serviceablePincodes = [
      //   '683565',
      //   '682021',
      //   '682037',
      //   '682030'
      // ];
      // if (pincode == null || !serviceablePincodes.contains(pincode)) {
      //   Navigator.of(context).pop();
      //   Fluttertoast.showToast(
      //     msg: "Delivery not available in your current address",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.BOTTOM,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0,
      //   );
      //   return;
      // }

      const url = 'https://api-jfnhkjk4nq-uc.a.run.app/address/location';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'latitude': locationData.latitude,
          'longitude': locationData.longitude,
          'type': addressType,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
          msg: "Current address added successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        Navigator.of(context).pop();
        Fluttertoast.showToast(
          msg: "Failed to add location",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(
        msg: "Error occurred: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}

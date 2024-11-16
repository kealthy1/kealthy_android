import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kealthy/Maps/SelectAdress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

class SavedAddress extends StatefulWidget {
  const SavedAddress({super.key});

  @override
  _SavedAddressState createState() => _SavedAddressState();
}

class _SavedAddressState extends State<SavedAddress> {
  final StreamController<void> _preferencesStreamController =
      StreamController<void>.broadcast();

  @override
  void dispose() {
    _preferencesStreamController.close();
    super.dispose();
  }

  Future<void> _updateSharedPreferences() async {
    _preferencesStreamController.add(null);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: _preferencesStreamController.stream,
      builder: (context, snapshot) {
        return FutureBuilder<Map<String, dynamic>?>(
          future: _getSavedAddress(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  color: Colors.grey[300],
                ),
              ));
            } else if (snapshot.hasError) {
              print('Error loading address: ${snapshot.error}');
              return const Text('Error loading address');
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Text('No address saved');
            }

            final savedAddressData = snapshot.data!;
            final addressType = savedAddressData['type'];
            final name = savedAddressData['Name'];
            final road = savedAddressData['road'];
            final distance = savedAddressData['distance'];
            final directions = savedAddressData['directions'];
            final landmark = savedAddressData['landmark'];
            final slot = savedAddressData['selectedSlot'];

            String formattedDistance =
                distance != null ? '${distance.toStringAsFixed(1)} km' : 'N/A';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Delivery',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                CupertinoModalPopupRoute(
                                  builder: (context) =>
                                      const SelectAdress(totalPrice: 0),
                                )).then((value) {
                              _updateSharedPreferences();
                            });
                          },
                          child: const Text(
                            'Change',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          addressType ?? 'Address Type',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$name, $road',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedDistance,
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Delivery Slot: ${slot ?? 'N/A'}",
                      style: const TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    if (directions!.isNotEmpty)
                      Text(
                        "Instructions: $directions",
                        style: const TextStyle(color: Colors.black),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      landmark != null && landmark.isNotEmpty
                          ? "Landmark: $landmark"
                          : "",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('Name');
    final road = prefs.getString('selectedRoad');
    final type = prefs.getString('selectedType');
    final distance = prefs.getDouble('selectedDistance');
    final mobile = prefs.getString('phoneNumber');
    final directions = prefs.getString('selectedDirections');
    final landmark = prefs.getString('landmark');
    final slot = prefs.getString('selectedSlot');

    if (name != null && road != null && type != null) {
      return {
        'Name': name,
        'road': road,
        'type': type,
        'distance': distance,
        'mobile': mobile,
        'directions': directions,
        'selectedSlot': slot,
        'landmark': landmark,
      };
    }
    return null;
  }
}

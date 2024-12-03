import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kealthy/LandingPage/Widgets/Appbar.dart';
import 'package:kealthy/Maps/Select%20Location.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../Payment/Bill.dart';

final selectedAddressProvider = StateProvider<Address?>((ref) => null);

final addressesProvider = FutureProvider<List<Address>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final phoneNumber = prefs.getString('phoneNumber');

  if (phoneNumber != null) {
    try {
      final response = await http.get(Uri.parse(
          'https://api-jfnhkjk4nq-uc.a.run.app/getalladdresses?phoneNumber=$phoneNumber'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => Address.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('Error fetching addresses: $e');
    }
  }
  return [];
});

class SelectAdress extends ConsumerStatefulWidget {
  final double totalPrice;

  const SelectAdress({super.key, required this.totalPrice});

  @override
  _LocationSelectionPageState createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends ConsumerState<SelectAdress> {
  List<dynamic> addresses = [];
  Future<void> deleteAddress(
      String phoneNumber, String type, WidgetRef ref) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://api-jfnhkjk4nq-uc.a.run.app/deleteaddress?phoneNumber=$phoneNumber&type=$type'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('Address deleted successfully');

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('selectedAddressId');
        await prefs.remove('Name');
        await prefs.remove('selectedRoad');
        await prefs.remove('selectedType');
        await prefs.remove('selectedDirections');
        await prefs.remove('selectedLatitude');
        await prefs.remove('selectedLongitude');
        await prefs.remove('selectedDistance');

        print('Address removed from SharedPreferences');
        // ignore: unused_result
        ref.refresh(addressesProvider);
        // ignore: unused_result
        ref.refresh(selectedRoadProvider);
      } else {
        print('Failed to delete address: ${response.body}');
      }
    } catch (e) {
      print('Error deleting address: $e');
    }
  }

  Future<void> saveSelectedAddress(Address address, double distance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedAddressId', address.id);
    await prefs.setString('Name', address.Name);
    await prefs.setString('selectedRoad', address.road);
    await prefs.setString('selectedType', address.type);
    if (address.directions != null) {
      await prefs.setString('selectedDirections', address.directions!);
    }
    await prefs.setDouble('selectedLatitude', address.latitude);
    await prefs.setDouble('selectedLongitude', address.longitude);
    await prefs.setDouble('selectedDistance', distance);
    await prefs.setString('Landmark', address.Landmark);

    print(distance);
    print('Landmark: ${address.Landmark}');
  }

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    // ignore: unused_result
    ref.refresh(addressesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final addressesAsyncValue = ref.watch(addressesProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);

    double? restaurantLatitude;
    double? restaurantLongitude;
    double? calculatedDistance;
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // ignore: unused_result
        ref.refresh(selectedRoadProvider);

        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Confirm delivery location'),
          backgroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    CupertinoModalPopupRoute(
                      builder: (context) => const SelectLocationPage(
                        totalPrice: 0,
                      ),
                    ),
                  );
                },
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
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: const Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Colors.green),
                        SizedBox(width: 12.0),
                        Text(
                          'Add address',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              _buildCenteredTitle('SAVED ADDRESSES'),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: addressesAsyncValue.when(
                  data: (addresses) {
                    if (addresses.isEmpty) {
                      return const Center(
                          child: Text('No saved addresses found.'));
                    }

                    return RefreshIndicator(
                      color: Colors.green,
                      onRefresh: () async {
                        // ignore: unused_result
                        ref.refresh(addressesProvider);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: addresses.length,
                              itemBuilder: (context, index) {
                                final address = addresses[index];

                                restaurantLatitude = 10.010279427438405;
                                restaurantLongitude = 76.38426666931349;
                                calculatedDistance = calculateDistance(
                                  address.latitude,
                                  address.longitude,
                                  restaurantLatitude!,
                                  restaurantLongitude!,
                                );
                                return AddressCard(
                                  address: address,
                                  isSelected: selectedAddress == address,
                                  restaurantLatitude: restaurantLatitude,
                                  restaurantLongitude: restaurantLongitude,
                                  distance: calculatedDistance,
                                  onSelected: () {
                                    ref
                                        .read(selectedAddressProvider.notifier)
                                        .state = address;
                                    saveSelectedAddress(
                                        address, calculatedDistance!);
                                  },
                                  onDelete: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final phoneNumber =
                                        prefs.getString('phoneNumber');
                                    if (phoneNumber != null) {
                                      await deleteAddress(
                                          phoneNumber, address.type, ref);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => Center(
                      child: LoadingAnimationWidget.inkDrop(
                          color: Colors.green, size: 50)),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenteredTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: Colors.grey.shade300,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black38,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.grey.shade300,
            ),
          ),
        ],
      ),
    );
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}

class Address {
  final String id;
  final String Name;
  final String Landmark;

  final String road;
  final String type;
  final String? directions;
  final String? phoneNumber;
  final double latitude;
  final double longitude;

  Address({
    required this.id,
    required this.Name,
    required this.road,
    required this.type,
    this.directions,
    this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.Landmark,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'],
      Name: json['Name'],
      Landmark: json['Landmark'],
      road: json['road'],
      type: json['type'],
      directions: json['directions'],
      phoneNumber: json['phoneNumber'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Name': Name,
      'road': road,
      'type': type,
      'directions': directions,
      'phoneNumber': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'Landmark': Landmark,
    };
  }
}

class AddressCard extends ConsumerWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onSelected;
  final VoidCallback onDelete;
  final double? restaurantLatitude;
  final double? restaurantLongitude;
  final double? distance;

  const AddressCard({
    super.key,
    required this.address,
    required this.isSelected,
    required this.onSelected,
    required this.onDelete,
    this.restaurantLatitude,
    this.restaurantLongitude,
    this.distance,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDeliverable = distance != null && distance! <= 30;

    if (!isDeliverable && isSelected) {
      _removeAddressFromSharedPreferences();
      ref.read(selectedAddressProvider.notifier).state = null;
    }

    IconData getIconBasedOnType(String type) {
      switch (type.toLowerCase()) {
        case 'home':
          return CupertinoIcons.home;
        case 'work':
          return Icons.work_outline;
        default:
          return Icons.location_on_outlined;
      }
    }

    return GestureDetector(
      onTap: () async {
        if (!isSelected) {
          ref.read(selectedAddressProvider.notifier).state = address;
          Navigator.pop(context);

          if (distance != null) {
            await saveSelectedAddress(
              address,
              distance!,
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: isDeliverable
            ? Row(
                children: [
                  Column(
                    children: [
                      Icon(
                        getIconBasedOnType(address.type),
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      if (distance != null)
                        Text(
                          '${distance!.toStringAsFixed(2)} km',
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 10),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.type,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${address.Name}, ${address.road}',
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.black54),
                                overflow: TextOverflow.visible,
                              ),
                            ),
                          ],
                        ),
                        if (address.Landmark.isNotEmpty)
                          Text(
                            'Landmark: ${address.Landmark}',
                            style: const TextStyle(color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (address.directions != null)
                          Text(
                            'Instructions: ${address.directions}',
                            style: const TextStyle(color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                          ),
                        const Text(
                          "Delivery available",
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: "poppins",
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: Colors.white,
                    icon: const Icon(Icons.more_vert),
                    onSelected: (String choice) {
                      if (choice == 'Edit') {
                        Navigator.pushReplacement(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => const SelectLocationPage(
                                      totalPrice: 0,
                                    )));
                      } else if (choice == 'Delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: Colors.black54),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Delete',
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.delete,
                                  color: Colors.black54),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              )
            : Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "assets/location_icon.png",
                          height: 50,
                        ),
                        const Text(
                          "Location is not serviceable",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(CupertinoIcons.multiply_circle,
                          color: Colors.black),
                      onPressed: () {
                        onDelete();
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _removeAddressFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('selectedRoad');
  }
}

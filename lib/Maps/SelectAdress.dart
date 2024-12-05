import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/LandingPage/Widgets/Appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import '../Riverpod/distance.dart';
import 'Select Location.dart';

final selectedAddressProvider = StateProvider<Address?>((ref) => null);

final addressesProvider = FutureProvider<List<Address>>((ref) async {
  final prefs = await SharedPreferences.getInstance();

  final savedAddresses = prefs.getStringList('savedAddresses') ?? [];

  return savedAddresses
      .map((addressJson) => Address.fromJson(jsonDecode(addressJson)))
      .toList();
});

class SelectAdress extends ConsumerStatefulWidget {
  final double totalPrice;

  const SelectAdress({super.key, required this.totalPrice});

  @override
  _SelectAddressState createState() => _SelectAddressState();
}

class _SelectAddressState extends ConsumerState<SelectAdress> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ignore: unused_result
      ref.refresh(addressesProvider);
    });
  }

  Future<void> saveAddress(Address newAddress, WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddresses = prefs.getStringList('savedAddresses') ?? [];

    List<Address> addresses = savedAddresses
        .map((addressJson) => Address.fromJson(jsonDecode(addressJson)))
        .toList();

    bool isTypeReplaced = false;

    addresses = addresses.map((address) {
      if (address.type == newAddress.type) {
        isTypeReplaced = true;
        return newAddress;
      }
      return address;
    }).toList();

    if (!isTypeReplaced) {
      addresses.add(newAddress);
    }

    await prefs.setStringList(
      'savedAddresses',
      addresses.map((address) => jsonEncode(address.toJson())).toList(),
    );

    // ignore: unused_result
    ref.refresh(addressesProvider);
  }

  Future<void> saveSelectedAddress(Address address, double distance) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('selectedAddressId', address.id);
    await prefs.setString('Name', address.name);
    await prefs.setString('selectedRoad', address.road);
    await prefs.setString('selectedType', address.type);

    if (address.directions != null) {
      await prefs.setString('selectedDirections', address.directions!);
    }

    await prefs.setDouble('selectedLatitude', address.latitude);
    await prefs.setDouble('selectedLongitude', address.longitude);
    await prefs.setDouble('selectedDistance', distance);
    await prefs.setString('landmark', address.landmark);

    print('Address saved: ${address.name}, Distance: $distance');
  }

  Future<void> deleteAddressLocally(Address address, WidgetRef ref) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAddresses = prefs.getStringList('savedAddresses') ?? [];

      final updatedAddresses = savedAddresses
          .where((addressJson) =>
              Address.fromJson(jsonDecode(addressJson)).road != address.road)
          .toList();

      await prefs.setStringList('savedAddresses', updatedAddresses);
      final selectedAddressId = prefs.getString('selectedRoad');
      if (selectedAddressId == address.road) {
        await prefs.remove('selectedAddressId');
        await prefs.remove('Name');
        await prefs.remove('selectedRoad');
        await prefs.remove('selectedType');
        await prefs.remove('selectedDirections');
        await prefs.remove('selectedLatitude');
        await prefs.remove('selectedLongitude');
        await prefs.remove('selectedDistance');
        await prefs.remove('landmark');
        print('Selected address cleared from SharedPreferences');
      }
      // ignore: unused_result
      ref.refresh(addressesProvider);

      Fluttertoast.showToast(
        msg: "Address deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 12.0,
      );
    } catch (e) {
      print('Error deleting address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressesAsyncValue = ref.watch(addressesProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);

    return WillPopScope(
      onWillPop: ()async {
        ref.refresh(selectedRoadProvider);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            'Confirm delivery location',
            style: TextStyle(fontFamily: "poppins"),
          ),
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
                        Icon(Icons.add, color: Color(0xFF273847)),
                        SizedBox(width: 12.0),
                        Text(
                          'Add address',
                          style: TextStyle(
                            color: Color(0xFF273847),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildCenteredTitle('SAVED ADDRESSES'),
              const SizedBox(height: 10),
              Expanded(
                child: addressesAsyncValue.when(
                  data: (addresses) {
                    if (addresses.isEmpty) {
                      return const Center(
                          child: Text('No saved addresses found.'));
                    }

                    return RefreshIndicator(
                      color: Color(0xFF273847),
                      onRefresh: () async {
                        // ignore: unused_result
                        ref.refresh(addressesProvider);
                      },
                      child: ListView.builder(
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          final address = addresses[index];
                          final double restaurantLatitude = 10.010279427438405;
                          final double restaurantLongitude = 76.38426666931349;
                          final double calculatedDistance = calculatesDistance(
                            address.latitude,
                            address.longitude,
                            restaurantLatitude,
                            restaurantLongitude,
                          );

                          return AddressCard(
                            address: address,
                            isSelected: selectedAddress == address,
                            restaurantLatitude: restaurantLatitude,
                            restaurantLongitude: restaurantLongitude,
                            distance: calculatedDistance,
                            onSelected: () {
                              ref.read(selectedAddressProvider.notifier).state =
                                  address;
                              saveSelectedAddress(address, calculatedDistance);
                            },
                            onDelete: () async {
                              await deleteAddressLocally(address, ref);
                            },
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.green)),
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


}

class Address {
  final String id;
  final String name;
  final String landmark;
  final String road;
  final String type;
  final String? directions;
  final String? phoneNumber;
  final double latitude;
  final double longitude;

  Address({
    required this.id,
    required this.name,
    required this.road,
    required this.type,
    this.directions,
    this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.landmark,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      road: json['road'] ?? 'Unknown',
      type: json['type'] ?? 'Other',
      directions: json['directions'],
      phoneNumber: json['phoneNumber'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      landmark: json['landmark'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'road': road,
      'type': type,
      'directions': directions,
      'phoneNumber': phoneNumber,
      'latitude': latitude,
      'longitude': longitude,
      'landmark': landmark,
    };
  }
}

class AddressCard extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback onSelected;
  final VoidCallback onDelete;
  final double restaurantLatitude;
  final double restaurantLongitude;
  final double distance;

  const AddressCard({
    super.key,
    required this.address,
    required this.isSelected,
    required this.onSelected,
    required this.onDelete,
    required this.restaurantLatitude,
    required this.restaurantLongitude,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final isDeliverable = distance <= 30;
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
      onTap: isDeliverable
          ? () async {
              Fluttertoast.showToast(
                msg: "Address ${address.type} Selected!",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 12.0,
              );
              onSelected();
              Navigator.pop(context);
            }
          : null,
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
        child: Row(
          children: [
            Column(
              children: [
                Icon(getIconBasedOnType(address.type),
                    color: Color(0xFF273847)),
                const SizedBox(height: 8),
                Text(
                  '${distance.toStringAsFixed(2)} km',
                  style: const TextStyle(color: Colors.black54, fontSize: 10),
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
                  Text(
                    '${address.name}, ${address.road}',
                    style: const TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  if (address.landmark.isNotEmpty)
                    Text(
                      'Landmark: ${address.landmark}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  if (address.directions != null)
                    Text(
                      'Instructions: ${address.directions}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  Text(
                    isDeliverable
                        ? "Delivery available"
                        : "Delivery unavailable",
                    style: TextStyle(
                        fontSize: 13,
                        fontFamily: "Poppins",
                        color: isDeliverable ? Colors.green : Colors.red),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              color: Colors.white,
              onSelected: (String choice) {
                if (choice == 'Edit') {
                  Navigator.pushReplacement(
                    context,
                    CupertinoModalPopupRoute(
                      builder: (context) => const SelectLocationPage(
                        totalPrice: 0,
                      ),
                    ),
                  );
                } else if (choice == 'Delete') {
                  onDelete();
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'Edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Color(0xFF273847)),
                      SizedBox(width: 8),
                      Text(
                        'Edit',
                        style: TextStyle(fontFamily: "poppins"),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'Delete',
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.delete, color: Color(0xFF273847)),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(fontFamily: "poppins")),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

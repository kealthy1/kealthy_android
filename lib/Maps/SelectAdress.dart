import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/LandingPage/Widgets/Appbar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Payment/Addressconfirm.dart';
import '../Payment/Bill.dart';
import '../Payment/SavedAdress.dart';
import '../Riverpod/distance.dart';
import '../Services/adresslisten.dart';
import 'fluttermap.dart';
import 'functions/Location_Permission.dart';

final loadingProvider = StateProvider<bool>((ref) => false);
final selectedAddressProvider = StateProvider<Address?>((ref) => null);
final loadingAddressProvider = StateProvider<String?>((ref) => null);

final dio = Dio(BaseOptions(baseUrl: "https://api-jfnhkjk4nq-uc.a.run.app"));
final addressesProvider = FutureProvider<List<Address>>((ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');

    if (phoneNumber == null || phoneNumber.isEmpty) {
      print("Phone number not found in SharedPreferences.");
      return [];
    }

    print("Using phoneNumber: $phoneNumber");

    final response = await dio.get(
      "/getalladdresses",
      queryParameters: {'phoneNumber': phoneNumber},
    );

    if (response.statusCode == 200) {
      final jsonResponse = response.data;
      return (jsonResponse['data'] as List)
          .map((data) => Address.fromJson(data))
          .toList();
    } else {
      print(
          "Failed to fetch addresses. Status Code: ${response.statusCode}, Response: ${response.data}");
      return [];
    }
  } catch (e) {
    if (e is DioException) {
      print("Dio error fetching addresses: ${e.response?.data ?? e.message}");
    } else {
      print("Error fetching addresses: $e");
    }
    return [];
  }
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

  Future<void> deleteAddressFromAPI(Address address, WidgetRef ref) async {
    const String apiUrl = "https://api-jfnhkjk4nq-uc.a.run.app/deleteAddress";

    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phoneNumber');
      await prefs.remove("type");
      await prefs.remove("selectedRoad");
      await prefs.remove("selectedAddressMessage");

      if (phoneNumber == null || phoneNumber.isEmpty) {
        Fluttertoast.showToast(
          msg: "Phone number not found. Please log in again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 12.0,
        );
        return;
      }

      final dio = Dio();
      dio.options.headers = {'Content-Type': 'application/json'};

      final response = await dio.delete(
        apiUrl,
        queryParameters: {
          'phoneNumber': phoneNumber,
          'type': address.type,
        },
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "Address deleted successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 12.0,
        );

        // ignore: unused_result
        ref.refresh(addressesProvider);
      } else if (response.statusCode == 404) {
        Fluttertoast.showToast(
          msg: "Address not found: ${address.type}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 12.0,
        );
      } else {
        throw Exception(
            "Failed to delete address. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("Error deleting address: $e");
      Fluttertoast.showToast(
        msg: "Failed to delete address. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 12.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final addressesAsyncValue = ref.watch(addressesProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);

    return WillPopScope(
      onWillPop: () async {
        // ignore: unused_result
        ref.refresh(showAddressProviders);
        // ignore: unused_result
        ref.refresh(selectedSlotProviders);
        // ignore: unused_result
        ref.refresh(savedAddressProvider);
        // ignore: unused_result
        ref.refresh(totalDistanceProvider);
        // ignore: unused_result
        ref.refresh(selectedRoadProvider);
        // ignore: unused_result
        ref.refresh(typeProvider);

        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            'Confirm delivery location',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 22,
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  bool serviceEnabled =
                      await Geolocator.isLocationServiceEnabled();

                  if (serviceEnabled) {
                    Navigator.push(
                      context,
                      CupertinoModalPopupRoute(
                        builder: (context) => SelectLocationPage(
                          name: "",
                          selectedRoad: "",
                          landmark: "",
                          type: "",
                          directions: '',
                        ),
                      ),
                    );
                  } else {
                    checkAndRequestLocation(context);
                  }
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
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.add, color: Color(0xFF273847)),
                        const SizedBox(width: 12.0),
                        Text(
                          'Add address',
                          style: GoogleFonts.poppins(
                            color: Color(0xFF273847),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildCenteredTitle('SAVED ADDRESSES'),
              const SizedBox(height: 10),
              Expanded(
                child: addressesAsyncValue.when(
                  data: (addresses) {
                    if (addresses.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 50,
                            color: Color(0xFF273847),
                          ),
                          Text(
                            'No saved addresses found.',
                            style: TextStyle(fontFamily: "poppins"),
                          ),
                        ],
                      );
                    }

                    return RefreshIndicator(
                      backgroundColor: Colors.white,
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

                          final Future<double> drivingDistanceFuture =
                              calculateDrivingDistance(
                            apiKey: "AIzaSyD1MUoakZ0mm8WeFv_GK9k_zAWdGk5r1hA",
                            startLatitude: address.latitude,
                            startLongitude: address.longitude,
                            endLatitude: restaurantLatitude,
                            endLongitude: restaurantLongitude,
                          );

                          return FutureBuilder<double>(
                            future: drivingDistanceFuture,
                            builder: (context, snapshot) {
                              final double drivingDistance =
                                  snapshot.data ?? calculatedDistance;

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: AddressCard(
                                  address: address,
                                  isSelected: selectedAddress == address,
                                  restaurantLatitude: restaurantLatitude,
                                  restaurantLongitude: restaurantLongitude,
                                  distance: drivingDistance,
                                  onSelected: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final phoneNumber =
                                        prefs.getString('phoneNumber');
                                    await prefs.setDouble(
                                        'selectedDistance', drivingDistance);
                                    await ref
                                        .read(updateAddressProvider.notifier)
                                        .updateSelectedAddress(
                                            phoneNumber!, address.type);
                                    if (mounted) {
                                      ref
                                          .read(
                                              selectedAddressProvider.notifier)
                                          .state = address;
                                    }
                                  },
                                  onDelete: () async {
                                    await deleteAddressFromAPI(address, ref);
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                  loading: () => Center(
                    child: LoadingAnimationWidget.inkDrop(
                      color: Color(0xFF273847),
                      size: 60,
                    ),
                  ),
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
              color: Colors.grey,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: Color(0xFF273847),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: Colors.grey,
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
  final String road;
  final String landmark;
  final String directions;
  final DateTime? deliveryDate;
  final String type;
  final double latitude;
  final double longitude;
  final bool selected;

  Address({
    required this.id,
    required this.name,
    required this.road,
    required this.landmark,
    required this.directions,
    this.deliveryDate,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.selected,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'] ?? '',
      name: json['Name'] ?? '',
      road: json['road'] ?? '',
      landmark: json['Landmark'] ?? '',
      directions: json['directions'],
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      type: json['type'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      selected: json['selected'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'Name': name,
      'road': road,
      'Landmark': landmark,
      'directions': directions,
      'deliveryDate': deliveryDate?.toIso8601String(),
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'selected': selected,
    };
  }
}

class AddressCard extends ConsumerStatefulWidget {
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
  ConsumerState<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends ConsumerState<AddressCard> {
  @override
  Widget build(BuildContext context) {
    final loadingAddress = ref.watch(loadingAddressProvider);
    final isLoading = loadingAddress == widget.address.type;

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
        ref.read(loadingAddressProvider.notifier).state = widget.address.type;
        final prefs = await SharedPreferences.getInstance();
        final phoneNumber = prefs.getString('phoneNumber');

        if (phoneNumber != null) {
          final success = await ref
              .read(updateAddressProvider.notifier)
              .updateSelectedAddress(phoneNumber, widget.address.type);
          if (!mounted) return;
          if (Navigator.canPop(context)) {
            if (success) {
              await prefs.setString('selectedRoad', widget.address.road);

              await prefs.setString('type', widget.address.type);
              await prefs.setString('name', widget.address.name);
              await prefs.setString(
                  'selectedAddressMessage', widget.address.road);

              Fluttertoast.showToast(
                msg: "Address ${widget.address.type} Selected ✔️",
                backgroundColor: Colors.green,
                textColor: Colors.white,
              );

              ref.invalidate(selectedAddressProvider);
              ref.invalidate(selectedSlotProviders);
              widget.onSelected();
              Navigator.pop(context);
              // ignore: unused_result
              ref.refresh(showAddressProviders);
              // ignore: unused_result
              ref.refresh(selectedSlotProviders);
              // ignore: unused_result
              ref.refresh(savedAddressProvider);
              // ignore: unused_result
              ref.refresh(totalDistanceProvider);
              // ignore: unused_result
              ref.refresh(selectedRoadProvider);
              // ignore: unused_result
              ref.refresh(typeProvider);
            } else {
              Fluttertoast.showToast(
                msg: "Failed to select address. Try again.",
                backgroundColor: Colors.red,
                textColor: Colors.white,
              );
            }
          }
        } else {
          Fluttertoast.showToast(
            msg: "Phone number not found. Please log in again.",
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }

        if (mounted) {
          ref.read(loadingAddressProvider.notifier).state = null;
        }
      },
      child: isLoading
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LoadingAnimationWidget.inkDrop(
                  color: Color(0xFF273847),
                  size: 50,
                ),
              ),
            )
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Icon(getIconBasedOnType(widget.address.type),
                          color: const Color(0xFF273847)),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.distance.toStringAsFixed(2)} km',
                        style: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.address.type,
                          style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${widget.address.name}, ${widget.address.road}',
                          style: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontSize: 15,
                          ),
                        ),
                        if (widget.address.landmark.isNotEmpty)
                          Text(
                            'Landmark: ${widget.address.landmark}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        if (widget.address.directions.isNotEmpty)
                          Text(
                            'Directions: ${widget.address.directions}',
                            style: const TextStyle(color: Colors.black54),
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
                            builder: (context) => SelectLocationPage(
                              name: widget.address.name,
                              selectedRoad: widget.address.road,
                              landmark: widget.address.landmark,
                              type: widget.address.type,
                              directions: widget.address.directions,
                            ),
                          ),
                        );
                      } else if (choice == 'Delete') {
                        widget.onDelete();
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
                            Icon(CupertinoIcons.delete,
                                color: Color(0xFF273847)),
                            SizedBox(width: 8),
                            Text('Delete',
                                style: TextStyle(fontFamily: "poppins")),
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

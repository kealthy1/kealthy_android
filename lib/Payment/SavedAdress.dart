import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../Maps/SelectAdress.dart';

final selectedSlotProviders = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('selectedSlot') ?? 'No slot selected';
});
final selectedAddressProviders =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  const String apiUrl =
      "https://api-jfnhkjk4nq-uc.a.run.app/getSelectedAddress";

  try {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');

    if (phoneNumber == null) {
      throw Exception("Phone number not found in SharedPreferences");
    }

    final response = await http.get(
      Uri.parse("$apiUrl?phoneNumber=$phoneNumber"),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final Map<String, dynamic> addressData = jsonResponse['data'];

      return addressData;
    } else {
      throw Exception("Failed to fetch address: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching address: $e");
    return null;
  }
});

class SavedAddress extends ConsumerWidget {
  const SavedAddress({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressAsyncValue = ref.watch(selectedAddressProviders);
    ref.watch(selectedSlotProviders);

    return addressAsyncValue.when(
      data: (savedAddressData) {
        if (savedAddressData == null) {
          return const Center(child: Text('No address saved'));
        }
        final addressType = savedAddressData['type'];
        final name = savedAddressData['Name'];
        final road = savedAddressData['road'];
        final distance = savedAddressData['distance'] != null
            ? '${savedAddressData['distance'].toStringAsFixed(1)} km'
            : 'N/A';
        final directions = savedAddressData['directions'];
        final landmark = savedAddressData['Landmark'];
        IconData getIconForAddressType(String? addressType) {
          if (addressType == "Work") {
            return Icons.work_outline;
          } else if (addressType == "Home") {
            return CupertinoIcons.home;
          } else {
            return Icons.location_on;
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
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
                          ),
                        ).then((_) {});
                      },
                      child: const Text(
                        'Change',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          fontFamily: "poppins",
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      getIconForAddressType(addressType),
                      size: 24,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      addressType ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: "poppins",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '$name, $road',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  distance,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (directions != null && directions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Directions: $directions",
                      style: const TextStyle(
                        fontFamily: "poppins",
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (landmark != null && landmark.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      "Landmark: $landmark",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
      loading: () => Center(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            width: double.infinity,
            height: 150,
            color: Colors.grey[300],
          ),
        ),
      ),
      error: (error, _) => Center(
        child: Text(
          'Error loading address: $error',
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}

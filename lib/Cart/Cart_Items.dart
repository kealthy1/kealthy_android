import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kealthy/Cart/SlotsBooking.dart';
import 'package:kealthy/Payment/Adress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Maps/SelectAdress.dart';
import '../Services/FirestoreCart.dart';
import 'Categories.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Eta.dart';

final checkoutLoadingProvider = StateProvider<bool>((ref) => false);
final selectedETAProviders = StateProvider<DateTime?>((ref) => null);

class ShowCart extends ConsumerWidget {
  const ShowCart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(selectedSlotProvider);

    final cartItems = ref.watch(sharedPreferencesCartProvider);

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final totalPrice =
        cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

    ref.watch(selectedETAProviders);

    return WillPopScope(
      onWillPop: () async {
        // ignore: unused_result
        ref.refresh(selectedSlotProvider);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: const Center(
            child: Text(
              'Cart',
              style: TextStyle(color: Colors.black, fontFamily: "poppins"),
            ),
          ),
          elevation: 0.5,
        ),
        body: cartItems.isEmpty
            ? const Center(
                child: CircleAvatar(
                  radius: 180,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      AssetImage("assets/kealthycart-removebg-preview.png"),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                      child: Column(
                        children: [
                          CategoryContainer(
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                          ),
                          const SizedBox(height: 20),
                          FutureBuilder<Map<String, dynamic>>(
                            future: _fetchETAData(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final etaTime = snapshot.data!['etaTime'];
                                return EstimatedTimeSelector(
                                  isSelected: ref.watch(selectedETAProviders) ==
                                      etaTime,
                                  onSelect: () async {
                                    if (ref.read(selectedETAProviders) ==
                                        etaTime) {
                                      ref
                                          .read(selectedETAProviders.notifier)
                                          .state = null;

                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.remove('selectedSlot');
                                    } else {
                                      ref
                                          .read(selectedETAProviders.notifier)
                                          .state = etaTime;

                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      prefs.setString('selectedSlot',
                                          'Instant Delivery ⚡ ${DateFormat('h:mm a').format(etaTime)}');
                                    }
                                  },
                                );
                              } else if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                );
                              } else {
                                return const Center(
                                  child: Text("Error loading ETA."),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          if (ref.watch(selectedETAProvider) == null)
                            SlotSelectionContainer(),
                        ],
                      ),
                    ),
                  ),
                  _buildCheckoutSection(
                    screenWidth,
                    screenHeight,
                    totalPrice,
                    cartItems,
                    context,
                    ref,
                  ),
                ],
              ),
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchETAData() async {
    final prefs = await SharedPreferences.getInstance();
    final distance = prefs.getDouble('selectedDistance') ?? 0.0;

    const double averageSpeedKmH = 30.0;
    const int cookingTimeMinutes = 15;

    final etaMinutes = (distance / averageSpeedKmH) * 100 + cookingTimeMinutes;
    final currentTime = DateTime.now();
    final etaTime = currentTime.add(Duration(minutes: etaMinutes.toInt()));

    return {
      'etaTime': etaTime,
      'distance': distance,
    };
  }
}

Widget _buildCheckoutSection(
  double screenWidth,
  double screenHeight,
  double totalPrice,
  List<SharedPreferencesCartItem> cartItems,
  BuildContext context,
  WidgetRef ref,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Container(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _buildTotal(cartItems, screenWidth, screenHeight),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SizedBox(
              width: double.infinity,
              child: Consumer(
                builder: (context, ref, child) {
                  final isLoading = ref.watch(checkoutLoadingProvider);

                  return isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF273847),
                              strokeWidth: 4.0,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  ref
                                      .read(checkoutLoadingProvider.notifier)
                                      .state = true;

                                  try {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final selectedSlot =
                                        prefs.getString('selectedSlot');
                                    ref.read(selectedETAProviders);
                                    if (selectedSlot == null) {
                                      Fluttertoast.showToast(
                                        msg: "Please Select a Delivery Option",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.black54,
                                        textColor: Colors.white,
                                        fontSize: 16.0,
                                      );
                                      return;
                                    }

                                    await prefs.remove("cookinginstrcutions");
                                    await prefs.remove("deliveryInstructions");
                                    for (String key
                                        in prefs.getKeys().toList()) {
                                      if (key.startsWith('item_')) {
                                        await prefs.remove(key);
                                      }
                                    }
                                    for (int i = 0; i < cartItems.length; i++) {
                                      SharedPreferencesCartItem item =
                                          cartItems[i];
                                      await prefs.setString(
                                          'item_name_$i', item.name);
                                      await prefs.setInt(
                                          'item_quantity_$i', item.quantity);
                                      await prefs.setDouble(
                                          'item_price_$i', item.price);
                                    }

                                    final savedAddressId =
                                        prefs.getString('selectedRoad');

                                    if (savedAddressId == null ||
                                        savedAddressId.isEmpty) {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => SelectAdress(
                                              totalPrice: totalPrice),
                                        ),
                                      );
                                    } else {
                                      Navigator.pushReplacement(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => AdressPage(
                                            totalPrice: totalPrice,
                                          ),
                                        ),
                                      );
                                    }
                                  } finally {
                                    ref
                                        .read(checkoutLoadingProvider.notifier)
                                        .state = false;
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF273847),
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: FutureBuilder<String?>(
                            future: SharedPreferences.getInstance().then(
                                (prefs) => prefs.getString('selectedRoad')),
                            builder: (context, snapshot) {
                              final savedAddressId = snapshot.data;
                              final buttonText = (savedAddressId == null ||
                                      savedAddressId.isEmpty)
                                  ? 'Select Address'
                                  : 'Proceed to Checkout';

                              return Text(
                                buttonText,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        );
                },
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildTotal(
  List<SharedPreferencesCartItem> cartItems,
  double screenWidth,
  double screenHeight,
) {
  final total = cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: const [
          Text(
            'Total Bill',
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.black,
              fontFamily: "poppins",
            ),
          ),
          SizedBox(width: 5),
          Icon(
            Icons.description_outlined,
            size: 24.0,
            color: Color(0xFF273847),
          ),
        ],
      ),
      Text(
        '₹${total.toStringAsFixed(2)}',
        style: const TextStyle(
          fontSize: 20.0,
          color: Colors.black,
          fontFamily: "poppins",
        ),
      ),
    ],
  );
}

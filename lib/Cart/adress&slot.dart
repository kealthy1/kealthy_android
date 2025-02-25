import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Payment/Addressconfirm.dart';
import '../Payment/Adress.dart';
import '../Payment/Bill.dart';
import '../Payment/SavedAdress.dart';
import '../Riverpod/order_provider.dart';
import 'Cart_Items.dart';
import 'Eta.dart';
import 'SlotsBooking.dart';

class AdressSlot extends ConsumerWidget {
  final double totalprice;
  const AdressSlot({super.key, required this.totalprice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Confirm Address",
          style: GoogleFonts.poppins(
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const SavedAddress(),
                  const SizedBox(height: 20),
                  FutureBuilder<Map<String, dynamic>>(
                    future: _fetchETAData(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final etaTime = snapshot.data!['etaTime'];
                        final currentTime = snapshot.data!['currentTime'];

                        final startBoundary = DateTime(
                          currentTime.year,
                          currentTime.month,
                          currentTime.day,
                          9,
                        );
                        final endBoundary = DateTime(
                          currentTime.year,
                          currentTime.month,
                          currentTime.day,
                          18,
                        );

                        print('Start Boundary: $startBoundary');
                        print('End Boundary: $endBoundary');
                        print('Current Time: $currentTime');
                        bool showETASelector =
                            !(currentTime.isAfter(endBoundary) ||
                                currentTime.isBefore(startBoundary));

                        if (!showETASelector) {
                          return const SizedBox
                              .shrink(); // Hide EstimatedTimeSelector
                        }

                        if (currentTime.isAfter(endBoundary) ||
                            currentTime.isBefore(startBoundary)) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: EstimatedTimeSelector(
                            isSelected:
                                ref.watch(selectedETAProviders) == etaTime,
                            onSelect: () async {
                              if (ref.read(selectedETAProviders) == etaTime) {
                                ref.read(selectedETAProviders.notifier).state =
                                    null;

                                final prefs =
                                    await SharedPreferences.getInstance();
                                prefs.remove('selectedSlot');
                              } else {
                                ref.read(selectedETAProviders.notifier).state =
                                    etaTime;

                                final prefs =
                                    await SharedPreferences.getInstance();
                                final formattedSlot =
                                    'Instant Delivery ⚡ ${DateFormat('h:mm a').format(etaTime)}';

                                print('Saving Slot: $formattedSlot');

                                await prefs.setString(
                                    'selectedSlot', formattedSlot);
                                final selectedSlot =
                                    prefs.getString('selectedSlot');
                                print('Saved Slot: $selectedSlot');
                              }
                            },
                          ),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: LoadingAnimationWidget.inkDrop(
                            color: Color(0xFF273847),
                            size: 30,
                          ),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  ),
                  if (ref.watch(selectedETAProvider) == null &&
                      DateTime.now().hour >= 9 &&
                      DateTime.now().hour < 18)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 5),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey, // Grey color divider
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              "OR",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey, // Grey color divider
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (ref.watch(selectedETAProvider) == null)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: SlotSelectionContainer(),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: Consumer(
                builder: (context, ref, child) {
                  final isLoading = ref.watch(checkoutLoadingProvider);

                  return isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF273847),
                            strokeWidth: 4.0,
                          ),
                        )
                      : ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  // ignore: unused_result
                                  ref.refresh(totalDistanceProvider);
                                  // ignore: unused_result
                                  ref.refresh(orderProvider);
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.remove("RazorpayorderId");
                                  // ignore: unused_result
                                  ref.refresh(savedAddressProvider);
                                  ref
                                      .read(checkoutLoadingProvider.notifier)
                                      .state = true;

                                  try {
                                    // ignore: unused_result
                                    ref.refresh(SlotProvider);
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

                                    Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        builder: (context) => AdressPage(
                                          totalPrice: totalprice,
                                        ),
                                      ),
                                    );
                                  } finally {
                                    ref
                                        .read(checkoutLoadingProvider.notifier)
                                        .state = false;
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF273847),
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Proceed To Checkout",
                            style: GoogleFonts.poppins(
                              fontSize: 18.0,
                              color: Colors.white,
                            ),
                          ),
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchETAData() async {
    final prefs = await SharedPreferences.getInstance();
    final distance = prefs.getDouble('selectedDistance') ?? 0.0;

    const double averageSpeedKmH = 30.0;
    const int cookingTimeMinutes = 15;

    final etaMinutes = (distance / averageSpeedKmH) * 100 + cookingTimeMinutes;

    final currentTime = await NTP.now();
    print('Current NTP Time: $currentTime');

    final etaTime = currentTime.add(Duration(minutes: etaMinutes.toInt()));
    print('Calculated ETA Time: $etaTime');

    return {
      'etaTime': etaTime,
      'distance': distance,
      'currentTime': currentTime,
    };
  }
}

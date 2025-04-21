import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kealthy/Payment/RazorPay.dart';
import 'package:kealthy/Services/Navigation.dart';
import 'package:kealthy/Services/Order_Completed.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../DetailsPage/Ratings/Providers.dart';
import '../MenuPage/MenuPage.dart';
import '../MenuPage/Search_provider.dart';
import '../Orders/ordersTab.dart';
import '../Riverpod/order_provider.dart';
import '../Services/FirestoreCart.dart';
import '../Services/PaymentHandler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'payment_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final paymentMethodProvider = StateProvider<String?>((ref) => null);

final CODloadingProvider = StateProvider<bool>((ref) => false);
final codpageprovider =
    StateNotifierProvider<AddressNotifier, Map<String, dynamic>>(
  (ref) => AddressNotifier(),
);

class AddressNotifier extends StateNotifier<Map<String, dynamic>> {
  AddressNotifier() : super({}) {
    fetchSelectedAddress();
  }

  Future<void> fetchSelectedAddress() async {
    const String apiUrl =
        "https://api-jfnhkjk4nq-uc.a.run.app/getSelectedAddress";

    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phoneNumber');
      final selectedSlot = prefs.getString('selectedSlot');

      final response = await http.get(
        Uri.parse("$apiUrl?phoneNumber=$phoneNumber"),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final addressData = jsonResponse['data'];

        state = {
          'road': addressData['road'] ?? 'N/A',
          'directions': addressData['directions'] ?? 'N/A',
          'Name': addressData['Name'] ?? 'N/A',
          'selectedSlot': selectedSlot,
          'selectedDistance': addressData['distance'] ?? 0.0,
          'latitude': addressData['latitude'] ?? 0.0,
          'longitude': addressData['longitude'] ?? 0.0,
          'Landmark': addressData['Landmark'] ?? 0.0,
          'type': addressData['type'] ?? 'N/A',
        };
      } else {
        print("Error fetching address: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching address: $e");
    }
  }

  void refreshAddress() {
    fetchSelectedAddress();
  }
}

class OrderConfirmation extends ConsumerStatefulWidget {
  final List<SharedPreferencesCartItem> cartItems;

  const OrderConfirmation({
    super.key,
    required this.cartItems,
  });

  @override
  _OrderConfirmationState createState() => _OrderConfirmationState();
}

class _OrderConfirmationState extends ConsumerState<OrderConfirmation> {
  late double totalAmountToPay;

  @override
  void initState() {
    super.initState();

    // Fetch the total amount to pay from PaymentService
    totalAmountToPay = PaymentService().totalToPay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderProvider.notifier).createOrder(totalAmountToPay);
    });
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final selectedPaymentMethod = ref.watch(paymentMethodProvider);
    final isLoading = ref.watch(CODloadingProvider);
    ref.watch(codpageprovider);
    double totalAmountToPay = PaymentService().totalToPay;

    return WillPopScope(
      onWillPop: () async {
        // ignore: unused_result
        ref.refresh(rateProductProvider);
        // ignore: unused_result
        // ignore: unused_result
        ref.refresh(CODloadingProvider);
        ref.read(CODloadingProvider.notifier).state = false;
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          title: Text(
            'Select Payment Method',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w300,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPaymentOption(context, ref, Icons.currency_rupee_sharp,
                    'Cash on Delivery', selectedPaymentMethod),
                const SizedBox(height: 10),
                _buildPaymentOption(context, ref, Icons.payment,
                    'Online Payment', selectedPaymentMethod),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.zero,
                bottomRight: Radius.zero,
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
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Total Bill',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(Icons.description_outlined,
                                size: 24.0, color: Color(0xFF273847))
                          ],
                        ),
                        Text(
                          '₹${totalAmountToPay.toStringAsFixed(0)}/-',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(18.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF273847),
                              strokeWidth: 4.0,
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    // ignore: unused_result
                                    ref.refresh(rateProductProvider);

                                    // ignore: unused_result
                                    ref.refresh(searchQueryProvider);
                                    ref
                                            .read(refreshTriggerProvider.notifier)
                                            .state =
                                        !ref.read(refreshTriggerProvider);
                                    if (selectedPaymentMethod == null) {
                                      Fluttertoast.showToast(
                                        msg: "Please select a payment method.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0,
                                      );
                                      return;
                                    }
                                    ref
                                        .read(CODloadingProvider.notifier)
                                        .state = true;

                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final double etaMinutes =
                                        prefs.getDouble('selectedDistance') ??
                                            0;
                                    final currentTime = DateTime.now();
                                    currentTime.add(
                                        Duration(minutes: etaMinutes.toInt()));

                                    ref
                                        .read(CODloadingProvider.notifier)
                                        .state = true;
                                    PaymentHandler paymentHandler =
                                        PaymentHandler();

                                    try {
                                      if (selectedPaymentMethod ==
                                          'Online Payment') {
                                        Navigator.pushReplacement(
                                            context,
                                            SeamlessRevealRoute(
                                              page: RazorPay(
                                                totalAmountToPay:
                                                    totalAmountToPay,
                                              ),
                                            ));
                                      } else if (selectedPaymentMethod ==
                                          'Cash on Delivery') {
                                        await paymentHandler
                                            .saveOrderDetails(ref);
                                        await paymentHandler.clearCart(ref);
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        prefs.setString('Rate',
                                            'Your feedback message here');
                                        prefs.setInt(
                                            'RateTimestamp',
                                            DateTime.now()
                                                .millisecondsSinceEpoch);

                                        ref
                                            .read(CODloadingProvider.notifier)
                                            .state = false;
                                        ReusableCountdownDialog(
                                          context: context,
                                          ref: ref,
                                          message: "Order Placed Successfully",
                                          imagePath:
                                              "assets/Animation - 1731992471934.json",
                                          onRedirect: () {
                                            Navigator.pushReplacement(
                                              context,
                                              CupertinoModalPopupRoute(
                                                builder: (context) =>
                                                    const OrdersTabScreen(),
                                              ),
                                            );
                                          },
                                          button: 'My Orders',
                                          color: Colors.green,
                                          buttonTextColor: Colors.white,
                                          buttonColor: Colors.green,
                                        ).show();
                                      }
                                    } catch (e) {
                                      ref
                                          .read(CODloadingProvider.notifier)
                                          .state = false;
                                      Fluttertoast.showToast(
                                        msg: "Error occurred: ${e.toString()}",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF273847),
                              minimumSize: const Size(50, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              selectedPaymentMethod == 'Online Payment'
                                  ? 'Make a Payment'
                                  : 'Place Order',
                              style: GoogleFonts.poppins(color: Colors.white),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    String value,
    String? selectedPaymentMethod,
  ) {
    bool isSelected = selectedPaymentMethod == value;

    return GestureDetector(
      onTap: () {
        ref.read(paymentMethodProvider.notifier).state = value;
        _savePaymentMethod(value);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 230, 230, 236)
              : Colors.white,
          border: Border.all(
              color: isSelected ? Color(0xFF273847) : Colors.grey.shade400,
              width: 1.5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Radio<String>(
                value: value,
                groupValue: selectedPaymentMethod,
                onChanged: (String? newValue) {
                  ref.read(paymentMethodProvider.notifier).state = newValue;
                  _savePaymentMethod(newValue!);
                },
                activeColor: Color(0xFF273847)),
            Icon(icon,
                color: isSelected ? Color(0xFF273847) : Colors.grey.shade500),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: isSelected ? Colors.black : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePaymentMethod(String method) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedPaymentMethod', method);
    print("Selected Payment Method: $method");
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;

  const ResponsiveContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black26),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: child,
    );
  }
}

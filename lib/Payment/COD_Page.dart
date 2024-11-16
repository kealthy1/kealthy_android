import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kealthy/Maps/SelectAdress.dart';
import 'package:kealthy/Payment/RazorPay.dart';
import 'package:kealthy/Services/Order_Completed.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Cart/AvailableslotGenerator.dart';
import '../Orders/ordersTab.dart';
import '../Services/FirestoreCart.dart';
import '../Services/PaymentHandler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'payment_service.dart';

final paymentMethodProvider = StateProvider<String?>((ref) => null);

final CODloadingProvider = StateProvider<bool>((ref) => false);
final savedAddressProvider =
    StateNotifierProvider<AddressNotifier, Map<String, dynamic>>(
        (ref) => AddressNotifier());

class AddressNotifier extends StateNotifier<Map<String, dynamic>> {
  AddressNotifier() : super({});

  Future<void> loadSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final road = prefs.getString('selectedRoad');
    final directions = prefs.getString('selectedDirections');
    final name = prefs.getString('Name');
    final slot = prefs.getString('selectedSlot');
    final distance = prefs.getDouble('selectedDistance');

    state = {
      'road': road,
      'directions': directions,
      'Name': name,
      'selectedSlot': slot,
      'selectedDistance': distance,
    };
  }

  Future<void> updateAddress(
      String road, String directions, String name, String slot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedRoad', road);
    await prefs.setString('selectedDirections', directions);
    await prefs.setString('Name', name);
    await prefs.setString('selectedSlot', slot);
    await loadSavedAddress();
  }
}

class OrderConfirmation extends ConsumerWidget {
  final List<SharedPreferencesCartItem> cartItems;

  const OrderConfirmation({
    super.key,
    required this.cartItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPaymentMethod = ref.watch(paymentMethodProvider);
    final isLoading = ref.watch(CODloadingProvider);
    final savedAddressData = ref.watch(savedAddressProvider);
    double totalAmountToPay = PaymentService().totalToPay;

    ref.read(savedAddressProvider.notifier).loadSavedAddress();

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // ignore: unused_result
        ref.refresh(CODloadingProvider);
        ref.read(CODloadingProvider.notifier).state = false;
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Select Payment Method',
            style: TextStyle(
              fontFamily: "poppins",
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Delivery address',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          CupertinoModalPopupRoute(
                            builder: (context) =>
                                const SelectAdress(totalPrice: 0),
                          ),
                        ).then((_) => ref
                            .read(savedAddressProvider.notifier)
                            .loadSavedAddress());
                      },
                      icon: const Icon(
                        Icons.mode_edit_outlined,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ResponsiveContainer(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 8),
                            const Icon(Icons.location_on,
                                size: 30, color: Colors.black),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    '${savedAddressData['Name'] ?? 'N/A'}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${savedAddressData['road'] ?? 'N/A'}',
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Delivery Slot: ${savedAddressData['selectedSlot'] ?? 'N/A'}',
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(savedAddressData['selectedDistance'] != null ? savedAddressData['selectedDistance'].toStringAsFixed(2) : 'N/A')} km',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
                          const Text(
                            'Total Bill',
                            style: TextStyle(
                              fontFamily: "poppins",
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(Icons.description_outlined,
                              size: 24.0, color: Colors.green)
                        ],
                      ),
                      Text(
                        '₹${totalAmountToPay.toStringAsFixed(0)}/-',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                isLoading
                    ? const Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.green,
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
                                  ref.read(CODloadingProvider.notifier).state =
                                      true;

                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  final String selectedSlot =
                                      prefs.getString('selectedSlot') ?? '';

                                  final currentTime = DateTime.now();
                                  final generator = AvailableSlotsGenerator(
                                    slotDurationMinutes: 30,
                                    minGapMinutes: 30,
                                    startTime: DateTime(
                                      currentTime.year,
                                      currentTime.month,
                                      currentTime.day,
                                      7,
                                      0,
                                    ),
                                    endTime: DateTime(
                                      currentTime.year,
                                      currentTime.month,
                                      currentTime.day + 1,
                                      0,
                                      0,
                                    ),
                                  );
                                  final availableSlots =
                                      generator.getAvailableSlots(currentTime);
                                  if (!availableSlots.any((slot) =>
                                      DateFormat('h:mm a').format(slot) ==
                                      selectedSlot)) {
                                    ref
                                        .read(CODloadingProvider.notifier)
                                        .state = false;

                                    ref
                                        .read(CODloadingProvider.notifier)
                                        .state = false;

                                    Fluttertoast.showToast(
                                      msg:
                                          "The chosen time slot is already Closed",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                    return;
                                  }

                                  ref.read(CODloadingProvider.notifier).state =
                                      true;
                                  PaymentHandler paymentHandler =
                                      PaymentHandler();

                                  try {
                                    if (selectedPaymentMethod ==
                                        'Online Payment') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RazorPay(
                                            totalAmountToPay: totalAmountToPay,
                                            cartItems: cartItems,
                                          ),
                                        ),
                                      );
                                    } else if (selectedPaymentMethod ==
                                        'Cash on Delivery') {
                                      await paymentHandler.saveOrderDetails();
                                      await paymentHandler.clearCart(ref);
                                      ref
                                          .read(CODloadingProvider.notifier)
                                          .state = false;
                                      ReusableCountdownDialog(
                                        context: context,
                                        ref: ref,
                                        message:
                                            "Payment Successful! Redirecting to My Orders",
                                        imagePath:
                                            "assets/Animation - 1731992471934.json",
                                        countdownDuration: 10,
                                        onRedirect: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const OrdersTabScreen(),
                                            ),
                                          );
                                        },
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
                            backgroundColor: Colors.green,
                            minimumSize: const Size(50, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Place Order',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
              ],
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
              ? const Color.fromARGB(255, 169, 211, 171)
              : Colors.white,
          border: Border.all(
              color: isSelected ? Colors.green : Colors.grey.shade400,
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
              activeColor: Colors.green,
            ),
            Icon(icon, color: isSelected ? Colors.green : Colors.grey.shade500),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "poppins",
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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

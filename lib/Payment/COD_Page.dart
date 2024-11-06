import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Maps/SelectAdress.dart';
import 'package:kealthy/Payment/RazorPay.dart';
import 'package:kealthy/Services/Order_Completed.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Services/FirestoreCart.dart';
import '../Services/PaymentHandler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'payment_service.dart';

final paymentMethodProvider = StateProvider<String?>((ref) => null);

final loadingProvider = StateProvider<bool>((ref) => false);
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
  final List<CartItem> cartItems;

  const OrderConfirmation({
    super.key,
    required this.cartItems,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPaymentMethod = ref.watch(paymentMethodProvider);
    final isLoading = ref.watch(loadingProvider);
    final savedAddressData = ref.watch(savedAddressProvider);
    double totalAmountToPay = PaymentService().totalToPay;

    ref.read(savedAddressProvider.notifier).loadSavedAddress();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 1,
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
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              const SizedBox(height: 16),
              _buildPaymentOption(context, ref, Icons.currency_rupee_sharp,
                  'COD', 'Cash on Delivery (COD)', selectedPaymentMethod),
              _buildPaymentOption(context, ref, Icons.payment, 'UPI',
                  'UPI or CARD', selectedPaymentMethod),
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
                                Text('${savedAddressData['road'] ?? 'N/A'}',
                                    overflow: TextOverflow.ellipsis),
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
              if (isLoading)
                Center(
                  child: LoadingAnimationWidget.discreteCircle(
                    color: Colors.white,
                    size: 100,
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Total ₹${totalAmountToPay.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (totalAmountToPay == 0) {
                    Fluttertoast.showToast(
                      msg: "Total amount cannot be zero!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                    return;
                  }

                  ref.read(loadingProvider.notifier).state = true;
                  PaymentHandler paymentHandler = PaymentHandler();

                  try {
                    if (selectedPaymentMethod == 'UPI') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RazorPay(
                            totalAmountToPay: totalAmountToPay,
                            cartItems: cartItems,
                          ),
                        ),
                      );
                    } else if (selectedPaymentMethod == 'COD') {
                      await paymentHandler.saveOrderDetails();
                      await paymentHandler.clearCart(ref);
                      ref.read(loadingProvider.notifier).state = false;

                      Navigator.pushAndRemoveUntil(
                        context,
                        CupertinoModalPopupRoute(
                          builder: (context) => const Ordersucces(),
                        ),
                        (Route<dynamic> route) => route.isFirst,
                      );
                    }
                  } catch (e) {
                    ref.read(loadingProvider.notifier).state = false;
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
                icon: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
                label: const Text(
                  'Place Order',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(50, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    String value,
    String subtitle,
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
          color: isSelected ? Colors.black : Colors.white,
          border: Border.all(color: Colors.black, width: 1.5),
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
              activeColor: Colors.white,
            ),
            Icon(icon, color: isSelected ? Colors.white : Colors.black),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey,
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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Cart/SlotsBooking.dart';
import 'package:kealthy/Payment/Adress.dart';
import 'package:kealthy/Payment/COD_Page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Maps/SelectAdress.dart';
import '../Services/FirestoreCart.dart';
import 'Category/Categories.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ShowCart extends ConsumerWidget {
  const ShowCart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(selectedSlotProvider);
    ref.read(addCartProvider.notifier).fetchCartItems();

    final cartItems = ref.watch(addCartProvider);

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    final totalPrice =
        cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text('Cart'),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: CircleAvatar(
              radius: 180,
              backgroundColor: Colors.white,
              backgroundImage:
                  AssetImage("assets/kealthycart-removebg-preview.png"),
            ))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Column(
                      children: [
                        if (cartItems.any((item) => item.category == 'Snacks'))
                          CategoryContainer(
                            category: 'Snacks',
                            items: cartItems
                                .where((item) => item.category == 'Snacks')
                                .toList(),
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                          ),
                        if (cartItems.any((item) => item.category == 'Drinks'))
                          CategoryContainer(
                            category: 'Drinks',
                            items: cartItems
                                .where((item) => item.category == 'Drinks')
                                .toList(),
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                          ),
                        if (cartItems.any((item) => item.category == 'Food'))
                          CategoryContainer(
                            category: 'Food',
                            items: cartItems
                                .where((item) => item.category == 'Food')
                                .toList(),
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                          ),
                        const SlotSelectionContainer()
                      ],
                    ),
                  ),
                ),
                _buildCheckoutSection(screenWidth, screenHeight, totalPrice,
                    cartItems, context, ref)
              ],
            ),
    );
  }

  Widget _buildCheckoutSection(
      double screenWidth,
      double screenHeight,
      double totalPrice,
      List<CartItem> cartItems,
      BuildContext context,
      WidgetRef ref) {
    final addressesAsyncValue = ref.watch(addressesProvider);

    return Container(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '₹${totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Divider(height: screenHeight * 0.02),
                Column(
                  children: [
                    if (cartItems.any((item) => item.category == 'Snacks')) ...[
                      _buildCategoryTotal(
                          'Snacks', cartItems, screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.01),
                    ],
                    if (cartItems.any((item) => item.category == 'Drinks')) ...[
                      _buildCategoryTotal(
                          'Drinks', cartItems, screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.01),
                    ],
                    if (cartItems.any((item) => item.category == 'Food'))
                      _buildCategoryTotal(
                          'Food', cartItems, screenWidth, screenHeight),
                  ],
                )
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.03),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // ignore: unused_result
                  ref.refresh(paymentMethodProvider);
                  final selectedSlot = ref.watch(selectedSlotProvider);

                  if (selectedSlot == null) {
                    Fluttertoast.showToast(
                      msg: "Please Select Slot",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.transparent,
                      textColor: Colors.red,
                      fontSize: 16.0,
                    );
                    return;
                  }
                  final currentTime = DateTime.now();
                  if (selectedSlot.difference(currentTime).inMinutes < 45) {
                    Fluttertoast.showToast(
                      msg: "Selected slot is Not available",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.transparent,
                      textColor: Colors.red,
                      fontSize: 16.0,
                    );
                    return;
                  }

                  final prefs = await SharedPreferences.getInstance();
                  Set<String> keys = prefs.getKeys();
                  for (String key in keys) {
                    if (key.startsWith('item_name_') ||
                        key.startsWith('item_quantity_') ||
                        key.startsWith('item_price_')) {
                      await prefs.remove(key);
                    }
                  }

                  for (int i = 0; i < cartItems.length; i++) {
                    CartItem item = cartItems[i];
                    await prefs.setString('item_name_$i', item.name);
                    await prefs.setInt('item_quantity_$i', item.quantity);
                    await prefs.setDouble('item_price_$i', item.price);
                  }

                  print('Saved cart items to SharedPreferences');

                  for (int i = 0; i < cartItems.length; i++) {
                    String? name = prefs.getString('item_name_$i');
                    int? quantity = prefs.getInt('item_quantity_$i');
                    double? price = prefs.getDouble('item_price_$i');
                    print(
                        'Item $i - Name: $name, Quantity: $quantity, Price: $price');
                  }

                  final savedAddressId = prefs.getString('selectedAddressId');

                  if (savedAddressId == null || savedAddressId.isEmpty) {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) =>
                            SelectAdress(totalPrice: totalPrice),
                      ),
                    );
                  } else {
                    addressesAsyncValue.when(
                      data: (addresses) {
                        if (addresses.isEmpty) {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) =>
                                  SelectAdress(totalPrice: totalPrice),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => AdressPage(
                                totalPrice: totalPrice,
                                totalAmountToPay: null,
                                time: '',
                              ),
                            ),
                          );
                        }
                      },
                      loading: () {
                        showDialog(
                          context: context,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      error: (error, stack) {
                        print('Error fetching addresses: $error');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to fetch addresses'),
                          ),
                        );
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.height * 0.02,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTotal(String category, List<CartItem> cartItems,
      double screenWidth, double screenHeight) {
    final categoryItems =
        cartItems.where((item) => item.category == category).toList();
    final categoryTotal =
        categoryItems.fold(0.0, (sum, item) => sum + item.totalPrice);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$category Total',
          style: const TextStyle(fontSize: 16.0, color: Colors.grey),
        ),
        Text(
          '₹${categoryTotal.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16.0, color: Colors.black),
        ),
      ],
    );
  }
}

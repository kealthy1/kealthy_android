// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../Maps/SelectAdress.dart';
// import '../../Payment/Adress.dart';
// import '../../Payment/COD_Page.dart';
// import '../../Services/AlertHelper.dart';
// import '../../Services/FirestoreCart.dart';
// import '../SlotsBooking.dart';

// class ProceedCheckoutButton extends StatelessWidget {
//   final BuildContext context;
//   final WidgetRef ref;
//   final List<CartItem> cartItems;
//   final double totalPrice;
//   final double screenHeight;
//   final double screenWidth;
//   final AsyncValue<List<Address>> addressesAsyncValue; // Added addressesAsyncValue
//   final Widget proceedAnywayPage; // Added proceedAnywayPage to pass to AlertHelper

//   const ProceedCheckoutButton({
//     Key? key,
//     required this.context,
//     required this.ref,
//     required this.cartItems,
//     required this.totalPrice,
//     required this.screenHeight,
//     required this.screenWidth,
//     required this.addressesAsyncValue, // Initialize this in the constructor
//     required this.proceedAnywayPage,   // Initialize proceedAnywayPage
//   }) : super(key: key);

//   Future<void> _onProceed() async {
//     ref.refresh(paymentMethodProvider);
//     final selectedSlot = ref.watch(selectedSlotProvider);

//     if (selectedSlot == null) {
//       Fluttertoast.showToast(
//         msg: "Please Select Slot",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.CENTER,
//         backgroundColor: Colors.transparent,
//         textColor: Colors.red,
//         fontSize: 16.0,
//       );
//       return;
//     }

//     final currentTime = DateTime.now();
//     if (selectedSlot.difference(currentTime).inMinutes < 45) {
//       Fluttertoast.showToast(
//         msg: "Selected slot is Not available",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.CENTER,
//         backgroundColor: Colors.transparent,
//         textColor: Colors.red,
//         fontSize: 16.0,
//       );
//       return;
//     }

//     final prefs = await SharedPreferences.getInstance();
//     final savedAddress = prefs.getString('selectedRoad') ?? '';
//     final savedAddressId = prefs.getString('selectedAddressId');
//     const List<String> serviceablePincodes = ['682030', '682037', '683565'];
    
//     bool isServiceable = serviceablePincodes
//         .any((pincode) => savedAddress.contains(pincode));
    
//     bool hasFoodItems = cartItems.any((item) => item.category == 'Food');
//     bool hasOnlySnacks = cartItems.every((item) => item.category == 'Snacks');

//     if (savedAddressId == null || savedAddressId.isEmpty) {
//       Navigator.push(
//         context,
//         CupertinoPageRoute(
//           builder: (context) => SelectAdress(totalPrice: totalPrice),
//         ),
//       );
//       return;
//     }

//     if (!isServiceable && hasFoodItems) {
//       Fluttertoast.showToast(
//         msg: "Food can't be delivered by courier",
//         toastLength: Toast.LENGTH_SHORT,
//         gravity: ToastGravity.CENTER,
//         backgroundColor: Colors.transparent,
//         textColor: Colors.red,
//         fontSize: 16.0,
//       );
//       return;
//     }

//     if (!isServiceable && hasOnlySnacks) {
//       AlertHelper.showProceedAlert(
//         context: context,
//         title: "Long Distance Order",
//         description:
//             "Your order is coming from a long distance.\nAdditional delivery fees may apply.",
//         getItNowPage: SelectAdress(totalPrice: totalPrice),
//         proceedAnywayPage: proceedAnywayPage, // Pass the proceedAnywayPage here
//         onProceedAnyway: () {
//           if (hasFoodItems) {
//             Fluttertoast.showToast(
//               msg: "Food can't be delivered by courier",
//               toastLength: Toast.LENGTH_SHORT,
//               gravity: ToastGravity.CENTER,
//               backgroundColor: Colors.transparent,
//               textColor: Colors.red,
//               fontSize: 16.0,
//             );
//           } else {
//             Navigator.push(
//               context,
//               CupertinoPageRoute(
//                 builder: (context) => AdressPage(
//                   totalPrice: totalPrice,
//                   totalAmountToPay: null,
//                   time: '',
//                 ),
//               ),
//             );
//           }
//         },
//       );
//       return;
//     }

//     await _saveCartItemsToPrefs();

//     addressesAsyncValue.when(
//       data: (addresses) {
//         if (addresses.isEmpty) {
//           Navigator.push(
//             context,
//             CupertinoPageRoute(
//               builder: (context) => SelectAdress(totalPrice: totalPrice),
//             ),
//           );
//         } else {
//           Navigator.push(
//             context,
//             CupertinoPageRoute(
//               builder: (context) => AdressPage(
//                 totalPrice: totalPrice,
//                 totalAmountToPay: null,
//                 time: '',
//               ),
//             ),
//           );
//         }
//       },
//       loading: () {
//         showDialog(
//           context: context,
//           builder: (context) => const Center(
//             child: CircularProgressIndicator(),
//           ),
//         );
//       },
//       error: (error, stack) {
//         print('Error fetching addresses: $error');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to fetch addresses')),
//         );
//       },
//     );
//   }

//   Future<void> _saveCartItemsToPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     final keys = prefs.getKeys();
//     for (String key in keys) {
//       if (key.startsWith('item_name_') ||
//           key.startsWith('item_quantity_') ||
//           key.startsWith('item_price_')) {
//         await prefs.remove(key);
//       }
//     }

//     for (int i = 0; i < cartItems.length; i++) {
//       CartItem item = cartItems[i];
//       await prefs.setString('item_name_$i', item.name);
//       await prefs.setInt('item_quantity_$i', item.quantity);
//       await prefs.setDouble('item_price_$i', item.price);
//     }

//     print('Cart items saved to SharedPreferences');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
//       child: SizedBox(
//         width: double.infinity,
//         child: ElevatedButton(
//           onPressed: _onProceed,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green,
//             padding: EdgeInsets.symmetric(
//               vertical: screenHeight * 0.02,
//             ),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           child: const Text(
//             'Proceed to Checkout',
//             style: TextStyle(
//               fontSize: 18.0,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

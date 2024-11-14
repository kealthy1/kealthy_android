import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'FirestoreCart.dart';

class PaymentHandler {
  final FirebaseDatabase database1 = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://kealthy-90c55-dd236.firebaseio.com/',
  );

  String generateOrderId() {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int randomNum = Random().nextInt(900000) + 100000;
    return '$randomNum$timestamp';
  }

  Future<void> saveOrderDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String selectedType = prefs.getString('selectedType') ?? '';
      double selectedDistance = prefs.getDouble('selectedDistance') ?? 0.0;
      String Name = prefs.getString('Name') ?? '';

      String deliveryInstructions =
          (prefs.getStringList('deliveryInstructions') ?? []).join(', ');

      String selectedDirections = prefs.getString('selectedDirections') ?? '';
      double selectedLatitude = prefs.getDouble('selectedLatitude') ?? 0.0;
      double selectedLongitude = prefs.getDouble('selectedLongitude') ?? 0.0;
      String selectedRoad = prefs.getString('selectedRoad') ?? '';
      String Landmark = prefs.getString('landmark') ?? '';
      String phoneNumber = prefs.getString('phoneNumber') ?? '';
      String selectedSlot = prefs.getString('selectedSlot') ?? '';
      double totalAmountToPay = prefs.getDouble('totalToPay') ?? 0;
      String paymentmethod = prefs.getString('selectedPaymentMethod') ?? '';

      if (selectedType.isEmpty || Name.isEmpty || selectedRoad.isEmpty) {
        print("Missing required fields!");
        return;
      }

      String orderId = generateOrderId();

      DatabaseReference ref = database1.ref().child('orders').child(orderId);

      List<Map<String, dynamic>> orderItems = [];
      int index = 0;
      while (true) {
        String? itemName = prefs.getString('item_name_$index');
        int? itemQuantity = prefs.getInt('item_quantity_$index');
        double? itemPrice = prefs.getDouble('item_price_$index');

        if (itemName == null || itemQuantity == null || itemPrice == null) {
          break;
        }

        orderItems.add({
          'item_name': itemName,
          'item_quantity': itemQuantity,
          'item_price': itemPrice,
        });

        index++;
      }

      await ref.set({
        'orderId': orderId,
        'selectedType': selectedType,
        'selectedDistance': selectedDistance,
        'Name': Name,
        'deliveryInstructions': deliveryInstructions,
        'selectedDirections': selectedDirections,
        'selectedLatitude': selectedLatitude,
        'selectedLongitude': selectedLongitude,
        'selectedRoad': selectedRoad,
        'phoneNumber': phoneNumber,
        'totalAmountToPay': totalAmountToPay,
        'selectedSlot': selectedSlot,
        'status': 'Order Placed',
        'assignedto': 'NotAssigned',
        'createdAt': DateTime.now().toIso8601String(),
        'orderItems': orderItems,
        'landmark': Landmark,
        'distance': selectedDistance.toStringAsFixed(2),
        'paymentmethod': paymentmethod,
      });

      print("Order details saved successfully with orderId: $orderId");
    } catch (e) {
      print("Failed to save order details: $e");
    }
  }

  Future<void> clearCart(WidgetRef ref) async {
    final cartItems = ref.read(sharedPreferencesCartProvider);
    if (cartItems.isNotEmpty) {
      ref.read(sharedPreferencesCartProvider.notifier).clearCart();
      print("All items have been removed from the cart.");
    } else {
      print("The cart is already empty.");
    }
  }
}

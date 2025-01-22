import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Payment/COD_Page.dart';
import 'FirestoreCart.dart';
import 'sharedpreferncesname.dart';

class PaymentHandler {
  final FirebaseDatabase database1 = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://kealthy-90c55-dd236.firebaseio.com/',
  );
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<String> generateOrderId() async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int randomNum = Random().nextInt(900000) + 100000;
    String orderId = '$randomNum$timestamp';

    await saveOrderId(orderId);

    return orderId;
  }

  Future<void> saveOrderId(String orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('order_id', orderId);
    print("Order ID saved to SharedPreferences: $orderId");
  }

  Future<void> saveOrderDetails(WidgetRef ref) async {
    try {
      final savedAddress = ref.read(codpageprovider);

      double selectedDistance = savedAddress['selectedDistance'] ?? 0.0;
      String name = savedAddress['Name'] ?? '';

      String selectedDirections = savedAddress['directions'] ?? '';
      double selectedLatitude = savedAddress['latitude'] ?? 0.0;
      double selectedLongitude = savedAddress['longitude'] ?? 0.0;
      String selectedRoad = savedAddress['road'] ?? '';
      String landmark = savedAddress['Landmark'] ?? '';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('notification_shown');
      String phoneNumber = prefs.getString('phoneNumber') ?? '';
      String selectedSlot = prefs.getString('selectedSlot') ?? '';
      double totalAmountToPay = prefs.getDouble('totalToPay') ?? 0.0;
      String paymentMethod = prefs.getString('selectedPaymentMethod') ?? '';
      String fcmToken = prefs.getString('fcm_token') ?? '';
      String cookingInstructions = prefs.getString('cookinginstrcutions') ?? '';
      Object deliveryInstructions =
          prefs.getString('deliveryInstructions') ?? '';

      String orderId = await generateOrderId();
      DatabaseReference refDB = database1.ref().child('orders').child(orderId);

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
        // unawaited(reduceItemStock(itemName, itemQuantity));
        index++;
      }
      unawaited(SharedPreferencesHelper.saveOrderItems(orderItems));
      await refDB.set({
        'orderId': orderId,
        'selectedDistance': selectedDistance,
        'Name': name,
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
        'DA': 'NotAssigned',
        'DAMOBILE': 'NotAssigned',
        'createdAt': DateTime.now().toIso8601String(),
        'orderItems': orderItems,
        'landmark': landmark,
        'distance': selectedDistance.toStringAsFixed(2),
        'paymentmethod': paymentMethod,
        'fcm_token': fcmToken,
        'cookinginstrcutions': cookingInstructions,
      });

      print("Order details saved successfully with orderId: $orderId");
    } catch (e) {
      print("Failed to save order details: $e");
    }
  }

  // Future<void> reduceItemStock(String itemName, int quantityOrdered) async {
  //   try {
  //     QuerySnapshot querySnapshot = await firestore
  //         .collection('Products')
  //         .where('Name', isEqualTo: itemName)
  //         .get();

  //     if (querySnapshot.docs.isNotEmpty) {
  //       DocumentSnapshot doc = querySnapshot.docs.first;

  //       double currentSoh = (doc['SOH'] as num).toDouble();

  //       double newSoh = currentSoh - quantityOrdered;

  //       if (newSoh < 0) {
  //         print("Stock for $itemName is insufficient. Cannot reduce below 0.");
  //         return;
  //       }

  //       await doc.reference.update({'SOH': newSoh});
  //       print("Stock for $itemName reduced successfully to $newSoh.");
  //     } else {
  //       print("Item $itemName not found in Firestore.");
  //     }
  //   } catch (e) {
  //     print("Failed to update stock for $itemName: $e");
  //   }
  // }

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

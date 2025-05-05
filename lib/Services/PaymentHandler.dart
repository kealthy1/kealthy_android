import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Payment/COD_Page.dart';
import 'FirestoreCart.dart';
import '../Notifications/Notificationsave_to_firestore.dart';
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
      double deliveryFee = prefs.getDouble("deliveryFee") ?? 0.0;
      double instantDeliveryCharge =
          prefs.getDouble("instantDeliveryCharge") ?? 0.0;
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
        String? EAN = prefs.getString('item_EAN_$index');

        if (itemQuantity == null) {
          break;
        }

        orderItems.add({
          'item_name': itemName,
          'item_quantity': itemQuantity,
          'item_price': itemPrice,
          "item_EAN": EAN,
        });
        // unawaited(reduceItemStock(EAN!, itemQuantity));
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
        "deliveryFee": deliveryFee + instantDeliveryCharge,
      });
      List<String> productNames =
          orderItems.map((item) => item['item_name'].toString()).toList();

      List<String> randomTitles = [
        "Rate Your Experience!",
        "How Did We Do?",
        "Your Feedback Matters!",
        "Share Your Thoughts!",
        "Give Us a Star!",
        "Love It? Let Us Know!"
      ];

      List<String> randomBodies = [
        "Tell us what you think about your recent purchase by leaving a star rating.",
        "We'd love to hear your thoughts! Rate your recent purchase now.",
        "Help us improve by sharing your feedback on your latest order!",
        "How was your experience? Give us a quick star rating!",
        "Your opinion counts! Leave a review for your recent order.",
        "Loved it? Hated it? Rate your order and let us know!"
      ];

      final random = Random();
      String randomTitle = randomTitles[random.nextInt(randomTitles.length)];
      String randomBody = randomBodies[random.nextInt(randomBodies.length)];

      NotificationData notification = NotificationData(
        title: randomTitle,
        body: randomBody,
        payload: "review_screen",
        fcm_token: fcmToken,
        imageUrl:
            "https://firebasestorage.googleapis.com/v0/b/kealthy-90c55.appspot.com/o/feedback%2Fa-minimalistic-design-for-a-healthy-food_38vJ50AsTdOxv4Z5Wt32LA_8cxtpxqbSYaVP_s8Ygh7bQ.jpeg?alt=media&token=03691f32-6713-44cb-8cb4-edf94ebf645a",
        productNames: productNames,
        timestamp: Timestamp.now(),
        orderId: orderId,
        phoneNumber: phoneNumber,
      );

      await FirestoreService.instance.addNotification(notification);
    } catch (e) {
      print("Failed to save order details: $e");
    }
  }

  Future<void> reduceItemStock(String EAN, int quantityOrdered) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Products')
          .where('EAN', isEqualTo: EAN)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;

        double currentSoh = (doc['SOH'] as num).toDouble();

        double newSoh = currentSoh - quantityOrdered;

        if (newSoh < 0) {
          print("Stock for $EAN is insufficient. Cannot reduce below 0.");
          return;
        }

        await doc.reference.update({'SOH': newSoh});
        print("Stock for $EAN reduced successfully to $newSoh.");
      } else {
        print("Item $EAN not found in Firestore.");
      }
    } catch (e) {
      print("Failed to update stock for $EAN: $e");
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

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Alert.dart';

class OrderStatusNotifier extends StateNotifier<AsyncValue<bool>> {
  OrderStatusNotifier() : super(const AsyncValue.loading()) {
    _listenToOrderStatus();
  }

  DatabaseReference? _orderRef;

  Future<void> _listenToOrderStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? orderId = prefs.getString('order_id');

      if (orderId == null || orderId.isEmpty) {
        state = const AsyncValue.data(true);
        return;
      }

      final database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL: 'https://kealthy-90c55-dd236.firebaseio.com/',
      );
      _orderRef = database.ref().child('orders').child(orderId);

      _orderRef!.onValue.listen((event) async {
        final snapshot = event.snapshot;
        if (!snapshot.exists ||
            snapshot.child('status').value == 'Order Delivered') {
          final notificationShown =
              prefs.getBool('notification_shown') ?? false;

          if (!notificationShown) {
            ReviewService.instance.showNotification(
              title: "Love It or Leave It?",
              body:
                  "Tell us what you think about your recent purchase by leaving a star rating.",
              payload: "review_screen",
              imageUrl:
                  "https://firebasestorage.googleapis.com/v0/b/kealthy-90c55.appspot.com/o/feedback%2Fa-minimalistic-design-for-a-healthy-food_38vJ50AsTdOxv4Z5Wt32LA_8cxtpxqbSYaVP_s8Ygh7bQ.jpeg?alt=media&token=03691f32-6713-44cb-8cb4-edf94ebf645a",
            );

            await prefs.setBool('notification_shown', true);
          }
          state = const AsyncValue.data(true);
        } else {
          state = const AsyncValue.data(false);
        }
      });
    } catch (e) {
      print("Error listening to order status: $e");
    }
  }

  @override
  void dispose() {
    _orderRef?.onDisconnect();
    super.dispose();
    }
  }

final orderStatusProvider =
    StateNotifierProvider<OrderStatusNotifier, AsyncValue<bool>>(
  (ref) => OrderStatusNotifier(),
);

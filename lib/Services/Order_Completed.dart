import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Orders/ordersTab.dart';

class CountdownNotifier extends StateNotifier<int> {
  CountdownNotifier(this.ref) : super(5) {
    ref.onDispose(cancelTimer);
  }

  final Ref ref;
  Timer? _timer;

  void startCountdown(Function onComplete) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state > 1) {
        state--;
      } else {
        _timer?.cancel();
        onComplete();
      }
    });
  }

  void cancelTimer() {
    _timer?.cancel();
  }
}

final countdownProvider = StateNotifierProvider<CountdownNotifier, int>((ref) {
  return CountdownNotifier(ref);
});

class Ordersucces extends ConsumerStatefulWidget {
  const Ordersucces({super.key});

  @override
  ConsumerState<Ordersucces> createState() => _OrdersuccesState();
}

class _OrdersuccesState extends ConsumerState<Ordersucces> {
  @override
  void initState() {
    super.initState();

    ref.read(countdownProvider.notifier).startCountdown(() {
      Navigator.push(
        context,
        CupertinoModalPopupRoute(
          builder: (context) => const OrdersTabScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final countdown = ref.watch(countdownProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/order_placed-removebg-preview.png",
              height: 200,
            ),
            const SizedBox(height: 20),
            Text(
              "Redirecting to My Orders in $countdown seconds",
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoModalPopupRoute(
                    builder: (context) => const OrdersTabScreen(),
                  ),
                );
              },
              child: const Text(
                "My Orders",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

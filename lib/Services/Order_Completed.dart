import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class CountdownNotifier extends StateNotifier<int> {
  CountdownNotifier(super.initialCountdown);

  Timer? _timer;

  void startCountdown(VoidCallback onComplete) {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state > 1) {
        state--;
      } else {
        _timer?.cancel();
        onComplete();
      }
    });
  }

  void cancelCountdown() {
    _timer?.cancel();
  }
}

final countdownProvider =
    StateNotifierProvider.family<CountdownNotifier, int, int>(
  (ref, initialCountdown) => CountdownNotifier(initialCountdown),
);

class ReusableCountdownDialog {
  final BuildContext context;
  final WidgetRef ref;
  final String message;
  final String imagePath;
  final int countdownDuration;
  final VoidCallback onRedirect;

  ReusableCountdownDialog({
    required this.context,
    required this.ref,
    required this.message,
    required this.imagePath,
    required this.countdownDuration,
    required this.onRedirect,
  });

  void show() {
    ref.read(countdownProvider(countdownDuration).notifier).startCountdown(() {
      Navigator.pop(context);
      onRedirect();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final countdown = ref.watch(countdownProvider(countdownDuration));
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    imagePath,
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "$message in $countdown seconds",
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      ref
                          .read(countdownProvider(countdownDuration).notifier)
                          .cancelCountdown();
                      Navigator.pop(context);
                      onRedirect();
                    },
                    child: const Text(
                      "My Orders",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

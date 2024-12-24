import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/LandingPage/Widgets/floating_bottom_navigation_bar.dart';
import 'package:kealthy/Services/Navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../LandingPage/Widgets/Review&Feedback.dart';

class NotificationState {
  final String? rateUsDialogBody;

  NotificationState({this.rateUsDialogBody});

  NotificationState copyWith({String? rateUsDialogBody}) {
    return NotificationState(
      rateUsDialogBody: rateUsDialogBody ?? this.rateUsDialogBody,
    );
  }
}

class NotificationStateNotifier extends StateNotifier<NotificationState> {
  NotificationStateNotifier()
      : super(NotificationState(rateUsDialogBody: null));

  Future<void> fetchRateUsDialogBody() async {
    final prefs = await SharedPreferences.getInstance();
    final body = prefs.getString('Rate');
    final timestamp = prefs.getInt('RateTimestamp');

    if (body != null && timestamp != null) {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final timeDifference = currentTime - timestamp;

      if (timeDifference > 3600000) {
        state = state.copyWith(rateUsDialogBody: body);
      } else {
        state = state.copyWith(rateUsDialogBody: null);
      }
    } else {
      state = state.copyWith(rateUsDialogBody: null);
    }
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationStateNotifier, NotificationState>(
  (ref) => NotificationStateNotifier(),
);

class NotificationHandler {
  static bool _isDialogShown = false;

  static Future<void> initialize(BuildContext context, WidgetRef ref) async {
    await ref.read(notificationProvider.notifier).fetchRateUsDialogBody();

    final dialogBody = ref.read(notificationProvider).rateUsDialogBody;
    if (dialogBody != null && dialogBody.isNotEmpty && !_isDialogShown) {
      _showRateUsDialog(context, dialogBody);
    }
  }

  static void _showRateUsDialog(BuildContext context, String body) {
    if (_isDialogShown) return;
    _isDialogShown = true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titlePadding: const EdgeInsets.all(16),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Column(
          children: [
            Image.asset(
              'assets/feedback.png',
              height: 100,
            ),
            const SizedBox(height: 10),
            const Text(
              "Help us improve by sharing your feedback",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "poppins"),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.start,
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              prefs.remove('Rate');
              prefs.remove('RateTimestamp');

              Navigator.push(context,
                  SeamlessRevealRoute(page: CustomBottomNavigationBar()));
            },
            child: const Text(
              'No thanks',
              style: TextStyle(color: Colors.grey, fontFamily: "poppins"),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.push(
                  context, SeamlessRevealRoute(page: FeedbackPage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF273847),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Sure, I’ll give feedback',
              style: TextStyle(color: Colors.white, fontFamily: "poppins"),
            ),
          ),
        ],
      ),
    ).then((_) {
      _isDialogShown = false;
    });
  }
}

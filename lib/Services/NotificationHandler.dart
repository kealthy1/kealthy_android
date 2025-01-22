import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
      _showRateUsDialog(context, ref, dialogBody);
    }
  }

  static void _showRateUsDialog(
      BuildContext context, WidgetRef ref, String body) {
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
            Text(
              "Help us improve by sharing your feedback",
              style: GoogleFonts.poppins(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.spaceAround,
        actions: [
          TextButton(
            onPressed: () async {
              // ignore: unused_result
              ref.refresh(notificationProvider);
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('Rate');
              await prefs.remove('RateTimestamp');

              ref.read(notificationProvider.notifier).fetchRateUsDialogBody();

              Navigator.pop(context);
            },
            child: Text(
              'No thanks',
              style: GoogleFonts.poppins(
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // ignore: unused_result
              ref.refresh(notificationProvider);

              Navigator.push(
                context,
                SeamlessRevealRoute(page: FeedbackPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF273847),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Sure',
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ).then((_) {
      _isDialogShown = false;
    });
  }
}

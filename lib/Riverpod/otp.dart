import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../LandingPage/Widgets/floating_bottom_navigation_bar.dart';

class OtpState {
  final String? otp;
  final bool isLoading;
  final String? error;

  OtpState({
    this.otp,
    this.isLoading = false,
    this.error,
  });
}

class OtpNotifier extends StateNotifier<OtpState> {
  OtpNotifier() : super(OtpState());

  void setOtp(String otp) {
    state = OtpState(otp: otp);
  }

  Future<void> verifyOtp(
      String verificationId, String otp, BuildContext context,
      {Function? onSuccess}) async {
    state = OtpState(isLoading: true);
    const url = 'https://api-jfnhkjk4nq-uc.a.run.app/verify-otp';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'verificationId': verificationId,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        state = OtpState();
        if (onSuccess != null) {
          onSuccess();
        }
        FocusScope.of(context).unfocus();
        Navigator.pushReplacement(
          context,
          CupertinoModalPopupRoute(
              builder: (context) => const CustomBottomNavigationBar()),
        );
      } else {
        state = OtpState(error: 'Inavalid OTP');
      }
    } catch (e) {
      state = OtpState(error: 'An error occurred');
    }
  }

  Future<void> resendOtp(String phoneNumber,
      Function(String newVerificationId)? onVerificationIdUpdated) async {
    const url = 'https://api-jfnhkjk4nq-uc.a.run.app/send-otp';
    state = OtpState(isLoading: true);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['verificationId'] != null &&
            onVerificationIdUpdated != null) {
          onVerificationIdUpdated(responseData['verificationId']);
        }
        state = OtpState();
      } else {
        state = OtpState(error: 'Failed to resend OTP');
      }
    } catch (e) {
      state = OtpState(error: 'An error occurred while resending OTP');
    }
  }
}

final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>(
  (ref) => OtpNotifier(),
);

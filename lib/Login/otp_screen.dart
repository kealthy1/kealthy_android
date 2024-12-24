import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:telephony/telephony.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../Services/Loading.dart';
import '../Riverpod/otp.dart';

class OtpScreenNotifier extends StateNotifier<OtpScreenState> {
  OtpScreenNotifier(String initialVerificationId)
      : super(OtpScreenState(verificationId: initialVerificationId));

  void setReceivedText(String text) {
    state = state.copyWith(textReceived: text);
  }

  void startTimer() {
    cancelTimer(); // Ensure no existing timers are running
    state = state.copyWith(
      timer: Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state.start == 0) {
          cancelTimer();
        } else {
          state = state.copyWith(start: state.start - 1);
        }
      }),
    );
  }

  void resetTimer() {
    cancelTimer(); // Cancel the existing timer before restarting
    state = state.copyWith(start: 30); // Reset timer to 30 seconds
    startTimer();
  }

  void cancelTimer() {
    if (state.timer != null && state.timer!.isActive) {
      state.timer!.cancel();
    }
    state = state.copyWith(timer: null);
  }

  void updateVerificationId(String newVerificationId) {
    state = state.copyWith(verificationId: newVerificationId);
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }
}

class OtpScreenState {
  final String textReceived;
  final Timer? timer;
  final int start;
  final String verificationId;
  final String otpControllerText;

  OtpScreenState({
    this.textReceived = '',
    this.timer,
    this.start = 30,
    required this.verificationId,
    this.otpControllerText = '',
  });

  OtpScreenState copyWith({
    String? textReceived,
    Timer? timer,
    int? start,
    String? verificationId,
    String? otpControllerText,
  }) {
    return OtpScreenState(
      textReceived: textReceived ?? this.textReceived,
      timer: timer ?? this.timer,
      start: start ?? this.start,
      verificationId: verificationId ?? this.verificationId,
      otpControllerText: otpControllerText ?? this.otpControllerText,
    );
  }
}

final otpScreenProvider =
    StateNotifierProvider.family<OtpScreenNotifier, OtpScreenState, String>(
  (ref, initialVerificationId) => OtpScreenNotifier(initialVerificationId),
);

class OTPScreen extends ConsumerWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });
  Future<void> _savePhoneNumber(WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanedPhoneNumber =
        phoneNumber.replaceAll('+91', '').replaceAll(' ', '');

    await prefs.setString('phoneNumber', cleanedPhoneNumber);

    const apiUrl = "https://api-jfnhkjk4nq-uc.a.run.app/login";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': phoneNumber}),
    );

    if (response.statusCode == 200) {
      debugPrint('Phone number saved to MongoDB: \${response.body}');
    } else {
      debugPrint(
          'Failed to save phone number to MongoDB: \${response.statusCode}, \${response.body}');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otpState = ref.watch(otpProvider);
    final otpScreenState = ref.watch(otpScreenProvider(verificationId));
    void extractAndFillOtp(String message, WidgetRef ref) {
      final RegExp otpRegExp =
          RegExp(r'Dear User Your OTP Code for login in Kealthy is (\d{4})');
      final match = otpRegExp.firstMatch(message);

      if (match != null) {
        final extractedOtp = match.group(1);
        if (extractedOtp != null) {
          ref
              .read(otpScreenProvider(verificationId).notifier)
              .setReceivedText(extractedOtp);
          ref.read(otpScreenProvider(verificationId).notifier).state =
              otpScreenState.copyWith(otpControllerText: extractedOtp);
          if (extractedOtp.length == 4) {
            ref.read(otpProvider.notifier).verifyOtp(
                  otpScreenState.verificationId,
                  extractedOtp,
                  context,
                  onSuccess: () => _savePhoneNumber(ref),
                );
          }
        }
      } else {
        debugPrint("No OTP found in the message.");
      }
    }

    void startListeningForSms() {
      final telephony = Telephony.instance;
      telephony.listenIncomingSms(
        onNewMessage: (SmsMessage message) {
          debugPrint("Received SMS: \${message.body}");
          if (message.body != null &&
              message.body!.contains("Your OTP Code for login in Kealthy is")) {
            extractAndFillOtp(message.body!, ref);
          }
        },
        listenInBackground: false,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      startListeningForSms();
      ref.read(otpScreenProvider(verificationId).notifier).startTimer();
    });

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Enter OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text('OTP sent to $phoneNumber'),
              const SizedBox(height: 50),
              Form(
                child: PinCodeTextField(
                  controller: TextEditingController(
                    text: otpScreenState.otpControllerText,
                  ),
                  appContext: context,
                  length: 4,
                  onChanged: (value) {
                    ref.read(otpScreenProvider(verificationId).notifier).state =
                        otpScreenState.copyWith(otpControllerText: value);
                  },
                  onCompleted: (otp) {
                    if (otp.length == 4) {
                      ref.read(otpProvider.notifier).verifyOtp(
                            otpScreenState.verificationId,
                            otp,
                            context,
                            onSuccess: () => _savePhoneNumber(ref),
                          );
                    }
                  },
                  pinTheme: PinTheme(
                    borderWidth: 10,
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeColor: const Color(0xFF273847),
                    inactiveColor: Colors.grey,
                    selectedColor: const Color(0xFF273847),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              if (otpState.error != null) ...[
                const SizedBox(height: 10),
                Text(
                  otpState.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 20),
              otpState.isLoading
                  ? LoadingAnimationWidget.inkDrop(
                      color: Color(0xFF273847),
                      size: 30,
                    )
                  : ElevatedButton(
                      onPressed: () {
                        final otp = otpScreenState.otpControllerText.trim();
                        if (otp.length == 4) {
                          ref.read(otpProvider.notifier).verifyOtp(
                                otpScreenState.verificationId,
                                otp,
                                context,
                                onSuccess: () => _savePhoneNumber(ref),
                              );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF273847),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 30.0,
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  ref.read(otpProvider.notifier).resendOtp(
                    phoneNumber,
                    (newVerificationId) {
                      ref
                          .read(otpScreenProvider(verificationId).notifier)
                          .updateVerificationId(newVerificationId);
                      ref
                          .read(otpScreenProvider(verificationId).notifier)
                          .resetTimer();
                    },
                  );
                },
                child: const Text(
                  'Resend',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

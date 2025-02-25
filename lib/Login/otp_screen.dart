import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Riverpod/otp.dart';

class OtpScreenNotifier extends StateNotifier<OtpScreenState> {
  OtpScreenNotifier(String initialVerificationId)
      : super(OtpScreenState(verificationId: initialVerificationId));

  void setReceivedText(String text) {
    state = state.copyWith(textReceived: text);
  }

  void startTimer() {
    cancelTimer();
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
    cancelTimer();
    state = state.copyWith(start: 30);
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(otpScreenProvider(verificationId).notifier).startTimer();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 50),
              Text('Enter OTP sent to $phoneNumber',
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 50),
              Form(
                child: PinCodeTextField(
                  animationDuration: Duration.zero,
                  cursorColor: Color(0xFF273847),
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  controller: TextEditingController(
                    text: otpScreenState.otpControllerText,
                  ),
                  appContext: context,
                  length: 4,
                  onChanged: (value) {
                    // ignore: invalid_use_of_protected_member
                    ref
                            .read(otpScreenProvider(verificationId).notifier)
                            // ignore: invalid_use_of_protected_member
                            .state =
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
                    fieldWidth: 50,
                    activeBoxShadow: [
                      BoxShadow(
                        color: Color(0xFF273847).withOpacity(0.1),
                      ),
                    ],
                    inActiveBoxShadow: [
                      BoxShadow(
                        color: Color(0xFF273847).withOpacity(0.2),
                      ),
                    ],
                    activeColor: Colors.grey.shade500,
                    inactiveColor: Colors.grey.shade500,
                    selectedColor: const Color(0xFF273847),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              if (otpState.error != null) ...[
                const SizedBox(height: 10),
                Text(
                  otpState.error!,
                  style: GoogleFonts.poppins(color: Colors.red),
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
                      child: Text(
                        'Continue',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Didn\'t receive OTP?',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
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
                    child: Text(
                      'Resend it',
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

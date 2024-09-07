import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';
import '../LandingPage/HomePage.dart';

// OtpState now includes loading and error states.
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

// StateNotifier to manage the state
class OtpNotifier extends StateNotifier<OtpState> {
  OtpNotifier() : super(OtpState());

  void setOtp(String otp) {
    state = OtpState(otp: otp);
  }

  Future<void> verifyOtp(String verificationId, String otp, BuildContext context) async {
    state = OtpState(isLoading: true);
    const url = 'https://us-central1-kealthy-90c55.cloudfunctions.net/api/verify-otp';

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      } else {
        state = OtpState(error: 'OTP verification failed');
      }
    } catch (e) {
      state = OtpState(error: 'An error occurred');
    }
  }

  Future<void> resendOtp(String phoneNumber) async {
    const url = 'https://us-central1-kealthy-90c55.cloudfunctions.net/api/send-otp';
    state = OtpState(isLoading: true);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      if (response.statusCode == 200) {
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

class OTPScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Timer _timer;
  int _start = 30; // OTP timeout duration in seconds

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('OTP sent to ${widget.phoneNumber}'),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: PinCodeTextField(
                controller: _otpController,
                appContext: context,
                length: 4,
                onChanged: (value) {},
                onCompleted: (otp) {
                  if (_formKey.currentState?.validate() == true) {
                    final verificationId = widget.verificationId;
                    ref.read(otpProvider.notifier).verifyOtp(verificationId, otp, context);
                  }
                },
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.grey,
                  selectedColor: Colors.blue,
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
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() == true) {
                        final otp = _otpController.text.trim();
                        final verificationId = widget.verificationId;
                        ref.read(otpProvider.notifier).verifyOtp(verificationId, otp, context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 30.0),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
            const SizedBox(height: 20),
            _start == 0
                ? ElevatedButton(
                    onPressed: () {
                      ref.read(otpProvider.notifier).resendOtp(widget.phoneNumber);
                      setState(() {
                        _start = 30;
                      });
                      _startTimer();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 30.0),
                    ),
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900),
                    ),
                  )
                : Text(
                    'Resend OTP in $_start seconds',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
          ],
        ),
      ),
    );
  }
}

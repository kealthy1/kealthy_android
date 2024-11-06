import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/Services/Loading.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:telephony/telephony.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Riverpod/otp.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  final Telephony telephony = Telephony.instance;
  String textReceived = "";
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Timer _timer;
  int _start = 30;

  @override
  void initState() {
    super.initState();
    startListening();
    _startTimer();
  }

  void startListening() {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        if (message.body != null &&
            message.body!.contains("Your OTP code is:")) {
          _extractAndFillOtp(message.body!);
          setState(() {
            textReceived = message.body ?? "";
          });
        } else {
          setState(() {
            textReceived = "Ignored message: ${message.body ?? ""}";
          });
        }
      },
      listenInBackground: false,
    );
  }

  void _extractAndFillOtp(String message) {
    final RegExp otpRegExp = RegExp(r'Your OTP code is:\s*(\d{4})');
    final match = otpRegExp.firstMatch(message);
    if (match != null) {
      final extractedOtp = match.group(1);
      if (extractedOtp != null) {
        _otpController.text = extractedOtp;
        if (_otpController.text.length == 4) {
          _formKey.currentState?.validate();
          ref.read(otpProvider.notifier).verifyOtp(
              widget.verificationId, extractedOtp, context,
              onSuccess: _savePhoneNumber); // Pass the save function
        }
      }
    }
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

  Future<void> _savePhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();

    String cleanedPhoneNumber =
        widget.phoneNumber.replaceAll('+91', '').replaceAll(' ', '');

    await prefs.setString('phoneNumber', cleanedPhoneNumber);

    const String apiUrl = "https://api-jfnhkjk4nq-uc.a.run.app/login";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phoneNumber': widget.phoneNumber}),
    );

    if (response.statusCode == 200) {
      print('Phone number saved to MongoDB: ${response.body}');
    } else {
      print(
          'Failed to save phone number to MongoDB: ${response.statusCode}, ${response.body}');
      print('Response: ${response.toString()}');
    }
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
        automaticallyImplyLeading: false,
        title: const Text('Enter OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('OTP sent to ${widget.phoneNumber}'),
            const SizedBox(height: 50),
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
                    ref.read(otpProvider.notifier).verifyOtp(
                        verificationId, otp, context,
                        onSuccess: _savePhoneNumber);
                  }
                },
                pinTheme: PinTheme(
                  borderWidth: 10,
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  activeColor: Colors.green,
                  inactiveColor: Colors.grey,
                  selectedColor: Colors.green,
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
                ? const Center(
                    child: LoadingWidget(message: "Fueling your health..."))
                : ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() == true) {
                        final otp = _otpController.text.trim();
                        final verificationId = widget.verificationId;
                        ref.read(otpProvider.notifier).verifyOtp(
                            verificationId, otp, context,
                            onSuccess: _savePhoneNumber);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            _start == 0
                ? TextButton(
                    onPressed: () {
                      ref
                          .read(otpProvider.notifier)
                          .resendOtp(widget.phoneNumber);
                      setState(() {
                        _start = 30;
                      });
                      _startTimer();
                    },
                    child: const Text(
                      'Resend',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  )
                : Text(
                    'Resend OTP in $_start seconds',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
            const SizedBox(height: 20),
            Text(textReceived)
          ],
        ),
      ),
    );
  }
}

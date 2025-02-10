import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../LandingPage/Myprofile/PrivacyPolicy.dart';
import '../LandingPage/Myprofile/Terms&Conditions.dart';
import '../Riverpod/otp.dart';
import 'otp_screen.dart';

// StateNotifier for managing the checkbox state
class TermsAndPrivacyNotifier extends StateNotifier<Map<String, bool>> {
  TermsAndPrivacyNotifier()
      : super({
          "privacy": false,
          "terms": false,
        });

  void togglePrivacy(bool value) {
    state = {...state, "privacy": value};
  }

  void toggleTerms(bool value) {
    state = {...state, "terms": value};
  }
}

// Provider for checkbox state
final termsAndPrivacyProvider =
    StateNotifierProvider<TermsAndPrivacyNotifier, Map<String, bool>>(
  (ref) => TermsAndPrivacyNotifier(),
);

class SignUpScreen extends ConsumerWidget {
  final String verificationId;
  final String phoneNumber;

  const SignUpScreen({
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
    final termsAndPrivacy = ref.watch(termsAndPrivacyProvider);

    final otpState = ref.watch(otpProvider);
    final otpScreenState = ref.watch(otpScreenProvider(verificationId));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(otpScreenProvider(verificationId).notifier).startTimer();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFF273847),
        automaticallyImplyLeading: false,
        title: Text('Sign Up',
            style: GoogleFonts.poppins(
              color: Colors.white,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  // onCompleted: (otp) {
                  //   if (otp.length == 4) {
                  //     ref.read(otpProvider.notifier).verifyOtp(
                  //           otpScreenState.verificationId,
                  //           otp,
                  //           context,
                  //           onSuccess: () => _savePhoneNumber(ref),
                  //         );
                  //   }
                  // },blueblue
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          activeColor: Colors.blue,
                          value: termsAndPrivacy["privacy"],
                          onChanged: (value) {
                            ref
                                .read(termsAndPrivacyProvider.notifier)
                                .togglePrivacy(value!);
                          },
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Text("I accept the "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PrivacyPolicyPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Privacy Policy",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          activeColor: Colors.blue,
                          value: termsAndPrivacy["terms"],
                          onChanged: (value) {
                            ref
                                .read(termsAndPrivacyProvider.notifier)
                                .toggleTerms(value!);
                          },
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Text("I agree to the "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TermsAndConditionsPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "Terms & Conditions",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (termsAndPrivacy["privacy"] == true &&
                  termsAndPrivacy["terms"] == true)
                otpState.isLoading
                    ? LoadingAnimationWidget.inkDrop(
                        color: Color(0xFF273847),
                        size: 30,
                      )
                    : ElevatedButton(
                        onPressed: (termsAndPrivacy["privacy"] == true &&
                                termsAndPrivacy["terms"] == true)
                            ? () {
                                ref.read(otpProvider.notifier).verifyOtp(
                                      otpScreenState.verificationId,
                                      otpScreenState.otpControllerText.trim(),
                                      context,
                                      onSuccess: () => _savePhoneNumber(ref),
                                    );
                              }
                            : null, // Disables the button if checkboxes are not checked
                        style: ElevatedButton.styleFrom(
                          backgroundColor: (termsAndPrivacy["privacy"] ==
                                      true &&
                                  termsAndPrivacy["terms"] == true)
                              ? const Color(0xFF273847)
                              : Colors
                                  .grey, // Button appears grey when disabled
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

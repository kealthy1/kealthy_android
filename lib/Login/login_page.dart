import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kealthy/Login/otp_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../LandingPage/Widgets/floating_bottom_navigation_bar.dart';
import '../Riverpod/LoadingproviderLoginpage.dart';
import 'Guest_Alert.dart';
import 'signUp.dart';

class LoginFields extends ConsumerStatefulWidget {
  const LoginFields({super.key});

  @override
  _LoginFieldsState createState() => _LoginFieldsState();
}

class _LoginFieldsState extends ConsumerState<LoginFields> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    ref.read(loadingProvider.notifier).state = true;

    final phoneNumber = _phoneController.text.trim();
    const checkUserUrl =
        'https://api-jfnhkjk4nq-uc.a.run.app/checkUserExists?phoneNumber=';
    const otpUrl = 'https://api-jfnhkjk4nq-uc.a.run.app/send-otp';

    try {
      final checkUserResponse =
          await http.get(Uri.parse('$checkUserUrl$phoneNumber'));

      if (checkUserResponse.statusCode == 200) {
        final userData = jsonDecode(checkUserResponse.body);

        if (userData['success'] && userData['message'] == "User found") {
          final otpResponse = await http.post(
            Uri.parse(otpUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phoneNumber': phoneNumber}),
          );

          if (otpResponse.statusCode == 200) {
            final otpData = jsonDecode(otpResponse.body);
            final verificationId = otpData['verificationId'];

            print('OTP sent successfully! Response: ${otpResponse.body}');
            FocusScope.of(context).unfocus();

            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => OTPScreen(
                  verificationId: verificationId,
                  phoneNumber: phoneNumber,
                ),
              ),
            );
          } else {
            print('Failed to send OTP: ${otpResponse.body}');
          }
        } else {
          final otpResponse = await http.post(
            Uri.parse(otpUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phoneNumber': phoneNumber}),
          );

          if (otpResponse.statusCode == 200) {
            final otpData = jsonDecode(otpResponse.body);
            final verificationId = otpData['verificationId'];
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => SignUpScreen(
                  phoneNumber: phoneNumber,
                  verificationId: verificationId,
                ),
              ),
            );
          } else {
            print('Failed to send OTP: ${otpResponse.body}');
          }
        }
      } else {
        print('Failed to check user: ${checkUserResponse.body}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(phoneNumberProvider);
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Colors.grey.withOpacity(0.4), width: 0.5),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    image: DecorationImage(
                      image: AssetImage("assets/opening.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: () {
                        GuestDialog.show(
                          context: context,
                          title: "Continue as Guest?",
                          content:
                              "You won't be able to save preferences or place orders without logging in.",
                          navigateTo: const CustomBottomNavigationBar(),
                        );
                      },
                      child: Text(
                        "Skip",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Colors.grey.shade400, width: 1),
                      ),
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        cursorColor: Colors.grey.shade500,
                        onChanged: (value) {
                          ref.read(phoneNumberProvider.notifier).state = value;
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            CupertinoIcons.phone,
                            color: Colors.grey.shade500,
                          ),
                          hintText: 'Enter Phone Number',
                          hintStyle: GoogleFonts.poppins(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600),
                          filled: true,
                          fillColor: Colors.grey.shade300,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: GoogleFonts.poppins(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await _sendOtp();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF273847),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 25.0),
                        ),
                        child: isLoading
                            ? LoadingAnimationWidget.inkDrop(
                                color: Colors.white,
                                size: 20,
                              )
                            : Text(
                                'Continue',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

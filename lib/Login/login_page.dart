import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:kealthy/Login/otp_screen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../Riverpod/LoadingproviderLoginpage.dart';
import '../Riverpod/Texanimation.dart';

class LoginFields extends ConsumerStatefulWidget {
  const LoginFields({super.key});

  @override
  _LoginFieldsState createState() => _LoginFieldsState();
}

class _LoginFieldsState extends ConsumerState<LoginFields> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _startAnimation();
  }

  void _startAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(opacityProvider.notifier).state = 0.0;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ref.read(opacityProvider.notifier).state = 1.0;
        }
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    ref.read(loadingProvider.notifier).state = true;

    final phoneNumber = _phoneController.text.trim();
    const url = 'https://api-jfnhkjk4nq-uc.a.run.app/send-otp';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final verificationId = data['verificationId'];
        print('OTP sent successfully! Response: ${response.body}');
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
        print('Failed to send OTP: ${response.body}');
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
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "assets/a-photo-of-a-family-sitting-at-a-table-eating-heal-WzTfpXsNT66riCX_SEJ3BA-uXSmtXOlRKa79_7mMqYIGw_11zon.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 15, top: 100, bottom: 35, right: 15),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInText(
                        text: 'YOUR JOURNEY TO WELLNESS',
                        duration: const Duration(seconds: 1),
                        color: Colors.green,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                      ),
                      FadeInText(
                        text: 'STARTS HERE.',
                        duration: const Duration(seconds: 1),
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.10,
                      ),
                      const SizedBox(height: 50),
                      const FadeInText(
                        text: 'Phone no.',
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        enableInteractiveSelection: false,
                        controller: _phoneController,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          ref.read(phoneNumberProvider.notifier).state = value;
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(CupertinoIcons.phone),
                          hintText: 'Enter Phone Number',
                          hintStyle: GoogleFonts.poppins(color: Colors.black54),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white70,
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: GoogleFonts.poppins(color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                await _sendOtp();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF273847),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 30.0),
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

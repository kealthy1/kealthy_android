import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kealthy/LandingPage/HomePage.dart';
import 'package:kealthy/Login/introscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateAfterDelay();
  }

  Future<void> navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final hasPhoneNumber = await _checkPhoneNumber();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) =>
              hasPhoneNumber ? const MyHomePage() : const IntroScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Kealthy.jpeg',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<bool> _checkPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');
    print("Phone number in prefs: $phoneNumber"); // Debugging line
    return phoneNumber != null;
  }
}

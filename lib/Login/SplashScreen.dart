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

    Timer(const Duration(seconds: 2), () async {
      final hasPhoneNumber = await _checkPhoneNumber();

      Navigator.pushReplacement(
          context,
          CupertinoModalPopupRoute(
            builder: (context) =>
                hasPhoneNumber ? const MyHomePage() : const IntroScreen(),
          ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/2.png',
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
    return phoneNumber != null;
  }
}

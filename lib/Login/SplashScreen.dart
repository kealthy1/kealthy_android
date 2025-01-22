import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kealthy/LandingPage/Widgets/floating_bottom_navigation_bar.dart';
import 'package:kealthy/Login/introscreen.dart';
import 'package:kealthy/Services/Navigation.dart';
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
    await Future.delayed(const Duration(seconds: 4));

    final hasPhoneNumber = await _checkPhoneNumber();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        SeamlessRevealRoute(
          page: hasPhoneNumber
              ? const CustomBottomNavigationBar()
              : const IntroPage2(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/splash.gif'),
              fit: BoxFit.fill,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
              ],
            ),
          ),
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

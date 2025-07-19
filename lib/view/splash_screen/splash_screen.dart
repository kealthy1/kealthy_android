import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/view/BottomNavBar/bottom_nav_bar.dart';
import 'package:kealthy/view/Login/login_page.dart';
import 'package:kealthy/view/splash_screen/maintanance.dart';
import 'package:kealthy/view/splash_screen/required_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));

    final updateInfo = await _checkForceUpdateRequired();
    if (!mounted) return;

    final hasShownUpdate = await _hasShownUpdatePage();
    if (updateInfo['forceUpdate']) {
      if (!hasShownUpdate) {
        await _setUpdatePageShown();
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (_) => const ForceUpdatePage(),
          ),
        );
        return;
      }
    } else {
      await _resetUpdatePageShown();
    }

    final isUnderMaintenance = await _checkMaintenanceStatus();
    if (!mounted) return;

    if (isUnderMaintenance) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(builder: (_) => const MaintenanceScreen()),
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      final storedPhone = prefs.getString('phoneNumber') ?? '';

      // ✅ Set phone number into provider
      ref.read(phoneNumberProvider.notifier).state = storedPhone;

      Navigator.pushReplacement(
        context,
        CupertinoModalPopupRoute(
          builder: (_) =>
              storedPhone.isNotEmpty ? BottomNavBar() : const LoginFields(),
        ),
      );
    }
  }

  Future<bool> _hasShownUpdatePage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasShownUpdatePage') ?? false;
  }

  Future<void> _setUpdatePageShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasShownUpdatePage', true);
  }

  Future<void> _resetUpdatePageShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasShownUpdatePage', false);
  }

  Future<Map<String, dynamic>> _checkForceUpdateRequired() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('updateControl')
          .get();
      final data = doc.data();
      if (data?['forceUpdate'] == true) {
        return {
          'forceUpdate': true,
        };
      } else {
        return {
          'forceUpdate': false,
          'hasShownUpdate': false,
        };
      }
    } catch (e) {
      print("⚠️ Force update check failed: $e");
      return {'forceUpdate': false, 'appStoreUrl': '', 'hasShownUpdate': false};
    }
  }

  Future<bool> _checkMaintenanceStatus() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('maintenance')
          .doc('status')
          .get();
      return doc.data()?['maintenance'] == true;
    } catch (e) {
      print("⚠️ Maintenance check failed: $e");
      return false;
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
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/images/splash.gif'),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/LandingPage/Widgets/floating_bottom_navigation_bar.dart';
import 'package:kealthy/Services/Connection.dart';

class NoInternetPage extends ConsumerWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ConnectivityService connectivityService = ConnectivityService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<bool>(
        stream: connectivityService.connectivityStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      "assets/INTERNET.JPG",
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Icon(
                    CupertinoIcons.wifi_slash,
                    color: Colors.red,
                    size: 44,
                  ),
                  const Text(
                    textAlign: TextAlign.center,
                    "Oops! You're Offline",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "poppins",
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  const Text(
                    textAlign: TextAlign.center,
                    "Looks like you've lost connection. Check your internet and try again.",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: "poppins",
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasData && snapshot.data == true) {
            Future.microtask(() => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const CustomBottomNavigationBar()),
                  (Route<dynamic> route) => false,
                ));
            return Container();
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(
                    "assets/INTERNET.JPG",
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width * 0.7,
                  ),
                ),
                const SizedBox(height: 5),
                Icon(
                  CupertinoIcons.wifi_slash,
                  color: Colors.red,
                  size: 44,
                ),
                const Text(
                  textAlign: TextAlign.center,
                  "Oops! You're Offline",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "poppins",
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                const Text(
                  textAlign: TextAlign.center,
                  "Looks like you've lost connection. Check your internet and try again.",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: "poppins",
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

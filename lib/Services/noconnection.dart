import 'package:flutter/material.dart';
import 'package:kealthy/Services/Connection.dart';
import 'package:kealthy/LandingPage/HomePage.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    ConnectivityService connectivityService = ConnectivityService();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: StreamBuilder<bool>(
          stream: connectivityService.connectivityStream,
          builder: (context, snapshot) {
            // Check the connection status
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Image.asset(
                "assets/Capture-removebg-preview (1).png",
                height: 300,
              ); 
            }

            if (snapshot.data == true) {
              // Navigate to Home page if connected
              Future.microtask(() => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MyHomePage()),
                    (Route<dynamic> route) => false,
                  ));
              const SizedBox(height: 20);
              const Text(
                'Please check your internet connection.',
                style: TextStyle(fontSize: 18),
              );
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/Capture-removebg-preview (1).png",
                  height: 300,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Please check your internet connection.',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

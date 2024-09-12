import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'noconnection.dart';

class ConnectivityService {
  final InternetConnectionChecker _checker = InternetConnectionChecker();

  Stream<bool> get connectivityStream =>
      _checker.onStatusChange.map((status) => status == InternetConnectionStatus.connected);

  Future<bool> isConnected() async {
    return await _checker.hasConnection;
  }
}

class ConnectivityWidget extends StatefulWidget {
  final Widget child;

  const ConnectivityWidget({
    required this.child,
    super.key,
  });

  @override
  _ConnectivityWidgetState createState() => _ConnectivityWidgetState();
}

class _ConnectivityWidgetState extends State<ConnectivityWidget> {
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    // Optionally, you might want to check connection initially
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      // If not connected initially, navigate to the NoInternetPage
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const NoInternetPage()),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _connectivityService.connectivityStream,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;

        // If not connected, navigate to the NoInternetPage
        if (!isConnected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToNoConnectionPage(context);
          });
        }

        return Container(
          color: Colors.white,
          child: widget.child,
        );
      },
    );
  }

  void _navigateToNoConnectionPage(BuildContext context) {
    // Directly navigate to NoInternetPage
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const NoInternetPage()),
      (Route<dynamic> route) => false,
    );
  }
}

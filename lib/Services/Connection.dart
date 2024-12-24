import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'noconnection.dart';

class ConnectivityService {
  final InternetConnectionChecker _checker = InternetConnectionChecker();

  Stream<bool> get connectivityStream => _checker.onStatusChange
      .map((status) => status == InternetConnectionStatus.connected);

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
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<void> _checkInitialConnection() async {
    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected && _mounted) {
      _navigateToNoConnectionPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _connectivityService.connectivityStream,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;

        if (!isConnected && _mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToNoConnectionPage();
          });
        }

        return Container(
          color: Colors.white,
          child: widget.child,
        );
      },
    );
  }

  void _navigateToNoConnectionPage() {
    if (_mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const NoInternetPage()),
        (Route<dynamic> route) => false,
      );
    }
  }
}

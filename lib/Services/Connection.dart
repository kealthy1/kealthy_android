import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  final InternetConnectionChecker _checker = InternetConnectionChecker();

  Stream<bool> get connectivityStream => _checker.onStatusChange
      .map((status) => status == InternetConnectionStatus.connected);

  Future<bool> isConnected() async {
    return await _checker.hasConnection;
  }
}

class ConnectivityWidget extends StatelessWidget {
  final Widget child;

  const ConnectivityWidget({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService().connectivityStream,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;

        return Container(
          color: Colors.white, 
          child: Stack(
            children: [
              child,
              if (!isConnected)
                const Positioned(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No Internet Connection',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

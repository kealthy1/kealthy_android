import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kealthy/LandingPage/Widgets/floating_bottom_navigation_bar.dart';
import 'package:kealthy/Services/Connection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

final retryLoadingProvider = StateProvider<bool>((ref) => false);

class NoInternetPage extends ConsumerWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ConnectivityService connectivityService = ConnectivityService();
    final isLoading = ref.watch(retryLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: StreamBuilder<bool>(
          stream: connectivityService.connectivityStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/Capture-removebg-preview (1).png",
                    height: 300,
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }

            if (snapshot.data == true) {
              Future.microtask(() => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const CustomBottomNavigationBar()),
                    (Route<dynamic> route) => false,
                  ));
              return Container();
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/Capture-removebg-preview (1).png",
                  height: 300,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: const BeveledRectangleBorder()),
                  onPressed: () async {
                    ref.read(retryLoadingProvider.notifier).state = true;

                    bool isConnected = await connectivityService.isConnected();

                    ref.read(retryLoadingProvider.notifier).state = false;

                    if (isConnected) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const CustomBottomNavigationBar()),
                        (Route<dynamic> route) => false,
                      );
                    } else {
                      Fluttertoast.showToast(
                        msg: "Still no connection, please try again.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
                  },
                  child: isLoading
                      ? LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.green,
                          size: 50,
                        )
                      : const Text('Try Again',
                          style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

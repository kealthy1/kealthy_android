import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DeliveryIn_Kakkanad.dart';

class LocationDialogManager {
  final WidgetRef ref;

  LocationDialogManager(this.ref);

  Future<void> fetchAndCheckLocation(BuildContext context) async {
    await ref.read(deliveryLimitProvider.notifier).fetchCurrentLocation();
    final currentLocation = ref.read(deliveryLimitProvider);

    List<String> serviceablePincodes = ['682030', '682037', '683565'];
    if (context.mounted) {
      if (currentLocation.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();

        String fullAddressWithPincode = currentLocation;
        await prefs.remove('currentaddress');
        await prefs.setString('currentaddress', fullAddressWithPincode);
        print(fullAddressWithPincode);

        if (serviceablePincodes
            .any((pincode) => currentLocation.contains(pincode))) {
          // Alert(
          //   context: context,
          //   type: AlertType.success,
          //   title: 'Serviceable Location',
          //   desc:
          //       'Your current location is within the service area. Delivery can be made to this location.',
          //   style: const AlertStyle(
          //       descStyle:
          //           TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          //   buttons: [
          //     DialogButton(
          //       color: Colors.green,
          //       onPressed: () => Navigator.pop(context),
          //       child: const Text(
          //         "OK",
          //         style: TextStyle(color: Colors.white, fontSize: 18),
          //       ),
          //     ),
          //   ],
          // ).show();
        } else {
          // Alert(
          //   style: const AlertStyle(
          //       descStyle:
          //           TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          //   context: context,
          //   type: AlertType.warning,
          //   title: 'Delivery Not Available',
          //   desc:
          //       "Your current address: $fullAddressWithPincode Unfortunately, we do not deliver to this area.",
          //   buttons: [
          //     DialogButton(
          //       color: Colors.green,
          //       onPressed: () {
          //         Navigator.push(
          //           context,
          //           CupertinoModalPopupRoute(
          //             builder: (context) => const SelectAdress(totalPrice: 0),
          //           ),
          //         );
          //       },
          //       child: const Text(
          //         "Set Address",
          //         style: TextStyle(color: Colors.white),
          //       ),
          //     ),
          //     DialogButton(
          //       color: Colors.black,
          //       onPressed: () {
          //         Navigator.push(
          //           context,
          //           CupertinoModalPopupRoute(
          //             builder: (context) => const MyHomePage(),
          //           ),
          //         );
          //       },
          //       child: const Text(
          //         "Skip",
          //         style: TextStyle(color: Colors.white),
          //       ),
          //     ),
          //   ],
          // ).show();
        }
      } else {
        // Alert(
        //   style: const AlertStyle(
        //       descStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        //   context: context,
        //   type: AlertType.warning,
        //   title: 'Delivery Not Available',
        //   desc: "Please enable location permissions.",
        //   buttons: [
        //     DialogButton(
        //       color: Colors.green,
        //       onPressed: () {
        //         Navigator.push(
        //           context,
        //           CupertinoModalPopupRoute(
        //             builder: (context) => const SelectAdress(totalPrice: 0),
        //           ),
        //         );
        //       },
        //       child: const Text(
        //         "Set Address",
        //         style: TextStyle(color: Colors.white),
        //       ),
        //     ),
        //     DialogButton(
        //       color: Colors.black,
        //       onPressed: () {
        //         Navigator.pop(context);
        //       },
        //       child: const Text(
        //         "Skip",
        //         style: TextStyle(color: Colors.white),
        //       ),
        //     ),
        //   ],
        // ).show();
      }
    }
  }
}

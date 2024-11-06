import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ServiceableAlert {
  static void show({
    required BuildContext context,
    required VoidCallback onContinue,
  }) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: 'Notice on Delivery Distance',
      desc:
          "It appears that you are ordering from a location far away from our service area. Additional delivery charges may apply.",
      style: const AlertStyle(
        descStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      buttons: [
        DialogButton(
          color: Colors.green,
          onPressed: () {
            Navigator.pop(context);
            onContinue();
          },
          child: const Text(
            "Continue",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ).show();
  }
}

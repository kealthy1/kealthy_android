// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:rflutter_alert/rflutter_alert.dart';

// class AlertHelper {
//   static void showProceedAlert({
//     required BuildContext context,
//     required String title,
//     required String description,
//     required Widget getItNowPage,
//     required VoidCallback onProceedAnyway, // Custom callback for Proceed Anyway
//   }) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final double imageSize = screenWidth * 0.25;
//     final double titleFontSize = screenWidth * 0.06;
//     final double descFontSize = screenWidth * 0.04;
//     final double buttonFontSize = screenWidth * 0.045;
//     final double buttonHeight = screenWidth * 0.12;

//     Alert(
//       context: context,
//       image: Image.asset(
//         "assets/location_icon.png",
//         width: imageSize,
//         height: imageSize,
//         fit: BoxFit.contain,
//       ),
//       title: title,
//       desc: description,
//       style: AlertStyle(
//         titleStyle: TextStyle(
//           fontSize: titleFontSize,
//           fontWeight: FontWeight.bold,
//           color: Colors.black,
//         ),
//         descStyle: TextStyle(
//           fontSize: descFontSize,
//           color: Colors.black54,
//         ),
//       ),
//       buttons: [
//         DialogButton(
//           onPressed: () {
//             Navigator.pop(context);
//             Navigator.push(
//               context,
//               CupertinoPageRoute(builder: (context) => getItNowPage),
//             );
//           },
//           color: Colors.green,
//           height: buttonHeight,
//           child: Text(
//             "Get It Now",
//             style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
//           ),
//         ),
//         DialogButton(
//           onPressed: () {
//             Navigator.pop(context);
//             onProceedAnyway(); // Execute the custom Proceed Anyway callback
//           },
//           color: Colors.red,
//           height: buttonHeight,
//           child: Text(
//             "Proceed Anyway",
//             style: TextStyle(color: Colors.white, fontSize: buttonFontSize),
//           ),
//         ),
//       ],
//     ).show();
//   }
// }

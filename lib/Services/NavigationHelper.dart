import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ServiceableAlert.dart';

class NavigationHelper {
  static const List<String> _serviceablePincodes = ['682030', '682037', '683565'];

  /// [context] - Build context.
  /// [destinationPage] - The page to navigate to.
  /// [checkServiceable] - If true, checks if the current address is within serviceable areas.
  static Future<void> navigateToPage(
    BuildContext context, 
    Widget destinationPage, 
    {bool checkServiceable = false}
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString('currentaddress') ?? '';
    bool isServiceable = _serviceablePincodes.any((pincode) => savedAddress.contains(pincode));

    if (!isServiceable && checkServiceable) {
      ServiceableAlert.show(
        context: context,
        onContinue: () {
          Navigator.push(
            context,
            CupertinoModalPopupRoute(builder: (context) => destinationPage),
          );
        },
      );
    } else {
      Navigator.push(
        context,
        CupertinoModalPopupRoute(builder: (context) => destinationPage),
      );
    }
  }
}

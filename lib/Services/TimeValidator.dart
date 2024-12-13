import 'package:ntp/ntp.dart';

class TimeValidator {
  static Future<bool> validateTime(
      {int allowedDifferenceInSeconds = 300}) async {
    try {
      DateTime serverTime = await NTP.now();
      DateTime deviceTime = DateTime.now().toUtc();

      print('Server Time: $serverTime');
      print('Device Time: $deviceTime');
      print(
          'Time Difference (seconds): ${deviceTime.difference(serverTime).inSeconds}');

      return (deviceTime.difference(serverTime).inSeconds).abs() <=
          allowedDifferenceInSeconds;
    } catch (e) {
      print('Error in time validation: $e');
      return false;
    }
  }
}

import 'package:ntp/ntp.dart';

class TimeService {
  static Future<DateTime> getCurrentTime() async {
    final now = await NTP.now();
    return now;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:erp/model/global.dart' as globals;

class CommonFunction {
  Future<String> getIPAddress() async {
    final response =
        await http.get(Uri.parse('https://api.ipify.org?format=json'));

    if (response.statusCode == 200) {
      final ipData = json.decode(response.body);
      return ipData['ip'];
    } else {
      throw '';
    }
  }

  Future<Position> getCurrentLocation() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      return await Geolocator.getCurrentPosition();
    } else {
      throw Exception('Location permission denied');
    }
  }

  Future<String?> getCityName(double latitude, double longitude) async {
    const apiKey =
        '7ba3ef37e5034a70b762dc74d7f200e0'; // Replace with your API key
    final url =
        'https://api.opencagedata.com/geocode/v1/json?key=$apiKey&q=$latitude+$longitude';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];

      if (results.isNotEmpty) {
        return results[0]['components']['city'] as String?;
      }
    }

    return null;
  }

  Future<String> fetchCity() async {
    try {
      final position = await getCurrentLocation();
      final city = await getCityName(position.latitude, position.longitude);

      if (city != null) {
        return city;
      } else {
        return 'City not found';
      }
    } catch (e) {
      return '';
    }
  }

  Future<Map<String, dynamic>> getCityAndTimeZone(ipAddress) async {
    // Replace with the IP address you want to look up

    final response =
        await http.get(Uri.parse('https://ipinfo.io/$ipAddress/json'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final city = data['city'];
      final timeZone = data['timezone'];
      final location = data['loc'];

      return {'city': city, 'timeZone': timeZone, 'location': location};
    } else {
      return {
        'city': '',
        'timeZone': '',
        'location': '',
      };
    }
  }

  // Function to clear global variables
  void clearGlobals() {
    globals.userCD = '';
    globals.countryCD = '';
  }
}

String getInitials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  } else if (parts.isNotEmpty) {
    return parts[0].substring(0, 2).toUpperCase();
  }
  return '';
}

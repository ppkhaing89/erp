import 'dart:convert';
import 'package:http/http.dart';

class Api {
  apiCall(url, obj) async {
    String username = 'DLINKERP';
    String password = 'EAZ7kiX3uScb8tzYyg8';
    String basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    Response r = await post(Uri.parse('https://erp.dlink.com.sg/api/$url'),
        headers: <String, String>{
          'authorization': basicAuth,
        },
        body: obj);

    return r.body;
  }
}

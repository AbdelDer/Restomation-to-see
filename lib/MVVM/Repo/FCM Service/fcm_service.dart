import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:restomation/Utils/contants.dart';

class FCMServices {
  static Future<http.Response> sendFCM(token, id, title, description) {
    return http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "key=$serverKey",
      },
      body: jsonEncode({
        "to": token.toString(),
        "notification": {
          "title": title,
          "body": description,
        },
        "data": {
          "id": id,
        }
      }),
    );
  }
}

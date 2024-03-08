import 'dart:convert';

import 'package:http/http.dart' as http;

class FrontendToBackendConnection {
  static const String baseURL = "http://localhost:8000";
  final String loginURL = "/login/";

  static Future<dynamic> getData(String urlPattern) async {
    try {
      String fullUrl = baseURL + urlPattern;
      final response = await http.get(Uri.parse(fullUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get-data');
      }
    } catch (e) {
      throw Exception('Network-Error while trying to get data: $e');
    }
  }

  static Future<dynamic> postData(String url, Map<String, dynamic> data) async {
    try {
      String fullUrl = baseURL + url;
      final response = await http.post(Uri.parse(fullUrl), body: data);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to post-data');
      }
    } catch (e) {
      throw Exception('Network-Error while trying to post data: $e');
    }
  }
}

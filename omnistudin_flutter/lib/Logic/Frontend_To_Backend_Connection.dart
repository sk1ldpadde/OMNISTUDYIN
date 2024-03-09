import 'dart:convert';
import 'package:http/http.dart' as http;

class FrontendToBackendConnection {
  // baseURL for the backend server running on the PC!
  static const String baseURL = "http://10.0.2.2:8000/";

  // method to get data from the server
  // urlPattern is the backend endpoint url pattern
  static Future<dynamic> getData(String urlPattern) async {
    try {
      String fullUrl = baseURL + urlPattern;
      final response = await http.get(Uri.parse(fullUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to get data: HTTP status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while trying to get data: $e');
    }
  }

  // Method to send post request to the server
  // urlPattern is the backend endpoint url pattern
  static Future<dynamic> postData(String url, Map<String, dynamic> data) async {
    try {
      String fullUrl = baseURL + url;
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to post data: HTTP status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while trying to post data: $e');
    }
  }

  // Method to send put request to the server
  static Future<dynamic> putData(String url, Map<String, dynamic> data) async {
    try {
      String fullUrl = baseURL + url;
      final response = await http.put(
        Uri.parse(fullUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to put data: HTTP status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error while trying to put data: $e');
    }
  }
}

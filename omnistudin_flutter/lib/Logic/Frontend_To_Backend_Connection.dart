import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_session_jwt/flutter_session_jwt.dart';

class FrontendToBackendConnection {
  // baseURL for the backend server running on the PC!
  static const String baseURL = "http://10.0.2.2:8000/";

  // method to get data from the server
  // urlPattern is the backend endpoint url pattern
  static Future<dynamic> getData(String urlPattern,
      {client = "default"}) async {
    try {
      if (client == "default") {
        client = http.Client();
      }
      String fullUrl = baseURL + urlPattern;
      final response = await client.get(Uri.parse(fullUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to get data: HTTP status ${response.statusCode},  ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while trying to get data: $e');
    }
  }

  // Method to send post request to the server
  // urlPattern is the backend endpoint url pattern
  // data is the data to be sent to the server in a Map, which is basically a JSON object / Python-dictionary
  static Future<dynamic> postData(String url, Map<String, dynamic> data,
      {client = "default"}) async {
    print(data);
    try {
      if (client == "default") {
        client = http.Client();
      }
      String fullUrl = baseURL + url;
      final response = await client.post(
        Uri.parse(fullUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to post data: HTTP status ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while trying to post data: $e');
    }
  }

  // Method to send put request to the server
  // urlPattern is the backend endpoint url pattern
  // data is the data to be sent to the server in a Map, which is basically a JSON object / Python-dictionary
  static Future<dynamic> putData(String url, Map<String, dynamic> data,
      {client = "default"}) async {
    try {
      if (client == "default") {
        client = http.Client();
      }
      String fullUrl = baseURL + url;
      final response = await client.put(
        Uri.parse(fullUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to put data: HTTP status ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while trying to put data: $e');
    }
  }

  // Method to send delete request to the server
  // urlPattern is the backend endpoint url pattern
  static Future<dynamic> deleteData(String url, {client = "default"}) async {
    try {
      if (client == "default") {
        client = http.Client();
      }
      String fullUrl = baseURL + url;
      final response = await client.delete(Uri.parse(fullUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to delete data: HTTP status ${response
                .statusCode},  ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while trying to delete data: $e');
    }
  }

  static Future<http.Response> login(String userName, String password) async {
    try {
      var response = await http.post(
        Uri.parse('https://jsonplaceholder.typicode.com/albums'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'userName': userName,
          'password': password
        }),
      );

      if (response.statusCode == 200) {
        var token = jsonDecode(response.body)['token']; // Korrigiert, um den Token aus der Antwort zu extrahieren
        await FlutterSessionJwt.saveToken(token);
        return response; // Gibt die Antwort zurück, wenn die Anmeldung erfolgreich ist
      } else {
        throw Exception(
            'Failed to login: HTTP status ${response.statusCode}, ${response
                .body}');
      }
    } catch (e) {
      throw Exception('Network error while trying to login: $e');
    }
  }
}
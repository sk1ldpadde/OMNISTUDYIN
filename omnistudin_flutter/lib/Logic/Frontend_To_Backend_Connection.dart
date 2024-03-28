import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_session_jwt/flutter_session_jwt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


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

  // Erstellen Sie eine Instanz von FlutterSecureStorage
  static final storage = new FlutterSecureStorage();

  static Future<http.Response> loginStudent(String email, String password) async {
    try {
      String fullUrl = baseURL + "login/";
      var response = await http.post(
        Uri.parse(fullUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        var token = jsonDecode(response.body)['jwt'];
        // Speichern Sie den Token mit FlutterSecureStorage
        print('Tokennnnnn:');
        print(token);
        print('Info:');
        print(jsonDecode(response.body)['info']);
        await storage.write(key: 'token', value: token);

        // Ausgabe des gespeicherten Tokens
        String? savedToken = await storage.read(key: 'token');
        print('Saved token:');
        print(savedToken);


        return response;
      } else {
        throw Exception(
            'Failed to login: HTTP status ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while trying to login: $e');
    }
  }

  static Future<String?> getToken() async {
    // Lesen Sie den Token mit FlutterSecureStorage
    String? token = await storage.read(key: 'token');

    // Ausgabe des abgerufenen Tokens
    print('Retrieved token:');
    print(token);

    if (token != null) {
      await FlutterSessionJwt.saveToken(token);
    }
    print(await FlutterSessionJwt.getPayload());
    print(await FlutterSessionJwt.getExpirationDateTime());
    // Überprüfen Sie, ob der Token abgelaufen is

    if (await FlutterSessionJwt.isTokenExpired()) {
      token = await updateToken();
    }

    return token;
  }
  static Future<String?> updateToken() async {
    print("Updating token");
    try {
      String fullUrl = baseURL + "update_jwt/";
      var response = await http.get(
        Uri.parse(fullUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        var token = jsonDecode(response.body)['jwt'];
        await storage.write(key: 'token', value: token);
        return token;
      } else {
        throw Exception(
            'Failed to update token: HTTP status ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error while trying to update token: $e');
    }
  }
  }
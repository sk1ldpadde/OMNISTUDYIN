import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:http/http.dart' as http;

import 'package:omnistudin_flutter/Logic/chat_message_service/message.dart';

void startMessagePollingService(SendPort dbIsolatePort, String email) async {
  // create a new isolate
  await Isolate.spawn(
    messagePollingService,
    {'sendPort': dbIsolatePort, 'email': email},
  );
}

void spawnMessagePollingService(SendPort sendPort) {
  messagePollingService({'sendPort': sendPort});
}

void messagePollingService(Map initialData) async {
  const String baseURL = "http://localhost:8000/";

  // Get port and email from initial data map
  SendPort sendPort = initialData['sendPort'];
  String email = initialData['email'];
  String fullUrl = "${baseURL}pull_new_chat_msg/?email=$email";

  Timer.periodic(const Duration(seconds: 2), (Timer t) async {
    // Poll new messages from the server
    var response = await http.get(Uri.parse(fullUrl));

    // Check response status code
    if (response.statusCode != 200) {
      throw Exception('Failed to poll new messages');
    }

    // Parse the response body
    Map<String, dynamic> responseData = jsonDecode(response.body);

    for (var data in responseData["messages"]) {
      // Create a new message object
      Message msg = Message(
        fromStudent: data['fromStudent'],
        content: data['content'],
        timestamp: DateTime.parse(data['timestamp']),
        isRead: data['isRead'] == 1,
        ownMsg: data['own_msg'] == 1,
      );
      print(msg.toString());
      // Insert the message into the database
      sendPort.send(['i', msg]);
    }

    // Notify the main thread that new messages are available
  });
}

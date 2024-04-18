import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;

import 'package:omnistudin_flutter/Logic/chat_message_service/message.dart';


void startMessagePollingService(SendPort mainIsolate, String email, Directory appDocDir) async {
  // create a new isolate
  await Isolate.spawn(
    messagePollingService,
    {'sendPort': mainIsolate, 'email': email, 'appDocDir': appDocDir.path},
  );
}

void messagePollingService(Map initialData) async {
  // Get port and email from initial data map
  SendPort sendPort = initialData['sendPort'];
  String email = initialData['email'];
  Directory appDocDir = Directory(initialData['appDocDir']);

  // create a new receive port
  final receivePort = ReceivePort();

  // Notify main Isolate about send Port
  sendPort.send(receivePort.sendPort);

  String filePath = '${appDocDir.path}/messages.txt';

  // Create a new file
  File file = File(filePath);

  if (!await file.exists()) {
    await file.create();
  }

  // Define a function that inserts messages into the database
  Future<void> insertMessage(Message msg) async {
    // create a new line, if file contains other messages already
    String contents = await file.readAsString();

    if (contents.isNotEmpty) {
      await file.writeAsString("\n", mode: FileMode.append);
    }

    await file.writeAsString(jsonEncode(msg.toMap()), mode: FileMode.append);
  }

  // A method that retrieves all the messages from the messages table.
  Future<List<Message>> getMessages() async {
    List<String> lines = await file.readAsLines();
    List<Message> messages = lines.map((line) => Message.fromJson(jsonDecode(line))).toList();
    return messages;
  }

  /*
  ************************************
  * POLLING SERVICE
  ************************************
   */
  Timer.periodic(const Duration(seconds: 2), (Timer t) async {
    // Poll new messages from the server
    var response = await http.get(Uri.parse('http://10.0.2.2:8000/pull_new_chat_msg/?email=$email'));

    print("POLLING ...");

    // Check response status code
    if (response.statusCode != 200) {
      throw Exception('Failed to poll new messages');
    }

    // Parse the response body
    Map<String, dynamic> responseMap = jsonDecode(response.body);
    List? responseData = responseMap['messages'];

    for (var data in responseData!) {
      // Create a new message object
      Message msg = Message(
        fromStudent: data['from_student'],
        content: data['content'],
        timestamp: DateTime.parse(DateTime.now().toIso8601String()), //DateTime.parse(data['timestamp']),
        isRead: data['isRead'] == 1,
        ownMsg: data['own_msg'] == 1,
      );

      // Store message in text file
      insertMessage(msg);
    }

    // Notify the main thread that new messages are available
  });


  /*
  *********************************
  * MAIN ISOLATE MESSAGE HANDLING
  *********************************
   */

  /// Listen to messages sent to Mike's receive port
  await for (var message in receivePort) {
    if (message is List) {
      if (message[0] == 'g') {
        /// Get main response sendPort
        final SendPort mainResponsePort = message[1];
        /// Send Response with Message List
        mainResponsePort.send(await getMessages());
      }
    }
  }

}

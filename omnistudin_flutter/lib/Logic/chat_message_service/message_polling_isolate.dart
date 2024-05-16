import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:omnistudin_flutter/Logic/chat_message_service/message.dart';
import 'package:omnistudin_flutter/Logic/Frontend_To_Backend_Connection.dart';


void startMessagePollingService(SendPort mainIsolate, String email, Directory appDocDir) async {
  // create a new isolate
  await Isolate.spawn(
    messagePollingService,
    {'sendPort': mainIsolate, 'email': email, 'appDocDir': appDocDir.path},
  );
}
// In message_polling_isolate.dart

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
  Future<List<Message>> getMessages() async {
    List<String> lines = await file.readAsLines();
    List<Message> messages = lines.map((line) => Message.fromJson(jsonDecode(line))).toList();
    return messages;
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


  // A Method to retrieve all messages associated with one specific chat partner
  Future<List<Message>> getAllMessageWith(String withStudent) async {
    List<Message> messages = await getMessages();

    // Filter the messages for all messages associated with the given student
    List<Message> filteredMessages = messages.where((message) => message.fromStudent == withStudent).toList();

    // TODO set isRead to True and save persistent

    return filteredMessages;
  }

  // A Method to send out a new message
  int sendOwnMessage(final String fromStudent, final String toStudent, final String content) {
    Map<String, String> jsonPayload = {};
    jsonPayload["from_student"] = fromStudent;
    jsonPayload["to"] = toStudent;
    jsonPayload["content"] = content;
    jsonPayload["timestamp"] = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());

    // Send message: for the receiving student, ownMsg = 0
    var response = FrontendToBackendConnection.postData("send_chat_msg/", jsonPayload);

    // TODO error handling for response

    // Set ownMsg = 1 and Save message in local file
    Message ownMsg = Message(
        fromStudent: toStudent,
        content: content,
        timestamp: DateTime.parse(DateTime.now().toIso8601String()),
        isRead: true,
        ownMsg: true
    );



    insertMessage(ownMsg);

    return 1;
  }

  // A Method to retrieve all distinct chat partners with the last message associated
  Future<List<Message>> getDistinctChatPartners() async {
    List<Message> messages = await getMessages();
    Map<String, Message> distinctPartners = {};

    for (var message in messages) {
      distinctPartners[message.fromStudent] = message;
    }

    return distinctPartners.values.toList();
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
        timestamp: DateFormat('dd-MM-yyyy HH:mm:ss').parse(data['timestamp']),
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

  // Listen to requests
  await for (var message in receivePort) {
    if (message is List) {

      // Get main response sendPort
      final SendPort mainResponsePort = message[1];

      switch (message[0]) {
        // Get all messages
        case 'g': {
          mainResponsePort.send(await getMessages());
        } break;
        // Send own message
        case 's': {
          // message[2] defines a list with: fromStudent, toStudent and content
          sendOwnMessage(message[2][0], message[2][1], message[2][2]);
        } break;
        // Get distinct chat partners
        case 'd': {
          mainResponsePort.send(await getDistinctChatPartners());
        }
        // Get all chat messages associated with xy
        case 'w': {
          // message[2] defines xy
          mainResponsePort.send(await getAllMessageWith(message[2][0]));
        } break;

        default: {
          mainResponsePort.send(-1);
        }
      }
    }
  }

}

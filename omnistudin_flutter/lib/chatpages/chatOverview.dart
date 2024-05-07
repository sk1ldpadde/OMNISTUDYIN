import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/Logic/chat_message_service/message.dart';
import 'package:omnistudin_flutter/Logic/chat_message_service/message_polling_isolate.dart'; // Stellen Sie sicher, dass spawnMessagePollingService hier definiert ist

class ChatOverviewPage extends StatefulWidget {
  @override
  _ChatOverviewPageState createState() => _ChatOverviewPageState();
}

class _ChatOverviewPageState extends State<ChatOverviewPage> {
  late final SendPort _pollingServicePort;
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final mainReceivePort = ReceivePort();
    await Isolate.spawn(spawnMessagePollingService, mainReceivePort.sendPort); // Änderung hier
    _pollingServicePort = await mainReceivePort.first;
    Timer.periodic(const Duration(seconds: 2), (Timer t) async {
      final pollingResponsePort = ReceivePort();
      _pollingServicePort.send(['w', pollingResponsePort.sendPort, ['inf21113@gmail.com']]);
      final response = await pollingResponsePort.first;
      setState(() {
        _messages = response as List<Message>;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current chats'),
      ),
      body: ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return ListTile(
            title: Text(message.content),
            subtitle: Text('From: ${message.fromStudent}, Time: ${message.timestamp}'),
          );
        },
      ),
    );
  }
}
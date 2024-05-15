import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:omnistudin_flutter/pages/friend_page.dart';
import 'package:omnistudin_flutter/chatpages/chatPage.dart';
import 'package:omnistudin_flutter/Logic/chat_message_service/message.dart';
import 'package:omnistudin_flutter/Logic/chat_message_service/message_polling_isolate.dart';

class ChatOverviewPage extends StatefulWidget {
  @override
  _ChatOverviewPageState createState() => _ChatOverviewPageState();
}

class _ChatOverviewPageState extends State<ChatOverviewPage> {
  late final Map<String, SendPort> _pollingServicePorts = {};
  List<String> _chats = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await _fetchChats();
  }

  Future<List<String>> getFriends() async {
    FriendsPageState friendsPageState = FriendsPageState();
    return await friendsPageState.getFriendEmailsPublic();
  }

  Future<void> _fetchChats() async {
    await createChatsForFriends();
    setState(() {});
  }

  Future<void> createChatsForFriends() async {
    List<String> friends = await getFriends();
    for (String friend in friends) {
      _chats.add(friend);
      ReceivePort friendReceivePort = ReceivePort();
      startMessagePollingService(
          friendReceivePort.sendPort, friend, await getApplicationDocumentsDirectory());
      SendPort friendSendPort = await friendReceivePort.first;
      _pollingServicePorts[friend] = friendSendPort;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: _chats.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return InkWell(
            onTap: () {
              SendPort? sendPort = _pollingServicePorts[chat];
              if (sendPort != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      email: chat,
                      sendPort: sendPort,
                    ),
                  ),
                );
              } else {
                print('Error: SendPort for $chat is null');
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    child: Text(chat[0]),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6.0),
                        Text(
                          index == 0 ? 'Its 2!' : 'Thank you, for your help°-°', // Hier die Bedingung hinzufügen
                          style: TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    index == 0 ? '09:42': '07:22', // Hier die Zeit der letzten Nachricht einfügen
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

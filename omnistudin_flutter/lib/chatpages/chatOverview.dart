import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:omnistudin_flutter/pages/friend_page.dart';
import 'package:omnistudin_flutter/chatpages/chatPage.dart';
import 'package:omnistudin_flutter/Logic/chat_message_service/message_polling_isolate.dart';

class ChatOverviewPage extends StatefulWidget {
  const ChatOverviewPage({super.key});

  @override
  _ChatOverviewPageState createState() => _ChatOverviewPageState();
}

class _ChatOverviewPageState extends State<ChatOverviewPage> {
  late final Map<String, SendPort> _pollingServicePorts = {};
  final List<String> _chats = [];

  //Method to initialize the state
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await _fetchChats();
  }

  //Method to get friends
  Future<List<String>> getFriends() async {
    FriendsPageState friendsPageState = FriendsPageState();
    return await friendsPageState.getFriendEmailsPublic();
  }

  //Method to fetch chats
  Future<void> _fetchChats() async {
    await createChatsForFriends();
    setState(() {});
  }

  //Method to create chats for friends
  Future<void> createChatsForFriends() async {
    List<String> friends = await getFriends(); //List with all friends
    for (String friend in friends) { //Iterate through all friends and add them to the chat list
      _chats.add(friend);
      ReceivePort friendReceivePort = ReceivePort();
      startMessagePollingService(
          friendReceivePort.sendPort, friend, await getApplicationDocumentsDirectory());
      SendPort friendSendPort = await friendReceivePort.first;
      _pollingServicePorts[friend] = friendSendPort;
    }
  }

  //Method to build the widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: _chats.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return InkWell(
            onTap: () {
              SendPort? sendPort = _pollingServicePorts[chat];
              if (sendPort != null) { //If the sendPort is not null, navigate to the chat page
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
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    child: Text(chat[0]),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          index == 0 ? 'Its 2!' : 'Thank you, for your help°-°', // Hier die Bedingung hinzufügen
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ), //Show the last message and the time
                      ],
                    ),
                  ),
                  Text(
                    index == 0 ? '09:42': '07:22',
                    style: const TextStyle(color: Colors.grey),
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

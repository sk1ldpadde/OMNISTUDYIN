import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:omnistudin_flutter/pages/friend_page.dart';
import 'package:omnistudin_flutter/chatpages/chatPage.dart';
import 'package:omnistudin_flutter/Logic/chat_message_service/message.dart';
import 'package:omnistudin_flutter/Logic/chat_message_service/message_polling_isolate.dart'; // Stellen Sie sicher, dass spawnMessagePollingService hier definiert ist

class ChatOverviewPage extends StatefulWidget {
  @override
  _ChatOverviewPageState createState() => _ChatOverviewPageState();
}

class _ChatOverviewPageState extends State<ChatOverviewPage> {
  late final Map<String, SendPort> _pollingServicePorts = {}; // Map von Freund-Emails zu SendPorts
  List<String> _chats = []; // Liste der Chats

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    // Start the message database service as an isolate
    ReceivePort mainReceivePort = ReceivePort();
    // Start the message polling service as an isolate
    await _fetchChats();

    }


  Future<List<String>> getFriends() async {
    FriendsPageState friendsPageState = FriendsPageState(); // Erstellen Sie eine Instanz von FriendsPageState
    List<String> friendEmails = await friendsPageState.getFriendEmailsPublic(); // Rufen Sie die getFriendEmailsPublic Methode auf
    print(friendEmails);
    print("gerfriends");
    return friendEmails;
  }


  Future <void> _fetchChats() async {
    await createChatsForFriends(); // Erstellen Sie Chats für Freunde
    setState(() {}); // Aktualisieren Sie die Ansicht, um die Chats anzuzeigen
  }

  Future <void> createChatsForFriends() async {
    List<String> friends = await getFriends(); // Rufen Sie die Freunde ab
    print(friends); // Debug-Ausgabe (optional)
    for (String friend in friends) { // Durchlaufen Sie die Liste der Freunde
      _chats.add(friend); // Fügen Sie jeden Freund zur _chats-Liste hinzu
 // Erstellen Sie einen neuen ReceivePort für diesen Freund
      ReceivePort friendReceivePort = ReceivePort();
      // Starten Sie den MessagePollingService für diesen Freund
      startMessagePollingService(friendReceivePort.sendPort, friend, await getApplicationDocumentsDirectory());
      // Speichern Sie den SendPort für diesen Freund
      SendPort friendSendPort = await friendReceivePort.first;
      _pollingServicePorts[friend] = friendSendPort;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current chats'),
      ),
      body: _chats.isEmpty
          ? Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return Card( // Verwenden Sie ein Card Widget
            child: ListTile(
              leading: CircleAvatar( // Fügen Sie ein CircleAvatar Widget hinzu
                child: Text(chat[0]), // Zeigen Sie den ersten Buchstaben des Chat-Namens an
              ),
              title: Text(chat),
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
                  // Handle the case where sendPort is null
                  // For example, show an error message
                  print('Error: SendPort for $chat is null');
                }
              },
            ),
          );
        },
      ),
    );
  }
}

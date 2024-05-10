import 'dart:isolate';

import 'package:flutter/cupertino.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/app.dart';
import 'package:omnistudin_flutter/pages/home_page.dart';
import 'package:omnistudin_flutter/pages/profile_page.dart';
import 'package:omnistudin_flutter/pages/friend_page.dart';
import 'package:omnistudin_flutter/register/login.dart';
import 'package:provider/provider.dart';
import '../Logic/Frontend_To_Backend_Connection.dart';
import 'Logic/chat_message_service/message_polling_isolate.dart';
import 'Logic/chat_message_service/message_persistence_isolate.dart';
import 'Logic/chat_message_service/message.dart';
import 'package:intl/intl.dart';

void main() async {
  // runApp(OmniStudyingApp());
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(
    LandingPage(),
  );

  /************************
  // CHAT MESSAGING SERVICES
  *************************/
  List MessageList = [];
  ReceivePort mainReceivePort = ReceivePort();

  // Start the message database service as an isolate
  startMessagePersistenceService(mainReceivePort);

  // Get the send port of the message persistence service
  SendPort dbIsolatePort = await mainReceivePort.first;

  // Start the message polling service as an isolate
  startMessagePollingService(dbIsolatePort, 'ma@gmail.com');

  // Create a response port and immediately set up a listener.
  ReceivePort responsePort = ReceivePort();
  responsePort.listen((message) {
    MessageList.add(message);
    // Log or process the answer received from the isolate
  });

  // Inform the database isolate about where to send responses.
  // Assuming the database service is expecting a "setupResponsePort" message with a SendPort.
  dbIsolatePort.send(["setupResponsePort", responsePort.sendPort]);

  // Now send a message to the database isolate asking for data.
  dbIsolatePort.send(["g"]);

  Message msg = Message(
      fromStudent: "ma@gmail.com",
      content: "Hello",
      timestamp: DateTime.now(),
      isRead: false,
      ownMsg: true);
  Map<String, dynamic> msgMap = msg.toMap();
  msgMap["to"] = "ma@gmail.com";
  msgMap["timestamp"] = DateFormat('dd-MM-yyyy HH:mm:ss').format(msg.timestamp);
  FrontendToBackendConnection.postData("send_chat_msg/", msgMap);
  while (true) {
    // Now send a message to the database isolate asking for data.
    dbIsolatePort.send(["g"]);
    await Future.delayed(Duration(seconds: 5));
    print(MessageList);
  }
}

// Method for Landing Page
class LandingPage extends StatefulWidget {
  const LandingPage({super.key}); //Constructor for Landing Page

  @override
  _LandingPageState createState() =>
      _LandingPageState(); //Create State for Landing Page
}

// State for Landing Page
class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0; // Index for the current page

  bool _isLoggedIn = false; // Set this value based on your login status
  //late bool _showSearchBar;

  final List<Widget> _pages = [
    // List of pages
    const HomePage(),
    const FriendsPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    // Initialize the state
    super.initState();
    //_showSearchBar = false;
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // Check the login status
    var token = await FrontendToBackendConnection.getToken(); // Get the token
    setState(() {
      // Set the state
      _isLoggedIn = token != null;
    });
  }

  void checkLoginStatus() {
    // Check the login status
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/', // Set the initial route
      routes: {
        // Set the routes
        '/home': (context) => const HomePage(),
        '/friends': (context) => const FriendsPage(),
        '/profile': (context) => const ProfilePage(),
      },
      home: FutureBuilder(
        future: FrontendToBackendConnection.getToken(), // Get the token
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // Build the context
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show the circular progress indicator if the connection state is waiting
          } else {
            _isLoggedIn = snapshot.data != null; // Set the login status
            return Scaffold(
              body: _isLoggedIn
                  ? _pages[_currentIndex] // Show the current page
                  : LoginPage(
                      onLoginSuccess: _checkLoginStatus), // Show the login page
              bottomNavigationBar: _isLoggedIn
                  ? BottomNavigationBar(
                      currentIndex: _currentIndex,
                      onTap: (index) {
                        setState(() {
                          // Set the state
                          _currentIndex = index; // Set the current index
                        });
                      },
                      items: const [
                        //Set the bottom navigation bar items
                        BottomNavigationBarItem(
                          icon: Icon(Icons.home),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.people),
                          label: 'Find Friends',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.person),
                          label: 'Profile',
                        ),
                      ],
                      selectedItemColor: const Color(0xFFf46139),
                      unselectedItemColor: const Color(0xFFf7b29f),
                    )
                  : null,
            );
          }
        },
      ),
    );
  }
}

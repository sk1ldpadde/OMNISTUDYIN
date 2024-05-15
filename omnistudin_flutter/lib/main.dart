import 'dart:isolate';
import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/app.dart';
import 'package:path_provider/path_provider.dart';
import 'Logic/chat_message_service/message.dart';
import 'package:omnistudin_flutter/pages/home_page.dart';
import 'package:omnistudin_flutter/pages/profile_page.dart';
import 'package:omnistudin_flutter/pages/friend_page.dart';
import 'package:omnistudin_flutter/chatpages/chatOverview.dart';
import 'package:omnistudin_flutter/register/login.dart';
import 'package:provider/provider.dart';
import '../Logic/Frontend_To_Backend_Connection.dart';
import 'Logic/chat_message_service/message_polling_isolate.dart';
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
  ReceivePort mainReceivePort = ReceivePort();

  // Start the message polling service as an isolate
  startMessagePollingService(mainReceivePort.sendPort, 'inf21111@gmail.com',
      await getApplicationDocumentsDirectory());

  // Receive send port of polling Isolate
  SendPort pollingServicePort = await mainReceivePort.first;

  // Periodically print ALL stored messages
  Timer.periodic(const Duration(seconds: 2), (Timer t) async {
    // Create new port for responses from polling Isolate
    ReceivePort pollingResponsePort = ReceivePort();

    // Get all messages
    pollingServicePort.send([
      'w',
      pollingResponsePort.sendPort,
      ['inf21113@gmail.com']
    ]);

    // Listen for response
    final pollingServiceResponse = await pollingResponsePort.first;

    // Print message for debug
    final List<Message> messages = await pollingServiceResponse;

    for (var message in messages) {
      print(message);
    }
  });
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
    ChatOverviewPage(),

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
        '/chat': (context) => ChatOverviewPage(),
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
                        BottomNavigationBarItem(
                          icon: Icon(Icons.chat),
                          label: 'Chat',
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

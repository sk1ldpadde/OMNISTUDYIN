import 'dart:async';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/app.dart';
import 'package:omnistudin_flutter/pages/home_page.dart';
import 'package:omnistudin_flutter/pages/profile_page.dart';
import 'package:omnistudin_flutter/pages/findfriends_page.dart';
import 'package:omnistudin_flutter/register/login.dart';
import 'package:path_provider/path_provider.dart';
import '../Logic/Frontend_To_Backend_Connection.dart';
import 'Logic/chat_message_service/message.dart';
import 'Logic/chat_message_service/message_polling_isolate.dart';

void main() async{
  runApp(OmniStudyingApp());
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(LandingPage());

  /************************
  // CHAT MESSAGING SERVICES
  *************************/
  ReceivePort mainReceivePort = ReceivePort();

  // Start the message polling service as an isolate
  startMessagePollingService(mainReceivePort.sendPort, 'inf21111@gmail.com', await getApplicationDocumentsDirectory());

  // Receive send port of polling Isolate
  SendPort pollingServicePort = await mainReceivePort.first;

  // Periodically print ALL stored messages
  Timer.periodic(const Duration(seconds: 2), (Timer t) async {
    // Create new port for responses from polling Isolate
    ReceivePort pollingResponsePort = ReceivePort();

    // Get all messages
    pollingServicePort.send(['g', pollingResponsePort.sendPort]);

    // Listen for response
    final pollingServiceResponse = await pollingResponsePort.first;

    // Print message for debug
    final List<Message> messages = await pollingServiceResponse;

    for (var message in messages) {
      print(message);
    }
  });
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0;
  bool _isLoggedIn = false; // Set this value based on your login status
  late bool _showSearchBar;

  final List<Widget> _pages = [
    HomePage(),
    FindFriendsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _showSearchBar = false;
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    var token = await FrontendToBackendConnection.getToken();
    setState(() {
      _isLoggedIn = token != null;
    });
  }

  void checkLoginStatus() {
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: FrontendToBackendConnection.getToken(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Zeigen Sie einen Ladeindikator an, während auf den Token gewartet wird
          } else {
            _isLoggedIn = snapshot.data != null;
            return Scaffold(
              body: _isLoggedIn ? _pages[_currentIndex] : LoginPage(onLoginSuccess: _checkLoginStatus),
              bottomNavigationBar: _isLoggedIn ? BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: const[
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
                selectedItemColor: Colors.amber,
                unselectedItemColor: Colors.blue,
              ) : null,
            );
          }
        },
      ),
    );
  }
}
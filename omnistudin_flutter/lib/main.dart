import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/app.dart';
import 'package:omnistudin_flutter/pages/home_page.dart';
import 'package:omnistudin_flutter/pages/profile_page.dart';
import 'package:omnistudin_flutter/pages/findfriends_page.dart';
import 'package:omnistudin_flutter/register/login.dart';
import '../Logic/Frontend_To_Backend_Connection.dart';

void main() {
  runApp(OmniStudyingApp());
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(LandingPage());
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
              body: _isLoggedIn
                  ? _pages[_currentIndex]
                  : LoginPage(onLoginSuccess: _checkLoginStatus),
              bottomNavigationBar: _isLoggedIn
                  ? BottomNavigationBar(
                      currentIndex: _currentIndex,
                      onTap: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      items: const [
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
                      selectedItemColor: Color(0xFFf46139),
                      unselectedItemColor: Color(0xFFf7b29f),
                    )
                  : null,
            );
          }
        },
      ),
    );
  }
}

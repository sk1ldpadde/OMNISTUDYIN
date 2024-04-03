import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/Logic/Frontend_To_Backend_Connection.dart';
import '../register/login.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showSearchBar = false;

  void clearLocalStorage() async {
    await FrontendToBackendConnection.clearStorage();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearchBar ? TextField() : Text('Home'),
        leading: IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            // Add your create post logic here
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.audiotrack),
            onPressed: () {
              clearLocalStorage();
            },
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification) {
            setState(() {
              _showSearchBar = scrollNotification.scrollDelta! < 0;
            });
          }
          return true;
        },
        child: ListView.builder(
          itemCount: 100, // Replace with your actual item count
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Item $index'),
            );
          },
        ),
      ),
    );
  }
}
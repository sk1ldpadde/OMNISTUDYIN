import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showSearchBar = false;

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

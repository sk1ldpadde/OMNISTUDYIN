import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FindFriendsPage extends StatefulWidget {
//  final int tabIndex;
//  const FindFriendsPage({super.key, required this.tabIndex});

  @override
  _FindFriendsPageState createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends State<FindFriendsPage> {
  List<dynamic> friendsList = []; // List to hold friends data

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    var url =
        'http://yourdjangoapi.com/api/friends'; // Replace with your API URL
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          friendsList = json.decode(response.body);
        });
      } else {
        print('Failed to load friends');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          width: 280,
          height: 400,
          child: Image.asset('assets/images/logo_name.png'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: friendsList.length,
                itemBuilder: (context, index) {
                  return CupertinoListTile(
                    leading: const Icon(CupertinoIcons.profile_circled),
                    title: Text(friendsList[index]
                        ['name']), // Adjust based on your data structure
                    trailing: const Icon(CupertinoIcons.add_circled),
                    onTap: () {
                      // Your code for adding a friend
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

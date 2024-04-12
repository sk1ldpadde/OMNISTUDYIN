import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:omnistudin_flutter/Logic/Frontend_To_Backend_Connection.dart';

class FriendsPage extends StatefulWidget {
//  final int tabIndex;
//  const FindFriendsPage({super.key, required this.tabIndex});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  List<dynamic> friendsList = []; // List to hold friends data

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    FrontendToBackendConnection.getData("get_friends/").then((data) {
      if (data is http.Response) {
        if (data.statusCode == 200) {
          setState(() {
            friendsList = json.decode(data.body);
            print(friendsList);
          });
        } else {
          print('Failed to load friends');
        }
      } else if (data is List<dynamic>) {
        setState(() {
          friendsList = data;
          print(friendsList);
        });
      }
    });
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
                  return Card(
                    child: ListTile(
                      leading: friendsList[index]['profile_picture'] != null
                          ? ClipOval(
                              child: Image.memory(base64Decode(
                                  friendsList[index]['profile_picture'])),
                            )
                          : Icon(Icons
                              .person), // replace with actual image if available
                      title: Text(friendsList[index]['forename'] ??
                          'No name'), // use 'forename' field
                      subtitle: Text(friendsList[index]['bio'] ??
                          'No bio'), // use 'bio' field
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Center(
                                child: Text(
                                  '${friendsList[index]['forename']} ${friendsList[index]['surname'] ?? ''}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    if (friendsList[index]['profile_picture'] !=
                                        null)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Center(
                                          child: ClipOval(
                                            child: Image.memory(base64Decode(
                                                friendsList[index]
                                                    ['profile_picture'])),
                                          ),
                                        ),
                                      ),
                                    if (friendsList[index]['bio'] != null)
                                      RichText(
                                        text: TextSpan(
                                          text: 'Bio:\n',
                                          style: DefaultTextStyle.of(context)
                                              .style
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    '${friendsList[index]['bio']}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal)),
                                          ],
                                        ),
                                      ),
                                    if (friendsList[index]['uni_name'] != null)
                                      RichText(
                                        text: TextSpan(
                                          text: 'University:\n',
                                          style: DefaultTextStyle.of(context)
                                              .style
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    '${friendsList[index]['uni_name']}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal)),
                                          ],
                                        ),
                                      ),
                                    if (friendsList[index]['degree'] != null)
                                      RichText(
                                        text: TextSpan(
                                          text: 'Degree:\n',
                                          style: DefaultTextStyle.of(context)
                                              .style
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    '${friendsList[index]['degree']}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal)),
                                          ],
                                        ),
                                      ),
                                    if (friendsList[index]['semester'] != null)
                                      RichText(
                                        text: TextSpan(
                                          text: 'Semester:\n',
                                          style: DefaultTextStyle.of(context)
                                              .style
                                              .copyWith(
                                                  fontWeight: FontWeight.bold),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    '${friendsList[index]['semester']}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal)),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
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

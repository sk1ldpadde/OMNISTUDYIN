import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:omnistudin_flutter/Logic/Frontend_To_Backend_Connection.dart';
import 'package:omnistudin_flutter/pages/findfriends_page.dart';
import 'package:omnistudin_flutter/chatpages//chatPage.dart'; // Importieren Sie die Chat-Seite

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

// friend_page.dart
class FriendsPageState extends _FriendsPageState {
  // Hier können Sie öffentliche Methoden und Eigenschaften definieren, die von anderen Dateien aufgerufen werden können
  Future<List<String>> getFriendEmailsPublic() async {
    return await getFriendEmails();
  }
}

class _FriendsPageState extends State<FriendsPage> with WidgetsBindingObserver {
  List<dynamic> friendsList = []; // List to hold friends data
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();


  Future<List<String>> getFriendEmailsPublic() {
    return getFriendEmails();
  }

  Future<List<String>> getFriendEmails() async {
    List<String> friendEmails = [];
    await FrontendToBackendConnection.getData("get_friends/").then((data) {
      if (data is http.Response) {
        if (data.statusCode == 200) {
          friendsList = json.decode(data.body);
        } else {
          print('Failed to load friends');
        }
      } else if (data is List<dynamic>) {
        friendsList = data;
      }
      print(friendsList);
    });
    for (var friend in friendsList) {
      friendEmails.add(friend['email']);
      print(friend['email']);
    }
    return friendEmails;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //addTestFriend();
    fetchFriends();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("App resumed");
      fetchFriends();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void addTestFriend() {
    setState(() {
      friendsList.add({
        'email': 'testfriend@example.com',
        'forename': 'Test',
        'surname': 'Friend',
        'bio': 'This is a test friend for testing the chat function.',
        'uni_name': 'Test University',
        'degree': 'Test Degree',
        'semester': 'Test Semester',
        'profile_picture': null, // Sie können hier ein Bild hinzufügen, wenn Sie möchten
        'friendship_status': 'accepted',
      });
    });
  }

  Future<void> fetchFriends() async {
    FrontendToBackendConnection.getData("get_friends/").then((data) {
      if (data is http.Response) {
        if (data.statusCode == 200) {
          setState(() {
            friendsList = json.decode(data.body);
          });
        } else {
          print('Failed to load friends');
        }
      } else if (data is List<dynamic>) {
        setState(() {
          friendsList = data;
        });
      }
      print(friendsList);
    });
  }

  Future<void> deleteFriend(String email) async {
    await FrontendToBackendConnection.postData(
        "delete_friend/", {"friend_email": email}).then((response) {
      var responseData = response;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Friend'),
            content: response["success"] != null
                ? Text(responseData["success"])
                : response["error"] != null
                ? Text(responseData["error"])
                : const Text('An error occurred'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
    fetchFriends();
  }

  Future<void> addFriend(String email) async {
    await FrontendToBackendConnection.postData(
        "send_friend_request/", {"friend_email": email}).then((response) {
      var responseData = response;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Friend Request'),
            content: response["success"] != null
                ? Text(responseData["success"])
                : response["error"] != null
                ? Text(responseData["error"])
                : const Text('An error occurred'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: SizedBox(
          width: 280,
          height: 400,
          child: Image.asset('assets/images/logo_name.png'),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Add a friend'),
                    content: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Enter friend\'s email',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email';
                          }
                          return null;
                        },
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Add'),
                        onPressed: () {
                          if (_formKey.currentState != null &&
                              _formKey.currentState!.validate()) {
                            addFriend(_emailController.text);
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
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
                          : const Icon(Icons
                          .person), // replace with actual image if available
                      title: Text(friendsList[index]['forename'] ??
                          'No name'), // use 'forename' field
                      subtitle: Text(friendsList[index]['bio'] ??
                          'No bio'), // use 'bio' field
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          friendsList[index]['friendship_status'] == "pending"
                              ? GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Friend Request'),
                                    content: const Text('Delete friend request?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('Delete'),
                                        onPressed: () {
                                          deleteFriend(
                                              friendsList[index]['email']);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child:
                            Text(friendsList[index]['friendship_status']),
                          )
                              : PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                deleteFriend(friendsList[index]['email']);
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Center(
                                child: Text(
                                  '${friendsList[index]['forename']} ${friendsList[index]['surname'] ?? ''}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                                                style: const TextStyle(
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
                                                style: const TextStyle(
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
                                                style: const TextStyle(
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
                                                style: const TextStyle(
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
                                  child: const Text('Close'),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CupertinoButton(
          color: Colors.orange,
          child: const Text('Find Friends'),
          onPressed: () {
            final result = Navigator.push(context,
                CupertinoPageRoute(builder: (context) => const FindFriendsPage()));
            result.then((value) {
              if (value == 'fetchFriends') {
                print('fetching friends');
                fetchFriends();
              }
            });
          },
        ),
      ),
    );
  }
}
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';


class OmniStudyingApp extends StatelessWidget {
  const OmniStudyingApp({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: OmniStudyingHomepage(),
    );
  }
}

class OmniStudyingHomepage extends StatefulWidget {
  const OmniStudyingHomepage({super.key});

  @override
  State<OmniStudyingHomepage> createState() => _OmniStudyingHomepageState();
}

class _OmniStudyingHomepageState extends State<OmniStudyingHomepage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_circle),
            label: 'My Profile',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (BuildContext context) {
            return CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                middle: Text('Page 1 of tab $index'),
              ),
              child: Center(
                child: CupertinoButton(
                  child: const Text('Next page'),
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute<void>(

                        builder: (BuildContext context) =>
                            FindFriendsPage(tabIndex: index),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class FindFriendsPage extends StatefulWidget {
  final int tabIndex;
  const FindFriendsPage({super.key, required this.tabIndex});

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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Find Friends'),
      ),
      child: SafeArea(
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
            Align(
              alignment: Alignment.bottomCenter,
              child: CupertinoButton(
                child: const Text('Back'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

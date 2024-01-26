import 'package:flutter/cupertino.dart';

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

class FindFriendsPage extends StatelessWidget {
  final int tabIndex;
  const FindFriendsPage({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Find Friends'),
      ),
      child: SafeArea(
        // Added SafeArea for better UI layout
        child: Column(
          // Changed to Column to include both list and button
          children: [
            Expanded(
              // Wrap the list in Expanded to use available space
              child: CupertinoListSection(
                header: const Text("Add Friends"),
                children: [
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.profile_circled),
                    title: const Text('John Doe'),
                    trailing: const Icon(CupertinoIcons.add_circled),
                    onTap: () {
                      showCupertinoModalPopup<void>(
                        context: context,
                        builder: (BuildContext context) => CupertinoActionSheet(
                          title: const Text('Add "John Doe" as a friend?'),
                          message: const Text(
                              'Your friend will be able to see your location.'),
                          actions: <CupertinoActionSheetAction>[
                            CupertinoActionSheetAction(
                              child: const Text('Add Friend'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            child: const Text('Cancel'),
                            isDefaultAction: true,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
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

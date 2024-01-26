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
                        builder: (BuildContext context) {
                          return CupertinoPageScaffold(
                            navigationBar: CupertinoNavigationBar(
                              middle: Text('Page 2 of tab $index'),
                            ),
                            child: Center(
                              child: CupertinoButton(
                                child: const Text('Back'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                          );
                        },
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

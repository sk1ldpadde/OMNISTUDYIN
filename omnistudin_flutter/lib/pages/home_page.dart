import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/Logic/Frontend_To_Backend_Connection.dart';
import '../register/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

// String jwtToken =
//     'your_initial_token'; // Replace 'your_initial_token' with the actual JWT token

// Future<List<AdInGroup>> fetchAdGroups() async {
//   final response =
//       await http.get(Uri.parse('http://10.0.2.2:8000/get_adgroups/'));

//   if (response.statusCode == 200) {
//     Iterable l = json.decode(response.body);
//     List<AdInGroup> adGroups =
//         List<AdInGroup>.from(l.map((model) => AdInGroup.fromJson(model)));
//     return adGroups;
//   } else {
//     throw Exception('Failed to load AdGroups');
//   }
// }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showSearchBar = false;
  List<AdInGroup> _adsInGroup = [];

  @override
  void initState() {
    super.initState();
    initializeState();
  }

  void initializeState() async {
    var token = await FrontendToBackendConnection.getToken();
    FrontendToBackendConnection.fetchAdGroups(token!)
        .then((value) => setState(() {
              _adsInGroup = value;
            }));
  }

  void _addNewAdsInGroup(
      String adgroupname, String title, String description) async {
    Map<String, String> newAd = {
      "ad_group_name": adgroupname,
      "title": title,
      "description": description
    };
    var resOfCreate = await FrontendToBackendConnection.postData(
        "create_ads_in_group/", newAd);
    print(resOfCreate);
    var MapListOfAdsInGroup = await FrontendToBackendConnection.postData(
        "get_ads_of_group/", {"ad_group_name": adgroupname});
    _adsInGroup = [];
    for (int i = 0; i < MapListOfAdsInGroup.length; i++) {
      _adsInGroup.add(AdInGroup(
          adGroupName: MapListOfAdsInGroup[i]['ad_group_name'],
          name: MapListOfAdsInGroup[i]['title'],
          description: MapListOfAdsInGroup[i]['description']));
    }
    print(_adsInGroup);
  }

  void _addNewAdGroup(String name, String description) async {
    Map<String, String> adgroup = {
      'name': name,
      'description': description,
    };
    var resOfCreate =
        await FrontendToBackendConnection.postData("create_adgroup/", adgroup);
    print(resOfCreate);
    // var MapListOfAdsInGroup =
    //     await FrontendToBackendConnection.getData("get_adgroups/");
    // _adGroups = [];
    // for (int i = 0; i < MapListOfAdsInGroup.length; i++) {
    //   _adGroups.add(AdGroup(
    //       name: MapListOfAdsInGroup[i]['name'],
    //       description: MapListOfAdsInGroup[i]['description']));
    // }
  }

  void _deleteAdGroup(int index, String name) async {
    Map<String, String> adgroup = {
      'name': name,
    };
    var token = await FrontendToBackendConnection.getToken();
    try {
      await FrontendToBackendConnection.deleteAdGroup(context, index, name);
      await Future.delayed(const Duration(seconds: 2)); // Wait for 2 seconds

      List<dynamic> data =
          await FrontendToBackendConnection.getData('get_adgroups/');
      if (data != null) {
        List<AdGroup> adgroup =
            data.map((item) => AdGroup.fromJson(item)).toList();
        print('Fetched ad groups: $adgroup');

        setState(() {});

        print('Updated state with new ad groups');
      } else {
        print('No AdGroups found');
      }
    } catch (e) {
      print('Error deleting AdGroup: $e');
      if (e is http.ClientException && e.message.contains('<!DOCTYPE html>')) {
        print('Server returned an HTML response: ${e.message}');
      } else if (e is http.ClientException && e.message.contains('404')) {
        // Handle 403 error
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(
              content: Text('You are not authorized to delete this ad group')),
        );
      } else {
        // Handle other errors
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(content: Text('Failed to delete ad group')),
        );
      }
    }
  }

  // void updateAdInGroup(
  //     int index, String oldName, String newName, String description) async {
  //   var token = await FrontendToBackendConnection.getToken();
  //   try {
  //     await FrontendToBackendConnection.getAdGroup(
  //         index, oldName, newName, description);
  //     await Future.delayed(const Duration(seconds: 2)); // Wait for 2 seconds
  //     List<AdInGroup> adsInGroup =
  //         await FrontendToBackendConnection.fetchAdGroups(token!);
  //     print('Fetched ad groups: $adsInGroup');
  //     setState(() {
  //       _adsInGroup = adsInGroup;
  //     });
  //     print('Updated state with new ad groups');
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to update ad group')),
  //     );
  //   }
  // }

  void clearLocalStorage() async {
    await FrontendToBackendConnection.clearStorage();
    Navigator.pushReplacement(
      context as BuildContext,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
    });
  }

  // void _searchAdGroups(String query) async {
  //   var token = await FrontendToBackendConnection.getToken();
  //   List<AdInGroup> adsInGroups =
  //       await FrontendToBackendConnection.searchAdsInGroup(query);
  //   setState(() {
  //     _adsInGroups = adsInGroups;
  //   });
  // }

  void _showPostPage(Map adGroup) async {
    // Check if adGroup contains 'id' key and it's not null
    if (adGroup.containsKey('name') && adGroup['name'] != null) {
      print('groupName: ${adGroup['name']}'); // print the group name
      // Fetch the ads for the adGroup
      List<AdInGroup> ads =
          await FrontendToBackendConnection.getAdsOfGroup(adGroup['name']);

      // Navigate to the PostPage and pass the ads to it
      Navigator.push(
        context as BuildContext,
        MaterialPageRoute(
          builder: (context) => PostPage(
            key: UniqueKey(),
            adInGroup: {'ads': ads}, // pass the fetched ads here
          ),
        ),
      );
    } else {
      print('adGroup does not contain id or id is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: SizedBox(
            width: 280,
            height: 400,
            child: Image.asset('assets/images/logo_name.png')),
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () async {
            final action = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text('Create'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop('Ad');
                          },
                          child: const Text('Ad'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop('Ad Group');
                          },
                          child: const Text('Ad Group'),
                        ),
                      ],
                    ));
            if (action != null) {
              if (action == 'Ad') {
                final newAdInGroup = await showDialog<AdInGroup>(
                  context: context,
                  builder: (context) => const CreateAdInGroupDialog(),
                );
                if (newAdInGroup != null) {
                  _addNewAdsInGroup(newAdInGroup.adGroupName, newAdInGroup.name,
                      newAdInGroup.description);
                }
              } else if (action == 'Ad Group') {
                final newAdGroup = await showDialog<AdGroup>(
                  context: context,
                  builder: (context) => const CreateAdGroupDialog(),
                );
                if (newAdGroup != null) {
                  _addNewAdGroup(newAdGroup.name, newAdGroup.description);
                }
              }
            }

            setState(() {});
          },
        ),
      ),
      body: FutureBuilder(
          future: FrontendToBackendConnection.getData('get_adgroups/'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              print(snapshot.data);
              List adGroups = snapshot.data;
              if (adGroups.isEmpty) {
                return Center(child: Text('No AdGroups found'));
              } else {
                print(adGroups[0]['name']);
                return ListView.builder(
                  itemCount: adGroups.length,
                  itemBuilder: (context, index) {
                    final adGroup = adGroups[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15.0), // Add rounded corners
                      ),
                      color: Colors.grey, // Change the card color
                      child: ListTile(
                        onTap: () => _showPostPage(adGroup),
                        title: Text(
                          adGroup['name'],
                          style: const TextStyle(
                              color: Colors.white), // Change the title color
                        ),
                        subtitle: Text(
                          adGroup['description'],
                          style: const TextStyle(
                              color:
                                  Colors.white70), // Change the subtitle color
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'Change') {
                              final updatedAdGroup =
                                  await showDialog<AdInGroup>(
                                context: context,
                                builder: (context) => UpdateAdGroupDialog(
                                  oldName: adGroup['name'],
                                  newName: adGroup['name'],
                                  oldDescription: adGroup['description'],
                                  newDescription: adGroup['description'],
                                ),
                              );
                              if (updatedAdGroup != null) {
                                FrontendToBackendConnection.updateAdInGroup(
                                    adGroup['name'],
                                    updatedAdGroup.name,
                                    adGroup['description']);
                              }
                            } else if (value == 'Delete') {
                              _deleteAdGroup(index, adGroup['name']);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'Change',
                              child: Text('Change'),
                            ),
                            const PopupMenuItem(
                              value: 'Delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            }
          }),
    );
  }
}

class PostPage extends StatefulWidget {
  final Map adInGroup;

  PostPage({Key? key, required this.adInGroup}) : super(key: key);

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  List<AdInGroup>? ads;

  @override
  void initState() {
    super.initState();
    ads = widget.adInGroup['ads'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Page'),
      ),
      body: ListView.builder(
        itemCount: ads?.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(ads?[index].name ?? ''),
            subtitle: Text(ads?[index].description ?? ''),
          );
        },
      ),
    );
  }
}

class AGPage extends StatelessWidget {
  final Map adGroup;

  const AGPage({super.key, required this.adGroup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(adGroup['name']),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(adGroup['description'])),
    );
  }
}

class AdGroupView extends StatelessWidget {
  final List<Map> adGroups;

  const AdGroupView({super.key, required this.adGroups});

  void _showAGPage(BuildContext context, Map adGroup) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AGPage(adGroup: adGroup)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: adGroups.length,
        itemBuilder: (context, index) {
          final adGroup = adGroups[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Add rounded corners
            ),
            color: Colors.grey, // Change the card color
            child: ListTile(
              onTap: () => _showAGPage(context, adGroup),
              title: Text(
                adGroup['name'],
                style: const TextStyle(
                    color: Colors.white), // Change the title color
              ),
              subtitle: Text(
                adGroup['description'],
                style: const TextStyle(
                    color: Colors.white70), // Change the subtitle color
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'Change') {
                    final updatedAdGroup = await showDialog<AdGroup>(
                      context: context,
                      builder: (context) => UpdateAdGroupDialog(
                        oldName: adGroup['name'],
                        newName: adGroup['name'],
                        oldDescription: adGroup['description'],
                        newDescription: adGroup['description'],
                      ),
                    );
                    if (updatedAdGroup != null) {
                      FrontendToBackendConnection.updateAdGroup(adGroup['name'],
                          updatedAdGroup.name, adGroup['description']);
                    }
                  } else if (value == 'Delete') {
                    FrontendToBackendConnection.deleteAdGroup(
                        context, index, adGroup['name']);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'Change',
                    child: Text('Change'),
                  ),
                  const PopupMenuItem(
                    value: 'Delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newAdGroup = await showDialog<AdGroup>(
            context: context,
            builder: (context) => const CreateAdGroupDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CreateAdInGroupDialog extends StatefulWidget {
  const CreateAdInGroupDialog({super.key});

  @override
  _CreateAdInGroupDialogState createState() => _CreateAdInGroupDialogState();
}

class _CreateAdInGroupDialogState extends State<CreateAdInGroupDialog> {
  final _adGroupNameController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
        data: const CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: Color(0xFFf46139),
        ),
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('Create Post'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.of(context).pop(AdInGroup(
                  adGroupName: _adGroupNameController.text,
                  name: _nameController.text,
                  description: _descriptionController.text,
                ));
              },
              child: const Text('Post'),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CupertinoTextField(
                    controller: _adGroupNameController,
                    placeholder: 'Ad Group Name',
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoColors.lightBackgroundGray,
                          width: 0.0, // One physical pixel.
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                  CupertinoTextField(
                    controller: _nameController,
                    placeholder: 'Name',
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoColors.lightBackgroundGray,
                          width: 0.0, // One physical pixel.
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  CupertinoTextField(
                    controller: _descriptionController,
                    placeholder: 'Description',
                    maxLines: null,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoColors.lightBackgroundGray,
                          width: 0.0, // One physical pixel.
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class UpdateAdGroupDialog extends StatefulWidget {
  final String oldName;
  final String oldDescription;
  final String newName;
  final String newDescription;

  const UpdateAdGroupDialog({
    super.key,
    required this.newName,
    required this.newDescription,
    required this.oldName,
    required this.oldDescription,
  });

  @override
  _UpdateAdGroupDialogState createState() => _UpdateAdGroupDialogState();
}

class _UpdateAdGroupDialogState extends State<UpdateAdGroupDialog> {
  late TextEditingController _adGroupNameController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _adGroupNameController = TextEditingController(text: widget.oldName);
    _nameController = TextEditingController(text: widget.oldName);
    _descriptionController = TextEditingController(text: widget.oldDescription);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Ad Group'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(AdInGroup(
              adGroupName: _adGroupNameController.text,
              name: _nameController.text,
              description: _descriptionController.text,
            ));
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

class CreateAdGroupDialog extends StatefulWidget {
  const CreateAdGroupDialog({Key? key}) : super(key: key);

  @override
  _CreateAdGroupDialogState createState() => _CreateAdGroupDialogState();
}

class _CreateAdGroupDialogState extends State<CreateAdGroupDialog> {
  final _formKey = GlobalKey<FormState>();

  Map<String, String> adgroup = {
    'name': '',
    'description': '',
  };

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Ad Group'),
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              // onSaved: (value) {
              //   _name = value!;
              // },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              // onSaved: (value) {
              //   _description = value!;
              // },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              adgroup['name'] = _nameController.text;
              adgroup['description'] = _descriptionController.text;
              await FrontendToBackendConnection.postData(
                  "create_adgroup/", adgroup);
              Navigator.of(context).pop();
            }
          },
          child: Text('Create'),
        ),
      ],
    );
  }
}

// void main() {
//   runApp(ChangeNotifierProvider(
//     create: (context) => FrontendToBackendConnection(),
//     child: MaterialApp(
//       home: AdGroupView(adGroups: []),
//     ),
//   ));
// }

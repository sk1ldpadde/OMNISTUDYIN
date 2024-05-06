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

// Future<AdInGroup> createAdsInGroup(
//     String ad_group_name, String name, String description) async {
//   final response = await http.post(
//     Uri.parse('http://10.0.2.2:8000/create_ads_in_group/'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//       'Authorization': 'Bearer $jwtToken',
//     },
//     body: jsonEncode(<String, String>{
//       'ad_group_name': ad_group_name,
//       'name': name,
//       'description': description,
//     }),
//   );

//   if (response.statusCode == 200) {
//     return AdInGroup.fromJson(json.decode(response.body));
//   } else {
//     throw Exception('Failed to create AdGroup');
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
  List<AdGroup> _adGroups = [];

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
    var MapListOfAdsInGroup =
        await FrontendToBackendConnection.getData("get_adgroups/");
    _adGroups = [];
    for (int i = 0; i < MapListOfAdsInGroup.length; i++) {
      _adGroups.add(AdGroup(
          name: MapListOfAdsInGroup[i]['name'],
          description: MapListOfAdsInGroup[i]['description']));
    }
    print(_adGroups);
  }

  void _deleteAdGroup(int index, String name) async {
    var token = await FrontendToBackendConnection.getToken();
    try {
      await FrontendToBackendConnection.deleteAdGroup(
          context as BuildContext, index, name);
      await Future.delayed(const Duration(seconds: 2)); // Wait for 2 seconds
      List<AdInGroup> adsInGroup =
          await FrontendToBackendConnection.fetchAdGroups(token!);
      print('Fetched ad groups: $adsInGroup');
      setState(() {
        _adsInGroup = adsInGroup;
      });
      print('Updated state with new ad groups');
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

  void _showPostPage(AdInGroup adGroup) {
    Navigator.push(
      context as BuildContext,
      MaterialPageRoute(
        builder: (context) => PostPage(adInGroup: adGroup),
      ),
    );
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
            ;
          },
        ),
      ),
      body: ListView.builder(
        itemCount: _adsInGroup.length,
        itemBuilder: (context, index) {
          final adGroup = _adsInGroup[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Add rounded corners
            ),
            color: Colors.grey, // Change the card color
            child: ListTile(
              onTap: () => _showPostPage(adGroup),
              title: Text(
                adGroup.name,
                style: const TextStyle(
                    color: Colors.white), // Change the title color
              ),
              subtitle: Text(
                adGroup.description,
                style: const TextStyle(
                    color: Colors.white70), // Change the subtitle color
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'Change') {
                    final updatedAdGroup = await showDialog<AdInGroup>(
                      context: context,
                      builder: (context) => UpdateAdGroupDialog(
                        oldName: adGroup.name,
                        newName: adGroup.name,
                        oldDescription: adGroup.description,
                        newDescription: adGroup.description,
                      ),
                    );
                    if (updatedAdGroup != null) {
                      FrontendToBackendConnection.updateAdInGroup(adGroup.name,
                          updatedAdGroup.name, adGroup.description);
                    }
                  } else if (value == 'Delete') {
                    _deleteAdGroup(index, adGroup.name);
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
    );
  }
}

class PostPage extends StatelessWidget {
  final AdInGroup adInGroup;

  const PostPage({super.key, required this.adInGroup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(adInGroup.name),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(adInGroup.description)),
    );
  }
}

class AGPage extends StatelessWidget {
  final AdGroup adGroup;

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
        title: Text(adGroup.name),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16), child: Text(adGroup.description)),
    );
  }
}

// class AGPostPage extends StatelessWidget {
//   final AdGroup adGroup;
//   var token = FrontendToBackendConnection.getToken();

//   AGPostPage({required this.adGroup});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(adGroup.name),
//       ),
//       body: FutureBuilder<List<AdInGroup>>(
//         future: FrontendToBackendConnection.fetchAdsInGroup(adGroup, await token), // Replace with your method to fetch ads
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Text('Error: ${snapshot.error}');
//           } else {
//             return ListView.builder(
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) {
//                 final ad = snapshot.data![index];
//                 return ListTile(
//                   title: Text(ad.name), // Replace with your ad fields
//                   subtitle: Text(ad.description), // Replace with your ad fields
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

class AdGroupView extends StatelessWidget {
  final List<AdGroup> adGroups;

  AdGroupView({required this.adGroups});

  void _showAGPage(BuildContext context, AdGroup adGroup) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => AGPage(adGroup: adGroup)));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
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
              adGroup.name,
              style: const TextStyle(
                  color: Colors.white), // Change the title color
            ),
            subtitle: Text(
              adGroup.description,
              style: const TextStyle(
                  color: Colors.white70), // Change the subtitle color
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'Change') {
                  final updatedAdGroup = await showDialog<AdGroup>(
                    context: context,
                    builder: (context) => UpdateAdGroupDialog(
                      oldName: adGroup.name,
                      newName: adGroup.name,
                      oldDescription: adGroup.description,
                      newDescription: adGroup.description,
                    ),
                  );
                  if (updatedAdGroup != null) {
                    FrontendToBackendConnection.updateAdGroup(
                        adGroup.name, updatedAdGroup.name, adGroup.description);
                  }
                } else if (value == 'Delete') {
                  FrontendToBackendConnection.deleteAdGroup(
                      context, index, adGroup.name);
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
  String _name = '';
  String _description = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Ad Group'),
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onSaved: (value) {
                _name = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              onSaved: (value) {
                _description = value!;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              AdGroup newAdGroup =
                  AdGroup(name: _name, description: _description);
              Navigator.of(context).pop(newAdGroup);
              List<AdGroup> _adGroups =
                  []; // Define the variable _adGroups as an empty list
              _adGroups.add(newAdGroup); // Add newAdGroup to _adGroups list

              Navigator.of(context)
                  .pop(AdGroup(name: _name, description: _description));
              // Navigate to AGPostPage
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AdGroupView(
                    adGroups: [],
                  ),
                ),
              );
            }
          },
          child: Text('Create'),
        ),
      ],
    );
  }
}

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => FrontendToBackendConnection(),
    child: const MaterialApp(
      home: HomePage(),
    ),
  ));
}

import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/Logic/Frontend_To_Backend_Connection.dart';
import '../register/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

String jwtToken =
    'your_initial_token'; // Replace 'your_initial_token' with the actual JWT token

Future<List<AdGroup>> fetchAdGroups() async {
  final response =
      await http.get(Uri.parse('http://10.0.2.2:8000/get_adgroups/'));

  if (response.statusCode == 200) {
    Iterable l = json.decode(response.body);
    List<AdGroup> adGroups =
        List<AdGroup>.from(l.map((model) => AdGroup.fromJson(model)));
    return adGroups;
  } else {
    throw Exception('Failed to load AdGroups');
  }
}

Future<AdGroup> createAdGroup(String name, String description) async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:8000/create_adgroup/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken',
    },
    body: jsonEncode(<String, String>{
      'name': name,
      'description': description,
    }),
  );

  if (response.statusCode == 200) {
    return AdGroup.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create AdGroup');
  }
}

Future<void> updateAdGroup(
    String oldName, String newName, String description) async {
  final response = await http.put(
    Uri.parse('http://10.0.2.2:8000/change_adgroup/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken',
    },
    body: jsonEncode(<String, String>{
      'old_name': oldName,
      'new_name': newName,
      'description': description,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update AdGroup');
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showSearchBar = false;
  List<AdGroup> _adGroups = [];

  @override
  void initState() {
    super.initState();
    fetchAdGroups().then((value) => setState(() {
          _adGroups = value;
        }));
  }

  void _addNewAdGroup(String name, String description) async {
    print('Adding new ad group');
    var token = await FrontendToBackendConnection.getToken();
    print('Got token: $token');
    await FrontendToBackendConnection.addNewAdGroup(name, description, token);
    print('Added new ad group');
    await Future.delayed(const Duration(seconds: 2)); // Wait for 2 seconds
    List<AdGroup> adGroups =
        await FrontendToBackendConnection.fetchAdGroups(token!);
    print('Fetched ad groups: $adGroups');
    setState(() {
      _adGroups = adGroups;
    });
    print('Updated state with new ad groups');
  }

  void _deleteAdGroup(int index, String name) async {
    var token = await FrontendToBackendConnection.getToken();
    try {
      await FrontendToBackendConnection.deleteAdGroup(context, index, name);
      await Future.delayed(const Duration(seconds: 2)); // Wait for 2 seconds
      List<AdGroup> adGroups =
          await FrontendToBackendConnection.fetchAdGroups(token!);
      print('Fetched ad groups: $adGroups');
      setState(() {
        _adGroups = adGroups;
      });
      print('Updated state with new ad groups');
    } catch (e) {
      print('Error deleting AdGroup: $e');
      if (e is http.ClientException && e.message.contains('<!DOCTYPE html>')) {
        print('Server returned an HTML response: ${e.message}');
      } else if (e is http.ClientException && e.message.contains('404')) {
        // Handle 403 error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You are not authorized to delete this ad group')),
        );
      } else {
        // Handle other errors
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete ad group')),
        );
      }
    }
  }

  void updateAdGroup(
      int index, String oldName, String newName, String description) async {
    var token = await FrontendToBackendConnection.getToken();
    try {
      await FrontendToBackendConnection.getAdGroup(
          index, oldName, newName, description);
      await Future.delayed(const Duration(seconds: 2)); // Wait for 2 seconds
      List<AdGroup> adGroups =
          await FrontendToBackendConnection.fetchAdGroups(token!);
      print('Fetched ad groups: $adGroups');
      setState(() {
        _adGroups = adGroups;
      });
      print('Updated state with new ad groups');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update ad group')),
      );
    }
  }

  void clearLocalStorage() async {
    await FrontendToBackendConnection.clearStorage();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void _toggleSearchBar() {
    setState(() {
      _showSearchBar = !_showSearchBar;
    });
  }

  void _searchAdGroups(String query) async {
    var token = await FrontendToBackendConnection.getToken();
    List<AdGroup> adGroups =
        await FrontendToBackendConnection.searchAdGroups(query);
    setState(() {
      _adGroups = adGroups;
    });
  }

  void _showPostPage(AdGroup adGroup) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostPage(adGroup: adGroup),
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
            final newAdGroup = await showDialog<AdGroup>(
              context: context,
              builder: (context) => const CreateAdGroupDialog(),
            );
            if (newAdGroup != null) {
              _addNewAdGroup(newAdGroup.name, newAdGroup.description);
            }
          },
        ),
      ),
      body: ListView.builder(
        itemCount: _adGroups.length,
        itemBuilder: (context, index) {
          final adGroup = _adGroups[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Add rounded corners
            ),
            color: Colors.grey, // Change the card color
            child: ListTile(
              onTap: () => _showPostPage(adGroup),
              title: Text(
                adGroup.name,
                style: const TextStyle(color: Colors.white), // Change the title color
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
                        oldDescription: adGroup.description,
                      ),
                    );
                    if (updatedAdGroup != null) {
                      updateAdGroup(index, adGroup.name, updatedAdGroup.name,
                          updatedAdGroup.description);
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
  final AdGroup adGroup;

  const PostPage({super.key, required this.adGroup});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(adGroup.name),
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16), child: Text(adGroup.description)),
    );
  }
}

class CreateAdGroupDialog extends StatefulWidget {
  const CreateAdGroupDialog({super.key});

  @override
  _CreateAdGroupDialogState createState() => _CreateAdGroupDialogState();
}

class _CreateAdGroupDialogState extends State<CreateAdGroupDialog> {
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
                Navigator.of(context).pop(AdGroup(
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

  const UpdateAdGroupDialog({super.key, 
    required this.oldName,
    required this.oldDescription,
  });

  @override
  _UpdateAdGroupDialogState createState() => _UpdateAdGroupDialogState();
}

class _UpdateAdGroupDialogState extends State<UpdateAdGroupDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
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
            Navigator.of(context).pop(AdGroup(
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

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => FrontendToBackendConnection(),
    child: const MaterialApp(
      home: HomePage(),
    ),
  ));
}

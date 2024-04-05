import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:omnistudin_flutter/Logic/Frontend_To_Backend_Connection.dart';
import '../register/login.dart';
=======
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

String jwtToken =
    'your_initial_token'; // Replace 'your_initial_token' with the actual JWT token

Future<List<AdGroup>> fetchAdGroups() async {
  final response =
      await http.get(Uri.parse('http://localhost:8000/get_adgroups/'));

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
    Uri.parse('http://localhost:8000/create_adgroup/'),
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
    Uri.parse('http://localhost:8000/change_adgroup/'),
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

Future<void> deleteAdGroup(String name) async {
  final response = await http.delete(
    Uri.parse('http://localhost:8000/delete_adgroup/'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken',
    },
    body: jsonEncode(<String, String>{
      'name': name,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete AdGroup');
  }
}

class AdGroup {
  String name;
  String description;

  AdGroup({
    required this.name,
    required this.description,
  });

  factory AdGroup.fromJson(Map<String, dynamic> json) {
    return AdGroup(
      name: json['name'],
      description: json['description'],
    );
  }
}
>>>>>>> Stashed changes

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showSearchBar = false;
<<<<<<< Updated upstream

  void clearLocalStorage() async {
    await FrontendToBackendConnection.clearStorage();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearchBar ? TextField() : Text('Home'),
        leading: IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            // Add your create post logic here
=======
  List<AdGroup> _adGroups = [];

  @override
  void initState() {
    super.initState();
    fetchAdGroups().then((value) => setState(() {
          _adGroups = value;
        }));
  }

  Future<void> _addNewAdGroup(String name, String description) async {
    try {
      final newAdGroup = await createAdGroup(name, description);
      setState(() {
        _adGroups.insert(0, newAdGroup);
      });
    } catch (e) {
      print('Error creating AdGroup: $e');
    }
  }

  Future<void> _updateAdGroup(
      int index, String oldName, String newName, String description) async {
    try {
      await updateAdGroup(oldName, newName, description);
      setState(() {
        _adGroups[index].name = newName;
        _adGroups[index].description = description;
      });
    } catch (e) {
      print('Error updating AdGroup: $e');
    }
  }

  Future<void> _deleteAdGroup(int index, String name) async {
    try {
      await deleteAdGroup(name);
      setState(() {
        _adGroups.removeAt(index);
      });
    } catch (e) {
      print('Error deleting AdGroup: $e');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _showSearchBar
            ? TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  contentPadding: EdgeInsets.all(10.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              )
            : Container(
                width: 280, // Adjust as needed
                height: 400, // Adjust as needed
                child: Image.asset('assets/images/logo_name.png'),
              ),
        leading: IconButton(
          icon: Icon(Icons.add),
          onPressed: () async {
            final newAdGroup = await showDialog<AdGroup>(
              context: context,
              builder: (context) => CreateAdGroupDialog(),
            );
            if (newAdGroup != null) {
              _addNewAdGroup(newAdGroup.name, newAdGroup.description);
            }
>>>>>>> Stashed changes
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.audiotrack),
            onPressed: () {
              clearLocalStorage();
            },
          ),
        ],
      ),
<<<<<<< Updated upstream
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
=======
      body: ListView.builder(
        itemCount: _adGroups.length,
        itemBuilder: (context, index) {
          final adGroup = _adGroups[index];
          return Card(
            child: ListTile(
              title: Text(adGroup.name),
              subtitle: Text(adGroup.description),
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
                      _updateAdGroup(index, adGroup.name, updatedAdGroup.name,
                          updatedAdGroup.description);
                    }
                  } else if (value == 'Delete') {
                    _deleteAdGroup(index, adGroup.name);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'Change',
                    child: Text('Change'),
                  ),
                  PopupMenuItem(
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

class CreateAdGroupDialog extends StatefulWidget {
  @override
  _CreateAdGroupDialogState createState() => _CreateAdGroupDialogState();
}

class _CreateAdGroupDialogState extends State<CreateAdGroupDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Post'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
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
          child: Text('Create'),
        ),
      ],
    );
  }
}

class UpdateAdGroupDialog extends StatefulWidget {
  final String oldName;
  final String oldDescription;

  const UpdateAdGroupDialog({
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
      title: Text('Update Ad Group'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
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
          child: Text('Update'),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
>>>>>>> Stashed changes

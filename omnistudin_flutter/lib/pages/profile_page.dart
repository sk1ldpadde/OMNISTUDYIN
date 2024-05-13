import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/Logic/Frontend_To_Backend_Connection.dart';
import 'package:omnistudin_flutter/pages/profilesettings_page.dart';
import 'package:omnistudin_flutter/main.dart';
import 'package:omnistudin_flutter/register/registration.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> studentData = {};

  @override
  void initState() {
    super.initState();
    loadStudentData();
  }

  Future<void> loadStudentData() async {
    try {
      var data = await FrontendToBackendConnection.getSessionStudent();
      setState(() {
        studentData = data;
      });
    } catch (e) {
      print('Failed to load student data: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    print('didChangeDependencies: $studentData'); // Debugging purposes
  }

  String get profileName {
    return '${studentData['forename']} ${studentData['surname'] ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    print(studentData); // Debugging purposes

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsPage()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage(
                    '/Users/amandademoura/Documents/GitHub/OMNISTUDYIN2/omnistudin_flutter/assets/images/logo_picture.png'), // Replace with actual path or use a placeholder image
              ),
              const SizedBox(height: 20),
              Text(
                profileName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width *
                    0.9, // 90% of screen width
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          studentData['uni_name'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          studentData['semester'].toString() ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          studentData['degree'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // CupertinoButton.filled(
              //   child: const Text('Test Register'),
              //   onPressed: () async {
              //     await _register(); // Call the _register method
              //   },
              // ),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width *
                    0.9, // 90% of screen width
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          studentData['email'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          studentData['dob'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          studentData['bio'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/Logic/Frontend_To_Backend_Connection.dart';
import 'package:omnistudin_flutter/pages/profilesettings_page.dart';
import 'package:omnistudin_flutter/main.dart';
import 'package:omnistudin_flutter/register/registration.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';

import 'dart:convert';
import 'dart:io';

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

  String get profileName {
    return '${studentData['forename']} ${studentData['surname'] ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
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
              CircleAvatar(
                radius: 80,
                backgroundImage: MemoryImage(
                    base64Decode(studentData['profile_picture'] ?? '')),
              ),
              const SizedBox(height: 20),
              Text(
                profileName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              buildInfoCard('uni_name', 'semester', 'degree'),
              const SizedBox(height: 20),
              buildInfoCard('email', 'dob', 'bio'),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInfoCard(String field1, String field2, String field3) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                '$field1: ${studentData[field1] ?? ''}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                '$field2: ${studentData[field2]?.toString() ?? ''}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                '$field3: ${studentData[field3] ?? ''}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

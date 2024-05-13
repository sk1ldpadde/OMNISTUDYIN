import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/pages/profilesettings_page.dart';
import 'package:omnistudin_flutter/main.dart';
import 'package:omnistudin_flutter/register/registration.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const ProfilePage({Key? key, required this.registrationData})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String get profileName {
    return '${widget.registrationData['forename']} ${widget.registrationData['surname'] ?? ''}';
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
              // Navigate to the settings page
              // Replace 'SettingsPage()' with your actual settings page
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
                          widget.registrationData['uni_name'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          widget.registrationData['semester'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          widget.registrationData['degree'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
                          widget.registrationData['email'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          widget.registrationData['dob'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          widget.registrationData['bio'] ?? '',
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

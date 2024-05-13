import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/Logic/Frontend_To_Backend_Connection.dart';
import 'package:omnistudin_flutter/pages/profilesettings_page.dart';
import 'package:omnistudin_flutter/main.dart';
import 'package:omnistudin_flutter/register/registration.dart';
import 'package:provider/provider.dart';

Future<void> _register() async {
  Map<String, dynamic> registerData = getMockRegistrationData();
  print('registerData: $registerData'); // Debugging purposes
  try {
    await FrontendToBackendConnection.register(
        "register/", registerData); // Await the register method
  } catch (e) {
    print('Error while trying to register: $e');
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> registrationData = {};

  @override
  void initState() {
    super.initState();
    registrationData =
        Provider.of<RegistrationData>(context as BuildContext, listen: false)
            .data;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    registrationData =
        Provider.of<RegistrationData>(context, listen: false).data;
    print('didChangeDependencies: $registrationData'); // Debugging purposes
  }

  String get profileName {
    return '${registrationData['forename']} ${registrationData['surname'] ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    print(registrationData); // Debugging purposes

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
                          registrationData['uni_name'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          registrationData['semester'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          registrationData['degree'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              CupertinoButton.filled(
                child: const Text('Test Register'),
                onPressed: () async {
                  await _register(); // Call the _register method
                },
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
                          registrationData['email'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          registrationData['dob'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          registrationData['bio'] ?? '',
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

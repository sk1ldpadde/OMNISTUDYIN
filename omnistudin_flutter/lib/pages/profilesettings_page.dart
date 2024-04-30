import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/Logic/Frontend_To_Backend_Connection.dart';
import 'package:omnistudin_flutter/register/login.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Edit Profile'),
            onTap: () {
              // TODO: Implement edit profile functionality
            },
          ),
          ListTile(
            title: const Text('Change Password'),
            onTap: () {
              // TODO: Implement change password functionality
            },
          ),
          ListTile(
            title: const Text('Privacy Settings'),
            onTap: () {
              // TODO: Implement privacy settings functionality
            },
          ),
          ListTile(
            title: const Text('Notification Settings'),
            onTap: () {
              // TODO: Implement notification settings functionality
            },
          ),
          ListTile(
            title: const Text('Logout'),
            onTap: () async {
              await FrontendToBackendConnection.clearStorage();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}

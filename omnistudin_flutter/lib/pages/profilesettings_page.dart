import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/Logic/Frontend_To_Backend_Connection.dart';
import 'package:omnistudin_flutter/register/login.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Edit Profile'),
            onTap: () {
              // TODO: Implement edit profile functionality
            },
          ),
          ListTile(
            title: Text('Change Password'),
            onTap: () {
              // TODO: Implement change password functionality
            },
          ),
          ListTile(
            title: Text('Privacy Settings'),
            onTap: () {
              // TODO: Implement privacy settings functionality
            },
          ),
          ListTile(
            title: Text('Notification Settings'),
            onTap: () {
              // TODO: Implement notification settings functionality
            },
          ),
          ListTile(
            title: Text('Logout'),
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

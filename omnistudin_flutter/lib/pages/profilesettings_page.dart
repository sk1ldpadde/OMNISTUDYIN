import 'package:flutter/material.dart';

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
            onTap: () {
              // TODO: Implement logout functionality
            },
          ),
        ],
      ),
    );
  }
}

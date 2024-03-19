import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/pages/profilesettings_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String profileName = "Profile Name"; // Replace with actual profile name
  String email = "Email"; // Replace with actual email
  String major = "Selected Major"; // Replace with actual major

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Navigate to the settings page
              // Replace 'SettingsPage()' with your actual settings page
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SettingsPage()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage(
                    'path_to_profile_picture'), // Replace with actual path or use a placeholder image
              ),
              SizedBox(height: 20),
              Text(
                profileName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                email,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                major,
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

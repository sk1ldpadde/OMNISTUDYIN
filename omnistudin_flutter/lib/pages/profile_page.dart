import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String profileName = "John Doe";
  String email = "johndoe@example.com";
  String major = "Computer Science";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text("Profile"),
              background: Image.network(
                "https://via.placeholder.com/150",
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Profile Name: $profileName',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Email: $email',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Major: $major',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Profile Settings',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      ListTile(
                        title: Text('Modify Profile Name'),
                        trailing: Icon(Icons.edit),
                        onTap: () {
                          // Implement your functionality here
                        },
                      ),
                      ListTile(
                        title: Text('Modify Email'),
                        trailing: Icon(Icons.edit),
                        onTap: () {
                          // Implement your functionality here
                        },
                      ),
                      ListTile(
                        title: Text('Modify Major'),
                        trailing: Icon(Icons.edit),
                        onTap: () {
                          // Implement your functionality here
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

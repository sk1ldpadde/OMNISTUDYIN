import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/Logic/Frontend_To_Backend_Connection.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResultsAds = [];
  List<Map<String, dynamic>> _searchResultsAdgroups = [];
  List<Map<String, dynamic>> _searchResultsStudents = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _makeHttpRequest(_searchQuery);
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          if (_searchResultsAds.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Ads',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResultsAds.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(_searchResultsAds[index]['title']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AdDetailView(ad: _searchResultsAds[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (_searchResultsAdgroups.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Adgroups',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResultsAdgroups.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(_searchResultsAdgroups[index]['name']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdGroupDetailView(
                              adGroup: _searchResultsAdgroups[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          if (_searchResultsStudents.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Students',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResultsStudents.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(_searchResultsStudents[index]['forename']),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentDetailView(
                              student: _searchResultsStudents[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makeHttpRequest(String query) async {
    Map<String, dynamic> data = {'query': query};
    Map<String, dynamic> map =
        await FrontendToBackendConnection.postData("query_all/", data);
    setState(() {
      _searchResultsAdgroups =
          List<Map<String, dynamic>>.from(map['ad_groups']);
      _searchResultsAds = List<Map<String, dynamic>>.from(map['ads']);
      _searchResultsStudents = List<Map<String, dynamic>>.from(map['students']);
    });
  }
}

class AdDetailView extends StatelessWidget {
  final Map<String, dynamic> ad;

  const AdDetailView({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Ad Detail'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              Card(
                  child: ad['image'] != ""
                      ? Image.network(ad['image'])
                      : const Icon(Icons.image)),
              Card(
                  child: ListTile(
                      title: const Text('Title'),
                      subtitle: Text(ad['title'] ?? 'No title'))),
              Card(
                  child: ListTile(
                      title: const Text('Description'),
                      subtitle: Text(ad['description'] ?? 'No description'))),
            ],
          ),
        ),
      ),
    );
  }
}

class AdGroupDetailView extends StatelessWidget {
  final Map<String, dynamic> adGroup;

  const AdGroupDetailView({super.key, required this.adGroup});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Ad Group Detail'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              Card(
                  child: ListTile(
                      title: const Text('Name'),
                      subtitle: Text(adGroup['name'] ?? 'No name'))),
              Card(
                  child: ListTile(
                      title: const Text('Description'),
                      subtitle:
                          Text(adGroup['description'] ?? 'No description'))),
            ],
          ),
        ),
      ),
    );
  }
}

class StudentDetailView extends StatelessWidget {
  final Map<String, dynamic> student;

  const StudentDetailView({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Student Detail'),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              Card(
                  child: student['profile_picture'] != ""
                      ? Image.memory(base64Decode(student['profile_picture']))
                      : const Icon(Icons.account_circle)),
              Card(
                  child: ListTile(
                      title: const Text('Forename'),
                      subtitle: Text(student['forename'] ?? 'No forename'))),
              Card(
                  child: ListTile(
                      title: const Text('Surname'),
                      subtitle: Text(student['surname'] ?? 'No surname'))),
              Card(
                  child: ListTile(
                      title: const Text('Email'),
                      subtitle: Text(student['email'] ?? 'No email'))),
              Card(
                  child: ListTile(
                      title: const Text('DOB'),
                      subtitle: Text(student['dob'] ?? 'No DOB'))),
              Card(
                  child: ListTile(
                      title: const Text('Bio'),
                      subtitle: Text(student['bio'] ?? 'No bio'))),
              Card(
                  child: ListTile(
                      title: const Text('University Name'),
                      subtitle:
                          Text(student['uni_name'] ?? 'No university name'))),
              Card(
                  child: ListTile(
                      title: const Text('Degree'),
                      subtitle: Text(student['degree'] ?? 'No degree'))),
              Card(
                  child: ListTile(
                      title: const Text('Semester'),
                      subtitle: Text(student['semester'] ?? 'No semester'))),
              Card(
                  child: ListTile(
                      title: const Text('Interests and Goals'),
                      subtitle: Text(student['interests_and_goals'] ??
                          'No interests and goals'))),
            ],
          ),
        ),
      ),
    );
  }
}

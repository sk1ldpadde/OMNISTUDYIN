import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/Logic/Frontend_To_Backend_Connection.dart';
import '../register/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

// HomePage widget which is a StatefulWidget, meaning it can maintain state during the lifetime of the widget
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // Creating the state for HomePage widget
  _HomePageState createState() => _HomePageState();
}

// The state for HomePage widget
class _HomePageState extends State<HomePage> {
  // Boolean to control the visibility of the search bar
  bool _showSearchBar = false;
  // List to hold the ads in a group
  List<AdInGroup> _adsInGroup = [];

  @override
  // initState is the first method called when the widget is created
  void initState() {
    super.initState();
    // Initializing the state
    initializeState();
  }

  // Method to initialize the state
  void initializeState() async {
    var token =
        await FrontendToBackendConnection.getToken(); // Fetching the token
    FrontendToBackendConnection.fetchAdGroups(
            token!) // Fetching the ad groups using the token and updating the state
        .then((value) => setState(() {
              _adsInGroup = value;
            }));
  }

  // Method to add new ads in a group
  void _addNewAdsInGroup(
      String adgroupname, String title, String description) async {
    // Creating a new ad with the provided ad group name, title, and description
    Map<String, String> newAd = {
      "ad_group_name": adgroupname,
      "title": title,
      "description": description
    };
    // Sending a POST request to the server to create the new ad
    var resOfCreate = await FrontendToBackendConnection.postData(
        "create_ads_in_group/", newAd);
    print(resOfCreate);
    // Sending a POST request to the server to get the ads of the group
    var MapListOfAdsInGroup = await FrontendToBackendConnection.postData(
        "get_ads_of_group/", {"ad_group_name": adgroupname});
    // Clearing the _adsInGroup list
    _adsInGroup = [];
    // Adding the ads from the response to the _adsInGroup list
    for (int i = 0; i < MapListOfAdsInGroup.length; i++) {
      _adsInGroup.add(AdInGroup(
          adGroupName: MapListOfAdsInGroup[i]['ad_group_name'],
          name: MapListOfAdsInGroup[i]['title'],
          description: MapListOfAdsInGroup[i]['description']));
    }
    print(_adsInGroup);
  }

  // Method to add a new ad group
  void _addNewAdGroup(String name, String description) async {
    // Creating a new ad group with the provided name and description
    Map<String, String> adgroup = {
      'name': name,
      'description': description,
    };
    // Sending a POST request to the server to create the new ad group
    var resOfCreate =
        await FrontendToBackendConnection.postData("create_adgroup/", adgroup);
    print(resOfCreate);
  }

  // Method to delete an ad group
  void _deleteAdGroup(int index, String name) async {
    // Creating a map with the name of the ad group to delete
    Map<String, String> adgroup = {
      'name': name,
    };
    var token = await FrontendToBackendConnection.getToken();
    try {
      await FrontendToBackendConnection.deleteAdGroup(context, index, name);
      await Future.delayed(const Duration(
          seconds:
              2)); // Waiting for 2 seconds to ensure the server has time to process the request

      // Sending a GET request to the server to get the updated list of ad groups
      List<dynamic> data =
          await FrontendToBackendConnection.getData('get_adgroups/');
      if (data != null) {
        // If the response is not null, converting the response to a list of AdGroup objects
        List<AdGroup> adgroup =
            data.map((item) => AdGroup.fromJson(item)).toList();
        print('Fetched ad groups: $adgroup');

        // Updating the state with the new list of ad groups
        setState(() {});

        print('Updated state with new ad groups');
      } else {
        // If the response is null, printing a message
        print('No AdGroups found');
      }
    } catch (e) {
      print('Error deleting AdGroup: $e');
      if (e is http.ClientException && e.message.contains('<!DOCTYPE html>')) {
        print('Server returned an HTML response: ${e.message}');
      } else if (e is http.ClientException && e.message.contains('404')) {
        // Handle 403 error
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(
              content: Text('You are not authorized to delete this ad group')),
        );
      } else {
        // Handle other errors
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(content: Text('Failed to delete ad group')),
        );
      }
    }
  }

  // void updateAdInGroup(
  //     int index, String oldName, String newName, String description) async {
  //   var token = await FrontendToBackendConnection.getToken();
  //   try {
  //     await FrontendToBackendConnection.getAdGroup(
  //         index, oldName, newName, description);
  //     await Future.delayed(const Duration(seconds: 2)); // Wait for 2 seconds
  //     List<AdInGroup> adsInGroup =
  //         await FrontendToBackendConnection.fetchAdGroups(token!);
  //     print('Fetched ad groups: $adsInGroup');
  //     setState(() {
  //       _adsInGroup = adsInGroup;
  //     });
  //     print('Updated state with new ad groups');
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Failed to update ad group')),
  //     );
  //   }
  // }

  // Method to clear local storage
  void clearLocalStorage() async {
    // Clearing the storage
    await FrontendToBackendConnection.clearStorage();
    // Navigating to the LoginPage
    Navigator.pushReplacement(
      context as BuildContext,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Method to toggle the visibility of the search bar
  void _toggleSearchBar() {
    // Updating the state to show or hide the search bar
    setState(() {
      _showSearchBar = !_showSearchBar;
    });
  }

  // void _searchAdGroups(String query) async {
  //   var token = await FrontendToBackendConnection.getToken();
  //   List<AdInGroup> adsInGroups =
  //       await FrontendToBackendConnection.searchAdsInGroup(query);
  //   setState(() {
  //     _adsInGroups = adsInGroups;
  //   });
  // }

  // Method to show the PostPage
  void _showPostPage(Map adGroup) async {
    // Check if adGroup contains 'id' key and it's not null
    if (adGroup.containsKey('name') && adGroup['name'] != null) {
      print('groupName: ${adGroup['name']}'); // print the group name
      // Fetch the ads for the adGroup
      List<AdInGroup> ads =
          await FrontendToBackendConnection.getAdsOfGroup(adGroup['name']);

      // Navigate to the PostPage and pass the ads to it
      Navigator.push(
        context as BuildContext,
        MaterialPageRoute(
          builder: (context) => PostPage(
            key: UniqueKey(),
            adInGroup: {
              'ads': ads,
              'ad_group_name': adGroup['name']
            }, // pass the  fetched ads and ad group name here
          ),
        ),
      );
    } else {
      print('adGroup does not contain id or id is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Returning a Scaffold widget which provides a framework to implement the basic material design layout of the application
    return Scaffold(
      // AppBar at the top of the Scaffold
      appBar: AppBar(
        centerTitle: true,
        title: SizedBox(
            width: 280,
            height: 400,
            child: Image.asset('assets/images/logo_name.png')),
        // Leading widget (at the start of the AppBar), using an IconButton
        leading: IconButton(
          icon: const Icon(Icons.add),
          // Action to perform when the IconButton is pressed
          onPressed: () async {
            final action = await showDialog<String>(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text('Create'),
                      actions: [
                        TextButton(
                          // Action to perform when the 'Ad' button is pressed
                          onPressed: () {
                            Navigator.of(context).pop('Ad');
                          },
                          child: const Text('Ad'),
                        ),
                        TextButton(
                          // Action to perform when the 'Ad Group' button is pressed
                          onPressed: () {
                            Navigator.of(context).pop('Ad Group');
                          },
                          child: const Text('Ad Group'),
                        ),
                      ],
                    ));
            if (action != null) {
              // Check if an action was returned from the dialog
              if (action == 'Ad') {
                print("Ad!!!!!!");
                // Show a dialog to create a new ad in a group and wait for the user to fill in the details
                final newAdInGroup = await showDialog<AdInGroup>(
                  context: context,
                  builder: (context) => const CreateAdInGroupDialog(),
                );
                if (newAdInGroup != null) {
                  // Add the new ad in the group
                  _addNewAdsInGroup(newAdInGroup.adGroupName, newAdInGroup.name,
                      newAdInGroup.description);
                }
              } else if (action == 'Ad Group') {
                // Show a dialog to create a new ad group and wait for the user to fill in the details
                final newAdGroup = await showDialog<AdGroup>(
                  context: context,
                  builder: (context) => const CreateAdGroupDialog(),
                );
                if (newAdGroup != null) {
                  _addNewAdGroup(newAdGroup.name, newAdGroup.description);
                }
              }
            }
            // Update the state to reflect the changes
            setState(() {});
          },
        ),
      ),
      // The body of the Scaffold, using a FutureBuilder to handle asynchronous data
      body: FutureBuilder(
          future: FrontendToBackendConnection.getData(
              'get_adgroups/'), // Fetching the ad groups from the server
          builder: (context, snapshot) {
            // Building the widget based on the future's state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child:
                      CircularProgressIndicator()); // If the future is still running, showing a CircularProgressIndicator
            } else if (snapshot.hasError) {
              // If the future completed with an error, showing the error
              return Text('Error: ${snapshot.error}');
            } else {
              // If the future completed with data, showing the data
              print(snapshot.data); //Debugging purposes

              List adGroups =
                  snapshot.data; // Converting the data to a list of ad groups
              if (adGroups.isEmpty) {
                return Center(
                    child: Text(
                        'No AdGroups found')); // If the list is empty, showing a message
              } else {
                print(adGroups[0]['name']); //Debugging purposes
                return ListView.builder(
                  itemCount: adGroups.length, // Building each item in the list
                  itemBuilder: (context, index) {
                    final adGroup = adGroups[
                        index]; // Getting the ad group at the current index and returning a Card for the ad group
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(15.0), // Add rounded corners
                      ),
                      color: Colors.grey, // Change the card color
                      child: ListTile(
                        onTap: () => _showPostPage(
                            adGroup), // When the ListTile is tapped, showing the PostPage for the ad group
                        title: Text(
                          adGroup['name'],
                          style: const TextStyle(
                              color: Colors.white), // Change the title color
                        ),
                        subtitle: Text(
                          adGroup['description'],
                          style: const TextStyle(
                              color:
                                  Colors.white70), // Change the subtitle color
                        ),
                        trailing: PopupMenuButton<String>(
                          // Trailing widget (at the end of the ListTile), using a PopupMenuButton
                          onSelected: (value) async {
                            // Action to perform when a menu item is selected
                            if (value == 'Change') {
                              final updatedAdGroup =
                                  await showDialog<AdInGroup>(
                                context: context,
                                builder: (context) => UpdateAdGroupDialog(
                                  // Pass the old name and description to the dialog
                                  oldName: adGroup['name'],
                                  newName: adGroup['name'],
                                  oldDescription: adGroup['description'],
                                  newDescription: adGroup['description'],
                                ),
                              );
                              if (updatedAdGroup != null) {
                                // Update the ad group on the server
                                FrontendToBackendConnection.updateAdInGroup(
                                    adGroup['name'],
                                    updatedAdGroup.name,
                                    adGroup['description']);
                              }
                            } else if (value == 'Delete') {
                              _deleteAdGroup(index,
                                  adGroup['name']); // Delete the ad group
                            }
                          },
                          itemBuilder: (context) => [
                            // Building the menu items
                            const PopupMenuItem(
                              value: 'Change',
                              child: Text('Change'),
                            ),
                            const PopupMenuItem(
                              value: 'Delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            }
          }),
    );
  }
}

// Creating a state that can be persisted over the lifetime of the widget
class PostPage extends StatefulWidget {
  final Map adInGroup; // Declare a variable to hold the ad group data

  PostPage({Key? key, required this.adInGroup})
      : super(
            key:
                key); // Define a constructor for the PostPage widget that requires adInGroup parameter and accepts an optional key

  @override // Create a fresh instance of _PostPageState each time Flutter needs to inflate the widget
  _PostPageState createState() => _PostPageState();
}

// Creating a class thar holds data that can change over the lifetime of the widget
class _PostPageState extends State<PostPage> {
  List<AdInGroup>? ads;
  String? adGroupName;

  // This method runs once when the stateful widget is inserted in the widget tree
  @override
  void initState() {
    super.initState();
    ads = widget.adInGroup[
        'ads']; // Initialize the ads variable with the ads data from the widget
    adGroupName =
        widget.adInGroup['ad_group_name']; // Analog to the ads variable
  }

  // Method to delete an ad in a group
  void _deleteAdInGroup(String name) async {
    Map<String, String> ad = {
      // Map to hold the ad data
      'name': name,
    };
    var token = await FrontendToBackendConnection.getToken();
    try {
      // Try to delete the ad in the group
      await FrontendToBackendConnection.deleteAdInGroup(name, token);
      await Future.delayed(const Duration(seconds: 2)); // Wait for 2 seconds
      print('Ad group name: $name'); //Debugging purposes
      print('Token: $token'); //Debugging purposes

      List<dynamic> data = await FrontendToBackendConnection.getData(
          'get_adsofgroup/'); // Fetch the ads of the group from the server
      if (data != null) {
        List<AdInGroup> adInGroup = // Convert the data to a list of AdInGroup
            data.map((item) => AdInGroup.fromJson(item)).toList();
        print('Fetched ad groups: $adInGroup'); //Debugging purposes

        // Update the state to reflect the changes
        setState(() {});

        print('Updated state with new ads'); //Debugging purposes
      } else {
        print('No Ads found'); //Debugging purposes
      }
    } catch (e) {
      print('Error deleting Ad: $e');
      if (e is http.ClientException && e.message.contains('<!DOCTYPE html>')) {
        // If the error is a ClientException and the message contains '<!DOCTYPE html>'
        print(
            'Server returned an HTML response: ${e.message}'); //Debugging purposes
      } else if (e is http.ClientException && e.message.contains('404')) {
        // Handle 403 error
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(
              content: Text('You are not authorized to delete this ad')),
        );
      } else {
        // Handle other errors
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(content: Text('Failed to delete ad')),
        );
      }
    }
  }

  // Method to build the widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Return a Scaffold widget
      appBar: AppBar(
        title: Text(adGroupName ??
            'Default Title'), // Set the title of the AppBar to ad group name, or 'Default Title' if it's null
      ),
      body: FutureBuilder(
        future: () async {
          // Fetch the ads of the group
          ads = await FrontendToBackendConnection.getAdsOfGroup(adGroupName!)
              as List<AdInGroup>?;
        }(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return ListView.builder(
              itemCount: ads?.length,
              itemBuilder: (context, index) {
                // Build each item in the list
                for (int i = 0; i < ads!.length; i++) {
                  print('Ad name: ${ads![i].name}'); //Debugging purposes
                }
                return Card(
                  child: ListTile(
                    // Create a ListTile for each ad
                    //Debugging purposes
                    title: Text(ads?[index].name ??
                        ''), // Set the title of the ListTile to the name of the ad, or an empty string if it's null
                    subtitle: Text(
                        ads?[index].description ?? ''), //Analog to the title
                    trailing: PopupMenuButton(
                      onSelected: (value) async {
                        // Define a function to handle when a menu item is selected
                        if (value == 'Edit') {
                          // Edit functionality
                        } else if (value == 'Delete') {
                          print('Ads: $ads'); //Debugging purposes
                          _deleteAdInGroup(
                              ads![index].name); // Delete the ad in the group
                        }
                      },
                      itemBuilder: (context) => [
                        // Build the menu items
                        PopupMenuItem(
                          value: 'Edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem(
                          value: 'Delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                    onTap: () {
                      // onTap functionality
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// Class to represent the adgroup page
class AGPage extends StatelessWidget {
  final Map adGroup; // Declare a variable to hold the ad group data

  const AGPage(
      {super.key,
      required this.adGroup}); // Define a constructor for the AGPage widget that requires adGroup parameter and accepts an optional key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons
              .arrow_back), // Leading widget (at the start of the AppBar), using an IconButton
          onPressed: () {
            Navigator.pop(
                context); // Action to perform when the IconButton is pressed
          },
        ),
        title: Text(adGroup['name']),
      ),
      body: SingleChildScrollView(
          // The body of the Scaffold, using a SingleChildScrollView to make the content scrollable
          padding: const EdgeInsets.all(16),
          child: Text(adGroup['description'])),
    );
  }
}

// Class to represent the ad group view
class AdGroupView extends StatelessWidget {
  final List<Map> adGroups; // Declare a variable to hold the ad groups data

  const AdGroupView(
      {super.key,
      required this.adGroups}); // Define a constructor for the AdGroupView widget that requires adGroups parameter and accepts an optional key

  void _showAGPage(BuildContext context, Map adGroup) {
    // Method to show the AGPage
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AGPage(
                adGroup:
                    adGroup))); // Navigate to the AGPage and pass the ad group data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        // Create a ListView.builder to build the list of ad groups
        itemCount: adGroups.length, // Build each item in the list
        itemBuilder: (context, index) {
          final adGroup =
              adGroups[index]; // Get the ad group at the current index
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Add rounded corners
            ),
            color: Colors.grey, // Change the card color
            child: ListTile(
              onTap: () => _showAGPage(context,
                  adGroup), // When the ListTile is tapped, show the AGPage for the ad group
              title: Text(
                adGroup['name'],
                style: const TextStyle(
                    color: Colors.white), // Change the title color
              ),
              subtitle: Text(
                adGroup['description'],
                style: const TextStyle(
                    color: Colors.white70), // Change the subtitle color
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'Change') {
                    final updatedAdGroup = await showDialog<AdGroup>(
                      // Show a dialog to update the ad group
                      context: context,
                      builder: (context) => UpdateAdGroupDialog(
                        // Pass the old name and description to the dialog
                        oldName: adGroup['name'],
                        newName: adGroup['name'],
                        oldDescription: adGroup['description'],
                        newDescription: adGroup['description'],
                      ),
                    );
                    if (updatedAdGroup != null) {
                      FrontendToBackendConnection.updateAdGroup(
                          adGroup['name'], // Update the ad group on the server
                          updatedAdGroup.name,
                          adGroup['description']);
                    }
                  } else if (value == 'Delete') {
                    FrontendToBackendConnection.deleteAdGroup(
                        // Delete the ad group
                        context,
                        index,
                        adGroup['name']);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'Change',
                    child: Text('Change'),
                  ),
                  const PopupMenuItem(
                    value: 'Delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Floating action button to add a new ad group
        onPressed: () async {
          final newAdGroup = await showDialog<AdGroup>(
            // Show a dialog to create a new ad group
            context: context,
            builder: (context) => const CreateAdGroupDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Class to represent an adingroup
class CreateAdInGroupDialog extends StatefulWidget {
  const CreateAdInGroupDialog(
      {super.key}); // Define a constructor for the CreateAdInGroupDialog widget that accepts an optional key

  @override
  _CreateAdInGroupDialogState createState() =>
      _CreateAdInGroupDialogState(); // Create the state for the CreateAdInGroupDialog widget
}

class _CreateAdInGroupDialogState extends State<CreateAdInGroupDialog> {
  // Create the state for the CreateAdInGroupDialog widget
  final _adGroupNameController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController =
      TextEditingController(); // Declare controllers for the text fields

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
        // Return a CupertinoTheme widget (Apple) to style the dialog
        data: const CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: Color(0xFFf46139),
        ),
        child: CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            // Create a CupertinoNavigationBar
            middle: const Text('Create Post'),
            trailing: CupertinoButton(
              // Create a CupertinoButton
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.of(context).pop(AdInGroup(
                  // When the button is pressed, pop the dialog and return the AdInGroup object
                  adGroupName: _adGroupNameController.text,
                  name: _nameController.text,
                  description: _descriptionController.text,
                ));
              },
              child: const Text('Post'),
            ),
          ),
          child: SafeArea(
            // Create a SafeArea widget
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CupertinoTextField(
                    controller:
                        _adGroupNameController, // Create a CupertinoTextField for the ad group name
                    placeholder: 'Ad Group Name',
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoColors.lightBackgroundGray,
                          width: 0.0, // One physical pixel.
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                  CupertinoTextField(
                    controller:
                        _nameController, // Create a CupertinoTextField for the name
                    placeholder: 'Name',
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoColors.lightBackgroundGray,
                          width: 0.0, // One physical pixel.
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  CupertinoTextField(
                    controller:
                        _descriptionController, // Create a CupertinoTextField for the description
                    placeholder: 'Description',
                    maxLines: null,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoColors.lightBackgroundGray,
                          width: 0.0, // One physical pixel.
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

// Class to represent an ad group update
class UpdateAdGroupDialog extends StatefulWidget {
  final String oldName;
  final String oldDescription;
  final String newName;
  final String
      newDescription; // Declare variables to hold the old and new name and description

  const UpdateAdGroupDialog({
    super.key,
    required this.newName,
    required this.newDescription,
    required this.oldName,
    required this.oldDescription, // Define a constructor for the UpdateAdGroupDialog widget that requires the old and new name and description
  });

  @override
  _UpdateAdGroupDialogState createState() =>
      _UpdateAdGroupDialogState(); // Create the state for the UpdateAdGroupDialog widget
}

// Class to represent the state of the UpdateAdGroupDialog widget
class _UpdateAdGroupDialogState extends State<UpdateAdGroupDialog> {
  late TextEditingController _adGroupNameController;
  late TextEditingController _nameController;
  late TextEditingController
      _descriptionController; // Declare controllers for the text fields

  @override
  void initState() {
    // Initialize the state with controllers
    super.initState();
    _adGroupNameController = TextEditingController(text: widget.oldName);
    _nameController = TextEditingController(text: widget.oldName);
    _descriptionController = TextEditingController(text: widget.oldDescription);
  }

  @override
  Widget build(BuildContext context) {
    // Build the widget
    return AlertDialog(
      title: const Text('Update Ad Group'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Action to perform when the button is pressed
            Navigator.of(context).pop(AdInGroup(
              // Pop the dialog and return the AdInGroup object
              adGroupName: _adGroupNameController.text,
              name: _nameController.text,
              description: _descriptionController.text,
            ));
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

// Class to represent an ad group dialog
class CreateAdGroupDialog extends StatefulWidget {
  const CreateAdGroupDialog({Key? key})
      : super(
            key:
                key); // Define a constructor for the CreateAdGroupDialog widget that accepts an optional key

  @override
  _CreateAdGroupDialogState createState() =>
      _CreateAdGroupDialogState(); // Create the state for the CreateAdGroupDialog widget
}

// Class to represent the state of the CreateAdGroupDialog widget
class _CreateAdGroupDialogState extends State<CreateAdGroupDialog> {
  final _formKey = GlobalKey<FormState>(); // Declare a form key

  Map<String, String> adgroup = {
    // Declare a map to hold the ad group data
    'name': '',
    'description': '',
  };

  late TextEditingController _nameController;
  late TextEditingController
      _descriptionController; // Declare controllers for the text fields

  @override
  void initState() {
    // Initialize the state with controllers
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    // Dispose the controllers when the widget is disposed
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Return an AlertDialog widget
      title: const Text('Create Ad Group'),
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  // Validate the name field
                  return 'Please enter a name';
                }
                return null;
              },
              // onSaved: (value) {
              //   _name = value!;
              // },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  // Validate the description field
                  return 'Please enter a description';
                }
                return null;
              },
              // onSaved: (value) {
              //   _description = value!;
              // },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            // Action to perform when the button is pressed
            if (_formKey.currentState!.validate()) {
              // Validate the form
              _formKey.currentState!.save(); // Save the form
              adgroup['name'] = _nameController.text;
              adgroup['description'] = _descriptionController.text;
              await FrontendToBackendConnection.postData(
                  // Send a POST request to the server to create the new ad group
                  "create_adgroup/",
                  adgroup);
              Navigator.of(context).pop(); // Pop the dialog
            }
          },
          child: Text('Create'),
        ),
      ],
    );
  }
}

// void main() {
//   runApp(ChangeNotifierProvider(
//     create: (context) => FrontendToBackendConnection(),
//     child: MaterialApp(
//       home: AdGroupView(adGroups: []),
//     ),
//   ));
// }

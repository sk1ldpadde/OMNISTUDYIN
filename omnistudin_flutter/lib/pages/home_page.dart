import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Post {
  final String description;
  final String? imagePath;
  bool starred;
  final int originalIndex;

  Post(
      {required this.description,
      this.imagePath,
      this.starred = false,
      required this.originalIndex});
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showSearchBar = false;
  final List<Post> _posts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearchBar ? TextField() : Text('Home'),
        leading: IconButton(
          icon: Icon(Icons.add),
          onPressed: () async {
            final newPost = await showDialog<Post>(
              context: context,
              builder: (context) => CreatePostDialog(postCount: _posts.length),
            );
            if (newPost != null) {
              setState(() {
                _posts.insert(0, newPost);
              });
            }
          },
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollUpdateNotification) {
            setState(() {
              _showSearchBar = scrollNotification.scrollDelta! < 0;
            });
          }
          return true;
        },
        child: ListView.builder(
          itemCount: _posts.length,
          itemBuilder: (context, index) {
            final post = _posts[index];
            return Card(
              child: ListTile(
                leading: post.imagePath != null
                    ? Image.file(File(post.imagePath!))
                    : null,
                title: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: post.starred ? Colors.amber : Colors.transparent,
                    ),
                    SizedBox(width: 8),
                    Text(post.description),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'Star') {
                      // Handle star action
                      setState(() {
                        post.starred = !post.starred;
                        _posts.remove(post);
                        if (post.starred) {
                          _posts.insert(0, post);
                        } else {
                          _posts.insert(post.originalIndex, post);
                        }
                      });
                    } else if (value == 'Change') {
                      // Handle change action
                      final updatedPost = await showDialog<Post>(
                        context: context,
                        builder: (context) => CreatePostDialog(
                          initialDescription: post.description,
                          initialImagePath: post.imagePath,
                          postCount: _posts.length,
                        ),
                      );
                      if (updatedPost != null) {
                        setState(() {
                          _posts[index] = updatedPost;
                        });
                      }
                    } else if (value == 'Delete') {
                      // Handle delete action
                      setState(() {
                        _posts.removeAt(index);
                      });
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'Star',
                      child: Text('Star'),
                    ),
                    PopupMenuItem(
                      value: 'Change',
                      child: Text('Change'),
                    ),
                    PopupMenuItem(
                      value: 'Delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CreatePostDialog extends StatefulWidget {
  final String? initialDescription;
  final String? initialImagePath;
  final int postCount;

  CreatePostDialog(
      {this.initialDescription,
      this.initialImagePath,
      required this.postCount});

  @override
  _CreatePostDialogState createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  late TextEditingController _descriptionController;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.initialDescription);
    _imagePath = widget.initialImagePath;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create Post'),
      content: Container(
        height: MediaQuery.of(context).size.height *
            0.4, // Adjust this value as needed
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(hintText: 'Description'),
              ),
              ElevatedButton(
                child: Text('Select Image'),
                onPressed: () async {
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _imagePath = pickedFile.path;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text('Publish'),
          onPressed: () {
            if (_descriptionController.text.isNotEmpty) {
              Navigator.of(context).pop(
                Post(
                    description: _descriptionController.text,
                    imagePath: _imagePath,
                    originalIndex: widget.postCount),
              );
            }
          },
        ),
      ],
    );
  }
}

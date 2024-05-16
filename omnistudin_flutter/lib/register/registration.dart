import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:omnistudin_flutter/register/login.dart';

// Check if the password is strong enough
bool isPasswordStrong(String password) {
  if (password.length < 8) {
    return false;
  }

  // Check for at least one uppercase letter
  if (!password.contains(RegExp(r'[A-Z]'))) {
    return false;
  }

  // Check for at least one lowercase letter
  if (!password.contains(RegExp(r'[a-z]'))) {
    return false;
  }

  // Check for at least one number
  if (!password.contains(RegExp(r'[0-9]'))) {
    return false;
  }

  // Check for at least one special character
  if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    return false;
  }


  return true; // Return true if all checks pass
}

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  // This widget is the page for the registration

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Willkommen'),
      ),
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Willkommen!',
                  style: TextStyle(fontSize: 24.0),
                ), // Text for welcome
                const SizedBox(height: 16.0),
                const Text(
                  'Du bist bald bereit durchzustarten',
                  style: TextStyle(fontSize: 22.0),
                ), // Text for getting started
                const SizedBox(height: 24.0),
                CupertinoButton.filled(
                  child: const Text('Weiter'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const DataEntryPage())); // Navigation to Data Entry Page
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DataEntryPage extends StatefulWidget {
  const DataEntryPage({super.key});
  @override
  DataEntryPageState createState() => DataEntryPageState();
}

class DataEntryPageState extends State<DataEntryPage> {
  File? _image; // variable for image
  final TextEditingController _firstPassword = TextEditingController(); // controller for first password
  final TextEditingController _secondPassword = TextEditingController(); // controller for second password
  DateTime _dateOfBirth = DateTime.now(); // variable for date of birth
  final TextEditingController _email = TextEditingController();  // controller for email
  final TextEditingController _firstName = TextEditingController();  // controller for first name
  final TextEditingController _lastName = TextEditingController();  // controller for last name
  final TextEditingController _bio = TextEditingController(); // controller for bio
  final TextEditingController _university = TextEditingController();  // controller for university
  final TextEditingController _course = TextEditingController(); // controller for course
  final TextEditingController _semester = TextEditingController();  // controller for semester


  // Method for showing date picker for date of birth
  void _showDatePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 200,
        color: CupertinoColors.white,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: _dateOfBirth,
          onDateTimeChanged: (DateTime newDateTime) {
            setState(() {
              _dateOfBirth = newDateTime;
            });
          },
        ),
      ),
    );
  }


  // Method for getting registration data
  Map<String, dynamic> getRegistrationData() {
    String? base64Image;
    if (_image != null) {
      List<int> imageBytes = _image!.readAsBytesSync();
      base64Image = base64Encode(imageBytes);
    }
    return {
      'email': _email.text,
      'password': _firstPassword.text,
      'forename': _firstName.text,
      'surname': _lastName.text,
      'dob': DateFormat('dd-MM-yyyy').format(_dateOfBirth),
      'bio': _bio.text,
      'uni_name': _university.text,
      'degree': _course.text,
      'semester': _semester.text.isNotEmpty ? _semester.text : '-1',
      'profile_picture': base64Image, // Pfad zur Bilddatei
    };
  } // it returns a map with the registration data


  // Method for getting image with image picker
  Future getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }


  // This widget is the page for the data entry
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Registrierung'),
      ),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              const Text(
                'Gib deinen Vornamen ein:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0), // Box with height 8.0 for spacing
              CupertinoTextField(
                controller: _firstName,
                placeholder: 'Vorname',
                padding: const EdgeInsets.all(8.0),
              ), //Input field for first name
              const SizedBox(height: 16.0),
              const Text(
                'Gib deinen Nachnamen ein:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              CupertinoTextField(
                controller: _lastName,
                placeholder: 'Nachname',
                padding: const EdgeInsets.all(12.0),
              ), //Input field for last name
              const SizedBox(height: 16.0), // 16 Pixel Abstand
              const Text(
                'Gib dein Geburtsdatum ein:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0), // 16 Pixel Abstand
              CupertinoButton(
                child: Text(
                  _dateOfBirth == DateTime.now()
                      ? 'Datum auswählen'
                      : DateFormat('dd.MM.yyyy').format(_dateOfBirth),
                  style: const TextStyle(color: CupertinoColors.activeBlue),
                ),
                onPressed: () => _showDatePicker(context),
              ), //this button opens the date picker
              const Text(
                'Gib deine Bio ein:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0), // 16 Pixel Abstand
              CupertinoTextField(
                controller: _bio,
                placeholder: 'Bio',
                padding: const EdgeInsets.all(12.0),
                maxLines: 5,
              ), //Input field for bio
              const SizedBox(height: 16.0),
              const Text(
                'Welche Universität besuchst du?',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              CupertinoTextField(
                controller: _university,
                placeholder: 'Universität',
                padding: const EdgeInsets.all(12.0),
              ), //Input field for university
              const SizedBox(height: 16.0),
              const Text(
                'Welches Studienfach belegst du?',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              CupertinoTextField(
                controller: _course,
                placeholder: 'Studienfach',
                padding: const EdgeInsets.all(12.0),
              ), //Input field for course
              const SizedBox(height: 16.0),
              const Text(
                'Welches Semester belegst du?',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              CupertinoTextField(
                controller: _semester,
                placeholder: 'Semester',
                padding: const EdgeInsets.all(12.0),
                keyboardType: TextInputType.number,
              ), //Input field for semester
              const SizedBox(height: 16.0),
              const Text(
                'Gib deine E-Mail-Adresse ein:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              CupertinoTextField(
                controller: _email,
                placeholder: 'E-Mail-Adresse',
                padding: const EdgeInsets.all(12.0),
                keyboardType: TextInputType.emailAddress,
              ), //Input field for email
              const SizedBox(height: 16.0),
              const Text(
                'Wähle ein sicheres Passwort:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              CupertinoTextField(
                controller: _firstPassword,
                placeholder: 'Passwort',
                padding: const EdgeInsets.all(12.0),
                obscureText: true,
              ), //Input field for password
              const SizedBox(height: 16.0),
              const Text(
                'Bestätige dein Passwort:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0),
              CupertinoTextField(
                controller: _secondPassword,
                placeholder: 'Passwort bestätigen:',
                padding: const EdgeInsets.all(12.0),
                obscureText: true,
              ), //Input field for password confirmation
              const SizedBox(height: 16.0),
              const SizedBox(height: 24.0),
              const Text(
                'Lade ein Profilbild hoch:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(
                  height:
                      16.0),
              Stack(
                alignment: Alignment.center,
                children: [
                  if (_image != null) // If image is not null show the image
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: CupertinoColors.activeBlue,
                          width: 3.0,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                        image: DecorationImage(
                          image: FileImage(_image!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  if (_image == null) // If image is null show the add icon
                    CupertinoButton(
                      onPressed: getImage,
                      padding: EdgeInsets.zero,
                      color: CupertinoColors.white.withOpacity(0.0),
                      minSize: 48.0,
                      child: const Icon(
                        CupertinoIcons.add,
                        color: CupertinoColors.inactiveGray,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24.0),
              CupertinoButton.filled(
                child: const Text('Registrieren'),
                onPressed: () async {
                  if (_firstPassword.text == _secondPassword.text) { // Check if the passwords match
                    if (isPasswordStrong(_firstPassword.text)) { // Check if the password is strong enough and register the user
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => LoginPage())); // Navigation to login page
                    } else {
                      showCupertinoDialog( // Show an alert dialog if the password is not strong enough
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: const Text('Fehler'),
                            content: const Text(
                                'Das Passwort ist nicht sicher genug. Wähle mindestens 8 Zeichen, mindestens einen Großbuchstaben, einen Kleinbuchstaben, eine Zahl und ein Sonderzeichen.'),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('OK'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } else {
                    showCupertinoDialog( // Show an alert dialog if the passwords do not match
                      context: context,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: const Text('Fehler'),
                          content: const Text(
                              'Die Passwörter stimmen nicht überein'),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('OK'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
            ], // Diese schließende Klammer fehlte
          ),
        ),
      ),
    );
  }
}

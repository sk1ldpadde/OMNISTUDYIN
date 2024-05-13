import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:omnistudin_flutter/main.dart';
import 'package:omnistudin_flutter/pages/profile_page.dart';
import 'package:omnistudin_flutter/register/login.dart';
import 'package:provider/provider.dart';
import '../Logic/Frontend_To_Backend_Connection.dart';

bool isPasswordStrong(String password) {
  // Mindestlänge von 8 Zeichen
  if (password.length < 8) {
    return false;
  }

  // Überprüfen auf mindestens einen Großbuchstaben
  if (!password.contains(RegExp(r'[A-Z]'))) {
    return false;
  }

  // Überprüfen auf mindestens einen Kleinbuchstaben
  if (!password.contains(RegExp(r'[a-z]'))) {
    return false;
  }

  // Überprüfen auf mindestens eine Zahl
  if (!password.contains(RegExp(r'[0-9]'))) {
    return false;
  }

  // Überprüfen auf mindestens ein Sonderzeichen
  if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    return false;
  }

  // Wenn alle Kriterien erfüllt sind, ist das Passwort stark
  return true;
}

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

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
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Du bist bald bereit durchzustarten',
                  style: TextStyle(fontSize: 22.0),
                ),
                const SizedBox(height: 24.0),
                CupertinoButton.filled(
                  child: const Text('Weiter'),
                  onPressed: () {
                    // Hier navigieren Sie zur Seite für die Dateneingabe
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const DataEntryPage()));
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
  _DataEntryPageState createState() => _DataEntryPageState();
}

class _DataEntryPageState extends State<DataEntryPage> {
  File? _image;
  final TextEditingController _firstPassword = TextEditingController();
  final TextEditingController _secondPassword = TextEditingController();
  DateTime _dateOfBirth = DateTime.now();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _bio = TextEditingController();
  final TextEditingController _university = TextEditingController();
  final TextEditingController _course = TextEditingController();
  final TextEditingController _semester = TextEditingController();

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
  }

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

  Future getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

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
              const SizedBox(height: 8.0),
              CupertinoTextField(
                controller: _firstName,
                placeholder: 'Vorname',
                padding: const EdgeInsets.all(8.0),
              ),
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
              ),
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
              ),
              const Text(
                'Gib deine Bio ein:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0), // 16 Pixel Abstand
              CupertinoTextField(
                controller: _bio,
                placeholder: 'Bio',
                padding: const EdgeInsets.all(12.0),
                maxLines: 5, // Erlaubt bis zu 5 Zeilen Text
              ), // 16 Pixel Abstand
              const SizedBox(height: 16.0),
              const Text(
                'Welche Universität besuchst du?',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0), // 16 Pixel Abstand
              CupertinoTextField(
                controller: _university,
                placeholder: 'Universität',
                padding: const EdgeInsets.all(12.0),
              ),
              const SizedBox(height: 16.0), // 16 Pixel Abstand
              const Text(
                'Welches Studienfach belegst du?',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0), // 16 Pixel Abstand
              CupertinoTextField(
                controller: _course,
                placeholder: 'Studienfach',
                padding: const EdgeInsets.all(12.0),
              ),
              const SizedBox(height: 16.0), // 16 Pixel Abstand
              const Text(
                'Welches Semester belegst du?',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0), // 16 Pixel Abstand
              CupertinoTextField(
                controller: _semester,
                placeholder: 'Semester',
                padding: const EdgeInsets.all(12.0),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Gib deine E-Mail-Adresse ein:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0), // 16 Pixel Abstand
              CupertinoTextField(
                controller: _email,
                placeholder: 'E-Mail-Adresse',
                padding: const EdgeInsets.all(12.0),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Wähle ein sicheres Passwort:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0), // 16 Pixel Abstand
              CupertinoTextField(
                controller: _firstPassword,
                placeholder: 'Passwort',
                padding: const EdgeInsets.all(12.0),
                obscureText: true,
              ),
              const SizedBox(height: 16.0), // 16 Pixel Abstand
              const Text(
                'Bestätige dein Passwort:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 16.0), // 16 Pixel Abstand
              CupertinoTextField(
                controller: _secondPassword,
                placeholder: 'Passwort bestätigen:',
                padding: const EdgeInsets.all(12.0),
                obscureText: true,
              ),
              const SizedBox(height: 16.0), // 16 Pixel Abstand
              const SizedBox(height: 24.0),
              const Text(
                'Lade ein Profilbild hoch:',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(
                  height:
                      16.0), // 16 Pixel Abstand (nur ein Container mit Höhe 16.0 Pixel
              Stack(
                alignment: Alignment.center,
                children: [
                  if (_image != null)
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
                  if (_image == null)
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
                  if (_firstPassword.text == _secondPassword.text) {
                    if (isPasswordStrong(_firstPassword.text)) {
                      await _register(); // Wait for _register to complete
                      var registrationData = getRegistrationData();
                      Provider.of<RegistrationData>(context, listen: false)
                          .setData(registrationData);
                      print(registrationData); //Debugging purposes

                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => LoginPage()));
                    } else {
                      showCupertinoDialog(
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
                    showCupertinoDialog(
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

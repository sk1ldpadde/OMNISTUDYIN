import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
      navigationBar: const CupertinoNavigationBar(middle: Text('Willkommen'),),
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
                    Navigator.push(context, CupertinoPageRoute(builder: (context) => DataEntryPage()));
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
  const DataEntryPage({Key? key}) : super(key: key);
  @override
  _DataEntryPageState createState() => _DataEntryPageState();
}

class _DataEntryPageState extends State<DataEntryPage> {
  File? _image;
  TextEditingController _firstPassword = TextEditingController();
  TextEditingController _secondPassword = TextEditingController();
  DateTime _dateOfBirth = DateTime.now();
  TextEditingController _email = TextEditingController();
  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();
  TextEditingController _bio = TextEditingController();
  TextEditingController _university = TextEditingController();
  TextEditingController _course = TextEditingController();
  TextEditingController _semester = TextEditingController();


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


  Future getImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

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
      navigationBar: const CupertinoNavigationBar(middle: Text('Registrierung'),),
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Gib deinen Vornamen ein:', style: TextStyle(fontSize: 16.0),),
                  const SizedBox(height: 16.0), // 16 Pixel Abstand (nur ein Container mit Höhe 16.0 Pixel
                  CupertinoTextField(
                    controller: _firstName,
                    placeholder: 'Vorname',
                    padding: EdgeInsets.all(12.0),),
                  const SizedBox(height: 16.0), // 16 Pixel Abstand
                  const Text('Gib deinen Nachnamen ein:', style: TextStyle(fontSize: 16.0),),
                  const SizedBox(height: 16.0), // 16 Pixel Abstand (nur ein Container mit Höhe 16.0 Pixel
                  CupertinoTextField(
                    controller: _lastName,
                    placeholder: 'Nachname',
                    padding: EdgeInsets.all(12.0),),
                  const SizedBox(height: 16.0), // 16 Pixel Abstand
                  const Text('Gib dein Geburtsdatum ein:', style: TextStyle(fontSize: 16.0),),
                  const SizedBox(height: 16.0), // 16 Pixel Abstand
                  CupertinoButton(
                    child: Text(
                      _dateOfBirth == DateTime.now() ? 'Datum auswählen' : DateFormat('dd.MM.yyyy').format(_dateOfBirth),
                      style: TextStyle(color: CupertinoColors.activeBlue),
                    ),
                    onPressed: () => _showDatePicker(context),
                  ),
                  const Text('Gib deine Bio ein:', style: TextStyle(fontSize: 16.0),),
                  const SizedBox(height: 16.0), // 16 Pixel Abstand
                  CupertinoTextField(
                    controller: _bio,
                    placeholder: 'Bio',
                    padding: EdgeInsets.all(12.0),
                    maxLines: 5, // Erlaubt bis zu 5 Zeilen Text
                  ),// 16 Pixel Abstand
                  const SizedBox(height: 16.0),
                  const Text('Welche Universität besuchst du?', style: TextStyle(fontSize: 16.0),),
                  SizedBox(height: 16.0), // 16 Pixel Abstand
                  CupertinoTextField(
                    controller: _university,
                    placeholder: 'Universität',
                    padding: EdgeInsets.all(12.0),
                  ),
                  const SizedBox(height: 16.0), // 16 Pixel Abstand
                  const Text('Welches Studienfach belegst du?', style: TextStyle(fontSize: 16.0),),
                  const SizedBox(height: 16.0), // 16 Pixel Abstand
                  CupertinoTextField(
                    controller: _course,
                    placeholder: 'Studienfach',
                    padding: EdgeInsets.all(12.0),
                  ),
                  const SizedBox(height: 16.0), // 16 Pixel Abstand
                  const Text('Welches Semester belegst du?', style: TextStyle(fontSize: 16.0),),
                  const SizedBox(height: 16.0), // 16 Pixel Abstand
                  CupertinoTextField(
                    controller: _semester,
                    placeholder: 'Semester',
                    padding: EdgeInsets.all(12.0),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Gib deine E-Mail-Adresse ein:', style: TextStyle(fontSize: 16.0),),
                  const SizedBox(height: 16.0), // 16 Pixel Abstand
                  CupertinoTextField(
                    controller: _email,
                    placeholder: 'E-Mail-Adresse',
                    padding: EdgeInsets.all(12.0),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Wähle ein sicheres Passwort:', style: TextStyle(fontSize: 16.0),),
                  const SizedBox(height: 16.0), // 16 Pixel Abstand
                  CupertinoTextField(
                    controller: _firstPassword,
                    placeholder: 'Passwort',
                    padding: EdgeInsets.all(12.0),
                    obscureText: true,
                  ),
                  SizedBox(height: 16.0), // 16 Pixel Abstand
                  const Text('Bestätige dein Passwort:', style: TextStyle(fontSize: 16.0),),
                  SizedBox(height: 16.0), // 16 Pixel Abstand
                  CupertinoTextField(
                    controller: _secondPassword,
                    placeholder: 'Passwort bestätigen:',
                    padding: EdgeInsets.all(12.0),
                    obscureText: true,
                  ),
                  SizedBox(height: 16.0), // 16 Pixel Abstand
                  const SizedBox(height: 24.0),
                  const Text('Lade ein Profilbild hoch:', style: TextStyle(fontSize: 16.0),),
                  SizedBox(height: 16.0), // 16 Pixel Abstand (nur ein Container mit Höhe 16.0 Pixel
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
                          child: Icon(CupertinoIcons.add, color: CupertinoColors.inactiveGray,),
                          onPressed: getImage,
                          padding: EdgeInsets.zero,
                          color: CupertinoColors.white.withOpacity(0.0),
                          minSize: 48.0,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  CupertinoButton.filled(
                    child: const Text('Registrieren'),
                    onPressed: () {
                      if (_firstPassword.text == _secondPassword.text) {
                        if (isPasswordStrong(_firstPassword.text)) {
                          // Hier kannst du die Registrierungslogik implementieren
                        } else {
                          showCupertinoDialog(
                            context: context,
                            builder: (context) {
                              return CupertinoAlertDialog(
                                title: const Text('Fehler'),
                                content: const Text('Das Passwort ist nicht sicher genug. Wähle mindestens 8 Zeichen, mindestens einen Großbuchstaben, einen Kleinbuchstaben, eine Zahl und ein Sonderzeichen.'),
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
                              content: const Text('Die Passwörter stimmen nicht überein'),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
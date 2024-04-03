import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/register/registration.dart';
import '../Logic/Frontend_To_Backend_Connection.dart';

class LoginPage extends StatelessWidget {

  final VoidCallback? onLoginSuccess;

  LoginPage({this.onLoginSuccess});

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  void _login(String email, String password) async {
    try {
      var response = await FrontendToBackendConnection.loginStudent(email, password);
      print('Login successful');
      if (response.statusCode == 200) {
        onLoginSuccess?.call();
      }
    } catch (e) {
      print('Error while trying to register: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Login'),),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: screenHeight * 0.1, // 10% der Bildschirmlänge
                child: Image.asset(
                  'assets/images/line.png',
                  fit: BoxFit.scaleDown, // behält das Seitenverhältnis des Bildes bei
                ),
              ),
              SizedBox(height: 20.0), // 20 Pixel Abstand
              CupertinoTextField(
                controller: _email,
                placeholder: 'E-Mail',
                padding: EdgeInsets.all(12.0),),
              SizedBox(height: 16.0),
              CupertinoTextField(
                controller: _password,
                placeholder: 'Passwort',
                padding: EdgeInsets.all(12.0),
                obscureText: true,
              ),
              SizedBox(height: 24.0),
              GestureDetector(
                onTap: () {
                  // Hier navigieren Sie zur Registrierungsseite
                  Navigator.push(context, CupertinoPageRoute(builder: (context) => RegistrationPage()));
                },
                child: const Text(
                  'Noch kein Konto?  Hier kannst du dich registrieren',
                  style: TextStyle(color: CupertinoColors.activeBlue),
                ),
              ),
              SizedBox(height: 24.0),
              CupertinoButton.filled(
                child: const Text('Anmelden'),
                onPressed: () {
                  try {
                    _login(_email.text, _password.text);
                  } catch (e) {
                    print('Error while trying to login: $e');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
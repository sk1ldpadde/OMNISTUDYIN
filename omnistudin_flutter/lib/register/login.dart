import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/register/registration.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
              const CupertinoTextField(placeholder: 'Benutzername', padding: EdgeInsets.all(12.0),),
              const SizedBox(height: 16.0),
              const CupertinoTextField(
                placeholder: 'Passwort',
                padding: EdgeInsets.all(12.0),
                obscureText: true,
              ),
              const SizedBox(height: 24.0),
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
              const SizedBox(height: 24.0),
              CupertinoButton.filled(
                child: const Text('Anmelden'),
                onPressed: () {
                  // Hier kannst du die Anmeldelogik implementieren
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

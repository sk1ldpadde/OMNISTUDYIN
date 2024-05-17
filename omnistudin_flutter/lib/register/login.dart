import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:omnistudin_flutter/register/registration.dart';
import '../Logic/Frontend_To_Backend_Connection.dart';
import '../main.dart';

class LoginPage extends StatelessWidget {
  final VoidCallback? onLoginSuccess;

  LoginPage({super.key, this.onLoginSuccess});

  final TextEditingController _email = TextEditingController();  // TextController for email
  final TextEditingController _password = TextEditingController(); // TextController for password

  void _login(String email, String password, BuildContext context) async {
    final localContext = context;
    try { // Try to log in
      var response =
      await FrontendToBackendConnection.loginStudent(email, password); // Wait for the response
      if (response.statusCode == 200) {  // If the response is successful, attempt to log in
        onLoginSuccess?.call();   // Call onLoginSuccess
        const LandingPage().createState().checkLoginStatus(); // Check login status
        Navigator.pushReplacementNamed(
          localContext,
          '/',
        ); // Navigate to the home page
      }
    } catch (e) {
      ScaffoldMessenger.of(localContext).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      ); // Display an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    // this is the login page

    return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Login'),
        ),
        child: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: screenHeight * 0.1,
                    child: Image.asset(
                      'assets/images/line.png', // image for login page
                      fit: BoxFit
                          .scaleDown,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  CupertinoTextField( // input field for email
                    controller: _email,
                    placeholder: 'E-Mail',
                    padding: const EdgeInsets.all(12.0),
                  ),
                  const SizedBox(height: 16.0),
                  CupertinoTextField(
                    controller: _password, // input field for password
                    placeholder: 'Passwort',
                    padding: const EdgeInsets.all(12.0),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24.0),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => const RegistrationPage()));
                      }, //Navigation to Registration Page, if user wants to create an account and taps on the text
                    child: const Text(
                      'Noch kein Konto?  Hier kannst du dich registrieren',
                      style: TextStyle(color: CupertinoColors.activeBlue),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  CupertinoButton.filled(
                    child: const Text('Anmelden'), // Login Button
                    onPressed: () {
                      try {
                        _login(_email.text, _password.text, context); // try to login
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ein Fehler ist aufgetreten: $e')),
                        ); // show error message
                        }
                    },
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:okaychata/constants/routes.dart';
import 'package:okaychata/utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: GestureDetector(
        // This is to dismiss keyboard when tapped anywhere on the screen.
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: Container(
          color: Colors.teal[50],
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 0),
            child: Column(
              children: [
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: "Enter your email",
                  ),
                ),
                TextField(
                  controller: _password,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: "Enter your password",
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: TextButton(
                    onPressed: () async {
                      FocusManager.instance.primaryFocus?.unfocus(); // Removing input focus to dismiss keyboard.

                      final email = _email.text;
                      final password = _password.text;

                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                        Navigator.of(context).pushNamedAndRemoveUntil(
                          notesRoute,
                          (route) => false,
                        );
                      } on FirebaseAuthException catch (e) {
                        if (e.code == "user-not-found") {
                          await showErrorDialog(
                            context,
                            "User not found",
                          );
                        } else if (e.code == "wrong-password") {
                          await showErrorDialog(
                            context,
                            "Incorrect password",
                          );
                        } else {
                          await showErrorDialog(
                            context,
                            "Error: ${e.code}",
                          );
                        }
                      } catch (e) {
                        await showErrorDialog(
                          context,
                          e.toString(),
                        );
                      }
                    },
                    child: const Text("Login"),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      registerRoute,
                      (route) => false,
                    );
                  },
                  child: const Text("Go to Register"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
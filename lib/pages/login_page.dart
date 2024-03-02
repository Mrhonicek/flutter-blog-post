import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/components/button.dart';
import 'package:flutter_blog_post_project/components/constants.dart';
import 'package:flutter_blog_post_project/components/textfield.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({
    Key? key,
    required this.showRegisterPage,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  late String errormessage;
  late bool isError;

  @override
  void initState() {
    errormessage = "This is an error";
    isError = false;
    super.initState();
  }

  @override
  void dispose() {
    usernamecontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.background,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'LOGIN',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                            letterSpacing: 2,
                            fontSize: 38,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          height: 70,
                          child: Center(
                            child: Image(
                              image:
                                  const AssetImage('images/blog_post_logo.png'),
                              errorBuilder: (context, error, stackTrace) {
                                return const Text('Error loading image');
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Blog Post App',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        letterSpacing: 2,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(0.9),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset:
                            const Offset(0, 2), // changes the shadow position
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 25,
                        ),
                        child: Column(
                          children: [
                            MyTextField(
                              controller: usernamecontroller,
                              obscureText: false,
                              icon: Icons.alternate_email_rounded,
                              hintText: 'Enter Email',
                            ),
                            const SizedBox(height: 15),
                            MyTextField(
                              controller: passwordcontroller,
                              obscureText: true,
                              icon: Icons.lock,
                              hintText: 'Enter Password',
                            ),
                            const SizedBox(height: 15),
                            MyButton(
                              onTap: () {
                                checkLogin(
                                  usernamecontroller.text.trim(),
                                  passwordcontroller.text.trim(),
                                );
                              },
                              text: "Login",
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: widget.showRegisterPage,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Not a member?",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "Register here!",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            (isError)
                                ? Text(
                                    errormessage,
                                    style: errortxtstyle,
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isLoginInProgress = false;

  Future checkLogin(username, password) async {
    if (isLoginInProgress) {
      return;
    }

    setState(() {
      isLoginInProgress = true;
    });

    showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: username,
        password: password,
      );
      isError = false;
      errormessage = "";
    } on FirebaseAuthException catch (e) {
      print(e);

      isError = true;
      errormessage = e.message.toString();
    } finally {
      setState(() {
        isLoginInProgress = false;
        Navigator.pop(context);
      });
    }
  }
}

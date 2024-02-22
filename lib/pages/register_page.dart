import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/components/button.dart';
import 'package:flutter_blog_post_project/components/textfield.dart';
import 'package:flutter_blog_post_project/models/users.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;

  const RegisterPage({
    Key? key,
    required this.showLoginPage,
  }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
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
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'REGISTER',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                        letterSpacing: 2,
                        fontSize: 38,
                        fontWeight: FontWeight.w600,
                      ),
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
                        offset: Offset(0, 2), // changes the shadow position
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
                              icon: Icons.person,
                              hintText: 'Enter Username',
                            ),
                            const SizedBox(height: 15),
                            MyTextField(
                              controller: emailcontroller,
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
                                registerUser();
                              },
                              text: "REGISTER",
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: widget.showLoginPage,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already have an account?",
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
                                  Expanded(
                                    child: Text(
                                      "Login here!",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
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

  var errortxtstyle = const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.red,
    letterSpacing: 1,
    fontSize: 18,
  );
  var txtstyle = const TextStyle(
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
    fontSize: 38,
  );

  Future createUser() async {
    final user = FirebaseAuth.instance.currentUser!;
    final userId = user.uid;
    final docUser = FirebaseFirestore.instance.collection("Users").doc(userId);

    final newUser = Users(
      createdAt: Timestamp.now(),
      email: emailcontroller.text,
      username: usernamecontroller.text,
      userId: userId,
      bio: 'Empty bio...',
      userImage: '',
    );

    final json = newUser.toJson();
    await docUser.set(json);
  }

  Future<void> registerUser() async {
    if (usernamecontroller.text.trim().isEmpty) {
      // Show alert for empty username
      showAlert("Username cannot be empty.");
      return;
    }

    showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // for user registration purposes
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailcontroller.text.trim(),
        password: passwordcontroller.text.trim(),
      );

      // to create user at the firebase
      createUser();

      setState(() {
        isError = false;
        errormessage = "";
        Navigator.pop(context);
      });
    } on FirebaseAuthException catch (e) {
      print(e);
      setState(() {
        isError = true;
        errormessage = e.message.toString();
        Navigator.pop(context);
      });
    }
  }

  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: TextStyle(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

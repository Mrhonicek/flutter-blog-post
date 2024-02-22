import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/pages/login_page.dart';
import 'package:flutter_blog_post_project/pages/register_page.dart';

class AuthLoginRegister extends StatefulWidget {
  const AuthLoginRegister({super.key});

  @override
  State<AuthLoginRegister> createState() => _AuthLoginRegisterState();
}

class _AuthLoginRegisterState extends State<AuthLoginRegister> {
  //initially show the login page
  bool isLoginPageShown = true;

  void toggleScreens() {
    setState(() {
      isLoginPageShown = !isLoginPageShown;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoginPageShown) {
      return LoginPage(showRegisterPage: toggleScreens);
    } else {
      return RegisterPage(showLoginPage: toggleScreens);
    }
  }
}

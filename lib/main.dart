import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/authenticator.dart';
import 'package:flutter_blog_post_project/theme/default_theme.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter_blog_post_project/theme/custom_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Blog Post',
      debugShowCheckedModeBanner: false,
      theme: defaultTheme,
      darkTheme: customTheme,
      home: const Authenticator(),
    );
  }
}

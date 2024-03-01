import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/authenticator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_blog_post_project/notifications/callLocalNotifications.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'themes/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  await LocalNotification.initialize(flutterLocalNotificationsPlugin);

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
      theme: lightOrangeTheme,
      darkTheme: customTheme,
      home: const Authenticator(),
    );
  }
}

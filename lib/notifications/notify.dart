import 'package:flutter/material.dart';
import 'package:flutter_blog_post_project/notifications/callLocalNotifications.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class Notify extends StatefulWidget {
  const Notify({super.key});

  @override
  State<Notify> createState() => _NotifyState();
}

class _NotifyState extends State<Notify> {
  @override
  void initState() {
    super.initState();
    LocalNotification.initialize(flutterLocalNotificationsPlugin);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3ac3cb), Color(0xFFf85187)])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.blue.withOpacity(0.5),
        ),
        body: Center(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            width: 200,
            height: 80,
            child: ElevatedButton(
              onPressed: () {
                LocalNotification.showBigTextNotification(
                    title: "YOU THERE!",
                    body: "Cook!",
                    fln: flutterLocalNotificationsPlugin);
              },
              child: const Text("Click"),
            ),
          ),
        ),
      ),
    );
  }
}

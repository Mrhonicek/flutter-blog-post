import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  static Future initialize(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize =
        const AndroidInitializationSettings('blog_post_logo');

    var initializationSettings = InitializationSettings(
      android: androidInitialize,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future showBigTextNotification({
    dynamic id = 0,
    required String title,
    required String body,
    var payload,
    required FlutterLocalNotificationsPlugin fln,
  }) async {
    // Ensure that id is not null and is of type int
    if (id != null && id is int) {
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          const AndroidNotificationDetails(
        'you_can_name_it_whatever1',
        'channel_name',
        playSound: true,
        importance: Importance.max,
        priority: Priority.high,
      );

      var not = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      // Use id directly, no need for id.writeInt(0)
      await fln.show(id, title, body, not);
    } else {
      // Handle the case where id is null or not an int
      print("Invalid id: $id");
    }
  }
}

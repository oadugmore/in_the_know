import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'list.dart';

// This "Headless Task" is run when app is terminated.
// void backgroundFetchHeadlessTask(String taskId) async {
//   print('[BackgroundFetch] Headless event received.');
//   BackgroundFetch.finish(taskId);
// }

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails notificationAppLaunchDetails;
ValueNotifier notificationSelected = ValueNotifier(null);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  runApp(MyApp());

}

Future selectNotification(String payload) async {
  if (payload != null) {
    print('notification payload: $payload');
  }
  notificationSelected.value = payload;
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'In The Know',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        buttonColor: Colors.amber[800],
        accentColor: Colors.lightBlue[300],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
        buttonColor: Colors.amber[900],
        accentColor: Colors.blueAccent,
      ),
      home: SituationListPage(title: 'What\'s Happening'),
    );
  }
}

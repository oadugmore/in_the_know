import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'list.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationAppLaunchDetails notificationAppLaunchDetails;
//ValueNotifier notificationSelected = ValueNotifier(null);
VoidCallback notificationSelected;
final backgroundQueryKey = 'backgroundQuery';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeNotificationSettings();
  runApp(MyApp());
}

initializeNotificationSettings() async {
  notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  var initializationSettingsAndroid =
      AndroidInitializationSettings('ic_stat_name');
  var initializationSettingsIOS;
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: selectNotification);
}

Future selectNotification(String payload) async {
  if (payload != null) {
    print('notification payload: $payload');
  }
  // if (notificationSelected.value == payload) {
  //   print('Duplicate payload.');
  //   payload = '';
  // }
  notificationSelected();
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

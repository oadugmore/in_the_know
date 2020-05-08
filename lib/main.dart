import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'list.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final situationKey = 'situation';
final backgroundQueryKey = 'backgroundQuery';
final backgroundTaskEnabledKey = 'backgroundTaskEnabled';
final notificationColorKey = 'notificationColor';
final notificationColor = Colors.amber;

void main() {
  runApp(MyApp());
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

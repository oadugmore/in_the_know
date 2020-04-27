import 'package:flutter/material.dart';

import 'list.dart';

// This "Headless Task" is run when app is terminated.
// void backgroundFetchHeadlessTask(String taskId) async {
//   print('[BackgroundFetch] Headless event received.');
//   BackgroundFetch.finish(taskId);
// }

void main() {
  runApp(MyApp());

  // Register to receive BackgroundFetch events after app is terminated.
  // Requires {stopOnTerminate: false, enableHeadless: true}
  //BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
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

import 'package:flutter/material.dart';

import 'list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'In The Know',
      theme: ThemeData(
        primarySwatch: Colors.lime,
        cardColor: Colors.amber[400],
        accentColor: Colors.lightBlue[300],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.lime,
        cardColor: Colors.amber[800],
        accentColor: Colors.blue
      ),
      home: SituationListPage(title: 'What\'s Happening'),
    );
  }
}

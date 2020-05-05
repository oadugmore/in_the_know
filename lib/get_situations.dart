import 'dart:convert';
import 'dart:ui';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'situation.dart';
import 'package:http/http.dart' as http;

var notificationColor;

Future<List<Situation>> getNerData(String query, bool useLocalServer) async {
    var result;
    // var situations = List<Situation>();
    final safeQuery = Uri.encodeComponent(query);
    const remoteBaseUrl =
        'https://us-central1-in-the-know-82723.cloudfunctions.net/get_situations';
    const localBaseUrl = 'http://10.0.2.2:8080';
    final url =
        (useLocalServer ? localBaseUrl : remoteBaseUrl) + '?q=' + safeQuery;

    try {
      print('Searching query "$safeQuery"');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        result = Situation.allFromJson(response.body);
      } else {
        print(
            'HTTP request returned status code ${response.statusCode.toString()}.');
      }
    } catch (exception) {
      print('Error: ' + exception.toString());
    }
    return result;
  }

  void backgroundTask(String taskId) async {
    var prefs = await SharedPreferences.getInstance();
    var bgNerQuery = prefs.getString(backgroundQueryKey) ?? '';
    print('Running background search with query "$bgNerQuery".');
    var situations = await getNerData(bgNerQuery, false);
    if (situations.length > 0) {
      print('Found situations, saving to SharedPreferences and sending notification...');
      await prefs.setString(situationKey, jsonEncode(situations.first));
      var colorValue = prefs.getInt(notificationColorKey) ?? Colors.white.value;
      notificationColor = Color(colorValue);
      var androidChannelSpecifics = AndroidNotificationDetails(
        'situations',
        'Situations',
        null,
        color: notificationColor,
        importance: Importance.High,
        priority: Priority.High,
        icon: 'ic_stat_name',
      );
      var iOSChannelSpecifics = IOSNotificationDetails();
      var notificationDetails =
          NotificationDetails(androidChannelSpecifics, iOSChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        situations.first.type,
        '${situations.first.statuses.length} people Tweeting',
        notificationDetails,
        payload: 'sample payload',
      );
    } else {
      print('Didn\'t find any situations.');
    }
    BackgroundFetch.finish(taskId);
  }
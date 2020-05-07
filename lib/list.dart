import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_the_know/detail.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_the_know/main.dart';
import 'package:in_the_know/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'get_situations.dart' as get_situations;
import 'situation.dart';

class SituationListPage extends StatefulWidget {
  SituationListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  createState() => SituationListPageState();
}

class SituationListPageState extends State<SituationListPage> {
  String _nerQuery = '';
  bool _loading = false;
  var _situations = new List<Situation>();
  var _prefs = SharedPreferences.getInstance();
  bool _useLocalServer = false;

  @override
  void initState() {
    super.initState();
    initializeNotificationSettings();

    // Configure background fetch when SharedPrefs is available
    _prefs.then((final prefs) async {
      final currentColor = Theme.of(context).primaryColor;
      get_situations.notificationColor = currentColor;
      prefs.setInt(notificationColorKey, currentColor.value);
      var enableBackground = prefs.getBool(backgroundTaskEnabledKey) ?? false;
      await BackgroundFetch.configure(
              BackgroundFetchConfig(
                minimumFetchInterval: 15,
                stopOnTerminate: false,
                enableHeadless: true,
                startOnBoot: true,
                requiresBatteryNotLow: true,
                requiredNetworkType: NetworkType.ANY,
              ),
              get_situations.backgroundTask)
          .then((int status) => print('Configured background fetch.'))
          .catchError((e) => print('Error configuring background fetch: $e'));
      await BackgroundFetch.registerHeadlessTask(get_situations.backgroundTask);

      if (!enableBackground) {
        await BackgroundFetch.stop();
      }
    });
  }

  void initializeNotificationSettings() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_name');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  Future selectNotification(String payload) async {
    // if (payload != null) {
    //   print('Selected notification with payload: $payload');
    // }
    final prefs = await _prefs;
    print('Retrieving situation from notification.');
    var storedSituation = prefs.getString(situationKey);
    if (storedSituation != null) {
      final situationFromNotification =
          Situation.fromJson(jsonDecode(storedSituation));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SituationDetailPage(
            currentSituation: situationFromNotification,
          ),
        ),
      );
    } else {
      print(
          'Error: No situations detected, even though a notification was clicked.');
    }
  }

  void _submitQuery(String text) async {
    _nerQuery = text;
    if (text.trim().isEmpty) {
      setState(() {
        _situations.clear();
      });
      return;
    }
    setState(() {
      _loading = true;
    });
    _situations = await get_situations.getNerData(text, _useLocalServer);
    setState(() {
      _loading = false;
    });
  }

  Widget _enableNotificationsCard() {
    return Card(
      color: Theme.of(context).primaryColor,
      child: ListTile(
        title: Text('Get notifications for this query'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsPage(
                queryForBackgroundTask: _nerQuery,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _situationsWidget() {
    if (_loading) {
      return Container(
        margin: EdgeInsets.only(top: 20),
        height: 80,
        width: 80,
        child: CircularProgressIndicator(
          strokeWidth: 8,
        ),
      );
    }

    var cardList = <Card>[];
    if (_nerQuery.trim() != '') {
      cardList.add(_enableNotificationsCard());
    }
    for (var currentSituation in _situations) {
      var titleText = currentSituation.type;
      if (currentSituation.locations.length > 0) {
        titleText += ' near ${currentSituation.locations[0].name}';
      } else {
        titleText += ', location unknown';
      }
      var subtitleText = '${currentSituation.statuses.length} people tweeting';
      cardList.add(
        Card(
          color: Theme.of(context).buttonColor,
          child: ListTile(
            title: Text(titleText),
            subtitle: Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(subtitleText),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SituationDetailPage(
                    currentSituation: currentSituation,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(8.0),
        children: cardList,
      ),
    );
  }

  _clickAppBarAction(String action) {
    switch (action) {
      case AppBarActions.settings:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsPage(),
          ),
        );
        break;
      default:
        print('Error: $action has not been added as an AppBarAction.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: AppBarActions.settings,
            onPressed: () => _clickAppBarAction(AppBarActions.settings),
          )
          // PopupMenuButton<String>(
          //   onSelected: _selectOverflowMenuChoice,
          //   itemBuilder: (context) {
          //     return OverflowMenuChoices.choices.map((String choice) {
          //       return PopupMenuItem<String>(
          //         child: Text(choice),
          //         value: choice,
          //       );
          //     }).toList();
          //   },
          // ),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 8, top: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onSubmitted: _submitQuery,
                      onChanged: (value) => _nerQuery = value,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Enter location or other search term',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    tooltip: 'Search',
                    onPressed: () => _submitQuery(_nerQuery),
                  ),
                ],
              ),
            ),
            if (kDebugMode)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Use local server'),
                  Switch(
                    onChanged: (value) => setState(
                      () => _useLocalServer = value,
                    ),
                    value: _useLocalServer,
                  ),
                ],
              ),
            if (_situations.length == 0 && !_loading)
              Text((_nerQuery == '')
                  ? 'Type something in the box to get started!'
                  : 'No situations found.'),
            _situationsWidget(),
          ],
        ),
      ),
    );
  }
}

class AppBarActions {
  static const String settings = 'Settings';

  static const List<String> all = <String>[
    settings,
  ];
}

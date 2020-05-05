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

class SituationListPageState extends State<SituationListPage>
    with WidgetsBindingObserver {
  String _nerQuery = '';
  String _nerData = '';
  bool _loading = false;
  var _situations = new List<Situation>();
  var _prefs = SharedPreferences.getInstance();
  bool _useLocalServer = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    get_situations.appLifecycleState = AppLifecycleState.resumed;
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
    var initializationSettingsIOS;
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    get_situations.appLifecycleState = state;
    print('Changed app lifecycle state to $state');
    super.didChangeAppLifecycleState(state);
  }

  void _submitQuery(String text) async {
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

  _selectOverflowMenuChoice(OverflowMenuChoice choice) {
    switch (choice.title) {
      case 'Settings':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsPage(),
          ),
        );
        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<OverflowMenuChoice>(
            onSelected: _selectOverflowMenuChoice,
            itemBuilder: (context) {
              return choices.map((OverflowMenuChoice choice) {
                return PopupMenuItem<OverflowMenuChoice>(
                  child: Text(choice.title),
                  value: choice,
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(8),
              // decoration: BoxDecoration(
              //   border: Border(
              //     bottom: BorderSide(
              //       width: 0,
              //     ),
              //   ),
              // ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onSubmitted: _submitQuery,
                      onChanged: (value) => _nerQuery = value,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Enter location or other search term',
                        // border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _submitQuery(_nerQuery),
                    icon: Icon(Icons.search),
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

class OverflowMenuChoice {
  const OverflowMenuChoice({this.title});

  final String title;
}

const List<OverflowMenuChoice> choices = const <OverflowMenuChoice>[
  const OverflowMenuChoice(title: 'Settings'),
];

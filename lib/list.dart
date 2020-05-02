import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_the_know/detail.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_the_know/main.dart';
import 'package:in_the_know/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'situation.dart';

class SituationListPage extends StatefulWidget {
  SituationListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  createState() => SituationListPageState();
}

class SituationListPageState extends State<SituationListPage> {
  String _nerQuery = '';
  String _nerData = '';
  bool _loading = false;
  var _situations = new List<Situation>();
  var _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();

    // Add callback for notifiation selected
    notificationSelected = (() {
      if (_situations.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SituationDetailPage(
              currentSituation: _situations.first,
            ),
          ),
        );
      } else {
        print(
            'Error: No situations detected, even though a notification was clicked.');
      }
    });

    // Configure background fetch when SharedPrefs is available
    _prefs.then((final prefs) async {
      var enableBackground = prefs.getBool(backgroundTaskEnabledKey) ?? false;
      await BackgroundFetch.configure(
              BackgroundFetchConfig(
                minimumFetchInterval: 15,
                stopOnTerminate: false,
                enableHeadless: true,
                requiredNetworkType: NetworkType.ANY,
              ),
              _backgroundTask)
          .then((int status) => print('Configured background fetch.'))
          .catchError((e) => print('Error configuring background fetch: $e'));

      if (!enableBackground) {
        await BackgroundFetch.stop();
      }
    });
  }

  _getNerData(String query) async {
    var result;
    String safeQuery = Uri.encodeComponent(query);
    // local testing URL
    //var url = 'http://10.0.2.2:8080?q=' + safeQuery;
    //var url = 'http://192.168.1.101:8080?q=' + safeQuery;
    var url =
        'https://us-central1-in-the-know-82723.cloudfunctions.net/get_situations?q=' +
            safeQuery;
    setState(() {
      _loading = true;
    });

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        result = Situation.allFromJson(response.body);
        // result = Situation.allFromJson(jsonDecode(
        // '{"situations": [{"type": "type1", "locations": [{"name": "loc1", "frequency": "0.85"}, {"name": "loc2", "frequency": "0.15"}]}, {"type": "type2", "locations": [{"name": "loc3", "frequency": "0.5"}, {"name": "loc4", "frequency": "0.5"}]}] }'));
        setState(() {
          //_nerData = result;
          _situations = result;
        });
      } else {
        print(
            'HTTP request returned status code ${response.statusCode.toString()}.');
      }
    } catch (exception) {
      print('Error: ' + exception.toString());
    }
    setState(() {
      _loading = false;
    });
  }

  _submitQuery(String text) {
    if (text.trim().isEmpty) {
      setState(() {
        _situations.clear();
      });
      return;
    }
    _getNerData(text);
  }

  _backgroundTask(String taskId) async {
    var prefs = await SharedPreferences.getInstance();
    _nerQuery = prefs.getString(backgroundQueryKey) ?? '';
    //print('task ID $taskId');
    print('Running background search with query "$_nerQuery".');
    await _getNerData(_nerQuery);
    if (_situations.length > 0) {
      print('Found situations, sending notification...');
      var androidChannelSpecifics = AndroidNotificationDetails(
        'situations',
        'Situations',
        null,
        color: Theme.of(context).primaryColor,
        importance: Importance.High,
        priority: Priority.High,
      );
      var iOSChannelSpecifics = IOSNotificationDetails();
      var notificationDetails =
          NotificationDetails(androidChannelSpecifics, iOSChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        _situations.first.type,
        '${_situations.first.statuses.length} people Tweeting',
        notificationDetails,
        payload: 'sample payload',
      );
    } else {
      print('Didn\'t find any situations.');
    }
    BackgroundFetch.finish(taskId);
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

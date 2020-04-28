import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_the_know/detail.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_the_know/main.dart';
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
  bool _backgroundTaskEnabled = false;
  bool _backgroundTaskConfigured = false;

  @override
  void initState() {
    super.initState();
    notificationSelected.addListener(() {
      if (_situations.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SituationDetailPage(
              currentSituation: _situations.first,
            ),
          ),
        );
      }
      else {
        print('Error: No situations detected, even though a notification was clicked.');
      }
    });
    print('added listener');
  }

  _getNerData(String query) async {
    if (query.trim().isEmpty) return null;
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

  _toggleBackgroundTaskEnabled(bool enabled) {
    setState(() {
      _backgroundTaskEnabled = enabled;
    });
    if (_backgroundTaskEnabled) {
      //if (_backgroundTaskConfigured) {
      //BackgroundFetch.start();
      //} else {
      _configureBackgroundTask();
      //}
    } else {
      BackgroundFetch.stop();
    }
  }

  _configureBackgroundTask() async {
    BackgroundFetch.configure(
            BackgroundFetchConfig(
              minimumFetchInterval: 15,
              stopOnTerminate: false,
              enableHeadless: true,
              requiredNetworkType: NetworkType.ANY,
            ),
            _backgroundTask)
        .then((int status) => print('Configured background task'))
        .catchError((e) => print('Error configuring background task: $e'));

    BackgroundFetch.scheduleTask(TaskConfig(
      taskId: 'com.oadugmore.customtask',
      delay: 5000,
      periodic: false,
      enableHeadless: true,
    ));

    _backgroundTaskConfigured = true;
  }

  _backgroundTask(String taskId) async {
    print('hello from task ID $taskId');
    await _getNerData(_nerQuery);
    if (_situations.length > 0) {
      print('found situations. sending notification...');
      await flutterLocalNotificationsPlugin.show(0, _situations.first.type, '${_situations.first.statuses.length} people Tweeting', null);
    } else {
      print('didnt find any situations.');
    }
    BackgroundFetch.finish(taskId);
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
    if (_situations.length == 0) {
      String message = _nerQuery == ''
          ? 'Type something in the box to get started!'
          : 'No situations found.';
      return Text(message);
    }
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _situations.length,
        itemBuilder: (context, index) {
          Situation currentSituation = _situations[index];
          String titleText = currentSituation.type;
          if (currentSituation.locations.length > 0) {
            titleText += ' near ${currentSituation.locations[0].name}';
          } else {
            titleText += ', location unknown';
          }
          String subtitleText =
              '${currentSituation.statuses.length} people tweeting';
          return Card(
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
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('Enable background task'),
                Switch(
                  value: _backgroundTaskEnabled,
                  onChanged: _toggleBackgroundTaskEnabled,
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0,
                  ),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter location or other search term',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) async => await _getNerData(value),
                      onChanged: (value) => _nerQuery = value,
                    ),
                  ),
                  IconButton(
                    onPressed: () async => await _getNerData(_nerQuery),
                    icon: Icon(Icons.search),
                  ),
                ],
              ),
            ),
            _situationsWidget(),
          ],
        ),
      ),
    );
  }
}

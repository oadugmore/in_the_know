import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.queryForBackgroundTask}) : super(key: key);

  final String queryForBackgroundTask;

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  var _backgroundTaskEnabled = false;
  var _prefs = SharedPreferences.getInstance();
  // bool _backgroundTaskConfigured = false;

  @override
  void initState() {
    super.initState();
    if (widget.queryForBackgroundTask != null) {
      _setBackgroundTaskQuery(widget.queryForBackgroundTask);
    }
    _prefs.then((final prefs) {
      setState(() {
        _backgroundTaskEnabled = prefs.getBool(backgroundTaskEnabledKey) ?? false;
      });
    });
  }

  // _initAsync() async {
  //   final prefs = await _prefs;
  //   setState(() {
  //     _backgroundTaskEnabled = prefs.getBool(backgroundTaskEnabledKey) ?? false;
  //   });
  // }

  _setBackgroundTaskQuery(String query) async {
    var prefs = await _prefs;
    await prefs.setString(backgroundQueryKey, query);
    print('saved $query as background query');
  }

  _toggleBackgroundTaskEnabled(bool enabled) async {
    setState(() {
      _backgroundTaskEnabled = enabled;
    });

    final prefs = await _prefs;
    prefs.setBool(backgroundTaskEnabledKey, _backgroundTaskEnabled);
    if (_backgroundTaskEnabled) {
      BackgroundFetch.start();
      // _scheduleBackgroundTask();
    } else {
      BackgroundFetch.stop();
    }
  }

  _scheduleBackgroundTask() async {
    BackgroundFetch.scheduleTask(TaskConfig(
      taskId: 'com.oadugmore.customtask',
      delay: 5000,
      periodic: false,
      enableHeadless: true,
      stopOnTerminate: false,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Background search',
                    ),
                    onSubmitted: (value) => _setBackgroundTaskQuery(value),
                  ),
                ),
                Text('Enabled'),
                Switch(
                  value: _backgroundTaskEnabled,
                  onChanged: _toggleBackgroundTaskEnabled,
                ),
              ],
            ),
          ),
          RaisedButton(
            onPressed: _scheduleBackgroundTask,
            child: Text('Run in 5 seconds'),
          )
        ],
      ),
    );
  }
}

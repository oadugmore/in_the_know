import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';
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
  var _packageInfo = PackageInfo.fromPlatform();
  var _packageVersion = '';
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.queryForBackgroundTask != null) {
      _setBackgroundTaskQuery(widget.queryForBackgroundTask);
      _toggleBackgroundTaskEnabled(true);
    }
    _packageInfo.then((final packageInfo) {
      setState(() {
        _packageVersion = packageInfo.version;
      });
    });
    _prefs.then((final prefs) {
      if (widget.queryForBackgroundTask == null) {
        setState(() {
          _backgroundTaskEnabled =
              prefs.getBool(backgroundTaskEnabledKey) ?? false;
        });
      }
      var nerQuery = prefs.getString(backgroundQueryKey) ?? '';
      _controller.text = nerQuery;
    });
  }

  _setBackgroundTaskQuery(String query) async {
    var prefs = await _prefs;
    await prefs.setString(backgroundQueryKey, query);
    print('Saved "$query" as background query.');
  }

  _toggleBackgroundTaskEnabled(bool enabled) async {
    setState(() {
      _backgroundTaskEnabled = enabled;
    });

    final prefs = await _prefs;
    prefs.setBool(backgroundTaskEnabledKey, _backgroundTaskEnabled);
    if (_backgroundTaskEnabled) {
      BackgroundFetch.start();
    } else {
      BackgroundFetch.stop();
    }
  }

  _scheduleBackgroundTask() async {
    await BackgroundFetch.scheduleTask(TaskConfig(
      taskId: 'com.oadugmore.customtask',
      delay: 5000,
      periodic: false,
      enableHeadless: true,
      stopOnTerminate: false,
    ));
    print('Background task scheduled, running in 5 seconds.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              'Notifications',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          SwitchListTile(
            title: Text('Enable notifications'),
            onChanged: _toggleBackgroundTaskEnabled,
            value: _backgroundTaskEnabled,
          ),
          ListTile(
            title: TextField(
              enabled: _backgroundTaskEnabled,
              onSubmitted: (value) => _setBackgroundTaskQuery(value),
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Search term',
                hintText: 'Enter a search term to get notifications for',
              ),
            ),
          ),
          ListTile(
            title: Text(
              'About',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          AboutListTile(
            applicationVersion: 'Version $_packageVersion',
            applicationLegalese: '© 2020 Owen Dugmore',
          ),
          if (kDebugMode)
            ListTile(
              title: RaisedButton(
                onPressed: _scheduleBackgroundTask,
                child: Text('Run in 5 seconds'),
              ),
            ),
        ],
      ),
    );
  }
}

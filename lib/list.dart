import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_the_know/detail.dart';
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
  var _situations = new List<Situation>();

  _getNerData(String query) async {
    if (query.trim().isEmpty) return null;
    var result;
    String safeQuery = Uri.encodeComponent(query);
    // local testing URL
    //var url = 'http://10.0.2.2:8080?loc=' + safeQuery;
    //var url = 'http://192.168.1.101:8080?loc=' + safeQuery;
    var url =
        'https://us-central1-in-the-know-82723.cloudfunctions.net/get_situations?loc=' +
            safeQuery;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(children: <Widget>[
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
          Expanded(
            child: (_situations.length == 0)
                ? Text('No situations found.')
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _situations.length,
                    itemBuilder: (context, index) {
                      Situation currentSituation = _situations[index];
                      String titleText = currentSituation.type;
                      if (currentSituation.locations.length > 0) {
                        titleText +=
                            ' near ${currentSituation.locations[0].name}';
                      } else {
                        titleText += ', location unknown';
                      }
                      String subtitleText = '${currentSituation.statuses.length} people tweeting';
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
          ),
        ]),
      ),
    );

    // floatingActionButton: FloatingActionButton(
    //   onPressed: _testTwitterApi,
    //   child: Icon(Icons.new_releases),
    // ), // This trailing comma makes auto-formatting nicer for build methods.
  }
}

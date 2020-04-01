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
    var url = 'https://us-central1-in-the-know-82723.cloudfunctions.net/get_situations?loc=' + safeQuery;

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
          TextField(
            onSubmitted: (value) async {
              await _getNerData(value);
            },
            onChanged: (value) => _nerQuery = value,
          ),
          RaisedButton(
            onPressed: () async => await _getNerData(_nerQuery),
            child: Text('Refresh'),
          ),
          Expanded(
            child: (_situations.length == 0)
                ? Text('No situations found.')
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _situations.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SituationDetailPage(
                                  currentSituation: _situations[index],
                                ),
                              ),
                            );
                          },
                          title: Text('SITUATION: ${_situations[index].type}'),
                          subtitle: Column(
                            children: <Widget>[
                              Text('Locations mentioned:'),
                              Column(
                                children: [
                                  for (var location
                                      in _situations[index].locations)
                                    Text(
                                        '${location.name}, frequency: ${location.frequency.toString()}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ]),

        //crossAxisAlignment: CrossAxisAlignment.start,
        // children: <Widget>[
        //   Container(
        //     margin: EdgeInsets.only(top: 20, bottom: 20, left: 8),
        //     child: Text(
        //       'News',
        //       style: Theme.of(context).textTheme.headline6,
        //     ),
        //   ),
        //   Container(
        //     color: Colors.grey[200],
        //     height: 200,
        //     child: ListView(
        //       scrollDirection: Axis.horizontal,
        //       padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        //       children: <Widget>[
        //         Container(
        //           margin: EdgeInsets.symmetric(horizontal: 4),
        //           width: 200,
        //           child: Material(
        //             color: Colors.white,
        //             child: InkWell(
        //               onTap: () => {/* TODO */},
        //               child: Column(
        //                 children: <Widget>[
        //                   Container(
        //                     color: Colors.grey[400],
        //                     child: Icon(
        //                       Icons.image,
        //                       size: 100,
        //                     ),
        //                     height: 100,
        //                     width: 200,
        //                   ),
        //                   Container(
        //                     padding: EdgeInsets.all(8),
        //                     child: Column(
        //                       children: <Widget>[
        //                         Align(
        //                           alignment: Alignment.topLeft,
        //                           child: Text(
        //                             'KTLA',
        //                             style:
        //                                 Theme.of(context).textTheme.bodyText1,
        //                           ),
        //                         ),
        //                         Align(
        //                           alignment: Alignment.topLeft,
        //                           child: Text(
        //                             'Chase in LA',
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ),
        //         ),
        //         Container(
        //           margin: EdgeInsets.symmetric(horizontal: 4),
        //           width: 200,
        //           child: Material(
        //             color: Colors.white,
        //             child: InkWell(
        //               onTap: () => {/* TODO */},
        //               child: Column(
        //                 children: <Widget>[
        //                   Container(
        //                     color: Colors.grey[400],
        //                     child: Icon(
        //                       Icons.image,
        //                       size: 100,
        //                     ),
        //                     height: 100,
        //                     width: 200,
        //                   ),
        //                   Container(
        //                     padding: EdgeInsets.all(8),
        //                     child: Column(
        //                       children: <Widget>[
        //                         Align(
        //                           alignment: Alignment.topLeft,
        //                           child: Text(
        //                             'ABC7',
        //                             style:
        //                                 Theme.of(context).textTheme.bodyText1,
        //                           ),
        //                         ),
        //                         Align(
        //                           alignment: Alignment.topLeft,
        //                           child: Text(
        //                             'Unfolding chaos in the downtown area',
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        //   Container(
        //     margin: EdgeInsets.only(top: 20, bottom: 20, left: 8),
        //     child: Text(
        //       'Twitter',
        //       style: Theme.of(context).textTheme.headline6,
        //     ),
        //   ),
        //   Container(
        //     color: Colors.grey[200],
        //     height: 200,
        //     child: ListView(
        //       scrollDirection: Axis.horizontal,
        //       padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        //       children: <Widget>[
        //         Container(
        //           margin: EdgeInsets.symmetric(horizontal: 4),
        //           width: 200,
        //           child: Material(
        //             color: Colors.white,
        //             child: InkWell(
        //               onTap: () => {/* TODO */},
        //               child: Column(
        //                 children: <Widget>[
        //                   Container(
        //                     color: Colors.grey[400],
        //                     child: Icon(
        //                       Icons.person,
        //                       size: 100,
        //                     ),
        //                     height: 100,
        //                     width: 200,
        //                   ),
        //                   Container(
        //                     padding: EdgeInsets.all(8),
        //                     child: Column(
        //                       children: <Widget>[
        //                         Align(
        //                           alignment: Alignment.topLeft,
        //                           child: Text(
        //                             '@LAPD',
        //                             style:
        //                                 Theme.of(context).textTheme.bodyText1,
        //                           ),
        //                         ),
        //                         Align(
        //                           alignment: Alignment.topLeft,
        //                           child: Text(
        //                             '"Avoid this intersection for now."',
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ),
        //         ),
        //         Container(
        //           margin: EdgeInsets.symmetric(horizontal: 4),
        //           width: 200,
        //           child: Material(
        //             color: Colors.white,
        //             child: InkWell(
        //               onTap: () => {/* TODO */},
        //               child: Column(
        //                 children: <Widget>[
        //                   Container(
        //                     color: Colors.grey[400],
        //                     child: Icon(
        //                       Icons.person,
        //                       size: 100,
        //                     ),
        //                     height: 100,
        //                     width: 200,
        //                   ),
        //                   Container(
        //                     padding: EdgeInsets.all(8),
        //                     child: Column(
        //                       children: <Widget>[
        //                         Align(
        //                           alignment: Alignment.topLeft,
        //                           child: Text(
        //                             '@twitteruser335',
        //                             style:
        //                                 Theme.of(context).textTheme.bodyText1,
        //                           ),
        //                         ),
        //                         Align(
        //                           alignment: Alignment.topLeft,
        //                           child: Text(
        //                             '"I saw it! They\'re headed towards Main Street!"',
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ),
        //         ),
        //         Container(
        //           margin: EdgeInsets.symmetric(horizontal: 4),
        //           width: 200,
        //           child: Material(
        //             color: Colors.white,
        //             child: InkWell(
        //               onTap: () => {/* TODO */},
        //               child: Column(
        //                 children: <Widget>[
        //                   Container(
        //                     color: Colors.grey[400],
        //                     child: Icon(
        //                       Icons.person,
        //                       size: 100,
        //                     ),
        //                     height: 100,
        //                     width: 200,
        //                   ),
        //                   Container(
        //                     padding: EdgeInsets.all(8),
        //                     child: Column(
        //                       children: <Widget>[
        //                         Align(
        //                           alignment: Alignment.topLeft,
        //                           child: Text(
        //                             '@unituint',
        //                             style:
        //                                 Theme.of(context).textTheme.bodyText1,
        //                           ),
        //                         ),
        //                         Align(
        //                           alignment: Alignment.topLeft,
        //                           child: Text(
        //                             '"What\'s all that noise?"',
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _testTwitterApi,
      //   child: Icon(Icons.new_releases),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

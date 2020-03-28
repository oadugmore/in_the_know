import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_functions/cloud_functions.dart';
import 'situation.dart';

class SituationList extends StatefulWidget {
  SituationList({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  createState() => SituationListState();
}

class SituationListState extends State<SituationList> {
  int _counter = 0;
  String _nerQuery = '';
  String _nerData = '';
  var _situations = new List<Situation>();

  _getNerData(String query) async {
    if (query.trim().isEmpty) return;
    // local testing URL
    dynamic result;
    String safeQuery = Uri.encodeComponent(query);
    var url = 'http://10.0.2.2:8080?loc=' + safeQuery;

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        //dynamic responseData = response.body;
        //result = responseData['rawData'];
        //result = Situation.allFromJson(jsonDecode(response.body));
        result = Situation.allFromJson(jsonDecode("{\"situations\": [{\"type\": \"type1\", \"location\": \"loc1\"}, {\"type\": \"type2\", \"location\": \"loc2\"}, {\"type\": \"type3\", \"location\": \"loc3\"}] }"));
        for (var sit in result) {
          print(sit.type + ", " + sit.location);
        }
      } else {
        print('status code: ' + response.statusCode.toString());
      }
    } catch (exception) {
      result = 'Error: ' + exception.toString();
    }

    setState(() {
      //_nerData = result;
      _situations = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
            child: Text('Get NER Data'),
          ),
          Expanded(
            child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _situations.length,
                itemBuilder: (context, index) {
                  return Text(_situations[index].type +
                      ' in ' +
                      _situations[index].location);
                }),
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

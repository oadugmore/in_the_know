import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'situation.dart';

class SituationDetailPage extends StatefulWidget {
  SituationDetailPage({Key key, this.currentSituation}) : super(key: key);

  final Situation currentSituation;

  @override
  SituationDetailPageState createState() => SituationDetailPageState();
}

class SituationDetailPageState extends State<SituationDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.currentSituation.type),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Column(
              children: <Widget>[
                Text(
                  'Mentioned locations',
                  style: Theme.of(context).textTheme.headline5,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Table(
                    defaultColumnWidth: FixedColumnWidth(100),
                    children: <TableRow>[
                      TableRow(
                        children: <Widget>[
                          Text(
                            'Location',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          Text(
                            'Frequency',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                        ],
                      ),
                      for (var location in widget.currentSituation.locations)
                        TableRow(
                          children: <Widget>[
                            Text(
                              '${location.name}',
                            ),
                            Text(
                              '${location.frequency.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            child: Text(
              'Activity',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              itemCount: widget.currentSituation.statuses.length,
              itemBuilder: (context, index) {
                return Card(
                  child: InkWell(
                    child: Row(
                      children: <Widget>[
                        Container(
                          height: 100,
                          margin: EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.alternate_email,
                            size: 60,
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      '@${widget.currentSituation.statuses[index].username}',
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                    ),
                                  ],
                                ),
                                Text(
                                  widget.currentSituation.statuses[index].text,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      var url =
                          'https://twitter.com/u/status/${widget.currentSituation.statuses[index].statusId.toString()}';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

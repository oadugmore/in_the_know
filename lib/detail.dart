import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'situation.dart';

class SituationDetailPage extends StatefulWidget {
  SituationDetailPage({Key key, this.currentSituation}) : super(key: key);

  //final String title;
  final Situation currentSituation;

  @override
  SituationDetailPageState createState() => SituationDetailPageState();
}

class SituationDetailPageState extends State<SituationDetailPage> {
  @override
  Widget build(BuildContext context) {
    String appBarTitle = widget.currentSituation.type;
    if (widget.currentSituation.locations.length > 0) {
      appBarTitle += ' near ${widget.currentSituation.locations[0].name}';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 20, left: 8),
            child: Text(
              'Twitter',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            color: Theme.of(context).backgroundColor,
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              itemCount: widget.currentSituation.statuses.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Theme.of(context).canvasColor,
                  child: InkWell(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 0),
                      width: 200,
                      child: Column(
                        children: [
                          Container(
                            color: Theme.of(context).accentColor,
                            child: Icon(
                              Icons.person,
                              size: 80,
                            ),
                            height: 80,
                            width: 200,
                          ),
                          Container(
                            // color: Theme.of(context).canvasColor,
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    '@${widget.currentSituation.statuses[index].username}',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    widget
                                        .currentSituation.statuses[index].text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

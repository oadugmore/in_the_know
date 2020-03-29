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
  // void testTwitterApi() async {
  //   final key = "API_KEY";
  //   final secret = "API_SECRET";
  //   final accessToken = "TOKEN";
  //   final keyURLEncoded = Uri.encodeComponent(key);
  //   final secretURLEncoded = Uri.encodeComponent(secret);
  //   final keySecret = keyURLEncoded + ":" + secretURLEncoded;
  //   final keySecretBase64Encoded = base64.encode(keySecret.codeUnits);

  //   //function = functions.CloudFunctions.instance;

  //   HttpsCallable twitterFunction = CloudFunctions.instance.getHttpsCallable(functionName: "twitterTest");

  //   final http.Response response = await http.get(
  //     "https://api.twitter.com/1.1/statuses/user_timeline.json?count=100&screen_name=twitterapi",
  //     headers: <String, String>{
  //       'Authorization': 'Basic $accessToken',
  //     },
  //   );

  //   print(jsonDecode(response.body));
  // }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
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
          title: widget.currentSituation.locations.length > 0
              ? Text(
                  '${widget.currentSituation.type} near ${widget.currentSituation.locations[0].name}')
              : Text('${widget.currentSituation.type}')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 20, left: 8),
            child: Text(
              'News',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          // Container(
          //   color: Colors.grey[200],
          //   height: 200,
          //   child: ListView(
          //     scrollDirection: Axis.horizontal,
          //     padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          //     children: <Widget>[
          //       Container(
          //         margin: EdgeInsets.symmetric(horizontal: 4),
          //         width: 200,
          //         child: Material(
          //           color: Colors.white,
          //           child: InkWell(
          //             onTap: () => {/* TODO */},
          //             child: Column(
          //               children: <Widget>[
          //                 Container(
          //                   color: Colors.grey[400],
          //                   child: Icon(
          //                     Icons.image,
          //                     size: 100,
          //                   ),
          //                   height: 100,
          //                   width: 200,
          //                 ),
          //                 Container(
          //                   padding: EdgeInsets.all(8),
          //                   child: Column(
          //                     children: <Widget>[
          //                       Align(
          //                         alignment: Alignment.topLeft,
          //                         child: Text(
          //                           'KTLA',
          //                           style:
          //                               Theme.of(context).textTheme.bodyText1,
          //                         ),
          //                       ),
          //                       Align(
          //                         alignment: Alignment.topLeft,
          //                         child: Text(
          //                           'Chase in LA',
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ),
          //       Container(
          //         margin: EdgeInsets.symmetric(horizontal: 4),
          //         width: 200,
          //         child: Material(
          //           color: Colors.white,
          //           child: InkWell(
          //             onTap: () => {/* TODO */},
          //             child: Column(
          //               children: <Widget>[
          //                 Container(
          //                   color: Colors.grey[400],
          //                   child: Icon(
          //                     Icons.image,
          //                     size: 100,
          //                   ),
          //                   height: 100,
          //                   width: 200,
          //                 ),
          //                 Container(
          //                   padding: EdgeInsets.all(8),
          //                   child: Column(
          //                     children: <Widget>[
          //                       Align(
          //                         alignment: Alignment.topLeft,
          //                         child: Text(
          //                           'ABC7',
          //                           style:
          //                               Theme.of(context).textTheme.bodyText1,
          //                         ),
          //                       ),
          //                       Align(
          //                         alignment: Alignment.topLeft,
          //                         child: Text(
          //                           'Unfolding chaos in the downtown area',
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 20, left: 8),
            child: Text(
              'Twitter',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            color: Colors.grey[200],
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              itemCount: widget.currentSituation.statuses.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 200,
                  child: Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () async {
                        var url = 'https://twitter.com/u/status/${widget.currentSituation.statuses[index].statusId.toString()}';
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Column(
                        children: <Widget>[
                          Container(
                            color: Colors.grey[400],
                            child: Icon(
                              Icons.person,
                              size: 80,
                            ),
                            height: 80,
                            width: 200,
                          ),
                          Container(
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
                                    widget.currentSituation.statuses[index].text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

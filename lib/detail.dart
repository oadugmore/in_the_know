import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_functions/cloud_functions.dart';

class SituationDetail extends StatefulWidget {
  SituationDetail({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  SituationDetailState createState() => SituationDetailState();
}

class SituationDetailState extends State<SituationDetail> {
  int _counter = 0;

  void testTwitterApi() async {
    final key = "API_KEY";
    final secret = "API_SECRET";
    final accessToken = "TOKEN";
    final keyURLEncoded = Uri.encodeComponent(key);
    final secretURLEncoded = Uri.encodeComponent(secret);
    final keySecret = keyURLEncoded + ":" + secretURLEncoded;
    final keySecretBase64Encoded = base64.encode(keySecret.codeUnits);

    //function = functions.CloudFunctions.instance;

    HttpsCallable twitterFunction = CloudFunctions.instance.getHttpsCallable(functionName: "twitterTest");

    final http.Response response = await http.get(
      "https://api.twitter.com/1.1/statuses/user_timeline.json?count=100&screen_name=twitterapi",
      headers: <String, String>{
        'Authorization': 'Basic $accessToken',
      },
    );

    print(jsonDecode(response.body));
  }

  void testNewsApi() async {
    final response = await http.get(
        'http://newsapi.org/v2/sources?language=en&country=us&apiKey=API_KEY');
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      var jsonObject = json.decode(response.body);
      print(jsonObject['sources']);
    } else {
      // If the server did not return a 200 OK response, then throw an exception.
      throw Exception('Failed to load data');
    }
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
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
          Container(
            color: Colors.grey[200],
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 200,
                  child: Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () => {/* TODO */},
                      child: Column(
                        children: <Widget>[
                          Container(
                            color: Colors.grey[400],
                            child: Icon(
                              Icons.image,
                              size: 100,
                            ),
                            height: 100,
                            width: 200,
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'KTLA',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Chase in LA',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 200,
                  child: Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () => {/* TODO */},
                      child: Column(
                        children: <Widget>[
                          Container(
                            color: Colors.grey[400],
                            child: Icon(
                              Icons.image,
                              size: 100,
                            ),
                            height: 100,
                            width: 200,
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'ABC7',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Unfolding chaos in the downtown area',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20, bottom: 20, left: 8),
            child: Text(
              'Twitter',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            color: Colors.grey[200],
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 200,
                  child: Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () => {/* TODO */},
                      child: Column(
                        children: <Widget>[
                          Container(
                            color: Colors.grey[400],
                            child: Icon(
                              Icons.person,
                              size: 100,
                            ),
                            height: 100,
                            width: 200,
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    '@LAPD',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    '"Avoid this intersection for now."',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 200,
                  child: Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () => {/* TODO */},
                      child: Column(
                        children: <Widget>[
                          Container(
                            color: Colors.grey[400],
                            child: Icon(
                              Icons.person,
                              size: 100,
                            ),
                            height: 100,
                            width: 200,
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    '@twitteruser335',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    '"I saw it! They\'re headed towards Main Street!"',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: 200,
                  child: Material(
                    color: Colors.white,
                    child: InkWell(
                      onTap: () => {/* TODO */},
                      child: Column(
                        children: <Widget>[
                          Container(
                            color: Colors.grey[400],
                            child: Icon(
                              Icons.person,
                              size: 100,
                            ),
                            height: 100,
                            width: 200,
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    '@unituint',
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    '"What\'s all that noise?"',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: testTwitterApi,
        child: Icon(Icons.new_releases),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

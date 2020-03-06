import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Police Chase in Downtown LA'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void testTwitterApi() async {
    final key = "API_KEY";
    final secret = "API_SECRET";
    final keyURLEncoded = Uri.encodeComponent(key);
    final secretURLEncoded = Uri.encodeComponent(secret);
    final keySecret = keyURLEncoded + ":" + secretURLEncoded;
    final keySecretBase64Encoded = base64.encode(keySecret.codeUnits);

    final http.Response response = await http.post(
      "https://api.twitter.com/oauth2/token",
      headers: <String, String>{
        'Authorization': 'Basic $keySecretBase64Encoded',
        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
      },
      body: 'grant_type=client_credentials',
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

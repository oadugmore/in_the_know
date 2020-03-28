import 'dart:convert';

class Situation {
  final String type;
  final String location;

  Situation({this.type, this.location});

  factory Situation.fromJson(Map<String, dynamic> json) {
    return Situation(
      type: json['type'],
      location: json['location'],
    );
  }

  static List<Situation> allFromJson(Map<String, dynamic> jsonBody) {
    var situations = new List<Situation>();
    for (var situation in jsonBody['situations']) {
      situations.add(Situation.fromJson(situation));
    }
    //final parsed = json.decode(jsonBody).cast<Map<String, dynamic>>();
    //return parsed.map<Situation>((json) => Situation.fromJson(json)).toList();
    return situations;
  }

}
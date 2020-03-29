import 'dart:convert';

class Situation {
  final String type;
  final List<LocationEntry> locations;

  Situation({this.type, this.locations});

  factory Situation.fromJson(Map<String, dynamic> json) {
    var locs = List<LocationEntry>();
    for (var loc in json['locations']) {
      locs.add(LocationEntry(name: loc['name'], frequency: double.parse(loc['frequency'])));
    }
    for (var entry in locs) {
      print(entry.name + entry.frequency.toString());
    }
    return Situation(
      type: json['type'],
      locations: locs,
    );
  }

  static List<Situation> allFromJson(Map<String, dynamic> jsonBody) {
    var situations = List<Situation>();
    for (var situation in jsonBody['situations']) {
      situations.add(Situation.fromJson(situation));
    }
    return situations;
  }

}

class LocationEntry {
  final String name;
  final double frequency;

  LocationEntry({this.name, this.frequency});
}
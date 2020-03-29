import 'dart:convert';

class Situation {
  final String type;
  final List<LocationEntry> locations;

  Situation({this.type, this.locations});

  factory Situation.fromJson(Map<String, dynamic> json) {
    var locs = List<LocationEntry>();
    for (var loc in json['locations']) {
      locs.add(LocationEntry(
          name: loc['name'], frequency: loc['frequency']));
    }
    for (var entry in locs) {
      print(entry.name + entry.frequency.toString());
    }
    return Situation(
      type: json['type'],
      locations: locs,
    );
  }

  static List<Situation> allFromJson(String json) {
    var situations = List<Situation>();
    var parsedJson;
    try {
      parsedJson = jsonDecode(json);
    if (parsedJson.containsKey('situations')) {
      for (var situation in parsedJson['situations']) {
        situations.add(Situation.fromJson(situation));
      }
    }
    } catch (e) {
      print('Result did not have correctly formatted JSON. Exception: $e');
    }
    return situations;
  }
}

class LocationEntry {
  final String name;
  final double frequency;

  LocationEntry({this.name, this.frequency});
}

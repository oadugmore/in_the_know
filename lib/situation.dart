import 'dart:convert';

class Situation {
  final String type;
  final List<LocationEntry> locations;
  final List<TwitterStatus> statuses;

  Situation({this.type, this.locations, this.statuses});

  factory Situation.fromJson(Map<String, dynamic> json) {
    var locs = List<LocationEntry>();
    var stats = List<TwitterStatus>();

    for (var loc in json['locations']) {
      locs.add(LocationEntry.fromJson(loc));
    }
    for (var status in json['statuses']) {
      stats.add(TwitterStatus.fromJson(status));
    }
    return Situation(
      type: json['type'],
      locations: locs,
      statuses: stats,
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

  factory LocationEntry.fromJson(Map<String, dynamic> json) {
    return LocationEntry(
      name: json['name'],
      frequency: json['frequency'],
    );
  }
}

class TwitterStatus {
  final String text;
  final int statusId; // 'int' in Dart is 64-bit
  final String createdAt;
  final String username; // called 'screen_name' in the Twitter API
  final bool verified;

  TwitterStatus(
      {this.text, this.statusId, this.createdAt, this.username, this.verified});

  factory TwitterStatus.fromJson(Map<String, dynamic> json) {
    //var createdAt = DateTime.parse(json['created_at']);
    return TwitterStatus(
      text: json['text'],
      statusId: json['id'],
      createdAt: json['created_at'],
      username: json['user']['screen_name'],
      verified: json['user']['verified'],
    );
  }
}

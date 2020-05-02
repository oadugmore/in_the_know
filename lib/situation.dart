import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

part 'situation.g.dart';

@JsonSerializable()
class Situation {
  final String type;
  final List<LocationEntry> locations;
  final List<TwitterStatus> statuses;

  Situation({this.type, this.locations, this.statuses});
  factory Situation.fromJson(Map<String, dynamic> json) => _$SituationFromJson(json);
  Map<String, dynamic> toJson() => _$SituationToJson(this);

  // factory Situation.fromJson(Map<String, dynamic> json) {
  //   var locs = List<LocationEntry>();
  //   var stats = List<TwitterStatus>();
  //   print('Situation.fromJson');
  //   try {
  //   for (var loc in json['locations']) {
  //     print('Deserializing loc $loc');
  //     locs.add(LocationEntry.fromJson(loc));
  //   }
  //   for (var status in json['statuses']) {
  //     print('Deserializing status $status');
  //     stats.add(TwitterStatus.fromJson(status));
  //   }
  //   } catch (exception) {
  //     print(exception);
  //   }
  //   print('Returning created situation');
  //   return Situation(
  //     type: json['type'],
  //     locations: locs,
  //     statuses: stats,
  //   );
  // }

  // Map<String, dynamic> toJson() => {
  //       'type': type,
  //       'locations': jsonEncode(locations),
  //       'statuses': jsonEncode(statuses)
  //     };

  static List<Situation> allFromJson(String json) {
    var situations = List<Situation>();
    var parsedJson;
    try {
      parsedJson = jsonDecode(json);
      if (parsedJson.containsKey('situations')) {
        for (var situation in parsedJson['situations']) {
          print('adding situation $situation');
          situations.add(Situation.fromJson(situation));
        }
      }
    } catch (e) {
      print('Result did not have correctly formatted JSON. Exception: $e');
    }
    return situations;
  }
}

@JsonSerializable()
class LocationEntry {
  final String name;
  final double frequency;

  LocationEntry({this.name, this.frequency});
  factory LocationEntry.fromJson(Map<String, dynamic> json) => _$LocationEntryFromJson(json);
  Map<String, dynamic> toJson() => _$LocationEntryToJson(this);

  // factory LocationEntry.fromJson(Map<String, dynamic> json) {
  //   print('LocationEntry.fromJson');
  //   return LocationEntry(
  //     name: json['name'],
  //     frequency: json['frequency'],
  //   );
  // }

  // Map<String, dynamic> toJson() => {'name': name, 'frequency': frequency};
}

@JsonSerializable(fieldRename: FieldRename.snake)
class TwitterStatus {
  final String text;
  final int statusId; // 'int' in Dart is 64-bit
  final String createdAt;
  final String username; // called 'screen_name' in the Twitter API
  final bool verified;

  TwitterStatus(
      {this.text, this.statusId, this.createdAt, this.username, this.verified});
  factory TwitterStatus.fromJson(Map<String, dynamic> json) => _$TwitterStatusFromJson(json);
  Map<String, dynamic> toJson() => _$TwitterStatusToJson(this);

  // factory TwitterStatus.fromJson(Map<String, dynamic> json) {
  //   //var createdAt = DateTime.parse(json['created_at']);
  //   print('TwitterStatus.fromJson');
  //   return TwitterStatus(
  //     text: json['text'],
  //     statusId: json['id'],
  //     createdAt: json['created_at'],
  //     username: json['user']['screen_name'],
  //     verified: json['user']['verified'],
  //   );
  // }

  // Map<String, dynamic> toJson() => {
  //       'text': text,
  //       'id': statusId,
  //       'created_at': createdAt,
  //       'user': {'screen_name': username, 'verified': verified},
  //     };
}

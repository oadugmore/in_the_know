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

@JsonSerializable()
class LocationEntry {
  final String name;
  final double frequency;

  LocationEntry({this.name, this.frequency});
  factory LocationEntry.fromJson(Map<String, dynamic> json) => _$LocationEntryFromJson(json);
  Map<String, dynamic> toJson() => _$LocationEntryToJson(this);
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
}

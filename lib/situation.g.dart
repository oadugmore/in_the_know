// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'situation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Situation _$SituationFromJson(Map<String, dynamic> json) {
  return Situation(
    type: json['type'] as String,
    locations: (json['locations'] as List)
        ?.map((e) => e == null
            ? null
            : LocationEntry.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    statuses: (json['statuses'] as List)
        ?.map((e) => e == null
            ? null
            : TwitterStatus.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$SituationToJson(Situation instance) => <String, dynamic>{
      'type': instance.type,
      'locations': instance.locations,
      'statuses': instance.statuses,
    };

LocationEntry _$LocationEntryFromJson(Map<String, dynamic> json) {
  return LocationEntry(
    name: json['name'] as String,
    frequency: (json['frequency'] as num)?.toDouble(),
  );
}

Map<String, dynamic> _$LocationEntryToJson(LocationEntry instance) =>
    <String, dynamic>{
      'name': instance.name,
      'frequency': instance.frequency,
    };

TwitterStatus _$TwitterStatusFromJson(Map<String, dynamic> json) {
  return TwitterStatus(
    text: json['text'] as String,
    statusId: json['status_id'] as int,
    createdAt: json['created_at'] as String,
    username: json['username'] as String,
    verified: json['verified'] as bool,
  );
}

Map<String, dynamic> _$TwitterStatusToJson(TwitterStatus instance) =>
    <String, dynamic>{
      'text': instance.text,
      'status_id': instance.statusId,
      'created_at': instance.createdAt,
      'username': instance.username,
      'verified': instance.verified,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'individual_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Individual _$IndividualFromJson(Map<String, dynamic> json) {
  return Individual(
    json['sId'] as String,
    (json['sCollectionList'] as List)
        ?.map((e) =>
            e == null ? null : Collection.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['sdataOK'] as bool,
    json['sAcc'] as int,
    json['sAlt'] as int,
    (json['sLat'] as num)?.toDouble(),
    (json['sLon'] as num)?.toDouble(),
    json['sTimeStamp'] == null
        ? null
        : DateTime.parse(json['sTimeStamp'] as String),
    json['sUiTime'] as String,
    json['sGpsType'] as String,
  );
}

Map<String, dynamic> _$IndividualToJson(Individual instance) =>
    <String, dynamic>{
      'sId': instance.sId,
      'sCollectionList': instance.sCollectionList,
      'sdataOK': instance.sdataOK,
      'sAcc': instance.sAcc,
      'sAlt': instance.sAlt,
      'sLat': instance.sLat,
      'sLon': instance.sLon,
      'sTimeStamp': instance.sTimeStamp?.toIso8601String(),
      'sUiTime': instance.sUiTime,
      'sGpsType': instance.sGpsType,
    };

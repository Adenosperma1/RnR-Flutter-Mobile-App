// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Collection _$CollectionFromJson(Map<String, dynamic> json) {
  return Collection(
    json['sId'] as String,
    json['sBarcode'] as String,
    json['sCollectorsID'] as String,
    json['sUiTime'] as String,
    json['sType'] as String,
    json['sStatus'] as int,
    json['sNote'] as String,
  )..sTimeStamp = json['sTimeStamp'] == null
      ? null
      : DateTime.parse(json['sTimeStamp'] as String);
}

Map<String, dynamic> _$CollectionToJson(Collection instance) =>
    <String, dynamic>{
      'sId': instance.sId,
      'sBarcode': instance.sBarcode,
      'sCollectorsID': instance.sCollectorsID,
      'sUiTime': instance.sUiTime,
      'sType': instance.sType,
      'sStatus': instance.sStatus,
      'sTimeStamp': instance.sTimeStamp?.toIso8601String(),
      'sNote': instance.sNote,
    };

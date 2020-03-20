// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Site _$SiteFromJson(Map<String, dynamic> json) {
  return Site(
    json['sname'] as String,
    json['sdescription'] as String,
    json['ssoilColour'] as String,
    json['ssoilTexture'] as String,
    json['sdisturbanceOther'] as String,
    json['slandFormOther'] as String,
    json['shabitatOther'] as String,
    json['sid'] as String,
    json['sAssociated'] as String,
    json['sTenure'] as String,
    json['sDate'] as String,
    (json['shabitatMapDB'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as bool),
    ),
    (json['slandFormMapDB'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as bool),
    ),
    (json['sdisturbanceMapDB'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as bool),
    ),
    (json['sCollectors'] as List)
        ?.map(
            (e) => e == null ? null : User.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['sAcc'] as int,
    json['sAlt'] as int,
    (json['sLat'] as num)?.toDouble(),
    (json['sLon'] as num)?.toDouble(),
    json['sTimeStamp'] == null
        ? null
        : DateTime.parse(json['sTimeStamp'] as String),
    json['sUiTime'] as String,
    json['sFlagType'] as String,
    json['sSpeciesCount'] as int,
    json['sCollectionCount'] as int,
    json['sDataOK'] as bool,
    json['sDataUploaded'] as bool,
  );
}

Map<String, dynamic> _$SiteToJson(Site instance) => <String, dynamic>{
      'sid': instance.sid,
      'sname': instance.sname,
      'sdescription': instance.sdescription,
      'ssoilColour': instance.ssoilColour,
      'ssoilTexture': instance.ssoilTexture,
      'sdisturbanceOther': instance.sdisturbanceOther,
      'slandFormOther': instance.slandFormOther,
      'shabitatOther': instance.shabitatOther,
      'sAssociated': instance.sAssociated,
      'sTenure': instance.sTenure,
      'sDate': instance.sDate,
      'shabitatMapDB': instance.shabitatMapDB,
      'sdisturbanceMapDB': instance.sdisturbanceMapDB,
      'slandFormMapDB': instance.slandFormMapDB,
      'sCollectors': instance.sCollectors,
      'sAcc': instance.sAcc,
      'sAlt': instance.sAlt,
      'sLat': instance.sLat,
      'sLon': instance.sLon,
      'sTimeStamp': instance.sTimeStamp?.toIso8601String(),
      'sUiTime': instance.sUiTime,
      'sFlagType': instance.sFlagType,
      'sSpeciesCount': instance.sSpeciesCount,
      'sCollectionCount': instance.sCollectionCount,
      'sDataOK': instance.sDataOK,
      'sDataUploaded': instance.sDataUploaded,
    };

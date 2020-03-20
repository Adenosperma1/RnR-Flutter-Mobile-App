// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'population_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Population _$PopulationFromJson(Map<String, dynamic> json) {
  return Population(
    json['sid'] as String,
    json['sfkSite'] as String,
    json['sname'] as String,
    json['sNameGenus'] as String,
    json['sNameSpecies'] as String,
    json['sNameRank'] as String,
    json['sNameRankName'] as String,
    json['ssighted'] as String,
    json['sreproductiveState'] as String,
    json['sflowers'] as String,
    json['sfruit'] as String,
    (json['sfruitMapDB'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as bool),
    ),
    json['splantsPresent'] as String,
    json['sadultsPresent'] as String,
    json['sjuvenilesPresent'] as String,
    json['snotes'] as String,
    (json['sflowersMapDB'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as bool),
    ),
    (json['sIndividualsList'] as List)
        ?.map((e) =>
            e == null ? null : Individual.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    json['sNotOnList'] as bool,
    json['sdataOK'] as bool,
  );
}

Map<String, dynamic> _$PopulationToJson(Population instance) =>
    <String, dynamic>{
      'sid': instance.sid,
      'sfkSite': instance.sfkSite,
      'sname': instance.sname,
      'sNameGenus': instance.sNameGenus,
      'sNameSpecies': instance.sNameSpecies,
      'sNameRank': instance.sNameRank,
      'sNameRankName': instance.sNameRankName,
      'ssighted': instance.ssighted,
      'sreproductiveState': instance.sreproductiveState,
      'sflowers': instance.sflowers,
      'sfruit': instance.sfruit,
      'splantsPresent': instance.splantsPresent,
      'sadultsPresent': instance.sadultsPresent,
      'sjuvenilesPresent': instance.sjuvenilesPresent,
      'snotes': instance.snotes,
      'sflowersMapDB': instance.sflowersMapDB,
      'sfruitMapDB': instance.sfruitMapDB,
      'sIndividualsList': instance.sIndividualsList,
      'sNotOnList': instance.sNotOnList,
      'sdataOK': instance.sdataOK,
    };

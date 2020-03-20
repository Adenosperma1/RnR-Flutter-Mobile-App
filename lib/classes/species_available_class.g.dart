// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'species_available_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailableSpecies _$AvailableSpeciesFromJson(Map<String, dynamic> json) {
  return AvailableSpecies(
    json['sId'] as String,
    json['sName'] as String,
  )
    ..sIdFM = json['sIdFM'] as String
    ..sNameGenus = json['sNameGenus'] as String
    ..sNameSpecies = json['sNameSpecies'] as String
    ..sNameRank = json['sNameRank'] as String
    ..sNameRankName = json['sNameRankName'] as String;
}

Map<String, dynamic> _$AvailableSpeciesToJson(AvailableSpecies instance) =>
    <String, dynamic>{
      'sId': instance.sId,
      'sIdFM': instance.sIdFM,
      'sName': instance.sName,
      'sNameGenus': instance.sNameGenus,
      'sNameSpecies': instance.sNameSpecies,
      'sNameRank': instance.sNameRank,
      'sNameRankName': instance.sNameRankName,
    };

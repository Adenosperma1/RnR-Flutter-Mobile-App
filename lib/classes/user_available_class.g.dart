// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_available_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvailableUser _$AvailableUserFromJson(Map<String, dynamic> json) {
  return AvailableUser(
    json['sId'] as String,
    json['sName'] as String,
    json['sEmail'] as String,
    json['sPassword'] as String,
    json['sInitials'] as String,
    json['sAdmin'] as bool,
  );
}

Map<String, dynamic> _$AvailableUserToJson(AvailableUser instance) =>
    <String, dynamic>{
      'sId': instance.sId,
      'sName': instance.sName,
      'sEmail': instance.sEmail,
      'sPassword': instance.sPassword,
      'sInitials': instance.sInitials,
      'sAdmin': instance.sAdmin,
    };

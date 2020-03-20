// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_class.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    json['sId'] as String,
    json['sName'] as String,
    json['sEmail'] as String,
    json['sPassword'] as String,
    json['sInitials'] as String,
    json['sAdmin'] as bool,
    json['sHideCollectorID'] as bool,
    json['sHideSiteGPS'] as bool,
    json['sRemoveAfterUpload'] as bool,
  )..sRnrUser = json['sRnrUser'] as bool;
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'sId': instance.sId,
      'sName': instance.sName,
      'sEmail': instance.sEmail,
      'sPassword': instance.sPassword,
      'sInitials': instance.sInitials,
      'sRnrUser': instance.sRnrUser,
      'sAdmin': instance.sAdmin,
      'sHideCollectorID': instance.sHideCollectorID,
      'sHideSiteGPS': instance.sHideSiteGPS,
      'sRemoveAfterUpload': instance.sRemoveAfterUpload,
    };

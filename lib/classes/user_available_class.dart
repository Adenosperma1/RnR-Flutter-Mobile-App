import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';


//https://flutter.io/docs/development/data-and-backend/json
//to update json
//cd to app folder
//$ export PATH=~/flutter/bin:$PATH;
//$ flutter packages pub run build_runner build
part 'user_available_class.g.dart';

//need this variable for json_annotation
@JsonSerializable()

//object of a site created by the user
//-------------------------------------------------------------------//
class AvailableUser {
  //vars can't have private variables with json_anotation so prefixed with s
  String sId;
  String sName;
  String sEmail;
  String sPassword;
  String sInitials;
  bool   sAdmin;

//-------------------------------------------------------------------//
//Constructor need this for json_annotation
  AvailableUser(
  this.sId,
  this.sName,
  this.sEmail,
  this.sPassword,
  this.sInitials,
  this.sAdmin
  );

//-------------------------------------------------------------------//
//Constructor from a site name
  AvailableUser.fromName(var name, String aUuid) {
    sId = aUuid;
    sName = name;  
    sInitials = _makeInitials(name);
    sAdmin = false;
  }

//-------------------------------------------------------------------//
_makeInitials(String fullName){
List words = fullName.split(' ');
int wordCount = words.length;
print('words: ' + wordCount.toString());
String initials;

if(wordCount >= 1){
initials = words[0].substring(0, 1);
}
if(wordCount >= 2){
initials = initials + words[1].substring(0, 1);
}

return initials;
}//end _makeInitials
  

//need this for json_annotation
  factory AvailableUser.fromJson(Map<String, dynamic> json) => _$AvailableUserFromJson(json);

//need this for json_annotation
  Map<String, dynamic> toJson() => _$AvailableUserToJson(this);

  //-------------------------------------------------------------------//
  //Getters
  String get id => sId;
  String get name => sName;
  String get email => sEmail;
  String get password =>sPassword;
  String get initials =>sInitials;
  bool get admin => sAdmin;

//-------------------------------------------------------------------//
//Setter, field by name and variable
  set(String varName, var varValue) {
    if (varName == 'id') {
      this.sId = varValue;
    } else if (varName == 'name') {
      this.sName = varValue;
    } else if (varName == 'email') {
      this.sEmail = varValue;
    } else if (varName == 'password') {
      this.sPassword = varValue;
    } else if (varName == 'initials') {
      this.sInitials = varValue;
    } else if (varName == 'admin') {
      this.sAdmin = varValue;
    }
  }

//-------------------------------------------------------------------//
    AvailableUser.fromSnapshot(DocumentSnapshot snapshot) {
      sId = snapshot.documentID;
      sName = snapshot.data['name'];
      sEmail = snapshot.data['email'];
      sPassword = snapshot.data['password'];
      sInitials = snapshot.data['initials'];
      sAdmin = snapshot.data['admin'];
    }

//-------------------------------------------------------------------//
//used to prepare for Firestore
Map<String, dynamic> toMap() {
var map = new Map<String, dynamic>();
//if (sId != null) {map['id'] = sId;}
map['name'] = sName;
map['email'] = sEmail;
map['password'] = sPassword;
map['initials'] = sInitials;
map['admin'] = sAdmin;

return map;
}//end toMap
  
}//Class

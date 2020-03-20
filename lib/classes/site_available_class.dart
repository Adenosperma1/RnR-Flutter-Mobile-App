import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';


//https://flutter.io/docs/development/data-and-backend/json
//to update json
//cd to app folder
//$ export PATH=~/flutter/bin:$PATH;
//$ flutter packages pub run build_runner build
part 'site_available_class.g.dart';

//need this variable for json_annotation
@JsonSerializable()


//sites that a user can select from


class AvailableSite {
  String sId;
  String sName;
  //gps to help find those that are near by?


 //need this for json_annotation
  factory AvailableSite.fromJson(Map<String, dynamic> json) => _$AvailableSiteFromJson(json);

  //need this for json_annotation
  Map<String, dynamic> toJson() => _$AvailableSiteToJson(this);


  //-------------------------------------------------------------------//
  //Constructor
  AvailableSite(
    this.sId, 
    this.sName); 

  //Constructor from a name
  AvailableSite.fromName(var name, String aUuid,) {
    sName = name;
    sId = aUuid;
  } 

  //-------------------------------------------------------------------//
  //Getters
  String get id => sId;
  String get name => sName;


  //-------------------------------------------------------------------//
  //Setter, field by name and variable
  set(String varName, var varValue) {
    if (varName == 'id') {
      this.sId = varValue;
    } else if (varName == 'name') {
      this.sName = varValue;  
    }
  }


//-------------------------------------------------------------------//
//used to prepare for Firestore
Map<String, dynamic> toMap() {
var map = new Map<String, dynamic>();
//if (sId != null) {map['id'] = sId;}
map['name'] = sName;
return map;
}//end toMap

//-------------------------------------------------------------------//
 AvailableSite.fromSnapshot(DocumentSnapshot snapshot) {
    sId = snapshot.documentID;
    sName = snapshot.data['name'];
}



}//end class

/*
//-------------------------------------------------------------------//
//not used but might be needed?
AvailableSite.fromMap(Map<String, dynamic> map) {
    this.sId = map['id'];
    this.sName = map['name'];
}
*/
//TODO_ can all variables loose the s prefix and then loose the .set function???

//BUG 1 -  switch doesn't move on tap
//BUG 2 -  gps updates to worse ?
//BUG 3 - gps time comparision issue, can't see current time to see how long ago the reading was made
//BUG 4 - export voucher id flows through to everything after it
//BUG 5 - change the heading title for Peter, "Incidental observation" field to "Record type"

import 'package:json_annotation/json_annotation.dart';


//https://flutter.io/docs/development/data-and-backend/json
//to update json
//cd to app folder
//$ export PATH=~/flutter/bin:$PATH;
//$ flutter packages pub run build_runner build
part 'collection_class.g.dart';

//need this variable for json_annotation
@JsonSerializable()
  
//an object of a collection for a species

  //-------------------------------------------------------------------//
  class Collection{
  //can't have private variables with json_anotation so prefixed with s
  String sId;
  String sBarcode;
  String sCollectorsID;
  String sUiTime;
  String sType; //sample, voucher, sighted, notSighted, seed, propagation etc.
  int    sStatus;
  DateTime sTimeStamp;
  String sNote; //sighted, not sighted etc


 
  //-------------------------------------------------------------------//
  //Constructor need this for json_annotation
  Collection(
  this.sId,
  this.sBarcode,
  this.sCollectorsID,
  this.sUiTime,
  this.sType,
  this.sStatus,
  this.sNote
  );

  //-------------------------------------------------------------------//
  //constructor for an empty collection object
  Collection.fromID(String id, String type) {
  sId = id;
  sBarcode = '';
  sCollectorsID = '';
  sUiTime = '';
  sStatus = 0;
  sTimeStamp = null;
  sType = type;
  sNote = '';
}

//need this for json_annotation
  factory Collection.fromJson(Map<String, dynamic> json) => _$CollectionFromJson(json);

//need this for json_annotation
  Map<String, dynamic> toJson() => _$CollectionToJson(this);

  //-------------------------------------------------------------------//
  //Getters
  String get id => sId;
  int    get status => sStatus;
  String get barcode => sBarcode;
  String get collectorsID => sCollectorsID;
  String get uiTime => sUiTime;
  String get type => sType;
  DateTime get timestamp => sTimeStamp;
  String get note => sNote;


  //-------------------------------------------------------------------//
  //dodgy! not sure why i did this way?
  //Setter, field by name and variable
  set(String varName, var varValue) {
    if (varName == 'id') {
      this.sId = varValue;
    } else if (varName == 'status') {
      this.sStatus = varValue;
    } else if (varName == 'barcode') {
      this.sBarcode = varValue;
    } else if (varName == 'collectorsID') {
      this.sCollectorsID = varValue;
    }else if (varName == 'type') {
      this.sType = varValue;
    } else if (varName == 'uiTime') {
      this.sUiTime = varValue;
    } else if (varName == 'note') {
      this.sNote = varValue;
    } 
  }//end get


//used to prepare for Firestore
Map<String, dynamic> toMap() {
var map = new Map<String, dynamic>();
map['type'] = sType;
return map;
}//end toMap



}// end class
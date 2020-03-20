import 'package:json_annotation/json_annotation.dart';
import 'package:restoreandrenew/classes/collection_class.dart';

//https://flutter.io/docs/development/data-and-backend/json
//to update json
//cd to app folder
//$ export PATH=~/flutter/bin:$PATH;
//$ flutter packages pub run build_runner build
part 'individual_class.g.dart';

//need this variable for json_annotation
@JsonSerializable()
  
//an object of an Individual of a population

  //-------------------------------------------------------------------//
  class Individual{
  //can't have private variables with json_anotation so prefixed with s
  String sId;
  //there's a list of individuals in the population object
  List<Collection> sCollectionList;
  bool sdataOK;
  int    sAcc;
  int    sAlt;
  double sLat;
  double sLon;
  DateTime sTimeStamp;
  String sUiTime;
  String sGpsType; //new, site, none,


 
  //-------------------------------------------------------------------//
  //Constructor need this for json_annotation
  Individual(
  this.sId,
  this.sCollectionList,
  this.sdataOK,
  this.sAcc,
  this.sAlt,
  this.sLat,
  this.sLon,
  this.sTimeStamp,
  this.sUiTime,
  this.sGpsType,
  );

  //-------------------------------------------------------------------//
  //constructor for an empty collection object
  Individual.fromID(String id, Collection collection) {
  sId = id;
  sdataOK = true;
  sCollectionList = [];
  sCollectionList.add(collection);
  sAcc = 0;
  sAlt = 0;
  sLat = 0.0;
  sLon = 0.0;
  sTimeStamp = null;
  sUiTime = '';
  sGpsType = '';
}

//need this for json_annotation
  factory Individual.fromJson(Map<String, dynamic> json) => _$IndividualFromJson(json);

//need this for json_annotation
  Map<String, dynamic> toJson() => _$IndividualToJson(this);

  //-------------------------------------------------------------------//
  //Getters
  String get id => sId;
  List<Collection> get collectionList => sCollectionList;
  double get lat => sLat;
  double get lon => sLon;
  int    get acc => sAcc;
  int    get alt => sAlt;
  DateTime get timestamp => sTimeStamp;
  String get uiTime => sUiTime;
  String get gpsType => sGpsType;

  //-------------------------------------------------------------------//
  
  //Setter, field by name and variable
  set(String varName, var varValue) {
    if (varName == 'id') {
      this.sId = varValue;
    } else if (varName == 'collectionList') {
      this.sCollectionList = varValue;
    } else if (varName == 'timestamp') {
      this.sTimeStamp = varValue;
    } else if (varName == 'lat') {
      this.sLat = varValue;
    } else if (varName == 'lon') {
      this.sLon = varValue;
    } else if (varName == 'acc') {
    this.sAcc = varValue;
    }else if (varName == 'uiTime') {
      this.sUiTime = varValue;
    }  else if (varName == 'gpsType') {
      this.sGpsType = varValue;
    } else if (varName == 'alt') {
    this.sAlt = varValue;  }



  }//end get





}// end class
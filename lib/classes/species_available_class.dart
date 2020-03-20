

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

//https://flutter.io/docs/development/data-and-backend/json
//to update json
//cd to app folder
//$ export PATH=~/flutter/bin:$PATH;
//$ flutter packages pub run build_runner build
part 'species_available_class.g.dart';

//need this variable for json_annotation
@JsonSerializable()

//an object of a species selected by the user

class AvailableSpecies {
  String sId;
  String sIdFM;
  String sName;

  String sNameGenus;
  String sNameSpecies;
  String sNameRank;
  String sNameRankName;

  //need this for json_annotation
  factory AvailableSpecies.fromJson(Map<String, dynamic> json) =>
      _$AvailableSpeciesFromJson(json);

  //need this for json_annotation
  Map<String, dynamic> toJson() => _$AvailableSpeciesToJson(this);

  //-------------------------------------------------------------------//
  //Constructor
  AvailableSpecies(this.sId, this.sName);

  //-------------------------------------------------------------------//
//Constructor from a name
  AvailableSpecies.fromName(var name, String aUuid) {
    sId = aUuid;
    sIdFM = '';
    sName = name;
    sNameGenus = name;
    sNameSpecies = '';
    sNameRank = '';
    sNameRankName = '';
  } //end fromName


  //Constructor from a name
  AvailableSpecies.fromNameFull(
  String aUuid, 
  var idFilemaker, 
  String nameFull, 
  String nameGenus,
  String nameSpecies,
  String nameRank,
  String nameRankName,

  ) {
    sId = aUuid;
    sIdFM = idFilemaker.toString();
    sName = nameFull;
    sNameGenus = nameGenus;
    sNameSpecies = nameSpecies;
    sNameRank = nameRank;
    sNameRankName = nameRankName;
  } //end fromName

  //-------------------------------------------------------------------//
  //Getters
  String get id => sId;
  String get idFM => sIdFM;
  String get name => sName;
  String get nameGenus => sNameGenus;
  String get nameSpecies => sNameSpecies;
  String get nameRank => sNameRank;
  String get nameRankName => sNameRankName;

  //-------------------------------------------------------------------//
  //Setter, field by name and variable
  set(String varName, var varValue) {
      if (varName == 'id') {
      this.sId = varValue;
      } else if (varName == 'idFM') {
      this.sIdFM = varValue;
      } else if (varName == 'name') {
      this.sName = varValue;
      } else if (varName == 'nameGenus') {
      this.sNameGenus = varValue;
      } else if (varName == 'nameSpecies') {
      this.sNameSpecies = varValue;
      } else if (varName == 'nameRank') {
      this.sNameRank = varValue;
      } else if (varName == 'nameRankName') {
      this.sNameRankName = varValue;
    }
  } //end setter



    
  

  //-------------------------------------------------------------------//
  //used to prepare for Firestore
  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
  //if (sId != null) {map['id'] = sId;}
    map['idFM'] = sIdFM;
    map['name'] = sName;
    map['nameGenus'] = sNameGenus;
    map['nameSpecies'] = sNameSpecies;
    map['nameRank'] = sNameRank;
    map['nameRankName'] = sNameRankName;

    return map;
  } //end toMap


  //-------------------------------------------------------------------//
  //Used to convert from firestore
  AvailableSpecies.fromSnapshot(DocumentSnapshot snapshot) {
    sId = snapshot.documentID;
    sIdFM = snapshot.data['idFM'];
    sName = snapshot.data['name'];
    sNameGenus = snapshot.data['nameGenus'];
    sNameSpecies = snapshot.data['nameSpecies'];
    sNameRank = snapshot.data['nameRank'];
    sNameRankName = snapshot.data['nameRankName'];
  } //end fromSnapshot

} //end class


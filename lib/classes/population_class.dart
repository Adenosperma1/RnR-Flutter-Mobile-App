import 'package:json_annotation/json_annotation.dart';

//Classes
import 'package:restoreandrenew/classes/individual_class.dart';
//import 'package:restoreandrenew/classes/collection_class.dart';
  

//https://flutter.io/docs/development/data-and-backend/json
//to update json
//cd to app folder
//$ export PATH=~/flutter/bin:$PATH;
//$ flutter packages pub run build_runner build
part 'population_class.g.dart';

//need this variable for json_annotation
@JsonSerializable()
  
//an object of a species selected by the user
  class Population{
    String sid; 
    String sfkSite;
    String sname; //calc from the others
    String sNameGenus;
    String sNameSpecies;
    String sNameRank;
    String sNameRankName;
    String ssighted;
    String sreproductiveState;
    String sflowers; //user friendly
    String sfruit;
    String splantsPresent;
    String sadultsPresent;
    String sjuvenilesPresent;
    String snotes;
    Map<String, bool> sflowersMapDB;
    Map<String, bool> sfruitMapDB;


//change this to a list of individuals?
    List<Individual> sIndividualsList;
    bool sNotOnList;
    bool sdataOK;


  //need this for json_annotation
  factory Population.fromJson(Map<String, dynamic> json) => _$PopulationFromJson(json);

  //need this for json_annotation
  Map<String, dynamic> toJson() => _$PopulationToJson(this);
   
  //Constructor
  Population(
    this.sid, 
    this.sfkSite, 
    this.sname,
    this.sNameGenus,
    this.sNameSpecies,
    this.sNameRank,
    this.sNameRankName,
    this.ssighted,
    this.sreproductiveState,
    this.sflowers,
    this.sfruit,
    this.sfruitMapDB,
    this.splantsPresent, 
    this.sadultsPresent,
    this.sjuvenilesPresent,
    this.snotes,
    this.sflowersMapDB,
    this.sIndividualsList,
    this.sNotOnList,
    this.sdataOK,
    );

  //-------------------------------------------------------------------//
  //constructor
  Population.fromFkSite(var fkSite, String aUuid, String speciesName, String nameGenus, String nameSpecies, String nameRank, String nameRankName) {
  sid = aUuid;
  sfkSite = fkSite;
  sname = speciesName;
  sNameGenus = nameGenus;
  sNameSpecies = nameSpecies;
  sNameRank = nameRank;
  sNameRankName = nameRankName;
  ssighted = '';
  sreproductiveState = '';
  sflowers = '';
  sfruit= '';
  splantsPresent = '';
  sadultsPresent = '';
  sjuvenilesPresent = '';
  snotes = '';
  sIndividualsList = [];
  sNotOnList = false;
  sdataOK = true;
}

 //-------------------------------------------------------------------//
    //Getters
    String get id => sid;
    String get fkSite => sfkSite;
    String get name => sname;
    String get nameGenus => sNameGenus;
    String get nameSpecies => sNameSpecies;
    String get nameRank => sNameRank;
    String get nameRankName => sNameRankName;
    String get sighted => ssighted;
    String get reproductiveState => sreproductiveState;
    String get flowers => sflowers;
    String get fruit => sfruit;
    String get plantsPresent => splantsPresent;
    String get adultsPresent => sadultsPresent;
    String get juvenilesPresent => sjuvenilesPresent;
    String get notes => snotes;
    Map<String, bool>    get fruitMapDB => sfruitMapDB;
    Map<String, bool>    get flowersMapDB => sflowersMapDB;
    List<Individual> get individualsList => sIndividualsList;
    bool get notOnList => sNotOnList;
    bool get dataOK => sdataOK;

//-------------------------------------------------------------------//
//Setter, field by name and variable
  set(String varName, var varValue) {
    if (varName == 'id') {
      this.sid = varValue;
    } else if (varName == 'fkSite') {
      this.sfkSite = varValue;
    } else if (varName == 'name') {
      this.sname = varValue;
    } else if (varName == 'nameGenus') {
      this.sNameGenus = varValue;
    } else if (varName == 'nameSpecies') {
      this.sNameSpecies = varValue;
    } else if (varName == 'nameRank') {
      this.sNameRank = varValue;
    } else if (varName == 'nameRankName') {
      this.sNameRankName = varValue;
    } else if (varName == 'sighted') {
      this.ssighted = varValue;
    } else if (varName == 'reproductiveState') {
      this.sreproductiveState = varValue;
    } else if (varName == 'flowers') {
      this.sflowers = varValue;
    } else if (varName == 'fruit') {
      this.sfruit = varValue;
    } else if (varName == 'plantsPresent') {
      this.splantsPresent = varValue;
    } else if (varName == 'adultsPresent') {
      this.sadultsPresent = varValue;
    } else if (varName == 'juvenilesPresent') {
      this.sjuvenilesPresent = varValue;
    } else if (varName == 'notes') {
      this.snotes = varValue;
    } else if (varName == 'flowersMapDB') {
      this.sflowersMapDB= varValue;
    } else if (varName == 'fruitMapDB') {
      this.sfruitMapDB = varValue;
    } else if (varName == 'individualsList') {
      this.sIndividualsList = varValue;
    } else if (varName == 'notOnList') {
      this.sNotOnList = varValue;
    } else if (varName == 'dataOK') {
      this.sdataOK = varValue;
    } 
  }//end setter

//-------------------------------------------------------------------//
  String getFlowers() {
    return _getTrueValuesFromMap('flowers');
  }//end getFlowers

//-------------------------------------------------------------------//
  String getFruits() {
    return _getTrueValuesFromMap('fruits');
  }//end getFruits

//-------------------------------------------------------------------//
  String _getTrueValuesFromMap(String type) {
    Map theMap;
    if (type == "flowers") {
      theMap = flowersMapDB;
    } else if (type == "fruits") {
      theMap = fruitMapDB;
    } 

    String result = '';
    if (theMap != null) {
      theMap.forEach((k, v) {
        var key = k;
        var value = v;
        if (value == true) {
          if (result == '') {
            result = key;
          } else {
            result = key + ', ' + result;
          }
        }
      });
    }
    return result;
}//end _getTrueValuesFromMap



}//end class
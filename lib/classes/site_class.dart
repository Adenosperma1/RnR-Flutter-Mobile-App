
import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

//Classes
import 'package:restoreandrenew/classes/user_class.dart'; //site class

//https://flutter.io/docs/development/data-and-backend/json
//to update json
//cd to app folder
//$ export PATH=~/flutter/bin:$PATH;
//$ flutter packages pub run build_runner build
part 'site_class.g.dart';

//need this variable for json_annotation
@JsonSerializable()

//object of a site created by the user
//-------------------------------------------------------------------//
class Site {
  //vars can't have private variables with json_anotation so prefixed with s
  String sid;
  String sname;
  String sdescription; //Precise location
  String ssoilColour;
  String ssoilTexture;
  String sdisturbanceOther;
  String slandFormOther;
  String shabitatOther;
  String sAssociated;
  String sTenure;
  String sDate;
  Map<String, bool> shabitatMapDB;
  Map<String, bool> sdisturbanceMapDB;
  Map<String, bool> slandFormMapDB;
  List<User> sCollectors;
  

  //site gps
  int sAcc;
  int sAlt;
  double sLat;
  double sLon;
  DateTime sTimeStamp;
  String sUiTime;

//Sighting details
  String sFlagType; //this is typeSighted or typeNotSighted

//status counts
  int sSpeciesCount;
  int sCollectionCount;
  bool sDataOK;
  bool sDataUploaded;
//-------------------------------------------------------------------//
//Constructor need this for json_annotation
  Site(
    this.sname,
    //this.sPreciseLocation,
    this.sdescription,
    this.ssoilColour,
    this.ssoilTexture,
    this.sdisturbanceOther,
    this.slandFormOther,
    this.shabitatOther,
    this.sid,
    this.sAssociated,
    this.sTenure,
    this.sDate,
    this.shabitatMapDB,
    this.slandFormMapDB,
    this.sdisturbanceMapDB,
    this.sCollectors,
    this.sAcc,
    this.sAlt,
    this.sLat,
    this.sLon,
    this.sTimeStamp,
    this.sUiTime,
    this.sFlagType,
    this.sSpeciesCount,
    this.sCollectionCount,
    this.sDataOK,
    this.sDataUploaded,
  );

//need this for json_annotation
  factory Site.fromJson(Map<String, dynamic> json) => _$SiteFromJson(json);

//need this for json_annotation
  Map<String, dynamic> toJson() => _$SiteToJson(this);

//-------------------------------------------------------------------//
//Constructor from a site name
  Site.fromName(var siteName, String aUuid, List<User> collectors) {
    sid = aUuid;
    sname = siteName;
    sdescription = '';
    ssoilColour = '';
    ssoilTexture = '';
    sdisturbanceOther = '';
    slandFormOther = '';
    shabitatOther = '';
    sAssociated = '';
    sTenure = '';
    shabitatMapDB = null;
    sdisturbanceMapDB = null;
    slandFormMapDB = null;
    sCollectors = collectors;
    sDate = _getDate();
    sAcc = 0;
    sAlt = 0;
    sLat = 0.0;
    sLon = 0.0;
    sTimeStamp = DateTime.now();
    sUiTime = '';
    sFlagType = '';
    sSpeciesCount = 0;
    sCollectionCount = 0;
    sDataOK = false;
    sDataUploaded = false;
  }

  //-------------------------------------------------------------------//
  //Getters
  String get id => sid;
  String get name => sname;
  //String get preciseLocation => sPreciseLocation;
  String get description => sdescription;
  String get soilColour => ssoilColour;
  String get soilTexture => ssoilTexture;
  String get disturbanceOther => sdisturbanceOther;
  String get landFormOther => slandFormOther;
  String get habitatOther => shabitatOther;
  String get associated => sAssociated;
  String get tenure => sTenure;
  String get date => sDate;
  Map<String, bool> get disturbanceMapDB => sdisturbanceMapDB;
  Map<String, bool> get landFormMapDB => slandFormMapDB;
  Map<String, bool> get habitatMapDB => shabitatMapDB;
  List<User> get collectors => sCollectors;
  double get lat => sLat;
  double get lon => sLon;
  int get acc => sAcc;
  int get alt => sAlt;
  DateTime get timestamp => sTimeStamp;
  String get uiTime => sUiTime;
  String get flagType => sFlagType;
  int get speciesCount => sSpeciesCount;
  int get collectionCount => sCollectionCount;
  bool get dataOK => sDataOK;
  bool get dataUploaded => sDataUploaded;
//-------------------------------------------------------------------//
  String _getDate() {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    return formatter.format(now); //2019-02-15
  }

//-------------------------------------------------------------------//
  String getCollectors() {
    String collectorsNames = '';
    for (var collector in collectors) {
      if (collectorsNames == '') {
        collectorsNames = collector.name;
      } else {
        collectorsNames = collectorsNames + ', ' + collector.name;
      }
    }
    return collectorsNames;
  }

//-------------------------------------------------------------------//
  String getDisturbances() {
    return _getTrueValuesFromMap('disturbance');
  }

//-------------------------------------------------------------------//
  String getLandForms() {
    return _getTrueValuesFromMap('landForms');
  }

//-------------------------------------------------------------------//
  String getHabitats() {
    return _getTrueValuesFromMap('habitats');
  }

//-------------------------------------------------------------------//
  String getNationalPark() {
    if (sTenure.contains('National Park')) {
      return sTenure;
    } else {
      return '';
    }
  }

  //-------------------------------------------------------------------//
  String getStateConservationArea() {
    if (sTenure.contains('State Conservation Area')) {
      return sTenure;
    } else {
      return '';
    }
  }

  //-------------------------------------------------------------------//
  String getStateForest() {
    if (sTenure.contains('State Forest')) {
      return sTenure;
    } else {
      return '';
    }
  }

  //-------------------------------------------------------------------//
  String getNatureReserve() {
    if (sTenure.contains('Nature Reserve')) {
      return sTenure;
    } else {
      return '';
    }
  }

//-------------------------------------------------------------------//
  String _getTrueValuesFromMap(String type) {
    Map theMap;
    if (type == "disturbance") {
      theMap = disturbanceMapDB;
    } else if (type == "landForms") {
      theMap = landFormMapDB;
    } else if (type == "habitats") {
      theMap = habitatMapDB;
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
  }

//-------------------------------------------------------------------//
//Setter, field by name and variable
  set(String varName, var varValue) {
    if (varName == 'id') {
      this.sid = varValue;
    } else if (varName == 'name') {
      this.sname = varValue;
    } else if (varName == 'description') {
      this.sdescription = varValue;
    } else if (varName == 'soilColour') {
      this.ssoilColour = varValue;
    } else if (varName == 'soilTexture') {
      this.ssoilTexture = varValue;
    } else if (varName == 'disturbanceOther') {
      this.sdisturbanceOther = varValue;
    } else if (varName == 'landFormOther') {
      this.slandFormOther = varValue;
    } else if (varName == 'habitatOther') {
      this.shabitatOther = varValue;
    } else if (varName == 'associated') {
      this.sAssociated = varValue;
    } else if (varName == 'tenure') {
      this.sTenure = varValue;
    } else if (varName == 'date') {
      this.sDate = varValue;
     } else if (varName == 'flagType') {
    this.sFlagType = varValue;
    } else if (varName == 'habitatMapDB') {
      this.shabitatMapDB = varValue;
    } else if (varName == 'disturbanceMapDB') {
      this.sdisturbanceMapDB = varValue;
    } else if (varName == 'landFormMapDB') {
      this.slandFormMapDB = varValue;
    } else if (varName == 'collectors') {
      this.sCollectors = varValue;
    } else if (varName == 'lat') {
      this.sLat = varValue;
    } else if (varName == 'lon') {
      this.sLon = varValue;
    } else if (varName == 'acc') {
      this.sAcc = varValue;
    } else if (varName == 'alt') {
      this.sAlt = varValue;
    } else if (varName == 'timestamp') {
      this.sTimeStamp = varValue;
    } else if (varName == 'uiTime') {
      this.sUiTime = varValue;
    }else if (varName == 'speciesCount') {
      this.sSpeciesCount = varValue;
    }else if (varName == 'collectionCount') {
      this.sCollectionCount = varValue;
    }else if (varName == 'dataOK') {
      this.sDataOK = varValue;
    }else if (varName == 'dataUploaded') {
      this.sDataUploaded = varValue;
    }
}



   
} //Class

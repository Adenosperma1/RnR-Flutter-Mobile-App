import 'package:json_annotation/json_annotation.dart';

//Classes
  



//https://flutter.io/docs/development/data-and-backend/json
//to update json
//cd to app folder
//$ export PATH=~/flutter/bin:$PATH;
//$ flutter packages pub run build_runner build
part 'user_class.g.dart';

//need this variable for json_annotation
@JsonSerializable()
  
//an object of a species selected by the user
  class User{
  String sId;
  String sName;
  String sEmail;
  String sPassword;
  String sInitials;
  bool sRnrUser;
  bool sAdmin;
  bool sHideCollectorID;
  bool sHideSiteGPS;
  bool sRemoveAfterUpload;

  //need this for json_annotation
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  //need this for json_annotation
  Map<String, dynamic> toJson() => _$UserToJson(this);
   
  //Constructor
  User(
    this.sId, 
    this.sName, 
    this.sEmail,
    this.sPassword,
    this.sInitials,
    this.sAdmin,
    this.sHideCollectorID,
    this.sHideSiteGPS,
    this.sRemoveAfterUpload
    );

//-------------------------------------------------------------------//
//Constructor from a user name
  User.fromName(var name) {
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



 //-------------------------------------------------------------------//
   //Getters
  String get id => sId;
  String get name => sName;
  String get email => sEmail;
  String get password => sPassword;
  String get initials => sInitials;
  bool get admin => sAdmin;
  bool get hideCollectorID => sHideCollectorID;
  bool get hideSiteGPS => sHideSiteGPS;
  bool get removeAfterUpload => sRemoveAfterUpload;

}//end class
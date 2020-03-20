import 'dart:io';

//Classes
import 'package:restoreandrenew/classes/user_class.dart';

//Helpers
import 'package:restoreandrenew/helpers/database_local_helper.dart';
import 'package:restoreandrenew/helpers/database_remote_helper.dart';



//temp for testing php call
import 'package:restoreandrenew/helpers/database_remote_helper1.dart';


DatabaseHelper db = new DatabaseHelper();

ibGetHomePage() async{

//Has someone logged in in the past?
User _loggedInUser = await ibGetLoggedInUser();
//yes let them in

if (_loggedInUser != null) {
  ibCheckForUpdates();
  return 'siteList';
  }

//no one saved log in & there's no internet, check for local users
if(await ibInternetConnection() == false){
  if(await ibAreThereAvailableUsersLocally() == true ){
    return 'logIn';
  }
  return 'errorPage';

}else{
  //there's internet
  //get updates and show log in
  await ibCheckForUpdates();
  return 'logIn';
}
}

//-------------------------------------------------------------------//
ibCheckForUpdates() async {

//check for internet connection
  bool internetConnection = await ibInternetConnection();
  if (internetConnection == true) {
  
    //always update the user list
    ibRemoteAvailable('availableUser');
    
    //only update if there are different amounts local vs server
    ibCompareAvailableLists('availableSite');
    ibCompareAvailableLists('availableSpecies');
    return true;
  } else {
    print('DB IB says: No internet connection');
    return false;
  }
}

//compares on count but should do it on changed details as well?
//-------------------------------------------------------------------//
ibCompareAvailableLists(String type) async {
  var availableLocal = new List();
  var availableRemote = new List();

  availableLocal = await db.getObjectList(type);
  availableRemote = await fsGetRemoteListAsync(type);

  if (availableLocal.length != availableRemote.length) {
    await db.saveObjectList(type, availableRemote, '1');
    print('Updated ' + type + ' list.');
    availableLocal = await db.getObjectList(type);
  } else if(availableRemote.length > 0){
    print('Up to date: ' + type);
  }
} //end compareAvailableList()




//-------------------------------------------------------------------//
ibRemoteAvailable(String type) async {
    var availableRemote = new List();
    availableRemote = await fsGetRemoteListAsync(type);
    await db.saveObjectList(type, availableRemote, '1');
    print('Updated ' + type + ' list.');
} //end

//-------------------------------------------------------------------//
ibInternetConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('DB IB says: Internet connected!');

print("start test");
await fsGetRemoteListAsync1('test');
print("end test");

      return true;
    }
  } on SocketException catch (_) {
    print('DB IB says: No internet?');
    return false;
  }
}//end


//-------------------------------------------------------------------//
ibGetLoggedInUser() async {
  var userList = await db.getObjectList('user');
  if(userList.length != 0){
    print('DB IB says: there is a logged in user');
    return userList[0];
  }else{
    print('DB IB says: there is not a logged in user');
    return null;}
}//end




//-------------------------------------------------------------------//
ibAreThereAvailableUsersLocally() async {
    var availableUserLocal = new List();
    availableUserLocal = await db.getObjectList('availableUser');

  if(availableUserLocal.length != 0){
    print('DB IB says: there are local users');
    return true;
  }else{
    print('DB IB says: there are no local users');
    return false;
  }
}//end

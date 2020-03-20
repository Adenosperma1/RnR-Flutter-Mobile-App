import 'package:flutter/services.dart';
import 'package:location/location.dart';
//import 'dart:io'; //for system check

//import 'package:restoreandrenew/classes/collection_class.dart';

String error;
Location _locationService = new Location();
LocationData location;

//-------------------------------------------------------------------//
getGPS() async {
  try {
    bool serviceStatus = await _locationService.serviceEnabled();

    if (serviceStatus) {
      var permission = await _locationService.hasPermission();
      if(permission == false){
        await _locationService.requestPermission();
      } 
    }


  //clear the current location
  location = null;
  location = await _locationService.getLocation();
    

  } on PlatformException catch (e) {
    if (e.code == 'PERMISSION_DENIED') {
      error = e.message;
    } else if (e.code == 'SERVICE_STATUS_ERROR') {
      error = e.message;
    }
    location = null;
  }
  
  return location;
}







/*
//-------------------------------------------------------------------//
getGPSForCollection(Collection collection) async {
  DateTime timeStamp;
  timeStamp = null;
  String _uiTime = '';
  LocationData location;

  try {
    location = await getGPS();
    
  } catch (e) {
  }

print('Time: ' ); //+ location.time.toString());


  if (location.latitude != null) {
    collection.set('lat', location.latitude);
    collection.set('lon', location.longitude);
    collection.set('acc', location.accuracy.toInt());
    collection.set('alt', location.altitude.toInt());
    
    timeStamp = Platform.isIOS
            ? DateTime.fromMillisecondsSinceEpoch(location.time.toInt() * 1000)
            : DateTime.fromMillisecondsSinceEpoch(location.time.toInt());
    
    collection.set('timestamp', timeStamp);


    /*collection.set(
        'timestamp',
        Platform.isIOS
            ? DateTime.fromMillisecondsSinceEpoch(location.time.toInt() * 1000)
            : DateTime.fromMillisecondsSinceEpoch(location.time.toInt()));
            */


    //DateTime theDateTime = timeStamp;
    String hour = timeStamp.hour.toString();
    String minute = timeStamp.minute.toString();
    String second = timeStamp.second.toString();

    if (minute.length == 1) {
      minute = '0' + minute;
    }
    if (second.length == 1) {
      second = '0' + second;
    }

    _uiTime = hour + ':' + minute + ':' + second;
    collection.set('uiTime', _uiTime);
print('GPS2 says: got gps');
  } 
  
  else {
    print('GPS2 says: There\'s no gps!');
    collection.set('lat', 0.0);
    collection.set('lon', 0.0);
    collection.set('acc', 0);
    collection.set('alt', 0);
    collection.set('timestamp', null);
  }

} //end _getGPS
*/

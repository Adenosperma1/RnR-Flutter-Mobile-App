
//import 'dart:convert';
import 'package:http/http.dart';



    
//-------------------------------------------------------------------//
fsGetRemoteListAsync1(String collection) async {
  //hello.php
  //getList.php

  //this works in a browser
  //http://www.thefigsofaustralia.com/herbarium/con.php

final jsonEndpoint = "http://www.thefigsofaustralia.com/herbarium/conn.php";
final response = await get(jsonEndpoint);
//if (response.statusCode == 200) {

print(response.body);

print("done");
//} else
//print('zip');
}



/*
//final jsonEndpoint = "http://174.136.12.166/ello.php/";
final jsonEndpoint = "http://http://www.thefigsofaustralia.com/herbarium/hello.php";
final response = await get(jsonEndpoint);
if (response.statusCode == 200) {
List spacecrafts = json.decode(response.body);
return spacecrafts
.map((spacecraft) => new Spacecraft.fromJson(spacecraft))
.toList();
} else
throw Exception('We were not able to successfully download the json data.');
}
*/





 /* 
QuerySnapshot querySnapshot = await
mainReference
.collection(collection)
.orderBy('name', descending: false)
.getDocuments();

List<DocumentSnapshot> snapshotlist;
var theList = new List();
snapshotlist = querySnapshot.documents;

theList = snapshotlist.map((DocumentSnapshot data){
  if(     collection == 'availableSite'){return AvailableSite.fromSnapshot(data);}
  else if(collection == 'availableSpecies'){return AvailableSpecies.fromSnapshot(data);}
  else if(collection == 'availableUser'){return AvailableUser.fromSnapshot(data);}
}
).toList();

return theList;
*/
//}//end fsGetRemoteListAsync


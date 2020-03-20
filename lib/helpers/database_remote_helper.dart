


//import 'dart:convert';
//import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:csv/csv.dart';
//import 'package:uuid/uuid.dart';

//Classes 
import 'package:restoreandrenew/classes/site_available_class.dart';
import 'package:restoreandrenew/classes/species_available_class.dart';
import 'package:restoreandrenew/classes/user_available_class.dart';


Firestore mainReference = Firestore.instance;


//-------------------------------------------------------------------//
fsDocumentUpdateAsync(String collection, String documentID, String fieldName,  var fieldData) async{
    await mainReference.collection(collection).document(documentID).updateData({fieldName: fieldData});
    if (fieldData is String) {
      print('Updated firestore field: ' + fieldName+ ', with data: ' + fieldData);
    } else {
      print('Updated firestore field: ' + fieldName );
    }
  }//end fsDocumentUpdateAsync

//-------------------------------------------------------------------// 
fsDocumentNewAsync(String collection, var theObject)async{
//return the id of the new doc
final DocumentReference newDoc = await mainReference.collection(collection).add(theObject.toMap());
//print('here: ' + newDoc.documentID);
return newDoc.documentID;
}//end fsDocumentNewAsync

//-------------------------------------------------------------------//
fsDocumentDeleteAsync(String collection, String documentID) async {
await mainReference.collection(collection).document(documentID).delete();
}//end fsDocumentDeleteAsync
    
//-------------------------------------------------------------------//
fsGetRemoteListAsync(String collection) async {
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
  return null;
}
).toList();

return theList;
}//end fsGetRemoteListAsync


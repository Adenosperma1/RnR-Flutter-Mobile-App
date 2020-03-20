import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart'; //for text input black list

//Helpers
import 'package:restoreandrenew/helpers/database_local_helper.dart';
import 'package:restoreandrenew/helpers/database_remote_helper.dart';
import 'package:restoreandrenew/helpers/ui_helper.dart';

//Classes
import 'package:restoreandrenew/classes/user_available_class.dart';
import 'package:restoreandrenew/classes/site_available_class.dart';
import 'package:restoreandrenew/classes/species_available_class.dart';

//Pages
import 'package:restoreandrenew/pages/user_cloud_page.dart';
import 'package:restoreandrenew/pages/species_cloud_page.dart';





DatabaseHelper db = new DatabaseHelper();
var uuid = new Uuid(); //library that makes uuids

//-------------------------------------------------------------------//
class Selector extends StatefulWidget {
  final String type;

  final bool edit;

  Selector(
      //constructor //hand in the site
      {Key key,
      @required this.type,
      this.edit})
      : super(key: key);

  @override
  _SelectorState createState() => _SelectorState();
}

//-------------------------------------------------------------------//
class _SelectorState extends State<Selector> {
  var _searchview = new TextEditingController();
  var _asyncResult;
  bool _loadingInProgress; //used for spinner
  bool _firstSearch = true;
  String _query = "";
  String typeSite = 'Site';
  String typeSpecies = 'Species';
  String typeUser = 'User'; //the local database calls it user
  String availableSite = 'availableSite';
  String availableSpecies = 'availableSpecies';
  String availableUser = 'availableUser';
  var availableObjects = new List();
  
  var theType;
  String availableType;
  String addOrEdit; 

  //UI lists from local database
  List<String> _unfilterList = new List<String>();
  List<String> _filterList;

  @override
  void initState() {
    super.initState();

    _loadingInProgress = true;
    theType = widget.type;
    if (theType == typeSite) {
      availableType = availableSite;
    } else if (theType == typeSpecies) {
      availableType = availableSpecies;
    } else if (theType == typeUser) {
      availableType = availableUser;}
    if (widget.edit == true) {
      addOrEdit = 'Edit';
    }else{
      addOrEdit = 'Add';
    }

    syncList();
  }

//-------------------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    if (_loadingInProgress == true) {
      return Scaffold(
          backgroundColor: Colors.white,
          body: Container(
              child: Center(
            child: new CircularProgressIndicator(),
          )));
    } else {
      _unfilterList = _asyncResult;
      return 
      WillPopScope(//this stops the Android OS back button
    onWillPop: () async => false,
    child:   
      
      
      Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(30.0),
            child: (uiBuildAppBarWhite(context, ''))),
        body: new Container(
          margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
          child: new Column(
            children: <Widget>[
              _sectionSearchView(),
              _firstSearch ? _sectionListView(false) : _performSearch()
            ],
          ),
        ),
      ));
    }
  } //end build

//-------------------------------------------------------------------//
syncList() async{
//get the local list// this helps update it for some reason
db.getObjectList(availableType) .then((_) =>
_buildNamesList(context, availableType).then((result) {
        setState(() {
          _asyncResult = result;
          _loadingInProgress = false; //used for spinner
        });
}));
//print('Selector says: sync done...');
} //end syncList

//-------------------------------------------------------------------//
  Widget _sectionSearchView() {
    return new Container(
        child: _uiSearchField(_searchview, widget.type + " Name"));
  } //end _createSearchView

//-------------------------------------------------------------------//
  Widget _sectionListView(bool filtered) {
    List<String> theList;
    if (filtered == false) {
      theList = _unfilterList;
    } else {
      theList = _filterList;
    }
    return new Flexible(
      child: new ListView.builder(
          itemCount: theList.length,
          itemBuilder: (BuildContext context, int index) {
            return buildListTile(theList, index, context);
          }),
    );
  } //end _createListView

//-------------------------------------------------------------------//
  ListTile buildListTile(
      List<String> theList, int index, BuildContext context) {
    if (widget.edit == false) {
      //show a normal list view
      return ListTile(
        title: Text('${theList[index]}'),
        onTap: () => _selectAvailable(theList[index], context),
      );
    } else {
      if (widget.type == typeUser) {
        return ListTile(
          //show the arrow icon
          title: Text('${theList[index]}'),
          trailing:
              Icon(Icons.keyboard_arrow_right, color: Colors.black, size: 30.0),
          onTap: () => _openAvailableUser(context, '${theList[index]}'),
        );
      } else if(widget.type == typeSpecies){
    
      return ListTile(
          //show the arrow icon
          title: Text('${theList[index]}'),
          trailing:
              Icon(Icons.keyboard_arrow_right, color: Colors.black, size: 30.0),
          onTap: () =>  _openAvailableSpecies(context, '${theList[index]}'),
        );
      } else {
        return ListTile(
          //show the trash can icon
          title: Text('${theList[index]}'),
          trailing: Icon(Icons.delete_outline, color: Colors.black, size: 20.0),
          onTap: () => _deleteAvailable(theList, index, context),
        );
      }
    }
  } //end buildListTile

//-------------------------------------------------------------------//
  _SelectorState() {
    //Register a closure to be called when the object changes.
    _searchview.addListener(() {
      if (_searchview.text.isEmpty) {
        //Notify the framework that the internal state of this object has changed.
        setState(() {
          _firstSearch = true;
          _query = "";
        });
      } else {
        setState(() {
          _firstSearch = false;
          _query = _searchview.text;
        });
      }
    });
  } //end _SelectorState

//-------------------------------------------------------------------//
  Widget _performSearch() {
    _filterList = new List<String>();
    for (int i = 0; i < _unfilterList.length; i++) {
      var item = _unfilterList[i];
      if (item.toLowerCase().contains(_query.toLowerCase())) {
        _filterList.add(item);
      }
    }
    _filterList.sort();
    return _sectionListView(true);
  } // _performSearch

//-------------------------------------------------------------------//
  _selectAvailable(String name, BuildContext context) async{
    //return the species object
    if(widget.type == typeSpecies){
      int position =  await _getPositionFromName(name);
      AvailableSpecies availableSpecies = availableObjects[position];
      Navigator.pop(context, availableSpecies); //return the name of the new site
    } else {
    Navigator.pop(context, name); //return the name of the new site
    }
  } //end _selectAvailable

//-------------------------------------------------------------------//
  _deleteAvailable(List<String> theList, int index, BuildContext context) {
    _dialogRemove(context, theList, index);
  } //end _deleteAvailable

//-------------------------------------------------------------------//
  _openAvailableUser(BuildContext context, String name) async {
    if (widget.type == typeUser) {
      int position = await _getPositionFromName(name);
      //print('position: ' + position.toString());

      String result = await 
      Navigator.push(context,MaterialPageRoute(
              builder: (context) => UserCloud(users: availableObjects, position: position)),
        );
      
      if(result == 'remove'){
        _removeName(name);
      }
      else {
        syncList();
      }
    }
  } //end _openAvailable

  //-------------------------------------------------------------------//
  _openAvailableSpecies(BuildContext context, String name) async {

//print('here...');
    if (widget.type == typeSpecies) {
      //get the object
      //AvailableUser user = await _getObjectFromName(name);
      int position = await _getPositionFromName(name);

      String result = await 
      Navigator.push(context,MaterialPageRoute(
              builder: (context) => SpeciesCloud(speciesList: availableObjects, position: position)),
        );
      
      if(result == 'remove'){
        _removeName(name);
      }
      else {
        syncList();
      }
    }
  } //end _openAvailable

//-------------------------------------------------------------------//
  _addNewName(BuildContext context, String name) async{

    //check if the type is species
    if (widget.edit == false) {
      //this adds it to the UI list but not online
      if(widget.type == typeSpecies){
        //the star means it isn't on the list the star is removed in the species list page
       // name = '*' + name;

      }

      Navigator.pop(context, name); //close the dialog
      Navigator.pop(context, name); //close the selector page
    } else {
      //this adds it to the firestore database
      Navigator.pop(context, name); //close the dialog
      
      //clear the search field
      _searchview.text = '';

      //make a local object to hand on to firestore
      var theObject;

      if (widget.type == typeUser){
      theObject = new AvailableUser.fromName(name, 'tempID');
      }else if(widget.type == typeSite){
      theObject = new AvailableSite.fromName(name, 'tempID');
      }else if(widget.type == typeSpecies){
      theObject = new AvailableSpecies.fromName(name, 'tempID');
      }

      //make a new firestore document from the local object
      String docID = await fsDocumentNewAsync(availableType, theObject);

      //update the local objects id
      theObject.set('id', docID);

      //add it to the list of objects
      availableObjects.add(theObject);
      //add it to the local database
      await db.saveObjectList(availableType, availableObjects, '1');

     //update the list
      await syncList();//this updates the UI list with the local db records
    
      //open the item
      await _openNewItem(name);
    }
  } //end _addNewName


//-------------------------------------------------------------------//
_openNewItem(String name) async{
  //now open the new user or species form, push the new object
      if(widget.type == typeSpecies){
        _openAvailableSpecies(context, name);
      } else if(widget.type == typeUser){
        _openAvailableUser(context, name);
      }
}


//-------------------------------------------------------------------//
_buildNamesList(BuildContext context, String type) async {
    
    var availableNames = new List<String>();
    String name;

    availableObjects = await db.getObjectList(type);
    
    //get a list of the names from the objects list
    for (var anAvailableObject in availableObjects) {
      name = anAvailableObject.name;
      availableNames.add(name);
    }
    availableNames.sort();
    return availableNames;
  } //end _getList

//-------------------------------------------------------------------//
  _uiSearchField(TextEditingController theController, String searchTitle) {
    return Center(
        child: Row(children: [
      Expanded(
          child: new TextField(
        //autofocus: true,
        controller: theController,
        inputFormatters: [BlacklistingTextInputFormatter(RegExp(getBlackList())),],
        textCapitalization: TextCapitalization.sentences,


        decoration: InputDecoration(
          border:
              OutlineInputBorder(borderRadius: new BorderRadius.circular(30.0)),
          contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
          fillColor: Colors.white,
          prefixIcon: new Icon(Icons.search),
          hintText: searchTitle,
          hintStyle: new TextStyle(color: Colors.black45),
        ),
        textAlign: TextAlign.left,
      )),
      Container(
        width: 55.0,
        height: 55.0,
        padding: EdgeInsets.only(left: 5.0),
        child: _uiButtonOutLinePlus(),
      )
    ]));
  } //end  _uiSearchField

//-------------------------------------------------------------------//
  _uiButtonOutLinePlus() {

    //111 can i grey this out till there is something in the text field
    return Material(
        child: Ink(
      decoration: BoxDecoration(
        border: Border.all(color: uiGetPrimaryColor(), width: 2.0),
        shape: BoxShape.circle,
      ),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(1000.0), //Something large to ensure a circle
        onTap: () => _dialogAdd(context),
        child: Icon(Icons.add, size: 30.0, color: uiGetPrimaryColor()),
      ),
    ));
  } //end _uiButtonOutLinePlus

//-------------------------------------------------------------------//
  void _dialogAdd(BuildContext context) {
    String name = _searchview.text;
    String theType = widget.type;
    print('typeSite: ' + typeSite);
    if(widget.type == typeSite){
      theType = 'Tenure';
    }
    if (_searchview.text.isNotEmpty) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: new Text("Add " + theType),
                content: new Text(name),
                actions: <Widget>[
                  new FlatButton(
                    textColor: Colors.black,
                    child: new Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  new FlatButton(
                    textColor: Colors.white,
                    color: uiGetGreenColor(),
                    child: new Text('ADD'),
                    onPressed: () => _addNewName(context, name),
                  ),
                ]);
          });
    } else {
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: new Text("Search first!"),
                content: new Text("If not found then add."),
              );
          });
    }
  } //end _dialogAdd

//-------------------------------------------------------------------//
_dialogRemove(
    BuildContext context,
    List<String> theList,
    int index,
  ) {
    String name = theList[index];
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text("Remove"),
              content: new Text(name),
              actions: <Widget>[
                new FlatButton(
                  textColor: Colors.black,
                  child: new Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  textColor: Colors.white,
                  color: Colors.red,
                  child: new Text('REMOVE'),
                  onPressed: () =>
                      _removeName(name), //_addNewName(name, context),
                ),
              ]);
        });
  } //end _dialogRemove

//-------------------------------------------------------------------//
_removeName(String name) async {

  print('Selector page is deleting');
if(theType == typeSite ){
Navigator.pop(context); //close the dialog
}
    //find the id for the object with this name
    String docId;
    var theObject;

    for (var anAvailableObject in availableObjects) {
      if (anAvailableObject.name == name) {
        docId = anAvailableObject.id;
        theObject = anAvailableObject;
      }
    }

      //firestore delete
      await fsDocumentDeleteAsync(availableType, docId);

      //delete the local one from the list
      availableObjects.remove(theObject);

      //add it to the local database
      await db.saveObjectList(availableType, availableObjects, '1');

      syncList();
  } //end removeName




  //-------------------------------------------------------------------//
  _getPositionFromName(String name) async {
    var availableObjects = new List();
    availableObjects = await db.getObjectList('$availableType');
    int position = 0;
    for (var anAvailableObject in availableObjects) {
      if (anAvailableObject.name == name) {
        return position;
      }
      position = position + 1;
    }

    
  } //end _getList





} //end class

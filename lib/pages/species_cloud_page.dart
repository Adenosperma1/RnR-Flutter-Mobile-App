import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //for text input black list

//Classes
import 'package:restoreandrenew/classes/species_available_class.dart'; //Species class

//Helpers
import 'package:restoreandrenew/helpers/database_local_helper.dart';
import 'package:restoreandrenew/helpers/database_remote_helper.dart';
import 'package:restoreandrenew/helpers/ui_helper.dart';


//Pages

//-------------------------------------------------------------------//
class SpeciesCloud extends StatefulWidget {
  final int position;
  final speciesList;

  SpeciesCloud({
    Key key,
    @required this.speciesList,
    this.position,
  }) : super(key: key); //hand in the Species from the previous context

  @override
  _SpeciesCloudState createState() => _SpeciesCloudState();
}

//-------------------------------------------------------------------//
class _SpeciesCloudState extends State<SpeciesCloud> {
  DatabaseHelper db = new DatabaseHelper();

  String availableType = 'availableSpecies';

  //-------------------------------------------------------------------//
//List of values for drop down fields
  final List<String> rankNameList = <String>['', 'var.', 'subsp.', 'forma'];

  //one list that holds all the selected results for the drop down menus
  var resultsList = new List<String>.filled(2, '');

//-------------------------------------------------------------------//
//Controllers for normal fields
  final TextEditingController idController = TextEditingController();
  // final TextEditingController nameController = TextEditingController();
  final TextEditingController nameGenusController = TextEditingController();
  final TextEditingController nameSpeciesController = TextEditingController();
  //final TextEditingController nameRankController = TextEditingController();
  final TextEditingController nameRankNameController = TextEditingController();

  bool admin;
  bool unsaved = false;
  bool saving = false;

  AvailableSpecies species;

//-------------------------------------------------------------------//
  @override
  void initState() {
    species = widget.speciesList[widget.position];

    //normal fields
    idController.text = species.idFM;
    //nameController.text = species.name;
    nameGenusController.text = species.nameGenus; //species.nameGenus;
    nameSpeciesController.text = species.nameSpecies;
    //nameRankController.text = species.nameRank;
    nameRankNameController.text = species.nameRankName;

    //drop down menu fields, results are saved into a list of results
    resultsList[0] = species.nameRank;

    return super.initState();
  } //end initState

//-------------------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    return  
        Scaffold(
            appBar: _buildAppBar(context, ''), body: _buildBody(context));
  } //end build

//-------------------------------------------------------------------//
  Widget _buildAppBar(BuildContext context, String title) {
    return AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        centerTitle: false,
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text(title,
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 19)),

        // action button
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_outline, size: 30.0),
            onPressed: () {
              _dialogRemoveSpecies(context);
            },
          ),
        ]);
  } //end _buildAppBar

//-------------------------------------------------------------------//
  Widget _buildBody(BuildContext context) {
    return new SafeArea(
        top: false,
        bottom: false,
        child: new Form(
            autovalidate: true,
            child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: <Widget>[
                  uiSpaceBelow(10),
                 // uiTitle('DB ID'),
                 // _uiFieldSave(idController),
                  uiTitle('Genus'),
                  _uiFieldSave(nameGenusController),
                  uiTitle('Species'),
                  _uiFieldSave(nameSpeciesController),
                  uiTitle('Sub Type'),
                  _fieldDropDown(rankNameList, 0, 'nameRank'),
                  uiTitle('Sub Type Name'),
                  _uiFieldSave(nameRankNameController),
                  uiSpaceBelow(20),
                  _showSaveButton(),
                ])));
  } //end _buildBody

/*
//-------------------------------------------------------------------//
  _showSaveButton() {
    if (unsaved == true) {
      return _buttonSave(context);
    } else {
      return Container();
    }
  }
*/

//-------------------------------------------------------------------//
  _spinner() {
    return Container(child: Column(children: <Widget>[uiSpinnerBlack()]));
  }

//-------------------------------------------------------------------//
  _showSaveButton() {

    if (unsaved == true) {

      if (saving == true) {
        return _spinner();
      } else {
        return _buttonSave(context);
      }
    } else {
      return Container();
    }
  }

//-------------------------------------------------------------------//
  _buttonSave(context) {
    return new SizedBox(
      height: 45.0,
      child: ButtonTheme(
        child: FlatButton(
          child: Text('SAVE'),
          onPressed: () {
            _saveSpecies();
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          color: uiGetGreenColor(),
          textColor: Colors.white, //uiGetPrimaryColorDark(),
        ),
      ),
    );
  } //end _buttonSave

//-------------------------------------------------------------------//
  _saveSpecies() async {


    if (unsaved == true) {
//start the spinner?
      setState(() {
        saving = true;
      });



//update the local object
    String fullName = nameGenusController.text +
        ' ' +
        nameSpeciesController.text +
        ' ' +
        resultsList[0] +
        ' ' +
        nameRankNameController.text;
    print(fullName);

//nameRankController.text + ' ' +
//species.set('id', idController.text);
    await species.set('idFM', idController.text);
     await species.set('name', fullName.trim());
     await species.set('nameGenus', nameGenusController.text);
     await species.set('nameSpecies', nameSpeciesController.text);
     await species.set('nameRank', resultsList[0]);
     await species.set('nameRankName', nameRankNameController.text);


    //print(species.name);
    

//save to local database
    //print('availableType: ' + availableType);
//await db.saveObjectList(availableType, widget.speciesList, '1');
    _save();

     await  fsDocumentUpdateAsync(availableType, species.id, 'idFM', species.idFM);
     await fsDocumentUpdateAsync(availableType, species.id, 'name', species.name);
     await fsDocumentUpdateAsync(
        availableType, species.id, 'nameGenus', species.nameGenus);
     await fsDocumentUpdateAsync(
        availableType, species.id, 'nameSpecies', species.nameSpecies);
     await fsDocumentUpdateAsync(
        availableType, species.id, 'nameRank', species.nameRank);
     await fsDocumentUpdateAsync(
        availableType, species.id, 'nameRankName', species.nameRankName);

    setState(() {
      unsaved = false;
      saving = false;
    });

    }
  } //end _saveUser

//-------------------------------------------------------------------//
  _save() async {
    await db.saveObjectList(availableType, widget.speciesList, '1');
  }

//-------------------------------------------------------------------//
  _uiFieldSave(
      //the object needs a bool called unsaved
      TextEditingController theController) {
    return TextField(
      controller: theController,
      inputFormatters: [BlacklistingTextInputFormatter(RegExp(getBlackList())),],


      decoration: InputDecoration(
          contentPadding: fieldInset(),
          border:
              OutlineInputBorder(borderRadius: new BorderRadius.circular(0.0))),
      onChanged: (newValue) {
        setState(() {
          unsaved = true;
        });
      },
    );
  } //end

//-------------------------------------------------------------------//
  _dialogRemoveSpecies(BuildContext context) {
    String name = species.name;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text('Remove'),
              content: new Text(
                  name + '. \n \n This species will not be available again!'),
              actions: <Widget>[
                new FlatButton(
                  textColor: Colors.black,
                  child: new Text('CANCEL'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                    color: Colors.red,
                    textColor: Colors.white,
                    child: new Text('REMOVE'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _removeName(name);
                    }),
              ]);
        });
  } // end _dialogRemoveSpecies

//-------------------------------------------------------------------//
  //removes from the list screen
  _removeName(String name) async {
    Navigator.pop(context, 'remove');
  } //end removeName

//-------------------------------------------------------------------//
//Build Feilds with drop down menus
  _fieldDropDown(List<String> theList, int resultPosition, var dbField) {
    return new FormField(
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: InputDecoration(
            contentPadding: fieldInset(),
            //contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border: OutlineInputBorder(
                borderRadius: new BorderRadius.circular(0.0)),
          ),
          child: new DropdownButtonHideUnderline(
            child: new DropdownButton(
              value: this.resultsList[resultPosition],
              isDense: true,
              onChanged: (String newValue) {
                setState(() {
                  unsaved = true;
                  this.resultsList[resultPosition] = newValue;
                  state.didChange(newValue);
                  //this is different to the rest of the app, you don't save here
 
                });
              },
              items: theList.map((String value) {
                return new DropdownMenuItem(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  } //end

} //class

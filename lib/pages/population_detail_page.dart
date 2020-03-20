import 'package:flutter/material.dart';

//Classes
import 'package:restoreandrenew/classes/site_class.dart'; 
import 'package:restoreandrenew/classes/population_class.dart'; 
import 'package:restoreandrenew/classes/species_available_class.dart';


//Helpers
import 'package:restoreandrenew/helpers/database_local_helper.dart';
import 'package:restoreandrenew/helpers/ui_helper.dart';
import 'package:restoreandrenew/pages/selector_page.dart';

//-------------------------------------------------------------------//
class PopulationDetail extends StatefulWidget {
  final Site site;
  final List<Population>
      populationList; // hand in the list to save into and to the db
  final Population population; // hand in the selected Species object

  PopulationDetail({Key key, @required this.site, this.population, this.populationList})
      : super(key: key); //hand in the Species from the previous context

  @override
  _SpeciesDetailState createState() => _SpeciesDetailState();
}

//-------------------------------------------------------------------//
class _SpeciesDetailState extends State<PopulationDetail> {
  DatabaseHelper db = new DatabaseHelper();

//-------------------------------------------------------------------//
//Controllers for normal fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final List<String> reproductiveStateList = <String>['', 'Sterile', 'Fertile'];

  final List<String> plantsPresentList = <String>[
    '',
    'Less than 5',
    'Between 5 and 20',
    'More than 20'
  ];

  final List<String> adultsPresentList = <String>[
    '',
    'Yes',
    'No',
    'Not Sure'
  ];

  final List<String> juvenilesPresentList = <String>[
    '',
    'Yes',
    'No',
    'Not Sure',
  ];

//one list that holds all the selected results for the drop down menus
  var resultsList = new List<String>.filled(5, '');

//-------------------------------------------------------------------//
//Check box values
  Map<String, bool> flowersMapUI  = uiMapFromList([
    'Buds',
    'Mature',
    'Male',
    'Female',
    'Bisexual',
    'Not Sure (flowers present)',
    'Not present',
  ]);

  Map<String, bool>  fruitMapUI = uiMapFromList([
    'Immature',
    'Mature',
    'Seed mature',
    'Seed immature',
    'Seed released',
    'Not present',
  ]);

 // var collectionName = 'species';

//-------------------------------------------------------------------//
//Build Feilds with drop down menus
  _fieldDropDown(List<String> theList, int resultPosition, var dbField) {
    return new FormField(
      builder: (FormFieldState state) {
        return InputDecorator(
          decoration: InputDecoration(
            contentPadding: fieldInset(),
            border: OutlineInputBorder(
                borderRadius: new BorderRadius.circular(0.0)),
          ),
          child: new DropdownButtonHideUnderline(
            child: new DropdownButton(
              value: this.resultsList[resultPosition],
              isDense: true,
              onChanged: (String newValue) {
                setState(() {
                  this.resultsList[resultPosition] = newValue;
                  state.didChange(newValue);
                  //update the species object
                  widget.population.set(dbField, newValue);
                  //save to species list to the db
                  _save();
                  //db.updateSpeciesList(widget.speciesList, widget.site.id);
                });
              },
              items: theList.map((String value) {
                return new DropdownMenuItem(
                  value: value,
                  child: new Text(value),
                );
              }).toList(),
            )));
      },
    );
  } //end fieldDropDown

//-------------------------------------------------------------------//
//Build a checklist
  _checkList(Map<String, bool> theMap, String dbMapField, String dbField) {
    return new ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(), //need this for a list in a list

      children: theMap.keys.map((String key) {
        return new CheckboxListTile(
          value: theMap[key],
          title: new Text(key),
          dense: uiIsDense(),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (bool value) {
            setState(() {
              theMap[key] = value;
            });

            //save a human readable list of checked boxes to the database
            //var readableList = uiCheckListResult(theMap);
            //dbUpdate(collectionName, widget.species.id, dbField, readableList);

            //update the species object
            widget.population.set(dbMapField, theMap);
            //save to species list to the db
            _save();
            //db.updateSpeciesList(widget.speciesList, widget.site.id);
          });
      }).toList(),
    );
  } //end _checkList

//-------------------------------------------------------------------//
  @override
  void initState() {
    //set the intial feild value

    //normal fields
    nameController.text = widget.population.name;
    notesController.text = widget.population.notes;

    //drop down menu fields
    //resultsList[0] = widget.species.sighted;
    resultsList[1] = widget.population.reproductiveState;
    resultsList[2] = widget.population.plantsPresent;
    resultsList[3] = widget.population.adultsPresent;
    resultsList[4] = widget.population.juvenilesPresent;

    //Checklists
    if (widget.population.flowersMapDB != null) {
      flowersMapUI = widget.population.flowersMapDB.cast<String, bool>();
    }

    if (widget.population.fruitMapDB != null) {
      fruitMapUI = widget.population.fruitMapDB.cast<String, bool>();
    }
    return super.initState();
  } //end initState

//-------------------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    return 
    WillPopScope(//this stops the Android OS back button
    onWillPop: () async => false,
    child:   
    
    Scaffold(
        appBar: _buildAppBar(context, ''), body: _buildBody(context)));
  } //end build

//-------------------------------------------------------------------//
  Widget _buildAppBar(BuildContext context, String title) {
    return AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        centerTitle: false,
        leading:_backArrow(context),
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
            icon: Icon(Icons.delete_outline//, size: 30.0
            ),
            onPressed: () {
              _dialogRemoveSpecies(context);
            },
          ),
        ]);
  }//end _buildAppBar


//-------------------------------------------------------------------//
  _save(){
    db.updatePopulationRow(widget.populationList, widget.site.id);
  }

//-------------------------------------------------------------------//
  Widget _buildBody(BuildContext context) {
    Population population = widget.population;
    return new SafeArea(
        top: false,
        bottom: false,
        child: new Form(
            autovalidate: true,
            child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: <Widget>[

                  //here
                  //uiTitleSpecies(widget.species.name),
                  _buttonChangeName(),

                  uiTitle("Reproductive State"),
                  _fieldDropDown(reproductiveStateList, 1, 'reproductiveState'),
                  uiTitle("Flowers"),
                  _checkList(flowersMapUI, 'flowersMapDB', 'flowers'),
                  uiTitle("Fruit"),
                  _checkList(fruitMapUI, 'fruitMapDB', 'fruit'),
                  uiTitle('Other ' + widget.population.name + ' within 10m radius'),
                  _fieldDropDown(plantsPresentList, 2, 'plantsPresent'),
                  uiTitle('Adults Present'),
                  _fieldDropDown(adultsPresentList, 3, 'adultsPresent'),
                  uiTitle('Juveniles Present'),
                  _fieldDropDown(juvenilesPresentList, 4, 'juvenilesPresent'),
                  uiTitle("Notes"),
                  
                  uiField(widget.populationList, population, notesController,'notes',
                  //oouiField(objects, object, theController, fieldName)
                  ),
                  uiTitle(""),
                  _buttonCollections(),
                  uiSpaceBelow(5),
                ])));
  }//end _buildBody

//-------------------------------------------------------------------//
  _dialogRemoveSpecies(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text('Remove'),
              content: new Text(widget.population.name),
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
                      _removeSpecies();
                    }),
              ]);
        });
  }//end _dialogRemoveSpecies

  //-------------------------------------------------------------------//
  _dialogChangeSpecies(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text('Change Species Name'),
              content: new Text(widget.population.name),
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
                    child: new Text('CHANGE'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _changeSpecies();
                      //_removeSpecies();
                    }),
              ]);
        });
  }//end _dialogRemoveSpecies


  //-------------------------------------------------------------------//
  _dialogLeavePage(BuildContext context) {
    
    if(widget.population.dataOK == false){showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text('Form'),
              content: new Text('Mark as complete?'),
              actions: <Widget>[
                new FlatButton(
                  textColor: Colors.black,
                  child: new Text('Later'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                    color: Colors.black,
                    textColor: Colors.white,
                    child: new Text('Complete'),
                    onPressed: () {
                      //widget.species.set('dataOK', true);
                      widget.population.sdataOK = true;
                      _save();
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      setState(() {
                        
                      });
                      //_removeSpecies();
                    }),
              ]);
        });}else{
           Navigator.pop(context);
        }
    
  }//end _dialogRemoveSpecies

 

//-------------------------------------------------------------------//
  _removeSpecies() {
//loop through and check name the one with the same name
    for (int position = 0; position < widget.populationList.length; position++) {
      if (widget.populationList[position].name == widget.population.name) {
        print('position: ' + position.toString());
        Navigator.pop(context);
        setState(() {
          //remove the site
          widget.populationList.removeAt(position);
          _save();
          //db.updateSpeciesList(widget.speciesList, widget.site.id);
          print('Site Details says: removed species');
        });
      }
    }
  } //end _removeSpecies

//-------------------------------------------------------------------//
  _buttonCollections() {
    return new SizedBox(
      height: 45.0,
      child: ButtonTheme(
        child: FlatButton(
          child: Text('COLLECTIONS'),
          onPressed: () {
             _dialogLeavePage(context) ;
           // Navigator.of(context).pop();
          },
          color: uiGetPrimaryColor(),
          textColor: Colors.white, //uiGetPrimaryColorDark(),
        ),
      ),
    );
  }//end buttonCollections

  //-------------------------------------------------------------------//
  //here
  _buttonChangeName() {
    return new SizedBox(
      //height: 90.0,
      child: ButtonTheme(
        child: FlatButton(
          child: uiTitleSpecies(widget.population.name),
          //Text(widget.species.name),
          onPressed: () {
            _dialogChangeSpecies(context);
          },
          color: Colors.white,
          textColor: Colors.black, //uiGetPrimaryColorDark(),
        ),
      ),
    );
  }//end buttonCollections

//-------------------------------------------------------------------//
  _backArrow(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios), 
      onPressed: () {
         _dialogLeavePage(context) ;  
      },
    );
  }//end


 //-------------------------------------------------------------------//
  void _changeSpecies() async {
    Population species = widget.population;
    String speciesUuid = uuid.v1();

    //go to the species selector page
    //It will return an object for the one from the list
    //or a string with the name if u added a new name

    var speciesObject = await Navigator.push(
        context,

        //need to get the speciesObject to get all the name variables
        new MaterialPageRoute(
            builder: (context) => new Selector(type: 'Species', edit: false)));

    if (speciesObject is bool) {
    //do nothing pressed back arrow
    } else if (speciesObject is AvailableSpecies) {
      species.sname = speciesObject.name;
      species.sNameGenus = speciesObject.nameGenus;
      species.sNameSpecies = speciesObject.nameSpecies;
      species.sNameRank = speciesObject.nameRank;
      species.sNameRankName = speciesObject.nameRankName;
      species.sid = speciesObject.id;
      species.set('notOnList', false);
      if (species.sid.isEmpty) {
        species.sid = speciesUuid; //keep the original species id if not new?
      }

//It should be a new name as a string which will just go into the name variable
    } else {
      species.sname = speciesObject;
      print(widget.population.sname);
      species.sNameGenus = '';
      species.sNameSpecies = '';
      species.sNameRank = '';
      species.sNameRankName = '';
      species.set('notOnList', true);
      species.sid = speciesUuid;
    }

    db.saveObjectList('population', widget.populationList, widget.site.id);
    }//end Change species





  }//end class
   



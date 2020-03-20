
//TODO_ counter to lock in number on envelope??? joel yes marlien no
import 'package:flutter/material.dart';
//import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:uuid/uuid.dart';

//Classes
import 'package:restoreandrenew/classes/site_class.dart';
import 'package:restoreandrenew/classes/population_class.dart';
import 'package:restoreandrenew/classes/individual_class.dart';
import 'package:restoreandrenew/classes/species_available_class.dart';
import 'package:restoreandrenew/classes/collection_class.dart';

//Helpers
import 'package:restoreandrenew/helpers/ui_helper.dart';
import 'package:restoreandrenew/helpers/database_local_helper.dart';

//Pages
import 'package:restoreandrenew/pages/population_detail_page.dart';
import 'package:restoreandrenew/pages/selector_page.dart';
import 'package:restoreandrenew/pages/collection_detail_page.dart';

final double buttonWidth = 35.0;
final double buttonHeight = 55.0;
final double theElevation = 2.0;
double smallIconHeight = 34;
double smallIconWidth = 25;
double plusIconWidth = 54;

DatabaseHelper db = new DatabaseHelper();

//-------------------------------------------------------------------//
class PopulationList extends StatefulWidget {
  final Site site; // hand in the selected site object //maybe just the id???

  PopulationList({Key key, @required this.site}) : super(key: key);

  @override
  _PopulationListState createState() {
    return _PopulationListState();
  }
}

//-------------------------------------------------------------------//
class _PopulationListState extends State<PopulationList> {
//-------------------------------------------------------------------//
  List<Population> populationList = new List();
  var uuid = new Uuid(); //library that makes uuids

  @override
  void initState() {
    _initPopulationList();
    widget.site.sDataOK =
        _isDataOK(); //update when coming back from population form
    super.initState();
    //BackButtonInterceptor.add(myInterceptor, zIndex:2, name:"Population");
    
  }


  //-------------------------------------------------------------------//
  @override
  void dispose() {
    //WillPopScope(BackButtonInterceptor.removeByName("Population");
    super.dispose();
  }


//-------------------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(children: [
      _buildHeading(),
      _buildBody(),
      _headerIcons(context),
    ]));
  }

/*
//-------------------------------------------------------------------//
bool myInterceptor(bool stopDefaultButtonEvent)  {
   print("1 Population says: press OS BACK BUTTON!"); // Do some stuff.
    _backArrowPressed();
   return false; //don't go back
}
*/

//-------------------------------------------------------------------//
  _buildHeading() {
    double screenWidth = MediaQuery.of(context).size.width;
    double width = MediaQuery.of(context).size.width;
    double headerHeight = uiGetHeaderHeight();
    return Material(
        child: Container(
            child: Column(children: [
      Stack(children: [
        headerImage(headerHeight, screenWidth),
        Positioned(
          left: 20.0,
          top: 90.0,
          child: uiSubHeading(widget.site.description, width),
        ),
      ])
    ])));
  } //end _buildHeading

  //-------------------------------------------------------------------//
  _buildBody() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double statusbarHeight = MediaQuery.of(context).padding.top;
    double theAppBarHeight = uiGetHeaderHeight() - statusbarHeight;
    return 
    
    WillPopScope(//this stops the Android OS back button
    onWillPop: () async => false,
    child:   Scaffold(
        floatingActionButton: _floatingButton(),
        resizeToAvoidBottomPadding: true,
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(theAppBarHeight),
            child: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: Image.asset('assets/appBarTitle.png', width: 90.0),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )),
        body: _buildBodyList(screenHeight, theAppBarHeight, screenWidth))
    );
  }

  //-------------------------------------------------------------------//
  _buildBodyList(double screenHeight, double headerHeight, double screenWidth) {
    return Container(
        color: Colors.white,
        child: Builder(builder: (BuildContext internalContext) {
          return _buildPopulationlist(
              internalContext, screenHeight, screenWidth);
        }));
  } //end buildBodyList

//-------------------------------------------------------------------//
  Widget _buildPopulationlist(
      BuildContext context, double screenHeight, double screenWidth) {
    double listHeight = screenHeight - uiGetHeaderHeight();
    return Container(
        //color: Colors.blue,
        height: listHeight,
        width: screenWidth,
        child: ListView.builder(
            itemCount: populationList.length,
            itemBuilder: (context, position) {
              return _buildPopulationListItem(
                context,
                position,
              );
            }));
  }

//-------------------------------------------------------------------//
  Widget _buildPopulationListItem(BuildContext context, int position) {
    double screenWidth = MediaQuery.of(context).size.width;

    final site = widget.site;

//THE ROW FOR THE Individuals, sample, voucher etc
    final individualsSection = Container(
      child: Expanded(
        child: Container(
          //color: Colors.red,
          height: 74.0,
          child: _buildIndividualList(context, position),
        ),
      ),
    );

//SECTION FOR A POPULATION
    return new Card(
      elevation: 0.0,
      margin: const EdgeInsets.only(bottom: 0.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Row(children: <Widget>[
                  new Expanded(
                      child: Container(
                          //color: Colors.red,
                          height: 35,

                          //Population Tile
                          child: ListTile(
                              title: Column(children: <Widget>[
                                Row(children: [
                                  //Population name heading
                                  Container(
                                      width: screenWidth - 25 - 35,
                                      child: uiGetPlantNameStyleSmall(
                                          ' ' + populationList[position].name,
                                          1)),

                                  Container(
                                    width: 25,
                                    child: uiErrorIcon(
                                        populationList[position].sdataOK,
                                        Colors.red),
                                  ),
                                ])
                              ]),
                              onTap: () {
                                _openPopulationDetailPage(site, position);
                              })))
                ]),
                Row(children: [
                  //Plus icon
                  Container(
                      //color: Colors.orange,
                      width: plusIconWidth,
                      child: IconButton(
                          icon: Icon(Icons.add),
                          color: uiiconImageColor(),
                          onPressed: () {
                            _dialogAddCollection(
                                context, populationList[position]);
                          })),

                  Container(
                      width: screenWidth - plusIconWidth,
                      child: Row(children: [
                        individualsSection,
                      ])),
                ]),

                  //Divider
                //Here
                Row(children: [
                  Container(
                    width: plusIconWidth,
                    height: 30.0
                  ),

                  
                  Text(_buildIndividualsStatusText(position),
                      style: TextStyle(
                        //fontFamily: 'Helvetica',
                        fontSize: 12,
                        //fontWeight: FontWeight.w100,
                        color: Colors.black,
                        //Colors.black87,
                      )),
                

                ]),

                Row(children: [Expanded(flex: 1, child: Divider())]),
              ],
            ),
          ),
        ],
      ),
    );
  } //end

//-------------------------------------------------------------------//
  _buildPopulationStatusText() {
    String speciesText = '';
    String collectionText = '';
    String theStatus = '';
    int collectionCount = _countCollections();

    if (populationList.length > 0) {
      speciesText = populationList.length.toString() + ' Species';
    }

    if (collectionCount == 1) {
      collectionText = '1 Collection';
    } else if (collectionCount > 1) {
      collectionText = collectionCount.toString() + ' Collections';
    }

    if (speciesText.isNotEmpty && collectionText.isNotEmpty) {
      theStatus = speciesText + ', ' + collectionText;
    } else {
      theStatus = speciesText + collectionText;
    }

    return theStatus;
  }

//-------------------------------------------------------------------//
  _buildIndividualsStatusText(int position) {
    List<Individual> individualList = populationList[position].individualsList;

    int countSample = 0;
    int countVoucher = 0;
    int countSeed = 0;

    //loop through the individuals and count each type 
    for (Individual individual in individualList) {
      for(Collection collection in individual.collectionList){
          print('The collection type: ' + collection.type);
          if(collection.type == typeSample){
            countSample += 1;
          } else if (collection.type == typeVoucher){
            countVoucher += 1;
          } 
          else if (collection.type == typeSeed){
            countSeed += 1;
          } 
      }
    }

    String sampleText = '';
    String voucherText = '';
    String seedText = '';
    String statusText = '';
    String commaOne = '';
    String commaTwo = '';

    if (countSample == 1) {
      sampleText = '1 ' + typeSample;
    } else if (countSample > 1) {
      sampleText = countSample.toString() + ' ' + typeSample + 's';
    }

    if (countVoucher == 1) {
      voucherText = "1 " + typeVoucher;
    } else if (countVoucher > 1) {
      voucherText = countVoucher.toString() + ' ' + typeVoucher + 's';
    }

    if (countSeed > 0) {
    seedText = countSeed.toString() + ' ' + typeSeed;
    }

    if(sampleText != '' && (voucherText != '' || seedText != '')){
      commaOne = ', ';

    }

    if(voucherText != '' && seedText != ''){
      commaTwo = ', ';
    }

    statusText = sampleText + commaOne + voucherText + commaTwo + seedText;
    
    return statusText;

  } //end



//-------------------------------------------------------------------//
  _initPopulationList() async {
    populationList = await db.getPopulationList(widget.site.id);
    populationList.sort((a, b) => a.name.compareTo(b.name));
    setState(() {});
  }

//-------------------------------------------------------------------//
  void _addSpecies() async {
    Site site = widget.site;
    String speciesUuid = uuid.v1();

    //go to the species selector page
    //It will return an object for the one from the list
    //or a string with the name if u added a new name

    var speciesObject = await Navigator.push(
        context,

        //need to get the speciesObject to get all the name variables
        new MaterialPageRoute(
            builder: (context) => new Selector(type: 'Species', edit: false)));

    String speciesName = '';
    String speciesGenus;
    String speciesSpecies;
    String speciesRank;
    String speciesRankName;
    String speciesID;
    bool notOnList;
    bool dup = false;

    if (speciesObject is bool) {
//do nothing pressed back arrow
    } else if (speciesObject is AvailableSpecies) {
      speciesName = speciesObject.name;
      speciesGenus = speciesObject.nameGenus;
      speciesSpecies = speciesObject.nameSpecies;
      speciesRank = speciesObject.nameRank;
      speciesRankName = speciesObject.nameRankName;

      speciesID = speciesObject.id;
      if (speciesID.isEmpty) {
        speciesID = speciesUuid;
      }

//It should be a new name as a string
    } else {
      speciesName = speciesObject;
      speciesGenus = '';
      speciesSpecies = '';
      speciesRank = '';
      speciesRankName = '';
      notOnList = true;
      speciesID = speciesUuid;
    }

    if (speciesName != '') {
      for (final aSpecies in populationList) {
        if (aSpecies.name == speciesName) {
          dup = true;
        }
      }
      //it's new so add it to the list of populations
      if (dup == false) {
        //make a new population from the name
        Population population = Population.fromFkSite(
            site.id,
            speciesID,
            speciesName,
            speciesGenus,
            speciesSpecies,
            speciesRank,
            speciesRankName);

        if (notOnList == true) {
          population.set('notOnList', true);
        }

        populationList.add(population);
        populationList.sort((a, b) => a.name.compareTo(b.name));
      } else {
        //('No species selected!');
      }
    }
  } //end add species

//-------------------------------------------------------------------//
  _save() {
    print('Save says: ' + populationList[0].sNameGenus);
    db.saveObjectList('population', populationList, widget.site.id);
  }

//-------------------------------------------------------------------//
  _openPopulationDetailPage(Site site, int populationPosition) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PopulationDetail(
              site: site,
              population: populationList[populationPosition],
              populationList: populationList)),
    );
  } //end

//-------------------------------------------------------------------//
  _openCollectionPage(Population population, int individualsPosition) {
    List<Collection> collectionList =
        population.individualsList[individualsPosition].collectionList;

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CollectionDetail(
                siteList: null, //only needed from the sitelist screeen for deleting a sighting
                site: widget.site,
                populationList: populationList,
                population: population,
                individualsPosition: individualsPosition,
                collectionList: collectionList,
              )),
    );
  } //end

//-------------------------------------------------------------------//
  void _dialogAddCollection(BuildContext context, Population population) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //NEW SAMPLE
                new ListTile(
                  leading: Container(
                    height: smallIconHeight,
                    width: smallIconWidth,
                    color: forTypeColor(typeSample),
                  ),
                  title: new Text(typeSample,
                      style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addCollectionToNewIndividual(
                        context, population, typeSample);
                  },
                ),

                //NEW VOUCHER
                new ListTile(
                  leading: Container(
                    height: smallIconHeight,
                    width: smallIconWidth,
                    color: forTypeColor(typeVoucher),//Colors.grey.withOpacity(.2),
                  ),
                  title: new Text(typeVoucher,
                      style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addCollectionToNewIndividual(
                        context, population, typeVoucher);
                  },
                ),

                //NEW SEED
                /*
                new ListTile(
                  leading: Container(
                    height: smallIconHeight,
                    width: smallIconWidth,
                    color: forTypeColor(typeSeed),
                  ),
                  title:
                      new Text(typeSeed, style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addCollectionToNewIndividual(
                        context, population, typeSeed);
                  },
                ),
*/

                //NEW Note
                new ListTile(
                  leading: uiAddPageIcon(typeNote),
                  title:
                      new Text(typeNote, style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addCollectionToNewIndividual(
                        context, population, typeNote);
                  },
                ),

                //NEW Sighting
                new ListTile(
                  leading: uiAddPageIcon(typeSighted),
                  title: new Text(typeSighted,
                      style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addCollectionToNewIndividual(
                        context, population, typeSighted);
                  },
                ),

//NEW Not Sighted
                new ListTile(
                  leading: uiAddPageIcon(typeNotSighted),
                  title: new Text(typeNotSighted,
                      style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addCollectionToNewIndividual(
                        context, population, typeNotSighted);
                  },
                ),
              ],
            ),
          );
        });
  } //end _dialogAdd



//-------------------------------------------------------------------//
  _addCollectionToNewIndividual(
      BuildContext context, Population population, String type) {
    String aUuid = uuid.v1(); //create an id for the new record
    Collection collection = Collection.fromID(aUuid, type);


    int individualsPosition = _createNewIndividual(population, collection);

    if (type == typeSighted || type == typeNotSighted) {
      //this means it won't use the site gps ever.
      collection.set("gpsType", 'single');
      collection.set("collectorsID", 'NA');
    }

    if (type == typeNote) {
      collection.set("gpsType", 'None');
      collection.set("collectorsID", 'NA');
      population.individualsList[individualsPosition].set('lat', 0.0);
      population.individualsList[individualsPosition].set('lon', 0.0);
      population.individualsList[individualsPosition].set('acc', 0);
      population.individualsList[individualsPosition].set('alt', 0);
      population.individualsList[individualsPosition].set('gpsType', 'none');
    }

    _openCollectionPage(population, individualsPosition);
  } //end _addCollection

//-------------------------------------------------------------------//
//buttons for the individuals collections
  GestureDetector _collectionListButton(Population population,
      List<Individual> individualsList, int individualsPosition) {
    return GestureDetector(
      onTap: () => _openCollectionPage(population, individualsPosition),
      child: Stack(
        overflow: Overflow.visible,
        children: <Widget>[
          Container(
            height: buttonHeight, //can this grow???
            width: buttonWidth + 12.0,
          ),
          ...buildIcons(individualsList, individualsPosition)
        ],
      ),
    );
  } //end collectionListButton

//-------------------------------------------------------------------//

//-------------------------------------------------------------------//
  buildIcons(List<Individual> individualsList, int individualsPosition) {
    Individual individual = individualsList[individualsPosition];
    List<Collection> collectionList = new List();
    collectionList = individual.collectionList;
    double theTop = 0;
    List<Widget> list = new List<Widget>();
    var newCard;

    for (var collection in collectionList) {
      newCard = Positioned(
          left: 0.0,
          top: theTop,
          child: Card(
              elevation: theElevation,
              child: Container(
                  alignment: Alignment(0.0, 0.0),
                  decoration: BoxDecoration(
                      border: new Border.all(
                          color: Colors.black,
                          width: 0.08,
                          style: BorderStyle.solid),
                      color: forTypeColorForPopulationListIcons(collection.type),
                      borderRadius: BorderRadius.all(Radius.circular(0.0))),
                  height: buttonHeight * 0.95,
                  width: buttonWidth * 0.95,

                  child: (collection.type == typeNote ||
                          collection.type == typeSighted ||
                          collection.type == typeNotSighted)

                      ? uiButtonIcon(collection.type)
                      : Text(
                         // (individualsPosition + 1).toString(),
                          '', //remove the counter number from the icon
                          style: TextStyle(
                            color: forTypeFontColor(collection.type),
                          ),
                        )


                        )));

      theTop = theTop + 5;
      list.add(newCard);
    }
    return list;
  }



//-------------------------------------------------------------------//
  //this across the screen, each individual has a stack of collections
  Widget _buildIndividualList(BuildContext context, int populationPosition) {
    Population population = populationList[populationPosition];
    List<Individual> individualsList = population.individualsList;

    return Container(
        //color: Colors.black,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(top: 0.0, bottom: 0.0, right: 4.0),
            itemCount: individualsList.length,
            itemBuilder: (context, int index) {
              return _collectionButton(
                  context,
                  population,
                  //populationPosition,
                  individualsList,
                  index++);
            }));
  } //end buildCollectionBody

//-------------------------------------------------------------------//
//decide which button style to show
  Widget _collectionButton(
      BuildContext context,
      Population population,
      //int populationPosition,
      List<Individual> individualsList,
      int individualsPosition) {
    Widget child;
    child =
        _collectionListButton(population, individualsList, individualsPosition);
    return new Container(child: child);
  } //end _collectionButton

//-------------------------------------------------------------------//
  int _createNewIndividual(Population population, Collection collection) {
    String aUuid = uuid.v1(); //create an id for the new record
    Individual individual = Individual.fromID(aUuid, collection);
    int length = population.individualsList.length;

    if (length == 0) {
      population.sdataOK = false;
      widget.site.sDataOK = false;
    }

    setState(() {
      population.individualsList.add(individual);
    });

    _save(); //2
    return length;
  }





//-------------------------------------------------------------------//
//-------------------------------------------------------------------//
//-------------------------------------------------------------------//
//Header Section---------------------------------------------------------//

//-------------------------------------------------------------------//
  _floatingButton() {
    return Container(
        child: FloatingActionButton.extended(
      shape: RoundedRectangleBorder(borderRadius: uiGetRadius()),
      backgroundColor: uiGetGreenColor(),
      elevation: 2.0,
      onPressed: () {
        _addSpecies();
      },
      label: Text(
        "+ SPECIES",
        style: TextStyle(
          fontFamily: theFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ));
  } //end floating button

  //-------------------------------------------------------------------//
  _headerIcons(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Material(
        color: Colors.transparent,
        child: Container(
            height: uiGetHeaderHeight(),
            width: screenWidth,
            child: Column(children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _backArrow(),
              ]),
              _buildStatusBar(screenWidth),
            ])));
  } //end _headerIcons

  //-------------------------------------------------------------------//
  _buildStatusBar(double screenWidth) {
    return Padding(
        padding: const EdgeInsets.only(top: 106.0, left: 20, right: 0),
        child: Row(children: <Widget>[
          Container(
              width: screenWidth - 25 - 38,
              child: Text(_buildPopulationStatusText(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w100,
                    color: Colors.white,
                  ))),
          Container(
            width: 25,
            child: uiErrorIcon(_isDataOK(), Colors.white),
          ),
        ]));
  }

//-------------------------------------------------------------------//
  _backArrow() {
    return Material(
        color: Colors.transparent,
        child: Container(
            color: Colors.transparent, //Colors.transparent,
            padding: const EdgeInsets.only(top: 25),
            child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                color: Colors.white,
                onPressed: () => _backArrowPressed())));
  } //end _backArrow

//-------------------------------------------------------------------//
  _backArrowPressed() {
    
    widget.site.sSpeciesCount = populationList.length;
    widget.site.sCollectionCount = _countCollections();
    bool isDataOK = _isDataOK();
    widget.site.sDataOK = isDataOK;

    if (isDataOK == false) {
      _dialogIncompleteData(context);
    } else {
      print('here');
      Navigator.pop(context);
    }
  }

  //-------------------------------------------------------------------//
  _dialogIncompleteData(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text('Incomplete'),
              content: new Text('Leave page with species forms incomplete?'),
              actions: <Widget>[
                new FlatButton(
                    color: Colors.black,
                    textColor: Colors.white,
                    child: new Text('Leave Incomplete'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }),
              ]);
        });
  } //end _dialogIncompleteData

//-------------------------------------------------------------------//
  _countCollections() {
    num sum = 0;
    for (Population population in populationList) {
      for (Individual individual in population.individualsList) {
        sum += individual.collectionList.length;
      }
    }
    return sum;
  } //end countCollections

/*
  //-------------------------------------------------------------------//
  _countIndividuals() {
    num sum = 0;
    for (Population population in populationList) {
      sum += population.individualsList.length;
    }
    return sum;
  } //end countCollections
*/

//-------------------------------------------------------------------//
  bool _isDataOK() {
    bool result = true;
    for (Population population in populationList) {
      if (population.dataOK == false) {
        result = false;
      }
    }

    if (_countCollections() == 0) {
      result = false;
    }

    return result;
  } //end countPopulationsNotComplete

} //end class

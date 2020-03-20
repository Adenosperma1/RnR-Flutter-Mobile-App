import 'dart:io';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart'; //for platform error & blacklist
import 'package:barcode_scan/barcode_scan.dart';
import 'package:uuid/uuid.dart';

//Helpers
import 'package:restoreandrenew/helpers/database_local_helper.dart';
import 'package:restoreandrenew/helpers/ui_helper.dart';
import 'package:restoreandrenew/helpers/gps2_helper.dart';

//Classes
import 'package:restoreandrenew/classes/site_class.dart';
import 'package:restoreandrenew/classes/population_class.dart';
import 'package:restoreandrenew/classes/individual_class.dart';
import 'package:restoreandrenew/classes/collection_class.dart';

//-------------------------------------------------------------------//
class CollectionDetail extends StatefulWidget {
  // hand in the objects from the previous page
  final List<Site>
      siteList; //need for deleting a sighting created from the home screen
  final Site site;
  final List<Population> populationList; //need for the save
  final Population population; //used for population name
  final int individualsPosition;
  final List<Collection> collectionList;

  CollectionDetail({
    Key key,
    @required this.siteList,
    this.site,
    this.populationList,
    this.population,
    this.individualsPosition,
    this.collectionList,
  }) : super(key: key);

  @override
  _CollectionDetailState createState() {
    return _CollectionDetailState();
  }
}

//-------------------------------------------------------------------//
class _CollectionDetailState extends State<CollectionDetail>
    with SingleTickerProviderStateMixin {
  //can't remember why I needed this???
//-------------------------------------------------------------------//

//-------------------------------------------------------------------//
//Controllers for normal fields
  final TextEditingController collectorsIDController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  FocusNode _focusNode;

  var uuid = new Uuid(); //library that makes uuids
  DatabaseHelper db = new DatabaseHelper();

  bool loading = false;
  String date;
  String typeGPS = 'gps';
  String typeBarcode = 'barcode';
  String typeCollectorsID = 'collectorsID';

  String gpsType; //can be one of the below
  String gpsTypeSingle = 'single';
  String gpsTypeSite = 'site';
  String gpsTypeNone = 'none';

  final double buttonWidth = 35.0;
  final double buttonHeight = 55.0;
  final double theElevation = 2.0;

  double smallIconHeight = 34;
  double smallIconWidth = 25;

  double collectionWidth = 300.0;
  double collectionHeight = 500.0;

  Site site;
  Individual individual;
  List<Collection> collectionList;

//These are reset if you change the current collection
  Collection collection;
  double lat;
  double lon;
  int acc;
  int alt;
  String uiTime;
  String uniqueType; //barcode or collectors id
  String barcode; //sample's barcode
  String collectorsID; //sample's collectors id
  AppBar appBar;

  //-------------------------------------------------------------------//
  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    site = widget.site;
    collectionList = widget.collectionList;
    individual = widget.population.individualsList[widget.individualsPosition];
    _setCollectionDetails();
     
    //return
   
  }

//-------------------------------------------------------------------//
  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
  }

//-------------------------------------------------------------------//
  _buildBackground(List<Collection> collectionList) {
    int counter = 0;
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = appBar.preferredSize.height;
    double theMainAreaHeight = (screenHeight - appBarHeight);
    double theTopForLastCollection = (theMainAreaHeight - collectionHeight) / 3;
    double theTop;
    double offset;
    bool last = false;
    int length = collectionList.length;

    List<Widget> list = new List<Widget>();
    var newCollection;

    for (var collection in collectionList) {
      _setCollectionDetails();
      if (counter == length - 1) {
        last = true;
      }

      offset = (length - counter) * 10.0;
      theTop = theTopForLastCollection - offset;

      newCollection = _collectionImageBackground(collection.type, theTop, last);

      list.add(newCollection);
      counter = counter + 1;
    }
    return list;
  } //end buildstack

//-------------------------------------------------------------------//
  _setCollectionDetails() {
    int last = _getLastCollection();

    setState(() {
      collection = collectionList[last];

      barcode = collection.barcode;
      collectorsID = collection.collectorsID;
      //set the intial feild value
      collectorsIDController.text = collectorsID;
      noteController.text = collection.note;

      //from the parent object
      lat = individual.lat;
      lon = individual.lon;
      acc = individual.acc;
      alt = individual.alt;
      gpsType = individual.gpsType;

      //show barcode or unique id
      uniqueType = typeBarcode;
      if (collectorsID != null) {
        if (collectorsID.isNotEmpty) {
          uniqueType = typeCollectorsID;
        }
      }

      uiTime = collection.uiTime;
    });
  }

//-------------------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    appBar = _buildAppBar(context);
    return 
    WillPopScope( //this stops the Android OS back button
    onWillPop: () async => false,
    child: 
    Scaffold(appBar: appBar, body: _buildBody(context)));
  } //end build

//-------------------------------------------------------------------//
  Widget _buildAppBar(
    BuildContext context,
  ) {
    return AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
          
        ),
        centerTitle: false,
        elevation: 0.0,
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        leading: _backArrow(context, collection.type),

        // action button
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.delete_outline,
              ),
              onPressed: () {
                _dialogRemoveCollection(context);
              })
        ]);
  } //end _buildAppBar

//-------------------------------------------------------------------//
  _backArrow(BuildContext context, String type) {
    return IconButton(
        icon: Icon(Icons.arrow_back_ios),
        onPressed: () {
          _validate("backArrow");
        });
  }

  //-------------------------------------------------------------------//
//check if you should add..
  _validate(String navType) {
    bool hasGps = _validateGPS(context);
    bool hasUID = _validateUniqueID(context);
    if (hasGps == true && hasUID == true) {
      if (navType == "backArrow") {
        Navigator.pop(context);
      } else if (navType == "addButton") {
        _dialogAddCollection(context, widget.population);
      } else if (navType == "changeOrder") {
        _changeOrder();
      }
    } else {
      _dialogMissingDetails(context, hasGps, hasUID);
    }
  }

//-------------------------------------------------------------------//
  _validateUniqueID(BuildContext context) {
    bool hasUI = true;
    if (barcode.isEmpty && collectorsID.isEmpty) {
      hasUI = false;
    }
    return hasUI;
  } //end _validateUniqueID

  //-------------------------------------------------------------------//
  _validateGPS(BuildContext context) {
    bool hasGPS = false;
    if (lat != 0) {
      hasGPS = true;
    } else if (gpsType.isNotEmpty) {
      //this is because the site gps is saved at the site level or it could be set to none
      hasGPS = true;
    }
    return hasGPS;
  } //end validateGPS

//-------------------------------------------------------------------//
  Widget _buildBody(BuildContext context) {
    var stack = IndexedStack(
      children: <Widget>[
        Stack(overflow: Overflow.visible, children: <Widget>[
          ..._buildBackground(collectionList),
        ])
      ],
    );

    return stack;
  } // end _buildBody

//-------------------------------------------------------------------//
  _collectionImageBackground(String type, double theTop, bool last) {
    double screenWidth = MediaQuery.of(context).size.width;
    double left = (screenWidth - collectionWidth) / 2;

    return Positioned(
        left: left,
        top: theTop,
        child: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Stack(overflow: Overflow.visible, children: <Widget>[
                Container(
                    width: collectionWidth,
                    height: collectionHeight,
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.0)),
                        color: forTypeColor(type),
                        elevation: 8.0,
                        child: Padding(
                            padding: EdgeInsets.only(top: 40.0),
                            child: Column(
                              children: _buildCollectionContent(type),
                            )))),
                (last == true) ? _showAddIcon(type) : Container(),
                (last == true) ? _showChangeOrderIcon(type) : Container(),
              ])
            ])
            //)
            ));
  } //end sampleSample

//-------------------------------------------------------------------//
  _sectionTop(String type) {
    bool showIndividual = true;
    double height = 200.0;
    double width = 280.0;

    if (type == typeSighted || type == typeNotSighted) {
      height = 110;
      showIndividual = false;
    } else if (type == typeNote) {
      height = 140.0;
      if (collectionList.length == 1) {
        showIndividual = false;
      }
    }

    Widget individualText = Text(
      'Individual ' + (widget.individualsPosition + 1).toString(),
      style: TextStyle(color: forTypeFontColor(type)),
    );

    return Row(
        //crossAxisAlignment: CrossAxisAlignment.start, //align top to bottom
        mainAxisAlignment: MainAxisAlignment.center, //align to left to right?
        children: [
          Container(
              //color: Colors.red,
              padding: new EdgeInsets.only(left: 10.0, right: 10),
              height: height,
              width: width,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    newLine(),
                    Text(
                      type,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: forTypeFontColor(type),
                          fontSize: 18),
                    ),
                    newLine(),
                    (showIndividual == true) ? individualText : Container(),
                    (showIndividual == true) ? newLine() : Container(),
                    Text(
                      widget.population.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: forTypeFontColor(type)),
                    ),
                    newLine(),
                    Text(site.description == 'Flag' ? '' : site.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: forTypeFontColor(type))),
                  ]))
        ]);
  } //end

//-------------------------------------------------------------------//
  _buildCollectionContent(String type) {
    if (type == typeNote) {
      return <Widget>[
        _sectionTop(type),
        _sectionNoteArea(type),
      ];
    } else if (type == typeSighted || type == typeNotSighted) {
      return <Widget>[
        _sectionTop(type),
        _sectionGPS(type),
        _sectionNoteArea(type)
      ];
    } else {
      return <Widget>[
        _sectionTop(type),
        _sectionGPS(type),
        _sectionUniqueID(type),
      ];
    }
  } //end

  //-------------------------------------------------------------------//
  Row _sectionNoteArea(String type) {
    double height = 310.0;
    double width = 280.0;
    int maxlines = 11;

    if (type == typeSighted || type == typeNotSighted) {
      height = 220.0;
      maxlines = 7;
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.center, //align to left to right?
        crossAxisAlignment: CrossAxisAlignment.center, //align to left to right?
        children: [
          Stack(children: <Widget>[
            Container(
                padding: new EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
                //color: Colors.blue,
                height: height,
                width: width,
                child: Column(children: <Widget>[
                  _uiFieldMultiline(
                      collection, noteController, 'note', maxlines),
                ])),
          ])
        ]);
  }

  //-------------------------------------------------------------------//
//Override Build a field
  _uiFieldMultiline(var object, TextEditingController theController,
      String fieldName, int maxlines) {
    return TextField(
      focusNode: _focusNode,
      //decoration: new InputDecoration(),
      //keyboardType: TextInputType.multiline,
      maxLines: maxlines,
      autofocus:false ,
      textInputAction: TextInputAction.done,
      onChanged: (newValue) {
        object.set(fieldName, newValue);
        _save();
      },

      onEditingComplete: () {//print("edit");
            _focusNode.unfocus();},

      controller: theController,
      decoration: InputDecoration(
        //labelText: "Note...",
        fillColor: Colors.white,
        filled: true,
        contentPadding: fieldInset(),
        border: InputBorder.none,
        // OutlineInputBorder(borderRadius: new BorderRadius.circular(0.0))
      ),
      
    );
  } //end uiField

//-------------------------------------------------------------------//
  Row _sectionUniqueID(String type) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center, //align to left to right?
        crossAxisAlignment: CrossAxisAlignment.center, //align to left to right?
        children: [
          Stack(children: <Widget>[
            Container(
                //color: Colors.blue,
                height: 100.0,
                width: 280.0,
                child: Column(children: <Widget>[
                  _showDetailsUniqueID(type),
                ])),
            _buttonUpdateBarcode(type),
          ])
        ]);
  } // _sectionBarCode

//-------------------------------------------------------------------//
  _showAddIcon(String type) {
//hide if you have already collected one of each type for this individual

    if (collectionList.length > 2) {
      return Container();
    }

    if (type == typeNote && collectionList.length == 1) {
      return Container();
    }

    if (type == typeSighted || type == typeNotSighted) {
      return Container();
    }

    return Positioned(
        right: 5.0,
        top: 5.0,
        child: Container(
            height: buttonHeight,
            width: buttonWidth,
            child: GestureDetector(
              onTap: () {
                _validate("addButton");
                //_dialogAddCollection(context, widget.population);
              },
              child: Icon(Icons.add, color: forTypeFontColor(type)
                  //Colors.black
                  ), //uiiconImageColor()),
            )));
  } //end showAddIcon

  //end _okToAddCollection()

//-------------------------------------------------------------------//
  _showChangeOrderIcon(String type) {
//hide if you only have one collection
    if (collectionList.length == 1) {
      return Container();
    }
    return Positioned(
        left: 5.0,
        top: 5.0,
        child: Container(
            height: buttonHeight,
            width: buttonWidth,
            child: GestureDetector(
                onTap: () {
                  _validate('changeOrder');
                },
                child: Icon(
                  Icons.keyboard_arrow_up,
                  color: forTypeFontColor(type),
                ))));
  } //end

//-------------------------------------------------------------------//
  _changeOrder() {
    setState(() {
      Collection last = collectionList[_getLastCollection()];
      collectionList.insert(0, last);
      collectionList.removeLast();
    });
  }

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
                (_hideType(typeSample) == false)
                    ? new ListTile(
                        leading: Container(
                          height: smallIconHeight,
                          width: smallIconWidth,
                          color:
                              forTypeColor(typeSample), //uibuttonyellowColor(),
                        ),
                        title: new Text(typeSample,
                            style: TextStyle(color: Colors.black)),
                        onTap: () {
                          _addCollection(typeSample);
                        })
                    : Container(),

                //NEW VOUCHER
                (_hideType(typeVoucher) == false)
                    ? new ListTile(
                        leading: Container(
                          height: smallIconHeight,
                          width: smallIconWidth,
                          color: Colors.grey.withOpacity(.2),
                        ),
                        title: new Text(typeVoucher,
                            style: TextStyle(color: Colors.black)),
                        onTap: () {
                          _addCollection(typeVoucher);
                        })
                    : Container(),

                //NEW SEED
                /*
                (_hideType(typeSeed) == false)
                    ? new ListTile(
                        leading: Container(
                          height: smallIconHeight,
                          width: smallIconWidth,
                          color: forTypeColor(
                              typeSeed), //uiGetSeedPackColor(), //Colors.grey.withOpacity(.2),
                        ),
                        title: new Text(typeSeed,
                            style: TextStyle(color: Colors.black)),
                        onTap: () {
                          _addCollection(typeSeed);
                        })
                    : Container(),
*/

                //NEW Note
                (_hideType(typeNote) == false)
                    ? new ListTile(
                        leading: _addPageIcon(typeNote),
                        title: new Text(typeNote,
                            style: TextStyle(color: Colors.black)),
                        onTap: () {
                          _addCollection(typeNote);
                        })
                    : Container(),
              ],
            ),
          );
        });
  } //end _dialogAdd

  //-------------------------------------------------------------------//
  _addPageIcon(String theType) {
    return Container(
      decoration: BoxDecoration(
          border: new Border.all(
              color: Colors.grey, width: 0.8, style: BorderStyle.solid),
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(0.0))),
      height: smallIconHeight,
      width: smallIconWidth,
      child: Icon(
        forTypeIcon(theType),
        size: 20.0,
        color: forTypeColor(theType),
      ),
    );
  }

//-------------------------------------------------------------------//
  bool _hideType(String type) {
    bool hideType = false;

    List<Collection> filteredList =
        collectionList.where((i) => i.type == type).toList();

    if (filteredList.length > 0) {
      hideType = true;
    }

    return hideType;
  }

//-------------------------------------------------------------------//
  _addCollection(String type) {
    if (_hideType(type) == false) {
      Navigator.of(context).pop();
      _addCollectionToIndividual(context, widget.population, type);
    }
  } // end _onPressed

  //-------------------------------------------------------------------//
  _addCollectionToIndividual(
      BuildContext context, Population population, String type) {
    String aUuid = uuid.v1(); //create an id for the new collection
    Collection collection =
        Collection.fromID(aUuid, type); //new collection object

    if (type == typeNote) {
      collection.set("collectorsID", 'NA');
    }

    setState(() {
      collectionList.add(collection);
    });

    _save();
  } //end _addCollection

//Collection
//-------------------------------------------------------------------//
//-------------------------------------------------------------------//
//-------------------------------------------------------------------//

//-------------------------------------------------------------------//
  _removeCollection() {
    int collectionPosition = widget.collectionList.length - 1;
    setState(() {
      widget.collectionList.removeAt(collectionPosition);

      //remove orphaned individual

      if (widget.collectionList.length == 0) {
        //need to delete the individual record as well");
        widget.population.individualsList.removeAt(widget.individualsPosition);
        //_save();

        if (widget.collectionList.length == 0) {
          Navigator.pop(context);
        }
      }
      _save();

      _removeOrphanedSite();
    });
  } //end _removeCollection

  //-------------------------------------------------------------------//
  _removeOrphanedSite() async {
    if (widget.siteList != null) {
      //the user has come in from the site list page remove the site so it's not orphaned
      setState(() {
        widget.siteList.removeWhere((aSite) => aSite.id == site.id);
        _saveSite();
      });
    }
  } //end _removeSite

  //-------------------------------------------------------------------//
  _saveSite() async {
    print('Collection Detail says: saved Site');
    await db.saveObjectList('site', widget.siteList, '1');
  }

//Barcode
//-------------------------------------------------------------------//
//-------------------------------------------------------------------//
//-------------------------------------------------------------------//

//-------------------------------------------------------------------//
  _showDetailsUniqueID(String type) {
    //Barcode
    if (uniqueType == typeBarcode) {
      if (barcode == '') {
        return _buttonOutlined(typeBarcode, type); //show the button
      } else {
        return _detailsBarcode(type);
      }
      //Collectors ID
    } else if (uniqueType == typeCollectorsID) {
      if (collectorsID == '') {
        return _buttonOutlined(typeBarcode, type); //show the button
      } else {
        return _detailsCollectorsID(type); //show the collectors id
      }
      //Nothing
    } else {
      return Container(); //fix when the dialog shows
    }
  } //end showDetailsUniqueID

//-------------------------------------------------------------------//
  _detailsCollectorsID(type) {
    return Stack(children: <Widget>[
      Column(children: <Widget>[
        Container(
            //white box with the collectors ID in it
            color: Colors.white,
            width: 200.0,
            height: 80.0,
            margin: EdgeInsets.only(top: 20.0),
            child: Column(children: <Widget>[
              Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.center, //align top to bottom
                  mainAxisAlignment:
                      MainAxisAlignment.center, //align to left to right?
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 5.0, bottom: 4.0),
                      width: 170.0,
                      height: 40.0,
                      color: Colors.white,
                    )
                  ]),
              Row(
                //barcode number
                crossAxisAlignment:
                    CrossAxisAlignment.start, //align top to bottom
                mainAxisAlignment:
                    MainAxisAlignment.center, //align to left to right?
                children: <Widget>[Text(collectorsID)],
              )
            ]))
      ])
    ]);
  } //end  _detailsCollectorsID

//-------------------------------------------------------------------//
  _getBarcode() async {
    String theError;
    uniqueType = typeBarcode;

    try {
      String theBarcode = await BarcodeScanner.scan();

      setState(() {
        //wipe out the collectorsID
        collection.set('collectorsID', '');
        collectorsIDController.text = '';
        collectorsID = widget.collectionList[_getLastCollection()].collectorsID;

        this.barcode = theBarcode;
        collection.set('barcode', barcode);
      });

      _save();
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        theError = 'No camera permission!';
      } else {
        theError = 'Unknown error: $e';
      }
    } on FormatException {
      theError = 'Nothing captured.';
    } catch (e) {
      theError = 'Unknown error: $e';
    }
    if (theError != '') {}
  } //end _getBarcode

//-------------------------------------------------------------------//
  _setCollectorsID(String theCollectorsID) {
    collection.set('barcode', '');
    collection.set('collectorsID', theCollectorsID);
    _save();
    setState(() {
      collectorsID = widget.collectionList[_getLastCollection()].collectorsID;
    });
  } //end setCollectorsID

  //-------------------------------------------------------------------//
  _dialogGetCollectorsID(String type) {
    uniqueType = typeCollectorsID; //this is a global var

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              contentPadding: const EdgeInsets.all(16.0),
              content: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new TextField(
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () {
                        print("edit");
                        _focusNode.unfocus();
                      },
                      controller: collectorsIDController,
                      inputFormatters: [BlacklistingTextInputFormatter(RegExp(getBlackList())),],
                      
                      decoration: new InputDecoration(labelText: 'Unique ID'),
                    ),
                  )
                ],
              ),
              actions: <Widget>[
                new FlatButton(
                    color: Colors.black,
                    textColor: Colors.white,
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                      _setCollectorsID(collectorsIDController.text);
                    }),
              ]);
        });
  } //end dialog

//-------------------------------------------------------------------//
  _detailsBarcode(String type) {
    return Stack(children: [
      Column(
        children: [
          Container(
              //white box with the barcode in it
              color: Colors.white,
              width: 200.0,
              height: 80.0,
              margin: EdgeInsets.only(top: 20.0),
              child: Column(
                children: <Widget>[
                  Row(
                    //barcode image
                    crossAxisAlignment:
                        CrossAxisAlignment.center, //align top to bottom
                    mainAxisAlignment:
                        MainAxisAlignment.center, //align to left to right?
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.only(top: 5.0, bottom: 4.0),
                          width: 170.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                              image: new DecorationImage(
                            image: new ExactAssetImage('assets/barcode.png'),
                            fit: BoxFit.fill,
                          )))
                    ],
                  ),
                  Row(
                    //barcode number
                    crossAxisAlignment:
                        CrossAxisAlignment.start, //align top to bottom
                    mainAxisAlignment:
                        MainAxisAlignment.center, //align to left to right?
                    children: <Widget>[Text(barcode)],
                  )
                ],
              ))
        ],
      ),
    ]);
  } //end _detailsBarcode

//-------------------------------------------------------------------//
  _buttonUpdateBarcode(String type) {
    String theUniqueIDField;

    if (uniqueType == typeCollectorsID) {
      theUniqueIDField = collection.collectorsID;
    } else if (uniqueType == typeBarcode) {
      theUniqueIDField = collection.barcode;
    }

    if (theUniqueIDField != '') {
      return Positioned(
          left: 218.0,
          top: 30.0,
          child: FlatButton(
            child: Icon(
              Icons.autorenew,
              size: 20.0,
              color: forTypeFontColor(type),
              //Colors.black,
            ),
            onPressed: () {
              _dialogIDPicker(context, type);
            },
          ));
    }

    return Container();
  } //end _buttonUpdateBarcode

//GPS
//-------------------------------------------------------------------//
//-------------------------------------------------------------------//
//-------------------------------------------------------------------//

//-------------------------------------------------------------------//
  _setGPS(String gpsType) async {
    String _uiTime;
    DateTime theDateTime;
    LocationData location;


    

              //print("Time: " + theDateTime.toString());

    individual.set('gpsType', gpsType);
    _save();

    setState(() {
      loading = true;
    });

    
    if (gpsType == gpsTypeSingle) {
      location = await getGPS();
    } else if (gpsType == gpsTypeSite) {
      location = null;
    } else if (gpsType == gpsTypeNone) {
      location = null;
    }

    if (location != null) {
      individual.set('lat', location.latitude);
      individual.set('lat', location.latitude);
      individual.set('lon', location.longitude);
      individual.set('acc', location.accuracy.toInt());
      individual.set('alt', location.altitude.toInt());
      theDateTime = Platform.isIOS
              ? DateTime.fromMillisecondsSinceEpoch(location.time.toInt() * 1000)
              : DateTime.fromMillisecondsSinceEpoch(location.time.toInt());
      individual.set('timestamp', theDateTime);
      
      //print('Time: ' + theDateTime.toString());
      //DateTime theDateTime = individual.timestamp;
      String hour = theDateTime.hour.toString();
      String minute = theDateTime.minute.toString();
      String second = theDateTime.second.toString();

      if (minute.length == 1) {
        minute = '0' + minute;
      }
      if (second.length == 1) {
        second = '0' + second;
      }
      _uiTime = hour + ':' + minute + ':' + second;
      individual.set('uiTime', _uiTime);
    } else {
      individual.set('lat', 0.0);
      individual.set('lon', 0.0);
      individual.set('acc', 0);
      individual.set('alt', 0);
    }
    _save();

    setState(() {
      lat = individual.lat;
      lon = individual.lon;
      acc = individual.acc;
      alt = individual.alt;
      uiTime = _uiTime;
      loading = false;
    });
  } //end _getGPS

//-------------------------------------------------------------------//
  _save() {
    db.updatePopulationRow(widget.populationList, site.id);
  }

  //-------------------------------------------------------------------//
  _showDetailsGPS(String type) {
    if (gpsType.isEmpty) {
      return _buttonOutlined(typeGPS, type);
    } else {
      return _detailsGPS(gpsType, type);
    }
  } //end _showDetailsGPS

//-------------------------------------------------------------------//
  _detailsGPS(String gpsType, String type) {
    //show the gps details on the screen
    String theLat;
    String theLon;
    String theAcc;
    theLat = (uiRoundDouble(lat, 4)).toString();
    theLon = (uiRoundDouble(lon, 4)).toString();
    theAcc = acc.toString();
    String theTime = individual.uiTime;
    String theText = '';

    if (gpsType == gpsTypeSingle) {
      theText = 'Latitude: ' +
          theLat +
          '\n' +
          'Longitude: ' +
          theLon +
          '\n' +
          '  Acc: ' +
          theAcc +
          'm    Time: ' +
          theTime;
    } else if (gpsType == gpsTypeSite) {
      theText = 'GPS from site.';
    } else if (gpsType == gpsTypeNone) {
      theText = 'No GPS!';
    } else if (gpsType == 'loading') {
      theText = 'loading...';
    }

    return new SizedBox(
        height: 100.0,
        width: 280.0,
        child: new Stack(children: <Widget>[
          Center(
              child: Text(
            theText,
            style: TextStyle(height: 1.2, color: forTypeFontColor(type)),
            textAlign: TextAlign.center,
          )),
          _buttonUpdateGPS(type),
        ]));
  } //end _detailsGPS

//-------------------------------------------------------------------//
  _buttonUpdateGPS(String type) {
    return Positioned(
        left: 218.0,
        top: 23.0,
        child: FlatButton(
          child: Icon(
            Icons.autorenew,
            size: 20.0,
            color: forTypeFontColor(type),
            //Colors.black,
          ),
          onPressed: () {
            site.lat != 0 ? _dialogGPSPicker(context) : _setGPS(gpsTypeSingle);
          },
        ));
  } //end _buttonUpdateGPS

//-------------------------------------------------------------------//
  _sectionGPS(String type) {
    if (type == typeSighted || type == typeNotSighted) {
      if (individual.lat == 0) {
        loading = true;
        _setGPS(gpsTypeSingle);
      }
    }

    return Row(
        crossAxisAlignment: CrossAxisAlignment.center, //align top to bottom
        mainAxisAlignment: MainAxisAlignment.center, //align to left to right?
        children: [
          Container(
              //color: Colors.red,
              height: 110.0,
              width: 280.0,
              child: Column(children: <Widget>[
                loading ? forTypeUiSpinner(type) : _showDetailsGPS(type),
              ]))
        ]);
  } //end _sectionGPS()

//Dialogs
//-------------------------------------------------------------------//
//-------------------------------------------------------------------//
//-------------------------------------------------------------------//

//-------------------------------------------------------------------//
  _dialogGPSPicker(BuildContext context) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content:
                  new Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            //NEW GPS
            new ListTile(
              leading: new Icon(Icons.gps_fixed, color: Colors.black),
              title: new Text('New GPS', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.of(context).pop();
                _setGPS(gpsTypeSingle);
              },
            ),

            //Check if there's a Site GPS
            site.lat != 0
                ? ListTile(
                    leading: Icon(Icons.gps_not_fixed, color: Colors.black),
                    title:
                        Text('Site GPS', style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.of(context).pop();
                      _setGPS(gpsTypeSite);
                    })
                : Container(),

            //No GPS
            ListTile(
                leading: Icon(Icons.gps_off, color: Colors.black),
                title:
                    new Text('No GPS', style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.of(context).pop();
                  _setGPS(gpsTypeNone);
                })
          ]));
        });
  } //end _dialogGPSPicker

//-------------------------------------------------------------------//
  _dialogIDPicker(BuildContext context, String type) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content:
                  new Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            new ListTile(
                leading:
                    new Icon(Icons.center_focus_strong, color: Colors.black),
                title: new Text('Scan Barcode',
                    style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.of(context).pop();
                  _getBarcode();
                }),
            new ListTile(
                leading: new Icon(
                  Icons.keyboard,
                  color: Colors.black,
                ),
                title: new Text('Type an ID',
                    style: TextStyle(color: Colors.black)),
                onTap: () {
                  Navigator.of(context).pop();
                  _dialogGetCollectorsID(type);
                }),

                //THIS WAS USED FOR THE COLLECTION TYPE OF SEED WHICH ISN'T IMPLEMENTED
/*
            (type == typeSeed && _hideType(typeSample) == true)
                ? new ListTile(
                    leading: Container(
                      height: smallIconHeight,
                      width: smallIconWidth,
                      color: forTypeColor(typeSample),
                    ),
                    title: new Text(typeSample + "'s ID",
                        style: TextStyle(color: Colors.black)),
                    onTap: () {
                      _useIDFromAnotherCollection(typeSample);
                    })
                : Container(),
            (type == typeSeed && _hideType(typeVoucher) == true)
                ? new ListTile(
                    leading: Container(
                      height: smallIconHeight,
                      width: smallIconWidth,
                      color: forTypeColor(typeVoucher),
                    ),
                    title: new Text(typeVoucher + "'s ID",
                        style: TextStyle(color: Colors.black)),
                    onTap: () {
                      _useIDFromAnotherCollection(typeVoucher);
                    })


                : Container(),
                */
          ]
          )
          );
        });
  } //end _dialogScanOrKeyboa


/*
//-------------------------------------------------------------------//
  _useIDFromAnotherCollection(String type) {
    Navigator.of(context).pop();
//get the collectors id or barcode from the type?
//write it in allows the user to append it? easier to export
//write 'from sample' I don't need to figure it out, and it won't break if they change the original number
    _setCollectorsID('idfromtheothecollection');
    print("set this collections unique id to the id from: " + type);
  }
*/



//-------------------------------------------------------------------//
  _dialogRemoveCollection(BuildContext context) {
    String type = collection.type;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text('Remove'),
              content: new Text(
                  "This " + type + ' for ' + '\n ' + widget.population.name,
                  style: TextStyle(height: 1.2)),
              actions: <Widget>[
                new FlatButton(
                    textColor: Colors.black,
                    child: new Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                new FlatButton(
                    color: Colors.red,
                    textColor: Colors.white,
                    child: new Text('REMOVE'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _removeCollection();
                    })
              ]);
        });
  } //end _dialogRemoveCollection

//-------------------------------------------------------------------//
  _getLastCollection() {
    return widget.collectionList.length - 1;
  }

//-------------------------------------------------------------------//
  _dialogMissingDetails(BuildContext context, bool hasGPS, bool hasUUI) {
    String errorMessage = 'Missing ';

    if (hasGPS == false) {
      errorMessage = errorMessage + "GPS";
    }

    if (hasGPS == false && hasUUI == false) {
      errorMessage = errorMessage + " & ";
    }

    if (hasUUI == false) {
      errorMessage = errorMessage + "Identifier";
    }

    errorMessage = errorMessage + "!";

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text('Alert!'),
              content: new Text(errorMessage, style: TextStyle(height: 1.2)),
              actions: <Widget>[
                new FlatButton(
                    color: Colors.red,
                    textColor: Colors.white,
                    child: new Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    })
              ]);
        });
  } //end

//Buttons
//-------------------------------------------------------------------//
//-------------------------------------------------------------------//
//-------------------------------------------------------------------//

  String _buttonTitle(String type) {
    if (type == typeGPS) {
      return 'GET GPS';
    } else if (type == typeBarcode) {
      return 'IDENTIFIER';
    } else if (type == typeSample) {
      return 'ADD VOUCHER'; //is this used???
    } else if (type == typeVoucher) {
      return 'ADD SAMPLE'; //is this used???
    }
    return '';
  } //end _buttonTitle

//-------------------------------------------------------------------//
  _buttonMethod(String actionType, String type) {
    if (actionType == typeGPS) {
      if (site.lat != 0) {
        return _dialogGPSPicker(context); //_showGPSTypeSelector();
      } else {
        return _setGPS(gpsTypeSingle);
      } //getGPS
    } else if (actionType == typeBarcode) {
      if (site.collectors[1].sHideCollectorID == false) {
        return _dialogIDPicker(context, type);
      } else {
        //just scan barcode
        _getBarcode();
      }
    }
  } //end _buttonMethod

//-------------------------------------------------------------------//
  _buttonOutlined(String actionType, type) {
    return SizedBox(
        height: 45.0,
        width: 200.0,
        child: ButtonTheme(
          child: OutlineButton(
              child: Text(_buttonTitle(actionType)),
              onPressed: () => (_buttonMethod(actionType, type)),
              textColor: forTypeFontColor(type),
              borderSide: BorderSide(width: 1.0, color: forTypeFontColor(type)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(00.0))),
        ));
  } //end _buttonOutlined

} //end class

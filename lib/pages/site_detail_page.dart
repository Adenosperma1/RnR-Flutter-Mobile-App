import 'dart:io';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart'; //for text input black list
//import 'package:back_button_interceptor/back_button_interceptor.dart';

//Classes
import 'package:restoreandrenew/classes/site_class.dart'; //site class
import 'package:restoreandrenew/classes/user_class.dart';

//Helpers
import 'package:restoreandrenew/helpers/database_local_helper.dart'; //help create checklist
import 'package:restoreandrenew/helpers/ui_helper.dart'; //help create checklist
import 'package:restoreandrenew/helpers/gps2_helper.dart';

//Pages
import 'package:restoreandrenew/pages/population_list_page.dart'; //push to this page
import 'package:restoreandrenew/pages/selector_page.dart'; //push to this page

//-------------------------------------------------------------------//
class SiteDetail extends StatefulWidget {
  final Site site; // hand in the selected site object
  final siteList; // hand in the site List

  SiteDetail({Key key, @required this.site, this.siteList})
      : super(key: key); //hand in the site from the previous context

  @override
  _SiteDetailState createState() => _SiteDetailState();
}

//-------------------------------------------------------------------//
class _SiteDetailState extends State<SiteDetail>
    with WidgetsBindingObserver //not sure why I added this???
{
  Site site;
  List<Site> siteList;
  DatabaseHelper db = new DatabaseHelper();
  bool loading = false;
  double lat;
  double lon;
  int acc;
  int alt;
  String uiTime;

  List<User> collectorList;

//-------------------------------------------------------------------//
//Controllers for normal fields
  final TextEditingController nameController = TextEditingController();
  
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController disturbanceOtherController =
      TextEditingController();
  final TextEditingController landFormOtherController = TextEditingController();
  final TextEditingController habitatController = TextEditingController();
  final TextEditingController habitatOtherController = TextEditingController();
  final TextEditingController newUserController = TextEditingController();
  final TextEditingController associatedController = TextEditingController();
  final TextEditingController tenureController = TextEditingController();




  FocusNode descriptionfocusNode = new FocusNode();
//-------------------------------------------------------------------//
//List of values for drop down fields
  final List<String> soilColourList = <String>[
    '',
    'Black',
    'Brown',
    'Grey',
    'Red',
    'Yellow'
  ];

  final List<String> soilTextureList = <String>[
    '',
    'Clay',
    'Clay Loam',
    'Loam',
    'Peat',
    'Sand',
    'Sandy Loam',
    'Silt',
    'Not Sure',
  ];

//one list that holds all the selected results for the drop down menus
  var resultsList = new List<String>.filled(2, '');

//-------------------------------------------------------------------//
//Check box values
  Map<String, bool> disturbanceMapUI = uiMapFromList([
    //can't have odd characters in these strings
    'Undisturbed',
    'Recent Fire',
    'Past Fire',
    'Not Sure',
  ]);

  Map<String, bool> landFormMapUI = uiMapFromList([
    //can't have odd characters in these strings
    'Cliff',
    'Depression',
    'Dune',
    'Flat',
    'Gully',
    'Ridge',
    'Rocky',
    'Slope',
    'Undulating',
    'Water edge'
  ]);

  Map<String, bool> habitatMapUI = uiMapFromList([
    //can't have odd characters in these strings
    'Dry Eucalypt Forest and Woodland',
    'Wet Eucalypt Forest and Woodland',
    'Non Eucalypt Forest and Woodland',
    'Rainforest and Related Scrub',
    'Scrub Heathland and Coastal Complexes',
    'Native Grassland',
    'Saltmarsh and Wetlands',
    'Swamps',
    'Highland Treeless Vegetation',
    'Disturbed'
  ]);

//-------------------------------------------------------------------//
//Build a checklist
  _checkList(Map<String, bool> theMap, String dbMapField) {
    return new ListView(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(), //need this for a list in a list
      children: theMap.keys.map((String key) {
        return new CheckboxListTile(
          value: theMap[key],
          dense: uiIsDense(),
          title: new Text(key),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (bool value) {
            setState(() {
              theMap[key] = value;
            });
            //update the site object
            site.set(dbMapField, theMap);
            //update the database

            _saveSite();
            //db.saveObjectList('site', sites, '1');
          },
        );
      }).toList(),
    );
  } //end

//-------------------------------------------------------------------//
  @override
  void initState() {
    site = widget.site;
    siteList = widget.siteList;
    collectorList = site.collectors;
    uiTime = site.uiTime;
    lat = site.lat;
    lon = site.lon;
    acc = site.acc;
    alt = site.alt;

    //set the intial feild value
    


    nameController.text = site.name;
    descriptionController.text = site.description;
    disturbanceOtherController.text = site.disturbanceOther;
    landFormOtherController.text = site.landFormOther;
    habitatOtherController.text = site.habitatOther;
    associatedController.text = site.associated;
    tenureController.text = site.tenure;

    descriptionfocusNode.addListener(_focusNodeListener);

    //drop down menu fields, results are saved into a list of results
    resultsList[0] = site.soilColour;
    resultsList[1] = site.soilTexture;

    //Checklists
    if (site.disturbanceMapDB != null) {
      disturbanceMapUI = site.disturbanceMapDB.cast<String, bool>();
    }
    if (site.habitatMapDB != null) {
      habitatMapUI = site.habitatMapDB.cast<String, bool>();
    }
    if (site.landFormMapDB != null) {
      landFormMapUI = site.landFormMapDB.cast<String, bool>();
    }
    //return
    super.initState();
    //BackButtonInterceptor.add(myInterceptor, zIndex:3, name:"Site");
    WidgetsBinding.instance.addObserver(this);
  }

//-------------------------------------------------------------------//
  @override
  void dispose() {
    descriptionfocusNode.removeListener(_focusNodeListener);
    WidgetsBinding.instance.removeObserver(this);
    //BackButtonInterceptor.removeByName("Site");
    super.dispose();
  }

//-------------------------------------------------------------------//
  _focusNodeListener() async {
    if (descriptionfocusNode.hasFocus) {
      //print('TextField got the focus');
    } else {
      //print('TextField lost the focus');
    }
  }

/*
//-------------------------------------------------------------------//
  bool myInterceptor(bool stopDefaultButtonEvent) {
   print("Site detail says: press OS BACK BUTTON!"); // Do some stuff.
    _backArrowPressed();
   return false;
}
*/

//-------------------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(children: [
      _buildHeading(),
      _buildBody(),
      _headerIcons(context),
    ]));
  } //end

//-------------------------------------------------------------------//
  _buildBody() {
    double statusbarHeight = MediaQuery.of(context).padding.top;
    double theAppBarHeight = uiGetHeaderHeight() - statusbarHeight;
    return 
    WillPopScope( //this stops the Android OS back button
    onWillPop: () async => false,
    child:   
    
    Scaffold(
        resizeToAvoidBottomPadding: true,
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(theAppBarHeight),
            child: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: new Image.asset('assets/appBarTitle.png', width: 90.0),
              backgroundColor: Colors.transparent,
              elevation: 0,
            )),
        body: ListView(children: [
          _buildForm(
            context,
          )
        ])));
  }

//-------------------------------------------------------------------//
  _buildForm(BuildContext context) {
    int count = (collectorList.length - 1);
    String collectorText = '';
    if (count == 1) {
      collectorText = '1 Collector';
    } else {
      collectorText = count.toString() + ' Collectors';
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double listHeight = screenHeight - uiGetHeaderHeight();

    return Container(
        color: Colors.white,
        width: screenWidth,
        height: listHeight,
        child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            children: <Widget>[
              ...siteFormPart1(collectorText),
              ...siteFormPart2()
            ]));
  } //end _buildBody

//-------------------------------------------------------------------//
  siteFormPart1(String collectorText) {
    return <Widget>[
      uiTitle(collectorText),
      new Container(
        height: 75,
        color: uicollectionRowBackGroundColor(),
        child: _buildCollectorsBody(context),
      ),
      uiSpaceBelow(5),
      _sectionGPS(),
      uiSpaceBelow(1),
      uiTitle("Precise Location"),
      uiField(
        siteList,
        site,
        descriptionController,
        'description',
      )
    ];
  }

//-------------------------------------------------------------------//
  siteFormPart2() {
    if (site.description.isNotEmpty) {
      return <Widget>[
        uiTitle("Tenure"),
        _buttonTenure(),
        uiTitle("Soil Colour"),
        _fieldDropDown(soilColourList, 0, 'soilColour'),
        uiTitle("Soil Texture"),
        _fieldDropDown(soilTextureList, 1, 'soilTexture'),
        uiTitle("Disturbance"),
        _checkList(disturbanceMapUI, 'disturbanceMapDB'),
        uiTitle("Disturbance Other"),
        uiField(
          siteList,
          site,
          disturbanceOtherController,
          'disturbanceOther',
        ),
        uiTitle("Land Form"),
        _checkList(landFormMapUI, 'landFormMapDB'),
        uiTitle("Land Form Other"),
        uiField(
          siteList,
          site,
          landFormOtherController,
          'landFormOther',
        ),
        uiTitle("Habitat"),
        _checkList(habitatMapUI, 'habitatMapDB'),
        uiTitle("Habitat Other"),
        uiField(
          siteList,
          site,
          habitatOtherController,
          'habitatOther',
        ),
        uiTitle("Associated Vegetation"),
        uiField(
          siteList,
          site,
          associatedController,
          'associated',
        ),
        uiSpaceBelow(5),
        _buttonSpecies(),
        uiSpaceBelow(2)
      ];
    } else {
      return <Widget>[];
    }
  }

//-------------------------------------------------------------------//
  _buttonSiteGPS() {
    return Row(children: [
      Expanded(
          child: Container(
        height: 56.0,
        child: ButtonTheme(
          shape: RoundedRectangleBorder(borderRadius: uiGetRadius()),
          child: FlatButton(
            child: Text('GET GPS'),
            onPressed: () {
              _getGPS();
            },
            color: uiGetPrimaryColor(),
            textColor: Colors.white,
          ),
        ),
      ))
    ]);
  }

//-------------------------------------------------------------------//
  _getGPS() async {
    //this code is pretty much repeated in the collection detail so make sure to update it there as well
    print('Site Detail says: setGPS called!');
    String _uiTime;
    DateTime theDateTime;
    LocationData location = await getGPS();

    setState(() {
      loading = true;
    });

    if (location != null) {
      print('Site Detail says: There\'s a gps!');
      site.set('lat', location.latitude);
      site.set('lon', location.longitude);
      site.set('acc', location.accuracy.toInt());
      site.set('alt', location.altitude.toInt());


       theDateTime = Platform.isIOS
              ? DateTime.fromMillisecondsSinceEpoch(location.time.toInt() * 1000)
              : DateTime.fromMillisecondsSinceEpoch(location.time.toInt());

      site.set('timestamp', theDateTime);
 
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
      site.set('uiTime', _uiTime);
    } else {
      print('Site Detail says: There\'s no gps!');
      site.set('lat', 0.0);
      site.set('lon', 0.0);
      site.set('acc', 0);
      site.set('alt', 0);
    }
    //save objects to local database
    _saveSite();

    setState(() {
      lat = site.lat;
      lon = site.lon;
      acc = site.acc;
      alt = site.alt;
      uiTime = _uiTime;
      loading = false;
    });
  } //end _getGPS

  //-------------------------------------------------------------------//
  _sectionGPS() {
    if (collectorList[1].sHideSiteGPS == false) {
      return Row(
          crossAxisAlignment: CrossAxisAlignment.center, //align top to bottom
          mainAxisAlignment: MainAxisAlignment.center, //align to left to right?
          children: [
            Expanded(
                child: Container(
                    child: Column(children: <Widget>[
              loading ? uiSpinnerWhite() : _showDetailsGPS()
            ])))
          ]);
    }
    return Container();
  } //end _sectionGPS()

 

  //-------------------------------------------------------------------//
  _showDetailsGPS() {
    if (site.lat == 0) {
      return _buttonSiteGPS();
    } else {
      return _detailsGPS();
    }
  } //end _showDetailsGPS

  //-------------------------------------------------------------------//
  _detailsGPS() {
    String theLat;
    String theLon;
    String theAcc;
    theLat = (uiRoundDouble(lat, 4)).toString();
    theLon = (uiRoundDouble(lon, 4)).toString();
    theAcc = acc.toString();
    String theTime = uiTime;

    String theText = 'Latitude: ' +
        theLat +
        '\n' +
        'Longitude: ' +
        theLon +
        '\n' +
        '  Acc: ' +
        theAcc +
        'm    Time: ' +
        theTime;

    return Stack(children: <Widget>[
      uiGetGPSGreyBox(theText),
      _buttonUpdateGPS(),
    ]);
  } //end _detailsGPS

  //-------------------------------------------------------------------//
  _buttonUpdateGPS() {
    return Positioned(
        right: -20.0,
        top: 25.0,
        child: FlatButton(
          child: Icon(
            Icons.autorenew,
            size: 20.0,
            color: Colors.black,
          ),
          onPressed: () {
            _getGPS();
          },
        ));
  }

  //-------------------------------------------------------------------//
  _buttonSpecies() {
    return new SizedBox(
      height: 56.0,
      child: ButtonTheme(
        shape: RoundedRectangleBorder(borderRadius: uiGetRadius()),
        child: FlatButton(
          child: Text('SPECIES'),
          onPressed: () {
            _validatePreciseLocation(context);
          },
          color: uiGetPrimaryColor(),
          textColor: Colors.white,
        ),
      ),
    );
  }

//-------------------------------------------------------------------//
  _buttonTenure() {
    return new SizedBox(
      height: 55.0,
      child: ButtonTheme(
        highlightColor: Colors.white,
        child: OutlineButton(
          borderSide: BorderSide(
            color: uiGetPrimaryColor(),
            width: .6,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              child: Text(tenureController.text,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 15.5,
                    color: Colors.black,
                  )),
            ),
          ),
          onPressed: () {
            _selectTenure();
          },
          color: uiGetPrimaryColor(),
          textColor: Colors.black,
        ),
      ),
    );
  } //end

//-------------------------------------------------------------------//
  _selectTenure() async {
    var tenure = await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new Selector(type: 'Site', edit: false)));

    if (tenure is bool) {
      return null;
    } else if (tenure is String) {
      setState(() {
        //set the field to result
        tenureController.text = tenure;

        //set the objects field to result
        site.set('tenure', tenure);

        //save to database
        _saveSite();
      });
    }
  } //end _selectTenure

//-------------------------------------------------------------------//
  _removeSite() async {
//remove all related populations
    db.deleteOrphanedPopulations(site.id);

//now delete the site
    setState(() {
      Navigator.pop(context);
      siteList.removeWhere((aSite) => aSite.id == site.id);
      _saveSite();
    });
  } //end _removeSite

//-------------------------------------------------------------------//
  _saveSite() {
    db.saveObjectList('site', siteList, '1');
  }

//-------------------------------------------------------------------//
//-------------------------------------------------------------------//
//-------------------------------------------------------------------//
//COLLECTORS---------------------------------------------------------//

//-------------------------------------------------------------------//
  Widget _collectorIconAdd(List<User> collectorList, int position) {
    return GestureDetector(
        onTap: () => _clickAddCollector(),
        child: new Container(
            height: 35.0,
            width: 35.0,
            child: new CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.add, color: uiiconImageColor()),
            )));
  } //end _collectorIconAdd

//-------------------------------------------------------------------//
  _clickAddCollector() {
    //check if the logged in user is an rnr user, i.e. they have a password
    if (collectorList[1].password.length != 0) {
      return _dialogAddCollectorFromList(context);
    } else {
      return _dialogAddCollectorName(context, newUserController);
    }
  }

//-------------------------------------------------------------------//
  Widget _collectorIcon(List<User> collectorList, int position) {
    return GestureDetector(
        //HERE if RnR user show dialog...
        onTap: () => _dialogRemoveCollector(context, position),
        child: new Container(
            height: 60.0,
            width: 60.0,
            padding: EdgeInsets.only(left: 2.00, right: 2),
            child: new CircleAvatar(
                backgroundColor: Colors.black,
                child: Text(
                  collectorList[position].initials,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w400),
                ))));
  } //end _collectorIcon

//-------------------------------------------------------------------//
  Widget _collectorIconFirst(User user) {
    return GestureDetector(
        onTap: () => _dialogChangeCollector(context),
        child: new Container(
            height: 60.0,
            width: 60.0,
            padding: EdgeInsets.only(right: 2.00),
            child: new CircleAvatar(
                backgroundColor: Colors.black,
                child: Text(
                  user.initials,
                  style: TextStyle(
                      fontWeight: FontWeight.w400, color: Colors.white),
                ))));
  } //end _collectorIconFirst

//-------------------------------------------------------------------//
//decide which icon to show for the collector
  Widget _collectorIconType(
      BuildContext context, List<User> collectorList, int position) {
    Widget child;
    User collector = collectorList[position];

    if ((position == 0)) {
      //show the plus icon, click to add
      child = _collectorIconAdd(collectorList, position);
    } else if (collectorList.length == 2) {
      //first user icon, click to change logged in user
      child = _collectorIconFirst(collector);
    } else {
      //other collectors icon, click to delete it
      child = _collectorIcon(collectorList, position);
    }
    return new Container(child: child);
  } //end _collectorIconType

//-------------------------------------------------------------------//
  Widget _buildCollectorsBody(BuildContext context) {
    return Container(
        color: Colors.white,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, right: 5.0),
            itemCount: collectorList.length,
            itemBuilder: (context, int index) {
              return _collectorIconType(context, collectorList, index++);
            }));
  } //end buildCollectionBody

  //-------------------------------------------------------------------//
  _changeFirstCollector(aCollector) {
    //new user object //currently an available user object
    User mainCollector = new User(
        aCollector.id,
        aCollector.name,
        aCollector.email,
        aCollector.password,
        aCollector.initials,
        aCollector.admin,
        aCollector.hideCollectorID,
        aCollector.hideSiteGPS,
        aCollector.removeAfterUpload,
        );
        
    setState(() {
      collectorList[1] = mainCollector;
    });
  }

//-------------------------------------------------------------------//
  _addCollector(String name) {
    if (name != '') {
      User collector = new User.fromName(name);
      setState(() {
        collectorList.add(collector);
      });

      _saveSite();
    }
  } //end addCollector

  //-------------------------------------------------------------------//
  _removeCollector(int position) {
    setState(() {
      collectorList.removeAt(position);
      _saveSite();
    });
  } //end removeCollector

//-------------------------------------------------------------------//
//-------------------------------------------------------------------//
//-------------------------------------------------------------------//
//DIALOGS---------------------------------------------------------//

//-------------------------------------------------------------------//
  void _dialogChangeCollector(BuildContext context) async {
    //get a list of available users
    var availableCollectorList = new List();
    availableCollectorList = await db.getObjectList('availableUser');
    List<Widget> widgetList = new List();

    if (collectorList.length != 0) {
      //build a list of widgets for the collectors
      for (final anAvailableCollector in availableCollectorList) {
        Widget newWidget = // set up the list options
            SimpleDialogOption(
          child: Text(anAvailableCollector.name),
          onPressed: () {
            _changeFirstCollector(anAvailableCollector);
            Navigator.of(context).pop();
          },
        );
        widgetList.add(newWidget);
      }
    }

    //check if the logged in user is an rnr user, i.e. they have a password
    if (collectorList[1].password.length != 0) {
      _dialogList(context, widgetList, 'Change Collector');
    } else {
      //'print('Not an rnr collector?');
    }
  } //end dialogChangeCollector

  //-------------------------------------------------------------------//
  _validatePreciseLocation(BuildContext context) {
    if (site.description.isEmpty) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: new Text('Precise Location'),
                content: new Text(
                    'Please provide the Precise Location of this site.'),
                actions: <Widget>[
                  new FlatButton(
                      color: Colors.black,
                      textColor: Colors.white,
                      child: new Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ]);
          });
    } else {
      _openPopulationList(context);
    }
  } //end dialogPreciseLocation

//-------------------------------------------------------------------//
  _openPopulationList(
    BuildContext context,
  ) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PopulationList(site: widget.site)));
  }

//-------------------------------------------------------------------//
  void _dialogAddCollectorFromList(BuildContext context) async {
    //get a list of available users
    var availableCollectorList = new List();
    availableCollectorList = await db.getObjectList('availableUser');

    List<Widget> widgetList = new List();
    if (collectorList.length != 0) {
      //build a list of widgets for the collectors
      for (final anAvailableCollector in availableCollectorList) {
        Widget newWidget = // set up the list options
            SimpleDialogOption(
          child: Text(anAvailableCollector.name),
          onPressed: () {
            _addCollector(anAvailableCollector.name);
            Navigator.of(context).pop();
          },
        );
        widgetList.add(newWidget);
      }
    }

    Widget otherWidget =
        SimpleDialogOption(
      child: Text(
        'OTHER',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        _dialogAddCollectorName(context, newUserController);
      },
    );
    widgetList.add(otherWidget);
    _dialogList(context, widgetList, 'Add Collector');
  } //end dialogAddCollector

//-------------------------------------------------------------------//
  _dialogList(BuildContext context, List<Widget> widgetList, String heading) {
    SimpleDialog dialog = SimpleDialog(
      title: Text(heading),
      children: widgetList,
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  } //end dialogList

//-------------------------------------------------------------------//
  void _dialogAddCollectorName(
      BuildContext context, TextEditingController theController) {
    theController.text = '';







    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text('Collector Name'),
            content: new Row(
              children: <Widget>[
                new Expanded(
                  child: new TextField(
                    controller: theController,
                    inputFormatters: [BlacklistingTextInputFormatter(RegExp(getBlackList())),],
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                    decoration: new InputDecoration(hintText: 'John Citizen'),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  textColor: Colors.black,
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              new FlatButton(
                  color: Colors.black,
                  textColor: Colors.white,
                  child: const Text(
                    'ADD',
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _addCollector(theController.text);
                  })
            ],
          );
        });
  } // end _dialogAddCollector

//-------------------------------------------------------------------//
  _dialogRemoveSite(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text('Remove'),
              content: new Text(site.description),
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
                      _removeSite();
                    }),
              ]);
        });
  } //end dialogRemoveSite

//-------------------------------------------------------------------//
  void _dialogRemoveCollector(BuildContext context, int position) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text('Remove'),
              content:
                  new Text(collectorList[position].name + ' as a collector?'),
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
                      _removeCollector(position);
                    }),
              ]);
        });
  } //end dialog

//-------------------------------------------------------------------//
//-------------------------------------------------------------------//
//-------------------------------------------------------------------//
//Header Section---------------------------------------------------------//

//-------------------------------------------------------------------//
  _buildHeading() {
    double screenWidth = MediaQuery.of(context).size.width;
    double headerHeight = uiGetHeaderHeight();
    return Material(
        child: Container(
            child: Column(children: [
      Stack(children: [
        headerImage(headerHeight, screenWidth),
        Positioned(
            left: 20.0,
            top: 90.0,
            child: uiSubHeading(site.description, screenWidth)),
      ])
    ])));
  } //end _buildHeading

  //-------------------------------------------------------------------//
  _speciesStatusButton(BuildContext context, double screenWidth) {
    return Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => _buildSpeciesStatusText() != ''
              ? _validatePreciseLocation(context)
              : null,
          child: _buildStatusBar(screenWidth),
        ));
  } //end

  //-------------------------------------------------------------------//
  _buildStatusBar(double screenWidth) {
    return Padding(
        padding: const EdgeInsets.only(top: 106.0, left: 20, right: 0),
        child: Row(children: <Widget>[
          Container(
              width: screenWidth - 25 - 38,
              child: Text(_buildSpeciesStatusText(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w100,
                    color: Colors.white,
                  ))),
          Container(
            width: 25,
            child: uiErrorIcon(site.dataOK, Colors.white),
          ),
        ]));
  }

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
                _trashCan(),
              ]),
              Row(children: <Widget>[
                _speciesStatusButton(context, screenWidth),
              ])
            ])));
  } //end _headerIcons

//-------------------------------------------------------------------//
  _trashCan() {
    return Container(
        color: Colors.transparent,
        child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.only(right: 10.0, top: 25),
            child: IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () {
                _dialogRemoveSite(context);
              },
              color: Colors.white,
            )));
  } //end

  //-------------------------------------------------------------------//
  _backArrow() {
    return Material(
        color: Colors.transparent,
        child: Container(
            color: Colors.transparent,
            padding: const EdgeInsets.only(top: 25),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => _backArrowPressed(), //=> Navigator.pop(context),
              color: Colors.white,
            )));
  } //end _backArrow


//-------------------------------------------------------------------//
_backArrowPressed(){
Navigator.pop(context);
}


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
                  site.set(dbField, newValue);
                  _saveSite();
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

//-------------------------------------------------------------------//
  String _buildSpeciesStatusText() {
    String speciesText = '';
    String collectionText = '';
    String theStatus = '';

    if (site.speciesCount > 0) {
      speciesText = site.speciesCount.toString() + ' Species';
    }

    if (site.collectionCount == 1) {
      collectionText = '1 Collection';
    } else if (site.collectionCount > 1) {
      collectionText = site.collectionCount.toString() + ' Collections';
    }

    if (speciesText.isNotEmpty && collectionText.isNotEmpty) {
      theStatus = speciesText + ', ' + collectionText;
    } else {
      theStatus = speciesText + collectionText;
    }

    return theStatus;
  }
} //end class

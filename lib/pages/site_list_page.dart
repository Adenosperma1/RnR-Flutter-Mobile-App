
//TODO_ send data to me so I can get email addresses for marketing?
//TODO_ set up my website to host the syncing currently done with google db

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:restoreandrenew/classes/individual_class.dart';
import 'package:uuid/uuid.dart';

//Classes
import 'package:restoreandrenew/classes/site_class.dart';
import 'package:restoreandrenew/classes/user_class.dart';
import 'package:restoreandrenew/classes/population_class.dart';
import 'package:restoreandrenew/classes/species_available_class.dart';
import 'package:restoreandrenew/classes/collection_class.dart';

//Helpers
import 'package:restoreandrenew/helpers/database_local_helper.dart';
import 'package:restoreandrenew/helpers/database_inbetween_helper.dart';
import 'package:restoreandrenew/helpers/export_helper.dart';
import 'package:restoreandrenew/helpers/ui_helper.dart';

//Pages
import 'package:restoreandrenew/pages/selector_page.dart';
import 'package:restoreandrenew/pages/site_detail_page.dart';
import 'package:restoreandrenew/pages/collection_detail_page.dart';
import 'package:restoreandrenew/pages/login_page.dart';

//-------------------------------------------------------------------//
class SiteList extends StatefulWidget {
  final User user;

  SiteList({
    Key key,
    @required this.user,
  }) : super(key: key); //hand in the user from the login

  @override
  _SiteListState createState() {
    return _SiteListState();
  }
}

//-------------------------------------------------------------------//
class _SiteListState extends State<SiteList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  List<Site> siteList = new List();
  List<Population> populationList = new List();
  Color theBackGroundColor = Colors.white;

  final double buttonWidth = 35.0;
  final double buttonHeight = 55.0;
  final double theElevation = 2.0;
  

  DatabaseHelper db = new DatabaseHelper();
  var uuid = new Uuid(); //library that makes uuids

  bool switchOnCollectorID = false;
  bool switchOnSiteGPS = false;
  bool removeAfterUpload = false;

  @override
  void initState() {
    if (widget.user.hideCollectorID == null) {
      switchOnCollectorID = false;
    } else {
      switchOnCollectorID = widget.user.hideCollectorID;
    }

    if (widget.user.hideCollectorID == null) {
      switchOnSiteGPS = false;
    } else {
      switchOnSiteGPS = widget.user.hideSiteGPS;
    }

    if (widget.user.removeAfterUpload == null) {
      removeAfterUpload = false;
    } else {
      removeAfterUpload = widget.user.removeAfterUpload;
    }

    _initSiteList();
    super.initState();
    

  }

//-------------------------------------------------------------------//
  Widget build(BuildContext context) {

    if (siteList.length != 0) {
      _saveSite(); //saves the site list on return from the species page after the dataok is set
    }
    return 
    
    
    Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: _appbar(),
        resizeToAvoidBottomPadding: true,
        floatingActionButton: _floatingButton(),
        body: _body());
  }



//-------------------------------------------------------------------//
  _appbar() {
    return AppBar(
      centerTitle: true,
      title: new Image.asset('assets/appBarTitle.png', width: 90.0),
      leading: IconButton(
        icon: Icon(Icons.perm_identity),
        onPressed: () => _dialogUserPreferences(context),
      ),
      backgroundColor: uiGetGreenColor(),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.visibility),
          onPressed: () => _dialogAddCollection(context),
        ),
        IconButton(
          icon: Icon(Icons.cloud_queue),
          onPressed: () => _openCloudOptionsForUser(context),
          color: Colors.white,
        ),
      ],
    );
  }





//-------------------------------------------------------------------//
  _body() {
    double screenHeight = MediaQuery.of(context).size.height;
    double barHeight = 100;
    double listHeight = screenHeight - barHeight + 20;
    return Stack(children: [
      _siteList(listHeight, barHeight),
    ]);
  }

//-------------------------------------------------------------------//
  _floatingButton() {
    return Container(
        child: FloatingActionButton.extended(
            shape: RoundedRectangleBorder(borderRadius: uiGetRadius()),
            backgroundColor: uiGetGreenColor(),
            elevation: 2.0,
            onPressed: () {
              _addSite(true);
            },
            label: Text("+ SITE",
                style: TextStyle(
                  fontFamily: theFontFamily,
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ))));
  } //end floating button

  //-------------------------------------------------------------------//
  _addSighting(BuildContext context, String type) async {
    Site site = await _addSite(false);
    site.set('description', 'Flag');
    site.sDataOK = true;

    //POPULATION
    Population population = await _addPopulation(context, site);

    if (population is Population) {
      //the user may have cancelled which returns a bool?
      site.set('name',
          population.name); //this shows the plant name under the flag icon

      site.set('flagType', type);

      _saveSite();

      populationList.clear();
      populationList.add(population);

      String aUuid = uuid.v1(); //create an id for the new collection record
      Collection collection = Collection.fromID(aUuid, type);

      int individualsPosition =
          _createNewIndividual(site, populationList, collection);

      if (type == typeSighted || type == typeNotSighted) {
        collection.set("gpsType", 'single');
      }

      if (type == typeNote) {
        collection.set("gpsType", 'none');
      }

      _openCollectionPage(site, populationList[0], individualsPosition);
    } else {
      _cleanUpNoSightingMade(
          site); //clean up if the user didn't select a species
    }
  } //end _addFlag

  //-------------------------------------------------------------------//

  _openCollectionPage(
      Site site, Population population, int individualsPosition) {
    List<Collection> collectionList =
        population.individualsList[individualsPosition].collectionList;

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CollectionDetail(
                siteList: siteList,
                site: site,
                populationList: populationList,
                population: populationList[0], //population,
                individualsPosition: individualsPosition,
                collectionList: collectionList,
              )),
    );
  } //end

//-------------------------------------------------------------------//
  _openSighting(Site site) async {
    populationList = await db.getPopulationList(site.id);
    _openCollectionPage(site, populationList[0], 0);
  }

//-------------------------------------------------------------------//
  int _createNewIndividual(
    Site site, List<Population> populationList, Collection collection) {
    Population population = populationList[0];
    String aUuid = uuid.v1(); //create an id for the new record
    Individual individual = Individual.fromID(aUuid, collection);
    int length = population.individualsList.length;

    //if (length == 1) {
    //hide the alert icon
    populationList[0].sdataOK = true;
    site.sDataOK = true;
    //}

    if (collection.type == typeNote) {
      //set all the gps to null
      collection.set("collectorsID", 'NA');
      individual.set('lat', 0.0);
      individual.set('lon', 0.0);
      individual.set('acc', 0);
      individual.set('alt', 0);
      individual.set('gpsType', 'none');
    }

    if (collection.type == typeSighted || collection.type == typeNotSighted) {
      collection.set("collectorsID", 'NA');
    }

    setState(() {
      population.individualsList.add(individual);
    });
    _savePopulation(site.id.toString(), populationList);
    return length;
  }

//-------------------------------------------------------------------//
  _savePopulation(String siteId, List<Population> populationList) async {
    await db.saveObjectList('population', populationList, siteId);
  }

//-------------------------------------------------------------------//
  _siteList(double screenHeight, double barHeight) {
    return Positioned(
        child: Material(
            color: Colors.transparent,
            child: Builder(builder: (BuildContext internalContext) {
              return _list(internalContext, screenHeight);
            })));
  } //end

//-------------------------------------------------------------------//
  _addSite(bool openPage) async {
    //add current user to the site
    List<User> collectorList = new List();

    //add an empty user to show the plus button
    User emptyUser = new User('', '', '', '', '', false, false, false, false);
    collectorList.add(emptyUser);

    //add the logged in user to the collectors list
    User user = widget.user;
    //print('Added user: ' + user.password);
    collectorList.add(user);

    //make a new site object
    String aUuid = uuid.v1();
    int position = siteList.length + 1;
    String siteName = 'Site ' + position.toString();
    Site site = Site.fromName(siteName, aUuid, collectorList);
    siteList.add(site);
    _sortSiteList();
    _saveSite();
//go to it if the user added it
    if (openPage) {
      print("Open site!");
      _openSite(site);
    } else {
      return site;
    }
  } //end

//-------------------------------------------------------------------//
  _sortSiteList() {
    //return siteList.sort((a, b) => a.name.compareTo(b.timestamp));
  }

//-------------------------------------------------------------------//
  _openSite(Site site) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SiteDetail(site: site, siteList: siteList)),
    );
  }

//-------------------------------------------------------------------//
  _initSiteList() async {
    print("Site List Page Says_init the site list");
    List<dynamic> siteListDynamic = await db.getObjectList('site');
    siteList = siteListDynamic.cast<Site>();
    setState(() {
      siteList = siteList;
    });
  } // end initSiteList()

//-------------------------------------------------------------------//
  _openCloudOptionsForUser(BuildContext context) async {
    int siteListLength = _uploadCheckSites(siteList);

    if (await ibInternetConnection() == false) {
      _dialogNoInternet(context);
    } else {
      //if admin just open the admin picker
      if (widget.user.admin == true) {
        _dialogUploadPicker(context);
        //if not admin check if they have sites to upload
      } else if (siteListLength == 0) {
        _dialogNoData(context);
      } else {
        _dialogUpload(context);
      }
    }
  } //end _openCloudOptionsForUser

  //-------------------------------------------------------------------//
  _addPopulation(context, Site site) async {
    //go to the species selector page
    //could return an availabespecies object (with a current name) or a string (for a new name), or a bool for nothing
    var speciesObject = await Navigator.push(
        context,
        new MaterialPageRoute(
            builder: (context) => new Selector(type: 'Species', edit: false)));

    String speciesName = '';
    String speciesGenus = '';
    String speciesSpecies = '';
    String speciesRank = '';
    String speciesRankName = '';
    String speciesID = '';
    String speciesUuid = uuid.v1();

    bool notOnList = false;

    if (speciesObject is bool) {
      //nothing returned
    } else if (speciesObject is AvailableSpecies) {
      speciesID = speciesObject.id;
      speciesName = speciesObject.name;
      speciesGenus = speciesObject.nameGenus;
      speciesSpecies = speciesObject.nameSpecies;
      speciesRank = speciesObject.nameRank;
      speciesRankName = speciesObject.nameRankName;

      if (speciesID.isEmpty) {
        speciesID = speciesUuid;
      }
    } else if (speciesObject is String) {
      speciesName = speciesObject;
      speciesGenus = '';
      speciesSpecies = '';
      speciesRank = '';
      speciesRankName = '';
      notOnList = true;
      speciesID = speciesUuid;
    }

    if (speciesName != '') {
      //make a species record with the site id

//make a new species from the name
      Population population = Population.fromFkSite(
          site.id,
          speciesID, //speciesUuid,
          speciesName,
          speciesGenus,
          speciesSpecies,
          speciesRank,
          speciesRankName);

      if (notOnList == true) {
        population.set('notOnList', true);
      }
      return population;
    }
  } //end

//-------------------------------------------------------------------//
  Widget _list(BuildContext context, double sreenHeight) {
    return Center(
        child: Container(
            height: sreenHeight,
            color: Colors.transparent,
            child: ListView.builder(
              itemCount: siteList.length,
              itemBuilder: (context, position) {
                return Column(children: <Widget>[
                  Card(
                      elevation: 0.0,
                      margin: new EdgeInsets.symmetric(
                          horizontal: 0.0, vertical: 0.0),
                      child: Container(child: _tile(position))),
                ]);
              },
            )));
  } //buildbody

//-------------------------------------------------------------------//
  _tile(int position) {
    Site site = siteList[position];
    return ListTile(
        trailing: siteList[position].dataUploaded == true
            ? uiUploadedIcon()
            : uiErrorIcon(siteList[position].dataOK, Colors.red),
        contentPadding:
            EdgeInsets.only(left: 15, top: 10, right: 10, bottom: 10),
        //Text in middle
        title: Row(children: [
          Column(children: [_tileLeadingIcon(site)]),
          Padding(
              padding: EdgeInsets.only(left: 3),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  _tileHeadingText(siteList[position]),
                ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [_tileSubHeadingText(siteList[position])]),
              ])),
        ]),
        onTap: () {
          site.description == 'Flag' ? _openSighting(site) : _openSite(site);
        });
  } //end tile

//-------------------------------------------------------------------//
  _tileHeadingText(Site site) {
    String theText = site.description;
    double cWidth = MediaQuery.of(context).size.width * 0.7;

    if (site.description == 'Flag') {
      theText = site.name;
    }

    return new Container(
        padding: const EdgeInsets.only(left: 10.0),
        width: cWidth,
        child: site.description == 'Flag'
            ? uiGetPlantNameStyleSmall(theText, 2)
            : uiGetSiteNameStyleSmall(theText));
  }

//-------------------------------------------------------------------//
  _tileSubHeadingText(Site site) {
    String theDate;

    site.timestamp != null
        ? theDate = DateFormat.jm().add_yMMMd().format(site.timestamp)
        : theDate = '';

    double cWidth = MediaQuery.of(context).size.width * 0.7;
    return new Container(
        padding: const EdgeInsets.only(left: 10.0),
        width: cWidth,
        child: site.description == "Flag"
            ? Container()
            : Text(theDate,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: theFontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w200,
                    height: 2)));
  }

//-------------------------------------------------------------------//
  _editUsers(BuildContext context) async {
    bool internetConnection = await ibInternetConnection();
    if (internetConnection == false) {
      _dialogNoInternet(context);
    } else {
      //print('Site List says: Internet');
    }

    Navigator.of(context).pop();
    if (widget.user.admin == true) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Selector(
                    type: 'User',
                    edit: true,
                  )));
    }
  } //end _editUsers

//-------------------------------------------------------------------//
  _editTenures(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Selector(
                  type: 'Site',
                  edit: true,
                )));
  } //end

//-------------------------------------------------------------------//
  _editSpecies(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Selector(
                  type: 'Species',
                  edit: true,
                )));
  } //end

//-------------------------------------------------------------------//
  _logOut() {
    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
    print('Site List says: logged out user.');

//The database method expects a list so add it to a list
    List<User> userList = new List();

//save empty userlist to the database
    _saveUser(userList);
  }

//-------------------------------------------------------------------//
  _saveUser(List<User> userList) {
    db.saveObjectList('user', userList, '1');
  }

//-------------------------------------------------------------------//
  _saveSite() {
    db.saveObjectList('site', siteList, '1');
  }

//-------------------------------------------------------------------//
  _dialogNoInternet(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text('Error'),
              content: new Text('No internet connection!'),
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
  } //end _dialogNoInternet

//-------------------------------------------------------------------//
  void _dialogUpLoadResult(bool result) {
    print('Site List says: _uploading result: ' + result.toString());
    Icon theIcon =
        Icon(Icons.check_circle_outline, color: uiGetGreenColor(), size: 50);
    String theResult = "Upload successful!";
    if ((result == false) || (result == null)) {
      theIcon = Icon(Icons.error_outline, color: Colors.red, size: 50);
      theResult = 'Upload failed!' + '\n' + 'Try again later.';
      print('failed!');
    }
    setState(() {});
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => new Dialog(
                child: new Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                height: 20.0,
                width: 150.0,
              ),
              Container(
                  height: 50.0,
                  width: 150.0,
                  child: Center(
                    child: theIcon,
                  )),
              Container(
                  height: 50.0,
                  width: 150.0,
                  child: Center(
                      child: Text(
                    theResult,
                    textAlign: TextAlign.center,
                  )))
            ])));
  } //end

//-------------------------------------------------------------------//
  _dialogUserPreferences(BuildContext context) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(widget.user.name,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    )),

                Text(widget.user.email,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                    )),

                ListTile(
                  title: Text('RnR Version 1.0.19' ,
                      style: TextStyle(color: Colors.black, fontSize: 10.0)),
                ),

                // ListTile(), //for extra space

                ListTile(
                  title: Text('Hide Site GPS',
                      style: TextStyle(color: Colors.black)),
                  trailing: Switch(
                    onChanged: _onSwitchChangedSiteGPS,
                    value: switchOnSiteGPS,
                  ),
                ),

                ListTile(
                  title: Text('Barcode Only',
                      style: TextStyle(color: Colors.black)),
                  trailing: Switch(
                      onChanged: _onSwitchChangedCollectorID,
                      value: switchOnCollectorID),
                ),

                ListTile(
                  title: Text('Remove After Upload',
                      style: TextStyle(color: Colors.black)),
                  trailing: Switch(
                    onChanged: _onSwitchChangedRemoveAfterUpload,
                    value: removeAfterUpload,
                  ),
                ),

                ListTile(
                  title: Text('Log Out', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _dialogLogOutUser(context);
                  },
                ),
              ],
            ),
          );
        });
  } //end _dialogGPSPicker

//-------------------------------------------------------------------//
  void _onSwitchChangedCollectorID(bool value) {
    if (switchOnCollectorID == false) {
      switchOnCollectorID = true;
      widget.user.sHideCollectorID = true;
    } else {
      switchOnCollectorID = false;
      widget.user.sHideCollectorID = false;
    }

    //SAVE THE USER TO THE DATABASE
    List<User> userList = new List();
    userList.add(widget.user);

    //hack, close and reopen dialog to update the switch if the user just taps it
    Navigator.of(context).pop(); 
    _dialogUserPreferences(context);

    //save to database
    _saveUser(userList);
  }

//-------------------------------------------------------------------//
  void _onSwitchChangedSiteGPS(bool value) {
    if (switchOnSiteGPS == false) {
      switchOnSiteGPS = true;
      widget.user.sHideSiteGPS = true;
    } else {
      switchOnSiteGPS = false;
      widget.user.sHideSiteGPS = false;   
    }

    List<User> userList = new List();
    userList.add(widget.user);

    //hack, close and reopen dialog to update the switch if the user just taps it
    Navigator.of(context).pop(); 
    _dialogUserPreferences(context);

    //save to database
    _saveUser(userList);
  }

  //-------------------------------------------------------------------//
  void _onSwitchChangedRemoveAfterUpload(bool value) {
    if (removeAfterUpload == false) {
      removeAfterUpload = true;
      widget.user.sRemoveAfterUpload = true;
    } else {
      removeAfterUpload = false;
      widget.user.sRemoveAfterUpload = false;
    }

    List<User> userList = new List();
    userList.add(widget.user);

    //hack, close and reopen dialog to update the switch if the user just taps it
    Navigator.of(context).pop(); 
    _dialogUserPreferences(context);

    //save to database
    _saveUser(userList);
  }

//-------------------------------------------------------------------//
  _dialogLogOutUser(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Log Out'),
              content: Text(widget.user.name),
              actions: <Widget>[
                FlatButton(
                    textColor: Colors.black,
                    child: Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                FlatButton(
                    color: Colors.red,
                    textColor: Colors.white,
                    child: Text('LOG OUT'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _logOut();
                    }),
              ]);
        });
  } //end _dialogLogOutUser

//-------------------------------------------------------------------//
  void _dialogUpload(BuildContext context) async {
    if (widget.user.admin == true) {
      Navigator.pop(context);
    }
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text("Upload"),
              content: new Text("Upload completed collections?"),
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
                  child: new Text('UPLOAD'),
                  onPressed: () {
                    _upload(context);
                  },
                ),
              ]);
        });
  } //end _uploadDialog

  //-------------------------------------------------------------------//
  _dialogUploadPicker(BuildContext context) {
    int siteListLength = _uploadCheckSites(siteList);
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new ListTile(
                  leading: new Icon(Icons.cloud_upload, color: Colors.black),
                  title:
                      new Text('Upload', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    siteListLength == 0
                        ? _dialogNoData(context)
                        : _dialogUpload(context);
                  },
                ),
                new ListTile(
                  leading: new Icon(Icons.edit, color: Colors.black),
                  title:
                      new Text('Users', style: TextStyle(color: Colors.black)),
                  onTap: () {
                    _editUsers(context);
                  },
                ),
                new ListTile(
                  leading: new Icon(Icons.edit, color: Colors.black),
                  title: new Text('Tenure List',
                      style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _editTenures(context);
                  },
                ),
                new ListTile(
                  leading: new Icon(Icons.edit, color: Colors.black),
                  title: new Text('Species List',
                      style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _editSpecies(context);
                  },
                ),
              ],
            ),
          );
        });
  } //end _dialogGPSPicker

  //-------------------------------------------------------------------//
  _uploadCheckSites(List<Site> siteList) {
    if (siteList.length == 0) {
      return 0;
    } else {
      var siteListdataOK = siteList.where((site) => site.dataOK != false);
      var siteListdataOK1 =
          siteListdataOK.where((site) => site.dataUploaded != true);
      return siteListdataOK1.length;
    }
  }

//-------------------------------------------------------------------//
  void _dialogNoData(BuildContext context) {
    if (widget.user.admin == true) {
      Navigator.of(context).pop();
    }
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text("Alert!"),
              content: new Text("Nothing to upload!"),
              actions: <Widget>[
                new FlatButton(
                  color: Colors.black,
                  textColor: Colors.white,
                  child: new Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ]);
        });
  } //end _noDataDialog

  //-------------------------------------------------------------------//
  _cleanUpNoSightingMade(Site site) async {
//this cleans up the site if the user didn't pick a species for a sighted record.

    //remove the population record which has the individualsList and the collectionsLists in it
    await db.deleteOrphanedPopulations(site.id);

//remove the orphaned site record from the home screen
    setState(() {
      siteList.removeWhere((aSite) => aSite.id == site.id);
      _saveSite();
    });
  } //end _removeSite

//-------------------------------------------------------------------//
  _upload(BuildContext context) async {
    Navigator.of(context).pop();
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayWhite =
        OverlayEntry(builder: (context) => Center(child: FullScreenOverlay()));
    OverlayEntry overlaySpinner =
        OverlayEntry(builder: (context) => Center(child: Spinner()));

    overlayState.insert(overlayWhite);
    overlayState.insert(overlaySpinner);

    ExportHelper exporter = ExportHelper(siteList: siteList, user: widget.user);
    bool result = await exporter.doExport();
    print('Site List says: Result: ' + result.toString());

    if (result == true && removeAfterUpload == true) {
      //delete the uploaded records...
      for (Site site in siteList) {
        if (site.dataUploaded == true) {
          _removeSite(site);
          //sleep();
        }
      }
    }

    overlaySpinner.remove();
    overlayWhite.remove();

    _dialogUpLoadResult(result);
  } //end

  //-------------------------------------------------------------------//
  _removeSite(Site site) async {
//remove all related populations
await sleep();
    await db.deleteOrphanedPopulations(site.id);

//now delete the site
    setState(() {
      siteList.removeWhere((aSite) => aSite.id == site.id);
      _saveSite();
    });
  } //end _removeSite

//-------------------------------------------------------------------//
  Future sleep() {
  return new Future.delayed(const Duration(seconds: 1), () => "1");
}

  //-------------------------------------------------------------------//
  void _dialogAddCollection(
    BuildContext context,
  ) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //NEW Sighting
                new ListTile(
                  leading: uiAddPageIcon(typeSighted),
                  title: new Text(typeSighted,
                      style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addSighting(context, typeSighted);
                  },
                ),

                //NEW Not Sighted
                new ListTile(
                  leading: uiAddPageIcon(typeNotSighted),
                  title: new Text(typeNotSighted,
                      style: TextStyle(color: Colors.black)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _addSighting(context, typeNotSighted);
                    //_addCollectionToNewIndividual(
                    //context, population, typeNotSighted);
                  },
                ),
              ],
            ),
          );
        });
  } //end _dialogAdd




//-------------------------------------------------------------------//
  _tileLeadingIcon(Site site) {
    return Card(
        elevation: theElevation,
        child: Container(
            alignment: Alignment(0.0, 0.0),
            decoration: BoxDecoration(
                border: new Border.all(
                    color: Colors.black, width: 0.15, style: BorderStyle.solid),
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(0.0))),
            height: buttonHeight * 0.95,
            width: buttonWidth * 0.95,
            child: site.description == 'Flag'
                ? uiButtonIcon(site.flagType)
                : new Image.asset('assets/siteIcon.png')));
  }

/*
//keep this for uploading to firestore
//-------------------------------------------------------------------//
  _uploadSpeciesListToFireStore() async {
    var uuid = new Uuid();
    final input = new File('/Users/brendan/Desktop/test.csv').openRead();
    List<List<dynamic>> lines = await input
        .transform(utf8.decoder)
        .transform(new CsvToListConverter())
        .toList();

    for (var aLine in lines) {
      String theUuid = uuid.v1();
      AvailableSpecies availableSpecies = AvailableSpecies.fromNameFull(
          theUuid, aLine[0], aLine[1], aLine[2], aLine[3], aLine[4], aLine[5]);
      String docID =
          await fsDocumentNewAsync("availableSpecies", availableSpecies);
      print('doc id: ' + docID);
    }
  } //end uploadSpeciesListToFireStore
*/

} //End Class






//-------------------------------------------------------------------//
  class FullScreenOverlay extends StatelessWidget {
  const FullScreenOverlay({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: 0.5, child: Container(color: Colors.black));
  }
}


//-------------------------------------------------------------------//
  class Spinner extends StatelessWidget {
  const Spinner({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        type: MaterialType.transparency,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )),
              Center(
                  child: Text('Uploading data...',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        height: 2.0,
                        color: Colors.white,
                        fontSize: 14.0,
                      )))
            ]));
  }
}


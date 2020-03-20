


//NOTES FOR PETER
//Site txt file: Sometimes a site's  'Precise Location' feild will contain 'flag' : 
//these are empty 'Site' records used in the app and are link to 'Sighted' and 'Not Sighted' records that were created on the apps home screen.
//these records can be ignored or I can stop them exporting if needed,

//Species txt file: There is now a 'Collection Notes' field in the 'Species' txt file, 
//this replaces a field called 'Flag Notes', which I'm not sure was ever set up in the database?
//this 'Collection Notes' field holds notes from collections of the type 'Sighted', 'Not Sighted' and 'Notes'
//Notes for an 'individual' that has a sample and or voucher are written into the sample's 'Collection Notes' and or voucher's 'Collection Notes'
//Notes not linked to an 'individual' will be written into the 'Population Notes' field


//spinner on site detail get gps
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:io';

//Classes
import 'package:restoreandrenew/classes/site_class.dart'; //site class
import 'package:restoreandrenew/classes/population_class.dart';
import 'package:restoreandrenew/classes/individual_class.dart';
import 'package:restoreandrenew/classes/collection_class.dart';
import 'package:restoreandrenew/classes/user_class.dart';

//Helpers
import 'package:restoreandrenew/helpers/database_local_helper.dart';
import 'package:restoreandrenew/helpers/file_helper.dart';
import 'package:restoreandrenew/helpers/ui_helper.dart';

class ExportHelper extends StatelessWidget {
  final FileHelper fh = new FileHelper();
  final DatabaseHelper db = new DatabaseHelper();
  final List<Site> siteList; // hand in the site List
  final User user; //hand in the user account

  ExportHelper({Key key, @required this.siteList, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }

//-------------------------------------------------------------------//

  DateTime creationDate = DateTime.now();
  String delimiter = '\t';
  String siteListExport = '';
  String speciesListExport = '';

  //Site List Headings
  final String siteListColumn1 = 'ID Site';
  final String siteListColumn2 = 'Today\'s Date';
  final String siteListColumn3 =
      'People present (capitalise names and comma between each)';
  final String siteListColumn4 =
      'Precise location (brief detailed description of site location)';
  final String siteListColumn5 = 'National Park (select)';
  final String siteListColumn6 = 'State Conservation Area (select)';
  final String siteListColumn7 = 'State Forest (select)';
  final String siteListColumn8 = 'Nature Reserve (select)';
  final String siteListColumn9 = 'Other tenure';
  final String siteListColumn10 = 'Soil colour';
  final String siteListColumn11 = 'Soil Texture';
  final String siteListColumn12 =
      'Disturbance and fire history (can select multiple entries)';
  final String siteListColumn13 = 'Other (e.g. logged, cleared, etc.)';
  final String siteListColumn14 =
      'Landform primary (can select multiple entries)';
  final String siteListColumn15 = 'Other landform';
  final String siteListColumn16 = 'Habitat (select)';
  final String siteListColumn17 = 'Other habitat';
  final String siteListColumn18 = 'Associated vegetation';

  //speciesList Headings
  final String speciesListColumn1 = 'ID Site';
  final String speciesListColumn2 = 'Restore & Renew species list (select)';
  final String speciesListColumn3 = 'Infraspecific rank';
  final String speciesListColumn4 = 'Infrasp. name';
  final String speciesListColumn5 = 'Species name if not on list';
  final String speciesListColumn6 =
      'Tissue sample barcode'; //'Genetic sample 1 barcode number (autofills from scan)';
  final String speciesListColumn7 = 'Location Lat';
  final String speciesListColumn8 = 'Location Long';
  final String speciesListColumn9 = 'Location Acc';
  final String speciesListColumn10 = 'Location Alt';
  final String speciesListColumn11 =
      'Voucher barcode number (autofills from scan)';
  final String speciesListColumn12 = 'Genetic sample taken from voucher?';
  final String speciesListColumn13 = 'If YES which genetic sample number';
  final String speciesListColumn14 = 'Reproductive state';
  final String speciesListColumn15 = 'Flowers (select one or more)';
  final String speciesListColumn16 = 'Fruit (select one or more)';
  final String speciesListColumn17 = 'Number of plants within a radius of 10 m';
  final String speciesListColumn18 = 'Adults Present';
  final String speciesListColumn19 = 'Juveniles Present';
  final String speciesListColumn20 =
      'Population Notes:'; //notes for the population

  final String speciesListColumn21 =
      'Record type'; //can now contain ’’Sample’, ‘Voucher’, ‘Sighted’ or ’Not Sighted’.
  final String speciesListColumn22 = 'ID Species';
  final String speciesListColumn23 = 'fieldNumberSample';
  final String speciesListColumn24 =
      'fieldNumberVoucher'; //the voucher id if hand entered
  final String speciesListColumn25 =
      'Collection Notes'; //for an individual's sample/voucher/sighted/not sighted/ there's also a population notes field
  //final String speciesListColumn26 = 'Collection Type'; //sample, voucher, flag, used internally,
  final String speciesListColumn27 = 'ID Collection';
  final String speciesListColumn28 = 'ID Individual';

  //Site List Row
  String siteListColumn1Value = ''; //id site
  String siteListColumn2Value = ''; //site.date;
  String siteListColumn3Value =
      ''; //collectors, need to create the list of names
  String siteListColumn4Value = ''; //Precise location
  String siteListColumn5Value = ''; //'National Park (select)';
  String siteListColumn6Value = ''; //'State Conservation Area (select)';
  String siteListColumn7Value = ''; //'State Forest (select)';
  String siteListColumn8Value = ''; //'Nature Reserve (select)';
  String siteListColumn9Value = ''; //'Other tenure'; this is set below...
  String siteListColumn10Value = ''; //'Soil colour';
  String siteListColumn11Value = ''; //'Soil Texture';
  String siteListColumn12Value =
      ''; //'Disturbance and fire history (can select multiple entries)'; pull apart the map
  String siteListColumn13Value = ''; //'Other (e.g. logged, cleared, etc.)';
  String siteListColumn14Value =
      ''; //'Landform primary (can select multiple entries)';
  String siteListColumn15Value = ''; //'Other landform';
  String siteListColumn16Value =
      ''; //'Habitat (select)'; //need to get the user friendly list
  String siteListColumn17Value = ''; //Other habitat
  String siteListColumn18Value = ''; //'Associated vegetation';

  //Species List Row
  String speciesListColumn1Value = ''; //ID site
  String speciesListColumn2Value =
      ''; //'Restore & Renew species list (select)';
  String speciesListColumn3Value = ''; //'Infraspecific rank';
  String speciesListColumn4Value = ''; // 'Infrasp. name';
  String speciesListColumn5Value = ''; // 'Species name if not on list';
  String speciesListColumn6Value =
      ''; // 'Genetic sample 1 barcode number (autofills from scan)';
  String speciesListColumn7Value = ''; // 'Location Lat';
  String speciesListColumn8Value = ''; // 'Location Long';
  String speciesListColumn9Value = ''; // 'Location Acc';
  String speciesListColumn10Value = ''; // 'Location Alt';
  String speciesListColumn11Value =
      ''; // 'Voucher barcode number (autofills from scan)';
  String speciesListColumn12Value = ''; // 'Genetic sample taken from voucher?';
  String speciesListColumn13Value = ''; // 'If YES which genetic sample number';
  String speciesListColumn14Value = ''; // 'Reproductive state';
  String speciesListColumn15Value = ''; // 'Flowers (select one or more)';
  String speciesListColumn16Value = ''; // 'Fruit (select one or more)';
  String speciesListColumn17Value =
      ''; // 'Number of plants within a radius of 10 m';
  String speciesListColumn18Value = ''; // 'Adults Present';
  String speciesListColumn19Value = ''; // 'Juveniles Present';
  String speciesListColumn20Value = ''; // 'Population Notes:';
  String speciesListColumn21Value =
      ''; //Incidental Observation // Species sighted, absent or probable misID (select)
  String speciesListColumn22Value = ''; // Species ID
  String speciesListColumn23Value =
      ''; // fieldNumberSample (instead of barcode or as well as in the future)
  String speciesListColumn24Value =
      ''; // CollectorsIDV for the voucher instead of barcode
  String speciesListColumn25Value =
      ''; // Flag Notes //Collection Notes, flag notes
  //String speciesListColumn26Value = ''; // Collection type, sample, voucher, flag
  String speciesListColumn27Value = ''; // Collection ID
  String speciesListColumn28Value = ''; // Individuals ID

  double siteLat = 0.0;
  double siteLon = 0.0;
  int siteAcc = 0;
  int siteAlt = 0;

  String rnrAddress = "restore.renew@rbgsyd.nsw.gov.au";

//DATABASE METHODS______________________________________________________//

//-------------------------------------------------------------------//
  doExport() async {
//build the first line with the headings for each spreadsheet
    _buildSiteHeadings();
    _buildSpeciesHeadings();
    var siteListdataOK = _uploadCheckSites(siteList);

//var siteListdataOK = siteList.where((site) => site.dataOK != false);

//-------------------------------------------------------------------//
//Build the sites spreadsheet
    for (var site in siteListdataOK) {
//don't want the site details exported but we do want to export the species fields?

      //for (var site in sites) {
      siteLat = site.lat;
      siteLon = site.lon;
      siteAcc = site.acc;
      siteAlt = site.alt;

      siteListColumn1Value = site.id;
      siteListColumn2Value = site.date; //site.date; ?
      siteListColumn3Value =
          site.getCollectors(); //collectors, need to create the list of names
      siteListColumn4Value =
          site.description; //Precise location //aka description
      siteListColumn5Value = site.getNationalPark(); //'National Park (select)';
      siteListColumn6Value =
          site.getStateConservationArea(); //'State Conservation Area (select)';
      siteListColumn7Value = site.getStateForest(); //'State Forest (select)';
      siteListColumn8Value =
          site.getNatureReserve(); //'Nature Reserve (select)';
      siteListColumn9Value =
          _getTenure(site); //'Other tenure'; this is set below...
      siteListColumn10Value = site.soilColour; //'Soil colour';
      siteListColumn11Value = site.soilTexture; //'Soil Texture';
      siteListColumn12Value = site
          .getDisturbances(); //'Disturbance and fire history (can select multiple entries)'; pull apart the map
      siteListColumn13Value =
          site.disturbanceOther; //'Other (e.g. logged, cleared, etc.)';
      siteListColumn14Value = site
          .getLandForms(); //'Landform primary (can select multiple entries)';
      siteListColumn15Value = site.landFormOther; //'Other landform';
      siteListColumn16Value = site
          .getHabitats(); //'Habitat (select)'; //need to get the user friendly list
      siteListColumn17Value = site.habitatOther; //Other habitat
      siteListColumn18Value = site.sAssociated; //'Associated vegetation';
      siteListExport = siteListExport + '\n' + _buildSiteLine();
    }

    String fileName = 'site_' + creationDate.toString() + '.txt';
    File siteFile = await fh.writeFile(fileName, siteListExport);

//______________________________________________________________
//species spreadsheet
//loop through the site list and build the collection records

    for (Site site in siteListdataOK) {
      //if (site.dataOK != false){
      //print('site list length: ' + siteListdataOK.length.toString());

      var siteFK = site.id;
      List<Population> populationList = await _getPopulationList(siteFK);

      //now loop through the populations
      for (var population in populationList) {

        List<Individual> individualsList = population.sIndividualsList;
        Individual individual;
        String noteTextPop = '';
        


        for (individual in individualsList) {
          //is there only one collection in the list and is it a 'note' if so grab it's text
          if(individual.collectionList.length == 1 && individual.collectionList[0].type == typeNote){
            Collection note = individual.collectionList[0];
            noteTextPop  = population.notes + ' ' + note.sNote;
          }
        }

        speciesListColumn1Value = siteFK; //ID site id?

        if (population.notOnList == false) {
          speciesListColumn2Value =
              population.nameGenus + ' ' + population.nameSpecies;
          speciesListColumn5Value = '';
        }

        speciesListColumn3Value = population.nameRank; //'Infraspecific rank';
        speciesListColumn4Value = population.nameRankName; // 'Infrasp. name';

        if (population.notOnList == true) {
          speciesListColumn2Value = '';
          speciesListColumn5Value = population.name;
        }

        speciesListColumn14Value =
            population.reproductiveState; // 'Reproductive state';
        speciesListColumn15Value =
            population.getFlowers(); // 'Flowers (select one or more)';
        speciesListColumn16Value =
            population.getFruits(); // 'Fruit (select one or more)';
        speciesListColumn17Value = population
            .plantsPresent; // 'Number of plants within a radius of 10 m';
        speciesListColumn18Value =
            population.adultsPresent; // 'Adults Present';
        speciesListColumn19Value =
            population.juvenilesPresent; // 'Juveniles Present';
        speciesListColumn20Value = noteTextPop; // population.notes// 'Notes:';

        speciesListColumn22Value = population.id; //Species ID

        //print('Species list name: ' + species.name);

        //______________________________________________________________
        //species spreadsheet
        //List<Individual> individualsList = population.sIndividualsList;
        //Individual individual;

        //need to loop through the individuals to get all the collections...

        for (var i = 0; i < individualsList.length; i++) {
          individual = individualsList[i];

          //should only be one note per individual atm...
          List<Collection> noteList = individual.collectionList
              .where((i) => i.type == typeNote)
              .toList();
          String noteText = '';

          for (Collection note in noteList) {
            //if (note.sNote.isNotEmpty) {
              noteText = note.sNote;
            //}
          }

          List<Collection> collectionList = individual.collectionList
              .where((i) => i.type != typeNote)
              .toList();

          //List<Collection> collectionList = individual.collectionList;
          Collection collection;

          for (var i = 0; i < collectionList.length; i++) {
            collection = collectionList[i];

//if the user typed in an nsw instead of scanning it then put it in the sample barcode field
            if (collection.type == typeSample) {
              speciesListColumn6Value = collection
                  .barcode; // Sample Barcode, 'Genetic sample 1 barcode number (autofills from scan)';
              if (speciesListColumn6Value.isEmpty) {
                String lowerCaseNumber = collection.collectorsID.toLowerCase();
                if (lowerCaseNumber.startsWith('nsw')) {
                  speciesListColumn6Value = collection.collectorsID;
                }
              }
            }
//if the collectors id was used in the sample barcode field then don't use it in the collectors id field
            if (speciesListColumn6Value != collection.collectorsID &&
                collection.type == typeSample) {
              speciesListColumn23Value = collection.collectorsID;
            } else {
              speciesListColumn23Value = '';
            }
            //end type sample

            //reset the voucher number
            speciesListColumn11Value = '';

            if (collection.type == typeVoucher) {
              //if its a voucher set the voucher barcode and collector id fields
              speciesListColumn11Value = collection
                  .barcode; // 'Voucher barcode number (autofills from scan)';
              if (speciesListColumn11Value.isEmpty) {
                String lowerCaseNumber = collection.collectorsID.toLowerCase();
                if (lowerCaseNumber.startsWith('nsw')) {
                  speciesListColumn11Value =
                      collection.collectorsID; //collection.collectorsID;
                }
              }
            }

            //if the collection id has been put into the voucher barcode id field then don't put it in the collectors id field
            if (speciesListColumn11Value != collection.collectorsID &&
                collection.type == typeVoucher) {
              speciesListColumn24Value = collection.collectorsID;
            } else {
              speciesListColumn24Value = '';
            }
            //end type voucher

            speciesListColumn21Value = collection.type; //sample, voucher, sighted, notSighted, Note etc

            //Notes for Sighted and Not Sighted records need to be written into the collection Notes field otherwise write the note for the individual
            speciesListColumn25Value = (collection.type == typeSighted || collection.type == typeNotSighted)? collection.note : noteText; 
            //speciesListColumn26Value = collection.type; // Collection type, sample, voucher, flag
            speciesListColumn27Value = collection.id;
            speciesListColumn28Value = individual.id;
            print("here: " + speciesListColumn28Value);

            if (individual.gpsType == 'site') {
              speciesListColumn7Value = siteLat.toString();
              speciesListColumn8Value = siteLon.toString();
              speciesListColumn9Value = siteAcc.toString();
              speciesListColumn10Value = siteAlt.toString();
            } else {
              speciesListColumn7Value = individual.lat.toString();
              speciesListColumn8Value = individual.lon.toString();
              speciesListColumn9Value = individual.acc.toString();
              speciesListColumn10Value = individual.alt.toString();
            }

            //does the individual have a sample and a voucher??
            var sampleList = collectionList
                .where((collection) => collection.type == typeSample);
            var voucherList = collectionList
                .where((collection) => collection.type == typeVoucher);

            if (sampleList.length > 0 && voucherList.length > 0 && collection.type == typeVoucher) {
              speciesListColumn12Value = 'yes'; // 'Genetic sample taken from voucher?';
              speciesListColumn13Value = '1'; // this will be 1 'If YES which genetic sample number';
            } else {
              speciesListColumn12Value = ''; // 'Genetic sample taken from voucher?';
              speciesListColumn13Value = ''; // this will be 1 'If YES which genetic sample number';
            }

            //ignore collection records that hold the plus button //think I fixed this but no harm in leaving it...
            if (collection.type != 'delete') {
              speciesListExport =
                  speciesListExport + '\n' + _buildSpeciesLine();
            }
          }
        }



      }
    }

    //vars for emailing
    String speciesFileName = 'species_' + creationDate.toString() + '.txt';
    File speciesFile = await fh.writeFile(speciesFileName, speciesListExport);
    String loggedInName = user.name;
    String loggedInEmail = user.email;


    //send the data to me
    await _sendMail(siteFile, speciesFile, loggedInName, 'brendanwilde@optusnet.com.au');
    
    //send data to the logged in users email...
    bool emailResult = await _sendMail(
        siteFile, speciesFile, loggedInName, loggedInEmail,
        );

    //if an rnr user send to rnr

  
    
    if (user.password.length != 0) { 
      print('has a password for rnr');
      emailResult = await _sendMail(
          siteFile, speciesFile, loggedInName, 
          //loggedInEmail, 
          rnrAddress);
    }





    if (emailResult == true) {
      //set site uploaded flags to true
      for (var site in siteListdataOK) {
        site.sDataUploaded = true;
      }

      _saveSiteList();


     

      return true;
    } else {
      return false;
    }
  }

//-------------------------------------------------------------------//
  _sendMail(File siteFile, File speciesFile, String loggedInName,

    String sendtoEmail) async {
    FileAttachment attachment1 = FileAttachment(siteFile);
    FileAttachment attachment2 = FileAttachment(speciesFile);

    String username = 'restoreandrenewdata@gmail.com';
    //String password = 'D5Q-bq7-mCs-n7M'; //encode?
    String password = 'hceewpqyfgzxhlwe';

    final smtpServer = gmail(username, password);

    // Create our message.
    final message = new Message()
      ..from = new Address(username, 'Restore & Renew Data')

      //..bccRecipients.add(new Address('$loggedInEmail'))
      ..bccRecipients.add(new Address('$sendtoEmail'))
      //..bccRecipients.add(new Address('brendanwilde@optusnet.com.au'))
      ..subject = 'From $loggedInName'
      ..text = ''
      ..attachments.add(attachment1)
      ..attachments.add(attachment2)
      ..html =
          "<h1>Restore & Renew Data</h1>\n<p>${creationDate.toString()}</p>";


    bool result = false;
    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      result = true;
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }


    return result;
  } //end sendMail

//-------------------------------------------------------------------//
  _getPopulationList(String siteId) async {
    //bring in from database
    var populationList = await db.getPopulationList(siteId);
    populationList.sort((a, b) => a.name.compareTo(b.name));
    return populationList;
  }

//-------------------------------------------------------------------//
  String _getTenure(Site site) {
    if ((siteListColumn5Value == "") &
        (siteListColumn6Value == "") &
        (siteListColumn7Value == "") &
        (siteListColumn8Value == "")) {
      return site.tenure;
    }
    return "";
  }

//-------------------------------------------------------------------//
  String _buildSiteLine() {
    return siteListColumn1Value +
        delimiter +
        siteListColumn2Value +
        delimiter +
        siteListColumn3Value +
        delimiter +
        siteListColumn4Value +
        delimiter +
        siteListColumn5Value +
        delimiter +
        siteListColumn6Value +
        delimiter +
        siteListColumn7Value +
        delimiter +
        siteListColumn8Value +
        delimiter +
        siteListColumn9Value +
        delimiter +
        siteListColumn10Value +
        delimiter +
        siteListColumn11Value +
        delimiter +
        siteListColumn12Value +
        delimiter +
        siteListColumn13Value +
        delimiter +
        siteListColumn14Value +
        delimiter +
        siteListColumn15Value +
        delimiter +
        siteListColumn16Value +
        delimiter +
        siteListColumn17Value +
        delimiter +
        siteListColumn18Value;
  }
  //First line for a site

  //-------------------------------------------------------------------//
  String _buildSpeciesLine() {
    return speciesListColumn1Value +
        delimiter +
        speciesListColumn22Value +
        delimiter +
        speciesListColumn28Value +
        delimiter +
        speciesListColumn27Value +
        delimiter +
        speciesListColumn2Value +
        delimiter +
        speciesListColumn3Value +
        delimiter +
        speciesListColumn4Value +
        delimiter +
        speciesListColumn5Value +
        delimiter +
        speciesListColumn6Value +
        delimiter +
        speciesListColumn7Value +
        delimiter +
        speciesListColumn8Value +
        delimiter +
        speciesListColumn9Value +
        delimiter +
        speciesListColumn10Value +
        delimiter +
        speciesListColumn11Value +
        delimiter +
        speciesListColumn12Value +
        delimiter +
        speciesListColumn13Value +
        delimiter +
        speciesListColumn14Value +
        delimiter +
        speciesListColumn15Value +
        delimiter +
        speciesListColumn16Value +
        delimiter +
        speciesListColumn17Value +
        delimiter +
        speciesListColumn18Value +
        delimiter +
        speciesListColumn19Value +
        delimiter +
        speciesListColumn20Value +
        delimiter +
        speciesListColumn21Value +
        delimiter +
        speciesListColumn23Value +
        delimiter +
        speciesListColumn24Value +
        delimiter +
        speciesListColumn25Value;
    //delimiter +
    //speciesListColumn26Value;
  }

  //-------------------------------------------------------------------//
  _buildSiteHeadings() {
    //First line for a site
    siteListExport = siteListColumn1 +
        delimiter +
        siteListColumn2 +
        delimiter +
        siteListColumn3 +
        delimiter +
        siteListColumn4 +
        delimiter +
        siteListColumn5 +
        delimiter +
        siteListColumn6 +
        delimiter +
        siteListColumn7 +
        delimiter +
        siteListColumn8 +
        delimiter +
        siteListColumn9 +
        delimiter +
        siteListColumn10 +
        delimiter +
        siteListColumn11 +
        delimiter +
        siteListColumn12 +
        delimiter +
        siteListColumn13 +
        delimiter +
        siteListColumn14 +
        delimiter +
        siteListColumn15 +
        delimiter +
        siteListColumn16 +
        delimiter +
        siteListColumn17 +
        delimiter +
        siteListColumn18;
  }

  //-------------------------------------------------------------------//
  _buildSpeciesHeadings() {
//First line for a species
    speciesListExport = speciesListColumn1 +
        delimiter +
        speciesListColumn22 +
        delimiter +
        speciesListColumn28 +
        delimiter +
        speciesListColumn27 +
        delimiter +
        speciesListColumn2 +
        delimiter +
        speciesListColumn3 +
        delimiter +
        speciesListColumn4 +
        delimiter +
        speciesListColumn5 +
        delimiter +
        speciesListColumn6 +
        delimiter +
        speciesListColumn7 +
        delimiter +
        speciesListColumn8 +
        delimiter +
        speciesListColumn9 +
        delimiter +
        speciesListColumn10 +
        delimiter +
        speciesListColumn11 +
        delimiter +
        speciesListColumn12 +
        delimiter +
        speciesListColumn13 +
        delimiter +
        speciesListColumn14 +
        delimiter +
        speciesListColumn15 +
        delimiter +
        speciesListColumn16 +
        delimiter +
        speciesListColumn17 +
        delimiter +
        speciesListColumn18 +
        delimiter +
        speciesListColumn19 +
        delimiter +
        speciesListColumn20 +
        delimiter +
        speciesListColumn21 +
        delimiter +
        speciesListColumn23 +
        delimiter +
        speciesListColumn24 +
        delimiter +
        speciesListColumn25;
    //delimiter +
    //speciesListColumn26;
  }

  //-------------------------------------------------------------------//
  _uploadCheckSites(List<Site> siteList) {
    var siteListdataOK = siteList.where((site) => site.dataOK != false);
    var siteListdataOK1 = siteListdataOK.where((site) => site.dataUploaded != true);
    return siteListdataOK1;
  } // end uploadCheckSites




//-------------------------------------------------------------------//
  _saveSiteList() {
    print('save site list: ' + siteList.length.toString());
    db.saveObjectList('site', siteList, '1');
  } //end _saveSite



} // end class





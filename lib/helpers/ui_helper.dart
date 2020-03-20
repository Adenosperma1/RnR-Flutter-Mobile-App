import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //for text input black list
import 'dart:math';

//Classes
import 'package:restoreandrenew/classes/site_class.dart';
import 'package:restoreandrenew/classes/population_class.dart';

//Helpers
import 'package:restoreandrenew/helpers/database_local_helper.dart'; //help create checklist

DatabaseHelper db = new DatabaseHelper();
String theFontFamily = 'Avenir';
String typeSample = 'Sample';
String typeVoucher = 'Voucher';
String typeFlag = 'Flag';
String typeSeed = 'Seed';
String typeNote = 'Note';
String typeSighted = 'Sighted';
String typeNotSighted = 'Not Sighted';

//-------------------------------------------------------------------//
bool uiIsDense() {
  return true;
} //end uiIsDense

//-------------------------------------------------------------------//
//Build a feild title
uiTitle(String theTitle) {
  return Row(children: [
    Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: const EdgeInsets.only(bottom: 5.0, top: 20.0),
          child: Text(theTitle,
              style: TextStyle(
                  fontFamily: theFontFamily, fontWeight: FontWeight.w600)))
    ]))
  ]);
} //end uiTitle

//-------------------------------------------------------------------//
//Build a feild title
uiTitleSpecies(String theTitle) {
  return Row(children: [
    Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          //padding: const EdgeInsets.only(bottom: 5.0, top: 20.0),
          child: Text(theTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: theFontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                fontStyle: FontStyle.italic,
              )))
    ]))
  ]);
} //end uiTitleSpecies

uiGetRadius() {
  return BorderRadius.all(Radius.circular(5.0));
}

uiGetHeaderHeight() {
  double theHeight = 200;
  return theHeight;
}

//-------------------------------------------------------------------//
getBlackList(){
 return "[\"\']";
}

//-------------------------------------------------------------------//
//Build a field
uiField(
  List objects,
  var object,
  TextEditingController theController,
  String fieldName,
) 

{
  return TextField(
    controller: theController,
    inputFormatters: [BlacklistingTextInputFormatter(RegExp(getBlackList())),],
    textCapitalization: TextCapitalization.sentences,
    decoration: InputDecoration(
        contentPadding: fieldInset(),
        border:
            OutlineInputBorder(borderRadius: new BorderRadius.circular(0.0))),
    onChanged: (newValue) {
      //update the object
      object.set(fieldName, newValue);
      //update the database
      updateDBForObject(objects, object, newValue);
      print('UI Helper says: updated db for: ' + newValue);
    },
  );
} //end uiField

//-------------------------------------------------------------------//
//Build a field
uifieldLocked(TextEditingController theController) {
  return TextField(
    controller: theController,
    decoration: InputDecoration(
        contentPadding: fieldInset(),
        border:
            OutlineInputBorder(borderRadius: new BorderRadius.circular(0.0)),
        enabled: false),
    onChanged: (newValue) {},
  );
} //end uifieldLocked

//-------------------------------------------------------------------//
//Use this to change the size of the text fields
EdgeInsets fieldInset() {
  return EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0);
} //end fieldInset()

//-------------------------------------------------------------------//
Widget uiBuildAppBarWhite(BuildContext context, String title) {
  return AppBar(
      automaticallyImplyLeading: true,
      title: Text(title,
          style: TextStyle(
              fontFamily: theFontFamily,
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 20)),
      centerTitle: false,
      backgroundColor: Colors.white,
      elevation: 0.0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
        onPressed: () => Navigator.pop(context, false),
      ));
} //end uiBuildAppBarWhite

//-------------------------------------------------------------------//
uiClosePage1(BuildContext context) {
  Navigator.pop(context, ''); //send back an empty name
} //end uiClosePage

//-------------------------------------------------------------------//
//returns a readable string with a list of the checked items
String uiCheckListResult(Map<String, bool> theMap) {
  final filteredMap = new Map.fromIterable(
      theMap.keys.where((k) => theMap[k] == true),
      value: (k) => theMap[k]);
  String asString = filteredMap.keys.toString();
  return asString;
} //end uiCheckListResult

//-------------------------------------------------------------------//
//prepares the checkbox maps - converts a list into a map that has values of false
Map<String, bool> uiMapFromList(List theList) {
//need to check strings for odd characters???
  return Map.fromIterable(theList,
      key: (item) => item.toString(), value: (item) => false);
} //end uiMapFromList

//-------------------------------------------------------------------//
//Add space between interface elements
Container uiSpaceBelow(double amount) {
  return Container(
    child: new Text(""),
    margin: new EdgeInsets.fromLTRB(0.0, amount, 0.0, 0.0),
  );
} //end uiSpaceBelow

//-------------------------------------------------------------------//
Color uiGetPrimaryColor() {
  return Colors.black;
} //end uiGetPrimaryColor

//-------------------------------------------------------------------//
//Color uiGetSeedPackColor() {
  //return Color.fromRGBO(232, 223, 209, 1);
//} //end uiGetPrimaryColor


//-------------------------------------------------------------------//
//Color uiGetSightedColor() {
  //return uiGetGreenColor(); //Colors.green;
//} //end 

//-------------------------------------------------------------------//
//Color uiGetNotSightedColor() {
  //return Colors.red;
//} //end 

//-------------------------------------------------------------------//
//Color uiGetNoteColor() {
  //return Color.fromRGBO(253, 247, 193, 1);
  //return Colors.grey;
  //return Color.fromRGBO(255, 255, 102, 1);
//} //end 

//-------------------------------------------------------------------//
Color uiGetGreenColor() {
  return Color(0xFF9eaa38);
} //end uiGetGreenColor

//-------------------------------------------------------------------//
Color uicollectionRowBackGroundColor() {
  return Colors.white;
} //end uicollectionRowBackGroundColor

//-------------------------------------------------------------------//
Color uiiconImageColor() {
  return Colors.black54;
} //end uiiconImageColor

//-------------------------------------------------------------------//
Color uibuttonGreyColor() {
  return Colors.grey[100];
} //end uibuttonGreyColor

//-------------------------------------------------------------------//
//Color uibuttonyellowColor() {
  //return Color(uiHexStringToHexInt('#ffc300'));
//} //end uibuttonyellowColor

//-------------------------------------------------------------------//
//convert colour strings
int uiHexStringToHexInt(String hex) {
  hex = hex.replaceFirst('#', '');
  hex = hex.length == 6 ? 'ff' + hex : hex;
  int val = int.parse(hex, radix: 16);
  return val;
} //end uiHexStringToHexInt

//-------------------------------------------------------------------//
//round off the gps lat and long to four places
double uiRoundDouble(double theNumber, int places) {
  int fac = pow(10, places);
  theNumber = (theNumber * fac).round() / fac;
  return theNumber;
} //end uiRoundDouble

//-------------------------------------------------------------------//
//used by fields
updateDBForObject(
  List objects,
  var object,
  String newValue,
) {
  if (object is Site) {
    db.saveObjectList('site', objects, '1');
  } else if (object is Population) {
    //collections list is inside the species objects
    db.saveObjectList('population', objects, object.fkSite);
  }
} //end updateDBForObject

//HEADER WITH IMAGE//
//-------------------------------------------------------------------//
//-------------------------------------------------------------------//
//-------------------------------------------------------------------//

headerImage(double height, double width) {
  return Container(
    height: height,
    width: width,
    decoration: new BoxDecoration(
        image: DecorationImage(
      image: new AssetImage('assets/headerSmall.jpg'),
      fit: BoxFit.fill,
    )),
  );
} //end headerImage

//-------------------------------------------------------------------//
uiSubHeading(String subheading, double width) {
  double theFontSize = 22;
  return Container(
    width: width - 40,
    child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(subheading,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Helvetica',
                fontWeight: FontWeight.w200,
                fontSize: theFontSize,
                color: Colors.white,
              )),
        ]),
  );
}




//-------------------------------------------------------------------//
uiSpinnerWhite() {
  return SizedBox(
      height: 25.0,
      width: 25.0,
      child: CircularProgressIndicator(
          value: null,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
}


//-------------------------------------------------------------------//
forTypeUiSpinner(String type) {
  return SizedBox(
      height: 25.0,
      width: 25.0,
      child: CircularProgressIndicator(
          value: null,
          valueColor: AlwaysStoppedAnimation<Color>(forTypeFontColor(type))));
}

//-------------------------------------------------------------------//
uiSpinnerBlack() {
  return SizedBox(
      height: 25.0,
      width: 25.0,
      child: CircularProgressIndicator(
          value: null,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black)));
}

//-------------------------------------------------------------------//
Icon uiButtonIcon(String flagType) {
  Color theColor = Colors.grey;
  var theIcon;

  if (flagType == typeSighted) {
    theColor = uiGetGreenColor();
    theIcon = forTypeIcon(typeSighted);
  } else if (flagType == typeNotSighted) {
    theColor = Colors.red;
    theIcon = forTypeIcon(typeNotSighted);
  } else if (flagType == typeNote) {
    theColor = Colors.grey;
    theIcon =  forTypeIcon(typeNote);
  }


  return Icon(
    theIcon,
    size: 24.0,
    color: theColor,
  );
}

//-------------------------------------------------------------------//
uiGetPlantNameStyleSmall(String theText, int lines) {
  return Text(theText,
      maxLines: lines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontWeight: FontWeight.w100,
          fontSize: 14,
          fontFamily: 'Helvetica',
          fontStyle: FontStyle.italic,
          height: 1.1));
}

//-------------------------------------------------------------------//
uiGetSiteNameStyleSmall(String theText) {
  return Text(theText,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: 'Helvetica',
          fontSize: 16,
          fontStyle: FontStyle.normal,
          height: 1.1));
}

//-------------------------------------------------------------------//
uiGetGPSGreyBox(String theText) {
  return Container(
    color: Colors.grey.withOpacity(.2),
    height: 100.0,
    child: Center(
        child: Text(
      theText,
      style: TextStyle(height: 1.2),
      textAlign: TextAlign.center,
    )),
  );
}

//-------------------------------------------------------------------//
uiUploadedIcon() {
  return Icon(Icons.cloud_done, color: uiGetGreenColor(), size: 18.0);
}

//-------------------------------------------------------------------//
Icon uiErrorIcon(bool dataOK, Color theColor) {
  var theIcon;
  if (dataOK == false) {
    theIcon = Icons.report_problem;
  }
  return Icon(theIcon, color: theColor, size: 18.0);
}

Color colorSampleYellow(){
  return Color(uiHexStringToHexInt('#ffc300'));
}

Color colorVoucherGrey(){
  return Colors.grey[200];
}


//-------------------------------------------------------------------//
Color forTypeColor(String type) {
  Color theColor = Colors.white;

  if (type == typeSample) {
    theColor = colorSampleYellow();
   }else if (type == typeVoucher) {
   theColor = colorVoucherGrey();
  } else if (type == typeSeed) {
    theColor = Color.fromRGBO(232, 223, 209, 1);
  } else if (type == typeSighted) {
    theColor = uiGetGreenColor();
  } else if (type == typeNotSighted) {
    theColor = Colors.red;
  } else if (type == typeNote) {
    theColor = Colors.grey;
  }
  return theColor;
}



//-------------------------------------------------------------------//
Color forTypeColorForPopulationListIcons(String type) {
  Color theColor = Colors.white;

  if (type == typeSample) {
    theColor = colorSampleYellow();
  }if (type == typeVoucher) {
    theColor = colorVoucherGrey();
  } else if (type == typeSeed) {
    theColor = Color.fromRGBO(232, 223, 209, 1);
  } else if (type == typeSighted) {
    theColor = Colors.white;
  } else if (type == typeNotSighted) {
    theColor = Colors.white;
  } else if (type == typeNote) {
    theColor = Colors.white;
  }
  return theColor;
}


//-------------------------------------------------------------------//
forTypeIcon(String type){
var theIcon;
if (type == typeNote) {
    theIcon = Icons.subject;
} else if (type == typeNotSighted) {
    theIcon = Icons.visibility_off;
} else if (type == typeSighted) {
    theIcon = Icons.visibility;
} else {
    theIcon = null;
  }
  return theIcon;
}

//-------------------------------------------------------------------//
Color forTypeFontColor(String type){
Color theColor = Colors.black;

if (type == typeSighted) {
    theColor = Colors.white;
  } else if (type == typeNotSighted) {
    theColor = Colors.white;
  }else if (type == typeNote) {
    theColor = Colors.white;
  }

  return theColor;
}



//-------------------------------------------------------------------//
  newLine() {
    return Text('\n',
        style: TextStyle(
          height: .3,
        ));
  }


  //-------------------------------------------------------------------//
  uiAddPageIcon(String theType) {
    double smallIconHeight = 34;
double smallIconWidth = 25;
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
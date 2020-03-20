import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//Helpers
import 'package:restoreandrenew/helpers/database_inbetween_helper.dart';
import 'package:restoreandrenew/helpers/ui_helper.dart';

//Classes
import 'package:restoreandrenew/classes/user_class.dart';

//Pages
import 'package:restoreandrenew/pages/site_list_page.dart'; 
import 'package:restoreandrenew/pages/login_page.dart'; 
import 'package:restoreandrenew/pages/error_page.dart'; 


// Set log in screen as default home.
  Widget _defaultHome = new LoginPage();

  void main() async {

WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);


  String homePage = await ibGetHomePage();

  if(homePage == 'errorPage'){
    _defaultHome = ErrorPage();
  }else if(homePage == 'siteList'){
    User _loggedInUser = await ibGetLoggedInUser();
    _defaultHome = SiteList(user: _loggedInUser);
  }



  ThemeData buildTheme() {
  var mainColor = uiGetPrimaryColor();


  //final ThemeData base= ThemeData();
  //final ThemeData theTheme;
  //return base.copyWith(
    return ThemeData(

    fontFamily: 'Avenir',
    primaryColor: mainColor,
    accentColor: mainColor,

    
    scaffoldBackgroundColor: Colors.white,
    //primaryIconTheme: base.iconTheme.copyWith(color: Colors.white),
    buttonColor: mainColor,
    toggleableActiveColor: mainColor,  
    
    
  );
}//end theme


  runApp(new MaterialApp(
    title: 'App',
    home: _defaultHome,
    theme: buildTheme(), //rnrTheme,
  ));


}//end class

  
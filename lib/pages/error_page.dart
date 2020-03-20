import 'package:flutter/material.dart';


class ErrorPage extends StatefulWidget {
  static String tag = 'login-page';

  @override
  _ErrorPageState createState() => new _ErrorPageState();
}

class _ErrorPageState extends State<ErrorPage> {
  

//-------------------------------------------------------------------//
  Widget build(BuildContext context) {
    
    final errorLabel = FlatButton(
      child: Text(
        'No internet connection!', textAlign: TextAlign.center,
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 25.0, ),
      ),
      onPressed: () {},
    );

     final errorText = FlatButton(
      child: Text(
        'This app downloads data the first time it is started. \n Quit and run again when there is an internect connection.', textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black87  ),
      ),
      onPressed: () {},
    );

    return 
    WillPopScope(//this stops the Android OS back button
    onWillPop: () async => false,
    child:   
    
    Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
           
            IconButton(
            icon: Icon(Icons.cloud_off, color: Colors.red, ),
            iconSize: 90.0,
            
            onPressed: null,
          ),

          errorLabel,
          errorText,
          ],
        ),
      ),
    ));
  }

} //end class

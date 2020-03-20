import 'package:flutter/material.dart';

//helpers
//import 'package:restoreandrenew/helpers/database_local_helper.dart';
import 'package:restoreandrenew/helpers/ui_helper.dart';

//Pages
import 'package:restoreandrenew/pages/login_public_page.dart';
import 'package:restoreandrenew/pages/login_private_page.dart';






//DatabaseHelper db = new DatabaseHelper();

class LoginPage extends StatefulWidget {
  //static String tag = 'login-page'; //what's this doing???

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    return super.initState();
  }

//-------------------------------------------------------------------//
Widget build(BuildContext context) {
    

final collectForMe = Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: RaisedButton(
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: uiGetRadius(),),
        onPressed: () =>  _collectForMe(context),
        padding: EdgeInsets.all(12),
        color: uiGetGreenColor(), //uiGetPrimaryColor(),
        child: Text('MYSELF', style: TextStyle(color: Colors.white)),
      ),
    );


    final collectForRnR = Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: RaisedButton(
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: uiGetRadius(), 
        ),
        onPressed: () => _collectForRnR(context),
        padding: EdgeInsets.all(12),
        color: uiGetGreenColor(), //uiGetPrimaryColor(),
        child: Text('RESTORE & RENEW', style: TextStyle(color: Colors.white)),
      ),
    );


//-------------------------------------------------------------------//
//Draw interface
    return 
    WillPopScope(//this stops the Android OS back button
    onWillPop: () async => false,
    child:   
    
    Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                child: SafeArea(
                    top: false,
                    bottom: false,
                    child: new Form(
                      child: Center(
                        child: ListView(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(left: 24.0, right: 24.0),
                          children: <Widget>[
                           Text("I'm collecting for...", textScaleFactor: 1.5,),
                            SizedBox(height: 20.0),
                            collectForMe,
                            collectForRnR
                          ],
                        ),
                      ),
                    )))
          ],
        ))));
  }


  //-------------------------------------------------------------------//
  _collectForMe(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPagePublic()));
  }

   //-------------------------------------------------------------------//
  _collectForRnR(BuildContext context) {
     Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPagePrivate())); 
  }
  
} //end class

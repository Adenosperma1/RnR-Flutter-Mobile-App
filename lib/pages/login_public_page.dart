import 'package:flutter/material.dart';

//helpers
import 'package:restoreandrenew/helpers/database_local_helper.dart';
import 'package:restoreandrenew/helpers/ui_helper.dart';



//Classes
import 'package:restoreandrenew/classes/user_class.dart';

//Pages
import 'package:restoreandrenew/pages/site_list_page.dart';

DatabaseHelper db = new DatabaseHelper();

class LoginPagePublic extends StatefulWidget {
  //userNamestatic String tag = 'login-page';

  @override
  _LoginPagePublicState createState() => new _LoginPagePublicState();
}

class _LoginPagePublicState extends State<LoginPagePublic> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();

  @override
  void initState() {
    return super.initState();
  }

//-------------------------------------------------------------------//
  Widget build(BuildContext context) {

    final email = TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Email data to...',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(0.0)),
      ),
    );

    final userName = TextFormField(
      controller: userNameController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'My Name',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(0.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: uiGetRadius(),
        ),
        onPressed: () => _checkDetails(context),
        padding: EdgeInsets.all(12),
        color: uiGetGreenColor(), //uiGetPrimaryColor(),
        child: Text('START COLLECTING', style: TextStyle(color: Colors.white)),
      ),
    );

//-------------------------------------------------------------------//
    return 
    //WillPopScope(//this stops the Android OS back button
   // onWillPop: () async => false,
   // child:   
    
    
    Scaffold(
        backgroundColor: Colors.white,
        appBar: _appbar(),
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
                            //logo,
                            //SizedBox(height: 48.0),
                            //uiTitle("Name"),
                            userName,
                            SizedBox(height: 8.0),
                            //uiTitle("Email my data to"),
                            email,
                            SizedBox(height: 24.0),
                            loginButton,
                          ],
                        ),
                      ),
                    )))
          ],
        ))
        //)
        );
  }



//-------------------------------------------------------------------//
_checkDetails(BuildContext context) async {
    print('Login says: checkDetails');

    bool letEmIn = false;
    
    String userName = userNameController.text;
    String email = emailController.text;
    User user;

    bool emailCheck = _checkEmail(email);
    
    if (emailCheck == true) {
      if(userName.length != 0){

            //make a user object
            String id = '100';
            String initial = userName[0].substring(0, 1);
            bool admin = false;
            user = new User(id, userName, email, "", initial,  admin, false, false, false);
            //The database method expects a list so add it to a list
            List<User> userList = new List();
            userList.add(user);

            //save to database
            _saveUser(userList);
            letEmIn = true;
          }
        }


    if (letEmIn == true) {
      print('let em in');

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SiteList(user: user)),
      );
    } else {
      print('lock em out');
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: new Text("Alert"),
                content: new Text('Need a Name and Email!'),
                actions: <Widget>[
                  new FlatButton(
                      color: Colors.black,
                      textColor: Colors.white,
                      child: new Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                ]);
          });}
  } //end


//-------------------------------------------------------------------//
_checkEmail(String email){
bool emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
return emailValid;
}

//-------------------------------------------------------------------//
  _saveUser(List<User> userList) {
    db.saveObjectList('user', userList, '1');
  }


  //-------------------------------------------------------------------//
  _appbar() {
    return AppBar(
      iconTheme: IconThemeData(
            color: Colors.black, 
          ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
    );
  }//_appBar()


  
} //end class

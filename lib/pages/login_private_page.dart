import 'package:flutter/material.dart';

//helpers
import 'package:restoreandrenew/helpers/database_local_helper.dart';
import 'package:restoreandrenew/helpers/ui_helper.dart';



//Classes
import 'package:restoreandrenew/classes/user_class.dart';

//Pages
import 'package:restoreandrenew/pages/site_list_page.dart';

DatabaseHelper db = new DatabaseHelper();

class LoginPagePrivate extends StatefulWidget {
  static String tag = 'login-page';

  @override
  _LoginPagePrivateState createState() => new _LoginPagePrivateState();
}

class _LoginPagePrivateState extends State<LoginPagePrivate> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    return super.initState();
  }

//-------------------------------------------------------------------//
  Widget build(BuildContext context) {
    


    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 60.0,
        child: Image.asset('assets/title.png'),
      ),
    );

    final email = TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Email',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(0.0)),
      ),
    );

    final password = TextFormField(
      controller: passwordController,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Password',
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
          //BorderRadius.circular(0.0),
        ),
        onPressed: () => _checkDetails(context),
        padding: EdgeInsets.all(12),
        color: uiGetGreenColor(), //uiGetPrimaryColor(),
        child: Text('LOG IN', style: TextStyle(color: Colors.white)),
      ),
    );

    return 
   // WillPopScope(//this stops the Android OS back button
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
                            logo,
                            SizedBox(height: 48.0),
                            email,
                            SizedBox(height: 8.0),
                            password,
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

    var availableUserLocal = new List();
    availableUserLocal = await db.getObjectList('availableUser');
    bool letEmIn = false;

    String email = emailController.text;
    String password = passwordController.text;
    User user;

    if (availableUserLocal.length != 0) {
      print('Login says: There are local users');

      for (final aUser in availableUserLocal) {
        print('admin: ' + aUser.admin.toString());
        if (aUser.email.toString().toLowerCase() == email.toLowerCase()) {
          print('Email Match!');
          if (aUser.password.toString().toLowerCase() == password.toLowerCase()) {
            print('Password Match!');

            //make a user object
            user = new User(aUser.id, aUser.name, aUser.email, aUser.password,
                aUser.initials,  aUser.admin, false, false, false); //true is setting this user as an rnrUser
            //The database method expects a list so add it to a list
            List<User> userList = new List();
            userList.add(user);

            //save to database
            _saveUser(userList);
            letEmIn = true;
          }
        }
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
                title: new Text("Login Failed"),
                content: new Text('Wrong Email or Password!'),
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
  _saveUser(List<User> userList) {
    //db.saveUser(userList);
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

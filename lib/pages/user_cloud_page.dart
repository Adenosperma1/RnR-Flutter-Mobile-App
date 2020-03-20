import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //for text input black list

//Classes
import 'package:restoreandrenew/classes/user_available_class.dart'; //Species class

//Helpers
import 'package:restoreandrenew/helpers/database_local_helper.dart';
import 'package:restoreandrenew/helpers/database_remote_helper.dart';

import 'package:restoreandrenew/helpers/ui_helper.dart';

//Pages

//-------------------------------------------------------------------//
class UserCloud extends StatefulWidget {
  final int position;
  final users;
  //final List users;

  UserCloud({
    Key key,
    @required this.users,
    this.position,
  }) : super(key: key); //hand in the Species from the previous context

  @override
  _UserCloudState createState() => _UserCloudState();
}

//-------------------------------------------------------------------//
class _UserCloudState extends State<UserCloud> {
  DatabaseHelper db = new DatabaseHelper();

  String availableType = 'availableUser';

//-------------------------------------------------------------------//
//Controllers for normal fields
  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController initialsController = TextEditingController();


  bool admin;
  bool unsaved = false;
  bool saving = false;

  AvailableUser user;

//-------------------------------------------------------------------//
  @override
  void initState() {
    user = widget.users[widget.position];

    //normal fields
    idController.text = user.id;
    nameController.text = user.name;
    //nameController.text = user.name;
    emailController.text = user.email;
    passwordController.text = user.password;
    initialsController.text = user.initials;

 

    //bool field
    if (user.admin == null) {
      admin = false;
    } else {
      admin = user.admin;
    }

    return super.initState();
  } //end initState

//-------------------------------------------------------------------//
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(context, ''), body: _buildBody(context));
  } //end build

//-------------------------------------------------------------------//
  Widget _buildAppBar(BuildContext context, String title) {
    return AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        centerTitle: false,
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Text(title,
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 19)),

        // action button
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete_outline, size: 30.0),
            onPressed: () {
              _dialogRemoveUser(context);
            },
          ),
        ]);
  } //end _buildAppBar

//-------------------------------------------------------------------//
  Widget _buildBody(BuildContext context) {
    return new SafeArea(
        top: false,
        bottom: false,
        child: new Form(
            autovalidate: true,
            child: new ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: <Widget>[
                  //uiTitleSite('Edit User'),
                  uiSpaceBelow(10),
                  _uiCheckBoxAdmin('Cloud Admin', 'admin'),
                  uiTitle('Name'),
                  _uiFieldSave(nameController),
                  uiTitle('Email'),
                  _uiFieldSave(emailController),
                  uiTitle('Password'),
                  _uiFieldSave(passwordController),
                  uiTitle('Initials'),
                  _uiFieldSave(initialsController),
                  uiSpaceBelow(20),
                  _showSaveButton(),
                  //ShowSaveButton(unsaved: unsaved, saving: saving,)
                ])));
  } //end _buildBody

//-------------------------------------------------------------------//

  _uiCheckBoxAdmin(String title, String fieldName) {
    return CheckboxListTile(
        value: admin,
        dense: uiIsDense(),
        title: new Text(title),
        controlAffinity: ListTileControlAffinity.leading,
        onChanged: (bool value) {
          setState(() {
            user.set(fieldName, value);
            admin = value;
            unsaved = true;
          });
        });
  }

//-------------------------------------------------------------------//
  _showSaveButton() {

    if (unsaved == true) {

      if (saving == true) {
        return _spinner();
      } else {
        return _buttonSave();
      }
    } else {
      return Container();
    }
  }

//-------------------------------------------------------------------//
  _spinner() {
    return Container(child: Column(children: <Widget>[uiSpinnerBlack()]));
  }

//-------------------------------------------------------------------//
  _buttonSave() {
    return new SizedBox(
      height: 45.0,
      child: ButtonTheme(
        child: FlatButton(
          child: Text('SAVE'),
          onPressed: () {
            _saveUser();
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          color: uiGetGreenColor(),
          textColor: Colors.white, //uiGetPrimaryColorDark(),
        ),
      ),
    );
  } //end _buttonSave

//-------------------------------------------------------------------//
  _saveUser() async {
    if (unsaved == true) {
//start the spinner?
      setState(() {
        saving = true;
      });


//update the local object
      user.set('name', nameController.text);
      user.set('email', emailController.text);
      user.set('password', passwordController.text);
      user.set('initials', initialsController.text);
      user.set('admin', user.admin);

//save to local database
      await db.saveObjectList('availableUser', widget.users, '1');

//update the firestore object
//TO DO make one write
//TO DO BUG if u change the users name it doesn't update in the UI on the home page

     await fsDocumentUpdateAsync('availableUser', user.id, 'name', user.name);
     await fsDocumentUpdateAsync('availableUser', user.id, 'email', user.email);
     await fsDocumentUpdateAsync(
          'availableUser', user.id, 'password', user.password);
     await fsDocumentUpdateAsync(
          'availableUser', user.id, 'initials', user.initials);
          await fsDocumentUpdateAsync(
          'availableUser', user.id, 'admin', admin);

      setState(() {
        unsaved = false;
        saving = false;
      });
    }
  } //end _saveUser

//-------------------------------------------------------------------//
//Build a field that doesn't save back to the database until the user hits the save button
  _uiFieldSave(
      //the object needs a bool called unsaved
      TextEditingController theController) {
    return TextField(
      controller: theController,
      inputFormatters: [BlacklistingTextInputFormatter(RegExp(getBlackList())),],
      decoration: InputDecoration(
          contentPadding: fieldInset(),
          border:
              OutlineInputBorder(borderRadius: new BorderRadius.circular(0.0))),
      onChanged: (newValue) {
        setState(() {
          unsaved = true;
        });
      },
    );
  } //end

//-------------------------------------------------------------------//
  _dialogRemoveUser(BuildContext context) {
    String name = user.name;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: new Text('Remove'),
              content: new Text(
                  name + '. \n \n This user will not be able to log in again!'),
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
                      _removeName(name);
                    }),
              ]);
        });
  } // end _dialogRemoveSpecies

//-------------------------------------------------------------------//
  _removeName(String name) async {
    Navigator.pop(context, 'remove');
  } //end removeName

} //class


//New classes that replace functions
//-------------------------------------------------------------------//




import 'package:chakh_le_flutter/static_variables/static_variables.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'main.dart';

class EditProfile extends StatefulWidget {
  final String email, mobile;

  EditProfile({this.email, this.mobile});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  @override
  Widget build(BuildContext context) {
    HomePage.isVisible = false;

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            MediaQuery.removePadding(
              removeTop: true,
              context: context,
              removeBottom: true,
              removeLeft: true,
              removeRight: true,
              child: Text(
                'EDIT ACCOUNT',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  fontFamily: 'Avenir-Black',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        leading: InkWell(
          child: Icon(Icons.arrow_back, color: Colors.black87),
          onTap: () {
            Navigator.pop(context);
            HomePage.isVisible = true;
          },
        ),
      ),
      body: Wrap(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme(
              data: ThemeData(cursorColor: Colors.red),
              child: TextFormField(
                initialValue: ConstantVariables.user['mobile'],
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                  fontFamily: 'Avenir',
                ),
                decoration: InputDecoration(
                  labelText: "PHONE NUMBER",
                  icon: Icon(Icons.phone_iphone),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                    fontFamily: 'Avenir',
                  ),
                  fillColor: Colors.redAccent
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme(
              data: ThemeData(
                cursorColor: Colors.red,
              ),
              child: TextFormField(
                initialValue: ConstantVariables.user['email'],
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                    fontFamily: 'Avenir'),
                decoration: InputDecoration(
                    labelText: "EMAIL ADDRESS",
                    icon: Icon(Icons.mail),
                    labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                        fontFamily: 'Avenir')),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 30.0),
            child: ButtonTheme(
              minWidth: MediaQuery.of(context).size.width,
              height: 45.0,
              child: RaisedButton(
                onPressed: () {
                  Fluttertoast.showToast(
                    msg: "Profile Updated Successfully!",
                    toastLength: Toast.LENGTH_LONG,
                    timeInSecForIos: 2,
                  );
                },
                child: Text(
                  'UPDATE',
                  style: TextStyle(
                      fontFamily: 'Avenir-Bold',
                      fontSize: 15.0,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
                color: Colors.red,
              ),
            ),
          )
        ],
      ),
    );
  }
}

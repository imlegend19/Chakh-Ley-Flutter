import 'dart:io';

import 'package:chakh_le_flutter/entity/api_static.dart';
import 'package:chakh_le_flutter/models/user_post.dart';
import 'package:chakh_le_flutter/pages/otp.dart';
import 'package:chakh_le_flutter/pages/text_field.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

String buttonText = "ENTER NAME";
bool enableSignUp = false;

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();

  static String mobile;
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController =
      TextEditingController(text: SignUpPage.mobile);

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(getButtonText);
    _emailController.addListener(getButtonText);
    _phoneController.addListener(getButtonText);
  }

  void getButtonText() {
    String regex =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(regex);

    if (_nameController.text.trim().length == 0) {
      setState(() {
        buttonText = "ENTER NAME";
        enableSignUp = false;
      });
    } else if (_phoneController.text.trim().length != 10) {
      setState(() {
        buttonText = "ENTER VALID PHONE";
        enableSignUp = false;
      });
    } else {
      setState(() {
        enableSignUp = true;
        buttonText = "SIGN UP";
      });
    }

    if (_emailController.text.trim() != '') {
      if (!regExp.hasMatch(_emailController.text.trim()))
        setState(() {
          buttonText = "ENTER VALID EMAIL";
          enableSignUp = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: ListView(
        controller: _scrollController,
        children: <Widget>[
          _buildAppBar(),
          _buildSignUp(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.grey.shade400,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: Navigator.of(context).pop),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, right: 5.0, bottom: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 5.0),
                  child: Text(
                    'SIGN UP',
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.0,
                      fontFamily: 'Avenir-Black',
                    ),
                  ),
                ),
                Text(
                  'Create a  account',
                  style: TextStyle(
                    fontFamily: 'Avenir-Bold',
                    fontSize: 13.0,
                    fontWeight: FontWeight.w300,
                    color: Colors.black54,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUp() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          buildTextField(Icons.person, 'Name', _nameController, context, false),
          buildTextField(
              Icons.email, 'Email', _emailController, context, false),
          buildTextField(
              Icons.phone, 'Phone Number', _phoneController, context, true),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 15.0),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 45.0,
                child: RaisedButton(
                  disabledColor: Colors.red.shade200,
                  color: Colors.redAccent,
                  disabledElevation: 0.0,
                  elevation: 3.0,
                  splashColor: Colors.red.shade200,
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15.0,
                      fontFamily: 'Avenir-Bold',
                      color: enableSignUp ? Colors.white : Colors.white70,
                    ),
                  ),
                  onPressed: enableSignUp
                      ? () {
                          setState(() {
                            enableSignUp = false;
                          });
                          registerUser();
                        }
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<http.Response> createPost(UserPost post) async {
    final response = await http.post(UserStatic.keyOTPRegURL,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: postUserToJson(post));

    return response;
  }

  registerUser() {
    UserPost post = UserPost(
      name: _nameController.text,
      email: _emailController.text,
      mobile: _phoneController.text,
    );

    createPost(post).then((response) {
      if (response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: "OTP has been sent to your registered email.",
          fontSize: 13.0,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIos: 2,
        );
        OTPBottomSheet.name = _nameController.text;
        OTPBottomSheet.email = _emailController.text;
        OTPBottomSheet.phone = _phoneController.text;
        showOTPBottomSheet(context, _phoneController.text, false);
      } else if (response.statusCode == 400) {
        Fluttertoast.showToast(
          msg: "Error! Please verify you credentials.",
          fontSize: 13.0,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIos: 2,
        );
      } else if (response.statusCode >= 500) {
        Fluttertoast.showToast(
          msg: "Sorry, something went wrong! A team of highly trained monkeys "
              "has been dispatched to deal with this situation.",
          fontSize: 13.0,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIos: 2,
        );
      }
    });
  }
}

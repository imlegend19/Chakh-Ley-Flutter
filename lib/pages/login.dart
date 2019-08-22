import 'dart:convert' as JSON;
import 'dart:io';

import 'package:chakh_le_flutter/entity/api_static.dart';
import 'package:chakh_le_flutter/models/user_post.dart';
import 'package:chakh_le_flutter/pages/otp.dart';
import 'package:chakh_le_flutter/pages/sign_up.dart';
import 'package:chakh_le_flutter/pages/text_field.dart';
import 'package:chakh_le_flutter/static_variables/static_variables.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:rounded_modal/rounded_modal.dart';

void showLoginBottomSheet(BuildContext context, String title, String msg) {
  showRoundedModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return LoginSheetContent(title, msg);
    },
    dismissOnTap: false,
  );
}

class LoginSheetContent extends StatefulWidget {
  @override
  _LoginSheetContentState createState() => _LoginSheetContentState();

  final String title, msg;

  LoginSheetContent(this.title, this.msg);
}

class _LoginSheetContentState extends State<LoginSheetContent> {
  TextEditingController loginPhoneController = TextEditingController();
  bool enableLoginContinue = false;

  @override
  void initState() {
    super.initState();
    loginPhoneController.addListener(validateLoginPhone);
  }

  @override
  Widget build(BuildContext context) {
    return loginBottomSheet();
  }

  Future<http.Response> createPost(LoginPost post) async {
    final response = await http.post(UserStatic.keyOtpURL,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: postLoginToJson(post));

    return response;
  }

  loginUserPost() {
    LoginPost post = LoginPost(
      destination: loginPhoneController.text,
      isLogin: "true",
    );

    createPost(post).then((response) async {
      if (response.statusCode == 201) {
        // print(response.body);
        Navigator.of(context).pop();
        showOTPBottomSheet(context, loginPhoneController.text, true);
        // showOTPBottomSheet(context, loginPhoneController.text, true);
        Fluttertoast.showToast(
          msg: "OTP has been sent to your registered email.",
          fontSize: 13.0,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIos: 2,
        );
        return "true";
      } else if (response.statusCode == 404) {
        SignUpPage.mobile = loginPhoneController.text;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignUpPage(),
          ),
        );

        return null;
      } else if (response.statusCode == 403) {
        // OTP requesting not allowed
        var json = JSON.jsonDecode(response.body);
        assert(json is Map);
        Navigator.of(context).pop();
        Fluttertoast.showToast(
          msg: json['detail'],
          fontSize: 13.0,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIos: 2,
        );

        return null;
      } else if (response.statusCode == 400) {
        await ConstantVariables.sentryClient.captureException(
          exception: Exception("Login User Failure"),
          stackTrace:
          '[statusCode : ${response.statusCode}, post: $post '
              'response.body: ${response.body}, response.headers: ${response.headers}]',
        );

        return null;
      } else if (response.statusCode >= 500) {
        await ConstantVariables.sentryClient.captureException(
          exception: Exception("Login User Failure"),
          stackTrace:
          '[statusCode : ${response.statusCode}, post: $post '
              'response.body: ${response.body}, response.headers: ${response.headers}]',
        );
        
        Fluttertoast.showToast(
          msg: "Sorry, something went wrong!",
          fontSize: 13.0,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIos: 2,
        );

        return null;
      } else {
        await ConstantVariables.sentryClient.captureException(
          exception: Exception("Login User Failure"),
          stackTrace:
          '[statusCode : ${response.statusCode}, post: $post '
              'response.body: ${response.body}, response.headers: ${response.headers}]',
        );
        
        var json = JSON.jsonDecode(response.body);
        assert(json is Map);
        Fluttertoast.showToast(
          msg: json['detail'],
          fontSize: 13.0,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIos: 2,
        );
        
        return null;
      }
    }).catchError((error) async {
      await ConstantVariables.sentryClient.captureException(
        exception: Exception("Login User Failure"),
        stackTrace:
        'error: ${error.toString()}',
      );
      
      return null;
    });
  }

  void validateLoginPhone() {
    if (loginPhoneController.text.length == 10) {
      setState(() {
        enableLoginContinue = true;
      });
    } else {
      setState(() {
        enableLoginContinue = false;
      });
    }
  }

  Widget loginBottomSheet() {
    return Container(
      alignment: Alignment.topCenter,
      height: MediaQuery.of(context).size.height * 0.35,
      child: Wrap(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 5.0, right: 5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, bottom: 5.0, left: 15.0),
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.0,
                      fontFamily: 'Avenir-Black',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    widget.msg,
                    style: TextStyle(
                      fontFamily: 'Avenir-Bold',
                      fontSize: 13.0,
                      fontWeight: FontWeight.w300,
                      color: Colors.black54,
                    ),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
          buildTextField(Icons.phone_android, 'Phone Number',
              loginPhoneController, context, false),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
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
                    'Continue',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15.0,
                      fontFamily: 'Avenir-Bold',
                      color:
                          enableLoginContinue ? Colors.white : Colors.white70,
                    ),
                  ),
                  onPressed: enableLoginContinue
                      ? () {
                          setState(() {
                            enableLoginContinue = false;
                          });
                          loginUserPost();
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
}

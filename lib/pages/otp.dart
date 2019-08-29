import 'dart:convert' as JSON;
import 'dart:io';

import 'package:chakh_ley_flutter/entity/api_static.dart';
import 'package:chakh_ley_flutter/models/user_post.dart';
import 'package:chakh_ley_flutter/models/user_pref.dart';
import 'package:chakh_ley_flutter/pages/profile_page.dart';
import 'package:chakh_ley_flutter/static_variables/static_variables.dart';
import 'package:chakh_ley_flutter/utils/parse_jwt.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_text_field/pin_code_text_field.dart';

import 'cart_page.dart';

void showOTPDialog(BuildContext context, String destination, bool decider) {
  showDialog(
    context: context,
    builder: (BuildContext bc) {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
          backgroundColor: Colors.white,
          elevation: 5.0,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xffF2F8F4),
        ),
        body: OTPBuilder(destination, decider),
        backgroundColor: Color(0xffF2F8F4),
      );
    },
  );
}

class OTPBuilder extends StatefulWidget {
  @override
  _OTPBuilderState createState() => _OTPBuilderState();

  final String destination;
  final bool decider;

  static String name, email, phone;

  OTPBuilder(this.destination, this.decider);
}

class _OTPBuilderState extends State<OTPBuilder> {
  @override
  Widget build(BuildContext context) {
    return otpSheet();
  }

  Widget otpSheet() {
    return SingleChildScrollView(
      child: Container(
        color: Color(0xffF2F8F4),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 30.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.width * 0.5,
                child: Image.asset("assets/otp.png"),
              ),
            ),
            Container(
              alignment: Alignment.topLeft,
              height: MediaQuery.of(context).size.height * 0.3,
              margin: const EdgeInsets.only(top: 5, left: 15, right: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Wrap(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 5.0),
                            child: Text(
                              'Verify OTP',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 15.0,
                                fontFamily: 'Avenir-Black',
                              ),
                            ),
                          ),
                          Text(
                            'OTP has been sent to your mobile.',
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
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: PinCodeTextField(
                        autofocus: false,
                        maxLength: 5,
                        onDone: (pin) {
                          widget.decider
                              ? verifyOTP(pin)
                              : verifyRegisterOTP(
                                  pin,
                                  OTPBuilder.name,
                                  OTPBuilder.phone == null
                                      ? widget.destination
                                      : OTPBuilder.phone,
                                  OTPBuilder.email,
                                );
                        },
                        pinBoxHeight: 50.0,
                        pinBoxWidth: 50.0,
                        defaultBorderColor: Colors.grey.shade800,
                        pinTextStyle: TextStyle(
                            fontFamily: 'Avenir-Black',
                            fontWeight: FontWeight.w700,
                            fontSize: 14.0,
                            color: Colors.black87),
                        pinTextAnimatedSwitcherTransition:
                            ProvidedPinBoxTextAnimation.scalingTransition,
                        pinTextAnimatedSwitcherDuration:
                            Duration(milliseconds: 150),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<http.Response> createOTPPost(VerifyLoginOTPPost post) async {
    final response = await http.post(
      UserStatic.keyOtpURL,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: postVerifyLoginOTPToJson(post),
    );

    print(response.statusCode);

    return response;
  }

  Future<http.Response> createRegisterOTPPost(var post) async {
    final response = await http.post(UserStatic.keyOTPRegURL,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: postUserOTPToJson(post));

    return response;
  }

  void verifyRegisterOTP(String pin, String name, String phone,
      [String email]) {
    UserOTPPost post =
        UserOTPPost(name: name, mobile: phone, email: email, verifyOTP: pin);

    createRegisterOTPPost(post).then((response) {
      validate(response);
    });
  }

  void verifyOTP(String pin) {
    VerifyLoginOTPPost post = VerifyLoginOTPPost(
        destination: widget.destination, isLogin: "true", verifyOTP: pin);

    createOTPPost(post).then((response) {
      validate(response);
    });
  }

  void saveUserCredentials(int id, String email, String mobile, String name) {
    ConstantVariables.user['email'] = email;
    ConstantVariables.user['mobile'] = mobile;
    ConstantVariables.user['name'] = name;
    ConstantVariables.user['id'] = "$id";
    ConstantVariables.userLoggedIn = true;

    saveUser(id, name, email, mobile);
    loginUser();
  }

  ///
  /// SAMPLE PAYLOAD DATA JWT
  ///
  /// {
  ///  "user_id": 1,
  ///  "is_admin": true,
  ///  "exp": 1563122247,
  ///  "email": "mahengandhi19@gmail.com",
  ///  "mobile": "9881745553",
  ///  "name": "Mahen Gandhi",
  ///  "username": "imlegend19"
  /// }
  ///

  void validate(http.Response response) {
    print("validate : ${response.statusCode}");
    if (response.statusCode == 403) {
      // OTP validation failed
      var json = JSON.jsonDecode(response.body);
      assert(json is Map);
      Fluttertoast.showToast(
        msg: json['detail'],
        fontSize: 13.0,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIos: 2,
      );
    } else if (response.statusCode == 202) {
      Fluttertoast.showToast(
        msg: "Logged In Successfully !!!",
        fontSize: 13.0,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIos: 2,
      );
      var json = JSON.jsonDecode(response.body);
      assert(json is Map);
      String token = json["token"];
      var decodedObject = parseJwt(token);
      saveUserCredentials(decodedObject['user_id'], decodedObject['email'],
          decodedObject['mobile'], decodedObject['name']);
      Navigator.of(context).pop();
      if (ProfilePage.callback == null) {
        CartPage.callback(0);
      } else {
        ProfilePage.callback(0);
      }
    } else {
      var json = JSON.jsonDecode(response.body);
      assert(json is Map);
      Fluttertoast.showToast(
        msg: "Some error occurred!",
        fontSize: 13.0,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIos: 2,
      );
    }
  }
}

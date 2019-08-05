import 'dart:convert' as JSON;
import 'dart:io';

import 'package:chakh_le_flutter/entity/api_static.dart';
import 'package:chakh_le_flutter/models/user_post.dart';
import 'package:chakh_le_flutter/models/user_pref.dart';
import 'package:chakh_le_flutter/static_variables/static_variables.dart';
import 'package:chakh_le_flutter/utils/parse_jwt.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:rounded_modal/rounded_modal.dart';

void showOTPBottomSheet(
    BuildContext context, String destination, bool decider) {
  showRoundedModalBottomSheet(
    context: context,
    builder: (BuildContext bc) {
      return OTPBottomSheet(destination, decider);
    },
    dismissOnTap: false,
  );
}

class OTPBottomSheet extends StatefulWidget {
  @override
  _OTPBottomSheetState createState() => _OTPBottomSheetState();

  final String destination;
  final bool decider;

  static String name, email, phone;

  OTPBottomSheet(this.destination, this.decider);
}

class _OTPBottomSheetState extends State<OTPBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return otpBottomSheet();
  }

  Widget otpBottomSheet() {
    return Container(
      alignment: Alignment.topLeft,
      height: MediaQuery.of(context).size.height * 0.3,
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
                    'Verify OTP',
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
                    'OTP has been sent to your email.',
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
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: PinCodeTextField(
                autofocus: false,
                maxLength: 5,
                onDone: (pin) {
                  widget.decider
                      ? verifyOTP(pin)
                      : verifyRegisterOTP(pin, OTPBottomSheet.name,
                          OTPBottomSheet.email, OTPBottomSheet.phone);
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
                pinTextAnimatedSwitcherDuration: Duration(milliseconds: 150),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<http.Response> createOTPPost(VerifyLoginOTPPost post) async {
    final response = await http.post(
      UserStatic.keyOtpURL,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
      body: postVerifyLoginOTPToJson(post),
    );

    return response;
  }

  Future<http.Response> createRegisterOTPPost(UserOTPPost post) async {
    final response = await http.post(UserStatic.keyOTPRegURL,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: postUserOTPToJson(post));

    return response;
  }

  void verifyRegisterOTP(String pin, String name, String email, String phone) {
    UserOTPPost post =
        UserOTPPost(name: name, email: email, mobile: phone, verifyOTP: pin);

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
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }
}

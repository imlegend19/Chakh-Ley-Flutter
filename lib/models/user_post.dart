import 'dart:convert';

class LoginPost {
  String destination;
  String isLogin;

  LoginPost({this.destination, this.isLogin});

  factory LoginPost.fromJson(Map<String, dynamic> json) =>
      LoginPost(
        destination: json["destination"],
        isLogin: json["is_login"],
      );

  Map<String, dynamic> toJson() =>
      {
        "destination": destination,
        "is_login": isLogin,
      };
}

String postLoginToJson(LoginPost data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class VerifyLoginOTPPost {
  String destination;
  String isLogin;
  String verifyOTP;

  VerifyLoginOTPPost({this.destination, this.isLogin, this.verifyOTP});

  factory VerifyLoginOTPPost.fromJson(Map<String, dynamic> json) =>
      VerifyLoginOTPPost(
          destination: json["destination"],
          isLogin: json["is_login"],
          verifyOTP: json["verify_otp"]
      );

  Map<String, dynamic> toJson() =>
      {
        "destination": destination,
        "is_login": isLogin,
        "verify_otp": verifyOTP
      };
}

String postVerifyLoginOTPToJson(VerifyLoginOTPPost data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class UserPost {
  String name;
  String email;
  String mobile;

  UserPost({
    this.name,
    this.email,
    this.mobile,
  });

  factory UserPost.fromJson(Map<String, dynamic> json) => UserPost(
        name: json["name"],
        email: json["email"],
    mobile: json["mobile"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
    "mobile": mobile,
      };
}

String postUserToJson(UserPost data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class UserOTPPost {
  String name;
  String email;
  String mobile;
  String verifyOTP;

  UserOTPPost({
    this.name,
    this.email,
    this.mobile,
    this.verifyOTP
  });

  factory UserOTPPost.fromJson(Map<String, dynamic> json) =>
      UserOTPPost(
          name: json["name"],
          email: json["email"],
          mobile: json["mobile"],
          verifyOTP: json["verify_otp"]
      );

  Map<String, dynamic> toJson() =>
      {
        "name": name,
        "email": email,
        "mobile": mobile,
        "verify_otp": verifyOTP
      };
}

String postUserOTPToJson(UserOTPPost data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}
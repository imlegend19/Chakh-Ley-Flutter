import 'dart:convert';

class LoginPost {
  String destination;
  String isLogin;

  LoginPost({this.destination, this.isLogin});

  factory LoginPost.fromJson(Map<String, dynamic> json) => LoginPost(
        destination: json["destination"],
        isLogin: json["is_login"],
      );

  Map<String, dynamic> toJson() => {
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
          verifyOTP: json["verify_otp"]);

  Map<String, dynamic> toJson() => {
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
  String mobile;
  String email;

  UserPost({
    this.name,
    this.mobile,
    this.email,
  });

  factory UserPost.fromJson(Map<String, dynamic> json) => UserPost(
        name: json["name"],
        mobile: json["mobile"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "mobile": mobile,
        "email": email,
      };
}

String postUserToJson(var data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class UserOTPPost {
  String name;
  String mobile;
  String email;
  String verifyOTP;

  UserOTPPost({this.name, this.mobile, this.email, this.verifyOTP});

  factory UserOTPPost.fromJson(Map<String, dynamic> json) => UserOTPPost(
      name: json["name"],
      mobile: json["mobile"],
      email: json["email"],
      verifyOTP: json["verify_otp"]);

  Map<String, dynamic> toJson() =>
      {"name": name, "mobile": mobile, "email": email, "verify_otp": verifyOTP};
}

String postUserOTPToJson(var data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

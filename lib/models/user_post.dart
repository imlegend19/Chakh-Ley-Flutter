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

  UserPost({
    this.name,
    this.mobile,
  });

  factory UserPost.fromJson(Map<String, dynamic> json) => UserPost(
        name: json["name"],
        mobile: json["mobile"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "mobile": mobile,
      };
}

class UserEmailPost {
  String name;
  String email;
  String mobile;

  UserEmailPost({
    this.name,
    this.email,
    this.mobile,
  });

  factory UserEmailPost.fromJson(Map<String, dynamic> json) => UserEmailPost(
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

String postUserToJson(var data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

String postUserEmailToJson(var data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class UserOTPPost {
  String name;
  String mobile;
  String verifyOTP;

  UserOTPPost({this.name, this.mobile, this.verifyOTP});

  factory UserOTPPost.fromJson(Map<String, dynamic> json) => UserOTPPost(
      name: json["name"],
      mobile: json["mobile"],
      verifyOTP: json["verify_otp"]);

  Map<String, dynamic> toJson() =>
      {"name": name, "mobile": mobile, "verify_otp": verifyOTP};
}

class UserEmailOTPPost {
  String name;
  String email;
  String mobile;
  String verifyOTP;

  UserEmailOTPPost({this.name, this.email, this.mobile, this.verifyOTP});

  factory UserEmailOTPPost.fromJson(Map<String, dynamic> json) =>
      UserEmailOTPPost(
        name: json["name"],
        email: json["email"],
        mobile: json["mobile"],
        verifyOTP: json["verify_otp"],
      );

  Map<String, dynamic> toJson() =>
      {"name": name, "email": email, "mobile": mobile, "verify_otp": verifyOTP};
}

String postUserOTPToJson(var data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

String postUserEmailOTPToJson(var data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

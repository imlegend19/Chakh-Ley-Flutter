import 'dart:async';

import 'package:chakh_ley_flutter/static_variables/static_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveUser(int id, String name, String email, String mobile) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("id", id);
  prefs.setString("name", name);
  prefs.setString("email", email);
  prefs.setString("mobile", mobile);
}

Future<void> initialPage(bool clicked) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('initial', clicked);
}

Future<bool> getInitialPageStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('initial');
}

Future<Map> getDetails() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Map<String, String> details = Map();
  details["id"] = "${prefs.getInt("id")}";
  details["name"] = prefs.getString("name");
  details["email"] = prefs.getString("email");
  details["mobile"] = prefs.getString("mobile");
  return details;
}

Future<int> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getInt("id");
}

Future<void> loginUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool("logged_in", true);
  ConstantVariables.userLoggedIn = true;
}

Future<void> logoutUser() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool("logged_in", false);
  ConstantVariables.userLoggedIn = false;
}

Future<bool> isLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool loggedIn = prefs.getBool("logged_in");
  return loggedIn == null ? false : loggedIn;
}

Future<int> getBusiness() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int business = prefs.getInt("business");
  return business == null ? 0 : business;
}

Future<void> setBusiness(int id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("business", id);
}

Future<void> setBusinessPosition(String latitude, String longitude) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList("position", [latitude, longitude]);
}

Future<List<String>> getBusinessPosition() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> businessPosition = prefs.getStringList("position");
  return businessPosition == null ? null : businessPosition;
}

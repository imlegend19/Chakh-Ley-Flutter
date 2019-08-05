import 'dart:async';

import 'package:chakh_le_flutter/entity/restaurant.dart';
import 'package:chakh_le_flutter/static_variables/static_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveRestaurant(Restaurant restaurant) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  ConstantVariables.cartRestaurant = restaurant;
  ConstantVariables.cartRestaurantId = restaurant.id;
  prefs.setInt("restaurant_id", restaurant.id).then((bool success) {
    return restaurant.id;
  });
}

Future<int> getRestaurant() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int id = prefs.getInt("restaurant_id");
  return id;
}

Future<bool> checkRestaurant(int id) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getInt("restaurant_id") == id) {
    return true;
  } else {
    return false;
  }
}

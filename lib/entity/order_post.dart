import 'dart:convert';

import 'package:chakh_ley_flutter/entity/api_static.dart';

class PostOrder {
  final String name;
  final String mobile;
  final String email;
  final int restaurant;
  final int business;
  final int preparationTime;
  final Map<String, dynamic> delivery;
  final List<Map<String, int>> subOrderSet;

  PostOrder({
    this.name,
    this.mobile,
    this.email,
    this.business,
    this.restaurant,
    this.preparationTime,
    this.delivery,
    this.subOrderSet,
  });

  factory PostOrder.fromJson(Map<String, dynamic> json) {
    return PostOrder(
      name: json[APIStatic.keyName],
      mobile: json[RestaurantStatic.keyMobile],
      email: json[RestaurantStatic.keyEmail],
      business: json[APIStatic.keyBusiness],
      preparationTime: json[RestaurantStatic.keyPreparationTime],
      restaurant: json[RestaurantStatic.keyRestaurant],
      delivery: json[RestaurantStatic.keyDelivery],
      subOrderSet: json[RestaurantStatic.keySubOrderSet],
    );
  }

  Map<String, dynamic> toJson() => {
        APIStatic.keyName: name,
        RestaurantStatic.keyMobile: mobile,
        RestaurantStatic.keyEmail: email,
        APIStatic.keyBusiness: business,
        RestaurantStatic.keyPreparationTime: preparationTime,
        RestaurantStatic.keyRestaurant: restaurant,
        RestaurantStatic.keyDelivery: delivery,
        RestaurantStatic.keySubOrderSet: subOrderSet,
      };
}

String postOrderToJson(PostOrder data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

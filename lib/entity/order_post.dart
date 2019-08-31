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
      mobile: json[APIStatic.keyMobile],
      email: json[APIStatic.keyEmail],
      business: json[APIStatic.keyBusiness],
      preparationTime: json[OrderStatic.keyPreparationTime],
      restaurant: json[OrderStatic.keyRestaurant],
      delivery: json[OrderStatic.keyDelivery],
      subOrderSet: json[OrderStatic.keySubOrderSet],
    );
  }

  Map<String, dynamic> toJson() => {
        APIStatic.keyName: name,
        APIStatic.keyMobile: mobile,
        APIStatic.keyEmail: email,
        APIStatic.keyBusiness: business,
        OrderStatic.keyPreparationTime: preparationTime,
        OrderStatic.keyRestaurant: restaurant,
        OrderStatic.keyDelivery: delivery,
        OrderStatic.keySubOrderSet: subOrderSet,
      };
}

String postOrderToJson(PostOrder data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

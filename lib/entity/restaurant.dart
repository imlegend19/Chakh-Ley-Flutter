import 'dart:convert';

import 'package:chakh_ley_flutter/static_variables/static_variables.dart';
import 'package:http/http.dart' as http;

import 'api_static.dart';

class Restaurant {
  final int id;
  final String name;
  final bool isActive;
  final int businessId;
  final String costForTwo;
  final int deliveryTime;
  final List<dynamic> cuisines;
  final bool isVeg;
  final bool open;
  final int categoryCount;
  final List<dynamic> images;
  final String packagingCharge;
  final bool gst;
  final String ribbon;
  final String fullAddress;

  Restaurant({
    this.id,
    this.name,
    this.isActive,
    this.businessId,
    this.costForTwo,
    this.deliveryTime,
    this.cuisines,
    this.isVeg,
    this.open,
    this.categoryCount,
    this.images,
    this.packagingCharge,
    this.gst,
    this.ribbon,
    this.fullAddress,
  });
}

class GetRestaurant {
  List<Restaurant> restaurants;
  int count;
  int openRestaurantsCount;

  GetRestaurant({this.restaurants, this.count, this.openRestaurantsCount});

  factory GetRestaurant.fromJson(Map<String, dynamic> response) {
    List<Restaurant> restaurants = [];
    int count = response[APIStatic.keyCount];

    List<dynamic> results = response[APIStatic.keyResult];

    for (int i = 0; i < results.length; i++) {
      Map<String, dynamic> jsonRestaurant = results[i];
      restaurants.add(
        Restaurant(
          id: jsonRestaurant[APIStatic.keyID],
          name: jsonRestaurant[APIStatic.keyName],
          isActive: jsonRestaurant[RestaurantStatic.keyIsActive],
          businessId: jsonRestaurant[RestaurantStatic.keyBusinessId],
          deliveryTime: jsonRestaurant[RestaurantStatic.keyDeliveryTime],
          costForTwo: jsonRestaurant[RestaurantStatic.keyCostForTwo],
          categoryCount: jsonRestaurant[RestaurantStatic.keyCategoryCount],
          isVeg: jsonRestaurant[RestaurantStatic.keyIsVeg],
          open: jsonRestaurant[RestaurantStatic.keyOpen],
          images: jsonRestaurant[RestaurantStatic.keyImages],
          cuisines: jsonRestaurant[RestaurantStatic.keyCuisine],
          packagingCharge: jsonRestaurant[RestaurantStatic.keyPackagingCharge],
          gst: jsonRestaurant[RestaurantStatic.keyGST],
          ribbon: jsonRestaurant[RestaurantStatic.keyRibbon],
          fullAddress: jsonRestaurant[RestaurantStatic.keyFullAddress],
        ),
      );
    }

    count = restaurants.length;
    ConstantVariables.cuisines = response[RestaurantStatic.keyCuisines];

    return GetRestaurant(
        restaurants: restaurants,
        count: count,
        openRestaurantsCount:
            response[RestaurantStatic.keyOpenRestaurantsCount]);
  }
}

Future<GetRestaurant> fetchRestaurants(int businessID) async {
  final response = await http
      .get(RestaurantStatic.keyRestaurantURL + '$businessID')
      .catchError((error) {});

  if (response.statusCode == 200) {
    int count = jsonDecode(response.body)[APIStatic.keyCount];
    int execute = count != 0 ? count ~/ 10 + 1 : 0;

    GetRestaurant restaurant =
        GetRestaurant.fromJson(jsonDecode(response.body));
    if (execute != 0) execute--;

    while (execute != 0) {
      GetRestaurant tempRestaurant = GetRestaurant.fromJson(jsonDecode(
          (await http.get(jsonDecode(response.body)[APIStatic.keyNext])).body));
      restaurant.restaurants += tempRestaurant.restaurants;
      restaurant.count += tempRestaurant.count;

      execute--;
    }

    return restaurant;
  } else {
    return null;
  }
}

Future<GetRestaurant> fetchRestaurantData(int id) async {
  final response =
      await http.get(RestaurantStatic.keyRestaurantDetailURL + id.toString());

  if (response.statusCode == 200) {
    GetRestaurant restaurant =
        GetRestaurant.fromJson(jsonDecode(response.body));
    return restaurant;
  } else {
    return null;
  }
}

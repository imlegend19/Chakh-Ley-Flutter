import 'dart:convert';

import 'package:chakh_le_flutter/static_variables/static_variables.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'api_static.dart';

class Restaurant {
  final int id;
  final String name;
  final int deliveryTime;
  final String fullAddress;
  final bool openStatus;
  final String costForTwo;
  final int categoryCount;
  final double latitude;
  final double longitude;
  final int commission;
  final bool isVeg;
  final List<dynamic> images;
  final List<dynamic> cuisines;

  Restaurant({
    this.id,
    this.name,
    this.deliveryTime,
    this.fullAddress,
    this.openStatus,
    this.costForTwo,
    this.categoryCount,
    this.latitude,
    this.longitude,
    this.commission,
    this.isVeg,
    this.images,
    this.cuisines,
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
          deliveryTime: jsonRestaurant[RestaurantStatic.keyDeliveryTime],
          fullAddress: jsonRestaurant[RestaurantStatic.keyFullAddress],
          openStatus: jsonRestaurant[RestaurantStatic.keyOpen],
          costForTwo: jsonRestaurant[RestaurantStatic.keyCostForTwo],
          categoryCount: jsonRestaurant[RestaurantStatic.keyCategoryCount],
          latitude: double.parse(jsonRestaurant[RestaurantStatic.keyLatitude]),
          longitude:
              double.parse(jsonRestaurant[RestaurantStatic.keyLongitude]),
          commission: jsonRestaurant[RestaurantStatic.keyCommission],
          isVeg: jsonRestaurant[RestaurantStatic.keyIsVeg],
          images: jsonRestaurant[RestaurantStatic.keyImages],
          cuisines: jsonRestaurant[RestaurantStatic.keyCuisine],
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
  final response =
      await http.get(RestaurantStatic.keyRestaurantURL + '$businessID');

  if (response.statusCode == 200) {
    int count = jsonDecode(response.body)[APIStatic.keyCount];
    int execute = count ~/ 10 + 1;

    GetRestaurant restaurant =
        GetRestaurant.fromJson(jsonDecode(response.body));
    execute--;

    while (execute != 0) {
      GetRestaurant tempRestaurant = GetRestaurant.fromJson(jsonDecode(
          (await http.get(jsonDecode(response.body)[APIStatic.keyNext])).body));
      restaurant.restaurants += tempRestaurant.restaurants;
      restaurant.count += tempRestaurant.count;

      execute--;
    }

    return restaurant;
  } else {
    // Failed to load get
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
    Fluttertoast.showToast(
      msg: "Check your Internet Connection",
      fontSize: 13.0,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIos: 1,
    );

    return null;
  }
}

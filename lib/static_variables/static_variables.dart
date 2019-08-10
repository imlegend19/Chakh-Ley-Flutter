import 'package:chakh_le_flutter/entity/business.dart';
import 'package:chakh_le_flutter/entity/restaurant.dart';
import 'package:geocoder/geocoder.dart';

class ConstantVariables {
  static var restaurantList = List<Restaurant>();
  static int openRestaurantsCount;
  static var businessList = List<Business>();

  static Restaurant cartRestaurant;
  static int cartRestaurantId;

  static double userLatitude;
  static double userLongitude;

  static String userAddress;

  static bool hasLocationPermission;

  static int cartProductsCount;

  static Map<String, String> user = Map();
  static bool userLoggedIn = false;

  static String appName;
  static String packageName;
  static String version;
  static String buildNumber;

  static List<dynamic> cuisines;

  static List<String> order = [
    "Pending",
    "Accepted",
    "Preparing",
    "Ready",
    "Dispatched",
    "Delivered",
    "Cancelled"
  ];

  static List<String> orderDescription = [
    "We have received your Order. Please wait while we review it.",
    "Your order has been placed!",
    "Your delicious meal is being prepared!",
    "Your order is ready to get dispatched!",
    "Your order is on the way.",
    "Enjoy your meal, hope you like it!",
    "Your order was Cancelled!"
  ];

  static String userCity;
  static int businessID;
  static double totalDistance;
  static var categoryList = [];
  static bool businessPresent;
  static List<Address> address;
}

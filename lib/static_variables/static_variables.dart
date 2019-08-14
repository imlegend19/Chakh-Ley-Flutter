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

  static List<List<String>> statusDescription = [
    ["New", "Your order has been received!"],
    ["Accepted", "Your order has been placed."],
    ["Preparing", "Your delicious meal is being prepared!"],
    ["On its way", "Your order has been dispatched!"],
    ["Delivered", "Chakh Ley! India."],
    ["Cancelled", "Your order was Cancelled!"]
  ];

  static List<String> order = [
    "New",
    "Accepted",
    "Preparing",
    "On its way",
    "Delivered",
    "Cancelled"
  ];

  static String userCity;
  static int businessID;
  static double totalDistance;
  static var categoryList = [];
  static bool businessPresent;
  static List<Address> address;
}

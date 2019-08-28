import 'package:chakh_ley_flutter/entity/business.dart';
import 'package:chakh_ley_flutter/entity/restaurant.dart';
import 'package:connectivity/connectivity.dart';
import 'package:geocoder/geocoder.dart';

class ConstantVariables {
  static var restaurantList = List<Restaurant>();
  static int openRestaurantsCount;
  static int restaurantCount;

  static var businessList = List<Business>();
  static var position = [];

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

  static List<String> orderStatus = [
    "New",
    "Accepted",
    "Preparing",
    "On its way",
    "Delivered",
    "Cancelled"
  ];

  static String userCity;
  static double totalDistance;
  static var categoryList = [];
  static bool businessPresent;
  static Address address;

  static String sentryDSN =
      'https://ef4eaa0e0a4f451eaf8f3fb2ddae09f5:567c0b6caf134a82a50846e0a14e7fdf@sentry.io/1531091';

  static Business business;
  static bool businessFetched = false;
  static bool fetchedBusinessID = false;
  static int businessID;

  static ConnectivityResult connectionStatus;

  static String selectedFilter = 'R';
  static int appliedSort = 0;
}

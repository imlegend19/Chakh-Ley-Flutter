import 'dart:async';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:chakh_le_flutter/entity/restaurant.dart';
import 'package:chakh_le_flutter/models/user_pref.dart';
import 'package:chakh_le_flutter/pages/cart_page.dart';
import 'package:chakh_le_flutter/pages/home_page.dart';
import 'package:chakh_le_flutter/pages/offers_page.dart';
import 'package:chakh_le_flutter/pages/profile_page.dart';
import 'package:chakh_le_flutter/static_variables/static_variables.dart';
import 'package:chakh_le_flutter/utils/color_loader.dart';
import 'package:chakh_le_flutter/utils/database_helper.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeleton_text/skeleton_text.dart';

import 'entity/business.dart';
import 'models/restaurant_pref.dart';

void main() {
  Admob.initialize("ca-app-pub-8388035646909700~7166466048");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chakh Le',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Avenir',
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  static bool isVisible = true;
  static int spRestaurantID;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var currentLocation;
  loc.Location location = loc.Location();
  Geolocator geoLocator = Geolocator();
  Position userLocation;
  List<Address> address;
  var position = [];
  List<int> businessId = [];

  bool permissionDenied = false;
  bool businessFetched = false;
  bool businessPresent;
  bool fetchedBusinessID = false;
  bool locationSetUpCompleted = false;

  Future<double> calculateDistance(double originLat, double originLong,
      double destLat, double destLong) async {
    if (ConstantVariables.hasLocationPermission) {
      Geolocator geoLocator = Geolocator();
      var metres = await geoLocator.distanceBetween(
          originLat, originLong, destLat, destLong);
      return metres;
    } else {
      return 0;
    }
  }

  var _connectionStatus;
  Connectivity connectivity;

  StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    super.initState();

    connectivity = Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          _connectionStatus = result;

          if (result == ConnectivityResult.none) {
            setState(() {
              if ((selectedIndex == 0) || (selectedIndex == 2)) {
                body = _buildNoInternet();
              }
            });
          } else if ((result == ConnectivityResult.mobile) ||
              (result == ConnectivityResult.wifi)) {
            fetchBusiness().then((value) {
              for (final i in value.business) {
                position.add([i.latitude, i.longitude]);
                businessId.add(i.id);
              }
              setState(() {
                businessFetched = true;
                selectedTab(0);
              });
            });

            if (!locationSetUpCompleted) {
              _setupLocation();
            }
          }
        });

    getRestaurant().then((value) {
      setState(() {
        HomePage.spRestaurantID = value;
      });
    });

    Future<int> count = getCartProductCount();
    count.then((value) {
      if (value <= 0) {
        ConstantVariables.cartProductsCount = 0;
      } else {
        ConstantVariables.cartProductsCount = value;
      }
    });

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      ConstantVariables.appName = packageInfo.appName;
      ConstantVariables.packageName = packageInfo.packageName;
      ConstantVariables.version = packageInfo.version;
      ConstantVariables.buildNumber = packageInfo.buildNumber;
    });

    _getUserCredentials();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  void _setupLocation() {
    _getLocation().then((position) {
      location.hasPermission().then((bool) {
        if (bool) {
          permissionDenied = false;
          ConstantVariables.hasLocationPermission = true;
          _getLocationDetails(
              Coordinates(position.latitude, position.longitude))
              .then((value) {
            setState(() {
              ConstantVariables.userLatitude = position.latitude;
              ConstantVariables.userLongitude = position.longitude;
              address = value;
              ConstantVariables.userAddress = address.elementAt(0).featureName +
                  ", " +
                  address.elementAt(0).locality;
              ConstantVariables.userCity = address.elementAt(0).locality;

              locationSetUpCompleted = true;
            });
          });
        } else {
          setState(() {
            permissionDenied = true;
            ConstantVariables.hasLocationPermission = false;

            body = _buildLocationPermission("Enable Location Service");
          });
        }
      });
    });
  }

  void _getUserCredentials() async {
    Future<bool> loggedIn = isLoggedIn();
    loggedIn.then((bool) {
      if (bool) {
        var details = getDetails();
        details.then((result) {
          ConstantVariables.user['email'] = result['email'];
          ConstantVariables.user['mobile'] = result['mobile'];
          ConstantVariables.user['name'] = result['name'];
          ConstantVariables.user['id'] = result['id'];
        });
      }

      ConstantVariables.userLoggedIn = bool == null ? false : bool;
    });
  }

  Future<List<Address>> _getLocationDetails(Coordinates coordinates) async {
    List<Address> address = await Geocoder.local
        .findAddressesFromCoordinates(coordinates)
        .catchError((error) {
      print(error.toString());
      _getLocationDetails(coordinates);
    });

    return address;
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geoLocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }

    return currentLocation;
  }

  dynamic body = _buildLoadingScreen();
  int selectedIndex = 0;

  void selectedTab(int index) {
    if (index == 0) {
      setState(() {
        if (_connectionStatus != ConnectivityResult.none) {
          if (!permissionDenied) {
            if (businessPresent == true) {
              body = HomeMainPage(
                  restaurant: fetchRestaurant(ConstantVariables.businessID));
            } else if (businessPresent == false) {
              body = _buildLocationUnavailable();
            }
          } else {
            body = _buildLocationPermission("Enable Location Service");
          }
        } else {
          body = _buildNoInternet();
        }
        selectedIndex = 0;
      });
    } else if (index == 1) {
      setState(() {
        body = offerPage(context);
        selectedIndex = 1;
      });
    } else if (index == 2) {
      setState(() {
        if (_connectionStatus != ConnectivityResult.none) {
          body = CartPage(
              restaurant: fetchRestaurantData(HomePage.spRestaurantID));
        } else {
          body = _buildNoInternet();
        }
        selectedIndex = 2;
      });
    } else if (index == 3) {
      setState(() {
        body = ProfilePage();
        selectedIndex = 3;
      });
    }
  }

  void changeVisibilityOfFAB(bool visibility) {
    setState(() {
      HomePage.isVisible = visibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    HomePage.isVisible = true;

    if (!fetchedBusinessID) {
      if (ConstantVariables.hasLocationPermission == true) {
        if (businessFetched) {
          if (ConstantVariables.userLongitude != null &&
              ConstantVariables.userLatitude != null) {
            for (final i in position) {
              double km;
              calculateDistance(ConstantVariables.userLatitude,
                  ConstantVariables.userLongitude, i[0], i[1])
                  .then((value) {
                km = value * 0.001;

                ConstantVariables.totalDistance = km;

                if (km < 15) {
                  setState(() {
                    businessPresent = true;
                    ConstantVariables.businessID = 1;
                  });
                } else {
                  setState(() {
                    businessPresent = false;
                  });
                }

                selectedTab(0);
              });

              if (businessPresent == true) {
                break;
              }
            }
            fetchedBusinessID = true;
          }
        }
      }
    }

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Shimmer.fromColors(
                  baseColor: Colors.black,
                  highlightColor: Colors.red,
                  direction: ShimmerDirection.ltr,
                  period: Duration(milliseconds: 2000),
                  child: Text(
                    'NOW',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: Colors.black,
                      fontFamily: 'Avenir-Black',
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black54,
                      style: BorderStyle.solid,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.0),
              Icon(Icons.arrow_forward, color: Colors.black87, size: 15.0),
              SizedBox(width: 3.0),
              Container(
                child: address != null
                    ? Text(
                  address
                      .elementAt(0)
                      .featureName +
                      ", " +
                      address
                          .elementAt(0)
                          .locality,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Colors.black54,
                    letterSpacing: 1.0,
                    fontFamily: 'Neutraface',
                  ),
                )
                    : !permissionDenied
                    ? SkeletonAnimation(
                  child: Container(
                    width: 100.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[300],
                    ),
                  ),
                )
                    : Text(
                  'Permission Denied...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Colors.black54,
                    letterSpacing: 1.0,
                    fontFamily: 'Neutraface',
                  ),
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      style: BorderStyle.none,
                      width: 3.0,
                    ),
                  ),
                ),
              ),
            ],
          )),
      body: body,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.group),
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 6.0,
        shape: CircularNotchedRectangle(),
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.local_dining,
                    color: selectedIndex == 0 ? Colors.redAccent : Colors.grey,
                  ),
                  onPressed: () => selectedTab(0),
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.local_offer,
                    color: selectedIndex == 1 ? Colors.redAccent : Colors.grey,
                  ),
                  onPressed: () => selectedTab(1),
                ),
              ),
              Expanded(child: Text('')),
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.shopping_cart,
                    color: selectedIndex == 2 ? Colors.redAccent : Colors.grey,
                  ),
                  onPressed: () => selectedTab(2),
                ),
              ),
              Expanded(
                child: IconButton(
                  icon: Icon(
                    Icons.person,
                    color: selectedIndex == 3 ? Colors.redAccent : Colors.grey,
                  ),
                  onPressed: () => selectedTab(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationUnavailable() {
    return Container(
      width: double.infinity,
      height: MediaQuery
          .of(context)
          .size
          .height,
      color: Color.fromRGBO(255, 255, 200, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Transform.translate(
            offset: Offset(0, -45),
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.5,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.5,
              child:
              Image(image: AssetImage('assets/location_unavailable.png')),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -100),
            child: Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.7,
              child: Text(
                "Sorry, we aren't still here. We'll be there soon - hang tight!",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Avenir-Bold',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPermission(String buttonText) {
    return Container(
      width: double.infinity,
      height: MediaQuery
          .of(context)
          .size
          .height - 60.0,
      color: Color.fromRGBO(246, 246, 240, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            height: MediaQuery
                .of(context)
                .size
                .height * 0.5,
            child: Transform.translate(
              child: Image(image: AssetImage('assets/location_permission.png')),
              offset: Offset(0, -50),
            ),
          ),
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.85,
            child: Transform.translate(
              offset: Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  'We need to know where you are in order to find the nearby restaurants!',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Avenir-Black',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -20),
            child: RaisedButton(
              child: Text(
                buttonText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Avenir-Black',
                ),
              ),
              onPressed: () {
                buttonText != "Reload Content"
                    ? PermissionHandler()
                    .shouldShowRequestPermissionRationale(
                    PermissionGroup.location)
                    .then((value) {
                  if (!value) {
                    PermissionHandler().openAppSettings().then((value) {
                      if (value) {
                        setState(() {
                          body =
                              _buildLocationPermission("Reload Content");
                        });
                      }
                    });
                  } else {
                    PermissionHandler().requestPermissions(
                        [PermissionGroup.location]).then((value) {
                      final status = value[PermissionGroup.location];
                      if (status == PermissionStatus.granted) {
                        setState(() {
                          body = _buildLoadingScreen();
                          permissionDenied = false;
                          ConstantVariables.hasLocationPermission = true;
                          _setupLocation();
                        });
                      }
                    });
                  }
                })
                    : setState(() {
                  PermissionHandler()
                      .checkPermissionStatus(PermissionGroup.location)
                      .then((val) {
                    if (val == PermissionStatus.granted) {
                      setState(() {
                        body = _buildLoadingScreen();
                        permissionDenied = false;
                        ConstantVariables.hasLocationPermission = true;
                        _setupLocation();
                      });
                    } else {
                      setState(() {
                        body = _buildLocationPermission(
                            "Enable Location Service");
                      });
                    }
                  });
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              splashColor: Colors.red.shade50,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildLoadingScreen() {
    return Container(
      child: Center(
        child: ColorLoader(),
      ),
    );
  }

  Widget _buildNoInternet() {
    return Container(
      width: double.infinity,
      height: MediaQuery
          .of(context)
          .size
          .height - 60.0,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.4,
            height: MediaQuery
                .of(context)
                .size
                .height * 0.4,
            child: Transform.translate(
              child:
              Image(image: AssetImage('assets/no_internet_connection.gif')),
              offset: Offset(0, -50),
            ),
          ),
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.85,
            child: Transform.translate(
              offset: Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Text(
                  'No connection',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Avenir-Black',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.7,
            child: Transform.translate(
              offset: Offset(0, -40),
              child: Text(
                'Please check your internet connection and try again.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Avenir-Bold',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

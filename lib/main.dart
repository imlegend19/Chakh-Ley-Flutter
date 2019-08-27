import 'dart:async';
import 'package:chakh_ley_flutter/entity/restaurant.dart';
import 'package:chakh_ley_flutter/models/user_pref.dart';
import 'package:chakh_ley_flutter/pages/cart_page.dart';
import 'package:chakh_ley_flutter/pages/home_page.dart';
import 'package:chakh_ley_flutter/pages/offers_page.dart';
import 'package:chakh_ley_flutter/pages/profile_page.dart';
import 'package:chakh_ley_flutter/pages/splash_screen.dart';
import 'package:chakh_ley_flutter/static_variables/static_variables.dart';
import 'package:chakh_ley_flutter/utils/color_loader.dart';
import 'package:chakh_ley_flutter/utils/error_widget.dart';
import 'package:chakh_ley_flutter/utils/geo_location.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:sentry/sentry.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'entity/business.dart';

final SentryClient _sentry = SentryClient(dsn: ConstantVariables.sentryDSN);

var _connectionStatus;
Connectivity connectivity = Connectivity();
StreamSubscription<ConnectivityResult> subscription;

Future<Null> _reportError(dynamic error, dynamic stackTrace) async {
  // print('Reporting to Sentry.io...');
  await _sentry.captureException(
    exception: error,
    stackTrace: stackTrace,
  );
}

void main() async {
  FlutterError.onError = (FlutterErrorDetails details) async {
    _reportError(details.exception, details.stack);
  };

  runZoned(() async {
    runApp(MyApp());
  }, onError: (error, stackTrace) async {
    await _reportError(error, stackTrace);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    getInitialPageStatus().then((val) {
      setState(() {
        SplashScreen.switchToHomePage = val == null ? false : true;
        // print("Initial status fetched");
      });
    });

    getBusiness().then((val) {
      setState(() {
        if (val == 0) {
          ConstantVariables.businessFetched = false;
        } else {
          ConstantVariables.businessFetched = true;
          ConstantVariables.businessID = val;
          ConstantVariables.businessPresent = true;
        }

        // print("business Fetched: $val");
      });
    });

    connectivity.checkConnectivity().then((result) {
      if ((result == ConnectivityResult.mobile) ||
          (result == ConnectivityResult.wifi)) {
        if (ConstantVariables.businessFetched) {
          fetchRestaurants(ConstantVariables.businessID).then((val) {
            setState(() {
              ConstantVariables.restaurantList = val.restaurants;
              ConstantVariables.openRestaurantsCount = val.openRestaurantsCount;
              ConstantVariables.restaurantCount = val.count;

              for (int i=0; i<ConstantVariables.restaurantCount; i++) {
                ConstantVariables.categoryList.add(null);
              }

              // print("restaurant fetched!");
            });
          });

          fetchBusiness().then((val) {
            ConstantVariables.business = val.business[0];
          });
        } else {
          fetchBusiness().then((val) {
            setState(() {
              for (final i in val.business) {
                ConstantVariables.position.add([i.latitude, i.longitude]);
                ConstantVariables.businessList.add(i);
              }

              ConstantVariables.businessFetched = true;
            });

            // print("business fetched");
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context);
    };

    return MaterialApp(
      debugShowMaterialGrid: false,
      title: 'Chakh Ley',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Avenir',
      ),
      home: SplashScreen(),
      builder: (BuildContext context, Widget widget) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return getErrorWidget(context);
        };

        return widget;
      },
      debugShowCheckedModeBanner: false,
      showSemanticsDebugger: false,
    );
  }
}

class HomePage extends StatefulWidget {
  static bool isVisible = true;
  static int spRestaurantID;
  static PermissionStatus permissionStatus;
  static GetRestaurant restaurant;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  AnimationController expandController;
  Animation<double> animation;

  int setupLocationTry = 0;

  var currentLocation;
  loc.Location location = loc.Location();
  Geolocator geoLocator = Geolocator();
  Position userLocation;

  bool permissionDenied = false;
  bool serviceDenied = false;
  bool locationError = false;
  bool locationSetUpCompleted = false;

  @override
  void initState() {
    super.initState();

    if (HomePage.permissionStatus == PermissionStatus.disabled)
      loc.Location().requestService().then(
        (value) {
          if (value == true) {
            setState(() {
              body = _buildLoadingScreen();
              permissionDenied = false;
              ConstantVariables.hasLocationPermission = true;
              _setupLocation();
            });
          } else {
            setState(() {
              permissionDenied = false;
              serviceDenied = true;
              body = _buildLocationPermission("Enable Location Service");
            });
          }
        },
      );

    connectivity.checkConnectivity().then((val) {
      // print(val);

      selectedTab(0);

      if (val == ConnectivityResult.none) {
        setState(() {
          if ((selectedIndex == 0) || (selectedIndex == 2)) {
            body = _buildNoInternet();
          }
        });
      } else if ((val == ConnectivityResult.mobile) ||
          (val == ConnectivityResult.wifi)) {
        if (!ConstantVariables.businessFetched) {
          fetchBusiness().then((value) {
            if (value != null) {
              for (final i in value.business) {
                ConstantVariables.position.add([i.latitude, i.longitude]);
                ConstantVariables.businessList.add(i);
              }
              setState(() {
                ConstantVariables.businessFetched = true;
                selectedTab(0);
              });
            } else {
              setState(() {
                body = getErrorWidget(context);
              });
              Fluttertoast.showToast(
                msg: "Some error occurred!",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIos: 1,
                fontSize: 13.0,
              );
            }
          });
        }

        if (!locationSetUpCompleted) {
          // print(locationSetUpCompleted);
          _setupLocation();
        }
      }
    });

    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _connectionStatus = result;
      ConstantVariables.connectionStatus = result;

      selectedTab(0);

      if (result == ConnectivityResult.none) {
        setState(() {
          if ((selectedIndex == 0) || (selectedIndex == 2)) {
            body = _buildNoInternet();
          }
        });
      } else {
        if (!ConstantVariables.businessFetched) {
          fetchBusiness().then((value) {
            if (value != null) {
              for (final i in value.business) {
                ConstantVariables.position.add([i.latitude, i.longitude]);
                ConstantVariables.businessList.add(i);
              }
              setState(() {
                ConstantVariables.businessFetched = true;
                selectedTab(0);
              });
            } else {
              setState(() {
                body = getErrorWidget(context);
              });
              Fluttertoast.showToast(
                msg: "Some error occurred!",
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIos: 1,
                fontSize: 13.0,
              );
            }
          }).catchError((error) {
            // print(error);
          });
        }

        if (!locationSetUpCompleted) {
          _setupLocation();
        }
      }
    });

    getUserCredentials();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  void _setupLocation() {
    getLocation(geoLocator).then((position) {
      location.hasPermission().then((bool) {
        if (bool) {
          permissionDenied = false;
          ConstantVariables.hasLocationPermission = true;
          getLocationDetails(Coordinates(position.latitude, position.longitude))
              .catchError((error) {
            locationSetUpCompleted = false;
            locationError = true;
            body = _buildLocationPermission('Reload Content');
          }).then((value) {
            setState(() {
              try {
                ConstantVariables.userLatitude = position.latitude;
                ConstantVariables.userLongitude = position.longitude;
                ConstantVariables.address = value[0];

                ConstantVariables.userAddress = getAddress();

                ConstantVariables.userCity =
                    ConstantVariables.address.subAdminArea;

                locationSetUpCompleted = true;
              } catch (e) {
                setState(() {
                  locationSetUpCompleted = false;
                  locationError = true;
                  body = _buildLocationPermission('Reload Content');
                });
              }
            });
          });
        } else {
          setState(() {
            permissionDenied = true;
            ConstantVariables.hasLocationPermission = false;
            body = _buildLocationPermission("Enable Location Service");
          });
        }
      }).catchError((error) async {
        if (setupLocationTry < 2) {
          setupLocationTry += 1;
          _setupLocation();
        }
      });
    });
  }

  dynamic body = ConstantVariables.businessPresent != null
      ? ConstantVariables.businessPresent
          ? HomeMainPage()
          : _buildLoadingScreen()
      : _buildLoadingScreen();

  int selectedIndex = 0;

  void selectedTab(int index) {
    if (index == 0) {
      setState(() {
        if (_connectionStatus != ConnectivityResult.none) {
          if (!permissionDenied) {
            if (ConstantVariables.businessPresent == true) {
              body = HomeMainPage();
            } else if (ConstantVariables.businessPresent == false) {
              body = _buildLocationUnavailable();
            } else {
              fetchBusiness();
              body = _buildLoadingScreen();
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
            restaurant: HomePage.spRestaurantID == null
                ? null
                : fetchRestaurantData(
                    HomePage.spRestaurantID,
                  ),
          );
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

    if (!ConstantVariables.fetchedBusinessID) {
      if (ConstantVariables.hasLocationPermission == true) {
        if (ConstantVariables.businessFetched) {
          if (ConstantVariables.userLongitude != null &&
              ConstantVariables.userLatitude != null) {
            for (int i = 0; i < ConstantVariables.position.length; i++) {
              double km;
              calculateDistance(
                ConstantVariables.userLatitude,
                ConstantVariables.userLongitude,
                ConstantVariables.position[i][0],
                ConstantVariables.position[i][1],
              ).then((value) {
                km = value * 0.001;

                ConstantVariables.totalDistance = km;

                if (km < 15) {
                  setState(() {
                    ConstantVariables.businessPresent = true;
                    ConstantVariables.business =
                        ConstantVariables.businessList[i];

                    setBusiness(ConstantVariables.businessList[i].id);
                    setBusinessPosition(
                        ConstantVariables.businessList[i].latitude.toString(),
                        ConstantVariables.businessList[i].longitude.toString());
                  });
                } else {
                  setState(() {
                    ConstantVariables.businessPresent = false;
                  });
                }

                selectedTab(0);
              });

              if (ConstantVariables.businessPresent == true) {
                break;
              }
            }

            ConstantVariables.fetchedBusinessID = true;
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
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
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: ConstantVariables.address != null
                      ? Text(
                          ConstantVariables.userAddress,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                            color: Colors.black54,
                            letterSpacing: 1.0,
                            fontFamily: 'Neutraface',
                          ),
                          overflow: TextOverflow.ellipsis,
                        )
                      : !permissionDenied
                          ? _connectionStatus == ConnectivityResult.none
                              ? Text(
                                  'No Internet...',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                    color: Colors.black54,
                                    letterSpacing: 1.0,
                                    fontFamily: 'Neutraface',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                )
                              : serviceDenied
                                  ? Text(
                                      'Location Service Denied...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color: Colors.black54,
                                        letterSpacing: 1.0,
                                        fontFamily: 'Neutraface',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : locationError
                                      ? Text(
                                          'Some Error Occurred!',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0,
                                            color: Colors.black54,
                                            letterSpacing: 1.0,
                                            fontFamily: 'Neutraface',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : SkeletonAnimation(
                                          child: Container(
                                            width: 100.0,
                                            height: 20.0,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
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
                              overflow: TextOverflow.ellipsis,
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
            ),
          )),
      body: Stack(
        children: <Widget>[
          body,
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 65.0,
              child: Card(
                color: Colors.white,
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(40.0),
                    topRight: const Radius.circular(40.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.local_dining,
                        color:
                            selectedIndex == 0 ? Colors.redAccent : Colors.grey,
                      ),
                      onPressed: () => selectedTab(0),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.local_offer,
                        color:
                            selectedIndex == 1 ? Colors.redAccent : Colors.grey,
                      ),
                      onPressed: () => selectedTab(1),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.shopping_cart,
                        color:
                            selectedIndex == 2 ? Colors.redAccent : Colors.grey,
                      ),
                      onPressed: () => selectedTab(2),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.person,
                        color:
                            selectedIndex == 3 ? Colors.redAccent : Colors.grey,
                      ),
                      onPressed: () => selectedTab(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationUnavailable() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Transform.translate(
            offset: Offset(0, -45),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height * 0.5,
              child:
                  Image(image: AssetImage('assets/location_unavailable.png')),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -100),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
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
      height: MediaQuery.of(context).size.height - 60.0,
      color: Color.fromRGBO(246, 246, 240, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Transform.translate(
              child: Image(image: AssetImage('assets/location_permission.png')),
              offset: Offset(0, -50),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
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
                    ? permissionDenied
                        ? PermissionHandler()
                            .shouldShowRequestPermissionRationale(
                                PermissionGroup.location)
                            .then((value) {
                            if (!value) {
                              PermissionHandler()
                                  .openAppSettings()
                                  .then((value) {
                                if (value) {
                                  setState(() {
                                    body = _buildLocationPermission(
                                        "Reload Content");
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
                                    ConstantVariables.hasLocationPermission =
                                        true;
                                    _setupLocation();
                                  });
                                }
                              });
                            }
                          })
                        : loc.Location().requestService().then((value) {
                            if (value) {
                              setState(() {
                                serviceDenied = false;
                                body = _buildLoadingScreen();
                                _setupLocation();
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
                          } else if (val == PermissionStatus.disabled) {
                            loc.Location().requestService().then((value) {
                              if (value == true) {
                                setState(() {
                                  body = _buildLoadingScreen();
                                  permissionDenied = false;
                                  ConstantVariables.hasLocationPermission =
                                      true;
                                  _setupLocation();
                                });
                              } else {
                                setState(() {
                                  permissionDenied = false;
                                  serviceDenied = true;
                                  body = _buildLocationPermission(
                                      "Enable Location Service");
                                });
                              }
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
      height: MediaQuery.of(context).size.height - 60.0,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Transform.translate(
              child:
                  Image(image: AssetImage('assets/no_internet_connection.gif')),
              offset: Offset(0, -50),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
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
            width: MediaQuery.of(context).size.width * 0.7,
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

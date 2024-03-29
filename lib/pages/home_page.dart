import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chakh_ley_flutter/entity/category.dart';
import 'package:chakh_ley_flutter/entity/restaurant.dart';
import 'package:chakh_ley_flutter/restaurant_screen.dart';
import 'package:chakh_ley_flutter/static_variables/static_variables.dart';
import 'package:chakh_ley_flutter/utils/color_loader.dart';
import 'package:chakh_ley_flutter/utils/ios_search_bar.dart';
import 'package:chakh_ley_flutter/utils/slide_transistion.dart';
import 'package:connectivity/connectivity.dart';
import 'package:floating_ribbon/floating_ribbon.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:vertical_tabs/vertical_tabs.dart';

class HomeMainPage extends StatefulWidget {
  @override
  _HomeMainPageState createState() => _HomeMainPageState();
}

class _HomeMainPageState extends State<HomeMainPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool error = false;

  StreamController _restaurantController;

  TextEditingController _searchTextController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  Animation _animation;
  AnimationController _animationController;

  List<Restaurant> _displayList = ConstantVariables.restaurantList.length != 0
      ? ConstantVariables.restaurantList
      : null;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  Future<void> _handleRefresh() {
    final Completer<void> completer = Completer<void>();
    Timer(const Duration(seconds: 3), () {
      completer.complete();
    });
    return completer.future.then<void>((_) {
      setState(() {});
    });
  }

  loadRestaurants() async {
    if (ConstantVariables.connectionStatus != ConnectivityResult.none) {
      Future.sync(() {
        fetchRestaurants(ConstantVariables.business.id).then((val) {
          if (val != null) {
            _restaurantController.add(val);
          }

          if (ConstantVariables.categoryList.length == 0) {
            for (int i = 0; i < ConstantVariables.restaurantCount; i++) {
              ConstantVariables.categoryList.add(null);
            }
          }

          if (ConstantVariables.restaurantList == null) {
            ConstantVariables.restaurantList = val.restaurants;
          }
        }).catchError((error) {
          _restaurantController = StreamController();
          loadRestaurants();
        });
      }).catchError((error) {
        _restaurantController = StreamController();
        loadRestaurants();
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _restaurantController = StreamController();

    Timer.periodic(Duration(seconds: 5), (_) => loadRestaurants());

    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
    _searchFocusNode.addListener(() {
      if (!_animationController.isAnimating) {
        _animationController.forward();
      }
    });

    _searchTextController.addListener(filterRestaurants);
  }

  @override
  void dispose() {
    _restaurantController.close();
    super.dispose();
  }

  void filterRestaurants() {
    String text = _searchTextController.text.trim().toLowerCase();
    setState(() {
      _displayList = ConstantVariables.restaurantList.where((restaurant) {
        var restaurantTitle = restaurant.name.toLowerCase();
        return restaurantTitle.contains(text);
      }).toList();
    });
  }

  void _cancelSearch() {
    _searchTextController.clear();
    _searchFocusNode.unfocus();
    _animationController.reverse();

    if (_searchTextController.text.trim().length != 0) {
      if (!this.mounted) {
        return;
      } else {
        setState(() {
          _displayList = ConstantVariables.restaurantList;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_restaurantController.isClosed) {
        _restaurantController = StreamController();
      }
    }
  }

  void callback(List<Restaurant> rest) {
    setState(() {
      this._displayList = rest;
    });
  }

  void _clearSearch() {
    _searchTextController.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (ConstantVariables.restaurantList.length == 0 && !error) {
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: StreamBuilder(
          stream: _restaurantController.stream,
          builder: (context, response) {
            if (response.hasData) {
              if (ConstantVariables.restaurantList.length == 0) {
                ConstantVariables.restaurantList = response.data.restaurants;
              }

              ConstantVariables.openRestaurantsCount =
                  response.data.openRestaurantsCount;

              // print(ConstantVariables.openRestaurantsCount);

              ConstantVariables.restaurantCount = response.data.count;

              // print(ConstantVariables.restaurantCount);

              _displayList = ConstantVariables.restaurantList;

              return _buildRestaurants(response.data.restaurants,
                  response.data.openRestaurantsCount);
            } else {
              return LoadingListPage();
            }
          },
        ),
      );
    } else if (_displayList == null) {
      fetchRestaurants(ConstantVariables.businessID);
      return LoadingListPage();
    } else if (_displayList.length == 0 && !error) {
      return _buildNotFoundPage();
    } else if (error) {
      return _buildErrorPage();
    } else {
      return _buildRestaurants(
          _displayList, ConstantVariables.openRestaurantsCount);
    }
  }

  Widget restaurantListTile(
      Restaurant restaurant, Function onTap, BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    width = width * 0.30;

    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: Colors.white70,
        ),
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              restaurant.ribbon == null
                  ? Padding(
                      padding: const EdgeInsets.all(5),
                      child: _buildRestaurantImage(restaurant))
                  : FloatingRibbon(
                      height: 85,
                      width: 85,
                      child: _buildRestaurantImage(restaurant),
                      childWidth: 75,
                      childHeight: 75,
                      clipper: Clipper.right,
                      ribbon: SkeletonAnimation(
                        child: Center(
                          child: Text(
                            restaurant.ribbon == "Ex" ? "EXCLUSIVE" : "NEW",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Avenir-Bold'),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      ribbonSwatch: restaurant.ribbon == "Ex"
                          ? Colors.redAccent
                          : Colors.yellow.shade700,
                      ribbonShadowSwatch: restaurant.ribbon == "Ex"
                          ? Colors.red.shade800
                          : Colors.yellow.shade900,
                    ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0, bottom: 5.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.65,
                      child: Text(
                        restaurant.name,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Avenir-Bold'),
                        maxLines: 3,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Icon(Icons.access_alarms,
                              color: Colors.black54, size: 20),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.5),
                          child: Text(
                              restaurant.deliveryTime.toString() + " min",
                              style: TextStyle(
                                  color: Colors.black45,
                                  fontFamily: 'Avenir-Black',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5.0, right: 5.0, top: 3.0),
                          child: Icon(Icons.fiber_manual_record,
                              color: Colors.black54, size: 8.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 3.5),
                          child: Text(
                            restaurant.open ? 'Open' : 'Closed',
                            style: TextStyle(
                              color: restaurant.open
                                  ? Colors.green
                                  : Colors.black54,
                              fontFamily: 'Avenir-Black',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5.0, right: 5.0, top: 3.0),
                          child: Icon(Icons.fiber_manual_record,
                              color: Colors.black54, size: 8.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Text(
                            restaurant.costForTwo,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildRestaurants(
      List<Restaurant> restaurants, int openRestaurantsCount) {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(left: 15.0, top: 10.0, bottom: 5.0),
                child: Center(
                  child: Text(
                    '$openRestaurantsCount Open Restaurants',
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontFamily: 'Avenir-Black',
                        fontSize: 13.0,
                        fontWeight: FontWeight.w200),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, right: 8.0, top: 5.0),
                child: FlatButton.icon(
                  onPressed: () => _filterPressed(),
                  icon: Icon(
                    Icons.filter_list,
                    color: Colors.grey.shade700,
                  ),
                  label: Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      'Filters',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontFamily: 'Avenir-Black',
                        fontSize: 13.0,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          IOSSearchBar(
            controller: _searchTextController,
            focusNode: _searchFocusNode,
            animation: _animation,
            onCancel: _cancelSearch,
            onClear: _clearSearch,
            cancelColor: Colors.grey.shade700,
            cursorColor: Colors.grey.shade700,
            textColor: Colors.grey.shade600,
          ),
          Expanded(
            child: LiquidPullToRefresh(
              key: _refreshIndicatorKey,
              color: Colors.redAccent,
              onRefresh: _handleRefresh,
              showChildOpacityTransition: false,
              springAnimationDurationInMilliseconds: 400,
              height: 80.0,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: restaurants.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == restaurants.length) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                    );
                  } else {
                    Restaurant restaurant = restaurants[index];
                    return restaurantListTile(
                      restaurant,
                      () => Navigator.push(
                        context,
                        SlideTopRoute(
                          page: RestaurantScreen(
                            restaurant: restaurant,
                            category: fetchCategory(restaurant.id),
                          ),
                        ),
                      ),
                      context,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundPage() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                child: IOSSearchBar(
                  controller: _searchTextController,
                  focusNode: _searchFocusNode,
                  animation: _animation,
                  onCancel: _cancelSearch,
                  onClear: _clearSearch,
                  cancelColor: Colors.grey.shade700,
                  cursorColor: Colors.grey.shade700,
                  textColor: Colors.grey.shade600,
                  searchBarColor: Colors.grey.shade200,
                ),
              ),
              FlatButton.icon(
                onPressed: () => _filterPressed(),
                icon: Icon(
                  Icons.filter_list,
                  color: Colors.grey.shade700,
                ),
                label: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    'Filters',
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontFamily: 'Avenir-Black',
                        fontSize: 13.0,
                        fontWeight: FontWeight.w200),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Transform.translate(
            child: Image(image: AssetImage('assets/not_found.png')),
            offset: Offset(0, -50),
          ),
          Transform.translate(
            offset: Offset(0, -30),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Center(
                child: Text(
                  'Oooooops!',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Avenir-Black',
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
            child: Transform.translate(
              offset: Offset(0, -30),
              child: Center(
                child: Text(
                  'No Restaurant Found. Please check the spelling or try a different search.',
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
          ),
        ],
      ),
    );
  }

  void _filterPressed() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return FilterBottomSheet(callback: this.callback);
        });
  }

  Widget _buildErrorPage() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Image(
        image: AssetImage('assets/error.png'),
      ),
    );
  }

  Widget _buildRestaurantImage(Restaurant restaurant) {
    return Hero(
      tag: "restaurant_${restaurant.id}_hero",
      child: Container(
        width: 75.0,
        height: 75.0,
        child: restaurant.images.length == 0
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image(
                    image: AssetImage('assets/logo.png'),
                  ),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: CachedNetworkImage(
                  imageUrl: restaurant.images[0],
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Center(child: ColorLoader()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
        decoration: BoxDecoration(
          color: restaurant.images.length == 0
              ? Colors.grey.shade300
              : Colors.grey[200],
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
      ),
    );
  }
}

class LoadingListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: SingleChildScrollView(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300],
          highlightColor: Colors.grey[50],
          child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 5.0, top: 10.0, bottom: 5.0),
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 20.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 5.0, right: 5.0, top: 5.0),
                        child: Container(
                          width: 100.0,
                          height: 20.0,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 5.0, right: 5.0, top: 15.0),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        height: 20.0,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    0,
                    1,
                    2,
                    3,
                    4,
                    5,
                    6,
                    7,
                    8,
                    9,
                    10,
                    11,
                    12,
                    13,
                    14,
                    15
                  ]
                      .map(
                        (_) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: 8.0, left: 10.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 75.0,
                                height: 75.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15.0, bottom: 5.0),
                                    child: Container(
                                      height: 15,
                                      width: MediaQuery.of(context).size.width *
                                          0.6,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5.0),
                                          child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2.5),
                                          child: Container(
                                            width: 50.0,
                                            height: 13,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5.0, right: 5.0, top: 3.0),
                                          child: Icon(Icons.fiber_manual_record,
                                              color: Colors.grey[400],
                                              size: 8.0),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 3.5),
                                          child: SkeletonAnimation(
                                            child: Container(
                                              width: 50.0,
                                              height: 13,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5.0, right: 5.0, top: 3.0),
                                          child: Icon(Icons.fiber_manual_record,
                                              color: Colors.grey[400],
                                              size: 8.0),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 3.0),
                                          child: SkeletonAnimation(
                                            child: Container(
                                              width: 50.0,
                                              height: 13,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();

  final Function callback;

  FilterBottomSheet({this.callback});
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  List<bool> cuisinesVal =
      List<bool>.generate(ConstantVariables.cuisines.length, (i) => false);
  List<dynamic> cuisines = ConstantVariables.cuisines;

  List<String> sort = ['Recommended', 'Cost For Two', 'Delivery Time'];

  String _result;
  static int _radioValue = 0;

  bool disableApply =
      _radioValue == ConstantVariables.appliedSort ? true : false;

  void _handleSort(int value) {
    setState(() {
      _radioValue = value;

      switch (_radioValue) {
        case 0:
          _result = 'R';
          ConstantVariables.selectedFilter = 'R';
          if (_radioValue == ConstantVariables.appliedSort) {
            setState(() {
              disableApply = true;
            });
          } else {
            setState(() {
              disableApply = false;
            });
          }

          break;
        case 1:
          ConstantVariables.selectedFilter = 'CT';
          _result = 'CT';

          if (_radioValue == ConstantVariables.appliedSort) {
            setState(() {
              disableApply = true;
            });
          } else {
            setState(() {
              disableApply = false;
            });
          }

          break;
        case 2:
          ConstantVariables.selectedFilter = 'DT';
          _result = 'DT';

          if (_radioValue == ConstantVariables.appliedSort) {
            setState(() {
              disableApply = true;
            });
          } else {
            setState(() {
              disableApply = false;
            });
          }

          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    if (ConstantVariables.selectedFilter == 'R') {
      setState(() {
        _radioValue = 0;
      });
    } else if (ConstantVariables.selectedFilter == 'CT') {
      setState(() {
        _radioValue = 1;
      });
    } else if (ConstantVariables.selectedFilter == 'DT') {
      setState(() {
        _radioValue = 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    cuisines.sort();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.black54,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Sort / Filter',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontFamily: 'Avinir-Black',
                fontSize: 15.0,
                color: Colors.black87,
              ),
            ),
            FlatButton(
              child: Text(
                'CLEAR ALL',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Avinir-Bold',
                  fontSize: 13.0,
                  color: Colors.redAccent,
                ),
              ),
              onPressed: () {
                _handleSort(0);

                for (int i = 0; i < cuisinesVal.length; i++) {
                  cuisinesVal[i] = false;
                }

                setState(() {
                  disableApply = true;
                  filter('R', []);
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          VerticalTabs(
            tabsWidth: MediaQuery.of(context).size.width * 0.35,
            disabledChangePageFromContentView: true,
            changePageDuration: Duration(milliseconds: 10),
            indicatorColor: Colors.red,
            selectedTabBackgroundColor: Colors.grey[200],
            tabs: <Tab>[
              Tab(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    'Sort',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Avinir-Black',
                      fontSize: 13.0,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              Tab(
                child: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    'Cusines',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Avinir-Black',
                      fontSize: 13.0,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
            contents: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 13.0, left: 12.0, bottom: 10.0),
                    child: Text(
                      'SORT RESTAURANTS BY',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Avinir-Bold',
                        fontSize: 12.0,
                        color: Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      itemCount: sort.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Radio(
                              value: index,
                              groupValue: _radioValue,
                              onChanged: _handleSort,
                            ),
                            Text(
                              sort[index],
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 15.0,
                                fontFamily: 'Avenir',
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 65.0),
                child: ListView.builder(
                  itemCount: ConstantVariables.cuisines.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Checkbox(
                          checkColor: Colors.white,
                          value: cuisinesVal[index],
                          onChanged: (bool value) {
                            setState(() {
                              cuisinesVal[index] = value;
                              bool trueSeen = false;
                              for (final i in cuisinesVal) {
                                if (i == true) {
                                  trueSeen = true;
                                  break;
                                }
                              }
                              if (!trueSeen) {
                                disableApply = true;
                              } else {
                                disableApply = false;
                              }
                            });
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Text(
                            cuisines[index],
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 15.0,
                              fontFamily: 'Avenir',
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200)),
              width: MediaQuery.of(context).size.width * 0.65,
              height: 65.0,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: RaisedButton(
                  color: Colors.redAccent,
                  child: Text(
                    'APPLY',
                    style: TextStyle(
                      fontFamily: 'Avenir-Black',
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  textColor: Colors.white,
                  elevation: 3.0,
                  disabledColor: Colors.redAccent.shade100,
                  disabledTextColor: Colors.white54,
                  splashColor: Colors.red.shade50,
                  onPressed: disableApply
                      ? null
                      : () {
                          String sortText;

                          if (_result == 'R') {
                            sortText = sort[0];
                          } else if (_result == 'CT') {
                            sortText = sort[1];
                          } else if (_result == 'DT') {
                            sortText = sort[2];
                          }

                          List<String> filteredCuisine = [];

                          for (int i = 0; i < cuisinesVal.length; i++) {
                            if (cuisinesVal[i] == true) {
                              filteredCuisine.add(cuisines[i]);
                            }
                          }

                          filter(sortText, filteredCuisine);

                          ConstantVariables.appliedSort = _radioValue;

                          Navigator.of(context).pop();
                        },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void filter(String sortText, List<String> filteredCuisine) {
    List<Restaurant> filteredRestaurant = [];
    if (sortText == null) {
      for (int i = 0; i < ConstantVariables.restaurantList.length; i++) {
        // print(ConstantVariables.restaurantList[i].name);
        for (int j = 0;
            j < ConstantVariables.restaurantList[i].cuisines.length;
            j++) {
          if (filteredCuisine
              .contains(ConstantVariables.restaurantList[i].cuisines[j])) {
            filteredRestaurant.add(ConstantVariables.restaurantList[i]);
            break;
          }
        }
      }
    } else {
      for (int i = 0; i < ConstantVariables.restaurantList.length; i++) {
        filteredRestaurant.add(ConstantVariables.restaurantList[i]);
      }

      if (filteredCuisine.length != 0) {
        for (int i = 0; i < ConstantVariables.restaurantList.length; i++) {
          for (int j = 0;
              j < ConstantVariables.restaurantList[i].cuisines.length;
              j++) {
            if (filteredCuisine
                .contains(ConstantVariables.restaurantList[i].cuisines[j])) {
              filteredRestaurant.add(ConstantVariables.restaurantList[i]);
              break;
            }
          }
        }
      }

      if (sortText == 'Cost For Two') {
        filteredRestaurant
            .sort((p1, p2) => p1.costForTwo.compareTo(p2.costForTwo));
        _handleSort(1);
      } else if (sortText == 'Delivery Time') {
        filteredRestaurant
            .sort((p1, p2) => p1.deliveryTime.compareTo(p2.deliveryTime));
        _handleSort(2);
      } else {
        filteredRestaurant = ConstantVariables.restaurantList;
        _handleSort(0);
      }
    }

    widget.callback(filteredRestaurant);
  }
}

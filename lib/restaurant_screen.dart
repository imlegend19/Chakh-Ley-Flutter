import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chakh_le_flutter/entity/category.dart';
import 'package:chakh_le_flutter/entity/restaurant.dart';
import 'package:chakh_le_flutter/static_variables/static_variables.dart';
import 'package:chakh_le_flutter/utils/color_loader.dart';
import 'package:chakh_le_flutter/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skeleton_text/skeleton_text.dart';

import 'entity/api_static.dart';
import 'main.dart';
import 'models/cart.dart';
import 'models/restaurant_pref.dart';

bool disableAdd = false;

class RestaurantScreen extends StatefulWidget {
  final Restaurant restaurant;
  final Future<GetCategory> category;

  RestaurantScreen({this.restaurant, @required this.category});

  @override
  _RestaurantScreenState createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  int cartItemCount = 0;
  int expandingIndex;
  ScrollController _scrollController;
  List<Category> staticCategories;

  bool isVegSwitched = false;

  @override
  void initState() {
    super.initState();
    databaseHelper.initializeDatabase();

    Future<int> cnt = databaseHelper.getCount();
    cnt.then((value) {
      setState(() {
        cartItemCount = value;
      });
    });

    _scrollController = ScrollController();
  }

  void switchAdd(bool addCondition) {
    setState(() {
      disableAdd = !addCondition;
    });
  }

  @override
  Widget build(BuildContext context) {
    HomePage.isVisible = false;

    bool _enabled = false;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                color: Colors.grey,
                height: MediaQuery.of(context).size.height * 0.3,
                child: widget.restaurant.images.length == 0
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image(
                          image: AssetImage('assets/logo.png'),
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: widget.restaurant.images[0],
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) =>
                            Center(child: ColorLoader()),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                        child: Text(
                          widget.restaurant.name,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Avenir-Bold',
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Icon(Icons.access_alarms,
                                  color: Colors.black54, size: 20),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Text(
                                widget.restaurant.deliveryTime.toString() +
                                    " min",
                                style: TextStyle(
                                    color: Colors.black45,
                                    fontFamily: 'Avenir-Black',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Divider(color: Colors.grey),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 15.0, right: 5.0),
                          child: Text(
                            'Veg Only',
                            style: TextStyle(
                              color: Colors.black87,
                              fontFamily: 'Avenir-Bold',
                              fontWeight: FontWeight.w700,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 5.0),
                          child: Transform.scale(
                            scale: 1.2,
                            child: Switch(
                              value: widget.restaurant.isVeg ? true : _enabled,
                              onChanged: widget.restaurant.isVeg
                                  ? null
                                  : (bool value) {
                                      setState(() {
                                        _enabled = value;
                                        if (value) {
                                          isVegSwitched = true;
                                        } else {
                                          isVegSwitched = false;
                                        }
                                      });
                                    },
                              inactiveThumbColor: widget.restaurant.isVeg
                                  ? Colors.green
                                  : Colors.red,
                              activeColor: Colors.green,
                              inactiveTrackColor: widget.restaurant.isVeg
                                  ? Colors.green.shade200
                                  : Colors.red.shade200,
                              activeTrackColor: Colors.green.shade200,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Divider(color: Colors.grey),
                    ),
                    staticCategories == null
                        ? ConstantVariables
                                    .categoryList[widget.restaurant.id] ==
                                null
                            ? FutureBuilder<GetCategory>(
                                future: widget.category,
                                builder: (context, response) {
                                  if (response.hasData) {
                                    staticCategories = response.data.categories;
                                    ConstantVariables.categoryList[widget
                                        .restaurant
                                        .id] = response.data.categories;
                                    return _buildContent(response.data.count,
                                        response.data.categories);
                                  } else {
                                    return MediaQuery.removePadding(
                                      removeTop: true,
                                      child: Expanded(
                                        child: ListView.builder(
                                          itemCount:
                                              widget.restaurant.categoryCount,
                                          itemBuilder: (context, int index) {
                                            return SkeletonAnimation(
                                              child: ExpansionTile(
                                                title: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.6,
                                                  height: 15.0,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                      color: Colors.grey[300]),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      context: context,
                                    );
                                  }
                                },
                              )
                            : _buildContent(
                                ConstantVariables
                                    .categoryList[widget.restaurant.id].length,
                                ConstantVariables
                                    .categoryList[widget.restaurant.id])
                        : _buildContent(
                            staticCategories.length, staticCategories),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: RawMaterialButton(
              onPressed: () => Navigator.pop(context),
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 25.0,
              ),
              shape: CircleBorder(),
              fillColor: Colors.white,
              padding: const EdgeInsets.all(15.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget productExpandedList(Category category, DatabaseHelper dh, int count) {
    if (isVegSwitched) {
      return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildExpandableContent(dh, count, category.vegProducts));
    } else {
      return Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: _buildExpandableContent(dh, count, category.products),
      );
    }
  }

  List<Widget> _buildExpandableContent(
      DatabaseHelper databaseHelper, int count, List<dynamic> products) {
    List<Widget> columnContent = [];

    for (final product in products) {
      String name = product[APIStatic.keyName];
      AssetImage image;

      if (product[ProductStatic.keyIsVeg]) {
        image = AssetImage('assets/veg.png');
      } else {
        image = AssetImage('assets/non_veg.png');
      }

      columnContent.add(
        ListTile(
          title: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(top: 5.0, bottom: 5.0, right: 8.0),
                child: Image(
                  image: image,
                  fit: BoxFit.contain,
                  height: 23.0,
                  width: 23.0,
                ),
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    AutoSizeText(
                      name,
                      style: TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Avenir-Bold',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(
                      height: 2.0,
                    ),
                    Text(
                      "₹ " + product[ProductStatic.keyDisplayPrice].toString(),
                      style: TextStyle(
                        color: Colors.black54,
                        fontFamily: 'Avenir-Black',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          trailing: OutlineButton(
            child: Text(
              product[ProductStatic.keyActive]
                  ? "ADD"
                  : 'Currently\nUnavailable',
              style: TextStyle(
                  fontFamily: 'Avenir-Bold',
                  fontWeight: FontWeight.w800,
                  color: product[ProductStatic.keyActive]
                      ? Colors.green
                      : Colors.green.shade200,
                  fontSize: product[ProductStatic.keyActive] ? 13.0 : 10.0),
              textAlign: TextAlign.center,
            ),
            onPressed: disableAdd
                ? null
                : product[ProductStatic.keyActive]
                    ? () {
                        switchAdd(disableAdd);
                        _insertItemToCart(
                          name,
                          product[ProductStatic.keyPrice],
                          product[APIStatic.keyID],
                          databaseHelper,
                          count,
                          widget.restaurant,
                        );
                        _updateRestaurant(widget.restaurant);
                      }
                    : null,
            splashColor: Colors.green.shade100,
            highlightedBorderColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
        ),
      );
    }

    return columnContent;
  }

  void _updateRestaurant(Restaurant restaurant) {
    checkRestaurant(restaurant.id).then((value) {
      if (!value) {
        saveRestaurant(restaurant);
        HomePage.spRestaurantID = restaurant.id;
      }
    });
  }

  _insertItemToCart(String name, double price, int productID,
      DatabaseHelper databaseHelper, int count, Restaurant restaurant) {
    int restoId = getCartRestaurant();

    if (restoId == restaurant.id) {
      if (count == 0) {
        databaseHelper.insertItem(Cart(name, price, 1, productID));
        saveCartProductCount(1);
      } else {
        Future<int> check = databaseHelper.checkExistence(productID);

        check.then((value) {
          if (value == 0) {
            databaseHelper.insertItem(Cart(name, price, 1, productID));
            Future<int> count = getCartProductCount();
            count.then((value) {
              saveCartProductCount(value + 1);
            });
          } else {
            databaseHelper.updateItemAdd(productID);
          }
        });
      }

      cartItemCount += 1;
      switchAdd(disableAdd);

      return Fluttertoast.showToast(
        msg: "$name added to cart",
        fontSize: 13.0,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIos: 1,
      );
    } else {
      databaseHelper.clearCart();
      databaseHelper.insertItem(Cart(name, price, 1, productID));
      saveCartProductCount(1);

      cartItemCount = 1;
      switchAdd(disableAdd);

      saveRestaurant(restaurant);
      ConstantVariables.cartRestaurant = null;
      HomePage.spRestaurantID = restaurant.id;

      return Fluttertoast.showToast(
        msg: "$name added to cart",
        fontSize: 13.0,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIos: 1,
      );
    }
  }

  int getCartRestaurant() {
    int restoId;

    if (ConstantVariables.cartRestaurantId == null) {
      getRestaurant().then((value) {
        restoId = value;
      });
    } else {
      restoId = ConstantVariables.cartRestaurantId;
    }

    return restoId;
  }

  Widget _buildContent(int count, List<Category> categories) {
    return Flexible(
      child: MediaQuery.removePadding(
        removeTop: true,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: count + 1,
          itemBuilder: (context, int index) {
            if (index < count) {
              return ExpansionTile(
                title: AutoSizeText(
                  categories[index].name,
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Avenir-Bold',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: index == expandingIndex
                    ? <Widget>[
                        productExpandedList(
                          categories[index],
                          databaseHelper,
                          cartItemCount,
                        )
                      ]
                    : <Widget>[],
                onExpansionChanged: (bool expanding) => setState(() {
                  expandingIndex = index;
                  if (expanding) {
                    _scrollController.animateTo(index * 58.0,
                        duration: Duration(seconds: 1), curve: Curves.ease);
                  }
                }),
              );
            } else {
              return SizedBox(height: 150.0);
            }
          },
        ),
        context: context,
      ),
    );
  }
}

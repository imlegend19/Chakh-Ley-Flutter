import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chakh_le_flutter/entity/restaurant.dart';
import 'package:chakh_le_flutter/models/cart.dart';
import 'package:chakh_le_flutter/pages/checkout_page.dart';
import 'package:chakh_le_flutter/pages/login.dart';
import 'package:chakh_le_flutter/static_variables/static_variables.dart';
import 'package:chakh_le_flutter/utils/color_loader.dart';
import 'package:chakh_le_flutter/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:chakh_le_flutter/utils/transparent_image.dart';
import 'cart_skeletons.dart';

class CartPage extends StatefulWidget {
  final Future<GetRestaurant> restaurant;

  CartPage({this.restaurant});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Cart> cartProducts;
  double totalCost = 0;

  bool disableCheckout = true;
  double deliveryFee = 0;

  bool fetchedDistance = false;

  bool userLoggedIn = ConstantVariables.userLoggedIn;
  double km;

  void fetchDistance() {
    calculateDeliveryCharge(
      ConstantVariables.cartRestaurant.latitude,
      ConstantVariables.cartRestaurant.longitude,
      ConstantVariables.userLatitude,
      ConstantVariables.userLongitude,
    ).then((value) {
      setState(() {
        km = value * 0.001;
        if (km > 15) {
          disableCheckout = true;
        } else {
          disableCheckout = false;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();

    if (ConstantVariables.cartProductsCount != 0) {
      if (cartProducts == null) {
        cartProducts = List<Cart>();
        getData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ConstantVariables.cartProductsCount != 0) {
      if (ConstantVariables.cartRestaurant != null) {
        if (!fetchedDistance) {
          fetchDistance();
          fetchedDistance = true;
        }
        return _buildCartView(ConstantVariables.cartRestaurant);
      } else {
        return FutureBuilder<GetRestaurant>(
          future: widget.restaurant,
          builder: (context, response) {
            if (response.hasData) {
              ConstantVariables.cartRestaurant = response.data.restaurants[0];
              if (!fetchedDistance) {
                fetchDistance();
                fetchedDistance = true;
              }
              return _buildCartView(response.data.restaurants[0]);
            } else {
              return Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildSkeletonRestaurant(context),
                  cartProducts.length == 0 ? Container() : _buildCartItems(),
                ],
              );
            }
          },
        );
      }
    } else if (ConstantVariables.cartProductsCount == 0) {
      return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height - 60.0,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.05),
              child: FadeInImage(
                image: AssetImage('assets/empty_cart.png'),
                placeholder: MemoryImage(kTransparentImage),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    'I am empty :(',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Avenir-Black',
                    ),
                  ),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Avenir-Bold',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildCartView(Restaurant restaurant) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildRestaurant(
          restaurant.name,
          restaurant.fullAddress,
          restaurant.openStatus,
          restaurant.images,
        ),
        cartProducts.length == 0 ? Container() : _buildCartItems(),
        userLoggedIn
            ? _buildCheckOut(restaurant.deliveryTime)
            : _buildAskLogin(),
      ],
    );
  }

  void _minus(int index, BuildContext context) {
    if (cartProducts[index].quantity - 1 == 0) {
      _showDialog(index, context);
    } else {
      setState(() {
        cartProducts[index].quantity--;
        databaseHelper.updateItemMinus(cartProducts[index].productID);
      });
    }
    getData();
  }

  void _add(int index) {
    if (cartProducts[index].quantity + 1 != 31) {
      setState(() {
        cartProducts[index].quantity++;
        databaseHelper.updateItemAdd(cartProducts[index].productID);
      });
    }
    getData();
  }

  void _delete(BuildContext context, Cart cart) async {
    int result = await databaseHelper.deleteItem(cart.id);
    if (result != 0) {
      _showToast('Item Deleted Successfully');
      getData();
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIos: 1,
        fontSize: 13.0);
  }

  void getData() {
    final dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((result) {
      final cartFuture = databaseHelper.getCartMapList();
      cartFuture.then((result) {
        List<Cart> cartList = List<Cart>();
        double cost = 0;
        ConstantVariables.cartProductsCount = result.length;
        for (int i = 0; i < ConstantVariables.cartProductsCount; i++) {
          cartList.add(Cart.fromMapObject(result[i]));
          cost += Cart.fromMapObject(result[i]).price *
              Cart.fromMapObject(result[i]).quantity;
          // debugPrint(cartList[i].name);
        }
        setState(() {
          cartProducts = cartList;
          totalCost = cost;
        });

        // debugPrint("items " + count.toString());
      });
    });
  }

  void _showDialog(int index, BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(35.0),
                    bottomLeft: Radius.circular(35.0))),
            title: Text(
              'Hold On!',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Avenir-Black',
                  fontSize: 18.0,
                  color: Colors.black),
            ),
            content: RichText(
              text: TextSpan(
                  style: TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Avenir-Bold',
                      color: Colors.grey.shade700),
                  children: <TextSpan>[
                    TextSpan(text: "Do you want to remove "),
                    TextSpan(
                        text: cartProducts[index].name,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black87)),
                    TextSpan(text: " from your Cart ?")
                  ]),
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ButtonTheme(
                      minWidth: 50.0,
                      child: RaisedButton(
                        elevation: 0.0,
                        color: Colors.grey.shade200,
                        child: Text(
                          "NO",
                          style: TextStyle(
                              fontFamily: 'Avenir-Bold',
                              fontWeight: FontWeight.w700,
                              fontSize: 13.0,
                              color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        onPressed: () => {Navigator.of(context).pop()},
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    ButtonTheme(
                      minWidth: 50.0,
                      child: RaisedButton(
                        elevation: 0.0,
                        color: Colors.redAccent,
                        child: Text(
                          "YES",
                          style: TextStyle(
                              fontFamily: 'Avenir-Bold',
                              fontWeight: FontWeight.w700,
                              fontSize: 13.0,
                              color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0)),
                        onPressed: () {
                          Future<int> cnt = getCartProductCount();
                          cnt.then((value) {
                            saveCartProductCount(value - 1);
                          });
                          Navigator.of(context).pop();
                          setState(() {
                            _delete(context, cartProducts[index]);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        });
  }

  Widget productListTile(Cart cartProduct, int index, BuildContext context) {
    return Container(
      color: index % 2 == 0 ? Colors.grey[200] : Colors.white70,
      child: Padding(
        padding: const EdgeInsets.only(
            left: 13.0, right: 10.0, top: 10.0, bottom: 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: AutoSizeText(
                      cartProduct.name,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Avenir-Bold'),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                  child: Text("₹ " + cartProduct.price.toString(),
                      style: TextStyle(
                          color: Colors.black45,
                          fontFamily: 'Avenir-Black',
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700)),
                )
              ],
            ),
            Container(
              height: 35.0,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade700, width: 1.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.remove, size: 15.0),
                    onPressed: () => {_minus(index, context)},
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 3.0, right: 3.0),
                    child: Text(
                      cartProduct.quantity.toString(),
                      style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'Neutraface',
                          fontSize: 15.0,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.red, size: 15.0),
                    onPressed: () => {_add(index)},
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurant(
      String name, String fullAddress, bool open, List<dynamic> images) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
              top: 5.0, bottom: 5.0, left: 10.0, right: 5.0),
          child: Container(
            width: 75.0,
            height: 75.0,
            child: images.length == 0
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image(image: AssetImage('assets/logo.png')),
                  )
                : CachedNetworkImage(
                    imageUrl: images[0],
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
            decoration: BoxDecoration(
              color: images.length == 0 ? Colors.grey : Colors.grey[200],
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 4.0, right: 4.0, top: 2.0, bottom: 2.0),
                child: Text(
                  '$name',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Avenir-Bold',
                      fontSize: 15.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 4.0, right: 4.0, top: 2.0, bottom: 2.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: AutoSizeText(
                    "$fullAddress",
                    style: TextStyle(
                        color: Colors.black45,
                        fontFamily: 'Avenir-Black',
                        fontWeight: FontWeight.w700,
                        fontSize: 12.0),
                    maxLines: 3,
                    softWrap: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 4.0, right: 4.0, top: 2.0, bottom: 2.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: AutoSizeText(
                    open ? "Open" : "Closed",
                    style: TextStyle(
                        color: open ? Colors.green : Colors.red,
                        fontFamily: 'Avenir-Black',
                        fontWeight: FontWeight.w700,
                        fontSize: 12.0),
                    maxLines: 3,
                    softWrap: true,
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildCartItems() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.38,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: ConstantVariables.cartProductsCount + 1,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemBuilder: (context, int position) {
            if (position < ConstantVariables.cartProductsCount) {
              return productListTile(cartProducts[position], position, context);
            } else {
              return invoiceDetails();
            }
          },
        ),
      ),
    );
  }

  Widget _buildAskLogin() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(13.0),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.185,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'ALMOST THERE',
                        style: TextStyle(
                            color: Colors.black87,
                            fontFamily: 'Avenir-Black',
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        'Login or Sign up to place your order',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontFamily: 'Avenir-Black',
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 5.0),
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 45.0,
                    child: RaisedButton(
                      disabledColor: Colors.red.shade200,
                      color: Colors.redAccent,
                      disabledElevation: 0.0,
                      elevation: 3.0,
                      splashColor: Colors.red.shade200,
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15.0,
                          fontFamily: 'Avenir-Bold',
                          color: Colors.white,
                        ),
                      ),
                      onPressed: () => {
                        showLoginBottomSheet(context, 'ALMOST THERE',
                            'Sign up or Login to proceed')
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckOut(int deliveryTime) {
    return Stack(
      children: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.all(13.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.185,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.location_on,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Text(
                            'Delivery in $deliveryTime mins',
                            style: TextStyle(
                                color: Colors.grey.shade800,
                                fontFamily: 'Avenir-Black',
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 5.0),
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: 45.0,
                        child: RaisedButton(
                          disabledColor: Colors.red.shade200,
                          color: Colors.redAccent,
                          disabledElevation: 0.0,
                          elevation: 3.0,
                          splashColor: Colors.red.shade200,
                          child: Text(
                            'Checkout',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15.0,
                              fontFamily: 'Avenir-Bold',
                            ),
                          ),
                          onPressed: ConstantVariables.hasLocationPermission
                              ? disableCheckout
                                  ? null
                                  : ConstantVariables.cartRestaurant.openStatus
                                      ? () => {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CheckoutPage(
                                                        cartProducts:
                                                            cartProducts,
                                                        total: totalCost,
                                                        deliveryFee:
                                                            deliveryFee),
                                              ),
                                            )
                                          }
                                      : null
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: MediaQuery.of(context).size.width * 0.65,
          bottom: MediaQuery.of(context).size.height * 0.108,
          child: Container(
            width: 100,
            height: 40,
            margin: EdgeInsets.symmetric(vertical: 16.0),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5.0)),
            child: Center(
              child: Text(
                totalCost != null ? "Rs. ${totalCost + deliveryFee}" : "-",
                style: TextStyle(
                    fontFamily: 'Avenir-Bold',
                    fontWeight: FontWeight.w600,
                    fontSize: 15.0,
                    color: Colors.grey.shade700),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget invoiceDetails() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 10.0, bottom: 5.0),
          child: Text(
            'Bill Details',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
                fontFamily: 'Avenir-Black'),
          ),
        ),
        _buildInvoiceRow('Item Total', totalCost),
        _buildInvoiceRow('Container Charges', 0),
        _buildInvoiceRow('Delivery Fee', getDeliveryFee(km, totalCost)),
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
          child: Divider(color: Colors.grey.shade600),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 5.0, bottom: 5.0),
              child: Text(
                'To Pay',
                style: TextStyle(
                  fontFamily: 'Avelir-Bold',
                  fontSize: 14.0,
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(right: 15.0, top: 5.0, bottom: 5.0),
              child: Text(
                totalCost != null
                    ? "₹" + (totalCost + deliveryFee).toString()
                    : "NA",
                style: TextStyle(
                  fontFamily: 'Avelir-Bold',
                  fontSize: 14.0,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<double> calculateDeliveryCharge(double originLat, double originLong,
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

  double getDeliveryFee(double km, double subTotal) {
    double effectiveDistance = km != null ? km + 0.5 : 0;

    // print("Effective distance : $effectiveDistance");

    if (effectiveDistance == 0) {
      return 0;
    } else if (effectiveDistance > 10) {
      totalCost = null;
      return -1;
    } else {
      if (subTotal <= 150) {
        deliveryFee = 40;
        return 40;
      } else if (subTotal > 150 && subTotal < 750) {
        deliveryFee = 30;
        return 30;
      } else if (subTotal >= 750 && subTotal < 1000) {
        deliveryFee = 20;
        return 20;
      } else {
        deliveryFee = 0;
        return 0;
      }
    }
  }
}

Widget _buildInvoiceRow(String title, double value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.max,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 5.0, bottom: 5.0),
        child: Text(
          '$title',
          style: TextStyle(
            fontFamily: 'Avelir-Bold',
            fontSize: 13.0,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      value != null
          ? Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 5.0, bottom: 5.0),
              child: Text(
                value != 0
                    ? (value != -1 ? "₹" + value.toString() : "NA")
                    : "Free",
                style: TextStyle(
                  fontFamily: 'Avelir-Bold',
                  fontSize: 13.0,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w400,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 5.0, bottom: 5.0),
              child: SkeletonAnimation(
                child: Container(
                  width: 50,
                  height: 13,
                  color: Colors.grey[300],
                ),
              ),
            ),
    ],
  );
}

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chakh_ley_flutter/entity/restaurant.dart';
import 'package:chakh_ley_flutter/models/cart.dart';
import 'package:chakh_ley_flutter/pages/checkout_page.dart';
import 'package:chakh_ley_flutter/pages/login.dart';
import 'package:chakh_ley_flutter/static_variables/static_variables.dart';
import 'package:chakh_ley_flutter/utils/cart_skeletons.dart';
import 'package:chakh_ley_flutter/utils/color_loader.dart';
import 'package:chakh_ley_flutter/utils/database_helper.dart';
import 'package:chakh_ley_flutter/utils/slide_transistion.dart';
import 'package:chakh_ley_flutter/utils/transparent_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:skeleton_text/skeleton_text.dart';

class CartPage extends StatefulWidget {
  final Future<GetRestaurant> restaurant;

  CartPage({this.restaurant});

  static var callback;

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage>
    with SingleTickerProviderStateMixin {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Cart> cartProducts;
  double totalCost = 0;
  double restaurantCharges = 0;
  bool disableCheckout = false;
  double deliveryFee = 0;
  bool userLoggedIn = ConstantVariables.userLoggedIn;

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
        return SingleChildScrollView(
            child: _buildCartView(ConstantVariables.cartRestaurant));
      } else {
        return SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: FutureBuilder<GetRestaurant>(
              future: widget.restaurant,
              builder: (context, response) {
                if (response.hasData) {
                  ConstantVariables.cartRestaurant =
                      response.data.restaurants[0];

                  return _buildCartView(response.data.restaurants[0]);
                } else if (response.hasError) {
                  throw Exception;
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildSkeletonRestaurant(context),
                      Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height - 150,
                          child: cartProducts.length == 0
                              ? Container()
                              : ColorLoader(),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
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
                fadeInDuration: Duration(milliseconds: 100),
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
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildRestaurant(restaurant),
              cartProducts.length == 0
                  ? Container()
                  : _buildCartItems(restaurant),
            ],
          ),
          Positioned(
            top: ConstantVariables.business.isActive
                ? MediaQuery.of(context).size.height * 0.55
                : MediaQuery.of(context).size.height * 0.54,
            child: userLoggedIn
                ? _buildCheckOut(restaurant.deliveryTime, restaurant)
                : _buildAskLogin(),
          ),
        ],
      ),
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
      fontSize: 13.0,
    );
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
          deliveryFee = getDeliveryFee(totalCost);
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
                          fontWeight: FontWeight.w800, color: Colors.black87)),
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
                          color: Colors.black87,
                        ),
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
                          color: Colors.white,
                        ),
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
      },
    );
  }

  Widget productListTile(Cart cartProduct, int index, BuildContext context) {
    AssetImage image;

    if (cartProduct.isVeg == 1) {
      image = AssetImage('assets/veg.png');
    } else {
      image = AssetImage('assets/non_veg.png');
    }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Image(
                  image: image,
                  fit: BoxFit.contain,
                  height: 23.0,
                  width: 23.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: AutoSizeText(
                          cartProduct.name,
                          style: TextStyle(
                            color: Colors.black87,
                            fontFamily: 'Avenir-Bold',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 3,
                        ),
                      ),
                      SizedBox(
                        height: 2.0,
                      ),
                      Text(
                        "₹ " + cartProduct.price.toString(),
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

  Widget _buildRestaurant(Restaurant restaurant) {
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
            child: restaurant.images.length == 0
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image(image: AssetImage('assets/logo.png')),
                  )
                : CachedNetworkImage(
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
            decoration: BoxDecoration(
              color: restaurant.images.length == 0
                  ? Colors.grey
                  : Colors.grey[200],
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
                  '${restaurant.name}',
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
                    "${restaurant.fullAddress}",
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
                    restaurant.open ? "Open" : "Closed",
                    style: TextStyle(
                        color: restaurant.open ? Colors.green : Colors.red,
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

  Widget _buildCartItems(Restaurant restaurant) {
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
              return invoiceDetails(restaurant);
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

  Widget _buildCheckOut(int deliveryTime, Restaurant restaurant) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(13.0),
        child: Container(
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3.0),
                            child: Text(
                              'Delivery in $deliveryTime mins',
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontFamily: 'Avenir-Black',
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 3,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 3.0, right: 3.0),
                            child: Container(
                              width: 100.0,
                              child: Text(
                                totalCost != null
                                    ? "Rs. ${(totalCost + deliveryFee + _getRestaurantCharge(restaurant, totalCost))}"
                                    : "-",
                                style: TextStyle(
                                  fontFamily: 'Avenir-Bold',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.0,
                                  color: Colors.grey.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                Center(
                  child: ConstantVariables.business.isActive
                      ? _buildCheckoutButton()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Text(
                                "⚠ Temporarily out of service!",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontFamily: 'Avenir',
                                ),
                                maxLines: 3,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            _buildCheckoutButton(),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget invoiceDetails(Restaurant restaurant) {
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
        _buildInvoiceRow('Item Total', totalCost, restaurant),
        _buildInvoiceRow(
            'Restaurant Charges',
            _getRestaurantCharge(restaurant, totalCost),
            restaurant,
            restaurant.gst
                ? Icons.error
                : double.parse(restaurant.packagingCharge) != 0
                    ? Icons.error
                    : null),
        _buildInvoiceRow('Delivery Fee', deliveryFee, restaurant),
      ],
    );
  }

  double getDeliveryFee(double subTotal) {
    if (subTotal <= 200) {
      return 30;
    } else if (subTotal > 200 && subTotal <= 1000) {
      return 25;
    } else {
      return 15;
    }
  }

  double _getRestaurantCharge(Restaurant restaurant, double totalCost) {
    double charge = 0;

    if (restaurant.gst) {
      charge += totalCost * 0.05;
    }

    if (double.parse(restaurant.packagingCharge) != 0) {
      charge += double.parse(restaurant.packagingCharge);
    }

    restaurantCharges = charge;
    return double.parse(charge.toStringAsFixed(2));
  }

  Widget _buildCheckoutButton() {
    return Container(
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
        onPressed: disableCheckout
            ? null
            : ConstantVariables.business.isActive
                ? ConstantVariables.cartRestaurant.open
                    ? () => {
                          Navigator.push(
                            context,
                            SizeRoute(
                              page: CheckoutPage(
                                  cartProducts: cartProducts,
                                  total: totalCost,
                                  deliveryFee: deliveryFee),
                            ),
                          )
                        }
                    : null
                : null,
      ),
    );
  }
}

Widget _buildInvoiceRow(String title, double value, Restaurant restaurant,
    [IconData icon]) {
  final key = new GlobalKey();

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.max,
    children: <Widget>[
      Flexible(
        child: icon == null
            ? Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, top: 5.0, bottom: 5.0),
                child: Text(
                  '$title',
                  style: TextStyle(
                    fontFamily: 'Avelir-Bold',
                    fontSize: 13.0,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, top: 5.0, bottom: 5.0),
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
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Container(
                      width: 13,
                      height: 13.0,
                      child: Tooltip(
                        key: key,
                        message: getMessage(restaurant),
                        preferBelow: false,
                        padding: EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: GestureDetector(
                          child: Icon(
                            icon,
                            size: 20,
                          ),
                          onTap: () {
                            final dynamic tooltip = key.currentState;
                            tooltip.ensureTooltipVisible();
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
      ),
      value != null
          ? Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 5.0, bottom: 5.0),
              child: Text(
                value != 0
                    ? (value != -1 ? "₹" + value.toString() : "-NA-")
                    : title == "Delivery Fee" ? "-NA-" : "Free",
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

String getMessage(Restaurant restaurant) {
  String msg = '';

  if (restaurant.gst) {
    msg += "CGST - 2.5%, SGST - 2.5%";
  }

  if (double.parse(restaurant.packagingCharge) != 0) {
    if (msg.length != 0) {
      msg += " and Packaging Charge";
    } else {
      msg += "Packaging Charge";
    }
  }

  return msg;
}

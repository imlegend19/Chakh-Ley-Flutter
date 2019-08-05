import 'dart:io';

import 'package:chakh_le_flutter/entity/api_static.dart';
import 'package:chakh_le_flutter/entity/order_post.dart';
import 'package:chakh_le_flutter/models/cart.dart';
import 'package:chakh_le_flutter/static_variables/static_variables.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class CheckoutPage extends StatefulWidget {
  final List<Cart> cartProducts;
  final double total, deliveryFee;

  CheckoutPage(
      {@required this.cartProducts,
      @required this.total,
      @required this.deliveryFee});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  TextEditingController _controller =
      TextEditingController(text: ConstantVariables.userAddress);
  TextEditingController _unitNoController = TextEditingController();
  TextEditingController _landmarkController = TextEditingController();

  Future<PostOrder> postOrder;

  bool enableProceed = false;
  String buttonText = "ENTER HOUSE / FLAT NO";

  List<Map<String, int>> suborderSet = List();

  @override
  void initState() {
    super.initState();

    _controller.addListener(validateText);
    _unitNoController.addListener(validateText);
    _landmarkController.addListener(validateText);

    suborderSet = convertToMap(widget.cartProducts);
  }

  @override
  void dispose() {
    _controller.dispose();
    _unitNoController.dispose();
    _landmarkController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        textTheme: TextTheme(
          title: TextStyle(
            fontWeight: FontWeight.w300,
            color: Colors.white,
            fontFamily: 'Avenir-Black',
            fontSize: 18.0,
          ),
        ),
        titleSpacing: 2,
        title: Padding(
          padding: const EdgeInsets.only(top: 3.0),
          child: Text('Set delivery location'),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15.0, bottom: 5.0),
              child: Container(
                color: Colors.grey[300],
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10.0),
                    labelText: 'Location',
                    labelStyle: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Avenir-Black',
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  enabled: false,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontFamily: 'Avenir-Bold',
                    color: Colors.black87,
                  ),
                  controller: _controller,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10.0),
                  labelText: 'House / Flat No',
                  labelStyle: TextStyle(
                    fontSize: 14.0,
                    fontFamily: 'Avenir-Black',
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                style: TextStyle(
                  fontSize: 15.0,
                  fontFamily: 'Avenir-Bold',
                  color: Colors.black87,
                ),
                cursorColor: Colors.red,
                controller: _unitNoController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 5.0, bottom: 5.0),
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10.0),
                  labelText: 'Landmark',
                  labelStyle: TextStyle(
                    fontSize: 14.0,
                    fontFamily: 'Avenir-Black',
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                style: TextStyle(
                  fontSize: 15.0,
                  fontFamily: 'Avenir-Bold',
                  color: Colors.black87,
                ),
                cursorColor: Colors.red,
                controller: _landmarkController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 15.0, right: 5.0, top: 1.0),
                    child: Icon(
                      Icons.report,
                      size: 13.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    'Cash on Delivery by default',
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontFamily: "Avenir-Black",
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 50.0,
                child: RaisedButton(
                  disabledColor: Colors.red.shade200,
                  color: Colors.redAccent,
                  disabledElevation: 0.0,
                  elevation: 3.0,
                  splashColor: Colors.red.shade200,
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13.0,
                      color: Colors.white,
                      fontFamily: 'Avenir-Bold',
                    ),
                  ),
                  onPressed: enableProceed
                      ? () {
                          checkoutOrder();
                        }
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void validateText() {
    if (_unitNoController.text.length == 0) {
      setState(() {
        enableProceed = false;
        buttonText = "ENTER HOUSE / FLAT NO";
      });
    } else if (_landmarkController.text.length == 0) {
      setState(() {
        enableProceed = false;
        buttonText = "ENTER LANDMARK";
      });
    } else {
      setState(() {
        enableProceed = true;
        buttonText = "PLACE ORDER";
      });
    }
  }

  List<Map<String, int>> convertToMap(List<Cart> cartProducts) {
    List<Map<String, int>> suborderList = List();

    cartProducts.forEach((Cart cart) {
      Map<String, int> suborder = Map();
      suborder["item"] = cart.productID;
      suborder["quantity"] = cart.quantity;
      suborderList.add(suborder);
    });

    return suborderList;
  }

  Future<http.Response> createPost(PostOrder post) async {
    final response = await http.post(RestaurantStatic.keyCreateOrderURL,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: postOrderToJson(post));

    return response;
  }

  checkoutOrder() {
    PostOrder post = PostOrder(
        name: ConstantVariables.user['name'],
        mobile: ConstantVariables.user['mobile'],
        email: ConstantVariables.user['email'],
        business: 1,
        restaurant: ConstantVariables.cartRestaurant.id,
        preparationTime: ConstantVariables.cartRestaurant.deliveryTime,
        delivery: convertAddressToMap(),
        subOrderSet: suborderSet);

    createPost(post).then((response) {
      if (response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: "Order has been placed successfully!",
          fontSize: 13.0,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIos: 2,
        );
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      } else if (response.statusCode == 400) {
        // print(response.body);
      }
    }).catchError((Object error) {
      Fluttertoast.showToast(
        msg: "Please check your internet!",
        fontSize: 13.0,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIos: 2,
      );
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: error.toString(),
        fontSize: 13.0,
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIos: 2,
      );
    });
  }

  ///  "location": "string",
  ///  "unit_no": "string",
  ///  "address_line_2": "string"
  Map<String, dynamic> convertAddressToMap() {
    Map<String, dynamic> delivery = Map();
    delivery["location"] = _controller.text;
    delivery["unit_no"] = _unitNoController.text.toUpperCase();
    String addressLine = _landmarkController.text;
    delivery["address_line_2"] =
        '${addressLine[0].toUpperCase()}${addressLine.substring(1)}';
    delivery["amount"] = widget.deliveryFee;
    delivery["latitude"] = ConstantVariables.userLatitude;
    delivery["longitude"] = ConstantVariables.userLongitude;

    return delivery;
  }
}

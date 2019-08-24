import 'dart:async';

import 'package:chakh_ley_flutter/entity/order.dart';
import 'package:chakh_ley_flutter/pages/order_page.dart';
import 'package:chakh_ley_flutter/static_variables/static_variables.dart';
import 'package:chakh_ley_flutter/utils/color_loader.dart';
import 'package:chakh_ley_flutter/utils/slide_transistion.dart';
import 'package:flutter/material.dart';

class OrderHistoryPage extends StatefulWidget {
  final Future<GetOrders> order;

  OrderHistoryPage({this.order});

  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  StreamController _controller;

  loadOrders() async {
    Future.sync(() {
      fetchOrder(ConstantVariables.user['mobile']).then((val) async {
        if (val != null) {
          _controller.add(val);
        }
      }).catchError((error) {
        _controller = StreamController();
        loadOrders();
      });
    }).catchError((error) {
      _controller = StreamController();
      loadOrders();
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = StreamController();

    Timer.periodic(Duration(seconds: 3), (_) => loadOrders());
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        titleSpacing: 2,
        automaticallyImplyLeading: false,
        elevation: 0.5,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Text(
              'Order History',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 20.0,
                color: Colors.white,
                fontFamily: 'Avenir-Bold',
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder(
        stream: _controller.stream,
        builder: (context, response) {
          if (response.hasData) {
            if (response.data.count == 0) {
              return Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height - 60.0,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Transform.translate(
                      child: Image(image: AssetImage('assets/no_orders.png')),
                      offset: Offset(0, -50),
                    ),
                    Transform.translate(
                      offset: Offset(0, -40),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: Text(
                          'No Orders Yet',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Avenir-Black',
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, -40),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Text(
                          "Look's like you, haven't made your menu yet.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Avenir-Bold',
                          ),
                          maxLines: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                itemCount: response.data.count,
                itemBuilder: (context, int index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0, bottom: 5.0),
                      child:
                          _buildOrderHistoryCard(index, response.data.orders),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(
                          top: 5.0, left: 10.0, right: 10.0, bottom: 5.0),
                      child:
                          _buildOrderHistoryCard(index, response.data.orders),
                    );
                  }
                },
              );
            }
          } else {
            return Container(
              child: Center(
                child: ColorLoader(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildOrderHistoryCard(int index, List<Order> orders) {
    return Container(
      color: Colors.white,
      height: 100.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 5.0, top: 8.0, bottom: 5.0),
                child: Text(
                  getDate(orders[index].orderDate),
                  style: TextStyle(
                      fontFamily: 'Avenir-Black',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.0,
                      color: Colors.red.shade700),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 5.0, top: 5.0, bottom: 5.0),
                child: Text(
                  'Order ID : #${orders[index].id}',
                  style: TextStyle(
                      fontFamily: 'Avenir-Black',
                      fontWeight: FontWeight.w600,
                      fontSize: 13.0,
                      color: Colors.black87),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 5.0, top: 5.0, bottom: 8.0),
                child: Text(
                  'Rs. ${orders[index].total}',
                  style: TextStyle(
                      fontFamily: 'Avenir-Black',
                      fontWeight: FontWeight.w600,
                      fontSize: 13.0,
                      color: Colors.green),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.only(top: 13.0, left: 5.0, right: 5.0),
                child: Text(
                  orders[index].status,
                  style: TextStyle(
                      fontFamily: 'Avenir-Black',
                      fontWeight: FontWeight.w600,
                      fontSize: 15.0,
                      color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0, bottom: 8.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.35,
                  height: 45.0,
                  child: RawMaterialButton(
                    disabledElevation: 0.0,
                    elevation: 3.0,
                    splashColor: Colors.red.shade200,
                    fillColor: Colors.redAccent,
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        fontFamily: 'Avenir-Bold',
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      SizeRoute(
                        page: OrderPage(
                          order: orders[index],
                          orderId: orders[index].id,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  String getDate(String orderDate) {
    var datetime = orderDate.split("T");
    return datetime[0];
  }
}

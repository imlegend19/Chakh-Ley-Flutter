import 'dart:async';
import 'package:chakh_le_flutter/entity/order.dart';
import 'package:chakh_le_flutter/utils/error_widget.dart';
import 'package:flutter/material.dart';

import 'content_card.dart';
import 'restaurant_details.dart';

class OrderPage extends StatefulWidget {
  final Order order;
  final int orderId;

  OrderPage({this.order, this.orderId});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with TickerProviderStateMixin {
  StreamController _orderController;

  loadOrders() async {
    Future.sync(() {
      fetchOrder(null, widget.orderId).then((val) async {
        if (val != null) {
          _orderController.add(val);
        }
      }).catchError((error) {
        _orderController = StreamController();
        loadOrders();
      });
    }).catchError((error) {
      _orderController = StreamController();
      loadOrders();
    });
  }

  @override
  void initState() {
    super.initState();
    _orderController = StreamController();

    Timer.periodic(Duration(seconds: 5), (_) => loadOrders());
  }

  @override
  void dispose() {
    _orderController.close();
    super.dispose();
  }

  bool showBody = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _orderController.stream,
        builder: (context, response) {
          if (response.hasData) {
            return _buildOrderPage(response.data.orders[0]);
          } else if (response.hasError) {
            return getErrorWidget(context);
          } else {
            return _buildOrderPage(widget.order);
          }
        });
  }

  Widget _buildAppBarRow(Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Text(
          order.status,
          style: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w700,
            fontSize: 15.0,
            fontFamily: 'Avenir-Bold',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child:
              Icon(Icons.fiber_manual_record, color: Colors.black54, size: 8.0),
        ),
        Text(
          '${order.suborderSet.length} Items',
          style: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w700,
            fontSize: 15.0,
            fontFamily: 'Avenir-Bold',
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4.0, right: 4.0),
          child:
              Icon(Icons.fiber_manual_record, color: Colors.black54, size: 8.0),
        ),
        Text(
          '₹${order.total}',
          style: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w500,
            fontSize: 15.0,
            fontFamily: 'Avenir-Bold',
          ),
        ),
      ],
    );
  }

  Widget _buildOrderPage(Order order) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          titleSpacing: 2,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Text(
                    'Order: ${order.id}',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 25.0,
                        fontFamily: 'Neutraface',
                        letterSpacing: 1.0),
                  ),
                  _buildAppBarRow(order),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          RestaurantDetails(
              height: MediaQuery.of(context).size.height,
              restaurant: order.restaurant),
          Positioned.fill(
            child: Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top + 25),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: ContentCard(
                      orderStatus: order.status,
                      order: widget.order,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}

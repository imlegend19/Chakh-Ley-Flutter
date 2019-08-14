import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chakh_le_flutter/entity/api_static.dart';
import 'package:chakh_le_flutter/entity/order.dart';
import 'package:chakh_le_flutter/utils/color_loader.dart';
import 'package:chakh_le_flutter/utils/seperator.dart';
import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'restaurant_details.dart';
import 'content_card.dart';

class OrderPage extends StatefulWidget {
  final Order order;
  final int orderId;

  OrderPage({this.order, this.orderId});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool showBody = true;

  @override
  Widget build(BuildContext context) {
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
                    'Order: ${widget.orderId}',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 25.0,
                        fontFamily: 'Neutraface',
                        letterSpacing: 1.0),
                  ),
                  _buildAppBarRow(widget.order),
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
              restaurant: widget.order.restaurant),
          Positioned.fill(
            child: Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).padding.top + 25),
              child: Column(
                children: <Widget>[
                  Expanded(child: ContentCard(orderStatus: widget.order.status)),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _billDetails(List<dynamic> suborderSet) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          height:
              MediaQuery.of(context).size.height * 0.06 * suborderSet.length,
          child: ListView.builder(
            itemCount: suborderSet.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.black87,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: suborderSet[index]
                                    [SuborderSetStatic.keyProduct]
                                [APIStatic.keyName],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Avenir-Black',
                              fontSize: 16.0,
                            ),
                          ),
                          TextSpan(text: ' x '),
                          TextSpan(
                            text: suborderSet[index]
                                    [SuborderSetStatic.keyQuantity]
                                .toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Avenir-Black',
                              fontSize: 16.0,
                            ),
                          )
                        ],
                      ),
                    ),
                    Text(
                      suborderSet[index][SuborderSetStatic.keySubTotal]
                          .toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15.0,
                        fontFamily: 'Avenir',
                        color: Colors.black87,
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15.0, right: 15.0),
          child: Separator(
            color: Colors.grey,
            width: MediaQuery.of(context).size.width,
          ),
        ),
        invoiceDetails(),
      ],
    );
  }

  Widget invoiceDetails() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildInvoiceRow(
              'Item Total', getItemTotal(widget.order.suborderSet)),
          _buildInvoiceRow('Container Charges', 0),
          _buildInvoiceRow('Delivery Fee ',
              widget.order.total - getItemTotal(widget.order.suborderSet)),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
            child: Separator(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, bottom: 5.0),
                  child: Text(
                    widget.order.paymentDone ? 'Amount Paid' : 'To Pay',
                    style: TextStyle(
                      fontFamily: 'Avelir-Bold',
                      fontSize: 18.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 15.0, bottom: 5.0),
                  child: Text(
                    "₹" + widget.order.total.toString(),
                    style: TextStyle(
                      fontFamily: 'Avelir-Bold',
                      fontSize: 18.0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceRow(String title, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 5.0),
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
                padding:
                    const EdgeInsets.only(right: 8.0, top: 5.0, bottom: 5.0),
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
                padding:
                    const EdgeInsets.only(right: 8.0, top: 5.0, bottom: 5.0),
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

  double getItemTotal(List suborderSet) {
    double total = 0;

    for (final i in suborderSet) {
      total += i[SuborderSetStatic.keySubTotal];
    }

    return total;
  }

  Widget _buildBillDetails() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0, top: 8.0),
          child: Center(
            child: Text(
              'Bill Details',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18.0,
                fontFamily: 'Avenir-Black',
                color: Colors.black87,
              ),
            ),
          ),
        ),
        Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height *
              (widget.order.suborderSet.length * 0.05 + 0.3),
          child: _billDetails(widget.order.suborderSet),
        ),
      ],
    );
  }

  Widget _buildTimeLine() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _buildBillDetails(),
        Expanded(child: Container()),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: FloatingActionButton(
            onPressed: () => setState(() => showBody = false),
            child: Icon(Icons.timeline, size: 36.0),
          ),
        ),
      ],
    );
  }
}

import 'package:chakh_le_flutter/entity/api_static.dart';
import 'package:chakh_le_flutter/entity/order.dart';
import 'package:chakh_le_flutter/pages/timeline/timeline.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton_text/skeleton_text.dart';

class ContentCard extends StatefulWidget {
  final String orderStatus;
  final Order order;

  ContentCard({@required this.orderStatus, @required this.order});

  static bool showInput = true;

  @override
  _ContentCardState createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  bool showInputTabOptions = true;

  void callback(bool showInput) {
    setState(() {
      ContentCard.showInput = showInput;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (!ContentCard.showInput) {
          setState(() {
            ContentCard.showInput = true;
            showInputTabOptions = true;
          });
          return Future(() => false);
        } else {
          return Future(() => true);
        }
      },
      child: Card(
        elevation: 4.0,
        margin:
            const EdgeInsets.only(top: 70, bottom: 8.0, left: 8.0, right: 8.0),
        child: DefaultTabController(
          child: LayoutBuilder(
            builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
              return Column(
                children: <Widget>[
                  _buildContentContainer(viewportConstraints),
                ],
              );
            },
          ),
          length: 3,
        ),
      ),
    );
  }

  Widget _buildContentContainer(BoxConstraints viewportConstraints) {
    return Expanded(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: viewportConstraints.maxHeight - 48.0,
          ),
          child: IntrinsicHeight(
            child: ContentCard.showInput
                ? PriceTab(
                    height: viewportConstraints.maxHeight - 48.0,
                    onBikeBikeStart: () =>
                        setState(() => showInputTabOptions = false),
                    status: widget.orderStatus,
                    callback: this.callback,
                  )
                : _buildTimeline(),
          ),
        ),
      ),
    );
  }

  Widget invoiceDetails(Order order) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildInvoiceRow('Item Total', getItemTotal(order.suborderSet)),
          _buildInvoiceRow('Container Charges', 0),
          _buildInvoiceRow(
              'Delivery Fee ', order.total - getItemTotal(order.suborderSet)),
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 15.0, right: 15.0),
            child: Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
              height: 3,
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
                    order.paymentDone ? 'Amount Paid' : 'To Pay',
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
                    "₹" + order.total.toString(),
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

  Widget _billDetails(Order order) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15.0, top: 5, bottom: 3),
            child: Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
              height: 3,
            ),
          ),
          CupertinoScrollbar(
            child: Container(
              height: MediaQuery.of(context).size.height *
                          0.06 *
                          order.suborderSet.length >
                      MediaQuery.of(context).size.height * 0.3
                  ? MediaQuery.of(context).size.height * 0.3
                  : MediaQuery.of(context).size.height *
                      0.06 *
                      order.suborderSet.length,
              child: ListView.builder(
                itemCount: order.suborderSet.length,
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
                                text: order.suborderSet[index]
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
                                text: order.suborderSet[index]
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
                          order.suborderSet[index]
                                  [SuborderSetStatic.keySubTotal]
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
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
              height: 3,
            ),
          ),
          invoiceDetails(order),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Column(
      children: <Widget>[
        _buildBillDetails(widget.order),
        widget.orderStatus == 'Delivered'
            ? Stack(
                children: <Widget>[
                  Positioned(
                    top: 30,
                    left: 65,
                    child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Text(
                        'Your order has been delivered.\nChakh Ley! India',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'AvenirBold',
                          color: Colors.black54,
                          fontSize: 15.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 100,
                      height: 100,
                      child: FlareActor(
                        "assets/success_check.flr",
                        animation: "Untitled",
                      ),
                    ),
                  ),
                ],
              )
            : widget.orderStatus == 'Cancelled'
                ? Stack(
                    children: <Widget>[
                      Positioned(
                        top: 30,
                        left: 65,
                        child: Container(
                          color: Colors.white,
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Text(
                            'Your order has been cancelled.\nChakh Ke Dekh Ley! India',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'AvenirBold',
                              color: Colors.black54,
                              fontSize: 15.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 100,
                          height: 100,
                          child: FlareActor(
                            "assets/error.flr",
                            animation: "Error",
                          ),
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: FloatingActionButton(
                      onPressed: () => setState(() {
                        ContentCard.showInput = true;
                      }),
                      child: Icon(Icons.timeline, size: 36.0),
                    ),
                  ),
      ],
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
              fontSize: 14.0,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        value != null
            ? Padding(
                padding:
                    const EdgeInsets.only(right: 8.0, top: 5.0, bottom: 2.0),
                child: Text(
                  value != 0
                      ? (value != -1 ? "₹" + value.toString() : "NA")
                      : "Free",
                  style: TextStyle(
                    fontFamily: 'Avelir-Bold',
                    fontSize: 13.0,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            : Padding(
                padding:
                    const EdgeInsets.only(right: 8.0, top: 5.0, bottom: 2.0),
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

  double getItemTotal(List suborderSet) {
    double total = 0;

    for (final i in suborderSet) {
      total += i[SuborderSetStatic.keySubTotal];
    }

    return total;
  }

  Widget _buildBillDetails(Order order) {
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
          height: MediaQuery.of(context).size.height * 0.48,
          child: _billDetails(order),
        ),
      ],
    );
  }

  Widget _buildDeliveryBoy() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.15,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Container(
              width: 65,
              height: 65,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 35,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(50.0),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  widget.order.deliveryBoy['user'][APIStatic.keyName],
                  style: TextStyle(
                    color: Colors.black87,
                    fontFamily: 'AvenirBold',
                    fontSize: 15.0,
                  ),
                ),
              ),
              Container(
                width: 70,
                height: 25,
                child: FlatButton(
                  onPressed: () {},
                  child: Text(
                    "Call",
                    style: TextStyle(
                      color: Colors.green,
                      fontFamily: "AvenirBold",
                      fontSize: 15.0,
                    ),
                  ),
                  shape: StadiumBorder(),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  String getInitials(String name) {
    List s = name.split(" ");
    try {
      return s[0][0].toString().toUpperCase() +
          s[0][1].toString().toUpperCase();
    } catch (e) {
      return s[0][0].toString().toUpperCase() +
          s[0][1].toString().toUpperCase();
    }
  }
}

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chakh_le_flutter/entity/api_static.dart';
import 'package:chakh_le_flutter/entity/order.dart';
import 'package:chakh_le_flutter/static_variables/static_variables.dart';
import 'package:chakh_le_flutter/utils/color_loader.dart';
import 'package:chakh_le_flutter/utils/seperator.dart';
import 'package:chakh_le_flutter/utils/timeline.dart';
import 'package:chakh_le_flutter/utils/timeline_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:skeleton_text/skeleton_text.dart';

class OrderPage extends StatefulWidget {
  final Order order;
  final int orderId;

  OrderPage({this.order, this.orderId});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<LatLng> latlng = List();
  LatLng origin;
  LatLng destination;
  GoogleMapController mapController;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polyline = {};

  @override
  void initState() {
    super.initState();

    origin = LatLng(
        double.parse(widget.order.restaurant[RestaurantStatic.keyLatitude]),
        double.parse(widget.order.restaurant[RestaurantStatic.keyLongitude]));
    destination =
        LatLng(ConstantVariables.userLatitude, ConstantVariables.userLongitude);

    latlng.add(destination);
    latlng.add(origin);
  }

  @override
  Widget build(BuildContext context) {
    _markers.add(Marker(
      markerId: MarkerId(origin.toString()),
      position: origin,
      infoWindow: InfoWindow(
        title: widget.order.restaurant[APIStatic.keyName],
      ),
      draggable: false,
      icon: BitmapDescriptor.defaultMarker,
    ));

    _markers.add(Marker(
      markerId: MarkerId(destination.toString()),
      position: destination,
      infoWindow: InfoWindow(
        title: ConstantVariables.userAddress,
      ),
      draggable: false,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    ));

    _polyline.add(Polyline(
      polylineId: PolylineId(origin.toString()),
      visible: true,
      points: latlng,
      color: Colors.blue,
    ));

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
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              polylines: _polyline,
              markers: _markers,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: LatLng((origin.latitude + destination.latitude) / 2,
                    (origin.longitude + destination.longitude) / 2),
                zoom: ConstantVariables.totalDistance > 15 ? 5.0 : 14.0,
                tilt: 90,
              ),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              mapType: MapType.normal,
              onCameraMoveStarted: () => mapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng((origin.latitude + destination.latitude) / 2,
                        (origin.longitude + destination.longitude) / 2),
                    zoom: ConstantVariables.totalDistance > 15 ? 5.0 : 14.0,
                    tilt: 90,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Row(
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
                    child: widget.order.restaurant[RestaurantStatic.keyImages]
                                .length ==
                            0
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image(image: AssetImage('assets/logo.png')),
                          )
                        : CachedNetworkImage(
                            imageUrl: widget.order
                                .restaurant[RestaurantStatic.keyImages][0],
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
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                    decoration: BoxDecoration(
                      color: widget.order.restaurant[RestaurantStatic.keyImages]
                                  .length ==
                              0
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
                          '${widget.order.restaurant[APIStatic.keyName]}',
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
                            "${widget.order.restaurant[RestaurantStatic.keyFullAddress]}",
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
                            widget.order.restaurant[RestaurantStatic.keyOpen]
                                ? "Open"
                                : "Closed",
                            style: TextStyle(
                                color: widget.order
                                        .restaurant[RestaurantStatic.keyOpen]
                                    ? Colors.green
                                    : Colors.red,
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
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                  child: _buildTimeLine(widget.order.status,
                      ConstantVariables.order.indexOf(widget.order.status) + 1),
                  width: MediaQuery.of(context).size.width,
                  height: _getTimeLineHeight(
                      ConstantVariables.order.indexOf(widget.order.status) +
                          1)),
            ],
          ),
          Expanded(
            child: ListView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              addRepaintBoundaries: true,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
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
          child: const Separator(color: Colors.grey),
        ),
        invoiceDetails()
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
            child: const Separator(color: Colors.grey),
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

  Widget _buildTimeLine(String status, int index) {
    TextStyle titleStyle = TextStyle(
      color: Colors.black87,
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      fontFamily: 'Avenir-Black',
    );

    TextStyle descriptionStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      fontFamily: 'Avenir-Bold',
    );

    List<TimelineModel> list = [];

    for (int i = 0; i < index; i++) {
      list.add(TimelineModel(
          id: i.toString(),
          isCancel: ConstantVariables.order[i] == "Cancelled" ? true : false,
          title: ConstantVariables.order[i],
          titleStyle: titleStyle,
          description: ConstantVariables.orderDescription[i],
          descriptionStyle: descriptionStyle,
          circleColor: ConstantVariables.order[i] == "Delivered"
              ? Colors.green
              : Colors.redAccent));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: TimelineComponent(
        timelineList: list,
      ),
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

  double _getTimeLineHeight(int i) {
    return MediaQuery.of(context).size.height * 0.15 * i;
  }

  double getItemTotal(List suborderSet) {
    double total = 0;

    for (final i in suborderSet) {
      total += i[SuborderSetStatic.keySubTotal];
    }

    return total;
  }
}

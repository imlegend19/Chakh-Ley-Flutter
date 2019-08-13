import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chakh_le_flutter/entity/api_static.dart';
import 'package:chakh_le_flutter/entity/order.dart';
import 'package:chakh_le_flutter/utils/color_loader.dart';
import 'package:chakh_le_flutter/utils/seperator.dart';
import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';

class OrderPage extends StatefulWidget {
  final Order order;
  final int orderId;

  OrderPage({this.order, this.orderId});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with TickerProviderStateMixin {
  final List<int> _flightStops = [1, 2, 3, 4];
  final double _cardHeight = 80.0;

  final List<GlobalKey<BikeStopCardState>> _stopKeys = []; //<--- Add keys
  AnimationController _fabAnimationController;
  Animation _fabAnimation;

  AnimationController _dotsAnimationController;
  List<Animation<double>> _dotPositions = [];

  AnimationController _bikeSizeAnimationController;
  Animation _bikeSizeAnimation;
  AnimationController _bikeTravelController;
  Animation _bikeTravelAnimation;

  double get _bikeSize => _bikeSizeAnimation.value;

  double get _bikeTopPadding =>
      20 + (1 - _bikeTravelAnimation.value) * _maxBikeTopPadding;

  double get _maxBikeTopPadding =>
      MediaQuery.of(context).size.height * 0.7 - 40 - _bikeSize;

  final List<BikeStop> _bikeStops = [
    BikeStop("JFK", "ORY", "JUN 05", "6h 25m", "\$851", "9:26 am - 3:43 pm"),
    BikeStop("MRG", "FTB", "JUN 20", "6h 25m", "\$532", "9:26 am - 3:43 pm"),
    BikeStop("ERT", "TVS", "JUN 20", "6h 25m", "\$718", "9:26 am - 3:43 pm"),
    BikeStop("KKR", "RTY", "JUN 20", "6h 25m", "\$663", "9:26 am - 3:43 pm"),
  ];

  @override
  void initState() {
    super.initState();
    _initSizeAnimations();
    _initBikeTravelAnimations();
    _initDotAnimationController();
    _initDotAnimations();

    _initFabAnimationController(); //<--- init fab controller
    _flightStops.forEach((stop) =>
        _stopKeys.add(GlobalKey<BikeStopCardState>())); //<-- init card keys
    _bikeSizeAnimationController.forward();

    _bikeSizeAnimationController.forward();
  }

  _initBikeTravelAnimations() {
    _bikeTravelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _bikeTravelAnimation = CurvedAnimation(
      parent: _bikeTravelController,
      curve: Curves.fastOutSlowIn,
    );
  }

  _initSizeAnimations() {
    _bikeSizeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(Duration(milliseconds: 800),
              () => _bikeTravelController.forward());
          Future.delayed(Duration(milliseconds: 1200), () {
            // <--- dots animation start
            _dotsAnimationController.forward();
          });
        }
      });
    _bikeSizeAnimation =
        Tween<double>(begin: 60.0, end: 36.0).animate(CurvedAnimation(
      parent: _bikeSizeAnimationController,
      curve: Curves.decelerate,
    ));
  }

  Widget _mapBikeStopToDot(stop) {
    int index = _bikeStops.indexOf(stop);
    bool isEnd = index == _bikeStops.length - 1;
    Color color = isEnd ? Colors.red : Colors.green;
    return AnimatedDot(
      animation: _dotPositions[index],
      color: color,
    );
  }

  @override
  void dispose() {
    _bikeSizeAnimationController.dispose();
    _bikeTravelController.dispose();
    _dotsAnimationController.dispose();
    super.dispose();
  }

  bool showBody = true;

  Widget _buildTimeLine() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.7,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AnimatedBuilder(
            animation: _bikeTravelAnimation,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.7,
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Column(
                    children: <Widget>[
                      AnimatedBikeIcon(
                        animation: _bikeSizeAnimation,
                      ),
                      Container(
                        width: 4.0,
                        height: _flightStops.length * _cardHeight * 0.8,
                        color: Color.fromARGB(255, 200, 200, 200),
                      ),
//                      child: Column(
//                          children: List.generate(
//                              20, (_) {
//                            return SizedBox(
//                              width: 4,
//                              height: _flightStops.length * _cardHeight * 0.8,
//                              child: DecoratedBox(
//                                decoration: BoxDecoration(
//                                    color: Color.fromARGB(255, 200, 200, 200)),
//                              ),
//                            );
//                          }),
//                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                          crossAxisAlignment: CrossAxisAlignment.center,
//                          mainAxisSize: MainAxisSize.max,
//                        ),
//                      ),
                    ],
                  ),
                ),
              ),
            ),
            builder: (context, child) => Positioned(
              top: _bikeTopPadding,
              child: child,
            ),
          ),
        ]
          ..addAll(_bikeStops.map(_buildStopCard))
          ..addAll(_bikeStops.map(_mapBikeStopToDot))
          ..add(_buildFab()),
      ),
    );
  }

  Widget _buildStopCard(BikeStop stop) {
    int index = _bikeStops.indexOf(stop);
    double topMargin = _dotPositions[index].value -
        0.5 * (BikeStopCard.height - AnimatedDot.size);
    bool isLeft = index.isOdd;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: topMargin),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            isLeft ? Container() : Expanded(child: Container()),
            Expanded(
              child: BikeStopCard(
                key: _stopKeys[index], //<--- Add a key
                bikeStop: stop,
                isLeft: isLeft,
              ),
            ),
            !isLeft ? Container() : Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  void _initDotAnimationController() {
    _dotsAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addStatusListener((status) {
            //<--- Add a listener to start card animations
            if (status == AnimationStatus.completed) {
              _animateBikeStopCards().then((_) => _animateFab());
            }
          });
  }

  Future _animateBikeStopCards() async {
    return Future.forEach(_stopKeys, (GlobalKey<BikeStopCardState> stopKey) {
      return Future.delayed(Duration(milliseconds: 250), () {
        stopKey.currentState.runAnimation();
      });
    });
  }

  void _initFabAnimationController() {
    _fabAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _fabAnimation = new CurvedAnimation(
        parent: _fabAnimationController, curve: Curves.easeOut);
  }

  _animateFab() {
    _fabAnimationController.forward();
  }

  Widget _buildFab() {
    return Positioned(
      bottom: 16.0,
      child: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.check, size: 36.0),
        ),
      ),
    );
  }

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
      floatingActionButton: Visibility(
        visible: showBody ? true : false,
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              showBody = false;
            });
          },
          child: Icon(
            Icons.timeline,
            size: 36,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
          showBody
              ? Expanded(
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    addRepaintBoundaries: true,
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
                  ),
                )
              : _buildTimeLine(),
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

  void _initDotAnimations() {
    final double slideDurationInterval = 0.4;
    final double slideDelayInterval = 0.2;
    double startingMarginTop = 450;
    double minMarginTop = 20 + _bikeSize + 0.5 * (0.8 * _cardHeight);

    for (int i = 0; i < _flightStops.length; i++) {
      final start = slideDelayInterval * i;
      final end = start + slideDurationInterval;

      double finalMarginTop = minMarginTop + i * (0.8 * _cardHeight);
      Animation<double> animation = Tween(
        begin: startingMarginTop,
        end: finalMarginTop,
      ).animate(
        CurvedAnimation(
          parent: _dotsAnimationController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
      _dotPositions.add(animation);
    }
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
}

class AnimatedBikeIcon extends AnimatedWidget {
  AnimatedBikeIcon({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    Animation<double> animation = super.listenable;
    return Container(
      width: animation.value,
      height: animation.value,
      child: Tab(
        icon: Image.asset(
          "assets/motorbike.png",
          color: Colors.redAccent,
        ),
      ),
    );
  }
}

class AnimatedDot extends AnimatedWidget {
  final Color color;
  static final double size = 24.0;

  AnimatedDot({
    Key key,
    Animation<double> animation,
    @required this.color,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    Animation<double> animation = super.listenable;
    return Positioned(
      top: animation.value,
      child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFFDDDDDD), width: 1.0)),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          )),
    );
  }
}

class BikeStop {
  String from;
  String to;
  String date;
  String duration;
  String price;
  String fromToTime;

  BikeStop(this.from, this.to, this.date, this.duration, this.price,
      this.fromToTime);
}

class BikeStopCard extends StatefulWidget {
  final BikeStop bikeStop;
  final bool isLeft;
  static const double height = 40.0;
  static const double width = 120.0;

  const BikeStopCard({Key key, @required this.bikeStop, @required this.isLeft})
      : super(key: key);

  @override
  BikeStopCardState createState() => BikeStopCardState();
}

class BikeStopCardState extends State<BikeStopCard>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _cardSizeAnimation;
  Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 600,
      ),
    );
    _cardSizeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.9,
        curve: ElasticOutCurve(0.8),
      ),
    );
    _lineAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.2, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void runAnimation() {
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: BikeStopCard.height,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            buildLine(),
            buildCard(),
          ],
        ),
      ),
    );
  }

  double get maxWidth {
    RenderBox renderBox = context.findRenderObject();
    BoxConstraints constraints = renderBox?.constraints;
    double maxWidth = constraints?.maxWidth ?? 0.0;
    return maxWidth;
  }

  Widget buildLine() {
    double animationValue = _lineAnimation.value;
    double maxLength = maxWidth - BikeStopCard.width;
    return Align(
        alignment: widget.isLeft ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          height: 2.0,
          width: maxLength * animationValue,
          color: Color.fromARGB(255, 200, 200, 200),
        ));
  }

  Positioned buildCard() {
    double animationValue = _cardSizeAnimation.value;
    double minOuterMargin = 8.0;
    double outerMargin = minOuterMargin + (1 - animationValue) * maxWidth;

    return Positioned(
      right: widget.isLeft ? null : outerMargin,
      left: widget.isLeft ? outerMargin : null,
      child: Container(
        width: 100.0,
        height: 40.0,
        child: Transform.scale(
          scale: animationValue,
          child: Card(
            color: Colors.grey.shade100,
            elevation: 3.0,
            child: Center(
              child: Text(
                'New',
                style: TextStyle(
                    fontFamily: 'Avenir-Bold',
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  double getMarginBottom(double animationValue) {
    double minBottomMargin = 8.0;
    double bottomMargin =
        minBottomMargin + (1 - animationValue) * minBottomMargin;
    return bottomMargin;
  }

  double getMarginTop(double animationValue) {
    double minMarginTop = 8.0;
    double marginTop =
        minMarginTop + (1 - animationValue) * BikeStopCard.height * 0.5;
    return marginTop;
  }

  double getMarginLeft(double animationValue) {
    return getMarginHorizontal(animationValue, true);
  }

  double getMarginRight(double animationValue) {
    return getMarginHorizontal(animationValue, false);
  }

  double getMarginHorizontal(double animationValue, bool isTextLeft) {
    if (isTextLeft == widget.isLeft) {
      double minHorizontalMargin = 16.0;
      double maxHorizontalMargin = maxWidth - minHorizontalMargin;
      double horizontalMargin =
          minHorizontalMargin + (1 - animationValue) * maxHorizontalMargin;
      return horizontalMargin;
    } else {
      double maxHorizontalMargin = maxWidth - BikeStopCard.width;
      double horizontalMargin = animationValue * maxHorizontalMargin;
      return horizontalMargin;
    }
  }
}

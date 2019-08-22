import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'bike_stop.dart';

class BikeStopCard extends StatefulWidget {
  final BikeStop bikeStop;
  final bool isLeft;
  static const double height = 80.0;
  static const double width = 140.0;

  const BikeStopCard({Key key, @required this.bikeStop, @required this.isLeft})
      : super(key: key);

  @override
  BikeStopCardState createState() => BikeStopCardState();
}

class BikeStopCardState extends State<BikeStopCard>
    with TickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _cardSizeAnimation;
  Animation<double> _titlePositionAnimation;
  Animation<double> _descriptionPositionAnimation;
  Animation<double> _lineAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _cardSizeAnimation = CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.9, curve: ElasticOutCurve(0.8)));
    _titlePositionAnimation = CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.1, 1.0, curve: ElasticOutCurve(0.95)));
    _descriptionPositionAnimation = CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.1, 0.95, curve: ElasticOutCurve(0.95)));
    _lineAnimation = CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.2, curve: Curves.linear));
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
      child: Transform.scale(
        scale: animationValue,
        child: Container(
          width: MediaQuery.of(context).size.width / 2 - 35,
          height: MediaQuery.of(context).size.height * 0.15,
          child: Card(
            color: Colors.grey.shade100,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 5.0),
                    child: Text(
                      "\u00B7 ${widget.bikeStop.title} \u00B7",
                      style: TextStyle(
                          fontFamily: 'AvenirBold',
                          fontSize: 14.0 * _titlePositionAnimation.value,
                          color: Colors.black87,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                    child: Text(
                      "${widget.bikeStop.description}",
                      style: TextStyle(
                        fontSize: 12.0 * _descriptionPositionAnimation.value,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 8,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
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

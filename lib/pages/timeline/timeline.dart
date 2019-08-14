import 'dart:async';
import 'package:chakh_le_flutter/static_variables/static_variables.dart';
import 'package:flutter/material.dart';

import 'animated_dot.dart';
import 'animated_bike_icon.dart';
import 'bike_stop.dart';
import 'bike_stop_card.dart';

class PriceTab extends StatefulWidget {
  final double height;
  final VoidCallback onBikeBikeStart;
  final String status;

  const PriceTab(
      {Key key, this.height, this.onBikeBikeStart, @required this.status})
      : super(key: key);

  @override
  _PriceTabState createState() => _PriceTabState();
}

class _PriceTabState extends State<PriceTab> with TickerProviderStateMixin {
  final double _initialBikePaddingBottom = 16.0;
  final double _minBikePaddingTop = 16.0;
  final List<BikeStop> _bikeStops = [
    BikeStop(
        title: ConstantVariables.statusDescription[0][0],
        description: ConstantVariables.statusDescription[0][1]),
    BikeStop(
        title: ConstantVariables.statusDescription[1][0],
        description: ConstantVariables.statusDescription[1][1]),
    BikeStop(
        title: ConstantVariables.statusDescription[2][0],
        description: ConstantVariables.statusDescription[2][1]),
    BikeStop(
        title: ConstantVariables.statusDescription[3][0],
        description: ConstantVariables.statusDescription[3][1]),
  ];
  final List<GlobalKey<BikeStopCardState>> _stopKeys = [];

  AnimationController _bikeSizeAnimationController;
  AnimationController _bikeTravelController;
  AnimationController _dotsAnimationController;
  AnimationController _fabAnimationController;
  AnimationController _blinker;
  Animation _bikeSizeAnimation;
  Animation _bikeTravelAnimation;
  Animation _fabAnimation;

  List<Animation<double>> _dotPositions = [];

  double get _bikeTopPadding =>
      _minBikePaddingTop +
      (1 - _bikeTravelAnimation.value) * _maxBikeTopPadding;

  double get _maxBikeTopPadding =>
      widget.height -
      _minBikePaddingTop -
      _initialBikePaddingBottom -
      _bikeSize;

  double get _bikeSize => _bikeSizeAnimation.value;

  @override
  void initState() {
    super.initState();
    _initSizeAnimations();
    _initBikeTravelAnimations();
    _initDotAnimationController();
    _initDotAnimations();
    _initFabAnimationController();
    _bikeStops.forEach((stop) => _stopKeys.add(GlobalKey<BikeStopCardState>()));
    _bikeSizeAnimationController.forward();
    _blinker = AnimationController(
        vsync: this, duration: Duration(seconds: 1), lowerBound: 0.5);
    _blinker.repeat();
  }

  @override
  void dispose() {
    _bikeSizeAnimationController.dispose();
    _bikeTravelController.dispose();
    _dotsAnimationController.dispose();
    _fabAnimationController.dispose();
    _blinker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[_buildBike()]
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
                key: _stopKeys[index],
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

  Widget _mapBikeStopToDot(BikeStop stop) {
    int index = _bikeStops.indexOf(stop);
    Color color = ConstantVariables.orderStatus.indexOf(stop.title) <
            ConstantVariables.orderStatus.indexOf(widget.status)
        ? Colors.green
        : Colors.red;
    if (ConstantVariables.orderStatus.indexOf(stop.title) ==
        ConstantVariables.orderStatus.indexOf(widget.status)) {
      return AnimatedDot(
        animation: _dotPositions[index],
        color: color,
        pulsing: true,
        blinker: _blinker,
      );
    } else {
      return AnimatedDot(
        animation: _dotPositions[index],
        color: color,
      );
    }
  }

  Widget _buildBike() {
    return AnimatedBuilder(
      animation: _bikeTravelAnimation,
      child: Column(
        children: <Widget>[
          AnimatedBikeIcon(animation: _bikeSizeAnimation),
          Container(
            width: 2.0,
            height: _bikeStops.length * BikeStopCard.height * 0.8,
            color: Color.fromARGB(255, 200, 200, 200),
          ),
        ],
      ),
      builder: (context, child) => Positioned(
        top: _bikeTopPadding,
        child: child,
      ),
    );
  }

  Widget _buildFab() {
    return Padding(
      padding:
          EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.6 - 20),
      child: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Icon(Icons.check, size: 36.0),
        ),
      ),
    );
  }

  _initSizeAnimations() {
    _bikeSizeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 340),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(Duration(milliseconds: 500), () {
            widget?.onBikeBikeStart();
            _bikeTravelController.forward();
          });
          Future.delayed(Duration(milliseconds: 700), () {
            _dotsAnimationController.forward();
          });
        }
      });
    _bikeSizeAnimation =
        Tween<double>(begin: 60.0, end: 36.0).animate(CurvedAnimation(
      parent: _bikeSizeAnimationController,
      curve: Curves.easeOut,
    ));
  }

  _initBikeTravelAnimations() {
    _bikeTravelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _bikeTravelAnimation = CurvedAnimation(
      parent: _bikeTravelController,
      curve: Curves.fastOutSlowIn,
    );
  }

  void _initDotAnimations() {
    //what part of whole animation takes one dot travel
    final double slideDurationInterval = 0.4;
    //what are delays between dot animations
    final double slideDelayInterval = 0.2;
    //at the bottom of the screen
    double startingMarginTop = widget.height;
    //minimal margin from the top (where first dot will be placed)
    double minMarginTop =
        _minBikePaddingTop + _bikeSize + 0.5 * (0.8 * BikeStopCard.height);

    for (int i = 0; i < _bikeStops.length; i++) {
      final start = slideDelayInterval * i;
      final end = start + slideDurationInterval;

      double finalMarginTop = minMarginTop + i * (0.8 * BikeStopCard.height);
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

  void _initDotAnimationController() {
    _dotsAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addStatusListener((status) {
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
    _fabAnimation =
        CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeOut);
  }

  _animateFab() {
    _fabAnimationController.forward();
  }
}

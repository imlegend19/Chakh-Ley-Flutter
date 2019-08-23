import 'package:flutter/material.dart';

class AnimatedBikeIcon extends AnimatedWidget {
  final bool hasDeliveryBoy;
  final AnimationController bikeBlinker;

  AnimatedBikeIcon({
    Key key,
    Animation<double> animation,
    @required this.hasDeliveryBoy,
    this.bikeBlinker,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    Animation<double> animation = super.listenable;
    if (hasDeliveryBoy) {
      return FadeTransition(
        opacity: bikeBlinker,
        child: Icon(
          Icons.directions_bike,
          color: Colors.green,
          size: animation.value,
        ),
      );
    } else {
      return Icon(
        Icons.directions_bike,
        color: Colors.red,
        size: animation.value,
      );
    }
  }
}

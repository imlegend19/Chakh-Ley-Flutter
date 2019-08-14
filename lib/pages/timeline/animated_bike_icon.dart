import 'package:flutter/material.dart';

class AnimatedBikeIcon extends AnimatedWidget {
  AnimatedBikeIcon({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    Animation<double> animation = super.listenable;
    return Icon(
      Icons.directions_bike,
      color: Colors.red,
      size: animation.value,
    );
  }
}

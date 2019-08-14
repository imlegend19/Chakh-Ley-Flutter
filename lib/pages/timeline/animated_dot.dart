import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

class AnimatedDot extends AnimatedWidget {
  final Color color;
  static final double size = 24.0;
  final bool pulsing;
  final AnimationController blinker;

  AnimatedDot({
    Key key,
    Animation<double> animation,
    @required this.color,
    this.pulsing = false,
    this.blinker,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    Animation<double> animation = super.listenable;

    if (pulsing) {
      return Positioned(
        top: animation.value,
        child: FadeTransition(
          opacity: blinker,
          child: Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFFDDDDDD), width: 1.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      );
    } else {
      return Positioned(
        top: animation.value,
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xFFDDDDDD), width: 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ),
      );
    }
  }
}

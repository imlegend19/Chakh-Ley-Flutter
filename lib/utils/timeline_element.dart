import 'package:flutter/material.dart';

import 'timeline_model.dart';
import 'timeline_painter.dart';

typedef void TapCallback(TimelineElement element);
typedef void LongPressCallback(TimelineElement element);

class TimelineElement extends StatelessWidget {
  final Color lineColor;
  final Color circleColor;
  final Color backgroundColor;
  final TimelineModel model;
  final bool firstElement;
  final bool lastElement;
  final bool isCancel;
  final Animation<double> controller;
  final Color headingColor;
  final Color descriptionColor;

  /// Called when the timeline item is tapped.
  final TapCallback onTap;

  /// Called when the timeline item is long pressed.
  final LongPressCallback onLongPress;

  TimelineElement(
      {@required this.lineColor,
      @required this.circleColor,
      @required this.backgroundColor,
      @required this.model,
        @required this.isCancel,
      this.firstElement = false,
      this.lastElement = false,
      this.controller,
      this.headingColor,
      this.descriptionColor,
      this.onTap,
      this.onLongPress});

  Widget _buildLine(BuildContext context, Widget child) {
    return Container(
      width: 40.0,
      child: CustomPaint(
        painter: TimelinePainter(
          lineColor: lineColor,
          circleColor: circleColor,
          backgroundColor: backgroundColor,
          firstElement: firstElement,
          lastElement: lastElement,
          controller: controller,
          isCancel: isCancel,
        ),
      ),
    );
  }

  Widget _buildContentColumn(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap(this);
        }
      },
      onLongPress: () {
        if (onLongPress != null) {
          onLongPress(this);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: 10.0, bottom: 5.0, top: 8.0),
            child: Text(
              model.title.length > 47
                  ? model.title.substring(0, 47) + "..."
                  : model.title,
              style: model.titleStyle,
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
            child: Text(
              model.description != null
                  ? (model.description.length > 100
                  ? model.description.substring(0, 100) + "..."
                  : model.description)
                  : "",
              style: model.descriptionStyle,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context) {
    return Container(
      height: 80.0,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AnimatedBuilder(
            builder: _buildLine,
            animation: controller,
          ),
          Expanded(child: _buildContentColumn(context)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildRow(context);
  }
}

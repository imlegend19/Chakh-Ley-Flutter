import 'package:flutter/material.dart';

import 'timeline_element.dart';
import 'timeline_model.dart';

typedef void ItemTapCallback(TimelineElement element);
typedef void ItemLongPressCallback(TimelineElement element);

class TimelineComponent extends StatefulWidget {
  final List<TimelineModel> timelineList;

  final Color lineColor;

  final Color backgroundColor;

  final Color headingColor;

  final Color descriptionColor;

  /// Called when the timeline item is tapped.
  final ItemTapCallback onItemTap;

  /// Called when the timeline item is long pressed.
  final ItemLongPressCallback onItemLongPress;

  final bool shrinkWrap;

  const TimelineComponent(
      {Key key,
      this.timelineList,
      this.lineColor,
      this.backgroundColor,
      this.headingColor,
      this.descriptionColor,
      this.onItemTap,
      this.onItemLongPress,
      this.shrinkWrap = false})
      : super(key: key);

  @override
  TimelineComponentState createState() {
    return TimelineComponentState();
  }
}

class TimelineComponentState extends State<TimelineComponent>
    with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  double fraction = 0.0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.timelineList.length,
      shrinkWrap: widget.shrinkWrap,
      physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        return TimelineElement(
            lineColor: widget.lineColor == null
                ? Theme
                .of(context)
                .accentColor
                : widget.lineColor,
            circleColor: widget.timelineList[index].circleColor == null
                ? Theme
                .of(context)
                .accentColor
                : widget.timelineList[index].circleColor,
            backgroundColor: widget.backgroundColor == null
                ? Colors.white
                : widget.backgroundColor,
            model: widget.timelineList[index],
            firstElement: index == 0,
            lastElement: widget.timelineList.length == index + 1,
            controller: controller,
            headingColor: widget.headingColor,
            descriptionColor: widget.descriptionColor,
            isCancel: widget.timelineList[index].isCancel,
            onTap: (TimelineElement element) {
              if (widget.onItemTap != null) {
                widget.onItemTap(element);
              }
            },
            onLongPress: (TimelineElement element) {
              if (widget.onItemLongPress != null) {
                widget.onItemLongPress(element);
              }
            });
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

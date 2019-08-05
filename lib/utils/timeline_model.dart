import 'package:flutter/material.dart';

class TimelineModel {
  final String id;
  final String title;
  final TextStyle titleStyle;
  final String description;
  final TextStyle descriptionStyle;
  final Color circleColor;
  final bool isCancel;

  const TimelineModel({
    this.id,
    this.title,
    this.titleStyle,
    this.description,
    this.descriptionStyle,
    this.circleColor,
    this.isCancel = false,
  });
}

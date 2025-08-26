import 'package:flutter/material.dart';

class IntroductionModel {
  String? title;
  String? subTitle;
  Color? color;
  Map<String, dynamic>? data;

  /// Can be image url or asset path
  String? image;

  IntroductionModel({
    this.title,
    this.subTitle,
    this.image,
    this.color,
    this.data,
  });
}

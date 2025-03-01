import 'package:flutter/material.dart';

class MonSmsProAuthStyle {
  final double paddingSize;
  final Color mainColor;
  final Color buttonTextColor;
  final BorderRadius buttonRadius;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;

  const MonSmsProAuthStyle({
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.paddingSize = 15,
    this.mainColor = Colors.black,
    this.buttonTextColor = Colors.white,
    this.buttonRadius = const BorderRadius.all(Radius.circular(15)),
  });
}

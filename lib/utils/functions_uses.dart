import 'package:flutter/material.dart';

TextStyle style_(
    {String fontFamily = 'Montserrat',
    FontWeight fontWeight = FontWeight.w900,
    double fontSize = 16.0,
    Color color = Colors.black,
    String}) {
  return TextStyle(
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      fontSize: fontSize,
      color: color);
}

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width * 0.95;
    screenHeight = _mediaQueryData.size.height * 0.95;
  }
}

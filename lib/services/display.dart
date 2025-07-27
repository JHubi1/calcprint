import 'package:flutter/material.dart';

class Display {
  final double _width;

  Display.from(BuildContext context)
    : _width = MediaQuery.sizeOf(context).width;

  bool get isPhone => _width < 600;

  bool get lessEqualTablet => isPhone || isTablet;
  bool get isTablet => !isPhone && !isDesktop;
  bool get moreEqualTablet => isTablet || isDesktop;

  bool get isDesktop => _width >= 1024;
}

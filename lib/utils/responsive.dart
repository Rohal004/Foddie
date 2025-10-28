import 'package:flutter/material.dart';

class Responsive {
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static bool isTablet(BuildContext context) => width(context) > 600;
  static bool isDesktop(BuildContext context) => width(context) > 1024;
}

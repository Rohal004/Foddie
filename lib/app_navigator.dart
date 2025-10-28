import 'package:flutter/widgets.dart';

/// Global navigator key used to perform navigation without a BuildContext.
/// This is helpful to avoid BuildContext usage across async gaps.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

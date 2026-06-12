import 'package:flutter/material.dart';

class HomeScrollBehavior extends MaterialScrollBehavior {
  const HomeScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Disable stretch/glow overscroll indicator to keep pull-to-refresh
    // feeling like a simple swipe gesture.
    return child;
  }
}

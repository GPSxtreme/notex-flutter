import 'package:flutter/material.dart';

class CustomScrollPhysics extends ClampingScrollPhysics {
  final Color? overscrollColor;

  const CustomScrollPhysics({this.overscrollColor, ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(
      overscrollColor: overscrollColor,
      parent: buildParent(ancestor),
    );
  }

  Color? get overscrollIndicatorColor => overscrollColor;
}

class CustomScrollBehavior extends ScrollBehavior {
  final Color scrollColor;

  const CustomScrollBehavior(this.scrollColor);
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return GlowingOverscrollIndicator(
      axisDirection: axisDirection,
      color: scrollColor, // Set the desired overscroll color
      child: child,
    );
  }
}

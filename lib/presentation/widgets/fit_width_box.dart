import 'dart:math';
import 'package:flutter/material.dart';
import 'package:notex/presentation/styles/size_config.dart';

class FitWidthBox extends StatelessWidget {
  const FitWidthBox({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SizedBox(
      width: min(SizeConfig.screenWidth!, 900),
      child: child,
    );
  }
}

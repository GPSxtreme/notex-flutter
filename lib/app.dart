import 'package:flutter/material.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import 'package:notex/router/app_route_config.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: MyAppRouter.getRouter(false),
    );
  }
}

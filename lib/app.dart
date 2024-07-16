import 'package:flutter/material.dart';
import 'package:notex/presentation/styles/size_config.dart';
import 'package:notex/presentation/styles/theme_data.dart';
import 'package:notex/router/app_route_config.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final router = MyAppRouter.getRouter();
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return MaterialApp.router(
      darkTheme: defaultThemeData,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}

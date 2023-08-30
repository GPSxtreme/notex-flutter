import 'package:flutter/material.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import 'package:notex/router/app_route_config.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: ThemeData.dark(useMaterial3: true),
      darkTheme: ThemeData(
          useMaterial3: true,
          appBarTheme:
              const AppBarTheme(iconTheme: IconThemeData(color: kWhite)),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
              showUnselectedLabels: false,
              selectedItemColor: kPink,
              backgroundColor: kPinkD1,
              elevation: 0,
              selectedLabelStyle: kInter.copyWith(color: kWhite)),
          listTileTheme: const ListTileThemeData(horizontalTitleGap: 30)),
      debugShowCheckedModeBanner: false,
      routerConfig: MyAppRouter.getRouter(),
    );
  }
}

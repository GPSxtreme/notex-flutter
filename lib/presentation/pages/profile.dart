import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../styles/app_styles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              splashRadius: 20,
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                GoRouter.of(context).pop();
              },
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            );
          },
        ),
        title: Text(
          "Profile",
          style: kInter,
        ),
        backgroundColor: kPageBgStart,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: kPageBgGradient),
      ),
    );
  }
}

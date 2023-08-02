import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../styles/app_styles.dart';
import '../styles/size_config.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: null,
      body: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight,
        decoration: const BoxDecoration(gradient: kPageBgGradient),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              left: SizeConfig.screenWidth! * 0.1,
              right: SizeConfig.screenWidth! * 0.1,
              child: SvgPicture.asset(
                "assets/svg/magnify-glass.svg",
              ),
            ),
            // showed when no notes are found
            Positioned(
                top: 0,
                bottom: 0,
                left: SizeConfig.screenWidth! * 0.1,
                right: SizeConfig.screenWidth! * 0.1,
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'No',
                      style: kInter.copyWith(
                          fontSize: 30, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: SizeConfig.blockSizeHorizontal! * 2,
                    ),
                    Text(
                      ' notes',
                      style: kInter.copyWith(
                        color: kPink,
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Found',
                  style: kInter.copyWith(
                      fontSize: 30, fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: SizeConfig.blockSizeVertical! * 3,
                ),
                Text(
                  "You can add new note by pressing\nAdd button at the bottom",
                  style: kInter.copyWith(fontSize: 15, color: kWhite24),
                  textAlign: TextAlign.center,
                )
              ],
            )),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
              child: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overScroll) {
                  overScroll.disallowIndicator();
                  return true;
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // note widgets go here if present
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

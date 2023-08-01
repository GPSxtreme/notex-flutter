import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import 'package:notex/presentation/styles/size_config.dart';


class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
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
            // showed when no to-dos are found
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
                          ' todos',
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
                      "You can add new todo by pressing\nAdd button at the bottom",
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
                      // to-do widgets go here if present
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPink,
        onPressed: () {
          // create new note
          print("add todo pressed");
        },
        child: Icon(
          Icons.add,
          color: kWhite,
          size: SizeConfig.blockSizeVertical! * 5,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:notex/presentation/pages/notes.dart';
import 'package:notex/presentation/pages/todos.dart';
import 'package:notex/presentation/styles/app_styles.dart';

import '../styles/size_config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: kPageBgEnd,
      appBar: AppBar(
        centerTitle: true,
        title: SvgPicture.asset(
          'assets/svg/app_logo.svg',
          height: SizeConfig.blockSizeVertical! * 5,
        ),
        backgroundColor: kPageBgStart,
        elevation: 0,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            backgroundColor: kPinkD1,
            elevation: 0,
            selectedLabelStyle: kInter.copyWith(color: kPink,fontSize: 14),
            unselectedLabelStyle: kInter.copyWith(color: kWhite,fontSize: 14),
            selectedItemColor: kPink,
            onTap: _goBranch,
            currentIndex: widget.navigationShell.currentIndex,
            items: [
              BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/svg/notes_icon.svg',
                  ),
                  activeIcon: SvgPicture.asset(
                    'assets/svg/notes_icon.svg',
                    color: kPink,
                  ),
                  label: "notes"),
              BottomNavigationBarItem(
                  icon: SvgPicture.asset('assets/svg/todo_icon.svg'),
                  activeIcon: SvgPicture.asset(
                    'assets/svg/todo_icon.svg',
                    color: kPink,
                  ),
                  label: "todo")
            ],
          ),
        ),
      ),
      body: GoRouter.of(context).routerDelegate.currentConfiguration.uri.path == '/notes' ? const NotesPage() : const TodosPage(),
    );
  }
}

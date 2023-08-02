// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notex/presentation/pages/notes.dart';
import 'package:notex/presentation/pages/todos.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import '../physics/custom_scroll_physics.dart';
import '../styles/size_config.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

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
        floatingActionButton: FloatingActionButton(
          backgroundColor: kPink,
          onPressed: () {
            print(_currentIndex);
          },
          child: Icon(
            Icons.add,
            color: kWhite,
            size: SizeConfig.blockSizeVertical! * 5,
          ),
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
            onTap: (index){
              _pageController.animateToPage(index ,duration: const Duration(milliseconds: 500), curve: Curves.ease);
            },
            currentIndex: _currentIndex,
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
      body: ScrollConfiguration(
        behavior: const CustomScrollBehavior(kPinkD1), // Create a custom ScrollBehavior
        child: PageView(
          controller: _pageController,
          onPageChanged: (newIndex) {
            setState(() {
              _currentIndex = newIndex;
            });
          },
          children: const [
            NotesPage(),
            TodosPage()
          ],
        ),
      ),

    );
  }
}

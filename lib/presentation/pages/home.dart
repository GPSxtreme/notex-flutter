// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:notex/presentation/blocs/notes/notes_bloc.dart';
import 'package:notex/presentation/blocs/todos/todos_bloc.dart';
import 'package:notex/presentation/pages/notes.dart';
import 'package:notex/presentation/pages/todos.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import '../styles/size_config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController(initialPage: 0);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentPageIndex = 0;
  final NotesBloc notesBloc = NotesBloc();
  final TodosBloc todosBloc = TodosBloc();
  bool _selectAllTodos = false;
  bool _selectAllNotes = false;

  @override
  void dispose(){
    todosBloc.close();
    super.dispose();
  }


  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return kPink;
    }
    return kPink;
  }

  Widget _buildBottomActionBar() {
    return Container(
      color: kPinkD1,
      height: kBottomNavigationBarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox.fromSize(
            size: const Size(kBottomNavigationBarHeight, kBottomNavigationBarHeight), // button width and height
            child: ClipOval(
              child: Material(
                color: Colors.transparent, // button color
                child: InkWell(
                  splashColor: kPinkD2, // splash color
                  onTap: () {
                    todosBloc.add(TodosDeleteSelectedTodosEvent());
                  }, // button pressed
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/svg/delete_icon.svg',
                      ), // icon
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          'Delete',
                          style: kInter.copyWith(color: kWhite, fontSize: 12),
                        ),
                      ), // text
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox.fromSize(
            size: const Size(56, 56), // button width and height
            child: ClipOval(
              child: Material(
                color: Colors.transparent, // button color
                child: InkWell(
                  splashColor: kPinkD2, // splash color
                  onTap: () {}, // button pressed
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.asset(
                        'assets/svg/hide_icon.svg',
                      ), // icon
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          'Hide',
                          style: kInter.copyWith(color: kWhite, fontSize: 12),
                        ),
                      ), // text
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: kPinkD1,
      elevation: 0,
      selectedLabelStyle: kInter.copyWith(color: kPink, fontSize: 14),
      unselectedLabelStyle: kInter.copyWith(color: kWhite, fontSize: 14),
      selectedItemColor: kPink,
      onTap: (index) {
        _pageController.animateToPage(index,
            duration: const Duration(milliseconds: 500), curve: Curves.ease);
      },
      currentIndex: _currentPageIndex,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return BlocBuilder(
      bloc: notesBloc,
      buildWhen: (previous, current) =>
          current is NotesActionState || (previous == null || current == null),
      builder: (context, notesState) {
        return BlocBuilder(
          bloc: todosBloc,
          buildWhen: (previous, current) =>
              current is TodosActionState ||
              (previous == null || current == null),
          builder: (context, todosState) {

            bool isInEditing = (todosState is TodosEnteredEditingState ||
                notesState is NotesEnteredEditingState);
            bool isFetching = (todosState is TodosFetchingState || notesState is NotesFetchingState);
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: kPageBgEnd,
              appBar: AppBar(
                backgroundColor: kPageBgStart,
                centerTitle: true,
                leadingWidth: 10.0,
                elevation: 0,
                title: !isInEditing
                    ? SvgPicture.asset(
                        'assets/svg/app_logo.svg',
                        height: SizeConfig.blockSizeVertical! * 5,
                      )
                    : SizedBox(
                        width: SizeConfig.screenWidth! * 0.95,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: IconButton(
                                splashRadius: 20,
                                icon: const Icon(
                                  Icons.close,
                                  color: kWhite,
                                  size: 30,
                                ),
                                onPressed: () {
                                  // emit cancel event,
                                  todosBloc.add(TodosExitedEditingEvent());
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Transform.scale(
                                scale: 1.3,
                                child: Checkbox(
                                    value: _selectAllTodos,
                                    checkColor: kPinkD1,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    fillColor:
                                        MaterialStateProperty.resolveWith(
                                            getColor),
                                    onChanged: (bool? value) {
                                      if (value != null) {
                                        // select / unselect all tiles.
                                        setState(() {
                                          _selectAllTodos = value;
                                        });
                                        todosBloc.add(
                                            TodosAreAllTodosSelectedEvent(
                                                value));
                                      }
                                    }),
                              ),
                            )
                          ],
                        ),
                      ),
              ),
              floatingActionButton: !isInEditing && !isFetching
                  ? FloatingActionButton(
                      backgroundColor: kPink,
                      onPressed: () {
                        switch (_currentPageIndex) {
                          case 0: // notes page

                            break;
                          case 1: // todos page
                            todosBloc.add(TodosShowAddTodoDialogBoxEvent());
                            break;
                        }
                      },
                      child: Icon(
                        Icons.add,
                        color: kWhite,
                        size: SizeConfig.blockSizeVertical! * 5,
                      ),
                    )
                  : null,
              bottomNavigationBar: !isInEditing
                  ? _buildBottomNavigationBar()
                  : _buildBottomActionBar(),
              body: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(overscroll: false),
                // Create a custom ScrollBehavior
                child: PageView(
                  controller: _pageController,
                  physics:
                      isInEditing ? const NeverScrollableScrollPhysics() : null,
                  onPageChanged: (newIndex) {
                    setState(() {
                      _currentPageIndex = newIndex;
                    });
                  },
                  children: [
                    BlocProvider(
                      create: (context) => notesBloc..add(NotesInitialEvent()),
                      child: const NotesPage(),
                    ),
                    BlocProvider(
                      create: (context) => todosBloc..add(TodosInitialEvent()),
                      child: const TodosPage(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ignore_for_file: deprecated_member_use
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:notex/presentation/blocs/notes/notes_bloc.dart';
import 'package:notex/presentation/blocs/todos/todos_bloc.dart';
import 'package:notex/presentation/pages/notes.dart';
import 'package:notex/presentation/pages/todos.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import '../../core/config/api_routes.dart';
import '../../core/repositories/auth_repository.dart';
import '../../router/app_route_constants.dart';
import '../styles/size_config.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';

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
  final _advancedDrawerController = AdvancedDrawerController();

  @override
  void dispose() {
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
            size: const Size(
                kBottomNavigationBarHeight, kBottomNavigationBarHeight),
            // button width and height
            child: ClipOval(
              child: Material(
                color: Colors.transparent, // button color
                child: InkWell(
                  splashColor: kPinkD2, // splash color
                  onTap: () {
                    if (_currentPageIndex == 1) {
                      todosBloc.add(TodosDeleteSelectedTodosEvent());
                    } else if (_currentPageIndex == 0) {
                      notesBloc.add(NotesDeleteSelectedNotesEvent());
                    }
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
                  onTap: () {
                    if (_currentPageIndex == 1) {
                      todosBloc.add(TodosHideSelectedTodosEvent());
                    } else if (_currentPageIndex == 0) {
                      notesBloc.add(NotesHideSelectedNotesEvent());
                    }
                  }, // button pressed
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
  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }

  @override
  Widget build(BuildContext context) {

    SizeConfig().init(context);
    return BlocConsumer(
      bloc: notesBloc,
      buildWhen: (previous, current) => current is NotesHomeState,
      listener: (context, notesState) {
        if (notesState is NotesSetAllNotesSelectedCheckBoxState) {
          setState(() {
            _selectAllNotes = notesState.flag;
          });
        } else if (notesState is NotesExitedEditingState) {
          setState(() {
            _selectAllNotes = false;
          });
        }
      },
      builder: (context, notesState) {
        return BlocConsumer(
          bloc: todosBloc,
          buildWhen: (previous, current) => current is TodosHomeState,
          listener: (context, todosState) {
            if (todosState is TodosSetAllTodosSelectedCheckBoxState) {
              setState(() {
                _selectAllTodos = todosState.flag;
              });
            } else if (todosState is TodosExitedEditingState) {
              setState(() {
                _selectAllTodos = false;
              });
            }
          },
          builder: (context, todosState) {
            bool isInEditing = (todosState is TodosEditingState ||
                        notesState is NotesEditingState) &&
                    (notesState is! NotesEmptyState ||
                        todosState is! TodosEmptyState)
                ? true
                : false;
            bool isFetching = (todosState is TodosFetchingState ||
                    notesState is NotesFetchingState)
                ? true
                : false;

            return AdvancedDrawer(
              backdrop: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: kPageBgGradient,
                ),
              ),
              controller: _advancedDrawerController,
              animationCurve: Curves.easeInOut,
              animationDuration: const Duration(milliseconds: 300),
              animateChildDecoration: true,
              rtlOpening: false,
              openScale: 0.9,
              disabledGestures: false,
              childDecoration: const BoxDecoration(
                // NOTICE: Uncomment if you want to add shadow behind the page.
                // Keep in mind that it may cause animation jerks.
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2.0,
                  ),
                ],
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              drawer: SafeArea(
                child: SizedBox(
                  child: ListTileTheme(
                    textColor: kWhite,
                    iconColor: kPinkD1,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          width: 128.0,
                          height: 128.0,
                          margin: const EdgeInsets.only(
                            top: 24.0,
                            bottom: 64.0,
                          ),
                          clipBehavior: Clip.antiAlias,
                          decoration: const BoxDecoration(
                            color: Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: CachedNetworkImage(
                            imageUrl: USER_PROFILE_PICTURE_GET_ROUTE,
                            httpHeaders: {
                              'Content-Type': 'application/json',
                              'Authorization': AuthRepository.userToken
                            },
                            width: 128.0,
                            height: 128.0,
                          ),
                        ),
                        ListTile(
                          onTap: () {},
                          contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                          leading: const Icon(Icons.account_circle_rounded),
                          title: Text('Profile',style: kInter,),
                        ),
                        ListTile(
                          onTap: () {},
                          contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                          leading: const Icon(Icons.favorite),
                          title: Text('Favourites',style: kInter,),
                        ),
                        ListTile(
                          onTap: () {},
                          contentPadding: const EdgeInsets.symmetric(horizontal: 30),
                          leading: const Icon(Icons.settings),
                          title: Text('Settings',style: kInter,),
                        ),
                        const Spacer(),
                        DefaultTextStyle(
                          style: kInter.copyWith(color: kWhite75,fontSize: 12),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 16.0,
                            ),
                            child: const Text('Terms of Service | Privacy Policy'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              child: Scaffold(
                key: _scaffoldKey,
                backgroundColor: kPageBgEnd,
                appBar: AppBar(
                  backgroundColor: kPageBgStart,
                  centerTitle: true,
                  elevation: 0,
                  leadingWidth: 100,
                  leading: !isFetching && !isInEditing ? Row(
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      IconButton(
                        splashRadius: 20,
                        onPressed: _handleMenuButtonPressed,
                        icon: ValueListenableBuilder<AdvancedDrawerValue>(
                          valueListenable: _advancedDrawerController,
                          builder: (_, value, __) {
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Icon(
                                value.visible ? Icons.clear : Ionicons.menu_outline,
                                size: 35,
                                key: ValueKey<bool>(value.visible),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ) : null,
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
                                    _currentPageIndex == 0
                                        ? notesBloc.add(NotesExitedEditingEvent())
                                        : todosBloc
                                            .add(TodosExitedEditingEvent());
                                  },
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Transform.scale(
                                  scale: 1.3,
                                  child: Checkbox(
                                      value: _currentPageIndex == 0
                                          ? _selectAllNotes
                                          : _selectAllTodos,
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
                                            _currentPageIndex == 0
                                                ? _selectAllNotes = value
                                                : _selectAllTodos = value;
                                          });
                                          _currentPageIndex == 0
                                              ? notesBloc.add(
                                                  NotesAreAllNotesSelectedEvent(
                                                      value))
                                              : todosBloc.add(
                                                  TodosAreAllTodosSelectedEvent(
                                                      value));
                                        }
                                      }),
                                ),
                              )
                            ],
                          ),
                        ),
                  actions: !isFetching && !isInEditing ? [

                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: IconButton(
                          onPressed: () {},
                          splashRadius: 20,
                          icon: const Icon(
                            Ionicons.ellipsis_vertical,
                            color: kWhite,
                            size: 25,
                          )),
                    )
                  ] : null,
                ),
                floatingActionButton: !isInEditing && !isFetching
                    ? FloatingActionButton(
                        backgroundColor: kPink,
                        onPressed: () {
                          switch (_currentPageIndex) {
                            case 0: // notes page
                              GoRouter.of(context).pushNamed(
                                  AppRouteConstants.noteViewRouteName,
                                  pathParameters: {'noteId': 'new'},
                                  extra: notesBloc);
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
              ),
            );
          },
        );
      },
    );
  }
}

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
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/app_text.dart';
import '../../core/config/api_routes.dart';
import '../../core/repositories/auth_repository.dart';
import '../../main.dart';
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
  bool _isNotesHiddenMode = false;
  bool _isNotesDeletedMode = false;
  final _advancedDrawerController = AdvancedDrawerController();

  @override
  void dispose() {
    todosBloc.close();
    super.dispose();
  }

  Widget _buildActionLabelButton(
          IconData icon, String label, void Function() onTap) =>
      Padding(
        padding: EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onTap,
                borderRadius: AppBorderRadius.full,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: AppSpacing.iconSize2Xl,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                label,
                style: AppText.textSmMedium
                    .copyWith(color: AppColors.mutedForeground),
              ),
            )
          ],
        ),
      );

  Widget _buildBottomActionBar() {
    return Material(
      color: AppColors.secondary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionLabelButton(Icons.delete_rounded, "Delete", () {
            if (_currentPageIndex == 1) {
              todosBloc.add(TodosDeleteSelectedTodosEvent());
            } else if (_currentPageIndex == 0) {
              notesBloc.add(NotesDeleteSelectedNotesEvent(
                  isInHiddenMode: _isNotesHiddenMode));
            }
          }),
          _buildActionLabelButton(Icons.sync_rounded, "Sync", () {
            if (_currentPageIndex == 1) {
              // sync to-do
              todosBloc.add(TodosSyncSelectedTodosEvent());
            } else if (_currentPageIndex == 0) {
              // sync note
              notesBloc.add(NotesSyncSelectedNotesEvent(
                  isInHiddenMode: _isNotesHiddenMode));
            }
          }),
          if (_currentPageIndex == 0)
            _buildActionLabelButton(
                _isNotesHiddenMode ? Icons.visibility_off : Icons.visibility,
                !_isNotesHiddenMode ? 'Hide' : 'Unhide', () {
              !_isNotesHiddenMode
                  ? notesBloc.add(NotesHideSelectedNotesEvent())
                  : notesBloc.add(NotesUnHideSelectedNotesEvent(
                      isInHiddenMode: _isNotesHiddenMode));
            })
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      onTap: (index) {
        _pageController.animateToPage(index,
            duration: const Duration(milliseconds: 500), curve: Curves.ease);
      },
      selectedLabelStyle:
          AppText.textBaseMedium.copyWith(color: AppColors.primary),
      unselectedLabelStyle: AppText.textBaseMedium,
      currentIndex: _currentPageIndex,
      useLegacyColorScheme: false,
      items: [
        BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svg/notes_icon.svg',
            ),
            activeIcon: SvgPicture.asset(
              'assets/svg/notes_icon.svg',
            ),
            label: "Notes"),
        BottomNavigationBarItem(
            icon: SvgPicture.asset('assets/svg/todo_icon.svg'),
            activeIcon: SvgPicture.asset(
              'assets/svg/todo_icon.svg',
            ),
            label: "Todo")
      ],
    );
  }

  void _handleMenuButtonPressed() {
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
        if (notesState is NotesState) {
          _isNotesHiddenMode = notesState.isInHiddenMode;
          _isNotesDeletedMode = notesState.isInDeletedMode;
        }
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
              controller: _advancedDrawerController,
              animationCurve: Curves.easeInOut,
              animationDuration: const Duration(milliseconds: 300),
              animateChildDecoration: true,
              rtlOpening: false,
              openScale: 0.9,
              disabledGestures: notesState is NotesEditingState ||
                  todosState is TodosEditingState,
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
              drawer: Material(
                color: Colors.transparent,
                child: SafeArea(
                  child: ListTileTheme(
                    contentPadding: EdgeInsets.zero,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _advancedDrawerController.hideDrawer();
                            GoRouter.of(context)
                                .pushNamed(AppRouteConstants.profileRouteName);
                          },
                          child: Container(
                            width: 128.0,
                            height: 128.0,
                            margin: EdgeInsets.only(
                                top: 24.0,
                                bottom: !USER.data!.isEmailVerified ? 20 : 30),
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: USER_PROFILE_PICTURE_GET_ROUTE,
                                httpHeaders: {
                                  'Content-Type': 'application/json',
                                  'Authorization': AuthRepository.userToken
                                },
                                cacheKey: USER.profilePictureCacheKey,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                        CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  Icons.person,
                                  size: 70,
                                ),
                                width: 128.0,
                                height: 128.0,
                              ),
                            ),
                          ),
                        ),
                        if (!USER.data!.isEmailVerified)
                          Container(
                              margin: EdgeInsets.only(bottom: AppSpacing.sm),
                              padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.md),
                              decoration: const BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(16),
                                    bottomRight: Radius.circular(16)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Ionicons.alert_circle_outline,
                                    color: Colors.yellow,
                                    size: AppSpacing.iconSize3Xl,
                                  ),
                                  SizedBox(
                                    width: AppSpacing.md,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Account not verified",
                                          style: AppText.textLgSemiBold,
                                        ),
                                        SizedBox(
                                          height: AppSpacing.sm,
                                        ),
                                        Text(
                                            "Go to settings to start verification",
                                            style: AppText.textSm.copyWith(
                                                color:
                                                    AppColors.mutedForeground)),
                                      ],
                                    ),
                                  )
                                ],
                              )),
                        ListTile(
                          onTap: () {
                            _advancedDrawerController.hideDrawer();
                            GoRouter.of(context)
                                .pushNamed(AppRouteConstants.profileRouteName);
                          },
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          leading: const Icon(
                            Icons.account_circle_rounded,
                            color: AppColors.mutedForeground,
                          ),
                          title: const Text(
                            'Profile',
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            _advancedDrawerController.hideDrawer();
                            GoRouter.of(context)
                                .pushNamed(AppRouteConstants.settingsRouteName);
                          },
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          leading: const Icon(
                            Icons.settings,
                            color: AppColors.mutedForeground,
                          ),
                          title: const Text(
                            'Settings',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              child: Scaffold(
                key: _scaffoldKey,
                appBar: AppBar(
                  centerTitle: true,
                  elevation: 0,
                  leadingWidth: 100,
                  leading: !isFetching && !isInEditing
                      ? Row(
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
                                      value.visible
                                          ? Icons.clear
                                          : Ionicons.menu_outline,
                                      size: 35,
                                      key: ValueKey<bool>(value.visible),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      : null,
                  title: !isInEditing
                      ? SvgPicture.asset(
                          'assets/svg/app_logo_v2.svg',
                          height: SizeConfig.blockSizeVertical! * 3.5,
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
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    // emit cancel event,
                                    _currentPageIndex == 0
                                        ? notesBloc.add(NotesExitedEditingEvent(
                                            isInHiddenMode: _isNotesHiddenMode))
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
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
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
                                                      value,
                                                      isInHiddenMode:
                                                          _isNotesHiddenMode))
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
                  actions: !isFetching && !isInEditing
                      ? [
                          Padding(
                            padding: EdgeInsets.only(right: AppSpacing.md),
                            child: PopupMenuButton<String>(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              icon: const Icon(
                                Ionicons.ellipsis_vertical,
                                size: 25,
                              ),
                              splashRadius: 20,
                              onSelected: (value) {
                                switch (value) {
                                  case 'refetch':
                                    if (_currentPageIndex == 0) {
                                      notesBloc.add(NotesInitialEvent(
                                          isInHiddenMode: _isNotesHiddenMode,
                                          isInDeletedMode:
                                              _isNotesDeletedMode));
                                    } else if (_currentPageIndex == 1) {
                                      todosBloc.add(TodosInitialEvent());
                                    }
                                    break;
                                  case 'sync':
                                    if (_currentPageIndex == 0) {
                                      notesBloc.add(NotesSyncAllNotesEvent(
                                          isInHiddenMode: _isNotesHiddenMode,
                                          isInDeletedMode:
                                              _isNotesDeletedMode));
                                    } else if (_currentPageIndex == 1) {
                                      todosBloc.add(TodosSyncAllTodosEvent());
                                    }
                                    break;
                                  case 'showHidden':
                                    // Handle show hidden action for notes
                                    // todo : to ask user for privacy password provided by android
                                    notesBloc.add(NotesShowHiddenNotesEvent(
                                        value: !_isNotesHiddenMode));
                                    break;
                                  case 'showDeleted':
                                    // Handle show deleted action for notes
                                    notesBloc.add(NotesShowDeletedNotesEvent(
                                        value: !_isNotesDeletedMode));
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  const PopupMenuItem<String>(
                                    value: 'refetch',
                                    child: ListTile(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 0),
                                      horizontalTitleGap: 15,
                                      leading: Icon(
                                        Icons.refresh,
                                      ),
                                      title: Text(
                                        'Reload',
                                      ),
                                      tileColor: Colors.transparent,
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'sync',
                                    child: ListTile(
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 0),
                                      horizontalTitleGap: 15,
                                      leading: Icon(
                                        Icons.sync,
                                      ),
                                      title: Text(
                                        'Sync All',
                                      ),
                                      tileColor: Colors.transparent,
                                    ),
                                  ),
                                  if (_currentPageIndex == 0)
                                    PopupMenuItem<String>(
                                      value: 'showHidden',
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 0),
                                        horizontalTitleGap: 15,
                                        leading: Icon(
                                          !_isNotesHiddenMode
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        title: Text(
                                          !_isNotesHiddenMode
                                              ? 'Show Hidden'
                                              : 'Hide Hidden',
                                        ),
                                        tileColor: Colors.transparent,
                                      ),
                                    ),
                                  if (_currentPageIndex == 0)
                                    PopupMenuItem<String>(
                                      value: 'showDeleted',
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 0),
                                        horizontalTitleGap: 15,
                                        leading: Icon(
                                          !_isNotesDeletedMode
                                              ? Icons.delete
                                              : Icons.hide_source,
                                        ),
                                        title: Text(
                                          !_isNotesDeletedMode
                                              ? 'Show Deleted'
                                              : 'Hide Deleted',
                                        ),
                                        tileColor: Colors.transparent,
                                      ),
                                    ),
                                ];
                              },
                            ),
                          ),
                        ]
                      : null,
                ),
                floatingActionButton: !isInEditing &&
                        !isFetching &&
                        !(_currentPageIndex == 0 &&
                            (_isNotesHiddenMode || _isNotesDeletedMode))
                    ? FloatingActionButton(
                        onPressed: () {
                          switch (_currentPageIndex) {
                            case 0: // notes page
                              GoRouter.of(context).pushNamed(
                                  AppRouteConstants.noteViewRouteName,
                                  pathParameters: {
                                    'noteId': 'new',
                                    'isInHiddenMode': 'false'
                                  },
                                  extra: notesBloc);
                              break;
                            case 1: // todos page
                              todosBloc.add(TodosShowAddTodoDialogBoxEvent());
                              break;
                          }
                        },
                        child: Icon(
                          Icons.add_rounded,
                          size: AppSpacing.iconSize2Xl,
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
                    physics: isInEditing
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    onPageChanged: (newIndex) {
                      setState(() {
                        _currentPageIndex = newIndex;
                      });
                    },
                    children: [
                      BlocProvider(
                        create: (context) =>
                            notesBloc..add(const NotesInitialEvent()),
                        child: const NotesPage(),
                      ),
                      BlocProvider(
                        create: (context) =>
                            todosBloc..add(TodosInitialEvent()),
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

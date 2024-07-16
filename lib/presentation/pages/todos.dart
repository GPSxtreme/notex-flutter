import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:notex/presentation/blocs/todos/todos_bloc.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import 'package:notex/presentation/styles/app_text.dart';
import 'package:notex/presentation/styles/size_config.dart';
import 'package:notex/presentation/widgets/add_todo_dialog_box.dart';
import 'package:notex/presentation/widgets/todo_tile.dart';
import '../../data/models/todo_model.dart';

// ignore: constant_identifier_names
const ANIMATION_DURATION = 220;

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage>
    with AutomaticKeepAliveClientMixin<TodosPage> {
  late TodosBloc todosBloc; // Declare the NotesBloc variable
  final _doneTodosListKey = GlobalKey<AnimatedListState>();
  final _notDoneTodosListKey = GlobalKey<AnimatedListState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late List<TodoModel> doneTodos;
  late List<TodoModel> notDoneTodos;
  bool _isSyncing = false;
  int _noOfTodosSyncing = 0;
  int _noOfTodosNotUploaded = 0;
  bool _areTodosNotUploaded = false;

  @override
  bool get wantKeepAlive => true;

  commonTodoTile(int todoIndex, TodoModel todo) =>
      AnimationConfiguration.staggeredGrid(
        position: todoIndex,
        duration: const Duration(milliseconds: ANIMATION_DURATION),
        columnCount: 1,
        child: FlipAnimation(
          child: FadeInAnimation(
            child: Padding(
              key: ValueKey<int>(todoIndex),
              padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.blockSizeVertical! * 0.8),
              child: TodoTile(todo: todo, todosBloc: todosBloc),
            ),
          ),
        ),
      );

  @override
  void initState() {
    super.initState();
    todosBloc = BlocProvider.of<TodosBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    SizeConfig().init(context);
    return BlocConsumer(
      bloc: todosBloc,
      listenWhen: (previous, current) => current is TodosActionState,
      buildWhen: (previous, current) => current is! TodosActionState,
      listener: (context, state) {
        if (state is TodosShowAddTodoDialogBoxState) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return AddTodoDialogBox(
                todosBloc: todosBloc,
              );
            },
          );
        } else if (state is TodosAddTodoSuccessState) {
          kSnackBar(context, "Successfully added todo!");
        } else if (state is TodosOperationFailedState) {
          kSnackBar(context, state.reason);
        }
      },
      builder: (context, state) {
        if (state is TodosFetchedState) {
          doneTodos = state.doneTodos;
          notDoneTodos = state.notDoneTodos;
          if (state.syncingTodos != null) {
            _isSyncing = true;
            _noOfTodosSyncing = state.syncingTodos!.length;
          } else {
            _isSyncing = false;
          }
          if (doneTodos.any((t) => !t.isUploaded) ||
              notDoneTodos.any((t) => !t.isUploaded)) {
            _areTodosNotUploaded = true;
            _noOfTodosNotUploaded = [
              ...doneTodos.where((e) => !e.isUploaded),
              ...notDoneTodos.where((e) => !e.isUploaded)
            ].length;
          } else {
            _areTodosNotUploaded = false;
          }
        } else if (state is TodosEditingState) {
          doneTodos = state.doneTodos;
          notDoneTodos = state.notDoneTodos;
        }
        return Scaffold(
          key: _scaffoldKey,
          appBar: null,
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            child: Stack(
              children: [
                if (state is TodosEmptyState) ...[
                  SizedBox(
                    width: SizeConfig.screenWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Material(
                          shape: const CircleBorder(),
                          color: AppColors.muted,
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xl),
                            child: Icon(
                              Icons.visibility_off_rounded,
                              color: AppColors.mutedForeground,
                              size: AppSpacing.iconSize2Xl,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppSpacing.lg,
                        ),
                        Text(
                          'No Todos',
                          style: AppText.textXlBold,
                        ),
                        Text(
                          "Found",
                          style: AppText.textBase,
                        ),
                        SizedBox(
                          height: AppSpacing.md,
                        ),
                        SizedBox(
                          width: SizeConfig.screenWidth! * 0.6,
                          child: Text(
                            "You can add new todo by pressing\nAdd button at the bottom",
                            textAlign: TextAlign.center,
                            style: AppText.textSm
                                .copyWith(color: AppColors.mutedForeground),
                          ),
                        )
                      ],
                    ),
                  ),
                ] else if (state is TodosFetchingState) ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitRing(
                        color: AppColors.primary,
                        size: AppSpacing.iconSize3Xl,
                        lineWidth: 5,
                      ),
                      SizedBox(
                        height: AppSpacing.lg,
                      ),
                      Text('This might take a while',
                          textAlign: TextAlign.center,
                          style: AppText.textSm
                              .copyWith(color: AppColors.mutedForeground))
                    ],
                  )
                ] else if (state is TodosFetchingFailedState) ...[
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Material(
                          shape: const CircleBorder(),
                          color: AppColors.muted,
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xl),
                            child: Icon(
                              Icons.visibility_off_rounded,
                              color: AppColors.mutedForeground,
                              size: AppSpacing.iconSize2Xl,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppSpacing.lg,
                        ),
                        Text(
                          'Failed to load notes',
                          style: AppText.textXlBold,
                        ),
                        SizedBox(
                          height: AppSpacing.md,
                        ),
                        Text(
                          state.reason,
                          textAlign: TextAlign.center,
                          style: AppText.textSm
                              .copyWith(color: AppColors.mutedForeground),
                        ),
                      ],
                    ),
                  )
                ] else if (state is TodosFetchedState ||
                    state is TodosEditingState) ...[
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 0),
                    child:
                        NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overScroll) {
                        overScroll.disallowIndicator();
                        return true;
                      },
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!_isSyncing &&
                                _areTodosNotUploaded &&
                                state is! TodosEditingState) ...[
                              AnimationConfiguration.synchronized(
                                duration: const Duration(milliseconds: 375),
                                child: FlipAnimation(
                                  child: FadeInAnimation(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: AppSpacing.md),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        borderRadius: AppBorderRadius.lg,
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '$_noOfTodosNotUploaded ${_noOfTodosNotUploaded == 1 ? 'todo is' : "todos are"} not uploaded',
                                                    style: AppText.textBase,
                                                  ),
                                                  SizedBox(
                                                    height: AppSpacing.sm,
                                                  ),
                                                  Text(
                                                    'Click on the icon to upload',
                                                    style: AppText.textSmMedium
                                                        .copyWith(
                                                            color: AppColors
                                                                .mutedForeground),
                                                  )
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                todosBloc.add(
                                                    TodosUploadTodosToCloudEvent([
                                                  ...doneTodos.where(
                                                      (e) => !e.isUploaded),
                                                  ...notDoneTodos.where(
                                                      (e) => !e.isUploaded)
                                                ]));
                                              },
                                              icon: Icon(
                                                  Icons.cloud_upload_outlined,
                                                  size: AppSpacing.iconSize2Xl),
                                              splashRadius: 20,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                            if (_isSyncing) ...[
                              AnimationConfiguration.synchronized(
                                duration: const Duration(milliseconds: 375),
                                child: FlipAnimation(
                                  child: FadeInAnimation(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          vertical: AppSpacing.md),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondary,
                                        borderRadius: AppBorderRadius.lg,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '$_noOfTodosSyncing ${_noOfTodosSyncing == 1 ? 'todo is' : "todos are"} syncing',
                                                  style: AppText.textBase,
                                                ),
                                                SizedBox(
                                                  height: AppSpacing.sm,
                                                ),
                                                Text(
                                                  'PLEASE DO NOT QUIT',
                                                  style: AppText.textSmBold
                                                      .copyWith(
                                                          color: AppColors
                                                              .mutedForeground),
                                                )
                                              ],
                                            ),
                                          ),
                                          SpinKitRing(
                                            color: AppColors.primary,
                                            lineWidth: 3.0,
                                            size: AppSpacing.iconSizeXl,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                            if (!todosBloc.isSelectedTodoStreamClosed)
                              StreamBuilder<List<TodoModel>>(
                                stream: todosBloc.selectedTodosStream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final selectedTodos = snapshot.data;
                                    if (selectedTodos != null) {
                                      final selectedTodosCount =
                                          selectedTodos.length;
                                      return Padding(
                                        padding: EdgeInsets.only(
                                            bottom: AppSpacing.lg,
                                            top: AppSpacing.md),
                                        child: RichText(
                                            text: TextSpan(children: [
                                          TextSpan(
                                              text: 'Selected ',
                                              style: AppText.textBaseMedium
                                                  .copyWith(
                                                      color: AppColors
                                                          .foreground)),
                                          TextSpan(
                                              text: '$selectedTodosCount ',
                                              style: AppText.textLgBold
                                                  .copyWith(
                                                      color:
                                                          AppColors.primary)),
                                        ])),
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  } else {
                                    // Handle the case when the snapshot doesn't have data yet
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
                            if (notDoneTodos.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.only(
                                    top: AppSpacing.md, bottom: AppSpacing.sm),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.list,
                                      color: AppColors.mutedForeground,
                                      size: AppSpacing.iconSizeLg,
                                    ),
                                    SizedBox(
                                      width: AppSpacing.xs,
                                    ),
                                    Text(
                                      "Todo (${notDoneTodos.length})",
                                      style: AppText.textSmBold.copyWith(
                                          color: AppColors.mutedForeground),
                                    ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                key: _notDoneTodosListKey,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: notDoneTodos.length,
                                itemBuilder:
                                    (BuildContext context, int todoIndex) {
                                  final todo = notDoneTodos[todoIndex];
                                  return commonTodoTile(todoIndex, todo);
                                },
                              ),
                            ],
                            if (doneTodos.isNotEmpty) ...[
                              SizedBox(
                                height: SizeConfig.blockSizeVertical!,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: AppSpacing.md, bottom: AppSpacing.sm),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check,
                                      color: AppColors.mutedForeground,
                                      size: AppSpacing.iconSizeLg,
                                    ),
                                    SizedBox(
                                      width: AppSpacing.xs,
                                    ),
                                    Text(
                                      "Done (${doneTodos.length})",
                                      style: AppText.textSmBold.copyWith(
                                          color: AppColors.mutedForeground),
                                    ),
                                  ],
                                ),
                              ),
                              ListView.builder(
                                key: _doneTodosListKey,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: doneTodos.length,
                                itemBuilder: (
                                  BuildContext context,
                                  int todoIndex,
                                ) {
                                  final todo = doneTodos[todoIndex];
                                  return commonTodoTile(todoIndex, todo);
                                },
                              )
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}

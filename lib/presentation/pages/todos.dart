import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:notex/presentation/blocs/todos/todos_bloc.dart';
import 'package:notex/presentation/styles/app_styles.dart';
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
          if (doneTodos.any(
              (t) => !t.isUploaded) || notDoneTodos.any((t) => !t.isUploaded)) {
            _areTodosNotUploaded = true;
            _noOfTodosNotUploaded = [
              ...doneTodos.where((e) => !e.isUploaded).toList(),
              ...notDoneTodos.where((e) => !e.isUploaded).toList()
            ].length;
          }else{
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
            decoration: const BoxDecoration(gradient: kPageBgGradient),
            child: Stack(
              children: [
                if (state is TodosEmptyState) ...[
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
                            style:
                                kInter.copyWith(fontSize: 15, color: kWhite24),
                            textAlign: TextAlign.center,
                          )
                        ],
                      )),
                ] else if (state is TodosFetchingState) ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SpinKitRing(
                        color: kPinkD1,
                        size: 35,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'This might take a while',
                        style: kInter.copyWith(color: kWhite75, fontSize: 15),
                      )
                    ],
                  )
                ] else if (state is TodosFetchingFailedState) ...[
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load notes',
                          style: kInter.copyWith(
                              fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 2,
                        ),
                        Text(
                          state.reason,
                          style: kInter.copyWith(fontSize: 14),
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
                            if (!_isSyncing && _areTodosNotUploaded) ...[
                              SizedBox(
                                height: SizeConfig.blockSizeVertical! * 3,
                              ),
                              AnimationConfiguration.synchronized(
                                duration: const Duration(milliseconds: 375),
                                child: FlipAnimation(
                                  child: FadeInAnimation(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 15),
                                      decoration: BoxDecoration(
                                          color: kPinkD2,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                              color: kPinkD1, width: 1.0)),
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
                                                    style: kInter.copyWith(
                                                        fontSize: 15),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'Click on the icon to upload',
                                                    style: kInter.copyWith(
                                                        fontSize: 13,color: kWhite24),
                                                  )
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                                onPressed: () {
                                                  todosBloc.add(TodosUploadTodosToCloudEvent(
                                                      [
                                                        ...doneTodos.where((e) => !e.isUploaded).toList(),
                                                        ...notDoneTodos.where((e) => !e.isUploaded).toList()
                                                      ]
                                                  ));
                                                },
                                                icon: const Icon(
                                                  Icons.cloud_upload_outlined,
                                                  color: kWhite,
                                                  size: 30,
                                                ),
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
                              SizedBox(
                                height: SizeConfig.blockSizeVertical! * 3,
                              ),
                              AnimationConfiguration.synchronized(
                                duration: const Duration(milliseconds: 375),
                                child: FlipAnimation(
                                  child: FadeInAnimation(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 15),
                                      decoration: BoxDecoration(
                                          color: kPinkD2,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          border: Border.all(
                                              color: kPinkD1, width: 1.0)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '$_noOfTodosSyncing ${_noOfTodosSyncing == 1 ? 'todo is' : "todos are"} syncing',
                                                  style: kInter.copyWith(
                                                      fontSize: 15),
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                  'Please do not quit',
                                                  style: kInter.copyWith(
                                                      fontSize: 15),
                                                )
                                              ],
                                            ),
                                          ),
                                          const SpinKitRing(
                                            color: kWhite,
                                            lineWidth: 3.0,
                                            size: 20,
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 20),
                                        child: Text(
                                          'Selected (${selectedTodosCount.toString()})',
                                          style: kInter.copyWith(
                                              fontSize: 35,
                                              fontWeight: FontWeight.w500),
                                        ),
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
                            SizedBox(
                              height: !_isSyncing ||
                                      !todosBloc.isSelectedTodoStreamClosed
                                  ? SizeConfig.blockSizeVertical! * 3
                                  : SizeConfig.blockSizeVertical! * 2,
                            ),
                            if (notDoneTodos.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: SizeConfig.blockSizeVertical!),
                                child: Text(
                                  "Todo (${notDoneTodos.length})",
                                  style: kInter.copyWith(color: kWhite75),
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
                                height: SizeConfig.blockSizeVertical! * 2,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: SizeConfig.blockSizeVertical!),
                                child: Text(
                                  "Done (${doneTodos.length})",
                                  style: kInter.copyWith(color: kWhite75),
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

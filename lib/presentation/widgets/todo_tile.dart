import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:notex/data/models/todo_model.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import '../blocs/todos/todos_bloc.dart';
import '../styles/size_config.dart';

// ignore: must_be_immutable
class TodoTile extends StatefulWidget {
  const TodoTile({super.key, required this.todo, required this.todosBloc});

  final TodoModel todo;
  final TodosBloc todosBloc;

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {
  bool _isSelected = false;
  bool _areAllSelected = false;
  bool _isSyncing = false;

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return kPinkD1;
    }
    return kPinkD1;
  }

  _isEditOnTap() {
    if (_areAllSelected) {
      widget.todosBloc.add(TodosSetAllTodosSelectedCheckBoxEvent(false));
      _areAllSelected = false;
      if (_areAllSelected && !_isSelected) {
        _isSelected = true;
      } else {
        _isSelected = false;
      }
      widget.todosBloc.add(TodosIsTodoSelectedEvent(_isSelected, widget.todo));
    } else {
      _isSelected = !_isSelected;
      widget.todosBloc.add(TodosIsTodoSelectedEvent(_isSelected, widget.todo));
    }
  }
  detailTile(String key,String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          key,style: kAppFont.copyWith(fontSize: 15,fontWeight: FontWeight.w400),
        ),
        Text(
          value,style: kAppFont.copyWith(fontSize: 15,fontWeight: FontWeight.w400),
        )
      ],
    ),
  );

  divider() => Divider(
    color: kPinkD1.withOpacity(0.3),
    thickness: 1.0,
    indent: 20,
    endIndent: 20,
  );

  void _showNoteDetails() => showModalBottomSheet(
    showDragHandle: true,
    backgroundColor: kPinkD2,
    context: context,
    builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          detailTile('Created on', DateFormat('d MMMM, h:mm a').format(widget.todo.createdTime.toLocal()).toString()),
          divider(),
          detailTile('Remainder time', DateFormat('d MMMM, h:mm a').format(widget.todo.expireTime.toLocal()).toString()),
          divider(),
          detailTile('Is completed', widget.todo.isCompleted ? 'yes' : 'no'),
          divider(),
          detailTile('Is synced', widget.todo.isSynced ? 'yes' : 'no'),
          divider(),
          detailTile('Is uploaded', widget.todo.isUploaded ? 'yes' : 'no'),
        ],
      );
    },
  );


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return BlocConsumer(
      bloc: widget.todosBloc,
      buildWhen: (previous, current) => current is! TodosActionState,
      listener: (context, state) {
        if (state is TodosExitedEditingState) {
          _isSelected = false;
          _areAllSelected = false;
        }
      },
      builder: (context, state) {
        if (state is TodosEditingState) {
          if (state.selectedTodoIds != null) {
            state.selectedTodoIds!.contains(widget.todo.id)
                ? _isSelected = true
                : _isSelected = false;
          } else {
            _isSelected = false;
            _areAllSelected = false;
          }
          if (!_isSelected && state.areAllSelected) {
            _areAllSelected = true;
          }
        }
        if (state is TodosFetchedState) {
          if (state.syncingTodos != null) {
            if (state.syncingTodos!.contains(widget.todo.id)) {
              _isSyncing = true;
            }
          } else {
            _isSyncing = false;
          }
        }
        return Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
              color: DateTime.now().isAfter(widget.todo.expireTime.toLocal())
                  ? kPinkD2
                  : kPinkD2,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(width: 1.0, color: kPinkD1)),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20.0),
            child: InkWell(
              splashColor: kPink,
              borderRadius: BorderRadius.circular(20.0),
              onLongPress: () {
                widget.todosBloc.add(TodosEnteredEditingEvent());
                _isEditOnTap();
              },
              onTap: () {
                if (state is! TodosEditingState) {
                  // open edit to-do dialog
                } else {
                  _isEditOnTap();
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.blockSizeVertical! * 0.5),
                child: Row(
                  children: [
                    if (state is! TodosEditingState && !_isSyncing) ...[
                      Transform.scale(
                        scale: 1.3,
                        child: Checkbox(
                            value: widget.todo.isCompleted,
                            checkColor: kPink,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            onChanged: (bool? value) {
                              if (value != null) {
                                if (value) {
                                  widget.todosBloc
                                      .add(TodosMarkTodoDoneEvent(widget.todo));
                                } else {
                                  widget.todosBloc.add(
                                      TodosMarkTodoNotDoneEvent(widget.todo));
                                }
                              }
                            }),
                      ),
                    ] else if (state is! TodosEditingState && _isSyncing) ...[
                      const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: SizedBox(
                            width: 25,
                            height: 25,
                            child: SpinKitRing(color: kPinkD1, lineWidth: 4.0)),
                      )
                    ],
                    SizedBox(
                      width: SizeConfig.blockSizeHorizontal! * 2,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.todo.body,
                              style: kAppFont,
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical! * 0.5,
                            ),
                            /*
                            Text(
                              'created on : ${DateFormat('d MMMM, h:mm a').format(widget.todo.createdTime.toLocal()).toString()}',
                              style: kAppFont.copyWith(
                                  color: kWhite75, fontSize: 12),
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical! * 0.5,
                            ),
                            Text(
                              'last edited : ${DateFormat('d MMMM, h:mm a').format(widget.todo.editedTime.toLocal()).toString()}',
                              style: kAppFont.copyWith(
                                  color: kWhite75, fontSize: 12),
                            ),
                            Text(
                              'is synced : ${widget.todo.isSynced}',
                              style: kAppFont.copyWith(
                                  color: kWhite75, fontSize: 12),
                            ),
                            Text(
                              'completion on : ${DateFormat('d MMMM, h:mm a').format(widget.todo.expireTime.toLocal()).toString()}',
                              style: kAppFont.copyWith(
                                  color: kWhite75, fontSize: 12),
                            ),
                            Text(
                              'is completed : ${widget.todo.isCompleted}',
                              style: kAppFont.copyWith(
                                  color: kWhite75, fontSize: 12),
                            ),
                            Text(
                              'is uploaded : ${widget.todo.isUploaded}',
                              style: kAppFont.copyWith(
                                  color: kWhite75, fontSize: 12),
                            ),
                             */
                          ],
                        ),
                      ),
                    ),
                    if (state is! TodosEditingState)
                      IconButton(
                          onPressed: () {
                            _showNoteDetails();
                          },
                          splashRadius: 20,
                          icon: const Icon(
                            Ionicons.information,
                            color: kWhite,
                          )),
                    if (state is TodosEditingState)
                      Transform.scale(
                        scale: 1.3,
                        child: Checkbox(
                            value:
                                _areAllSelected ? _areAllSelected : _isSelected,
                            checkColor: kPink,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            onChanged: (bool? value) {
                              if (_areAllSelected) {
                                widget.todosBloc
                                    .add(TodosAreAllTodosSelectedEvent(false));
                              } else if (value != null) {
                                // select tile in edit mode
                                setState(() {
                                  _isSelected = value;
                                  _areAllSelected
                                      ? _areAllSelected = !_areAllSelected
                                      : null;
                                });
                                widget.todosBloc.add(TodosIsTodoSelectedEvent(
                                    _isSelected, widget.todo));
                              }
                            }),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

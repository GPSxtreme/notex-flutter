import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
    if(_areAllSelected){
      widget.todosBloc.add(TodosSetAllTodosSelectedCheckBoxEvent(false));
      _areAllSelected = false;
      if(_areAllSelected && !_isSelected){
        _isSelected = true;
      }else{
        _isSelected = false;
      }
      widget.todosBloc.add(TodosIsTodoSelectedEvent(_isSelected, widget.todo));
    }else{
      _isSelected = !_isSelected;
      widget.todosBloc.add(TodosIsTodoSelectedEvent(_isSelected, widget.todo));
    }
  }

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
        return Container(
          width: double.maxFinite,
          decoration: BoxDecoration(
              color: kPinkD2,
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
                    if (state is! TodosEditingState)
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
                              style: kInter,
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical! * 0.5,
                            ),
                            Text(
                              'created on : ${DateFormat('d MMMM, h:mm a').format(widget.todo.createdTime).toString()}',
                              style: kInter.copyWith(
                                  color: kWhite75, fontSize: 12),
                            ),
                            SizedBox(
                              height: SizeConfig.blockSizeVertical! * 0.5,
                            ),
                            Text(
                              'last edited : ${DateFormat('d MMMM, h:mm a').format(widget.todo.editedTime).toString()}',
                              style: kInter.copyWith(
                                  color: kWhite75, fontSize: 12),
                            ),
                            Text(
                              'is synced : ${widget.todo.isSynced}',
                              style: kInter.copyWith(
                                  color: kWhite75, fontSize: 12),
                            ),
                            Text(
                              'expires on : ${DateFormat('d MMMM, h:mm a').format(widget.todo.expireTime).toString()}',
                              style: kInter.copyWith(
                                  color: kWhite75, fontSize: 12),
                            ),
                            Text(
                              'is completed : ${widget.todo.isCompleted}',
                              style: kInter.copyWith(
                                  color: kWhite75, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
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

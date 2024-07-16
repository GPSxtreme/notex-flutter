import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import 'package:notex/data/models/todo_model.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/app_text.dart';
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

  detailTile(String key, String value) => Padding(
        padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              key,
              style:
                  AppText.textBase.copyWith(color: AppColors.mutedForeground),
            ),
            Text(
              value,
              style: AppText.textBaseSemiBold
                  .copyWith(color: AppColors.foreground),
            )
          ],
        ),
      );

  divider() => const Divider(
        thickness: 1.0,
        indent: 20,
        endIndent: 20,
        color: AppColors.border,
      );

  void _showNoteDetails() => showModalBottomSheet(
        showDragHandle: true,
        backgroundColor: AppColors.secondary,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                detailTile(
                    'Created on',
                    DateFormat('d MMMM, h:mm a')
                        .format(widget.todo.createdTime.toLocal())
                        .toString()),
                divider(),
                detailTile(
                    'Remainder time',
                    DateFormat('d MMMM, h:mm a')
                        .format(widget.todo.expireTime.toLocal())
                        .toString()),
                divider(),
                detailTile(
                    'Is completed', widget.todo.isCompleted ? 'Yes' : 'No'),
                divider(),
                detailTile('Is synced', widget.todo.isSynced ? 'Yes' : 'No'),
                divider(),
                detailTile(
                    'Is uploaded', widget.todo.isUploaded ? 'Yes' : 'No'),
              ],
            ),
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
              borderRadius: AppBorderRadius.lg, color: AppColors.secondary),
          child: Material(
            color: Colors.transparent,
            borderRadius: AppBorderRadius.lg,
            child: InkWell(
              borderRadius: AppBorderRadius.lg,
              onLongPress: () {
                widget.todosBloc.add(TodosEnteredEditingEvent());
                _isEditOnTap();
              },
              onTap: () {
                if (state is! TodosEditingState && !_isSyncing) {
                  if (!widget.todo.isCompleted) {
                    widget.todosBloc.add(TodosMarkTodoDoneEvent(widget.todo));
                  } else {
                    widget.todosBloc
                        .add(TodosMarkTodoNotDoneEvent(widget.todo));
                  }
                } else {
                  _isEditOnTap();
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: 0, horizontal: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (state is! TodosEditingState && !_isSyncing) ...[
                      Transform.scale(
                        scale: 1.3,
                        child: Checkbox(
                            value: widget.todo.isCompleted,
                            shape: const CircleBorder(),
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
                            child: SpinKitRing(
                                color: AppColors.primary, lineWidth: 4.0)),
                      )
                    ],
                    SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Text(
                          widget.todo.body,
                          style: AppText.textBaseMedium,
                        ),
                      ),
                    ),
                    if (state is! TodosEditingState)
                      IconButton(
                          style: const ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(Colors.transparent)),
                          onPressed: () {
                            _showNoteDetails();
                          },
                          icon: Icon(
                            Ionicons.information,
                            size: AppSpacing.iconSizeLg,
                          )),
                    if (state is TodosEditingState)
                      Transform.scale(
                        scale: 1.3,
                        child: Checkbox(
                            value:
                                _areAllSelected ? _areAllSelected : _isSelected,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
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

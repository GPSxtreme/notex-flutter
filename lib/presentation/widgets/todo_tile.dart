import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notex/data/models/todo_model.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import '../styles/size_config.dart';

// ignore: must_be_immutable
class TodoTile extends StatefulWidget {
  TodoTile(
      {super.key,
      required this.todo,
      required this.onCheckboxPressed,
      required this.animation,
      required this.onLongPress,
      required this.isInEditMode,
      required this.isSelected,
      required this.onSelect});

  final TodoModel todo;
  final Animation<double> animation;
  final Function(bool isDone) onCheckboxPressed;
  final Function() onLongPress;
  final Function(bool isSelected) onSelect;
  final bool isInEditMode;
  late bool isSelected;

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> {

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

  @override
  Widget build(BuildContext context) => SlideTransition(
        key: ValueKey(widget.todo.id),
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: const Offset(0.0, 0.0),
        ).animate(widget.animation),
        child: buildItem(),
      );

  Widget buildItem() {
    SizeConfig().init(context);
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
          onLongPress: widget.onLongPress,
          onTap: (){
            if(widget.isInEditMode){
              widget.onSelect(!widget.isSelected);
              setState(() {
                widget.isSelected = !widget.isSelected;
              });
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
                vertical: SizeConfig.blockSizeVertical! * 0.5),
            child: Row(
              children: [
                if (!widget.isInEditMode)
                  Transform.scale(
                    scale: 1.3,
                    child: Checkbox(
                        value: widget.todo.isCompleted,
                        checkColor: kPink,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        fillColor: MaterialStateProperty.resolveWith(getColor),
                        onChanged: (bool? value) {
                          if (value != null) {
                            widget.onCheckboxPressed(value);
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
                          style: kInter.copyWith(color: kWhite75, fontSize: 12),
                        ),
                        SizedBox(
                          height: SizeConfig.blockSizeVertical! * 0.5,
                        ),
                        Text(
                          'last edited : ${DateFormat('d MMMM, h:mm a').format(widget.todo.editedTime).toString()}',
                          style: kInter.copyWith(color: kWhite75, fontSize: 12),
                        ),
                        Text(
                          'is synced : ${widget.todo.isSynced}',
                          style: kInter.copyWith(color: kWhite75, fontSize: 12),
                        ),
                        Text(
                          'expires on : ${DateFormat('d MMMM, h:mm a').format(widget.todo.expireTime).toString()}',
                          style: kInter.copyWith(color: kWhite75, fontSize: 12),
                        ),
                        Text(
                          'is completed : ${widget.todo.isCompleted}',
                          style: kInter.copyWith(color: kWhite75, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.isInEditMode)
                  Transform.scale(
                    scale: 1.3,
                    child: Checkbox(
                        value: widget.isSelected,
                        checkColor: kPink,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        fillColor: MaterialStateProperty.resolveWith(getColor),
                        onChanged: (bool? value) {
                          if (value != null) {
                            // select tile in edit mode
                            setState(() {
                              widget.isSelected = value;
                            });
                            widget.onSelect(value);
                          }
                        }),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

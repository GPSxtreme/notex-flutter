import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notex/data/models/todo_model.dart';
import 'package:notex/presentation/styles/app_styles.dart';

import '../styles/size_config.dart';

class TodoTile extends StatefulWidget {
  const TodoTile({super.key, required this.todo, required this.onCheckboxPressed});
  final TodoModel todo;
  final Function(bool isDone) onCheckboxPressed;
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
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Container(
      width: double.maxFinite,
      padding: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical! * 0.5),
      decoration: BoxDecoration(
        color: kPinkD2,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(width: 1.0,color: kPinkD1)
      ),
      child: Row(
        children: [
          Transform.scale(
            scale:1.3,
            child: Checkbox(
                value: widget.todo.isCompleted,
                checkColor: kPink,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                fillColor:
                MaterialStateProperty.resolveWith(getColor),
                onChanged: (bool? value) {
                  if(value != null){
                    widget.onCheckboxPressed(value);
                  }
                }),
          ),
          SizedBox(width: SizeConfig.blockSizeHorizontal! * 2,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.todo.body,style: kInter,),
                SizedBox(height: SizeConfig.blockSizeVertical!  * 0.5,),
                Text(DateFormat('d MMMM, h:mm a').format(widget.todo.createdTime).toString(),style: kInter.copyWith(color: kWhite75,fontSize: 12),),
                SizedBox(height: SizeConfig.blockSizeVertical!  * 0.5,),
                Text(DateFormat('d MMMM, h:mm a').format(widget.todo.editedTime).toString(),style: kInter.copyWith(color: kWhite75,fontSize: 12),),
              ],
            ),
          )
        ],
      ),
    );
  }
}

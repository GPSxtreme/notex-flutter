// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:notex/data/models/todo_model.dart';
import 'package:notex/presentation/blocs/todos/todos_bloc.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import 'package:uuid/uuid.dart';
import '../../main.dart';
import '../styles/size_config.dart';

class AddTodoDialogBox extends StatefulWidget {
  const AddTodoDialogBox({super.key, required this.todosBloc});

  final TodosBloc todosBloc;

  @override
  State<AddTodoDialogBox> createState() => _AddTodoDialogBoxState();
}

class _AddTodoDialogBoxState extends State<AddTodoDialogBox> {
  final TextEditingController _todoController = TextEditingController();
  DateTime _expireTime = DateTime.now().toUtc();
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      backgroundColor: kPinkD2,
      titlePadding: EdgeInsets.zero,
      actionsAlignment: MainAxisAlignment.start,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                splashRadius: 15,
                icon: const Icon(
                  Icons.close,
                  color: kWhite,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ),
            Center(
              child: Text(
                'New To-Do',
                style: kInter.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                splashRadius: 15,
                icon: const Icon(
                  Icons.check,
                  color: kPink,
                  size: 20,
                ),
                onPressed: () async{
                  if (_todoController.text.isEmpty) {
                    kSnackBar(context, "please fill in required fields");
                  } else {
                    // add task
                    final userData = USER.data;
                    final todo = TodoModel(id: const Uuid().v4(),
                        userId: userData!.userId,
                        body: _todoController.text,
                        isCompleted: false,
                        createdTime: DateTime.now().toUtc(),
                        editedTime: DateTime.now().toUtc(),
                        expireTime: _expireTime,
                        v: 0);
                    widget.todosBloc.add(TodosAddTodoEvent(todo));
                    Navigator.of(context).pop(); // Close the dialog
                  }
                },
              ),
            ),
          ],
        ),
      ),
      content: TextField(
        style: kInter.copyWith(fontSize: 18),
        controller: _todoController,
        maxLines: 3,
        minLines: 1,
        keyboardType: TextInputType.emailAddress,
        cursorColor: kWhite,
        decoration: kTextFieldDecorationT1,
      ),
      actions: [
        IconButton(
          splashRadius: 20,
          icon: const Icon(
            Icons.notification_add,
            color: kWhite,
            size: 20,
          ),
          onPressed: () {
            // show pick end date settings
          },
        )
      ],
    );
  }
}

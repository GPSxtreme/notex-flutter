// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

Future<DateTime?> showDateTimePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  initialDate ??= DateTime.now();
  firstDate ??= DateTime.now();
  lastDate ??= firstDate.add(const Duration(days: 365 * 200));

  final DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  if (selectedDate == null) return null;

  if (!context.mounted) return selectedDate;

  final TimeOfDay? selectedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(DateTime.now()),
  );

  return selectedTime == null
      ? selectedDate
      : DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    selectedTime.hour,
    selectedTime.minute,
  );
}
class _AddTodoDialogBoxState extends State<AddTodoDialogBox> {
  final TextEditingController _todoController = TextEditingController();
  DateTime? _expireTime;
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
                        expireTime: _expireTime ?? DateTime.now().add(const Duration(hours: 6)).toUtc(),
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
        Row(
          children: [
            IconButton(
              splashRadius: 20,
              icon: const Icon(
                Icons.notification_add,
                color: kWhite,
                size: 20,
              ),
              onPressed: () async{
                // show pick end date settings
                _expireTime = await showDateTimePicker(context: context);
                setState(() {
                  _expireTime;
                });
              },
            ),
            // const SizedBox(width: 5,),
            if(_expireTime != null)
            Container(
              decoration: BoxDecoration(
                color: kPink.withOpacity(0.75),
                borderRadius: BorderRadius.circular(18)
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 6),
              child: Text(
                DateFormat('h:mm a, d MMMM y').format(_expireTime!),
                style: kInter.copyWith(fontSize: 13,color: kWhite,fontWeight: FontWeight.w600),
              ),
            )
          ],
        )
      ],
    );
  }
}

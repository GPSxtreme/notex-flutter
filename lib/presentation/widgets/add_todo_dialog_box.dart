// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notex/data/models/todo_model.dart';
import 'package:notex/presentation/blocs/todos/todos_bloc.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import 'package:notex/presentation/styles/app_text.dart';
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
    initialTime:
        TimeOfDay.fromDateTime(DateTime.now().add(const Duration(seconds: 70))),
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
  DateTime? _expireTime = DateTime.now().add(const Duration(hours: 6)).toUtc();
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.lg),
      contentPadding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.md,
          bottom: AppSpacing.sm),
      titlePadding: EdgeInsets.zero,
      actionsAlignment: MainAxisAlignment.start,
      actionsPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      title: SizedBox(
        width: SizeConfig.screenWidth! * 0.8,
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: AppSpacing.md, horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.close, size: AppSpacing.iconSizeLg),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ),
              Center(
                child: Text(
                  'New Todo',
                  style: AppText.textLgSemiBold,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  splashRadius: 15,
                  icon: Icon(Icons.check, size: AppSpacing.iconSizeLg),
                  onPressed: () async {
                    if (_todoController.text.isEmpty) {
                      kSnackBar(context, "please fill in required fields");
                    } else {
                      // add task
                      final userData = USER.data;
                      final todo = TodoModel(
                          id: const Uuid().v4(),
                          userId: userData!.userId,
                          body: _todoController.text,
                          isCompleted: false,
                          createdTime: DateTime.now().toUtc(),
                          editedTime: DateTime.now().toUtc(),
                          expireTime: _expireTime!,
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
      ),
      content: SizedBox(
        width: SizeConfig.screenWidth! * 0.8,
        child: TextField(
          controller: _todoController,
          maxLines: 3,
          minLines: 1,
          decoration: const InputDecoration(
            hintText: 'What do you want to do?',
          ),
          keyboardType: TextInputType.text,
        ),
      ),
      actions: [
        Row(
          children: [
            IntrinsicHeight(
              child: IconButton(
                style: ButtonStyle(
                  padding: WidgetStatePropertyAll(
                    EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  ),
                ),
                icon: Icon(Icons.notification_add,
                    size: AppSpacing.iconSizeLg, color: AppColors.primary),
                onPressed: () async {
                  // show pick end date settings
                  _expireTime = await showDateTimePicker(context: context);
                  setState(() {
                    _expireTime;
                  });
                },
              ),
            ),
            SizedBox(
              width: AppSpacing.sm,
            ),
            if (_expireTime != null)
              Container(
                decoration: BoxDecoration(
                    borderRadius: AppBorderRadius.lg,
                    color: AppColors.secondary),
                padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.md),
                child: Text(
                  DateFormat('h:mm a, d MMMM y').format(_expireTime!),
                  style:
                      AppText.textSm.copyWith(color: AppColors.mutedForeground),
                ),
              )
          ],
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';

class AddTodoDialogBox extends StatefulWidget {
  const AddTodoDialogBox({super.key});

  @override
  State<AddTodoDialogBox> createState() => _AddTodoDialogBoxState();
}

class _AddTodoDialogBoxState extends State<AddTodoDialogBox> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Todo'),
      content: TextField(
        decoration: InputDecoration(
          hintText: 'Enter todo',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Add todo logic
            Navigator.of(context).pop();
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

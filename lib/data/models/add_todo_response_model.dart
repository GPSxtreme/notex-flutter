// To parse this JSON data, do
//
//     final addTodoResponseModel = addTodoResponseModelFromJson(jsonString);

import 'dart:convert';

AddTodoResponseModel addTodoResponseModelFromJson(String str) => AddTodoResponseModel.fromJson(json.decode(str));

String addTodoResponseModelToJson(AddTodoResponseModel data) => json.encode(data.toJson());

class AddTodoResponseModel {
  final bool success;
  final String message;
  final String todoId;

  AddTodoResponseModel({
    required this.success,
    required this.message,
    required this.todoId,
  });

  factory AddTodoResponseModel.fromJson(Map<String, dynamic> json) => AddTodoResponseModel(
    success: json["success"],
    message: json["message"],
    todoId: json["todoId"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "todoId": todoId,
  };
}

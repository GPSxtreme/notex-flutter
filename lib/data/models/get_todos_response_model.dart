// To parse this JSON data, do
//
//     final getTodosResponseModel = getTodosResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:notex/data/models/todo_model.dart';

GetTodosResponseModel getTodosResponseModelFromJson(String str) => GetTodosResponseModel.fromJson(json.decode(str));

String getTodosResponseModelToJson(GetTodosResponseModel data) => json.encode(data.toJson());

class GetTodosResponseModel {
  final bool success;
  final String message;
  final List<TodoModel>? todos;

  GetTodosResponseModel({
    required this.success,
    required this.message,
    this.todos,
  });

  factory GetTodosResponseModel.fromJson(Map<String, dynamic> json) => GetTodosResponseModel(
    success: json["success"],
    message: json["message"],
    todos: List<TodoModel>.from(json["todos"].map((x) => TodoModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": success,
    "message": message,
    "todos": todos != null ?  List<dynamic>.from(todos!.map((x) => x.toJson())) : null,
  };
}
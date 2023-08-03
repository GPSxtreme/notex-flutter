// To parse this JSON data, do
//
//     final todoModel = todoModelFromJson(jsonString);

import 'dart:convert';

TodoModel todoModelFromJson(String str) => TodoModel.fromJson(json.decode(str));

String todoModelToJson(TodoModel data) => json.encode(data.toJson());

class TodoModel {
  final String id;
  final String userId;
  final String body;
  final bool isCompleted;
  final DateTime createdTime;
  final DateTime editedTime;
  final DateTime expireTime;
  final int v;
  final bool? isSynced;

  TodoModel({
    required this.id,
    required this.userId,
    required this.body,
    required this.isCompleted,
    required this.createdTime,
    required this.editedTime,
    required this.expireTime,
    required this.v,
    this.isSynced
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
    id: json["_id"],
    userId: json["userId"],
    body: json["body"],
    isCompleted: json["isCompleted"],
    createdTime: DateTime.parse(json["createdTime"]),
    editedTime: DateTime.parse(json["editedTime"]),
    expireTime: DateTime.parse(json["expireTime"]),
    v: json["__v"],
  );

  factory TodoModel.fromJsonOfLocalDb(Map<String, dynamic> json) => TodoModel(
    id: json["_id"],
    userId: json["userId"],
    body: json["body"],
    isCompleted: json["isCompleted"] == 0 ? false : true,
    createdTime: DateTime.parse(json["createdTime"]),
    editedTime: DateTime.parse(json["editedTime"]),
    expireTime: DateTime.parse(json["expireTime"]),
    v: json["__v"],
    isSynced: json['isSynced'] == 0 ? false : true
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "body": body,
    "isCompleted": isCompleted,
    "createdTime": createdTime.toIso8601String(),
    "editedTime": editedTime.toIso8601String(),
    "expireTime": expireTime.toIso8601String(),
    "__v": v,
  };
}

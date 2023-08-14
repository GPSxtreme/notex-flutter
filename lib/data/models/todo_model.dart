// To parse this JSON data, do
//
//     final todoModel = todoModelFromJson(jsonString);

import 'dart:convert';

TodoModel todoModelFromJson(String str) => TodoModel.fromJson(json.decode(str));

String todoModelToJson(TodoModel data) => json.encode(data.toJson());

class TodoModel {
  final String id;
  final String userId;
  String body;
  dynamic isCompleted;
  final DateTime createdTime;
  DateTime editedTime;
  DateTime expireTime;
  final int v;
  dynamic isSynced;

  TodoModel(
      {required this.id,
      required this.userId,
      required this.body,
      required this.isCompleted,
      required this.createdTime,
      required this.editedTime,
      required this.expireTime,
      required this.v,
      this.isSynced = false});

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
      isSynced: json['isSynced'] == 0 ? false : true);

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

  Map<String, dynamic> toJsonToServerAdd() => {
        "body": body,
        "isCompleted": isCompleted,
        "createdTime": createdTime.toIso8601String(),
        "editedTime": editedTime.toIso8601String(),
        "expireTime": expireTime.toIso8601String(),
      };

  Map<String, dynamic> toJsonToServerUpdate() => {
        "_id": id,
        "body": body,
        "isCompleted": isCompleted,
        "editedTime": editedTime.toIso8601String(),
        "expireTime": expireTime.toIso8601String(),
        "__v": v,
      };
}

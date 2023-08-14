// To parse this JSON data, do
//
//     final noteModel = noteModelFromJson(jsonString);

import 'dart:convert';

NoteModel noteModelFromJson(String str) => NoteModel.fromJson(json.decode(str));

String noteModelToJson(NoteModel data) => json.encode(data.toJson());

class NoteModel {
  final String id;
  final String userId;
  String title;
  String body;
  final DateTime createdTime;
  DateTime editedTime;
  final int v;
  dynamic isSynced;

  NoteModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdTime,
    required this.editedTime,
    required this.v,
    this.isSynced = false
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
    id: json["_id"],
    userId: json["userId"],
    title: json["title"],
    body: json["body"],
    createdTime: DateTime.parse(json["createdTime"]),
    editedTime: DateTime.parse(json["editedTime"]),
    v: json["__v"],
  );
  factory NoteModel.fromJsonOfLocalDb(Map<String, dynamic> json) => NoteModel(
    id: json["_id"],
    userId: json["userId"],
    title: json["title"],
    body: json["body"],
    createdTime: DateTime.parse(json["createdTime"]),
    editedTime: DateTime.parse(json["editedTime"]),
    v: json["__v"],
    isSynced: json["isSynced"] == 0 ? false : true
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "title": title,
    "body": body,
    "createdTime": createdTime.toIso8601String(),
    "editedTime": editedTime.toIso8601String(),
    "__v": v,
  };
  Map<String, dynamic> toJsonToServerAdd() => {
    "title": title,
    "body": body,
    "createdTime": createdTime.toIso8601String(),
    "editedTime": editedTime.toIso8601String(),
  };
  Map<String, dynamic> toJsonToServerUpdate() => {
    "_id": id,
    "title": title,
    "body": body,
    "createdTime": createdTime.toIso8601String(),
    "editedTime": editedTime.toIso8601String(),
    "__v": v,
  };
}

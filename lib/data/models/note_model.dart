// To parse this JSON data, do
//
//     final noteModel = noteModelFromJson(jsonString);

import 'dart:convert';

NoteModel noteModelFromJson(String str) => NoteModel.fromJson(json.decode(str));

String noteModelToJson(NoteModel data) => json.encode(data.toJson());

class NoteModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime createdTime;
  final DateTime editedTime;
  final int v;

  NoteModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdTime,
    required this.editedTime,
    required this.v,
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

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "title": title,
    "body": body,
    "createdTime": createdTime.toIso8601String(),
    "editedTime": editedTime.toIso8601String(),
    "__v": v,
  };
}

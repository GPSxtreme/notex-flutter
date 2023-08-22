// To parse this JSON data, do
//
//     final noteModel = noteModelFromJson(jsonString);

import 'dart:convert';

NoteModel noteModelFromJson(String str) => NoteModel.fromJson(json.decode(str));

String noteModelToJson(NoteModel data) => json.encode(data.toJson());

class NoteModel {
  String id;
  final String userId;
  String title;
  String body;
  final DateTime createdTime;
  DateTime editedTime;
  final int v;
  dynamic isSynced;
  dynamic isFavorite;
  dynamic isUploaded;

  NoteModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdTime,
    required this.editedTime,
    required this.v,
    this.isSynced = false,
    this.isFavorite = false,
    this.isUploaded = false
  });

  void updateIsSynced(dynamic value) => isSynced = value;
  void updateId(String newId) => id = newId;
  void setIsFavorite(bool value) => isFavorite = value;
  void setIsUploaded(bool value) => isUploaded = value;

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
    id: json["_id"],
    userId: json["userId"],
    title: json["title"],
    body: json["body"],
    createdTime: DateTime.parse(json["createdTime"]),
    editedTime: DateTime.parse(json["editedTime"]),
    isFavorite: json['isFavorite'],
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
    isSynced: json["isSynced"] == 0 ? false : true,
    isFavorite: json['isFavorite'] == 0 ? false : true,
    isUploaded: json['isUploaded'] == 0 ? false : true,
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "title": title,
    "body": body,
    "createdTime": createdTime.toIso8601String(),
    "editedTime": editedTime.toIso8601String(),
    'isFavorite' : isFavorite,
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
    'isFavorite' : isFavorite,
    "__v": v,
  };
}

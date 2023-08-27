// To parse this JSON data, do
//
//     final noteModel = noteModelFromJson(jsonString);

import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../../main.dart';

NoteModel noteModelFromJson(String str) => NoteModel.fromJson(json.decode(str));

String noteModelToJson(NoteModel data) => json.encode(data.toJson());

class NoteModel {
  String id;
  final String userId;
  String title;
  String body;
  final DateTime createdTime;
  DateTime editedTime;
  int v;
  dynamic isSynced;
  dynamic isFavorite;
  dynamic isUploaded;
  dynamic isHidden;
  dynamic isDeleted;
  dynamic deletedTime;

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
    this.isUploaded = false,
    this.isHidden = false,
    this.isDeleted = false,
    this.deletedTime,
  });

  void updateIsSynced(value) => isSynced = value;
  void updateId(String newId) => id = newId;
  void setIsFavorite(bool value) => isFavorite = value;
  void setIsUploaded(bool value) => isUploaded = value;
  void setEditedTime(DateTime time) => editedTime = time.toUtc();
  void setIsHidden(value) => isHidden = value;
  void setIsDeleted(value) => isDeleted = value;
  void setDelTs(DateTime? time) => deletedTime = time?.toUtc();
  void incV() => v++;

  factory NoteModel.createEmptyNote() => NoteModel(
      id: const Uuid().v4(),
      userId: USER.data!.userId,
      title: '',
      body: '',
      createdTime: DateTime.now().toUtc(),
      editedTime: DateTime.now().toUtc(),
      v: 0
  );

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
    id: json["_id"],
    userId: json["userId"],
    title: json["title"],
    body: json["body"],
    createdTime: DateTime.parse(json["createdTime"]),
    editedTime: DateTime.parse(json["editedTime"]),
    isFavorite: json['isFavorite'],
    isHidden: json['isHidden'],
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
    isHidden: json['isHidden'] == 0 ? false : true,
    isDeleted: json['isDeleted'] == 0 ? false : true,
    deletedTime: json['deletedTime'] != null && json['deletedTime'] != 'null' ? DateTime.parse(json['deletedTime']) : null
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "title": title,
    "body": body,
    "createdTime": createdTime.toIso8601String(),
    "editedTime": editedTime.toIso8601String(),
    'isSynced' : isSynced,
    'isFavorite' : isFavorite,
    'isHidden' : isHidden,
    'isUploaded' : isUploaded,
    'isDeleted' : isDeleted,
    'deletedTime' : deletedTime,
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
    'isHidden' : isHidden,
    "__v": v,
  };
}

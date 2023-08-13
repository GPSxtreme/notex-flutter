// To parse this JSON data, do
//
//     final addNoteResponseModel = addNoteResponseModelFromJson(jsonString);

import 'dart:convert';

AddNoteResponseModel addNoteResponseModelFromJson(String str) => AddNoteResponseModel.fromJson(json.decode(str));

String addNoteResponseModelToJson(AddNoteResponseModel data) => json.encode(data.toJson());

class AddNoteResponseModel {
  final bool success;
  final String message;
  final String noteId;

  AddNoteResponseModel({
    required this.success,
    required this.message,
    required this.noteId,
  });

  factory AddNoteResponseModel.fromJson(Map<String, dynamic> json) => AddNoteResponseModel(
    success: json["success"],
    message: json["message"],
    noteId: json["noteId"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "noteId": noteId,
  };
}

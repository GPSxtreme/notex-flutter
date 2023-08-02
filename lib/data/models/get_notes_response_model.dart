// To parse this JSON data, do
//
//     final getNotesResponseModel = getNotesResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:notex/data/models/note_model.dart';

GetNotesResponseModel getNotesResponseModelFromJson(String str) => GetNotesResponseModel.fromJson(json.decode(str));

String getNotesResponseModelToJson(GetNotesResponseModel data) => json.encode(data.toJson());

class GetNotesResponseModel {
  final bool status;
  final String message;
  final List<NoteModel> notes;

  GetNotesResponseModel({
    required this.status,
    required this.message,
    required this.notes,
  });

  factory GetNotesResponseModel.fromJson(Map<String, dynamic> json) => GetNotesResponseModel(
    status: json["status"],
    message: json["message"],
    notes: List<NoteModel>.from(json["notes"].map((x) => NoteModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "todos": List<dynamic>.from(notes.map((x) => x.toJson())),
  };
}

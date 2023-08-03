// To parse this JSON data, do
//
//     final getNotesResponseModel = getNotesResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:notex/data/models/note_model.dart';

GetNotesResponseModel getNotesResponseModelFromJson(String str) => GetNotesResponseModel.fromJson(json.decode(str));

String getNotesResponseModelToJson(GetNotesResponseModel data) => json.encode(data.toJson());

class GetNotesResponseModel {
  final bool success;
  final String message;
  final List<NoteModel>? notes;

  GetNotesResponseModel({
    required this.success,
    required this.message,
    this.notes,
  });

  factory GetNotesResponseModel.fromJson(Map<String, dynamic> json) => GetNotesResponseModel(
    success: json["success"],
    message: json["message"],
    notes: List<NoteModel>.from(json["notes"].map((x) => NoteModel.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": success,
    "message": message,
    "todos": notes != null ? List<dynamic>.from(notes!.map((x) => x.toJson())) : null,
  };
}

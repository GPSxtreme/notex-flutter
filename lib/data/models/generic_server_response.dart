// To parse this JSON data, do
//
//     final genericServerResponse = genericServerResponseFromJson(jsonString);

import 'dart:convert';

GenericServerResponse genericServerResponseFromJson(String str) => GenericServerResponse.fromJson(json.decode(str));

String genericServerResponseToJson(GenericServerResponse data) => json.encode(data.toJson());

class GenericServerResponse {
  final bool success;
  final String message;

  GenericServerResponse({
    required this.success,
    required this.message,
  });

  factory GenericServerResponse.fromJson(Map<String, dynamic> json) => GenericServerResponse(
    success: json["success"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
  };
}

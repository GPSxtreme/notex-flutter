// To parse this JSON data, do
//
//     final updateUserDataResponseModel = updateUserDataResponseModelFromJson(jsonString);

import 'dart:convert';

UpdateUserDataResponseModel updateUserDataResponseModelFromJson(String str) => UpdateUserDataResponseModel.fromJson(json.decode(str));

String updateUserDataResponseModelToJson(UpdateUserDataResponseModel data) => json.encode(data.toJson());

class UpdateUserDataResponseModel {
  final bool success;
  final String message;
  final String? token;

  UpdateUserDataResponseModel({
    required this.success,
    required this.message,
    this.token,
  });

  factory UpdateUserDataResponseModel.fromJson(Map<String, dynamic> json) => UpdateUserDataResponseModel(
    success: json["success"],
    message: json["message"],
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "token": token,
  };
}

// To parse this JSON data, do
//
//     final registerResponseModel = registerResponseModelFromJson(jsonString);

import 'dart:convert';

RegisterResponseModel registerResponseModelFromJson(String str) => RegisterResponseModel.fromJson(json.decode(str));

String registerResponseModelToJson(RegisterResponseModel data) => json.encode(data.toJson());

class RegisterResponseModel {
  final bool success;
  final String message;
  final String? token;
  final String? tokenExpiresIn;

  RegisterResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.tokenExpiresIn,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) => RegisterResponseModel(
    success: json["success"],
    message: json["message"],
    token: json["token"],
    tokenExpiresIn: json["tokenExpiresIn"],
  );

  Map<String, dynamic> toJson() => {
    "status": success,
    "message": message,
    "token": token,
    "tokenExpiresIn": tokenExpiresIn,
  };
}

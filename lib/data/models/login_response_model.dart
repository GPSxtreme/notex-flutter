// To parse this JSON data, do
//
//     final loginResponseModel = loginResponseModelFromJson(jsonString);

import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) => LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) => json.encode(data.toJson());

class LoginResponseModel {
  final bool success;
  final String message;
  final String? token;

  LoginResponseModel( {
    required this.success,
    required this.message,
    this.token,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
    success: json["success"],
    message: json["message"],
    token: json["token"]
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "token" : token
  };
}

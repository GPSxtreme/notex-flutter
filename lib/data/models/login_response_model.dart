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
  final String? tokenExpiresIn;

  LoginResponseModel({
    required this.success,
    required this.message,
    this.token,
    this.tokenExpiresIn
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
    success: json["success"],
    message: json["message"],
    token: json["token"],
    tokenExpiresIn: json["tokenExpiresIn"]
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "token" : token,
    "tokenExpiresIn" : tokenExpiresIn
  };
}

// To parse this JSON data, do
//
//     final tokenDataModel = tokenDataModelFromJson(jsonString);

import 'dart:convert';

TokenDataModel tokenDataModelFromJson(String str) => TokenDataModel.fromJson(json.decode(str));

String tokenDataModelToJson(TokenDataModel data) => json.encode(data.toJson());

class TokenDataModel {
  final String userId;
  final String name;
  final String email;

  TokenDataModel({
    required this.userId,
    required this.name,
    required this.email,
  });

  factory TokenDataModel.fromJson(Map<String, dynamic> json) => TokenDataModel(
    userId: json["userId"],
    name: json["name"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "name": name,
    "email": email,
  };
}

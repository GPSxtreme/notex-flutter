// To parse this JSON data, do
//
//     final userDataModel = userDataModelFromJson(jsonString);

import 'dart:convert';

UserDataModel userDataModelFromJson(String str) => UserDataModel.fromJson(json.decode(str));

String userDataModelToJson(UserDataModel data) => json.encode(data.toJson());

class UserDataModel {
  final String userId;
  final String email;
  final String name;
  final bool isEmailVerified;
  final int iat;
  final int exp;

  UserDataModel({
    required this.userId,
    required this.email,
    required this.name,
    required this.isEmailVerified,
    required this.iat,
    required this.exp,
  });

  factory UserDataModel.fromJson(Map<String, dynamic> json) => UserDataModel(
    userId: json["userId"],
    email: json["email"],
    name: json["name"],
    isEmailVerified: json["isEmailVerified"],
    iat: json["iat"],
    exp: json["exp"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "email": email,
    "name": name,
    "isEmailVerified": isEmailVerified,
    "iat": iat,
    "exp": exp,
  };
}

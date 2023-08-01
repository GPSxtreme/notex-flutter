// To parse this JSON data, do
//
//     final updatableUserDataModel = updatableUserDataModelFromJson(jsonString);

import 'dart:convert';

UpdatableUserDataModel updatableUserDataModelFromJson(String str) => UpdatableUserDataModel.fromJson(json.decode(str));

String updatableUserDataModelToJson(UpdatableUserDataModel data) => json.encode(data.toJson());

class UpdatableUserDataModel {
  final String name;
  final String country;
  final String dob;

  UpdatableUserDataModel({
    required this.name,
    required this.country,
    required this.dob,
  });

  factory UpdatableUserDataModel.fromJson(Map<String, dynamic> json) => UpdatableUserDataModel(
    name: json["name"],
    country: json["country"],
    dob: json["dob"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "country": country,
    "dob": dob,
  };
}

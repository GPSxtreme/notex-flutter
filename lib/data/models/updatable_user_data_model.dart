// To parse this JSON data, do
//
//     final updatableUserDataModel = updatableUserDataModelFromJson(jsonString);

import 'dart:convert';

UpdatableUserDataModel updatableUserDataModelFromJson(String str) => UpdatableUserDataModel.fromJson(json.decode(str));

String updatableUserDataModelToJson(UpdatableUserDataModel data) => json.encode(data.toJson());

class UpdatableUserDataModel {
  final String name;
  final String countryCode;
  final DateTime dob;

  UpdatableUserDataModel({
    required this.name,
    required this.countryCode,
    required this.dob,
  });

  factory UpdatableUserDataModel.fromJson(Map<String, dynamic> json) => UpdatableUserDataModel(
    name: json["name"],
    countryCode: json["country"],
    dob: DateTime.parse(json["dob"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "country": countryCode,
    "dob": dob.toUtc().toIso8601String(),
  };
}

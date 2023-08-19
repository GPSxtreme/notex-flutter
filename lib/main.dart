// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notex/core/repositories/local_database_repository.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import 'app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'data/datasources/user_data.dart';

LocalDatabaseRepository LOCAL_DB = LocalDatabaseRepository();
User USER = User();

void main() async{
  await dotenv.load();
  // print({"time":DateTime.now().toIso8601String()});
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: kPageBgStart,
  ));
  runApp(const MyApp());
}



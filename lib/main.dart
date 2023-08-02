import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notex/core/repositories/local_database_repository.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import 'app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// ignore: non_constant_identifier_names
LocalDatabaseRepository LOCAL_DB = LocalDatabaseRepository();

void main() async{
  await dotenv.load();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: kPageBgStart,
  ));
  runApp(const MyApp());
}



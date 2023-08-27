// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notex/core/repositories/local_database_repository.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import 'package:notex/services/notification.dart';
import 'app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/datasources/settngs_data.dart';
import 'data/datasources/user_data.dart';
import 'package:timezone/data/latest.dart' as tz;

LocalDatabaseRepository LOCAL_DB = LocalDatabaseRepository();
User USER = User();
Settings SETTINGS = Settings();
NotificationService NOTIFICATION_SERVICES = NotificationService();

void main() async{
  await dotenv.load();
  await NOTIFICATION_SERVICES.init();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: kPageBgStart,
  ));
  tz.initializeTimeZones();
  runApp(const MyApp());
}



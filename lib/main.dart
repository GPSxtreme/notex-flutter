import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notex/presentation/styles/app_styles.dart';
import 'app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  await dotenv.load();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: kPageBgStart,
  ));
  runApp(const MyApp());
}



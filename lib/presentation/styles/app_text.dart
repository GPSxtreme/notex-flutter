import 'package:flutter/material.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/size_config.dart';

class AppText {
  // Define text sizes
  static double get _textXsSize => 12 * SizeConfig.textScaleFactor!;
  static double get _textSmSize => 14 * SizeConfig.textScaleFactor!;
  static double get _textBaseSize => 16 * SizeConfig.textScaleFactor!;
  static double get _textLgSize => 18 * SizeConfig.textScaleFactor!;
  static double get _textXlSize => 20 * SizeConfig.textScaleFactor!;
  static double get _text2XlSize => 24 * SizeConfig.textScaleFactor!;
  static double get _text3XlSize => 30 * SizeConfig.textScaleFactor!;
  static double get _text4XlSize => 36 * SizeConfig.textScaleFactor!;
  static double get _text5XlSize => 48 * SizeConfig.textScaleFactor!;
  static double get _text6XlSize => 60 * SizeConfig.textScaleFactor!;
  static double get _text7XlSize => 72 * SizeConfig.textScaleFactor!;

  static TextStyle get textXs => TextStyle(
      fontSize: _textXsSize, color: AppColors.foreground, height: 1.16);
  static TextStyle get textSm => TextStyle(
      fontSize: _textSmSize, color: AppColors.foreground, height: 1.20);
  static TextStyle get textBase => TextStyle(
      fontSize: _textBaseSize, color: AppColors.foreground, height: 1.24);
  static TextStyle get textLg => TextStyle(
      fontSize: _textLgSize, color: AppColors.foreground, height: 1.28);
  static TextStyle get textXl => TextStyle(
      fontSize: _textXlSize, color: AppColors.foreground, height: 1.28);
  static TextStyle get text2Xl => TextStyle(
      fontSize: _text2XlSize, color: AppColors.foreground, height: 1.32);
  static TextStyle get text3Xl => TextStyle(
      fontSize: _text3XlSize, color: AppColors.foreground, height: 0.9);
  static TextStyle get text4Xl => TextStyle(
      fontSize: _text4XlSize, color: AppColors.foreground, height: 0.9);
  static TextStyle get text5Xl => TextStyle(
      fontSize: _text5XlSize, color: AppColors.foreground, height: 0.8);
  static TextStyle get text6Xl => TextStyle(
      fontSize: _text6XlSize, color: AppColors.foreground, height: 0.8);
  static TextStyle get text7Xl => TextStyle(
      fontSize: _text7XlSize, color: AppColors.foreground, height: 0.7);

  // Font weight definitions
  static FontWeight get _thin => FontWeight.w100;
  static FontWeight get _extraLight => FontWeight.w200;
  static FontWeight get _light => FontWeight.w300;
  static FontWeight get _normal => FontWeight.w400;
  static FontWeight get _medium => FontWeight.w500;
  static FontWeight get _semiBold => FontWeight.w600;
  static FontWeight get _bold => FontWeight.w700;
  static FontWeight get _extraBold => FontWeight.w800;
  static FontWeight get _black => FontWeight.w900;

  //text-xs
  static TextStyle get textXsThin => textXs.copyWith(fontWeight: _thin);
  static TextStyle get textXsExtraLight =>
      textXs.copyWith(fontWeight: _extraLight);
  static TextStyle get textXsLight => textXs.copyWith(fontWeight: _light);
  static TextStyle get textXsNormal => textXs.copyWith(fontWeight: _normal);
  static TextStyle get textXsMedium => textXs.copyWith(fontWeight: _medium);
  static TextStyle get textXsSemiBold => textXs.copyWith(fontWeight: _semiBold);
  static TextStyle get textXsBold => textXs.copyWith(fontWeight: _bold);
  static TextStyle get textXsExtraBold =>
      textXs.copyWith(fontWeight: _extraBold);
  static TextStyle get textXsBlack => textXs.copyWith(fontWeight: _black);

  //text-sm
  static TextStyle get textSmThin => textSm.copyWith(fontWeight: _thin);
  static TextStyle get textSmExtraLight =>
      textSm.copyWith(fontWeight: _extraLight);
  static TextStyle get textSmLight => textSm.copyWith(fontWeight: _light);
  static TextStyle get textSmNormal => textSm.copyWith(fontWeight: _normal);
  static TextStyle get textSmMedium => textSm.copyWith(fontWeight: _medium);
  static TextStyle get textSmSemiBold => textSm.copyWith(fontWeight: _semiBold);
  static TextStyle get textSmBold => textSm.copyWith(fontWeight: _bold);
  static TextStyle get textSmExtraBold =>
      textSm.copyWith(fontWeight: _extraBold);
  static TextStyle get textSmBlack => textSm.copyWith(fontWeight: _black);

  //text-md
  static TextStyle get textBaseThin => textBase.copyWith(fontWeight: _thin);
  static TextStyle get textBaseExtraLight =>
      textBase.copyWith(fontWeight: _extraLight);
  static TextStyle get textBaseLight => textBase.copyWith(fontWeight: _light);
  static TextStyle get textBaseNormal => textBase.copyWith(fontWeight: _normal);
  static TextStyle get textBaseMedium => textBase.copyWith(fontWeight: _medium);
  static TextStyle get textBaseSemiBold =>
      textBase.copyWith(fontWeight: _semiBold);
  static TextStyle get textBaseBold => textBase.copyWith(fontWeight: _bold);
  static TextStyle get textBaseExtraBold =>
      textBase.copyWith(fontWeight: _extraBold);
  static TextStyle get textBaseBlack => textBase.copyWith(fontWeight: _black);

  //text-lg
  static TextStyle get textLgThin => textLg.copyWith(fontWeight: _thin);
  static TextStyle get textLgExtraLight =>
      textLg.copyWith(fontWeight: _extraLight);
  static TextStyle get textLgLight => textLg.copyWith(fontWeight: _light);
  static TextStyle get textLgNormal => textLg.copyWith(fontWeight: _normal);
  static TextStyle get textLgMedium => textLg.copyWith(fontWeight: _medium);
  static TextStyle get textLgSemiBold => textLg.copyWith(fontWeight: _semiBold);
  static TextStyle get textLgBold => textLg.copyWith(fontWeight: _bold);
  static TextStyle get textLgExtraBold =>
      textLg.copyWith(fontWeight: _extraBold);
  static TextStyle get textLgBlack => textLg.copyWith(fontWeight: _black);

  //text-xl
  static TextStyle get textXlThin => textXl.copyWith(fontWeight: _thin);
  static TextStyle get textXlExtraLight =>
      textXl.copyWith(fontWeight: _extraLight);
  static TextStyle get textXlLight => textXl.copyWith(fontWeight: _light);
  static TextStyle get textXlNormal => textXl.copyWith(fontWeight: _normal);
  static TextStyle get textXlMedium => textXl.copyWith(fontWeight: _medium);
  static TextStyle get textXlSemiBold => textXl.copyWith(fontWeight: _semiBold);
  static TextStyle get textXlBold => textXl.copyWith(fontWeight: _bold);
  static TextStyle get textXlExtraBold =>
      textXl.copyWith(fontWeight: _extraBold);
  static TextStyle get textXlBlack => textXl.copyWith(fontWeight: _black);

  //text-2xl
  static TextStyle get text2XlThin => text2Xl.copyWith(fontWeight: _thin);
  static TextStyle get text2XlExtraLight =>
      text2Xl.copyWith(fontWeight: _extraLight);
  static TextStyle get text2XlLight => text2Xl.copyWith(fontWeight: _light);
  static TextStyle get text2XlNormal => text2Xl.copyWith(fontWeight: _normal);
  static TextStyle get text2XlMedium => text2Xl.copyWith(fontWeight: _medium);
  static TextStyle get text2XlSemiBold =>
      text2Xl.copyWith(fontWeight: _semiBold);
  static TextStyle get text2XlBold => text2Xl.copyWith(fontWeight: _bold);
  static TextStyle get text2XlExtraBold =>
      text2Xl.copyWith(fontWeight: _extraBold);
  static TextStyle get text2XlBlack => text2Xl.copyWith(fontWeight: _black);

  //text-3xl
  static TextStyle get text3XlThin => text3Xl.copyWith(fontWeight: _thin);
  static TextStyle get text3XlExtraLight =>
      text3Xl.copyWith(fontWeight: _extraLight);
  static TextStyle get text3XlLight => text3Xl.copyWith(fontWeight: _light);
  static TextStyle get text3XlNormal => text3Xl.copyWith(fontWeight: _normal);
  static TextStyle get text3XlMedium => text3Xl.copyWith(fontWeight: _medium);
  static TextStyle get text3XlSemiBold =>
      text3Xl.copyWith(fontWeight: _semiBold);
  static TextStyle get text3XlBold => text3Xl.copyWith(fontWeight: _bold);
  static TextStyle get text3XlExtraBold =>
      text3Xl.copyWith(fontWeight: _extraBold);
  static TextStyle get text3XlBlack => text3Xl.copyWith(fontWeight: _black);

  //text-4xl
  static TextStyle get text4XlThin => text4Xl.copyWith(fontWeight: _thin);
  static TextStyle get text4XlExtraLight =>
      text4Xl.copyWith(fontWeight: _extraLight);
  static TextStyle get text4XlLight => text4Xl.copyWith(fontWeight: _light);
  static TextStyle get text4XlNormal => text4Xl.copyWith(fontWeight: _normal);
  static TextStyle get text4XlMedium => text4Xl.copyWith(fontWeight: _medium);
  static TextStyle get text4XlSemiBold =>
      text4Xl.copyWith(fontWeight: _semiBold);
  static TextStyle get text4XlBold => text4Xl.copyWith(fontWeight: _bold);
  static TextStyle get text4XlExtraBold =>
      text4Xl.copyWith(fontWeight: _extraBold);
  static TextStyle get text4XlBlack => text4Xl.copyWith(fontWeight: _black);

  // text5xl
  static TextStyle get text5XlThin => text5Xl.copyWith(fontWeight: _thin);
  static TextStyle get text5XlExtraLight =>
      text5Xl.copyWith(fontWeight: _extraLight);
  static TextStyle get text5XlLight => text5Xl.copyWith(fontWeight: _light);
  static TextStyle get text5XlNormal => text5Xl.copyWith(fontWeight: _normal);
  static TextStyle get text5XlMedium => text5Xl.copyWith(fontWeight: _medium);
  static TextStyle get text5XlSemiBold =>
      text5Xl.copyWith(fontWeight: _semiBold);
  static TextStyle get text5XlBold => text5Xl.copyWith(fontWeight: _bold);
  static TextStyle get text5XlExtraBold =>
      text5Xl.copyWith(fontWeight: _extraBold);
  static TextStyle get text5XlBlack => text5Xl.copyWith(fontWeight: _black);

  // text6Xl
  static TextStyle get text6XlThin => text6Xl.copyWith(fontWeight: _thin);
  static TextStyle get text6XlExtraLight =>
      text6Xl.copyWith(fontWeight: _extraLight);
  static TextStyle get text6XlLight => text6Xl.copyWith(fontWeight: _light);
  static TextStyle get text6XlNormal => text6Xl.copyWith(fontWeight: _normal);
  static TextStyle get text6XlMedium => text6Xl.copyWith(fontWeight: _medium);
  static TextStyle get text6XlSemiBold =>
      text6Xl.copyWith(fontWeight: _semiBold);
  static TextStyle get text6XlBold => text6Xl.copyWith(fontWeight: _bold);
  static TextStyle get text6XlExtraBold =>
      text6Xl.copyWith(fontWeight: _extraBold);
  static TextStyle get text6XlBlack => text6Xl.copyWith(fontWeight: _black);

// text7Xl
  static TextStyle get text7XlThin => text7Xl.copyWith(fontWeight: _thin);
  static TextStyle get text7XlExtraLight =>
      text7Xl.copyWith(fontWeight: _extraLight);
  static TextStyle get text7XlLight => text7Xl.copyWith(fontWeight: _light);
  static TextStyle get text7XlNormal => text7Xl.copyWith(fontWeight: _normal);
  static TextStyle get text7XlMedium => text7Xl.copyWith(fontWeight: _medium);
  static TextStyle get text7XlSemiBold =>
      text7Xl.copyWith(fontWeight: _semiBold);
  static TextStyle get text7XlBold => text7Xl.copyWith(fontWeight: _bold);
  static TextStyle get text7XlExtraBold =>
      text7Xl.copyWith(fontWeight: _extraBold);
  static TextStyle get text7XlBlack => text7Xl.copyWith(fontWeight: _black);
}

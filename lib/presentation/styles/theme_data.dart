import 'package:flutter/material.dart';
import 'package:notex/presentation/styles/app_colors.dart';
import 'package:notex/presentation/styles/app_text.dart';
import 'package:notex/presentation/styles/size_config.dart';

final defaultThemeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      primaryContainer: AppColors.primary,
      secondary: AppColors.secondary,
      secondaryContainer: AppColors.secondary,
      surface: AppColors.background,
      error: Colors.red,
      onPrimary: AppColors.foreground,
      onSecondary: AppColors.foreground,
      onSurface: AppColors.foreground,
      onError: Colors.black,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding:
          EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 0),
      titleTextStyle: AppText.textBaseSemiBold,
      subtitleTextStyle: AppText.textSm,
    ),
    switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(AppColors.primaryForeground),
        thumbIcon: WidgetStateProperty.resolveWith<Icon?>(
          (Set<WidgetState> states) {
            return Icon(
              Icons.circle_rounded,
              size: AppSpacing.iconSizeSm,
              color: AppColors.primaryForeground,
            );
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.input;
          },
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        trackOutlineWidth: const WidgetStatePropertyAll(0.0)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: AppText.textLgSemiBold.copyWith(color: AppColors.primary),
        shape: ContinuousRectangleBorder(
          borderRadius: AppBorderRadius.lg,
        ),
        backgroundColor: AppColors.accent,
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryForeground.withOpacity(
                  0.15); // Color for the splash effect when pressed
            }
            return null; // Use the default overlay color in other states
          },
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.transparent, // Background color for the text field
      hintStyle: AppText.textBase.copyWith(color: AppColors.mutedForeground),
      border: OutlineInputBorder(
        // Normal state border
        borderRadius: AppBorderRadius.lg,
// Rounded corners
        borderSide: const BorderSide(color: AppColors.border), // Border color
      ),
      enabledBorder: OutlineInputBorder(
        // Enabled state border
        borderRadius: AppBorderRadius.lg,

        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        // Focused state border
        borderRadius: AppBorderRadius.lg,
        borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.0), // Thicker border when focused
      ),
      contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 12.0), // Padding inside the text field
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.accent),
          elevation: WidgetStateProperty.all(8.0),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: AppBorderRadius.lg,
            ),
          ),
          padding: WidgetStateProperty.all(
            EdgeInsets.all(AppSpacing.sm),
          ),
          iconColor: WidgetStateProperty.all(AppColors.foreground)),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
            borderRadius: AppBorderRadius.md,
            side: const BorderSide(color: AppColors.border, width: 1.0))),
        side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.border, width: 1.0)),
        backgroundColor: WidgetStateProperty.all(AppColors.card),
        padding: WidgetStateProperty.all(const EdgeInsets.all(0.0)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        constraints: BoxConstraints(maxHeight: AppSpacing.xxl),
        isDense: true,
        contentPadding:
            EdgeInsets.symmetric(horizontal: 12.0, vertical: AppSpacing.sm),
        isCollapsed: true,
        border: OutlineInputBorder(
          // Adding a border
          borderRadius: AppBorderRadius.md,
          borderSide: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.md,
          borderSide: const BorderSide(color: AppColors.border, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppBorderRadius.md,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
        ),
      ),
    ));

import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/nivex_colors.dart';

abstract final class NivexTheme {
  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: NivexColors.blue,
      onPrimary: NivexColors.white,
      secondary: NivexColors.green,
      onSecondary: NivexColors.white,
      surface: NivexColors.white,
      onSurface: NivexColors.navy,
      outline: NivexColors.border,
      error: NivexColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: NivexColors.ivory,
      splashFactory: InkSparkle.splashFactory,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: NivexColors.navy,
          fontSize: 31,
          height: 1.1,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
        ),
        headlineSmall: TextStyle(
          color: NivexColors.navy,
          fontSize: 22,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          color: NivexColors.navy,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: NivexColors.navy,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: NivexColors.navy,
          fontSize: 15,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          color: NivexColors.textSecondary,
          fontSize: 13,
          height: 1.4,
        ),
        labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      dividerTheme: const DividerThemeData(
        color: NivexColors.border,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: NivexColors.white,
        indicatorColor: NivexColors.blueSoft,
        height: 72,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: NivexColors.navy,
        contentTextStyle: const TextStyle(color: NivexColors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

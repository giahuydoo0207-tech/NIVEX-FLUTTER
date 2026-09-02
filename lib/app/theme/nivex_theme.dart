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
      scaffoldBackgroundColor: NivexColors.white,
      splashFactory: InkSparkle.splashFactory,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: NivexColors.navy,
          fontSize: 32,
          height: 1.15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          color: NivexColors.navy,
          fontSize: 22,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          color: NivexColors.navy,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          color: NivexColors.navy,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        bodyLarge: TextStyle(
          color: NivexColors.navy,
          fontSize: 15,
          height: 1.45,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(
          color: NivexColors.textSecondary,
          fontSize: 13,
          height: 1.4,
          letterSpacing: 0,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: NivexColors.border,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: NivexColors.white,
        indicatorColor: Colors.transparent,
        height: 64,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: NivexColors.blue,
              letterSpacing: 0,
            );
          }
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: NivexColors.textSecondary,
            letterSpacing: 0,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: NivexColors.blue, size: 24);
          }
          return const IconThemeData(
            color: NivexColors.textSecondary,
            size: 24,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: NivexColors.navy,
        contentTextStyle: const TextStyle(
          color: NivexColors.white,
          letterSpacing: 0,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

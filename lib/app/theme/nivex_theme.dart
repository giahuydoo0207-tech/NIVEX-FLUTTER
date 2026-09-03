import 'package:flutter/material.dart';
import 'package:nivex_flutter/app/theme/app_theme_mode.dart';
import 'package:nivex_flutter/app/theme/nivex_theme_extension.dart';

abstract final class NivexTheme {
  static ThemeData get light => forMode(AppThemeMode.defaultTheme);

  static ThemeData forMode(AppThemeMode mode) {
    final ext = switch (mode) {
      AppThemeMode.defaultTheme => NivexThemeExtension.defaultLight,
      AppThemeMode.cyberNight => NivexThemeExtension.cyberNight,
      AppThemeMode.blockchainFlow => NivexThemeExtension.blockchainFlow,
      AppThemeMode.vietnamFuture => NivexThemeExtension.vietnamFuture,
    };

    final scheme = ColorScheme(
      brightness: ext.isDark ? Brightness.dark : Brightness.light,
      primary: ext.primary,
      onPrimary: ext.isDark ? const Color(0xFF0F172A) : Colors.white,
      secondary: ext.secondary,
      onSecondary: Colors.white,
      surface: ext.surface,
      onSurface: ext.textPrimary,
      error: ext.danger,
      onError: Colors.white,
      outline: ext.border,
      outlineVariant: ext.divider,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ext.background,
      splashFactory: InkSparkle.splashFactory,
      extensions: [ext],
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: ext.textPrimary,
          fontSize: 32,
          height: 1.15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          color: ext.textPrimary,
          fontSize: 22,
          height: 1.2,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          color: ext.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          color: ext.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
        bodyLarge: TextStyle(
          color: ext.textPrimary,
          fontSize: 15,
          height: 1.45,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(
          color: ext.textSecondary,
          fontSize: 13,
          height: 1.4,
          letterSpacing: 0,
        ),
        labelLarge: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ext.textPrimary,
          letterSpacing: 0,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: ext.divider,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ext.surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: ext.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        contentTextStyle: TextStyle(
          color: ext.textSecondary,
          fontSize: 14,
          height: 1.4,
          letterSpacing: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: ext.border),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: ext.surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: ext.textSecondary,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ext.surface,
        indicatorColor: Colors.transparent,
        height: 64,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ext.primary,
              letterSpacing: 0,
            );
          }
          return TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: ext.textSecondary,
            letterSpacing: 0,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: ext.primary, size: 24);
          }
          return IconThemeData(color: ext.textSecondary, size: 24);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ext.isDark ? ext.surfaceSubtle : ext.textPrimary,
        contentTextStyle: TextStyle(
          color: ext.isDark ? ext.textPrimary : Colors.white,
          letterSpacing: 0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: ext.border),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

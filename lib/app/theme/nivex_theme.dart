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
      appBarTheme: AppBarTheme(
        backgroundColor: ext.background,
        foregroundColor: ext.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ext.surface,
        hintStyle: TextStyle(color: ext.textSecondary, fontSize: 13),
        labelStyle: TextStyle(color: ext.textSecondary, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: ext.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: ext.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: ext.primary, width: 1.5),
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        elevation: const WidgetStatePropertyAll(0),
        backgroundColor: WidgetStatePropertyAll(ext.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        hintStyle: WidgetStatePropertyAll(
          TextStyle(color: ext.textSecondary, fontSize: 13),
        ),
        textStyle: WidgetStatePropertyAll(
          TextStyle(color: ext.textPrimary, fontSize: 14),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: ext.border),
          ),
        ),
        constraints: const BoxConstraints(minHeight: 50),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(0, 46)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 8),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? ext.primary
                : ext.textSecondary;
          }),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? ext.primary.withValues(alpha: 0.1)
                : ext.surface;
          }),
          side: WidgetStatePropertyAll(BorderSide(color: ext.border)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: ext.primary,
          foregroundColor: ext.isDark ? const Color(0xFF07101F) : Colors.white,
          disabledBackgroundColor: ext.disabled.withValues(alpha: 0.45),
          disabledForegroundColor: ext.textSecondary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: ext.textPrimary,
          side: BorderSide(color: ext.border),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: ext.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: ext.border),
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
        height: 68,
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

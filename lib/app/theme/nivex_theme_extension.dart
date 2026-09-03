import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivex_flutter/app/theme/app_theme_mode.dart';

class NivexThemeExtension extends ThemeExtension<NivexThemeExtension> {
  const NivexThemeExtension({
    required this.mode,
    required this.heroImage,
    required this.heroGradient,
    required this.background,
    required this.surface,
    required this.surfaceSubtle,
    required this.primary,
    required this.secondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.divider,
    required this.success,
    required this.successSoft,
    required this.danger,
    required this.dangerSoft,
    required this.warning,
    required this.warningSoft,
    required this.disabled,
    required this.isDark,
    required this.systemOverlayStyle,
  });

  final AppThemeMode mode;
  final String heroImage;
  final LinearGradient heroGradient;
  final Color background;
  final Color surface;
  final Color surfaceSubtle;
  final Color primary;
  final Color secondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color divider;
  final Color success;
  final Color successSoft;
  final Color danger;
  final Color dangerSoft;
  final Color warning;
  final Color warningSoft;
  final Color disabled;
  final bool isDark;
  final SystemUiOverlayStyle systemOverlayStyle;

  static const defaultLight = NivexThemeExtension(
    mode: AppThemeMode.defaultTheme,
    heroImage: 'assets/images/nivex-home-skyline.jpg',
    heroGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xF2071A2E), Color(0xD00A2340), Color(0x2B0B2749)],
      stops: [0.0, 0.55, 1.0],
    ),
    background: Color(0xFFF8F9FA),
    surface: Color(0xFFFFFFFF),
    surfaceSubtle: Color(0xFFF1F4F6),
    primary: Color(0xFF1E60D5),
    secondary: Color(0xFF108A55),
    textPrimary: Color(0xFF0F2439),
    textSecondary: Color(0xFF64748B),
    border: Color(0xFFE5E9EF),
    divider: Color(0xFFE5E9EF),
    success: Color(0xFF108A55),
    successSoft: Color(0xFFE8F6EF),
    danger: Color(0xFFDC2626),
    dangerSoft: Color(0xFFFEE2E2),
    warning: Color(0xFFB7791F),
    warningSoft: Color(0xFFFEF3C7),
    disabled: Color(0xFFCBD5E1),
    isDark: false,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFFFFFFFF),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  static const cyberNight = NivexThemeExtension(
    mode: AppThemeMode.cyberNight,
    heroImage: 'assets/images/themes/cyber-night-hero.jpg',
    heroGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xF2070A11), Color(0xD00A0E1A), Color(0x250A0E1A)],
      stops: [0.0, 0.55, 1.0],
    ),
    background: Color(0xFF070A11),
    surface: Color(0xFF0F172A),
    surfaceSubtle: Color(0xFF1E293B),
    primary: Color(0xFF00D2FF),
    secondary: Color(0xFF10B981),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    border: Color(0xFF1E293B),
    divider: Color(0xFF1E293B),
    success: Color(0xFF10B981),
    successSoft: Color(0xFF064E3B),
    danger: Color(0xFFEF4444),
    dangerSoft: Color(0xFF450A0A),
    warning: Color(0xFFF59E0B),
    warningSoft: Color(0xFF451A03),
    disabled: Color(0xFF475569),
    isDark: true,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF070A11),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  static const blockchainFlow = NivexThemeExtension(
    mode: AppThemeMode.blockchainFlow,
    heroImage: 'assets/images/themes/blockchain-flow-hero.jpg',
    heroGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xF2080E24), Color(0xD00E193C), Color(0x250E193C)],
      stops: [0.0, 0.55, 1.0],
    ),
    background: Color(0xFF080E24),
    surface: Color(0xFF101C3D),
    surfaceSubtle: Color(0xFF1B2B59),
    primary: Color(0xFF38BDF8),
    secondary: Color(0xFF818CF8),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    border: Color(0xFF223566),
    divider: Color(0xFF223566),
    success: Color(0xFF34D399),
    successSoft: Color(0xFF064E3B),
    danger: Color(0xFFF87171),
    dangerSoft: Color(0xFF450A0A),
    warning: Color(0xFFFBBF24),
    warningSoft: Color(0xFF451A03),
    disabled: Color(0xFF475569),
    isDark: true,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF080E24),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  static const vietnamFuture = NivexThemeExtension(
    mode: AppThemeMode.vietnamFuture,
    heroImage: 'assets/images/themes/vietnam-future-hero.jpg',
    heroGradient: LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Color(0xD9140F08), Color(0x9918120B), Color(0x2618120B)],
      stops: [0.0, 0.55, 1.0],
    ),
    background: Color(0xFFFAF7F2),
    surface: Color(0xFFFFFFFF),
    surfaceSubtle: Color(0xFFFBF4E4),
    primary: Color(0xFFA16B0A),
    secondary: Color(0xFF15803D),
    textPrimary: Color(0xFF0F2439),
    textSecondary: Color(0xFF64748B),
    border: Color(0xFFEBE2CF),
    divider: Color(0xFFEBE2CF),
    success: Color(0xFF15803D),
    successSoft: Color(0xFFEAF5EE),
    danger: Color(0xFFDC2626),
    dangerSoft: Color(0xFFFEE2E2),
    warning: Color(0xFFA16B0A),
    warningSoft: Color(0xFFFEF3C7),
    disabled: Color(0xFFCBD5E1),
    isDark: false,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFFFFFFFF),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  @override
  ThemeExtension<NivexThemeExtension> copyWith({
    AppThemeMode? mode,
    String? heroImage,
    LinearGradient? heroGradient,
    Color? background,
    Color? surface,
    Color? surfaceSubtle,
    Color? primary,
    Color? secondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? divider,
    Color? success,
    Color? successSoft,
    Color? danger,
    Color? dangerSoft,
    Color? warning,
    Color? warningSoft,
    Color? disabled,
    bool? isDark,
    SystemUiOverlayStyle? systemOverlayStyle,
  }) {
    return NivexThemeExtension(
      mode: mode ?? this.mode,
      heroImage: heroImage ?? this.heroImage,
      heroGradient: heroGradient ?? this.heroGradient,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      disabled: disabled ?? this.disabled,
      isDark: isDark ?? this.isDark,
      systemOverlayStyle: systemOverlayStyle ?? this.systemOverlayStyle,
    );
  }

  @override
  ThemeExtension<NivexThemeExtension> lerp(
    covariant ThemeExtension<NivexThemeExtension>? other,
    double t,
  ) {
    if (other is! NivexThemeExtension) return this;

    return NivexThemeExtension(
      mode: t < 0.5 ? mode : other.mode,
      heroImage: t < 0.5 ? heroImage : other.heroImage,
      heroGradient:
          LinearGradient.lerp(heroGradient, other.heroGradient, t) ??
          (t < 0.5 ? heroGradient : other.heroGradient),
      background:
          Color.lerp(background, other.background, t) ??
          (t < 0.5 ? background : other.background),
      surface:
          Color.lerp(surface, other.surface, t) ??
          (t < 0.5 ? surface : other.surface),
      surfaceSubtle:
          Color.lerp(surfaceSubtle, other.surfaceSubtle, t) ??
          (t < 0.5 ? surfaceSubtle : other.surfaceSubtle),
      primary:
          Color.lerp(primary, other.primary, t) ??
          (t < 0.5 ? primary : other.primary),
      secondary:
          Color.lerp(secondary, other.secondary, t) ??
          (t < 0.5 ? secondary : other.secondary),
      textPrimary:
          Color.lerp(textPrimary, other.textPrimary, t) ??
          (t < 0.5 ? textPrimary : other.textPrimary),
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ??
          (t < 0.5 ? textSecondary : other.textSecondary),
      border:
          Color.lerp(border, other.border, t) ??
          (t < 0.5 ? border : other.border),
      divider:
          Color.lerp(divider, other.divider, t) ??
          (t < 0.5 ? divider : other.divider),
      success:
          Color.lerp(success, other.success, t) ??
          (t < 0.5 ? success : other.success),
      successSoft:
          Color.lerp(successSoft, other.successSoft, t) ??
          (t < 0.5 ? successSoft : other.successSoft),
      danger:
          Color.lerp(danger, other.danger, t) ??
          (t < 0.5 ? danger : other.danger),
      dangerSoft:
          Color.lerp(dangerSoft, other.dangerSoft, t) ??
          (t < 0.5 ? dangerSoft : other.dangerSoft),
      warning:
          Color.lerp(warning, other.warning, t) ??
          (t < 0.5 ? warning : other.warning),
      warningSoft:
          Color.lerp(warningSoft, other.warningSoft, t) ??
          (t < 0.5 ? warningSoft : other.warningSoft),
      disabled:
          Color.lerp(disabled, other.disabled, t) ??
          (t < 0.5 ? disabled : other.disabled),
      isDark: t < 0.5 ? isDark : other.isDark,
      systemOverlayStyle: t < 0.5
          ? systemOverlayStyle
          : other.systemOverlayStyle,
    );
  }
}

extension NivexThemeContextExtension on BuildContext {
  NivexThemeExtension get nivexTheme =>
      Theme.of(this).extension<NivexThemeExtension>() ??
      NivexThemeExtension.defaultLight;
}

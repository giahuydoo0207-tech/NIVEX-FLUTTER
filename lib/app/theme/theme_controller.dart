import 'package:flutter/foundation.dart';
import 'package:nivex_flutter/app/theme/app_theme_mode.dart';
import 'package:nivex_flutter/app/theme/theme_store.dart';

class ThemeController extends ValueNotifier<AppThemeMode> {
  ThemeController({
    ThemePreferenceStore? store,
    AppThemeMode initialMode = AppThemeMode.defaultTheme,
  }) : _store = store ?? SharedPreferencesThemeStore(),
       super(initialMode);

  final ThemePreferenceStore _store;

  AppThemeMode get mode => value;

  Future<void> load() async {
    try {
      final storedString = await _store.readTheme();
      final resolvedMode = AppThemeMode.fromStorageString(storedString);
      value = resolvedMode;
    } catch (_) {
      value = AppThemeMode.defaultTheme;
    }
  }

  Future<bool> setTheme(AppThemeMode newMode) async {
    if (value == newMode) return true;
    final previousMode = value;
    value = newMode;
    try {
      await _store.writeTheme(newMode.toStorageString());
      return true;
    } catch (_) {
      value = previousMode;
      return false;
    }
  }

  void resetForTest([AppThemeMode mode = AppThemeMode.defaultTheme]) {
    value = mode;
  }
}

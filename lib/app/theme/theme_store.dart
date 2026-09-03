import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ThemePreferenceStore {
  Future<String?> readTheme();
  Future<void> writeTheme(String value);
}

class SharedPreferencesThemeStore implements ThemePreferenceStore {
  SharedPreferencesThemeStore([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? _safeCreatePrefs();

  static SharedPreferencesAsync? _safeCreatePrefs() {
    try {
      return SharedPreferencesAsync();
    } catch (_) {
      return null;
    }
  }

  final SharedPreferencesAsync? _prefs;
  static const String _key = 'nivex_app_theme_mode';

  @override
  Future<String?> readTheme() async {
    try {
      return await _prefs?.getString(_key);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> writeTheme(String value) async {
    try {
      await _prefs?.setString(_key, value);
    } catch (_) {
      // Ignore or let caller handle
    }
  }
}

class FakeThemePreferenceStore implements ThemePreferenceStore {
  FakeThemePreferenceStore([this.storedValue, this.shouldThrowOnWrite = false]);

  String? storedValue;
  bool shouldThrowOnWrite;

  @override
  Future<String?> readTheme() async => storedValue;

  @override
  Future<void> writeTheme(String value) async {
    if (shouldThrowOnWrite) {
      throw Exception('Fake write error');
    }
    storedValue = value;
  }
}

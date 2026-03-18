import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme_mode.dart';

abstract class ThemePreferenceStore {
  Future<AppThemeMode?> readThemeMode();

  Future<void> writeThemeMode(AppThemeMode mode);
}

final themePreferenceStoreProvider = Provider<ThemePreferenceStore>((ref) {
  return SharedPreferencesThemePreferenceStore();
});

class SharedPreferencesThemePreferenceStore implements ThemePreferenceStore {
  static const _themeModeKey = 'flashmind_theme_mode';

  @override
  Future<AppThemeMode?> readThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_themeModeKey);

    if (value == null || value.isEmpty) {
      return null;
    }

    return AppThemeModeX.fromStorage(value);
  }

  @override
  Future<void> writeThemeMode(AppThemeMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeModeKey, mode.storageValue);
  }
}

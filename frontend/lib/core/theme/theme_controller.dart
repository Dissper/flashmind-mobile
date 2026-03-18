import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme_mode.dart';
import 'theme_preference_store.dart';

final themeControllerProvider =
    NotifierProvider<ThemeController, AppThemeMode>(ThemeController.new);

class ThemeController extends Notifier<AppThemeMode> {
  late final ThemePreferenceStore _preferenceStore;

  @override
  AppThemeMode build() {
    _preferenceStore = ref.watch(themePreferenceStoreProvider);
    _restoreThemeMode();
    return AppThemeMode.dark;
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (state == mode) {
      return;
    }

    state = mode;
    await _preferenceStore.writeThemeMode(mode);
  }

  Future<void> _restoreThemeMode() async {
    final savedMode = await _preferenceStore.readThemeMode();
    if (savedMode == null) {
      return;
    }

    state = savedMode;
  }
}

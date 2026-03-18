import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flashmind_mobile/core/theme/app_theme_mode.dart';
import 'package:flashmind_mobile/core/theme/theme_controller.dart';
import 'package:flashmind_mobile/core/theme/theme_preference_store.dart';

void main() {
  group('ThemeController', () {
    test('restores a saved theme mode on startup', () async {
      final store = InMemoryThemePreferenceStore(
        initialMode: AppThemeMode.light,
      );

      final container = ProviderContainer(
        overrides: [
          themePreferenceStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(themeControllerProvider), AppThemeMode.dark);

      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(container.read(themeControllerProvider), AppThemeMode.light);
    });

    test('persists a changed theme mode', () async {
      final store = InMemoryThemePreferenceStore();
      final container = ProviderContainer(
        overrides: [
          themePreferenceStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(themeControllerProvider.notifier)
          .setThemeMode(AppThemeMode.light);

      expect(container.read(themeControllerProvider), AppThemeMode.light);
      expect(store.savedMode, AppThemeMode.light);
    });
  });
}

class InMemoryThemePreferenceStore implements ThemePreferenceStore {
  InMemoryThemePreferenceStore({this.initialMode});

  final AppThemeMode? initialMode;
  AppThemeMode? savedMode;

  @override
  Future<AppThemeMode?> readThemeMode() async {
    return savedMode ?? initialMode;
  }

  @override
  Future<void> writeThemeMode(AppThemeMode mode) async {
    savedMode = mode;
  }
}

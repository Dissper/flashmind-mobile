import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:flashmind_mobile/core/theme/app_theme.dart';
import 'package:flashmind_mobile/core/theme/app_theme_mode.dart';
import 'package:flashmind_mobile/core/theme/theme_controller.dart';
import 'package:flashmind_mobile/core/theme/theme_preference_store.dart';

void main() {
  testWidgets(
    'MaterialApp.router updates theme mode and navigation keeps working',
    (tester) async {
      final store = _MemoryThemePreferenceStore();

      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Consumer(
              builder: (context, ref, child) {
                return Scaffold(
                  body: Column(
                    children: [
                      const Text('Home route'),
                      FilledButton(
                        onPressed: () => ref
                            .read(themeControllerProvider.notifier)
                            .setThemeMode(AppThemeMode.light),
                        child: const Text('Switch theme'),
                      ),
                      FilledButton(
                        onPressed: () => context.go('/settings'),
                        child: const Text('Open settings'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Settings route')),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            themePreferenceStoreProvider.overrideWithValue(store),
          ],
          child: Consumer(
            builder: (context, ref, child) {
              return MaterialApp.router(
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: ref.watch(themeControllerProvider).materialMode,
                routerConfig: router,
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home route'), findsOneWidget);
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark,
      );

      await tester.tap(find.text('Switch theme'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.light,
      );

      await tester.tap(find.text('Open settings'));
      await tester.pumpAndSettle();

      expect(find.text('Settings route'), findsOneWidget);
    },
  );
}

class _MemoryThemePreferenceStore implements ThemePreferenceStore {
  AppThemeMode? savedMode;

  @override
  Future<AppThemeMode?> readThemeMode() async => savedMode;

  @override
  Future<void> writeThemeMode(AppThemeMode mode) async {
    savedMode = mode;
  }
}

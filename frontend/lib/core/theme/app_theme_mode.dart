import 'package:flutter/material.dart';

enum AppThemeMode {
  dark,
  light,
  system,
}

extension AppThemeModeX on AppThemeMode {
  ThemeMode get materialMode {
    switch (this) {
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  String get storageValue {
    switch (this) {
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.system:
        return 'system';
    }
  }

  String get label {
    switch (this) {
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.system:
        return 'System';
    }
  }

  static AppThemeMode fromStorage(String? value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'system':
        return AppThemeMode.system;
      case 'dark':
      default:
        return AppThemeMode.dark;
    }
  }
}

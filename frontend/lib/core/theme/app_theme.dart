import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme_tokens.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return _buildTheme(
      brightness: Brightness.light,
      seedColor: const Color(0xFF6E63F6),
      tokens: AppThemeTokens.light,
    );
  }

  static ThemeData dark() {
    return _buildTheme(
      brightness: Brightness.dark,
      seedColor: const Color(0xFF8A80FF),
      tokens: AppThemeTokens.dark,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color seedColor,
    required AppThemeTokens tokens,
  }) {
    final baseColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    final colorScheme = baseColorScheme.copyWith(
      primary: brightness == Brightness.dark
          ? const Color(0xFF9087FF)
          : const Color(0xFF685DF0),
      onPrimary: Colors.white,
      secondary: brightness == Brightness.dark
          ? const Color(0xFF86A4FF)
          : const Color(0xFF5878DD),
      onSecondary: Colors.white,
      tertiary: brightness == Brightness.dark
          ? const Color(0xFF90D1FF)
          : const Color(0xFF4B9AD8),
      onTertiary: Colors.white,
      primaryContainer: brightness == Brightness.dark
          ? const Color(0xFF27244A)
          : const Color(0xFFE6E3FF),
      onPrimaryContainer: brightness == Brightness.dark
          ? const Color(0xFFE0DDFF)
          : const Color(0xFF221F49),
      secondaryContainer: brightness == Brightness.dark
          ? const Color(0xFF1D2943)
          : const Color(0xFFE3ECFF),
      onSecondaryContainer: brightness == Brightness.dark
          ? const Color(0xFFDCE7FF)
          : const Color(0xFF1C305C),
      surface: tokens.surfacePrimary,
      onSurface: brightness == Brightness.dark
          ? const Color(0xFFF4F6FF)
          : const Color(0xFF171D2E),
      error: tokens.errorStrong,
      onError: Colors.white,
      errorContainer: tokens.errorSoft,
      onErrorContainer: brightness == Brightness.dark
          ? const Color(0xFFFFD9E0)
          : const Color(0xFF5B2030),
      outline: tokens.borderStrong,
      outlineVariant: tokens.borderSubtle,
      shadow: Colors.black,
      scrim: Colors.black87,
      surfaceTint: Colors.transparent,
    );

    final baseTextTheme = GoogleFonts.robotoTextTheme(
      brightness == Brightness.dark
          ? ThemeData.dark(useMaterial3: true).textTheme
          : ThemeData.light(useMaterial3: true).textTheme,
    );

    final textTheme = baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.1,
        height: 1.02,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.08,
      ),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        height: 1.45,
        color: colorScheme.onSurface,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        height: 1.5,
        color: colorScheme.onSurface,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        height: 1.45,
        color: tokens.textMuted,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      labelMedium: baseTextTheme.labelMedium?.copyWith(
        color: tokens.textMuted,
        fontWeight: FontWeight.w500,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: tokens.backgroundBase,
      canvasColor: tokens.backgroundBase,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarThemeData(
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: tokens.surfacePrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(
          alpha: brightness == Brightness.dark ? 0.30 : 0.10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: tokens.borderSubtle),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: tokens.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        iconColor: colorScheme.primary,
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: tokens.surfaceSecondary,
        hintStyle: TextStyle(color: tokens.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: tokens.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(color: tokens.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1.3,
          ),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primaryContainer;
            }
            return tokens.surfaceSecondary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimaryContainer;
            }
            return tokens.textSoft;
          }),
          side: WidgetStateProperty.all(
            BorderSide(color: tokens.borderSubtle),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          foregroundColor: Colors.white,
          backgroundColor: colorScheme.primary,
          disabledBackgroundColor: tokens.surfaceHighlight,
          disabledForegroundColor: tokens.textMuted,
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return 0;
            }
            return brightness == Brightness.dark ? 2 : 1;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: tokens.borderStrong),
          backgroundColor: tokens.surfaceSecondary,
          textStyle: textTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: tokens.surfaceHighlight,
        thumbColor: Colors.white,
        overlayColor: colorScheme.primary.withValues(alpha: 0.12),
        valueIndicatorColor: colorScheme.primary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: tokens.surfaceHighlight,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: tokens.surfaceSecondary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          side: BorderSide(color: tokens.borderSubtle),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.surfaceSecondary,
        side: BorderSide(color: tokens.borderSubtle),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return brightness == Brightness.dark
              ? tokens.surfaceHighlight
              : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return tokens.surfaceHighlight;
        }),
      ),
      extensions: [tokens],
    );
  }
}

import 'package:flutter/material.dart';

@immutable
class AppThemeTokens extends ThemeExtension<AppThemeTokens> {
  const AppThemeTokens({
    required this.scaffoldGradient,
    required this.heroGradient,
    required this.primaryAccentGradient,
    required this.backgroundBase,
    required this.backgroundElevated,
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceHighlight,
    required this.borderSubtle,
    required this.borderStrong,
    required this.textMuted,
    required this.textSoft,
    required this.glowColor,
    required this.successSoft,
    required this.successStrong,
    required this.warningSoft,
    required this.warningStrong,
    required this.errorSoft,
    required this.errorStrong,
    required this.infoSoft,
    required this.infoStrong,
    required this.destructiveSoft,
    required this.destructiveStrong,
  });

  final LinearGradient scaffoldGradient;
  final LinearGradient heroGradient;
  final LinearGradient primaryAccentGradient;
  final Color backgroundBase;
  final Color backgroundElevated;
  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color surfaceHighlight;
  final Color borderSubtle;
  final Color borderStrong;
  final Color textMuted;
  final Color textSoft;
  final Color glowColor;
  final Color successSoft;
  final Color successStrong;
  final Color warningSoft;
  final Color warningStrong;
  final Color errorSoft;
  final Color errorStrong;
  final Color infoSoft;
  final Color infoStrong;
  final Color destructiveSoft;
  final Color destructiveStrong;

  static const AppThemeTokens dark = AppThemeTokens(
    scaffoldGradient: LinearGradient(
      colors: [
        Color(0xFF0A0D18),
        Color(0xFF111527),
        Color(0xFF171B31),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    heroGradient: LinearGradient(
      colors: [
        Color(0xFF25213D),
        Color(0xFF1B2A49),
        Color(0xFF171F37),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryAccentGradient: LinearGradient(
      colors: [
        Color(0xFF8C7CFF),
        Color(0xFF6678F6),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundBase: Color(0xFF0B0E19),
    backgroundElevated: Color(0xFF121726),
    surfacePrimary: Color(0xFF151A2A),
    surfaceSecondary: Color(0xFF1B2134),
    surfaceHighlight: Color(0xFF232A43),
    borderSubtle: Color(0xFF2A3147),
    borderStrong: Color(0xFF414A66),
    textMuted: Color(0xFF98A1BE),
    textSoft: Color(0xFFC7CEE5),
    glowColor: Color(0xFF716AF7),
    successSoft: Color(0xFF18362D),
    successStrong: Color(0xFF72D7A2),
    warningSoft: Color(0xFF3D3118),
    warningStrong: Color(0xFFF1CB6D),
    errorSoft: Color(0xFF3B2229),
    errorStrong: Color(0xFFFF8C98),
    infoSoft: Color(0xFF1C2945),
    infoStrong: Color(0xFF90B4FF),
    destructiveSoft: Color(0xFF40242D),
    destructiveStrong: Color(0xFFFF8598),
  );

  static const AppThemeTokens light = AppThemeTokens(
    scaffoldGradient: LinearGradient(
      colors: [
        Color(0xFFF6F7FC),
        Color(0xFFF0F3FB),
        Color(0xFFECEFFD),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    heroGradient: LinearGradient(
      colors: [
        Color(0xFFE8E6FF),
        Color(0xFFE4EEFF),
        Color(0xFFF3F5FF),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    primaryAccentGradient: LinearGradient(
      colors: [
        Color(0xFF6E63F6),
        Color(0xFF5377EB),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    backgroundBase: Color(0xFFF4F6FC),
    backgroundElevated: Color(0xFFFFFFFF),
    surfacePrimary: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF5F7FD),
    surfaceHighlight: Color(0xFFEEF2FF),
    borderSubtle: Color(0xFFDCE2F2),
    borderStrong: Color(0xFFB9C3DD),
    textMuted: Color(0xFF5E6786),
    textSoft: Color(0xFF434B66),
    glowColor: Color(0xFF7A72F8),
    successSoft: Color(0xFFDFF4EA),
    successStrong: Color(0xFF1A8B5A),
    warningSoft: Color(0xFFFFF2D4),
    warningStrong: Color(0xFFAD7A00),
    errorSoft: Color(0xFFFFE1E7),
    errorStrong: Color(0xFFD4506D),
    infoSoft: Color(0xFFE1EBFF),
    infoStrong: Color(0xFF3F67D8),
    destructiveSoft: Color(0xFFFFE3E8),
    destructiveStrong: Color(0xFFD6556F),
  );

  @override
  AppThemeTokens copyWith({
    LinearGradient? scaffoldGradient,
    LinearGradient? heroGradient,
    LinearGradient? primaryAccentGradient,
    Color? backgroundBase,
    Color? backgroundElevated,
    Color? surfacePrimary,
    Color? surfaceSecondary,
    Color? surfaceHighlight,
    Color? borderSubtle,
    Color? borderStrong,
    Color? textMuted,
    Color? textSoft,
    Color? glowColor,
    Color? successSoft,
    Color? successStrong,
    Color? warningSoft,
    Color? warningStrong,
    Color? errorSoft,
    Color? errorStrong,
    Color? infoSoft,
    Color? infoStrong,
    Color? destructiveSoft,
    Color? destructiveStrong,
  }) {
    return AppThemeTokens(
      scaffoldGradient: scaffoldGradient ?? this.scaffoldGradient,
      heroGradient: heroGradient ?? this.heroGradient,
      primaryAccentGradient:
          primaryAccentGradient ?? this.primaryAccentGradient,
      backgroundBase: backgroundBase ?? this.backgroundBase,
      backgroundElevated: backgroundElevated ?? this.backgroundElevated,
      surfacePrimary: surfacePrimary ?? this.surfacePrimary,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceHighlight: surfaceHighlight ?? this.surfaceHighlight,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      textMuted: textMuted ?? this.textMuted,
      textSoft: textSoft ?? this.textSoft,
      glowColor: glowColor ?? this.glowColor,
      successSoft: successSoft ?? this.successSoft,
      successStrong: successStrong ?? this.successStrong,
      warningSoft: warningSoft ?? this.warningSoft,
      warningStrong: warningStrong ?? this.warningStrong,
      errorSoft: errorSoft ?? this.errorSoft,
      errorStrong: errorStrong ?? this.errorStrong,
      infoSoft: infoSoft ?? this.infoSoft,
      infoStrong: infoStrong ?? this.infoStrong,
      destructiveSoft: destructiveSoft ?? this.destructiveSoft,
      destructiveStrong: destructiveStrong ?? this.destructiveStrong,
    );
  }

  @override
  AppThemeTokens lerp(ThemeExtension<AppThemeTokens>? other, double t) {
    if (other is! AppThemeTokens) {
      return this;
    }

    return AppThemeTokens(
      scaffoldGradient:
          LinearGradient.lerp(scaffoldGradient, other.scaffoldGradient, t)!,
      heroGradient: LinearGradient.lerp(heroGradient, other.heroGradient, t)!,
      primaryAccentGradient: LinearGradient.lerp(
        primaryAccentGradient,
        other.primaryAccentGradient,
        t,
      )!,
      backgroundBase: Color.lerp(backgroundBase, other.backgroundBase, t)!,
      backgroundElevated:
          Color.lerp(backgroundElevated, other.backgroundElevated, t)!,
      surfacePrimary: Color.lerp(surfacePrimary, other.surfacePrimary, t)!,
      surfaceSecondary:
          Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      surfaceHighlight:
          Color.lerp(surfaceHighlight, other.surfaceHighlight, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textSoft: Color.lerp(textSoft, other.textSoft, t)!,
      glowColor: Color.lerp(glowColor, other.glowColor, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      successStrong: Color.lerp(successStrong, other.successStrong, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      warningStrong: Color.lerp(warningStrong, other.warningStrong, t)!,
      errorSoft: Color.lerp(errorSoft, other.errorSoft, t)!,
      errorStrong: Color.lerp(errorStrong, other.errorStrong, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
      infoStrong: Color.lerp(infoStrong, other.infoStrong, t)!,
      destructiveSoft:
          Color.lerp(destructiveSoft, other.destructiveSoft, t)!,
      destructiveStrong:
          Color.lerp(destructiveStrong, other.destructiveStrong, t)!,
    );
  }
}

class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}

class AppRadii {
  const AppRadii._();

  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 30;
  static const double pill = 999;
}

class AppDurations {
  const AppDurations._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 420);
}

extension AppThemeContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  AppThemeTokens get tokens => theme.extension<AppThemeTokens>()!;
}

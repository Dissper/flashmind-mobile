import 'package:flutter/material.dart';

import '../../core/theme/app_theme_tokens.dart';
import 'app_pill.dart';
import 'app_surface_card.dart';

class AppHeroPanel extends StatelessWidget {
  const AppHeroPanel({
    required this.title,
    required this.description,
    this.eyebrow,
    this.trailing,
    this.footer,
    this.pills = const [],
    super.key,
  });

  final String title;
  final String description;
  final String? eyebrow;
  final Widget? trailing;
  final Widget? footer;
  final List<AppPill> pills;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final tokens = context.tokens;

    return AppSurfaceCard(
      gradient: tokens.heroGradient,
      borderColor: tokens.borderStrong.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(AppRadii.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  Text(
                    eyebrow!,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: tokens.textSoft,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: tokens.textSoft,
                      ),
                ),
                if (pills.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: pills,
                  ),
                ],
                if (footer != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  footer!,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.md),
            Flexible(child: trailing!),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_theme_tokens.dart';

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.onTap,
    this.gradient,
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppRadii.lg),
    ),
    this.borderColor,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? backgroundColor;
  final BorderRadius borderRadius;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final brightness = Theme.of(context).brightness;

    final content = Padding(
      padding: padding,
      child: child,
    );

    return AnimatedContainer(
      duration: AppDurations.medium,
      decoration: BoxDecoration(
        color: gradient == null
            ? (backgroundColor ?? tokens.surfacePrimary)
            : backgroundColor,
        gradient: gradient,
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor ?? tokens.borderSubtle,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: brightness == Brightness.dark ? 0.24 : 0.08,
            ),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: onTap == null
            ? content
            : InkWell(
                borderRadius: borderRadius,
                onTap: onTap,
                child: content,
              ),
      ),
    );
  }
}

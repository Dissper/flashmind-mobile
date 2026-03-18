import 'package:flutter/material.dart';

import '../../core/theme/app_theme_tokens.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.child,
    this.title,
    this.actions,
    super.key,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              actions: actions,
            ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: tokens.scaffoldGradient,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: _AmbientGlow(
                color: tokens.glowColor.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.18
                      : 0.10,
                ),
              ),
            ),
            Positioned(
              bottom: -110,
              left: -70,
              child: _AmbientGlow(
                color: context.colorScheme.secondary.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.12
                      : 0.07,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 120,
              spreadRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}

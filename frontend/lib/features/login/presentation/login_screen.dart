import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme_tokens.dart';
import '../../../shared/widgets/app_animated_reveal.dart';
import '../../../shared/widgets/app_hero_panel.dart';
import '../../../shared/widgets/app_pill.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../../../shared/widgets/primary_action_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      final message = next.errorMessage;
      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    return AppShell(
      child: ListView(
        children: [
          const SizedBox(height: AppSpacing.sm),
          AppAnimatedReveal(
            child: AppHeroPanel(
              eyebrow: 'FlashMind for students',
              title: 'Turn lecture notes into calm, focused study sessions.',
              description:
                  'Upload one document, choose a flashcard style, and move from messy material to a polished deck in minutes.',
              pills: const [
                AppPill(
                  label: 'Minimal study flow',
                  icon: Icons.auto_awesome_rounded,
                ),
                AppPill(
                  label: 'PDF, DOCX, PPTX',
                  icon: Icons.description_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppAnimatedReveal(
            delay: const Duration(milliseconds: 100),
            child: AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sign in',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Keep your decks, subscription status, and study sessions synced across devices.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryActionButton(
                    label: 'Continue with Google',
                    icon: Icons.login_rounded,
                    isLoading: authState.isLoading,
                    onPressed: () => ref
                        .read(authControllerProvider.notifier)
                        .loginWithGoogle(),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: authState.isLoading ||
                            !ref
                                .read(authControllerProvider.notifier)
                                .appleSignInSupported
                        ? null
                        : () => ref
                            .read(authControllerProvider.notifier)
                            .loginWithApple(),
                    icon: const Icon(Icons.apple_rounded),
                    label: Text(
                      ref
                              .read(authControllerProvider.notifier)
                              .appleSignInSupported
                          ? 'Continue with Apple'
                          : 'Apple Sign In unavailable',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Apple Sign In is platform-specific. Configure iOS capabilities and identifiers before production release.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.tokens.textMuted,
                        ),
                  ),
                  if (AppConfig.allowLoginBypass) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Divider(color: context.tokens.borderSubtle),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: authState.isLoading
                          ? null
                          : () => ref
                              .read(authControllerProvider.notifier)
                              .continueWithoutLogin(),
                      icon: const Icon(Icons.bolt_rounded),
                      label: const Text('Entrar sin login'),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppConfig.useMockBackend
                          ? 'Solo para desarrollo. Usa datos mock en memoria y no necesita backend.'
                          : 'Solo para desarrollo. Requiere que el backend tenga habilitado flashmind.auth.allow-dev-login-bypass.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

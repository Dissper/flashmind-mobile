import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/config/app_config.dart';
import '../../../shared/widgets/app_shell.dart';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.84),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flashcards from docs, without the mess.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'Upload one document, pick a mode, and get a study deck in around two minutes or less.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                PrimaryActionButton(
                  label: 'Continue with Google',
                  icon: Icons.login_rounded,
                  onPressed: authState.isLoading
                      ? null
                      : () => ref.read(authControllerProvider.notifier).loginWithGoogle(),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: authState.isLoading || !ref.read(authControllerProvider.notifier).appleSignInSupported
                      ? null
                      : () => ref.read(authControllerProvider.notifier).loginWithApple(),
                  icon: const Icon(Icons.apple_rounded),
                  label: Text(
                    ref.read(authControllerProvider.notifier).appleSignInSupported
                        ? 'Continue with Apple'
                        : 'Apple Sign In unavailable',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Apple Sign In is platform-specific. Configure iOS capabilities and identifiers before production release.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (AppConfig.allowLoginBypass) ...[
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: authState.isLoading
                        ? null
                        : () => ref.read(authControllerProvider.notifier).continueWithoutLogin(),
                    icon: const Icon(Icons.bolt_rounded),
                    label: const Text('Entrar sin login'),
                  ),
                  const SizedBox(height: 8),
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
          const Spacer(),
        ],
      ),
    );
  }
}

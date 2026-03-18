import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/subscription/subscription_controller.dart';
import '../../../core/theme/app_theme_mode.dart';
import '../../../core/theme/app_theme_tokens.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../shared/widgets/app_animated_reveal.dart';
import '../../../shared/widgets/app_hero_panel.dart';
import '../../../shared/widgets/app_pill.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/app_settings_tile.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../data/user_profile_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(settingsUserProfileProvider);
    final subscriptionState = ref.watch(subscriptionControllerProvider);
    final themeMode = ref.watch(themeControllerProvider);
    final visibleThemeMode =
        themeMode == AppThemeMode.system ? AppThemeMode.dark : themeMode;
    final profile = userProfile.valueOrNull;

    ref.listen(subscriptionControllerProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage &&
          next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
      if (next.infoMessage != null &&
          next.infoMessage != previous?.infoMessage &&
          next.infoMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.infoMessage!)),
        );
      }
    });

    return AppShell(
      title: 'Settings',
      child: Scrollbar(
        thumbVisibility: _desktopScrollbarVisible,
        child: ListView(
          children: [
            AppAnimatedReveal(
              child: AppHeroPanel(
                eyebrow: 'Workspace',
                title:
                    profile?.displayName ?? 'Keep FlashMind tuned to your study flow.',
                description: profile == null
                    ? 'Your account, subscription, and app appearance all live here in one calm, focused place.'
                    : '${profile.email}\nAdjust the app theme, review your account details, and manage your study workspace.',
                pills: [
                  AppPill(
                    icon: Icons.palette_outlined,
                    label: '${visibleThemeMode.label} theme',
                  ),
                  AppPill(
                    icon: subscriptionState.isSubscribed
                        ? Icons.workspace_premium_rounded
                        : Icons.timelapse_rounded,
                    label:
                        subscriptionState.isSubscribed ? 'Premium' : 'Free plan',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppAnimatedReveal(
              delay: const Duration(milliseconds: 70),
              child: AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionHeader(
                      title: 'Account',
                      subtitle:
                          'Review the identity and subscription details attached to this workspace.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    userProfile.when(
                      data: (profile) => Column(
                        children: [
                          _SettingsValue(
                            icon: Icons.person_outline_rounded,
                            label: 'Name',
                            value: profile.displayName,
                          ),
                          _SettingsValue(
                            icon: Icons.mail_outline_rounded,
                            label: 'Email',
                            value: profile.email,
                          ),
                          _SettingsValue(
                            icon: Icons.login_rounded,
                            label: 'Provider',
                            value: profile.provider,
                          ),
                          _SettingsValue(
                            icon: Icons.workspace_premium_outlined,
                            label: 'Subscription',
                            value: profile.isSubscribed ? 'Premium' : 'Free',
                          ),
                          _SettingsValue(
                            icon: Icons.event_available_rounded,
                            label: 'Expiration',
                            value: profile.subscriptionExpirationAt == null
                                ? 'Not available yet'
                                : profile.subscriptionExpirationAt!
                                    .toIso8601String(),
                          ),
                          _SettingsValue(
                            icon: Icons.auto_awesome_rounded,
                            label: 'Free generations left',
                            value:
                                '${profile.freeGenerationsRemaining}/${subscriptionState.freeGenerationLimit}',
                            isLast: true,
                          ),
                        ],
                      ),
                      loading: () => const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, stackTrace) => Text(
                        'Could not load profile: $error',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppAnimatedReveal(
              delay: const Duration(milliseconds: 120),
              child: AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionHeader(
                      title: 'Theme',
                      subtitle:
                          'Dark is the default target today, while light mode stays ready and functional.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // System mode stays supported in the state architecture for a future rollout.
                    SegmentedButton<AppThemeMode>(
                      segments: const [
                        ButtonSegment<AppThemeMode>(
                          value: AppThemeMode.dark,
                          icon: Icon(Icons.dark_mode_rounded),
                          label: Text('Dark'),
                        ),
                        ButtonSegment<AppThemeMode>(
                          value: AppThemeMode.light,
                          icon: Icon(Icons.light_mode_rounded),
                          label: Text('Light'),
                        ),
                      ],
                      selected: {visibleThemeMode},
                      onSelectionChanged: (selection) {
                        ref
                            .read(themeControllerProvider.notifier)
                            .setThemeMode(selection.first);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'System mode is already supported in the theme state and can be exposed here later without changing the architecture again.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppAnimatedReveal(
              delay: const Duration(milliseconds: 170),
              child: AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionHeader(
                      title: 'Actions',
                      subtitle:
                          'Keep restore available, and make logout visible without overpowering the rest of the screen.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppSettingsTile(
                      icon: Icons.restore_rounded,
                      title: 'Restore purchases',
                      subtitle:
                          'Sync your Premium access again if you already bought it.',
                      onTap: () async {
                        await ref
                            .read(subscriptionControllerProvider.notifier)
                            .restorePurchases();
                        await ref
                            .read(subscriptionControllerProvider.notifier)
                            .refreshProfile();
                        ref.invalidate(settingsUserProfileProvider);
                      },
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: context.tokens.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppSettingsTile(
                      icon: Icons.logout_rounded,
                      title: 'Cerrar Sesion',
                      subtitle: 'Sign out and return to the login flow.',
                      onTap: () =>
                          ref.read(authControllerProvider.notifier).logout(),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: context.tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _desktopScrollbarVisible {
    if (kIsWeb) {
      return true;
    }
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }
}

class _SettingsValue extends StatelessWidget {
  const _SettingsValue({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSettingsTile(
          icon: icon,
          title: label,
          trailing: SizedBox(
            width: 180,
            child: Align(
              alignment: Alignment.centerRight,
              child: SelectableText(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
            ),
          ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Divider(color: context.tokens.borderSubtle),
          ),
      ],
    );
  }
}

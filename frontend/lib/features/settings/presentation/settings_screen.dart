import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/subscription/subscription_controller.dart';
import '../../../shared/widgets/app_shell.dart';
import '../data/user_profile_repository.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(settingsUserProfileProvider);
    final subscriptionState = ref.watch(subscriptionControllerProvider);

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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This screen is intentionally minimal for now. The routing, data layer, and restore flow are in place for future settings work.',
                    ),
                    const SizedBox(height: 20),
                    userProfile.when(
                      data: (profile) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SettingsValue(
                            label: 'Email',
                            value: profile.email,
                          ),
                          _SettingsValue(
                            label: 'Provider',
                            value: profile.provider,
                          ),
                          _SettingsValue(
                            label: 'Subscription',
                            value: profile.isSubscribed ? 'Premium' : 'Free',
                          ),
                          _SettingsValue(
                            label: 'Expiration',
                            value: profile.subscriptionExpirationAt == null
                                ? 'Not available yet'
                                : profile.subscriptionExpirationAt!
                                    .toIso8601String(),
                          ),
                          _SettingsValue(
                            label: 'Free generations left',
                            value:
                                '${profile.freeGenerationsRemaining}/${subscriptionState.freeGenerationLimit}',
                          ),
                        ],
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) =>
                          Text('Could not load profile: $error'),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await ref
                            .read(subscriptionControllerProvider.notifier)
                            .restorePurchases();
                        await ref
                            .read(subscriptionControllerProvider.notifier)
                            .refreshProfile();
                        ref.invalidate(settingsUserProfileProvider);
                      },
                      icon: const Icon(Icons.restore_rounded),
                      label: const Text('Restore purchases'),
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
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 4),
          SelectableText(value),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/subscription/subscription_controller.dart';
import '../../../core/subscription/subscription_status.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/primary_action_button.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() =>
      _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>(() {
      ref.read(subscriptionControllerProvider.notifier).loadOfferings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionControllerProvider);
    final controller = ref.read(subscriptionControllerProvider.notifier);

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
      title: 'Go Premium',
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
                      'Unlock unlimited study decks',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subscriptionState.isSubscribed
                          ? 'Premium is active for this account.'
                          : 'Your free plan has ${subscriptionState.freeGenerationsRemaining} generations remaining.',
                    ),
                    const SizedBox(height: 20),
                    _PlanRow(
                      label: 'Free',
                      value:
                          '${subscriptionState.freeGenerationLimit} total generations, up to 10 cards',
                    ),
                    const SizedBox(height: 10),
                    const _PlanRow(
                      label: 'Premium',
                      value: 'Unlimited generations, up to 20 cards',
                    ),
                    const SizedBox(height: 24),
                    if (subscriptionState.monthlyProduct != null) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .secondaryContainer,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscriptionState.monthlyProduct!.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(subscriptionState.monthlyProduct!.description),
                            const SizedBox(height: 12),
                            Text(
                              subscriptionState.monthlyProduct!.priceLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),
                    ] else if (subscriptionState.isLoadingOfferings) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ] else ...[
                      Text(
                        'No RevenueCat monthly offering is available yet.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 24),
                    PrimaryActionButton(
                      label: subscriptionState.subscriptionStatus ==
                              SubscriptionStatus.purchasing
                          ? 'Processing purchase...'
                          : 'Subscribe monthly',
                      icon: Icons.workspace_premium_rounded,
                      onPressed: subscriptionState.isProcessingPurchase
                          ? null
                          : () async {
                              final unlocked =
                                  await controller.purchaseMonthly();
                              if (!context.mounted) {
                                return;
                              }
                              if (unlocked) {
                                context.go('/generate');
                              }
                            },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: subscriptionState.isProcessingPurchase
                          ? null
                          : () async {
                              final restored =
                                  await controller.restorePurchases();
                              if (!context.mounted) {
                                return;
                              }
                              if (restored) {
                                context.go('/generate');
                              }
                            },
                      icon: const Icon(Icons.restore_rounded),
                      label: const Text('Restore purchases'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'RevenueCat entitlement: premium\nStore product: configure PRODUCT_ID before release.',
                      style: Theme.of(context).textTheme.bodySmall,
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

class _PlanRow extends StatelessWidget {
  const _PlanRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}

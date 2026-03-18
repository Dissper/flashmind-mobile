import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/subscription/subscription_controller.dart';
import '../../../core/subscription/subscription_status.dart';
import '../../../core/theme/app_theme_tokens.dart';
import '../../../shared/widgets/app_animated_reveal.dart';
import '../../../shared/widgets/app_hero_panel.dart';
import '../../../shared/widgets/app_pill.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_surface_card.dart';
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
            AppAnimatedReveal(
              child: AppHeroPanel(
                eyebrow: 'Premium plan',
                title: 'Unlock a more generous and focused study workflow.',
                description:
                    subscriptionState.isSubscribed
                        ? 'Premium is already active on this account. You can keep generating decks without the free-plan limits.'
                        : 'FlashMind Premium keeps your momentum going with unlimited deck generation and room for larger study sets.',
                pills: [
                  AppPill(
                    icon: Icons.auto_awesome_rounded,
                    label: subscriptionState.isSubscribed
                        ? 'Premium active'
                        : '${subscriptionState.freeGenerationsRemaining} free generations left',
                  ),
                  const AppPill(
                    icon: Icons.workspace_premium_rounded,
                    label: 'Unlimited generations',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppAnimatedReveal(
              delay: const Duration(milliseconds: 80),
              child: AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionHeader(
                      title: 'Why students upgrade',
                      subtitle:
                          'More generations, larger decks, and less friction when you are studying on a deadline.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _BenefitRow(
                      icon: Icons.all_inclusive_rounded,
                      title: 'Unlimited deck generations',
                      description:
                          'Keep iterating on class notes, readings, and slide decks without hitting a free cap.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _BenefitRow(
                      icon: Icons.layers_rounded,
                      title: 'Bigger study sessions',
                      description:
                          'Premium supports up to 20 cards per generation for broader topic coverage.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _BenefitRow(
                      icon: Icons.timer_outlined,
                      title: 'Smoother exam-week flow',
                      description:
                          'Generate, review, and revisit decks without breaking concentration.',
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _PlanComparison(
                      freeGenerations: subscriptionState.freeGenerationLimit,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppAnimatedReveal(
              delay: const Duration(milliseconds: 140),
              child: AppSurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppSectionHeader(
                      title: 'Monthly plan',
                      subtitle:
                          'One clear subscription option with restore available below.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (subscriptionState.monthlyProduct != null) ...[
                      AppSurfaceCard(
                        backgroundColor: context.tokens.surfaceSecondary,
                        borderColor: context.tokens.borderStrong,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const AppPill(
                                  label: 'Most focused option',
                                  icon: Icons.star_rounded,
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.workspace_premium_rounded,
                                  color: context.colorScheme.primary,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              subscriptionState.monthlyProduct!.title,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(subscriptionState.monthlyProduct!.description),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              subscriptionState.monthlyProduct!.priceLabel,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      )
                    ] else if (subscriptionState.isLoadingOfferings) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ] else ...[
                      Text(
                        'No RevenueCat monthly offering is available yet.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    PrimaryActionButton(
                      label: subscriptionState.subscriptionStatus ==
                              SubscriptionStatus.purchasing
                          ? 'Processing purchase...'
                          : 'Subscribe monthly',
                      icon: Icons.workspace_premium_rounded,
                      isLoading: subscriptionState.isProcessingPurchase,
                      onPressed: () async {
                        final unlocked = await controller.purchaseMonthly();
                        if (!context.mounted) {
                          return;
                        }
                        if (unlocked) {
                          context.go('/generate');
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
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
                    const SizedBox(height: AppSpacing.md),
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
          width: 86,
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

class _PlanComparison extends StatelessWidget {
  const _PlanComparison({required this.freeGenerations});

  final int freeGenerations;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PlanRow(
          label: 'Free',
          value: '$freeGenerations total generations, up to 10 cards',
        ),
        const SizedBox(height: AppSpacing.sm),
        const _PlanRow(
          label: 'Premium',
          value: 'Unlimited generations, up to 20 cards',
        ),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: context.tokens.surfaceHighlight,
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Icon(
            icon,
            color: context.colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

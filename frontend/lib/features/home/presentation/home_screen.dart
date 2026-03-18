import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/subscription/subscription_controller.dart';
import '../../../core/theme/app_theme_tokens.dart';
import '../../../shared/widgets/app_animated_reveal.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_hero_panel.dart';
import '../../../shared/widgets/app_pill.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../../../shared/widgets/deck_list_tile.dart';
import '../../../shared/widgets/primary_action_button.dart';
import '../../../shared/models/deck_summary.dart';
import '../data/deck_repository.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Set<int> _hiddenDeckIds = <int>{};

  Future<bool> _confirmDeleteDeck(DeckSummary deck) async {
    try {
      await ref.read(deckRepositoryProvider).deleteDeck(deck.id);
      if (!mounted) {
        return false;
      }

      return true;
    } catch (error) {
      if (!mounted) {
        return false;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete ${deck.title}: $error')),
      );
      return false;
    }
  }

  void _handleDeckDeleted(DeckSummary deck) {
    setState(() {
      _hiddenDeckIds.add(deck.id);
    });
    ref.invalidate(decksProvider);
    ref.invalidate(deckDetailProvider(deck.id));
    ref.invalidate(deckFlashcardsProvider(deck.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${deck.title} deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final decks = ref.watch(decksProvider);
    final subscriptionState = ref.watch(subscriptionControllerProvider);

    ref.listen(subscriptionControllerProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage &&
          next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
    });

    return AppShell(
      title: 'FlashMind',
      actions: [
        IconButton(
          tooltip: 'Settings',
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () async => ref.refresh(decksProvider.future),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            AppAnimatedReveal(
              child: AppHeroPanel(
                eyebrow: 'Welcome back',
                title:
                    'Ready to turn your next study document into a polished deck?',
                description:
                    'Hi ${authState.user?.displayName ?? 'student'}, keep your flow steady with fast generation, clean review sessions, and a workspace that stays focused.',
                pills: [
                  AppPill(
                    icon: subscriptionState.isSubscribed
                        ? Icons.workspace_premium_rounded
                        : Icons.timelapse_rounded,
                    label: subscriptionState.isSubscribed
                        ? 'Premium active'
                        : '${subscriptionState.freeGenerationsRemaining}/${subscriptionState.freeGenerationLimit} free generations left',
                  ),
                  AppPill(
                    icon: Icons.style_rounded,
                    label: 'Up to ${subscriptionState.maxCardsAllowed} cards',
                  ),
                ],
                footer: PrimaryActionButton(
                  label: 'Generate Flashcards',
                  icon: Icons.auto_awesome_rounded,
                  onPressed: () async {
                    final canGenerate = await ref
                        .read(subscriptionControllerProvider.notifier)
                        .checkGenerationAccess();
                    if (!context.mounted || canGenerate == null) {
                      return;
                    }
                    context.push(canGenerate ? '/generate' : '/subscribe');
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader(
              title: 'Your decks',
              subtitle:
                  'Jump back into recent study sessions or clean up old material with a swipe.',
            ),
            const SizedBox(height: AppSpacing.md),
            decks.when(
              data: (items) {
                final visibleItems = items
                    .where((deck) => !_hiddenDeckIds.contains(deck.id))
                    .toList(growable: false);

                if (visibleItems.isEmpty) {
                  return const AppEmptyState(
                    title: 'No decks yet',
                    description:
                        'Upload a class document and FlashMind will shape it into your first clean, review-ready deck.',
                    icon: Icons.library_add_check_rounded,
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var index = 0; index < visibleItems.length; index++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: DeckListTile(
                          deck: visibleItems[index],
                          onTap: () =>
                              context.push('/study/${visibleItems[index].id}'),
                          onDelete: () => _confirmDeleteDeck(visibleItems[index]),
                          onDeleteDismissed: () =>
                              _handleDeckDeleted(visibleItems[index]),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => AppSurfaceCard(
                child: Text('Could not load decks: $error'),
              ),
            ),
            if (!subscriptionState.isSubscribed) ...[
              const SizedBox(height: AppSpacing.sm),
              AppSurfaceCard(
                backgroundColor: context.tokens.surfaceSecondary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need more deck generations?',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Premium unlocks unlimited generations with a cleaner study rhythm.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: () => context.push('/subscribe'),
                      child: const Text('View plans'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

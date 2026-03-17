import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/subscription/subscription_controller.dart';
import '../../../shared/widgets/app_shell.dart';
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
        IconButton(
          tooltip: 'Logout',
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () async => ref.refresh(decksProvider.future),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF123F3A),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${authState.user?.displayName ?? 'student'}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    subscriptionState.isSubscribed
                        ? 'Premium active. Unlimited deck generations and up to ${subscriptionState.maxCardsAllowed} cards.'
                        : 'Free plan: ${subscriptionState.freeGenerationsRemaining} of ${subscriptionState.freeGenerationLimit} generations left, up to ${subscriptionState.maxCardsAllowed} cards.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  PrimaryActionButton(
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
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your decks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            decks.when(
              data: (items) {
                final visibleItems = items
                    .where((deck) => !_hiddenDeckIds.contains(deck.id))
                    .toList(growable: false);

                if (visibleItems.isEmpty) {
                  return const _EmptyDeckState();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: visibleItems
                      .map(
                        (deck) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DeckListTile(
                            deck: deck,
                            onTap: () => context.push('/study/${deck.id}'),
                            onDelete: () => _confirmDeleteDeck(deck),
                            onDeleteDismissed: () => _handleDeckDeleted(deck),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text('Could not load decks: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDeckState extends StatelessWidget {
  const _EmptyDeckState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No decks yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload a file and create your first flashcard deck.',
            ),
          ],
        ),
      ),
    );
  }
}

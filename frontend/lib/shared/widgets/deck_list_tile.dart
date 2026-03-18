import 'package:flutter/material.dart';

import '../../core/theme/app_theme_tokens.dart';
import '../../core/utils/formatters.dart';
import '../models/flashcard_mode.dart';
import '../models/deck_summary.dart';
import 'app_pill.dart';
import 'app_surface_card.dart';

class DeckListTile extends StatelessWidget {
  const DeckListTile({
    required this.deck,
    required this.onTap,
    this.onDelete,
    this.onDeleteDismissed,
    super.key,
  });

  final DeckSummary deck;
  final VoidCallback onTap;
  final Future<bool> Function()? onDelete;
  final VoidCallback? onDeleteDismissed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tile = Card(
      color: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      child: AppSurfaceCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(
                    deck.mode == FlashcardMode.flip
                        ? Icons.flip_to_front_rounded
                        : Icons.fact_check_rounded,
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deck.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Ready for a quick review session',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: context.tokens.textMuted,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _DeckTag(label: formatDeckDate(deck.createdAt)),
                _DeckTag(label: deck.mode.label),
                _DeckTag(label: '${deck.cardCount} cards'),
              ],
            ),
          ],
        ),
      ),
    );

    if (onDelete == null) {
      return tile;
    }

    return Dismissible(
      key: ValueKey('deck-${deck.id}'),
      direction: DismissDirection.endToStart,
      dismissThresholds: const {
        DismissDirection.endToStart: 0.32,
      },
      movementDuration: const Duration(milliseconds: 240),
      resizeDuration: const Duration(milliseconds: 180),
      confirmDismiss: (_) => onDelete!.call(),
      onDismissed: (_) => onDeleteDismissed?.call(),
      background: const SizedBox.shrink(),
      secondaryBackground: const _DeleteDeckBackground(),
      child: tile,
    );
  }
}

class _DeckTag extends StatelessWidget {
  const _DeckTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return AppPill(
      label: label,
    );
  }
}

class _DeleteDeckBackground extends StatelessWidget {
  const _DeleteDeckBackground();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tokens = context.tokens;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        gradient: LinearGradient(
          colors: [
            tokens.destructiveSoft,
            tokens.errorSoft,
            tokens.destructiveStrong.withValues(alpha: 0.85),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Delete',
                style: textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../models/deck_summary.dart';

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
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deck.title,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DeckTag(label: formatDeckDate(deck.createdAt)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DeckTag(label: deck.mode.label),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DeckTag(label: '${deck.cardCount} cards'),
                  ),
                ],
              ),
            ],
          ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.center,
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _DeleteDeckBackground extends StatelessWidget {
  const _DeleteDeckBackground();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFC9BF),
            Color(0xFFFF7A6B),
            Color(0xFFE53935),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(height: 4),
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

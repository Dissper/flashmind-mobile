import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';
import '../models/deck_summary.dart';

class DeckListTile extends StatelessWidget {
  const DeckListTile({
    required this.deck,
    required this.onTap,
    super.key,
  });

  final DeckSummary deck;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
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
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _DeckTag(label: formatDeckDate(deck.createdAt)),
                  _DeckTag(label: deck.mode.label),
                  _DeckTag(label: '${deck.cardCount} cards'),
                ],
              ),
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}

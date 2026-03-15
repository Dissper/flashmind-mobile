import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/flashcard_mode.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../home/data/deck_repository.dart';

class StudyScreen extends ConsumerStatefulWidget {
  const StudyScreen({required this.deckId, super.key});

  final int deckId;

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  int _currentIndex = 0;
  bool _showAnswer = false;
  int? _selectedOption;

  @override
  Widget build(BuildContext context) {
    final deck = ref.watch(deckDetailProvider(widget.deckId));
    final cards = ref.watch(deckFlashcardsProvider(widget.deckId));

    return AppShell(
      title: 'Study',
      child: deck.when(
        data: (deckData) => cards.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(child: Text('No flashcards found.'));
            }

            final currentCard = items[_currentIndex];
            final progress = '${_currentIndex + 1}/${items.length}';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deckData.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(progress),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / items.length,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: deckData.mode == FlashcardMode.flip
                          ? _FlipCardView(
                              question: currentCard.question,
                              answer: currentCard.answer ?? '',
                              showAnswer: _showAnswer,
                              onFlip: () {
                                setState(() {
                                  _showAnswer = !_showAnswer;
                                });
                              },
                            )
                          : _MultipleChoiceView(
                              question: currentCard.question,
                              options: currentCard.options,
                              correctOption: currentCard.correctOption ?? 0,
                              selectedOption: _selectedOption,
                              onSelect: (value) {
                                setState(() {
                                  _selectedOption = value;
                                });
                              },
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _canMoveNext(deckData.mode)
                      ? () => _goNext(items.length)
                      : null,
                  child: Text(
                    _currentIndex == items.length - 1 ? 'Finish' : 'Next',
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Failed to load cards: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Failed to load deck: $error')),
      ),
    );
  }

  bool _canMoveNext(FlashcardMode mode) {
    if (mode == FlashcardMode.flip) {
      return true;
    }
    return _selectedOption != null;
  }

  void _goNext(int totalCards) {
    if (_currentIndex == totalCards - 1) {
      context.go('/');
      return;
    }

    setState(() {
      _currentIndex++;
      _showAnswer = false;
      _selectedOption = null;
    });
  }
}

class _FlipCardView extends StatelessWidget {
  const _FlipCardView({
    required this.question,
    required this.answer,
    required this.showAnswer,
    required this.onFlip,
  });

  final String question;
  final String answer;
  final bool showAnswer;
  final VoidCallback onFlip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Text(question, style: Theme.of(context).textTheme.headlineSmall),
        const Spacer(),
        if (showAnswer) ...[
          Text('Answer', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(answer),
          const SizedBox(height: 20),
        ],
        OutlinedButton.icon(
          onPressed: onFlip,
          icon: const Icon(Icons.flip_rounded),
          label: Text(showAnswer ? 'Hide answer' : 'Flip'),
        ),
      ],
    );
  }
}

class _MultipleChoiceView extends StatelessWidget {
  const _MultipleChoiceView({
    required this.question,
    required this.options,
    required this.correctOption,
    required this.selectedOption,
    required this.onSelect,
  });

  final String question;
  final List<String> options;
  final int correctOption;
  final int? selectedOption;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Text(question, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final selected = selectedOption == index;
              final isCorrect = index == correctOption;
              final resolvedColor = selectedOption == null
                  ? null
                  : isCorrect
                      ? Colors.green.shade100
                      : selected
                          ? Colors.red.shade100
                          : null;

              return Material(
                color: resolvedColor,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: selectedOption == null ? () => onSelect(index) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(options[index]),
                  ),
                ),
              );
            },
          ),
        ),
        if (selectedOption != null) ...[
          const SizedBox(height: 12),
          Text(
            selectedOption == correctOption ? 'Correct' : 'Not quite',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ],
    );
  }
}

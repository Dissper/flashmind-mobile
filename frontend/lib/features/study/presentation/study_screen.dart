import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme_tokens.dart';
import '../../../shared/models/flashcard_mode.dart';
import '../../../shared/widgets/app_animated_reveal.dart';
import '../../../shared/widgets/app_pill.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../../../shared/widgets/primary_action_button.dart';
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
            final progressValue = (_currentIndex + 1) / items.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAnimatedReveal(
                  child: AppSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                deckData.title,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            AppPill(
                              label: deckData.mode.label,
                              icon: deckData.mode == FlashcardMode.flip
                                  ? Icons.flip_to_front_rounded
                                  : Icons.fact_check_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            AppPill(
                              label: 'Card ${_currentIndex + 1}/${items.length}',
                              icon: Icons.auto_stories_rounded,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            AppPill(
                              label: '${deckData.cardCount} total cards',
                              icon: Icons.layers_outlined,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        LinearProgressIndicator(value: progressValue),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: AppAnimatedReveal(
                    delay: const Duration(milliseconds: 70),
                    child: AppSurfaceCard(
                      child: AnimatedSwitcher(
                        duration: AppDurations.medium,
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: Padding(
                          key: ValueKey(
                            '${currentCard.id}-$_showAnswer-$_selectedOption',
                          ),
                          padding: EdgeInsets.zero,
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
                                  correctOption:
                                      currentCard.correctOption ?? 0,
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
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryActionButton(
                  onPressed: _canMoveNext(deckData.mode)
                      ? () => _goNext(items.length)
                      : null,
                  icon: _currentIndex == items.length - 1
                      ? Icons.check_circle_outline_rounded
                      : Icons.arrow_forward_rounded,
                  label: _currentIndex == items.length - 1 ? 'Finish' : 'Next',
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text('Failed to load cards: $error'),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Failed to load deck: $error'),
        ),
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
        const AppPill(
          label: 'Flip card',
          icon: Icons.style_rounded,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Question',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          question,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const Spacer(),
        AnimatedSwitcher(
          duration: AppDurations.medium,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: showAnswer
              ? Container(
                  key: const ValueKey('answer-visible'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: context.tokens.surfaceSecondary,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: context.tokens.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Answer',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        answer,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                )
              : Container(
                  key: const ValueKey('answer-hidden'),
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: context.tokens.surfaceSecondary,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: context.tokens.borderSubtle),
                  ),
                  child: Text(
                    'Reveal the answer when you are ready to self-check.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton.icon(
          onPressed: onFlip,
          icon: Icon(
            showAnswer ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          ),
          label: Text(showAnswer ? 'Hide answer' : 'Reveal answer'),
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
    final feedbackText = selectedOption == null
        ? null
        : selectedOption == correctOption
            ? 'Correct answer'
            : 'Not quite - review the highlighted answer';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppPill(
          label: 'Multiple choice',
          icon: Icons.fact_check_rounded,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Question',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          question,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: ListView.separated(
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final selected = selectedOption == index;
              final isCorrect = index == correctOption;

              final backgroundColor = selectedOption == null
                  ? context.tokens.surfaceSecondary
                  : isCorrect
                      ? context.tokens.successSoft
                      : selected
                          ? context.tokens.errorSoft
                          : context.tokens.surfaceSecondary;

              final borderColor = selectedOption == null
                  ? context.tokens.borderSubtle
                  : isCorrect
                      ? context.tokens.successStrong
                      : selected
                          ? context.tokens.errorStrong
                          : context.tokens.borderSubtle;

              final foregroundColor = selectedOption == null
                  ? context.colorScheme.onSurface
                  : isCorrect
                      ? context.tokens.successStrong
                      : selected
                          ? context.tokens.errorStrong
                          : context.colorScheme.onSurface;

              return AnimatedContainer(
                duration: AppDurations.fast,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(color: borderColor),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  onTap: selectedOption == null ? () => onSelect(index) : null,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: foregroundColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Text(
                            String.fromCharCode(65 + index),
                            style:
                                Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: foregroundColor,
                                    ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            options[index],
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: foregroundColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (feedbackText != null) ...[
          const SizedBox(height: AppSpacing.md),
          AppPill(
            label: feedbackText,
            icon: selectedOption == correctOption
                ? Icons.check_circle_outline_rounded
                : Icons.info_outline_rounded,
            backgroundColor: selectedOption == correctOption
                ? context.tokens.successSoft
                : context.tokens.warningSoft,
            foregroundColor: selectedOption == correctOption
                ? context.tokens.successStrong
                : context.tokens.warningStrong,
          ),
        ],
      ],
    );
  }
}

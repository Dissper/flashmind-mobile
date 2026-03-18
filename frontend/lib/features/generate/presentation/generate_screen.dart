import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/subscription/subscription_controller.dart';
import '../../../core/theme/app_theme_tokens.dart';
import '../../../shared/models/flashcard_mode.dart';
import '../../../shared/widgets/app_animated_reveal.dart';
import '../../../shared/widgets/app_hero_panel.dart';
import '../../../shared/widgets/app_pill.dart';
import '../../../shared/widgets/app_section_header.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_surface_card.dart';
import '../../../shared/widgets/primary_action_button.dart';
import 'generate_controller.dart';

class GenerateScreen extends ConsumerWidget {
  const GenerateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(generateControllerProvider);
    final controller = ref.read(generateControllerProvider.notifier);
    final subscriptionState = ref.watch(subscriptionControllerProvider);
    final maxCardsAllowed = subscriptionState.maxCardsAllowed < 4
        ? 4
        : subscriptionState.maxCardsAllowed;

    ref.listen<GenerateState>(generateControllerProvider, (previous, next) {
      final message = next.errorMessage;
      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    });

    return AppShell(
      title: 'Generate',
      child: ListView(
        children: [
          AppAnimatedReveal(
            child: AppHeroPanel(
              eyebrow: 'Build a new deck',
              title: 'Create review-ready flashcards from the material you already have.',
              description:
                  'Choose a file, pick the mode that fits your study session, and let FlashMind shape the deck for you.',
              pills: [
                AppPill(
                  icon: Icons.bolt_rounded,
                  label: subscriptionState.isSubscribed
                      ? 'Premium generation unlocked'
                      : '${subscriptionState.freeGenerationsRemaining} free runs left',
                ),
                AppPill(
                  icon: Icons.layers_outlined,
                  label: 'Limit: $maxCardsAllowed cards',
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
                    title: '1. Add a study document',
                    subtitle:
                        'Bring in the notes, slides, or reading material you want to turn into flashcards.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _UploadPanel(
                    fileName: state.selectedFile?.name,
                    fileSizeBytes: state.selectedFile?.size,
                    isLoading: state.isSubmitting,
                    onPressed: controller.pickDocument,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Supported files: ${AppConfig.supportedFileTypesLabel}\n'
                    'Max file size: ${AppConfig.maxFileSizeLabel}',
                    style: Theme.of(context).textTheme.bodySmall,
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
                    title: '2. Pick the study mode',
                    subtitle:
                        'Choose the interaction style that matches the kind of recall you want to practice.',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SegmentedButton<FlashcardMode>(
                    segments: const [
                      ButtonSegment(
                        value: FlashcardMode.flip,
                        label: Text('Flip card'),
                        icon: Icon(Icons.flip_rounded),
                      ),
                      ButtonSegment(
                        value: FlashcardMode.multipleChoice,
                        label: Text('Multiple choice'),
                        icon: Icon(Icons.fact_check_rounded),
                      ),
                    ],
                    selected: {state.mode},
                    onSelectionChanged: state.isSubmitting
                        ? null
                        : (selection) => controller.setMode(selection.first),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    state.mode == FlashcardMode.flip
                        ? 'Flip card mode is ideal for quick self-testing and short-answer recall.'
                        : 'Multiple choice mode is useful when you want guided practice with answer feedback.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppAnimatedReveal(
            delay: const Duration(milliseconds: 200),
            child: AppSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(
                    title: '3. Choose deck size',
                    subtitle:
                        'Balance speed and coverage with a card count that fits your current plan.',
                    trailing: AppPill(
                      label: '${state.cardCount} cards',
                      icon: Icons.tune_rounded,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Slider(
                    value: state.cardCount.toDouble(),
                    min: 4,
                    max: maxCardsAllowed.toDouble(),
                    divisions: maxCardsAllowed - 4,
                    label: state.cardCount.toString(),
                    onChanged: state.isSubmitting ? null : controller.setCardCount,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Current plan limit: $maxCardsAllowed cards',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: AppDurations.medium,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: state.progressMessage == null
                ? const SizedBox(height: AppSpacing.lg)
                : Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: AppSurfaceCard(
                      key: const ValueKey('generate-progress'),
                      backgroundColor: context.tokens.surfaceSecondary,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Generating your deck',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            state.progressMessage!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const LinearProgressIndicator(),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryActionButton(
            label: state.isSubmitting ? 'Generating...' : 'Generate study deck',
            icon: Icons.auto_awesome_rounded,
            isLoading: state.isSubmitting,
            onPressed: () async {
              final deck = await controller.generate();
              if (deck != null && context.mounted) {
                context.go('/study/${deck.id}');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _UploadPanel extends StatelessWidget {
  const _UploadPanel({
    required this.fileName,
    required this.fileSizeBytes,
    required this.isLoading,
    required this.onPressed,
  });

  final String? fileName;
  final int? fileSizeBytes;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      backgroundColor: context.tokens.surfaceSecondary,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fileName == null)
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(
                    Icons.attach_file_rounded,
                    color: context.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Select a document to begin',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: context.tokens.infoSoft,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: context.tokens.infoStrong,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (fileSizeBytes != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          _formatFileSize(fileSizeBytes!),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton.icon(
            onPressed: isLoading ? null : onPressed,
            icon: const Icon(Icons.upload_file_rounded),
            label: Text(fileName == null ? 'Select document' : 'Replace document'),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(0)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

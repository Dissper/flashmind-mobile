import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/subscription/subscription_controller.dart';
import '../../../shared/models/flashcard_mode.dart';
import '../../../shared/widgets/app_shell.dart';
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generate a deck',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload a supported document, choose the flashcard mode, and keep it fast.',
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: state.isSubmitting ? null : controller.pickDocument,
                    icon: const Icon(Icons.attach_file_rounded),
                    label: Text(
                      state.selectedFile == null
                          ? 'Select document'
                          : state.selectedFile!.name,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Mode',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 20),
                  Text(
                    'Card count: ${state.cardCount}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: state.cardCount.toDouble(),
                    min: 4,
                    max: maxCardsAllowed.toDouble(),
                    divisions: maxCardsAllowed - 4,
                    label: state.cardCount.toString(),
                    onChanged: state.isSubmitting ? null : controller.setCardCount,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Supported files: ${AppConfig.supportedFileTypesLabel}\n'
                    'Max file size: ${AppConfig.maxFileSizeLabel}\n'
                    'Current plan limit: $maxCardsAllowed cards',
                  ),
                  if (state.progressMessage != null) ...[
                    const SizedBox(height: 20),
                    LinearProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(state.progressMessage!),
                  ],
                  const SizedBox(height: 24),
                  PrimaryActionButton(
                    label: state.isSubmitting ? 'Generating...' : 'Generate',
                    icon: Icons.auto_awesome_rounded,
                    onPressed: state.isSubmitting
                        ? null
                        : () async {
                            final deck = await controller.generate();
                            if (deck != null && context.mounted) {
                              context.go('/study/${deck.id}');
                            }
                          },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

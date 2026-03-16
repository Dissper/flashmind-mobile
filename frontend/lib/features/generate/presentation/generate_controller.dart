import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/subscription/subscription_controller.dart';
import '../../../shared/models/deck_detail.dart';
import '../../../shared/models/flashcard_mode.dart';
import '../../home/data/deck_repository.dart';

final generateControllerProvider =
    NotifierProvider<GenerateController, GenerateState>(GenerateController.new);

class GenerateState {
  const GenerateState({
    required this.selectedFile,
    required this.mode,
    required this.cardCount,
    required this.isSubmitting,
    required this.progressMessage,
    required this.errorMessage,
  });

  const GenerateState.initial()
      : selectedFile = null,
        mode = FlashcardMode.flip,
        cardCount = 10,
        isSubmitting = false,
        progressMessage = null,
        errorMessage = null;

  final PlatformFile? selectedFile;
  final FlashcardMode mode;
  final int cardCount;
  final bool isSubmitting;
  final String? progressMessage;
  final String? errorMessage;

  GenerateState copyWith({
    PlatformFile? selectedFile,
    FlashcardMode? mode,
    int? cardCount,
    bool? isSubmitting,
    String? progressMessage,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GenerateState(
      selectedFile: selectedFile ?? this.selectedFile,
      mode: mode ?? this.mode,
      cardCount: cardCount ?? this.cardCount,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      progressMessage: progressMessage,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class GenerateController extends Notifier<GenerateState> {
  Timer? _progressTimer;
  int _progressIndex = 0;

  static const _progressMessages = [
    'Uploading document...',
    'Extracting text...',
    'Generating flashcards...',
    'Saving deck...',
  ];

  @override
  GenerateState build() {
    ref.onDispose(() => _progressTimer?.cancel());
    ref.listen(subscriptionControllerProvider, (previous, next) {
      if (state.cardCount > next.maxCardsAllowed) {
        state = state.copyWith(
          cardCount: next.maxCardsAllowed,
          clearError: true,
        );
      }
    });
    return const GenerateState.initial();
  }

  Future<void> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      withData: true,
      allowedExtensions: const ['pdf', 'docx', 'pptx'],
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    state = state.copyWith(
      selectedFile: result.files.single,
      progressMessage: null,
      clearError: true,
    );
  }

  void setMode(FlashcardMode mode) {
    state = state.copyWith(mode: mode, clearError: true);
  }

  void setCardCount(double cardCount) {
    state = state.copyWith(cardCount: cardCount.round(), clearError: true);
  }

  Future<DeckDetail?> generate() async {
    final file = state.selectedFile;
    if (file == null) {
      state = state.copyWith(
        errorMessage: 'Select a PDF, DOCX, or PPTX file first.',
      );
      return null;
    }

    state = state.copyWith(
      isSubmitting: true,
      progressMessage: _progressMessages.first,
      clearError: true,
    );
    _startProgressTicker();

    try {
      final deck = await ref.read(deckRepositoryProvider).generateDeck(
            file: file,
            mode: state.mode,
            cardCount: state.cardCount,
          );
      ref.invalidate(decksProvider);
      state = state.copyWith(
        isSubmitting: false,
        progressMessage: null,
      );
      _progressTimer?.cancel();
      return deck;
    } catch (error) {
      _progressTimer?.cancel();
      state = state.copyWith(
        isSubmitting: false,
        progressMessage: null,
        errorMessage: '$error',
      );
      return null;
    }
  }

  void _startProgressTicker() {
    _progressTimer?.cancel();
    _progressIndex = 0;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      _progressIndex = (_progressIndex + 1) % _progressMessages.length;
      state = state.copyWith(
        progressMessage: _progressMessages[_progressIndex],
        clearError: true,
      );
    });
  }
}

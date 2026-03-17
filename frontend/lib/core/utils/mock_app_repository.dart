import '../../core/config/app_config.dart';
import '../../shared/models/deck_detail.dart';
import '../../shared/models/deck_summary.dart';
import '../../shared/models/flashcard_item.dart';
import '../../shared/models/flashcard_mode.dart';
import '../../shared/models/generation_access.dart';
import '../../shared/models/user_profile.dart';

class MockAppRepository {
  MockAppRepository() {
    _seedIfNeeded();
  }

  static final MockAppRepository instance = MockAppRepository._internal();

  MockAppRepository._internal();

  final List<DeckDetail> _decks = [];
  final Map<int, List<FlashcardItem>> _flashcardsByDeckId = {};
  int _nextDeckId = 3;
  int _nextFlashcardId = 100;
  int _freeGenerationsUsed = 0;
  bool _premiumActive = false;

  UserProfile get currentUser {
    final access = getGenerationAccess();
    return UserProfile(
      id: 1,
      email: 'demo@flashmind.local',
      displayName: 'Demo User',
      provider: 'DEV',
      revenueCatUserId: 'flashmind-user-1',
      subscriptionActive: _premiumActive,
      entitlementActive: _premiumActive,
      isSubscribed: access.subscribed,
      freeGenerationsUsed: access.freeGenerationsUsed,
      freeGenerationsRemaining: access.freeGenerationsRemaining,
      maxCardsAllowed: access.maxCardsAllowed,
    );
  }

  GenerationAccess getGenerationAccess() {
    final remaining = (AppConfig.freeGenerationLimit - _freeGenerationsUsed)
        .clamp(0, AppConfig.freeGenerationLimit);
    return GenerationAccess(
      subscribed: _premiumActive,
      freeGenerationsUsed: _freeGenerationsUsed,
      freeGenerationsRemaining: remaining,
      canGenerate: _premiumActive || remaining > 0,
      maxCardsAllowed:
          _premiumActive ? AppConfig.premiumMaxCards : AppConfig.freeMaxCards,
    );
  }

  void activatePremium() {
    _premiumActive = true;
  }

  List<DeckSummary> listDecks() {
    _seedIfNeeded();
    return _decks
        .map(
          (deck) => DeckSummary(
            id: deck.id,
            title: deck.title,
            mode: deck.mode,
            cardCount: deck.cardCount,
            createdAt: deck.createdAt,
          ),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  DeckDetail getDeck(int deckId) {
    _seedIfNeeded();
    return _decks.firstWhere((deck) => deck.id == deckId);
  }

  List<FlashcardItem> getFlashcards(int deckId) {
    _seedIfNeeded();
    return List<FlashcardItem>.from(_flashcardsByDeckId[deckId] ?? const []);
  }

  void deleteDeck(int deckId) {
    _seedIfNeeded();
    final index = _decks.indexWhere((deck) => deck.id == deckId);

    if (index == -1) {
      throw StateError('Deck not found.');
    }

    _decks.removeAt(index);
    _flashcardsByDeckId.remove(deckId);
  }

  DeckDetail generateDeck({
    required String title,
    required FlashcardMode mode,
    required int cardCount,
  }) {
    final access = getGenerationAccess();
    if (!access.canGenerate) {
      throw Exception('Free generation limit reached. Upgrade to premium.');
    }
    if (cardCount > access.maxCardsAllowed) {
      throw Exception(
        'Your current plan allows up to ${access.maxCardsAllowed} cards per deck.',
      );
    }

    final now = DateTime.now();
    final deck = DeckDetail(
      id: _nextDeckId++,
      title: title,
      mode: mode,
      cardCount: cardCount,
      createdAt: now,
    );

    final cards = List.generate(cardCount, (index) {
      if (mode == FlashcardMode.flip) {
        return FlashcardItem(
          id: _nextFlashcardId++,
          question: 'Pregunta ${index + 1} de $title',
          answer: 'Respuesta breve ${index + 1} generada en modo mock.',
          options: const [],
          correctOption: null,
          type: FlashcardMode.flip,
          position: index + 1,
        );
      }

      return FlashcardItem(
        id: _nextFlashcardId++,
        question: 'Selecciona la mejor respuesta para ${index + 1} en $title',
        answer: null,
        options: [
          'Opcion correcta ${index + 1}',
          'Distractor A ${index + 1}',
          'Distractor B ${index + 1}',
          'Distractor C ${index + 1}',
        ],
        correctOption: 0,
        type: FlashcardMode.multipleChoice,
        position: index + 1,
      );
    });

    _decks.add(deck);
    _flashcardsByDeckId[deck.id] = cards;
    if (!_premiumActive) {
      _freeGenerationsUsed++;
    }
    return deck;
  }

  void _seedIfNeeded() {
    if (_decks.isNotEmpty) {
      return;
    }

    final biologyDeck = DeckDetail(
      id: 1,
      title: 'Biology Notes',
      mode: FlashcardMode.flip,
      cardCount: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    );
    final historyDeck = DeckDetail(
      id: 2,
      title: 'World History Slides',
      mode: FlashcardMode.multipleChoice,
      cardCount: 3,
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
    );

    _decks.addAll([biologyDeck, historyDeck]);
    _flashcardsByDeckId[1] = [
      const FlashcardItem(
        id: 1,
        question: 'What is photosynthesis?',
        answer: 'The process plants use to convert light into chemical energy.',
        options: [],
        correctOption: null,
        type: FlashcardMode.flip,
        position: 1,
      ),
      const FlashcardItem(
        id: 2,
        question: 'What does chlorophyll do?',
        answer: 'It helps absorb light energy for photosynthesis.',
        options: [],
        correctOption: null,
        type: FlashcardMode.flip,
        position: 2,
      ),
      const FlashcardItem(
        id: 3,
        question: 'Where does photosynthesis mainly happen?',
        answer: 'In the chloroplasts of plant cells.',
        options: [],
        correctOption: null,
        type: FlashcardMode.flip,
        position: 3,
      ),
    ];
    _flashcardsByDeckId[2] = [
      const FlashcardItem(
        id: 4,
        question: 'Which event began in 1789?',
        answer: null,
        options: [
          'French Revolution',
          'Industrial Revolution',
          'American Civil War',
          'Congress of Vienna',
        ],
        correctOption: 0,
        type: FlashcardMode.multipleChoice,
        position: 1,
      ),
      const FlashcardItem(
        id: 5,
        question: 'Which empire built Machu Picchu?',
        answer: null,
        options: [
          'Roman Empire',
          'Inca Empire',
          'Ottoman Empire',
          'Mongol Empire',
        ],
        correctOption: 1,
        type: FlashcardMode.multipleChoice,
        position: 2,
      ),
      const FlashcardItem(
        id: 6,
        question: 'Who crossed the Alps with elephants?',
        answer: null,
        options: [
          'Julius Caesar',
          'Alexander the Great',
          'Hannibal',
          'Napoleon',
        ],
        correctOption: 2,
        type: FlashcardMode.multipleChoice,
        position: 3,
      ),
    ];
  }
}

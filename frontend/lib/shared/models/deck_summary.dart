import 'flashcard_mode.dart';

class DeckSummary {
  const DeckSummary({
    required this.id,
    required this.title,
    required this.mode,
    required this.cardCount,
    required this.createdAt,
  });

  final int id;
  final String title;
  final FlashcardMode mode;
  final int cardCount;
  final DateTime createdAt;

  factory DeckSummary.fromJson(Map<String, dynamic> json) {
    return DeckSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      mode: FlashcardMode.fromApiValue(json['mode'] as String),
      cardCount: json['cardCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

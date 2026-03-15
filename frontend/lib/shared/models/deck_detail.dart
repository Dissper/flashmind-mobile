import 'flashcard_mode.dart';

class DeckDetail {
  const DeckDetail({
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

  factory DeckDetail.fromJson(Map<String, dynamic> json) {
    return DeckDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      mode: FlashcardMode.fromApiValue(json['mode'] as String),
      cardCount: json['cardCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

import 'flashcard_mode.dart';

class FlashcardItem {
  const FlashcardItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.options,
    required this.correctOption,
    required this.type,
    required this.position,
  });

  final int id;
  final String question;
  final String? answer;
  final List<String> options;
  final int? correctOption;
  final FlashcardMode type;
  final int position;

  factory FlashcardItem.fromJson(Map<String, dynamic> json) {
    return FlashcardItem(
      id: json['id'] as int,
      question: json['question'] as String,
      answer: json['answer'] as String?,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
      correctOption: json['correctOption'] as int?,
      type: FlashcardMode.fromApiValue(json['type'] as String),
      position: json['position'] as int,
    );
  }
}

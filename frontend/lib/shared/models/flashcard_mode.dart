enum FlashcardMode {
  flip('FLIP', 'Flip card'),
  multipleChoice('MULTIPLE_CHOICE', 'Multiple choice');

  const FlashcardMode(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static FlashcardMode fromApiValue(String value) {
    return FlashcardMode.values.firstWhere(
      (mode) => mode.apiValue == value,
      orElse: () => FlashcardMode.flip,
    );
  }
}

class GenerationAccess {
  const GenerationAccess({
    required this.subscribed,
    required this.freeGenerationsUsed,
    required this.freeGenerationsRemaining,
    required this.canGenerate,
    required this.maxCardsAllowed,
  });

  final bool subscribed;
  final int freeGenerationsUsed;
  final int freeGenerationsRemaining;
  final bool canGenerate;
  final int maxCardsAllowed;

  factory GenerationAccess.fromJson(Map<String, dynamic> json) {
    return GenerationAccess(
      subscribed: json['subscribed'] as bool? ?? false,
      freeGenerationsUsed: json['freeGenerationsUsed'] as int? ?? 0,
      freeGenerationsRemaining: json['freeGenerationsRemaining'] as int? ?? 0,
      canGenerate: json['canGenerate'] as bool? ?? false,
      maxCardsAllowed: json['maxCardsAllowed'] as int? ?? 10,
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.provider,
    required this.revenueCatUserId,
    required this.subscriptionActive,
    required this.entitlementActive,
    required this.isSubscribed,
    required this.freeGenerationsUsed,
    required this.freeGenerationsRemaining,
    required this.maxCardsAllowed,
    this.createdAt,
    this.updatedAt,
    this.subscriptionExpirationAt,
  });

  final int id;
  final String email;
  final String displayName;
  final String provider;
  final String revenueCatUserId;
  final bool subscriptionActive;
  final bool entitlementActive;
  final bool isSubscribed;
  final int freeGenerationsUsed;
  final int freeGenerationsRemaining;
  final int maxCardsAllowed;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? subscriptionExpirationAt;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'FlashMind User',
      provider: json['provider'] as String? ?? 'GOOGLE',
      revenueCatUserId: json['revenuecatUserId'] as String? ?? '',
      subscriptionActive: json['subscriptionActive'] as bool? ?? false,
      entitlementActive: json['entitlementActive'] as bool? ?? false,
      isSubscribed: json['subscribed'] as bool? ?? false,
      freeGenerationsUsed: json['freeGenerationsUsed'] as int? ?? 0,
      freeGenerationsRemaining:
          json['freeGenerationsRemaining'] as int? ?? 0,
      maxCardsAllowed: json['maxCardsAllowed'] as int? ?? 10,
      createdAt: _parseDateTime(json['createdAt'] as String?),
      updatedAt: _parseDateTime(json['updatedAt'] as String?),
      subscriptionExpirationAt:
          _parseDateTime(json['subscriptionExpirationAt'] as String?),
    );
  }

  static DateTime? _parseDateTime(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}

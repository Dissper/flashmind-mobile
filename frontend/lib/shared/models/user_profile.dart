class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.provider,
  });

  final int id;
  final String email;
  final String displayName;
  final String provider;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'FlashMind User',
      provider: json['provider'] as String? ?? 'GOOGLE',
    );
  }
}

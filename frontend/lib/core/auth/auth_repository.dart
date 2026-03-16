import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/user_profile.dart';
import '../config/app_config.dart';
import '../networking/api_client.dart';
import '../utils/mock_app_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<SocialLoginResult> socialLogin({
    required String provider,
    required String idToken,
  }) async {
    if (AppConfig.useMockBackend) {
      return const SocialLoginResult(
        token: 'mock-session-token',
        user: UserProfile(
          id: 1,
          email: 'demo@flashmind.local',
          displayName: 'Demo User',
          provider: 'DEV',
          revenueCatUserId: 'flashmind-user-1',
          subscriptionActive: false,
          entitlementActive: false,
          isSubscribed: false,
          freeGenerationsUsed: 0,
          freeGenerationsRemaining: AppConfig.freeGenerationLimit,
          maxCardsAllowed: AppConfig.freeMaxCards,
        ),
      );
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/auth/social-login',
        data: {
          'provider': provider,
          'idToken': idToken,
        },
      );

      final data = response.data ?? <String, dynamic>{};
      return SocialLoginResult(
        token: data['token'] as String,
        user: UserProfile.fromJson(data['user'] as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      throw Exception(_extractApiErrorMessage(error));
    }
  }

  Future<SocialLoginResult> devLogin() async {
    if (AppConfig.useMockBackend) {
      final user = MockAppRepository.instance.currentUser;
      return SocialLoginResult(
        token: 'mock-session-token',
        user: user,
      );
    }

    try {
      final response =
          await _dio.post<Map<String, dynamic>>('/api/auth/dev-login');
      final data = response.data ?? <String, dynamic>{};
      return SocialLoginResult(
        token: data['token'] as String,
        user: UserProfile.fromJson(data['user'] as Map<String, dynamic>),
      );
    } on DioException catch (error) {
      throw Exception(_extractApiErrorMessage(error));
    }
  }

  Future<UserProfile> fetchCurrentUser() async {
    if (AppConfig.useMockBackend) {
      return MockAppRepository.instance.currentUser;
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>('/api/me');
      return UserProfile.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (error) {
      throw Exception(_extractApiErrorMessage(error));
    }
  }

  String _extractApiErrorMessage(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    return error.message ?? 'Request failed.';
  }
}

class SocialLoginResult {
  const SocialLoginResult({
    required this.token,
    required this.user,
  });

  final String token;
  final UserProfile user;
}

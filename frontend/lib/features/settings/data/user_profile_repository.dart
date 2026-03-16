import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/networking/api_client.dart';
import '../../../core/utils/mock_app_repository.dart';
import '../../../shared/models/generation_access.dart';
import '../../../shared/models/user_profile.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository(ref.watch(apiClientProvider));
});

final settingsUserProfileProvider = FutureProvider<UserProfile>((ref) async {
  return ref.watch(userProfileRepositoryProvider).fetchCurrentUser();
});

class UserProfileRepository {
  UserProfileRepository(this._dio);

  final Dio _dio;

  Future<UserProfile> fetchCurrentUser() async {
    if (AppConfig.useMockBackend) {
      return MockAppRepository.instance.currentUser;
    }

    final response = await _dio.get<Map<String, dynamic>>('/api/me');
    return UserProfile.fromJson(response.data ?? <String, dynamic>{});
  }

  Future<GenerationAccess> fetchGenerationAccess() async {
    if (AppConfig.useMockBackend) {
      return MockAppRepository.instance.getGenerationAccess();
    }

    final response =
        await _dio.get<Map<String, dynamic>>('/api/me/generation-access');
    return GenerationAccess.fromJson(response.data ?? <String, dynamic>{});
  }
}

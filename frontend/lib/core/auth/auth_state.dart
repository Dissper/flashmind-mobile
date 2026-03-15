import '../../shared/models/user_profile.dart';

class AuthState {
  const AuthState({
    required this.isLoading,
    required this.user,
    required this.token,
    required this.errorMessage,
  });

  const AuthState.loading()
      : isLoading = true,
        user = null,
        token = null,
        errorMessage = null;

  const AuthState.unauthenticated({this.errorMessage})
      : isLoading = false,
        user = null,
        token = null;

  const AuthState.authenticated({
    required UserProfile this.user,
    required String this.token,
  })  : isLoading = false,
        errorMessage = null;

  final bool isLoading;
  final UserProfile? user;
  final String? token;
  final String? errorMessage;

  bool get isAuthenticated => user != null && token != null;
}

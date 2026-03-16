import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../shared/models/user_profile.dart';
import '../storage/token_storage.dart';
import 'auth_repository.dart';
import 'auth_state.dart';

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _authRepository;
  late final TokenStorage _tokenStorage;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  AuthState build() {
    _authRepository = ref.read(authRepositoryProvider);
    _tokenStorage = ref.read(tokenStorageProvider);
    _bootstrap();
    return const AuthState.loading();
  }

  Future<void> _bootstrap() async {
    final token = await _tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      state = const AuthState.unauthenticated();
      return;
    }

    try {
      final user = await _authRepository.fetchCurrentUser();
      state = AuthState.authenticated(user: user, token: token);
    } catch (_) {
      await _tokenStorage.clearToken();
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> loginWithGoogle() async {
    state = const AuthState.loading();
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        state = const AuthState.unauthenticated();
        return;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Google did not return an ID token.');
      }

      final result = await _authRepository.socialLogin(
        provider: 'GOOGLE',
        idToken: idToken,
      );
      await _completeLogin(result.user, result.token);
    } catch (error) {
      state = AuthState.unauthenticated(errorMessage: '$error');
    }
  }

  Future<void> loginWithApple() async {
    state = const AuthState.loading();
    try {
      if (!appleSignInSupported) {
        throw Exception('Apple Sign In is not available on this platform.');
      }

      // TODO: Ensure Sign In with Apple capability and service identifiers
      // are configured for the iOS target before production use.
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final idToken = credential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Apple did not return an identity token.');
      }

      final result = await _authRepository.socialLogin(
        provider: 'APPLE',
        idToken: idToken,
      );
      await _completeLogin(result.user, result.token);
    } catch (error) {
      state = AuthState.unauthenticated(errorMessage: '$error');
    }
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _tokenStorage.clearToken();
    state = const AuthState.unauthenticated();
  }

  Future<void> refreshCurrentUser() async {
    final token = state.token;
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      final user = await _authRepository.fetchCurrentUser();
      state = AuthState.authenticated(user: user, token: token);
    } catch (_) {
      await _tokenStorage.clearToken();
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> continueWithoutLogin() async {
    state = const AuthState.loading();
    try {
      final result = await _authRepository.devLogin();
      await _completeLogin(result.user, result.token);
    } catch (error) {
      state = AuthState.unauthenticated(errorMessage: '$error');
    }
  }

  bool get appleSignInSupported {
    if (kIsWeb) {
      return false;
    }
    return Platform.isIOS || Platform.isMacOS;
  }

  Future<void> _completeLogin(UserProfile user, String token) async {
    await _tokenStorage.writeToken(token);
    state = AuthState.authenticated(user: user, token: token);
  }
}

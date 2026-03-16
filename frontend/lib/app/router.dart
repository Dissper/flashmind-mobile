import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_controller.dart';
import '../core/auth/auth_state.dart';
import '../features/generate/presentation/generate_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/login/presentation/login_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/study/presentation/study_screen.dart';
import '../features/subscription/presentation/subscription_screen.dart';

final routerRefreshProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.listen<AuthState>(authControllerProvider, (_, __) {
    notifier.value++;
  });
  ref.onDispose(notifier.dispose);
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);
  final refresh = ref.watch(routerRefreshProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isLoggedIn = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (isLoading) {
        return isLoginRoute ? null : '/login';
      }

      if (!isLoggedIn) {
        return isLoginRoute ? null : '/login';
      }

      if (isLoggedIn && isLoginRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/generate',
        builder: (context, state) => const GenerateScreen(),
      ),
      GoRoute(
        path: '/subscribe',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/study/:deckId',
        builder: (context, state) {
          final deckId = int.parse(state.pathParameters['deckId']!);
          return StudyScreen(deckId: deckId);
        },
      ),
    ],
  );
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/subscription/subscription_controller.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class FlashMindApp extends ConsumerWidget {
  const FlashMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(subscriptionControllerProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'FlashMind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
    );
  }
}

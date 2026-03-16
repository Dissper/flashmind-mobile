import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/subscription/subscription_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SubscriptionService.initializeSdk();
  runApp(const ProviderScope(child: FlashMindApp()));
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/handoff/ui/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MaintainerHandoffApp()));
}

class MaintainerHandoffApp extends ConsumerWidget {
  const MaintainerHandoffApp({super.key});

  static const Color accentBlue = Color(0xFF1D4ED8);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'MaintainerHandoff',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accent: accentBlue),
      darkTheme: AppTheme.dark(accent: accentBlue),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}

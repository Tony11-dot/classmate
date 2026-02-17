import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/pilot_theme.dart';
import 'router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final t = ref.watch(themeControllerProvider);
    final tc = ref.read(themeControllerProvider.notifier);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      themeMode: t.mode,
      theme: tc.theme(Brightness.light),
      darkTheme: tc.theme(Brightness.dark),
      routerConfig: router,
    );
  }
}

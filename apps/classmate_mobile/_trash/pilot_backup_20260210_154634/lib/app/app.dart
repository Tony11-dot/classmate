import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/pilot_theme.dart';
import 'router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final tc = ref.watch(themeControllerProvider.notifier);
    final ts = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      themeMode: ts.mode,
      theme: tc.theme(Brightness.light),
      darkTheme: tc.theme(Brightness.dark),
      routerConfig: router,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/theme_controller.dart';
import 'router.dart';

class ClassMateApp extends ConsumerWidget {
  const ClassMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final t = ref.watch(themeControllerProvider);

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(t.textScale)),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        themeMode: t.mode,
        theme: buildTheme(brightness: Brightness.light, s: t),
        darkTheme: buildTheme(brightness: Brightness.dark, s: t),
      ),
    );
  }
}

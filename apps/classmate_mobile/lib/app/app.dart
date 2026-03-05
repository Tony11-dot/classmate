import 'package:flutter/material.dart';
import 'router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/theme_controller.dart';

class ClassMateApp extends ConsumerWidget {
  const ClassMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeControllerProvider);

    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(t.textScale)),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: ref.watch(routerProvider),
        themeMode: t.mode,
        theme: buildTheme(brightness: Brightness.light, s: t),
        darkTheme: buildTheme(brightness: Brightness.dark, s: t),
      ),
    );
  }
}

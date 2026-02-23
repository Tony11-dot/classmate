import '../core/i18n/locale_controller.dart';
import 'package:classmate_mobile/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:classmate_mobile/core/theme/cm_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_controller.dart';
import '../core/config/env.dart';
import '../core/theme/theme_controller.dart';
import '../features/auth/login_screen.dart';
import 'shell/app_shell.dart';
import 'shell/parent_shell.dart';
import 'shell/cm_home_shell.dart';
import 'shell/cm_home_shell.dart';
import 'shell/parent_shell.dart';

class ClassMateApp extends ConsumerWidget {
  const ClassMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeControllerProvider);
    final auth = ref.watch(authControllerProvider);

    final app = MaterialApp(
      theme: CMTheme.light(),
      darkTheme: CMTheme.dark(),
      locale: ref.watch(localeControllerProvider),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar'), Locale('he')],
      debugShowCheckedModeBanner: false,
      title: 'ClassMate',
      themeMode: t.mode,
      builder: (context, child) {
        final scale = t.textScale;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final wrapped = CMTheme.heroBackground(
          dark: isDark,
          child: child ?? const SizedBox.shrink(),
        );
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
          ),
          child: wrapped,
        );
      },
      home: Builder(
        builder: (context) {
          if (!auth.ready) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (!auth.isAuthed) {
            return const LoginScreen();
          }

          return const ParentShell();
        },
      ),
    );

    assert(() {
      // ignore: avoid_print
      // ignore: avoid_print
      return true;
    }());

    return app;
  }
}

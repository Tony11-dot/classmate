import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/env.dart';
import 'core/realtime/realtime_listener.dart';
import 'ui/widgets/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Env.init();
  runApp(const ProviderScope(child: _RootApp()));
}

class _RootApp extends StatefulWidget {
  const _RootApp();

  @override
  State<_RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<_RootApp> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    // After splash: hand off to the full app (which has its own MaterialApp, theme, etc.)
    if (_splashDone) return const RealtimeListener(child: ClassMateApp());

    // Wrap splash in a minimal MaterialApp so Directionality, DefaultTextStyle,
    // MediaQuery, etc. are all available — avoids "No Directionality widget found"
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SplashScreen(
          onComplete: () {
            if (mounted) setState(() => _splashDone = true);
          },
        ),
      ),
    );
  }
}

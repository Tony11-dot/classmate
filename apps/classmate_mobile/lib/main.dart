import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/env.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Env.init();
  // ignore: avoid_print
  // ignore: avoid_print
  print(
    'CM apiBaseUrl=${Env.apiBaseUrl} schoolId=${Env.schoolId} devToken=${Env.devToken}',
  );
  runApp(const ProviderScope(child: ClassMateApp()));
}

import 'package:flutter/material.dart';
import 'core/auth/auth_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/env.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Env.init();
  runApp(const ProviderScope(child: ClassMateApp()));
}

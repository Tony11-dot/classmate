import 'core/i18n/locale_controller.dart';
import 'package:classmate_mobile/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/config/env.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Env.init();
  runApp(const ProviderScope(child: ClassMateApp()));
}

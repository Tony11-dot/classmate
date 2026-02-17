import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'api/api_client.dart';
import 'core/session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Boot auth as early as possible: load token + set bearer on Dio.
  final token = await Session.getToken();
  if (token != null && token.trim().isNotEmpty) {
    ApiClient.instance.setBearer(token.trim());
  }

  runApp(const ProviderScope(child: App()));
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../config/env.dart';
import 'api_client.dart';
import 'cm_api.dart';

final cmApiProvider = Provider<CMApi>((ref) {
  final auth = ref.read(authControllerProvider.notifier);
  final apiClient = ApiClient(baseUrl: Env.apiBaseUrl, tokenProvider: auth.token);
  return CMApi(apiClient);
});

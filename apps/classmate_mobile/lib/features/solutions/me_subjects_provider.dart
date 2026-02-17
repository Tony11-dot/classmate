import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_client.dart';
import 'me_subjects_api.dart';

final meSubjectsProvider = FutureProvider<List<MeSubject>>((ref) async {
  final api = MeSubjectsApi(ApiClient.instance);
  return api.list();
});

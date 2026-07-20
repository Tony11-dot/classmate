import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/http/cm_api.dart';

/// A single turn in the support-assistant conversation.
class SupportTurn {
  const SupportTurn({required this.role, required this.content});

  /// 'user' or 'assistant'.
  final String role;
  final String content;

  bool get isUser => role == 'user';

  Map<String, String> toJson() => {'role': role, 'content': content};
}

/// Talks to the backend support-assistant endpoints. Kept intentionally small:
/// a status probe (so the UI only offers the assistant when the server has a
/// provider configured) and a single ask call.
class SupportAiRepository {
  SupportAiRepository({required this.token});

  final String token;

  CMApi get _api => CMApi(token: token);

  /// Whether the backend has a support-AI provider configured. Returns false on
  /// any error so the UI safely falls back to the FAQ + contact card.
  Future<bool> isEnabled() async {
    try {
      final res = await _api.getJson('/support/ai/status');
      if (res is Map && res['enabled'] == true) return true;
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Ask one support question, optionally with prior turns for follow-up
  /// context. Throws [CMApiException] on failure so the UI can show a friendly
  /// message.
  Future<String> ask(String question, {List<SupportTurn> history = const []}) async {
    final res = await _api.postJson('/support/ai/ask', body: {
      'question': question,
      if (history.isNotEmpty)
        'history': history.map((t) => t.toJson()).toList(growable: false),
    });
    if (res is Map && res['answer'] is String) {
      return (res['answer'] as String).trim();
    }
    return '';
  }
}

final supportAiRepositoryProvider = Provider<SupportAiRepository>((ref) {
  final token = (ref.watch(authSessionProvider).token ?? '').trim();
  return SupportAiRepository(token: token);
});

/// Resolves once per screen mount: is the assistant available?
final supportAiEnabledProvider = FutureProvider.autoDispose<bool>((ref) async {
  return ref.watch(supportAiRepositoryProvider).isEnabled();
});

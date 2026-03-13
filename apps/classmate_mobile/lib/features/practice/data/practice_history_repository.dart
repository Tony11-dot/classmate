import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/practice_history_models.dart';

class PracticeHistoryRepository {
  static const String _storageKey = 'practice_history_sessions_v1';
  static const int _maxSessions = 60;

  Future<List<PracticeHistorySession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];

      return decoded
          .whereType<Map>()
          .map(
            (x) => PracticeHistorySession.fromJson(
              x.map((k, v) => MapEntry(k.toString(), v)),
            ),
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveSession(PracticeHistorySession session) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await loadSessions();

    final next = <PracticeHistorySession>[
      session,
      ...existing.where((x) => x.id != session.id),
    ];

    final trimmed = next.take(_maxSessions).toList();

    await prefs.setString(
      _storageKey,
      jsonEncode(trimmed.map((x) => x.toJson()).toList(growable: false)),
    );
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

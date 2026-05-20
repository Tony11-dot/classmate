// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_session.dart';
import '../../core/http/cm_api.dart';

/// Temporary diagnostic screen for the rokny / teacher-periods bug
/// (and any future "what's actually in the API response?" checks).
///
/// Shows the logged-in user's identity, then lets you fire any of the
/// schedule endpoints and see the raw JSON the server returned. One
/// "Copy all" button dumps everything to clipboard for pasting back
/// to support.
///
/// Reachable at /debug. Safe for any role — the API calls themselves
/// 401 / 403 if the role isn't authorised, and the screen displays
/// whatever the server replied with.
class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  final Map<String, String> _results = {};
  final Set<String> _loading = {};

  String _pretty(dynamic value) {
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  Future<void> _hit(String label, String path) async {
    final session = ref.read(authSessionProvider);
    final token = (session.token ?? '').trim();
    if (token.isEmpty) {
      setState(() => _results[label] = 'NO TOKEN — not logged in');
      return;
    }
    setState(() {
      _loading.add(label);
      _results.remove(label);
    });
    try {
      final api = CMApi(token: token);
      final raw = await api.getJson(path);
      setState(() {
        _results[label] = _pretty(raw);
      });
    } catch (e) {
      setState(() {
        _results[label] = 'ERROR: $e';
      });
    } finally {
      setState(() => _loading.remove(label));
    }
  }

  Future<void> _copyAll() async {
    final session = ref.read(authSessionProvider);
    final header = [
      '=== ClassMate Debug Dump ===',
      'userId:        ${session.userId}',
      'email:         ${session.email}',
      'displayName:   ${session.displayName}',
      'primaryRole:   ${session.primaryRole}',
      'token (first 20): ${(session.token ?? '').substring(0, (session.token ?? '').length.clamp(0, 20))}...',
      '',
    ].join('\n');

    final body = _results.entries
        .map((e) => '--- ${e.key} ---\n${e.value}\n')
        .join('\n');

    await Clipboard.setData(ClipboardData(text: '$header\n$body'));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied debug dump to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final session = ref.watch(authSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
        actions: [
          IconButton(
            tooltip: 'Copy all to clipboard',
            icon: const Icon(Icons.copy_all_rounded),
            onPressed: _copyAll,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Identity card ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Logged-in identity',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                _kv('userId', session.userId),
                _kv('email', session.email),
                _kv('displayName', session.displayName),
                _kv('primaryRole', session.primaryRole),
                _kv('has token', (session.token ?? '').isNotEmpty ? 'yes' : 'no'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Endpoint buttons ──────────────────────────────────────────
          Text('Hit an endpoint',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            'These call the same endpoints the app uses. Use this to confirm what the server is actually returning for the logged-in user.',
            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('auth/me', '/auth/me'),
              _btn('teacher today', '/teacher/schedule/today'),
              _btn('teacher week', '/teacher/schedule/week'),
              _btn('student week', '/student/schedule/week'),
            ],
          ),
          const SizedBox(height: 18),

          // ── Results ───────────────────────────────────────────────────
          if (_results.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('Tap a button above to fetch a response.',
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ),
            )
          else
            ..._results.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(e.key,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w800, color: cs.primary)),
                            ),
                            IconButton(
                              tooltip: 'Copy this response',
                              icon: const Icon(Icons.copy_rounded, size: 18),
                              onPressed: () async {
                                await Clipboard.setData(ClipboardData(text: e.value));
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Copied ${e.key} response')),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SelectableText(
                          e.value,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _btn(String label, String path) {
    final isLoading = _loading.contains(label);
    return FilledButton.tonal(
      onPressed: isLoading ? null : () => _hit(label, path),
      child: isLoading
          ? const SizedBox.square(
              dimension: 14, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(label),
    );
  }

  Widget _kv(String k, String v) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(k,
                style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
          ),
          Expanded(
            child: SelectableText(
              v.isEmpty ? '(empty)' : v,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

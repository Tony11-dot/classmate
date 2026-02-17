import 'dart:convert';

import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../core/session.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool loading = true;
  String? error;
  dynamic payload;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
      payload = null;
    });

    try {
      final token = await Session.token();
      final role = (await Session.role())?.toUpperCase();

      if (token == null || token.isEmpty) {
        setState(() {
          loading = false;
          error = 'Not logged in (missing token).';
        });
        return;
      }

      final api = ApiClient.instance;
      api.setBearer(token);

      final path = switch (role) {
        'TEACHER' => '/api/teacher/schedule/today',
        'PARENT' => '/api/parent/schedule/today',
        _ => '/api/student/schedule/today',
      };

      final res = await api.get(path);
      setState(() {
        loading = false;
        payload = res.data;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  List<Map<String, dynamic>> _extractItems(dynamic data) {
    // We don’t know exact shape yet, so try common patterns.
    if (data is List) {
      return data
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    }
    if (data is Map) {
      final m = Map<String, dynamic>.from(data as Map);
      for (final key in ['items', 'data', 'slots', 'schedule', 'events']) {
        final v = m[key];
        if (v is List) {
          return v
              .whereType<Map>()
              .map((x) => Map<String, dynamic>.from(x))
              .toList();
        }
      }
      // If it's a single object, show as one card
      return [m];
    }
    return [];
  }

  String _titleFor(Map<String, dynamic> item) {
    return (item['title'] ??
            item['courseName'] ??
            item['course'] ??
            item['subject'] ??
            item['name'] ??
            'Schedule item')
        .toString();
  }

  String _subtitleFor(Map<String, dynamic> item) {
    final parts = <String>[];
    for (final k in [
      'room',
      'location',
      'teacherName',
      'period',
      'start',
      'end',
      'startsAt',
      'endsAt',
    ]) {
      if (item[k] != null) parts.add('${k}: ${item[k]}');
    }
    return parts.isEmpty ? 'Tap to view raw details' : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Schedule')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Schedule')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Couldn’t load schedule:\n$error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    final items = _extractItems(payload);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: items.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'No schedule items found. Showing raw payload below:',
                ),
                const SizedBox(height: 12),
                SelectableText(
                  const JsonEncoder.withIndent('  ').convert(payload),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final it = items[i];
                return Card(
                  child: ListTile(
                    title: Text(_titleFor(it)),
                    subtitle: Text(_subtitleFor(it)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        showDragHandle: true,
                        builder: (_) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              const JsonEncoder.withIndent('  ').convert(it),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

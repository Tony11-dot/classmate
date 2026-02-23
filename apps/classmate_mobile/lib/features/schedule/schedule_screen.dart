import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/cm_api_provider.dart';
import '../../core/ui/cm_scaffold.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key, required this.role});
  final String role;

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  dynamic today;
  dynamic week;
  String? err;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = ref.read(cmApiProvider);

      if (widget.role != 'parent') {
        setState(() {
          today = const [];
          week = const [];
        });
        return;
      }

      final kids = await api.getAny('/api/parent/children');
      if (kids is! List || kids.isEmpty) {
        setState(() {
          today = const [];
          week = const [];
        });
        return;
      }

      final sid = (kids.first is Map ? (kids.first['studentId'] ?? '') : '').toString();
      if (sid.isEmpty) {
        setState(() {
          today = const [];
          week = const [];
        });
        return;
      }

      final t = await api.getAny('/api/parent/schedule/today?studentId=$sid');
      final w = await api.getAny('/api/parent/schedule/week?studentId=$sid');

      setState(() {
        today = t;
        week = w;
      });
    } catch (e) {
      setState(() => err = e.toString());
    }
  }

  List<dynamic> _items(dynamic v) {
    if (v is List) return v;
    if (v is Map && v['items'] is List) return (v['items'] as List).cast<dynamic>();
    if (v is Map && v['data'] is List) return (v['data'] as List).cast<dynamic>();
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    if (err != null) return CMEmpty(title: 'Schedule failed to load', subtitle: err);
    if (today == null || week == null) return const Center(child: CircularProgressIndicator());

    if (widget.role != 'parent') {
      return const CMEmpty(
        title: 'Schedule (next)',
        subtitle: 'Student/Admin schedule endpoints will be added in backend next.',
      );
    }

    Widget list(String title, List<dynamic> items) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 10),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          if (items.isEmpty) const CMSection(child: Text('No items.')),
          for (final it in items) ...[
            CMSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (it is Map ? (it['title'] ?? it['course'] ?? 'Class') : it).toString(),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  Text((it is Map ? (it['time'] ?? it['start'] ?? it['day'] ?? '') : '').toString()),
                  if (it is Map && it['location'] != null) ...[
                    const SizedBox(height: 4),
                    Text('📍 ${it['location']}'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        children: [
          list('Today', _items(today)),
          const SizedBox(height: 14),
          list('This week', _items(week)),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

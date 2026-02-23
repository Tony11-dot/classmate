import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/ui/glass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/config/env.dart';

final parentChildrenProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) async {
  final auth = ref.read(authControllerProvider.notifier);
  final api = ApiClient(baseUrl: Env.apiBaseUrl, tokenProvider: auth.token);
  final res = await api.get('/api/parent/children');
  if (res.statusCode == 401) throw Exception('unauthorized');
  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw Exception('failed ${res.statusCode}');
  }
  final j = jsonDecode(res.body);
  if (j is List) return j.cast<Map<String, dynamic>>();
  if (j is Map && j['items'] is List)
    return (j['items'] as List).cast<Map<String, dynamic>>();
  if (j is Map && j['children'] is List)
    return (j['children'] as List).cast<Map<String, dynamic>>();
  return const [];
});

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = ref.watch(parentChildrenProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: children.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(child: Text('No children yet'));
            }
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final c = items[i];
                final name =
                    (c['name'] ??
                            c['fullName'] ??
                            c['studentName'] ??
                            'Student')
                        as String;
                final grade = c['grade'];
                return GlassCard(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text(grade == null ? '' : 'Grade $grade'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            );
          },
          error: (e, _) => Center(child: Text('Error: $e')),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_client.dart';

final apiBaseUrlProvider = Provider<String>((ref) {
  const fromDefine = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000',
  );
  return fromDefine;
});

final apiProvider = Provider<ApiClient>(
  (ref) => ApiClient(ref.watch(apiBaseUrlProvider)),
);

final healthProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(apiProvider).health();
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(healthProvider);
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Icon(Icons.circle, size: 10, color: cs.primary),
              const SizedBox(width: 8),
              Text('Pilot', style: TextStyle(color: cs.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Backend Status',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  health.when(
                    data: (d) => Text(
                      'ok=${d['ok']}  env=${d['env']}',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    loading: () => const Text('Checking...'),
                    error: (e, _) =>
                        Text('Error: $e', style: TextStyle(color: cs.error)),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton(
                        onPressed: () => ref.invalidate(healthProvider),
                        child: const Text('Refresh'),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Demo mode: UI is real ✅'),
                            ),
                          );
                        },
                        child: const Text('Demo Snack'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _tile(
                    context,
                    title: 'Attendance',
                    subtitle: 'Ready for API integration',
                    right: '96%',
                  ),
                  const Divider(height: 22),
                  _tile(
                    context,
                    title: 'Assignments',
                    subtitle: '2 due this week',
                    right: '2',
                  ),
                  const Divider(height: 22),
                  _tile(
                    context,
                    title: 'Notifications',
                    subtitle: 'No critical alerts',
                    right: '0',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String right,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
        Text(
          right,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ],
    );
  }
}

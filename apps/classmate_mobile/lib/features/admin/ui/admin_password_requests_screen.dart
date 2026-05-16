import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/admin_repository.dart';

final _pendingRequestsProvider = FutureProvider.autoDispose<List<PasswordChangeRequest>>((ref) {
  return ref.watch(adminRepositoryProvider).listPasswordRequests();
});

class AdminPasswordRequestsScreen extends ConsumerWidget {
  const AdminPasswordRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final async = ref.watch(_pendingRequestsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (requests) {
            if (requests.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  _Header(theme: theme),
                  const SizedBox(height: 60),
                  Icon(Icons.inbox_outlined, size: 64, color: cs.outlineVariant),
                  const SizedBox(height: 12),
                  Center(child: Text('No pending requests',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                  const SizedBox(height: 4),
                  Center(child: Text(
                    'Users you have approved or rejected won\'t appear here. Pending requests expire after 24 hours.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  )),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                _Header(theme: theme, count: requests.length),
                const SizedBox(height: 16),
                ...requests.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RequestCard(
                    request: r,
                    onApprove: () => _approve(context, ref, r),
                    onReject:  () => _reject(context, ref, r),
                  ),
                )),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _approve(BuildContext context, WidgetRef ref, PasswordChangeRequest r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Approve password change?'),
        content: Text("This will set ${r.requesterName}'s password to the one they typed. The new password is not visible to you."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: const Text('Approve')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(adminRepositoryProvider).approvePasswordRequest(r.id);
      ref.invalidate(_pendingRequestsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Approved — ${r.requesterName} can sign in now.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref, PasswordChangeRequest r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Reject password change?'),
        content: Text("${r.requesterName}'s password won't change. They can submit a new request if needed."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
          FilledButton.tonal(onPressed: () => Navigator.pop(d, true), child: const Text('Reject')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(adminRepositoryProvider).rejectPasswordRequest(r.id);
      ref.invalidate(_pendingRequestsProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rejected.')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme, this.count});
  final ThemeData theme;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password requests',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(
          count == null
              ? "Users from your school who've asked you to approve a password change."
              : '$count user${count == 1 ? '' : 's'} waiting for your approval.',
          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onApprove, required this.onReject});

  final PasswordChangeRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final hoursLeft = request.expiresAt.difference(DateTime.now()).inHours;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: cs.primaryContainer, shape: BoxShape.circle),
                child: Icon(Icons.person_rounded, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.requesterName,
                        style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    if ((request.requesterEmail ?? '').isNotEmpty)
                      Text(request.requesterEmail!,
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Text('${hoursLeft.clamp(0, 24)}h left',
                  style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Wants their password changed. The new password is hidden.',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(foregroundColor: cs.error),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onApprove,
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

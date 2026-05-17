import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Approve password change?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("This sets ${r.requesterName}'s password to the one they typed (you don't see it)."),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.errorContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.error.withValues(alpha: 0.5)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18, color: cs.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only approve if you have verified the requester is really ${r.requesterName} — call them, or confirm in person. Anyone who knows a username can file this request.',
                      style: TextStyle(fontSize: 12, color: cs.error, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(d, true),
            style: FilledButton.styleFrom(backgroundColor: cs.error),
            child: const Text('I verified — approve'),
          ),
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
          if ((request.requesterPhone ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            // Tap-to-call / tap-to-SMS the phone the requester provided.
            // This is the primary out-of-band verification path — the admin
            // confirms identity before approving.
            _PhoneActionRow(phone: request.requesterPhone!),
          ],
          const SizedBox(height: 10),
          // Persistent reminder: identity isn't proven by the system —
          // the admin is the gate. Surfacing this on every card so it
          // can't be missed during a quick approve.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: cs.errorContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.error.withValues(alpha: 0.4)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.security_rounded, size: 16, color: cs.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Verify this is really ${request.requesterName} before approving (call them or confirm in person).',
                    style: TextStyle(fontSize: 11, color: cs.error, height: 1.4, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
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

/// Phone number + tap-to-call / tap-to-SMS chips. Surfaces the requester's
/// phone so the admin can verify identity out-of-band before approving.
class _PhoneActionRow extends StatelessWidget {
  const _PhoneActionRow({required this.phone});
  final String phone;

  Future<void> _launch(BuildContext ctx, Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text("Couldn't open ${uri.scheme} link")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.tertiary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.phone_rounded, size: 16, color: cs.tertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              phone,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onTertiaryContainer,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Call',
            icon: const Icon(Icons.call_rounded, size: 18),
            visualDensity: VisualDensity.compact,
            color: cs.tertiary,
            onPressed: () => _launch(context, Uri(scheme: 'tel', path: phone)),
          ),
          IconButton(
            tooltip: 'SMS',
            icon: const Icon(Icons.sms_rounded, size: 18),
            visualDensity: VisualDensity.compact,
            color: cs.tertiary,
            onPressed: () => _launch(context, Uri(scheme: 'sms', path: phone)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/chat_message_info.dart';


class ChatMessageInfoPage extends StatelessWidget {
  const ChatMessageInfoPage({
    super.key,
    required this.info,
    this.previewTitle = '',
    this.previewBody = '',
    this.previewMeta = '',
    this.seenByNames = const <String>[],
    this.deliveredToNames = const <String>[],
  });

  final ChatMessageInfo info;
  final String previewTitle;
  final String previewBody;
  final String previewMeta;
  final List<String> seenByNames;
  final List<String> deliveredToNames;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    String statusLabel() {
      if (info.deleteState.trim().toUpperCase() != 'VISIBLE') {
        return info.deleteState.trim();
      }
      if (info.seen) return 'Seen';
      if (info.delivered) return 'Delivered';
      return 'Not delivered';
    }

    String statusTime() {
      if (info.seen && info.seenAt.trim().isNotEmpty) return info.seenAt.trim();
      if (info.delivered && info.deliveredAt.trim().isNotEmpty) {
        return info.deliveredAt.trim();
      }
      return info.sentAt.trim();
    }

    Widget factRow(IconData icon, String label, String value) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: text.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '—' : value,
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget peopleCard(
      String title,
      List<String> names, {
      required IconData icon,
    }) {
      if (names.isEmpty) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...names.map(
              (name) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    name,
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message info'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.50),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (previewTitle.trim().isNotEmpty)
                  Text(
                    previewTitle.trim(),
                    style: text.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                    ),
                  ),
                if (previewTitle.trim().isNotEmpty) const SizedBox(height: 6),
                Text(
                  previewBody.trim().isEmpty ? '(empty)' : previewBody.trim(),
                  style: text.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (previewMeta.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    previewMeta.trim(),
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.22),
              ),
            ),
            child: Column(
              children: [
                factRow(Icons.schedule_rounded, 'Status', statusLabel()),
                const SizedBox(height: 14),
                factRow(Icons.access_time_rounded, 'Status time', statusTime()),
                const SizedBox(height: 14),
                factRow(
                  Icons.send_rounded,
                  'Sent at',
                  info.sentAt.trim(),
                ),
                if (info.deliveredAt.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  factRow(
                    Icons.done_rounded,
                    'Delivered at',
                    info.deliveredAt.trim(),
                  ),
                ],
                if (info.seenAt.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  factRow(
                    Icons.done_all_rounded,
                    'Seen at',
                    info.seenAt.trim(),
                  ),
                ],
                const SizedBox(height: 14),
                factRow(
                  Icons.category_rounded,
                  'Message type',
                  info.messageType.trim(),
                ),
                const SizedBox(height: 14),
                factRow(
                  Icons.edit_rounded,
                  'Edited',
                  info.edited ? 'Yes' : 'No',
                ),
                const SizedBox(height: 14),
                factRow(
                  Icons.forward_rounded,
                  'Forwarded',
                  info.forwarded ? 'Yes' : 'No',
                ),
                if (info.voiceDuration.trim().isNotEmpty) ...[
                  const SizedBox(height: 14),
                  factRow(
                    Icons.mic_rounded,
                    'Voice duration',
                    info.voiceDuration.trim(),
                  ),
                ],
              ],
            ),
          ),
          if (seenByNames.isNotEmpty) ...[
            const SizedBox(height: 14),
            peopleCard(
              'Seen by',
              seenByNames,
              icon: Icons.visibility_rounded,
            ),
          ],
          if (deliveredToNames.isNotEmpty) ...[
            const SizedBox(height: 14),
            peopleCard(
              'Delivered to',
              deliveredToNames,
              icon: Icons.mark_email_read_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

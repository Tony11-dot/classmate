// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';

class TeacherNewAnnouncementScreen extends ConsumerStatefulWidget {
  const TeacherNewAnnouncementScreen({super.key});

  @override
  ConsumerState<TeacherNewAnnouncementScreen> createState() =>
      _TeacherNewAnnouncementScreenState();
}

class _TeacherNewAnnouncementScreenState
    extends ConsumerState<TeacherNewAnnouncementScreen> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  bool _pinned = false;
  String _targetRole = 'STUDENT';
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and message are required')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(teacherMobileRepositoryProvider).createAnnouncement(
        title: title,
        body: body,
        targetRole: _targetRole,
        pinned: _pinned,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement published')),
      );
      if (context.canPop()) context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primaryContainer.withValues(alpha: 0.72),
                    cs.surfaceContainerHigh.withValues(alpha: 0.78),
                  ],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: cs.surface.withValues(alpha: 0.6),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'New Announcement',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _saving ? null : _publish,
                    icon: _saving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(_saving ? 'Publishing…' : 'Publish'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                children: [
                  LiquidGlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(20),
                    blurSigma: 14,
                    color: cs.surface.withValues(alpha: 0.82),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Announcement', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _titleCtrl,
                          decoration: InputDecoration(
                            labelText: 'Title *',
                            hintText: 'e.g. School event tomorrow',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _bodyCtrl,
                          decoration: InputDecoration(
                            labelText: 'Message *',
                            hintText: 'Write the full announcement here…',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                            alignLabelWithHint: true,
                          ),
                          minLines: 5,
                          maxLines: 10,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  LiquidGlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(20),
                    blurSigma: 14,
                    color: cs.surface.withValues(alpha: 0.82),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Audience', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _AudienceChip(
                              label: 'Students',
                              icon: Icons.school_rounded,
                              selected: _targetRole == 'STUDENT',
                              onTap: () => setState(() => _targetRole = 'STUDENT'),
                            ),
                            _AudienceChip(
                              label: 'Parents',
                              icon: Icons.family_restroom_rounded,
                              selected: _targetRole == 'PARENT',
                              onTap: () => setState(() => _targetRole = 'PARENT'),
                            ),
                            _AudienceChip(
                              label: 'Teachers',
                              icon: Icons.person_rounded,
                              selected: _targetRole == 'TEACHER',
                              onTap: () => setState(() => _targetRole = 'TEACHER'),
                            ),
                            _AudienceChip(
                              label: 'Everyone',
                              icon: Icons.groups_rounded,
                              selected: _targetRole == 'ALL',
                              onTap: () => setState(() => _targetRole = 'ALL'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SwitchListTile(
                          value: _pinned,
                          onChanged: (v) => setState(() => _pinned = v),
                          title: const Text('Pin announcement', style: TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: const Text('Pinned announcements appear at the top'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudienceChip extends StatelessWidget {
  const _AudienceChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? cs.primary.withValues(alpha: 0.5) : cs.outlineVariant.withValues(alpha: 0.3),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: selected ? cs.primary : cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

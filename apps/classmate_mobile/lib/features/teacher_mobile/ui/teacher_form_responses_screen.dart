// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';

class TeacherFormResponsesScreen extends ConsumerStatefulWidget {
  const TeacherFormResponsesScreen({
    super.key,
    required this.formId,
    required this.formTitle,
  });

  final String formId;
  final String formTitle;

  @override
  ConsumerState<TeacherFormResponsesScreen> createState() =>
      _TeacherFormResponsesScreenState();
}

class _TeacherFormResponsesScreenState
    extends ConsumerState<TeacherFormResponsesScreen> {
  List<Map<String, dynamic>> _responses = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final responses = await ref
          .read(teacherMobileRepositoryProvider)
          .formResponses(widget.formId);
      if (!mounted) return;
      setState(() {
        _responses = responses;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.formTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${_responses.length} response${_responses.length == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
            tooltip: AppLocalizations.of(context)!.commonRefresh,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CmLoading())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _load, child: Text(AppLocalizations.of(context)!.commonRetry)),
                    ],
                  ),
                )
              : _responses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.assignment_turned_in_outlined,
                            size: 64,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'No responses yet',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Responses will appear here once students submit.',
                            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                      itemCount: _responses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final r = _responses[i];
                        final name = r['studentName'] as String? ?? 'Student';
                        final submittedAt = r['submittedAt'] as String? ?? '';
                        final answers = r['answers'];

                        final dateStr = submittedAt.isNotEmpty
                            ? submittedAt.split('T').first
                            : '';

                        return LiquidGlassCard(
                          padding: const EdgeInsets.all(20),
                          borderRadius: BorderRadius.circular(22),
                          color: cs.surfaceContainerLow,
                          border: Border.all(color: cs.outlineVariant),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header row
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: cs.primaryContainer,
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : 'S',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: cs.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                        ),
                                        if (dateStr.isNotEmpty)
                                          Text(
                                            'Submitted $dateStr',
                                            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: cs.primaryContainer,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${i + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                        color: cs.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              if (answers is Map && answers.isNotEmpty) ...[
                                const SizedBox(height: 18),
                                Divider(color: cs.outlineVariant),
                                const SizedBox(height: 12),
                                ...answers.entries.map((entry) {
                                  final q = entry.key.toString();
                                  final a = entry.value;
                                  final answerText = a is List
                                      ? a.join(', ')
                                      : a?.toString() ?? '—';
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          q,
                                          style: theme.textTheme.labelLarge?.copyWith(
                                            color: cs.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          decoration: BoxDecoration(
                                            color: cs.surfaceContainerLow,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: cs.outlineVariant),
                                          ),
                                          child: Text(
                                            answerText.isEmpty ? '—' : answerText,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: answerText.isEmpty ? cs.onSurfaceVariant : cs.onSurface,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}

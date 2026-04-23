import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/forms_repository.dart';
import 'domain/form_models.dart';
import '../../ui/glass/liquid_glass_card.dart';

class FormDetailScreen extends ConsumerStatefulWidget {
  const FormDetailScreen({
    super.key,
    required this.formId,
    this.initialForm,
  });

  final String formId;
  final StudentFormItem? initialForm;

  @override
  ConsumerState<FormDetailScreen> createState() => _FormDetailScreenState();
}

class _FormDetailScreenState extends ConsumerState<FormDetailScreen> {
  final Map<String, dynamic> _answers = <String, dynamic>{};
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    if (widget.initialForm != null) {
      return _buildScaffold(context, widget.initialForm!);
    }

    final asyncForms = ref.watch(formsLiveProvider);
    return asyncForms.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Form')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load this form right now.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (forms) {
        final form = forms.cast<StudentFormItem?>().firstWhere(
          (item) => item?.id == widget.formId,
          orElse: () => ref.read(formsRepositoryProvider).byId(widget.formId),
        );
        if (form == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Form')),
            body: const Center(child: Text('Form not found')),
          );
        }
        return _buildScaffold(context, form);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, StudentFormItem form) {

    final cs = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(form.title),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Questions'),
              Tab(text: 'Responses'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _FormHero(form: form),
                const SizedBox(height: 16),
                ...form.questions.map((q) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _QuestionCard(
                        question: q,
                        answer: _answers[q.id],
                        onChanged: (value) {
                          setState(() {
                            _answers[q.id] = value;
                          });
                        },
                      ),
                    )),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: form.acceptingResponses ? () => _submit(context, form) : null,
                  icon: const Icon(Icons.send_rounded),
                  label: Text(_submitted ? 'Submitted' : 'Submit form'),
                ),
                if (!form.acceptingResponses) ...[
                  const SizedBox(height: 10),
                  Text(
                    'This form is closed and no longer accepts responses.',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ],
              ],
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _ResponsesSummaryCard(form: form),
                const SizedBox(height: 16),
                ...form.questions.map((q) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _StatsCard(question: q),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context, StudentFormItem form) {
    for (final question in form.questions) {
      final value = _answers[question.id];
      if (!question.required) continue;
      switch (question.type) {
        case StudentFormQuestionType.checkboxes:
          if (value is! Set<String> || value.isEmpty) {
            _showRequired(context, question.title);
            return;
          }
        case StudentFormQuestionType.shortAnswer:
        case StudentFormQuestionType.paragraph:
        case StudentFormQuestionType.multipleChoice:
        case StudentFormQuestionType.dropdown:
          if ((value?.toString() ?? '').trim().isEmpty) {
            _showRequired(context, question.title);
            return;
          }
        case StudentFormQuestionType.linearScale:
          if (value is! int) {
            _showRequired(context, question.title);
            return;
          }
      }
    }

    setState(() {
      _submitted = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form submitted')),
    );
  }

  void _showRequired(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Required: $title')),
    );
  }
}

class _FormHero extends StatelessWidget {
  const _FormHero({required this.form});

  final StudentFormItem form;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LiquidGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      blurSigma: 16,
      color: cs.surfaceContainerHigh.withValues(alpha: 0.82),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  form.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (form.acceptingResponses ? cs.primaryContainer : cs.surfaceContainerHighest)
                          .withValues(alpha: 0.94),
                      cs.surface.withValues(alpha: 0.58),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.14)),
                ),
                child: Text(
                  form.acceptingResponses ? 'Accepting responses' : 'Closed',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: form.acceptingResponses ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(form.description, style: TextStyle(color: cs.onSurfaceVariant, height: 1.4)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.subject_rounded, label: form.subject),
              _MetaChip(icon: Icons.person_outline_rounded, label: form.teacher),
              _MetaChip(icon: Icons.groups_rounded, label: form.audienceLabel),
              _MetaChip(icon: Icons.quiz_outlined, label: '${form.questionCount} questions'),
              _MetaChip(icon: Icons.publish_rounded, label: form.summary.publishedLabel),
              _MetaChip(
                icon: Icons.repeat_rounded,
                label: form.allowMultipleResponses ? 'Multiple submissions allowed' : '1 response per student',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surfaceContainerHighest.withValues(alpha: 0.92),
            cs.surface.withValues(alpha: 0.58),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: cs.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.answer,
    required this.onChanged,
  });

  final StudentFormQuestion question;
  final dynamic answer;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(22),
      blurSigma: 12,
      color: cs.surface.withValues(alpha: 0.84),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  question.title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              if (question.required)
                Text(
                  'Required',
                  style: TextStyle(
                    color: cs.error,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          if ((question.description ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              question.description!,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 14),
          _buildField(context),
        ],
      ),
    );
  }

  Widget _buildField(BuildContext context) {
    switch (question.type) {
      case StudentFormQuestionType.shortAnswer:
        return TextFormField(
          initialValue: answer?.toString() ?? '',
          onChanged: onChanged,
          decoration: const InputDecoration(hintText: 'Your answer'),
        );
      case StudentFormQuestionType.paragraph:
        return TextFormField(
          initialValue: answer?.toString() ?? '',
          onChanged: onChanged,
          minLines: 4,
          maxLines: 7,
          decoration: const InputDecoration(hintText: 'Long answer text'),
        );
      case StudentFormQuestionType.multipleChoice:
        return RadioGroup<String>(
          groupValue: answer?.toString(),
          onChanged: (value) => onChanged(value),
          child: Column(
            children: question.options
                .map(
                  (option) => RadioListTile<String>(
                    value: option,
                    contentPadding: EdgeInsets.zero,
                    title: Text(option),
                  ),
                )
                .toList(),
          ),
        );
      case StudentFormQuestionType.checkboxes:
        final selected = answer is Set<String> ? answer : <String>{};
        return Column(
          children: question.options
              .map(
                (option) => CheckboxListTile(
                  value: selected.contains(option),
                  onChanged: (checked) {
                    final next = <String>{...selected};
                    if (checked ?? false) {
                      next.add(option);
                    } else {
                      next.remove(option);
                    }
                    onChanged(next);
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text(option),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              )
              .toList(),
        );
      case StudentFormQuestionType.dropdown:
        return DropdownButtonFormField<String>(
          initialValue: answer?.toString().isEmpty ?? true
              ? null
              : answer.toString(),
          decoration: const InputDecoration(),
          items: question.options
              .map((option) => DropdownMenuItem<String>(value: option, child: Text(option)))
              .toList(),
          onChanged: onChanged,
        );
      case StudentFormQuestionType.linearScale:
        final selected = answer is int ? answer : null;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = question.minScale; i <= question.maxScale; i++)
              ChoiceChip(
                label: Text('$i'),
                selected: selected == i,
                onSelected: (_) => onChanged(i),
              ),
          ],
        );
    }
  }
}

class _ResponsesSummaryCard extends StatelessWidget {
  const _ResponsesSummaryCard({required this.form});

  final StudentFormItem form;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final completionPercent = (form.summary.completionRate * 100).round();

    return LiquidGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      blurSigma: 16,
      color: cs.surfaceContainerHigh.withValues(alpha: 0.82),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Response stats',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _StatTile(label: 'Responses', value: '${form.summary.responsesCount}')),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(label: 'Pending', value: '${form.summary.pendingCount}')),
              const SizedBox(width: 10),
              Expanded(child: _StatTile(label: 'Avg time', value: form.summary.averageDurationLabel)),
            ],
          ),
          const SizedBox(height: 14),
          Text('Completion', style: TextStyle(color: cs.onSurfaceVariant)),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: form.summary.completionRate, minHeight: 10),
          const SizedBox(height: 6),
          Text('$completionPercent% completed', style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(18),
      blurSigma: 10,
      color: cs.surface.withValues(alpha: 0.82),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.question});

  final StudentFormQuestion question;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(22),
      blurSigma: 12,
      color: cs.surface.withValues(alpha: 0.84),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 10),
          if (question.type == StudentFormQuestionType.paragraph ||
              question.type == StudentFormQuestionType.shortAnswer) ...[
            if (question.stats.textSamples.isEmpty)
              Text('No text responses yet.', style: TextStyle(color: cs.onSurfaceVariant)),
            ...question.stats.textSamples.map(
              (sample) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LiquidGlassCard(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(16),
                  blurSigma: 8,
                  color: cs.surfaceContainerHigh.withValues(alpha: 0.78),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.12)),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(sample),
                  ),
                ),
              ),
            ),
          ] else if (question.type == StudentFormQuestionType.linearScale) ...[
            Text(
              'Average score: ${question.stats.averageScale?.toStringAsFixed(1) ?? '-'}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ] else ...[
            ...question.stats.choiceStats.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(entry.label)),
                        Text('${(entry.fraction * 100).round()}%'),
                        const SizedBox(width: 8),
                        Text('${entry.count}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(value: entry.fraction, minHeight: 8),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

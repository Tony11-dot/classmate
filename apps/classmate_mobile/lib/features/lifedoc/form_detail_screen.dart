// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/app_localizations.dart';
import 'data/forms_repository.dart';
import 'domain/form_models.dart';
import '../../core/theme/cm_tokens.dart';
import '../../ui/widgets/cm_loading.dart';
import '../../ui/widgets/liquid_glass_dropdown.dart';

// ── Persisted submission tracking ─────────────────────────────────────────────
// Key: 'form_submitted:$formId' → JSON-encoded map of questionId → answer.
// Only written for once-per-student forms.

String _submittedPrefKey(String formId) => 'form_submitted:$formId';

Future<Map<String, dynamic>?> _loadSavedAnswers(String formId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_submittedPrefKey(formId));
    if ((raw ?? '').isEmpty) return null;
    final decoded = jsonDecode(raw!);
    if (decoded is! Map) return null;
    return Map<String, dynamic>.from(decoded);
  } catch (_) {
    return null;
  }
}

Future<void> _saveSubmittedAnswers(
  String formId,
  Map<String, dynamic> answers,
) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_submittedPrefKey(formId), jsonEncode(answers));
  } catch (_) {}
}

class FormDetailScreen extends ConsumerStatefulWidget {
  const FormDetailScreen({super.key, required this.formId, this.initialForm});

  final String formId;
  final StudentFormItem? initialForm;

  @override
  ConsumerState<FormDetailScreen> createState() => _FormDetailScreenState();
}

class _FormDetailScreenState extends ConsumerState<FormDetailScreen> {
  final Map<String, dynamic> _answers = <String, dynamic>{};
  // savedAnswers is non-null when the form was previously submitted (once-form).
  Map<String, dynamic>? _savedAnswers;
  bool _submitted = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _initSavedState();
  }

  Future<void> _initSavedState() async {
    final saved = await _loadSavedAnswers(widget.formId);
    if (!mounted) return;
    if (saved != null) {
      setState(() {
        _savedAnswers = saved;
        _submitted = true;
        _answers.addAll(saved);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialForm != null) {
      return _buildScaffold(context, widget.initialForm!);
    }

    final asyncForms = ref.watch(formsLiveProvider);
    return asyncForms.when(
      loading: () => const Scaffold(body: Center(child: CmLoading())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text(AppLocalizations.of(context)!.formTitle),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              AppLocalizations.of(context)!.formDetailScreenCouldNotLoad,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (forms) {
        final form = forms.cast<StudentFormItem?>().firstWhere(
          (item) => item?.id == widget.formId,
          orElse: () => null,
        );
        if (form == null) {
          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              title: Text(AppLocalizations.of(context)!.formTitle),
            ),
            body: Center(
              child: Text(AppLocalizations.of(context)!.formNotFound),
            ),
          );
        }
        return _buildScaffold(context, form);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, StudentFormItem form) {
    final cs = Theme.of(context).colorScheme;

    // Students see only the Questions tab (no Responses).
    // The form is always shown as a single-tab view for students.
    return Scaffold(
      appBar: AppBar(
        // Explicit back/chevron button so students can leave without submitting
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          tooltip: AppLocalizations.of(context)!.commonBack,
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          form.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _FormHero(form: form),
          const SizedBox(height: 16),
          if (_savedAnswers != null && !form.allowMultipleResponses) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: CmTokens.of(context).good.withValues(
                  alpha: cs.brightness == Brightness.dark ? 0.18 : 0.10,
                ),
                borderRadius: BorderRadius.circular(CmTokens.radiusMd),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: CmTokens.of(context).good,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.studentFormSubmittedBanner,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          for (final (i, q) in form.questions.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _QuestionCard(
                number: i + 1,
                question: q,
                answer: _answers[q.id],
                onChanged: _savedAnswers != null && !form.allowMultipleResponses
                    ? null
                    : (v) => setState(() => _answers[q.id] = v),
              ),
            ),
          const SizedBox(height: 8),
          // ── Submit button ───────────────────────────────────────────────────
          // Disabled after submit (or if form is closed, or allowMultipleResponses==false and already submitted)
          _SubmitSection(
            form: form,
            submitted: _submitted,
            submitting: _submitting,
            onSubmit: () => _submit(context, form),
          ),
          if (!form.acceptingResponses) ...[
            const SizedBox(height: 10),
            Text(
              AppLocalizations.of(context)!.formClosed,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, StudentFormItem form) async {
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

    setState(() => _submitting = true);

    try {
      final serialized = Map<String, dynamic>.fromEntries(
        _answers.entries.map((e) {
          final v = e.value;
          return MapEntry(e.key, v is Set ? v.toList() : v);
        }),
      );
      final result = await ref
          .read(formsRepositoryProvider)
          .submit(form.id, serialized);
      if (!mounted) return;
      if (result['ok'] == true) {
        setState(() {
          _submitted = true;
          _savedAnswers = serialized;
        });
        // Persist so the button stays locked on re-open (once-forms only).
        if (!form.allowMultipleResponses) {
          await _saveSubmittedAnswers(form.id, serialized);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              (result['message'] ??
                      AppLocalizations.of(context)!.formDetailScreenSubmitted)
                  .toString(),
            ),
          ),
        );
      } else {
        final error =
            (result['error'] ??
                    AppLocalizations.of(
                      context,
                    )!.formDetailScreenSubmissionFailed)
                .toString();
        if (error.toLowerCase().contains('already')) {
          setState(() {
            _submitted = true;
            _savedAnswers = serialized;
          });
          if (!form.allowMultipleResponses) {
            await _saveSubmittedAnswers(form.id, serialized);
          }
          // No snackbar — button is already locked, user sees "Already submitted" UI.
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.studentFormSubmitError(e.toString()),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showRequired(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.studentFormFieldRequired(title),
        ),
      ),
    );
  }
}

// ── Submit section — handles once-per-student logic ──────────────────────────

final ButtonStyle _submitStyle = FilledButton.styleFrom(
  minimumSize: const Size.fromHeight(52),
);

/// Fill for tiles nested inside a surfaceContainerLow card.
Color _innerBg(ColorScheme cs) =>
    cs.brightness == Brightness.dark ? cs.surfaceContainerHigh : cs.surface;

class _SubmitSection extends StatelessWidget {
  const _SubmitSection({
    required this.form,
    required this.submitted,
    required this.submitting,
    required this.onSubmit,
  });

  final StudentFormItem form;
  final bool submitted;
  final bool submitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // If the form is closed, show disabled button
    if (!form.acceptingResponses) {
      return FilledButton.icon(
        style: _submitStyle,
        onPressed: null,
        icon: const Icon(Icons.lock_outline_rounded),
        label: Text(AppLocalizations.of(context)!.studentFormClosedButton),
      );
    }

    // If once-per-student and already submitted, show "Already submitted"
    if (!form.allowMultipleResponses && submitted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            style: _submitStyle,
            onPressed: null,
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: Text(
              AppLocalizations.of(context)!.studentFormAlreadySubmittedButton,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.formDetailScreenAlreadySubmittedNote,
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
          ),
        ],
      );
    }

    return FilledButton.icon(
      style: _submitStyle,
      onPressed: submitting ? null : onSubmit,
      icon: submitting
          ? const CmLoading(size: 18)
          : const Icon(Icons.send_rounded),
      label: Text(
        submitting
            ? AppLocalizations.of(context)!.formDetailScreenSubmitting
            : submitted
            ? AppLocalizations.of(context)!.formDetailScreenSubmitAgain
            : AppLocalizations.of(context)!.formDetailScreenSubmitForm,
      ),
    );
  }
}

// ── Form hero ────────────────────────────────────────────────────────────────

class _FormHero extends StatelessWidget {
  const _FormHero({required this.form});

  final StudentFormItem form;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final accepting = form.acceptingResponses;
    final good = CmTokens.of(context).good;
    final dark = cs.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CmTokens.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            cs.primary.withValues(alpha: dark ? 0.20 : 0.10),
            cs.surfaceContainerLow,
          ],
        ),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
          width: 0.8,
        ),
        boxShadow: CmTokens.of(context).shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(CmTokens.radiusSm),
                ),
                child: Icon(
                  Icons.assignment_rounded,
                  color: cs.onPrimary,
                  size: 22,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: accepting
                      ? good.withValues(alpha: dark ? 0.20 : 0.12)
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      accepting ? Icons.circle : Icons.lock_outline_rounded,
                      size: accepting ? 8 : 13,
                      color: accepting ? good : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      accepting
                          ? AppLocalizations.of(context)!.formAccepting
                          : AppLocalizations.of(context)!.formClosed,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            form.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          if (form.description.trim().isNotEmpty)
            Text(
              form.description,
              style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
            ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _MetaChip(icon: Icons.subject_rounded, label: form.subject),
              _MetaChip(
                icon: Icons.person_outline_rounded,
                label: form.teacher,
              ),
              _MetaChip(icon: Icons.groups_rounded, label: form.audienceLabel),
              _MetaChip(
                icon: Icons.quiz_outlined,
                label: AppLocalizations.of(
                  context,
                )!.formDetailScreenQuestionCount(form.questionCount),
              ),
              _MetaChip(
                icon: Icons.publish_rounded,
                label: form.summary.publishedLabel,
              ),
              _MetaChip(
                icon: Icons.repeat_rounded,
                label: form.allowMultipleResponses
                    ? AppLocalizations.of(context)!.formDetailScreenMultiSubmit
                    : AppLocalizations.of(
                        context,
                      )!.formDetailScreenOnePerStudent,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _innerBg(cs),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
                color: cs.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.number,
    required this.question,
    required this.answer,
    required this.onChanged,
  });

  final int number;
  final StudentFormQuestion question;
  final dynamic answer;
  // Null means read-only (form already submitted).
  final ValueChanged<dynamic>? onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(CmTokens.radiusLg),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
          width: 0.8,
        ),
        boxShadow: CmTokens.of(context).shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(
                    alpha: cs.brightness == Brightness.dark ? 0.22 : 0.12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: cs.primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    question.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (question.required)
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 8, top: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cs.error.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.formDetailScreenRequired,
                    style: TextStyle(
                      color: cs.error,
                      fontWeight: FontWeight.w800,
                      fontSize: 11.5,
                    ),
                  ),
                ),
            ],
          ),
          if ((question.description ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 38),
              child: Text(
                question.description!,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ),
          ],
          const SizedBox(height: 14),
          _buildField(context),
        ],
      ),
    );
  }

  Widget _buildField(BuildContext context) {
    final readOnly = onChanged == null;
    switch (question.type) {
      case StudentFormQuestionType.shortAnswer:
        return TextFormField(
          initialValue: answer?.toString() ?? '',
          onChanged: readOnly ? null : onChanged,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: readOnly
                ? null
                : AppLocalizations.of(context)!.formDetailScreenYourAnswer,
          ),
        );
      case StudentFormQuestionType.paragraph:
        return TextFormField(
          initialValue: answer?.toString() ?? '',
          onChanged: readOnly ? null : onChanged,
          readOnly: readOnly,
          minLines: 4,
          maxLines: 7,
          decoration: InputDecoration(
            hintText: readOnly
                ? null
                : AppLocalizations.of(context)!.formDetailScreenLongAnswerText,
          ),
        );
      case StudentFormQuestionType.multipleChoice:
        return RadioGroup<String>(
          groupValue: answer?.toString(),
          onChanged: readOnly
              ? (_) {}
              : (value) {
                  if (value != null) onChanged!(value);
                },
          child: Column(
            children: question.options
                .map(
                  (option) => _OptionTile(
                    selected: answer?.toString() == option,
                    child: RadioListTile<String>(
                      value: option,
                      dense: true,
                      contentPadding: const EdgeInsetsDirectional.only(
                        start: 4,
                        end: 12,
                      ),
                      title: Text(option),
                    ),
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
                (option) => _OptionTile(
                  selected: selected.contains(option),
                  child: CheckboxListTile(
                    dense: true,
                    value: selected.contains(option),
                    onChanged: readOnly
                        ? null
                        : (checked) {
                            final next = <String>{...selected};
                            if (checked ?? false) {
                              next.add(option);
                            } else {
                              next.remove(option);
                            }
                            onChanged!(next);
                          },
                    contentPadding: const EdgeInsetsDirectional.only(
                      start: 4,
                      end: 12,
                    ),
                    title: Text(option),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              )
              .toList(),
        );
      case StudentFormQuestionType.dropdown:
        return LiquidGlassDropdown<String>(
          label: question.title.trim().isNotEmpty
              ? question.title
              : AppLocalizations.of(context)!.formDetailScreenSelect,
          value: (answer?.toString().isEmpty ?? true) ? '' : answer.toString(),
          items: question.options
              .map(
                (option) =>
                    LiquidGlassDropdownItem(value: option, label: option),
              )
              .toList(),
          onChanged: readOnly
              ? (_) {}
              : (v) {
                  if (onChanged != null) onChanged!(v.isEmpty ? null : v);
                },
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
                onSelected: readOnly ? null : (_) => onChanged!(i),
              ),
          ],
        );
    }
  }
}

/// Rounded option row for choice questions; tints when selected.
class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.selected, required this.child});

  final bool selected;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = cs.brightness == Brightness.dark;
    return AnimatedContainer(
      duration: CmTokens.medium,
      curve: CmTokens.easeOut,
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: selected
            ? cs.primary.withValues(alpha: dark ? 0.20 : 0.10)
            : _innerBg(cs),
        borderRadius: BorderRadius.circular(CmTokens.radiusMd),
        border: Border.all(
          color: selected
              ? cs.primary
              : cs.outlineVariant.withValues(alpha: 0.5),
          width: selected ? 1.4 : 0.8,
        ),
      ),
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/cm_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/widgets/cm_press.dart';

import '../../domain/practice_models.dart';
import '../../providers/practice_providers.dart';
import '../../providers/saved_questions_provider.dart';
import '../practice_mode_specs.dart';
import '../practice_display_text.dart';
import '../../../tutor/ui/nova_chat_screen.dart';
import '../../../../common/widgets/cm_ai_message.dart';

typedef SessionResetFn = void Function();

bool _isDark(ColorScheme cs) => cs.brightness == Brightness.dark;

/// Soft accent wash used for banners / selected states. Never a solid fill —
/// accent text and icons sit on top of it and must stay readable.
Color _accentWash(ColorScheme cs, Color accent, {double light = 0.10, double dark = 0.18}) {
  return accent.withValues(alpha: _isDark(cs) ? dark : light);
}

/// Inner panel that sits on the question card (prompt, flashcard face).
Color _innerPanelBg(ColorScheme cs) =>
    _isDark(cs) ? cs.surfaceContainerHigh : cs.surface;

/// Foreground that's guaranteed to contrast with a saturated accent fill.
/// White if the accent is dark enough; black-ish otherwise.
Color _onAccent(Color accent) {
  return accent.computeLuminance() < 0.5 ? Colors.white : Colors.black87;
}

class ModeContextData {
  final BuildContext context;
  final WidgetRef ref;
  final PracticeSessionState state;
  final PracticeSessionController sessionCtl;
  final PracticeQuestion? q;
  final List<String> options;
  final int? selectedIndex;
  final bool showExplanation;
  final ValueChanged<int?> onSelected;
  final ValueChanged<bool> onShowExplanation;
  final SessionResetFn resetTransientUi;

  const ModeContextData({
    required this.context,
    required this.ref,
    required this.state,
    required this.sessionCtl,
    required this.q,
    required this.options,
    required this.selectedIndex,
    required this.showExplanation,
    required this.onSelected,
    required this.onShowExplanation,
    required this.resetTransientUi,
  });

  bool get answered {
    final id = q?.id;
    if (id == null) return false;
    return state.answersByQuestionId.containsKey(id);
  }

  String get topicText => state.filter.topicPath.isEmpty
      ? AppLocalizations.of(context)!.practiceSessionGeneralTopic
      : state.filter.topicPath.join(' • ');

  String get topicDisplayText => localizedPracticeTopicPath(
        context,
        state.filter.topicPath,
      ).replaceAll(' · ', ' • ');

  String get subjectDisplayText => localizedPracticeSubject(
        context,
        state.filter.subject,
      );

  Color get accent => practiceModeColor(state.filter.mode);

  ThemeData get theme => Theme.of(context);
  ColorScheme get cs => theme.colorScheme;

  double get sessionProgress => state.questions.isEmpty
      ? 0
      : ((state.currentIndex + 1) / state.questions.length).clamp(0.0, 1.0);

  String get progressLabel => state.questions.isEmpty
      ? '0 / 0'
      : '${state.currentIndex + 1} / ${state.questions.length}';

  bool? get lastSubmittedCorrect => state.lastResult?.isCorrect;

  String promptOf() =>
      (q?.prompt ?? AppLocalizations.of(context)!.practiceModeFallbackQuestion)
          .toString();

  String explanationOf() {
    final txt = (q?.explanation ?? '').toString().trim();
    return txt.isEmpty
        ? AppLocalizations.of(context)!.practiceModeNoExplanationYet
        : txt;
  }

  Future<void> openNova() async {
    final optionsText = options
        .asMap()
        .entries
        .map((e) => '${String.fromCharCode(65 + e.key)}. ${e.value}')
        .join('\n');

    final prompt =
        '''
  Mode: ${practiceModeLabel(context, state.filter.mode)}
Subject: ${state.filter.subject}
Topic: $topicText
Difficulty: ${state.filter.difficulty}
Question:
${promptOf()}

Options:
$optionsText

Known explanation / context:
${explanationOf()}

Stay strictly inside the same subject/topic. Help the student solve this exact question.
''';

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NovaChatScreen(
          initialTitle:
              '${practiceModeLabel(context, state.filter.mode)} · $subjectDisplayText',
          initialPrompt: prompt,
        ),
      ),
    );
  }

  void submitOrNext() {
    if (q == null) return;
    if (!answered) {
      if (selectedIndex == null) return;
      sessionCtl.submit(selectedIndex!);
      onShowExplanation(true);

      final result = ref.read(practiceSessionProvider).lastResult;
      if (result != null) {
        if (result.isCorrect) {
          HapticFeedback.lightImpact();
        } else {
          HapticFeedback.mediumImpact();
        }
      }
      return;
    }
    sessionCtl.nextQuestion();
    resetTransientUi();
  }

  void previous() {
    sessionCtl.previousQuestion();
    resetTransientUi();
  }

  void next() {
    sessionCtl.nextQuestion();
    resetTransientUi();
  }

  void end() {
    sessionCtl.endWithoutRewards();
  }
}


/// Accent-washed strip with a filled icon badge — the one banner shape every
/// mode uses (speed round, exam prep, adaptive, bagrut, concept builder).
Widget modeInfoStrip(
  ModeContextData d, {
  required IconData icon,
  required String text,
  String? subtitle,
  Widget? trailing,
}) {
  final cs = d.cs;
  final accent = d.accent;
  return Container(
    width: double.infinity,
    padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 14, 10),
    decoration: BoxDecoration(
      color: _accentWash(cs, accent),
      borderRadius: BorderRadius.circular(CmTokens.radiusMd),
    ),
    child: Row(
      crossAxisAlignment: subtitle == null
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          child: Icon(icon, size: 17, color: _onAccent(accent)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: d.theme.textTheme.labelLarge?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: d.theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.25,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ],
    ),
  );
}

Widget modeBanner(ModeContextData d) {
  return modeInfoStrip(
    d,
    icon: practiceModeIcon(d.state.filter.mode),
    text: practiceModeLabel(d.context, d.state.filter.mode),
    subtitle: practiceModeDescription(d.context, d.state.filter.mode),
  );
}

Widget sessionProgressStrip(ModeContextData d) {
  final streak = d.state.stats.streak;
  final streakActive = streak > 1;
  final cs = d.cs;

  return Row(
    children: [
      Text(
        d.progressLabel,
        style: d.theme.textTheme.labelLarge?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w800,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: d.sessionProgress.toDouble()),
            duration: CmTokens.medium,
            curve: CmTokens.easeOut,
            builder: (_, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(d.accent),
            ),
          ),
        ),
      ),
      const SizedBox(width: 10),
      AnimatedContainer(
        duration: CmTokens.medium,
        curve: CmTokens.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: streakActive
              ? CmTokens.of(d.context).warnContainer
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              size: 15,
              color: streakActive
                  ? CmTokens.of(d.context).warn
                  : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 3),
            Text(
              '$streak',
              style: d.theme.textTheme.labelMedium?.copyWith(
                color: streakActive ? cs.onSurface : cs.onSurfaceVariant,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget questionCard(
  ModeContextData d, {
  required Widget child,
  EdgeInsets padding = const EdgeInsets.all(18),
}) {
  final cs = d.cs;
  return Container(
    padding: padding,
    decoration: BoxDecoration(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(CmTokens.radiusXl),
      border: Border.all(
        color: cs.outlineVariant.withValues(alpha: 0.35),
        width: 0.8,
      ),
      boxShadow: CmTokens.of(d.context).shadowSm,
    ),
    child: child,
  );
}

Widget defaultQuestionHeader(ModeContextData d) {
  final cs = d.theme.colorScheme;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: d.accent,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  practiceModeIcon(d.state.filter.mode),
                  size: 14,
                  color: _onAccent(d.accent),
                ),
                const SizedBox(width: 5),
                Text(
                  practiceModeLabel(d.context, d.state.filter.mode),
                  style: d.theme.textTheme.labelMedium?.copyWith(
                    color: _onAccent(d.accent),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              localizedPracticeTopicLabel(
                d.context,
                d.state.filter.topicLabel,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: d.theme.textTheme.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      questionPromptPanel(d),
    ],
  );
}

Widget questionPromptPanel(ModeContextData d, {bool withSave = true}) {
  final cs = d.theme.colorScheme;

  return Container(
    width: double.infinity,
    padding: withSave
        ? const EdgeInsetsDirectional.fromSTEB(18, 8, 6, 18)
        : const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: _innerPanelBg(cs),
      borderRadius: BorderRadius.circular(CmTokens.radiusLg),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (withSave)
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: saveQuestionButton(d),
          ),
        Padding(
          padding: EdgeInsetsDirectional.only(end: withSave ? 12 : 0),
          child: CMAiMessage(
            d.promptOf(),
            compact: true,
            textStyle: d.theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.28,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Bookmark toggle that stores/removes the current question in the
/// Saved Questions tab. Reactive to [savedQuestionsProvider] so the icon
/// reflects saved state immediately. Renders nothing when there's no question.
Widget saveQuestionButton(ModeContextData d) {
  final q = d.q;
  if (q == null) return const SizedBox.shrink();
  final l = AppLocalizations.of(d.context)!;
  final saved = d.ref
      .watch(savedQuestionsProvider)
      .any((x) => x.id == q.id);

  return IconButton(
    visualDensity: VisualDensity.compact,
    tooltip: saved
        ? l.practiceModeActionSavedQuestion
        : l.practiceModeActionSaveQuestion,
    onPressed: () {
      d.ref.read(savedQuestionsProvider.notifier).toggle(q);
      HapticFeedback.selectionClick();
      final messenger = ScaffoldMessenger.of(d.context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          content: Text(
            saved
                ? l.practiceModeQuestionRemovedToast
                : l.practiceModeQuestionSavedToast,
          ),
        ),
      );
    },
    icon: Icon(
      saved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
      color: saved ? d.accent : d.cs.onSurfaceVariant,
    ),
  );
}

class ModeAnswerTile extends StatelessWidget {
  final String label;
  final bool selected;
  final bool revealed;
  final bool correct;
  final bool wrongSelected;
  final Color accent;
  final VoidCallback onTap;
  /// Option position — rendered as the A/B/C/D badge.
  final int index;

  const ModeAnswerTile({
    super.key,
    required this.label,
    required this.selected,
    required this.revealed,
    required this.correct,
    required this.wrongSelected,
    required this.accent,
    required this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Quiz feedback keeps the universal green/red.
    const good = Colors.green;
    const bad = Colors.red;
    final showCorrect = revealed && correct;
    final showWrong = revealed && wrongSelected;
    final dimmed = revealed && !correct && !wrongSelected;
    final tone = showCorrect
        ? good
        : showWrong
        ? bad
        : (!revealed && selected)
        ? accent
        : null;

    final fill = tone != null
        ? tone.withValues(alpha: _isDark(cs) ? 0.20 : 0.11)
        : _innerPanelBg(cs);
    final border = tone ?? cs.outlineVariant.withValues(alpha: 0.5);

    final Widget badgeChild = showCorrect
        ? const Icon(Icons.check_rounded, size: 17, color: Colors.white)
        : showWrong
        ? const Icon(Icons.close_rounded, size: 17, color: Colors.white)
        : Text(
            String.fromCharCode(65 + index),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: tone != null ? _onAccent(tone) : cs.onSurfaceVariant,
            ),
          );

    return AnimatedOpacity(
      duration: CmTokens.medium,
      opacity: dimmed ? 0.55 : 1,
      child: CmPress(
        onTap: onTap,
        child: AnimatedContainer(
          duration: CmTokens.medium,
          curve: CmTokens.easeOut,
          padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 14, 10),
          constraints: const BoxConstraints(minHeight: 56),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(CmTokens.radiusMd + 2),
            border: Border.all(color: border, width: tone != null ? 1.6 : 1),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: CmTokens.medium,
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tone ?? cs.surfaceContainerHighest,
                ),
                child: badgeChild,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CMAiMessage(
                  label,
                  compact: true,
                  textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: (selected || showCorrect)
                        ? FontWeight.w700
                        : FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget answerList(ModeContextData d) {
  return Column(
    children: [
      for (int i = 0; i < d.options.length; i++) ...[
        ModeAnswerTile(
          index: i,
          label: d.options[i],
          selected: d.selectedIndex == i,
          revealed: d.answered,
          correct: i == (d.q?.correctIndex ?? -1),
          wrongSelected:
              d.answered &&
              d.selectedIndex == i &&
              i != (d.q?.correctIndex ?? -1),
          accent: d.accent,
          onTap: d.answered ? () {} : () => d.onSelected(i),
        ),
        if (i != d.options.length - 1) const SizedBox(height: 10),
      ],
    ],
  );
}

Widget answerResultBar(ModeContextData d) {
  final result = d.q == null || !d.answered || d.selectedIndex == null
      ? null
      : d.selectedIndex == d.q!.correctIndex;

  if (result == null) return const SizedBox.shrink();

  final accent = result ? Colors.green : Colors.red;
  final icon = result ? Icons.check_rounded : Icons.close_rounded;
  final l = AppLocalizations.of(d.context)!;
  final title = result ? l.practiceModeFeedbackCorrect : l.practiceModeFeedbackNotQuite;

  return Container(
    width: double.infinity,
    padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 14, 10),
    decoration: BoxDecoration(
      // Subtle tint, NOT a solid fill — the title sits on top of it.
      color: accent.withValues(alpha: _isDark(d.cs) ? 0.20 : 0.11),
      borderRadius: BorderRadius.circular(CmTokens.radiusMd),
    ),
    child: Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: d.theme.textTheme.titleSmall?.copyWith(
              color: d.cs.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget explanationCard(ModeContextData d, {String? title}) {
  final l = AppLocalizations.of(d.context)!;
  final cs = d.cs;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _innerPanelBg(cs),
      borderRadius: BorderRadius.circular(CmTokens.radiusLg),
      border: Border.all(color: d.accent.withValues(alpha: 0.35)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lightbulb_rounded, size: 18, color: d.accent),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title ?? l.practiceSessionExplanation,
                style: d.theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CMAiMessage(d.explanationOf(), compact: true),
      ],
    ),
  );
}

Widget answerFeedbackSection(
  ModeContextData d, {
  String? explanationTitle,
}) {
  if (!d.answered && !d.showExplanation) return const SizedBox.shrink();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (d.answered) answerResultBar(d),
      if (d.answered || d.showExplanation) ...[
        const SizedBox(height: 12),
        explanationCard(d, title: explanationTitle),
      ],
    ],
  );
}

Widget sharedPrimaryActionButton(
  ModeContextData d, {
  required String preAnswerLabel,
  required String postAnswerLabel,
  required IconData preAnswerIcon,
  IconData postAnswerIcon = Icons.arrow_forward_rounded,
}) {
  return FilledButton.icon(
    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
    onPressed: d.submitOrNext,
    icon: Icon(d.answered ? postAnswerIcon : preAnswerIcon),
    label: Text(
      d.answered ? postAnswerLabel : preAnswerLabel,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

Widget compactIconAction({
  required VoidCallback? onPressed,
  required IconData icon,
  required String tooltip,
}) {
  return IconButton.filledTonal(
    tooltip: tooltip,
    onPressed: onPressed,
    icon: Icon(icon),
  );
}

Widget novaHintAction(ModeContextData d) {
  return compactIconAction(
    onPressed: d.openNova,
    icon: Icons.tips_and_updates_rounded,
    tooltip: AppLocalizations.of(d.context)!.practiceModeActionNovaHint,
  );
}

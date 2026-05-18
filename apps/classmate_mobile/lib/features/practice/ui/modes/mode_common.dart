import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';

import '../../domain/practice_models.dart';
import '../../providers/practice_providers.dart';
import '../practice_mode_specs.dart';
import '../practice_display_text.dart';
import '../../../tutor/ui/nova_chat_screen.dart';
import '../../../../common/widgets/cm_ai_message.dart';
export '../../../../ui/math/math_view.dart';

typedef SessionResetFn = void Function();

Color _sessionPanelBorder(ColorScheme cs) {
  return cs.brightness == Brightness.dark
      ? cs.outlineVariant
      : cs.outlineVariant;
}

Color _sessionPanelBg(ColorScheme cs, Color accent) {
  return cs.brightness == Brightness.dark
      ? Color.alphaBlend(
          accent,
          cs.surfaceContainerHigh,
        )
      // Light mode: surface == scaffold bg, so the panel blends in. Step up
      // to a faintly elevated container so the card has shape.
      : cs.surfaceContainerHigh;
}

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

Widget modeBanner(ModeContextData d) {
  final accent = d.accent;
  final cs = d.cs;
  final theme = d.theme;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
    decoration: BoxDecoration(
      color: accent.withValues(
        alpha: cs.brightness == Brightness.dark ? 0.14 : 0.08,
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: accent.withValues(
          alpha: cs.brightness == Brightness.dark ? 0.26 : 0.22,
        ),
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(practiceModeIcon(d.state.filter.mode), color: accent, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                practiceModeLabel(d.context, d.state.filter.mode),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                practiceModeDescription(d.context, d.state.filter.mode),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget sessionProgressStrip(ModeContextData d) {
  final streakActive = d.state.stats.streak > 1;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: d.sessionProgress,
                minHeight: 8,
                backgroundColor: d.cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(d.accent),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: d.cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
              boxShadow: streakActive
                  ? [
                      BoxShadow(
                        color: d.accent,
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ]
                  : const [],
            ),
            child: Text(
              '🔥 ${d.state.stats.streak}',
              style: d.theme.textTheme.labelMedium?.copyWith(
                color: d.accent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        d.progressLabel,
        style: d.theme.textTheme.bodySmall?.copyWith(
          color: d.cs.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

Widget questionCard(
  ModeContextData d, {
  required Widget child,
  EdgeInsets padding = const EdgeInsets.all(20),
}) {
  final cs = d.cs;
  final accent = d.accent;
  return Container(
    padding: padding,
    decoration: BoxDecoration(
      color: cs.brightness == Brightness.dark
          ? Color.alphaBlend(
              accent,
              cs.surfaceContainerLow,
            )
          : cs.surface,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: cs.brightness == Brightness.dark
            ? cs.outlineVariant
            : cs.outlineVariant,
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: d.accent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: d.accent),
            ),
            child: Text(
              practiceModeLabel(d.context, d.state.filter.mode),
              style: d.theme.textTheme.labelLarge?.copyWith(
                // Was `d.accent` — identical to the chip fill, so the label
                // disappeared. Pick a contrasting foreground for the accent.
                color: _onAccent(d.accent),
                fontWeight: FontWeight.w800,
              ),
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

Widget questionPromptPanel(ModeContextData d) {
  final cs = d.theme.colorScheme;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
    decoration: BoxDecoration(
      color: _sessionPanelBg(cs, d.accent),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: _sessionPanelBorder(cs)),
    ),
    child: CMAiMessage(
      d.promptOf(),
      compact: true,
      textStyle: d.theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w900,
        height: 1.22,
      ),
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

  const ModeAnswerTile({
    super.key,
    required this.label,
    required this.selected,
    required this.revealed,
    required this.correct,
    required this.wrongSelected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Use an elevated container for the default state so the tile is
    // distinguishable from the scaffold background in light mode — plain
    // `cs.surface` is the same color as the page behind it.
    final defaultFill = cs.brightness == Brightness.dark
        ? cs.surface
        : cs.surfaceContainerHigh;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: revealed
                ? correct
                      ? Colors.green
                      : wrongSelected
                      ? Colors.red
                      : defaultFill
                : selected
                ? accent
                : defaultFill,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: revealed
                  ? correct
                        ? Colors.green
                        : wrongSelected
                        ? Colors.red
                        : cs.outlineVariant
                  : selected
                  ? accent
                  : cs.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: revealed
                      ? correct
                            ? Colors.green
                            : wrongSelected
                            ? Colors.red
                            : Colors.transparent
                      : selected
                      ? accent
                      : Colors.transparent,
                  border: Border.all(
                    color: revealed
                        ? correct
                              ? Colors.green
                              : wrongSelected
                              ? Colors.red
                              : cs.outlineVariant
                        : selected
                        ? accent
                        : cs.outlineVariant,
                  ),
                ),
                alignment: Alignment.center,
                child: revealed
                    ? correct
                          ? const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.green,
                            )
                          : wrongSelected
                          ? const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Colors.red,
                            )
                          : null
                    : selected
                    ? Icon(Icons.check_rounded, size: 14, color: accent)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CMAiMessage(
                  label,
                  compact: true,
                  textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    height: 1.15,
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
  final icon = result ? Icons.check_circle_rounded : Icons.cancel_rounded;
  final l = AppLocalizations.of(d.context)!;
  final title = result ? l.practiceModeFeedbackCorrect : l.practiceModeFeedbackNotQuite;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: accent,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: accent),
    ),
    child: Row(
      children: [
        Icon(icon, color: accent),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: d.theme.textTheme.titleSmall?.copyWith(
              color: accent,
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
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: d.accent,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: d.accent),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title ?? l.practiceSessionExplanation,
          style: d.theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: d.accent,
          ),
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
  return IconButton(tooltip: tooltip, onPressed: onPressed, icon: Icon(icon));
}

Widget novaHintAction(ModeContextData d) {
  return compactIconAction(
    onPressed: d.openNova,
    icon: Icons.tips_and_updates_rounded,
    tooltip: AppLocalizations.of(d.context)!.practiceModeActionNovaHint,
  );
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/practice_models.dart';
import '../../providers/practice_providers.dart';
import '../practice_mode_specs.dart';
import '../../../tutor/ui/nova_chat_screen.dart';
import '../../../../ui/math/math_view.dart';
export '../../../../ui/math/math_view.dart';

typedef SessionResetFn = void Function();

Color _sessionPanelBorder(ColorScheme cs) {
  return cs.brightness == Brightness.dark
      ? cs.outlineVariant.withValues(alpha: 0.32)
      : cs.outlineVariant.withValues(alpha: 0.44);
}

Color _sessionPanelBg(ColorScheme cs, Color accent) {
  return cs.brightness == Brightness.dark
      ? Color.alphaBlend(
          accent.withValues(alpha: 0.10),
          cs.surfaceContainerHigh,
        )
      : Color.alphaBlend(accent.withValues(alpha: 0.05), cs.surface);
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
      ? 'General'
      : state.filter.topicPath.join(' • ');

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

  String promptOf() => (q?.prompt ?? 'Question').toString();

  String explanationOf() {
    final txt = (q?.explanation ?? '').toString().trim();
    return txt.isEmpty ? 'No explanation available yet.' : txt;
  }

  Future<void> openNova() async {
    final optionsText = options
        .asMap()
        .entries
        .map((e) => '${String.fromCharCode(65 + e.key)}. ${e.value}')
        .join('\n');

    final prompt =
        '''
Mode: ${practiceModeLabel(state.filter.mode)}
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
              '${practiceModeLabel(state.filter.mode)} · ${state.filter.subject}',
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
                practiceModeLabel(d.state.filter.mode),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                practiceModeDescription(d.state.filter.mode),
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
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: d.accent.withValues(alpha: streakActive ? 0.16 : 0.08),
              borderRadius: BorderRadius.circular(999),
              boxShadow: streakActive
                  ? [
                      BoxShadow(
                        color: d.accent.withValues(alpha: 0.20),
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
              accent.withValues(alpha: 0.05),
              cs.surfaceContainerLow,
            )
          : cs.surface,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: cs.brightness == Brightness.dark
            ? cs.outlineVariant.withValues(alpha: 0.34)
            : cs.outlineVariant.withValues(alpha: 0.44),
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
              color: d.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: d.accent.withValues(alpha: 0.24)),
            ),
            child: Text(
              practiceModeLabel(d.state.filter.mode),
              style: d.theme.textTheme.labelLarge?.copyWith(
                color: d.accent,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              d.state.filter.topicLabel,
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
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          color: _sessionPanelBg(cs, d.accent),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _sessionPanelBorder(cs)),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 8),
              color: d.accent.withValues(alpha: 0.10),
            ),
          ],
        ),
        child: MathView(
          d.promptOf(),
          style: d.theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.22,
          ),
        ),
      ),
    ],
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
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: revealed
                ? correct
                      ? Colors.green.withValues(alpha: 0.14)
                      : wrongSelected
                      ? Colors.red.withValues(alpha: 0.14)
                      : cs.surface.withValues(alpha: 0.78)
                : selected
                ? accent.withValues(alpha: 0.14)
                : cs.surface.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: revealed
                  ? correct
                        ? Colors.green
                        : wrongSelected
                        ? Colors.red
                        : cs.outlineVariant.withValues(alpha: 0.28)
                  : selected
                  ? accent.withValues(alpha: 0.38)
                  : cs.outlineVariant.withValues(alpha: 0.28),
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
                            ? Colors.green.withValues(alpha: 0.18)
                            : wrongSelected
                            ? Colors.red.withValues(alpha: 0.18)
                            : Colors.transparent
                      : selected
                      ? accent.withValues(alpha: 0.18)
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
                child: MathView(
                  label,
                  compact: true,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
  final title = result ? 'Correct' : 'Not quite';

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: accent.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: accent.withValues(alpha: 0.24)),
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

Widget explanationCard(ModeContextData d, {String title = 'Explanation'}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: d.accent.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: d.accent.withValues(alpha: 0.18)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: d.theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: d.accent,
          ),
        ),
        const SizedBox(height: 8),
        MathView(d.explanationOf(), compact: true),
      ],
    ),
  );
}

Widget answerFeedbackSection(
  ModeContextData d, {
  String explanationTitle = 'Explanation',
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
    tooltip: 'NOVA hint',
  );
}

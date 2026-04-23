import '../../l10n/app_localizations.dart';

class ScheduleEmptyStateCopy {
  const ScheduleEmptyStateCopy._();

  static String title(AppLocalizations l) => l.scheduleNoClassesTitle;

  static String subtitle(AppLocalizations l, String day) =>
      l.scheduleNoClassesSubtitle(day);
}
// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get menu => 'Menü';

  @override
  String get sectionCore => 'Hauptfunktionen';

  @override
  String get sectionSchoolTools => 'Schultools';

  @override
  String get sectionAccount => 'Konto';

  @override
  String get navSchedule => 'Stundenplan';

  @override
  String get navClassrooms => 'Klassenräume';

  @override
  String get navPractice => 'Übung';

  @override
  String get navInsights => 'Analysen';

  @override
  String get navNova => 'NOVA';

  @override
  String get navMessages => 'Nachrichten';

  @override
  String get navAttendance => 'Anwesenheit';

  @override
  String get navGrades => 'Noten';

  @override
  String get navAssignments => 'Aufgaben';

  @override
  String get navMeetings => 'Meetings';

  @override
  String get navAnnouncements => 'Ankündigungen';

  @override
  String get navNotifications => 'Benachrichtigungen';

  @override
  String get navSolutions => 'Lösungen';

  @override
  String get navExams => 'Prüfungen';

  @override
  String get navForms => 'Formulare';

  @override
  String get navHome => 'Start';

  @override
  String get navTeacherWorkspace => 'Lehrerbereich';

  @override
  String get navTeacherAssessments => 'Bewertungen und Noten';

  @override
  String get navSavedQuestions => 'Gespeicherte Fragen';

  @override
  String get navProfile => 'Profil';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get navLogout => 'Abmelden';

  @override
  String get roleTeacher => 'Lehrer';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleSecretary => 'Sekretariat';

  @override
  String get roleParent => 'Elternteil';

  @override
  String get titleSchedule => 'Stundenplan';

  @override
  String get titleClasses => 'Klassen';

  @override
  String get titlePractice => 'Übung';

  @override
  String get titleInsights => 'Analysen';

  @override
  String get titleNova => 'NOVA';

  @override
  String get titleMessages => 'Nachrichten';

  @override
  String get titleSolutions => 'Lösungen';

  @override
  String get titleExams => 'Prüfungen';

  @override
  String get solutionsUploadAction => 'Hochladen';

  @override
  String get solutionsNoSubjectsAvailable => 'Keine Fächer verfügbar.';

  @override
  String solutionsNoSubjectsMatch(Object query) {
    return 'Keine Fächer stimmen mit \"$query\" überein.';
  }

  @override
  String solutionsBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Bücher',
      one: '1 Buch',
    );
    return '$_temp0';
  }

  @override
  String get solutionsBooksTitle => 'Bücher';

  @override
  String get solutionsAddBookTitle => 'Ein Buch hinzufügen';

  @override
  String get solutionsBookTitleHint => 'Buchtitel...';

  @override
  String get solutionsAddBookAction => 'Ein Buch hinzufügen';

  @override
  String get solutionsSearchBooks => 'Bücher durchsuchen';

  @override
  String get solutionsChooseSubjectFirst => 'Wählen Sie zuerst ein Fach aus.';

  @override
  String solutionsNoBooksYetBody(Object action) {
    return 'Noch keine Bücher.\nTippen Sie auf \"$action\", um die erste hinzuzufügen.';
  }

  @override
  String solutionsNoBooksMatch(Object query) {
    return 'Keine Bücher entsprechen \"$query\".';
  }

  @override
  String get solutionsBookLabel => 'Buch';

  @override
  String get solutionsPagesFilterHint =>
      'Geben Sie eine Seiten- und Fragennummer ein, um zu filtern, oder lassen Sie das Feld leer, um alle anzuzeigen.';

  @override
  String get solutionsPageNumberLabel => 'Seitennummer';

  @override
  String get solutionsPageNumberHint => 'z.B. 42';

  @override
  String get solutionsQuestionNumberLabel => 'Fragennummer';

  @override
  String get solutionsQuestionNumberHint => 'z.B. 3a oder 7';

  @override
  String get solutionsViewSolutionsAction => 'Lösungen anzeigen';

  @override
  String solutionsPageQuestionSummary(Object page, Object question) {
    return 'Seite $page • Frage $question';
  }

  @override
  String get solutionsExactQuestionTitle => 'Lösungen für diese genaue Frage';

  @override
  String get solutionsExactQuestionEmptySubtitle =>
      'Für diese genaue Frage wurden noch keine Lösungen hochgeladen. Seien Sie der Erste, der Ihren Klassenkameraden hilft.';

  @override
  String solutionsUploadsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Uploads gefunden',
      one: '1 Upload gefunden',
    );
    return '$_temp0';
  }

  @override
  String get solutionsExactQuestionEmptyBody =>
      'Keine genaue Übereinstimmung gefunden. Sie können jetzt eines hochladen oder sehen, was Ihre Klassenkameraden auf derselben Seite gelöst haben.';

  @override
  String get solutionsLoadMoreAction => 'Mehr laden';

  @override
  String get solutionsSamePageTitle =>
      'Andere Fragen, die auf dieser Seite gelöst wurden';

  @override
  String get solutionsSamePageEmptySubtitle =>
      'Es wurden noch keine benachbarten Fragen von dieser Seite hochgeladen.';

  @override
  String get solutionsSamePageFallbackSubtitle =>
      'Nützlicher Fallback, wenn Ihre genaue Frage noch keinen Upload hat.';

  @override
  String get solutionsSamePageEmptyBody =>
      'Noch keine Uploads in der Nähe auf dieser Seite. Ein neuer Upload hier würde wirklich hilfreich sein.';

  @override
  String get solutionsVerifiedByNova => 'Verifiziert von NOVA';

  @override
  String get solutionsUploadFileLimitReached => '10-Datei-Limit erreicht.';

  @override
  String solutionsUploadFilesAddedLimit(int count) {
    return '$count hinzugefügt — 10-Datei-Limit.';
  }

  @override
  String get solutionsUploadCompleteFields =>
      'Fach, Buch, Seite und Frage ausfüllen.';

  @override
  String get solutionsUploadAddOneFile =>
      'Fügen Sie mindestens ein Bild oder PDF hinzu.';

  @override
  String solutionsUploadFileFailed(Object error) {
    return 'Dateiupload fehlgeschlagen: $error';
  }

  @override
  String solutionsUploadCreateFailed(Object error) {
    return 'Lösung erstellen fehlgeschlagen: $error';
  }

  @override
  String get solutionsUploadSuccess => 'Lösung hochgeladen!';

  @override
  String get solutionsUploadAddNewBookOption => '+ Neues Buch hinzufügen...';

  @override
  String get solutionsUploadAddBookShortAction => 'Hinzufügen';

  @override
  String get solutionsUploadTitle => 'Eine Lösung hochladen';

  @override
  String get solutionsUploadSubtitle =>
      'Nur echte Bilder oder PDFs. NOVA-Überprüfung und Moderation werden nach dem Upload angewendet.';

  @override
  String get solutionsUploadNoBooksAbove =>
      'Keine Bücher — fügen Sie eins oben hinzu';

  @override
  String get solutionsUploadCaptionOptional => 'Beschriftung (optional)';

  @override
  String get solutionsUploadImagesAction => 'Bilder';

  @override
  String get solutionsUploadPdfAction => 'PDF';

  @override
  String solutionsUploadFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dateien ausgewählt',
      one: 'Datei ausgewählt',
    );
    return '$count / 10 $_temp0';
  }

  @override
  String get solutionsUploadSomeFilesFailed =>
      'Der Upload einiger Dateien ist fehlgeschlagen.';

  @override
  String get solutionsUploadRetryFailedFiles =>
      'Fehlgeschlagene Dateien erneut versuchen';

  @override
  String get solutionsUploadSubmittingAction => 'Wird hochgeladen...';

  @override
  String get solutionsUploadSubmitAction => 'Lösung hochladen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSubtitle => 'Erscheinungsbild, Sprache & Konto';

  @override
  String get settingsAppearance => 'Erscheinungsbild';

  @override
  String get settingsTheme => 'Design';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSystem => 'Systemstandard';

  @override
  String get settingsAccentColour => 'Akzentfarbe';

  @override
  String get settingsAccentSubtitle => 'Farbton der gesamten App';

  @override
  String get settingsReduceMotion => 'Bewegung reduzieren';

  @override
  String get settingsReduceMotionSubtitle => 'Weniger Animationen in der App';

  @override
  String get settingsAccount => 'Konto';

  @override
  String get settingsLogout => 'Abmelden';

  @override
  String get settingsLogoutSubtitle => 'Von diesem Gerät abmelden';

  @override
  String get settingsThemeSystem => 'Systemstandard';

  @override
  String get settingsThemeLight => 'Hell';

  @override
  String get settingsThemeDark => 'Dunkel';

  @override
  String get settingsLanguageSearchHint => 'Sprache suchen...';

  @override
  String get teacherWorkspaceSubtitle =>
      'Anwesenheit, Lerngruppen und Benotung in der mobilen App verwalten.';

  @override
  String get teacherMetricSessionsToday => 'Sitzungen heute';

  @override
  String get teacherMetricTeachingGroups => 'Lerngruppen';

  @override
  String get teacherMetricAssessments => 'Bewertungen';

  @override
  String get teacherQuickActions => 'Schnellzugriffe';

  @override
  String get teacherNoDateAvailable => 'Kein Datum verfügbar';

  @override
  String get teacherNoTeachingSlotsToday =>
      'Heute sind keine Unterrichtsstunden geplant.';

  @override
  String get teacherUpcomingAssessments => 'Anstehende Bewertungen';

  @override
  String get teacherUpcomingAssessmentsSubtitle =>
      'Live aus dem Lehrernotensystem';

  @override
  String get teacherNoAssessmentsYet => 'Noch keine Bewertungen erstellt.';

  @override
  String get teacherUnassignedSlot => 'Nicht zugewiesene Stunde';

  @override
  String get teacherNoCohort => 'Keine Gruppe';

  @override
  String get teacherCourseFallback => 'Kurs';

  @override
  String teacherPeriod(Object number) {
    return 'Stunde $number';
  }

  @override
  String get teacherLoadErrorTitle =>
      'Lehrerbereich konnte nicht geladen werden';

  @override
  String get teacherClassroomsLoadError =>
      'Klassenzimmer konnten nicht geladen werden. Zum Aktualisieren nach oben ziehen oder versuchen Sie es erneut.';

  @override
  String get teacherClassroomsLoadTimeout =>
      'Das Laden der Klassenzimmer dauert zu lange. Zum Aktualisieren nach oben ziehen oder versuchen Sie es in einem Moment erneut.';

  @override
  String get teacherClassroomsLoadNetwork =>
      'Klassenzimmer konnten sich gerade nicht verbinden. Überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.';

  @override
  String get teacherClassroomsSubtitle =>
      'Öffnen Sie die Klassenliste und generieren Sie einen Live-Joincode für den Studenteneintritt.';

  @override
  String get teacherClassroomsNoCohorts =>
      'Noch keine Klassencohorten mit diesem Lehrer verlinkt.';

  @override
  String teacherClassroomsCohort(Object cohortId) {
    return 'Kohorte $cohortId';
  }

  @override
  String get teacherClassroomsGeneratingJoinCode => 'Wird generiert…';

  @override
  String get teacherClassroomsCreateJoinCode => 'Joincode erstellen';

  @override
  String get teacherClassroomsLiveJoinCode => 'Live-Joincode';

  @override
  String teacherClassroomsExpiresAt(Object value) {
    return 'Läuft ab $value';
  }

  @override
  String get teacherClassroomsRoster => 'Klassenliste';

  @override
  String get teacherClassroomsNoStudents =>
      'Noch keine Schüler in diesem Klassenzimmer angemeldet.';

  @override
  String get teacherAttendanceLoadError =>
      'Anwesenheit konnte gerade nicht geladen werden. Zum Aktualisieren nach unten ziehen oder erneut versuchen.';

  @override
  String get teacherAttendanceLoadTimeout =>
      'Das Laden der Anwesenheit dauert zu lange. Zum Aktualisieren nach unten ziehen oder später erneut versuchen.';

  @override
  String get teacherAttendanceLoadNetwork =>
      'Anwesenheit konnte sich gerade nicht verbinden. Überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.';

  @override
  String get teacherAttendanceSubtitle =>
      'Wählen Sie eine Live-Sitzung, markieren Sie den Raum und speichern Sie nur geänderte Zeilen.';

  @override
  String get teacherAttendanceTodaySessions => 'Heutige Sitzungen';

  @override
  String teacherAttendanceSessionSummary(
    Object cohort,
    Object grade,
    Object date,
    Object period,
  ) {
    return '$cohort • Klasse $grade • $date • Stunde $period';
  }

  @override
  String get teacherAttendanceChanged => 'Geändert';

  @override
  String get teacherAttendanceNoteLabel => 'Notiz';

  @override
  String get teacherAttendanceSaving => 'Speichern…';

  @override
  String teacherAttendanceSaveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Änderungen',
      one: '1 Änderung',
    );
    return 'Speichern $_temp0';
  }

  @override
  String get teacherAttendanceSaved => 'Anwesenheit gespeichert';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get scheduleRefreshTooFast =>
      'Der Stundenplan wird gerade zu schnell aktualisiert. Warte einen Moment und versuche es dann erneut.';

  @override
  String get scheduleNotOnboarded =>
      'Dein Schülerprofil ist noch nicht vollständig eingerichtet, daher ist noch kein Stundenplan verfügbar.';

  @override
  String get scheduleLoadError =>
      'Der Stundenplan konnte noch nicht geladen werden.';

  @override
  String get scheduleSelectedDay => 'Ausgewählter Tag';

  @override
  String scheduleClassCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Stunden',
      one: '1 Stunde',
      zero: '0 Stunden',
    );
    return '$_temp0';
  }

  @override
  String get scheduleNextUp => 'Als Nächstes';

  @override
  String get scheduleNoMoreClasses => 'Keine weiteren Stunden';

  @override
  String get scheduleNoClassesTitle =>
      'An diesem Tag gibt es keinen Unterricht';

  @override
  String scheduleNoClassesSubtitle(Object day) {
    return '$day sieht frei aus.';
  }

  @override
  String get scheduleClassFallback => 'Unterricht';

  @override
  String get scheduleNoSubjectLocation => 'Noch kein Fach oder Ort';

  @override
  String get loginTitle => 'Mobile Anmeldung für Schüler und Lehrkräfte';

  @override
  String get loginSubtitle =>
      'Lehrkräfte-Konten öffnen den Lehrerbereich. Schülerkonten bleiben in der Schüleransicht.';

  @override
  String get loginSignIn => 'Anmelden';

  @override
  String get loginSigningIn => 'Anmeldung läuft...';

  @override
  String get loginEmailLabel => 'E-Mail';

  @override
  String get loginPasswordLabel => 'Passwort';

  @override
  String get profileNotAvailable => 'Nicht verfügbar';

  @override
  String get profileSchoolInfo => 'Schulinfos';

  @override
  String get profileFullName => 'Vollständiger Name';

  @override
  String get profileRole => 'Rolle';

  @override
  String get profileSchoolId => 'Schul-ID';

  @override
  String get profileCohortId => 'Kohorten-ID';

  @override
  String get profileAccountInfo => 'Kontoinfos';

  @override
  String get profileUsername => 'Benutzername';

  @override
  String get profileUsernameHint => 'your_username';

  @override
  String get profileContactEmail => 'Kontakt-E-Mail';

  @override
  String get profileEmailAddress => 'E-Mail-Adresse';

  @override
  String get profileEmailHint => 'you@example.com';

  @override
  String get profileBirthday => 'Geburtstag';

  @override
  String get profileSecurity => 'Sicherheit';

  @override
  String get profileSelectBirthday => 'Wähle deinen Geburtstag';

  @override
  String get profilePasswordUpdated => 'Passwort aktualisiert';

  @override
  String get profileSave => 'Speichern';

  @override
  String get profileEmptyValue => '—';

  @override
  String get profileChangePassword => 'Passwort ändern';

  @override
  String get profileCurrentPassword => 'Aktuelles Passwort';

  @override
  String get profileNewPassword => 'Neues Passwort';

  @override
  String get profileConfirmNewPassword => 'Neues Passwort bestätigen';

  @override
  String get profileUpdatePassword => 'Passwort aktualisieren';

  @override
  String get profilePasswordAllFieldsRequired =>
      'Alle Felder sind erforderlich';

  @override
  String get profilePasswordMinLength =>
      'Das neue Passwort muss mindestens 8 Zeichen lang sein';

  @override
  String get profilePasswordMismatch => 'Passwörter stimmen nicht überein';

  @override
  String get profilePasswordNotAuthenticated => 'Nicht angemeldet';

  @override
  String get profilePasswordIncorrect => 'Das aktuelle Passwort ist falsch';

  @override
  String get profilePasswordGenericError =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get editProfileTitle => 'Profil bearbeiten';

  @override
  String get editProfileSchool => 'Schule';

  @override
  String get editProfileSchoolPublic => 'Schule öffentlich';

  @override
  String get editProfileGradePublic => 'Klassenstufe öffentlich';

  @override
  String get editProfileMajors => 'Schwerpunkte';

  @override
  String get editProfileMajorsPublic => 'Schwerpunkte öffentlich';

  @override
  String get editProfileBio => 'Bio';

  @override
  String get editProfileBioPublic => 'Bio öffentlich';

  @override
  String get editProfileStatus => 'Status';

  @override
  String get editProfileStatusPublic => 'Status öffentlich';

  @override
  String get classroomsYourClassrooms => 'Deine Klassen';

  @override
  String get classroomsReorder => 'Klassen neu anordnen';

  @override
  String classroomsCount(Object count) {
    return '$count Klassen';
  }

  @override
  String get classroomsSearchHint => 'Klassen suchen';

  @override
  String get classroomsNoSearchMatches =>
      'Keine Klassen passen zu deiner Suche';

  @override
  String get classroomsClassroomLabel => 'Klasse';

  @override
  String get classroomsLoadingLatestMessage =>
      'Letzte Nachricht wird geladen...';

  @override
  String get classroomsTapToOpen => 'Tippen, um die Klasse zu öffnen';

  @override
  String get classroomsNoMessagesYet => 'Noch keine Nachrichten';

  @override
  String get classroomsMessageFallback => 'Nachricht';

  @override
  String get examsLoadError =>
      'Prüfungen oder Formulare konnten nicht geladen werden';

  @override
  String get examsAllFilter => 'Alle';

  @override
  String get examsFormsSubtitle =>
      'Prüfe Klassenformulare, Antwortfenster und Nachverfolgungen, die von deiner Schule veröffentlicht werden.';

  @override
  String get examsOnlySubtitle =>
      'Verfolge anstehende Bewertungen, Countdowns und frühere Prüfungen aus deinen Klassen.';

  @override
  String get examsUpcomingStat => 'Anstehende Prüfungen';

  @override
  String get examsOpenFormsStat => 'Offene Formulare';

  @override
  String get examsCountdownPast => 'Vergangen';

  @override
  String get examsCountdownTomorrow => 'Morgen';

  @override
  String examsCountdownInDays(Object days) {
    return 'In $days Tagen';
  }

  @override
  String get examsNoExamsPublished =>
      'Es wurden noch keine Prüfungen veröffentlicht.';

  @override
  String get examsNoFormsPublished =>
      'Es wurden noch keine Formulare veröffentlicht.';

  @override
  String examsNoExamsForFilter(Object subject) {
    return 'Für $subject sind derzeit keine Prüfungen verfügbar.';
  }

  @override
  String examsNoFormsForFilter(Object subject) {
    return 'Für $subject sind derzeit keine Formulare verfügbar.';
  }

  @override
  String examsMaterialsCount(Object count) {
    return '$count Materialien';
  }

  @override
  String get examsOpenState => 'Offen';

  @override
  String get examsClosedState => 'Geschlossen';

  @override
  String examsQuestionsCount(Object count) {
    return '$count Fragen';
  }

  @override
  String examsResponsesCount(Object count) {
    return '$count Antworten';
  }

  @override
  String get insightsTrendBaseline => 'Basis';

  @override
  String get insightsTrendImproving => 'Verbessert sich';

  @override
  String get insightsTrendDropping => 'Fällt';

  @override
  String get insightsTrendStable => 'Stabil';

  @override
  String get insightsHeadlineIntervention =>
      'Das Interventionsfenster ist offen';

  @override
  String get insightsHeadlineSignals =>
      'Mehrere Signale müssen enger geführt werden';

  @override
  String get insightsHeadlineMomentum =>
      'Der Schwung kann sich diese Woche verstärken';

  @override
  String get insightsBodyAttendance =>
      'Schütze zuerst die Anwesenheit. Bessere Präsenz עכשיו wird jedes andere Signal schneller verbessern.';

  @override
  String insightsBodyWeakTrend(Object subject) {
    return '$subject zusammen mit einem fallenden Übungstrend ist derzeit die größte Risikokombination. Behebe das, bevor du erweiterst.';
  }

  @override
  String insightsBodyLeverage(Object subject) {
    return '$subject ist dein Hebelpunkt. Nutze ihn, um Selbstvertrauen aufzubauen, während du schwächere Bereiche reparierst.';
  }

  @override
  String get insightsBodyConsistency =>
      'Sammle weiter kurze, fokussierte Sitzungen. Die nächsten Tage sind wichtiger als ein perfekter Langzeitplan.';

  @override
  String get insightsInterventionScoreTitle => 'Interventionswert';

  @override
  String insightsInterventionScoreBody(Object count) {
    return '$count aktive Signale prägen deinen nächsten Schritt.';
  }

  @override
  String get insightsRecoveryPathTitle => 'Schnellster Erholungspfad';

  @override
  String get insightsRecoveryPathDefault =>
      'Anwesenheit + Beständigkeit zuerst.';

  @override
  String insightsRecoveryPathTopic(Object topic, Object subject) {
    return 'Gehe $topic in $subject noch einmal durch, bevor du stärker drückst.';
  }

  @override
  String get insightsProjectedDirectionTitle => 'Erwartete Richtung';

  @override
  String insightsProjectedDirectionBody(Object trend) {
    return '$trend basierend auf dem jüngsten 7-Tage- gegenüber 30-Tage-Übungsverhalten.';
  }

  @override
  String get insightsLoadingTitle => 'Analysen werden geladen';

  @override
  String get insightsLoadingSubtitle =>
      'Dein prädiktives Dashboard wird aufgebaut.';

  @override
  String get insightsNotReadyTitle => 'Analysen sind noch nicht bereit';

  @override
  String get insightsEmptyTitle => 'Noch keine Analysen';

  @override
  String get insightsEmptySubtitle =>
      'Nutze weiter Übungen und Schultools, damit ClassMate ein klareres akademisches Bild aufbauen kann.';

  @override
  String get insightsGradeAverage => 'Notenschnitt';

  @override
  String get insightsAccuracy => 'Genauigkeit';

  @override
  String get insightsOpenNova => 'NOVA öffnen';

  @override
  String get insightsOpenNovaPrompt =>
      'Hilf mir, meinen schwächsten Bereich auf Grundlage meiner neuesten ClassMate-Analysen zu verbessern.';

  @override
  String get insightsPredictiveRecoveryPlanTitle => 'Prädiktiver Erholungsplan';

  @override
  String get insightsPracticeNow => 'Jetzt üben';

  @override
  String get insightsPredictiveModulesTitle => 'Prädiktive Module';

  @override
  String get insightsPredictiveModulesSubtitle =>
      'Die stärksten zukunftsgerichteten Signale aus deinen aktuellen Schülerdaten.';

  @override
  String get insightsAnnouncementsPressureTitle => 'Ankündigungsdruck';

  @override
  String get insightsAnnouncementsPressureSubtitle =>
      'Die Ankündigungs-Engine speist das Dashboard jetzt direkt.';

  @override
  String get insightsAiCoachTitle => 'KI-Coach-Zusammenfassung';

  @override
  String get insightsAiCoachLoadingSubtitle => 'KI-Hinweise werden geladen.';

  @override
  String get insightsAiCoachUnavailableSubtitle =>
      'KI-Hinweise sind für dieses Konto derzeit nicht verfügbar.';

  @override
  String get insightsAskNova => 'NOVA fragen';

  @override
  String get insightsAskNovaPrompt =>
      'Erstelle mir einen Erholungsplan auf Basis meiner neuesten Analysen.';

  @override
  String get insightsAiStudyCoachTitle => 'KI-Lerncoach';

  @override
  String get insightsSchoolToolsTitle => 'Schultools';

  @override
  String get insightsSchoolToolsSubtitle =>
      'Springe direkt zu den Schülerbereichen, die jetzt am wichtigsten sind.';

  @override
  String get tutorUntitledChat => 'Unbenannter Chat';

  @override
  String get tutorNewChat => 'Neuer Chat';

  @override
  String tutorFailedToOpenSeededChat(Object error) {
    return 'Chat konnte nicht geöffnet werden: $error';
  }

  @override
  String tutorFailedToCreateChat(Object error) {
    return 'Chat konnte nicht erstellt werden: $error';
  }

  @override
  String get tutorRenameChatTitle => 'Chat umbenennen';

  @override
  String get tutorChatNameHint => 'Chatname';

  @override
  String get tutorCancel => 'Abbrechen';

  @override
  String get tutorHide => 'Ausblenden';

  @override
  String get tutorHideChatTitle => 'Chat ausblenden';

  @override
  String get tutorHideChatSubtitle =>
      'Blendet diesen Chat auf diesem Gerät aus.';

  @override
  String get tutorHideChatConfirmTitle => 'Chat ausblenden?';

  @override
  String get tutorHideChatConfirmBody =>
      'Dadurch wird der Chat auf diesem Gerät aus der Liste ausgeblendet. Die Sitzung bleibt im Backend erhalten.';

  @override
  String get tutorTapToOpenHistory => 'Tippen, um den Verlauf zu öffnen';

  @override
  String get tutorAiTutorSubtitle => 'Dein KI-Tutor';

  @override
  String get tutorHeroBody =>
      'Echter Chatverlauf, sauberere Threads, schnellerer Zugriff.';

  @override
  String get tutorStartFreshConversation => 'Neue Unterhaltung starten';

  @override
  String get tutorSearchHistoryHint => 'Chatverlauf durchsuchen';

  @override
  String get chatComposerDefaultHint => 'Nachricht';

  @override
  String get chatComposerReplyingToMessage => 'Antwort auf Nachricht';

  @override
  String get chatComposerReplyFallback => 'Antwort';

  @override
  String get chatComposerMicHint =>
      'Tippe für eine schnelle Sprachnotiz oder halte zum Aufnehmen';

  @override
  String get chatComposerRecordingTitle => 'Aufnahme läuft';

  @override
  String get chatComposerReleaseToSend => 'Loslassen zum Senden';

  @override
  String get chatComposerCancelTitle => 'Abbrechen';

  @override
  String get chatComposerLockTitle => 'Sperren';

  @override
  String get chatComposerSlideLeftToCancel => 'Zum Abbrechen nach links ziehen';

  @override
  String get chatComposerSlideUpToLock => 'Zum Sperren nach oben ziehen';

  @override
  String get chatComposerReleaseToCancel => 'Loslassen zum Abbrechen';

  @override
  String get chatComposerKeepSlidingToCancel => 'Weiter ziehen zum Abbrechen';

  @override
  String get chatComposerReleaseToLock => 'Loslassen zum Sperren';

  @override
  String get chatComposerRelease => 'Loslassen';

  @override
  String get chatComposerLock => 'Sperren';

  @override
  String get chatComposerRecordingPaused => 'Aufnahme pausiert';

  @override
  String get chatComposerRecordingLocked => 'Aufnahme gesperrt';

  @override
  String get chatComposerResumeHint => 'Mach weiter, wenn du bereit bist';

  @override
  String get chatComposerLockedHint =>
      'Tippe auf Senden, wenn du teilen willst';

  @override
  String get chatContextDismiss => 'Schließen';

  @override
  String get chatContextCopyText => 'Text kopieren';

  @override
  String get chatContextDelete => 'Löschen';

  @override
  String get chatMessageInfoShortTitle => 'Info';

  @override
  String get chatMessageInfoStatus => 'Status';

  @override
  String get chatMessageInfoStatusTime => 'Statuszeit';

  @override
  String get chatMessageInfoSentAt => 'Gesendet um';

  @override
  String get chatMessageInfoDeliveredAt => 'Zugestellt um';

  @override
  String get chatMessageInfoSeenAt => 'Gesehen um';

  @override
  String get chatMessageInfoMessageType => 'Nachrichtentyp';

  @override
  String get chatMessageInfoTextType => 'Text';

  @override
  String get chatMessageInfoEdited => 'Bearbeitet';

  @override
  String get chatMessageInfoForwarded => 'Weitergeleitet';

  @override
  String get chatMessageInfoVoiceDuration => 'Sprachdauer';

  @override
  String get chatMessageInfoSeenBy => 'Gesehen von';

  @override
  String get chatMessageInfoDeliveredTo => 'Zugestellt an';

  @override
  String get chatMessageInfoEmptyBody => '(leer)';

  @override
  String get chatMessageInfoReadLess => 'Weniger lesen';

  @override
  String get chatMessageInfoReadMore => 'Mehr lesen';

  @override
  String get chatMessageInfoSeen => 'Gesehen';

  @override
  String get chatMessageInfoDelivered => 'Zugestellt';

  @override
  String get chatMessageInfoNotDelivered => 'Nicht zugestellt';

  @override
  String get chatMessageInfoSent => 'Gesendet';

  @override
  String get chatMessageInfoPending => 'Ausstehend';

  @override
  String get chatMessageInfoNotSeen => 'Nicht gesehen';

  @override
  String get chatMessageInfoType => 'Typ';

  @override
  String get chatMessageInfoDuration => 'Dauer';

  @override
  String get chatMessageInfoYes => 'Ja';

  @override
  String get chatMessageInfoNo => 'Nein';

  @override
  String get chatMessageInfoDeleteState => 'Löschstatus';

  @override
  String get chatReactionDetailsTitle => 'Reaktionen';

  @override
  String get chatReactionAddAction => 'Reaktion hinzufügen';

  @override
  String get chatReactionEmptyState => 'Noch keine Reaktionen';

  @override
  String get chatReactionSingle => 'Reaktion';

  @override
  String get chatReactionTapToRemove => 'Tippen zum Entfernen';

  @override
  String chatReactionYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' · $count',
      one: '',
    );
    return 'Du$_temp0';
  }

  @override
  String chatReactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Reaktionen',
      one: 'Reaktion',
    );
    return '$_temp0';
  }

  @override
  String get chatEmojiPickerTitle => 'Emoji auswählen';

  @override
  String get chatEmojiPickerSearchHint => 'Emoji suchen';

  @override
  String get chatEmojiPickerEmptyState => 'Kein Emoji gefunden';

  @override
  String get chatCameraTitle => 'Kamera';

  @override
  String get chatCameraUseAction => 'Verwenden';

  @override
  String get chatCameraGalleryAction => 'Galerie';

  @override
  String chatCameraSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgewählt',
      one: '1 ausgewählt',
      zero: '0 ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get chatMediaPreviewEmptyState => 'Nichts zur Vorschau';

  @override
  String get chatMediaPreviewDrawCropAction => 'Zeichnen & Zuschneiden';

  @override
  String get chatMediaPreviewRotateLeftAction => 'Nach links drehen';

  @override
  String get chatMediaPreviewRotateRightAction => 'Nach rechts drehen';

  @override
  String get chatMediaPreviewMirrorAction => 'Spiegeln';

  @override
  String get chatMediaPreviewResetAction => 'Zurücksetzen';

  @override
  String get chatMediaPreviewRemoveAction => 'Entfernen';

  @override
  String get chatMediaPreviewCaptionHint => 'Beschriftung hinzufügen...';

  @override
  String tutorPlanSelectedPlaceholder(Object plan) {
    return '$plan ausgewählt. Zahlungen bleiben vorerst im Platzhaltermodus.';
  }

  @override
  String get tutorFailedToLoadChats => 'Chats konnten nicht geladen werden';

  @override
  String get tutorNoChatsYet => 'Noch keine Chats';

  @override
  String get tutorNoChatsMatchSearch => 'Keine Chats passen zu deiner Suche';

  @override
  String get tutorCreateFirstChat => 'Ersten Chat erstellen';

  @override
  String get tutorPlansTitle => 'NOVA-Pläne';

  @override
  String tutorPlansSubtitle(Object model) {
    return 'Basierend auf $model-Kostenannahmen und harten Monatslimits, damit die Nutzung profitabel bleibt.';
  }

  @override
  String get tutorPlanPriceFree => 'Kostenlos';

  @override
  String tutorPlanPriceMonthly(Object price) {
    return '\$$price/Monat';
  }

  @override
  String get tutorPromptsLeft => 'Verbleibende Prompts';

  @override
  String get tutorUploadsLeft => 'Verbleibende Uploads';

  @override
  String get tutorVoiceLeft => 'Verbleibende Sprachzeit';

  @override
  String tutorUsageValue(Object remaining, Object total) {
    return '$remaining/$total';
  }

  @override
  String tutorVoiceUsageValue(Object remaining, Object total) {
    return '$remaining/$total Min';
  }

  @override
  String get tutorPaymentMethodsTitle => 'Zahlungsmethoden';

  @override
  String tutorPaymentMethodsSubtitle(Object plan) {
    return 'Checkout bleibt ein Platzhalter, bis das ClassMate-Bankkonto und der Zahlungsanbieter live sind. Der gewählte Plan ist $plan.';
  }

  @override
  String get tutorCardCheckoutTitle => 'Kartenzahlung';

  @override
  String get tutorCardCheckoutSubtitle =>
      'Platzhalter-Gateway für Visa, Mastercard und AmEx.';

  @override
  String get tutorApplePayTitle => 'Apple Pay';

  @override
  String get tutorApplePaySubtitle => 'Platzhalter-Wallet für iPhone und Web.';

  @override
  String get tutorBankTransferTitle => 'Banküberweisung';

  @override
  String get tutorBankTransferSubtitle =>
      'ClassMate-Bankkonto ausstehend. Details werden ergänzt, sobald es eröffnet ist.';

  @override
  String get tutorPlanStarterName => 'Starter';

  @override
  String get tutorPlanStarterTagline =>
      'Genug für Tests und leichte wöchentliche Wiederholung.';

  @override
  String get tutorPlanPlusName => 'Plus';

  @override
  String get tutorPlanPlusTagline =>
      'Am besten für einen engagierten Schüler, der NOVA an den meisten Tagen nutzt.';

  @override
  String get tutorPlanProName => 'Pro';

  @override
  String get tutorPlanProTagline =>
      'Für intensive tägliche Nutzung, volle Prüfungszeit und lange Lernsitzungen.';

  @override
  String get tutorPlanSchoolSeatName => 'Schulsitz';

  @override
  String get tutorPlanSchoolSeatTagline =>
      'Für den Rollout pro Schüler- oder Mitarbeitersitz in einer echten Schule.';

  @override
  String tutorPlanBulletPromptsMonthly(Object count) {
    return '$count NOVA-Prompts pro Monat';
  }

  @override
  String tutorPlanBulletPromptsPerSeatMonthly(Object count) {
    return '$count NOVA-Prompts pro Sitz monatlich';
  }

  @override
  String tutorPlanBulletUploads(Object count) {
    return '$count Bild- oder Datei-Uploads';
  }

  @override
  String tutorPlanBulletVoiceMinutes(Object count) {
    return '$count Minuten Sprachtranskription';
  }

  @override
  String tutorEstimatedCostCeilingFree(Object cost) {
    return 'Geschätzte Kostenobergrenze: \$$cost/Monat';
  }

  @override
  String tutorEstimatedCostCeilingPaid(Object cost, Object margin) {
    return 'Geschätzte Kostenobergrenze: \$$cost/Monat • Marge $margin%';
  }

  @override
  String tutorTimeMinutesShort(Object count) {
    return '$count Min';
  }

  @override
  String tutorTimeHoursShort(Object count) {
    return '$count Std';
  }

  @override
  String get tutorVoiceMessageFallback => 'Sprachnachricht';

  @override
  String get tutorFileFallback => 'Datei';

  @override
  String get tutorCopy => 'Kopieren';

  @override
  String get tutorEditMessage => 'Nachricht bearbeiten';

  @override
  String get tutorCopied => 'Kopiert';

  @override
  String get tutorLoadedIntoComposer => 'In den Eingabebereich geladen';

  @override
  String get tutorTakePhoto => 'Foto aufnehmen';

  @override
  String get tutorRecordVideo => 'Video aufnehmen';

  @override
  String get tutorChooseFromGallery => 'Aus der Galerie wählen';

  @override
  String get tutorPreviewTitle => 'Vorschau';

  @override
  String get tutorThinking => 'Denkt nach...';

  @override
  String get tutorDone => 'Fertig.';

  @override
  String get tutorFailedToStreamReply => 'Antwortstream fehlgeschlagen';

  @override
  String get tutorUnsupportedFilesMessage =>
      'NOVA unterstützt Bilder, Dokumente und Text. Video- und Audiodateien werden hier nicht unterstützt.';

  @override
  String get tutorNoAudioCaptured => 'Kein Audio aufgenommen.';

  @override
  String get tutorVoiceLimitReachedTitle => 'Sprachlimit erreicht';

  @override
  String get tutorVoiceLimitReachedMessage =>
      'Dein aktueller NOVA-Plan hat nicht genug Sprachminuten für diesen Transkriptionszyklus.';

  @override
  String get tutorTranscriptionFailed =>
      'Transkription fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get tutorMicrophonePermissionRequired =>
      'Mikrofonberechtigung ist erforderlich.';

  @override
  String get tutorPlanLimitReachedTitle => 'NOVA-Planlimit erreicht';

  @override
  String get tutorPlanLimitReachedMessage =>
      'Das monatliche Prompt- oder Upload-Kontingent deines aktuellen NOVA-Plans ist aufgebraucht. Wähle im NOVA-Startbildschirm einen höheren Plan, um fortzufahren.';

  @override
  String get tutorSendFailed => 'Senden fehlgeschlagen.';

  @override
  String tutorCurrentPlanUsageSummary(
    Object plan,
    Object prompts,
    Object uploads,
    Object voice,
  ) {
    return 'Aktueller Plan: $plan • $prompts Prompts übrig • $uploads Uploads übrig • $voice Sprachminuten übrig';
  }

  @override
  String get tutorReviewPlansInHome => 'Pläne im NOVA-Start ansehen';

  @override
  String get tutorCouldNotOpenAttachment =>
      'Anhang konnte nicht geöffnet werden.';

  @override
  String get tutorAttachmentUnavailable => 'Anhang nicht verfügbar.';

  @override
  String get tutorImageUnavailable => 'Bild nicht verfügbar';

  @override
  String get tutorYou => 'Du';

  @override
  String get tutorRegenerate => 'Neu generieren';

  @override
  String get tutorEmptyStateTitle => 'Starte mit einer echten Frage';

  @override
  String get tutorEmptyStateBody =>
      'Bitte NOVA, ein Konzept zu erklären, Notizen in eine Tabelle umzuwandeln, Ideen zu vergleichen oder dir beim Wiederholen mit einer hochgeladenen Datei zu helfen.';

  @override
  String get tutorPromptSuggestionSummarizeNotes =>
      'Fasse meine Unterrichtsnotizen zusammen';

  @override
  String get tutorPromptSuggestionRevisionTable => 'Erstelle eine Lerntabelle';

  @override
  String get tutorPromptSuggestionQuizMe => 'Teste mich zu diesem Thema';

  @override
  String get tutorMessageNovaHint => 'NOVA schreiben';

  @override
  String get tutorHeaderSubtitleReady =>
      'Strukturierte Antworten, Tabellen und Lernhilfe';

  @override
  String get tutorYourNovaPlanTitle => 'Dein NOVA-Plan';

  @override
  String get tutorYourNovaPlanMessage =>
      'Prüfe hier deine Prompt-, Upload- und Sprachlimits und springe dann zum NOVA-Start zurück, wenn du den Plan wechseln möchtest.';

  @override
  String get tutorExplainTitle => 'NOVA erklärt';

  @override
  String get classroomsThreadTypeClassroom => 'Klasse';

  @override
  String get classroomsThreadTypeGroup => 'Gruppe';

  @override
  String get classroomsThreadTypeDirectMessage => 'Direktnachricht';

  @override
  String get classroomsThreadTypeDirectMessageShort => 'DM';

  @override
  String get messagesBlockedPeopleTitle => 'Blockierte Personen';

  @override
  String get messagesStartChatAction => 'Chat starten';

  @override
  String messagesLoadFailed(Object error) {
    return 'Nachrichten konnten nicht geladen werden: $error';
  }

  @override
  String get messagesSearchHint => 'Nachrichten durchsuchen';

  @override
  String get messagesNoResults => 'Keine Nachrichten gefunden';

  @override
  String get messagesRequestsSection => 'Anfragen';

  @override
  String get messagesPendingApprovals => 'Ausstehende Freigaben';

  @override
  String get messagesChatsSection => 'Chats';

  @override
  String get messagesAllChatsSection => 'Alle Chats';

  @override
  String messagesConversationCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Unterhaltungen',
      one: '1 Unterhaltung',
    );
    return '$_temp0';
  }

  @override
  String get messagesRequestReviewStatus => 'Prüfen';

  @override
  String messagesPeopleLoadFailed(Object error) {
    return 'Personen konnten nicht geladen werden: $error';
  }

  @override
  String get messagesSearchPeopleHint => 'Personen suchen';

  @override
  String get messagesNewGroupTitle => 'Neue Gruppe';

  @override
  String get messagesNewGroupSubtitle => 'Einen Gruppenchat erstellen';

  @override
  String get messagesGroupNameHint => 'Gruppenname';

  @override
  String get messagesCreateGroupAction => 'Gruppe erstellen';

  @override
  String get messagesBlockedPersonFallback => 'diese Person';

  @override
  String get messagesUnblockPersonTitle => 'Person entsperren?';

  @override
  String messagesUnblockPersonBody(Object name) {
    return '$name wieder erlauben, dir Nachrichten zu senden?';
  }

  @override
  String get messagesUnblockAction => 'Entsperren';

  @override
  String messagesUnblockedToast(Object name) {
    return '$name entsperrt';
  }

  @override
  String messagesBlockedPeopleLoadFailed(Object error) {
    return 'Blockierte Personen konnten nicht geladen werden: $error';
  }

  @override
  String get messagesNoBlockedPeople => 'Keine blockierten Personen';

  @override
  String get messagesUnknownUser => 'Unbekannter Nutzer';

  @override
  String get messagesRequestTitle => 'Anfrage';

  @override
  String messagesRequestLoadFailed(Object error) {
    return 'Anfrage konnte nicht geladen werden: $error';
  }

  @override
  String get messagesRequestBannerIncoming => 'Nachrichtenanfrage';

  @override
  String get messagesRequestBannerOutgoing => 'Ausstehende Freigabe';

  @override
  String get messagesBlockAction => 'Blockieren';

  @override
  String get messagesApproveAction => 'Freigeben';

  @override
  String get messagesRequestUnlockHint =>
      'Der Chat wird freigeschaltet, nachdem der Empfänger deine erste Nachricht genehmigt.';

  @override
  String get messagesThreadConversationFallback => 'Unterhaltung';

  @override
  String get messagesThreadLeaveGroupTitle => 'Gruppe verlassen?';

  @override
  String get messagesThreadLeaveGroupBody =>
      'Du erhältst keine Nachrichten mehr aus dieser Gruppe.';

  @override
  String get messagesThreadBlockPersonTitle => 'Person blockieren?';

  @override
  String get messagesThreadBlockPersonBody =>
      'Du kannst mit dieser Person keine Nachrichten mehr austauschen.';

  @override
  String get messagesThreadPersonFallback => 'Person';

  @override
  String get messagesThreadProfileInfoUnavailable =>
      'Profilinformationen nicht verfügbar';

  @override
  String get messagesThreadParticipants => 'Teilnehmende';

  @override
  String get messagesThreadPeople => 'Personen';

  @override
  String get messagesThreadDeleteForMe => 'Für mich löschen';

  @override
  String get messagesThreadDeleteForEveryone => 'Für alle löschen';

  @override
  String get messagesThreadDeleteForEveryoneSubtitle =>
      'Entfernt die Nachricht für alle Teilnehmenden';

  @override
  String get messagesThreadSending => 'Wird gesendet…';

  @override
  String get messagesThreadWaitingForApproval => 'Warten auf Freigabe';

  @override
  String get classroomsForwardSearchHint => 'Chats durchsuchen';

  @override
  String get classroomsForwardNewChat => 'Neuer Chat';

  @override
  String classroomsForwardLoadError(Object error) {
    return 'Chats konnten nicht geladen werden: $error';
  }

  @override
  String get classroomsForwardNoChatsFound => 'Keine Chats gefunden';

  @override
  String get classroomsForwardSectionClassrooms => 'Klassen';

  @override
  String get classroomsForwardSectionDirectMessages => 'Direktnachrichten';

  @override
  String get classroomsForwardCancel => 'Abbrechen';

  @override
  String get classroomsForwardAction => 'Weiterleiten';

  @override
  String classroomsForwardCount(Object count) {
    return 'Weiterleiten ($count)';
  }

  @override
  String get markRead => 'Als gelesen markieren';

  @override
  String get markUnread => 'Als ungelesen markieren';

  @override
  String get markAllRead => 'Alle als gelesen markieren';

  @override
  String get filters => 'Filter';

  @override
  String get source => 'Quelle';

  @override
  String get state => 'Status';

  @override
  String get allSources => 'Alle Quellen';

  @override
  String get allStates => 'Alle Status';

  @override
  String get unread => 'Ungelesen';

  @override
  String get read => 'Gelesen';

  @override
  String get clear => 'Löschen';

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get earlier => 'Früher';

  @override
  String get openDetails => 'Details öffnen';

  @override
  String get total => 'Gesamt';

  @override
  String get local => 'Lokal';

  @override
  String get server => 'Server';

  @override
  String get notificationsSourceSystem => 'System';

  @override
  String get notificationsHeroSubtitleStudent =>
      'Dein Benachrichtigungsbereich für Ankündigungen, Server-Updates und wichtige schulische Aktivitäten in Echtzeit.';

  @override
  String get notificationsHeroSubtitleTeacher =>
      'Dein Lehrer-Benachrichtigungsbereich für Ankündigungen, Server-Updates und Schulaktivitäten in Echtzeit.';

  @override
  String get notificationsFiltersSubtitle =>
      'Nach Quelle oder Lesestatus filtern, um schneller zu priorisieren.';

  @override
  String get notificationsSearchSourcesHint => 'Quellen durchsuchen';

  @override
  String notificationsShowingSummary(Object shown, Object total) {
    return '$shown von $total Benachrichtigungen werden angezeigt.';
  }

  @override
  String get notificationsEmptyForAccount =>
      'Für dieses Konto sind derzeit keine Benachrichtigungen verfügbar.';

  @override
  String get notificationsEmptyFiltered =>
      'Keine Benachrichtigungen passen derzeit zu diesen Filtern. Filter löschen, um den gesamten Feed zu sehen.';

  @override
  String get notificationsEmpty =>
      'Derzeit sind keine Benachrichtigungen verfügbar.';

  @override
  String get notificationsNewBadge => 'Neu';

  @override
  String get notificationsUnavailable =>
      'Diese Benachrichtigung ist nicht mehr verfügbar. Aktualisiere den Posteingang und versuche es erneut.';

  @override
  String get notificationsSeverityCritical => 'Kritisch';

  @override
  String get notificationsSeverityWarning => 'Warnung';

  @override
  String get notificationsSeverityInfo => 'Info';

  @override
  String get announcementsLoadError =>
      'Ankündigungen konnten nicht geladen werden. Zum Aktualisieren nach unten ziehen oder erneut versuchen.';

  @override
  String get announcementsLoadTimeout =>
      'Ankündigungen werden zu lange zum Laden benötigt. Zum Aktualisieren nach unten ziehen oder kurz versuchen.';

  @override
  String get announcementsLoadNetwork =>
      'Ankündigungen konnten sich jetzt nicht verbinden. Überprüfen Sie die Verbindung und versuchen Sie es erneut.';

  @override
  String get announcementsAudienceTeacher => 'Lehrer';

  @override
  String get announcementsAudienceAccount => 'Konto';

  @override
  String get announcementsAudienceTeacherWorkspace => 'Lehrerarbeitsbereich';

  @override
  String get announcementsLoadFailedTitle =>
      'Ankündigungen konnten nicht geladen werden';

  @override
  String get announcementsLoadFailedHint =>
      'Zum Aktualisieren nach unten ziehen, wenn die Verbindung stabil ist.';

  @override
  String announcementsHeroSubtitle(Object audience) {
    return 'Veröffentlichte Schul-, Lehrer- und Systemankündigungen, verfügbar für $audience.';
  }

  @override
  String get announcementsLatestSourceLabel => 'Neueste Quelle';

  @override
  String get announcementsNone => 'Keine';

  @override
  String announcementsUnreadCountTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ungelesene Ankündigungen',
      one: '1 ungelesene Ankündigung',
    );
    return '$_temp0';
  }

  @override
  String get announcementsAllReadTitle => 'Alles ist gelesen';

  @override
  String announcementsEmptyForAudience(Object audience) {
    return 'Es wurden noch keine Ankündigungen für $audience veröffentlicht.';
  }

  @override
  String announcementsLatestBody(Object title) {
    return 'Neueste: $title. Tippen Sie, um den vollständigen Inhalt zu lesen.';
  }

  @override
  String get announcementsFiltersSubtitle =>
      'Begrenzen Sie den Posteingang nach Quelle oder Lesestatus, um sich auf das zu konzentrieren, was noch Aufmerksamkeit benötigt.';

  @override
  String get announcementsAllAnnouncements => 'Alle Ankündigungen';

  @override
  String get announcementsSearchStatesHint => 'Ungelesen / Gelesen';

  @override
  String announcementsSummarySourceSegment(Object source) {
    return ' von $source';
  }

  @override
  String announcementsSummaryStateSegment(Object state) {
    return ' in $state';
  }

  @override
  String announcementsShowingSummary(
    Object shown,
    Object total,
    Object sourceSegment,
    Object stateSegment,
  ) {
    return 'Zeige $shown von $total Ankündigungen$sourceSegment$stateSegment.';
  }

  @override
  String get announcementsNoMatchTitle =>
      'Keine Ankündigungen stimmen mit diesen Filtern überein';

  @override
  String get announcementsNoPublishedTitle =>
      'Noch keine veröffentlichten Ankündigungen';

  @override
  String get announcementsNoMatchSubtitle =>
      'Versuchen Sie eine andere Quelle oder wechseln Sie zu allen Ankündigungen, um mehr Elemente anzuzeigen.';

  @override
  String get announcementsClearFiltersHint =>
      'Filter löschen, um wieder alles zu sehen.';

  @override
  String get announcementsPullToRefreshHint =>
      'Zum Aktualisieren nach unten ziehen, nachdem eine neue Schulaktivität veröffentlicht wurde.';

  @override
  String get announcementsInboxTitle => 'Posteingang';

  @override
  String get announcementsInboxSubtitle =>
      'Nur Titel erscheinen hier zum schnellen Scannen. Tippen Sie auf ein Element, um den vollständigen Ankündigungsinhalt zu öffnen.';

  @override
  String get meetingsLoadError =>
      'Meetings konnten gerade nicht geladen werden. Ziehen zum Aktualisieren oder erneut versuchen.';

  @override
  String get meetingsLoadTimeout =>
      'Meetings dauert zu lange zum Laden. Ziehen zum Aktualisieren oder in einem Moment erneut versuchen.';

  @override
  String get meetingsLoadNetwork =>
      'Meetings konnte gerade nicht verbunden werden. Überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.';

  @override
  String get meetingsHeroSubtitle =>
      'Alle Klassenzimmer-Meetings in einer übersichtlichen Ansicht mit angehängten Links und einer Vollbilddetailseite, wenn Sie Kontext benötigen.';

  @override
  String get meetingsJoinReadyMetric => 'Beitrittsbereit';

  @override
  String get meetingsNoLinkMetric => 'Kein Link';

  @override
  String get meetingsNoPostedTitle => 'Noch keine Meetings verfügbar';

  @override
  String get meetingsEmptyForAccount =>
      'Es sind gerade keine Klassenzimmer-Meetings für dieses Schülerkonto verfügbar.';

  @override
  String meetingsLatestBody(Object title, Object updatedAt) {
    return '$title wurde aktualisiert $updatedAt. Öffnen Sie es für den angehängten Link und Klassenzimmer-Kontext.';
  }

  @override
  String get meetingsPullToRefreshHint => 'Ziehen zum erneuten Überprüfen.';

  @override
  String get meetingsFiltersSubtitle =>
      'Grenzen Sie die Liste nach Fach ein oder danach, ob das Meeting bereits einen öffnenbaren Link enthält.';

  @override
  String get meetingsAccessLabel => 'Zugriff';

  @override
  String get meetingsAllMeetings => 'Alle Meetings';

  @override
  String get meetingsAccessReady => 'Beitrittsbereit';

  @override
  String get meetingsAccessNoLink => 'Kein Link';

  @override
  String get meetingsAccessNoLinkYet => 'Noch kein Link';

  @override
  String get meetingsAccessSearchHint => 'Beitrittsbereit / Noch kein Link';

  @override
  String meetingsSummarySubjectSegment(Object subject) {
    return ' für $subject';
  }

  @override
  String meetingsSummaryAccessSegment(Object state) {
    return ' im Status $state';
  }

  @override
  String meetingsShowingSummary(
    Object shown,
    Object total,
    Object subjectSegment,
    Object accessSegment,
  ) {
    return 'Zeige $shown von $total Meetings$subjectSegment$accessSegment.';
  }

  @override
  String get meetingsNoMatchTitle => 'Keine Meetings passen zu diesen Filtern';

  @override
  String get meetingsNoMatchSubtitle =>
      'Versuchen Sie alle Fächer oder fügen Sie Meetings ohne Links ein, um mehr Ergebnisse in die Liste zurückzubringen.';

  @override
  String get meetingsListSubtitle =>
      'Tippen Sie auf ein Meeting, um die Vollbilddetailansicht zu öffnen und zu seinem angehängten Link zu springen, wenn verfügbar.';

  @override
  String meetingsDateTimeValue(Object date, Object time) {
    return '$date • $time';
  }

  @override
  String meetingsSharedByValue(Object name) {
    return 'Geteilt von $name';
  }

  @override
  String get meetingsPreviewFallback =>
      'Öffnen Sie dieses Meeting, um den angehängten Link und die neuesten Klassenzimmer-Details anzuzeigen.';

  @override
  String get meetingsNoValidLinkAttached =>
      'Es ist noch kein gültiger Meeting-Link angehängt.';

  @override
  String get meetingsCouldNotOpenLink =>
      'Meeting-Link konnte nicht geöffnet werden.';

  @override
  String get meetingsNoLinkToCopy => 'Noch kein Meeting-Link zum Kopieren.';

  @override
  String get meetingsLinkCopied => 'Meeting-Link kopiert.';

  @override
  String get meetingsUnavailableTitle => 'Meeting nicht verfügbar';

  @override
  String get meetingsUnavailableSubtitle =>
      'Dieses Meeting konnte im aktuellen Feed nicht gefunden werden. Es wurde möglicherweise entfernt oder ist nicht offline verfügbar.';

  @override
  String get meetingsUnavailableHint =>
      'Gehen Sie zurück und aktualisieren Sie die Meetings-Liste.';

  @override
  String get meetingsNoLinkAttachedYet => 'Noch kein Link angehängt';

  @override
  String get meetingsAttachedLinkTitle => 'Angehängter Meeting-Link';

  @override
  String get meetingsAttachedLinkMissingBody =>
      'Dieses Meeting ist in Ihrem Klassenzimmer-Feed sichtbar, aber im aktuellen Schülerdatensatz ist keine gültige URL angehängt.';

  @override
  String get meetingsDetailsTitle => 'Meeting-Details';

  @override
  String get meetingsDetailsSubtitle =>
      'Alles Schülerrelevante, das derzeit in der Klassenzimmer-Meeting-Datensatz verfügbar ist.';

  @override
  String get meetingsDetailClassroomLabel => 'Klassenzimmer';

  @override
  String get meetingsSharedByLabel => 'Geteilt von';

  @override
  String get meetingsIdLabel => 'Meeting-ID';

  @override
  String get meetingsAttachedLinkSubtitle =>
      'Verwenden Sie die angehängte URL, um beizutreten oder den Meeting-Link zu kopieren, wenn Ihr Klassenzimmer einen bereitstellt.';

  @override
  String get meetingsOpening => 'Wird geöffnet';

  @override
  String get meetingsOpenLink => 'Link öffnen';

  @override
  String get meetingsCopyLink => 'Link kopieren';

  @override
  String get meetingsAccessPanelTitle => 'Meeting-Zugriff';

  @override
  String get meetingsAccessPanelReadyBody =>
      'Öffnen Sie die angehängte URL in Ihrem Browser oder in der Meeting-App.';

  @override
  String get meetingsJoinAction => 'Beitreten';

  @override
  String get announcementsDetailLoadFailedHint =>
      'Gehen Sie zurück und versuchen Sie, den Ankündigungsposteingang zu aktualisieren.';

  @override
  String get announcementsUnavailableTitle => 'Ankündigung nicht verfügbar';

  @override
  String announcementsUnavailableSubtitle(Object audience) {
    return 'Diese Ankündigung ist nicht mehr im veröffentlichten Feed für $audience verfügbar.';
  }

  @override
  String get announcementsUnavailableHint =>
      'Gehen Sie zurück zum Posteingang, um fortzufahren.';

  @override
  String announcementsPublishedReadStateBody(Object audience) {
    return 'Diese Ankündigung wurde für $audience veröffentlicht und Ihr Lesestatus wird lokal auf diesem Gerät gespeichert.';
  }

  @override
  String get announcementsDetailsTitle => 'Ankündigungsdetails';

  @override
  String get announcementsDetailsSubtitle =>
      'Veröffentlichte Metadaten für diese Ankündigung und deren aktuellen Lesestatus.';

  @override
  String get announcementsSeverityLabel => 'Schweregrad';

  @override
  String get announcementsCreatedLabel => 'Erstellt';

  @override
  String get announcementsIdLabel => 'Ankündigungs-ID';

  @override
  String get announcementsFullContentTitle => 'Vollständiger Inhalt';

  @override
  String get announcementsFullContentSubtitle =>
      'Der vollständige Ankündigungstext wird hier angezeigt, nachdem Sie das Element aus dem Posteingang öffnen.';

  @override
  String get announcementsReadStateTitle => 'Lesestatus';

  @override
  String get announcementsReadStateBodyRead =>
      'Diese Ankündigung ist auf diesem Gerät als gelesen markiert.';

  @override
  String get announcementsReadStateBodyUnread =>
      'Diese Ankündigung ist auf diesem Gerät noch ungelesen.';

  @override
  String get alertsTitle => 'Warnungen';

  @override
  String get alertsSubtitle =>
      'Hier erscheinen Dinge, die jetzt Aufmerksamkeit brauchen, nicht nur allgemeine Updates.';

  @override
  String get alertsAttendanceTitle => 'Anwesenheit braucht Aufmerksamkeit';

  @override
  String alertsAttendanceBody(Object rate) {
    return 'Deine Anwesenheitsquote liegt bei $rate%. Ein paar verpasste Stunden können sich schnell summieren.';
  }

  @override
  String get alertsWeakestSubjectTitle => 'Signal für schwächstes Fach';

  @override
  String alertsWeakestSubjectBody(Object subject) {
    return '$subject braucht basierend auf deinen neuesten Noten aktuell die meiste Aufmerksamkeit.';
  }

  @override
  String get alertsPracticeWeakAreaTitle => 'Schwäche im Training';

  @override
  String alertsPracticeWeakAreaBody(Object topic, Object subject) {
    return '$topic in $subject ist aktuell dein deutlichstes Schwachthema.';
  }

  @override
  String get alertsPracticeTrendDroppedTitle => 'Trainingstrend gefallen';

  @override
  String get alertsPracticeTrendDroppedBody =>
      'Deine 7-Tage-Leistung liegt unter deinem 30-Tage-Niveau. Geh langsamer vor und festige die Grundlagen, bevor du weiter Druck machst.';

  @override
  String get alertsEmpty =>
      'Im Moment ist alles ruhig. Wenn etwas dringend Aufmerksamkeit braucht, erscheint es hier.';

  @override
  String get student => 'Schüler';

  @override
  String get classroomDetailPhoto => 'Foto';

  @override
  String get classroomDetailVoiceNote => 'Sprachnotiz';

  @override
  String get classroomDetailVideo => 'Video';

  @override
  String get classroomDetailFile => 'Datei';

  @override
  String get classroomDetailEmptyValue => '(leer)';

  @override
  String get classroomDetailAttachmentUnavailable => 'Anhang nicht verfügbar.';

  @override
  String get classroomDetailAudioUnavailable => 'Audio nicht verfügbar.';

  @override
  String get classroomDetailCouldNotOpenAttachment =>
      'Anhang konnte nicht geöffnet werden.';

  @override
  String get classroomDetailVoiceMessage => 'Sprachnachricht';

  @override
  String get classroomDetailVideoFile => 'Videodatei';

  @override
  String get classroomDetailAttachedFile => 'Angehängte Datei';

  @override
  String get classroomDetailAttachment => 'Anhang';

  @override
  String get classroomDetailPinAction => 'Anheften';

  @override
  String get classroomDetailUnpinAction => 'Lösen';

  @override
  String get classroomDetailMessageInfoTitle => 'Nachrichteninfo';

  @override
  String get classroomDetailForwardedSingle => 'Weitergeleitet';

  @override
  String classroomDetailForwardedMultiple(Object count) {
    return '$count Nachrichten weitergeleitet';
  }

  @override
  String get classroomDetailCannotForwardPending =>
      'Weiterleiten in einen Anfrage-Chat ist erst nach Freigabe möglich';

  @override
  String get classroomDetailCouldNotForwardSelected =>
      'Ausgewählte Nachrichten konnten nicht weitergeleitet werden';

  @override
  String classroomDetailSelectedCount(Object count) {
    return '$count ausgewählt';
  }

  @override
  String classroomDetailDeleteCount(Object count) {
    return 'Löschen ($count)';
  }

  @override
  String get classroomDetailSelectAllTooltip => 'Alle auswählen';

  @override
  String get classroomDetailCancelTooltip => 'Abbrechen';

  @override
  String get classroomDetailMicrophoneAccessTitle =>
      'Mikrofonzugriff erforderlich';

  @override
  String get classroomDetailMicrophoneAccessBody =>
      'Bitte erlaube den Mikrofonzugriff in den Einstellungen -> ClassMate, um Sprachnotizen zu senden.';

  @override
  String get classroomDetailOpenSettingsAction => 'Einstellungen öffnen';

  @override
  String classroomDetailForwardTargetNext(Object label) {
    return 'Weiterleitungsziel als Nächstes: $label';
  }

  @override
  String get classroomDetailEditMessageTitle => 'Nachricht bearbeiten';

  @override
  String get classroomDetailEditMessageHint => 'Bearbeite deine Nachricht...';

  @override
  String get classroomDetailLeaveClassroomTitle => 'Klasse verlassen?';

  @override
  String get classroomDetailLeaveClassroomBody =>
      'Du wirst aus dieser Klasse entfernt.';

  @override
  String get classroomDetailLeaveAction => 'Verlassen';

  @override
  String get classroomDetailNoAssignmentsTitle => 'Noch keine Aufgaben';

  @override
  String get classroomDetailNoAssignmentsSubtitle =>
      'Diese Klasse hat im Moment keine Aufgaben.';

  @override
  String get classroomDetailAssignmentFallback => 'Aufgabe';

  @override
  String get classroomDetailNoMaterialsTitle => 'Noch keine Materialien';

  @override
  String get classroomDetailNoMaterialsSubtitle =>
      'Diese Klasse hat im Moment keine Materialien.';

  @override
  String get classroomDetailMaterialFallback => 'Material';

  @override
  String get classroomDetailNoMeetingsTitle => 'Noch keine Meetings';

  @override
  String get classroomDetailNoMeetingsSubtitle =>
      'Diese Klasse hat im Moment keine Meetings.';

  @override
  String get classroomDetailMeetingFallback => 'Meeting';

  @override
  String get classroomDetailCouldNotLoadPeople =>
      'Personen konnten nicht geladen werden';

  @override
  String get classroomDetailNoPeopleTitle => 'Noch keine Personen';

  @override
  String get classroomDetailNoPeopleSubtitle =>
      'In dieser Klasse ist noch niemand sichtbar.';

  @override
  String get classroomDetailTabChat => 'Chat';

  @override
  String get classroomDetailTabMaterials => 'Materialien';

  @override
  String get classroomDetailTabPeople => 'Personen';

  @override
  String get classroomChatMediaSendPhoto => 'Foto senden';

  @override
  String get classroomChatMediaSendPhotoSubtitle =>
      'Ein Bild im Klassenchat teilen';

  @override
  String get classroomChatMediaSendVoiceMessage => 'Sprachnachricht senden';

  @override
  String get classroomChatMediaSendVoiceMessageSubtitle =>
      'Eine Sprachnotiz aufnehmen und senden';

  @override
  String get classroomDetailCouldNotLoadTab =>
      'Tab konnte nicht geladen werden';

  @override
  String get classroomDetailDeletedByYou => 'Du hast diese Nachricht gelöscht';

  @override
  String get classroomDetailDeletedMessage => 'Diese Nachricht wurde gelöscht';

  @override
  String get practiceSetupDifficultyEasy => 'Leicht';

  @override
  String get practiceSetupDifficultyMedium => 'Mittel';

  @override
  String get practiceSetupDifficultyHard => 'Schwer';

  @override
  String get practiceSetupDifficultyOlympiad => 'Olympiade';

  @override
  String get practiceSetupDifficultyAdaptive => 'Adaptiv';

  @override
  String get practiceSetupModeLabelPractice => 'Üben';

  @override
  String get practiceSetupModeLabelFlashcards => 'Karteikarten';

  @override
  String get practiceSetupModeLabelSpeedRound => 'Schnellrunde';

  @override
  String get practiceSetupModeLabelExamPrep => 'Prüfungsvorbereitung';

  @override
  String get practiceSetupModeLabelConceptBuilder => 'Konzeptaufbau';

  @override
  String get practiceSetupModeLabelAdaptive => 'Adaptiv';

  @override
  String get practiceSetupModeLabelBagrut => 'Bagrut';

  @override
  String get practiceSetupModeSubtitlePractice => 'Ausgewogenes tägliches Üben';

  @override
  String get practiceSetupModeSubtitleFlashcards =>
      'Aufdecken und selbst erinnern';

  @override
  String get practiceSetupModeSubtitleSpeedRound => 'Schnelles Drucktraining';

  @override
  String get practiceSetupModeSubtitleExamPrep => 'Ruhiger Prüfungsfluss';

  @override
  String get practiceSetupModeSubtitleConceptBuilder =>
      'Erst Konzept, dann lösen';

  @override
  String get practiceSetupModeSubtitleAdaptive =>
      'Schwierigkeit passt sich live an';

  @override
  String get practiceSetupModeSubtitleBagrut => 'Strenger offizieller Stil';

  @override
  String get practiceSetupModeHelpPractice =>
      'Ausgewogener Modus: lösen, prüfen, erklären und weitermachen.';

  @override
  String get practiceSetupModeHelpFlashcards =>
      'Karteikarten funktionieren am besten, wenn du dich vor dem Aufdecken erst erinnerst.';

  @override
  String get practiceSetupModeHelpSpeedRound =>
      'Die Schnellrunde trainiert schnelles Abrufen. Bewege dich schnell und vertraue starken Instinkten.';

  @override
  String get practiceSetupModeHelpExamPrep =>
      'Prüfungsvorbereitung ist ruhiger und formaler, wie eine echte Schulstunde.';

  @override
  String get practiceSetupModeHelpConceptBuilder =>
      'Konzeptaufbau erklärt zuerst die Idee und bittet dich dann, sie anzuwenden.';

  @override
  String get practiceSetupModeHelpAdaptive =>
      'Der adaptive Modus ändert die Herausforderung je nach deiner Leistung.';

  @override
  String get practiceSetupModeHelpBagrut =>
      'Der Bagrut-Modus konzentriert sich auf strenges Lösen und Überprüfen im Prüfungsstil.';

  @override
  String get practiceSetupModeInfoTitle => 'So funktioniert jeder Modus';

  @override
  String get practiceSetupHeroTitle => 'Sitzung starten';

  @override
  String get practiceSetupHeroSubtitle =>
      'Wähle Modus, Timing und Schwierigkeit.';

  @override
  String get practiceSetupInfiniteLives => 'Unendliche Leben';

  @override
  String practiceSetupLivesCount(Object count) {
    return '$count Leben';
  }

  @override
  String get practiceSetupAiTiming => 'KI-Timing';

  @override
  String practiceSetupSecondsShort(Object seconds) {
    return '${seconds}s';
  }

  @override
  String practiceSetupQuestionsCount(Object count) {
    return '$count Fragen';
  }

  @override
  String practiceSetupSummarySubject(Object subject) {
    return 'Fach: $subject';
  }

  @override
  String practiceSetupSummaryTopic(Object topic) {
    return 'Thema: $topic';
  }

  @override
  String practiceSetupSummaryMode(Object mode) {
    return 'Modus: $mode';
  }

  @override
  String practiceSetupSummaryDifficulty(Object difficulty) {
    return 'Schwierigkeit: $difficulty';
  }

  @override
  String practiceSetupSummaryQuestions(Object count) {
    return 'Fragen: $count';
  }

  @override
  String practiceSetupSummaryTiming(Object timing) {
    return 'Timing: $timing';
  }

  @override
  String practiceSetupSummaryLives(Object lives) {
    return 'Leben: $lives';
  }

  @override
  String get practiceSetupSectionSubjectTopic => 'Fach und Thema';

  @override
  String get practiceSetupFieldSubject => 'Fach';

  @override
  String get practiceSetupFieldSubjectHint => 'Fach wählen';

  @override
  String get practiceSetupChooseSubject => 'Fach wählen';

  @override
  String get practiceSetupFieldCustomSubject => 'Eigenes Fach';

  @override
  String get practiceSetupFieldCustomSubjectHint => 'Eigenes Fach eingeben';

  @override
  String get practiceSetupDialogCustomSubjectTitle => 'Eigenes Fach';

  @override
  String get practiceSetupDialogEnterSubject => 'Fach eingeben';

  @override
  String get practiceSetupUseAction => 'Verwenden';

  @override
  String get practiceSetupFieldTopic => 'Thema';

  @override
  String get practiceSetupFieldTopicHint => 'Unterthema wählen';

  @override
  String get practiceSetupChooseTopic => 'Thema wählen';

  @override
  String get practiceSetupFieldCustomTopic => 'Eigenes Thema';

  @override
  String get practiceSetupFieldCustomTopicHint => 'Eigenes Thema eingeben';

  @override
  String get practiceSetupDialogCustomTopicTitle => 'Eigenes Thema';

  @override
  String get practiceSetupDialogEnterTopic => 'Thema eingeben';

  @override
  String get practiceSubjectMath => 'Mathematik';

  @override
  String get practiceSubjectPhysics => 'Physik';

  @override
  String get practiceSubjectComputerScience => 'Informatik';

  @override
  String get practiceSubjectChemistry => 'Chemie';

  @override
  String get practiceSubjectBiology => 'Biologie';

  @override
  String get practiceSubjectEnglish => 'Englisch';

  @override
  String get practiceSubjectArabic => 'Arabisch';

  @override
  String get practiceSubjectHebrew => 'Hebräisch';

  @override
  String get practiceSubjectGeneralKnowledge => 'Allgemeinwissen';

  @override
  String get practiceTopicAllTopics => 'Alle Themen';

  @override
  String get practiceTopicAlgebra => 'Algebra';

  @override
  String get practiceTopicLinearEquations => 'Lineare Gleichungen';

  @override
  String get practiceTopicQuadraticEquations => 'Quadratische Gleichungen';

  @override
  String get practiceTopicFunctions => 'Funktionen';

  @override
  String get practiceTopicGeometry => 'Geometrie';

  @override
  String get practiceTopicTriangles => 'Dreiecke';

  @override
  String get practiceTopicCircles => 'Kreise';

  @override
  String get practiceTopicAnalyticGeometry => 'Analytische Geometrie';

  @override
  String get practiceTopicTrigonometry => 'Trigonometrie';

  @override
  String get practiceTopicProbability => 'Wahrscheinlichkeit';

  @override
  String get practiceTopicStatistics => 'Statistik';

  @override
  String get practiceTopicSequences => 'Folgen';

  @override
  String get practiceTopicCalculus => 'Analysis';

  @override
  String get practiceTopicLimits => 'Grenzwerte';

  @override
  String get practiceTopicDerivatives => 'Ableitungen';

  @override
  String get practiceTopicMechanics => 'Mechanik';

  @override
  String get practiceTopicKinematics => 'Kinematik';

  @override
  String get practiceTopicNewtonLaws => 'Newtonsche Gesetze';

  @override
  String get practiceTopicForces => 'Kräfte';

  @override
  String get practiceTopicEnergy => 'Energie';

  @override
  String get practiceTopicMomentum => 'Impuls';

  @override
  String get practiceTopicElectricity => 'Elektrizität';

  @override
  String get practiceTopicElectricField => 'Elektrisches Feld';

  @override
  String get practiceTopicCircuits => 'Stromkreise';

  @override
  String get practiceTopicWaves => 'Wellen';

  @override
  String get practiceTopicOptics => 'Optik';

  @override
  String get practiceTopicThermodynamics => 'Thermodynamik';

  @override
  String get practiceTopicConditions => 'Bedingungen';

  @override
  String get practiceTopicBooleanLogic => 'Boolesche Logik';

  @override
  String get practiceTopicIfElse => 'Wenn / Sonst';

  @override
  String get practiceTopicNestedConditions => 'Verschachtelte Bedingungen';

  @override
  String get practiceTopicLoops => 'Schleifen';

  @override
  String get practiceTopicVariables => 'Variablen';

  @override
  String get practiceTopicArrays => 'Arrays';

  @override
  String get practiceTopicStrings => 'Zeichenketten';

  @override
  String get practiceTopicAlgorithms => 'Algorithmen';

  @override
  String get practiceTopicComplexity => 'Komplexität';

  @override
  String get practiceTopicRecursion => 'Rekursion';

  @override
  String get practiceTopicAtoms => 'Atome';

  @override
  String get practiceTopicPeriodicTable => 'Periodensystem';

  @override
  String get practiceTopicChemicalBonds => 'Chemische Bindungen';

  @override
  String get practiceTopicReactions => 'Reaktionen';

  @override
  String get practiceTopicStoichiometry => 'Stöchiometrie';

  @override
  String get practiceTopicAcidsAndBases => 'Säuren und Basen';

  @override
  String get practiceTopicOrganicChemistry => 'Organische Chemie';

  @override
  String get practiceTopicCells => 'Zellen';

  @override
  String get practiceTopicGenetics => 'Genetik';

  @override
  String get practiceTopicHumanBody => 'Menschlicher Körper';

  @override
  String get practiceTopicEcology => 'Ökologie';

  @override
  String get practiceTopicEvolution => 'Evolution';

  @override
  String get practiceTopicSystems => 'Systeme';

  @override
  String get practiceTopicGrammar => 'Grammatik';

  @override
  String get practiceTopicReadingComprehension => 'Leseverständnis';

  @override
  String get practiceTopicVocabulary => 'Wortschatz';

  @override
  String get practiceTopicTenses => 'Zeitformen';

  @override
  String get practiceTopicWriting => 'Schreiben';

  @override
  String get practiceTopicRhetoric => 'Rhetorik';

  @override
  String get practiceSetupSectionMode => 'Modus';

  @override
  String get practiceSetupSectionDifficulty => 'Schwierigkeit';

  @override
  String get practiceSetupSectionControls => 'Sitzungssteuerung';

  @override
  String get practiceSetupQuestionsTitle => 'Fragen';

  @override
  String get practiceSetupQuestionsCaption =>
      'Wie viele generierte Fragen enthalten sein sollen';

  @override
  String get practiceSetupTimingTitle => 'Timing';

  @override
  String get practiceSetupTimingCaption =>
      'Wähle zuerst den Umfang, dann KI, deine eigene Zeit oder unendlich.';

  @override
  String get practiceSetupTimingScopePerQuestion => 'Pro Frage';

  @override
  String get practiceSetupTimingScopeWholeQuiz => 'Ganzer Test';

  @override
  String get practiceSetupTimingModeAi => 'KI';

  @override
  String get practiceSetupTimingModeMyTime => 'Meine Zeit';

  @override
  String get practiceSetupTimingModeInfinite => 'Unendlich';

  @override
  String get practiceSetupTimingCustomPerQuestionTitle => 'Sekunden pro Frage';

  @override
  String get practiceSetupTimingCustomPerQuestionCaption =>
      'Dein eigener Timer für jede Frage';

  @override
  String get practiceSetupTimingCustomQuizMinutesTitle => 'Quiz-Minuten';

  @override
  String get practiceSetupTimingCustomQuizMinutesCaption =>
      'Dein eigener Timer für das ganze Quiz';

  @override
  String get practiceSetupInfiniteLivesTitle => 'Unendliche Leben';

  @override
  String get practiceSetupInfiniteLivesSubtitle =>
      'Beende die Sitzung nie wegen falscher Antworten';

  @override
  String get practiceSetupLivesTitle => 'Leben';

  @override
  String get practiceSetupLivesCaption =>
      'Erlaubte Fehler, bevor die Sitzung endet';

  @override
  String get practiceSetupTooltipHistory => 'Übungsverlauf';

  @override
  String get practiceHistoryTitle => 'Trainingshistorie';

  @override
  String get practiceHistoryClearTooltip => 'Verlauf löschen';

  @override
  String get practiceHistoryClearConfirmTitle => 'Trainingshistorie löschen?';

  @override
  String get practiceHistoryClearConfirmBody =>
      'Dies entfernt alle gespeicherten Trainingssitzungen von diesem Gerät.';

  @override
  String get practiceHistoryLoadError =>
      'Trainingshistorie konnte gerade nicht geladen werden.';

  @override
  String get practiceHistoryErrorPrefix => 'Fehler:';

  @override
  String get practiceHistoryEmpty => 'Noch keine Trainingssitzungen.';

  @override
  String get practiceHistoryDeleteConfirmTitle => 'Diese Sitzung löschen?';

  @override
  String get practiceHistoryDeleteConfirmBody =>
      'Dies entfernt nur diese gespeicherte Trainingssitzung.';

  @override
  String get practiceHistoryOpenReview => 'Überprüfung öffnen';

  @override
  String get practiceHistoryDeleteSession => 'Sitzung löschen';

  @override
  String get practiceHistoryDebugTitle => 'Debug: Übungsverlauf';

  @override
  String get practiceAnalyticsTitle => 'Übungsanalysen';

  @override
  String get practiceAnalyticsSectionOverall => 'Gesamt';

  @override
  String get practiceAnalyticsRecentSessionsTitle => 'Letzte Sitzungen';

  @override
  String practiceAnalyticsRecentSessionsSummary(
    Object sessions,
    Object correct,
    Object answered,
    Object accuracy,
    Object xp,
  ) {
    return '$sessions Sitzungen • $correct/$answered richtig • $accuracy% • XP $xp';
  }

  @override
  String get practiceAnalyticsSectionWeakestTopics => 'Schwächste Themen';

  @override
  String get practiceAnalyticsSectionStrongestTopics => 'Stärkste Themen';

  @override
  String get practiceAnalyticsSectionModePerformance => 'Modusleistung';

  @override
  String get practiceAnalyticsNoTopicData => 'Noch keine Themendaten';

  @override
  String get practiceAnalyticsNoModeData => 'Noch keine Modusdaten';

  @override
  String get savedQuestionsTopSubjectNone => 'Noch nichts';

  @override
  String get savedQuestionsHeroSubtitle =>
      'Fragen, die Sie während des Trainings gespeichert haben, sollten leicht erneut besucht werden können. Diese Seite ist der saubere Wiederholungs-Hub dafür.';

  @override
  String get savedQuestionsSavedMetric => 'Gespeichert';

  @override
  String get savedQuestionsTopSubjectMetric => 'Bestes Thema';

  @override
  String get savedQuestionsQuickActionsSubtitle =>
      'Springen Sie direkt ins Training zurück oder durchsuchen Sie Community-Lösungen.';

  @override
  String get savedQuestionsOpenPractice => 'Training öffnen';

  @override
  String get savedQuestionsOpenPracticeSubtitle =>
      'Starten Sie eine neue Sitzung und bauen Sie weiter Momentum auf';

  @override
  String get savedQuestionsOpenSolutions => 'Lösungen öffnen';

  @override
  String get savedQuestionsOpenSolutionsSubtitle =>
      'Durchsuchen Sie hochgeladene Lösungen nach Thema, Buch, Seite und Frage';

  @override
  String get savedQuestionsQueueTitle => 'Ihre gespeicherte Warteschlange';

  @override
  String get savedQuestionsQueueSubtitle =>
      'Fragen, die Sie im Training speichern, erscheinen hier, damit Sie sie schnell erneut öffnen und weiterhin an Ihren Schwachstellen arbeiten können.';

  @override
  String get savedQuestionsEmptyTitle => 'Noch keine Fragen gespeichert';

  @override
  String get savedQuestionsEmptySubtitle =>
      'Speichern Sie eine Frage aus dem Training, um sie später erneut zu besuchen, öffnen Sie verwandte Lösungen und verfolgen Sie die Themen, die noch Arbeit benötigen.';

  @override
  String get savedQuestionsClearAction => 'Gespeicherte Fragen löschen';

  @override
  String get savedQuestionsWhyItWorks => 'Warum es funktioniert';

  @override
  String savedQuestionsHoursTarget(Object count) {
    return '$count h Ziel';
  }

  @override
  String savedQuestionsMinutesTarget(Object count) {
    return '$count min Ziel';
  }

  @override
  String savedQuestionsSecondsTarget(Object count) {
    return '$count sec Ziel';
  }

  @override
  String get practiceSetupTooltipAnalytics => 'Übungsanalyse';

  @override
  String get practiceSetupStopGenerating => 'Generierung stoppen';

  @override
  String get practiceSetupGenerating => 'Wird generiert...';

  @override
  String get practiceSetupStartSession => 'Sitzung starten';

  @override
  String get practiceSetupSearchHint => 'Suchen...';

  @override
  String get practiceSessionModeDescriptionPractice =>
      'Ausgewogenes Lösen mit sofortiger Prüfung und Rückmeldung.';

  @override
  String get practiceSessionModeDescriptionFlashcards =>
      'Gedächtnisorientierter Modus für schnelles Abrufen und Behalten.';

  @override
  String get practiceSessionModeDescriptionSpeedRound =>
      'Schnelle, reibungsarme, zeitgesteuerte Druckwiederholungen.';

  @override
  String get practiceSessionModeDescriptionExamPrep =>
      'Formelles Lösen mit Prüfungsgefühl und weniger Gamification.';

  @override
  String get practiceSessionModeDescriptionConceptBuilder =>
      'Erst die Idee verstehen, dann im Kontext lösen.';

  @override
  String get practiceSessionModeDescriptionAdaptive =>
      'Die Schwierigkeit ändert sich je nach deiner Leistung.';

  @override
  String get practiceSessionModeDescriptionBagrut =>
      'Offizieller formaler Bagrut-Ablauf mit einer Frage.';

  @override
  String get practiceSessionLoadingPractice =>
      'Deine Übungssitzung wird erstellt';

  @override
  String get practiceSessionLoadingFlashcards =>
      'Deine Karteikarten werden gemischt';

  @override
  String get practiceSessionLoadingSpeedRound => 'Die Schnellrunde startet';

  @override
  String get practiceSessionLoadingExamPrep =>
      'Deine Prüfungssitzung wird vorbereitet';

  @override
  String get practiceSessionLoadingConceptBuilder =>
      'Konzept-Coach wird geladen';

  @override
  String get practiceSessionLoadingAdaptive =>
      'Deine Herausforderung wird personalisiert';

  @override
  String get practiceSessionLoadingBagrut => 'Dein Bagrut-Set wird vorbereitet';

  @override
  String get practiceSessionLoadingDefault => 'Deine Sitzung wird vorbereitet';

  @override
  String practiceSessionCompleteTitle(Object mode) {
    return '$mode abgeschlossen';
  }

  @override
  String get practiceSessionMetricAnswered => 'Beantwortet';

  @override
  String get practiceSessionMetricCorrect => 'Richtig';

  @override
  String get practiceSessionMetricWrong => 'Falsch';

  @override
  String get practiceSessionMetricAccuracy => 'Genauigkeit';

  @override
  String get practiceSessionMetricTotal => 'Gesamt';

  @override
  String get practiceSessionMetricXp => 'XP';

  @override
  String get practiceSessionMetricStreak => 'Serie';

  @override
  String get practiceSessionReviewLayoutStacked => 'Gestapelt';

  @override
  String get practiceSessionReviewLayoutFocus => 'Fokus';

  @override
  String get practiceSessionFilterAll => 'Alle';

  @override
  String get practiceSessionFilterWrong => 'Falsch';

  @override
  String get practiceSessionFilterCorrect => 'Richtig';

  @override
  String get practiceSessionReviewTitle => 'Sitzungsrückblick';

  @override
  String get practiceSessionNoQuestionsForFilter =>
      'Noch keine Fragen passen zu diesem Filter.';

  @override
  String get practiceSessionNoAnswer => 'Keine Antwort';

  @override
  String get practiceSessionUnknownAnswer => 'Unbekannt';

  @override
  String get practiceSessionReflectionTitle => 'Reflexion';

  @override
  String get practiceSessionReflectionKnewIt => 'Wusste ich';

  @override
  String get practiceSessionReflectionReviewAgain => 'Nochmals wiederholen';

  @override
  String get practiceSessionBackOfCard => 'Rückseite der Karte';

  @override
  String get practiceSessionYourAnswer => 'Deine Antwort';

  @override
  String get practiceSessionCorrectAnswer => 'Richtige Antwort';

  @override
  String get practiceSessionExplanation => 'Erklärung';

  @override
  String get practiceSessionBackToSetup => 'Zurück zur Einrichtung';

  @override
  String get practiceSessionGeneralTopic => 'Allgemein';

  @override
  String practiceSessionQuestionProgress(Object current, Object total) {
    return 'Frage $current von $total';
  }

  @override
  String get practiceSessionMetricTime => 'Zeit';

  @override
  String practiceSessionMatchmakingDifficulty(Object difficulty) {
    return 'Schwierigkeit: $difficulty';
  }

  @override
  String get practiceModeActionPrevious => 'Vorherige';

  @override
  String get practiceModeActionCheckAnswer => 'Antwort prüfen';

  @override
  String get practiceModeActionNext => 'Weiter';

  @override
  String get practiceModeActionNextQuestion => 'Nächste Frage';

  @override
  String get practiceModeActionEndSession => 'Sitzung beenden';

  @override
  String get practiceModeActionEndQuestion => 'Frage beenden';

  @override
  String get practiceModeActionEndExam => 'Prüfung beenden';

  @override
  String get practiceModeActionNovaHint => 'NOVA-Hinweis';

  @override
  String get practiceModeActionReveal => 'Aufdecken';

  @override
  String get practiceModeActionShowSolution => 'Lösung anzeigen';

  @override
  String get practiceModeActionHideSolution => 'Lösung ausblenden';

  @override
  String get practiceModeActionLockIn => 'Festlegen';

  @override
  String get practiceModeActionCheckAdapt => 'Prüfen und anpassen';

  @override
  String get practiceModeActionContinue => 'Weiter';

  @override
  String get practiceModeActionSolveIt => 'Lösen';

  @override
  String get practiceModeActionNextConcept => 'Nächstes Konzept';

  @override
  String get practiceModeCardFront => 'Vorderseite der Karte';

  @override
  String get practiceModeRecallSummary => 'Erinnerungszusammenfassung';

  @override
  String get practiceModeFeelingPrompt => 'Wie hat sich das angefühlt?';

  @override
  String get practiceModeFeelingAgain => 'Nochmal';

  @override
  String get practiceModeFeelingHard => 'Schwer';

  @override
  String get practiceModeFeelingGood => 'Gut';

  @override
  String get practiceModeFeelingEasy => 'Leicht';

  @override
  String get practiceModeSpeedRoundBanner =>
      'Schnelle Runde · schnelle Entscheidungen, sofortiger Schwung';

  @override
  String get practiceModeFastFeedback => 'Schnelles Feedback';

  @override
  String get practiceModeExamPrepBanner =>
      'Prüfungsmodus · ruhigeres Layout, Antworten werden nach dem Weitergehen überprüft';

  @override
  String get practiceModeReview => 'Überprüfung';

  @override
  String get practiceModeBagrutBanner =>
      'Bagrut-Modus · offizieller Prüfungsbogenstil';

  @override
  String get practiceModeOfficialSolution => 'Lösung im offiziellen Stil';

  @override
  String get practiceModeAdaptiveWarmup => 'Aufwärmschwierigkeit';

  @override
  String get practiceModeAdaptiveTrendingUp => 'Schwierigkeit steigt';

  @override
  String get practiceModeAdaptiveEasingDown => 'Schwierigkeit sinkt etwas';

  @override
  String get practiceModeAdaptiveSteady => 'Schwierigkeit bleibt stabil';

  @override
  String get practiceModeAdaptiveFeedback => 'Adaptives Feedback';

  @override
  String get practiceModeConceptFirst => 'Zuerst das Konzept';

  @override
  String get practiceModeNowSolveIt => 'Jetzt lösen';

  @override
  String get practiceModeConceptTitle => 'Konzept';

  @override
  String get practiceModeFeedbackCorrect => 'Richtig';

  @override
  String get practiceModeFeedbackNotQuite => 'Noch nicht ganz';

  @override
  String get practiceModeFallbackQuestion => 'Frage';

  @override
  String get practiceModeNoExplanationYet => 'Noch keine Erklärung verfügbar.';

  @override
  String get teacherGradesAssessmentCreated => 'Bewertung erstellt';

  @override
  String get teacherGradesEditAssessmentTitle => 'Bewertung bearbeiten';

  @override
  String get teacherGradesFieldTitle => 'Titel';

  @override
  String get teacherGradesFieldDate => 'Datum (YYYY-MM-DD)';

  @override
  String get teacherGradesFieldMaxGrade => 'Maximale Note';

  @override
  String get teacherGradesAssessmentUpdated => 'Bewertung aktualisiert';

  @override
  String get teacherGradesDeleteAssessmentTitle => 'Bewertung löschen?';

  @override
  String teacherGradesDeleteAssessmentBody(Object title) {
    return 'Dadurch werden $title und der zugehörige Noteneintrag aus dem Lehrerbereich entfernt.';
  }

  @override
  String get teacherGradesDeleteAction => 'Löschen';

  @override
  String get teacherGradesAssessmentDeleted => 'Bewertung gelöscht';

  @override
  String get teacherGradesRosterLinkError =>
      'Diese Bewertung ist nicht mit einer Klassenliste verknüpft.';

  @override
  String get teacherGradesSaved => 'Noten gespeichert';

  @override
  String get teacherGradesSubtitle =>
      'Erstelle Bewertungen und speichere Noten anhand der Live-Klassenliste.';

  @override
  String get teacherGradesCreateAssessmentTitle => 'Bewertung erstellen';

  @override
  String get teacherGradesFieldCourse => 'Kurs';

  @override
  String get teacherGradesCreateAction => 'Erstellen';

  @override
  String get teacherGradesNoStudentsLoaded =>
      'Für diese Bewertung wurden keine Schüler geladen.';

  @override
  String get teacherGradesFieldGrade => 'Note';

  @override
  String teacherGradesMaxHint(Object grade) {
    return 'Max. $grade';
  }

  @override
  String get teacherGradesSaving => 'Speichert…';

  @override
  String teacherGradesSaveCount(Object count) {
    return '$count Noten speichern';
  }

  @override
  String get assignmentsNoDueDate => 'Kein Fälligkeitsdatum';

  @override
  String get assignmentsLoadError =>
      'Aufgaben konnten nicht geladen werden. Bitte ziehen Sie zum Aktualisieren oder versuchen Sie es erneut.';

  @override
  String get assignmentsLoadTimeout =>
      'Aufgaben brauchen zu lange zum Laden. Bitte ziehen Sie zum Aktualisieren oder versuchen Sie es später erneut.';

  @override
  String get assignmentsLoadNetwork =>
      'Aufgaben konnten nicht verbunden werden. Überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.';

  @override
  String get assignmentsStatusOverdue => 'Überfällig';

  @override
  String get assignmentsStatusDueSoon => 'Bald fällig';

  @override
  String get assignmentsStatusUpcoming => 'Anstehend';

  @override
  String get assignmentsPreviewFallback =>
      'Öffnen Sie diese Aufgabe, um die vollständigen Anweisungen zu sehen und Ihre Arbeit vorzubereiten.';

  @override
  String get assignmentsSubmissionPrepEmpty =>
      'Legen Sie Ihre Notiz oder Dateien hier ab.';

  @override
  String assignmentsSubmissionPrepCount(Object count) {
    return '$count Datei(en) lokal angehängt.';
  }

  @override
  String get assignmentsHeroSubtitle =>
      'Alle Klassenzimmeraufgaben in einer übersichtlichen Ansicht mit vollbildiger Detailseite und einem dedizierten Platz zur Vorbereitung.';

  @override
  String get assignmentsSubjectsMetric => 'Fächer';

  @override
  String get assignmentsNothingAssignedYet => 'Noch nichts zugewiesen';

  @override
  String get assignmentsNoAssignmentsForAccount =>
      'Für dieses Schülerkonto sind derzeit keine Klassenzimmeraufgaben verfügbar.';

  @override
  String assignmentsNextThingBody(Object title, Object due) {
    return '$title ist das Nächste, das Sie sich ansehen sollten. $due.';
  }

  @override
  String get assignmentsPullToCheckAgain =>
      'Zum erneuten Überprüfen nach unten ziehen.';

  @override
  String get assignmentsFiltersSubtitle =>
      'Grenzen Sie die Liste nach Fach oder Dringlichkeit ein, um sich auf das Wichtigste zu konzentrieren.';

  @override
  String get assignmentsSubjectLabel => 'Fach';

  @override
  String get assignmentsAllSubjects => 'Alle Fächer';

  @override
  String get assignmentsSearchSubjects => 'Fächer durchsuchen';

  @override
  String get assignmentsStatusLabel => 'Status';

  @override
  String get assignmentsAllStatuses => 'Alle Status';

  @override
  String get assignmentsSearchStatuses => 'Status durchsuchen';

  @override
  String assignmentsShowingSummary(Object shown, Object total) {
    return 'Zeige $shown von $total Aufgaben.';
  }

  @override
  String get assignmentsNoFilterMatchesTitle =>
      'Keine Aufgaben entsprechen diesen Filtern';

  @override
  String get assignmentsNoFilterMatchesSubtitle =>
      'Versuchen Sie alle Fächer oder eine breitere Statusansicht, um mehr Aufgaben in die Liste zurückzubringen.';

  @override
  String get assignmentsClearFiltersHint =>
      'Löschen Sie Filter, um alles erneut zu sehen.';

  @override
  String get assignmentsListSubtitle =>
      'Tippen Sie auf eine Aufgabe, um die vollbildige Detailansicht zu öffnen und Ihre Arbeit vorzubereiten.';

  @override
  String get assignmentsAddNoteBeforePrepare =>
      'Fügen Sie eine Notiz hinzu oder fügen Sie eine Datei an, bevor Sie Ihre Arbeit vorbereiten.';

  @override
  String get assignmentsWorkDraftPrepared => 'Arbeitsentwurf vorbereitet.';

  @override
  String get assignmentsWorkDraftPreparedWithFiles =>
      'Arbeitsentwurf vorbereitet. Angehängte Dateien werden auf diesem Gerät gespeichert.';

  @override
  String get assignmentsUnavailableTitle => 'Aufgabe nicht verfügbar';

  @override
  String get assignmentsUnavailableSubtitle =>
      'Diese Aufgabe konnte nicht im aktuellen Feed gefunden werden. Sie wurde möglicherweise entfernt oder ist offline nicht verfügbar.';

  @override
  String get assignmentsUnavailableHint =>
      'Gehen Sie zurück und aktualisieren Sie die Aufgabenliste.';

  @override
  String get assignmentsOverdueBannerBody =>
      'Diese Aufgabe ist überfällig. Öffnen Sie unten Ihren Arbeitsbereich, um zu bestätigen, was Sie einreichen möchten.';

  @override
  String get assignmentsWorkAreaBannerBody =>
      'Verwenden Sie unten den Arbeitsbereich, um Dateien zu organisieren, eine Notiz zu schreiben und alles an einem Ort bereit zu halten.';

  @override
  String get assignmentsDetailsSectionTitle => 'Aufgabendetails';

  @override
  String get assignmentsDetailsSectionSubtitle =>
      'Alles Relevante für Schüler, das in der Klassenzimmeraufgabe verfügbar ist.';

  @override
  String get assignmentsDetailDueLabel => 'Fälligkeitsdatum';

  @override
  String get assignmentsDetailClassroomLabel => 'Klassenzimmer';

  @override
  String get assignmentsDetailTeacherLabel => 'Lehrer';

  @override
  String get assignmentsDetailPostedByLabel => 'Gepostet von';

  @override
  String get assignmentsDetailPublishedLabel => 'Veröffentlicht';

  @override
  String get assignmentsDetailUpdatedLabel => 'Aktualisiert';

  @override
  String get assignmentsDetailIdLabel => 'Aufgaben-ID';

  @override
  String get assignmentsInstructionsTitle => 'Anweisungen';

  @override
  String get assignmentsInstructionsSubtitle =>
      'Vollständiger Aufgabentext aus dem Klassenzimmer-Feed mit erhaltener Originalformulierung.';

  @override
  String get assignmentsYourWorkTitle => 'Ihre Arbeit';

  @override
  String get assignmentsYourWorkSubtitle =>
      'Organisieren Sie eine Notiz, fügen Sie Dateien oder Dokumente an und halten Sie Ihre Abgabevorbereitung an einem fokussierten Ort bereit.';

  @override
  String get assignmentsPrivateNoteLabel => 'Private Arbeitsnotiz';

  @override
  String get assignmentsPrivateNoteHint =>
      'Fügen Sie hinzu, was Sie einreichen möchten, Erinnerungen für sich selbst oder eine Dokument-/Link-Zusammenfassung.';

  @override
  String get assignmentsAddFiles => 'Dateien oder Dokumente hinzufügen';

  @override
  String get assignmentsClearFiles => 'Dateien löschen';

  @override
  String get assignmentsStagedDeviceHint =>
      'Dateien werden auf diesem Gerät organisiert. Die Aufgabeneingabe ist in dieser App nicht verfügbar.';

  @override
  String assignmentsLastPrepared(Object time) {
    return 'Zuletzt vorbereitet $time.';
  }

  @override
  String get assignmentsSubmissionPrepTitle => 'Abgabevorbereitung';

  @override
  String get assignmentsPreparing => 'Wird vorbereitet';

  @override
  String get assignmentsPrepareWork => 'Arbeit vorbereiten';

  @override
  String get assignmentsLoadingSubtitle =>
      'Ihre Klassenzimmeraufgaben werden geladen.';

  @override
  String get assignmentsPullToRefreshRetry =>
      'Zum Aktualisieren ziehen oder unten erneut versuchen.';

  @override
  String get assignmentsFileSizeUnknown => 'Datei';

  @override
  String get assignmentsRemoveAttachment => 'Anhang entfernen';

  @override
  String get attendanceUndated => 'Ohne Datum';

  @override
  String get attendanceLoadError =>
      'Die Anwesenheit konnte jetzt nicht geladen werden. Ziehen Sie zum Aktualisieren oder versuchen Sie es erneut.';

  @override
  String get attendanceLoadTimeout =>
      'Das Laden der Anwesenheit dauert zu lange. Ziehen Sie zum Aktualisieren oder versuchen Sie es in einem Moment erneut.';

  @override
  String get attendanceLoadNetwork =>
      'Die Anwesenheit konnte jetzt keine Verbindung herstellen. Überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.';

  @override
  String get attendanceConsistencyBuilding => 'Wird noch aufgebaut';

  @override
  String get attendanceConsistencyExcellent => 'Ausgezeichnete Konsistenz';

  @override
  String get attendanceConsistencySteady => 'Größtenteils stabil';

  @override
  String get attendanceConsistencyNeedsAttention => 'Erfordert Aufmerksamkeit';

  @override
  String get attendanceConsistencyRisk => 'Anwesenheitsrisiko';

  @override
  String get attendanceWatchRecentAbsences => 'Kürzliche Abwesenheiten';

  @override
  String get attendanceWatchRepeatedLateness => 'Wiederholtes Zu-spät-Kommen';

  @override
  String get attendanceWatchExcusedAddingUp =>
      'Entschuldigte Zeit summiert sich';

  @override
  String get attendanceWatchNoFlags => 'Keine aktuellen Flaggen';

  @override
  String get attendanceAllSubjectsLowercase => 'alle Fächer';

  @override
  String attendanceShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return 'Zeige $shown von $total Markierungen für $subject in $range.';
  }

  @override
  String get attendanceDayToneAbsent => 'Abwesenheitstag';

  @override
  String get attendanceDayToneLate => 'Zu-spät-Signal';

  @override
  String get attendanceDayToneExcused => 'Entschuldigte Anwesenheit';

  @override
  String get attendanceDayToneClean => 'Sauberer Tag';

  @override
  String get attendanceLoadingSubtitle =>
      'Lädt Ihre neueste Anwesenheitszusammenfassung.';

  @override
  String get attendanceUnavailableTitle => 'Anwesenheit nicht verfügbar';

  @override
  String get attendanceHeroSubtitle =>
      'Ein klarer Überblick über Ihre Anwesenheitsquote, aktuelle Unterrichtsstunden und alles, das Aufmerksamkeit erfordert.';

  @override
  String get attendanceMetricRate => 'Satz';

  @override
  String get attendanceMetricPresent => 'Anwesenheitsmarkierungen';

  @override
  String get attendanceMetricLate => 'Zu-spät-Markierungen';

  @override
  String get attendanceMetricAbsent => 'Abwesenheitsmarkierungen';

  @override
  String attendanceHeroSignalBody(Object flag) {
    return '$flag. Der Anwesenheitsdruck kann sich leise aufbauen, daher konzentriert sich diese Ansicht auf das, was sich zuletzt am meisten geändert hat.';
  }

  @override
  String get attendanceNoSummary =>
      'Es ist noch keine Anwesenheitszusammenfassung für dieses Schülerkonto verfügbar.';

  @override
  String get attendanceEmptyTitle => 'Noch keine Anwesenheitsdatensätze';

  @override
  String get attendanceEmptySubtitle =>
      'Es wurden noch keine Anwesenheitsdatensätze für dieses Schülerkonto veröffentlicht.';

  @override
  String get attendanceFiltersSubtitle =>
      'Verwenden Sie denselben durchsuchbaren Auswahlstil wie in den Einstellungen, um die Anwesenheitsansicht nach Fach oder Zeitfenster einzugrenzen.';

  @override
  String get attendanceTimeRangeLabel => 'Zeitbereich';

  @override
  String get attendanceSearchRanges =>
      'Ganze Zeit / 7 Tage / 30 Tage / 90 Tage';

  @override
  String get attendanceNoFilteredMarksTitle =>
      'Keine Markierungen entsprechen diesen Filtern';

  @override
  String get attendanceNoFilteredMarksSubtitle =>
      'Probieren Sie alle Fächer oder einen größeren Zeitraum, um mehr Anwesenheitsmarkierungen zurück in die Ansicht zu bringen.';

  @override
  String get attendanceQuickReadTitle => 'Schnellgelesen';

  @override
  String get attendanceQuickReadSubtitleFiltered =>
      'Eine schnelle Zusammenfassung der gefilterten Anwesenheitsmarkierungen, die unten angezeigt werden.';

  @override
  String get attendanceQuickReadSubtitleAll =>
      'Eine schnelle Zusammenfassung basierend auf den neuesten verfügbaren Anwesenheitsdatensätzen.';

  @override
  String get attendanceSummaryConsistency => 'Konsistenz';

  @override
  String get attendanceSummaryWatchFor => 'Achten Sie auf';

  @override
  String get attendanceSummaryExcused => 'Entschuldigte Markierungen';

  @override
  String get attendanceSummaryMarksInView => 'Markierungen in Ansicht';

  @override
  String get attendanceSummaryRateInView => 'Satz in Ansicht';

  @override
  String get attendanceRecentDaysTitle => 'Letzte Tage';

  @override
  String get attendanceRecentDaysSubtitleFiltered =>
      'Nach Tag gruppiert für die derzeit sichtbaren gefilterten Markierungen.';

  @override
  String get attendanceRecentDaysSubtitleAll =>
      'Nach Tag gruppiert, damit Sie Abwesenheits- oder Verspätungsmuster schneller erkennen können.';

  @override
  String get attendanceLessonCountSingle => '1 Unterrichtsstunde';

  @override
  String attendanceLessonCount(Object count) {
    return '$count Unterrichtsstunden';
  }

  @override
  String get attendanceStatusPresent => 'Anwesend';

  @override
  String get attendanceStatusLate => 'Zu spät';

  @override
  String get attendanceStatusAbsent => 'Abwesend';

  @override
  String get attendanceStatusExcused => 'Entschuldigt';

  @override
  String get attendanceStatusRecorded => 'Aufgezeichnet';

  @override
  String get attendanceLessonFallback => 'Unterrichtsstunde';

  @override
  String get attendanceRangeAll => 'Ganze Zeit';

  @override
  String get attendanceRange7 => 'Letzte 7 Tage';

  @override
  String get attendanceRange30 => 'Letzte 30 Tage';

  @override
  String get attendanceRange90 => 'Letzte 90 Tage';

  @override
  String get attendanceRangeAllShort => 'Ganze Zeit';

  @override
  String get attendanceRange7Short => '7 Tage';

  @override
  String get attendanceRange30Short => '30 Tage';

  @override
  String get attendanceRange90Short => '90 Tage';

  @override
  String get gradesLoadError =>
      'Noten konnten jetzt nicht geladen werden. Zum Aktualisieren ziehen oder erneut versuchen.';

  @override
  String get gradesLoadTimeout =>
      'Das Laden der Noten dauert zu lange. Zum Aktualisieren ziehen oder in einem Moment erneut versuchen.';

  @override
  String get gradesLoadNetwork =>
      'Noten konnten gerade nicht verbunden werden. Überprüfe deine Verbindung und versuche es erneut.';

  @override
  String get gradesGeneralSubject => 'Allgemein';

  @override
  String get gradesBandBuilding => 'Wird noch aufgebaut';

  @override
  String get gradesBandExcellent => 'Ausgezeichnet';

  @override
  String get gradesBandStrong => 'Stark';

  @override
  String get gradesBandOkay => 'In Ordnung';

  @override
  String get gradesBandNeedsAttention => 'Benötigt Aufmerksamkeit';

  @override
  String get gradesBandRisk => 'Gefährdet';

  @override
  String get gradesTrendRising => 'Steigend';

  @override
  String get gradesTrendDropping => 'Fallend';

  @override
  String get gradesTrendStable => 'Stabil';

  @override
  String gradesShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return 'Zeige $shown von $total eingetragenen Noten für $subject in $range.';
  }

  @override
  String get gradesLoadingSubtitle =>
      'Lade deine neuesten akademischen Ergebnisse.';

  @override
  String get gradesUnavailableTitle => 'Noten nicht verfügbar';

  @override
  String get gradesHeroSubtitle =>
      'Eine klare Übersicht deines Durchschnitts, neuester Prüfungen und welche Fächer Schutz oder Verbesserung benötigen.';

  @override
  String get gradesMetricAverage => 'Durchschnitt';

  @override
  String get gradesMetricRecorded => 'Eingetragen';

  @override
  String get gradesMetricBestSubject => 'Bestes Fach';

  @override
  String get gradesMetricNeedsWork => 'Bedarf Arbeit';

  @override
  String gradesLatestSignalBody(
    Object assessment,
    Object subject,
    Object grade,
    Object band,
  ) {
    return '$assessment in $subject erreichte $grade. $band gerade.';
  }

  @override
  String get gradesSummaryAvailableNoRecent =>
      'Eine Notenzusammenfassung ist verfügbar, aber keine neuesten Prüfungen sind in dieser Ansicht bisher sichtbar.';

  @override
  String get gradesEmptyTitle => 'Noch keine Noten';

  @override
  String get gradesEmptySubtitle =>
      'Für dieses Schülerkonto wurden noch keine Noten veröffentlicht.';

  @override
  String get gradesFiltersSubtitle =>
      'Verwende das gleiche durchsuchbare Wahlformat wie in den Einstellungen, um Noten nach Fach oder Zeitraum einzugrenzen.';

  @override
  String get gradesNoFilteredTitle => 'Keine Noten entsprechen diesen Filtern';

  @override
  String get gradesNoFilteredSubtitle =>
      'Versuche alle Fächer oder einen breiteren Zeitraum, um mehr eingetragene Noten zurückzubekommen.';

  @override
  String get gradesQuickReadTitle => 'Schnelllese';

  @override
  String get gradesQuickReadSubtitleFiltered =>
      'Eine schnelle Zusammenfassung der derzeit angezeigten Noten.';

  @override
  String get gradesQuickReadSubtitleAll =>
      'Der schnellste Überblick, was zu schützen und was zu verbessern ist.';

  @override
  String get gradesWeakSpotLabel => 'Aktuelle Schwachstelle';

  @override
  String get gradesNoWeakSignal => 'Noch kein schwaches Fachsignal';

  @override
  String gradesWeakSpotValue(Object subject) {
    return '$subject benötigt den ersten Verbesserungsblock.';
  }

  @override
  String get gradesStrengthLabel => 'Aktuelle Stärke';

  @override
  String get gradesNoStrengthSignal => 'Noch kein starkes Fachsignal';

  @override
  String gradesStrengthValue(Object subject) {
    return '$subject ist gerade dein Vertrauensanker.';
  }

  @override
  String get gradesBandLabel => 'Bereich';

  @override
  String get gradesInViewLabel => 'In Ansicht';

  @override
  String gradesInViewCount(Object count) {
    return '$count eingetragene Noten in diesem Filter.';
  }

  @override
  String gradesInViewAverage(Object count, Object average) {
    return '$count eingetragene Noten mit Durchschnitt $average.';
  }

  @override
  String get gradesLatestAssessmentsTitle => 'Neueste Prüfungen';

  @override
  String get gradesLatestAssessmentsSubtitleFiltered =>
      'Neueste eingetragene Noten in der aktuellen gefilterten Ansicht.';

  @override
  String get gradesLatestAssessmentsSubtitleAll =>
      'Neueste eingetragene Noten in chronologischer Reihenfolge.';

  @override
  String get gradesSubjectDrilldownTitle => 'Fachdetail';

  @override
  String get gradesSubjectDrilldownSubtitleFiltered =>
      'Nach Fach gruppiert für die derzeit angezeigten Noten.';

  @override
  String get gradesSubjectDrilldownSubtitleAll =>
      'Nach Fach gruppiert, damit Tendenz und Druck schneller hervorstechen.';

  @override
  String get gradesAssessmentFallback => 'Prüfung';

  @override
  String get gradesChipBest => 'Beste';

  @override
  String get gradesNoAverageYet => 'Noch kein Durchschnitt';

  @override
  String gradesRecentAverage(Object average) {
    return 'Letzter Durchschnitt: $average';
  }

  @override
  String get actionCancel => 'Abbrechen';

  @override
  String get actionSave => 'Speichern';

  @override
  String get actionDelete => 'Löschen';

  @override
  String get actionRemove => 'Entfernen';

  @override
  String get actionBlock => 'Blockieren';

  @override
  String get actionCreate => 'Erstellen';

  @override
  String get actionShare => 'Teilen';

  @override
  String get actionScheduleVerb => 'Planen';

  @override
  String get actionAdd => 'Hinzufügen';

  @override
  String get actionKeep => 'Behalten';

  @override
  String get actionOpen => 'Öffnen';

  @override
  String get actionPublish => 'Veröffentlichen';

  @override
  String get actionPublishing => 'Wird veröffentlicht…';

  @override
  String get actionRefresh => 'Aktualisieren';

  @override
  String get msgBlockTitle => 'Diese Person blockieren?';

  @override
  String get msgBlockContent =>
      'Sie kann dir keine Nachrichten senden und du siehst ihre Nachrichten nicht mehr.';

  @override
  String get msgRenameGroup => 'Gruppe umbenennen';

  @override
  String get msgGroupName => 'Gruppenname';

  @override
  String get msgMute => 'Stumm';

  @override
  String get msgUnmute => 'Ton an';

  @override
  String get msgInviteCode => 'Einladungscode';

  @override
  String get msgCopyCode => 'Code kopieren';

  @override
  String get msgLeave => 'Verlassen';

  @override
  String get msgInviteCodeCopied => 'Einladungscode kopiert';

  @override
  String msgCodeCopied(Object code) {
    return 'Code kopiert: $code';
  }

  @override
  String msgParticipantsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Teilnehmer hinzugefügt',
      one: '1 Teilnehmer hinzugefügt',
    );
    return '$_temp0';
  }

  @override
  String msgMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mitglieder',
      one: '1 Mitglied',
    );
    return '$_temp0';
  }

  @override
  String get msgAdmin => 'Administrator';

  @override
  String get msgRemoveFromGroup => 'Aus Gruppe entfernen';

  @override
  String get msgMakeAdmin => 'Zum Admin machen';

  @override
  String get msgRemoveAdmin => 'Admin-Rechte entziehen';

  @override
  String get msgOnlyAdmin => 'Einziger Admin — zuerst einen anderen befördern';

  @override
  String msgRemoveMemberTitle(Object name) {
    return '$name entfernen?';
  }

  @override
  String get msgNotificationsMuted => 'Benachrichtigungen stummgeschaltet';

  @override
  String get msgNotificationsUnmuted => 'Benachrichtigungen aktiviert';

  @override
  String get msgJoinGroupTitle => 'Gruppe beitreten';

  @override
  String get msgJoinGroupSubtitle =>
      'Einladungscode des Gruppenadmins eingeben';

  @override
  String get examTitle => 'Prüfung';

  @override
  String get examNotFound => 'Prüfung nicht gefunden';

  @override
  String get examStudyWithNova => 'Mit NOVA lernen';

  @override
  String get examOpenInsights => 'Einblicke öffnen';

  @override
  String get examAddToCalendar => 'Zum Kalender hinzufügen';

  @override
  String get examCouldNotOpenCalendar =>
      'Kalender konnte nicht geöffnet werden.';

  @override
  String get formTitle => 'Formular';

  @override
  String get formNotFound => 'Formular nicht gefunden';

  @override
  String get formClosed => 'Dieses Formular ist geschlossen.';

  @override
  String get formCompletion => 'Abschluss';

  @override
  String get formNoTextResponses => 'Noch keine Textantworten.';

  @override
  String get meetingsCouldNotLoad =>
      'Besprechungen konnten nicht geladen werden';

  @override
  String get meetingCouldNotLoad => 'Besprechung konnte nicht geladen werden';

  @override
  String get insightsGenerateAction => 'Einblicke generieren';

  @override
  String get insightsRefreshAction => 'Aktualisieren';

  @override
  String get teacherGoToClassroom => 'Zum Klassenzimmer';

  @override
  String get teacherMarkAttendance => 'Anwesenheit erfassen';

  @override
  String get teacherPostAssignment => 'Aufgabe veröffentlichen';

  @override
  String get teacherNewAnnouncementAction => 'Neue Ankündigung';

  @override
  String get teacherViewFullWeekSchedule => 'Vollständigen Wochenplan anzeigen';

  @override
  String get teacherGroupsLabel => 'Gruppen';

  @override
  String get teacherTestsLabel => 'Tests';

  @override
  String get teacherAnnounceLabel => 'Ankündigen';

  @override
  String get teacherTitleAndMessageRequired =>
      'Titel und Nachricht sind erforderlich';

  @override
  String get teacherAnnouncementPublished => 'Ankündigung veröffentlicht';

  @override
  String teacherFailedToPublish(Object error) {
    return 'Veröffentlichung fehlgeschlagen: $error';
  }

  @override
  String get teacherAnnouncementSectionTitle => 'Ankündigung';

  @override
  String get teacherAudienceSectionTitle => 'Zielgruppe';

  @override
  String get teacherPinAnnouncement => 'Ankündigung anpinnen';

  @override
  String get teacherPinnedAtTop => 'Angepinnte Ankündigungen erscheinen oben';

  @override
  String get teacherPublishAction => 'Veröffentlichen';

  @override
  String get teacherPublishingAction => 'Wird veröffentlicht…';

  @override
  String get teacherAnnounceTitleLabel => 'Titel *';

  @override
  String get teacherAnnounceTitleHint => 'z.B. Schulveranstaltung morgen';

  @override
  String get teacherAnnounceMessageLabel => 'Nachricht *';

  @override
  String get teacherAnnounceMessageHint =>
      'Vollständige Ankündigung hier schreiben…';

  @override
  String get teacherStudentsLabel => 'Schüler';

  @override
  String get teacherParentsLabel => 'Eltern';

  @override
  String get teacherTeachersLabel => 'Lehrer';

  @override
  String get teacherWeekScheduleTitle => 'Wochenplan';

  @override
  String get teacherCouldNotLoadSchedule =>
      'Stundenplan konnte nicht geladen werden';

  @override
  String get teacherAttendanceLast30 => 'Anwesenheit (letzte 30 Tage)';

  @override
  String get teacherRecentGrades => 'Aktuelle Noten';

  @override
  String get teacherNoGradesRecorded => 'Noch keine Noten eingetragen';

  @override
  String get teacherGradeAvg => 'Notenschnitt';

  @override
  String get teacherSubmittedLabel => 'Eingereicht';

  @override
  String get teacherAnalyticsTitle => 'Analysen';

  @override
  String get teacherGradeReports => 'Notenberichte';

  @override
  String get teacherAvgLabel => 'Ø';

  @override
  String teacherBelow60(Object count) {
    return '$count unter 60%';
  }

  @override
  String teacherGradedFraction(Object graded, Object total) {
    return '$graded/$total bewertet';
  }

  @override
  String get teacherNoGradesEntered => 'Noch keine Noten eingegeben';

  @override
  String get teacherNewAssignment => 'Neue Aufgabe';

  @override
  String get teacherDeleteAssignment => 'Aufgabe löschen?';

  @override
  String get teacherDeleteAssignmentContent =>
      'Dies entfernt die Aufgabe für alle Schüler.';

  @override
  String get teacherShareMaterialTitle => 'Material teilen';

  @override
  String get teacherRemoveMaterial => 'Material entfernen?';

  @override
  String get teacherScheduleMeetingTitle => 'Besprechung planen';

  @override
  String get teacherCancelMeetingTitle => 'Besprechung absagen?';

  @override
  String get teacherCancelMeetingAction => 'Besprechung absagen';

  @override
  String get teacherJoinMeeting => 'Besprechung beitreten';

  @override
  String get teacherAddStudentTitle => 'Schüler hinzufügen';

  @override
  String teacherRemoveStudentTitle(Object name) {
    return '$name entfernen?';
  }

  @override
  String get teacherRemoveStudentContent =>
      'Dieser Schüler wird aus dem Klassenzimmer entfernt.';

  @override
  String get teacherStudentAdded => 'Schüler hinzugefügt';

  @override
  String get teacherClassroomAnalyticsTitle => 'Klassenanalysen';

  @override
  String get teacherOpenAnalyticsAction => 'Analysen öffnen';

  @override
  String teacherStudentsCount(Object count) {
    return 'Schüler ($count)';
  }

  @override
  String get teacherAssignmentLabel => 'Aufgabe';

  @override
  String get teacherShareMaterialLabel => 'Material teilen';

  @override
  String get teacherAttendanceRateLabel => 'Anwesenheitsrate';

  @override
  String get teacherSelectSessionPrompt =>
      'Wähle unten eine Sitzung aus, um die Anwesenheit zu erfassen';

  @override
  String get teacherOpenAction => 'Öffnen';

  @override
  String get chatDeleteForMe => 'Delete for me';

  @override
  String get chatDeleteForEveryone => 'Delete for everyone';

  @override
  String get chatMicNeeded => 'Microphone access needed';

  @override
  String get chatMicNeededBody =>
      'Please allow microphone access in Settings to send voice notes.';

  @override
  String get chatOpenSettings => 'Open Settings';

  @override
  String get chatCopied => 'Copied';

  @override
  String get chatCouldNotSendMedia => 'Could not send media.';

  @override
  String get chatCouldNotSendMessage => 'Could not send message.';

  @override
  String get chatCouldNotForward => 'Could not forward selected messages';

  @override
  String get chatSelectAll => 'Select all';

  @override
  String get chatDeselectAll => 'Deselect all';

  @override
  String get chatEditingMessage => 'Editing message';

  @override
  String get chatEditPlaceholder => 'Edit message…';

  @override
  String get chatMessageHint => 'Message';

  @override
  String get chatPin => 'Pin';

  @override
  String get chatUnpin => 'Unpin';

  @override
  String get chatPhoto => 'Photo';

  @override
  String get chatVideo => 'Video';

  @override
  String get chatMedia => 'Media';

  @override
  String get chatAudioFile => 'Audio file';

  @override
  String get chatVideoFile => 'Video file';

  @override
  String get chatAttachedFile => 'Attached file';

  @override
  String get chatFollowUp => 'Follow-up';

  @override
  String get chatCancelTooltip => 'Cancel';

  @override
  String get chatJoinGroup => 'Join Group';

  @override
  String get chatJoining => 'Joining…';

  @override
  String get chatJoinGroupTooltip => 'Join group by code';

  @override
  String get chatForwardNoChatAvailable => 'No approved chats available';

  @override
  String get chatFilterAll => 'All';

  @override
  String get novaDisclaimer =>
      'NOVA can make mistakes. Double-check important answers.';

  @override
  String get practiceCustomDisclaimer =>
      'Custom topics are AI-generated on the fly. Questions may drift off-topic or be inaccurate for niche subjects. Verify unfamiliar answers independently.';

  @override
  String get classroomsJoined => 'You joined the classroom!';

  @override
  String get classroomsJoinAction => 'Join Classroom';

  @override
  String get classroomsJoinTooltip => 'Join a classroom';

  @override
  String get classroomsJoinTitle => 'Join a Classroom';

  @override
  String get classroomsJoinSubtitle => 'Enter the code your teacher gave you';

  @override
  String get classroomsCouldNotOpenLink => 'Could not open link';

  @override
  String get classroomsReorderTitle => 'Reorder classrooms';

  @override
  String get classroomsNoClassroomsToReorder => 'No classrooms to reorder.';

  @override
  String get teacherPostAnnouncementAction => 'Post Announcement';

  @override
  String get announcementAudienceEveryone => 'Everyone';

  @override
  String get teacherGreetingMorning => 'Good morning';

  @override
  String get teacherGreetingAfternoon => 'Good afternoon';

  @override
  String get teacherGreetingEvening => 'Good evening';

  @override
  String get teacherTodaysClasses => 'Today\'s Classes';

  @override
  String get teacherNoDate => 'No date';

  @override
  String get teacherUpcomingTestsSubtitle => 'Next tests & quizzes';

  @override
  String get teacherNoClassesThisWeek => 'No classes this week';

  @override
  String get teacherNoClassesThisWeekSub =>
      'Your schedule for this week is empty';

  @override
  String get teacherTitleFieldLabel => 'Title *';

  @override
  String get teacherInstructionsLabel => 'Instructions';

  @override
  String get teacherLinkUrlLabel => 'Link / URL *';

  @override
  String get teacherLinkUrlHint => 'https://...';

  @override
  String get teacherDescriptionLabel => 'Description';

  @override
  String get teacherMeetingTitleLabel => 'Meeting title *';

  @override
  String get teacherMeetingLinkLabel => 'Meeting link *';

  @override
  String get teacherMeetingLinkHint => 'Zoom / Meet / Teams link';

  @override
  String get teacherStudentEmailLabel => 'Student email or ID';

  @override
  String get teacherTooltipRemoveStudent => 'Remove from classroom';

  @override
  String get teacherCouldNotLoad => 'Could not load';

  @override
  String get teacherNoAssignmentsYet => 'No assignments yet';

  @override
  String get teacherNoAssignmentsSub => 'Tap + to create the first assignment';

  @override
  String get teacherNoMaterialsYet => 'No materials yet';

  @override
  String get teacherNoMaterialsSub =>
      'Share links, documents, or resources with your class';

  @override
  String get teacherNoMeetingsScheduled => 'No meetings scheduled';

  @override
  String get teacherNoMeetingsSub => 'Tap + to schedule a class meeting';

  @override
  String get teacherAttendanceOther => 'Other';

  @override
  String get teacherTotal => 'Total';

  @override
  String get mediaOpenExternally => 'Open externally';

  @override
  String get mediaUnableToLoad => 'Unable to load image';

  @override
  String get searchHint => 'Search...';
}

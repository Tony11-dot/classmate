// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get menu => 'תפריט';

  @override
  String get sectionCore => 'ניווט ראשי';

  @override
  String get sectionSchoolTools => 'כלי בית ספר';

  @override
  String get sectionAccount => 'חשבון';

  @override
  String get navSchedule => 'לוח זמנים';

  @override
  String get navClassrooms => 'כיתות';

  @override
  String get navPractice => 'תרגול';

  @override
  String get navInsights => 'תובנות';

  @override
  String get navNova => 'נובה';

  @override
  String get navMessages => 'הודעות';

  @override
  String get navAttendance => 'נוכחות';

  @override
  String get navGrades => 'ציונים';

  @override
  String get navAssignments => 'משימות';

  @override
  String get navMeetings => 'פגישות';

  @override
  String get navAnnouncements => 'הודעות כלליות';

  @override
  String get navNotifications => 'התראות';

  @override
  String get navSolutions => 'פתרונות';

  @override
  String get navExams => 'בחינות';

  @override
  String get navForms => 'טפסים';

  @override
  String get navHome => 'בית';

  @override
  String get navTeacherWorkspace => 'סביבת המורה';

  @override
  String get navTeacherAssessments => 'הערכות וציונים';

  @override
  String get navSavedQuestions => 'שאלות שמורות';

  @override
  String get navProfile => 'פרופיל';

  @override
  String get navSettings => 'הגדרות';

  @override
  String get navLogout => 'התנתקות';

  @override
  String get roleTeacher => 'מורה';

  @override
  String get roleAdmin => 'מנהל';

  @override
  String get roleSecretary => 'מזכירות';

  @override
  String get roleParent => 'הורה';

  @override
  String get roleStudent => 'תלמיד';

  @override
  String get titleSchedule => 'לוח זמנים';

  @override
  String get titleClasses => 'כיתות';

  @override
  String get titlePractice => 'תרגול';

  @override
  String get titleInsights => 'תובנות';

  @override
  String get titleNova => 'נובה';

  @override
  String get titleMessages => 'הודעות';

  @override
  String get titleSolutions => 'פתרונות';

  @override
  String get titleExams => 'בחינות';

  @override
  String get solutionsUploadAction => 'העלאה';

  @override
  String get solutionsNoSubjectsAvailable => 'אין נושאים זמינים.';

  @override
  String solutionsNoSubjectsMatch(Object query) {
    return 'אין נושאים התואמים \"$query\".';
  }

  @override
  String solutionsBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ספרים',
      one: 'ספר אחד',
    );
    return '$_temp0';
  }

  @override
  String get solutionsBooksTitle => 'ספרים';

  @override
  String get solutionsAddBookTitle => 'הוסף ספר';

  @override
  String get solutionsBookTitleHint => 'כותרת הספר...';

  @override
  String get solutionsAddBookAction => 'הוסף ספר';

  @override
  String get solutionsSearchBooks => 'חפש ספרים';

  @override
  String get solutionsChooseSubjectFirst => 'בחר נושא קודם.';

  @override
  String solutionsNoBooksYetBody(Object action) {
    return 'אין ספרים עדיין.\nהקש על \"$action\" כדי להוסיף את הראשון.';
  }

  @override
  String solutionsNoBooksMatch(Object query) {
    return 'אין ספרים תואמים \"$query\".';
  }

  @override
  String get solutionsBookLabel => 'ספר';

  @override
  String get solutionsPagesFilterHint =>
      'הכנס מספר עמוד ומספר שאלה כדי לסנן, או השאר ריק כדי לראות הכל.';

  @override
  String get solutionsPageNumberLabel => 'מספר עמוד';

  @override
  String get solutionsPageNumberHint => 'למשל 42';

  @override
  String get solutionsQuestionNumberLabel => 'מספר שאלה';

  @override
  String get solutionsQuestionNumberHint => 'למשל 3a או 7';

  @override
  String get solutionsViewSolutionsAction => 'הצג פתרונות';

  @override
  String solutionsPageQuestionSummary(Object page, Object question) {
    return 'עמוד $page • שאלה $question';
  }

  @override
  String get solutionsExactQuestionTitle => 'פתרונות לשאלה זו בדיוק';

  @override
  String get solutionsExactQuestionEmptySubtitle =>
      'עדיין לא הועלה כלום לשאלה זו בדיוק. היה הראשון לעזור לחברי הכיתה שלך.';

  @override
  String solutionsUploadsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'נמצאו $count קבצים שהועלו',
      one: 'נמצא 1 קובץ שהועלה',
    );
    return '$_temp0';
  }

  @override
  String get solutionsExactQuestionEmptyBody =>
      'עדיין אין התאמה מדויקת. אתה יכול להעלות אחד עכשיו, או לבדוק מה חברי הכיתה שלך פתרו בעמוד זה.';

  @override
  String get solutionsLoadMoreAction => 'טען עוד';

  @override
  String get solutionsSamePageTitle => 'שאלות אחרות שנפתרו בעמוד זה';

  @override
  String get solutionsSamePageEmptySubtitle =>
      'עדיין לא הועלו שאלות שכנות מעמוד זה.';

  @override
  String get solutionsSamePageFallbackSubtitle =>
      'מקור משלים שימושי כשטרם הועלה פתרון לשאלה המדויקת שלך.';

  @override
  String get solutionsSamePageEmptyBody =>
      'עדיין אין העלאות קרובות בעמוד זה. העלאה חדשה כאן תעזור מאוד.';

  @override
  String get solutionsVerifiedByNova => 'אומת על ידי NOVA';

  @override
  String get solutionsUploadFileLimitReached => 'הגבול של 10 קבצים הושג.';

  @override
  String solutionsUploadFilesAddedLimit(int count) {
    return 'נוספו $count — גבול של 10 קבצים.';
  }

  @override
  String get solutionsUploadCompleteFields => 'השלם נושא, ספר, עמוד ושאלה.';

  @override
  String get solutionsUploadAddOneFile => 'הוסף לפחות תמונה אחת או PDF.';

  @override
  String solutionsUploadFileFailed(Object error) {
    return 'העלאת הקובץ נכשלה: $error';
  }

  @override
  String solutionsUploadCreateFailed(Object error) {
    return 'יצירת הפתרון נכשלה: $error';
  }

  @override
  String get solutionsUploadSuccess => 'הפתרון הועלה!';

  @override
  String get solutionsUploadAddNewBookOption => '+ הוסף ספר חדש...';

  @override
  String get solutionsUploadAddBookShortAction => 'הוסף';

  @override
  String get solutionsUploadTitle => 'העלה פתרון';

  @override
  String get solutionsUploadSubtitle =>
      'תמונות או PDFs אמיתיות בלבד. אימות NOVA והנחיות מופעלות לאחר ההעלאה.';

  @override
  String get solutionsUploadNoBooksAbove => 'אין ספרים — הוסף אחד למעלה';

  @override
  String get solutionsUploadCaptionOptional => 'כותרת (אופציונלי)';

  @override
  String get solutionsUploadImagesAction => 'תמונות';

  @override
  String get solutionsUploadPdfAction => 'PDF';

  @override
  String solutionsUploadFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'קבצים נבחרים',
      one: 'קובץ נבחר',
    );
    return '$count / 10 $_temp0';
  }

  @override
  String get solutionsUploadSomeFilesFailed => 'כמה קבצים נכשלו בהעלאה.';

  @override
  String get solutionsUploadRetryFailedFiles => 'נסו שוב קבצים שנכשלו';

  @override
  String get solutionsUploadSubmittingAction => 'מעלה...';

  @override
  String get solutionsUploadSubmitAction => 'העלה פתרון';

  @override
  String get settingsTitle => 'הגדרות';

  @override
  String get settingsSubtitle => 'מראה, שפה וחשבון';

  @override
  String get settingsAppearance => 'מראה';

  @override
  String get settingsTheme => 'ערכת נושא';

  @override
  String get settingsLanguage => 'שפה';

  @override
  String get settingsLanguageSystem => 'ברירת מחדל של מערכת';

  @override
  String get settingsAccentColour => 'צבע הדגשה';

  @override
  String get settingsAccentSubtitle => 'הגוון בכל רחבי האפליקציה';

  @override
  String get settingsReduceMotion => 'הפחת תנועה';

  @override
  String get settingsReduceMotionSubtitle => 'פחות אנימציות באפליקציה';

  @override
  String get settingsAccount => 'חשבון';

  @override
  String get settingsLogout => 'התנתקות';

  @override
  String get settingsLogoutSubtitle => 'צא מהמכשיר הזה';

  @override
  String get settingsThemeSystem => 'ברירת מחדל של מערכת';

  @override
  String get settingsThemeLight => 'בהיר';

  @override
  String get settingsThemeDark => 'כהה';

  @override
  String get settingsLanguageSearchHint => 'חפש שפה...';

  @override
  String get teacherWorkspaceSubtitle =>
      'נהלו נוכחות, רשימות וציונים מתוך האפליקציה.';

  @override
  String get teacherMetricSessionsToday => 'שיעורים היום';

  @override
  String get teacherMetricTeachingGroups => 'קבוצות הוראה';

  @override
  String get teacherMetricAssessments => 'הערכות';

  @override
  String get teacherQuickActions => 'פעולות מהירות';

  @override
  String get teacherNoDateAvailable => 'אין תאריך זמין';

  @override
  String get teacherNoTeachingSlotsToday => 'אין שיעורי הוראה מתוזמנים היום.';

  @override
  String get teacherUpcomingAssessments => 'הערכות קרובות';

  @override
  String get teacherUpcomingAssessmentsSubtitle =>
      'ישירות ממערכת הציונים של המורים';

  @override
  String get teacherNoAssessmentsYet => 'עדיין לא נוצרו הערכות.';

  @override
  String get teacherUnassignedSlot => 'שיעור לא משויך';

  @override
  String get teacherNoCohort => 'אין קבוצה';

  @override
  String get teacherCourseFallback => 'קורס';

  @override
  String teacherPeriod(Object number) {
    return 'שיעור $number';
  }

  @override
  String get teacherLoadErrorTitle => 'לא ניתן לטעון את סביבת המורה';

  @override
  String get teacherClassroomsLoadError =>
      'לא היינו יכולים לטעון כיתות עכשיו. גרור כדי לרענן או נסה שוב.';

  @override
  String get teacherClassroomsLoadTimeout =>
      'טעינת כיתות אורכת זמן רב מדי. גרור כדי לרענן או נסה שוב בעוד רגע.';

  @override
  String get teacherClassroomsLoadNetwork =>
      'כיתות לא יכלו להתחבר עכשיו. בדוק את החיבור שלך ונסה שוב.';

  @override
  String get teacherClassroomsSubtitle =>
      'פתח את רשימת התלמידים וצור קוד הצטרפות חי לכניסת תלמידים.';

  @override
  String get teacherClassroomsNoCohorts =>
      'עדיין לא קושרו קבוצות כיתות למורה זה.';

  @override
  String teacherClassroomsCohort(Object cohortId) {
    return 'קבוצה $cohortId';
  }

  @override
  String get teacherClassroomsGeneratingJoinCode => 'מייצר…';

  @override
  String get teacherClassroomsCreateJoinCode => 'יצור קוד הצטרפות';

  @override
  String get teacherClassroomsLiveJoinCode => 'קוד הצטרפות חי';

  @override
  String teacherClassroomsExpiresAt(Object value) {
    return 'פג תוקף $value';
  }

  @override
  String get teacherClassroomsRoster => 'רשימה';

  @override
  String get teacherClassroomsNoStudents => 'עדיין לא נרשמו תלמידים בכיתה זו.';

  @override
  String get teacherAttendanceLoadError =>
      'לא הצלחנו לטעון את הנוכחות כרגע. גרור כדי לרענן או נסה שוב.';

  @override
  String get teacherAttendanceLoadTimeout =>
      'טעינת הנוכחות לוקחת יותר מדי זמן. גרור כדי לרענן או נסה שוב בעוד רגע.';

  @override
  String get teacherAttendanceLoadNetwork =>
      'הנוכחות לא הצליחה להתחבר כרגע. בדוק את החיבור שלך ונסה שוב.';

  @override
  String get teacherAttendanceSubtitle =>
      'בחר בישיבה חיה, סמן את החדר והצילו רק שורות שהשתנו.';

  @override
  String get teacherAttendanceTodaySessions => 'ישיבות היום';

  @override
  String teacherAttendanceSessionSummary(
    Object cohort,
    Object grade,
    Object date,
    Object period,
  ) {
    return '$cohort • כיתה $grade • $date • שיעור $period';
  }

  @override
  String get teacherAttendanceChanged => 'שונה';

  @override
  String get teacherAttendanceNoteLabel => 'הערה';

  @override
  String get teacherAttendanceClassNotesLabel => 'הערות שיעור';

  @override
  String get teacherAttendanceClassNotesHint => 'מה כוסה בשיעור זה...';

  @override
  String get teacherAttendanceSaving => 'שומר…';

  @override
  String get teacherAttendanceSaveAll => 'שמור נוכחות';

  @override
  String teacherAttendanceSaveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count שינויים',
      one: 'שינוי אחד',
    );
    return 'שמור $_temp0';
  }

  @override
  String get teacherAttendanceSaved => 'הנוכחות נשמרה';

  @override
  String get retry => 'נסה שוב';

  @override
  String get scheduleRefreshTooFast =>
      'לוח הזמנים מתרענן מהר מדי כרגע. חכו רגע ונסו שוב.';

  @override
  String get scheduleSessionExpired => 'פג תוקף ההתחברות שלך. אנא התחבר מחדש.';

  @override
  String get scheduleNotOnboarded =>
      'פרופיל התלמיד שלך עדיין לא הוגדר. בקש ממנהל בית הספר לשייך אותך לכיתה.';

  @override
  String get scheduleLoadError => 'עדיין לא ניתן לטעון את לוח הזמנים.';

  @override
  String get scheduleSelectedDay => 'היום שנבחר';

  @override
  String scheduleClassCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count שיעורים',
      two: '2 שיעורים',
      one: 'שיעור אחד',
      zero: '0 שיעורים',
    );
    return '$_temp0';
  }

  @override
  String get scheduleNextUp => 'הבא בתור';

  @override
  String get scheduleNoMoreClasses => 'אין עוד שיעורים';

  @override
  String get scheduleNoClassesTitle => 'אין שיעורים ביום הזה';

  @override
  String scheduleNoClassesSubtitle(Object day) {
    return 'נראה ש-$day פנוי.';
  }

  @override
  String get scheduleClassFallback => 'שיעור';

  @override
  String get scheduleNoSubjectLocation => 'אין עדיין מקצוע או מיקום';

  @override
  String get scheduleNotes => 'הערות';

  @override
  String get scheduleGoToClassroom => 'מעבר לכיתה';

  @override
  String get loginTitle => 'התחברות בנייד לתלמידים ומורים';

  @override
  String get loginSubtitle =>
      'חשבונות מורים פותחים את סביבת המורה. חשבונות תלמידים נשארים בחוויית התלמיד.';

  @override
  String get loginSignIn => 'התחבר';

  @override
  String get loginWelcomeTitle => 'ברוך שובך';

  @override
  String get loginWelcomeSubtitle => 'התחבר לחשבון ClassMate שלך.';

  @override
  String get loginSigningIn => 'מתחבר...';

  @override
  String get loginEmailLabel => 'דוא\"ל או שם משתמש';

  @override
  String get loginPasswordLabel => 'סיסמה';

  @override
  String get profileNotAvailable => 'לא זמין';

  @override
  String get profileSchoolInfo => 'פרטי בית הספר';

  @override
  String get profileFullName => 'שם מלא';

  @override
  String get profileRole => 'תפקיד';

  @override
  String get profileSchoolId => 'מזהה בית ספר';

  @override
  String get profileCohortId => 'מזהה קבוצה';

  @override
  String get profileMyCohorts => 'הקבוצות שלי';

  @override
  String get profileMyCohortsEmpty => 'עדיין לא נרשמת לקבוצה.';

  @override
  String get profileAccountInfo => 'פרטי חשבון';

  @override
  String get profileUsername => 'שם משתמש';

  @override
  String get profileUsernameHint => 'your_username';

  @override
  String get profileContactEmail => 'אימייל ליצירת קשר';

  @override
  String get profileEmailAddress => 'כתובת אימייל';

  @override
  String get profileEmailHint => 'you@example.com';

  @override
  String get profileBirthday => 'יום הולדת';

  @override
  String get profileSecurity => 'אבטחה';

  @override
  String get profileSelectBirthday => 'בחר את יום ההולדת שלך';

  @override
  String get profilePasswordUpdated => 'הסיסמה עודכנה';

  @override
  String get profileSave => 'שמור';

  @override
  String get profileEmptyValue => '—';

  @override
  String get profileChangePassword => 'שנה סיסמה';

  @override
  String get profileCurrentPassword => 'סיסמה נוכחית';

  @override
  String get profileNewPassword => 'סיסמה חדשה';

  @override
  String get profileConfirmNewPassword => 'אשר סיסמה חדשה';

  @override
  String get profileUpdatePassword => 'עדכן סיסמה';

  @override
  String get profilePasswordAllFieldsRequired => 'כל השדות נדרשים';

  @override
  String get profilePasswordMinLength =>
      'הסיסמה החדשה חייבת להכיל לפחות 8 תווים';

  @override
  String get profilePasswordMismatch => 'הסיסמאות אינן תואמות';

  @override
  String get profilePasswordNotAuthenticated => 'לא מחובר';

  @override
  String get profilePasswordIncorrect => 'הסיסמה הנוכחית שגויה';

  @override
  String get profilePasswordGenericError => 'משהו השתבש. נסה שוב.';

  @override
  String get editProfileTitle => 'עריכת פרופיל';

  @override
  String get editProfileSchool => 'בית ספר';

  @override
  String get editProfileSchoolPublic => 'בית הספר ציבורי';

  @override
  String get editProfileGradePublic => 'הכיתה ציבורית';

  @override
  String get editProfileMajors => 'מגמות';

  @override
  String get editProfileMajorsPublic => 'המגמות ציבוריות';

  @override
  String get editProfileBio => 'ביוגרפיה';

  @override
  String get editProfileBioPublic => 'הביוגרפיה ציבורית';

  @override
  String get editProfileStatus => 'סטטוס';

  @override
  String get editProfileStatusPublic => 'הסטטוס ציבורי';

  @override
  String get classroomsYourClassrooms => 'הכיתות שלך';

  @override
  String get classroomsReorder => 'סידור הכיתות מחדש';

  @override
  String classroomsCount(Object count) {
    return '$count כיתות';
  }

  @override
  String get classroomsSearchHint => 'חיפוש כיתות';

  @override
  String get classroomsNoSearchMatches => 'אין כיתות שתואמות לחיפוש שלך';

  @override
  String get classroomsClassroomLabel => 'כיתה';

  @override
  String get classroomsLoadingLatestMessage => 'טוען את ההודעה האחרונה...';

  @override
  String get classroomsTapToOpen => 'הקש כדי לפתוח את הכיתה';

  @override
  String get classroomsNoMessagesYet => 'אין הודעות עדיין';

  @override
  String get classroomsMessageFallback => 'הודעה';

  @override
  String get examsLoadError => 'לא ניתן לטעון מבחנים או טפסים';

  @override
  String get examsAllFilter => 'הכול';

  @override
  String get examsFormsSubtitle =>
      'עיינו בטפסי הכיתה, חלונות המענה והמעקבים שמפורסמים על ידי בית הספר.';

  @override
  String get examsOnlySubtitle =>
      'עקבו אחר מבחנים קרובים, ספירות לאחור ורישומי מבחנים קודמים מהכיתות שלכם.';

  @override
  String get examsUpcomingStat => 'מבחנים קרובים';

  @override
  String get examsOpenFormsStat => 'טפסים פתוחים';

  @override
  String get examsCountdownPast => 'עבר';

  @override
  String get examsCountdownTomorrow => 'מחר';

  @override
  String examsCountdownInDays(Object days) {
    return 'בעוד $days ימים';
  }

  @override
  String get examsNoExamsPublished => 'עדיין לא פורסמו מבחנים.';

  @override
  String get examsNoFormsPublished => 'עדיין לא פורסמו טפסים.';

  @override
  String examsNoExamsForFilter(Object subject) {
    return 'אין כרגע מבחנים זמינים עבור $subject.';
  }

  @override
  String examsNoFormsForFilter(Object subject) {
    return 'אין כרגע טפסים זמינים עבור $subject.';
  }

  @override
  String examsMaterialsCount(Object count) {
    return '$count חומרים';
  }

  @override
  String get examsOpenState => 'פתוח';

  @override
  String get examsClosedState => 'סגור';

  @override
  String examsQuestionsCount(Object count) {
    return '$count שאלות';
  }

  @override
  String examsResponsesCount(Object count) {
    return '$count תגובות';
  }

  @override
  String get insightsTrendBaseline => 'קו בסיס';

  @override
  String get insightsTrendImproving => 'במגמת שיפור';

  @override
  String get insightsTrendDropping => 'בירידה';

  @override
  String get insightsTrendStable => 'יציב';

  @override
  String get insightsHeadlineIntervention => 'חלון ההתערבות פתוח';

  @override
  String get insightsHeadlineSignals => 'כמה אותות צריכים הידוק';

  @override
  String get insightsHeadlineMomentum => 'המומנטום יכול להתחזק השבוע';

  @override
  String get insightsBodyAttendance =>
      'שמרו קודם על נוכחות. נוכחות טובה יותר עכשיו תרים כל אות אחר מהר יותר.';

  @override
  String insightsBodyWeakTrend(Object subject) {
    return '$subject יחד עם ירידת מגמת התרגול הוא כרגע שילוב הסיכון הגדול ביותר. תקנו את זה לפני שמרחיבים.';
  }

  @override
  String insightsBodyLeverage(Object subject) {
    return '$subject היא נקודת המינוף שלך. השתמשו בה כדי לבנות ביטחון בזמן שאתם מחזקים את התחומים החלשים יותר.';
  }

  @override
  String get insightsBodyConsistency =>
      'המשיכו לצבור מפגשים קצרים וממוקדים. הימים הקרובים חשובים יותר מתוכנית מושלמת לטווח ארוך.';

  @override
  String get insightsInterventionScoreTitle => 'ציון התערבות';

  @override
  String insightsInterventionScoreBody(Object count) {
    return '$count אותות פעילים מעצבים את הצעד הבא שלך.';
  }

  @override
  String get insightsRecoveryPathTitle => 'מסלול ההתאוששות המהיר ביותר';

  @override
  String get insightsRecoveryPathDefault => 'נוכחות + עקביות קודם.';

  @override
  String insightsRecoveryPathTopic(Object topic, Object subject) {
    return 'חזרו אל $topic ב-$subject לפני שמגבירים את הקצב.';
  }

  @override
  String get insightsProjectedDirectionTitle => 'כיוון צפוי';

  @override
  String insightsProjectedDirectionBody(Object trend) {
    return '$trend לפי התנהגות התרגול האחרונה של 7 ימים מול 30 ימים.';
  }

  @override
  String get insightsLoadingTitle => 'טוען תובנות';

  @override
  String get insightsLoadingSubtitle => 'בונה את לוח המחוונים התחזיתי שלך.';

  @override
  String get insightsNotReadyTitle => 'התובנות עדיין לא מוכנות';

  @override
  String get insightsEmptyTitle => 'עדיין אין תובנות';

  @override
  String get insightsEmptySubtitle =>
      'המשיכו להשתמש בתרגול ובכלי בית הספר כדי ש-ClassMate יוכל לבנות תמונה אקדמית ברורה יותר.';

  @override
  String get insightsGradeAverage => 'ממוצע ציונים';

  @override
  String get insightsAccuracy => 'דיוק';

  @override
  String get insightsOpenNova => 'פתח את נובה';

  @override
  String get insightsOpenNovaPrompt =>
      'עזור לי לשפר את התחום החלש ביותר שלי על בסיס התובנות האחרונות של ClassMate.';

  @override
  String get insightsPredictiveRecoveryPlanTitle => 'תוכנית התאוששות תחזיתית';

  @override
  String get insightsPracticeNow => 'תרגל עכשיו';

  @override
  String get insightsPredictiveModulesTitle => 'מודולים תחזיתיים';

  @override
  String get insightsPredictiveModulesSubtitle =>
      'האותות הצופים פני עתיד החזקים ביותר מנתוני התלמיד הנוכחיים שלך.';

  @override
  String get insightsAnnouncementsPressureTitle => 'לחץ ההודעות';

  @override
  String get insightsAnnouncementsPressureSubtitle =>
      'מנוע ההודעות מזין עכשיו את לוח המחוונים ישירות.';

  @override
  String get insightsAiCoachTitle => 'סיכום מאמן ה-AI';

  @override
  String get insightsAiCoachLoadingSubtitle => 'טוען הנחיות AI.';

  @override
  String get insightsAiCoachUnavailableSubtitle =>
      'הנחיות AI אינן זמינות כרגע עבור החשבון הזה.';

  @override
  String get insightsAskNova => 'שאל את נובה';

  @override
  String get insightsAskNovaPrompt =>
      'בנה לי תוכנית התאוששות מהתובנות האחרונות שלי.';

  @override
  String get insightsAiStudyCoachTitle => 'מאמן לימוד AI';

  @override
  String get insightsSchoolToolsTitle => 'כלי בית ספר';

  @override
  String get insightsSchoolToolsSubtitle =>
      'עברו ישירות למסלולי התלמיד שהכי חשובים עכשיו.';

  @override
  String get tutorUntitledChat => 'צ\'אט ללא כותרת';

  @override
  String get tutorNewChat => 'צ\'אט חדש';

  @override
  String tutorFailedToOpenSeededChat(Object error) {
    return 'לא ניתן לפתוח את הצ\'אט: $error';
  }

  @override
  String tutorFailedToCreateChat(Object error) {
    return 'לא ניתן ליצור צ\'אט: $error';
  }

  @override
  String get tutorRenameChatTitle => 'שינוי שם הצ\'אט';

  @override
  String get tutorChatNameHint => 'שם הצ\'אט';

  @override
  String get tutorCancel => 'ביטול';

  @override
  String get tutorHide => 'הסתר';

  @override
  String get tutorHideChatTitle => 'הסתר צ\'אט';

  @override
  String get tutorHideChatSubtitle => 'מסתיר את הצ\'אט הזה במכשיר הזה.';

  @override
  String get tutorHideChatConfirmTitle => 'להסתיר את הצ\'אט?';

  @override
  String get tutorHideChatConfirmBody =>
      'הפעולה תסתיר את הצ\'אט מהרשימה במכשיר הזה. הסשן יישאר בשרת.';

  @override
  String get tutorTapToOpenHistory => 'הקשו כדי לפתוח היסטוריה';

  @override
  String get tutorAiTutorSubtitle => 'המורה ה-AI שלך';

  @override
  String get tutorHeroBody =>
      'היסטוריית צ\'אט אמיתית, שרשורים נקיים יותר וגישה מהירה יותר.';

  @override
  String get tutorStartFreshConversation => 'התחל שיחה חדשה';

  @override
  String get tutorSearchHistoryHint => 'חיפוש בהיסטוריית הצ\'אט';

  @override
  String get chatComposerDefaultHint => 'הודעה';

  @override
  String get chatComposerReplyingToMessage => 'מגיבים להודעה';

  @override
  String get chatComposerReplyFallback => 'השב';

  @override
  String get chatComposerMicHint =>
      'הקישו להודעה קולית מהירה או לחצו לחיצה ארוכה כדי להקליט';

  @override
  String get chatComposerRecordingTitle => 'מקליט';

  @override
  String get chatComposerReleaseToSend => 'שחררו כדי לשלוח';

  @override
  String get chatComposerCancelTitle => 'ביטול';

  @override
  String get chatComposerLockTitle => 'נעילה';

  @override
  String get chatComposerSlideLeftToCancel => 'החליקו שמאלה כדי לבטל';

  @override
  String get chatComposerSlideUpToLock => 'החליקו למעלה כדי לנעול';

  @override
  String get chatComposerReleaseToCancel => 'שחרר לביטול';

  @override
  String get chatComposerKeepSlidingToCancel => 'המשיכו להחליק כדי לבטל';

  @override
  String get chatComposerReleaseToLock => 'שחררו כדי לנעול';

  @override
  String get chatComposerRelease => 'שחרור';

  @override
  String get chatComposerLock => 'נעילה';

  @override
  String get chatComposerRecordingPaused => 'ההקלטה מושהית';

  @override
  String get chatComposerRecordingLocked => 'ההקלטה נעולה';

  @override
  String get chatComposerResumeHint => 'המשיכו כשתהיו מוכנים להמשיך להקליט';

  @override
  String get chatComposerLockedHint => 'הקישו על שליחה כשתהיו מוכנים לשתף';

  @override
  String get chatContextDismiss => 'סגירה';

  @override
  String get chatContextCopyText => 'העתקת טקסט';

  @override
  String get chatContextDelete => 'מחיקה';

  @override
  String get chatMessageInfoShortTitle => 'מידע';

  @override
  String get chatMessageInfoStatus => 'סטטוס';

  @override
  String get chatMessageInfoStatusTime => 'שעת סטטוס';

  @override
  String get chatMessageInfoSentAt => 'נשלח ב-';

  @override
  String get chatMessageInfoDeliveredAt => 'נמסר ב-';

  @override
  String get chatMessageInfoSeenAt => 'נצפה ב-';

  @override
  String get chatMessageInfoMessageType => 'סוג הודעה';

  @override
  String get chatMessageInfoTextType => 'טקסט';

  @override
  String get chatMessageInfoEdited => 'נערך';

  @override
  String get chatMessageInfoForwarded => 'הועבר';

  @override
  String get chatMessageInfoVoiceDuration => 'משך קולי';

  @override
  String get chatMessageInfoSeenBy => 'נצפה על ידי';

  @override
  String get chatMessageInfoDeliveredTo => 'נמסר אל';

  @override
  String get chatMessageInfoEmptyBody => '(ריק)';

  @override
  String get chatMessageInfoReadLess => 'קראו פחות';

  @override
  String get chatMessageInfoReadMore => 'קראו עוד';

  @override
  String get chatMessageInfoSeen => 'נצפה';

  @override
  String get chatMessageInfoDelivered => 'נמסר';

  @override
  String get chatMessageInfoNotDelivered => 'לא נמסר';

  @override
  String get chatMessageInfoSent => 'נשלח';

  @override
  String get chatMessageInfoPending => 'ממתין';

  @override
  String get chatMessageInfoNotSeen => 'לא נצפה';

  @override
  String get chatMessageInfoType => 'סוג';

  @override
  String get chatMessageInfoDuration => 'משך';

  @override
  String get chatMessageInfoYes => 'כן';

  @override
  String get chatMessageInfoNo => 'לא';

  @override
  String get chatMessageInfoDeleteState => 'מצב מחיקה';

  @override
  String get chatReactionDetailsTitle => 'תגובות';

  @override
  String get chatReactionAddAction => 'הוספת תגובה';

  @override
  String get chatReactionEmptyState => 'אין תגובות עדיין';

  @override
  String get chatReactionSingle => 'תגובה';

  @override
  String get chatReactionTapToRemove => 'הקישו להסרה';

  @override
  String chatReactionYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' · $count',
      one: '',
    );
    return 'אתם$_temp0';
  }

  @override
  String chatReactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count תגובות',
      one: 'תגובה',
    );
    return '$_temp0';
  }

  @override
  String get chatEmojiPickerTitle => 'בחירת אימוג\'י';

  @override
  String get chatEmojiPickerSearchHint => 'חיפוש אימוג\'י';

  @override
  String get chatEmojiPickerEmptyState => 'לא נמצא אימוג\'י';

  @override
  String get chatCameraTitle => 'מצלמה';

  @override
  String get chatCameraUseAction => 'שימוש';

  @override
  String get chatCameraGalleryAction => 'גלריה';

  @override
  String chatCameraSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count נבחרו',
      one: '1 נבחר',
      zero: '0 נבחרו',
    );
    return '$_temp0';
  }

  @override
  String get chatMediaPreviewEmptyState => 'אין מה להציג בתצוגה מקדימה';

  @override
  String get chatMediaPreviewDrawCropAction => 'ציור וחיתוך';

  @override
  String get chatMediaPreviewRotateLeftAction => 'סיבוב שמאלה';

  @override
  String get chatMediaPreviewRotateRightAction => 'סיבוב ימינה';

  @override
  String get chatMediaPreviewMirrorAction => 'שיקוף';

  @override
  String get chatMediaPreviewResetAction => 'איפוס';

  @override
  String get chatMediaPreviewRemoveAction => 'הסרה';

  @override
  String get chatMediaPreviewCaptionHint => 'הוסיפו כיתוב...';

  @override
  String tutorPlanSelectedPlaceholder(Object plan) {
    return 'התוכנית $plan נבחרה. התשלומים נשארים כרגע במצב דמה.';
  }

  @override
  String get tutorFailedToLoadChats => 'טעינת הצ\'אטים נכשלה';

  @override
  String get tutorNoChatsYet => 'עדיין אין צ\'אטים';

  @override
  String get tutorNoChatsMatchSearch => 'אין צ\'אטים שתואמים לחיפוש שלכם';

  @override
  String get tutorCreateFirstChat => 'צרו את הצ\'אט הראשון';

  @override
  String get tutorPlansTitle => 'תוכניות NOVA';

  @override
  String tutorPlansSubtitle(Object model) {
    return 'מבוסס על הנחות עלות של $model ומכסות חודשיות קשיחות כדי שהשימוש יישאר רווחי.';
  }

  @override
  String get tutorPlanPriceFree => 'חינם';

  @override
  String tutorPlanPriceMonthly(Object price) {
    return '\$$price/לחודש';
  }

  @override
  String get tutorPromptsLeft => 'פרומפטים שנותרו';

  @override
  String get tutorUploadsLeft => 'העלאות שנותרו';

  @override
  String get tutorVoiceLeft => 'דקות קול שנותרו';

  @override
  String tutorUsageValue(Object remaining, Object total) {
    return '$remaining/$total';
  }

  @override
  String tutorVoiceUsageValue(Object remaining, Object total) {
    return '$remaining/$total דק\'';
  }

  @override
  String get tutorPaymentMethodsTitle => 'אמצעי תשלום';

  @override
  String tutorPaymentMethodsSubtitle(Object plan) {
    return 'התשלום נשאר במצב דמה עד שחשבון הבנק והמעבד של ClassMate יהיו פעילים. התוכנית שנבחרה היא $plan.';
  }

  @override
  String get tutorCardCheckoutTitle => 'תשלום בכרטיס';

  @override
  String get tutorCardCheckoutSubtitle =>
      'שער דמה עבור Visa, Mastercard ו-AmEx.';

  @override
  String get tutorApplePayTitle => 'Apple Pay';

  @override
  String get tutorApplePaySubtitle => 'זרימת ארנק דמה עבור iPhone והווב.';

  @override
  String get tutorBankTransferTitle => 'העברה בנקאית';

  @override
  String get tutorBankTransferSubtitle =>
      'חשבון הבנק של ClassMate עדיין ממתין. הפרטים יתווספו לאחר פתיחתו.';

  @override
  String get tutorPlanStarterName => 'Starter';

  @override
  String get tutorPlanStarterTagline => 'מספיק לניסיון ולחזרה שבועית קלה.';

  @override
  String get tutorPlanPlusName => 'Plus';

  @override
  String get tutorPlanPlusTagline =>
      'הכי מתאים לתלמיד רציני שמשתמש ב-NOVA ברוב הימים.';

  @override
  String get tutorPlanProName => 'Pro';

  @override
  String get tutorPlanProTagline =>
      'לשימוש יומי כבד, עונת מבחנים מלאה ומפגשי לימוד ארוכים.';

  @override
  String get tutorPlanSchoolSeatName => 'מושב בית ספרי';

  @override
  String get tutorPlanSchoolSeatTagline =>
      'לפריסה לכל תלמיד או איש צוות בתוך בית ספר אמיתי.';

  @override
  String tutorPlanBulletPromptsMonthly(Object count) {
    return '$count פרומפטים של NOVA בכל חודש';
  }

  @override
  String tutorPlanBulletPromptsPerSeatMonthly(Object count) {
    return '$count פרומפטים של NOVA לכל מושב בכל חודש';
  }

  @override
  String tutorPlanBulletUploads(Object count) {
    return '$count העלאות תמונה או קובץ';
  }

  @override
  String tutorPlanBulletVoiceMinutes(Object count) {
    return '$count דקות תמלול קולי';
  }

  @override
  String tutorEstimatedCostCeilingFree(Object cost) {
    return 'תקרת עלות משוערת: \$$cost/לחודש';
  }

  @override
  String tutorEstimatedCostCeilingPaid(Object cost, Object margin) {
    return 'תקרת עלות משוערת: \$$cost/לחודש • מרווח $margin%';
  }

  @override
  String tutorTimeMinutesShort(Object count) {
    return '$countדק\'';
  }

  @override
  String tutorTimeHoursShort(Object count) {
    return '$countש\'';
  }

  @override
  String get tutorVoiceMessageFallback => 'הודעה קולית';

  @override
  String get tutorFileFallback => 'קובץ';

  @override
  String get tutorCopy => 'העתק';

  @override
  String get tutorEditMessage => 'ערוך הודעה';

  @override
  String get tutorCopied => 'הועתק';

  @override
  String get tutorLoadedIntoComposer => 'נטען לשורת הכתיבה';

  @override
  String get tutorTakePhoto => 'צלם תמונה';

  @override
  String get tutorRecordVideo => 'הקלט וידאו';

  @override
  String get tutorChooseFromGallery => 'בחר מהגלריה';

  @override
  String get tutorPreviewTitle => 'תצוגה מקדימה';

  @override
  String get tutorThinking => 'חושב...';

  @override
  String get tutorDone => 'בוצע.';

  @override
  String get tutorFailedToStreamReply => 'הזרמת התשובה נכשלה';

  @override
  String get tutorUnsupportedFilesMessage =>
      'NOVA תומך בתמונות, מסמכים וטקסט. קבצי וידאו ואודיו אינם נתמכים כאן.';

  @override
  String get tutorNoAudioCaptured => 'לא נקלט אודיו.';

  @override
  String get tutorVoiceLimitReachedTitle => 'הגעת למגבלת הקול';

  @override
  String get tutorVoiceLimitReachedMessage =>
      'לתוכנית ה-NOVA הנוכחית שלך אין מספיק דקות קול למחזור התמלול הזה.';

  @override
  String get tutorTranscriptionFailed => 'התמלול נכשל. נסו שוב.';

  @override
  String get tutorMicrophonePermissionRequired => 'נדרשת הרשאת מיקרופון.';

  @override
  String get tutorPlanLimitReachedTitle => 'הגעת למגבלת תוכנית NOVA';

  @override
  String get tutorPlanLimitReachedMessage =>
      'מכסת הפרומפטים או ההעלאות של החודש לתוכנית ה-NOVA הנוכחית שלך אזלה. בחרו תוכנית גבוהה יותר במסך הבית של NOVA כדי להמשיך.';

  @override
  String get tutorSendFailed => 'השליחה נכשלה.';

  @override
  String tutorCurrentPlanUsageSummary(
    Object plan,
    Object prompts,
    Object uploads,
    Object voice,
  ) {
    return 'תוכנית נוכחית: $plan • $prompts פרומפטים נותרו • $uploads העלאות נותרו • $voice דקות קול נותרו';
  }

  @override
  String get tutorReviewPlansInHome => 'עבור על התוכניות בבית של NOVA';

  @override
  String get tutorCouldNotOpenAttachment => 'לא ניתן לפתוח את הקובץ המצורף.';

  @override
  String get tutorAttachmentUnavailable => 'הקובץ המצורף אינו זמין.';

  @override
  String get tutorImageUnavailable => 'התמונה אינה זמינה';

  @override
  String get tutorYou => 'אתה';

  @override
  String get tutorRegenerate => 'צור מחדש';

  @override
  String get tutorEmptyStateTitle => 'התחילו משאלה אמיתית';

  @override
  String get tutorEmptyStateBody =>
      'בקשו מ-NOVA להסביר מושג, להפוך הערות לטבלה, להשוות רעיונות או לעזור לכם לחזור מחומר שהועלה.';

  @override
  String get tutorPromptSuggestionSummarizeNotes => 'סכם את הערות השיעור שלי';

  @override
  String get tutorPromptSuggestionRevisionTable => 'הכן טבלת חזרה';

  @override
  String get tutorPromptSuggestionQuizMe => 'בחן אותי על הנושא הזה';

  @override
  String get tutorMessageNovaHint => 'שלחו הודעה ל-NOVA';

  @override
  String get tutorHeaderSubtitleReady => 'תשובות מובנות, טבלאות ועזרת לימוד';

  @override
  String get tutorYourNovaPlanTitle => 'תוכנית ה-NOVA שלך';

  @override
  String get tutorYourNovaPlanMessage =>
      'בדקו כאן את מגבלות הפרומפטים, ההעלאות והקול, ואז חזרו לבית של NOVA אם תרצו להחליף תוכנית.';

  @override
  String get tutorExplainTitle => 'NOVA מסביר';

  @override
  String get classroomsThreadTypeClassroom => 'כיתה';

  @override
  String get classroomsThreadTypeGroup => 'קבוצה';

  @override
  String get classroomsThreadTypeDirectMessage => 'הודעה ישירה';

  @override
  String get classroomsThreadTypeDirectMessageShort => 'DM';

  @override
  String get messagesBlockedPeopleTitle => 'אנשים חסומים';

  @override
  String get messagesStartChatAction => 'התחלת צ\'אט';

  @override
  String messagesLoadFailed(Object error) {
    return 'טעינת ההודעות נכשלה: $error';
  }

  @override
  String get messagesSearchHint => 'חיפוש הודעות';

  @override
  String get messagesNoResults => 'לא נמצאו הודעות';

  @override
  String get messagesRequestsSection => 'בקשות';

  @override
  String get messagesPendingApprovals => 'אישורים ממתינים';

  @override
  String get messagesChatsSection => 'צ\'אטים';

  @override
  String get messagesAllChatsSection => 'כל הצ\'אטים';

  @override
  String messagesConversationCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count שיחות',
      one: 'שיחה אחת',
    );
    return '$_temp0';
  }

  @override
  String get messagesRequestReviewStatus => 'סקירה';

  @override
  String messagesPeopleLoadFailed(Object error) {
    return 'טעינת האנשים נכשלה: $error';
  }

  @override
  String get messagesSearchPeopleHint => 'חיפוש אנשים';

  @override
  String get messagesNewGroupTitle => 'קבוצה חדשה';

  @override
  String get messagesNewGroupSubtitle => 'יצירת צ\'אט קבוצתי';

  @override
  String get messagesGroupNameHint => 'שם הקבוצה';

  @override
  String get messagesCreateGroupAction => 'יצירת קבוצה';

  @override
  String get messagesBlockedPersonFallback => 'האדם הזה';

  @override
  String get messagesUnblockPersonTitle => 'לבטל חסימה של האדם הזה?';

  @override
  String messagesUnblockPersonBody(Object name) {
    return 'לאפשר ל-$name לשלוח לך שוב הודעות?';
  }

  @override
  String get messagesUnblockAction => 'ביטול חסימה';

  @override
  String messagesUnblockedToast(Object name) {
    return 'החסימה של $name בוטלה';
  }

  @override
  String messagesBlockedPeopleLoadFailed(Object error) {
    return 'טעינת האנשים החסומים נכשלה: $error';
  }

  @override
  String get messagesNoBlockedPeople => 'אין אנשים חסומים';

  @override
  String get messagesUnknownUser => 'משתמש לא ידוע';

  @override
  String get messagesRequestTitle => 'בקשה';

  @override
  String messagesRequestLoadFailed(Object error) {
    return 'טעינת הבקשה נכשלה: $error';
  }

  @override
  String get messagesRequestBannerIncoming => 'בקשת הודעה';

  @override
  String get messagesRequestBannerOutgoing => 'אישור ממתין';

  @override
  String get messagesBlockAction => 'חסימה';

  @override
  String get messagesApproveAction => 'אישור';

  @override
  String get messagesRequestUnlockHint =>
      'הצ\'אט ייפתח אחרי שהנמען יאשר את ההודעה הראשונה שלך.';

  @override
  String get messagesThreadConversationFallback => 'שיחה';

  @override
  String get messagesThreadLeaveGroupTitle => 'לעזוב את הקבוצה?';

  @override
  String get messagesThreadLeaveGroupBody =>
      'לא תקבלו יותר הודעות מהקבוצה הזו.';

  @override
  String get messagesThreadBlockPersonTitle => 'לחסום את האדם הזה?';

  @override
  String get messagesThreadBlockPersonBody =>
      'לא תוכלו עוד להחליף הודעות עם האדם הזה.';

  @override
  String get messagesThreadPersonFallback => 'אדם';

  @override
  String get messagesThreadProfileInfoUnavailable => 'פרטי הפרופיל לא זמינים';

  @override
  String get messagesThreadParticipants => 'משתתפים';

  @override
  String get messagesThreadPeople => 'אנשים';

  @override
  String get messagesThreadDeleteForMe => 'מחיקה בשבילי';

  @override
  String get messagesThreadDeleteForEveryone => 'מחיקה לכולם';

  @override
  String get messagesThreadDeleteForEveryoneSubtitle => 'הסרה עבור כל המשתתפים';

  @override
  String get messagesThreadSending => 'שולח…';

  @override
  String get messagesThreadWaitingForApproval => 'ממתין לאישור';

  @override
  String get classroomsForwardSearchHint => 'חיפוש שיחות';

  @override
  String get classroomsForwardNewChat => 'צ\'אט חדש';

  @override
  String classroomsForwardLoadError(Object error) {
    return 'טעינת הצ\'אטים נכשלה: $error';
  }

  @override
  String get classroomsForwardNoChatsFound => 'לא נמצאו צ\'אטים';

  @override
  String get classroomsForwardSectionClassrooms => 'כיתות';

  @override
  String get classroomsForwardSectionDirectMessages => 'הודעות ישירות';

  @override
  String get classroomsForwardCancel => 'ביטול';

  @override
  String get classroomsForwardAction => 'העבר';

  @override
  String classroomsForwardCount(Object count) {
    return 'העבר ($count)';
  }

  @override
  String get markRead => 'סמן כנקרא';

  @override
  String get markUnread => 'סמן כלא נקרא';

  @override
  String get markAllRead => 'סמן הכל כנקרא';

  @override
  String get filters => 'סינונים';

  @override
  String get source => 'מקור';

  @override
  String get state => 'סטטוס';

  @override
  String get allSources => 'כל המקורות';

  @override
  String get allStates => 'כל הסטטוסים';

  @override
  String get unread => 'לא נקרא';

  @override
  String get read => 'נקרא';

  @override
  String get clear => 'נקה';

  @override
  String get today => 'היום';

  @override
  String get yesterday => 'אתמול';

  @override
  String get thisWeek => 'השבוע';

  @override
  String get earlier => 'קודם לכן';

  @override
  String get openDetails => 'פתח פרטים';

  @override
  String get total => 'סה\"כ';

  @override
  String get local => 'מקומי';

  @override
  String get server => 'שרת';

  @override
  String get notificationsSourceSystem => 'מערכת';

  @override
  String get notificationsHeroSubtitleStudent =>
      'מרכז ההתראות שלך להודעות, עדכוני שרת ופעילות לימודית חשובה בזמן אמת.';

  @override
  String get notificationsHeroSubtitleTeacher =>
      'מרכז ההתראות של המורה להודעות, עדכוני שרת ופעילות בית ספרית בזמן אמת.';

  @override
  String get notificationsFiltersSubtitle =>
      'התמקדו לפי מקור או מצב קריאה כדי למיין מהר יותר.';

  @override
  String get notificationsSearchSourcesHint => 'חיפוש מקורות';

  @override
  String notificationsShowingSummary(Object shown, Object total) {
    return 'מוצגות $shown מתוך $total התראות.';
  }

  @override
  String get notificationsEmptyForAccount =>
      'אין כרגע התראות זמינות לחשבון הזה.';

  @override
  String get notificationsEmptyFiltered =>
      'אין כרגע התראות שתואמות למסננים האלה. נקו מסננים כדי לראות את כל הפיד.';

  @override
  String get notificationsEmpty => 'אין כרגע התראות זמינות.';

  @override
  String get notificationsNewBadge => 'חדש';

  @override
  String get notificationsUnavailable =>
      'ההתראה הזו כבר לא זמינה. רעננו את תיבת ההתראות ונסו שוב.';

  @override
  String get notificationsSeverityCritical => 'קריטי';

  @override
  String get notificationsSeverityWarning => 'אזהרה';

  @override
  String get notificationsSeverityInfo => 'מידע';

  @override
  String get announcementsLoadError =>
      'לא הצלחנו לטעון הודעות כעת. גרור כדי לרענן או נסה שוב.';

  @override
  String get announcementsLoadTimeout =>
      'הודעות לוקחות זמן רב מדי לטעינה. גרור כדי לרענן או נסה שוב בעוד רגע.';

  @override
  String get announcementsLoadNetwork =>
      'הודעות לא היו יכולות להתחבר כעת. בדוק את החיבור שלך ונסה שוב.';

  @override
  String get teacherDeleteClassroom => 'מחיקת כיתה';

  @override
  String get teacherDeleteClassroomConfirm =>
      'פעולה זו תמחק לצמיתות את הכיתה ואת כל הצ׳אט, המטלות, החומרים, המפגשים ורשימת החברים שלה. לא ניתן לבטל.';

  @override
  String get teacherClassroomDeleted => 'הכיתה נמחקה';

  @override
  String get announcementsTabReceived => 'התקבלו';

  @override
  String get announcementsTabPublished => 'פורסמו';

  @override
  String get announcementsAudienceTeacher => 'מורה';

  @override
  String get announcementsAudienceAccount => 'חשבון';

  @override
  String get announcementsAudienceTeacherWorkspace => 'מרחב עבודה של מורה';

  @override
  String get announcementsLoadFailedTitle => 'לא הצלחנו לטעון הודעות';

  @override
  String get announcementsLoadFailedHint => 'גרור כדי לרענן לאחר שהחיבור יציב.';

  @override
  String announcementsHeroSubtitle(Object audience) {
    return 'הודעות שפורסמו בבית ספר, מורה ומערכת זמינות ל$audience.';
  }

  @override
  String get announcementsLatestSourceLabel => 'מקור אחרון';

  @override
  String get announcementsNone => 'אין';

  @override
  String announcementsUnreadCountTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count הודעות שלא נקראו',
      one: 'הודעה אחת שלא נקראת',
    );
    return '$_temp0';
  }

  @override
  String get announcementsAllReadTitle => 'הכל נקרא';

  @override
  String announcementsEmptyForAudience(Object audience) {
    return 'לא פורסמו הודעות ל$audience עד כה.';
  }

  @override
  String announcementsLatestBody(Object title) {
    return 'אחרון: $title. הקש עליו כדי לקרוא את התוכן המלא.';
  }

  @override
  String get announcementsFiltersSubtitle =>
      'הצר את תיבת הדואר לפי מקור או לפי מצב קריאה כדי שתוכל להתמקד במה שעדיין צריך תשומת לב.';

  @override
  String get announcementsAllAnnouncements => 'כל ההודעות';

  @override
  String get announcementsSearchStatesHint => 'לא קרא / קרא';

  @override
  String announcementsSummarySourceSegment(Object source) {
    return ' מ$source';
  }

  @override
  String announcementsSummaryStateSegment(Object state) {
    return ' ב$state';
  }

  @override
  String announcementsShowingSummary(
    Object shown,
    Object total,
    Object sourceSegment,
    Object stateSegment,
  ) {
    return 'מציג $shown מתוך $total הודעות$sourceSegment$stateSegment.';
  }

  @override
  String get announcementsNoMatchTitle => 'אין הודעות התואמות לסינונים אלה';

  @override
  String get announcementsNoPublishedTitle => 'אין הודעות שפורסמו עדיין';

  @override
  String get announcementsNoMatchSubtitle =>
      'נסה מקור שונה או חזור לכל ההודעות כדי להביא עוד פריטים לתצוגה.';

  @override
  String get announcementsClearFiltersHint => 'נקה סינונים כדי לראות הכל שוב.';

  @override
  String get announcementsPullToRefreshHint =>
      'גרור כדי לרענן לאחר פרסום פעילות בית ספר חדשה.';

  @override
  String get announcementsInboxTitle => 'תיבת הדואר';

  @override
  String get announcementsInboxSubtitle =>
      'רק כותרות מופיעות כאן לסריקה מהירה. הקש על כל פריט כדי לפתוח את תוכן ההודעה המלא.';

  @override
  String get meetingsLoadError =>
      'לא ניתן לטעון פגישות כעת. גרור כדי לרענן או נסה שוב.';

  @override
  String get meetingsLoadTimeout =>
      'פגישות לוקחות זמן רב מדי לטעינה. גרור כדי לרענן או נסה שוב בעוד רגע.';

  @override
  String get meetingsLoadNetwork =>
      'לא ניתן להתחבר לפגישות כעת. בדוק את החיבור שלך ונסה שוב.';

  @override
  String get meetingsHeroSubtitle =>
      'כל פגישות הכיתה בתצוגה אחת נקייה, עם קישורים מצורפים ועמוד פרטים במסך מלא כשאתה צריך הקשר.';

  @override
  String get meetingsJoinReadyMetric => 'מוכן להצטרף';

  @override
  String get meetingsNoLinkMetric => 'ללא קישור';

  @override
  String get meetingsNoPostedTitle => 'עדיין לא פורסמו פגישות';

  @override
  String get meetingsEmptyForAccount =>
      'אין פגישות כיתה זמינות לחשבון התלמיד הזה כעת.';

  @override
  String meetingsLatestBody(Object title, Object updatedAt) {
    return '$title עודכן $updatedAt. פתח אותו כדי לראות את הקישור המצורף והקשר כיתה.';
  }

  @override
  String get meetingsPullToRefreshHint => 'גרור למטה כדי לבדוק שוב.';

  @override
  String get meetingsFiltersSubtitle =>
      'צמצם את הרשימה לפי נושא או אם הפגישה כוללת כבר קישור שאתה יכול לפתוח.';

  @override
  String get meetingsAccessLabel => 'גישה';

  @override
  String get meetingsAllMeetings => 'כל הפגישות';

  @override
  String get meetingsAccessReady => 'מוכן להצטרף';

  @override
  String get meetingsAccessNoLink => 'ללא קישור';

  @override
  String get meetingsAccessNoLinkYet => 'עדיין אין קישור';

  @override
  String get meetingsAccessSearchHint => 'מוכן להצטרף / עדיין אין קישור';

  @override
  String meetingsSummarySubjectSegment(Object subject) {
    return ' עבור $subject';
  }

  @override
  String meetingsSummaryAccessSegment(Object state) {
    return ' ב$state';
  }

  @override
  String meetingsShowingSummary(
    Object shown,
    Object total,
    Object subjectSegment,
    Object accessSegment,
  ) {
    return 'הצגה של $shown מתוך $total פגישות$subjectSegment$accessSegment.';
  }

  @override
  String get meetingsNoMatchTitle => 'אין פגישות תואמות לפילטרים אלה';

  @override
  String get meetingsNoMatchSubtitle =>
      'נסה את כל הנושאים או כלול פגישות ללא קישורים כדי לחזור יותר תוצאות לרשימה.';

  @override
  String get meetingsListSubtitle =>
      'הקש על כל פגישה כדי לפתוח את תצוגת הפרטים במסך מלא והקפוץ לקישור המצורף שלה כשהוא זמין.';

  @override
  String meetingsDateTimeValue(Object date, Object time) {
    return '$date • $time';
  }

  @override
  String meetingsSharedByValue(Object name) {
    return 'שותף על ידי $name';
  }

  @override
  String get meetingsPreviewFallback =>
      'פתח את הפגישה הזו כדי לראות את הקישור המצורף ופרטי הכיתה העדכניים.';

  @override
  String get meetingsNoValidLinkAttached => 'עדיין לא צורף קישור פגישה תקף.';

  @override
  String get meetingsCouldNotOpenLink => 'לא ניתן לפתוח קישור פגישה.';

  @override
  String get meetingsNoLinkToCopy => 'עדיין אין קישור פגישה להעתקה.';

  @override
  String get meetingsLinkCopied => 'קישור פגישה הועתק.';

  @override
  String get meetingsUnavailableTitle => 'פגישה לא זמינה';

  @override
  String get meetingsUnavailableSubtitle =>
      'לא ניתן למצוא את הפגישה הזו בפיד הנוכחי. ייתכן שהיא הוסרה או אינה זמינה בלא חיבור.';

  @override
  String get meetingsUnavailableHint => 'חזור אחורה ורענן את רשימת הפגישות.';

  @override
  String get meetingsNoLinkAttachedYet => 'עדיין לא צורף קישור';

  @override
  String get meetingsAttachedLinkTitle => 'קישור פגישה מצורף';

  @override
  String get meetingsAttachedLinkMissingBody =>
      'הפגישה הזו גלויה בפיד הכיתה שלך, אך לא צורפה URL תקפה בעומס התלמיד הנוכחי.';

  @override
  String get meetingsDetailsTitle => 'פרטי הפגישה';

  @override
  String get meetingsDetailsSubtitle =>
      'הכל הרלוונטי לסטודנט שזמין כעת הזמינים כעת.';

  @override
  String get meetingsDetailClassroomLabel => 'כיתה';

  @override
  String get meetingsSharedByLabel => 'שותף על ידי';

  @override
  String get meetingsIdLabel => 'מזהה פגישה';

  @override
  String get meetingsAttachedLinkSubtitle =>
      'השתמש ב-URL המצורף כדי להצטרף או העתק קישור פגישה כשהכיתה שלך מספקת אחד.';

  @override
  String get meetingsOpening => 'נפתח כעת';

  @override
  String get meetingsOpenLink => 'פתח קישור';

  @override
  String get meetingsCopyLink => 'העתק קישור';

  @override
  String get meetingsAccessPanelTitle => 'גישת פגישה';

  @override
  String get meetingsAccessPanelReadyBody =>
      'פתח את ה-URL המצורף בדפדפן או באפליקציית פגישה.';

  @override
  String get meetingsJoinAction => 'הצטרף';

  @override
  String get announcementsDetailLoadFailedHint =>
      'חזור ונסה לרענן את תיבת דואר ההודעות.';

  @override
  String get announcementsUnavailableTitle => 'הודעה לא זמינה';

  @override
  String announcementsUnavailableSubtitle(Object audience) {
    return 'הודעה זו כבר לא זמינה בהזנה המפורסמת עבור $audience.';
  }

  @override
  String get announcementsUnavailableHint => 'חזור לתיבת הדואר כדי להמשיך.';

  @override
  String announcementsPublishedReadStateBody(Object audience) {
    return 'הודעה זו פורסמה ל$audience ומצב הקריאה שלך מאוחסן באופן מקומי על התקן זה.';
  }

  @override
  String get announcementsDetailsTitle => 'פרטי הודעה';

  @override
  String get announcementsDetailsSubtitle =>
      'מטא נתונים שפורסמו עבור הודעה זו ומצב הקריאה הנוכחי שלה.';

  @override
  String get announcementsSeverityLabel => 'חומרה';

  @override
  String get announcementsCreatedLabel => 'נוצר';

  @override
  String get announcementsIdLabel => 'מזהה הודעה';

  @override
  String get announcementsFullContentTitle => 'תוכן מלא';

  @override
  String get announcementsFullContentSubtitle =>
      'הטקסט המלא של ההודעה מופיע כאן לאחר פתיחת הפריט מתיבת הדואר.';

  @override
  String get announcementsReadStateTitle => 'מצב קריאה';

  @override
  String get announcementsReadStateBodyRead =>
      'הודעה זו מסומנת כנקראת על התקן זה.';

  @override
  String get announcementsReadStateBodyUnread =>
      'הודעה זו עדיין לא נקראת על התקן זה.';

  @override
  String get alertsTitle => 'התראות';

  @override
  String get alertsSubtitle =>
      'זה המסך לדברים שדורשים תשומת לב עכשיו, לא רק עדכונים כלליים.';

  @override
  String get alertsAttendanceTitle => 'הנוכחות דורשת תשומת לב';

  @override
  String alertsAttendanceBody(Object rate) {
    return 'שיעור הנוכחות שלך הוא $rate%. כמה שיעורים שהוחמצו יכולים להצטבר מהר.';
  }

  @override
  String get alertsWeakestSubjectTitle => 'סימן למקצוע החלש ביותר';

  @override
  String alertsWeakestSubjectBody(Object subject) {
    return '$subject דורש כרגע את מירב תשומת הלב לפי הציונים האחרונים שלך.';
  }

  @override
  String get alertsPracticeWeakAreaTitle => 'אזור חולשה בתרגול';

  @override
  String alertsPracticeWeakAreaBody(Object topic, Object subject) {
    return '$topic ב-$subject הוא נושא החולשה הברור ביותר שלך כרגע.';
  }

  @override
  String get alertsPracticeTrendDroppedTitle => 'מגמת התרגול ירדה';

  @override
  String get alertsPracticeTrendDroppedBody =>
      'הביצועים שלך ב-7 הימים האחרונים נמוכים מקו הבסיס של 30 הימים. האטו וחזרו ליסודות לפני שמגבירים קצב.';

  @override
  String get alertsEmpty =>
      'כרגע הכול רגוע. אם משהו ידרוש תשומת לב דחופה, הוא יופיע כאן.';

  @override
  String get student => 'תלמיד';

  @override
  String get classroomDetailPhoto => 'תמונה';

  @override
  String get classroomDetailVoiceNote => 'הודעה קולית';

  @override
  String get classroomDetailVideo => 'וידאו';

  @override
  String get classroomDetailFile => 'קובץ';

  @override
  String get classroomDetailEmptyValue => '(ריק)';

  @override
  String get classroomDetailAttachmentUnavailable => 'הקובץ המצורף לא זמין.';

  @override
  String get classroomDetailAudioUnavailable => 'האודיו לא זמין.';

  @override
  String get classroomDetailCouldNotOpenAttachment =>
      'לא ניתן לפתוח את הקובץ המצורף.';

  @override
  String get classroomDetailVoiceMessage => 'הודעה קולית';

  @override
  String get classroomDetailVideoFile => 'קובץ וידאו';

  @override
  String get classroomDetailAttachedFile => 'קובץ מצורף';

  @override
  String get classroomDetailAttachment => 'קובץ מצורף';

  @override
  String get classroomDetailPinAction => 'נעץ';

  @override
  String get classroomDetailUnpinAction => 'בטל נעיצה';

  @override
  String get classroomDetailMessageInfoTitle => 'פרטי הודעה';

  @override
  String get classroomDetailForwardedSingle => 'הועבר';

  @override
  String classroomDetailForwardedMultiple(Object count) {
    return '$count הודעות הועברו';
  }

  @override
  String get classroomDetailCannotForwardPending =>
      'אי אפשר להעביר לצ\'אט בקשה לפני אישור';

  @override
  String get classroomDetailCouldNotForwardSelected =>
      'לא ניתן היה להעביר את ההודעות שנבחרו';

  @override
  String classroomDetailSelectedCount(Object count) {
    return '$count נבחרו';
  }

  @override
  String classroomDetailDeleteCount(Object count) {
    return 'מחק ($count)';
  }

  @override
  String get classroomDetailSelectAllTooltip => 'בחר הכל';

  @override
  String get classroomDetailCancelTooltip => 'ביטול';

  @override
  String get classroomDetailMicrophoneAccessTitle => 'נדרשת גישה למיקרופון';

  @override
  String get classroomDetailMicrophoneAccessBody =>
      'נא לאפשר גישה למיקרופון בהגדרות -> ClassMate כדי לשלוח הודעות קוליות.';

  @override
  String get classroomDetailOpenSettingsAction => 'פתח הגדרות';

  @override
  String classroomDetailForwardTargetNext(Object label) {
    return 'יעד ההעברה הבא: $label';
  }

  @override
  String get classroomDetailEditMessageTitle => 'עריכת הודעה';

  @override
  String get classroomDetailEditMessageHint => 'ערוך את ההודעה שלך...';

  @override
  String get classroomDetailLeaveClassroomTitle => 'לעזוב את הכיתה?';

  @override
  String get classroomDetailLeaveClassroomBody => 'תוסר מהכיתה הזו.';

  @override
  String get classroomDetailLeaveAction => 'עזיבה';

  @override
  String get classroomDetailNoAssignmentsTitle => 'אין מטלות עדיין';

  @override
  String get classroomDetailNoAssignmentsSubtitle =>
      'כרגע אין מטלות בכיתה הזו.';

  @override
  String get classroomDetailAssignmentFallback => 'מטלה';

  @override
  String get classroomDetailNoMaterialsTitle => 'אין חומרים עדיין';

  @override
  String get classroomDetailNoMaterialsSubtitle => 'כרגע אין חומרים בכיתה הזו.';

  @override
  String get classroomDetailMaterialFallback => 'חומר';

  @override
  String get classroomDetailNoMeetingsTitle => 'אין פגישות עדיין';

  @override
  String get classroomDetailNoMeetingsSubtitle => 'כרגע אין פגישות בכיתה הזו.';

  @override
  String get classroomDetailMeetingFallback => 'פגישה';

  @override
  String get classroomDetailCouldNotLoadPeople => 'לא ניתן לטעון את האנשים';

  @override
  String get classroomDetailNoPeopleTitle => 'אין אנשים עדיין';

  @override
  String get classroomDetailNoPeopleSubtitle =>
      'אף אחד עדיין לא מופיע בכיתה הזו.';

  @override
  String get classroomDetailTabChat => 'צ\'אט';

  @override
  String get classroomDetailTabMaterials => 'חומרים';

  @override
  String get classroomDetailTabPeople => 'אנשים';

  @override
  String get classroomChatMediaSendPhoto => 'שליחת תמונה';

  @override
  String get classroomChatMediaSendPhotoSubtitle => 'שתפו תמונה בצ\'אט הכיתה';

  @override
  String get classroomChatMediaSendVoiceMessage => 'שליחת הודעה קולית';

  @override
  String get classroomChatMediaSendVoiceMessageSubtitle =>
      'הקליטו ושלחו הודעה קולית';

  @override
  String get classroomDetailCouldNotLoadTab => 'לא ניתן לטעון את הלשונית';

  @override
  String get classroomDetailDeletedByYou => 'מחקת את ההודעה הזו';

  @override
  String get classroomDetailDeletedMessage => 'ההודעה הזו נמחקה';

  @override
  String get practiceSetupDifficultyEasy => 'קל';

  @override
  String get practiceSetupDifficultyMedium => 'בינוני';

  @override
  String get practiceSetupDifficultyHard => 'קשה';

  @override
  String get practiceSetupDifficultyOlympiad => 'אולימפיאדה';

  @override
  String get practiceSetupDifficultyAdaptive => 'מסתגל';

  @override
  String get practiceSetupModeLabelPractice => 'תרגול';

  @override
  String get practiceSetupModeLabelFlashcards => 'כרטיסיות';

  @override
  String get practiceSetupModeLabelSpeedRound => 'סבב מהיר';

  @override
  String get practiceSetupModeLabelExamPrep => 'הכנה למבחן';

  @override
  String get practiceSetupModeLabelConceptBuilder => 'בניית מושג';

  @override
  String get practiceSetupModeLabelAdaptive => 'מסתגל';

  @override
  String get practiceSetupModeLabelBagrut => 'בגרות';

  @override
  String get practiceSetupModeSubtitlePractice => 'תרגול יומי מאוזן';

  @override
  String get practiceSetupModeSubtitleFlashcards => 'חשיפה ושליפה עצמית';

  @override
  String get practiceSetupModeSubtitleSpeedRound => 'תרגיל לחץ מהיר';

  @override
  String get practiceSetupModeSubtitleExamPrep => 'זרימה רגועה בסגנון מבחן';

  @override
  String get practiceSetupModeSubtitleConceptBuilder =>
      'קודם מושג, אחר כך פתרון';

  @override
  String get practiceSetupModeSubtitleAdaptive => 'הקושי משתנה בזמן אמת';

  @override
  String get practiceSetupModeSubtitleBagrut => 'סגנון רשמי קפדני';

  @override
  String get practiceSetupModeHelpPractice =>
      'מצב מאוזן: פותרים, בודקים, מסבירים וממשיכים.';

  @override
  String get practiceSetupModeHelpFlashcards =>
      'כרטיסיות עובדות הכי טוב כשמנסים להיזכר לפני החשיפה.';

  @override
  String get practiceSetupModeHelpSpeedRound =>
      'הסבב המהיר מאמן שליפה מהירה. זוז מהר וסמוך על אינסטינקטים חזקים.';

  @override
  String get practiceSetupModeHelpExamPrep =>
      'הכנה למבחן רגועה ורשמית יותר, כמו שיעור בית ספר אמיתי.';

  @override
  String get practiceSetupModeHelpConceptBuilder =>
      'בניית מושג מלמדת קודם את הרעיון ואז מבקשת ליישם אותו.';

  @override
  String get practiceSetupModeHelpAdaptive =>
      'המצב המסתגל משנה את רמת האתגר לפי הביצועים שלך.';

  @override
  String get practiceSetupModeHelpBagrut =>
      'מצב בגרות מתמקד בפתרון ובסקירה בסגנון מבחן קפדני.';

  @override
  String get practiceSetupModeInfoTitle => 'איך כל מצב עובד';

  @override
  String get practiceSetupHeroTitle => 'התחל סשן';

  @override
  String get practiceSetupHeroSubtitle => 'בחר מצב, תזמון ורמת קושי.';

  @override
  String get practiceSetupInfiniteLives => 'חיים אינסופיים';

  @override
  String practiceSetupLivesCount(Object count) {
    return '$count חיים';
  }

  @override
  String get practiceSetupAiTiming => 'תזמון AI';

  @override
  String practiceSetupSecondsShort(Object seconds) {
    return '$secondsש׳';
  }

  @override
  String practiceSetupQuestionsCount(Object count) {
    return '$count שאלות';
  }

  @override
  String practiceSetupSummarySubject(Object subject) {
    return 'נושא לימוד: $subject';
  }

  @override
  String practiceSetupSummaryTopic(Object topic) {
    return 'תת-נושא: $topic';
  }

  @override
  String practiceSetupSummaryMode(Object mode) {
    return 'מצב: $mode';
  }

  @override
  String practiceSetupSummaryDifficulty(Object difficulty) {
    return 'קושי: $difficulty';
  }

  @override
  String practiceSetupSummaryQuestions(Object count) {
    return 'שאלות: $count';
  }

  @override
  String practiceSetupSummaryTiming(Object timing) {
    return 'תזמון: $timing';
  }

  @override
  String practiceSetupSummaryLives(Object lives) {
    return 'חיים: $lives';
  }

  @override
  String get practiceSetupSectionSubjectTopic => 'מקצוע ונושא';

  @override
  String get practiceSetupFieldSubject => 'מקצוע';

  @override
  String get practiceSetupFieldSubjectHint => 'בחר מקצוע';

  @override
  String get practiceSetupChooseSubject => 'בחר מקצוע';

  @override
  String get practiceSetupFieldCustomSubject => 'מקצוע מותאם';

  @override
  String get practiceSetupFieldCustomSubjectHint => 'כתוב את המקצוע שלך';

  @override
  String get practiceSetupDialogCustomSubjectTitle => 'מקצוע מותאם';

  @override
  String get practiceSetupDialogEnterSubject => 'הזן מקצוע';

  @override
  String get practiceSetupUseAction => 'השתמש';

  @override
  String get practiceSetupFieldTopic => 'נושא';

  @override
  String get practiceSetupFieldTopicHint => 'בחר תת-נושא';

  @override
  String get practiceSetupChooseTopic => 'בחר נושא';

  @override
  String get practiceSetupFieldCustomTopic => 'נושא מותאם';

  @override
  String get practiceSetupFieldCustomTopicHint => 'כתוב את הנושא שלך';

  @override
  String get practiceSetupDialogCustomTopicTitle => 'נושא מותאם';

  @override
  String get practiceSetupDialogEnterTopic => 'הזן נושא';

  @override
  String get practiceSubjectMath => 'מתמטיקה';

  @override
  String get practiceSubjectPhysics => 'פיזיקה';

  @override
  String get practiceSubjectComputerScience => 'מדעי המחשב';

  @override
  String get practiceSubjectChemistry => 'כימיה';

  @override
  String get practiceSubjectBiology => 'ביולוגיה';

  @override
  String get practiceSubjectEnglish => 'אנגלית';

  @override
  String get practiceSubjectArabic => 'ערבית';

  @override
  String get practiceSubjectHebrew => 'עברית';

  @override
  String get practiceSubjectGeneralKnowledge => 'ידע כללי';

  @override
  String get practiceTopicAllTopics => 'כל הנושאים';

  @override
  String get practiceTopicAlgebra => 'אלגברה';

  @override
  String get practiceTopicLinearEquations => 'משוואות ליניאריות';

  @override
  String get practiceTopicQuadraticEquations => 'משוואות ריבועיות';

  @override
  String get practiceTopicFunctions => 'פונקציות';

  @override
  String get practiceTopicGeometry => 'גיאומטריה';

  @override
  String get practiceTopicTriangles => 'משולשים';

  @override
  String get practiceTopicCircles => 'מעגלים';

  @override
  String get practiceTopicAnalyticGeometry => 'גיאומטריה אנליטית';

  @override
  String get practiceTopicTrigonometry => 'טריגונומטריה';

  @override
  String get practiceTopicProbability => 'הסתברות';

  @override
  String get practiceTopicStatistics => 'סטטיסטיקה';

  @override
  String get practiceTopicSequences => 'סדרות';

  @override
  String get practiceTopicCalculus => 'חשבון דיפרנציאלי ואינטגרלי';

  @override
  String get practiceTopicLimits => 'גבולות';

  @override
  String get practiceTopicDerivatives => 'נגזרות';

  @override
  String get practiceTopicMechanics => 'מכניקה';

  @override
  String get practiceTopicKinematics => 'קינמטיקה';

  @override
  String get practiceTopicNewtonLaws => 'חוקי ניוטון';

  @override
  String get practiceTopicForces => 'כוחות';

  @override
  String get practiceTopicEnergy => 'אנרגיה';

  @override
  String get practiceTopicMomentum => 'תנע';

  @override
  String get practiceTopicElectricity => 'חשמל';

  @override
  String get practiceTopicElectricField => 'שדה חשמלי';

  @override
  String get practiceTopicCircuits => 'מעגלים חשמליים';

  @override
  String get practiceTopicWaves => 'גלים';

  @override
  String get practiceTopicOptics => 'אופטיקה';

  @override
  String get practiceTopicThermodynamics => 'תרמודינמיקה';

  @override
  String get practiceTopicConditions => 'תנאים';

  @override
  String get practiceTopicBooleanLogic => 'לוגיקה בוליאנית';

  @override
  String get practiceTopicIfElse => 'אם / אחרת';

  @override
  String get practiceTopicNestedConditions => 'תנאים מקוננים';

  @override
  String get practiceTopicLoops => 'לולאות';

  @override
  String get practiceTopicVariables => 'משתנים';

  @override
  String get practiceTopicArrays => 'מערכים';

  @override
  String get practiceTopicStrings => 'מחרוזות';

  @override
  String get practiceTopicAlgorithms => 'אלגוריתמים';

  @override
  String get practiceTopicComplexity => 'סיבוכיות';

  @override
  String get practiceTopicRecursion => 'רקורסיה';

  @override
  String get practiceTopicAtoms => 'אטומים';

  @override
  String get practiceTopicPeriodicTable => 'הטבלה המחזורית';

  @override
  String get practiceTopicChemicalBonds => 'קשרים כימיים';

  @override
  String get practiceTopicReactions => 'תגובות';

  @override
  String get practiceTopicStoichiometry => 'סטוכיומטריה';

  @override
  String get practiceTopicAcidsAndBases => 'חומצות ובסיסים';

  @override
  String get practiceTopicOrganicChemistry => 'כימיה אורגנית';

  @override
  String get practiceTopicCells => 'תאים';

  @override
  String get practiceTopicGenetics => 'גנטיקה';

  @override
  String get practiceTopicHumanBody => 'גוף האדם';

  @override
  String get practiceTopicEcology => 'אקולוגיה';

  @override
  String get practiceTopicEvolution => 'אבולוציה';

  @override
  String get practiceTopicSystems => 'מערכות';

  @override
  String get practiceTopicGrammar => 'דקדוק';

  @override
  String get practiceTopicReadingComprehension => 'הבנת הנקרא';

  @override
  String get practiceTopicVocabulary => 'אוצר מילים';

  @override
  String get practiceTopicTenses => 'זמנים';

  @override
  String get practiceTopicWriting => 'כתיבה';

  @override
  String get practiceTopicRhetoric => 'רטוריקה';

  @override
  String get practiceSetupSectionMode => 'מצב';

  @override
  String get practiceSetupSectionDifficulty => 'קושי';

  @override
  String get practiceSetupSectionControls => 'בקרות הסשן';

  @override
  String get practiceSetupQuestionsTitle => 'שאלות';

  @override
  String get practiceSetupQuestionsCaption => 'כמה שאלות ליצור בסשן';

  @override
  String get practiceSetupTimingTitle => 'תזמון';

  @override
  String get practiceSetupTimingCaption =>
      'בחר קודם את ההיקף, ואז AI, הזמן שלך או אינסופי.';

  @override
  String get practiceSetupTimingScopePerQuestion => 'לכל שאלה';

  @override
  String get practiceSetupTimingScopeWholeQuiz => 'לכל המבחן';

  @override
  String get practiceSetupTimingModeAi => 'AI';

  @override
  String get practiceSetupTimingModeMyTime => 'הזמן שלי';

  @override
  String get practiceSetupTimingModeInfinite => 'אינסופי';

  @override
  String get practiceSetupTimingCustomPerQuestionTitle => 'שניות לכל שאלה';

  @override
  String get practiceSetupTimingCustomPerQuestionCaption =>
      'הטיימר שלך לכל שאלה';

  @override
  String get practiceSetupTimingCustomQuizMinutesTitle => 'דקות למבחן';

  @override
  String get practiceSetupTimingCustomQuizMinutesCaption =>
      'הטיימר שלך לכל המבחן';

  @override
  String get practiceSetupInfiniteLivesTitle => 'חיים אינסופיים';

  @override
  String get practiceSetupInfiniteLivesSubtitle =>
      'אל תסיים את הסשן בגלל תשובות שגויות';

  @override
  String get practiceSetupLivesTitle => 'חיים';

  @override
  String get practiceSetupLivesCaption => 'טעויות מותרות לפני שהסשן מסתיים';

  @override
  String get practiceSetupTooltipHistory => 'היסטוריית תרגול';

  @override
  String get practiceHistoryTitle => 'היסטוריית תרגול';

  @override
  String get practiceHistoryClearTooltip => 'מחק היסטוריה';

  @override
  String get practiceHistoryClearConfirmTitle => 'למחוק את היסטוריית התרגול?';

  @override
  String get practiceHistoryClearConfirmBody =>
      'פעולה זו מסירה את כל הפעילויות של תרגול השמורות מהמכשיר הזה.';

  @override
  String get practiceHistoryLoadError =>
      'לא ניתן לטעון את היסטוריית התרגול כרגע.';

  @override
  String get practiceHistoryErrorPrefix => 'שגיאה:';

  @override
  String get practiceHistoryEmpty => 'אין עדיין פעילויות של תרגול.';

  @override
  String get practiceHistoryDeleteConfirmTitle => 'למחוק את הפעילות הזו?';

  @override
  String get practiceHistoryDeleteConfirmBody =>
      'פעולה זו מסירה רק את הפעילות של תרגול השמורה הזו.';

  @override
  String get practiceHistoryOpenReview => 'פתח סקירה';

  @override
  String get practiceHistoryDeleteSession => 'מחק פעילות';

  @override
  String get practiceHistoryDebugTitle => 'ניפוי היסטוריית תרגול';

  @override
  String get practiceAnalyticsTitle => 'ניתוחי תרגול';

  @override
  String get practiceAnalyticsSectionOverall => 'כללי';

  @override
  String get practiceAnalyticsRecentSessionsTitle => 'אימונים אחרונים';

  @override
  String practiceAnalyticsRecentSessionsSummary(
    Object sessions,
    Object correct,
    Object answered,
    Object accuracy,
    Object xp,
  ) {
    return '$sessions אימונים • $correct/$answered נכונים • $accuracy% • XP $xp';
  }

  @override
  String get practiceAnalyticsSectionWeakestTopics => 'הנושאים החלשים ביותר';

  @override
  String get practiceAnalyticsSectionStrongestTopics => 'הנושאים החזקים ביותר';

  @override
  String get practiceAnalyticsSectionModePerformance => 'ביצועי מצבים';

  @override
  String get practiceAnalyticsNoTopicData => 'עדיין אין נתוני נושאים';

  @override
  String get practiceAnalyticsNoModeData => 'עדיין אין נתוני מצבים';

  @override
  String get savedQuestionsTopSubjectNone => 'עדיין אין';

  @override
  String get savedQuestionsHeroSubtitle =>
      'שאלות ששמרת במהלך התרגול אמורות להיות קלות לחזור אליהן. דף זה הוא מרכז הניסיון הנקי שלהן.';

  @override
  String get savedQuestionsSavedMetric => 'שמור';

  @override
  String get savedQuestionsTopSubjectMetric => 'נושא עליון';

  @override
  String get savedQuestionsQuickActionsSubtitle =>
      'קפוץ ישר חזרה לתרגול או עיין בפתרונות קהילה.';

  @override
  String get savedQuestionsOpenPractice => 'פתח תרגול';

  @override
  String get savedQuestionsOpenPracticeSubtitle =>
      'התחל סשן חדש והמשך לבנות תנופה';

  @override
  String get savedQuestionsOpenSolutions => 'פתח פתרונות';

  @override
  String get savedQuestionsOpenSolutionsSubtitle =>
      'עיין בפתרונות שהועלו לפי נושא, ספר, דף ושאלה';

  @override
  String get savedQuestionsQueueTitle => 'תור השמור שלך';

  @override
  String get savedQuestionsQueueSubtitle =>
      'שאלות שאתה שומר בתרגול מופיעות כאן כדי שתוכל לפתוח אותן מחדש במהירות ולהמשיך לעבוד על נקודות החולשה שלך.';

  @override
  String get savedQuestionsEmptyTitle => 'עדיין אין שאלות שמורות';

  @override
  String get savedQuestionsEmptySubtitle =>
      'שמור שאלה מתרגול כדי לחזור אליה מאוחר יותר, פתח פתרונות קשורים ועקוב אחרי הנושאים שעדיין צריכים עבודה.';

  @override
  String get savedQuestionsClearAction => 'נקה שאלות שמורות';

  @override
  String get savedQuestionsWhyItWorks => 'למה זה עובד';

  @override
  String savedQuestionsHoursTarget(Object count) {
    return '$count ש\' יעד';
  }

  @override
  String savedQuestionsMinutesTarget(Object count) {
    return '$count דק\' יעד';
  }

  @override
  String savedQuestionsSecondsTarget(Object count) {
    return '$count שנ\' יעד';
  }

  @override
  String get practiceSetupTooltipAnalytics => 'אנליטיקת תרגול';

  @override
  String get practiceSetupStopGenerating => 'עצור יצירה';

  @override
  String get practiceSetupGenerating => 'יוצר...';

  @override
  String get practiceSetupStartSession => 'התחל סשן';

  @override
  String get practiceSetupSearchHint => 'חיפוש...';

  @override
  String get practiceSessionModeDescriptionPractice =>
      'פתרון מאוזן עם בדיקה ומשוב מיידיים.';

  @override
  String get practiceSessionModeDescriptionFlashcards =>
      'מצב מבוסס זיכרון לשליפה ושימור מהירים.';

  @override
  String get practiceSessionModeDescriptionSpeedRound =>
      'חזרות לחץ מהירות, קצרות ומתוזמנות.';

  @override
  String get practiceSessionModeDescriptionExamPrep =>
      'פתרון בסגנון מבחן רשמי עם פחות גיימיפיקציה.';

  @override
  String get practiceSessionModeDescriptionConceptBuilder =>
      'להבין קודם את הרעיון ואז לפתור בהקשר.';

  @override
  String get practiceSessionModeDescriptionAdaptive =>
      'רמת הקושי משתנה לפי הביצועים שלך.';

  @override
  String get practiceSessionModeDescriptionBagrut =>
      'זרימת בגרות רשמית עם שאלה אחת בסגנון רשמי.';

  @override
  String get practiceSessionLoadingPractice => 'בונה את סשן התרגול שלך';

  @override
  String get practiceSessionLoadingFlashcards => 'מערבב את הכרטיסיות שלך';

  @override
  String get practiceSessionLoadingSpeedRound => 'מתחיל את הסבב המהיר';

  @override
  String get practiceSessionLoadingExamPrep => 'מכין את סשן המבחן שלך';

  @override
  String get practiceSessionLoadingConceptBuilder => 'טוען את מאמן המושגים';

  @override
  String get practiceSessionLoadingAdaptive => 'מתאים את האתגר עבורך';

  @override
  String get practiceSessionLoadingBagrut => 'מכין את סט הבגרות שלך';

  @override
  String get practiceSessionLoadingDefault => 'מכין את הסשן שלך';

  @override
  String practiceSessionCompleteTitle(Object mode) {
    return '$mode הושלם';
  }

  @override
  String get practiceSessionMetricAnswered => 'נענו';

  @override
  String get practiceSessionMetricCorrect => 'נכון';

  @override
  String get practiceSessionMetricWrong => 'שגוי';

  @override
  String get practiceSessionMetricAccuracy => 'דיוק';

  @override
  String get practiceSessionMetricTotal => 'סה״כ';

  @override
  String get practiceSessionMetricXp => 'XP';

  @override
  String get practiceSessionMetricStreak => 'רצף';

  @override
  String get practiceSessionReviewLayoutStacked => 'ערימה';

  @override
  String get practiceSessionReviewLayoutFocus => 'מיקוד';

  @override
  String get practiceSessionFilterAll => 'הכול';

  @override
  String get practiceSessionFilterWrong => 'שגויות';

  @override
  String get practiceSessionFilterCorrect => 'נכונות';

  @override
  String get practiceSessionReviewTitle => 'סקירת סשן';

  @override
  String get practiceSessionNoQuestionsForFilter =>
      'עדיין אין שאלות שתואמות למסנן הזה.';

  @override
  String get practiceSessionNoAnswer => 'אין תשובה';

  @override
  String get practiceSessionUnknownAnswer => 'לא ידוע';

  @override
  String get practiceSessionReflectionTitle => 'הרהור';

  @override
  String get practiceSessionReflectionKnewIt => 'ידעתי את זה';

  @override
  String get practiceSessionReflectionReviewAgain => 'לסקור שוב';

  @override
  String get practiceSessionBackOfCard => 'גב הכרטיס';

  @override
  String get practiceSessionYourAnswer => 'התשובה שלך';

  @override
  String get practiceSessionCorrectAnswer => 'התשובה הנכונה';

  @override
  String get practiceSessionExplanation => 'הסבר';

  @override
  String get practiceSessionBackToSetup => 'חזרה להגדרות';

  @override
  String get practiceSessionGeneralTopic => 'כללי';

  @override
  String practiceSessionQuestionProgress(Object current, Object total) {
    return 'שאלה $current מתוך $total';
  }

  @override
  String get practiceSessionMetricTime => 'זמן';

  @override
  String practiceSessionMatchmakingDifficulty(Object difficulty) {
    return 'קושי: $difficulty';
  }

  @override
  String get practiceModeActionPrevious => 'הקודם';

  @override
  String get practiceModeActionCheckAnswer => 'בדוק תשובה';

  @override
  String get practiceModeActionNext => 'הבא';

  @override
  String get practiceModeActionNextQuestion => 'שאלה הבאה';

  @override
  String get practiceModeActionEndSession => 'סיים סשן';

  @override
  String get practiceModeActionEndQuestion => 'סיים שאלה';

  @override
  String get practiceModeActionEndExam => 'סיים מבחן';

  @override
  String get practiceModeActionNovaHint => 'רמז NOVA';

  @override
  String get practiceModeActionReveal => 'חשוף';

  @override
  String get practiceModeActionShowSolution => 'הצג פתרון';

  @override
  String get practiceModeActionHideSolution => 'הסתר פתרון';

  @override
  String get practiceModeActionLockIn => 'נעל תשובה';

  @override
  String get practiceModeActionCheckAdapt => 'בדוק והסתגל';

  @override
  String get practiceModeActionContinue => 'המשך';

  @override
  String get practiceModeActionSolveIt => 'פתור את זה';

  @override
  String get practiceModeActionNextConcept => 'המושג הבא';

  @override
  String get practiceModeCardFront => 'צד קדמי של הכרטיס';

  @override
  String get practiceModeRecallSummary => 'סיכום היזכרות';

  @override
  String get practiceModeFeelingPrompt => 'איך זה הרגיש?';

  @override
  String get practiceModeFeelingAgain => 'שוב';

  @override
  String get practiceModeFeelingHard => 'קשה';

  @override
  String get practiceModeFeelingGood => 'טוב';

  @override
  String get practiceModeFeelingEasy => 'קל';

  @override
  String get practiceModeSpeedRoundBanner =>
      'סבב מהיר · החלטות מהירות ותנופה מיידית';

  @override
  String get practiceModeFastFeedback => 'משוב מהיר';

  @override
  String get practiceModeExamPrepBanner =>
      'הכנה למבחן · פריסה שקטה יותר, התשובות נבדקות אחרי ההתקדמות';

  @override
  String get practiceModeReview => 'סקירה';

  @override
  String get practiceModeBagrutBanner => 'מצב בגרות · זרימת טופס רשמית';

  @override
  String get practiceModeOfficialSolution => 'פתרון בסגנון רשמי';

  @override
  String get practiceModeAdaptiveWarmup => 'קושי חימום';

  @override
  String get practiceModeAdaptiveTrendingUp => 'הקושי עולה';

  @override
  String get practiceModeAdaptiveEasingDown => 'הקושי יורד';

  @override
  String get practiceModeAdaptiveSteady => 'הקושי נשאר יציב';

  @override
  String get practiceModeAdaptiveFeedback => 'משוב מסתגל';

  @override
  String get practiceModeConceptFirst => 'קודם הרעיון';

  @override
  String get practiceModeNowSolveIt => 'עכשיו פתור את זה';

  @override
  String get practiceModeConceptTitle => 'מושג';

  @override
  String get practiceModeFeedbackCorrect => 'נכון';

  @override
  String get practiceModeFeedbackNotQuite => 'לא בדיוק';

  @override
  String get practiceModeFallbackQuestion => 'שאלה';

  @override
  String get practiceModeNoExplanationYet => 'עדיין אין הסבר זמין.';

  @override
  String get teacherGradesAssessmentCreated => 'הערכת הישגים נוצרה';

  @override
  String get teacherGradesEditAssessmentTitle => 'עריכת הערכה';

  @override
  String get teacherGradesFieldTitle => 'כותרת';

  @override
  String get teacherGradesFieldDate => 'תאריך (YYYY-MM-DD)';

  @override
  String get teacherGradesFieldMaxGrade => 'ציון מקסימלי';

  @override
  String get teacherGradesAssessmentUpdated => 'הערכת הישגים עודכנה';

  @override
  String get teacherGradesDeleteAssessmentTitle => 'למחוק את ההערכה?';

  @override
  String teacherGradesDeleteAssessmentBody(Object title) {
    return 'הפעולה תסיר את $title ואת רשומת הציונים שלה ממרחב המורה.';
  }

  @override
  String get teacherGradesDeleteAction => 'מחיקה';

  @override
  String get teacherGradesAssessmentDeleted => 'הערכת הישגים נמחקה';

  @override
  String get teacherGradesRosterLinkError => 'הערכה זו אינה מקושרת לסגל כיתה.';

  @override
  String get teacherGradesSaved => 'הציונים נשמרו';

  @override
  String get teacherGradesSubtitle =>
      'צור הערכות ושמור ציונים מול סגל הכיתה החי.';

  @override
  String get teacherGradesCreateAssessmentTitle => 'יצירת הערכה';

  @override
  String get teacherGradesFieldCourse => 'קורס';

  @override
  String get teacherGradesCreateAction => 'יצירה';

  @override
  String get teacherGradesNoStudentsLoaded => 'לא נטענו תלמידים עבור הערכה זו.';

  @override
  String get teacherGradesFieldGrade => 'ציון';

  @override
  String teacherGradesMaxHint(Object grade) {
    return 'מקסימום $grade';
  }

  @override
  String get teacherGradesSaving => 'שומר…';

  @override
  String teacherGradesSaveCount(Object count) {
    return 'שמור $count ציונים';
  }

  @override
  String get assignmentsNoDueDate => 'אין תאריך סיום';

  @override
  String get assignmentsLoadError =>
      'לא הצלחנו לטעון משימות כעת. משוך כדי לרענן או נסה שוב.';

  @override
  String get assignmentsLoadTimeout =>
      'משימות לוקחות זמן רב מדי לטעינה. משוך כדי לרענן או נסה שוב בעוד רגע.';

  @override
  String get assignmentsLoadNetwork =>
      'לא ניתן היה להתחבר למשימות כעת. בדוק את החיבור שלך ונסה שוב.';

  @override
  String get assignmentsStatusOverdue => 'באיחור';

  @override
  String get assignmentsStatusDueSoon => 'מועד קרוב';

  @override
  String get assignmentsStatusUpcoming => 'קרוב';

  @override
  String get assignmentsPreviewFallback =>
      'פתח משימה זו כדי לראות את ההנחיות המלאות ולהכין את עבודתך.';

  @override
  String get assignmentsSubmissionPrepEmpty =>
      'שלח את ההערה או הקבצים שלך כאן.';

  @override
  String assignmentsSubmissionPrepCount(Object count) {
    return '$count קובץ(ים) מוצמדים באופן מקומי.';
  }

  @override
  String get assignmentsHeroSubtitle =>
      'כל משימות הכיתה בתצוגה אחת נקייה, עם דף פרטים במסך מלא ומקום ייעודי להכנת עבודתך.';

  @override
  String get assignmentsSubjectsMetric => 'נושאים';

  @override
  String get assignmentsNothingAssignedYet => 'עדיין לא הוקצה כלום';

  @override
  String get assignmentsNoAssignmentsForAccount =>
      'אין משימות כיתה זמינות עבור חשבון תלמיד זה כרגע.';

  @override
  String assignmentsNextThingBody(Object title, Object due) {
    return '$title הוא הדבר הבא שצריך להביט בו. $due.';
  }

  @override
  String get assignmentsPullToCheckAgain => 'משוך למטה כדי לבדוק שוב.';

  @override
  String get assignmentsFiltersSubtitle =>
      'צמצם את הרשימה לפי נושא או דחיפות כדי להתמקד במה שחשוב תחילה.';

  @override
  String get assignmentsSubjectLabel => 'נושא';

  @override
  String get assignmentsAllSubjects => 'כל הנושאים';

  @override
  String get assignmentsSearchSubjects => 'חפש נושאים';

  @override
  String get assignmentsStatusLabel => 'סטטוס';

  @override
  String get assignmentsAllStatuses => 'כל הסטטוסים';

  @override
  String get assignmentsSearchStatuses => 'חפש סטטוסים';

  @override
  String assignmentsShowingSummary(Object shown, Object total) {
    return 'מוצג $shown מתוך $total משימות.';
  }

  @override
  String get assignmentsNoFilterMatchesTitle =>
      'אין משימות התואמות למסננים אלה';

  @override
  String get assignmentsNoFilterMatchesSubtitle =>
      'נסה את כל הנושאים או תצוגת סטטוס רחבה יותר כדי להחזיר עוד משימות לרשימה.';

  @override
  String get assignmentsClearFiltersHint => 'נקה מסננים כדי לראות הכל שוב.';

  @override
  String get assignmentsListSubtitle =>
      'הקש על משימה כלשהי כדי לפתוח את תצוגת הפרטים במסך מלא ולהכין את עבודתך.';

  @override
  String get assignmentsAddNoteBeforePrepare =>
      'הוסף הערה או צרף קובץ לפני הכנת עבודתך.';

  @override
  String get assignmentsWorkDraftPrepared => 'טיוטת עבודה מוכנה.';

  @override
  String get assignmentsWorkDraftPreparedWithFiles =>
      'טיוטת עבודה מוכנה. קבצים מצורפים נשמרים בהתקן זה.';

  @override
  String get assignmentsUnavailableTitle => 'משימה לא זמינה';

  @override
  String get assignmentsUnavailableSubtitle =>
      'לא ניתן היה למצוא משימה זו בזרם הנוכחי. ייתכן שהוסרה או אינה זמינה במצב לא מקוון.';

  @override
  String get assignmentsUnavailableHint => 'חזור ורענן את רשימת המשימות.';

  @override
  String get assignmentsOverdueBannerBody =>
      'משימה זו עברה את תאריך הסיום שלה. פתח את אזור העבודה שלך להלן כדי להכין מה שברצונך להגיש.';

  @override
  String get assignmentsWorkAreaBannerBody =>
      'השתמש באזור העבודה למטה כדי לארגן קבצים, לכתוב הערה ולהשאיר הכל מוכן במקום אחד.';

  @override
  String get assignmentsDetailsSectionTitle => 'פרטי משימה';

  @override
  String get assignmentsDetailsSectionSubtitle =>
      'הכל רלוונטי לתלמיד המצוי כעת בעומס המשימה של הכיתה.';

  @override
  String get assignmentsDetailDueLabel => 'תאריך סיום';

  @override
  String get assignmentsDetailClassroomLabel => 'כיתה';

  @override
  String get assignmentsDetailTeacherLabel => 'מורה';

  @override
  String get assignmentsDetailPostedByLabel => 'פורסם על ידי';

  @override
  String get assignmentsDetailPublishedLabel => 'פורסם';

  @override
  String get assignmentsDetailUpdatedLabel => 'עודכן';

  @override
  String get assignmentsDetailIdLabel => 'מזהה משימה';

  @override
  String get assignmentsInstructionsTitle => 'הוראות';

  @override
  String get assignmentsInstructionsSubtitle =>
      'טקסט משימה מלא מזרם הכיתה, כשהנוסח המקורי נשמר.';

  @override
  String get assignmentsYourWorkTitle => 'עבודתך';

  @override
  String get assignmentsYourWorkSubtitle =>
      'ארגן הערה, צרף קבצים או מסמכים והשאיר את הכנת ההגשה שלך במקום ממוקד.';

  @override
  String get assignmentsPrivateNoteLabel => 'הערת עבודה פרטית';

  @override
  String get assignmentsPrivateNoteHint =>
      'הוסף מה שאתה מתכנן להגיש, תזכורות לעצמך או תקציר מסמך/קישור.';

  @override
  String get assignmentsAddFiles => 'הוסף קבצים או מסמכים';

  @override
  String get assignmentsClearFiles => 'נקה קבצים';

  @override
  String get assignmentsStagedDeviceHint =>
      'קבצים מסודרים בהתקן זה. הגשת קובץ משימה אינה זמינה באפליקציה זו.';

  @override
  String assignmentsLastPrepared(Object time) {
    return 'הוכן לאחרונה $time.';
  }

  @override
  String get assignmentsSubmissionPrepTitle => 'הכנת הגשה';

  @override
  String get assignmentsPreparing => 'בהכנה';

  @override
  String get assignmentsPrepareWork => 'הכן עבודה';

  @override
  String get assignmentsLoadingSubtitle => 'טעינת משימות הכיתה שלך.';

  @override
  String get assignmentsPullToRefreshRetry => 'משוך לרענון או נסה שוב להלן.';

  @override
  String get assignmentsFileSizeUnknown => 'קובץ';

  @override
  String get assignmentsRemoveAttachment => 'הסר קובץ מצורף';

  @override
  String get assignmentsSubmitted => 'הוגש';

  @override
  String get attendanceUndated => 'ללא תאריך';

  @override
  String get attendanceLoadError =>
      'לא יכולנו לטעון נוכחות כעת. גרור לרענון או נסה שוב.';

  @override
  String get attendanceLoadTimeout =>
      'נוכחות לוקחת זמן רב מדי לטעינה. גרור לרענון או נסה שוב בעוד רגע.';

  @override
  String get attendanceLoadNetwork =>
      'נוכחות לא יכלה להתחבר כעת. בדוק את החיבור שלך ונסה שוב.';

  @override
  String get attendanceConsistencyBuilding => 'עדיין בבנייה';

  @override
  String get attendanceConsistencyExcellent => 'עקביות מעולה';

  @override
  String get attendanceConsistencySteady => 'בעיקר יציב';

  @override
  String get attendanceConsistencyNeedsAttention => 'דורש תשומת לב';

  @override
  String get attendanceConsistencyRisk => 'סיכון נוכחות';

  @override
  String get attendanceWatchRecentAbsences => 'היעדרויות אחרונות';

  @override
  String get attendanceWatchRepeatedLateness => 'איחורים חוזרים';

  @override
  String get attendanceWatchExcusedAddingUp => 'זמן מוצדק מצטבר';

  @override
  String get attendanceWatchNoFlags => 'אין דגלים נוכחיים';

  @override
  String get attendanceAllSubjectsLowercase => 'כל הנושאים';

  @override
  String attendanceShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return 'מציג $shown מתוך $total סימנים עבור $subject בטווח $range.';
  }

  @override
  String get attendanceDayToneAbsent => 'יום היעדרות';

  @override
  String get attendanceDayToneLate => 'אות איחור';

  @override
  String get attendanceDayToneExcused => 'נוכחות מוצדקת';

  @override
  String get attendanceDayToneClean => 'יום נקי';

  @override
  String get attendanceLoadingSubtitle =>
      'טוען את סיכום הנוכחות העדכני ביותר שלך.';

  @override
  String get attendanceUnavailableTitle => 'נוכחות לא זמינה';

  @override
  String get attendanceHeroSubtitle =>
      'קריאה ברורה על שיעור הנוכחות שלך, שיעורים אחרונים וכל דבר שדורש תשומת לב.';

  @override
  String get attendanceMetricRate => 'שיעור';

  @override
  String get attendanceMetricPresent => 'סימני נוכחות';

  @override
  String get attendanceMetricLate => 'סימני איחור';

  @override
  String get attendanceMetricAbsent => 'סימני היעדרות';

  @override
  String attendanceHeroSignalBody(Object flag) {
    return '$flag. לחץ נוכחות יכול להצטבר בשקט, כך שהתצוגה זו מתמקדת במה שהשתנה לאחרונה.';
  }

  @override
  String get attendanceNoSummary =>
      'עדיין אין סיכום נוכחות זמין לחשבון תלמיד זה.';

  @override
  String get attendanceEmptyTitle => 'אין רישומי נוכחות עדיין';

  @override
  String get attendanceEmptySubtitle =>
      'עדיין לא פורסמו רישומי נוכחות לחשבון תלמיד זה.';

  @override
  String get attendanceFiltersSubtitle =>
      'השתמש באותו סגנון בורר ניתן לחיפוש כמו בהגדרות כדי להצר את תצוגת הנוכחות לפי נושא או חלון זמן.';

  @override
  String get attendanceTimeRangeLabel => 'טווח זמן';

  @override
  String get attendanceSearchRanges => 'כל הזמן / 7 ימים / 30 ימים / 90 ימים';

  @override
  String get attendanceNoFilteredMarksTitle => 'אין סימנים התואמים למסננים אלה';

  @override
  String get attendanceNoFilteredMarksSubtitle =>
      'נסה את כל הנושאים או טווח זמן רחב יותר כדי להחזיר יותר סימני נוכחות לתצוגה.';

  @override
  String get attendanceQuickReadTitle => 'קריאה מהירה';

  @override
  String get attendanceQuickReadSubtitleFiltered =>
      'סיכום מהיר עבור סימני הנוכחות המסוננים המוצגים להלן.';

  @override
  String get attendanceQuickReadSubtitleAll =>
      'סיכום מהיר המבוסס על רישומי הנוכחות העדכניים ביותר הזמינים.';

  @override
  String get attendanceSummaryConsistency => 'עקביות';

  @override
  String get attendanceSummaryWatchFor => 'שים לב ל';

  @override
  String get attendanceSummaryExcused => 'סימנים מוצדקים';

  @override
  String get attendanceSummaryMarksInView => 'סימנים בתצוגה';

  @override
  String get attendanceSummaryRateInView => 'שיעור בתצוגה';

  @override
  String get attendanceRecentDaysTitle => 'ימים אחרונים';

  @override
  String get attendanceRecentDaysSubtitleFiltered =>
      'מקובצים לפי יום עבור הסימנים המסוננים בתצוגה כרגע.';

  @override
  String get attendanceRecentDaysSubtitleAll =>
      'מקובצים לפי יום כך שתוכל לתפוס דפוסי היעדרות או איחור מהר יותר.';

  @override
  String get attendanceLessonCountSingle => 'שיעור אחד';

  @override
  String attendanceLessonCount(Object count) {
    return '$count שיעורים';
  }

  @override
  String get attendanceStatusPresent => 'נוכח';

  @override
  String get attendanceStatusLate => 'באיחור';

  @override
  String get attendanceStatusAbsent => 'היעדר';

  @override
  String get attendanceStatusExcused => 'מוצדק';

  @override
  String get attendanceStatusRecorded => 'מוקלט';

  @override
  String get attendanceLessonFallback => 'שיעור';

  @override
  String get attendanceRangeAll => 'כל הזמן';

  @override
  String get attendanceRange7 => '7 ימים אחרונים';

  @override
  String get attendanceRange30 => '30 ימים אחרונים';

  @override
  String get attendanceRange90 => '90 ימים אחרונים';

  @override
  String get attendanceRangeAllShort => 'כל הזמן';

  @override
  String get attendanceRange7Short => '7 ימים';

  @override
  String get attendanceRange30Short => '30 ימים';

  @override
  String get attendanceRange90Short => '90 ימים';

  @override
  String get gradesLoadError =>
      'לא היה ניתן לטעון ציונים כרגע. משוך כדי לרענן או נסה שוב.';

  @override
  String get gradesLoadTimeout =>
      'ציונים לוקחים יותר מדי זמן לטעינה. משוך כדי לרענן או נסה שוב בעוד רגע.';

  @override
  String get gradesLoadNetwork =>
      'לא הצליח להתחבר לציונים כרגע. בדוק את החיבור שלך ונסה שוב.';

  @override
  String get gradesGeneralSubject => 'כללי';

  @override
  String get gradesBandBuilding => 'עדיין בבניה';

  @override
  String get gradesBandExcellent => 'מעולה';

  @override
  String get gradesBandStrong => 'חזק';

  @override
  String get gradesBandOkay => 'בסדר';

  @override
  String get gradesBandNeedsAttention => 'צריך תשומת לב';

  @override
  String get gradesBandRisk => 'בסיכון';

  @override
  String get gradesTrendRising => 'עולה';

  @override
  String get gradesTrendDropping => 'יורד';

  @override
  String get gradesTrendStable => 'יציב';

  @override
  String gradesShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return 'מציג $shown מתוך $total ציונים שנרשמו עבור $subject ב-$range.';
  }

  @override
  String get gradesLoadingSubtitle => 'טוען את התוצאות האקדמיות העדכניות שלך.';

  @override
  String get gradesUnavailableTitle => 'ציונים לא זמינים';

  @override
  String get gradesHeroSubtitle =>
      'קריאה ברורה של הממוצע שלך, הערכות אחרונות, ואילו מקצועות צריכים הגנה או התאוששות.';

  @override
  String get gradesMetricAverage => 'ממוצע';

  @override
  String get gradesMetricRecorded => 'נרשם';

  @override
  String get gradesMetricBestSubject => 'המקצוע הטוב ביותר';

  @override
  String get gradesMetricNeedsWork => 'צריך עבודה';

  @override
  String gradesLatestSignalBody(
    Object assessment,
    Object subject,
    Object grade,
    Object band,
  ) {
    return '$assessment ב-$subject קיבל $grade. $band כרגע.';
  }

  @override
  String get gradesSummaryAvailableNoRecent =>
      'סיכום ציונים זמין, אך אין הערכות אחרונות גלויות בתצוגה זו כרגע.';

  @override
  String get gradesEmptyTitle => 'עדיין אין ציונים';

  @override
  String get gradesEmptySubtitle => 'לא פורסמו ציונים לחשבון התלמיד הזה עדיין.';

  @override
  String get gradesFiltersSubtitle =>
      'השתמש באותו סגנון בורר שניתן לחיפוש כמו בהגדרות כדי לצמצם ציונים לפי מקצוע או חלון זמן.';

  @override
  String get gradesNoFilteredTitle => 'אין ציונים התואמים לסנני אלה';

  @override
  String get gradesNoFilteredSubtitle =>
      'נסה את כל המקצועות או טווח זמן רחב יותר כדי להחזיר יותר ציונים שנרשמו.';

  @override
  String get gradesQuickReadTitle => 'קריאה מהירה';

  @override
  String get gradesQuickReadSubtitleFiltered =>
      'סיכום מהיר של הציונים כרגע בתצוגה.';

  @override
  String get gradesQuickReadSubtitleAll =>
      'הקריאה המהירה ביותר על מה להגן ומה להחזיר.';

  @override
  String get gradesWeakSpotLabel => 'נקודת חולשה נוכחית';

  @override
  String get gradesNoWeakSignal => 'אין עדיין אות מקצוע חלוש';

  @override
  String gradesWeakSpotValue(Object subject) {
    return '$subject צריך את בלוק ההתאוששות הראשון.';
  }

  @override
  String get gradesStrengthLabel => 'כוח נוכחי';

  @override
  String get gradesNoStrengthSignal => 'אין עדיין אות מקצוע חזק';

  @override
  String gradesStrengthValue(Object subject) {
    return '$subject הוא עוגן הביטחון שלך כרגע.';
  }

  @override
  String get gradesBandLabel => 'טווח';

  @override
  String get gradesInViewLabel => 'בתצוגה';

  @override
  String gradesInViewCount(Object count) {
    return '$count ציונים שנרשמו בסנן זה.';
  }

  @override
  String gradesInViewAverage(Object count, Object average) {
    return '$count ציונים שנרשמו בממוצע $average.';
  }

  @override
  String get gradesLatestAssessmentsTitle => 'הערכות אחרונות';

  @override
  String get gradesLatestAssessmentsSubtitleFiltered =>
      'ציונים שנרשמו לאחרונה בתצוגה המסוננת הנוכחית.';

  @override
  String get gradesLatestAssessmentsSubtitleAll =>
      'ציונים שנרשמו לאחרונה בסדר כרונולוגי.';

  @override
  String get gradesSubjectDrilldownTitle => 'פירוט מקצוע';

  @override
  String get gradesSubjectDrilldownSubtitleFiltered =>
      'מקובץ לפי מקצוע עבור הציונים כרגע בתצוגה.';

  @override
  String get gradesSubjectDrilldownSubtitleAll =>
      'מקובץ לפי מקצוע כדי שמגמה ולחץ יתבררו יותר מהר.';

  @override
  String get gradesAssessmentFallback => 'הערכה';

  @override
  String get gradesChipBest => 'הטוב ביותר';

  @override
  String get gradesNoAverageYet => 'אין ממוצע עדיין';

  @override
  String gradesRecentAverage(Object average) {
    return 'ממוצע אחרון: $average';
  }

  @override
  String get actionCancel => 'ביטול';

  @override
  String get actionSave => 'שמור';

  @override
  String get actionDelete => 'מחק';

  @override
  String get actionRemove => 'הסר';

  @override
  String get actionBlock => 'חסום';

  @override
  String get actionCreate => 'צור';

  @override
  String get actionShare => 'שתף';

  @override
  String get actionScheduleVerb => 'תזמן';

  @override
  String get actionAdd => 'הוסף';

  @override
  String get actionKeep => 'שמור';

  @override
  String get actionOpen => 'פתח';

  @override
  String get actionPublish => 'פרסם';

  @override
  String get actionPublishing => 'מפרסם…';

  @override
  String get actionRefresh => 'רענן';

  @override
  String get msgBlockTitle => 'לחסום משתמש זה?';

  @override
  String get msgBlockContent =>
      'הוא לא יוכל לשלוח לך הודעות ולא תראה את הודעותיו.';

  @override
  String get msgRenameGroup => 'שנה שם קבוצה';

  @override
  String get msgGroupName => 'שם הקבוצה';

  @override
  String get msgMute => 'השתק';

  @override
  String get msgUnmute => 'בטל השתקה';

  @override
  String get msgInviteCode => 'קוד הזמנה';

  @override
  String get msgCopyCode => 'העתק קוד';

  @override
  String get msgLeave => 'עזוב';

  @override
  String get msgInviteCodeCopied => 'קוד ההזמנה הועתק';

  @override
  String msgCodeCopied(Object code) {
    return 'קוד הועתק: $code';
  }

  @override
  String msgParticipantsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count משתתפים נוספו',
      one: 'משתתף אחד נוסף',
    );
    return '$_temp0';
  }

  @override
  String msgMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count חברים',
      one: 'חבר אחד',
    );
    return '$_temp0';
  }

  @override
  String get msgAdmin => 'מנהל';

  @override
  String get msgRemoveFromGroup => 'הסר מהקבוצה';

  @override
  String get msgMakeAdmin => 'הפוך למנהל';

  @override
  String get msgRemoveAdmin => 'הסר הרשאות מנהל';

  @override
  String get msgOnlyAdmin => 'מנהל יחיד — קדם אחר קודם';

  @override
  String msgRemoveMemberTitle(Object name) {
    return 'להסיר את $name?';
  }

  @override
  String get msgNotificationsMuted => 'ההתראות הושתקו';

  @override
  String get msgNotificationsUnmuted => 'ההתראות הופעלו';

  @override
  String get msgJoinGroupTitle => 'הצטרף לקבוצה';

  @override
  String get msgJoinGroupSubtitle => 'הזן את קוד ההזמנה ממנהל הקבוצה';

  @override
  String get examTitle => 'בחינה';

  @override
  String get examNotFound => 'הבחינה לא נמצאה';

  @override
  String get examStudyWithNova => 'לימוד עם NOVA';

  @override
  String get examOpenInsights => 'פתח תובנות';

  @override
  String get examAddToCalendar => 'הוסף ליומן';

  @override
  String get examCouldNotOpenCalendar => 'לא ניתן לפתוח את היומן.';

  @override
  String get formTitle => 'טופס';

  @override
  String get formNotFound => 'הטופס לא נמצא';

  @override
  String get formClosed => 'סגור';

  @override
  String get formCompletion => 'השלמה';

  @override
  String get formNoTextResponses => 'אין תשובות טקסט עדיין.';

  @override
  String get meetingsCouldNotLoad => 'לא ניתן לטעון פגישות';

  @override
  String get meetingCouldNotLoad => 'לא ניתן לטעון פגישה';

  @override
  String get insightsGenerateAction => 'צור תובנות';

  @override
  String get insightsRefreshAction => 'רענן';

  @override
  String get teacherGoToClassroom => 'עבור לכיתה';

  @override
  String get teacherMarkAttendance => 'סמן נוכחות';

  @override
  String get teacherPostAssignment => 'פרסם מטלה';

  @override
  String get teacherNewAnnouncementAction => 'הודעה חדשה';

  @override
  String get teacherViewFullWeekSchedule => 'הצג לוח שבועי מלא';

  @override
  String get teacherGroupsLabel => 'קבוצות';

  @override
  String get teacherTestsLabel => 'בחינות';

  @override
  String get teacherAnnounceLabel => 'הכרז';

  @override
  String get teacherTitleAndMessageRequired => 'נדרשים כותרת והודעה';

  @override
  String get teacherAnnouncementPublished => 'ההודעה פורסמה';

  @override
  String teacherFailedToPublish(Object error) {
    return 'הפרסום נכשל: $error';
  }

  @override
  String get teacherAnnouncementSectionTitle => 'הודעה';

  @override
  String get teacherAudienceSectionTitle => 'קהל יעד';

  @override
  String get teacherPinAnnouncement => 'נעץ הודעה';

  @override
  String get teacherPinnedAtTop => 'הודעות מנועצות מופיעות בראש';

  @override
  String get teacherPublishAction => 'פרסם';

  @override
  String get teacherPublishingAction => 'מפרסם…';

  @override
  String get teacherAnnounceTitleLabel => 'כותרת *';

  @override
  String get teacherAnnounceTitleHint => 'לדוגמה: אירוע בית ספר מחר';

  @override
  String get teacherAnnounceMessageLabel => 'הודעה *';

  @override
  String get teacherAnnounceMessageHint => 'כתוב את ההודעה המלאה כאן…';

  @override
  String get teacherStudentsLabel => 'תלמידים';

  @override
  String get teacherSearchStudents => 'חפש תלמידים…';

  @override
  String get teacherNoStudentsLoaded => 'לא נמצאו תלמידים בבית ספר זה.';

  @override
  String get teacherActions => 'פעולות מהירות';

  @override
  String get teacherParentsLabel => 'הורים';

  @override
  String get teacherTeachersLabel => 'מורים';

  @override
  String get teacherWeekScheduleTitle => 'לוח שבועי';

  @override
  String get teacherCouldNotLoadSchedule => 'לא ניתן לטעון את הלוח';

  @override
  String get teacherAttendanceLast30 => 'נוכחות (30 הימים האחרונים)';

  @override
  String teacherAttendanceFrom(Object date) {
    return 'מ-$date';
  }

  @override
  String get teacherAttendanceChangeDate => 'שינוי תאריך';

  @override
  String get teacherAttendanceNoSessions =>
      'אין מפגשי נוכחות שמורים.\nסמנו נוכחות מתוך המערכת.';

  @override
  String get teacherRecentGrades => 'ציונים אחרונים';

  @override
  String get teacherNoGradesRecorded => 'לא נרשמו ציונים עדיין';

  @override
  String get teacherGradeAvg => 'ממוצע ציונים';

  @override
  String get teacherSubmittedLabel => 'הוגש';

  @override
  String get teacherAnalyticsTitle => 'ניתוחים';

  @override
  String get teacherGradeReports => 'דוחות ציונים';

  @override
  String get teacherAvgLabel => 'ממוצע';

  @override
  String teacherBelow60(Object count) {
    return '$count מתחת ל-60%';
  }

  @override
  String teacherGradedFraction(Object graded, Object total) {
    return '$graded/$total עם ציון';
  }

  @override
  String get teacherNoGradesEntered => 'לא הוזנו ציונים עדיין';

  @override
  String get teacherNewAssignment => 'מטלה חדשה';

  @override
  String get teacherDeleteAssignment => 'למחוק מטלה?';

  @override
  String get teacherDeleteAssignmentContent =>
      'פעולה זו תסיר אותה לכל התלמידים.';

  @override
  String get teacherShareMaterialTitle => 'שתף חומר';

  @override
  String get teacherRemoveMaterial => 'להסיר חומר?';

  @override
  String get teacherScheduleMeetingTitle => 'תזמן פגישה';

  @override
  String get teacherCancelMeetingTitle => 'לבטל פגישה?';

  @override
  String get teacherCancelMeetingAction => 'בטל פגישה';

  @override
  String get teacherJoinMeeting => 'הצטרף לפגישה';

  @override
  String get teacherAddStudentTitle => 'הוסף תלמיד';

  @override
  String teacherRemoveStudentTitle(Object name) {
    return 'להסיר את $name?';
  }

  @override
  String get teacherRemoveStudentContent => 'תלמיד זה יוסר מכיתה זו.';

  @override
  String get teacherStudentAdded => 'התלמיד נוסף';

  @override
  String get teacherClassroomAnalyticsTitle => 'ניתוחי כיתה';

  @override
  String get teacherOpenAnalyticsAction => 'פתח ניתוחים';

  @override
  String teacherStudentsCount(Object count) {
    return 'תלמידים ($count)';
  }

  @override
  String get teacherAssignmentLabel => 'מטלה';

  @override
  String get teacherShareMaterialLabel => 'שתף חומר';

  @override
  String get teacherAttendanceRateLabel => 'שיעור נוכחות';

  @override
  String get teacherSelectSessionPrompt =>
      'בחר סשן למטה כדי להתחיל לסמן נוכחות';

  @override
  String get teacherOpenAction => 'פתח';

  @override
  String get chatDeleteForMe => 'מחק עבורי';

  @override
  String get chatDeleteForEveryone => 'מחק עבור כולם';

  @override
  String get chatMicNeeded => 'נדרשת גישה למיקרופון';

  @override
  String get chatMicNeededBody =>
      'אנא אפשר גישה למיקרופון בהגדרות כדי לשלוח הודעות קוליות.';

  @override
  String get chatOpenSettings => 'פתח הגדרות';

  @override
  String get chatCopied => 'הועתק';

  @override
  String get chatCouldNotSendMedia => 'לא ניתן לשלוח מדיה.';

  @override
  String get chatCouldNotSendMessage => 'לא ניתן לשלוח הודעה.';

  @override
  String get chatCouldNotForward => 'לא ניתן להעביר את ההודעות שנבחרו';

  @override
  String get chatSelectAll => 'בחר הכל';

  @override
  String get chatDeselectAll => 'בטל בחירת הכל';

  @override
  String get chatEditingMessage => 'עריכת הודעה';

  @override
  String get chatEditPlaceholder => 'ערוך הודעה…';

  @override
  String get chatMessageHint => 'הודעה';

  @override
  String get chatPin => 'נעץ';

  @override
  String get chatUnpin => 'בטל נעיצה';

  @override
  String get chatPhoto => 'תמונה';

  @override
  String get chatVideo => 'וידאו';

  @override
  String get chatMedia => 'מדיה';

  @override
  String get chatAudioFile => 'קובץ שמע';

  @override
  String get chatVideoFile => 'קובץ וידאו';

  @override
  String get chatAttachedFile => 'קובץ מצורף';

  @override
  String get chatFollowUp => 'המשך';

  @override
  String get chatCancelTooltip => 'ביטול';

  @override
  String get chatJoinGroup => 'הצטרף לקבוצה';

  @override
  String get chatJoining => 'מצטרף…';

  @override
  String get chatJoinGroupTooltip => 'הצטרף לקבוצה עם קוד';

  @override
  String get chatForwardNoChatAvailable => 'אין שיחות מאושרות זמינות';

  @override
  String get chatFilterAll => 'הכל';

  @override
  String get novaDisclaimer => 'NOVA עלולה לטעות. בדוק תשובות חשובות.';

  @override
  String get practiceCustomDisclaimer =>
      'נושאים מותאמים אישית נוצרים על ידי בינה מלאכותית בזמן אמת. שאלות עלולות לסטות מהנושא או להיות לא מדויקות בנושאים נישתיים. אמת תשובות לא מוכרות באופן עצמאי.';

  @override
  String get classroomsJoined => 'הצטרפת לכיתה!';

  @override
  String get classroomsJoinAction => 'הצטרף לכיתה';

  @override
  String get classroomsJoinTooltip => 'הצטרף לכיתה';

  @override
  String get classroomsJoinTitle => 'הצטרף לכיתה';

  @override
  String get classroomsJoinSubtitle => 'הזן את הקוד שהמורה שלך נתן לך';

  @override
  String get classroomsCouldNotOpenLink => 'לא ניתן לפתוח את הקישור';

  @override
  String get classroomsReorderTitle => 'סדר מחדש כיתות';

  @override
  String get classroomsNoClassroomsToReorder => 'אין כיתות לסידור מחדש.';

  @override
  String get teacherPostAnnouncementAction => 'פרסם הודעה';

  @override
  String get announcementAudienceEveryone => 'כולם';

  @override
  String get teacherGreetingMorning => 'בוקר טוב';

  @override
  String get teacherGreetingAfternoon => 'צהריים טובים';

  @override
  String get teacherGreetingEvening => 'ערב טוב';

  @override
  String get teacherTodaysClasses => 'שיעורי היום';

  @override
  String get teacherNoDate => 'אין תאריך';

  @override
  String get teacherUpcomingTestsSubtitle => 'מבחנים וחידונים הבאים';

  @override
  String get teacherNoClassesThisWeek => 'אין שיעורים השבוע';

  @override
  String get teacherNoClassesThisWeekSub => 'לוח הזמנים שלך לשבוע זה ריק';

  @override
  String get teacherTitleFieldLabel => 'כותרת *';

  @override
  String get teacherInstructionsLabel => 'הוראות';

  @override
  String get teacherLinkUrlLabel => 'קישור / כתובת URL *';

  @override
  String get teacherLinkUrlHint => 'https://...';

  @override
  String get teacherDescriptionLabel => 'תיאור';

  @override
  String get teacherMeetingTitleLabel => 'כותרת הפגישה *';

  @override
  String get teacherMeetingLinkLabel => 'קישור לפגישה *';

  @override
  String get teacherMeetingLinkHint => 'קישור Zoom / Meet / Teams';

  @override
  String get teacherStudentEmailLabel => 'אימייל או מזהה של תלמיד';

  @override
  String get teacherTooltipRemoveStudent => 'הסר מהכיתה';

  @override
  String get teacherCouldNotLoad => 'לא ניתן לטעון';

  @override
  String get teacherNoAssignmentsYet => 'אין מטלות עדיין';

  @override
  String get teacherNoAssignmentsSub => 'הקש + כדי ליצור את המטלה הראשונה';

  @override
  String get teacherNoMaterialsYet => 'אין חומרים עדיין';

  @override
  String get teacherNoMaterialsSub => 'שתף קישורים, מסמכים ומשאבים עם הכיתה';

  @override
  String get teacherNoMeetingsScheduled => 'אין פגישות מתוזמנות';

  @override
  String get teacherNoMeetingsSub => 'הקש + כדי לתזמן פגישת כיתה';

  @override
  String get teacherAttendanceOther => 'אחר';

  @override
  String get teacherTotal => 'סה״כ';

  @override
  String get mediaOpenExternally => 'פתח באפליקציה חיצונית';

  @override
  String get mediaUnableToLoad => 'לא ניתן לטעון את התמונה';

  @override
  String get searchHint => 'חפש...';

  @override
  String get teacherInsightsTitle => 'תובנות תלמידים';

  @override
  String get teacherInsightsSubtitle =>
      'בחר תלמיד כדי לצפות בתובנות האקדמיות שלו.';

  @override
  String get teacherInsightsNoStudents => 'לא נמצאו תלמידים.';

  @override
  String get teacherInsightsSearchHint => 'חיפוש תלמידים…';

  @override
  String get navDiplomas => 'תעודות';

  @override
  String get diplomasComingSoon => 'ניהול תעודות בקרוב.';

  @override
  String get teacherExamsTitle => 'בחינות';

  @override
  String get teacherExamsUpcoming => 'הבאות';

  @override
  String get teacherExamsPast => 'שעברו';

  @override
  String get teacherExamsEmpty => 'אין הערכות עדיין. הקש + כדי ליצור.';

  @override
  String teacherExamsGraded(Object count) {
    return '$count עם ציון';
  }

  @override
  String get teacherFormsTitle => 'טפסים';

  @override
  String get teacherFormsEmpty => 'אין טפסים עדיין. הקש + כדי ליצור.';

  @override
  String teacherFormsResponses(Object count) {
    return '$count תגובות';
  }

  @override
  String get teacherFormsPublished => 'פורסם';

  @override
  String get teacherFormsDraft => 'טיוטה';

  @override
  String get teacherFormsCreateTitle => 'צור טופס';

  @override
  String get teacherFormsAddQuestion => 'הוסף שאלה';

  @override
  String get teacherFormsQuestionHint => 'טקסט השאלה';

  @override
  String get teacherFormsViewResponses => 'צפה בתגובות';

  @override
  String get teacherFormsNoResponses => 'אין תגובות עדיין.';

  @override
  String get diplomasTitle => 'תעודות';

  @override
  String get diplomasEmpty => 'טרם הונפקו תעודות. הקש + להנפקת תעודה.';

  @override
  String get diplomasIssueTo => 'הנפק עבור';

  @override
  String get diplomasStudentName => 'שם התלמיד';

  @override
  String get diplomasCertificateType => 'סוג התעודה';

  @override
  String get diplomasIssueDiploma => 'הנפק תעודה';

  @override
  String diplomasIssuedOn(Object date) {
    return 'הונפק בתאריך $date';
  }

  @override
  String get examDetailsSection => 'פרטים';

  @override
  String get examInfoTeacher => 'מורה';

  @override
  String get examInfoAudience => 'קהל יעד';

  @override
  String get examInfoDate => 'תאריך';

  @override
  String get examInfoTime => 'שעה';

  @override
  String get examInfoPeriod => 'שיעור';

  @override
  String get examInfoDuration => 'משך';

  @override
  String get examInfoSubject => 'מקצוע';

  @override
  String get examMaterialsSection => 'חומרים מצורפים';

  @override
  String get examNoMaterials => 'אין חומרים מצורפים עדיין.';

  @override
  String get examQuickActionsSection => 'פעולות מהירות';

  @override
  String get examViewGradeTitle => 'צפה בציון שלך';

  @override
  String get examViewGradeBody =>
      'הבחינה הסתיימה. בדוק את הציון שלך בלשונית הציונים.';

  @override
  String get examViewGradeAction => 'פתח ציונים';

  @override
  String get teacherGradesSaveAction => 'שמור';

  @override
  String get teacherGradesNothingToSave => 'אין שינויים לשמירה.';

  @override
  String get teacherRetry => 'נסה שוב';

  @override
  String get teacherExamGradesStudents => 'תלמידים';

  @override
  String get teacherExamGradesGraded => 'מוערכים';

  @override
  String get teacherExamGradesNoStudents =>
      'אין תלמידים ממוקדים.\nערוך את הבחינה כדי להוסיף קהל.';

  @override
  String get teacherExamGradesEnterGrades => 'הזן ציונים';

  @override
  String get teacherDeleteExamTitle => 'מחיקת מבחן?';

  @override
  String get teacherDeleteExamBody => 'המבחן יימחק לצמיתות.';

  @override
  String get teacherMeetingsEmpty => 'אין פגישות עדיין.\nלחץ + לתזמון אחת.';

  @override
  String get teacherStudentsNoMatch => 'אין תלמידים תואמים';

  @override
  String get teacherMaterialsTitle => 'חומרים';

  @override
  String get profileNamesTitle => 'שם בשפות';

  @override
  String get profileDisplayNameLang => 'שפת הצגת שם';

  @override
  String get navDashboard => 'לוח בקרה';

  @override
  String get navPeople => 'משתמשים';

  @override
  String get navCohorts => 'קבוצות';

  @override
  String get navSchool => 'בית ספר';

  @override
  String get adminDashboardTitle => 'סקירת בית הספר';

  @override
  String get adminStudents => 'תלמידים';

  @override
  String get adminTeachers => 'מורים';

  @override
  String get adminParents => 'הורים';

  @override
  String get adminSecretaries => 'מזכירים';

  @override
  String get adminAdmins => 'מנהלים';

  @override
  String get adminTodaySessions => 'שיעורים היום';

  @override
  String get adminQuickActions => 'פעולות מהירות';

  @override
  String get adminAttendanceLast30 => 'נוכחות — 30 ימים אחרונים';

  @override
  String get adminNoAttendanceData => 'אין נתוני נוכחות ל-30 הימים האחרונים.';

  @override
  String get adminAddUser => 'הוסף משתמש';

  @override
  String get adminCreateUser => 'צור';

  @override
  String get adminFullName => 'שם מלא';

  @override
  String get adminEmailAddress => 'כתובת דוא\"ל';

  @override
  String get adminRoleLabel => 'תפקיד';

  @override
  String get adminUserCreated => 'משתמש נוצר';

  @override
  String get adminTempPassword => 'סיסמה זמנית';

  @override
  String get adminCopied => 'הועתק ללוח';

  @override
  String get adminResetPassword => 'אפס סיסמה';

  @override
  String get adminPasswordReset => 'איפוס סיסמה';

  @override
  String adminTempPasswordFor(Object name) {
    return 'סיסמה זמנית עבור $name';
  }

  @override
  String get adminDeleteUser => 'מחק משתמש';

  @override
  String adminDeleteUserConfirm(Object name) {
    return 'למחוק את $name? לא ניתן לבטל.';
  }

  @override
  String get adminDeleteCohort => 'מחק קבוצה';

  @override
  String adminDeleteCohortConfirm(Object name) {
    return 'למחוק \"$name\"? כל חברויות הסטודנטים יוסרו.';
  }

  @override
  String get adminAddCohort => 'הוסף קבוצה';

  @override
  String get adminNewCohort => 'קבוצה חדשה';

  @override
  String get adminCohortName => 'שם הקבוצה (למשל י׳א)';

  @override
  String get adminCohortGrade => 'כיתה';

  @override
  String get adminRenameCohort => 'שנה שם';

  @override
  String get adminAddStudents => 'הוסף תלמידים';

  @override
  String adminAddTo(Object name) {
    return 'הוסף ל-$name';
  }

  @override
  String get adminRemoveStudent => 'הסר תלמיד';

  @override
  String adminRemoveStudentConfirm(Object name, Object cohort) {
    return 'להסיר את $name מ-$cohort?';
  }

  @override
  String get adminNoCohortsYet => 'אין קבוצות עדיין';

  @override
  String get adminNoStudentsInCohort => 'אין תלמידים בקבוצה זו';

  @override
  String adminStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count תלמידים',
      one: 'תלמיד אחד',
    );
    return '$_temp0';
  }

  @override
  String get adminSearchStudents => 'חפש תלמידים…';

  @override
  String get adminScheduleTitle => 'מערכת שעות';

  @override
  String get adminScheduleAddPeriod => 'הוסף שיעור';

  @override
  String get adminScheduleNewPeriod => 'שיעור חדש';

  @override
  String get adminScheduleDayLabel => 'יום';

  @override
  String adminSchedulePeriodLabel(Object period) {
    return 'ש$period';
  }

  @override
  String get adminScheduleTeacherLabel => 'מורה';

  @override
  String get adminScheduleNoneTeacher => 'ללא מורה';

  @override
  String get adminScheduleCohortLabel => 'קבוצה / תלמידים';

  @override
  String get adminScheduleFrequencyLabel => 'תדירות';

  @override
  String get adminScheduleFreqWeekly => 'כל שבוע';

  @override
  String get adminScheduleFreqBiweekly => 'כל שבועיים';

  @override
  String get adminScheduleFreqMonthly => 'כל 4 שבועות';

  @override
  String get adminScheduleFreqCustom => 'מותאם';

  @override
  String adminScheduleFreqCustomLabel(int n) {
    return 'כל $n שבועות';
  }

  @override
  String get adminScheduleAddSlot => 'הוסף משבצת';

  @override
  String get adminScheduleAddAnother => 'הוסף יום / שיעור נוסף';

  @override
  String get adminScheduleSave => 'שמור';

  @override
  String get adminScheduleSearchTeacher => 'חפש מורים…';

  @override
  String get adminScheduleSearchCohort => 'חפש קבוצות…';

  @override
  String get adminScheduleSelectTeacher => 'בחר מורה';

  @override
  String get adminScheduleSelectCohort => 'בחר קבוצה';

  @override
  String get adminScheduleOrStudents => 'או בחר תלמידים בנפרד';

  @override
  String get adminScheduleNoSlots => 'אין שיעורים עדיין';

  @override
  String get adminScheduleNoSlotsHint => 'לחץ + להוספת שיעור ראשון';

  @override
  String get adminSchoolSettingsTitle => 'הגדרות בית הספר';

  @override
  String get adminSchoolName => 'שם בית הספר';

  @override
  String get adminSchoolLogoUrl => 'כתובת לוגו (אופציונלי)';

  @override
  String get adminSchoolLogoHint => 'https://…';

  @override
  String get adminSchoolSaved => 'נשמר';

  @override
  String get adminSubjectsTitle => 'מקצועות';

  @override
  String adminSubjectsGrade(int grade) {
    return 'כיתה $grade';
  }

  @override
  String get adminSubjectsAddHint => 'הוסף מקצוע…';

  @override
  String get adminSubjectsNoSubjects => 'לא הוגדרו מקצועות';

  @override
  String get adminSubjectsAdd => 'הוסף';

  @override
  String get adminSubjectsRemove => 'הסר';

  @override
  String get adminSettingsTitle => 'הגדרות';

  @override
  String get adminSettingsBellSchedule => 'פעמון בית הספר';

  @override
  String get adminSettingsPeriodDefaults => 'ברירות מחדל לשיעורים';

  @override
  String get adminSettingsPeriodDefaultsSubtitle => 'הגדר זמנים לכל שיעור';

  @override
  String get adminDeleteConfirmCancel => 'ביטול';

  @override
  String get adminDeleteConfirmDelete => 'מחק';

  @override
  String get adminSave => 'שמור';

  @override
  String get adminCancel => 'ביטול';

  @override
  String get adminSearchPeople => 'חפש לפי שם…';

  @override
  String adminNoResults(Object query) {
    return 'אין תוצאות עבור \"$query\"';
  }

  @override
  String adminNoPeopleYet(Object role) {
    return 'אין $role עדיין';
  }

  @override
  String get commonRetry => 'נסה שוב';

  @override
  String get commonBack => 'חזור';

  @override
  String get commonClose => 'סגור';

  @override
  String get commonDownload => 'הורד';

  @override
  String get commonOpenExternally => 'פתח חיצונית';

  @override
  String get commonSave => 'שמור';

  @override
  String get commonCancel => 'ביטול';

  @override
  String get commonDone => 'סיום';

  @override
  String get commonDelete => 'מחק';

  @override
  String get commonEdit => 'ערוך';

  @override
  String get commonSearch => 'חיפוש…';

  @override
  String get commonShare => 'שתף';

  @override
  String get commonLoading => 'טוען…';

  @override
  String get commonError => 'משהו השתבש';

  @override
  String get commonTryAgain => 'נסה שוב';

  @override
  String get studentMaterialsTitle => 'חומרים';

  @override
  String get studentMaterialsEmptyTitle => 'אין חומרים שותפו עדיין';

  @override
  String get studentMaterialsEmptyHint => 'המורה ישתף משאבים כאן.';

  @override
  String get studentMaterialsLoadError => 'לא ניתן לטעון את החומרים';

  @override
  String get studentAssignmentSubmittedSnackbar => 'המטלה הוגשה!';

  @override
  String get studentAssignmentSubmitFailed => 'לא ניתן להגיש — נסה שוב.';

  @override
  String get studentAssignmentUploadFailed => 'העלאת הקובץ נכשלה — נסה שוב.';

  @override
  String get studentAssignmentHandedInBadge => 'הוגש';

  @override
  String get studentAssignmentSubmitButton => 'הגשה';

  @override
  String get studentAssignmentSubmitting => 'מגיש…';

  @override
  String get studentAssignmentAttachFile => 'צרף קובץ';

  @override
  String get studentAssignmentAddMoreFiles => 'הוסף קבצים נוספים';

  @override
  String get studentAssignmentYourSubmission => 'ההגשה שלך';

  @override
  String get studentAssignmentTeacherAttachments => 'קבצים מצורפים';

  @override
  String secretaryWelcomeGreeting(Object name) {
    return 'שלום $name 👋';
  }

  @override
  String get secretaryYourTools => 'הכלים שלך';

  @override
  String get secretaryReports => 'דיווחים';

  @override
  String get secretaryExportData => 'ייצוא נתונים';

  @override
  String get secretaryHomeTile => 'בית';

  @override
  String parentHomeGreeting(Object name) {
    return 'שלום $name 👋';
  }

  @override
  String get parentYourTools => 'הכלים שלך';

  @override
  String get parentNoChildLinked => 'אין ילד מקושר עדיין';

  @override
  String get parentPickChildFirst => 'בחר ילד תחילה';

  @override
  String get parentNoApprovedChildren =>
      'אין ילדים מאושרים עדיין. בקש מבית הספר לקשר את חשבונך.';

  @override
  String get loginEmptyFieldsError => 'הזן דוא\"ל או שם משתמש וסיסמה.';

  @override
  String get loginConnectionError => 'אין חיבור. בדוק את האינטרנט ונסה שוב.';

  @override
  String get loginTimeoutError => 'הבקשה נכשלה בגלל פסק זמן. נסה שוב.';

  @override
  String get loginForgotPasswordLink => 'שכחת סיסמה?';

  @override
  String get forgotPasswordTitle => 'איפוס סיסמה';

  @override
  String get forgotPasswordModeEmail => 'דוא\"ל';

  @override
  String get forgotPasswordModeSms => 'SMS';

  @override
  String get forgotPasswordModeAdmin => 'מנהל';

  @override
  String get forgotPasswordEmailSent =>
      'קישור איפוס נשלח (אם נמצא חשבון תואם).';

  @override
  String get forgotPasswordEmptyError => 'הזן דוא\"ל או שם משתמש כדי להמשיך.';

  @override
  String get forgotPasswordEmailButton => 'שלח לי קישור איפוס בדוא\"ל';

  @override
  String get forgotPasswordSmsButton => 'שלח לי קישור איפוס ב-SMS';

  @override
  String get forgotPasswordLinkExpires =>
      'תוקף הקישור יפוג בעוד שעה וניתן לשימוש פעם אחת בלבד.';

  @override
  String get pushPermissionTitle => 'הישאר מעודכן';

  @override
  String get pushPermissionBody =>
      'הפעל התראות כדי שלא תפספס ציונים, הודעות או שינויים במערכת השעות.';

  @override
  String commonRequiredField(Object field) {
    return '$field נדרש';
  }

  @override
  String get commonAttachments => 'קבצים מצורפים';

  @override
  String get commonAttachFile => 'צרף קובץ';

  @override
  String get commonReplaceFile => 'החלף קובץ';

  @override
  String get commonTitleRequired => 'נדרש כותרת';

  @override
  String get commonPublish => 'פרסם';

  @override
  String get commonContinue => 'המשך';

  @override
  String get commonNext => 'הבא';

  @override
  String get commonStart => 'התחלה';

  @override
  String get commonEnd => 'סיום';

  @override
  String get commonRefresh => 'רענן';

  @override
  String get commonRemove => 'הסר';

  @override
  String get commonOpen => 'פתח';

  @override
  String get commonView => 'הצג';

  @override
  String get commonCopy => 'העתק';

  @override
  String get commonAdd => 'הוסף';

  @override
  String get commonOptional => 'אופציונלי';

  @override
  String get commonRequired => 'חובה';

  @override
  String get commonAuto => 'אוטומטי';

  @override
  String get teacherShareButton => 'שתף';

  @override
  String get teacherMaterialDetails => 'פרטי החומר';

  @override
  String get teacherMaterialTitleLabel => 'כותרת *';

  @override
  String get teacherMaterialDescriptionLabel => 'תיאור (אופציונלי)';

  @override
  String get teacherMaterialContentSection => 'תוכן';

  @override
  String get teacherMaterialContentRequired => 'אנא צרף קובץ או הוסף קישור';

  @override
  String teacherFilePickError(Object error) {
    return 'לא ניתן לבחור קובץ: $error';
  }

  @override
  String get teacherScheduleButton => 'תזמן';

  @override
  String get teacherMeetingTitleField => 'כותרת הפגישה *';

  @override
  String get teacherMeetingLinkField => 'קישור לפגישה *';

  @override
  String get teacherMeetingLinkRequired => 'נדרש קישור לפגישה';

  @override
  String get teacherMeetingTitleRequired => 'נדרשת כותרת לפגישה';

  @override
  String get teacherMeetingDateTimeRequired => 'נדרשים תאריך ושעת התחלה';

  @override
  String get teacherMeetingStartDate => 'תאריך התחלה *';

  @override
  String get teacherMeetingStartTime => 'שעת התחלה *';

  @override
  String get teacherMeetingEndDate => 'תאריך סיום (אופציונלי)';

  @override
  String get teacherMeetingEndTime => 'שעת סיום (אופציונלי)';

  @override
  String get teacherClearEndTime => 'נקה שעת סיום';

  @override
  String get teacherAssignmentTitleField => 'כותרת *';

  @override
  String get teacherAssignmentInstructions => 'הוראות (אופציונלי)';

  @override
  String get teacherAssignmentDueDate => 'תאריך הגשה (אופציונלי)';

  @override
  String get teacherAssignmentClearDueDate => 'נקה תאריך הגשה';

  @override
  String get teacherAssignmentMaxGrade => 'ציון מקסימלי (אופציונלי)';

  @override
  String get teacherAssignmentPublished => 'המטלה פורסמה.';

  @override
  String get teacherAssignmentDraftSaved => 'הטיוטה נשמרה.';

  @override
  String get teacherCreateAssignment => 'צור';

  @override
  String get teacherExamSubject => 'מקצוע *';

  @override
  String get teacherExamDate => 'תאריך מבחן *';

  @override
  String get teacherSelectSubject => 'בחר מקצוע';

  @override
  String get teacherNoSubjectOption => 'ללא מקצוע';

  @override
  String get teacherOtherSubjectOption => 'אחר';

  @override
  String get teacherSearchClassrooms => 'חפש כיתות…';

  @override
  String get teacherSearchMaterials => 'חפש חומרים…';

  @override
  String get teacherClassroomName => 'שם הכיתה *';

  @override
  String get adminReportsOpenTab => 'פתוחים';

  @override
  String get adminReportsResolvedTab => 'טופלו';

  @override
  String get adminReportsDismissedTab => 'נדחו';

  @override
  String get adminReportsNoOpen => 'אין דיווחים פתוחים';

  @override
  String get adminReportsNoInView => 'אין דיווחים בתצוגה זו';

  @override
  String get adminReportsMediaAttachment => '[קובץ מדיה]';

  @override
  String get adminReportsEmptyMessage => '(הודעה ריקה)';

  @override
  String get adminReportsDismiss => 'דחה';

  @override
  String get adminReportsResolve => 'טפל';

  @override
  String adminReportsReason(Object reason) {
    return 'סיבה: $reason';
  }

  @override
  String get chatReportTitle => 'דווח על הודעה';

  @override
  String get chatReportButton => 'דווח';

  @override
  String get chatReportSuccess => 'הדיווח התקבל. תודה — מנהל יבדוק.';

  @override
  String chatReportFailed(Object error) {
    return 'הדיווח נכשל: $error';
  }

  @override
  String chatSendError(Object message) {
    return 'לא ניתן לשלוח: $message';
  }

  @override
  String chatForwardLabel(Object count) {
    return 'העבר $count';
  }

  @override
  String chatDeleteLabel(Object count) {
    return 'מחק $count';
  }

  @override
  String chatSelectedCount(Object count) {
    return '$count נבחרו';
  }

  @override
  String get adminPasswordReqEmpty => 'אין בקשות ממתינות';

  @override
  String get adminPasswordReqExplainer =>
      'משתמשים שאישרת או דחית לא יופיעו כאן. בקשות ממתינות פגות לאחר 24 שעות.';

  @override
  String get adminPasswordReqApproveTitle => 'לאשר שינוי סיסמה?';

  @override
  String adminPasswordReqApproveExplain(Object name) {
    return 'פעולה זו תגדיר את הסיסמה של $name לזו שהוא הקליד (אתה לא רואה אותה).';
  }

  @override
  String adminPasswordReqVerifyWarning(Object name) {
    return 'אשר רק לאחר שאימתת שמגיש הבקשה הוא באמת $name — התקשר אליו או אמת אישית. כל מי שיודע שם משתמש יכול להגיש בקשה כזו.';
  }

  @override
  String get adminPasswordReqConfirmApprove => 'אימתתי — אשר';

  @override
  String adminPasswordReqApproveSnackbar(Object name) {
    return 'אושר — $name יכול להתחבר עכשיו.';
  }

  @override
  String get adminPasswordReqRejectTitle => 'לדחות שינוי סיסמה?';

  @override
  String adminPasswordReqRejectExplain(Object name) {
    return 'הסיסמה של $name לא תשתנה. הוא יכול להגיש בקשה חדשה במידת הצורך.';
  }

  @override
  String get adminPasswordReqRejectSnackbar => 'נדחה.';

  @override
  String get adminPasswordReqRejectButton => 'דחה';

  @override
  String get adminPasswordReqApproveButton => 'אשר';

  @override
  String get adminPasswordReqCardCopy =>
      'מעוניין בשינוי סיסמה. הסיסמה החדשה מוסתרת.';

  @override
  String get adminPasswordReqCallTooltip => 'התקשר';

  @override
  String get adminPasswordReqSmsTooltip => 'SMS';

  @override
  String get adminSetupSchoolSetup => 'הגדרת בית הספר';

  @override
  String get adminSetupComplete =>
      'הכול מוכן. הקש על כל פריט כדי לחזור אליו או לעדכן.';

  @override
  String get adminSetupInstructions =>
      'השלם שלבים אלה כדי להגדיר את בית הספר במלואו.';

  @override
  String get adminSetupLogoTitle => 'העלאת לוגו בית הספר';

  @override
  String get adminSetupLogoSubtitle => 'מופיע בכותרות ובתפריט הצדדי';

  @override
  String get adminSetupNameTitle => 'הגדרת שם בית הספר';

  @override
  String get adminSetupNameSubtitle => 'מוצג לתלמידים, מורים והורים';

  @override
  String get adminSetupSubjectsTitle => 'הגדרת מקצועות';

  @override
  String get adminSetupSubjectsSubtitle => 'לפחות שכבה אחת עם מקצועות מוגדרים';

  @override
  String get adminSetupBellTitle => 'הגדרת מערכת שעות';

  @override
  String get adminSetupBellSubtitle => 'שעות התחלה וסיום לכל שיעור';

  @override
  String get adminSetupCohortsTitle => 'יצירת קבוצות';

  @override
  String get adminSetupCohortsSubtitle => 'הגדר את קבוצות הכיתות שלך';

  @override
  String get adminSetupStudentsTitle => 'הוספת תלמידים';

  @override
  String get adminSetupStudentsSubtitle => 'צור חשבונות או הפק קודי הצטרפות';

  @override
  String get adminSetupTeachersTitle => 'הוספת מורים';

  @override
  String get adminSetupTeachersSubtitle => 'צור חשבונות למורים';

  @override
  String get supportContactTitle => 'דבר איתנו';

  @override
  String get supportContactDescription =>
      'לא מצאת את התשובה למטה? צור קשר ונחזור אליך תוך יום עסקים.';

  @override
  String get supportEmailLabel => 'דוא\"ל';

  @override
  String get supportPhoneLabel => 'טלפון';

  @override
  String get supportSmsLabel => 'הודעה';

  @override
  String get aboutWhatIsClassmate => 'מהו ClassMate?';

  @override
  String get aboutClassmateDescription =>
      'ClassMate הוא מערכת ההפעלה של בית הספר עבור תלמידים, מורים, מנהלים והורים. אפליקציה אחת, ארבעה תפקידים, וכל היבט של יום הלימודים במקום אחד — מערכת שעות, נוכחות, ציונים, כיתות, מטלות, הודעות, ושותף לימוד מבוסס בינה מלאכותית.';

  @override
  String get aboutMultilingualTitle => 'בנוי לבתי ספר שמדברים יותר משפה אחת';

  @override
  String get aboutMultilingualDescription =>
      'כל שם, מקצוע והודעה יכולים לשאת עד חמש שפות (אנגלית, ערבית, עברית, צרפתית, רוסית). תלמידים רואים את השפה הנוחה להם; מורים מנהלים בשפה שלהם.';

  @override
  String get aboutPrivacyTitle => 'פרטיות תחילה';

  @override
  String get aboutPrivacyDescription =>
      'נתוני בית הספר נשארים בתוך בית הספר. תפקידים תואמים את מה שכל אחד יכול לראות — מורים רואים את הכיתות שלהם, מנהלים רואים את בית ספרם, הורים רואים את ילדיהם. ללא מעקב צד שלישי וללא רשתות פרסום.';

  @override
  String get aboutContactTitle => 'צור קשר';

  @override
  String get aboutContactDescription =>
      'נבנה על ידי Tony Aboud וצוות ClassMate.\nשאלות: tony@classmateapp.org';

  @override
  String aboutVersionLabel(Object version) {
    return 'ClassMate · גרסה $version';
  }

  @override
  String get adminAddStudent => 'הוסף תלמיד';

  @override
  String get adminAddTeacher => 'הוסף מורה';

  @override
  String get adminAddParent => 'הוסף הורה';

  @override
  String get adminAddSecretary => 'הוסף מזכיר/ה';

  @override
  String get adminAddAdmin => 'הוסף מנהל';

  @override
  String get adminEditUser => 'ערוך משתמש';

  @override
  String get adminNoEmailPlaceholder => '(אין דוא\"ל)';

  @override
  String get adminNameEnglishRequired => 'נדרש שם מלא (באנגלית)';

  @override
  String get adminUsernameRequired => 'נדרש שם משתמש';

  @override
  String get adminPasswordMinLength =>
      'הסיסמה חייבת להיות בת 8 תווים לפחות (או השאר ריק לייצור אוטומטי)';

  @override
  String adminUserCreatedMsg(Object name) {
    return '$name נוצר.';
  }

  @override
  String get adminCredsUsername => 'שם משתמש';

  @override
  String get adminCredsEmail => 'דוא\"ל';

  @override
  String get adminCredsPassword => 'סיסמה';

  @override
  String get adminShareCredsHint => 'שתף את פרטי הגישה עם התלמיד.';

  @override
  String get adminCopyCredsButton => 'העתק הכול';

  @override
  String get adminGradeLabel => 'שכבה';

  @override
  String adminCohortGradeFormat(Object grade) {
    return 'שכבה $grade';
  }

  @override
  String get adminCreateAndAddStudents => 'צור והוסף תלמידים';

  @override
  String get adminAddStudentsTitle => 'הוספת תלמידים';

  @override
  String get adminSkipAdding => 'דלג';

  @override
  String get adminInCohortBadge => 'בקבוצה';

  @override
  String get adminNoStudentsFoundCohort =>
      'לא נמצאו תלמידים בשכבות של קבוצה זו';

  @override
  String get adminScheduleByCohort => 'לפי קבוצה ▾';

  @override
  String get adminScheduleByStudent => 'לפי תלמיד ▾';

  @override
  String get adminScheduleByGrade => 'לפי כיתה ▾';

  @override
  String get navSupport => 'תמיכה';

  @override
  String get navAbout => 'אודות';

  @override
  String get adminScheduleAddGrade => 'הוסף שכבה';

  @override
  String get adminScheduleAddCohort => 'הוסף קבוצה';

  @override
  String get adminScheduleAddStudent => 'הוסף תלמיד';

  @override
  String get adminScheduleClearFilters => 'נקה';

  @override
  String get adminSchedulePickSubjectRequired => 'בחר מקצוע לפני שמירת השיעור.';

  @override
  String get adminSchedulePickDateOnce => 'בחר תאריך לשיעור חד-פעמי.';

  @override
  String adminSchedulePickDateRecurring(Object freq) {
    return 'בחר תאריך התחלה ללוז של כל $freq שבועות.';
  }

  @override
  String get adminSchoolLogoLabel => 'לוגו בית הספר';

  @override
  String get adminSchoolLogoUploaded => 'הלוגו הועלה';

  @override
  String get adminSchoolNoLogoYet => 'אין לוגו עדיין';

  @override
  String get adminSchoolLogoDescription =>
      'מופיע ליד שם בית הספר בתפריט הצדדי.';

  @override
  String get adminSchoolLogoChange => 'החלף';

  @override
  String get adminSchoolLogoUpload => 'העלה';

  @override
  String get adminSchoolLogoRemove => 'הסר';

  @override
  String get adminSchoolGradeRangeLabel => 'טווח שכבות';

  @override
  String get adminSchoolGradeRangeDescription =>
      'שכבות זמינות בקבוצות, תלמידים ובתפריטים.';

  @override
  String get adminSchoolLowestGrade => 'נמוכה ביותר';

  @override
  String get adminSchoolHighestGrade => 'גבוהה ביותר';

  @override
  String get adminSchoolSubjectsTitle => 'מקצועות בית הספר';

  @override
  String get adminSchoolSubjectsDescription =>
      'זמינים לכל המורים בעת יצירת מטלות.';

  @override
  String get adminSchoolNoTranslations => 'הקש להוספת תרגומים';

  @override
  String get adminSchoolBellHint =>
      'הגדר שעות התחלה וסיום לכל שיעור. הוסף או הסר שיעורים לפי הצורך.';

  @override
  String get adminSchoolBellTitle => 'לוח צלצולים';

  @override
  String get adminSchoolBellInfo =>
      'הגדר את שעות ההתחלה והסיום לכל שיעור. אלו הופכות לשעות ברירת המחדל לבניית המערכת השבועית.';

  @override
  String get adminSchoolStartTime => 'התחלה';

  @override
  String get adminSchoolEndTime => 'סיום';

  @override
  String get adminExportStudentsTab => 'תלמידים';

  @override
  String get adminExportCohortsTab => 'קבוצות';

  @override
  String get adminExportGradesTab => 'שכבות';

  @override
  String get adminExportOptionsTitle => 'אפשרויות ייצוא';

  @override
  String get adminExportIncludePasswords => 'כלול סיסמאות';

  @override
  String get adminExportLanguageLabel => 'שפת השמות בייצוא';

  @override
  String get adminExportCsvButton => 'ייצא CSV';

  @override
  String get adminExportPdfButton => 'ייצא PDF';

  @override
  String get teacherCreateClassroomTooltip => 'יצירת כיתה';

  @override
  String get teacherClassroomNameRequired => 'שם הכיתה *';

  @override
  String get teacherSubjectRequired => 'מקצוע *';

  @override
  String messagesStartChatError(Object error) {
    return 'לא ניתן להתחיל צ\'אט: $error';
  }

  @override
  String messagesNoPeopleMatch(Object query) {
    return 'אין אנשים שתואמים ל-\"$query\"';
  }

  @override
  String get messagesNoPeopleFound => 'לא נמצאו אנשים';

  @override
  String messagesPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count אנשים',
      one: 'אדם אחד',
    );
    return '$_temp0';
  }

  @override
  String get studentAssignmentValidationRequired =>
      'הוסף הערה או צרף קובץ לפני ההגשה.';

  @override
  String get studentFormSubmittedBanner => 'התשובות שהגשת';

  @override
  String studentFormSubmitError(Object error) {
    return 'לא ניתן להגיש: $error';
  }

  @override
  String studentFormFieldRequired(Object field) {
    return 'חובה: $field';
  }

  @override
  String get studentFormClosedButton => 'הטופס סגור';

  @override
  String get studentFormAlreadySubmittedButton => 'כבר הוגש';

  @override
  String get studentDiplomaEditTitle => 'ערוך תעודה';

  @override
  String get studentDiplomaDeleteTitle => 'למחוק תעודה?';

  @override
  String studentDiplomaDeleteConfirm(Object name) {
    return 'להסיר את התעודה של \"$name\"?';
  }

  @override
  String teacherDeleteItemConfirm(Object title) {
    return 'למחוק את \"$title\"?';
  }

  @override
  String get teacherPublishTooltip => 'פרסם';

  @override
  String get teacherMeetingEnterTitle => 'אנא הזן כותרת.';

  @override
  String get teacherMeetingEnterLink => 'אנא הזן קישור לפגישה.';

  @override
  String get teacherMeetingEnterValidUrl =>
      'אנא הזן כתובת תקינה (לדוגמה https://zoom.us/j/...)';

  @override
  String get teacherMeetingPickStartTime => 'אנא בחר שעת התחלה.';

  @override
  String get teacherMeetingVisibleToEveryone => 'גלוי לכולם';

  @override
  String teacherMeetingDoneCount(int count) {
    return 'סיום ($count נבחרו)';
  }

  @override
  String get teacherDeleteAssignmentTitle => 'למחוק את המטלה?';

  @override
  String get teacherDeleteAssignmentBody =>
      'פעולה זו תמחק את המטלה ואת כל ההגשות לצמיתות.';

  @override
  String get teacherEditTooltip => 'ערוך';

  @override
  String get teacherDeleteTooltip => 'מחק';

  @override
  String get teacherClassroomBackTooltip => 'חזרה';

  @override
  String teacherClassroomGenericError(Object error) {
    return 'שגיאה: $error';
  }

  @override
  String teacherClassroomAttachFailed(Object error) {
    return 'צירוף נכשל: $error';
  }

  @override
  String get teacherClassroomFileUnavailable =>
      'הקובץ אינו זמין — המורה צריך להעלות אותו מחדש.';

  @override
  String get teacherClassroomCodeLabel => 'קוד הכיתה';

  @override
  String get teacherClassroomCodeCopied => 'הקוד הועתק';

  @override
  String get teacherClassroomCopyCodeTooltip => 'העתק קוד';

  @override
  String teacherClassroomCouldNotAdd(Object emails) {
    return 'לא ניתן להוסיף: $emails — בדוק את כתובת הדוא\"ל שלהם.';
  }

  @override
  String get teacherClassroomAddStudents => 'הוספת תלמידים';

  @override
  String get teacherClassroomSearchNameGrade => 'חפש לפי שם או שכבה…';

  @override
  String get teacherClassroomNoStudentsFound => 'לא נמצאו תלמידים';

  @override
  String get teacherClassroomNameSubjectRequired => 'שם ומקצוע נדרשים.';

  @override
  String get teacherClassroomCreated => 'הכיתה נוצרה!';

  @override
  String get teacherCustomSubjectLabel => 'מקצוע מותאם *';

  @override
  String get teacherCreateClassroomButton => 'צור כיתה';

  @override
  String get teacherCreateFormTitle => 'יצירת טופס';

  @override
  String get teacherFormSaveDraft => 'שמור טיוטה';

  @override
  String get teacherFormTitleHint => 'כותרת הטופס *';

  @override
  String get teacherFormDescriptionHint => 'תיאור (אופציונלי)';

  @override
  String get teacherFormAcceptingResponses => 'מקבל תגובות';

  @override
  String get teacherFormAllowMultiple => 'אפשר תגובות מרובות';

  @override
  String get teacherFormAllowMultipleSubtitle =>
      'כבוי = פעם אחת לתלמיד (ברירת מחדל)';

  @override
  String get teacherFormQuestionsSection => 'שאלות';

  @override
  String get teacherFormAddQuestionButton => 'הוסף שאלה';

  @override
  String teacherFormQuestionPlaceholder(Object index) {
    return 'שאלה $index';
  }

  @override
  String get teacherFormRequiredToggle => 'חובה';

  @override
  String get teacherFormAddOptionButton => 'הוסף אפשרות';

  @override
  String get teacherFormMinLabel => 'מינ\'';

  @override
  String get teacherFormMaxLabel => 'מקס\'';

  @override
  String get teacherFormEnterTitle => 'אנא הזן כותרת לטופס.';

  @override
  String teacherExamUploadFailedSkipped(Object name) {
    return 'העלאה נכשלה עבור $name. הקובץ דולג.';
  }

  @override
  String get teacherExamEnterTitle => 'אנא הזן כותרת.';

  @override
  String get teacherExamPickDate => 'אנא בחר תאריך מבחן.';

  @override
  String get teacherExamSelectSubject => 'אנא בחר מקצוע.';

  @override
  String teacherSlotDetachFailed(Object error) {
    return 'ניתוק נכשל: $error';
  }

  @override
  String teacherSlotAttachFailed(Object error) {
    return 'צירוף נכשל: $error';
  }

  @override
  String get teacherSlotAttachMaterial => 'צרף חומר';

  @override
  String get teacherSlotDetachTooltip => 'נתק';

  @override
  String get teacherDiplomaSelectStudent => 'בחר תלמיד תחילה.';

  @override
  String get teacherDiplomaUploadingWait => 'אנא המתן — קבצים עדיין מועלים.';

  @override
  String teacherDiplomaIssueFailed(Object error) {
    return 'לא ניתן להנפיק תעודה: $error';
  }

  @override
  String get teacherDiplomaCertTitleLabel => 'כותרת התעודה';

  @override
  String get teacherDiplomaSearchStudent => 'חפש תלמיד…';

  @override
  String get teacherProfileChatError => 'לא ניתן להתחיל צ\'אט';

  @override
  String get teacherGradeAssignmentType => 'מטלה';

  @override
  String get teacherGradeExamType => 'מבחן';

  @override
  String get teacherGradeOtherType => 'אחר';

  @override
  String get teacherGradeOutOfLabel => 'מתוך (אופציונלי)';

  @override
  String get teacherGradePublishedTitle => 'פורסם';

  @override
  String get teacherGradePublishedSubtitle => 'תלמידים יכולים לראות ציון זה';

  @override
  String get teacherMaterialPickSubject => 'אנא בחר מקצוע.';

  @override
  String get teacherMaterialAddLink => 'הוסף קישור';

  @override
  String get teacherMaterialAddFile => 'הוסף קובץ';

  @override
  String get teacherMaterialSearchStudentsGrade => 'חפש תלמידים או שכבה...';

  @override
  String teacherMaterialDoneSelected(int count) {
    return 'סיום ($count נבחרו)';
  }

  @override
  String get adminSubjectEnglishNameRequired => 'שם באנגלית נדרש';

  @override
  String adminSubjectNameInLang(Object language) {
    return 'שם ב$language';
  }

  @override
  String get adminSubjectResetButton => 'אפס';

  @override
  String get teacherAnnounceBroadcastTitle => 'לשלוח לכולם?';

  @override
  String get teacherAnnounceSendToEveryone => 'שלח לכולם';

  @override
  String get teacherAnnounceNoCohorts => 'אין קבוצות זמינות';

  @override
  String get teacherAnnounceNothingFound => 'לא נמצא דבר';

  @override
  String get teacherAnnounceNoParents => 'לא נמצאו הורים בבית ספר זה.';

  @override
  String get teacherGradesToGrade => 'לציון';

  @override
  String get teacherGradesGraded => 'צוין';

  @override
  String get teacherSaveGradesButton => 'שמור ציונים';

  @override
  String get teacherAllowResubmitLabel => 'אפשר הגשה חוזרת';

  @override
  String get teacherAllowResubmitTitle => 'לאפשר הגשה חוזרת?';

  @override
  String teacherAllowResubmitBody(Object name) {
    return 'פעולה זו תמחק את ההגשה של $name כדי שיוכל להגיש שוב.';
  }

  @override
  String get teacherAllowButton => 'אפשר';

  @override
  String get teacherGradeFieldLabel => 'ציון';

  @override
  String get teacherFeedbackOptionalLabel => 'משוב (אופציונלי)';

  @override
  String get teacherCreateClassroomFabLabel => 'צור';

  @override
  String get teacherLoadingStudents => 'טוען תלמידים…';

  @override
  String get teacherSearchHintShort => 'חיפוש…';

  @override
  String get teacherCreateClassroomTitle => 'כיתה חדשה';

  @override
  String teacherAssignmentUploadFailed(Object name) {
    return 'לא ניתן להעלות את $name';
  }

  @override
  String get teacherAssignmentEnterTitle => 'אנא הזן כותרת.';

  @override
  String get teacherAssignmentSelectSubject => 'אנא בחר מקצוע.';

  @override
  String get teacherAssignmentInstructionsLabel => 'הוראות / תיאור';

  @override
  String get teacherAttachFilesButton => 'צרף קבצים';

  @override
  String get tutorDeleteConversationTitle => 'למחוק שיחה?';

  @override
  String get tutorDeleteConversationButton => 'מחק לצמיתות';

  @override
  String tutorDeleteFailed(Object error) {
    return 'לא ניתן למחוק: $error';
  }

  @override
  String get tutorDeleteMenuTitle => 'מחק שיחה';

  @override
  String get tutorDeleteMenuSubtitle => 'מוחק לצמיתות מהשרת';

  @override
  String get accountVerifyButton => 'אמת';

  @override
  String get accountConfirmButton => 'אשר';

  @override
  String get accountResendCode => 'שלח קוד מחדש';

  @override
  String get accountCodeResent => 'נשלח קוד חדש.';

  @override
  String get accountContinueButton => 'המשך';

  @override
  String get studentClassroomFileUnavailable => 'הקובץ אינו זמין כעת.';

  @override
  String get studentClassroomDeleteMaterial => 'למחוק חומר?';

  @override
  String get studentClassroomCodeLabel => 'קוד הכיתה';

  @override
  String get studentClassroomLeaveTooltip => 'עזוב כיתה';

  @override
  String get adminEditUserEnglishNameRequired => 'שם באנגלית נדרש';

  @override
  String get adminEditUserSaved => 'נשמר';

  @override
  String adminEditUserPasswordChanged(Object name) {
    return 'הסיסמה של $name שונתה.';
  }

  @override
  String get adminEditUserLoginSection => 'התחברות';

  @override
  String get adminEditUserUsernameLabel => 'שם משתמש';

  @override
  String get adminEditUserEmailOptional => 'דוא\"ל (אופציונלי)';

  @override
  String get adminEditUserChangePassword => 'שנה סיסמה';

  @override
  String get adminEditUserNameSection => 'שם';

  @override
  String get adminEditUserAtLeastEnglish => 'אנגלית נדרשת לפחות.';

  @override
  String get adminEditUserGradeSection => 'שכבה';

  @override
  String get adminEditUserCohortsSection => 'קבוצות';

  @override
  String get adminEditUserLinkedChildren => 'ילדים מקושרים';

  @override
  String get adminEditUserLinkButton => 'קשר';

  @override
  String get adminEditUserNoChildren => 'לא קושרו ילדים עדיין.';

  @override
  String get adminEditUserSetPasswordTitle => 'הגדרת סיסמה חדשה';

  @override
  String get adminEditUserNewPasswordLabel => 'סיסמה חדשה';

  @override
  String get adminEditUserConfirmPasswordLabel => 'אישור סיסמה';

  @override
  String get adminEditUserSetPasswordButton => 'הגדר סיסמה';

  @override
  String get adminPeriodsTitle => 'ניהול שיעורים';

  @override
  String get adminPeriodsAddPeriod => 'הוסף שיעור';

  @override
  String get adminPeriodsNoPeriods => 'אין שיעורים עדיין';

  @override
  String get adminPeriodsTapToAdd => 'הקש + להוספת השיעור הראשון';

  @override
  String get adminPeriodsNewPeriod => 'שיעור חדש';

  @override
  String get adminPeriodsDayLabel => 'יום';

  @override
  String get adminPeriodsPeriodLabel => 'שיעור';

  @override
  String get adminPeriodsTimeLabel => 'שעה';

  @override
  String get adminPeriodsTeacherLabel => 'מורה';

  @override
  String get adminPeriodsClassroomOptional => 'כיתה (אופציונלי)';

  @override
  String get adminPeriodsCohortsLabel => 'קבוצות';

  @override
  String get adminPeriodsStudentsOptional => 'תלמידים (אופציונלי)';

  @override
  String get adminPeriodsSearchByName => 'חפש לפי שם…';

  @override
  String commonErrorWith(Object error) {
    return 'שגיאה: $error';
  }

  @override
  String commonAddCount(int count) {
    return 'הוסף $count';
  }

  @override
  String get teacherStudentGradesSaved => 'הציונים נשמרו';

  @override
  String get teacherStudentToGrade => 'לציון';

  @override
  String get teacherStudentGraded => 'צוין';

  @override
  String get classroomFileNotAvailable => 'הקובץ עדיין לא זמין.';

  @override
  String get classroomDeleteMaterialTitle => 'למחוק חומר?';

  @override
  String get classroomCodeLabel => 'קוד כיתה';

  @override
  String get plansCouldNotOpenSubscription => 'לא ניתן לפתוח את הגדרות המנוי.';

  @override
  String plansFailedToOpen(Object error) {
    return 'הפתיחה נכשלה: $error';
  }

  @override
  String get plansManageSubscription => 'נהל או בטל מנוי';

  @override
  String get plansUpgrade => 'שדרג';

  @override
  String get plansTryAgain => 'נסה שוב';

  @override
  String adminCohortsGradeOnly(String grade) {
    return 'כיתה $grade בלבד';
  }

  @override
  String adminCohortsGradeRangeOnly(int from, int to) {
    return 'כיתות $from-$to בלבד';
  }

  @override
  String get adminExportNeedStudents => 'בחר לפחות תלמיד או קבוצה אחת';

  @override
  String adminExportButton(int count) {
    return 'ייצא $count';
  }

  @override
  String get adminExportNoStudents => 'לא נמצאו תלמידים';

  @override
  String get adminExportIncludesPasswords => 'הייצוא יכלול סיסמאות';

  @override
  String get adminExportAnyway => 'ייצא בכל זאת';

  @override
  String get adminExportPdfStudentDirectory => 'ספריית תלמידים';

  @override
  String adminExportPdfBy(String name) {
    return 'ע\"י: $name';
  }

  @override
  String adminExportPdfStudentsCount(int count) {
    return '$count תלמידים';
  }

  @override
  String get adminExportPdfFooter => 'נוצר על ידי ClassMate';

  @override
  String get adminExportColumnIndex => '#';

  @override
  String get adminExportColumnName => 'שם';

  @override
  String get adminExportColumnEmail => 'דוא\"ל';

  @override
  String get adminExportColumnUsername => 'שם משתמש';

  @override
  String get adminExportColumnPhone => 'טלפון';

  @override
  String get adminExportColumnGrade => 'כיתה';

  @override
  String get adminExportColumnCohorts => 'קבוצות';

  @override
  String get adminExportColumnSchool => 'בית ספר';

  @override
  String get adminExportColumnPassword => 'סיסמה';

  @override
  String get adminExportColumnNameEn => 'שם (EN)';

  @override
  String get adminExportColumnNameAr => 'שם (AR)';

  @override
  String get adminExportColumnNameHe => 'שם (HE)';

  @override
  String get adminExportColumnNameFr => 'שם (FR)';

  @override
  String get adminExportColumnNameRu => 'שם (RU)';

  @override
  String adminExportStudentsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count תלמידים נבחרו',
      one: 'תלמיד אחד נבחר',
    );
    return '$_temp0';
  }

  @override
  String get teacherMaterialEditTitle => 'ערוך חומר';

  @override
  String get teacherMaterialAddTitle => 'הוסף חומר';

  @override
  String get teacherMaterialAudienceTitle => 'קהל';

  @override
  String get teacherMaterialAudienceClassrooms => 'כיתות';

  @override
  String get teacherMaterialAudienceCohorts => 'קבוצות';

  @override
  String get teacherMaterialAudienceGrades => 'כיתות';

  @override
  String get teacherMaterialAudienceStudents => 'תלמידים';

  @override
  String get teacherMaterialDetailsTitle => 'פרטים';

  @override
  String get teacherMaterialSubjectRequired => 'מקצוע *';

  @override
  String get teacherMaterialSubjectSelect => 'בחר מקצוע';

  @override
  String get teacherMaterialSubjectOther => 'אחר';

  @override
  String get teacherMaterialSubjectSearch => 'חפש מקצועות...';

  @override
  String get teacherMaterialAttachmentsTitle => 'קבצים מצורפים';

  @override
  String teacherMaterialAttachmentsWithCount(int count) {
    return 'קבצים מצורפים ($count)';
  }

  @override
  String get teacherMaterialDeleteTitle => 'למחוק חומר?';

  @override
  String get teacherMaterialListTitle => 'חומרים';

  @override
  String teacherMaterialTotalCount(int count) {
    return '$count סה\"כ';
  }

  @override
  String get teacherMaterialRetry => 'נסה שוב';

  @override
  String get teacherMaterialNoMaterials =>
      'אין חומרים עדיין.\nלחץ + כדי להוסיף.';

  @override
  String get teacherMaterialPublished => 'פורסם';

  @override
  String get teacherMaterialDraft => 'טיוטה';

  @override
  String get teacherMaterialSearchHint => 'חיפוש…';

  @override
  String teacherMaterialSelectedCount(int count) {
    return '$count נבחרו';
  }

  @override
  String teacherMaterialMembersWillReceive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count חברים יקבלו את זה',
      one: 'חבר אחד יקבל את זה',
    );
    return '$_temp0';
  }

  @override
  String teacherMaterialStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count תלמידים',
      one: 'תלמיד אחד',
    );
    return '$_temp0';
  }

  @override
  String get teacherMaterialPickerNone => 'ללא';

  @override
  String get teacherMaterialPickerCohortsTitle => 'בחר קבוצות';

  @override
  String get teacherMaterialPickerClassroomTitle => 'בחר כיתה';

  @override
  String get teacherMaterialPickerStudentsTitle => 'בחר תלמידים';

  @override
  String get teacherMaterialPickerGradesTitle => 'בחר כיתות';

  @override
  String get adminScheduleAddNew => 'הוסף חדש';

  @override
  String adminScheduleAddCount(int count) {
    return 'הוסף ($count)';
  }

  @override
  String get adminScheduleCaptionOptional => 'כותרת (אופציונלי)';

  @override
  String get adminScheduleCaptionHint => 'למשל: חזרה למבחן';

  @override
  String get adminScheduleAudienceCohorts => 'קבוצות';

  @override
  String get adminScheduleAudienceStudents => 'תלמידים';

  @override
  String get adminScheduleAudienceGrade => 'כיתה';

  @override
  String get adminScheduleSearchStudents => 'חפש תלמידים…';

  @override
  String get adminScheduleSearchSubjects => 'חפש מקצועות בית הספר…';

  @override
  String get adminScheduleEveryPrefix => 'כל ';

  @override
  String get adminScheduleWeeksSuffix => ' שבועות';

  @override
  String adminScheduleSlotN(int index) {
    return 'משבצת $index';
  }

  @override
  String adminScheduleSelectedCount(int count) {
    return '$count נבחרו';
  }

  @override
  String get adminScheduleConflictingPeriod => 'שיעור מתנגש';

  @override
  String get adminScheduleKeepCurrent => 'השאר נוכחי';

  @override
  String get adminScheduleOverride => 'החלף';

  @override
  String get adminScheduleShowBoth => 'הצג את שניהם';

  @override
  String get adminScheduleDeletePeriodTitle => 'למחוק שיעור?';

  @override
  String get adminScheduleDeletePeriodBody =>
      'זה מסיר את המשבצת מהמערכת. נוכחות עבר נשארת.';

  @override
  String get adminScheduleFailedToDelete => 'מחיקת השיעור נכשלה.';

  @override
  String get adminSchedulePickSubjectFirst => 'בחר מקצוע לפני שמירת השיעור.';

  @override
  String adminScheduleOverrideFailed(Object error) {
    return 'ההחלפה נכשלה: $error';
  }

  @override
  String get adminScheduleFailedToCreateSlots => 'יצירת המשבצות נכשלה';

  @override
  String adminScheduleCreatedSlots(int created, int total, String error) {
    return 'נוצרו $created/$total משבצות. $error';
  }

  @override
  String adminScheduleSavedLabelOnlyError(Object error) {
    return 'נשמר ככותרת בלבד — לא ניתן היה להוסיף לספריה: $error';
  }

  @override
  String get adminScheduleSavedLabelPickAudience =>
      'נשמר ככותרת. בחר תחילה קהל כדי להוסיף גם לספריית בית הספר.';

  @override
  String get commonNothingFound => 'לא נמצא דבר';

  @override
  String commonDownloadFailed(Object error) {
    return 'ההורדה נכשלה: $error';
  }

  @override
  String commonFailedWith(Object error) {
    return 'נכשל: $error';
  }

  @override
  String get commonCreate => 'צור';

  @override
  String get commonAttachStudyMaterials => 'צרף חומרי לימוד';

  @override
  String get teacherCreateClassroomNewTitle => 'כיתה חדשה';

  @override
  String get teacherCreateClassroomLoadingStudents => 'טוען תלמידים…';

  @override
  String get teacherExamPublishedHint => 'פורסם — תלמידים יכולים לראות מבחן זה';

  @override
  String teacherDoneSelected(int count) {
    return 'בוצע ($count נבחרו)';
  }

  @override
  String get secretaryAllCohorts => 'כל הקבוצות';

  @override
  String get secretaryClassrooms => 'כיתות';

  @override
  String get adminPasswordReqTitle => 'בקשות סיסמה';

  @override
  String get adminPasswordReqBlurb =>
      'משתמשים מבית הספר שלך שביקשו את אישורך לשינוי סיסמה.';

  @override
  String adminPasswordReqWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count משתמשים ממתינים לאישור שלך.',
      one: 'משתמש אחד ממתין לאישור שלך.',
    );
    return '$_temp0';
  }

  @override
  String get adminPasswordReqWantsChange =>
      'רוצה לשנות את הסיסמה. הסיסמה החדשה מוסתרת.';

  @override
  String get adminPasswordReqReject => 'דחה';

  @override
  String get adminPasswordReqApprove => 'אשר';

  @override
  String get adminPeopleGrade => 'כיתה';

  @override
  String get adminSchoolSettingsTapToAddTranslations => 'לחץ להוספת תרגומים';

  @override
  String adminSchoolSettingsAddPeriodNum(int num) {
    return 'הוסף שיעור (P$num)';
  }

  @override
  String get adminVisibleToEveryone => 'גלוי לכולם';

  @override
  String get navMaterials => 'חומרי לימוד';

  @override
  String get navPlans => 'תוכניות NOVA';

  @override
  String get navReports => 'דיווחים';

  @override
  String get navExportData => 'יצוא נתונים';

  @override
  String get navPasswordRequests => 'בקשות סיסמה';

  @override
  String get sectionSecretaryTools => 'כלי מזכירות';

  @override
  String get sectionSchoolToolsLabel => 'כלי בית הספר';

  @override
  String get sectionAdminTools => 'כלי מנהל';

  @override
  String get chatVideoTrimTitle => 'קיצוץ סרטון';

  @override
  String get chatMediaPreviewTrimAction => 'קצוץ';

  @override
  String get commonUntitled => 'ללא כותרת';

  @override
  String get plansMonthlyPlans => 'תוכניות חודשיות';

  @override
  String get plansTokenTopups => 'חבילות אסימונים';

  @override
  String get plansTopupsSubtitle =>
      'רכישות חד-פעמיות. לא פגות. נצברות מעל לתוכנית שלך.';

  @override
  String get plansCouldntLoadBalance => 'לא ניתן לטעון את היתרה';

  @override
  String get plansFreePlan => 'תוכנית חינמית';

  @override
  String get planTierFree => 'חינם';

  @override
  String get planTierBudget => 'חסכוני';

  @override
  String get planTierBalance => 'מאוזן';

  @override
  String get planTierCommitment => 'מחויבות';

  @override
  String get topupPackSmall => 'חבילה קטנה';

  @override
  String get topupPackMedium => 'חבילה בינונית';

  @override
  String get topupPackLarge => 'חבילה גדולה';

  @override
  String get topupPackMega => 'חבילה ענקית';

  @override
  String get planBlurbFree => 'טעימה מנובה. מתחדש מדי חודש.';

  @override
  String get planBlurbBudget => 'עזרה יומיומית בשיעורי הבית.';

  @override
  String get planBlurbBalance => 'לתלמידים שלומדים מדי יום.';

  @override
  String get planBlurbCommitment => 'תרגול אינטנסיבי + סקרנות בלי גבולות.';

  @override
  String plansTokensPerMonth(String tokens) {
    return '$tokens אסימונים / חודש';
  }

  @override
  String plansTokensOneTime(String tokens) {
    return '$tokens אסימונים';
  }

  @override
  String get planPriceFree => 'חינם';

  @override
  String get plansTokensRemaining => 'אסימונים נותרו';

  @override
  String plansPlanResetsAt(String when) {
    return 'התוכנית מתאפסת $when';
  }

  @override
  String plansTopupTokensInfo(String tokens) {
    return '$tokens אסימוני חבילה (ללא תפוגה)';
  }

  @override
  String get plansHowTokensWorkTitle => 'איך אסימונים עובדים';

  @override
  String get plansHowTokensWorkBody =>
      'אסימונים הם הדרך שבה ה-AI סופר את עבודתו.\n• שאלה קצרה ≈ 2,000 אסימונים\n• הסבר ארוך או תרגול ≈ 5,000–10,000\n• ניתוח תמונות עולה מעט יותר\n\nהאסימונים החודשיים מתאפסים בראשון לחודש. אסימוני חבילה לא פגים.';

  @override
  String get plansPerMonthSuffix => ' / לחודש';

  @override
  String get plansCurrentBadge => 'נוכחית';

  @override
  String get plansCouldntLoadPlans => 'לא ניתן לטעון תוכניות';

  @override
  String get paywallPlansUnavailable => 'התוכניות לא זמינות. נסה שוב בעוד רגע.';

  @override
  String get paywallTopupUnavailable =>
      'החבילה לא זמינה. החנות עוד לא אישרה את המוצר.';

  @override
  String get paywallRestored => 'המנוי שלך שוחזר.';

  @override
  String get paywallNoRestores => 'לא נמצאו רכישות קודמות במזהה Apple זה.';

  @override
  String paywallRestoreFailed(String error) {
    return 'השחזור נכשל: $error';
  }

  @override
  String get paywallPurchasesRestricted => 'רכישות מוגבלות במכשיר זה.';

  @override
  String get paywallPurchaseInvalid =>
      'הרכישה אינה חוקית. נסה אמצעי תשלום אחר.';

  @override
  String get paywallProductNotAvailable =>
      'התוכנית הזו לא זמינה כעת. נסה מאוחר יותר.';

  @override
  String get paywallNetworkError => 'בעיית רשת. בדוק את החיבור ונסה שוב.';

  @override
  String get paywallPaymentPending =>
      'התשלום ממתין לאישור (בקרת הורים וכו\'). יופעל לאחר אישור.';

  @override
  String get paywallStoreProblem => 'ב-App Store הייתה בעיה. נסה שוב בעוד דקה.';

  @override
  String get paywallGenericError => 'משהו השתבש. נסה שוב.';

  @override
  String paywallWelcomeMessage(String plan) {
    return 'ברוך הבא ל-$plan! האסימונים בדרך.';
  }

  @override
  String get paywallWelcomeFallback => 'התוכנית החדשה שלך';

  @override
  String get paywallTopupAdded => 'החבילה נוספה. האסימונים בדרך.';

  @override
  String get paywallPurchaseProcessed =>
      'הרכישה עובדה. האסימונים יופיעו בקרוב.';

  @override
  String paywallSubscribeTo(String plan) {
    return 'הירשם ל-$plan';
  }

  @override
  String paywallBuyTopupNamed(String topup) {
    return 'קנה $topup';
  }

  @override
  String get paywallPlanFallback => 'תוכנית';

  @override
  String get paywallTopupFallback => 'חבילה';

  @override
  String get paywallTopupBlurb =>
      'רכישה חד-פעמית. האסימונים לא פגים ונצברים מעל לתוכנית.';

  @override
  String paywallPerMonthWithTokens(String tokens) {
    return 'לחודש · $tokens';
  }

  @override
  String paywallOneTimeWithTokens(String tokens) {
    return 'חד-פעמי · $tokens';
  }

  @override
  String get paywallSubscribeButton => 'הירשם';

  @override
  String get paywallBuyButton => 'קנה';

  @override
  String get paywallRestoreButton => 'שחזר רכישות';

  @override
  String get paywallNotNow => 'לא עכשיו';

  @override
  String get paywallWebOnlyTitle => 'רכישה דרך הנייד';

  @override
  String get paywallWebOnlyBody =>
      'מנויים וטעינות עוברים דרך App Store או Google Play. פתח את ClassMate באייפון, אייפד או באנדרואיד כדי להירשם — החשבון והאסימונים שלך משותפים בין כל המכשירים.';

  @override
  String get paywallWebOnlyDismiss => 'הבנתי';

  @override
  String get paywallTermsSubscription =>
      'בהרשמה אתה מסכים לתנאי השימוש ולמדיניות הפרטיות של ClassMate. המנויים מתחדשים אוטומטית מדי חודש עד שיבוטלו. ניהול בכל עת מחשבון App Store.';

  @override
  String get paywallTermsTopup =>
      'ברכישה אתה מסכים לתנאי השימוש ולמדיניות הפרטיות של ClassMate. אסימוני חבילה אינם ניתנים להחזרה לאחר השימוש.';

  @override
  String get paywallTermsLink => 'תנאי שימוש (EULA)';

  @override
  String get paywallPrivacyLink => 'מדיניות פרטיות';

  @override
  String get paywallFeatureTokens => 'השתמש באסימונים ב-NOVA ובתרגול';

  @override
  String get paywallFeatureImages => 'ניתוח תמונות והעלאת קבצים כלולים';

  @override
  String get paywallFeatureReset => 'האסימונים מתאפסים בתחילת כל חודש';

  @override
  String get paywallFeatureCancel => 'בטל בכל עת — ללא התחייבות';

  @override
  String get studentMaterialsGeneralSubject => 'כללי';

  @override
  String studentMaterialsResourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count משאבים מהמורים שלך',
      one: 'משאב אחד מהמורים שלך',
    );
    return '$_temp0';
  }

  @override
  String classroomsCouldNotLoadWithError(String error) {
    return 'לא ניתן לטעון את הכיתות\n$error';
  }

  @override
  String get parentNoNotificationsYet => 'אין התראות עדיין.';

  @override
  String forwardCouldNotLoadChats(Object error) {
    return 'לא ניתן לטעון את הצ\'אטים: $error';
  }

  @override
  String get forwardNoChats => 'אין צ\'אטים';

  @override
  String get forgotPasswordFindAdmins => 'מצא את מנהלי בית הספר שלי';

  @override
  String forgotPasswordChooseAdmin(String school) {
    return 'בחר מנהל מתוך $school:';
  }

  @override
  String get forgotPasswordSendRequest => 'שלח בקשת סיסמה';

  @override
  String get commonTitle => 'כותרת';

  @override
  String get commonNotes => 'הערות';

  @override
  String get commonEmail => 'דוא\"ל';

  @override
  String get commonPassword => 'סיסמה';

  @override
  String get commonNumberOfPages => 'מספר עמודים';

  @override
  String get messagesSearchByNameOrGrade => 'חפש לפי שם או כיתה…';

  @override
  String get meetingStartDateRequired => 'תאריך התחלה *';

  @override
  String get meetingStartTimeRequired => 'שעת התחלה *';

  @override
  String get meetingEndDateOptional => 'תאריך סיום (אופציונלי)';

  @override
  String get meetingEndTimeOptional => 'שעת סיום (אופציונלי)';

  @override
  String get teacherMaterialLinkUrlOptional => 'קישור / URL (אופציונלי)';

  @override
  String get teacherSearchStudentsOrGrade => 'חפש תלמידים או כיתה…';

  @override
  String get teacherSearchParentsOrChildren => 'חפש הורים או ילדים…';

  @override
  String get studentAssignmentAddNoteOptional => 'הוסף הערה (אופציונלי)…';

  @override
  String get adminEditUserUsernameRequired => 'שם משתמש *';

  @override
  String get reportReasonOptional => 'סיבה (אופציונלי)';

  @override
  String get forwardSearchChatsAndClassrooms => 'חפש בצ\'אטים ובכיתות…';

  @override
  String get profileNewPhone => 'טלפון חדש';

  @override
  String get profileNewEmail => 'דוא\"ל חדש';

  @override
  String get forgotPasswordYourPhone =>
      'הטלפון שלך (כדי שהמנהל יוכל לאמת שזה באמת אתה)';

  @override
  String get forgotPasswordPhoneHelper =>
      'המנהל יתקשר או ישלח הודעה למספר זה לפני האישור.';

  @override
  String get forgotPasswordNewPasswordHelper =>
      'לפחות 8 תווים. נשמר מוצפן — המנהל לא יראה אותה.';

  @override
  String adminExportPasswordsWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'הקובץ יכיל את פרטי הכניסה של $count תלמידים, כולל סיסמאות נוכחיות. כל מי שיש לו גישה לקובץ יכול להתחבר כאחד התלמידים — שתף בזהירות ומחק את הקובץ בסיום. שורות של חשבונות שנוצרו לפני העדכון האחרון עשויות להציג סיסמה ריקה עד שכל משתמש יתחבר שוב או יאפס.',
      one:
          'הקובץ יכיל את פרטי הכניסה של תלמיד אחד, כולל הסיסמה הנוכחית. כל מי שיש לו גישה לקובץ יכול להתחבר כתלמיד הזה — שתף בזהירות ומחק את הקובץ בסיום. שורות של חשבונות שנוצרו לפני העדכון האחרון עשויות להציג סיסמה ריקה עד שהמשתמש יתחבר שוב או יאפס.',
    );
    return '$_temp0';
  }

  @override
  String get pickerSelectStudents => 'בחר תלמידים';

  @override
  String get pickerSelectCohorts => 'בחר קבוצות';

  @override
  String get pickerSelectGrades => 'בחר כיתות';

  @override
  String get pickerSelectClassroom => 'בחר כיתה';

  @override
  String get pickerSelectClasses => 'בחר כיתות';

  @override
  String get drawerLoadingChildren => 'טוען ילדים…';

  @override
  String get drawerCouldNotLoadChildren => 'לא ניתן לטעון את הילדים';

  @override
  String get drawerNoChildrenLinked => 'אין ילדים מקושרים';

  @override
  String get drawerSwitchChild => 'החלף ילד';

  @override
  String get shellAssessmentCreated => 'ההערכה נוצרה';

  @override
  String commonCouldNotOpenLink(String scheme) {
    return 'לא ניתן לפתוח קישור $scheme';
  }

  @override
  String commonCouldntSend(String error) {
    return 'לא ניתן לשלוח: $error';
  }

  @override
  String get teacherExamDetailsSection => 'פרטי המבחן';

  @override
  String teacherExamStudyMaterialsWithCount(int count) {
    return 'חומרי לימוד ($count)';
  }

  @override
  String get teacherMeetingDetailsSection => 'פרטי המפגש';

  @override
  String get teacherClassroomNameSection => 'שם הכיתה';

  @override
  String get teacherAddByCohortSection => 'הוסף לפי קבוצה';

  @override
  String get teacherAddIndividualStudentsSection => 'הוסף תלמידים בודדים';

  @override
  String get teacherGradeTypeSection => 'סוג ציון';

  @override
  String get teacherOtherGradeSection => 'ציון אחר';

  @override
  String get teacherEnterGradesSection => 'הזן ציונים';

  @override
  String teacherAttachmentsWithCount(int count) {
    return 'קבצים מצורפים ($count)';
  }

  @override
  String get studentFilesSharedByTeacher => 'קבצים ששיתף המורה שלך';

  @override
  String get studentYourSubmission => 'ההגשה שלך';

  @override
  String get studentFilesSharedWithAnnouncement =>
      'קבצים ששותפו עם ההודעה הזו.';

  @override
  String get announcementGradeRiskTitle => 'זוהה סיכון בציונים';

  @override
  String get announcementWeakSubjectTitle => 'זוהה מקצוע חלש';

  @override
  String get announcementLowAttendanceTitle => 'נוכחות נמוכה';

  @override
  String get announcementRepeatedLatenessTitle => 'איחורים חוזרים';

  @override
  String get announcementPracticeWeaknessTitle => 'התגלתה חולשה בתרגול';

  @override
  String get announcementPracticeTrendDroppedTitle => 'מגמת התרגול ירדה';

  @override
  String get announcementSolutionsActivityTitle => 'פעילות פתרונות פעילה';

  @override
  String get announcementAllGoodTitle => 'הכל בסדר';

  @override
  String get supportSectionGettingStarted => 'התחלת השימוש';

  @override
  String get supportSectionAccountPassword => 'חשבון וסיסמה';

  @override
  String get supportSectionForStudents => 'לתלמידים';

  @override
  String get supportSectionForTeachers => 'למורים';

  @override
  String get supportSectionForAdministrators => 'למנהלים';

  @override
  String get supportSectionForParents => 'להורים';

  @override
  String get supportSectionPrivacyData => 'פרטיות ונתונים';

  @override
  String get novaDisclaimerCanMakeMistakes => 'יכול לטעות';

  @override
  String get novaDisclaimerEducationalUseOnly => 'לשימוש חינוכי בלבד';

  @override
  String get novaDisclaimerYourPrivacy => 'הפרטיות שלך';

  @override
  String profileNameInLanguage(String language) {
    return 'שם ב$language';
  }

  @override
  String get adminSettingsScheduleSubtitle =>
      'שייך מורים וקבוצות למשבצות זמן שבועיות';

  @override
  String get practiceModeBalancedSubtitle => 'תרגול יומי מאוזן';

  @override
  String get practiceModeRevealSubtitle => 'חשיפה והיזכרות עצמית';

  @override
  String get practiceModeFastSubtitle => 'אימון מהיר בלחץ';

  @override
  String get practiceModeExamSubtitle => 'זרימה רגועה בסגנון מבחן';

  @override
  String get practiceModeConceptSubtitle => 'מושג קודם, פתרון אחר כך';

  @override
  String get practiceModeAdaptiveSubtitle => 'הקושי משתנה בזמן אמת';

  @override
  String get practiceModeStrictSubtitle => 'סגנון רשמי מחמיר';

  @override
  String get commonCall => 'התקשר';

  @override
  String get tooltipClearEndTime => 'נקה שעת סיום';

  @override
  String get tooltipDeletePeriod => 'מחק שיעור';

  @override
  String get tooltipLeaveClassroom => 'עזוב כיתה';

  @override
  String get announcementGradeRiskBody =>
      'הממוצע שלך ירד מתחת ל-70. מומלץ לפעול מיד.';

  @override
  String announcementWeakSubjectBody(String subject) {
    return '$subject צריך תשומת לב.';
  }

  @override
  String get announcementLowAttendanceBody =>
      'הנוכחות שלך יורדת. זה ישפיע על הציונים.';

  @override
  String get announcementLatenessBody => 'יש לך מספר איחורים.';

  @override
  String announcementPracticeWeakTopicBody(String topic, String subject) {
    return '$topic ב$subject מאט את ההתקדמות שלך.';
  }

  @override
  String get announcementPracticeDropBody =>
      'התרגול האחרון שלך מתחת לבסיס. האט ובנה מחדש.';

  @override
  String announcementSolutionsActivityBody(int page, int question) {
    return 'מרחב הפתרונות שלך פעיל בעמוד $page, שאלה $question. בדוק עבודות עמיתים או העלה משלך.';
  }

  @override
  String get announcementAllGoodBody => 'לא זוהו סיכונים אקדמיים גדולים כרגע.';

  @override
  String get faqStartedQ1 => 'איך אני מתחבר?';

  @override
  String get faqStartedA1 =>
      'הקש על \"היכנס\" במסך הפתיחה והזן את הדוא\"ל או שם המשתמש שמנהל בית הספר נתן לך, יחד עם הסיסמה הזמנית. תתבקש להגדיר סיסמה חדשה בפעם הראשונה.';

  @override
  String get faqStartedQ2 => 'אין לי עדיין חשבון.';

  @override
  String get faqStartedA2 =>
      'מנהל בית הספר יוצר חשבונות. בקש ממנו להוסיף אותך באפליקציית הניהול, או לשתף קוד הצטרפות אם בית הספר משתמש ברישום עצמי.';

  @override
  String get faqStartedQ3 => 'האם אוכל להשתמש באפליקציה בשפה שלי?';

  @override
  String get faqStartedA3 =>
      'כן — ClassMate תומך באנגלית, ערבית, עברית, צרפתית ורוסית. פתח הגדרות כדי להחליף שפה. תוכל גם להגדיר שפת שם מועדפת בפרופיל.';

  @override
  String get faqStartedQ4 => 'איך אני מחליף בין מצב כהה ובהיר?';

  @override
  String get faqStartedA4 =>
      'פתח הגדרות מהתפריט והחלף את מתג המראה. האפליקציה מכבדת את העדפת המערכת שלך כברירת מחדל.';

  @override
  String get faqAccountQ1 => 'שכחתי את הסיסמה.';

  @override
  String get faqAccountA1 =>
      'הקש על \"שכחת סיסמה?\" במסך הכניסה. תקבל קישור איפוס בדוא\"ל או קוד ב-SMS. אם אף ערוץ לא מאומת עדיין, בקש ממנהל בית הספר להנפיק סיסמה זמנית חדשה.';

  @override
  String get faqAccountQ2 => 'איך אני משנה את הסיסמה?';

  @override
  String get faqAccountA2 =>
      'פתח פרופיל מהתפריט, גלול לאבטחה, והקש על שורת הסיסמה. תזדקק לסיסמה הנוכחית כדי להגדיר חדשה.';

  @override
  String get faqAccountQ3 => 'איך אני משנה את הדוא\"ל או מספר הטלפון?';

  @override
  String get faqAccountA3 =>
      'פתח פרופיל, הקש על השדה שברצונך לשנות, ועקוב אחר הוראות האימות. תחילה יישלח קוד לדוא\"ל/טלפון הנוכחי שלך כדי לאשר שזה באמת אתה, ואז תוכל להגדיר את הערך החדש.';

  @override
  String get faqAccountQ4 =>
      'מנהל בית הספר יכול לשנות את הסיסמה שלי — איך זה עובד?';

  @override
  String get faqAccountA4 =>
      'כשמנהל מאפס את הסיסמה שלך, תקבל דוא\"ל ו-SMS עם קישור להגדרת סיסמה משלך. המנהל לעולם לא רואה מה אתה בוחר.';

  @override
  String get faqStudentsQ1 => 'איפה אני רואה את מערכת השעות?';

  @override
  String get faqStudentsA1 =>
      'מערכת השעות היא הפריט הראשון בתפריט. תראה את שיעורי השבוע, מי מלמד כל אחד, וכל שינוי שהמנהל פרסם.';

  @override
  String get faqStudentsQ2 => 'איך אני מצטרף לכיתה?';

  @override
  String get faqStudentsA2 =>
      'מורה יוסיף אותך ישירות, או ישתף קוד הצטרפות. כדי להשתמש בקוד הצטרפות, פתח כיתות מהתפריט והקש על \"הצטרף עם קוד\".';

  @override
  String get faqStudentsQ3 => 'איך נוכחות וציונים עובדים?';

  @override
  String get faqStudentsA3 =>
      'מורים מסמנים נוכחות במהלך השיעור. פתח נוכחות או ציונים מהתפריט כדי לראות את הרשומות שלך. הורים המקושרים לחשבונך רואים את אותם הנתונים.';

  @override
  String get faqStudentsQ4 => 'מה זה Nova?';

  @override
  String get faqStudentsA4 =>
      'Nova הוא חבר הלימודים שלך מבוסס AI — בקש ממנו להסביר מושג, ליצור חידון, או לעבור על בעיה צעד אחר צעד. פתח Nova מהתפריט כדי להתחיל מפגש.';

  @override
  String get faqTeachersQ1 => 'איך אני יוצר כיתה?';

  @override
  String get faqTeachersA1 =>
      'פתח כיתות מהתפריט והקש על כפתור +. תן לה שם ומקצוע; תלמידים יכולים להתווסף ידנית או באמצעות קוד הצטרפות.';

  @override
  String get faqTeachersQ2 => 'איך אני מסמן נוכחות?';

  @override
  String get faqTeachersA2 =>
      'פתח נוכחות מהתפריט, בחר תאריך ושיעור, ואז הקש על כל תלמיד כדי להגדיר את מצבו. השינויים נשמרים אוטומטית.';

  @override
  String get faqTeachersQ3 => 'איך אני מטיל שיעורי בית?';

  @override
  String get faqTeachersA3 =>
      'פתח מטלות, הקש +, מלא את הכותרת/מועד היעד/קבצים מצורפים, ובחר יעד (כל בית הספר, קבוצות ספציפיות, או תלמידים בשם). התלמידים רואים זאת מיד בתפריט שלהם.';

  @override
  String get faqTeachersQ4 => 'האם אוכל להנפיק תעודה?';

  @override
  String get faqTeachersA4 =>
      'כן — פתח תעודות מהתפריט, הקש +, בחר את התלמיד, מלא את הכותרת והפרטים, ושמור. התלמיד רואה את התעודה בסעיף התעודות שלו.';

  @override
  String get faqAdminsQ1 => 'מאיפה אני מתחיל להגדיר בית ספר?';

  @override
  String get faqAdminsA1 =>
      'פתח את לוח הניהול. ויג\'ט הגדרת בית הספר בראש מציג רשימת 7 שלבים (לוגו, שם, מקצועות, צלצולים, קבוצות, תלמידים, מורים). כל שלב מקושר ישירות למקום שבו אתה משלים אותו.';

  @override
  String get faqAdminsQ2 => 'איך קבוצות עובדות?';

  @override
  String get faqAdminsA2 =>
      'קבוצה היא קבוצת תלמידים החולקת מערכת שעות. פתח קבוצות מהתפריט כדי ליצור אותן, להקצות תלמידים, וליצור קודי הצטרפות. קבוצה אחת יכולה לכלול מספר כיתות.';

  @override
  String get faqAdminsQ3 => 'האם קבוצה יכולה לכסות יותר מכיתה אחת?';

  @override
  String get faqAdminsA3 =>
      'כן — בעת יצירת קבוצה, בחר מספר כיתות. הקבוצה תופיע במסננים ובתצוגות של כל אותן כיתות, והכרזות/תבניות המכוונות לכל אחת מהכיתות יגיעו אליה.';

  @override
  String get faqAdminsQ4 => 'איך אני בונה את מערכת השעות השבועית?';

  @override
  String get faqAdminsA4 =>
      'פתח מערכת שעות מהתפריט. הקש על תא כלשהו להוספת שיעור — בחר את היום/השיעור, המורה, המקצוע, והקהל (קבוצה/תלמיד/כיתה). שעות הצלצולים מגיעות מהגדרות בית הספר.';

  @override
  String get faqAdminsQ5 => 'איך אני מייצא תלמידים בכמות?';

  @override
  String get faqAdminsA5 =>
      'פתח יצוא נתונים מהתפריט. בחר אם לבחור לפי תלמיד או לפי קבוצה, בחר את השורות, והקש על ייצא. אופציונלית כלול סיסמאות נוכחיות במהלך הייצוא.';

  @override
  String get faqAdminsQ6 => 'משתמש ביקש איפוס סיסמה. מה אני עושה?';

  @override
  String get faqAdminsA6 =>
      'תוכל להגדיר את הסיסמה ישירות (פרופיל המשתמש → אבטחה) או לחכות שהוא יגיש בקשה דרך \"שכחת סיסמה\" ולאשר אותה מבקשות הסיסמה בתפריט.';

  @override
  String get faqParentsQ1 => 'איך אני מקשר את החשבון לילד שלי?';

  @override
  String get faqParentsA1 =>
      'בקש ממנהל בית הספר של ילדך להוסיף את הקישור מאפליקציית הניהול, או לשתף קוד קישור הורה חד-פעמי. פתח פרופיל והזן את הקוד תחת משפחה.';

  @override
  String get faqParentsQ2 => 'מה אני יכול לראות על הילד שלי?';

  @override
  String get faqParentsA2 =>
      'נוכחות, ציונים, הודעות, ושיעורי בית — בדיוק מה שהילד רואה, בנוסף למגמות לאורך זמן. לא תראה צ\'אטים פרטיים או מפגשי Nova.';

  @override
  String get faqPrivacyQ1 => 'מי יכול לראות את הנתונים שלי?';

  @override
  String get faqPrivacyA1 =>
      'רק אנשים בבית הספר שלך. מורים רואים את נתוני הכיתות שלהם, מנהלים רואים נתונים ברחבי בית הספר, הורים רואים את ילדיהם המקושרים. אנחנו לעולם לא מוכרים נתונים למפרסמים.';

  @override
  String get faqPrivacyQ2 => 'איך אני מוחק את החשבון?';

  @override
  String get faqPrivacyA2 =>
      'בקש ממנהל בית הספר למחוק אותו. הוא יכול להסיר את החשבון מאפליקציית הניהול, מה שמוחק את הפרופיל, מערכת השעות והצ\'אטים שלך.';

  @override
  String solutionsPagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count עמודים',
      one: 'עמוד אחד',
    );
    return '$_temp0';
  }

  @override
  String get teacherMeetingEditTitle => 'ערוך מפגש';

  @override
  String get teacherMeetingNewTitle => 'תזמן מפגש';

  @override
  String get teacherExamEditTitle => 'ערוך מבחן';

  @override
  String get teacherExamNewTitle => 'צור מבחן';

  @override
  String get teacherAssignmentEditTitle => 'ערוך מטלה';

  @override
  String get teacherAssignmentNewTitle => 'מטלה חדשה';

  @override
  String get tooltipShowTabs => 'הצג כרטיסיות';

  @override
  String get tooltipHideTabs => 'הסתר כרטיסיות';

  @override
  String get examsCouldNotLoadForms => 'לא ניתן לטעון טפסים';

  @override
  String get examsCouldNotLoadExams => 'לא ניתן לטעון מבחנים';

  @override
  String get messagesNoPeopleToAdd => 'אין אנשים להוסיף';

  @override
  String commonNoResultsForQuery(String query) {
    return 'אין תוצאות עבור \"$query\"';
  }

  @override
  String chatForwardedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'הועבר ל-$count צ\'אטים',
      one: 'הועבר לצ\'אט אחד',
    );
    return '$_temp0';
  }

  @override
  String get commonReadMore => 'קרא עוד';

  @override
  String get commonReadLess => 'קרא פחות';

  @override
  String get chatComposerSlideToCancel => 'החלק לביטול';

  @override
  String adminNoRoleYet(String role) {
    return 'אין עדיין $role';
  }

  @override
  String get profileVerified => 'אומת.';

  @override
  String get profileUpdatedPendingVerification => 'עודכן וממתין לאימות מחדש.';

  @override
  String get adminSearchCohorts => 'חפש קבוצות…';

  @override
  String get commonAdding => 'מוסיף…';

  @override
  String get teacherDiplomaIssuing => 'מנפיק…';

  @override
  String get teacherDiplomaIssue => 'הנפק';

  @override
  String get formAccepting => 'מקבל';

  @override
  String get profileVerifiedShort => 'מאומת';

  @override
  String get profileUnverified => 'לא מאומת';

  @override
  String get notificationNewGradePosted => 'פורסם ציון חדש';

  @override
  String notificationNewGradePostedIn(String subject) {
    return 'פורסם ציון חדש ב$subject';
  }

  @override
  String messagesAddParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'הוסף $count משתתפים',
      one: 'הוסף משתתף אחד',
    );
    return '$_temp0';
  }

  @override
  String get notificationFallbackTitle => 'התראה';

  @override
  String adminCohortGradeRange(int from, int to) {
    return 'כיתה $from-$to';
  }

  @override
  String adminCohortGradesList(String list) {
    return 'כיתות $list';
  }

  @override
  String get adminExportHeaderTitle => 'ייצוא משתמשים';

  @override
  String get adminExportHeaderSubtitle =>
      'הוסף סננים כתגיות — כל תגית מוסיפה משתמשים לייצוא. הקש על תגית להסרתה.';

  @override
  String get adminExportAddFilter => 'הוסף סנן';

  @override
  String get adminExportEmptyState =>
      'הוסף סנן להתחלה: בחר תפקיד, קבוצה, כיתה או משתמשים ספציפיים.';

  @override
  String get adminExportFilterRolesTab => 'תפקידים';

  @override
  String get adminExportFilterCohortsTab => 'קבוצות';

  @override
  String get adminExportFilterGradesTab => 'כיתות';

  @override
  String get adminExportFilterUsersTab => 'משתמשים';

  @override
  String get adminExportSelectAll => 'בחר הכול';

  @override
  String adminExportSelectedCount(int selected, int total) {
    return 'נבחרו $selected מתוך $total';
  }

  @override
  String adminExportRolePickedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count נבחרו',
      one: 'נבחר אחד',
    );
    return '$_temp0';
  }

  @override
  String get adminExportPillRolePrefix => 'תפקיד:';

  @override
  String get adminExportPillCohortPrefix => 'קבוצה:';

  @override
  String adminExportActiveFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count סננים פעילים',
      one: 'סנן פעיל אחד',
    );
    return '$_temp0';
  }

  @override
  String get adminExportClearAll => 'נקה הכל';

  @override
  String get adminExportCounting => 'סופר…';

  @override
  String adminExportMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count משתמשים יוצאו',
      one: 'משתמש אחד יוצא',
    );
    return '$_temp0';
  }

  @override
  String get adminExportNoGradesConfigured => 'אין כיתות מוגדרות לבית הספר';

  @override
  String get adminExportColumnRole => 'תפקיד';

  @override
  String get adminExportRoleStudent => 'תלמיד';

  @override
  String get adminExportRoleTeacher => 'מורה';

  @override
  String get adminExportRoleParent => 'הורה';

  @override
  String get adminExportRoleSecretary => 'מזכיר';

  @override
  String get adminExportRoleAdmin => 'מנהל';

  @override
  String adminExportUsersSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'נבחרו $count משתמשים',
      one: 'נבחר משתמש אחד',
    );
    return '$_temp0';
  }

  @override
  String get adminExportPasswordsOn =>
      'סיסמאות יופיעו בייצוא — טפל בקובץ בזהירות.';

  @override
  String get adminExportPasswordsOff => 'הייצוא לא יכיל סיסמאות.';

  @override
  String get adminExportPdfUserDirectory => 'ספריית משתמשים';

  @override
  String adminExportPdfUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count משתמשים',
      one: 'משתמש אחד',
    );
    return '$_temp0';
  }

  @override
  String get teacherAttachFromMaterials => 'מחומרים';

  @override
  String get teacherUploadFiles => 'העלה קבצים';

  @override
  String get solSubjectMathematics => 'מתמטיקה';

  @override
  String get solSubjectComputerScience => 'מדעי המחשב';

  @override
  String get solSubjectPhysics => 'פיזיקה';

  @override
  String get solSubjectChemistry => 'כימיה';

  @override
  String get solSubjectHebrew => 'עברית';

  @override
  String get solSubjectBiology => 'ביולוגיה';

  @override
  String get solSubjectHistory => 'היסטוריה';

  @override
  String get solSubjectArabic => 'ערבית';

  @override
  String get solSubjectElectronics => 'אלקטרוניקה';

  @override
  String get solSubjectMechanics => 'מכניקה';

  @override
  String get solSubjectFrench => 'צרפתית';

  @override
  String get solSubjectEnvironmentalScience => 'מדעי הסביבה';

  @override
  String get solSubjectCommunicationCinema => 'תקשורת וקולנוע';

  @override
  String get solSubjectCitizenship => 'אזרחות';

  @override
  String get solSubjectSociology => 'סוציולוגיה';

  @override
  String get solSubjectReligion => 'דת';

  @override
  String get solSubjectGeography => 'גאוגרפיה';

  @override
  String get commonUnknown => 'לא ידוע';

  @override
  String get solutionsReportTitle => 'דיווח על פתרון זה';

  @override
  String get solutionsReportBody =>
      'ספרו למנהלים מה הבעיה. מנהלי שני בתי הספר יבדקו זאת.';

  @override
  String get solutionsReportReasonHint => 'סיבה (אופציונלי)';

  @override
  String get solutionsReportAction => 'דווח';

  @override
  String get solutionsReportSubmitted => 'תודה — הדיווח נשלח למנהלים.';

  @override
  String get solutionsReportAlready => 'כבר דיווחת על זה.';

  @override
  String solutionsBookPagesCount(int count) {
    return '$count עמודים';
  }

  @override
  String get solutionsNoBooksYetForStudents =>
      'אין כאן ספרים עדיין. המורה יוסיף אותם.';

  @override
  String get solutionsManageBooksTitle => 'ניהול ספרים';

  @override
  String get solutionsNoBooksManageHint => 'אין ספרים למקצוע זה. הקש + להוספה.';

  @override
  String get solutionsDeleteBookTitle => 'למחוק ספר?';

  @override
  String solutionsDeleteBookBody(String title) {
    return 'למחוק את \"$title\"? לא ניתן לבטל.';
  }

  @override
  String solutionsBookSaveFailed(String error) {
    return 'השמירה נכשלה: $error';
  }

  @override
  String get solutionsBookNeedTitlePages => 'הזינו כותרת ומספר עמודים.';

  @override
  String get solutionsEditBookTitle => 'עריכת ספר';

  @override
  String get solutionsBookCoverLabel => 'כריכה';

  @override
  String solutionsGradeLabel(int grade) {
    return 'כיתה $grade';
  }

  @override
  String get solutionsReportsTitle => 'פתרונות שדווחו';

  @override
  String get solutionsReportsEmpty => 'אין דיווחים לבדיקה.';

  @override
  String get solutionsReportPostedBy => 'פורסם על ידי';

  @override
  String get solutionsReportReportedBy => 'דווח על ידי';

  @override
  String get solutionsReportReasonLabel => 'סיבה';

  @override
  String get solutionsReportKeepAction => 'השאר';

  @override
  String get solutionsReportRemoveAction => 'הסר';

  @override
  String get solutionsReportStatusPending => 'ממתין';

  @override
  String get solutionsReportStatusApproved => 'נשמר';

  @override
  String get solutionsReportStatusRemoved => 'הוסר';

  @override
  String get solutionsReportRemoved => 'הפתרון הוסר.';

  @override
  String get solutionsReportApproved => 'הדיווח נדחה — הפתרון נשמר.';

  @override
  String solutionsReportFailed(String error) {
    return 'הדיווח נכשל: $error';
  }

  @override
  String get teacherAddGradeTitle => 'הוספת ציון';

  @override
  String get commonCohort => 'קבוצה';

  @override
  String get teacherCreateNewExam => 'יצירת מבחן חדש';

  @override
  String get teacherCreateNewAssignment => 'יצירת מטלה חדשה';

  @override
  String get commonReturn => 'החזרה';

  @override
  String get reorderToolsTitle => 'סידור התפריט מחדש';

  @override
  String get reorderToolsSubtitle =>
      'גררו כדי לסדר מחדש את כלי בית הספר. מקטעי הליבה והחשבון נשארים במקומם.';

  @override
  String get reorderToolsReset => 'איפוס';

  @override
  String get reorderToolsSettingsSection => 'תפריט';

  @override
  String get reorderToolsSettingsSubtitle => 'סידור הכלים בתפריט הצד';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Pushto Pashto (`ps`).
class AppLocalizationsPs extends AppLocalizations {
  AppLocalizationsPs([String locale = 'ps']) : super(locale);

  @override
  String get menu => 'مينو';

  @override
  String get sectionCore => 'اصلي';

  @override
  String get sectionSchoolTools => 'د ښوونځي وسايل';

  @override
  String get sectionAccount => 'حساب';

  @override
  String get navSchedule => 'مهالويش';

  @override
  String get navClassrooms => 'ټولګيونه';

  @override
  String get navPractice => 'تمرين';

  @override
  String get navInsights => 'کتنې';

  @override
  String get navNova => 'NOVA';

  @override
  String get navMessages => 'پيغامونه';

  @override
  String get navAttendance => 'حاضري';

  @override
  String get navGrades => 'نمرې';

  @override
  String get navAssignments => 'دندې';

  @override
  String get navMeetings => 'غونډې';

  @override
  String get navAnnouncements => 'اعلانونه';

  @override
  String get navNotifications => 'خبرتیاوې';

  @override
  String get navSolutions => 'حلونه';

  @override
  String get navExams => 'ازموینې';

  @override
  String get navForms => 'فورمې';

  @override
  String get navHome => 'کور';

  @override
  String get navTeacherWorkspace => 'د ښوونکي کاري ځای';

  @override
  String get navTeacherAssessments => 'ارزونې او نمرې';

  @override
  String get navSavedQuestions => 'خوندي شوي پوښتنې';

  @override
  String get navProfile => 'پروفايل';

  @override
  String get navSettings => 'تنظیمات';

  @override
  String get navLogout => 'وتل';

  @override
  String get roleTeacher => 'ښوونکی';

  @override
  String get roleAdmin => 'مدير';

  @override
  String get roleSecretary => 'منشي';

  @override
  String get roleParent => 'والدين';

  @override
  String get roleStudent => 'زده‌کوونکی';

  @override
  String get titleSchedule => 'مهالويش';

  @override
  String get titleClasses => 'ټولګيونه';

  @override
  String get titlePractice => 'تمرين';

  @override
  String get titleInsights => 'کتنې';

  @override
  String get titleNova => 'NOVA';

  @override
  String get titleMessages => 'پيغامونه';

  @override
  String get titleSolutions => 'حلونه';

  @override
  String get titleExams => 'ازموینې';

  @override
  String get solutionsUploadAction => 'پورته کول';

  @override
  String get solutionsNoSubjectsAvailable => 'هیڅ مضمون شتون نلري.';

  @override
  String solutionsNoSubjectsMatch(Object query) {
    return 'هیڅ مضمون له \"$query\" سره سمون نه خوري.';
  }

  @override
  String solutionsBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کتابونه',
      one: '۱ کتاب',
    );
    return '$_temp0';
  }

  @override
  String get solutionsBooksTitle => 'کتابونه';

  @override
  String get solutionsAddBookTitle => 'یو کتاب اضافه کړئ';

  @override
  String get solutionsBookTitleHint => 'د کتاب نوم...';

  @override
  String get solutionsAddBookAction => 'یو کتاب اضافه کړئ';

  @override
  String get solutionsSearchBooks => 'کتابونه ولټوئ';

  @override
  String get solutionsChooseSubjectFirst => 'لومړی یو مضمون وټاکئ.';

  @override
  String solutionsNoBooksYetBody(Object action) {
    return 'تر اوسه هیڅ کتاب نشته.\nد لومړي کتاب د اضافه کولو لپاره \"$action\" کېکاږئ.';
  }

  @override
  String solutionsNoBooksMatch(Object query) {
    return 'هیڅ کتاب له \"$query\" سره سمون نه خوري.';
  }

  @override
  String get solutionsBookLabel => 'کتاب';

  @override
  String get solutionsPagesFilterHint =>
      'د فلټر کولو لپاره د پاڼې او پوښتنې شمېره دننه کړئ، یا د ټولو لیدلو لپاره یې خالي پرېږدئ.';

  @override
  String get solutionsPageNumberLabel => 'د پاڼې شمېره';

  @override
  String get solutionsPageNumberHint => 'لکه ۴۲';

  @override
  String get solutionsQuestionNumberLabel => 'د پوښتنې شمېره';

  @override
  String get solutionsQuestionNumberHint => 'لکه ۳a یا ۷';

  @override
  String get solutionsViewSolutionsAction => 'حلونه وګورئ';

  @override
  String solutionsPageQuestionSummary(Object page, Object question) {
    return 'پاڼه $page • پوښتنه $question';
  }

  @override
  String get solutionsExactQuestionTitle => 'د همدې دقیقې پوښتنې حلونه';

  @override
  String get solutionsExactQuestionEmptySubtitle =>
      'تر اوسه د دې دقیقې پوښتنې لپاره هیڅ شی نه دی پورته شوی. لومړی شئ چې خپلو همصنفانو سره مرسته وکړئ.';

  @override
  String solutionsUploadsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پورته شوي موندل شول',
      one: '۱ پورته شوی موندل شو',
    );
    return '$_temp0';
  }

  @override
  String get solutionsExactQuestionEmptyBody =>
      'تر اوسه دقیق سمون نشته. تاسو کولی شئ همدا اوس یو پورته کړئ، یا وګورئ چې همصنفانو په همدې پاڼه کې څه حل کړي دي.';

  @override
  String get solutionsLoadMoreAction => 'نور بار کړئ';

  @override
  String get solutionsSamePageTitle => 'په دې پاڼه کې حل شوي نورې پوښتنې';

  @override
  String get solutionsSamePageEmptySubtitle =>
      'تر اوسه د دې پاڼې څخه هیڅ ګاونډۍ پوښتنه نه ده پورته شوې.';

  @override
  String get solutionsSamePageFallbackSubtitle =>
      'ګټور بدیل کله چې ستاسو دقیقې پوښتنې ته هیڅ پورته شوی نه وي.';

  @override
  String get solutionsSamePageEmptyBody =>
      'تر اوسه په دې پاڼه کې هیڅ نږدې پورته شوی نشته. دلته یو نوی پورته کول به ډېره مرسته وکړي.';

  @override
  String get solutionsVerifiedByNova => 'د NOVA لخوا تصدیق شوی';

  @override
  String get solutionsUploadFileLimitReached => 'د ۱۰ فايلونو حد ته ورسېد.';

  @override
  String solutionsUploadFilesAddedLimit(int count) {
    return '$count اضافه شول — د ۱۰ فايلونو حد.';
  }

  @override
  String get solutionsUploadCompleteFields =>
      'مضمون، کتاب، پاڼه او پوښتنه بشپړ کړئ.';

  @override
  String get solutionsUploadAddOneFile =>
      'لږ تر لږه یو انځور یا PDF اضافه کړئ.';

  @override
  String solutionsUploadFileFailed(Object error) {
    return 'د فايل پورته کول ناکام شول: $error';
  }

  @override
  String solutionsUploadCreateFailed(Object error) {
    return 'د حل جوړول ناکام شول: $error';
  }

  @override
  String get solutionsUploadSuccess => 'حل پورته شو!';

  @override
  String get solutionsUploadAddNewBookOption => '+ نوی کتاب اضافه کړئ...';

  @override
  String get solutionsUploadAddBookShortAction => 'اضافه کول';

  @override
  String get solutionsUploadTitle => 'یو حل پورته کړئ';

  @override
  String get solutionsUploadSubtitle =>
      'یوازې ریښتیني انځورونه یا PDF. د NOVA تصدیق او څارنه د پورته کولو وروسته پلي کېږي.';

  @override
  String get solutionsUploadNoBooksAbove =>
      'هیڅ کتاب نشته — پورته یو اضافه کړئ';

  @override
  String get solutionsUploadCaptionOptional => 'سرليک (اختیاري)';

  @override
  String get solutionsUploadImagesAction => 'انځورونه';

  @override
  String get solutionsUploadPdfAction => 'PDF';

  @override
  String solutionsUploadFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'فايلونه وټاکل شول',
      one: 'فايل وټاکل شو',
    );
    return '$count / ۱۰ $_temp0';
  }

  @override
  String get solutionsUploadSomeFilesFailed => 'ځینې فايلونه پورته نشول.';

  @override
  String get solutionsUploadRetryFailedFiles => 'ناکام فايلونه بیا هڅه کړئ';

  @override
  String get solutionsUploadSubmittingAction => 'پورته کول...';

  @override
  String get solutionsUploadSubmitAction => 'حل پورته کړئ';

  @override
  String get settingsTitle => 'تنظیمات';

  @override
  String get settingsSubtitle => 'بڼه، ژبه او حساب';

  @override
  String get settingsAppearance => 'بڼه';

  @override
  String get settingsTheme => 'تيم';

  @override
  String get settingsLanguage => 'ژبه';

  @override
  String get settingsLanguageSystem => 'د سیسټم اصلي';

  @override
  String get settingsAccentColour => 'د تاکيد رنګ';

  @override
  String get settingsAccentSubtitle =>
      'هغه رنګ چې په ټوله اپلیکیشن کې کارول کېږي';

  @override
  String get settingsReduceMotion => 'حرکت کمول';

  @override
  String get settingsReduceMotionSubtitle =>
      'په ټوله اپلیکیشن کې لږ انیمیشنونه';

  @override
  String get settingsAccount => 'حساب';

  @override
  String get settingsLogout => 'وتل';

  @override
  String get settingsLogoutSubtitle => 'له دې وسیلې وتل';

  @override
  String get settingsThemeSystem => 'د سیسټم اصلي';

  @override
  String get settingsThemeLight => 'روښانه';

  @override
  String get settingsThemeDark => 'تياره';

  @override
  String get settingsLanguageSearchHint => 'ژبه ولټوئ...';

  @override
  String get teacherWorkspaceSubtitle =>
      'له موبایل اپلیکیشن څخه حاضري، نومليکونه او نمرې اداره کړئ.';

  @override
  String get teacherMetricSessionsToday => 'د نن ورځې ناستې';

  @override
  String get teacherMetricTeachingGroups => 'د تدریس ډلې';

  @override
  String get teacherMetricAssessments => 'ارزونې';

  @override
  String get teacherQuickActions => 'چټک کارونه';

  @override
  String get teacherNoDateAvailable => 'هیڅ نېټه شتون نلري';

  @override
  String get teacherNoTeachingSlotsToday =>
      'د نن ورځې لپاره د تدریس هیڅ وخت ندی ټاکل شوی.';

  @override
  String get teacherUpcomingAssessments => 'راتلونکې ارزونې';

  @override
  String get teacherUpcomingAssessmentsSubtitle =>
      'د ښوونکي د نمرو ورکولو سیسټم څخه ژوندۍ';

  @override
  String get teacherNoAssessmentsYet => 'تر اوسه هیڅ ارزونه نه ده جوړه شوې.';

  @override
  String get teacherUnassignedSlot => 'نه ټاکل شوی وخت';

  @override
  String get teacherNoCohort => 'هیڅ ډله نشته';

  @override
  String get teacherCourseFallback => 'کورس';

  @override
  String teacherPeriod(Object number) {
    return 'وخت $number';
  }

  @override
  String get teacherLoadErrorTitle => 'د ښوونکي کاري ځای بار نشو';

  @override
  String get teacherClassroomsLoadError =>
      'موږ همدا اوس ټولګيونه بار کولی نشو. د تازه کولو لپاره راکش کړئ یا بیا هڅه وکړئ.';

  @override
  String get teacherClassroomsLoadTimeout =>
      'ټولګيونه د بار کېدو لپاره ډیر وخت نیسي. د تازه کولو لپاره راکش کړئ یا لږ وروسته بیا هڅه وکړئ.';

  @override
  String get teacherClassroomsLoadNetwork =>
      'ټولګيونه همدا اوس نشي نښلېدلی. خپله اړیکه وګورئ او بیا هڅه وکړئ.';

  @override
  String get teacherClassroomsSubtitle =>
      'نومليک پرانیزئ او د زده‌کوونکو د ننوتلو لپاره ژوندی کوډ جوړ کړئ.';

  @override
  String get teacherClassroomsNoCohorts =>
      'تر اوسه له دې ښوونکي سره هیڅ د ټولګي ډله نه ده تړل شوې.';

  @override
  String teacherClassroomsCohort(Object cohortId) {
    return 'ډله $cohortId';
  }

  @override
  String get teacherClassroomsGeneratingJoinCode => 'جوړول…';

  @override
  String get teacherClassroomsCreateJoinCode => 'د یوځای کېدو کوډ جوړ کړئ';

  @override
  String get teacherClassroomsLiveJoinCode => 'ژوندی د یوځای کېدو کوډ';

  @override
  String teacherClassroomsExpiresAt(Object value) {
    return 'نېټه پای ته رسېږي $value';
  }

  @override
  String get teacherClassroomsRoster => 'نومليک';

  @override
  String get teacherClassroomsNoStudents =>
      'تر اوسه په دې ټولګي کې هیڅ زده‌کوونکی نه دی نوم لیکلی.';

  @override
  String get teacherAttendanceLoadError =>
      'موږ همدا اوس حاضري بار کولی نشو. د تازه کولو لپاره راکش کړئ یا بیا هڅه وکړئ.';

  @override
  String get teacherAttendanceLoadTimeout =>
      'حاضري د بار کېدو لپاره ډیر وخت نیسي. د تازه کولو لپاره راکش کړئ یا لږ وروسته بیا هڅه وکړئ.';

  @override
  String get teacherAttendanceLoadNetwork =>
      'حاضري همدا اوس نشي نښلېدلی. خپله اړیکه وګورئ او بیا هڅه وکړئ.';

  @override
  String get teacherAttendanceSubtitle =>
      'یوه ژوندۍ ناسته وټاکئ، ټولګی نښه کړئ، او یوازې بدل شوي قطارونه خوندي کړئ.';

  @override
  String get teacherAttendanceTodaySessions => 'د نن ورځې ناستې';

  @override
  String teacherAttendanceSessionSummary(
    Object cohort,
    Object grade,
    Object date,
    Object period,
  ) {
    return '$cohort • ټولګی $grade • $date • وخت $period';
  }

  @override
  String get teacherAttendanceChanged => 'بدل شو';

  @override
  String get teacherAttendanceNoteLabel => 'یادښت';

  @override
  String get teacherAttendanceClassNotesLabel => 'د ټولګي یادښتونه';

  @override
  String get teacherAttendanceClassNotesHint => 'په دې ناسته کې څه تدریس شول…';

  @override
  String get teacherAttendanceSaving => 'خوندي کول…';

  @override
  String get teacherAttendanceSaveAll => 'حاضري خوندي کړئ';

  @override
  String teacherAttendanceSaveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بدلونونه',
      one: '۱ بدلون',
    );
    return '$_temp0 خوندي کړئ';
  }

  @override
  String get teacherAttendanceSaved => 'حاضري خوندي شوه';

  @override
  String get retry => 'بیا هڅه';

  @override
  String get scheduleRefreshTooFast =>
      'مهالويش همدا اوس ډیر ژر تازه کېږي. لږ صبر وکړئ او بیا هڅه وکړئ.';

  @override
  String get scheduleSessionExpired =>
      'ستاسو ناسته پای ته رسېدلې. مهرباني وکړئ بیا ننوځئ.';

  @override
  String get scheduleNotOnboarded =>
      'ستاسو د زده‌کوونکي پروفايل تر اوسه په بشپړه توګه جوړ نه دی. د خپل ښوونځي مدير څخه وغواړئ چې تاسو یوې ټولګي ته وټاکي.';

  @override
  String get scheduleLoadError => 'تر اوسه مهالويش بار نشو.';

  @override
  String get scheduleSelectedDay => 'ټاکل شوې ورځ';

  @override
  String scheduleClassCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ټولګي',
      one: '۱ ټولګی',
      zero: '۰ ټولګي',
    );
    return '$_temp0';
  }

  @override
  String get scheduleNextUp => 'راتلونکی';

  @override
  String get scheduleNoMoreClasses => 'نور ټولګي نشته';

  @override
  String get scheduleNoClassesTitle => 'په دې ورځ کې هیڅ ټولګی نشته';

  @override
  String scheduleNoClassesSubtitle(Object day) {
    return '$day ازاد ښکاري.';
  }

  @override
  String get scheduleClassFallback => 'ټولګی';

  @override
  String get scheduleNoSubjectLocation => 'تر اوسه هیڅ مضمون یا ځای نشته';

  @override
  String get scheduleNotes => 'یادښتونه';

  @override
  String get scheduleGoToClassroom => 'ټولګي ته لاړ شئ';

  @override
  String get loginTitle => 'د زده‌کوونکو او ښوونکو لپاره د موبایل ننوتل';

  @override
  String get loginSubtitle =>
      'د ښوونکي حسابونه د ښوونکي کاري ځای پرانیزي. د زده‌کوونکو حسابونه د زده‌کوونکي تجربې پر کې پاتې کېږي.';

  @override
  String get loginSignIn => 'ننوتل';

  @override
  String get biometricSignIn => 'د بیومټریک سره ننوتل';

  @override
  String get biometricEnable => 'د بیومټریک ننوتل فعال کړئ';

  @override
  String get biometricReason => 'ClassMate ته د ننوتلو لپاره تصدیق وکړئ';

  @override
  String get biometricEnableReason =>
      'د بیومټریک ننوتلو د فعالولو لپاره تصدیق وکړئ';

  @override
  String get biometricSignInFaceId => 'د Face ID سره ننوتل';

  @override
  String get biometricSignInFingerprint => 'د ګوتې نښې سره ننوتل';

  @override
  String get biometricOrSignInWith => 'یا د دې سره ننوتل';

  @override
  String get biometricNotSetUp =>
      'تر اوسه هیڅ بیومټریک ننوتل نه دي تنظیم شوي. په پروفایل → بیومټریک ننوتل کې Face ID یا د ګوتې نښه فعاله کړئ.';

  @override
  String get biometricNotRecognized =>
      'بیومټریک ونه پېژندل شو. بیا هڅه وکړئ یا د خپل پټنوم سره ننوځئ.';

  @override
  String get biometricFaceUnavailable => 'Face ID پدې وسیله کې شتون نلري.';

  @override
  String get biometricFingerprintUnavailable =>
      'د ګوتې نښه پدې وسیله کې شتون نلري.';

  @override
  String get biometricNotAvailableOnDevice => 'پدې وسیله کې شتون نلري';

  @override
  String get biometricSectionTitle => 'بیومټریک ننوتل';

  @override
  String get biometricSectionSubtitle =>
      'د چټک ننوتلو لپاره Face ID یا خپله د ګوتې نښه فعاله کړئ. تاسو به یو ځل خپل پټنوم تایید کړئ.';

  @override
  String get biometricFaceId => 'Face ID';

  @override
  String get biometricFaceIdDesc => 'د ننوتلو لپاره Face ID وکاروئ';

  @override
  String get biometricFingerprint => 'د ګوتې نښه';

  @override
  String get biometricFingerprintDesc =>
      'د ننوتلو لپاره خپله د ګوتې نښه وکاروئ';

  @override
  String get biometricConfirmPasswordTitle => 'خپل پټنوم تایید کړئ';

  @override
  String get biometricConfirmPasswordBody =>
      'د بیومټریک ننوتلو د فعالولو لپاره خپل پټنوم ولیکئ.';

  @override
  String get biometricPasswordIncorrect =>
      'ناسم پټنوم. مهرباني وکړئ بیا هڅه وکړئ.';

  @override
  String get biometricEnrollFailed =>
      'ستاسو بیومټریک تایید نشو. ډاډ ترلاسه کړئ چې Face ID یا د ګوتې نښه ستاسو د وسیلې په تنظیماتو کې تنظیم شوې ده.';

  @override
  String get biometricEnterCredsFirst =>
      'لومړی خپل بریښنالیک او پټنوم ولیکئ، بیا بیومټریک ننوتل فعال کړئ.';

  @override
  String get biometricLoginFailed =>
      'بیومټریک ننوتل ناکام شو. مهرباني وکړئ د خپل پټنوم سره ننوځئ.';

  @override
  String get biometricEnrollTitle => 'بیومټریک ننوتل فعال کړئ؟';

  @override
  String get biometricEnrollBody =>
      'راتلونکی ځل د چټک ننوتلو لپاره Face ID یا خپله د ګوتې نښه وکاروئ.';

  @override
  String get biometricEnrollYes => 'فعال کړئ';

  @override
  String get biometricEnrollNo => 'اوس نه';

  @override
  String get loginWelcomeTitle => 'بیرته ښه راغلاست';

  @override
  String get loginWelcomeSubtitle => 'خپل ClassMate حساب ته ننوځئ.';

  @override
  String get loginSigningIn => 'ننوتل...';

  @override
  String get loginEmailLabel => 'بریښنالیک یا د کارن نوم';

  @override
  String get loginPasswordLabel => 'پټنوم';

  @override
  String get profileNotAvailable => 'شتون نلري';

  @override
  String get profileSchoolInfo => 'د ښوونځي معلومات';

  @override
  String get profileFullName => 'بشپړ نوم';

  @override
  String get profileRole => 'رول';

  @override
  String get profileSchoolId => 'د ښوونځي ID';

  @override
  String get profileCohortId => 'د ډلې ID';

  @override
  String get profileMyCohorts => 'زما ډلې';

  @override
  String get profileMyCohortsEmpty =>
      'تاسو تر اوسه په هیڅ ډله کې نوم نه دی لیکلی.';

  @override
  String get profileAccountInfo => 'د حساب معلومات';

  @override
  String get profileUsername => 'د کارن نوم';

  @override
  String get profileUsernameHint => 'your_username';

  @override
  String get profileContactEmail => 'د اړیکې بریښنالیک';

  @override
  String get profileEmailAddress => 'د بریښنالیک پته';

  @override
  String get profileEmailHint => 'you@example.com';

  @override
  String get profileBirthday => 'د زیږون ورځ';

  @override
  String get profileSecurity => 'امنیت';

  @override
  String get profileSelectBirthday => 'خپله د زیږون ورځ وټاکئ';

  @override
  String get profilePasswordUpdated => 'پټنوم تازه شو';

  @override
  String get profileSave => 'خوندي کول';

  @override
  String get profileEmptyValue => '—';

  @override
  String get profileChangePassword => 'پټنوم بدل کړئ';

  @override
  String get profileCurrentPassword => 'اوسنی پټنوم';

  @override
  String get profileNewPassword => 'نوی پټنوم';

  @override
  String get profileConfirmNewPassword => 'نوی پټنوم تایید کړئ';

  @override
  String get profileUpdatePassword => 'پټنوم تازه کړئ';

  @override
  String get profilePasswordAllFieldsRequired => 'ټول ساحې اړینې دي';

  @override
  String get profilePasswordMinLength => 'نوی پټنوم باید لږ تر لږه ۸ توري وي';

  @override
  String get profilePasswordMismatch => 'پټنومونه سره سمون نه خوري';

  @override
  String get profilePasswordNotAuthenticated => 'تصدیق شوی نه دی';

  @override
  String get profilePasswordIncorrect => 'اوسنی پټنوم سم نه دی';

  @override
  String get profilePasswordGenericError =>
      'یو څه ناسم شول. مهرباني وکړئ بیا هڅه وکړئ.';

  @override
  String get editProfileTitle => 'پروفايل سمول';

  @override
  String get editProfileSchool => 'ښوونځی';

  @override
  String get editProfileSchoolPublic => 'ښوونځی عامه';

  @override
  String get editProfileGradePublic => 'ټولګی عامه';

  @override
  String get editProfileMajors => 'اصلي مضامین';

  @override
  String get editProfileMajorsPublic => 'اصلي مضامین عامه';

  @override
  String get editProfileBio => 'ژوندلیک';

  @override
  String get editProfileBioPublic => 'ژوندلیک عامه';

  @override
  String get editProfileStatus => 'حالت';

  @override
  String get editProfileStatusPublic => 'حالت عامه';

  @override
  String get classroomsYourClassrooms => 'ستاسو ټولګيونه';

  @override
  String get classroomsReorder => 'ټولګيونه بیا ترتیب کړئ';

  @override
  String classroomsCount(Object count) {
    return '$count ټولګيونه';
  }

  @override
  String get classroomsSearchHint => 'ټولګيونه ولټوئ';

  @override
  String get classroomsNoSearchMatches =>
      'هیڅ ټولګی ستاسو له لټون سره سمون نه خوري';

  @override
  String get classroomsClassroomLabel => 'ټولګی';

  @override
  String get classroomsLoadingLatestMessage => 'وروستی پیغام بارېږي...';

  @override
  String get classroomsTapToOpen => 'د ټولګي د پرانستلو لپاره کېکاږئ';

  @override
  String get classroomsNoMessagesYet => 'تر اوسه هیڅ پیغام نشته';

  @override
  String get classroomsMessageFallback => 'پیغام';

  @override
  String get examsLoadError => 'ازموینې یا فورمې بار نشوې';

  @override
  String get examsAllFilter => 'ټول';

  @override
  String get examsFormsSubtitle =>
      'د ټولګي فورمې، د ځوابونو وختونه، او ستاسو د ښوونځي لخوا خپاره شوي تعقیبونه وګورئ.';

  @override
  String get examsOnlySubtitle =>
      'د خپلو ټولګیو راتلونکې ارزونې، شمیرنې، او د تېرو ازموینو ریکارډونه تعقیب کړئ.';

  @override
  String get examsUpcomingStat => 'راتلونکې ازموینې';

  @override
  String get examsOpenFormsStat => 'خلاصې فورمې';

  @override
  String get examsCountdownPast => 'تېرې';

  @override
  String get examsCountdownTomorrow => 'سبا';

  @override
  String examsCountdownInDays(Object days) {
    return 'په $days ورځو کې';
  }

  @override
  String get examsNoExamsPublished => 'تر اوسه هیڅ ازموینه نه ده خپره شوې.';

  @override
  String get examsNoFormsPublished => 'تر اوسه هیڅ فورمه نه ده خپره شوې.';

  @override
  String examsNoExamsForFilter(Object subject) {
    return 'همدا اوس د $subject لپاره هیڅ ازموینه شتون نلري.';
  }

  @override
  String examsNoFormsForFilter(Object subject) {
    return 'همدا اوس د $subject لپاره هیڅ فورمه شتون نلري.';
  }

  @override
  String examsMaterialsCount(Object count) {
    return '$count موادونه';
  }

  @override
  String get examsOpenState => 'خلاص';

  @override
  String get examsClosedState => 'تړل شوی';

  @override
  String examsQuestionsCount(Object count) {
    return '$count پوښتنې';
  }

  @override
  String examsResponsesCount(Object count) {
    return '$count ځوابونه';
  }

  @override
  String get insightsTrendBaseline => 'بنسټ';

  @override
  String get insightsTrendImproving => 'ښه کېدونکی';

  @override
  String get insightsTrendDropping => 'ښکته کېدونکی';

  @override
  String get insightsTrendStable => 'ثابت';

  @override
  String get insightsHeadlineIntervention => 'د مداخلې وخت خلاص دی';

  @override
  String get insightsHeadlineSignals => 'څو نښې سمولو ته اړتیا لري';

  @override
  String get insightsHeadlineMomentum => 'حرکت کولی شي دا اونۍ زیات شي';

  @override
  String get insightsBodyAttendance =>
      'لومړی حاضري وساتئ. اوس ښه شتون به هره بله نښه ژر لوړه کړي.';

  @override
  String insightsBodyWeakTrend(Object subject) {
    return '$subject او د تمرین ښکته کېدونکی روند همدا اوس ترټولو لوی خطرناک ترکیب دی. د پراختیا دمخه دا سم کړئ.';
  }

  @override
  String insightsBodyLeverage(Object subject) {
    return '$subject ستاسو د قوت ټکی دی. له دې څخه ګټه واخلئ چې اعتماد جوړ کړئ پداسې حال کې چې کمزوري برخې سموئ.';
  }

  @override
  String get insightsBodyConsistency =>
      'لنډ متمرکز ناستې جوړوئ. راتلونکې څو ورځې له بشپړ اوږدمهاله پلان څخه ډیر مهمې دي.';

  @override
  String get insightsInterventionScoreTitle => 'د مداخلې نمره';

  @override
  String insightsInterventionScoreBody(Object count) {
    return '$count فعالې نښې ستاسو راتلونکی حرکت جوړوي.';
  }

  @override
  String get insightsRecoveryPathTitle => 'د ژغورنې ترټولو ګړندۍ لار';

  @override
  String get insightsRecoveryPathDefault => 'لومړی حاضري + دوام.';

  @override
  String insightsRecoveryPathTopic(Object topic, Object subject) {
    return 'د نور هڅې کولو دمخه $topic په $subject کې بیا وګورئ.';
  }

  @override
  String get insightsProjectedDirectionTitle => 'اټکل شوې لوري';

  @override
  String insightsProjectedDirectionBody(Object trend) {
    return '$trend د وروستي ۷ ورځو په پرتله د ۳۰ ورځو د تمرین چلند پر بنسټ.';
  }

  @override
  String get insightsLoadingTitle => 'کتنې بارېږي';

  @override
  String get insightsLoadingSubtitle => 'ستاسو د وړاندوینې ډشبورډ جوړېږي.';

  @override
  String get insightsNotReadyTitle => 'کتنې تر اوسه چمتو نه دي';

  @override
  String get insightsEmptyTitle => 'تر اوسه هیڅ کتنه نشته';

  @override
  String get insightsEmptySubtitle =>
      'تمرین او د خپل ښوونځي وسایل کارول دوام ورکړئ ترڅو ClassMate وکولی شي روښانه علمي انځور جوړ کړي.';

  @override
  String get insightsGradeAverage => 'د نمرو منځنۍ';

  @override
  String get insightsAccuracy => 'دقت';

  @override
  String get insightsOpenNova => 'NOVA پرانیزئ';

  @override
  String get insightsOpenNovaPrompt =>
      'زما د وروستیو ClassMate کتنو پر بنسټ زما د کمزورې برخې په سمولو کې مرسته وکړه.';

  @override
  String get insightsPredictiveRecoveryPlanTitle => 'د وړاندوینې د ژغورنې پلان';

  @override
  String get insightsPracticeNow => 'همدا اوس تمرین وکړئ';

  @override
  String get insightsPredictiveModulesTitle => 'د وړاندوینې ماډلونه';

  @override
  String get insightsPredictiveModulesSubtitle =>
      'ستاسو د اوسني زده‌کوونکي معلوماتو څخه ترټولو پیاوړې مخکې لیدونکې نښې.';

  @override
  String get insightsAnnouncementsPressureTitle => 'د اعلانونو فشار';

  @override
  String get insightsAnnouncementsPressureSubtitle =>
      'د اعلانونو انجن اوس مستقیماً ډشبورډ ته معلومات ورکوي.';

  @override
  String get insightsAiCoachTitle => 'د AI روزونکي لنډیز';

  @override
  String get insightsAiCoachLoadingSubtitle => 'د AI لارښوونه بارېږي.';

  @override
  String get insightsAiCoachUnavailableSubtitle =>
      'د دې حساب لپاره همدا اوس د AI لارښوونه شتون نلري.';

  @override
  String get insightsAskNova => 'له NOVA څخه وپوښتئ';

  @override
  String get insightsAskNovaPrompt =>
      'زما د وروستیو کتنو څخه زما لپاره د ژغورنې پلان جوړ کړه.';

  @override
  String get insightsAiStudyCoachTitle => 'د AI زده‌کړې روزونکی';

  @override
  String get insightsSchoolToolsTitle => 'د ښوونځي وسایل';

  @override
  String get insightsSchoolToolsSubtitle =>
      'مستقیماً هغو زده‌کوونکي لارو ته ورننوځئ چې اوس ترټولو مهمې دي.';

  @override
  String get tutorUntitledChat => 'بې‌سرليکه چټ';

  @override
  String get tutorNewChat => 'نوی چټ';

  @override
  String tutorFailedToOpenSeededChat(Object error) {
    return 'چټ پرانستل ناکام شول: $error';
  }

  @override
  String tutorFailedToCreateChat(Object error) {
    return 'د چټ جوړول ناکام شول: $error';
  }

  @override
  String get tutorRenameChatTitle => 'چټ بیا نومول';

  @override
  String get tutorChatNameHint => 'د چټ نوم';

  @override
  String get tutorCancel => 'لغوه کول';

  @override
  String get tutorHide => 'پټول';

  @override
  String get tutorHideChatTitle => 'چټ پټ کړئ';

  @override
  String get tutorHideChatSubtitle => 'دا چټ په دې وسیله کې پټوي.';

  @override
  String get tutorHideChatConfirmTitle => 'چټ پټ کړئ؟';

  @override
  String get tutorHideChatConfirmBody =>
      'دا چټ په دې وسیله کې له لیست څخه پټوي. ناسته په باطنی سیسټم کې پاتې کېږي.';

  @override
  String get tutorTapToOpenHistory => 'د تاریخچې د پرانستلو لپاره کېکاږئ';

  @override
  String get tutorAiTutorSubtitle => 'ستاسو AI ښوونکی';

  @override
  String get tutorHeroBody => 'ریښتیني د چټ تاریخچه، پاک تارونه، چټکه لاسرسی.';

  @override
  String get tutorStartFreshConversation => 'نوې خبرې اترې پیل کړئ';

  @override
  String get tutorSearchHistoryHint => 'د چټ تاریخچه ولټوئ';

  @override
  String get chatComposerDefaultHint => 'پیغام';

  @override
  String get chatComposerReplyingToMessage => 'پیغام ته ځواب ورکول';

  @override
  String get chatComposerReplyFallback => 'ځواب';

  @override
  String get chatComposerMicHint =>
      'د چټک غږیز یادښت لپاره کېکاږئ یا د ثبت لپاره ونیسئ';

  @override
  String get chatComposerRecordingTitle => 'ثبتول';

  @override
  String get chatComposerReleaseToSend => 'د لېږلو لپاره خوشې کړئ';

  @override
  String get chatComposerCancelTitle => 'لغوه کول';

  @override
  String get chatComposerLockTitle => 'تړل';

  @override
  String get chatComposerSlideLeftToCancel =>
      'د لغوه کولو لپاره کیڼ ته ښکته کړئ';

  @override
  String get chatComposerSlideUpToLock => 'د تړلو لپاره پورته ښکته کړئ';

  @override
  String get chatComposerReleaseToCancel => 'د لغوه کولو لپاره خوشې کړئ';

  @override
  String get chatComposerKeepSlidingToCancel =>
      'د لغوه کولو لپاره ښکته کول دوام ورکړئ';

  @override
  String get chatComposerReleaseToLock => 'د تړلو لپاره خوشې کړئ';

  @override
  String get chatComposerRelease => 'خوشې کول';

  @override
  String get chatComposerLock => 'تړل';

  @override
  String get chatComposerRecordingPaused => 'ثبتول ودرول شول';

  @override
  String get chatComposerRecordingLocked => 'ثبتول وتړل شول';

  @override
  String get chatComposerResumeHint =>
      'کله چې د ثبتولو دوام ته چمتو شئ بیا پیل کړئ';

  @override
  String get chatComposerLockedHint =>
      'کله چې د شریکولو لپاره چمتو شئ لېږل کېکاږئ';

  @override
  String get chatContextDismiss => 'لرې کول';

  @override
  String get chatContextCopyText => 'متن کاپي کول';

  @override
  String get chatContextDelete => 'ړنګول';

  @override
  String get chatMessageInfoShortTitle => 'معلومات';

  @override
  String get chatMessageInfoStatus => 'حالت';

  @override
  String get chatMessageInfoStatusTime => 'د حالت وخت';

  @override
  String get chatMessageInfoSentAt => 'لېږل شوی په';

  @override
  String get chatMessageInfoDeliveredAt => 'ورسېدلی په';

  @override
  String get chatMessageInfoSeenAt => 'لیدل شوی په';

  @override
  String get chatMessageInfoMessageType => 'د پیغام ډول';

  @override
  String get chatMessageInfoTextType => 'متن';

  @override
  String get chatMessageInfoEdited => 'سم شوی';

  @override
  String get chatMessageInfoForwarded => 'لېږدول شوی';

  @override
  String get chatMessageInfoVoiceDuration => 'د غږ موده';

  @override
  String get chatMessageInfoSeenBy => 'لیدل شوی د';

  @override
  String get chatMessageInfoDeliveredTo => 'ورسېدلی تر';

  @override
  String get chatMessageInfoEmptyBody => '(خالي)';

  @override
  String get chatMessageInfoReadLess => 'لږ ولولئ';

  @override
  String get chatMessageInfoReadMore => 'نور ولولئ';

  @override
  String get chatMessageInfoSeen => 'لیدل شوی';

  @override
  String get chatMessageInfoDelivered => 'ورسېدلی';

  @override
  String get chatMessageInfoNotDelivered => 'نه دی ورسېدلی';

  @override
  String get chatMessageInfoSent => 'لېږل شوی';

  @override
  String get chatMessageInfoPending => 'په تمه';

  @override
  String get chatMessageInfoNotSeen => 'نه دی لیدل شوی';

  @override
  String get chatMessageInfoType => 'ډول';

  @override
  String get chatMessageInfoDuration => 'موده';

  @override
  String get chatMessageInfoYes => 'هو';

  @override
  String get chatMessageInfoNo => 'نه';

  @override
  String get chatMessageInfoDeleteState => 'د ړنګولو حالت';

  @override
  String get chatReactionDetailsTitle => 'غبرګونونه';

  @override
  String get chatReactionAddAction => 'غبرګون اضافه کړئ';

  @override
  String get chatReactionEmptyState => 'تر اوسه هیڅ غبرګون نشته';

  @override
  String get chatReactionSingle => 'غبرګون';

  @override
  String get chatReactionTapToRemove => 'د لرې کولو لپاره کېکاږئ';

  @override
  String chatReactionYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' · $count',
      one: '',
    );
    return 'تاسو$_temp0';
  }

  @override
  String chatReactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غبرګونونه',
      one: 'غبرګون',
    );
    return '$_temp0';
  }

  @override
  String get chatEmojiPickerTitle => 'ايموجي وټاکئ';

  @override
  String get chatEmojiPickerSearchHint => 'د ایموجي لټون';

  @override
  String get chatEmojiPickerEmptyState => 'هیڅ ایموجي ونه موندل شو';

  @override
  String get chatCameraTitle => 'کامره';

  @override
  String get chatCameraUseAction => 'وکاروه';

  @override
  String get chatCameraGalleryAction => 'ګالري';

  @override
  String chatCameraSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غوره شوي',
      one: '۱ غوره شو',
      zero: '۰ غوره شوي',
    );
    return '$_temp0';
  }

  @override
  String get chatMediaPreviewEmptyState => 'د کتلو لپاره هیڅ شته نه دي';

  @override
  String get chatMediaPreviewDrawCropAction => 'انځورول او پرېکول';

  @override
  String get chatMediaPreviewRotateLeftAction => 'کیڼ لور ته وګرځوه';

  @override
  String get chatMediaPreviewRotateRightAction => 'ښي لور ته وګرځوه';

  @override
  String get chatMediaPreviewMirrorAction => 'هنداره';

  @override
  String get chatMediaPreviewResetAction => 'بیا تنظیم';

  @override
  String get chatMediaPreviewRemoveAction => 'لرې کړه';

  @override
  String get chatMediaPreviewCaptionHint => 'یو شرح ورزیات کړه...';

  @override
  String tutorPlanSelectedPlaceholder(Object plan) {
    return '$plan غوره شو. تادیات اوس مهال په آزمایشي حالت کې پاتې دي.';
  }

  @override
  String get tutorFailedToLoadChats => 'خبرې اترې نه شوې پورته کېدای';

  @override
  String get tutorNoChatsYet => 'تر اوسه هیڅ خبرې اترې نشته';

  @override
  String get tutorNoChatsMatchSearch =>
      'ستا د لټون سره سمه خبرې اتره ونه موندل شوه';

  @override
  String get tutorCreateFirstChat => 'لومړۍ خبرې اتره جوړه کړه';

  @override
  String get tutorPlansTitle => 'د NOVA پلانونه';

  @override
  String tutorPlansSubtitle(Object model) {
    return 'د $model د لګښت اټکلونو او سختو میاشتنیو حدودو پر بنسټ ترڅو کارونه ګټوره پاتې شي.';
  }

  @override
  String get tutorPlanPriceFree => 'وړیا';

  @override
  String tutorPlanPriceMonthly(Object price) {
    return '\$$price/میاشت';
  }

  @override
  String get tutorPromptsLeft => 'پاتې پوښتنې';

  @override
  String get tutorUploadsLeft => 'پاتې اپلوډونه';

  @override
  String get tutorVoiceLeft => 'پاتې غږ';

  @override
  String tutorUsageValue(Object remaining, Object total) {
    return '$remaining/$total';
  }

  @override
  String tutorVoiceUsageValue(Object remaining, Object total) {
    return '$remaining/$total دقیقې';
  }

  @override
  String get tutorPaymentMethodsTitle => 'د تادیې لارې';

  @override
  String tutorPaymentMethodsSubtitle(Object plan) {
    return 'ترهغه چې د ClassMate بانکي حساب او پروسس کوونکی فعال نه شي، چک‌آوټ یوازې آزمایشي دی. غوره شوی پلان $plan دی.';
  }

  @override
  String get tutorCardCheckoutTitle => 'د کارت چک‌آوټ';

  @override
  String get tutorCardCheckoutSubtitle =>
      'د Visa، Mastercard، AmEx آزمایشي دروازه.';

  @override
  String get tutorApplePayTitle => 'Apple Pay';

  @override
  String get tutorApplePaySubtitle =>
      'د iPhone او ویب لپاره آزمایشي د والټ بهیر.';

  @override
  String get tutorBankTransferTitle => 'بانکي لیږد';

  @override
  String get tutorBankTransferSubtitle =>
      'د ClassMate بانکي حساب تر پروسې لاندې دی. تفصیلات به د پرانیستلو سره ډک شي.';

  @override
  String get tutorPlanStarterName => 'پیلوونکی';

  @override
  String get tutorPlanStarterTagline =>
      'د آزموینې او سپک اوونیز تکرار لپاره بسیا.';

  @override
  String get tutorPlanPlusName => 'پلس';

  @override
  String get tutorPlanPlusTagline =>
      'د یوه جدي زده‌کوونکي لپاره غوره چې ډېرې ورځې NOVA کاروي.';

  @override
  String get tutorPlanProName => 'پرو';

  @override
  String get tutorPlanProTagline =>
      'درنه ورځنۍ کارونه، بشپړ د امتحانونو موسم، او اوږدې مطالعه ناستې.';

  @override
  String get tutorPlanSchoolSeatName => 'د ښوونځي څوکۍ';

  @override
  String get tutorPlanSchoolSeatTagline =>
      'د هر زده‌کوونکي یا کارمند څوکۍ لپاره د یوه ریښتیني ښوونځي دننه.';

  @override
  String tutorPlanBulletPromptsMonthly(Object count) {
    return 'هره میاشت $count د NOVA پوښتنې';
  }

  @override
  String tutorPlanBulletPromptsPerSeatMonthly(Object count) {
    return 'هرې څوکۍ ته میاشتنۍ $count د NOVA پوښتنې';
  }

  @override
  String tutorPlanBulletUploads(Object count) {
    return '$count انځور یا فایل اپلوډونه';
  }

  @override
  String tutorPlanBulletVoiceMinutes(Object count) {
    return '$count د غږ لیکنې دقیقې';
  }

  @override
  String tutorEstimatedCostCeilingFree(Object cost) {
    return 'اټکل شوی د لګښت حد: \$$cost/میاشت';
  }

  @override
  String tutorEstimatedCostCeilingPaid(Object cost, Object margin) {
    return 'اټکل شوی د لګښت حد: \$$cost/میاشت • ګټه $margin%';
  }

  @override
  String tutorTimeMinutesShort(Object count) {
    return '$countد';
  }

  @override
  String tutorTimeHoursShort(Object count) {
    return '$countس';
  }

  @override
  String get tutorVoiceMessageFallback => 'غږیز پیغام';

  @override
  String get tutorFileFallback => 'فایل';

  @override
  String get tutorCopy => 'کاپي';

  @override
  String get tutorEditMessage => 'پیغام سم کړه';

  @override
  String get tutorCopied => 'کاپي شو';

  @override
  String get tutorLoadedIntoComposer => 'په لیکونکي کې پورته شو';

  @override
  String get tutorTakePhoto => 'انځور واخله';

  @override
  String get tutorRecordVideo => 'ویډیو ثبت کړه';

  @override
  String get tutorChooseFromGallery => 'له ګالري څخه وټاکه';

  @override
  String get tutorPreviewTitle => 'مخکتنه';

  @override
  String get tutorThinking => 'فکر کوي...';

  @override
  String get tutorDone => 'ترسره شو.';

  @override
  String get tutorFailedToStreamReply => 'ځواب نه شو راروان کېدای';

  @override
  String get tutorUnsupportedFilesMessage =>
      'NOVA انځورونه، اسناد او متن منلي. ویډیو او غږیز فایلونه دلته نه منل کیږي.';

  @override
  String get tutorNoAudioCaptured => 'هیڅ غږ ونه نیول شو.';

  @override
  String get tutorVoiceLimitReachedTitle => 'د غږ حد پای ته ورسید';

  @override
  String get tutorVoiceLimitReachedMessage =>
      'ستا اوسني د NOVA پلان د دې لیکنې دورې لپاره کافي پاتې د غږ دقیقې نه لري.';

  @override
  String get tutorTranscriptionFailed =>
      'لیکنه ناکامه شوه. مهرباني وکړه بیا هڅه وکړه.';

  @override
  String get tutorMicrophonePermissionRequired => 'د مایکروفون اجازه اړینه ده.';

  @override
  String get tutorPlanLimitReachedTitle => 'د NOVA پلان حد پای ته ورسید';

  @override
  String get tutorPlanLimitReachedMessage =>
      'ستا اوسني د NOVA پلان لپاره د دې میاشتې د پوښتنو یا اپلوډونو سهمیه پای ته ورسیده. د دوام لپاره د NOVA کور په پاڼه کې لوړ پلان غوره کړه.';

  @override
  String get tutorSendFailed => 'لیږل ناکام شو.';

  @override
  String tutorCurrentPlanUsageSummary(
    Object plan,
    Object prompts,
    Object uploads,
    Object voice,
  ) {
    return 'اوسنی پلان: $plan • $prompts پاتې پوښتنې • $uploads پاتې اپلوډونه • $voice پاتې د غږ دقیقې';
  }

  @override
  String get tutorReviewPlansInHome => 'په NOVA کور کې پلانونه وګوره';

  @override
  String get tutorCouldNotOpenAttachment => 'ضمیمه نه شوه پرانیستل کېدای.';

  @override
  String get tutorAttachmentUnavailable => 'ضمیمه شتون نه لري.';

  @override
  String get tutorImageUnavailable => 'انځور شتون نه لري';

  @override
  String get tutorYou => 'ته';

  @override
  String get tutorRegenerate => 'بیا جوړ کړه';

  @override
  String get tutorEmptyStateTitle => 'په یوې ریښتینې پوښتنې پیل وکړه';

  @override
  String get tutorEmptyStateBody =>
      'له NOVA څخه وغواړه چې یو مفهوم تشریح کړي، یادښتونه جدول ته واړوي، نظرونه پرتله کړي، یا له اپلوډ شوي فایل څخه ستا سره په تکرار کې مرسته وکړي.';

  @override
  String get tutorPromptSuggestionSummarizeNotes =>
      'زما د درس یادښتونه لنډ کړه';

  @override
  String get tutorPromptSuggestionRevisionTable => 'د تکرار جدول جوړ کړه';

  @override
  String get tutorPromptSuggestionQuizMe => 'په دې موضوع کې راڅخه پوښتنه وکړه';

  @override
  String get tutorMessageNovaHint => 'NOVA ته پیغام';

  @override
  String get tutorHeaderSubtitleReady =>
      'منظم ځوابونه، جدولونه او د مطالعې مرسته';

  @override
  String get tutorYourNovaPlanTitle => 'ستا د NOVA پلان';

  @override
  String get tutorYourNovaPlanMessage =>
      'دلته د پوښتنو، اپلوډ او غږ حدود وګوره، بیا که د پلان بدلولو هیله لرې NOVA کور ته بیرته لاړ شه.';

  @override
  String get tutorExplainTitle => 'NOVA تشریح';

  @override
  String get classroomsThreadTypeClassroom => 'ټولګی';

  @override
  String get classroomsThreadTypeGroup => 'ګروپ';

  @override
  String get classroomsThreadTypeDirectMessage => 'مستقیم پیغام';

  @override
  String get classroomsThreadTypeDirectMessageShort => 'DM';

  @override
  String get messagesBlockedPeopleTitle => 'بلاک شوي خلک';

  @override
  String get messagesStartChatAction => 'خبرې اترې پیل کړه';

  @override
  String messagesLoadFailed(Object error) {
    return 'پیغامونه نه شول پورته کېدای: $error';
  }

  @override
  String get messagesSearchHint => 'د پیغامونو لټون';

  @override
  String get messagesNoResults => 'هیڅ پیغام ونه موندل شو';

  @override
  String get messagesRequestsSection => 'غوښتنې';

  @override
  String get messagesPendingApprovals => 'په تمه منظورۍ';

  @override
  String get messagesChatsSection => 'خبرې اترې';

  @override
  String get messagesAllChatsSection => 'ټولې خبرې اترې';

  @override
  String messagesConversationCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count خبرې اترې',
      one: '۱ خبرې اتره',
    );
    return '$_temp0';
  }

  @override
  String get messagesRequestReviewStatus => 'بیاکتنه';

  @override
  String messagesPeopleLoadFailed(Object error) {
    return 'خلک نه شول پورته کېدای: $error';
  }

  @override
  String get messagesSearchPeopleHint => 'د خلکو لټون';

  @override
  String get messagesNewGroupTitle => 'نوی ګروپ';

  @override
  String get messagesNewGroupSubtitle => 'د ګروپ خبرې اترې جوړې کړه';

  @override
  String get messagesGroupNameHint => 'د ګروپ نوم';

  @override
  String get messagesCreateGroupAction => 'ګروپ جوړ کړه';

  @override
  String get messagesGroupMinMembers => 'Select at least 2 people for a group';

  @override
  String get messagesBlockedPersonFallback => 'دا کس';

  @override
  String get messagesUnblockPersonTitle => 'کس آن‌بلاک کړو؟';

  @override
  String messagesUnblockPersonBody(Object name) {
    return '$name ته اجازه ورکړو چې بیا تاته پیغام درکړي؟';
  }

  @override
  String get messagesUnblockAction => 'آن‌بلاک';

  @override
  String messagesUnblockedToast(Object name) {
    return '$name آن‌بلاک شو';
  }

  @override
  String messagesBlockedPeopleLoadFailed(Object error) {
    return 'بلاک شوي خلک نه شول پورته کېدای: $error';
  }

  @override
  String get messagesNoBlockedPeople => 'هیڅ بلاک شوی کس نشته';

  @override
  String get messagesUnknownUser => 'ناپیژندل شوی کاروونکی';

  @override
  String get messagesRequestTitle => 'غوښتنه';

  @override
  String messagesRequestLoadFailed(Object error) {
    return 'غوښتنه نه شوه پورته کېدای: $error';
  }

  @override
  String get messagesRequestBannerIncoming => 'د پیغام غوښتنه';

  @override
  String get messagesRequestBannerOutgoing => 'په تمه منظوري';

  @override
  String get messagesBlockAction => 'بلاک';

  @override
  String get messagesApproveAction => 'منظوره کړه';

  @override
  String get messagesRequestUnlockHint =>
      'خبرې اترې وروسته له هغه خلاصیږي چې اخیستونکی ستا لومړی پیغام منظور کړي.';

  @override
  String get messagesThreadConversationFallback => 'خبرې اترې';

  @override
  String get messagesThreadLeaveGroupTitle => 'ګروپ پرېږدو؟';

  @override
  String get messagesThreadLeaveGroupBody =>
      'ته به له دې ګروپ څخه نور پیغامونه ترلاسه نه کړې.';

  @override
  String get messagesThreadBlockPersonTitle => 'کس بلاک کړو؟';

  @override
  String get messagesThreadBlockPersonBody =>
      'ته به نور د دې کس سره د پیغامونو تبادله ونه کړای شې.';

  @override
  String get messagesThreadPersonFallback => 'کس';

  @override
  String get messagesThreadProfileInfoUnavailable =>
      'د پروفایل معلومات شتون نه لري';

  @override
  String get messagesThreadParticipants => 'ګډونوال';

  @override
  String get messagesThreadPeople => 'خلک';

  @override
  String get messagesThreadDeleteForMe => 'زما لپاره یې ړنګ کړه';

  @override
  String get messagesThreadDeleteForEveryone => 'د ټولو لپاره یې ړنګ کړه';

  @override
  String get messagesThreadDeleteForEveryoneSubtitle =>
      'د ټولو ګډونوالو لپاره یې لرې کوي';

  @override
  String get messagesThreadSending => 'لیږل کیږي…';

  @override
  String get messagesThreadWaitingForApproval => 'د منظورۍ په تمه';

  @override
  String get classroomsForwardSearchHint => 'د خبرو اترو لټون';

  @override
  String get classroomsForwardNewChat => 'نوې خبرې اترې';

  @override
  String classroomsForwardLoadError(Object error) {
    return 'خبرې اترې نه شوې پورته کېدای: $error';
  }

  @override
  String get classroomsForwardNoChatsFound => 'هیڅ خبرې اترې ونه موندل شوې';

  @override
  String get classroomsForwardSectionClassrooms => 'ټولګي';

  @override
  String get classroomsForwardSectionDirectMessages => 'مستقیم پیغامونه';

  @override
  String get classroomsForwardCancel => 'لغوه';

  @override
  String get classroomsForwardAction => 'ولیږه';

  @override
  String classroomsForwardCount(Object count) {
    return 'ولیږه ($count)';
  }

  @override
  String get markRead => 'لوستل شوی وټاکه';

  @override
  String get markUnread => 'نالوستی وټاکه';

  @override
  String get markAllRead => 'ټول لوستل شوي وټاکه';

  @override
  String get filters => 'فلټرونه';

  @override
  String get source => 'سرچینه';

  @override
  String get state => 'حالت';

  @override
  String get allSources => 'ټولې سرچینې';

  @override
  String get allStates => 'ټول حالتونه';

  @override
  String get unread => 'نالوستی';

  @override
  String get read => 'لوستل شوی';

  @override
  String get clear => 'پاک کړه';

  @override
  String get today => 'نن';

  @override
  String get yesterday => 'پرون';

  @override
  String get thisWeek => 'دا اوونۍ';

  @override
  String get earlier => 'مخکې';

  @override
  String get openDetails => 'تفصیلات پرانیزه';

  @override
  String get total => 'ټول';

  @override
  String get local => 'محلي';

  @override
  String get server => 'سرور';

  @override
  String get notificationsSourceSystem => 'سیسټم';

  @override
  String get notificationsHeroSubtitleStudent =>
      'ستا د خبرتیاوو مرکز د اعلانونو، د سرور تازه معلوماتو، او ګټورو علمي فعالیتونو لپاره کله چې پیښیږي.';

  @override
  String get notificationsHeroSubtitleTeacher =>
      'ستا د ښوونکي د خبرتیاوو مرکز د اعلانونو، د سرور تازه معلوماتو، او د ښوونځي فعالیتونو لپاره کله چې پیښیږي.';

  @override
  String get notificationsFiltersSubtitle =>
      'د چټک تنظیم لپاره د سرچینې یا لوستلو حالت له مخې تمرکز وکړه.';

  @override
  String get notificationsSearchSourcesHint => 'د سرچینو لټون';

  @override
  String notificationsShowingSummary(Object shown, Object total) {
    return 'د $total څخه $shown خبرتیاوې ښودل کیږي.';
  }

  @override
  String get notificationsEmptyForAccount =>
      'د دې حساب لپاره اوس مهال هیڅ خبرتیاوې شتون نه لري.';

  @override
  String get notificationsEmptyFiltered =>
      'اوس مهال هیڅ خبرتیا د دې فلټرونو سره سمون نه لري. د بشپړ فید لیدلو لپاره فلټرونه پاک کړه.';

  @override
  String get notificationsEmpty => 'اوس مهال هیڅ خبرتیاوې شتون نه لري.';

  @override
  String get notificationsNewBadge => 'نوی';

  @override
  String get notificationsUnavailable =>
      'دا خبرتیا نوره شتون نه لري. د انباکس تازه کولو لپاره راکش کړه او بیا هڅه وکړه.';

  @override
  String get notificationsSeverityCritical => 'بحراني';

  @override
  String get notificationsSeverityWarning => 'خبرداری';

  @override
  String get notificationsSeverityInfo => 'معلومات';

  @override
  String get announcementsLoadError =>
      'موږ اوس مهال اعلانونه نه شو پورته کولای. د تازه کولو لپاره راکش کړه یا بیا هڅه وکړه.';

  @override
  String get announcementsLoadTimeout =>
      'اعلانونه د پورته کیدو لپاره ډېر وخت نیسي. د تازه کولو لپاره راکش کړه یا یوه شیبه وروسته بیا هڅه وکړه.';

  @override
  String get announcementsLoadNetwork =>
      'اعلانونه اوس مهال نه شول وصل کېدای. خپله اړیکه وګوره او بیا هڅه وکړه.';

  @override
  String get teacherDeleteClassroom => 'ټولګی ړنګ کړئ';

  @override
  String get teacherDeleteClassroomConfirm =>
      'دا ټولګی او ټول چټ، دندې، مواد، غونډې او د غړو لیست یې د تل لپاره ړنګوي. دا بیرته نه راګرځي.';

  @override
  String get teacherClassroomDeleted => 'ټولګی ړنګ شو';

  @override
  String get announcementsTabReceived => 'ترلاسه شوي';

  @override
  String get announcementsTabPublished => 'خپاره شوي';

  @override
  String get announcementsAudienceTeacher => 'ښوونکی';

  @override
  String get announcementsAudienceAccount => 'حساب';

  @override
  String get announcementsAudienceTeacherWorkspace => 'د ښوونکي کاري ځای';

  @override
  String get announcementsLoadFailedTitle => 'اعلانونه نه شول پورته کېدای';

  @override
  String get announcementsLoadFailedHint =>
      'وروسته له هغه چې اړیکه ثابته شي د تازه کولو لپاره راکش کړه.';

  @override
  String announcementsHeroSubtitle(Object audience) {
    return 'د دې $audience لپاره شته خپاره شوي د ښوونځي، ښوونکي او سیسټم اعلانونه.';
  }

  @override
  String get announcementsLatestSourceLabel => 'وروستۍ سرچینه';

  @override
  String get announcementsNone => 'هیڅ';

  @override
  String announcementsUnreadCountTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نالوستي اعلانونه',
      one: '۱ نالوستی اعلان',
    );
    return '$_temp0';
  }

  @override
  String get announcementsAllReadTitle => 'هر څه لوستل شوي دي';

  @override
  String announcementsEmptyForAudience(Object audience) {
    return 'تر اوسه دې $audience ته هیڅ اعلان نه دی خپور شوی.';
  }

  @override
  String announcementsLatestBody(Object title) {
    return 'وروستی: $title. د بشپړ منځپانګې لوستلو لپاره پرې ټک وکړه.';
  }

  @override
  String get announcementsFiltersSubtitle =>
      'انباکس د سرچینې یا د لوستلو حالت له مخې محدود کړه ترڅو په هغه څه تمرکز وکړې چې لا پاملرنې ته اړتیا لري.';

  @override
  String get announcementsAllAnnouncements => 'ټول اعلانونه';

  @override
  String get announcementsSearchStatesHint => 'نالوستی / لوستل شوی';

  @override
  String announcementsSummarySourceSegment(Object source) {
    return ' له $source';
  }

  @override
  String announcementsSummaryStateSegment(Object state) {
    return ' په $state';
  }

  @override
  String announcementsShowingSummary(
    Object shown,
    Object total,
    Object sourceSegment,
    Object stateSegment,
  ) {
    return 'د $total څخه $shown اعلانونه$sourceSegment$stateSegment ښودل کیږي.';
  }

  @override
  String get announcementsNoMatchTitle =>
      'هیڅ اعلان د دې فلټرونو سره سمون نه لري';

  @override
  String get announcementsNoPublishedTitle => 'تر اوسه هیڅ خپور شوی اعلان نشته';

  @override
  String get announcementsNoMatchSubtitle =>
      'بله سرچینه هڅه وکړه یا بیرته ټولو اعلانونو ته واوړه ترڅو نور توکي راڅرګند شي.';

  @override
  String get announcementsClearFiltersHint =>
      'د هر څه بیا لیدلو لپاره فلټرونه پاک کړه.';

  @override
  String get announcementsPullToRefreshHint =>
      'وروسته له هغه چې د ښوونځي نوی فعالیت خپور شي د تازه کولو لپاره راکش کړه.';

  @override
  String get announcementsInboxTitle => 'انباکس';

  @override
  String get announcementsInboxSubtitle =>
      'دلته یوازې سرلیکونه د چټک کتنې لپاره ښکاري. د بشپړ اعلان منځپانګې پرانیستلو لپاره پر هر توکي ټک وکړه.';

  @override
  String get meetingsLoadError =>
      'موږ اوس مهال غونډې نه شو پورته کولای. د تازه کولو لپاره راکش کړه یا بیا هڅه وکړه.';

  @override
  String get meetingsLoadTimeout =>
      'غونډې د پورته کیدو لپاره ډېر وخت نیسي. د تازه کولو لپاره راکش کړه یا یوه شیبه وروسته بیا هڅه وکړه.';

  @override
  String get meetingsLoadNetwork =>
      'غونډې اوس مهال نه شوې وصل کېدای. خپله اړیکه وګوره او بیا هڅه وکړه.';

  @override
  String get meetingsHeroSubtitle =>
      'د ټولګي هره غونډه په یوه پاکه لیدنه کې، له ضمیمه شویو لینکونو سره او د بشپړ سکرین تفصیل پاڼه کله چې متن ته اړتیا لرې.';

  @override
  String get meetingsJoinReadyMetric => 'د ګډون لپاره چمتو';

  @override
  String get meetingsNoLinkMetric => 'هیڅ لینک نشته';

  @override
  String get meetingsNoPostedTitle => 'تر اوسه هیڅ غونډه نه ده خپره شوې';

  @override
  String get meetingsEmptyForAccount =>
      'اوس مهال ستا لپاره هیڅ غونډه نه ده ټاکل شوې. د بیا کتلو لپاره راکش کړه.';

  @override
  String meetingsLatestBody(Object title, Object updatedAt) {
    return '$title په $updatedAt تازه شوه. د ضمیمه شوي لینک او د ټولګي متن لپاره یې پرانیزه.';
  }

  @override
  String get meetingsPullToRefreshHint => 'د بیا کتلو لپاره راکش کړه.';

  @override
  String get meetingsFiltersSubtitle =>
      'لیست د موضوع له مخې یا د دې له مخې محدود کړه چې آیا غونډه دمخه یو لینک لري چې پرانیستلی شې.';

  @override
  String get meetingsAccessLabel => 'لاسرسی';

  @override
  String get meetingsAllMeetings => 'ټولې غونډې';

  @override
  String get meetingsAccessReady => 'د ګډون لپاره چمتو';

  @override
  String get meetingsAccessNoLink => 'هیڅ لینک نشته';

  @override
  String get meetingsAccessNoLinkYet => 'تر اوسه هیڅ لینک نشته';

  @override
  String get meetingsAccessSearchHint =>
      'د ګډون لپاره چمتو / تر اوسه هیڅ لینک نشته';

  @override
  String meetingsSummarySubjectSegment(Object subject) {
    return ' د $subject لپاره';
  }

  @override
  String meetingsSummaryAccessSegment(Object state) {
    return ' په $state';
  }

  @override
  String meetingsShowingSummary(
    Object shown,
    Object total,
    Object subjectSegment,
    Object accessSegment,
  ) {
    return 'د $total څخه $shown غونډې$subjectSegment$accessSegment ښودل کیږي.';
  }

  @override
  String get meetingsNoMatchTitle => 'هیڅ غونډه د دې فلټرونو سره سمون نه لري';

  @override
  String get meetingsNoMatchSubtitle =>
      'ټولې موضوعات هڅه وکړه یا هغه غونډې شامل کړه چې لینک نه لري ترڅو نور پایلې بیرته لیست ته راشي.';

  @override
  String get meetingsListSubtitle =>
      'پر هره غونډه ټک وکړه ترڅو د بشپړ سکرین تفصیل لیدنه پرانیزې او کله چې شتون ولري د هغې ضمیمه لینک ته ودانګې.';

  @override
  String meetingsDateTimeValue(Object date, Object time) {
    return '$date • $time';
  }

  @override
  String meetingsSharedByValue(Object name) {
    return 'د $name لخوا شریک شوی';
  }

  @override
  String get meetingsPreviewFallback =>
      'دا غونډه پرانیزه ترڅو ضمیمه لینک او د ټولګي وروستي تفصیلات وګورې.';

  @override
  String get meetingsNoValidLinkAttached =>
      'تر اوسه هیڅ معتبر د غونډې لینک نه دی ضمیمه شوی.';

  @override
  String get meetingsCouldNotOpenLink => 'د غونډې لینک نه شو پرانیستل کېدای.';

  @override
  String get meetingsNoLinkToCopy =>
      'تر اوسه د کاپي لپاره هیڅ د غونډې لینک نشته.';

  @override
  String get meetingsLinkCopied => 'د غونډې لینک کاپي شو.';

  @override
  String get meetingsUnavailableTitle => 'غونډه شتون نه لري';

  @override
  String get meetingsUnavailableSubtitle =>
      'دا غونډه په اوسني فید کې ونه موندل شوه. ممکن لرې شوې وي یا آفلاین شتون نه لري.';

  @override
  String get meetingsUnavailableHint =>
      'بیرته لاړ شه او د غونډو لیست تازه کړه.';

  @override
  String get meetingsNoLinkAttachedYet => 'تر اوسه هیڅ لینک نه دی ضمیمه شوی';

  @override
  String get meetingsAttachedLinkTitle => 'ضمیمه شوی د غونډې لینک';

  @override
  String get meetingsAttachedLinkMissingBody =>
      'دا غونډه ستا د ټولګي فید کې ښکاري، خو په اوسني د زده‌کوونکي پی‌لوډ کې هیڅ معتبر URL نه دی ضمیمه شوی.';

  @override
  String get meetingsDetailsTitle => 'د غونډې تفصیلات';

  @override
  String get meetingsDetailsSubtitle =>
      'هر هغه څه چې زده‌کوونکي ته اړوند دي او اوس مهال د ټولګي د غونډې پی‌لوډ کې شته دي.';

  @override
  String get meetingsDetailClassroomLabel => 'ټولګی';

  @override
  String get meetingsSharedByLabel => 'شریک شوی لخوا';

  @override
  String get meetingsIdLabel => 'د غونډې ID';

  @override
  String get meetingsAttachedLinkSubtitle =>
      'کله چې ستا ټولګی یې وړاندې کړي د ګډون یا د غونډې لینک کاپي کولو لپاره ضمیمه URL وکاروه.';

  @override
  String get meetingsOpening => 'پرانیستل کیږي';

  @override
  String get meetingsOpenLink => 'لینک پرانیزه';

  @override
  String get meetingsCopyLink => 'لینک کاپي کړه';

  @override
  String get meetingsAccessPanelTitle => 'د غونډې لاسرسی';

  @override
  String get meetingsAccessPanelReadyBody =>
      'ضمیمه URL خپل براوزر یا د غونډې اپ کې پرانیزه.';

  @override
  String get meetingsJoinAction => 'ګډون وکړه';

  @override
  String get announcementsDetailLoadFailedHint =>
      'بیرته لاړ شه او د اعلانونو انباکس تازه کولو هڅه وکړه.';

  @override
  String get announcementsUnavailableTitle => 'اعلان شتون نه لري';

  @override
  String announcementsUnavailableSubtitle(Object audience) {
    return 'دا اعلان نور د دې $audience لپاره په خپور شوي فید کې شتون نه لري.';
  }

  @override
  String get announcementsUnavailableHint =>
      'د دوام لپاره بیرته انباکس ته لاړ شه.';

  @override
  String announcementsPublishedReadStateBody(Object audience) {
    return 'دا اعلان دې $audience ته خپور شوی و او ستا د لوستلو حالت په دې وسیله کې په محلي توګه ساتل کیږي.';
  }

  @override
  String get announcementsDetailsTitle => 'د اعلان تفصیلات';

  @override
  String get announcementsDetailsSubtitle =>
      'د دې اعلان خپره شوې میټاډیټا او د هغې اوسنی د لوستلو حالت.';

  @override
  String get announcementsSeverityLabel => 'شدت';

  @override
  String get announcementsCreatedLabel => 'جوړ شو';

  @override
  String get announcementsIdLabel => 'د اعلان ID';

  @override
  String get announcementsFullContentTitle => 'بشپړه منځپانګه';

  @override
  String get announcementsFullContentSubtitle =>
      'بشپړ د اعلان متن دلته ښکاري وروسته له هغه چې توکی له انباکس څخه پرانیزې.';

  @override
  String get announcementsReadStateTitle => 'د لوستلو حالت';

  @override
  String get announcementsReadStateBodyRead =>
      'دا اعلان په دې وسیله کې لوستل شوی په نښه شوی دی.';

  @override
  String get announcementsReadStateBodyUnread =>
      'دا اعلان لا تر اوسه په دې وسیله کې نالوستی دی.';

  @override
  String get alertsTitle => 'خبرتیاوې';

  @override
  String get alertsSubtitle =>
      'دا د هغو شیانو پاڼه ده چې اوس پاملرنې ته اړتیا لري، نه یوازې عمومي تازه معلومات.';

  @override
  String get alertsAttendanceTitle => 'حاضري پاملرنې ته اړتیا لري';

  @override
  String alertsAttendanceBody(Object rate) {
    return 'ستا د حاضرۍ کچه $rate% ده. څو پرېښودل شوي درسونه ژر زیاتیدلی شي.';
  }

  @override
  String get alertsWeakestSubjectTitle => 'د کمزوري مضمون نښه';

  @override
  String alertsWeakestSubjectBody(Object subject) {
    return '$subject اوس مهال ستا د وروستیو نمرو پر بنسټ ډېرې پاملرنې ته اړتیا لري.';
  }

  @override
  String get alertsPracticeWeakAreaTitle => 'د تمرین کمزورې برخه';

  @override
  String alertsPracticeWeakAreaBody(Object topic, Object subject) {
    return 'په $subject کې $topic اوس مهال ترټولو څرګنده کمزورې موضوع ده.';
  }

  @override
  String get alertsPracticeTrendDroppedTitle => 'د تمرین روند راټیټ شو';

  @override
  String get alertsPracticeTrendDroppedBody =>
      'ستا د ۷ ورځو فعالیت ستا د ۳۰ ورځو معیار څخه ښکته دی. ورو شه او مخکې له دې چې سختي زیاته کړې بنسټیزو شیانو ته بیا وګوره.';

  @override
  String get alertsEmpty =>
      'ته اوس مهال پاک یې. کله چې یو څه بیړنۍ پاملرنې ته اړتیا ولري، دلته به راڅرګند شي.';

  @override
  String get student => 'زده‌کوونکی';

  @override
  String get classroomDetailPhoto => 'انځور';

  @override
  String get classroomDetailVoiceNote => 'غږیز یادښت';

  @override
  String get classroomDetailVideo => 'ویډیو';

  @override
  String get classroomDetailFile => 'فایل';

  @override
  String get classroomDetailEmptyValue => '(تش)';

  @override
  String get classroomDetailAttachmentUnavailable => 'ضمیمه شتون نه لري.';

  @override
  String get classroomDetailAudioUnavailable => 'غږ شتون نه لري.';

  @override
  String get classroomDetailCouldNotOpenAttachment =>
      'ضمیمه نه شوه پرانیستل کېدای.';

  @override
  String get classroomDetailVoiceMessage => 'غږیز پیغام';

  @override
  String get classroomDetailVideoFile => 'ویډیو فایل';

  @override
  String get classroomDetailAttachedFile => 'ضمیمه شوی فایل';

  @override
  String get classroomDetailAttachment => 'ضمیمه';

  @override
  String get classroomDetailPinAction => 'نښلول';

  @override
  String get classroomDetailUnpinAction => 'بې‌نښلول';

  @override
  String get classroomDetailMessageInfoTitle => 'د پیغام معلومات';

  @override
  String get classroomDetailForwardedSingle => 'لیږل شوی';

  @override
  String classroomDetailForwardedMultiple(Object count) {
    return '$count پیغامونه لیږل شوي';
  }

  @override
  String get classroomDetailCannotForwardPending =>
      'د غوښتنې خبرو اترو ته نه شي لیږل کېدای ترڅو منظوره نه شي';

  @override
  String get classroomDetailCouldNotForwardSelected =>
      'غوره شوي پیغامونه نه شول لیږل کېدای';

  @override
  String classroomDetailSelectedCount(Object count) {
    return '$count غوره شوي';
  }

  @override
  String classroomDetailDeleteCount(Object count) {
    return 'ړنګ کړه ($count)';
  }

  @override
  String get classroomDetailSelectAllTooltip => 'ټول وټاکه';

  @override
  String get classroomDetailCancelTooltip => 'لغوه';

  @override
  String get classroomDetailMicrophoneAccessTitle =>
      'د مایکروفون لاسرسي ته اړتیا ده';

  @override
  String get classroomDetailMicrophoneAccessBody =>
      'د غږیزو یادښتونو لیږلو لپاره مهرباني وکړه په Settings -> ClassMate کې د مایکروفون لاسرسي ته اجازه ورکړه.';

  @override
  String get classroomDetailOpenSettingsAction => 'Settings پرانیزه';

  @override
  String classroomDetailForwardTargetNext(Object label) {
    return 'د لیږلو هدف ټاکونکی بل: $label';
  }

  @override
  String get classroomDetailEditMessageTitle => 'پیغام سم کړه';

  @override
  String get classroomDetailEditMessageHint => 'خپل پیغام سم کړه...';

  @override
  String get classroomDetailLeaveClassroomTitle => 'ټولګی پرېږدو؟';

  @override
  String get classroomDetailLeaveClassroomBody =>
      'ته به له دې ټولګي څخه لرې شې.';

  @override
  String get classroomDetailLeaveAction => 'پرېږده';

  @override
  String get classroomDetailNoAssignmentsTitle => 'تر اوسه هیڅ دندې نشته';

  @override
  String get classroomDetailNoAssignmentsSubtitle =>
      'دې ټولګي ته اوس مهال هیڅ دندې نشته.';

  @override
  String get classroomDetailAssignmentFallback => 'دنده';

  @override
  String get classroomDetailNoMaterialsTitle => 'تر اوسه هیڅ مواد نشته';

  @override
  String get classroomDetailNoMaterialsSubtitle =>
      'دې ټولګي ته اوس مهال هیڅ مواد نشته.';

  @override
  String get classroomDetailMaterialFallback => 'ماده';

  @override
  String get classroomDetailNoMeetingsTitle => 'تر اوسه هیڅ غونډې نشته';

  @override
  String get classroomDetailNoMeetingsSubtitle =>
      'دې ټولګي ته اوس مهال هیڅ غونډې نشته.';

  @override
  String get classroomDetailMeetingFallback => 'غونډه';

  @override
  String get classroomDetailCouldNotLoadPeople => 'خلک نه شول پورته کېدای';

  @override
  String get classroomDetailNoPeopleTitle => 'تر اوسه هیڅ خلک نشته';

  @override
  String get classroomDetailNoPeopleSubtitle =>
      'تر اوسه په دې ټولګي کې هیڅوک نه ښکاري.';

  @override
  String get classroomDetailTabChat => 'خبرې اترې';

  @override
  String get classroomDetailTabMaterials => 'مواد';

  @override
  String get classroomDetailTabPeople => 'خلک';

  @override
  String get classroomChatMediaSendPhoto => 'انځور ولیږه';

  @override
  String get classroomChatMediaSendPhotoSubtitle =>
      'د ټولګي خبرو اترو کې یو انځور شریک کړه';

  @override
  String get classroomChatMediaSendVoiceMessage => 'غږیز پیغام ولیږه';

  @override
  String get classroomChatMediaSendVoiceMessageSubtitle =>
      'غږیز یادښت ثبت او ولیږه';

  @override
  String get classroomDetailCouldNotLoadTab => 'ټوب نه شو پورته کېدای';

  @override
  String get classroomDetailDeletedByYou => 'تا دا پیغام ړنګ کړ';

  @override
  String get classroomDetailDeletedMessage => 'دا پیغام ړنګ شو';

  @override
  String get practiceSetupDifficultyEasy => 'اسانه';

  @override
  String get practiceSetupDifficultyMedium => 'منځنی';

  @override
  String get practiceSetupDifficultyHard => 'ګران';

  @override
  String get practiceSetupDifficultyOlympiad => 'اولمپیاد';

  @override
  String get practiceSetupDifficultyAdaptive => 'تطبیقي';

  @override
  String get practiceSetupModeLabelPractice => 'تمرین';

  @override
  String get practiceSetupModeLabelFlashcards => 'فلش‌کارتونه';

  @override
  String get practiceSetupModeLabelSpeedRound => 'د چټکۍ پړاو';

  @override
  String get practiceSetupModeLabelExamPrep => 'د امتحان چمتووالی';

  @override
  String get practiceSetupModeLabelConceptBuilder => 'د مفهوم جوړونکی';

  @override
  String get practiceSetupModeLabelAdaptive => 'تطبیقي';

  @override
  String get practiceSetupModeLabelBagrut => 'Bagrut';

  @override
  String get practiceSetupModeSubtitlePractice => 'متوازن ورځنی تمرین';

  @override
  String get practiceSetupModeSubtitleFlashcards => 'ښکاره کول او خپله یادول';

  @override
  String get practiceSetupModeSubtitleSpeedRound => 'د چټک فشار تمرین';

  @override
  String get practiceSetupModeSubtitleExamPrep =>
      'د ازموینې په سبک کې آرام بهیر';

  @override
  String get practiceSetupModeSubtitleConceptBuilder => 'لومړی مفهوم، بیا حل';

  @override
  String get practiceSetupModeSubtitleAdaptive => 'ستونزمنتیا ژوندۍ بدلیږي';

  @override
  String get practiceSetupModeSubtitleBagrut => 'دقیق رسمي سبک';

  @override
  String get practiceSetupModeHelpPractice =>
      'متوازن حالت: حل کړه، وګوره، تشریح کړه، بیا مخکې لاړ شه.';

  @override
  String get practiceSetupModeHelpFlashcards =>
      'فلش کارتونه هغه وخت ښه کار کوي چې له ښودلو مخکې هڅه وکړې ترې یاد کړې.';

  @override
  String get practiceSetupModeHelpSpeedRound =>
      'د سرعت پړاو چټک یادونه روزي. ګړندی حرکت وکړه او په پیاوړو دریځونو باور وکړه.';

  @override
  String get practiceSetupModeHelpExamPrep =>
      'د ازموینې چمتووالی آرامه او رسمي دی، لکه د ښوونځي اصلي ناسته.';

  @override
  String get practiceSetupModeHelpConceptBuilder =>
      'مفهوم جوړونکی لومړی نظریه ښوونه کوي، بیا غواړي چې هغه پلي کړې.';

  @override
  String get practiceSetupModeHelpAdaptive =>
      'تطبیقي حالت ستا د کړنو پر بنسټ د ننګونې کچه بدلوي.';

  @override
  String get practiceSetupModeHelpBagrut =>
      'د بګروت حالت په دقیقه ازموینه‌یي ډول پر حل او بیاکتنه تمرکز کوي.';

  @override
  String get practiceSetupModeInfoTitle => 'هر حالت څنګه کار کوي';

  @override
  String get practiceSetupHeroTitle => 'یوه ناسته پیل کړه';

  @override
  String get practiceSetupHeroSubtitle =>
      'یو حالت، وخت او ستونزمنتیا غوره کړه.';

  @override
  String get practiceSetupInfiniteLives => 'بې شمېره ژوندونه';

  @override
  String practiceSetupLivesCount(Object count) {
    return '$count ژوندونه';
  }

  @override
  String get practiceSetupAiTiming => 'د AI وخت';

  @override
  String practiceSetupSecondsShort(Object seconds) {
    return '$secondsث';
  }

  @override
  String practiceSetupQuestionsCount(Object count) {
    return '$count پوښتنې';
  }

  @override
  String practiceSetupSummarySubject(Object subject) {
    return 'مضمون: $subject';
  }

  @override
  String practiceSetupSummaryTopic(Object topic) {
    return 'موضوع: $topic';
  }

  @override
  String practiceSetupSummaryMode(Object mode) {
    return 'حالت: $mode';
  }

  @override
  String practiceSetupSummaryDifficulty(Object difficulty) {
    return 'ستونزمنتیا: $difficulty';
  }

  @override
  String practiceSetupSummaryQuestions(Object count) {
    return 'پوښتنې: $count';
  }

  @override
  String practiceSetupSummaryTiming(Object timing) {
    return 'وخت: $timing';
  }

  @override
  String practiceSetupSummaryLives(Object lives) {
    return 'ژوندونه: $lives';
  }

  @override
  String get practiceSetupSectionSubjectTopic => 'مضمون او موضوع';

  @override
  String get practiceSetupFieldSubject => 'مضمون';

  @override
  String get practiceSetupFieldSubjectHint => 'مضمون وټاکه';

  @override
  String get practiceSetupChooseSubject => 'مضمون غوره کړه';

  @override
  String get practiceSetupFieldCustomSubject => 'خپل مضمون';

  @override
  String get practiceSetupFieldCustomSubjectHint => 'خپل مضمون ولیکه';

  @override
  String get practiceSetupDialogCustomSubjectTitle => 'خپل مضمون';

  @override
  String get practiceSetupDialogEnterSubject => 'مضمون دننه کړه';

  @override
  String get practiceSetupUseAction => 'وکاروه';

  @override
  String get practiceSetupFieldTopic => 'موضوع';

  @override
  String get practiceSetupFieldTopicHint => 'فرعي موضوع وټاکه';

  @override
  String get practiceSetupChooseTopic => 'موضوع غوره کړه';

  @override
  String get practiceSetupFieldCustomTopic => 'خپله موضوع';

  @override
  String get practiceSetupFieldCustomTopicHint => 'خپله موضوع ولیکه';

  @override
  String get practiceSetupDialogCustomTopicTitle => 'خپله موضوع';

  @override
  String get practiceSetupDialogEnterTopic => 'موضوع دننه کړه';

  @override
  String get practiceSubjectMath => 'ریاضي';

  @override
  String get practiceSubjectPhysics => 'فزیک';

  @override
  String get practiceSubjectComputerScience => 'کمپیوټر ساینس';

  @override
  String get practiceSubjectChemistry => 'کیمیا';

  @override
  String get practiceSubjectBiology => 'بیولوژي';

  @override
  String get practiceSubjectEnglish => 'انګلیسي';

  @override
  String get practiceSubjectArabic => 'عربي';

  @override
  String get practiceSubjectHebrew => 'عبري';

  @override
  String get practiceSubjectGeneralKnowledge => 'عمومي پوهه';

  @override
  String get practiceTopicAllTopics => 'ټولې موضوعات';

  @override
  String get practiceTopicAlgebra => 'الجبر';

  @override
  String get practiceTopicLinearEquations => 'خطي معادلې';

  @override
  String get practiceTopicQuadraticEquations => 'تربیعي معادلې';

  @override
  String get practiceTopicFunctions => 'فنکشنونه';

  @override
  String get practiceTopicGeometry => 'هندسه';

  @override
  String get practiceTopicTriangles => 'مثلثونه';

  @override
  String get practiceTopicCircles => 'دایرې';

  @override
  String get practiceTopicAnalyticGeometry => 'تحلیلي هندسه';

  @override
  String get practiceTopicTrigonometry => 'مثلثات';

  @override
  String get practiceTopicProbability => 'احتمال';

  @override
  String get practiceTopicStatistics => 'احصایه';

  @override
  String get practiceTopicSequences => 'ترتیبونه';

  @override
  String get practiceTopicCalculus => 'حساب التفاضل';

  @override
  String get practiceTopicLimits => 'حدونه';

  @override
  String get practiceTopicDerivatives => 'مشتقات';

  @override
  String get practiceTopicMechanics => 'میخانیک';

  @override
  String get practiceTopicKinematics => 'سینماتیک';

  @override
  String get practiceTopicNewtonLaws => 'د نیوټن قوانین';

  @override
  String get practiceTopicForces => 'قوې';

  @override
  String get practiceTopicEnergy => 'انرژي';

  @override
  String get practiceTopicMomentum => 'اندازه حرکت';

  @override
  String get practiceTopicElectricity => 'برق';

  @override
  String get practiceTopicElectricField => 'برقي ساحه';

  @override
  String get practiceTopicCircuits => 'برقي دورې';

  @override
  String get practiceTopicWaves => 'څپې';

  @override
  String get practiceTopicOptics => 'بصریات';

  @override
  String get practiceTopicThermodynamics => 'ترمودینامیک';

  @override
  String get practiceTopicConditions => 'شرطونه';

  @override
  String get practiceTopicBooleanLogic => 'بولین منطق';

  @override
  String get practiceTopicIfElse => 'که / نه';

  @override
  String get practiceTopicNestedConditions => 'ځاله‌یي شرطونه';

  @override
  String get practiceTopicLoops => 'لوپونه';

  @override
  String get practiceTopicVariables => 'متغیرونه';

  @override
  String get practiceTopicArrays => 'ارې‌ګانې';

  @override
  String get practiceTopicStrings => 'تارونه';

  @override
  String get practiceTopicAlgorithms => 'الګوریتمونه';

  @override
  String get practiceTopicComplexity => 'پېچلتیا';

  @override
  String get practiceTopicRecursion => 'تکراري بلنه';

  @override
  String get practiceTopicAtoms => 'اتومونه';

  @override
  String get practiceTopicPeriodicTable => 'دوریز جدول';

  @override
  String get practiceTopicChemicalBonds => 'کیمیاوي بندونه';

  @override
  String get practiceTopicReactions => 'تعاملات';

  @override
  String get practiceTopicStoichiometry => 'ستوکیومتري';

  @override
  String get practiceTopicAcidsAndBases => 'تېزابونه او بنسټونه';

  @override
  String get practiceTopicOrganicChemistry => 'عضوي کیمیا';

  @override
  String get practiceTopicCells => 'حجرې';

  @override
  String get practiceTopicGenetics => 'جنیتیک';

  @override
  String get practiceTopicHumanBody => 'د انسان بدن';

  @override
  String get practiceTopicEcology => 'چاپېریال پوهنه';

  @override
  String get practiceTopicEvolution => 'تکامل';

  @override
  String get practiceTopicSystems => 'سیستمونه';

  @override
  String get practiceTopicGrammar => 'ګرامر';

  @override
  String get practiceTopicReadingComprehension => 'د لوستلو درک';

  @override
  String get practiceTopicVocabulary => 'لغتونه';

  @override
  String get practiceTopicTenses => 'زمانې';

  @override
  String get practiceTopicWriting => 'لیکنه';

  @override
  String get practiceTopicRhetoric => 'بلاغت';

  @override
  String get practiceSetupSectionMode => 'حالت';

  @override
  String get practiceSetupSectionDifficulty => 'ستونزمنتیا';

  @override
  String get practiceSetupSectionControls => 'د ناستې کنټرولونه';

  @override
  String get practiceSetupQuestionsTitle => 'پوښتنې';

  @override
  String get practiceSetupQuestionsCaption => 'څومره جوړې شوې پوښتنې شاملې شي';

  @override
  String get practiceSetupTimingTitle => 'وخت';

  @override
  String get practiceSetupTimingCaption =>
      'لومړی ساحه وټاکه، بیا AI، خپل وخت، یا بې شمېره.';

  @override
  String get practiceSetupTimingScopePerQuestion => 'هرې پوښتنې لپاره';

  @override
  String get practiceSetupTimingScopeWholeQuiz => 'ټوله ازموینه';

  @override
  String get practiceSetupTimingModeAi => 'AI';

  @override
  String get practiceSetupTimingModeMyTime => 'زما وخت';

  @override
  String get practiceSetupTimingModeInfinite => 'بې شمېره';

  @override
  String get practiceSetupTimingCustomPerQuestionTitle => 'د هرې پوښتنې ثانیې';

  @override
  String get practiceSetupTimingCustomPerQuestionCaption =>
      'د هرې پوښتنې لپاره خپل ټایمر';

  @override
  String get practiceSetupTimingCustomQuizMinutesTitle => 'د ازموینې دقیقې';

  @override
  String get practiceSetupTimingCustomQuizMinutesCaption =>
      'د ټولې ازموینې لپاره خپل ټایمر';

  @override
  String get practiceSetupInfiniteLivesTitle => 'بې شمېره ژوندونه';

  @override
  String get practiceSetupInfiniteLivesSubtitle =>
      'ناسته به د غلطو ځوابونو له امله هیڅکله پای ته ونه رسیږي';

  @override
  String get practiceSetupLivesTitle => 'ژوندونه';

  @override
  String get practiceSetupLivesCaption => 'د ناستې له پای کېدو مخکې جوازې غلطۍ';

  @override
  String get practiceSetupTooltipHistory => 'د تمرین تاریخچه';

  @override
  String get practiceHistoryTitle => 'د تمرین تاریخچه';

  @override
  String get practiceHistoryClearTooltip => 'تاریخچه پاکه کړه';

  @override
  String get practiceHistoryClearConfirmTitle => 'د تمرین تاریخچه پاکه شي؟';

  @override
  String get practiceHistoryClearConfirmBody =>
      'دا به له دې وسیلې څخه ټولې خوندي شوې تمریني ناستې لرې کړي.';

  @override
  String get practiceHistoryLoadError => 'اوس د تمرین تاریخچه نشي پورته کیدی.';

  @override
  String get practiceHistoryErrorPrefix => 'تېروتنه:';

  @override
  String get practiceHistoryEmpty => 'تر اوسه هیڅ تمریني ناسته نشته.';

  @override
  String get practiceHistoryDeleteConfirmTitle => 'دا ناسته ړنګه شي؟';

  @override
  String get practiceHistoryDeleteConfirmBody =>
      'دا یوازې همدا خوندي شوې تمریني ناسته لرې کوي.';

  @override
  String get practiceHistoryOpenReview => 'بیاکتنه پرانیزه';

  @override
  String get practiceHistoryDeleteSession => 'ناسته ړنګه کړه';

  @override
  String get practiceHistoryDebugTitle => 'د تمرین تاریخچې ډیبګ';

  @override
  String get practiceAnalyticsTitle => 'د تمرین تحلیلونه';

  @override
  String get practiceAnalyticsSectionOverall => 'ټولیز';

  @override
  String get practiceAnalyticsRecentSessionsTitle => 'وروستۍ ناستې';

  @override
  String practiceAnalyticsRecentSessionsSummary(
    Object sessions,
    Object correct,
    Object answered,
    Object accuracy,
    Object xp,
  ) {
    return '$sessions ناستې • $correct/$answered سم • $accuracy% • XP $xp';
  }

  @override
  String get practiceAnalyticsSectionWeakestTopics => 'تر ټولو کمزورې موضوعات';

  @override
  String get practiceAnalyticsSectionStrongestTopics =>
      'تر ټولو پیاوړې موضوعات';

  @override
  String get practiceAnalyticsSectionModePerformance => 'د حالت کړنه';

  @override
  String get practiceAnalyticsNoTopicData => 'تر اوسه د موضوع معلومات نشته';

  @override
  String get practiceAnalyticsNoModeData => 'تر اوسه د حالت معلومات نشته';

  @override
  String get savedQuestionsTopSubjectNone => 'تر اوسه هیڅ';

  @override
  String get savedQuestionsHeroSubtitle =>
      'هغه پوښتنې چې د تمرین پر مهال دې خوندي کړې باید بیا کتل یې اسانه وي. دا مخ د هغوی لپاره پاک د بیا هڅې مرکز دی.';

  @override
  String get savedQuestionsSavedMetric => 'خوندي شوې';

  @override
  String get savedQuestionsTopSubjectMetric => 'غوره مضمون';

  @override
  String get savedQuestionsQuickActionsSubtitle =>
      'مستقیماً بیرته تمرین ته لاړ شه یا د ټولنې حلونه وګوره.';

  @override
  String get savedQuestionsOpenPractice => 'تمرین پرانیزه';

  @override
  String get savedQuestionsOpenPracticeSubtitle =>
      'نوې ناسته پیل کړه او خپل حرکت دوام ورکړه';

  @override
  String get savedQuestionsOpenSolutions => 'حلونه پرانیزه';

  @override
  String get savedQuestionsOpenSolutionsSubtitle =>
      'اپلوډ شوي حلونه د مضمون، کتاب، مخ او پوښتنې له مخې وګوره';

  @override
  String get savedQuestionsQueueTitle => 'ستا خوندي شوې قطار';

  @override
  String get savedQuestionsQueueSubtitle =>
      'هغه پوښتنې چې په تمرین کې یې خوندي کوې دلته ښکاري ترڅو ژر یې بیا پرانیزې او خپلې کمزورې برخې کار کوې.';

  @override
  String get savedQuestionsEmptyTitle => 'تر اوسه هیڅ خوندي شوې پوښتنه نشته';

  @override
  String get savedQuestionsEmptySubtitle =>
      'له تمرین څخه یوه پوښتنه خوندي کړه ترڅو وروسته یې بیا وګورې، اړوند حلونه پرانیزې، او هغه موضوعات تعقیب کړې چې لا کار ته اړتیا لري.';

  @override
  String get savedQuestionsClearAction => 'خوندي شوې پوښتنې پاکې کړه';

  @override
  String get savedQuestionsWhyItWorks => 'ولې کار کوي';

  @override
  String savedQuestionsHoursTarget(Object count) {
    return '$count ساعت موخه';
  }

  @override
  String savedQuestionsMinutesTarget(Object count) {
    return '$count دقیقه موخه';
  }

  @override
  String savedQuestionsSecondsTarget(Object count) {
    return '$count ثانیه موخه';
  }

  @override
  String get practiceSetupTooltipAnalytics => 'د تمرین تحلیلونه';

  @override
  String get practiceSetupStopGenerating => 'جوړول ودروه';

  @override
  String get practiceSetupGenerating => 'جوړیږي...';

  @override
  String get practiceSetupStartSession => 'ناسته پیل کړه';

  @override
  String get practiceSetupSearchHint => 'لټون...';

  @override
  String get practiceSessionModeDescriptionPractice =>
      'متوازن حل د سمدستي کتنې او بیاکتنې سره.';

  @override
  String get practiceSessionModeDescriptionFlashcards =>
      'د یادښت لومړۍ حالت چې د چټک یادولو او ساتلو لپاره جوړ شوی.';

  @override
  String get practiceSessionModeDescriptionSpeedRound =>
      'چټک، اسان، د وخت تر فشار لاندې تکرارونه.';

  @override
  String get practiceSessionModeDescriptionExamPrep =>
      'د رسمي ازموینې احساس سره حل، له لږ لوبیزه سرعت سره.';

  @override
  String get practiceSessionModeDescriptionConceptBuilder =>
      'لومړی نظریه پوه شه، بیا یې په شرایطو کې حل کړه.';

  @override
  String get practiceSessionModeDescriptionAdaptive =>
      'ستونزمنتیا ستا د کړنو پر بنسټ بدلیږي.';

  @override
  String get practiceSessionModeDescriptionBagrut =>
      'د رسمي سبک یوه‌پوښتنیزه رسمي بګروت بهیر.';

  @override
  String get practiceSessionLoadingPractice => 'ستا تمریني ناسته جوړیږي';

  @override
  String get practiceSessionLoadingFlashcards => 'ستا فلش کارتونه ګډوډیږي';

  @override
  String get practiceSessionLoadingSpeedRound => 'د سرعت پړاو پیلیږي';

  @override
  String get practiceSessionLoadingExamPrep => 'ستا د ازموینې ناسته چمتو کیږي';

  @override
  String get practiceSessionLoadingConceptBuilder =>
      'د مفهوم روزونکی پورته کیږي';

  @override
  String get practiceSessionLoadingAdaptive => 'ستا ننګونه شخصي کیږي';

  @override
  String get practiceSessionLoadingBagrut => 'ستا د بګروت ټولګه چمتو کیږي';

  @override
  String get practiceSessionLoadingDefault => 'ستا ناسته چمتو کیږي';

  @override
  String practiceSessionCompleteTitle(Object mode) {
    return '$mode بشپړ شو';
  }

  @override
  String get practiceSessionMetricAnswered => 'ځواب شوي';

  @override
  String get practiceSessionMetricCorrect => 'سم';

  @override
  String get practiceSessionMetricWrong => 'غلط';

  @override
  String get practiceSessionMetricAccuracy => 'دقت';

  @override
  String get practiceSessionMetricTotal => 'ټول';

  @override
  String get practiceSessionMetricXp => 'XP';

  @override
  String get practiceSessionMetricStreak => 'پرله‌پسې';

  @override
  String get practiceSessionReviewLayoutStacked => 'پرسره';

  @override
  String get practiceSessionReviewLayoutFocus => 'تمرکز';

  @override
  String get practiceSessionFilterAll => 'ټول';

  @override
  String get practiceSessionFilterWrong => 'غلط';

  @override
  String get practiceSessionFilterCorrect => 'سم';

  @override
  String get practiceSessionReviewTitle => 'د ناستې بیاکتنه';

  @override
  String get practiceSessionNoQuestionsForFilter =>
      'تر اوسه هیڅ پوښتنه له دې فلټر سره سمون نه خوري.';

  @override
  String get practiceSessionNoAnswer => 'ځواب نشته';

  @override
  String get practiceSessionUnknownAnswer => 'نامعلوم';

  @override
  String get practiceSessionReflectionTitle => 'ځان‌ارزونه';

  @override
  String get practiceSessionReflectionKnewIt => 'پوه وم';

  @override
  String get practiceSessionReflectionReviewAgain => 'بیا یې وګوره';

  @override
  String get practiceSessionBackOfCard => 'د کارت شاته';

  @override
  String get practiceSessionYourAnswer => 'ستا ځواب';

  @override
  String get practiceSessionCorrectAnswer => 'سم ځواب';

  @override
  String get practiceSessionExplanation => 'تشریح';

  @override
  String get practiceSessionBackToSetup => 'بیرته تنظیمولو ته';

  @override
  String get practiceSessionGeneralTopic => 'عمومي';

  @override
  String practiceSessionQuestionProgress(Object current, Object total) {
    return 'پوښتنه $current له $total';
  }

  @override
  String get practiceSessionMetricTime => 'وخت';

  @override
  String practiceSessionMatchmakingDifficulty(Object difficulty) {
    return 'ستونزمنتیا: $difficulty';
  }

  @override
  String get practiceModeActionPrevious => 'مخکنی';

  @override
  String get practiceModeActionCheckAnswer => 'ځواب وګوره';

  @override
  String get practiceModeActionNext => 'بل';

  @override
  String get practiceModeActionNextQuestion => 'بله پوښتنه';

  @override
  String get practiceModeActionEndSession => 'ناسته پای ته ورسوه';

  @override
  String get practiceModeActionEndQuestion => 'پوښتنه پای ته ورسوه';

  @override
  String get practiceModeActionEndExam => 'ازموینه پای ته ورسوه';

  @override
  String get practiceModeActionNovaHint => 'د NOVA لارښوونه';

  @override
  String get practiceModeActionSaveQuestion => 'پوښتنه خوندي کړه';

  @override
  String get practiceModeActionSavedQuestion => 'خوندي شوه';

  @override
  String get practiceModeQuestionSavedToast => 'ستا پوښتنو ته خوندي شوه';

  @override
  String get practiceModeQuestionRemovedToast => 'له خوندي شویو پوښتنو لرې شوه';

  @override
  String get practiceModeActionReveal => 'ښکاره کړه';

  @override
  String get practiceModeActionShowSolution => 'حل وښیه';

  @override
  String get practiceModeActionHideSolution => 'حل پټ کړه';

  @override
  String get practiceModeActionLockIn => 'قفل کړه';

  @override
  String get practiceModeActionCheckAdapt => 'وګوره او تطبیق کړه';

  @override
  String get practiceModeActionContinue => 'دوام ورکړه';

  @override
  String get practiceModeActionSolveIt => 'حل یې کړه';

  @override
  String get practiceModeActionNextConcept => 'بل مفهوم';

  @override
  String get practiceModeCardFront => 'د کارت مخ';

  @override
  String get practiceModeRecallSummary => 'د یادولو لنډیز';

  @override
  String get practiceModeFeelingPrompt => 'هغه څنګه احساس شو؟';

  @override
  String get practiceModeFeelingAgain => 'بیا';

  @override
  String get practiceModeFeelingHard => 'ستونزمن';

  @override
  String get practiceModeFeelingGood => 'ښه';

  @override
  String get practiceModeFeelingEasy => 'اسان';

  @override
  String get practiceModeSpeedRoundBanner =>
      'د سرعت پړاو · چټک پریکړې، سمدستي حرکت';

  @override
  String get practiceModeFastFeedback => 'چټک بیاکتنه';

  @override
  String get practiceModeExamPrepBanner =>
      'د ازموینې چمتووالی · آرامه ترتیب، ځوابونه له مخکې تللو وروسته کتل کیږي';

  @override
  String get practiceModeReview => 'بیاکتنه';

  @override
  String get practiceModeBagrutBanner => 'د بګروت حالت · د رسمي سبک کاغذي بهیر';

  @override
  String get practiceModeOfficialSolution => 'د رسمي سبک حل';

  @override
  String get practiceModeAdaptiveWarmup => 'د تودوخې ستونزمنتیا';

  @override
  String get practiceModeAdaptiveTrendingUp => 'ستونزمنتیا پورته خوا روانه';

  @override
  String get practiceModeAdaptiveEasingDown => 'ستونزمنتیا ښکته خوا روانه';

  @override
  String get practiceModeAdaptiveSteady => 'ستونزمنتیا ثابته پاتې';

  @override
  String get practiceModeAdaptiveFeedback => 'تطبیقي بیاکتنه';

  @override
  String get practiceModeConceptFirst => 'لومړی مفهوم';

  @override
  String get practiceModeNowSolveIt => 'اوس یې حل کړه';

  @override
  String get practiceModeConceptTitle => 'مفهوم';

  @override
  String get practiceModeFeedbackCorrect => 'سم';

  @override
  String get practiceModeFeedbackNotQuite => 'بشپړ نه دی';

  @override
  String get practiceModeFallbackQuestion => 'پوښتنه';

  @override
  String get practiceModeNoExplanationYet => 'تر اوسه هیڅ تشریح نشته.';

  @override
  String get teacherGradesAssessmentCreated => 'ارزونه جوړه شوه';

  @override
  String get teacherGradesEditAssessmentTitle => 'ارزونه سمه کړه';

  @override
  String get teacherGradesFieldTitle => 'سرلیک';

  @override
  String get teacherGradesFieldDate => 'نېټه (YYYY-MM-DD)';

  @override
  String get teacherGradesFieldMaxGrade => 'اعظمي نمره';

  @override
  String get teacherGradesAssessmentUpdated => 'ارزونه تازه شوه';

  @override
  String get teacherGradesDeleteAssessmentTitle => 'ارزونه ړنګه شي؟';

  @override
  String teacherGradesDeleteAssessmentBody(Object title) {
    return 'دا به $title او د هغې د نمرې اساس له ښوونکي کاري ځای څخه لرې کړي.';
  }

  @override
  String get teacherGradesDeleteAction => 'ړنګ کړه';

  @override
  String get teacherGradesAssessmentDeleted => 'ارزونه ړنګه شوه';

  @override
  String get teacherGradesRosterLinkError =>
      'دا ارزونه له کوم ټولګي لیست سره تړل شوې نه ده.';

  @override
  String get teacherGradesSaved => 'نمرې خوندي شوې';

  @override
  String get teacherGradesSubtitle =>
      'ارزونې جوړې کړه او نمرې د ژوندي ټولګي لیست پر وړاندې خوندي کړه.';

  @override
  String get teacherGradesCreateAssessmentTitle => 'ارزونه جوړه کړه';

  @override
  String get teacherGradesFieldCourse => 'کورس';

  @override
  String get teacherGradesCreateAction => 'جوړ کړه';

  @override
  String get teacherGradesNoStudentsLoaded =>
      'د دې ارزونې لپاره هیڅ زده‌کوونکی نه دی پورته شوی.';

  @override
  String get teacherGradesFieldGrade => 'نمره';

  @override
  String teacherGradesMaxHint(Object grade) {
    return 'اعظمي $grade';
  }

  @override
  String get teacherGradesSaving => 'خوندي کیږي…';

  @override
  String teacherGradesSaveCount(Object count) {
    return '$count نمرې خوندي کړه';
  }

  @override
  String get assignmentsNoDueDate => 'د سپارلو نېټه نشته';

  @override
  String get assignmentsLoadError =>
      'اوس مهال موږ دندې نشو پورته کولی. د تازه کولو لپاره ښکته راکاږه یا بیا هڅه وکړه.';

  @override
  String get assignmentsLoadTimeout =>
      'دندې د پورته کیدو لپاره ډېر وخت اخلي. د تازه کولو لپاره ښکته راکاږه یا یو شیبه وروسته بیا هڅه وکړه.';

  @override
  String get assignmentsLoadNetwork =>
      'اوس مهال دندې نشي وصل کیدی. خپله اړیکه وګوره او بیا هڅه وکړه.';

  @override
  String get assignmentsStatusOverdue => 'ناوخته';

  @override
  String get assignmentsStatusGraded => 'درجه بندي شوی';

  @override
  String get assignmentsStatusDueSoon => 'ژر سپارل کیږي';

  @override
  String get assignmentsStatusUpcoming => 'راتلونکی';

  @override
  String get assignmentsPreviewFallback =>
      'دا دنده پرانیزه ترڅو بشپړې لارښوونې وګورې او خپل کار چمتو کړې.';

  @override
  String get assignmentsSubmissionPrepEmpty =>
      'خپله یادښت یا فایلونه دلته کېږده.';

  @override
  String assignmentsSubmissionPrepCount(Object count) {
    return '$count فایل(ونه) محلي ضمیمه شوي.';
  }

  @override
  String get assignmentsHeroSubtitle =>
      'هره ټولګي دنده په یوه پاک لید کې، له بشپړ پردې تفصیلي مخ او د خپل کار چمتو کولو لپاره ځانګړي ځای سره.';

  @override
  String get assignmentsSubjectsMetric => 'مضامین';

  @override
  String get assignmentsNothingAssignedYet => 'تر اوسه هیڅ نه دی سپارل شوی';

  @override
  String get assignmentsNoAssignmentsForAccount =>
      'اوس مهال د دې زده‌کوونکي حساب لپاره هیڅ ټولګي دنده شته نه ده.';

  @override
  String assignmentsNextThingBody(Object title, Object due) {
    return '$title هغه بل شی دی چې وګورې یې. $due.';
  }

  @override
  String get assignmentsPullToCheckAgain => 'د بیا کتنې لپاره ښکته راکاږه.';

  @override
  String get assignmentsFiltersSubtitle =>
      'لیست د مضمون یا بیړنیتوب له مخې راکم کړه ترڅو لومړی پر مهمو شیانو تمرکز وکړې.';

  @override
  String get assignmentsSubjectLabel => 'مضمون';

  @override
  String get assignmentsAllSubjects => 'ټول مضامین';

  @override
  String get assignmentsSearchSubjects => 'مضامین ولټوه';

  @override
  String get assignmentsStatusLabel => 'حالت';

  @override
  String get assignmentsAllStatuses => 'ټول حالتونه';

  @override
  String get assignmentsSearchStatuses => 'حالتونه ولټوه';

  @override
  String assignmentsShowingSummary(Object shown, Object total) {
    return 'له $total دندو څخه $shown ښودل کیږي.';
  }

  @override
  String get assignmentsNoFilterMatchesTitle =>
      'هیڅ دنده له دې فلټرونو سره سمون نه خوري';

  @override
  String get assignmentsNoFilterMatchesSubtitle =>
      'ټول مضامین یا پراخ حالت لید هڅه وکړه ترڅو نورې دندې بیرته لیست ته راشي.';

  @override
  String get assignmentsClearFiltersHint =>
      'فلټرونه پاک کړه ترڅو بیا هرڅه وګورې.';

  @override
  String get assignmentsListSubtitle =>
      'هره دنده کېکاږه ترڅو بشپړ پردې تفصیلي لید پرانیزې او خپل کار چمتو کړې.';

  @override
  String get assignmentsAddNoteBeforePrepare =>
      'د خپل کار له چمتو کولو مخکې یادښت ولیکه یا فایل ضمیمه کړه.';

  @override
  String get assignmentsWorkDraftPrepared => 'د کار مسوده چمتو شوه.';

  @override
  String get assignmentsWorkDraftPreparedWithFiles =>
      'د کار مسوده چمتو شوه. ضمیمه شوي فایلونه پر دې وسیله خوندي دي.';

  @override
  String get assignmentsUnavailableTitle => 'دنده شته نه ده';

  @override
  String get assignmentsUnavailableSubtitle =>
      'دا دنده په اوسني فید کې ونه موندل شوه. کیدای شي لرې شوې وي یا آفلاین شته نه وي.';

  @override
  String get assignmentsUnavailableHint =>
      'بیرته لاړ شه او د دندو لیست تازه کړه.';

  @override
  String get assignmentsOverdueBannerBody =>
      'دا دنده له خپلې سپارلو نېټې تېره شوې. لاندې خپل کاري ساحه پرانیزه ترڅو هغه څه چمتو کړې چې سپارل غواړې.';

  @override
  String get assignmentsWorkAreaBannerBody =>
      'لاندې کاري ساحه وکاروه ترڅو فایلونه کېږدې، یادښت ولیکې، او هرڅه په یو ځای کې چمتو وساتې.';

  @override
  String get assignmentsDetailsSectionTitle => 'د دندې تفصیلات';

  @override
  String get assignmentsDetailsSectionSubtitle =>
      'هرڅه چې زده‌کوونکي ته اړوند دي او اوس مهال د ټولګي دندې محتوا کې شته دي.';

  @override
  String get assignmentsDetailDueLabel => 'سپارل';

  @override
  String get assignmentsDetailClassroomLabel => 'ټولګی';

  @override
  String get assignmentsDetailTeacherLabel => 'ښوونکی';

  @override
  String get assignmentsDetailPostedByLabel => 'خپور کړی د';

  @override
  String get assignmentsDetailPublishedLabel => 'خپور شو';

  @override
  String get assignmentsDetailUpdatedLabel => 'تازه شو';

  @override
  String get assignmentsDetailIdLabel => 'د دندې ID';

  @override
  String get assignmentsInstructionsTitle => 'لارښوونې';

  @override
  String get assignmentsInstructionsSubtitle =>
      'د ټولګي فید بشپړ د دندې متن، له اصلي ټکو ساتل سره.';

  @override
  String get assignmentsYourWorkTitle => 'ستا کار';

  @override
  String get assignmentsYourWorkSubtitle =>
      'یادښت کېږده، فایلونه یا اسناد ضمیمه کړه، او د سپارلو چمتووالی په یوه تمرکز شوي ځای کې وساته.';

  @override
  String get assignmentsPrivateNoteLabel => 'شخصي کاري یادښت';

  @override
  String get assignmentsPrivateNoteHint =>
      'هغه څه ولیکه چې سپارل غواړې، د ځان لپاره یادونې، یا د سند/لینک لنډیز.';

  @override
  String get assignmentsAddFiles => 'فایلونه یا اسناد ورزیات کړه';

  @override
  String get assignmentsClearFiles => 'فایلونه پاک کړه';

  @override
  String get assignmentsStagedDeviceHint =>
      'فایلونه پر دې وسیله ایښودل شوي. د دندې فایل سپارل په دې اپ کې شته نه دي.';

  @override
  String assignmentsLastPrepared(Object time) {
    return 'وروستی ځل چمتو شو $time.';
  }

  @override
  String get assignmentsSubmissionPrepTitle => 'د سپارلو چمتووالی';

  @override
  String get assignmentsPreparing => 'چمتو کیږي';

  @override
  String get assignmentsPrepareWork => 'کار چمتو کړه';

  @override
  String get assignmentsLoadingSubtitle => 'ستا د ټولګي دندې پورته کیږي.';

  @override
  String get assignmentsPullToRefreshRetry =>
      'د تازه کولو لپاره ښکته راکاږه یا لاندې بیا هڅه وکړه.';

  @override
  String get assignmentsFileSizeUnknown => 'فایل';

  @override
  String get assignmentsRemoveAttachment => 'لرې کړه';

  @override
  String get assignmentsSubmitted => 'سپارل شوه';

  @override
  String get attendanceUndated => 'بې نېټې';

  @override
  String get attendanceLoadError =>
      'اوس مهال موږ حاضري نشو پورته کولی. د تازه کولو لپاره ښکته راکاږه یا بیا هڅه وکړه.';

  @override
  String get attendanceLoadTimeout =>
      'حاضري د پورته کیدو لپاره ډېر وخت اخلي. د تازه کولو لپاره ښکته راکاږه یا یو شیبه وروسته بیا هڅه وکړه.';

  @override
  String get attendanceLoadNetwork =>
      'اوس مهال حاضري نشي وصل کیدی. خپله اړیکه وګوره او بیا هڅه وکړه.';

  @override
  String get attendanceConsistencyBuilding => 'لا جوړیږي';

  @override
  String get attendanceConsistencyExcellent => 'عالي دوام';

  @override
  String get attendanceConsistencySteady => 'ډېر باثباته';

  @override
  String get attendanceConsistencyNeedsAttention => 'پاملرنې ته اړتیا لري';

  @override
  String get attendanceConsistencyRisk => 'د حاضرۍ خطر';

  @override
  String get attendanceWatchRecentAbsences => 'وروستۍ غیرحاضرۍ';

  @override
  String get attendanceWatchRepeatedLateness => 'تکراري ناوختي راتګ';

  @override
  String get attendanceWatchExcusedAddingUp => 'د رخصت وخت ډېرېږي';

  @override
  String get attendanceWatchNoFlags => 'اوس مهال هیڅ نښه نشته';

  @override
  String get attendanceAllSubjectsLowercase => 'ټول مضامین';

  @override
  String attendanceShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return 'د $subject لپاره په $range کې له $total نښو څخه $shown ښودل کیږي.';
  }

  @override
  String get attendanceDayToneAbsent => 'د غیرحاضرۍ ورځ';

  @override
  String get attendanceDayToneLate => 'د ناوختي راتګ نښه';

  @override
  String get attendanceDayToneExcused => 'رخصت شوې حاضري';

  @override
  String get attendanceDayToneClean => 'پاکه ورځ';

  @override
  String get attendanceLoadingSubtitle =>
      'ستاسو د حاضرۍ وروستۍ لنډیز پورته کیږي.';

  @override
  String get attendanceUnavailableTitle => 'حاضري شته نه ده';

  @override
  String get attendanceHeroSubtitle =>
      'ستاسو د حاضرۍ کچې، وروستیو درسونو، او هغه څه چې پاملرنې ته اړتیا لري یو روښانه لیدنه.';

  @override
  String get attendanceMetricRate => 'کچه';

  @override
  String get attendanceMetricPresent => 'حاضر نښې';

  @override
  String get attendanceMetricLate => 'ناوختي نښې';

  @override
  String get attendanceMetricAbsent => 'غیرحاضر نښې';

  @override
  String attendanceHeroSignalBody(Object flag) {
    return '$flag. د حاضرۍ فشار کولی شي په خاموشۍ سره زیات شي، نو دا لیدنه پر هغه څه تمرکز کوي چې تازه بدل شوي دي.';
  }

  @override
  String get attendanceNoSummary =>
      'د دې زده‌کوونکي حساب لپاره لا تر اوسه د حاضرۍ هیڅ لنډیز شته نه دی.';

  @override
  String get attendanceEmptyTitle => 'لا تر اوسه د حاضرۍ ریکارډ نشته';

  @override
  String get attendanceEmptySubtitle =>
      'د دې زده‌کوونکي حساب لپاره لا تر اوسه د حاضرۍ هیڅ ریکارډ نه دی خپور شوی.';

  @override
  String get attendanceFiltersSubtitle =>
      'د حاضرۍ لیدنه د مضمون یا وخت له مخې راکمولو لپاره هماغه د لټون وړ ټاکونکی سټایل وکاروئ لکه په تنظیماتو کې.';

  @override
  String get attendanceTimeRangeLabel => 'د وخت موده';

  @override
  String get attendanceSearchRanges => 'ټول وخت / ۷ ورځې / ۳۰ ورځې / ۹۰ ورځې';

  @override
  String get attendanceNoFilteredMarksTitle =>
      'هیڅ نښه له دې فلټرونو سره سمون نه خوري';

  @override
  String get attendanceNoFilteredMarksSubtitle =>
      'د حاضرۍ نورې نښې راوستلو لپاره ټول مضامین یا پراخه وخت موده هڅه وکړئ.';

  @override
  String get attendanceQuickReadTitle => 'چټک لنډیز';

  @override
  String get attendanceQuickReadSubtitleFiltered =>
      'لاندې ښودل شویو فلټر شویو نښو لپاره یو چټک لنډیز.';

  @override
  String get attendanceQuickReadSubtitleAll =>
      'د موجودو وروستیو حاضرۍ ریکارډونو پر بنسټ یو چټک لنډیز.';

  @override
  String get attendanceSummaryConsistency => 'باثباتي';

  @override
  String get attendanceSummaryWatchFor => 'پاملرنه وکړئ';

  @override
  String get attendanceSummaryExcused => 'رخصت شوې نښې';

  @override
  String get attendanceSummaryMarksInView => 'په لید کې نښې';

  @override
  String get attendanceSummaryRateInView => 'په لید کې کچه';

  @override
  String get attendanceRecentDaysTitle => 'وروستۍ ورځې';

  @override
  String get attendanceRecentDaysSubtitleFiltered =>
      'د هغو فلټر شویو نښو لپاره چې اوس په لید کې دي د ورځې له مخې ډلبندي شوي.';

  @override
  String get attendanceRecentDaysSubtitleAll =>
      'د ورځې له مخې ډلبندي شوي ترڅو تاسو د غیرحاضرۍ یا ناوختي راتګ بڼې ژر ونیسئ.';

  @override
  String get attendanceLessonCountSingle => '۱ درس';

  @override
  String attendanceLessonCount(Object count) {
    return '$count درسونه';
  }

  @override
  String get attendanceStatusPresent => 'حاضر';

  @override
  String get attendanceStatusLate => 'ناوخته';

  @override
  String get attendanceStatusAbsent => 'غیرحاضر';

  @override
  String get attendanceStatusExcused => 'رخصت';

  @override
  String get attendanceStatusRecorded => 'ثبت شوی';

  @override
  String get attendanceLessonFallback => 'درس';

  @override
  String get attendanceRangeAll => 'ټول وخت';

  @override
  String get attendanceRange7 => 'وروستۍ ۷ ورځې';

  @override
  String get attendanceRange30 => 'وروستۍ ۳۰ ورځې';

  @override
  String get attendanceRange90 => 'وروستۍ ۹۰ ورځې';

  @override
  String get attendanceRangeAllShort => 'ټول وخت';

  @override
  String get attendanceRange7Short => '۷ ورځې';

  @override
  String get attendanceRange30Short => '۳۰ ورځې';

  @override
  String get attendanceRange90Short => '۹۰ ورځې';

  @override
  String get gradesLoadError =>
      'موږ اوس مهال نمرې نشو پورته کولی. د تازه کولو لپاره راکش کړئ یا بیا هڅه وکړئ.';

  @override
  String get gradesLoadTimeout =>
      'نمرې د پورته کیدو لپاره ډېر وخت اخلي. راکش کړئ یا یوه شیبه وروسته بیا هڅه وکړئ.';

  @override
  String get gradesLoadNetwork =>
      'نمرې اوس مهال ونه نښلیدې. خپله اړیکه وګورئ او بیا هڅه وکړئ.';

  @override
  String get gradesGeneralSubject => 'عمومي';

  @override
  String get gradesBandBuilding => 'لا روانه ده';

  @override
  String get gradesBandExcellent => 'عالي';

  @override
  String get gradesBandStrong => 'قوي';

  @override
  String get gradesBandOkay => 'ښه';

  @override
  String get gradesBandNeedsAttention => 'پاملرنې ته اړتیا لري';

  @override
  String get gradesBandRisk => 'په خطر کې';

  @override
  String get gradesTrendRising => 'په لوړېدو';

  @override
  String get gradesTrendDropping => 'په ټیټېدو';

  @override
  String get gradesTrendStable => 'ثابت';

  @override
  String gradesShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return 'د $subject لپاره په $range کې له $total ثبت شویو نمرو څخه $shown ښودل کیږي.';
  }

  @override
  String get gradesLoadingSubtitle =>
      'ستاسو وروستۍ زده‌کړیزې پایلې پورته کیږي.';

  @override
  String get gradesUnavailableTitle => 'نمرې شته نه دي';

  @override
  String get gradesHeroSubtitle =>
      'ستاسو د منځنۍ کچې، وروستیو ارزونو، او دا چې کوم مضامین ساتنې یا بیا روغتیا ته اړتیا لري یو روښانه لیدنه.';

  @override
  String get gradesMetricAverage => 'منځنۍ';

  @override
  String get gradesMetricRecorded => 'ثبت شوي';

  @override
  String get gradesMetricBestSubject => 'غوره مضمون';

  @override
  String get gradesMetricNeedsWork => 'کار ته اړتیا لري';

  @override
  String gradesLatestSignalBody(
    Object assessment,
    Object subject,
    Object grade,
    Object band,
  ) {
    return 'په $subject کې $assessment په $grade پایله ته ورسیده. اوس مهال $band.';
  }

  @override
  String get gradesSummaryAvailableNoRecent =>
      'د نمرو لنډیز شته، خو په دې لید کې لا تر اوسه هیڅ وروستۍ ارزونه نه ښکاري.';

  @override
  String get gradesEmptyTitle => 'لا تر اوسه نمرې نشته';

  @override
  String get gradesEmptySubtitle =>
      'د دې زده‌کوونکي حساب لپاره لا تر اوسه هیڅ نمرې نه دي خپرې شوې.';

  @override
  String get gradesFiltersSubtitle =>
      'د نمرو د مضمون یا وخت له مخې راکمولو لپاره هماغه د لټون وړ ټاکونکی سټایل وکاروئ لکه په تنظیماتو کې.';

  @override
  String get gradesNoFilteredTitle => 'هیڅ نمرې له دې فلټرونو سره سمون نه خوري';

  @override
  String get gradesNoFilteredSubtitle =>
      'نورې ثبت شوې نمرې راوستلو لپاره ټول مضامین یا پراخه وخت موده هڅه وکړئ.';

  @override
  String get gradesQuickReadTitle => 'چټک لنډیز';

  @override
  String get gradesQuickReadSubtitleFiltered =>
      'د هغو نمرو لپاره چې اوس په لید کې دي یو چټک لنډیز.';

  @override
  String get gradesQuickReadSubtitleAll =>
      'د دې چې څه وساتل شي او څه بیا روغ کړل شي تر ټولو چټک لنډیز.';

  @override
  String get gradesWeakSpotLabel => 'اوسنۍ کمزورې برخه';

  @override
  String get gradesNoWeakSignal => 'لا تر اوسه د کمزوري مضمون نښه نشته';

  @override
  String gradesWeakSpotValue(Object subject) {
    return '$subject د بیا روغتیا لومړي بلاک ته اړتیا لري.';
  }

  @override
  String get gradesStrengthLabel => 'اوسنۍ ځواکمنتیا';

  @override
  String get gradesNoStrengthSignal => 'لا تر اوسه د قوي مضمون نښه نشته';

  @override
  String gradesStrengthValue(Object subject) {
    return '$subject اوس مهال ستاسو د باور لنگر دی.';
  }

  @override
  String get gradesBandLabel => 'کچه';

  @override
  String get gradesInViewLabel => 'په لید کې';

  @override
  String gradesInViewCount(Object count) {
    return 'په دې فلټر کې $count ثبت شوې نمرې.';
  }

  @override
  String gradesInViewAverage(Object count, Object average) {
    return '$count ثبت شوې نمرې چې منځنۍ یې $average ده.';
  }

  @override
  String get gradesLatestAssessmentsTitle => 'وروستۍ ارزونې';

  @override
  String get gradesLatestAssessmentsSubtitleFiltered =>
      'په اوسني فلټر شوي لید کې تر ټولو وروستۍ ثبت شوې نمرې.';

  @override
  String get gradesLatestAssessmentsSubtitleAll =>
      'تر ټولو وروستۍ ثبت شوې نمرې په وخت ترتیب سره.';

  @override
  String get gradesSubjectDrilldownTitle => 'د مضمون تفصیل';

  @override
  String get gradesSubjectDrilldownSubtitleFiltered =>
      'د هغو نمرو لپاره چې اوس په لید کې دي د مضمون له مخې ډلبندي شوي.';

  @override
  String get gradesSubjectDrilldownSubtitleAll =>
      'د مضمون له مخې ډلبندي شوي ترڅو رجحان او فشار ژر څرګند شي.';

  @override
  String get gradesAssessmentFallback => 'ارزونه';

  @override
  String get gradesChipBest => 'غوره';

  @override
  String get gradesNoAverageYet => 'لا تر اوسه منځنۍ نشته';

  @override
  String gradesRecentAverage(Object average) {
    return 'وروستۍ منځنۍ: $average';
  }

  @override
  String get actionCancel => 'لغوه کول';

  @override
  String get actionSave => 'خوندي کول';

  @override
  String get actionDelete => 'ړنګول';

  @override
  String get actionRemove => 'لرې کول';

  @override
  String get actionBlock => 'بلاک';

  @override
  String get actionCreate => 'جوړول';

  @override
  String get actionShare => 'شریکول';

  @override
  String get actionScheduleVerb => 'مهال ویش';

  @override
  String get actionAdd => 'زیاتول';

  @override
  String get actionKeep => 'ساتل';

  @override
  String get actionOpen => 'خلاصول';

  @override
  String get actionPublish => 'خپرول';

  @override
  String get actionPublishing => 'خپرول کیږي…';

  @override
  String get actionRefresh => 'تازه کول';

  @override
  String get msgBlockTitle => 'دا کس بلاک کړئ؟';

  @override
  String get msgBlockContent =>
      'هغوی به نشي کولی تاسو ته پیغام واستوي او تاسو به یې پیغامونه ونه وینئ.';

  @override
  String get msgRenameGroup => 'د ګروپ نوم بدلول';

  @override
  String get msgGroupName => 'د ګروپ نوم';

  @override
  String get msgMute => 'غلي کول';

  @override
  String get msgUnmute => 'غږ بیرته راوستل';

  @override
  String get msgInviteCode => 'د بلنې کوډ';

  @override
  String get msgCopyCode => 'کوډ کاپي کول';

  @override
  String get msgLeave => 'وتل';

  @override
  String get msgInviteCodeCopied => 'د بلنې کوډ کاپي شو';

  @override
  String msgCodeCopied(Object code) {
    return 'کوډ کاپي شو: $code';
  }

  @override
  String msgParticipantsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ګډونوال زیات شول',
      one: '۱ ګډونوال زیات شو',
    );
    return '$_temp0';
  }

  @override
  String msgMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غړي',
      one: '۱ غړی',
    );
    return '$_temp0';
  }

  @override
  String get msgAdmin => 'اډمین';

  @override
  String get msgRemoveFromGroup => 'له ګروپه لرې کول';

  @override
  String get msgMakeAdmin => 'اډمین جوړول';

  @override
  String get msgRemoveAdmin => 'اډمین لرې کول';

  @override
  String get msgOnlyAdmin => 'یوازینی اډمین — لومړی بل ته دنده ورکړئ';

  @override
  String msgRemoveMemberTitle(Object name) {
    return '$name لرې کړئ؟';
  }

  @override
  String get msgNotificationsMuted => 'خبرتیاوې غلي شوې';

  @override
  String get msgNotificationsUnmuted => 'خبرتیاوې بیرته فعالې شوې';

  @override
  String get msgJoinGroupTitle => 'یوې ډلې سره یوځای شئ';

  @override
  String get msgJoinGroupSubtitle => 'د ګروپ له اډمین څخه د بلنې کوډ دننه کړئ';

  @override
  String get examTitle => 'ازموینه';

  @override
  String get examNotFound => 'ازموینه ونه موندل شوه';

  @override
  String get examStudyWithNova => 'له NOVA سره مطالعه';

  @override
  String get examOpenInsights => 'Insights خلاصول';

  @override
  String get examAddToCalendar => 'کلیز ته اضافه کول';

  @override
  String get examCouldNotOpenCalendar => 'کلیز نشو خلاصېدلی.';

  @override
  String get formTitle => 'فورمه';

  @override
  String get formNotFound => 'فورمه ونه موندل شوه';

  @override
  String get formClosed => 'تړل شوې';

  @override
  String get formCompletion => 'بشپړتیا';

  @override
  String get formNoTextResponses => 'لا تر اوسه د متن ځوابونه نشته.';

  @override
  String get meetingsCouldNotLoad => 'غونډې نشي پورته کیدی';

  @override
  String get meetingCouldNotLoad => 'غونډه نشي پورته کیدی';

  @override
  String get insightsGenerateAction => 'Insights جوړول';

  @override
  String get insightsRefreshAction => 'تازه کول';

  @override
  String get teacherGoToClassroom => 'ټولګي ته ورتلل';

  @override
  String get teacherMarkAttendance => 'حاضري نښه کول';

  @override
  String get teacherPostAssignment => 'دنده خپرول';

  @override
  String get teacherNewAnnouncementAction => 'نوې اعلامیه';

  @override
  String get teacherViewFullWeekSchedule => 'د بشپړې اونۍ مهال ویش وګورئ';

  @override
  String get teacherGroupsLabel => 'ګروپونه';

  @override
  String get teacherTestsLabel => 'ازموینې';

  @override
  String get teacherAnnounceLabel => 'اعلان';

  @override
  String get teacherTitleAndMessageRequired => 'سرلیک او پیغام اړین دي';

  @override
  String get teacherAnnouncementPublished => 'اعلامیه خپره شوه';

  @override
  String teacherFailedToPublish(Object error) {
    return 'خپرول ناکام شو: $error';
  }

  @override
  String get teacherAnnouncementSectionTitle => 'اعلامیه';

  @override
  String get teacherAudienceSectionTitle => 'اوریدونکي';

  @override
  String get teacherPinAnnouncement => 'اعلامیه پن کول';

  @override
  String get teacherPinnedAtTop => 'پن شوې اعلامیې په سر کې ښکاري';

  @override
  String get teacherPublishAction => 'خپرول';

  @override
  String get teacherPublishingAction => 'خپرول کیږي…';

  @override
  String get teacherAnnounceTitleLabel => 'سرلیک *';

  @override
  String get teacherAnnounceTitleHint => 'بېلګه: سبا د ښوونځي پیښه';

  @override
  String get teacherAnnounceMessageLabel => 'پیغام *';

  @override
  String get teacherAnnounceMessageHint => 'بشپړه اعلامیه دلته ولیکئ…';

  @override
  String get teacherStudentsLabel => 'زده‌کوونکي';

  @override
  String get teacherSearchStudents => 'زده‌کوونکي ولټوئ…';

  @override
  String get teacherNoStudentsLoaded =>
      'په دې ښوونځي کې هیڅ زده‌کوونکی ونه موندل شو.';

  @override
  String get teacherActions => 'چټک کارونه';

  @override
  String get teacherParentsLabel => 'مور و پلار';

  @override
  String get teacherTeachersLabel => 'ښوونکي';

  @override
  String get teacherWeekScheduleTitle => 'د اونۍ مهال ویش';

  @override
  String get teacherCouldNotLoadSchedule => 'مهال ویش نشي پورته کیدی';

  @override
  String get teacherAttendanceLast30 => 'حاضري (وروستۍ ۳۰ ورځې)';

  @override
  String teacherAttendanceFrom(Object date) {
    return 'له $date څخه';
  }

  @override
  String get teacherAttendanceChangeDate => 'نېټه بدلول';

  @override
  String get teacherAttendanceNoSessions =>
      'هیڅ خوندي شوې د حاضرۍ ناسته نشته.\nله مهال ویش څخه حاضري نښه کړئ.';

  @override
  String get teacherRecentGrades => 'وروستۍ نمرې';

  @override
  String get teacherNoGradesRecorded => 'لا تر اوسه نمرې نه دي ثبت شوې';

  @override
  String get teacherGradeAvg => 'د نمرو منځنۍ';

  @override
  String get teacherSubmittedLabel => 'سپارل شوی';

  @override
  String get teacherAnalyticsTitle => 'شننه';

  @override
  String get teacherGradeReports => 'د نمرو راپورونه';

  @override
  String get teacherAvgLabel => 'منځنۍ';

  @override
  String teacherBelow60(Object count) {
    return '$count له ۶۰٪ ښکته';
  }

  @override
  String teacherGradedFraction(Object graded, Object total) {
    return '$graded/$total نمره شوي';
  }

  @override
  String get teacherNoGradesEntered => 'لا تر اوسه نمرې نه دي ننوتلې';

  @override
  String get teacherNewAssignment => 'نوې دنده';

  @override
  String get teacherDeleteAssignment => 'دنده ړنګه کړئ؟';

  @override
  String get teacherDeleteAssignmentContent =>
      'دا به یې د ټولو زده‌کوونکو لپاره لرې کړي.';

  @override
  String get teacherShareMaterialTitle => 'موادو شریکول';

  @override
  String get teacherRemoveMaterial => 'مواد لرې کړئ؟';

  @override
  String get teacherScheduleMeetingTitle => 'د غونډې مهال ویش';

  @override
  String get teacherCancelMeetingTitle => 'غونډه لغوه کړئ؟';

  @override
  String get teacherCancelMeetingAction => 'غونډه لغوه کول';

  @override
  String get teacherJoinMeeting => 'غونډې سره یوځای کیدل';

  @override
  String get teacherAddStudentTitle => 'زده‌کوونکی زیاتول';

  @override
  String teacherRemoveStudentTitle(Object name) {
    return '$name لرې کړئ؟';
  }

  @override
  String get teacherRemoveStudentContent =>
      'دا زده‌کوونکی به له دې ټولګي څخه لرې شي.';

  @override
  String get teacherStudentAdded => 'زده‌کوونکی زیات شو';

  @override
  String get teacherClassroomAnalyticsTitle => 'د ټولګي شننه';

  @override
  String get teacherOpenAnalyticsAction => 'شننه خلاصول';

  @override
  String teacherStudentsCount(Object count) {
    return 'زده‌کوونکي ($count)';
  }

  @override
  String get teacherAssignmentLabel => 'دنده';

  @override
  String get teacherShareMaterialLabel => 'موادو شریکول';

  @override
  String get teacherAttendanceRateLabel => 'د حاضرۍ کچه';

  @override
  String get teacherSelectSessionPrompt =>
      'د حاضرۍ نښه کولو پیلولو لپاره لاندې یوه ناسته وټاکئ';

  @override
  String get teacherOpenAction => 'خلاصول';

  @override
  String get chatDeleteForMe => 'زما لپاره ړنګول';

  @override
  String get chatDeleteForEveryone => 'د ټولو لپاره ړنګول';

  @override
  String get chatMicNeeded => 'د مایکروفون لاسرسي ته اړتیا ده';

  @override
  String get chatMicNeededBody =>
      'د غږیزو یادښتونو لیږلو لپاره مهرباني وکړئ په تنظیماتو کې د مایکروفون لاسرسي ته اجازه ورکړئ.';

  @override
  String get chatOpenSettings => 'تنظیمات خلاصول';

  @override
  String get chatCopied => 'کاپي شو';

  @override
  String get chatCouldNotSendMedia => 'میډیا ونه لیږل شوه.';

  @override
  String get chatCouldNotSendMessage => 'پیغام ونه لیږل شو.';

  @override
  String get chatCouldNotForward => 'ټاکل شوي پیغامونه ونه استول شول';

  @override
  String get chatSelectAll => 'ټول وټاکئ';

  @override
  String get chatDeselectAll => 'ټول له ټاکنې وباسئ';

  @override
  String get chatEditingMessage => 'د پیغام سمول';

  @override
  String get chatEditPlaceholder => 'پیغام سم کړئ…';

  @override
  String get chatMessageHint => 'پیغام';

  @override
  String get chatPin => 'پن کول';

  @override
  String get chatUnpin => 'پن لرې کول';

  @override
  String get chatPhoto => 'انځور';

  @override
  String get chatVideo => 'ویډیو';

  @override
  String get chatMedia => 'میډیا';

  @override
  String get chatAudioFile => 'غږیزه فایل';

  @override
  String get chatVideoFile => 'ویډیو فایل';

  @override
  String get chatAttachedFile => 'ضمیمه شوې فایل';

  @override
  String get chatFollowUp => 'تعقیب';

  @override
  String get chatCancelTooltip => 'لغوه کول';

  @override
  String get chatJoinGroup => 'ګروپ سره یوځای کیدل';

  @override
  String get chatJoining => 'یوځای کیږي…';

  @override
  String get chatJoinGroupTooltip => 'د کوډ په واسطه ګروپ سره یوځای کیدل';

  @override
  String get chatForwardNoChatAvailable => 'هیڅ منل شوې خبرې اترې شته نه دي';

  @override
  String get chatFilterAll => 'ټول';

  @override
  String get novaDisclaimer =>
      'NOVA کولی شي تېروتنه وکړي. مهم ځوابونه دوه ځله وګورئ.';

  @override
  String get practiceCustomDisclaimer =>
      'دودیز موضوعات په همغه شیبه کې د AI لخوا جوړیږي. پوښتنې ممکن له موضوع څخه لرې شي یا د ځانګړو مضامینو لپاره ناسمې وي. ناآشنا ځوابونه په خپلواکه توګه تایید کړئ.';

  @override
  String get classroomsJoined => 'تاسو ټولګي سره یوځای شوئ!';

  @override
  String get classroomsJoinAction => 'ټولګي سره یوځای کیدل';

  @override
  String get classroomsJoinTooltip => 'یوه ټولګي سره یوځای کیدل';

  @override
  String get classroomsJoinTitle => 'یوه ټولګي سره یوځای شئ';

  @override
  String get classroomsJoinSubtitle => 'هغه کوډ دننه کړئ چې ستاسو ښوونکي درکړی';

  @override
  String get classroomsCouldNotOpenLink => 'لینک نشو خلاصېدلی';

  @override
  String get classroomsReorderTitle => 'ټولګي بیا ترتیبول';

  @override
  String get classroomsNoClassroomsToReorder =>
      'د بیا ترتیبولو لپاره هیڅ ټولګی نشته.';

  @override
  String get teacherPostAnnouncementAction => 'اعلامیه خپرول';

  @override
  String get announcementAudienceEveryone => 'هرڅوک';

  @override
  String get teacherGreetingMorning => 'سهار مو پخیر';

  @override
  String get teacherGreetingAfternoon => 'ماسپښین مو پخیر';

  @override
  String get teacherGreetingEvening => 'ماښام مو پخیر';

  @override
  String get teacherTodaysClasses => 'د نن ورځې ټولګي';

  @override
  String get teacherNoDate => 'نېټه نشته';

  @override
  String get teacherUpcomingTestsSubtitle => 'راتلونکې ازموینې او چټکې ازموینې';

  @override
  String get teacherNoClassesThisWeek => 'دا اونۍ هیڅ ټولګي نشته';

  @override
  String get teacherNoClassesThisWeekSub => 'ستاسو د دې اونۍ مهال ویش تش دی';

  @override
  String get teacherTitleFieldLabel => 'سرلیک *';

  @override
  String get teacherInstructionsLabel => 'لارښوونې';

  @override
  String get teacherLinkUrlLabel => 'لینک / URL *';

  @override
  String get teacherLinkUrlHint => 'https://...';

  @override
  String get teacherDescriptionLabel => 'تشریح';

  @override
  String get teacherMeetingTitleLabel => 'د غونډې سرلیک *';

  @override
  String get teacherMeetingLinkLabel => 'د غونډې لینک *';

  @override
  String get teacherMeetingLinkHint => 'د Zoom / Meet / Teams لینک';

  @override
  String get teacherStudentEmailLabel => 'د زده‌کوونکي بریښنالیک یا ID';

  @override
  String get teacherTooltipRemoveStudent => 'له ټولګي لرې کول';

  @override
  String get teacherCouldNotLoad => 'پورته نشو کیدی';

  @override
  String get teacherNoAssignmentsYet => 'لا تر اوسه دندې نشته';

  @override
  String get teacherNoAssignmentsSub => 'د لومړۍ دندې جوړولو لپاره + کېکاږئ';

  @override
  String get teacherNoMaterialsYet => 'لا تر اوسه مواد نشته';

  @override
  String get teacherNoMaterialsSub =>
      'له خپل ټولګي سره لینکونه، اسناد، یا سرچینې شریک کړئ';

  @override
  String get teacherNoMeetingsScheduled => 'هیڅ غونډه مهال ویش شوې نه ده';

  @override
  String get teacherNoMeetingsSub => 'د ټولګي غونډې مهال ویش لپاره + کېکاږئ';

  @override
  String get teacherAttendanceOther => 'نور';

  @override
  String get teacherTotal => 'ټول';

  @override
  String get mediaOpenExternally => 'بهر خلاصول';

  @override
  String get mediaUnableToLoad => 'انځور نشي پورته کیدی';

  @override
  String get searchHint => 'لټون...';

  @override
  String get teacherInsightsTitle => 'د زده‌کوونکي Insights';

  @override
  String get teacherInsightsSubtitle =>
      'د زده‌کوونکي زده‌کړیزو Insights لیدلو لپاره یو زده‌کوونکی وټاکئ.';

  @override
  String get teacherInsightsNoStudents => 'هیڅ زده‌کوونکی ونه موندل شو.';

  @override
  String get teacherInsightsSearchHint => 'زده‌کوونکي ولټوئ…';

  @override
  String get navDiplomas => 'سندونه';

  @override
  String get diplomasComingSoon => 'د سندونو مدیریت ډېر ژر راروان دی.';

  @override
  String get teacherExamsTitle => 'ازموینې';

  @override
  String get teacherExamsUpcoming => 'راتلونکې';

  @override
  String get teacherExamsPast => 'تېرې';

  @override
  String get teacherExamsEmpty =>
      'لا تر اوسه ارزونې نشته. د جوړولو لپاره + کېکاږئ.';

  @override
  String teacherExamsGraded(Object count) {
    return '$count نمره شوي';
  }

  @override
  String get teacherFormsTitle => 'فورمې';

  @override
  String get teacherFormsEmpty =>
      'لا تر اوسه فورمې نشته. د جوړولو لپاره + کېکاږئ.';

  @override
  String teacherFormsResponses(Object count) {
    return '$count ځوابونه';
  }

  @override
  String get teacherFormsPublished => 'خپور شوی';

  @override
  String get teacherFormsDraft => 'مسوده';

  @override
  String get teacherFormsCreateTitle => 'فورمه جوړول';

  @override
  String get teacherFormsAddQuestion => 'پوښتنه زیاتول';

  @override
  String get teacherFormsQuestionHint => 'د پوښتنې متن';

  @override
  String get teacherFormsViewResponses => 'ځوابونه لیدل';

  @override
  String get teacherFormsNoResponses => 'لا تر اوسه ځوابونه نشته.';

  @override
  String get diplomasTitle => 'سندونه';

  @override
  String get diplomasEmpty =>
      'لا تر اوسه هیڅ سند نه دی ورکړل شوی. د ورکولو لپاره + کېکاږئ.';

  @override
  String get diplomasIssueTo => 'ورکول دې ته';

  @override
  String get diplomasStudentName => 'د زده‌کوونکي نوم';

  @override
  String get diplomasCertificateType => 'د سند ډول';

  @override
  String get diplomasIssueDiploma => 'سند ورکول';

  @override
  String diplomasIssuedOn(Object date) {
    return 'په $date ورکړل شو';
  }

  @override
  String get examDetailsSection => 'تفصیلات';

  @override
  String get examInfoTeacher => 'ښوونکی';

  @override
  String get examInfoAudience => 'اوریدونکي';

  @override
  String get examInfoDate => 'نېټه';

  @override
  String get examInfoTime => 'وخت';

  @override
  String get examInfoPeriod => 'دوره';

  @override
  String get examInfoDuration => 'موده';

  @override
  String get examInfoSubject => 'مضمون';

  @override
  String get examMaterialsSection => 'ضمیمه شوي مواد';

  @override
  String get examNoMaterials => 'لا تر اوسه هیڅ مواد نه دي ضمیمه شوي.';

  @override
  String get examQuickActionsSection => 'چټک کارونه';

  @override
  String get examViewGradeTitle => 'خپله نمره وګورئ';

  @override
  String get examViewGradeBody =>
      'دا ازموینه بشپړه شوې ده. خپلې پایلې لپاره د نمرو ټب وګورئ.';

  @override
  String get examViewGradeAction => 'نمرې خلاصول';

  @override
  String get teacherGradesSaveAction => 'خوندي کول';

  @override
  String get teacherGradesNothingToSave => 'د خوندي کولو لپاره هیڅ بدلون نشته.';

  @override
  String get teacherRetry => 'بیا هڅه';

  @override
  String get teacherExamGradesStudents => 'زده‌کوونکي';

  @override
  String get teacherExamGradesGraded => 'نمره شوي';

  @override
  String get teacherExamGradesNoStudents =>
      'هیڅ زده‌کوونکی ونه ټاکل شو.\nد اوریدونکو زیاتولو لپاره ازموینه سم کړئ.';

  @override
  String get teacherExamGradesEnterGrades => 'نمرې دننه کول';

  @override
  String get teacherDeleteExamTitle => 'ازموینه ړنګه کړئ؟';

  @override
  String get teacherDeleteExamBody => 'دا به ازموینه د تل لپاره ړنګه کړي.';

  @override
  String get teacherMeetingsEmpty =>
      'لا تر اوسه غونډې نشته.\nد مهال ویش لپاره + کېکاږئ.';

  @override
  String get teacherStudentsNoMatch => 'هیڅ زده‌کوونکی سمون نه خوري';

  @override
  String get teacherMaterialsTitle => 'مواد';

  @override
  String get profileNamesTitle => 'نوم په ژبو کې';

  @override
  String get profileDisplayNameLang => 'د ښودلو نوم ژبه';

  @override
  String get navDashboard => 'ډشبورډ';

  @override
  String get navPeople => 'کارن';

  @override
  String get navCohorts => 'ډلې';

  @override
  String get navSchool => 'ښوونځی';

  @override
  String get adminDashboardTitle => 'د ښوونځي کتنه';

  @override
  String get adminStudents => 'زده کوونکي';

  @override
  String get adminTeachers => 'ښوونکي';

  @override
  String get adminParents => 'والدین';

  @override
  String get adminSecretaries => 'منشيان';

  @override
  String get adminAdmins => 'مدیران';

  @override
  String get adminTodaySessions => 'د نن ورځې ناستې';

  @override
  String get adminQuickActions => 'چټک کارونه';

  @override
  String get adminAttendanceLast30 => 'حاضري — تېرې ۳۰ ورځې';

  @override
  String get adminNoAttendanceData =>
      'د تېرو ۳۰ ورځو لپاره د حاضرۍ معلومات نشته.';

  @override
  String get adminAddUser => 'کاروونکی زیاتول';

  @override
  String get adminCreateUser => 'جوړول';

  @override
  String get adminFullName => 'بشپړ نوم';

  @override
  String get adminEmailAddress => 'د بریښنالیک پته';

  @override
  String get adminRoleLabel => 'رول';

  @override
  String get adminUserCreated => 'کاروونکی جوړ شو';

  @override
  String get adminTempPassword => 'لنډمهاله پټنوم';

  @override
  String get adminCopied => 'کلیپ‌بورډ ته کاپي شو';

  @override
  String get adminResetPassword => 'پټنوم بیا تنظیمول';

  @override
  String get adminPasswordReset => 'پټنوم بیا تنظیم شو';

  @override
  String adminTempPasswordFor(Object name) {
    return 'د $name لپاره لنډمهاله پټنوم';
  }

  @override
  String get adminDeleteUser => 'کاروونکی ړنګول';

  @override
  String adminDeleteUserConfirm(Object name) {
    return '$name ړنګ شي؟ دا بیرته نشي راګرځیدلی.';
  }

  @override
  String get adminDeleteCohort => 'ډله ړنګول';

  @override
  String adminDeleteCohortConfirm(Object name) {
    return '\"$name\" ړنګ شي؟ د ټولو زده کوونکو غړیتوب به لرې شي.';
  }

  @override
  String get adminAddCohort => 'ډله زیاتول';

  @override
  String get adminNewCohort => 'نوې ډله';

  @override
  String get adminCohortName => 'د ډلې نوم (لکه ۱۰م-۲)';

  @override
  String get adminCohortGrade => 'ټولګی';

  @override
  String get adminRenameCohort => 'نوم بدلول';

  @override
  String get adminAddStudents => 'زده کوونکي زیاتول';

  @override
  String adminAddTo(Object name) {
    return '$name ته زیاتول';
  }

  @override
  String get adminRemoveStudent => 'زده کوونکی لرې کول';

  @override
  String adminRemoveStudentConfirm(Object name, Object cohort) {
    return '$name له $cohort څخه لرې شي؟';
  }

  @override
  String get adminNoCohortsYet => 'تر اوسه ډلې نشته';

  @override
  String get adminNoStudentsInCohort => 'په دې ډله کې زده کوونکي نشته';

  @override
  String adminStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count زده کوونکي',
      one: '۱ زده کوونکی',
    );
    return '$_temp0';
  }

  @override
  String get adminSearchStudents => 'زده کوونکي ولټوئ…';

  @override
  String get adminScheduleTitle => 'مهالویش';

  @override
  String get adminScheduleAddPeriod => 'وخت زیاتول';

  @override
  String get adminScheduleNewPeriod => 'نوی وخت';

  @override
  String get adminScheduleDayLabel => 'ورځ';

  @override
  String adminSchedulePeriodLabel(Object period) {
    return 'د $period وخت';
  }

  @override
  String get adminScheduleTeacherLabel => 'ښوونکی';

  @override
  String get adminScheduleNoneTeacher => 'هیڅ ښوونکی نه دی ټاکل شوی';

  @override
  String get adminScheduleCohortLabel => 'ډله / زده کوونکي';

  @override
  String get adminScheduleFrequencyLabel => 'تکرار';

  @override
  String get adminScheduleFreqWeekly => 'هره اونۍ';

  @override
  String get adminScheduleFreqBiweekly => 'هرې ۲ اونۍ';

  @override
  String get adminScheduleFreqMonthly => 'هرې ۴ اونۍ';

  @override
  String get adminScheduleFreqCustom => 'دلخواه';

  @override
  String adminScheduleFreqCustomLabel(int n) {
    return 'هرې $n اونۍ';
  }

  @override
  String get adminScheduleAddSlot => 'ځای زیاتول';

  @override
  String get adminScheduleAddAnother => 'بله ورځ / وخت زیاتول';

  @override
  String get adminScheduleSave => 'ساتل';

  @override
  String get adminScheduleSearchTeacher => 'ښوونکي ولټوئ…';

  @override
  String get adminScheduleSearchCohort => 'ډلې ولټوئ…';

  @override
  String get adminScheduleSelectTeacher => 'ښوونکی وټاکئ';

  @override
  String get adminScheduleSelectCohort => 'ډله وټاکئ';

  @override
  String get adminScheduleOrStudents => 'یا انفرادي زده کوونکي وټاکئ';

  @override
  String get adminScheduleNoSlots => 'تر اوسه وختونه نشته';

  @override
  String get adminScheduleNoSlotsHint => 'لومړی وخت زیاتولو لپاره + کېکاږئ';

  @override
  String get adminSchoolSettingsTitle => 'د ښوونځي تنظیمات';

  @override
  String get adminSchoolName => 'د ښوونځي نوم';

  @override
  String get adminSchoolLogoUrl => 'د لوگو لینک (اختیاري)';

  @override
  String get adminSchoolLogoHint => 'https://…';

  @override
  String get adminSchoolSaved => 'وساتل شو';

  @override
  String get adminSubjectsTitle => 'مضامین';

  @override
  String adminSubjectsGrade(int grade) {
    return 'ټولګی $grade';
  }

  @override
  String get adminSubjectsAddHint => 'مضمون زیاتول…';

  @override
  String get adminSubjectsNoSubjects => 'هیڅ مضمون نه دی تنظیم شوی';

  @override
  String get adminSubjectsAdd => 'زیاتول';

  @override
  String get adminSubjectsRemove => 'لرې کول';

  @override
  String get adminSettingsTitle => 'تنظیمات';

  @override
  String get adminSettingsBellSchedule => 'د زنګ مهالویش';

  @override
  String get adminSettingsPeriodDefaults => 'د وخت اصلي تنظیمات';

  @override
  String get adminSettingsPeriodDefaultsSubtitle =>
      'د هر وخت لپاره د زنګ مهال وټاکئ';

  @override
  String get adminDeleteConfirmCancel => 'لغوه';

  @override
  String get adminDeleteConfirmDelete => 'ړنګول';

  @override
  String get adminSave => 'ساتل';

  @override
  String get adminCancel => 'لغوه';

  @override
  String get adminSearchPeople => 'د نوم له مخې ولټوئ…';

  @override
  String adminNoResults(Object query) {
    return 'د \"$query\" لپاره پایلې نشته';
  }

  @override
  String adminNoPeopleYet(Object role) {
    return 'تر اوسه $role نشته';
  }

  @override
  String get commonRetry => 'بیا هڅه';

  @override
  String get commonBack => 'بیرته';

  @override
  String get commonClose => 'بندول';

  @override
  String get commonDownload => 'ډاونلوډ';

  @override
  String get commonOpenExternally => 'بهر پرانیستل';

  @override
  String get commonSave => 'ساتل';

  @override
  String get commonCancel => 'لغوه';

  @override
  String get commonDone => 'بشپړ شو';

  @override
  String get commonDelete => 'ړنګول';

  @override
  String get commonEdit => 'سمول';

  @override
  String get commonSearch => 'لټون…';

  @override
  String get commonShare => 'شریکول';

  @override
  String get commonLoading => 'بارېږي…';

  @override
  String get commonError => 'یوه ستونزه رامنځته شوه';

  @override
  String get commonTryAgain => 'بیا هڅه وکړئ';

  @override
  String get studentMaterialsTitle => 'توکي';

  @override
  String get studentMaterialsEmptyTitle => 'تر اوسه هیڅ توکی نه دی شریک شوی';

  @override
  String get studentMaterialsEmptyHint =>
      'ستاسو ښوونکی به دلته سرچینې شریکې کړي.';

  @override
  String get studentMaterialsLoadError => 'توکي بار نشول';

  @override
  String get studentAssignmentSubmittedSnackbar => 'دنده وسپارل شوه!';

  @override
  String get studentAssignmentSubmitFailed =>
      'نه وسپارل شوه — مهرباني وکړئ بیا هڅه وکړئ.';

  @override
  String get studentAssignmentUploadFailed =>
      'د فایل اپلوډ پاتې راغی — مهرباني وکړئ بیا هڅه وکړئ.';

  @override
  String get studentAssignmentHandedInBadge => 'وسپارل شوه';

  @override
  String get studentAssignmentSubmitButton => 'سپارل';

  @override
  String get studentAssignmentSubmitting => 'سپارل کیږي…';

  @override
  String get studentAssignmentAttachFile => 'فایل ضمیمه کول';

  @override
  String get studentAssignmentAddMoreFiles => 'نور فایلونه زیاتول';

  @override
  String get studentAssignmentYourSubmission => 'ستاسو سپارنه';

  @override
  String get studentAssignmentTeacherAttachments => 'ضمیمې';

  @override
  String secretaryWelcomeGreeting(Object name) {
    return 'سلام $name 👋';
  }

  @override
  String get secretaryYourTools => 'ستاسو وسایل';

  @override
  String get secretaryReports => 'راپورونه';

  @override
  String get secretaryExportData => 'معلومات صادرول';

  @override
  String get secretaryHomeTile => 'کور';

  @override
  String parentHomeGreeting(Object name) {
    return 'سلام $name 👋';
  }

  @override
  String get parentYourTools => 'ستاسو وسایل';

  @override
  String get parentNoChildLinked => 'تر اوسه هیڅ ماشوم نه دی تړل شوی';

  @override
  String get parentPickChildFirst => 'لومړی یو ماشوم وټاکئ';

  @override
  String get parentNoApprovedChildren =>
      'تر اوسه تایید شوي ماشومان نشته. له خپل ښوونځي وغواړئ چې ستاسو حساب وتړي.';

  @override
  String get loginEmptyFieldsError =>
      'مهرباني وکړئ خپل بریښنالیک یا کارن‌نوم او پټنوم ولیکئ.';

  @override
  String get loginConnectionError =>
      'هیڅ اړیکه نشته. خپل انټرنیټ وګورئ او بیا هڅه وکړئ.';

  @override
  String get loginTimeoutError =>
      'د غوښتنې وخت پای ته ورسید. مهرباني وکړئ بیا هڅه وکړئ.';

  @override
  String get loginForgotPasswordLink => 'پټنوم مو هیر شو؟';

  @override
  String get forgotPasswordTitle => 'خپل پټنوم بیا تنظیم کړئ';

  @override
  String get forgotPasswordModeEmail => 'بریښنالیک';

  @override
  String get forgotPasswordModeSms => 'SMS';

  @override
  String get forgotPasswordEmailSent =>
      'د بیا تنظیمولو لینک ولیږل شو (که حساب سمون ولري).';

  @override
  String get forgotPasswordEmptyError =>
      'د دوام لپاره خپل بریښنالیک یا کارن‌نوم ولیکئ.';

  @override
  String get forgotPasswordEmailButton =>
      'د بیا تنظیمولو لینک راته بریښنالیک کړئ';

  @override
  String get forgotPasswordSmsButton => 'د بیا تنظیمولو لینک راته پیغام کړئ';

  @override
  String get forgotPasswordLinkExpires =>
      'دا لینک په ۱ ساعت کې پای ته رسیږي او یوازې یو ځل کارېدلی شي.';

  @override
  String get pushPermissionTitle => 'خبر اوسئ';

  @override
  String get pushPermissionBody =>
      'خبرتیاوې فعالې کړئ ترڅو نمرې، پیغامونه، یا د مهالویش بدلونونه له لاسه ورنکړئ.';

  @override
  String commonRequiredField(Object field) {
    return '$field اړین دی';
  }

  @override
  String get commonAttachments => 'ضمیمې';

  @override
  String get commonAttachFile => 'فایل ضمیمه کول';

  @override
  String get commonReplaceFile => 'فایل بدلول';

  @override
  String get commonTitleRequired => 'سرلیک اړین دی';

  @override
  String get commonPublish => 'خپرول';

  @override
  String get commonContinue => 'دوام';

  @override
  String get commonNext => 'بل';

  @override
  String get commonStart => 'پیل';

  @override
  String get commonEnd => 'پای';

  @override
  String get commonRefresh => 'تازه کول';

  @override
  String get commonRemove => 'لرې کول';

  @override
  String get commonOpen => 'پرانیستل';

  @override
  String get commonView => 'کتل';

  @override
  String get commonCopy => 'کاپي';

  @override
  String get commonAdd => 'زیاتول';

  @override
  String get commonOptional => 'اختیاري';

  @override
  String get commonRequired => 'اړین';

  @override
  String get commonAuto => 'اتومات';

  @override
  String get teacherShareButton => 'شریکول';

  @override
  String get teacherMaterialDetails => 'د توکي تفصیلات';

  @override
  String get teacherMaterialTitleLabel => 'سرلیک *';

  @override
  String get teacherMaterialDescriptionLabel => 'تشریح (اختیاري)';

  @override
  String get teacherMaterialContentSection => 'محتوا';

  @override
  String get teacherMaterialContentRequired =>
      'مهرباني وکړئ یو فایل ضمیمه یا لینک زیات کړئ';

  @override
  String teacherFilePickError(Object error) {
    return 'فایل نه ټاکل کیږي: $error';
  }

  @override
  String get teacherScheduleButton => 'مهالویش';

  @override
  String get teacherMeetingTitleField => 'د غونډې سرلیک *';

  @override
  String get teacherMeetingLinkField => 'د غونډې لینک *';

  @override
  String get teacherMeetingLinkRequired => 'د غونډې لینک اړین دی';

  @override
  String get teacherMeetingTitleRequired => 'د غونډې سرلیک اړین دی';

  @override
  String get teacherMeetingDateTimeRequired => 'د پیل نیټه او وخت اړین دي';

  @override
  String get teacherMeetingStartDate => 'د پیل نیټه *';

  @override
  String get teacherMeetingStartTime => 'د پیل وخت *';

  @override
  String get teacherMeetingEndDate => 'د پای نیټه (اختیاري)';

  @override
  String get teacherMeetingEndTime => 'د پای وخت (اختیاري)';

  @override
  String get teacherClearEndTime => 'د پای وخت پاکول';

  @override
  String get teacherAssignmentTitleField => 'سرلیک *';

  @override
  String get teacherAssignmentInstructions => 'لارښوونې (اختیاري)';

  @override
  String get teacherAssignmentDueDate => 'د سپارلو نیټه (اختیاري)';

  @override
  String get teacherAssignmentClearDueDate => 'د سپارلو نیټه پاکول';

  @override
  String get teacherAssignmentMaxGrade => 'اعظمي نمره (اختیاري)';

  @override
  String get teacherAssignmentPublished => 'دنده خپره شوه.';

  @override
  String get teacherAssignmentDraftSaved => 'مسوده وساتل شوه.';

  @override
  String get teacherCreateAssignment => 'جوړول';

  @override
  String get teacherExamSubject => 'مضمون *';

  @override
  String get teacherExamDate => 'د ازموینې نیټه *';

  @override
  String get teacherSelectSubject => 'مضمون وټاکئ';

  @override
  String get teacherNoSubjectOption => 'هیڅ مضمون نه';

  @override
  String get teacherOtherSubjectOption => 'نور';

  @override
  String get teacherSearchClassrooms => 'ټولګي ولټوئ…';

  @override
  String get teacherSearchMaterials => 'توکي ولټوئ…';

  @override
  String get teacherClassroomName => 'د ټولګي نوم *';

  @override
  String get adminReportsOpenTab => 'پرانیستی';

  @override
  String get adminReportsResolvedTab => 'حل شوی';

  @override
  String get adminReportsDismissedTab => 'رد شوی';

  @override
  String get adminReportsNoOpen => 'هیڅ پرانیستی راپور نشته';

  @override
  String get adminReportsNoInView => 'په دې کتنه کې راپورونه نشته';

  @override
  String get adminReportsMediaAttachment => '[رسنۍ ضمیمه]';

  @override
  String get adminReportsEmptyMessage => '(تش پیغام)';

  @override
  String get adminReportsDismiss => 'ردول';

  @override
  String get adminReportsResolve => 'حلول';

  @override
  String adminReportsReason(Object reason) {
    return 'علت: $reason';
  }

  @override
  String get chatReportTitle => 'پیغام راپورول';

  @override
  String get chatReportButton => 'راپور';

  @override
  String get chatReportSuccess => 'راپور شو. مننه — یو مدیر به یې وګوري.';

  @override
  String chatReportFailed(Object error) {
    return 'راپور پاتې راغی: $error';
  }

  @override
  String chatSendError(Object message) {
    return 'نه ولیږل شو: $message';
  }

  @override
  String chatForwardLabel(Object count) {
    return 'لیږل $count';
  }

  @override
  String chatDeleteLabel(Object count) {
    return 'ړنګول $count';
  }

  @override
  String chatSelectedCount(Object count) {
    return '$count ټاکل شوي';
  }

  @override
  String get adminSetupSchoolSetup => 'د ښوونځي تنظیمول';

  @override
  String get adminSetupComplete =>
      'هرڅه چمتو دي. د بیا کتنې یا سمون لپاره هر توکی کېکاږئ.';

  @override
  String get adminSetupInstructions =>
      'د خپل ښوونځي د بشپړ تنظیمولو لپاره دا ګامونه بشپړ کړئ.';

  @override
  String get adminSetupLogoTitle => 'د ښوونځي لوگو اپلوډ کول';

  @override
  String get adminSetupLogoSubtitle => 'په سرلیکونو او اړخیز پاڼه کې ښکاري';

  @override
  String get adminSetupNameTitle => 'د ښوونځي نوم ټاکل';

  @override
  String get adminSetupNameSubtitle => 'زده کوونکو، ښوونکو او والدینو ته ښکاري';

  @override
  String get adminSetupSubjectsTitle => 'مضامین تعریفول';

  @override
  String get adminSetupSubjectsSubtitle =>
      'لږ تر لږه یو ټولګی له تنظیم شوو مضامینو سره';

  @override
  String get adminSetupBellTitle => 'د زنګ مهالویش ټاکل';

  @override
  String get adminSetupBellSubtitle => 'د هر وخت پیل/پای وختونه';

  @override
  String get adminSetupCohortsTitle => 'ډلې جوړول';

  @override
  String get adminSetupCohortsSubtitle => 'خپل د ټولګي ډلې تنظیم کړئ';

  @override
  String get adminSetupStudentsTitle => 'زده کوونکي زیاتول';

  @override
  String get adminSetupStudentsSubtitle =>
      'حسابونه جوړ کړئ یا د یوځای کیدو کوډونه جوړ کړئ';

  @override
  String get adminSetupTeachersTitle => 'ښوونکي زیاتول';

  @override
  String get adminSetupTeachersSubtitle => 'د ښوونکو حسابونه جوړ کړئ';

  @override
  String get supportContactTitle => 'موږ سره خبرې وکړئ';

  @override
  String get supportContactDescription =>
      'خپله ځواب لاندې نه مومئ؟ موږ سره اړیکه ونیسئ او موږ به د یوې کاري ورځې په جریان کې درته ځواب ووایو.';

  @override
  String get supportEmailLabel => 'بریښنالیک';

  @override
  String get supportPhoneLabel => 'تلیفون';

  @override
  String get supportSmsLabel => 'پیغام';

  @override
  String get aboutWhatIsClassmate => 'ClassMate څه شی دی؟';

  @override
  String get aboutClassmateDescription =>
      'ClassMate د زده کوونکو، ښوونکو، مدیرانو او والدینو لپاره د ښوونځي عملیاتي سیستم دی. یوه اپلیکیشن، څلور رولونه، د ښوونځي د ورځې هره برخه په یوه ځای کې — مهالویش، حاضري، نمرې، ټولګي، دندې، پیغامونه او د زده کړې مصنوعي هوښیار ملګری.';

  @override
  String get aboutMultilingualTitle =>
      'د هغو ښوونځیو لپاره چې له یوې څخه زیاتو ژبو خبرې کوي';

  @override
  String get aboutMultilingualDescription =>
      'هر نوم، مضمون او اعلان تر پنځو ژبو پورې بڼې لرلی شي (انګلیسي، عربي، عبري، فرانسوي، روسي). زده کوونکي هغه ژبه ویني چې پکې راحته وي؛ ښوونکي په خپله ژبه اداره کوي.';

  @override
  String get aboutPrivacyTitle => 'محرمیت لومړی';

  @override
  String get aboutPrivacyDescription =>
      'د ښوونځي معلومات د ښوونځي دننه پاتې کیږي. رولونه پاکه سره سمون لري چې هر څوک څه لیدلی شي — ښوونکي خپل ټولګي ویني، مدیران خپل ښوونځی ویني، والدین خپل ماشومان ویني. هیڅ دریم اړخیز تعقیب کوونکی نشته، هیڅ اعلاناتي شبکه نشته.';

  @override
  String get aboutContactTitle => 'اړیکه';

  @override
  String get aboutContactDescription =>
      'د ClassMate ټیم لخوا جوړ شوی.\nپوښتنې: support@classmateapp.org';

  @override
  String aboutVersionLabel(Object version) {
    return 'ClassMate · v$version';
  }

  @override
  String get adminAddStudent => 'زده کوونکی زیاتول';

  @override
  String get adminAddTeacher => 'ښوونکی زیاتول';

  @override
  String get adminAddParent => 'والد زیاتول';

  @override
  String get adminAddSecretary => 'منشي زیاتول';

  @override
  String get adminAddAdmin => 'مدیر زیاتول';

  @override
  String get adminEditUser => 'کاروونکی سمول';

  @override
  String get adminNoEmailPlaceholder => '(بریښنالیک نشته)';

  @override
  String get adminNameEnglishRequired => 'بشپړ نوم (انګلیسي) اړین دی';

  @override
  String get adminUsernameRequired => 'کارن‌نوم اړین دی';

  @override
  String get adminPasswordMinLength =>
      'پټنوم باید لږ تر لږه ۸ توري وي (یا یې تش پریږدئ ترڅو اتومات جوړ شي)';

  @override
  String adminUserCreatedMsg(Object name) {
    return '$name جوړ شو.';
  }

  @override
  String get adminCredsUsername => 'کارن‌نوم';

  @override
  String get adminCredsEmail => 'بریښنالیک';

  @override
  String get adminCredsPassword => 'پټنوم';

  @override
  String get adminShareCredsHint => 'دا اسناد له زده کوونکي سره شریک کړئ.';

  @override
  String get adminCopyCredsButton => 'ټول کاپي';

  @override
  String get adminGradeLabel => 'ټولګی';

  @override
  String adminCohortGradeFormat(Object grade) {
    return 'ټولګی $grade';
  }

  @override
  String get adminCreateAndAddStudents => 'جوړول او زده کوونکي زیاتول';

  @override
  String get adminAddStudentsTitle => 'زده کوونکي زیاتول';

  @override
  String get adminSkipAdding => 'تیریدل';

  @override
  String get adminInCohortBadge => 'په ډله کې';

  @override
  String get adminNoStudentsFoundCohort =>
      'د دې ډلې په ټولګیو کې زده کوونکي ونه موندل شول';

  @override
  String get adminScheduleByCohort => 'د ډلې له مخې ▾';

  @override
  String get adminScheduleByStudent => 'د زده کوونکي له مخې ▾';

  @override
  String get adminScheduleByGrade => 'د ټولګي له مخې ▾';

  @override
  String get navSupport => 'ملاتړ';

  @override
  String get navAbout => 'په اړه';

  @override
  String get adminScheduleAddGrade => 'ټولګی زیاتول';

  @override
  String get adminScheduleAddCohort => 'ډله زیاتول';

  @override
  String get adminScheduleAddStudent => 'زده کوونکی زیاتول';

  @override
  String get adminScheduleClearFilters => 'پاکول';

  @override
  String get adminSchedulePickSubjectRequired =>
      'د وخت له ساتلو مخکې یو مضمون وټاکئ.';

  @override
  String get adminSchedulePickDateOnce => 'د یوځلي وخت لپاره نیټه وټاکئ.';

  @override
  String adminSchedulePickDateRecurring(Object freq) {
    return 'د هرې $freq اونۍ مهالویش لپاره د پیل نیټه وټاکئ.';
  }

  @override
  String get adminSchoolLogoLabel => 'د ښوونځي لوگو';

  @override
  String get adminSchoolLogoUploaded => 'لوگو اپلوډ شو';

  @override
  String get adminSchoolNoLogoYet => 'تر اوسه لوگو نشته';

  @override
  String get adminSchoolLogoDescription =>
      'په اپلیکیشن اړخیز پاڼه کې ستاسو د ښوونځي نوم تر څنګ ښکاري.';

  @override
  String get adminSchoolLogoChange => 'بدلول';

  @override
  String get adminSchoolLogoUpload => 'اپلوډ';

  @override
  String get adminSchoolLogoRemove => 'لرې کول';

  @override
  String get adminSchoolGradeRangeLabel => 'د ټولګیو حدود';

  @override
  String get adminSchoolGradeRangeDescription =>
      'هغه ټولګي چې په ډلو، زده کوونکو او ټاکونکو کې شته.';

  @override
  String get adminSchoolLowestGrade => 'ټیټ';

  @override
  String get adminSchoolHighestGrade => 'لوړ';

  @override
  String get adminSchoolSubjectsTitle => 'د ښوونځي مضامین';

  @override
  String get adminSchoolSubjectsDescription =>
      'د دندو په جوړولو کې ټولو ښوونکو ته شته.';

  @override
  String get adminSchoolNoTranslations => 'د ژباړو زیاتولو لپاره کېکاږئ';

  @override
  String get adminSchoolBellHint =>
      'د هر وخت لپاره د پیل او پای وختونه وټاکئ. د اړتیا سره سم وختونه زیات یا لرې کړئ.';

  @override
  String get adminSchoolBellTitle => 'د زنګ مهالویش';

  @override
  String get adminSchoolBellInfo =>
      'د هر وخت لپاره د پیل او پای وخت وټاکئ. دا د اونۍ مهالویش جوړولو پر مهال د اصلي وختونو په توګه کارول کیږي.';

  @override
  String get adminSchoolStartTime => 'پیل';

  @override
  String get adminSchoolEndTime => 'پای';

  @override
  String get adminExportStudentsTab => 'زده کوونکي';

  @override
  String get adminExportCohortsTab => 'ډلې';

  @override
  String get adminExportGradesTab => 'نمرې';

  @override
  String get adminExportOptionsTitle => 'د صادرولو اختیارونه';

  @override
  String get adminExportIncludePasswords => 'پټنومونه شاملول';

  @override
  String get adminExportLanguageLabel => 'په صادرات کې د نوم ژبه';

  @override
  String get adminExportCsvButton => 'CSV صادرول';

  @override
  String get adminExportPdfButton => 'PDF صادرول';

  @override
  String get teacherCreateClassroomTooltip => 'ټولګی جوړول';

  @override
  String get teacherClassroomNameRequired => 'د ټولګي نوم *';

  @override
  String get teacherSubjectRequired => 'مضمون *';

  @override
  String messagesStartChatError(Object error) {
    return 'خبرې نه پیلیږي: $error';
  }

  @override
  String messagesNoPeopleMatch(Object query) {
    return 'د \"$query\" سره هیڅ کس سمون نه لري';
  }

  @override
  String get messagesNoPeopleFound => 'هیڅ کس ونه موندل شو';

  @override
  String messagesPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کسان',
      one: '۱ کس',
    );
    return '$_temp0';
  }

  @override
  String get studentAssignmentValidationRequired =>
      'د سپارلو مخکې یوه یادښت ولیکئ یا فایل ضمیمه کړئ.';

  @override
  String get studentFormSubmittedBanner => 'ستاسو سپارل شوي ځوابونه';

  @override
  String studentFormSubmitError(Object error) {
    return 'نه وسپارل شو: $error';
  }

  @override
  String studentFormFieldRequired(Object field) {
    return 'اړین: $field';
  }

  @override
  String get studentFormClosedButton => 'فورمه بنده ده';

  @override
  String get studentFormAlreadySubmittedButton => 'مخکې سپارل شوې';

  @override
  String get studentDiplomaEditTitle => 'سند سمول';

  @override
  String get studentDiplomaDeleteTitle => 'سند ړنګ شي؟';

  @override
  String studentDiplomaDeleteConfirm(Object name) {
    return 'د \"$name\" لپاره سند لرې شي؟';
  }

  @override
  String teacherDeleteItemConfirm(Object title) {
    return '\"$title\" ړنګ شي؟';
  }

  @override
  String get teacherPublishTooltip => 'خپرول';

  @override
  String get teacherMeetingEnterTitle => 'مهرباني وکړئ یو سرلیک ولیکئ.';

  @override
  String get teacherMeetingEnterLink => 'مهرباني وکړئ د غونډې لینک ولیکئ.';

  @override
  String get teacherMeetingEnterValidUrl =>
      'مهرباني وکړئ یو سم URL ولیکئ (لکه https://zoom.us/j/...)';

  @override
  String get teacherMeetingPickStartTime => 'مهرباني وکړئ د پیل وخت وټاکئ.';

  @override
  String get teacherMeetingVisibleToEveryone => 'ټولو ته ښکاري';

  @override
  String teacherMeetingDoneCount(int count) {
    return 'بشپړ شو ($count ټاکل شوي)';
  }

  @override
  String get teacherDeleteAssignmentTitle => 'دنده ړنګه شي؟';

  @override
  String get teacherDeleteAssignmentBody =>
      'دا به دنده او ټولې سپارنې د تل لپاره ړنګې کړي.';

  @override
  String get teacherEditTooltip => 'سمول';

  @override
  String get teacherDeleteTooltip => 'ړنګول';

  @override
  String get teacherClassroomBackTooltip => 'بیرته';

  @override
  String teacherClassroomGenericError(Object error) {
    return 'تېروتنه: $error';
  }

  @override
  String teacherClassroomAttachFailed(Object error) {
    return 'ضمیمه پاتې راغله: $error';
  }

  @override
  String get teacherClassroomFileUnavailable =>
      'دا فایل شتون نلري — ښوونکی باید بیا یې اپلوډ کړي.';

  @override
  String get teacherClassroomCodeLabel => 'د ټولګي کوډ';

  @override
  String get teacherClassroomCodeCopied => 'کوډ کاپي شو';

  @override
  String get teacherClassroomCopyCodeTooltip => 'کوډ کاپي';

  @override
  String teacherClassroomCouldNotAdd(Object emails) {
    return 'نه شول زیات: $emails — د دوی بریښنالیک پته وګورئ.';
  }

  @override
  String get teacherClassroomAddStudents => 'زده کوونکي زیاتول';

  @override
  String get teacherClassroomSearchNameGrade => 'د نوم یا ټولګي له مخې ولټوئ…';

  @override
  String get teacherClassroomNoStudentsFound => 'هیڅ زده کوونکی ونه موندل شو';

  @override
  String get teacherClassroomNameSubjectRequired => 'نوم او مضمون اړین دي.';

  @override
  String get teacherClassroomCreated => 'ټولګی جوړ شو!';

  @override
  String get teacherCustomSubjectLabel => 'دلخواه مضمون *';

  @override
  String get teacherCreateClassroomButton => 'ټولګی جوړول';

  @override
  String get teacherCreateFormTitle => 'فورمه جوړول';

  @override
  String get teacherFormSaveDraft => 'مسوده ساتل';

  @override
  String get teacherFormTitleHint => 'د فورمې سرلیک *';

  @override
  String get teacherFormDescriptionHint => 'تشریح (اختیاري)';

  @override
  String get teacherFormAcceptingResponses => 'ځوابونه منل کیږي';

  @override
  String get teacherFormAllowMultiple => 'ډیر ځوابونه اجازه ورکول';

  @override
  String get teacherFormAllowMultipleSubtitle =>
      'بند = هر زده کوونکي ته یو ځل (اصلي)';

  @override
  String get teacherFormQuestionsSection => 'پوښتنې';

  @override
  String get teacherFormAddQuestionButton => 'پوښتنه زیاتول';

  @override
  String teacherFormQuestionPlaceholder(Object index) {
    return 'پوښتنه $index';
  }

  @override
  String get teacherFormRequiredToggle => 'اړین';

  @override
  String get teacherFormAddOptionButton => 'اختیار ورزیات کړئ';

  @override
  String get teacherFormMinLabel => 'لږ تر لږه';

  @override
  String get teacherFormMaxLabel => 'زیات تر زیاته';

  @override
  String get teacherFormEnterTitle => 'مهرباني وکړئ د فورمې سرليک وليکئ.';

  @override
  String teacherExamUploadFailedSkipped(Object name) {
    return 'د $name پورته کول ناکام شول. فايل پرېښودل شو.';
  }

  @override
  String get teacherExamEnterTitle => 'مهرباني وکړئ سرليک وليکئ.';

  @override
  String get teacherExamPickDate => 'مهرباني وکړئ د ازموینې نېټه وټاکئ.';

  @override
  String get teacherExamSelectSubject => 'مهرباني وکړئ مضمون وټاکئ.';

  @override
  String teacherSlotDetachFailed(Object error) {
    return 'بېلول ناکام شول: $error';
  }

  @override
  String teacherSlotAttachFailed(Object error) {
    return 'نښلول ناکام شول: $error';
  }

  @override
  String get teacherSlotAttachMaterial => 'مواد ونښلوئ';

  @override
  String get teacherSlotDetachTooltip => 'بېلول';

  @override
  String get teacherDiplomaSelectStudent => 'لومړی يو زده‌کوونکی وټاکئ.';

  @override
  String get teacherDiplomaUploadingWait =>
      'مهرباني وکړئ صبر وکړئ — فايلونه لا پورته کيږي.';

  @override
  String teacherDiplomaIssueFailed(Object error) {
    return 'د سند ورکول ناکام شول: $error';
  }

  @override
  String get teacherDiplomaCertTitleLabel => 'د سند سرليک';

  @override
  String get teacherDiplomaSearchStudent => 'زده‌کوونکی ولټوئ…';

  @override
  String get teacherProfileChatError => 'خبرې اترې پيل نه شول';

  @override
  String get teacherGradeAssignmentType => 'دنده';

  @override
  String get teacherGradeExamType => 'ازموینه';

  @override
  String get teacherGradeOtherType => 'نور';

  @override
  String get teacherGradeOutOfLabel => 'له ټولو څخه (اختياري)';

  @override
  String get teacherGradePublishedTitle => 'خپور شو';

  @override
  String get teacherGradePublishedSubtitle => 'زده‌کوونکي دا نمره ليدلی شي';

  @override
  String get teacherMaterialPickSubject => 'مهرباني وکړئ مضمون وټاکئ.';

  @override
  String get teacherMaterialAddLink => 'لينک ورزیات کړئ';

  @override
  String get teacherMaterialAddFile => 'فايل ورزیات کړئ';

  @override
  String get teacherMaterialSearchStudentsGrade =>
      'زده‌کوونکي يا ټولګی ولټوئ...';

  @override
  String teacherMaterialDoneSelected(int count) {
    return 'بشپړ شو ($count ټاکل شوي)';
  }

  @override
  String get adminSubjectEnglishNameRequired => 'انګليسي نوم اړين دی';

  @override
  String adminSubjectNameInLang(Object language) {
    return 'نوم په $language کې';
  }

  @override
  String get adminSubjectResetButton => 'بياځلي تنظيم';

  @override
  String get teacherAnnounceBroadcastTitle => 'ټولو ته ولېږل شي؟';

  @override
  String get teacherAnnounceSendToEveryone => 'ټولو ته ولېږئ';

  @override
  String get teacherAnnounceNoCohorts => 'هيڅ ډله شته نه ده';

  @override
  String get teacherAnnounceNothingFound => 'هيڅ ونه موندل شو';

  @override
  String get teacherAnnounceNoParents =>
      'په دې ښوونځي کې هيڅ مور و پلار ونه موندل شو.';

  @override
  String get teacherGradesToGrade => 'د نمرې لپاره';

  @override
  String get teacherGradesGraded => 'نمره شوي';

  @override
  String get teacherSaveGradesButton => 'نمرې خوندي کړئ';

  @override
  String get teacherAllowResubmitLabel => 'بياځلي سپارلو ته اجازه ورکړئ';

  @override
  String get teacherAllowResubmitTitle => 'بياځلي سپارلو ته اجازه ورکړئ؟';

  @override
  String teacherAllowResubmitBody(Object name) {
    return 'دا به د $name سپارل شوي حذف کړي ترڅو بيا يې وسپاري.';
  }

  @override
  String get teacherAllowButton => 'اجازه ورکړئ';

  @override
  String get teacherGradeFieldLabel => 'نمره';

  @override
  String get teacherFeedbackOptionalLabel => 'نظر (اختياري)';

  @override
  String get teacherCreateClassroomFabLabel => 'جوړول';

  @override
  String get teacherLoadingStudents => 'زده‌کوونکي راوړل کيږي…';

  @override
  String get teacherSearchHintShort => 'لټون…';

  @override
  String get teacherCreateClassroomTitle => 'نوی ټولګی';

  @override
  String teacherAssignmentUploadFailed(Object name) {
    return 'د $name پورته کول ونه شول';
  }

  @override
  String get teacherAssignmentEnterTitle => 'مهرباني وکړئ سرليک وليکئ.';

  @override
  String get teacherAssignmentSelectSubject => 'مهرباني وکړئ مضمون وټاکئ.';

  @override
  String get teacherAssignmentInstructionsLabel => 'لارښوونې / تشريح';

  @override
  String get teacherAttachFilesButton => 'فايلونه ونښلوئ';

  @override
  String get tutorDeleteConversationTitle => 'خبرې اترې حذف کړئ؟';

  @override
  String get tutorDeleteConversationButton => 'د تل لپاره حذف کړئ';

  @override
  String tutorDeleteFailed(Object error) {
    return 'حذف نه شو: $error';
  }

  @override
  String get tutorDeleteMenuTitle => 'خبرې اترې حذف کړئ';

  @override
  String get tutorDeleteMenuSubtitle => 'د تل لپاره يې له سرور څخه لرې کوي';

  @override
  String get accountVerifyButton => 'تاييد';

  @override
  String get accountConfirmButton => 'تاييدول';

  @override
  String get accountResendCode => 'کوډ بيا ولېږئ';

  @override
  String get accountCodeResent => 'نوی کوډ ولېږل شو.';

  @override
  String get accountContinueButton => 'دوام ورکړئ';

  @override
  String get studentClassroomFileUnavailable => 'دا فايل لا تر اوسه شته نه دی.';

  @override
  String get studentClassroomDeleteMaterial => 'مواد حذف کړئ؟';

  @override
  String get studentClassroomCodeLabel => 'د ټولګي کوډ';

  @override
  String get studentClassroomLeaveTooltip => 'ټولګی پرېږدئ';

  @override
  String get adminEditUserEnglishNameRequired => 'انګليسي نوم اړين دی';

  @override
  String get adminEditUserSaved => 'خوندي شو';

  @override
  String adminEditUserPasswordChanged(Object name) {
    return 'د $name پټنوم بدل شو.';
  }

  @override
  String get adminEditUserLoginSection => 'ننوتل';

  @override
  String get adminEditUserUsernameLabel => 'د کارن نوم';

  @override
  String get adminEditUserEmailOptional => 'ايميل (اختياري)';

  @override
  String get adminEditUserChangePassword => 'پټنوم بدل کړئ';

  @override
  String get adminEditUserNameSection => 'نوم';

  @override
  String get adminEditUserAtLeastEnglish => 'لږ تر لږه انګليسي اړين دی.';

  @override
  String get adminEditUserGradeSection => 'ټولګی';

  @override
  String get adminEditUserCohortsSection => 'ډلې';

  @override
  String get adminEditUserLinkedChildren => 'تړل شوي ماشومان';

  @override
  String get adminEditUserLinkButton => 'وتړئ';

  @override
  String get adminEditUserNoChildren => 'تر اوسه هيڅ ماشوم نه دی تړل شوی.';

  @override
  String get adminEditUserSetPasswordTitle => 'نوی پټنوم وټاکئ';

  @override
  String get adminEditUserNewPasswordLabel => 'نوی پټنوم';

  @override
  String get adminEditUserConfirmPasswordLabel => 'پټنوم تاييد کړئ';

  @override
  String get adminEditUserSetPasswordButton => 'پټنوم وټاکئ';

  @override
  String get adminPeriodsTitle => 'د درسي ساعتونو سمبالول';

  @override
  String get adminPeriodsAddPeriod => 'درسي ساعت ورزیات کړئ';

  @override
  String get adminPeriodsNoPeriods => 'تر اوسه هيڅ درسي ساعت نشته';

  @override
  String get adminPeriodsTapToAdd =>
      'د لومړي درسي ساعت ورزياتولو لپاره + کېکاږئ';

  @override
  String get adminPeriodsNewPeriod => 'نوی درسي ساعت';

  @override
  String get adminPeriodsDayLabel => 'ورځ';

  @override
  String get adminPeriodsPeriodLabel => 'درسي ساعت';

  @override
  String get adminPeriodsTimeLabel => 'وخت';

  @override
  String get adminPeriodsTeacherLabel => 'ښوونکی';

  @override
  String get adminPeriodsClassroomOptional => 'ټولګی (اختياري)';

  @override
  String get adminPeriodsCohortsLabel => 'ډلې';

  @override
  String get adminPeriodsStudentsOptional => 'زده‌کوونکي (اختياري)';

  @override
  String get adminPeriodsSearchByName => 'د نوم له مخې ولټوئ…';

  @override
  String commonErrorWith(Object error) {
    return 'تېروتنه: $error';
  }

  @override
  String commonAddCount(int count) {
    return '$count ورزیات کړئ';
  }

  @override
  String get teacherStudentGradesSaved => 'نمرې خوندي شوې';

  @override
  String get teacherStudentToGrade => 'د نمرې لپاره';

  @override
  String get teacherStudentGraded => 'نمره شوي';

  @override
  String get classroomFileNotAvailable => 'دا فايل لا تر اوسه شته نه دی.';

  @override
  String get classroomDeleteMaterialTitle => 'مواد حذف کړئ؟';

  @override
  String get classroomCodeLabel => 'د ټولګي کوډ';

  @override
  String get plansCouldNotOpenSubscription =>
      'د ګډون تنظيمات نه پرانيستل کيدل.';

  @override
  String plansFailedToOpen(Object error) {
    return 'پرانيستل ناکام شول: $error';
  }

  @override
  String get plansManageSubscription => 'ګډون سمبال يا لغوه کړئ';

  @override
  String get plansUpgrade => 'لوړول';

  @override
  String get plansTryAgain => 'بيا هڅه وکړئ';

  @override
  String adminCohortsGradeOnly(String grade) {
    return 'يوازې $grade ټولګی';
  }

  @override
  String adminCohortsGradeRangeOnly(int from, int to) {
    return 'يوازې $from-$to ټولګی';
  }

  @override
  String get adminExportNeedStudents =>
      'لومړی لږ تر لږه يو زده‌کوونکی يا ډله وټاکئ';

  @override
  String adminExportButton(int count) {
    return 'صادرول $count';
  }

  @override
  String get adminExportNoStudents => 'هيڅ زده‌کوونکی ونه موندل شو';

  @override
  String get adminExportIncludesPasswords => 'صادرول به پټنومونه شامل کړي';

  @override
  String get adminExportAnyway => 'بيا هم صادر کړئ';

  @override
  String get adminExportPdfStudentDirectory => 'د زده‌کوونکو لارښود';

  @override
  String adminExportPdfBy(String name) {
    return 'لخوا: $name';
  }

  @override
  String adminExportPdfStudentsCount(int count) {
    return '$count زده‌کوونکي';
  }

  @override
  String get adminExportPdfFooter => 'د ClassMate لخوا جوړ شو';

  @override
  String get adminExportColumnIndex => '#';

  @override
  String get adminExportColumnName => 'نوم';

  @override
  String get adminExportColumnEmail => 'ايميل';

  @override
  String get adminExportColumnUsername => 'د کارن نوم';

  @override
  String get adminExportColumnPhone => 'ټيليفون';

  @override
  String get adminExportColumnGrade => 'ټولګی';

  @override
  String get adminExportColumnCohorts => 'ډلې';

  @override
  String get adminExportColumnSchool => 'ښوونځی';

  @override
  String get adminExportColumnPassword => 'پټنوم';

  @override
  String get adminExportColumnNameEn => 'نوم (EN)';

  @override
  String get adminExportColumnNameAr => 'نوم (AR)';

  @override
  String get adminExportColumnNameHe => 'نوم (HE)';

  @override
  String get adminExportColumnNameFr => 'نوم (FR)';

  @override
  String get adminExportColumnNameRu => 'نوم (RU)';

  @override
  String adminExportStudentsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count زده‌کوونکي ټاکل شوي',
      one: '$count زده‌کوونکی ټاکل شوی',
    );
    return '$_temp0';
  }

  @override
  String get teacherMaterialEditTitle => 'مواد سم کړئ';

  @override
  String get teacherMaterialAddTitle => 'مواد ورزیات کړئ';

  @override
  String get teacherMaterialAudienceTitle => 'اورېدونکي';

  @override
  String get teacherMaterialAudienceClassrooms => 'ټولګيونه';

  @override
  String get teacherMaterialAudienceCohorts => 'ډلې';

  @override
  String get teacherMaterialAudienceGrades => 'ټولګيونه';

  @override
  String get teacherMaterialAudienceStudents => 'زده‌کوونکي';

  @override
  String get teacherMaterialDetailsTitle => 'تفصيلات';

  @override
  String get teacherMaterialSubjectRequired => 'مضمون *';

  @override
  String get teacherMaterialSubjectSelect => 'مضمون وټاکئ';

  @override
  String get teacherMaterialSubjectOther => 'نور';

  @override
  String get teacherMaterialSubjectSearch => 'مضمونونه ولټوئ...';

  @override
  String get teacherMaterialAttachmentsTitle => 'نښلونونه';

  @override
  String teacherMaterialAttachmentsWithCount(int count) {
    return 'نښلونونه ($count)';
  }

  @override
  String get teacherMaterialDeleteTitle => 'مواد حذف کړئ؟';

  @override
  String get teacherMaterialListTitle => 'مواد';

  @override
  String teacherMaterialTotalCount(int count) {
    return '$count ټول';
  }

  @override
  String get teacherMaterialRetry => 'بيا هڅه وکړئ';

  @override
  String get teacherMaterialNoMaterials =>
      'تر اوسه هيڅ مواد نشته.\nد ورزياتولو لپاره + کېکاږئ.';

  @override
  String get teacherMaterialPublished => 'خپور شو';

  @override
  String get teacherMaterialDraft => 'مسوده';

  @override
  String get teacherMaterialSearchHint => 'لټون…';

  @override
  String teacherMaterialSelectedCount(int count) {
    return '$count ټاکل شوي';
  }

  @override
  String teacherMaterialMembersWillReceive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غړي به دا ترلاسه کړي',
      one: '$count غړی به دا ترلاسه کړي',
    );
    return '$_temp0';
  }

  @override
  String teacherMaterialStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count زده‌کوونکي',
      one: '$count زده‌کوونکی',
    );
    return '$_temp0';
  }

  @override
  String get teacherMaterialPickerNone => 'هيڅ';

  @override
  String get teacherMaterialPickerCohortsTitle => 'ډلې وټاکئ';

  @override
  String get teacherMaterialPickerClassroomTitle => 'ټولګی وټاکئ';

  @override
  String get teacherMaterialPickerStudentsTitle => 'زده‌کوونکي وټاکئ';

  @override
  String get teacherMaterialPickerGradesTitle => 'ټولګيونه وټاکئ';

  @override
  String get adminScheduleAddNew => 'نوی ورزیات کړئ';

  @override
  String adminScheduleAddCount(int count) {
    return 'ورزیات کړئ ($count)';
  }

  @override
  String get adminScheduleCaptionOptional => 'سرليک (اختياري)';

  @override
  String get adminScheduleCaptionHint => 'د بېلګې په توګه د ازموینې بياکتنه';

  @override
  String get adminScheduleAudienceCohorts => 'ډلې';

  @override
  String get adminScheduleAudienceStudents => 'زده‌کوونکي';

  @override
  String get adminScheduleAudienceGrade => 'ټولګی';

  @override
  String get adminScheduleSearchStudents => 'زده‌کوونکي ولټوئ…';

  @override
  String get adminScheduleSearchSubjects => 'د ښوونځي مضمونونه ولټوئ…';

  @override
  String get adminScheduleEveryPrefix => 'هر ';

  @override
  String get adminScheduleWeeksSuffix => ' اونۍ';

  @override
  String adminScheduleSlotN(int index) {
    return 'ځای $index';
  }

  @override
  String adminScheduleSelectedCount(int count) {
    return '$count ټاکل شوي';
  }

  @override
  String get adminScheduleConflictingPeriod => 'ټکر کوونکی درسي ساعت';

  @override
  String get adminScheduleKeepCurrent => 'اوسنی وساتئ';

  @override
  String get adminScheduleOverride => 'بدلون ورکړئ';

  @override
  String get adminScheduleShowBoth => 'دواړه وښيئ';

  @override
  String get adminScheduleDeletePeriodTitle => 'درسي ساعت حذف کړئ؟';

  @override
  String get adminScheduleDeletePeriodBody =>
      'دا ځای له مهال ويش څخه لرې کوي. تېر حاضري پاتې کيږي.';

  @override
  String get adminScheduleFailedToDelete => 'درسي ساعت حذف کول ناکام شول.';

  @override
  String get adminSchedulePickSubjectFirst =>
      'د درسي ساعت له خوندي کولو مخکې يو مضمون وټاکئ.';

  @override
  String adminScheduleOverrideFailed(Object error) {
    return 'بدلون ناکام شو: $error';
  }

  @override
  String get adminScheduleFailedToCreateSlots => 'د ځايونو جوړول ناکام شول';

  @override
  String adminScheduleCreatedSlots(int created, int total, String error) {
    return '$created/$total ځايونه جوړ شول. $error';
  }

  @override
  String adminScheduleSavedLabelOnlyError(Object error) {
    return 'يوازې د ځای ليبل په توګه خوندي شو — کتابتون ته يې اضافه نه شو کولی: $error';
  }

  @override
  String get adminScheduleSavedLabelPickAudience =>
      'د ځای ليبل په توګه خوندي شو. د ښوونځي کتابتون ته يې هم د اضافه کولو لپاره لومړی اورېدونکي وټاکئ.';

  @override
  String get commonNothingFound => 'هيڅ ونه موندل شو';

  @override
  String commonDownloadFailed(Object error) {
    return 'ښکته کول ناکام شول: $error';
  }

  @override
  String commonFailedWith(Object error) {
    return 'ناکام شو: $error';
  }

  @override
  String get commonCreate => 'جوړول';

  @override
  String get commonAttachStudyMaterials => 'د زده‌کړې مواد ونښلوئ';

  @override
  String get teacherCreateClassroomNewTitle => 'نوی ټولګی';

  @override
  String get teacherCreateClassroomLoadingStudents => 'زده‌کوونکي راوړل کيږي…';

  @override
  String get teacherExamPublishedHint =>
      'خپور شو — زده‌کوونکي دا ازموینه ليدلی شي';

  @override
  String teacherDoneSelected(int count) {
    return 'بشپړ شو ($count ټاکل شوي)';
  }

  @override
  String get secretaryAllCohorts => 'ټولې ډلې';

  @override
  String get secretaryClassrooms => 'ټولګيونه';

  @override
  String get adminPeopleGrade => 'ټولګی';

  @override
  String get adminSchoolSettingsTapToAddTranslations =>
      'د ژباړو اضافه کولو لپاره کېکاږئ';

  @override
  String adminSchoolSettingsAddPeriodNum(int num) {
    return 'درسي ساعت ورزیات کړئ (P$num)';
  }

  @override
  String get adminVisibleToEveryone => 'ټولو ته ښکاره';

  @override
  String get navMaterials => 'مواد';

  @override
  String get classMaterialsAddTitle => 'مواد ورزیات کړئ';

  @override
  String get classMaterialsTitleLabel => 'سرليک';

  @override
  String classMaterialsFilesCount(int count) {
    return '$count فايلونه';
  }

  @override
  String get classMaterialsLoadError => 'مواد نه راوړل کيدل';

  @override
  String get classMaterialsEmpty =>
      'تر اوسه هيڅ مواد نشته — د شريکولو لپاره ورزیات کېکاږئ.';

  @override
  String get navPlans => 'د NOVA پلانونه';

  @override
  String get navReports => 'راپورونه';

  @override
  String get navExportData => 'ډاټا صادرول';

  @override
  String get sectionSecretaryTools => 'د منشي وسايل';

  @override
  String get sectionSchoolToolsLabel => 'د ښوونځي وسايل';

  @override
  String get sectionAdminTools => 'د اډمين وسايل';

  @override
  String get chatVideoTrimTitle => 'ويډيو پرې کړئ';

  @override
  String get chatMediaPreviewTrimAction => 'پرې کول';

  @override
  String get commonUntitled => 'بې سرليکه';

  @override
  String get plansMonthlyPlans => 'مياشتني پلانونه';

  @override
  String get plansTokenTopups => 'د ټوکنو ډکول';

  @override
  String get plansTopupsSubtitle =>
      'يو ځلي پيرود. هيڅکله نه ختميږي. ستاسو پلان باندې ورزياتيږي.';

  @override
  String get plansCouldntLoadBalance => 'ستاسو پاتې اندازه نه راوړل کيده';

  @override
  String get plansFreePlan => 'وړيا پلان';

  @override
  String get planTierFree => 'وړيا';

  @override
  String get planTierBudget => 'بودجه';

  @override
  String get planTierBalance => 'بيلانس';

  @override
  String get planTierCommitment => 'ژمنه';

  @override
  String get topupPackSmall => 'کوچنۍ بسته';

  @override
  String get topupPackMedium => 'منځنۍ بسته';

  @override
  String get topupPackLarge => 'لويه بسته';

  @override
  String get topupPackMega => 'ډيره لويه بسته';

  @override
  String get planBlurbFree => 'د NOVA خوند وڅکئ. هره مياشت بياځلي تنظيميږي.';

  @override
  String get planBlurbBudget => 'د ورځني کور دندو مرسته.';

  @override
  String get planBlurbBalance =>
      'د هغو زده‌کوونکو لپاره چې هره ورځ مطالعه کوي.';

  @override
  String get planBlurbCommitment => 'ډيره تمرين + بې حده پلټنه.';

  @override
  String plansTokensPerMonth(String tokens) {
    return '$tokens ټوکن / مياشت';
  }

  @override
  String plansTokensOneTime(String tokens) {
    return '$tokens ټوکن';
  }

  @override
  String get planPriceFree => 'وړيا';

  @override
  String get plansTokensRemaining => 'پاتې ټوکنونه';

  @override
  String plansPlanResetsAt(String when) {
    return 'پلان بياځلي تنظيميږي $when';
  }

  @override
  String plansTopupTokensInfo(String tokens) {
    return '$tokens اضافي ټوکنونه (بې ختميدو)';
  }

  @override
  String get plansHowTokensWorkTitle => 'ټوکنونه څنګه کار کوي';

  @override
  String get plansHowTokensWorkBody =>
      'ټوکنونه هغه څه دي چې AI پرې خپل کار شميري.\n• يوه لنډه پوښتنه ≈ ۲٬۰۰۰ ټوکن\n• يوه اوږده تشريح يا د تمرين ناسته ≈ ۵٬۰۰۰–۱۰٬۰۰۰\n• د انځور شننه يو څه زياته لګښت لري\n\nستاسو مياشتني ټوکنونه د مياشتې په لومړۍ نېټه بياځلي تنظيميږي. اضافي ټوکنونه هيڅکله نه ختميږي.';

  @override
  String get plansPerMonthSuffix => ' / مياشت';

  @override
  String get plansCurrentBadge => 'اوسنی';

  @override
  String get plansCouldntLoadPlans => 'پلانونه نه راوړل کيدل';

  @override
  String get paywallPlansUnavailable =>
      'پلانونه شته نه دي. يوه شيبه وروسته بيا هڅه وکړئ.';

  @override
  String get paywallTopupUnavailable =>
      'ډکول شته نه دي. پلورنځي لا د دې محصول تاييد نه دی بشپړ کړی.';

  @override
  String get paywallRestored => 'ستاسو ګډون بيا ترلاسه شو.';

  @override
  String get paywallNoRestores =>
      'په دې Apple ID کې هيڅ پخوانی پيرود ونه موندل شو.';

  @override
  String paywallRestoreFailed(String error) {
    return 'بيا ترلاسه کول ناکام شول: $error';
  }

  @override
  String get paywallPurchasesRestricted => 'په دې وسيله کې پيرودونه محدود دي.';

  @override
  String get paywallPurchaseInvalid =>
      'دا پيرود معتبر نه دی. بله د تادياتو لاره وآزمويئ.';

  @override
  String get paywallProductNotAvailable =>
      'دا پلان اوس مهال شته نه دی. وروسته بيا هڅه وکړئ.';

  @override
  String get paywallNetworkError =>
      'د شبکې ستونزه. خپل اړيکه وګورئ او بيا هڅه وکړئ.';

  @override
  String get paywallPaymentPending =>
      'تادیه د تاييد په تمه ده (د والدينو کنټرول، نور). د تاييد وروسته به فعاله شي.';

  @override
  String get paywallStoreProblem =>
      'د App Store سره ستونزه وه. يوه دقيقه وروسته بيا هڅه وکړئ.';

  @override
  String get paywallGenericError => 'يو څه خراب شول. بيا هڅه وکړئ.';

  @override
  String paywallWelcomeMessage(String plan) {
    return '$plan ته ښه راغلاست! ټوکنونه په لاره دي.';
  }

  @override
  String get paywallWelcomeFallback => 'ستاسو نوی پلان';

  @override
  String get paywallTopupAdded => 'ډکول ورزیات شو. ټوکنونه په لاره دي.';

  @override
  String get paywallPurchaseProcessed =>
      'پيرود پروسس شو. ټوکنونه به ډير ژر ښکاره شي.';

  @override
  String paywallSubscribeTo(String plan) {
    return 'په $plan کې ګډون وکړئ';
  }

  @override
  String paywallBuyTopupNamed(String topup) {
    return '$topup وپيرئ';
  }

  @override
  String get paywallPlanFallback => 'پلان';

  @override
  String get paywallTopupFallback => 'ډکول';

  @override
  String get paywallTopupBlurb =>
      'يو ځلي پيرود. ټوکنونه هيڅکله نه ختميږي او ستاسو پلان باندې ورزياتيږي.';

  @override
  String paywallPerMonthWithTokens(String tokens) {
    return 'هره مياشت · $tokens';
  }

  @override
  String paywallOneTimeWithTokens(String tokens) {
    return 'يو ځلي · $tokens';
  }

  @override
  String get paywallSubscribeButton => 'ګډون وکړئ';

  @override
  String get paywallBuyButton => 'وپيرئ';

  @override
  String get paywallRestoreButton => 'پيرودونه بيا ترلاسه کړئ';

  @override
  String get paywallNotNow => 'اوس نه';

  @override
  String get paywallWebOnlyTitle => 'په موبايل کې وپيرئ';

  @override
  String get paywallWebOnlyBody =>
      'ګډونونه او ډکولونه د App Store يا Google Play له لارې ترسره کيږي. د ګډون لپاره ClassMate په خپل iPhone، iPad، يا Android ټيليفون کې پرانيزئ — ستاسو حساب او ټوکنونه د ټولو وسايلو ترمنځ شريک دي.';

  @override
  String get paywallWebOnlyDismiss => 'پوه شوم';

  @override
  String get paywallTermsSubscription =>
      'د ګډون سره تاسو د ClassMate د شرايطو او د محرميت تګلارې سره موافقه کوئ. ګډونونه تر لغوه کيدو پورې هره مياشت په اتومات ډول تازه کيږي. هر وخت يې په خپل App Store حساب کې سمبال کړئ.';

  @override
  String get paywallTermsTopup =>
      'د پيرود سره تاسو د ClassMate د شرايطو او د محرميت تګلارې سره موافقه کوئ. اضافي ټوکنونه له لګښت وروسته بيرته نه ورکول کيږي.';

  @override
  String get paywallTermsLink => 'د کارولو شرايط (EULA)';

  @override
  String get paywallPrivacyLink => 'د محرميت تګلاره';

  @override
  String get paywallFeatureTokens =>
      'ټوکنونه د NOVA خبرو اترو او تمرين ناستو کې وکاروئ';

  @override
  String get paywallFeatureImages => 'د انځور شننه او د فايل پورته کول شامل دي';

  @override
  String get paywallFeatureReset =>
      'ټوکنونه د هرې مياشتې په پيل کې بياځلي تنظيميږي';

  @override
  String get paywallFeatureCancel => 'هر وخت لغوه کړئ — هيڅ ژمنه نشته';

  @override
  String get studentMaterialsGeneralSubject => 'عمومي';

  @override
  String studentMaterialsResourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سرچينې ستاسو له ښوونکو څخه',
      one: '$count سرچينه ستاسو له ښوونکو څخه',
    );
    return '$_temp0';
  }

  @override
  String classroomsCouldNotLoadWithError(String error) {
    return 'ټولګيونه نه راوړل کيدل\n$error';
  }

  @override
  String get parentNoNotificationsYet => 'تر اوسه هيڅ خبرتيا نشته.';

  @override
  String forwardCouldNotLoadChats(Object error) {
    return 'خبرې اترې نه راوړل کيدل: $error';
  }

  @override
  String get forwardNoChats => 'هيڅ خبرې اترې نشته';

  @override
  String get commonTitle => 'سرليک';

  @override
  String get commonNotes => 'يادښتونه';

  @override
  String get commonEmail => 'ايميل';

  @override
  String get commonPassword => 'پټنوم';

  @override
  String get commonNumberOfPages => 'د پاڼو شمير';

  @override
  String get messagesSearchByNameOrGrade => 'د نوم يا ټولګي له مخې ولټوئ…';

  @override
  String get meetingStartDateRequired => 'د پيل نېټه *';

  @override
  String get meetingStartTimeRequired => 'د پيل وخت *';

  @override
  String get meetingEndDateOptional => 'د پای نېټه (اختياري)';

  @override
  String get meetingEndTimeOptional => 'د پای وخت (اختياري)';

  @override
  String get teacherMaterialLinkUrlOptional => 'لينک / URL (اختياري)';

  @override
  String get teacherSearchStudentsOrGrade => 'زده‌کوونکي يا ټولګی ولټوئ…';

  @override
  String get teacherSearchParentsOrChildren => 'والدين يا ماشومان ولټوئ…';

  @override
  String get studentAssignmentAddNoteOptional => 'يادښت ورزیات کړئ (اختياري)…';

  @override
  String get adminEditUserUsernameRequired => 'د کارن نوم *';

  @override
  String get reportReasonOptional => 'دليل (اختياري)';

  @override
  String get forwardSearchChatsAndClassrooms => 'خبرې اترې او ټولګيونه ولټوئ…';

  @override
  String get profileNewPhone => 'نوی ټيليفون';

  @override
  String get profileNewEmail => 'نوی ايميل';

  @override
  String adminExportPasswordsWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'فايل به د $count زده‌کوونکو د ننوتلو معلومات ولري، د اوسنيو پټنومونو په ګډون. هر څوک چې فايل ولري کولی شي د دغو زده‌کوونکو په توګه ننوځي — په پاملرنه يې شريک کړئ او بشپړيدو وروسته يې حذف کړئ. د هغو حسابونو کرښې چې د وروستي تازه کولو دمخه جوړ شوي وي، تر هغه وخته به تش پټنوم وښيي چې هر کاروونکی بيا ننوځي يا بياځلي تنظيم وکړي.',
      one:
          'فايل به د $count زده‌کوونکي د ننوتلو معلومات ولري، د اوسني پټنوم په ګډون. هر څوک چې فايل ولري کولی شي د دې زده‌کوونکي په توګه ننوځي — په پاملرنه يې شريک کړئ او بشپړيدو وروسته يې حذف کړئ. د هغو حسابونو کرښې چې د وروستي تازه کولو دمخه جوړ شوي وي، تر هغه وخته به تش پټنوم وښيي چې کاروونکی بيا ننوځي يا بياځلي تنظيم وکړي.',
    );
    return '$_temp0';
  }

  @override
  String get pickerSelectStudents => 'زده‌کوونکي وټاکئ';

  @override
  String get pickerSelectCohorts => 'ډلې وټاکئ';

  @override
  String get pickerSelectGrades => 'ټولګيونه وټاکئ';

  @override
  String get pickerSelectClassroom => 'ټولګی وټاکئ';

  @override
  String get pickerSelectClasses => 'ټولګيونه وټاکئ';

  @override
  String get drawerLoadingChildren => 'ماشومان راوړل کيږي…';

  @override
  String get drawerCouldNotLoadChildren => 'ماشومان نه راوړل کيدل';

  @override
  String get drawerNoChildrenLinked => 'هيڅ ماشوم نه دی تړل شوی';

  @override
  String get drawerSwitchChild => 'ماشوم بدل کړئ';

  @override
  String get shellAssessmentCreated => 'ارزونه جوړه شوه';

  @override
  String commonCouldNotOpenLink(String scheme) {
    return 'د $scheme لينک نه پرانيستل کيده';
  }

  @override
  String commonCouldntSend(String error) {
    return 'نه ولېږل شو: $error';
  }

  @override
  String get teacherExamDetailsSection => 'د ازموینې تفصيلات';

  @override
  String teacherExamStudyMaterialsWithCount(int count) {
    return 'د زده‌کړې مواد ($count)';
  }

  @override
  String get teacherMeetingDetailsSection => 'د غونډې تفصيلات';

  @override
  String get teacherClassroomNameSection => 'د ټولګي نوم';

  @override
  String get teacherAddByCohortSection => 'د ډلې له مخې ورزیات کړئ';

  @override
  String get teacherAddIndividualStudentsSection =>
      'انفرادي زده‌کوونکي ورزیات کړئ';

  @override
  String get teacherGradeTypeSection => 'د نمرې ډول';

  @override
  String get teacherOtherGradeSection => 'بله نمره';

  @override
  String get teacherEnterGradesSection => 'نمرې وليکئ';

  @override
  String teacherAttachmentsWithCount(int count) {
    return 'نښلونونه ($count)';
  }

  @override
  String get studentFilesSharedByTeacher =>
      'ستاسو د ښوونکي لخوا شريک شوي فايلونه';

  @override
  String get studentYourSubmission => 'ستاسو سپارل شوی';

  @override
  String get studentFilesSharedWithAnnouncement =>
      'د دې اعلان سره شريک شوي فايلونه.';

  @override
  String get announcementGradeRiskTitle => 'د نمرې خطر وموندل شو';

  @override
  String get announcementWeakSubjectTitle => 'کمزوری مضمون وموندل شو';

  @override
  String get announcementLowAttendanceTitle => 'ټيټه حاضري';

  @override
  String get announcementRepeatedLatenessTitle => 'تکراري ناوختي';

  @override
  String get announcementPracticeWeaknessTitle => 'د تمرين کمزوري وموندل شوه';

  @override
  String get announcementPracticeTrendDroppedTitle => 'د تمرين روند ښکته شو';

  @override
  String get announcementSolutionsActivityTitle => 'د حلونو فعاليت روان دی';

  @override
  String get announcementAllGoodTitle => 'هر څه سم دي';

  @override
  String get supportSectionGettingStarted => 'پيلول';

  @override
  String get supportSectionAccountPassword => 'حساب او پټنوم';

  @override
  String get supportSectionForStudents => 'د زده‌کوونکو لپاره';

  @override
  String get supportSectionForTeachers => 'د ښوونکو لپاره';

  @override
  String get supportSectionForAdministrators => 'د مدیرانو لپاره';

  @override
  String get supportSectionForParents => 'د موروپلار لپاره';

  @override
  String get supportSectionPrivacyData => 'محرمیت او معلومات';

  @override
  String get novaDisclaimerCanMakeMistakes => 'تېروتنه کولی شي';

  @override
  String get novaDisclaimerEducationalUseOnly => 'یوازې د زده‌کړې لپاره';

  @override
  String get novaDisclaimerYourPrivacy => 'ستاسو محرمیت';

  @override
  String profileNameInLanguage(String language) {
    return 'په $language کې نوم';
  }

  @override
  String get adminSettingsScheduleSubtitle =>
      'ښوونکي او ډلې اونیزو وختي خانو ته وټاکئ';

  @override
  String get practiceModeBalancedSubtitle => 'متوازنه ورځنۍ تمرین';

  @override
  String get practiceModeRevealSubtitle => 'ښکاره کول او ځان‌ازموینه';

  @override
  String get practiceModeFastSubtitle => 'ګړندۍ فشاري تمرین';

  @override
  String get practiceModeExamSubtitle => 'د ازموینې په څېر آرام بهیر';

  @override
  String get practiceModeConceptSubtitle => 'لومړی مفهوم، بیا حل';

  @override
  String get practiceModeAdaptiveSubtitle => 'ستونزمنتیا ژوندۍ بدلیږي';

  @override
  String get practiceModeStrictSubtitle => 'سخت رسمي طرز';

  @override
  String get commonCall => 'زنګ ووهئ';

  @override
  String get tooltipClearEndTime => 'د پای وخت پاک کړئ';

  @override
  String get tooltipDeletePeriod => 'ساعت ړنګ کړئ';

  @override
  String get tooltipLeaveClassroom => 'ټولګی پرېږدئ';

  @override
  String get announcementGradeRiskBody =>
      'ستاسو منځنۍ کچه له ۷۰ ښکته شوه. سمدستي اقدام سپارښتنه کیږي.';

  @override
  String announcementWeakSubjectBody(String subject) {
    return '$subject پاملرنې ته اړتیا لري.';
  }

  @override
  String get announcementLowAttendanceBody =>
      'ستاسو حاضري ښکته کیږي. دا به پر نمرو اغېز وکړي.';

  @override
  String get announcementLatenessBody => 'تاسو څو ځله ناوخته راغلي یاست.';

  @override
  String announcementPracticeWeakTopicBody(String topic, String subject) {
    return 'په $subject کې $topic ستاسو پرمختګ ورو کوي.';
  }

  @override
  String get announcementPracticeDropBody =>
      'ستاسو وروستۍ تمرین له معمول ښکته ده. ورو شئ او بیا یې جوړ کړئ.';

  @override
  String announcementSolutionsActivityBody(int page, int question) {
    return 'ستاسو د حلونو برخه په پاڼه $page، پوښتنه $question کې فعاله ده. د نورو کار وګورئ یا خپل اپلوډ کړئ.';
  }

  @override
  String get announcementAllGoodBody => 'اوس مهال هیڅ لوی تحصیلي خطر نه ښکاري.';

  @override
  String get faqStartedQ1 => 'څنګه ننوځم؟';

  @override
  String get faqStartedA1 =>
      'د هرکلي پر پاڼه \"ننوتل\" کېکاږئ او هغه بریښنالیک یا کارن‌نوم ولیکئ چې ستاسو د ښوونځي مدیر درکړی، له خپل لنډمهاله پټنوم سره. لومړی ځل به څخه وغوښتل شي چې نوی پټنوم وټاکئ.';

  @override
  String get faqStartedQ2 => 'ما لا د ننوتلو حساب نه لري.';

  @override
  String get faqStartedA2 =>
      'ستاسو د ښوونځي مدیر حسابونه جوړوي. له هغوی وغواړئ چې تاسو په خپله مدیریتي اپلیکیشن کې اضافه کړي، یا که ستاسو ښوونځی ځان‌نوملیکنه کاروي، د ګډون کوډ درسره شریک کړي.';

  @override
  String get faqStartedQ3 => 'ایا اپلیکیشن په خپله ژبه کارولی شم؟';

  @override
  String get faqStartedA3 =>
      'هو — ClassMate انګلیسي، عربي، عبري، فرانسوي او روسي ژبې ملاتړ کوي. د ژبې بدلولو لپاره تنظیمات پرانیزئ. تاسو کولی شئ په پروفایل کې د نوم لپاره غوره ژبه هم وټاکئ.';

  @override
  String get faqStartedQ4 => 'د تور او روښانه حالت ترمنځ څنګه بدلون راولم؟';

  @override
  String get faqStartedA4 =>
      'له مینو څخه تنظیمات پرانیزئ او د بڼې ګمارنه بدله کړئ. اپلیکیشن په ډیفالټ ډول ستاسو د سیسټم غوره‌توب درناوی کوي.';

  @override
  String get faqAccountQ1 => 'خپل پټنوم مې هیر کړ.';

  @override
  String get faqAccountA1 =>
      'د ننوتلو پر پاڼه \"پټنوم مو هیر دی؟\" کېکاږئ. تاسو به د بریښنالیک له لارې د بیا‌ټاکنې لینک یا د SMS له لارې کوډ ترلاسه کړئ. که دواړه لارې لا تاییدې نه وي، له خپل ښوونځي مدیر وغواړئ نوی لنډمهاله پټنوم درکړي.';

  @override
  String get faqAccountQ2 => 'خپل پټنوم څنګه بدلوم؟';

  @override
  String get faqAccountA2 =>
      'له مینو څخه پروفایل پرانیزئ، خوندیتوب ته ښکته شئ، او د پټنوم کرښه کېکاږئ. د نوي ټاکلو لپاره به مو اوسني پټنوم ته اړتیا وي.';

  @override
  String get faqAccountQ3 => 'خپل بریښنالیک یا د تلیفون شمیره څنګه بدلوم؟';

  @override
  String get faqAccountA3 =>
      'پروفایل پرانیزئ، هغه برخه کېکاږئ چې بدلول یې غواړئ، او د تاییدې لارښوونو پسې لاړ شئ. لومړی ستاسو اوسني بریښنالیک/تلیفون ته یو کوډ لیږل کیږي چې ډاډ ترلاسه شي ریښتیا تاسو یاست، بیا نوې ارزښت ټاکلی شئ.';

  @override
  String get faqAccountQ4 =>
      'زما د ښوونځي مدیر زما پټنوم بدلولی شي — دا څنګه کار کوي؟';

  @override
  String get faqAccountA4 =>
      'کله چې مدیر ستاسو پټنوم بیا‌ټاکي، تاسو به یو بریښنالیک او SMS ترلاسه کړئ چې په یوه کلیک سره خپل پټنوم وټاکئ. مدیر هیڅکله نه ویني چې تاسو څه ټاکلی.';

  @override
  String get faqStudentsQ1 => 'خپل مهالویش چیرته ګورم؟';

  @override
  String get faqStudentsA1 =>
      'مهالویش په مینو کې لومړی توکی دی. تاسو به د دې اونۍ ساعتونه، د هر یوه ښوونکی، او هر هغه بدلون چې مدیر یې اعلان کړی وګورئ.';

  @override
  String get faqStudentsQ2 => 'ټولګي ته څنګه ګډون کوم؟';

  @override
  String get faqStudentsA2 =>
      'ښوونکی به تاسو مستقیم اضافه کړي، یا به د ګډون کوډ شریک کړي. د ګډون کوډ کارولو لپاره، له مینو څخه ټولګي پرانیزئ او \"په کوډ سره ګډون\" کېکاږئ.';

  @override
  String get faqStudentsQ3 => 'حاضري او نمرې څنګه کار کوي؟';

  @override
  String get faqStudentsA3 =>
      'ښوونکي د درس پر مهال حاضري نښه کوي. خپل ریکارډونه لیدلو لپاره له مینو څخه حاضري یا نمرې پرانیزئ. هغه موروپلار چې ستاسو حساب سره تړل شوي همدا معلومات ویني.';

  @override
  String get faqStudentsQ4 => 'نوا څه دی؟';

  @override
  String get faqStudentsA4 =>
      'نوا ستاسو د زده‌کړې هوښیار ملګری دی — له هغه وغواړئ یو مفهوم تشریح کړي، آزموینه جوړه کړي، یا یوه ستونزه ګام په ګام حل کړي. د پیلولو لپاره له مینو څخه نوا پرانیزئ.';

  @override
  String get faqTeachersQ1 => 'ټولګی څنګه جوړوم؟';

  @override
  String get faqTeachersA1 =>
      'له مینو څخه ټولګي پرانیزئ او د + تڼۍ کېکاږئ. نوم او مضمون ورکړئ؛ زده‌کوونکي په لاس یا د ګډون کوډ له لارې اضافه کیدای شي.';

  @override
  String get faqTeachersQ2 => 'حاضري څنګه نښه کوم؟';

  @override
  String get faqTeachersA2 =>
      'له مینو څخه حاضري پرانیزئ، نېټه او ساعت وټاکئ، بیا هر زده‌کوونکی کېکاږئ ترڅو حالت یې وټاکئ. بدلونونه په اتومات ډول خوندي کیږي.';

  @override
  String get faqTeachersQ3 => 'کورنۍ دنده څنګه ورکوم؟';

  @override
  String get faqTeachersA3 =>
      'دندې پرانیزئ، + کېکاږئ، سرلیک/د سپارلو نېټه/ضمیمې ډک کړئ، او یو هدف وټاکئ (ټول ښوونځی، ځانګړې ډلې، یا نومول شوي زده‌کوونکي). زده‌کوونکي یې سمدستي په خپله مینو کې ګوري.';

  @override
  String get faqTeachersQ4 => 'ایا دیپلوم یا سند صادرولی شم؟';

  @override
  String get faqTeachersA4 =>
      'هو — له مینو څخه دیپلومونه پرانیزئ، + کېکاږئ، زده‌کوونکی وټاکئ، سرلیک او جزییات ډک کړئ، او خوندي کړئ. زده‌کوونکی یې په خپله د دیپلومونو برخه کې ویني.';

  @override
  String get faqAdminsQ1 => 'د ښوونځي د جوړولو لپاره له کومه پیل وکړم؟';

  @override
  String get faqAdminsA1 =>
      'د مدیریت ډشبورډ پرانیزئ. پورته د ښوونځي د جوړولو وجیټ یو ۷-ګامیز لیست ښیي (لوګو، نوم، مضامین، د زنګ مهالویش، ډلې، زده‌کوونکي، ښوونکي). هر ګام هغه ځای ته مستقیم لینک لري چیرته یې بشپړوئ.';

  @override
  String get faqAdminsQ2 => 'ډلې څنګه کار کوي؟';

  @override
  String get faqAdminsA2 =>
      'ډله د هغو زده‌کوونکو ګروپ دی چې یو مهالویش لري. د جوړولو، زده‌کوونکو ګمارلو، او د ګډون کوډونو جوړولو لپاره له مینو څخه ډلې پرانیزئ. یوه ډله کولی شي څو ټولګۍ ولري.';

  @override
  String get faqAdminsQ3 => 'ایا یوه ډله له یوه ټولګي زیاته رانغاړلی شي؟';

  @override
  String get faqAdminsA3 =>
      'هو — د ډلې د جوړولو پر مهال څو ټولګۍ وټاکئ. ډله بیا د هغو ټولګیو په هر فلټر او لید کې ښکاري، او هغه اعلانونه/کاپۍ چې هغو ټولګیو ته نښه شوي، دې ته رسیږي.';

  @override
  String get faqAdminsQ4 => 'اونیز مهالویش څنګه جوړوم؟';

  @override
  String get faqAdminsA4 =>
      'له مینو څخه مهالویش پرانیزئ. د ساعت اضافه کولو لپاره هره خانه کېکاږئ — ورځ/ساعت، ښوونکی، مضمون، او اوریدونکي (ډله/زده‌کوونکی/ټولګی) وټاکئ. د زنګ وختونه له ښوونځي تنظیماتو راځي.';

  @override
  String get faqAdminsQ5 => 'زده‌کوونکي په ډله‌ییز ډول څنګه صادروم؟';

  @override
  String get faqAdminsA5 =>
      'له مینو څخه د معلوماتو صادرول پرانیزئ. وټاکئ چې د زده‌کوونکي یا د ډلې له مخې غوره کوئ، کرښې وټاکئ، او صادرول کېکاږئ. د خوښې له مخې د صادرولو پر مهال اوسني پټنومونه شامل کړئ.';

  @override
  String get faqAdminsQ6 => 'یو کارن وغوښتل چې پټنوم یې بیا‌وټاکم. څه وکړم؟';

  @override
  String get faqAdminsA6 =>
      'تاسو کولی شئ یا یې پټنوم مستقیم وټاکئ (د کارن پروفایل ← خوندیتوب) یا انتظار وکړئ چې هغوی د \"پټنوم مو هیر دی\" له لارې غوښتنه وکړي او تاسو یې له مینو کې د پټنوم غوښتنو څخه ومنئ.';

  @override
  String get faqParentsQ1 => 'خپل حساب له خپل ماشوم سره څنګه وتړم؟';

  @override
  String get faqParentsA1 =>
      'د خپل ماشوم له ښوونځي مدیر وغواړئ چې یا له خپلې مدیریتي اپلیکیشن لینک اضافه کړي، یا د موروپلار یو ځل‌مهاله لینک کوډ شریک کړي. پروفایل پرانیزئ او د کورنۍ لاندې کوډ ولیکئ.';

  @override
  String get faqParentsQ2 => 'د خپل ماشوم په اړه څه لیدلی شم؟';

  @override
  String get faqParentsA2 =>
      'حاضري، نمرې، اعلانونه، او کورنۍ دندې — دقیقاً هغه څه چې ستاسو ماشوم یې ویني، له اوږدمهاله بهیرونو سره. تاسو شخصي چټونه یا د نوا ناستې نه ګورئ.';

  @override
  String get faqPrivacyQ1 => 'زما معلومات څوک لیدلی شي؟';

  @override
  String get faqPrivacyA1 =>
      'یوازې ستاسو په ښوونځي کې کسان. ښوونکي د خپلو ټولګیو معلومات ګوري، مدیران د ښوونځي ټول معلومات، موروپلار خپل تړل شوي ماشومان. موږ هیڅکله معلومات اعلان‌کوونکو ته نه پلوري.';

  @override
  String get faqPrivacyQ2 => 'خپل حساب څنګه ړنګوم؟';

  @override
  String get faqPrivacyA2 =>
      'له خپل ښوونځي مدیر وغواړئ چې یې ړنګ کړي. هغوی کولی شي حساب له خپلې مدیریتي اپلیکیشن لرې کړي، چې ستاسو پروفایل، مهالویش، او چټونه پاکوي.';

  @override
  String solutionsPagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پاڼې',
      one: '$count پاڼه',
    );
    return '$_temp0';
  }

  @override
  String get teacherMeetingEditTitle => 'غونډه سمول';

  @override
  String get teacherMeetingNewTitle => 'د غونډې مهالویش';

  @override
  String get teacherExamEditTitle => 'ازموینه سمول';

  @override
  String get teacherExamNewTitle => 'ازموینه جوړول';

  @override
  String get teacherAssignmentEditTitle => 'دنده سمول';

  @override
  String get teacherAssignmentNewTitle => 'نوې دنده';

  @override
  String get tooltipShowTabs => 'ټوبونه ښکاره کړئ';

  @override
  String get tooltipHideTabs => 'ټوبونه پټ کړئ';

  @override
  String get examsCouldNotLoadForms => 'فورمې بار نه شوې';

  @override
  String get examsCouldNotLoadExams => 'ازموینې بار نه شوې';

  @override
  String get messagesNoPeopleToAdd => 'د اضافه کولو لپاره څوک نشته';

  @override
  String commonNoResultsForQuery(String query) {
    return 'د \"$query\" لپاره هیڅ پایله نشته';
  }

  @override
  String chatForwardedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count چټونو ته واستول شو',
      one: 'یوه چټ ته واستول شو',
    );
    return '$_temp0';
  }

  @override
  String get commonReadMore => 'نور ولولئ';

  @override
  String get commonReadLess => 'لږ ولولئ';

  @override
  String get chatComposerSlideToCancel => 'د لغوه کولو لپاره وښویئ';

  @override
  String adminNoRoleYet(String role) {
    return 'لا هیڅ $role نشته';
  }

  @override
  String get profileVerified => 'تایید شو.';

  @override
  String get profileUpdatedPendingVerification =>
      'تازه شو او د بیا‌تاییدې په تمه دی.';

  @override
  String get adminSearchCohorts => 'ډلې ولټوئ…';

  @override
  String get commonAdding => 'اضافه کیږي…';

  @override
  String get teacherDiplomaIssuing => 'صادریږي…';

  @override
  String get teacherDiplomaIssue => 'صادرول';

  @override
  String get formAccepting => 'منل کیږي';

  @override
  String get profileVerifiedShort => 'تایید شوی';

  @override
  String get profileUnverified => 'نه‌تایید شوی';

  @override
  String get notificationNewGradePosted => 'نوې نمره خپره شوه';

  @override
  String notificationNewGradePostedIn(String subject) {
    return 'په $subject کې نوې نمره خپره شوه';
  }

  @override
  String messagesAddParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ګډونوال اضافه کړئ',
      one: 'یو ګډونوال اضافه کړئ',
    );
    return '$_temp0';
  }

  @override
  String get notificationFallbackTitle => 'خبرتیا';

  @override
  String adminCohortGradeRange(int from, int to) {
    return 'ټولګی $from-$to';
  }

  @override
  String adminCohortGradesList(String list) {
    return 'ټولګۍ $list';
  }

  @override
  String get adminExportHeaderTitle => 'کاروونکي صادرول';

  @override
  String get adminExportHeaderSubtitle =>
      'فلټرونه د نښو په توګه اضافه کړئ — هره نښه کاروونکي صادرولو ته اضافه کوي. د لرې کولو لپاره نښه کېکاږئ.';

  @override
  String get adminExportAddFilter => 'فلټر اضافه کړئ';

  @override
  String get adminExportEmptyState =>
      'د پیلولو لپاره فلټر اضافه کړئ: یوه دنده، ډله، ټولګی، یا ځانګړي کاروونکي وټاکئ.';

  @override
  String get adminExportFilterRolesTab => 'دندې';

  @override
  String get adminExportFilterCohortsTab => 'ډلې';

  @override
  String get adminExportFilterGradesTab => 'ټولګۍ';

  @override
  String get adminExportFilterUsersTab => 'کاروونکي';

  @override
  String get adminExportSelectAll => 'ټول وټاکئ';

  @override
  String adminExportSelectedCount(int selected, int total) {
    return 'له $total څخه $selected ټاکل شوي';
  }

  @override
  String adminExportRolePickedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ټاکل شوي',
      one: '$count ټاکل شوی',
    );
    return '$_temp0';
  }

  @override
  String get adminExportPillRolePrefix => 'دنده:';

  @override
  String get adminExportPillCohortPrefix => 'ډله:';

  @override
  String adminExportActiveFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فعال فلټرونه',
      one: '$count فعال فلټر',
    );
    return '$_temp0';
  }

  @override
  String get adminExportClearAll => 'ټول پاک کړئ';

  @override
  String get adminExportCounting => 'شمیرل کیږي…';

  @override
  String adminExportMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کاروونکي به صادر شي',
      one: '$count کاروونکی به صادر شي',
    );
    return '$_temp0';
  }

  @override
  String get adminExportNoGradesConfigured =>
      'د دې ښوونځي لپاره هیڅ ټولګی نه دی تنظیم شوی';

  @override
  String get adminExportColumnRole => 'دنده';

  @override
  String get adminExportRoleStudent => 'زده‌کوونکی';

  @override
  String get adminExportRoleTeacher => 'ښوونکی';

  @override
  String get adminExportRoleParent => 'والد';

  @override
  String get adminExportRoleSecretary => 'منشي';

  @override
  String get adminExportRoleAdmin => 'مدیر';

  @override
  String adminExportUsersSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کاروونکي ټاکل شوي',
      one: '$count کاروونکی ټاکل شوی',
    );
    return '$_temp0';
  }

  @override
  String get adminExportPasswordsOn =>
      'پټنومونه به په صادراتو کې ښکاره وي — فایل په خوندي ډول وساتئ.';

  @override
  String get adminExportPasswordsOff => 'صادرات به هیڅ پټنوم نه لري.';

  @override
  String get adminExportPdfUserDirectory => 'د کاروونکو لارښود';

  @override
  String adminExportPdfUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count کاروونکي',
      one: '$count کاروونکی',
    );
    return '$_temp0';
  }

  @override
  String get teacherAttachFromMaterials => 'له موادو څخه';

  @override
  String get teacherUploadFiles => 'فایلونه اپلوډ کړئ';

  @override
  String get solSubjectMathematics => 'ریاضي';

  @override
  String get solSubjectComputerScience => 'کمپیوټر علوم';

  @override
  String get solSubjectPhysics => 'فزیک';

  @override
  String get solSubjectChemistry => 'کیمیا';

  @override
  String get solSubjectHebrew => 'عبري';

  @override
  String get solSubjectBiology => 'بیولوژي';

  @override
  String get solSubjectHistory => 'تاریخ';

  @override
  String get solSubjectArabic => 'عربي';

  @override
  String get solSubjectElectronics => 'الکترونیک';

  @override
  String get solSubjectMechanics => 'میخانیک';

  @override
  String get solSubjectFrench => 'فرانسوي';

  @override
  String get solSubjectEnvironmentalScience => 'چاپیریالي علوم';

  @override
  String get solSubjectCommunicationCinema => 'اړیکې او سینما';

  @override
  String get solSubjectCitizenship => 'مدنیت';

  @override
  String get solSubjectSociology => 'ټولنپوهنه';

  @override
  String get solSubjectReligion => 'دین';

  @override
  String get solSubjectGeography => 'جغرافیه';

  @override
  String get solSubjectPsychology => 'ارواپوهنه';

  @override
  String get insightsSemesterTitle => 'دا سمسټر';

  @override
  String get insightsOnTimeSubmissions => 'په وخت کار';

  @override
  String get insightsSubmissionsTitle => 'سپارنې';

  @override
  String get insightsOnTime => 'په وخت';

  @override
  String get insightsLate => 'ناوخته';

  @override
  String get insightsMissing => 'ورک';

  @override
  String get insightsPending => 'په تمه';

  @override
  String get insightsHandedInLabel => 'سپارل شوي';

  @override
  String get insightsLatestGrades => 'وروستۍ نمرې';

  @override
  String get insightsReviewWithNova => 'له نوا سره کتنه';

  @override
  String get insightsReviewWithNovaPrompt =>
      'د دې سمسټر زما د کړنو لنډه او رښتیني کتنه راکړه — نمرې، حاضري، او سپارنې — او هغه یو شی چې باید بل ګام پرې تمرکز وکړم.';

  @override
  String get insightsPracticeTitle => 'د تمرین دقت';

  @override
  String get commonUnknown => 'نامعلوم';

  @override
  String get solutionsReportTitle => 'د دې حل راپور ورکړئ';

  @override
  String get solutionsReportBody =>
      'مدیرانو ته ووایاست چې څه ناسم دي. د دواړو ښوونځیو مدیران به یې وڅیړي.';

  @override
  String get solutionsReportReasonHint => 'دلیل (اختیاري)';

  @override
  String get solutionsReportAction => 'راپور';

  @override
  String get solutionsReportSubmitted => 'مننه — مدیرانو ته راپور شو.';

  @override
  String get solutionsReportAlready => 'تاسو دا مخکې راپور کړی.';

  @override
  String solutionsBookPagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count پاڼې',
      one: '۱ پاڼه',
    );
    return '$_temp0';
  }

  @override
  String get solutionsNoBooksYetForStudents =>
      'دلته لا هیڅ کتاب نشته. ستاسو ښوونکی به یې اضافه کړي.';

  @override
  String get solutionsManageBooksTitle => 'کتابونه اداره کول';

  @override
  String get solutionsNoBooksManageHint =>
      'د دې مضمون لپاره لا هیڅ کتاب نشته. د اضافه کولو لپاره + کېکاږئ.';

  @override
  String get solutionsDeleteBookTitle => 'کتاب ړنګ کړئ؟';

  @override
  String solutionsDeleteBookBody(String title) {
    return '\"$title\" ړنګ کړئ؟ دا بیرته نه راګرځي.';
  }

  @override
  String solutionsBookSaveFailed(String error) {
    return 'خوندي نه شو: $error';
  }

  @override
  String get solutionsBookDuplicateHint =>
      'د زياتولو دمخه، ډاد ترلاسه کړئ چې دا کتاب لا دمخه په ډيټابیس کې نشته.';

  @override
  String get solutionsBookDuplicateTitle => 'ممکن دوه ګونی کتاب';

  @override
  String solutionsBookDuplicateBody(String title) {
    return 'د \"$title\" په نوم کتاب لا دمخه شتون لري. د زياتولو دمخه ډاد ترلاسه کړئ چې هماغه کتاب نه دی.';
  }

  @override
  String get solutionsBookAddAnyway => 'بیا هم زيات کړئ';

  @override
  String get solutionsBookNeedTitlePages => 'سرلیک او د پاڼو شمیر ولیکئ.';

  @override
  String get solutionsEditBookTitle => 'کتاب سمول';

  @override
  String get solutionsBookCoverLabel => 'پوښ';

  @override
  String solutionsGradeLabel(int grade) {
    return 'ټولګی $grade';
  }

  @override
  String get solutionsReportsTitle => 'راپور شوي حلونه';

  @override
  String get solutionsReportsEmpty => 'د کتنې لپاره هیڅ راپور نشته.';

  @override
  String get solutionsReportPostedBy => 'خپروونکی';

  @override
  String get solutionsReportReportedBy => 'راپور‌کوونکی';

  @override
  String get solutionsReportReasonLabel => 'دلیل';

  @override
  String get solutionsReportKeepAction => 'وساتئ';

  @override
  String get solutionsReportRemoveAction => 'لرې کړئ';

  @override
  String get solutionsReportStatusPending => 'په تمه';

  @override
  String get solutionsReportStatusApproved => 'وساتل شو';

  @override
  String get solutionsReportStatusRemoved => 'لرې شو';

  @override
  String get solutionsReportRemoved => 'حل لرې شو.';

  @override
  String get solutionsReportApproved => 'راپور رد شو — حل وساتل شو.';

  @override
  String solutionsReportFailed(String error) {
    return 'راپور نه شو: $error';
  }

  @override
  String get teacherAddGradeTitle => 'نمره اضافه کول';

  @override
  String get commonCohort => 'ډله';

  @override
  String get teacherCreateNewExam => 'نوې ازموینه جوړه کړئ';

  @override
  String get teacherCreateNewAssignment => 'نوې دنده جوړه کړئ';

  @override
  String get commonReturn => 'بیرته';

  @override
  String get reorderToolsTitle => 'مینو بیا‌ترتیب کړئ';

  @override
  String get reorderToolsSubtitle =>
      'د خپلو ښوونځي وسایلو د بیا‌ترتیبولو لپاره وکاږئ. د اصلي او حساب برخې پر خپل ځای پاتې کیږي.';

  @override
  String get reorderToolsReset => 'بیا‌تنظیم';

  @override
  String get reorderToolsSettingsSection => 'مینو';

  @override
  String get reorderToolsSettingsSubtitle =>
      'په خپله څنګه مینو کې وسایل بیا‌ترتیب کړئ';

  @override
  String get adminSchoolGradeRangesDescription =>
      'وټاکئ چې ستاسو ښوونځی کوم ټولګۍ رانغاړي. که ځینې ټولګۍ پریښودل شوي، څو حدونه اضافه کړئ (لکه ۴-۶ او ۹-۱۲).';

  @override
  String get adminSchoolAddGradeRange => 'حد اضافه کړئ';

  @override
  String get teacherListStudents => 'زده‌کوونکي ولیکئ';

  @override
  String get teacherNoStudentsInvolved =>
      'په دې ساعت کې لا هیڅ زده‌کوونکی نشته.';

  @override
  String get messagesFilterAdmins => 'مدیران';

  @override
  String get teacherAssignmentGradedStatus => 'نمره ورکړل شوه';

  @override
  String get teacherAssignmentReturnedStatus => 'د بیا‌حل لپاره بیرته شو';

  @override
  String get teacherAssignmentReturnAction => 'د بیا‌حل لپاره بیرته کړئ';

  @override
  String teacherAssignmentReturnDialogBody(String name) {
    return 'دا سپارنه $name ته بیرته واستوئ ترڅو یې سمه او بیا یې وسپاري؟ هر هغه نظر چې تاسو لیکلی شامل به وي.';
  }

  @override
  String teacherGradesSavedOf(int saved, int total) {
    return 'له $total څخه $saved خوندي شول.';
  }

  @override
  String teacherGradesSkippedSuffix(int dropped) {
    return '$dropped زده‌کوونکي پریښودل شول — په کومه ډله کې نه دي.';
  }

  @override
  String get adminPeopleGradeLevelRequired =>
      'د دې زده‌کوونکي لپاره یو ټولګی وټاکئ.';

  @override
  String teacherAddGradeLabel(int grade) {
    return 'ټولګی $grade';
  }

  @override
  String get teacherGradeOutOfHint => 'لکه ۲۰';

  @override
  String get plansDowngrade => 'ښکته کول';

  @override
  String get plansDowngradeNote =>
      'ستاسو د اوسني پلان له پای سره پیلیږي — تر هغه یې ساتئ، بیرته‌ورکونه نشته.';

  @override
  String get semesterThis => 'دا سمسټر';

  @override
  String get semesterPrevious => 'تیر';

  @override
  String get showMore => 'نور ښکاره کړئ';

  @override
  String get adminSchoolSemestersLabel => 'سمسټرونه';

  @override
  String get adminSchoolSemestersDescription =>
      'د ښوونځي کال په میاشتو سمسټرونو وویشئ. نمرې، ازموینې، غونډې او نور په اتومات ډول د سمسټر له مخې ګروپ کیږي.';

  @override
  String adminSchoolSemesterN(String n) {
    return 'سمسټر $n';
  }

  @override
  String get adminSchoolAddSemester => 'سمسټر اضافه کړئ';

  @override
  String get semesterStarts => 'پیلیږي';

  @override
  String get semesterEnds => 'پای ته رسیږي';

  @override
  String get commonWhen => 'کله';

  @override
  String get commonFiles => 'فایلونه';

  @override
  String get commonOnce => 'یو ځل';

  @override
  String get commonNoneDash => '— هیڅ —';

  @override
  String get commonNotesOptional => 'یادښتونه (اختیاري)';

  @override
  String get commonSubjectOptional => 'مضمون (اختیاري)';

  @override
  String get colorBlue => 'آبي';

  @override
  String get colorIndigo => 'نیلي';

  @override
  String get colorViolet => 'بنفش';

  @override
  String get colorTeal => 'آبي‌شین';

  @override
  String get colorGreen => 'شین';

  @override
  String get colorOrange => 'نارنجي';

  @override
  String get colorRose => 'ګلابي';

  @override
  String get teacherAddClassNotes => 'د ټولګي یادښتونه اضافه کړئ';

  @override
  String get teacherStudentsWithGrades => 'د نمرو لرونکي زده‌کوونکي';

  @override
  String get teacherOtherStudentsSameGrade =>
      'په همدې ټولګي/ډله کې نور زده‌کوونکي';

  @override
  String get teacherChooseExam => 'ازموینه وټاکئ';

  @override
  String get teacherChooseAssignment => 'دنده وټاکئ';

  @override
  String get teacherSearchExams => 'ازموینې ولټوئ…';

  @override
  String get teacherSearchAssignments => 'دندې ولټوئ…';

  @override
  String get teacherSearchQuestionTypes => 'د پوښتنو ډولونه ولټوئ…';

  @override
  String get teacherOtherCustomSubject => 'نور (په لاس ولیکئ)';

  @override
  String get adminLinkChild => 'ماشوم وتړئ';

  @override
  String get adminChooseStudentDash => '— زده‌کوونکی وټاکئ —';

  @override
  String get adminSelectStudentToLink => 'د تړلو لپاره زده‌کوونکی وټاکئ';

  @override
  String get adminEditPeriod => 'ساعت سمول';

  @override
  String get adminNotInAnyCohort =>
      'لا په هیڅ ډله کې نه دی — د ډلو له پاڼې وټاکئ.';

  @override
  String get adminPasswordChangeWarning =>
      'کاروونکی به بل ځل چې ننوځي له دې پټنوم سره ننوځي. هر هغه د پټنوم بیا‌ټاکنې لینک چې په تمه دی باطل کیږي.';

  @override
  String get nameInEnglish => 'په انګلیسي کې نوم';

  @override
  String get nameInArabic => 'په عربي کې نوم';

  @override
  String get nameInHebrew => 'په عبري کې نوم';

  @override
  String get nameInFrench => 'په فرانسوي کې نوم';

  @override
  String get nameInRussian => 'په روسي کې نوم';

  @override
  String get passwordMinChars => 'لږ تر لږه ۸ توري.';

  @override
  String get passwordsDoNotMatch => 'پټنومونه سره برابر نه دي.';

  @override
  String get adminWelcomeHeading => 'ClassMate ته ښه راغلاست';

  @override
  String get diplomasNoFilesAttached => 'دې سند سره هیڅ فایل نښتی نه دی.';

  @override
  String get diplomasFilesProcessing =>
      'فایلونه پرانیستل نه شول — کیدای شي لا پروسس کیږي.';

  @override
  String get novaOutOfTokens =>
      'تاسو د دې دورې لپاره خپل ټول ټوکنونه کارولي. د NOVA سره د دوام لپاره خپل پلان لوړ کړئ یا بیا ډک کړئ.';

  @override
  String get tutorDeleteConversationWarning =>
      'دا به خبرې اترې او ټول پیغامونه یې د سرور څخه د تل لپاره ړنګ کړي. دا بیرته نه راګرځي.';

  @override
  String get chatReportFlagWarning =>
      'دا پیغام به د مدیر لخوا د کتنې لپاره نښه شي.';

  @override
  String get solutionPreviewFailFallback =>
      'که مخکتنه پاتې راشي، له چټ ضمیمې یې پرانیزئ';

  @override
  String get practiceNoInternet =>
      'د انټرنېټ اړیکه نشته. مهرباني وکړئ بیا هڅه وکړئ.';

  @override
  String get practiceGenerationFailed =>
      'پوښتنې جوړې نه شوې. مهرباني وکړئ بیا هڅه وکړئ.';

  @override
  String get practiceTimingSecPerQuestion => 'ثانیه / پوښتنه';

  @override
  String get practiceTimingMinPerQuiz => 'دقیقه / آزموینه';

  @override
  String adminScheduleFrequencyWeeks(Object freq) {
    return '×$freq اونۍ';
  }

  @override
  String gradeLevelLabel(Object grade) {
    return 'ټولګی $grade';
  }

  @override
  String adminPeriodOption(Object period) {
    return 'ساعت $period';
  }

  @override
  String cohortStudentsCount(Object count) {
    return '$count زده‌کوونکي';
  }

  @override
  String diplomasIssuedCount(Object count) {
    return '$count سندونه صادر شول';
  }

  @override
  String get adminExportImportantHeading => 'مهم';

  @override
  String get adminExportWelcomeBodyWithPw =>
      'دا ستاسو د ClassMate حساب جزییات دي. د iOS یا Android په ClassMate اپلیکیشن کې د لاندې کارن‌نوم او پټنوم په کارولو ننوځئ. تاسو کولی شئ خپل پټنوم په اپلیکیشن کې بدل کړئ.';

  @override
  String get adminExportWelcomeBodyNoPw =>
      'دا ستاسو د ClassMate حساب جزییات دي. د iOS یا Android په ClassMate اپلیکیشن کې د خپل کارن‌نوم په کارولو ننوځئ.';

  @override
  String get adminExportNotePrivate =>
      'دا اعتبارنامې محرمې وساتئ. خپل پټنوم له بل چا سره شریک مه کوئ.';

  @override
  String get adminExportNoteChangePw =>
      'د لومړي ننوتلو وروسته خپل پټنوم له تنظیمات ← حساب څخه بدل کړئ.';

  @override
  String get adminExportNoteLegal =>
      'د ClassMate په کارولو سره تاسو زموږ د خدمت شرایط او د محرمیت تګلاره منئ.';

  @override
  String adminExportNoteHelp(String email) {
    return 'مرستې ته اړتیا لرئ؟ له خپل ښوونځي مدیر یا $email سره اړیکه ونیسئ.';
  }

  @override
  String get teacherGradeTitleHint => 'لکه د ټولګي ګډون، آزموینه ۳';

  @override
  String get teacherClassroomNameHint => 'لکه ریاضي ۱۰A';

  @override
  String get novaAbout => 'د NOVA په اړه';

  @override
  String get parentNotifForYou => 'ستاسو لپاره';

  @override
  String parentNotifAbout(String name) {
    return 'د $name په اړه';
  }

  @override
  String get navPrivacyPolicy => 'د محرمیت تګلاره';

  @override
  String get privacyPolicySubtitle => 'موږ ستاسو معلومات څنګه ساتو';

  @override
  String get semesterAllPrevious => 'ټول تیر';

  @override
  String get semesterSelectTitle => 'سمسټر وټاکئ';

  @override
  String get adminImportUsersScreenTitle => 'کاروونکي واردول';

  @override
  String get adminImportUsersScreenTabGrid => 'جدول';

  @override
  String get adminImportUsersScreenTabCsv => 'CSV';

  @override
  String adminImportUsersScreenLoadedRows(int count) {
    return '$count کرښې بار شوې — وګورئ او سم کړئ، بیا جوړ کړئ';
  }

  @override
  String get adminImportUsersScreenFillAtLeastOneName =>
      'لږ تر لږه یو نوم ډک کړئ';

  @override
  String adminImportUsersScreenFailed(String error) {
    return 'ناکام شو: $error';
  }

  @override
  String get adminImportUsersScreenBackToGrid => 'جدول ته بیرته';

  @override
  String get adminImportUsersScreenGridIntro =>
      'هر کس لپاره یوه کرښه ډکه کړئ، یا له CSV ټوب څخه CSV بار کړئ او دلته یې سم کړئ. کارن‌نوم اختیاري دی — که خالي وي موږ یې جوړوو. د زده‌کوونکو لپاره، ټولګی او (اختیاري) د والد کارن‌نوم وټاکئ ترڅو ویې تړئ.';

  @override
  String get adminImportUsersScreenAddRow => 'کرښه اضافه کړئ';

  @override
  String adminImportUsersScreenCreateCount(int count) {
    return 'جوړ کړئ ($count)';
  }

  @override
  String get adminImportUsersScreenRole => 'دنده';

  @override
  String get adminImportUsersScreenFullName => 'بشپړ نوم *';

  @override
  String get adminImportUsersScreenUsername => 'کارن‌نوم';

  @override
  String get adminImportUsersScreenUsernameHint => '(که خالي وي اتومات)';

  @override
  String get adminImportUsersScreenGrade => 'ټولګی';

  @override
  String get adminImportUsersScreenParentUsername => 'د والد کارن‌نوم';

  @override
  String get adminImportUsersScreenParentUsernameHint => 'تړل (اختیاري)';

  @override
  String get adminImportUsersScreenCouldNotReadFile => 'هغه فایل لوستل نه شو.';

  @override
  String get adminImportUsersScreenCsvIntro =>
      'د خپلو کاروونکو CSV اپلوډ کړئ. د کالمونو سرلیکونه په هره ژبه کیدای شي — ClassMate پیژني چې هر کالم څه معنا لري، بیا کرښې جدول ته بار کوي ترڅو یې د جوړولو مخکې وګورئ او سم کړئ.';

  @override
  String get adminImportUsersScreenChooseCsv => 'د CSV فایل وټاکئ';

  @override
  String get adminImportUsersScreenChooseDifferentFile => 'بل فایل وټاکئ';

  @override
  String adminImportUsersScreenSelectedFile(String fileName) {
    return 'ټاکل شوی: $fileName';
  }

  @override
  String get adminImportUsersScreenRecognisedColumns => 'پیژندل شوي کالمونه';

  @override
  String get adminImportUsersScreenRecognisedColumnsBody =>
      'نوم · کارن‌نوم · پټنوم · بریښنالیک · تلیفون · دنده · ټولګی · والد (یو کارن‌نوم) · ماشومان (کارن‌نومونه)\n\nد دندې کلمې لکه \"student / طالب / תלמיד / élève / ученик\" ټولې سمې انطباق کیږي. ټولګی له \"Grade 10\"، \"الصف 10\"، \"כיתה 10\" څخه شمیره لولي. ورک کارن‌نومونه یا پټنومونه په اتومات ډول جوړیږي.';

  @override
  String adminImportUsersScreenDetectedRows(int count) {
    return 'وپیژندل شوې — $count کرښې';
  }

  @override
  String get adminImportUsersScreenNoColumnsDetected =>
      'هیڅ پیژندل شوي کالمونه ونه موندل شول — د خپلې سرلیک کرښه وګورئ.';

  @override
  String get adminImportUsersScreenTruncatedNotice =>
      'د کتنې لپاره لومړۍ ۲۰۰۰ کرښې ښودل کیږي.';

  @override
  String get adminImportUsersScreenReviewEditInGrid =>
      'په جدول کې وګورئ او سم کړئ';

  @override
  String get adminImportUsersScreenReviewEditHint =>
      'جدول ټوب له دې کرښو سره مخکې‌ډک پرانیزي ترڅو د جوړولو مخکې هره تیروتنه سمه کړئ.';

  @override
  String adminImportUsersScreenResultSummary(int count, int links) {
    return '✓ $count کاروونکي جوړ شول · $links تړنې';
  }

  @override
  String adminImportUsersScreenResultFailedSuffix(int failed) {
    return ' · $failed ناکام';
  }

  @override
  String get adminImportUsersScreenFailedRows => 'ناکامې کرښې';

  @override
  String adminImportUsersScreenFailedRow(String row, String reason) {
    return 'کرښه $row: $reason';
  }

  @override
  String get adminImportUsersScreenCredentialsTitle =>
      'اعتبارنامې (دا خپلو کاروونکو ته ورکړئ)';

  @override
  String get teacherCohortsScreenTitle => 'ډلې';

  @override
  String get teacherCohortsScreenNewCohort => 'نوې ډله';

  @override
  String get teacherCohortsScreenLoadError => 'ډلې بار نه شوې.';

  @override
  String get teacherCohortsScreenEmpty =>
      'لا هیڅ ډله نشته.\nد جوړولو لپاره \"نوې ډله\" کېکاږئ.';

  @override
  String get teacherCohortsScreenCohortNameLabel => 'د ډلې نوم';

  @override
  String get teacherCohortsScreenCohortNameHint => 'لکه ۱۰-۲';

  @override
  String get teacherCohortsScreenGradesLabel => 'ټولګی(ګان)';

  @override
  String get teacherCohortsScreenGradesHint => 'لکه ۱۰  یا  ۷،۸';

  @override
  String get teacherCohortsScreenCancel => 'لغوه';

  @override
  String get teacherCohortsScreenCreate => 'جوړول';

  @override
  String get teacherCohortsScreenEnterNameAndGrade =>
      'نوم او لږ تر لږه یو ټولګی دننه کړئ';

  @override
  String get teacherCohortsScreenCohortCreated => 'ډله جوړه شوه';

  @override
  String get teacherCohortsScreenFailed => 'ناکام شو';

  @override
  String teacherCohortsScreenStudentsCount(int count) {
    return '$count زده کوونکي';
  }

  @override
  String get teacherCohortsScreenRenameGrades => 'نوم بدلول / ټولګي';

  @override
  String get teacherCohortsScreenDeleteCohort => 'ډله ړنګول';

  @override
  String get teacherCohortsScreenAddStudents => 'زده کوونکي زیاتول';

  @override
  String get teacherCohortsScreenEditCohort => 'ډله سمول';

  @override
  String get teacherCohortsScreenSave => 'خوندي کول';

  @override
  String get teacherCohortsScreenSaved => 'خوندي شو';

  @override
  String teacherCohortsScreenDeleteConfirmTitle(String name) {
    return '«$name» ړنګ کړئ؟';
  }

  @override
  String get teacherCohortsScreenDeleteConfirmBody =>
      'ډله لرې کیږي او زده کوونکي ترې جلا کیږي. د زده کوونکو حسابونه نه ړنګیږي.';

  @override
  String get teacherCohortsScreenDelete => 'ړنګول';

  @override
  String get teacherCohortsScreenDeleted => 'ړنګ شو';

  @override
  String get teacherCohortsScreenLoadStudentsError => 'زده کوونکي بار نشول';

  @override
  String teacherCohortsScreenAddNStudents(int count) {
    return '$count زده کوونکي زیات کړئ';
  }

  @override
  String teacherCohortsScreenAddedNStudents(int count) {
    return '$count زده کوونکي زیات شول';
  }

  @override
  String get teacherCohortsScreenNoStudentsYet =>
      'تر اوسه هیڅ زده کوونکی نشته.';

  @override
  String get adminSettingsScreenBulkTools => 'ډله ییز وسایل';

  @override
  String get adminSettingsScreenImportUsers => 'کاروونکي واردول';

  @override
  String get adminSettingsScreenImportUsersSubtitle =>
      'په یوځل ډیر زیات کړئ — جدول یا CSV';

  @override
  String get adminSettingsScreenUpgradeGrades => 'ټولګي لوړول';

  @override
  String get adminSettingsScreenUpgradeGradesSubtitle =>
      'هر زده کوونکی یو ټولګی پورته کړئ';

  @override
  String get adminSettingsScreenUpgradeGradesTitle => 'ټول ټولګي لوړ کړئ؟';

  @override
  String get adminSettingsScreenUpgradeGradesBody =>
      'هر زده کوونکی یو ټولګی پورته ځي. هغه زده کوونکي چې دمخه په لوړ ټولګي کې دي د فارغانو په توګه ساتل کیږي (هیڅکله نه ړنګیږي) ترڅو تاسو یې اداره کړئ. دا د ښوونځي د کال په پیل کې یوځل پرځای کول خوندي دي.';

  @override
  String get adminSettingsScreenUpgradeConfirm => 'لوړول';

  @override
  String adminSettingsScreenUpgradeSuccess(int promoted, int graduating) {
    return '$promoted زده کوونکي پورته شول · $graduating فارغیږي';
  }

  @override
  String get adminSettingsScreenDangerZone => 'د خطر سیمه';

  @override
  String get adminSettingsScreenResetSchedule => 'مهالویش بیا تنظیمول';

  @override
  String get adminSettingsScreenResetScheduleSubtitle =>
      'ټول دورې او بدلونونه ړنګ کړئ';

  @override
  String get adminSettingsScreenResetScheduleTitle =>
      'ټول مهالویش بیا تنظیم کړئ؟';

  @override
  String get adminSettingsScreenResetScheduleBody =>
      'دا د ستاسو د ښوونځي هره دوره او یوځلي بدلون په تل پاتې توګه ړنګوي. د زنګ مهالویش وختونه ساتل کیږي. دا بیرته نشي اوښتلی.';

  @override
  String adminSettingsScreenResetScheduleSuccess(int slots) {
    return 'مهالویش پاک شو — $slots دورې لرې شوې';
  }

  @override
  String get adminSettingsScreenResetCohorts => 'ډلې بیا تنظیمول';

  @override
  String get adminSettingsScreenResetCohortsSubtitle =>
      'ستاسو ټولې ډلې ړنګ کړئ';

  @override
  String get adminSettingsScreenResetCohortsTitle => 'ټولې ډلې ړنګ کړئ؟';

  @override
  String get adminSettingsScreenResetCohortsBody =>
      'دا ستاسو د ښوونځي هره ډله په تل پاتې توګه ړنګوي او زده کوونکي ترې لرې کوي. د زده کوونکو حسابونه نه ړنګیږي. دا بیرته نشي اوښتلی.';

  @override
  String get adminSettingsScreenDeleteCohortsConfirm => 'ډلې ړنګول';

  @override
  String adminSettingsScreenResetCohortsSuccess(int deleted) {
    return '$deleted ډلې ړنګې شوې';
  }

  @override
  String get adminSettingsScreenAppearanceSubtitle => 'بڼه، رنګونه، ژبه';

  @override
  String get adminSettingsScreenCancel => 'لغوه';

  @override
  String get adminSettingsScreenWorking => 'کار روان دی…';

  @override
  String adminSettingsScreenFailed(String error) {
    return 'ناکام شو: $error';
  }

  @override
  String adminSchedulePickStartDate(int freq) {
    return 'د هرو $freq اونیو مهالویش لپاره د پیل نیټه وټاکئ.';
  }

  @override
  String get adminScheduleNoCohortsYet =>
      'تر اوسه هیڅ ډله نشته — لومړی یوه جوړه کړئ.';

  @override
  String adminScheduleGradeWithCohort(String grade, String cohort) {
    return 'ټولګی $grade · $cohort';
  }

  @override
  String get adminScheduleDateOnLabel => 'په';

  @override
  String get adminScheduleDateStartsOnLabel => 'پیلیږي په';

  @override
  String adminScheduleStudentCount(int count) {
    return '$count زده کوونکي';
  }

  @override
  String get adminScheduleAudienceNone => '—';

  @override
  String adminScheduleTeacherClashNamed(String name) {
    return '$name به په یوه وخت کې دوه ټولګۍ ولري.';
  }

  @override
  String get adminScheduleTeacherClash =>
      'دا ښوونکی به په یوه وخت کې دوه ټولګۍ ولري.';

  @override
  String adminScheduleStudentClashSingle(String name) {
    return '$name به په یوه وخت کې دوه دورې ولري:';
  }

  @override
  String adminScheduleStudentClashMany(int count) {
    return '$count زده کوونکي به په یوه وخت کې دوه دورې ولري:';
  }

  @override
  String get adminScheduleAStudent => 'یو زده کوونکی';

  @override
  String adminScheduleAffected(String preview) {
    return 'اغیزمن: $preview';
  }

  @override
  String get adminScheduleResolvePrompt => 'دا باید څنګه حل شي؟';

  @override
  String get adminScheduleResolvePromptStudents =>
      'دا د هغو زده کوونکو لپاره باید څنګه حل شي؟';

  @override
  String adminScheduleStudentsInCohorts(int count, int cohortCount) {
    return 'په ټاکل شویو ډلو کې $count زده کوونکي';
  }

  @override
  String adminScheduleStudentsInGrade(int count, String grade) {
    return 'په ټولګي $grade کې $count زده کوونکي';
  }

  @override
  String get adminScheduleCustomizedNote =>
      'دودیز شوی — د جلا زده کوونکو په توګه خوندي شو';

  @override
  String adminScheduleMoreCount(int count) {
    return '+$count نور';
  }

  @override
  String get adminScheduleAddStudentsTitle => 'زده کوونکي زیاتول';

  @override
  String get adminScheduleNoStudentsMatch => 'هیڅ زده کوونکی سمون نه خوري.';

  @override
  String get adminScheduleNoPeriodsHere => 'دلته تر اوسه هیڅ دوره نشته.';

  @override
  String adminScheduleGradeRange(String from, String to) {
    return 'ټولګی $from-$to';
  }

  @override
  String adminScheduleGradesList(String grades) {
    return 'ټولګي $grades';
  }

  @override
  String get adminScheduleNoStudentsInCohorts =>
      'په دې ډلو کې تر اوسه هیڅ زده کوونکی نشته.';

  @override
  String adminScheduleEveryNWeeks(int freq) {
    return 'هرې $freq اونۍ';
  }

  @override
  String get adminScheduleColorLabel => 'رنګ';

  @override
  String get adminScheduleSubjectRequired => 'مضمون *';

  @override
  String get adminScheduleNoSchoolSubjects =>
      'تر اوسه د ښوونځي مضمونونه نشته. د یوه تعریفولو لپاره «نوی زیاتول» کلیک کړئ.';

  @override
  String get adminScheduleNoSubjectsMatch =>
      'ستاسو د لټون سره هیڅ مضمون سمون نه خوري.';

  @override
  String get teacherNewAnnouncementScreenBroadcastBody =>
      'هیڅ ځانګړې لیدونکي نه دي ټاکل شوي. دا اعلان به د ښوونځي هر زده کوونکي، مور و پلار، ښوونکي، منشي او اداره چي ته ښکاره وي.';

  @override
  String teacherNewAnnouncementScreenGradeLabel(int grade) {
    return 'ټولګی $grade';
  }

  @override
  String get teacherNewAnnouncementScreenNoFilesAttached =>
      'هیڅ فایل نه دی نښلول شوی.';

  @override
  String teacherNewAnnouncementScreenSelectedCount(int count) {
    return '$count ټاکل شوي';
  }

  @override
  String get teacherNewAnnouncementScreenAudienceHint =>
      'یوه کټګوري وټاکئ، بیا ځانګړي رولونه، ټولګي، ډلې یا کسان. د هرې کټګورۍ ټاکنې سره یوځای کیږي.';

  @override
  String get teacherNewAnnouncementScreenLoadingStudents =>
      'زده کوونکي بار کیږي…';

  @override
  String get teacherNewAnnouncementScreenNoGradeLevels =>
      'تر اوسه هیڅ ټولګی نه دی موندل شوی.';

  @override
  String get teacherNewAnnouncementScreenTapSelectCohorts =>
      'د ډلو ټاکلو لپاره کلیک کړئ…';

  @override
  String teacherNewAnnouncementScreenCohortsSelected(int count) {
    return '$count ډلې ټاکل شوې';
  }

  @override
  String get teacherNewAnnouncementScreenTapSelectStudents =>
      'د زده کوونکو ټاکلو لپاره کلیک کړئ…';

  @override
  String teacherNewAnnouncementScreenStudentsSelected(int count) {
    return '$count زده کوونکي ټاکل شوي';
  }

  @override
  String get teacherNewAnnouncementScreenTapSelectParents =>
      'د مور و پلار ټاکلو لپاره کلیک کړئ…';

  @override
  String teacherNewAnnouncementScreenParentsSelected(int count) {
    return '$count مور و پلار ټاکل شوي';
  }

  @override
  String get teacherNewAnnouncementScreenSelectedAudience => 'ټاکل شوي لیدونکي';

  @override
  String teacherNewAnnouncementScreenStudentsInCohorts(int count) {
    return 'په ټاکل شویو ډلو کې $count زده کوونکي';
  }

  @override
  String get teacherNewAnnouncementScreenSelectParents => 'مور و پلار ټاکل';

  @override
  String teacherNewAnnouncementScreenChildrenSummary(
    int count,
    String summary,
  ) {
    return '$count ماشومان — $summary';
  }

  @override
  String get teacherNewAnnouncementScreenNoLinkedChildren =>
      'هیڅ نښلول شوی ماشوم نشته';

  @override
  String adminPeriodsScreenDayN(int dow) {
    return 'ورځ $dow';
  }

  @override
  String adminPeriodsScreenPeriodN(int period) {
    return 'دوره $period';
  }

  @override
  String get adminPeriodsScreenPeriodDropdownLabel => 'دوره';

  @override
  String get adminPeriodsScreenSelectTeacher => 'ښوونکی وټاکئ…';

  @override
  String get adminPeriodsScreenNone => '— هیڅ —';

  @override
  String get adminPeriodsScreenLinkClassroom => 'له ټولګي سره نښلول…';

  @override
  String adminPeriodsScreenCohortGradeName(String grade, String name) {
    return 'ټ$grade — $name';
  }

  @override
  String adminPeriodsScreenGradeN(String grade) {
    return 'ټولګی $grade';
  }

  @override
  String get roleBadgeStudent => 'زده کوونکی';

  @override
  String get roleBadgeTeacher => 'ښوونکی';

  @override
  String get roleBadgeAdmin => 'اداره چي';

  @override
  String get roleBadgeSecretary => 'منشي';

  @override
  String get roleBadgeParent => 'مور و پلار';

  @override
  String get roleBadgeMember => 'غړی';

  @override
  String get teacherSlotAttachmentsScreenEmptyTitle => 'تر اوسه هیڅ ضمیمه نشته';

  @override
  String get teacherSlotAttachmentsScreenEmptyBody =>
      'توکي ضمیمه کړئ ترڅو ستاسو زده کوونکي یې د دې دورې په کارت کې وګوري.';

  @override
  String get teacherSlotAttachmentsScreenMaterialFallback => 'توکی';

  @override
  String get teacherSlotAttachmentsScreenSheetTitle => 'توکی ضمیمه کول';

  @override
  String get teacherSlotAttachmentsScreenCreateNew => 'نوی توکی جوړول';

  @override
  String get teacherAddGradeScreenPickAudience =>
      'لږ تر لږه یو زده کوونکی، ډله یا ټولګی وټاکئ.';

  @override
  String get teacherAddGradeScreenEnterTitle =>
      'د دې نمرې لپاره یو سرلیک دننه کړئ.';

  @override
  String get teacherAddGradeScreenPickExam => 'یوه ازموینه وټاکئ.';

  @override
  String get teacherAddGradeScreenPickAssignment => 'یو دنده وټاکئ.';

  @override
  String get teacherAddGradeScreenCouldNotResolveTitle =>
      'د نمرې سرلیک نشو ټاکلی.';

  @override
  String teacherAddGradeScreenEnterNumericGrade(String name) {
    return 'د $name لپاره عددي نمره دننه کړئ.';
  }

  @override
  String teacherAddGradeScreenError(String error) {
    return 'تېروتنه: $error';
  }

  @override
  String get teacherAddGradeScreenTapSelectStudents =>
      'د زده کوونکو ټاکلو لپاره کلیک کړئ…';

  @override
  String teacherAddGradeScreenStudentsSelected(int count) {
    return '$count زده کوونکي ټاکل شوي';
  }

  @override
  String get teacherAddGradeScreenTapSelectCohorts =>
      'د ډلو ټاکلو لپاره کلیک کړئ…';

  @override
  String teacherAddGradeScreenCohortsSelected(int count) {
    return '$count ډلې ټاکل شوې';
  }

  @override
  String teacherAddGradeScreenWillBeGraded(int count) {
    return '$count زده کوونکو ته به نمره ورکړل شي';
  }

  @override
  String get teacherAddGradeScreenNoGradeLevels =>
      'تر اوسه ستاسو په زده کوونکو هیڅ ټولګی نه دی موندل شوی.';

  @override
  String get teacherAddGradeScreenSelectAudienceExams =>
      'د ازموینو فلټرولو لپاره لومړی لیدونکي وټاکئ.';

  @override
  String teacherAddGradeScreenNoExamsReach(String audience) {
    return 'هیڅ ازموینه ټولو ټاکل شویو $audience ته نه رسیږي.';
  }

  @override
  String get teacherAddGradeScreenSelectAudienceAssignments =>
      'د دندو فلټرولو لپاره لومړی لیدونکي وټاکئ.';

  @override
  String teacherAddGradeScreenNoAssignmentsReach(String audience) {
    return 'هیڅ دنده ټولو ټاکل شویو $audience ته نه رسیږي.';
  }

  @override
  String get teacherAddGradeScreenSelectAudienceAbove =>
      'د نمرو دننه کولو لپاره پورته یو لیدونکي وټاکئ.';

  @override
  String get teacherAddGradeScreenSelectStudentsTitle => 'زده کوونکي ټاکل';

  @override
  String teacherAddGradeScreenCountSelected(int count) {
    return '$count ټاکل شوي';
  }

  @override
  String get teacherAddGradeScreenSelectCohortsTitle => 'ډلې ټاکل';

  @override
  String get teacherAddGradeScreenAudienceCohorts => 'ډلې';

  @override
  String get teacherAddGradeScreenAudienceGrades => 'ټولګي';

  @override
  String get teacherAddGradeScreenAudienceStudents => 'زده کوونکي';

  @override
  String get formDetailScreenCouldNotLoad => 'دا فورمه اوس مهال نشي بار کیدای.';

  @override
  String get formDetailScreenSubmitted => 'فورمه وسپارل شوه';

  @override
  String get formDetailScreenSubmissionFailed => 'سپارل ناکام شو';

  @override
  String get formDetailScreenAlreadySubmittedNote =>
      'تاسو دا فورمه دمخه سپارلې ده.';

  @override
  String get formDetailScreenSubmitting => 'سپارل کیږي…';

  @override
  String get formDetailScreenSubmitAgain => 'بیا سپارل';

  @override
  String get formDetailScreenSubmitForm => 'فورمه سپارل';

  @override
  String formDetailScreenQuestionCount(int count) {
    return '$count پوښتنې';
  }

  @override
  String get formDetailScreenMultiSubmit => 'څو ځله سپارل';

  @override
  String get formDetailScreenOnePerStudent => 'هر زده کوونکي ته ۱';

  @override
  String get formDetailScreenRequired => 'اړین';

  @override
  String get formDetailScreenYourAnswer => 'ستاسو ځواب';

  @override
  String get formDetailScreenLongAnswerText => 'اوږد ځواب متن';

  @override
  String get formDetailScreenSelect => 'وټاکئ';

  @override
  String get novaChatScreenAboutAiPoweredTitle => 'په AI ولاړ مرستندوی';

  @override
  String get novaChatScreenAboutAiPoweredBody =>
      'NOVA د لوی ژبني ماډل پر تخنیک جوړ دی ترڅو تاسو سره په زده کړه، د مفهومونو په پوهیدلو او د نظرونو په کشف کې مرسته وکړي.';

  @override
  String get novaChatScreenAboutMistakesBody =>
      'NOVA ممکن ناسم، نیمګړي یا زاړه معلومات تولید کړي. مهم ځوابونه تل د خپل ښوونکي یا د باور وړ سرچینې سره تایید کړئ.';

  @override
  String get novaChatScreenAboutEducationalBody =>
      'NOVA د زده کړې مرستې لپاره ډیزاین شوی او د مسلکي طبي، حقوقي یا مالي مشورې بدیل نه دی.';

  @override
  String get novaChatScreenAboutPrivacyBody =>
      'خبرې اترې د ځوابونو د تولید لپاره کارول کیږي. حساس شخصي معلومات مه شریکوئ.';

  @override
  String get novaChatScreenDisclaimerTapToLearn =>
      'NOVA کولی شي تېروتنې وکړي. د نورو زده کړې لپاره کلیک کړئ.';

  @override
  String get userProfileSheetSchool => 'ښوونځی';

  @override
  String get userProfileSheetClass => 'ټولګی';

  @override
  String get userProfileSheetParents => 'مور و پلار';

  @override
  String get userProfileSheetChildren => 'ماشومان';

  @override
  String get scheduleScreenNotes => 'یادښتونه';

  @override
  String get scheduleScreenMaterialFallback => 'توکی';

  @override
  String get scheduleScreenNow => 'اوس';

  @override
  String scheduleScreenMaterialCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count توکي',
      one: '۱ توکی',
    );
    return '$_temp0';
  }

  @override
  String teacherFormResponsesScreenResponseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ونه',
      one: '',
    );
    return '$count ځواب$_temp0';
  }

  @override
  String get teacherFormResponsesScreenEmptyTitle => 'تر اوسه هیڅ ځواب نشته';

  @override
  String get teacherFormResponsesScreenEmptySubtitle =>
      'کله چې زده کوونکي وسپاري، ځوابونه به دلته ښکاره شي.';

  @override
  String get teacherFormResponsesScreenStudentFallback => 'زده کوونکی';

  @override
  String teacherFormResponsesScreenSubmittedAt(String date) {
    return 'وسپارل شو $date';
  }

  @override
  String teacherCreateFormScreenQuestionNumber(String number) {
    return 'پ$number';
  }

  @override
  String get teacherCreateFormScreenShortAnswerPreview => 'لنډ ځواب';

  @override
  String get teacherCreateFormScreenLongAnswerPreview => 'اوږد ځواب';

  @override
  String get teacherCreateFormScreenDatePickerPreview => 'د نیټې ټاکونکی';

  @override
  String get teacherCreateFormScreenScaleTo => 'تر';

  @override
  String get teacherMeetingsScreenNoneOption => 'هیڅ';

  @override
  String teacherMeetingsScreenGradeLabel(String grade) {
    return 'ټولګی $grade';
  }

  @override
  String teacherMeetingsScreenStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ي',
      one: 'ی',
    );
    return '$count زده کوونک$_temp0';
  }

  @override
  String get teacherMeetingsScreenPickStartTime => 'د پیل وخت وټاکئ';

  @override
  String get teacherMeetingsScreenPickEndTime => 'د پای وخت وټاکئ';

  @override
  String teacherMeetingsScreenMembersWillReceive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ي',
      one: 'ی',
    );
    return '$count غړ$_temp0 به دا ترلاسه کړي';
  }

  @override
  String get teacherAssignmentsScreenTitle => 'دندې';

  @override
  String teacherAssignmentsScreenSummary(int total, int published) {
    return '$total ټول · $published خپاره شوي';
  }

  @override
  String get teacherAssignmentsScreenEmpty =>
      'تر اوسه هیڅ دنده نشته.\nد جوړولو لپاره + کلیک کړئ.';

  @override
  String teacherAssignmentsScreenSubmitted(int count) {
    return '$count وسپارل شول';
  }

  @override
  String get audienceSectionCohorts => 'ډلې';

  @override
  String get audienceSectionGrades => 'ټولګي';

  @override
  String audienceSectionGradeLabel(int grade) {
    return 'ټولګی $grade';
  }

  @override
  String get audienceSectionStudents => 'زده کوونکي';

  @override
  String audienceSectionStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ي',
      one: 'ی',
    );
    return '$count زده کوونک$_temp0';
  }

  @override
  String audienceSectionMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ي',
      one: 'ی',
    );
    return '$count غړ$_temp0 به دا ترلاسه کړي';
  }

  @override
  String audienceSectionSelectedCount(int count) {
    return '$count ټاکل شوي';
  }

  @override
  String secretaryStudentsScreenStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ي',
      one: 'ی',
    );
    return '$count زده کوونک$_temp0';
  }

  @override
  String secretaryStudentsScreenAvg(String grade) {
    return 'منځنۍ $grade';
  }

  @override
  String get secretaryStudentsScreenIdentity => 'هویت';

  @override
  String get secretaryStudentsScreenUsername => 'د کاروونکي نوم';

  @override
  String get secretaryStudentsScreenEmail => 'بریښنالیک';

  @override
  String get secretaryStudentsScreenPhone => 'تلیفون';

  @override
  String get secretaryStudentsScreenCohort => 'ډله';

  @override
  String get secretaryStudentsScreenGrade => 'ټولګی';

  @override
  String get secretaryStudentsScreenPrimaryCohort => 'اصلي ډله';

  @override
  String secretaryStudentsScreenTeacher(String name) {
    return 'ښوونکی: $name';
  }

  @override
  String get chatMessageBubbleEdited => 'سم شو';

  @override
  String get chatMessageBubbleForwarded => 'لیږل شوی';

  @override
  String get chatMessageBubblePinned => 'پن شوی';

  @override
  String get chatMessageBubbleReply => 'ځواب';

  @override
  String get chatMessageBubbleMessage => 'پیغام';

  @override
  String get chatMessageBubbleDeletedMessage => 'دا پیغام ړنګ شو';

  @override
  String get chatMessageBubbleImage => 'انځور';

  @override
  String get chatMessageBubbleVideo => 'ویډیو';

  @override
  String get chatMessageBubbleFile => 'فایل';

  @override
  String get chatMessageInfoPageReadSection => 'لوستل شوی';

  @override
  String get chatMessageInfoPageNoOneRead => 'تر اوسه چا دا نه دی لوستلی';

  @override
  String get chatMessageInfoPageDeliveredSection => 'رسول شوی';

  @override
  String get chatMessageInfoPagePendingSection => 'په تمه';

  @override
  String get chatMessageInfoPageUnknown => 'نامعلوم';

  @override
  String get profileEnterCodeTitle => '۶ رقمي کوډ دننه کړئ';

  @override
  String profileCodeSentTo(String target) {
    return '$target ته ولیږل شو. په ۱۵ دقیقو کې پای ته رسیږي.';
  }

  @override
  String get profileCodeSent => 'کوډ ولیږل شو. په ۱۵ دقیقو کې پای ته رسیږي.';

  @override
  String profileChangeContact(String label) {
    return '$label بدلول';
  }

  @override
  String get profileVerifyNewContactInfo =>
      'یو تایید کوډ به هغه ارزښت ته ولیږل شي چې تاسو یې دننه کوئ — ترڅو ثابته شي چې ستاسو دی.';

  @override
  String profileVerifyCurrentContactInfo(String label) {
    return 'یو تایید کوډ به ستاسو اوسني $label ته ولیږل شي ترڅو د بدلولو دمخه ثابته کړئ چې ستاسو دی.';
  }

  @override
  String get appShellReports => 'راپورونه';

  @override
  String get appShellExportData => 'د معلوماتو صادرول';

  @override
  String get appShellAdmin => 'اداره';

  @override
  String get appShellViewingAs => 'د دې په توګه کتل ';

  @override
  String get appShellSwitchChild => 'ماشوم بدلول';

  @override
  String get messageThreadScreenGroupInviteSubtitle =>
      'تاسو دې ګروپ ته د ګډون بلنه درکړل شوې.';

  @override
  String get messageThreadScreenBlockedHint =>
      'تاسو دا چټ بند کړی. د بیا چټ لپاره یې د بند شویو کسانو له لیست څخه خلاص کړئ.';

  @override
  String get messageThreadScreenCannotSendHint =>
      'تاسو اوس مهال په دې چټ کې پیغامونه نشئ لیږلی.';

  @override
  String get messageThreadScreenTapForGroupInfo =>
      'د ګروپ معلوماتو لپاره کلیک کړئ';

  @override
  String get messageThreadScreenAddParticipantsTitle => 'ګډون کوونکي زیاتول';

  @override
  String teacherExamsScreenGradedCount(int count) {
    return '$count نمره ورکړل شوي';
  }

  @override
  String get teacherScheduleScreenNextUp => 'راتلونکی';

  @override
  String teacherScheduleScreenPeriodLabel(String period) {
    return 'دوره $period';
  }

  @override
  String teacherScheduleScreenGradeLabel(int grade) {
    return 'ټولګی $grade';
  }

  @override
  String teacherScheduleScreenMaterialsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count توکي',
      one: '۱ توکی',
    );
    return '$_temp0';
  }

  @override
  String get teacherClassroomAddAssignmentScreenTitle => 'دنده زیاتول';

  @override
  String get teacherClassroomAddAssignmentScreenDetails => 'د دندې جزئیات';

  @override
  String get teacherClassroomAddAssignmentScreenDueDateOptional =>
      'د سپارلو نیټه (اختیاري)';

  @override
  String get teacherClassroomAddAssignmentScreenNotifyStudents =>
      'زده کوونکو ته خبر ورکول';

  @override
  String get teacherClassroomAddAssignmentScreenUploading => 'پورته کیږي…';

  @override
  String get teacherClassroomAddAssignmentScreenAttachFiles => 'فایلونه نښلول';

  @override
  String get teacherClassroomAddAssignmentScreenAddMoreFiles =>
      'نور فایلونه زیاتول';

  @override
  String get diplomasScreenCertificate => 'سند';

  @override
  String diplomasScreenIssuedDate(String date) {
    return 'صادر شو $date';
  }

  @override
  String get diplomasScreenNoCertificatesReceived =>
      'تر اوسه هیڅ سند نه دی ترلاسه شوی.';

  @override
  String diplomasScreenFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فایلونه',
      one: '$count فایل',
    );
    return '$_temp0';
  }

  @override
  String get gradesScreenOutOf100 => '/ ۱۰۰';

  @override
  String gradesScreenShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ې نمرې',
      one: 'ه نمره',
    );
    return '$count نور$_temp0 وښیه';
  }

  @override
  String get gradesScreenShowLess => 'لږ وښیه';

  @override
  String gradesScreenScoreOutOf100(String score) {
    return '$score / ۱۰۰';
  }

  @override
  String get adminSchoolSettingsStart => 'پیل';

  @override
  String get adminSchoolSettingsEnd => 'پای';

  @override
  String get adminExportScreenEachUserAlone => 'هر کاروونکی یوازې';

  @override
  String get adminExportScreenEachUserAloneOn =>
      'هر کاروونکي ته یوه بشپړه پاڼه، د لوستلو وړ لوی کارت طرحه.';

  @override
  String get adminExportScreenEachUserAloneOff =>
      'کوچنی جدول — هر کاروونکی یوه کرښه ده.';

  @override
  String get adminExportScreenSeparateFilesOn => 'هر کاروونکي ته جلا PDF';

  @override
  String get adminExportScreenSeparateFilesOff =>
      'یوازینی PDF، هر کاروونکي ته یوه پاڼه';

  @override
  String adminExportScreenSeparateFilesOnDesc(int count) {
    return 'تاسو به یوځل $count PDF فایلونه شریک کړئ — هر کاروونکی خپل ترلاسه کوي.';
  }

  @override
  String get adminExportScreenSeparateFilesOffDesc =>
      'هرڅوک په یوه PDF کې، هر یو په خپله پاڼه کې.';

  @override
  String get adminSubjectDetailScreenSchoolSettings => 'د ښوونځي امستنې';

  @override
  String get adminSubjectDetailScreenNewSubject => 'نوی مضمون';

  @override
  String get adminSubjectDetailScreenLangEnglish => 'انګلیسي';

  @override
  String get adminSubjectDetailScreenLangArabic => 'عربي';

  @override
  String get adminSubjectDetailScreenLangHebrew => 'عبري';

  @override
  String get adminSubjectDetailScreenLangFrench => 'فرانسوي';

  @override
  String get adminSubjectDetailScreenLangRussian => 'روسي';

  @override
  String get adminSubjectDetailScreenColor => 'رنګ';

  @override
  String get parentHomeScreenGreetingFallback => 'دلته';

  @override
  String parentHomeScreenChildrenLoadError(String error) {
    return 'ستاسو ماشومان بار نشول: $error';
  }

  @override
  String get parentHomeScreenMaterials => 'توکي';

  @override
  String get cmCodeBlockCopied => 'کاپي شو';

  @override
  String get cmCodeBlockCopy => 'کاپي';

  @override
  String get phoneFieldCountryCode => 'د هیواد کوډ';

  @override
  String get teacherClassroomAddMeetingScreenEndDateDefault =>
      'د پای نیټه د پیل نیټې ته اوړي';

  @override
  String get teacherAddMaterialScreenLinkHint => 'https://…';

  @override
  String get teacherAddMaterialScreenLinkFallback => 'لینک';

  @override
  String get teacherAddMaterialScreenFileFallback => 'فایل';

  @override
  String get teacherCreateDiplomaScreenTitle => 'سند صادرول';

  @override
  String get teacherCreateDiplomaScreenGradePrefix => 'ټولګی';

  @override
  String get teacherCreateDiplomaScreenAttachFiles => 'د سند فایل(ونه) نښلول';

  @override
  String get teacherCreateDiplomaScreenAddMoreFiles => 'نور فایلونه زیاتول';

  @override
  String get teacherAssignmentDetailScreenTitle => 'دنده';

  @override
  String get teacherAssignmentDetailScreenNoSubmissions =>
      'تر اوسه هیڅ سپارنه نشته';

  @override
  String teacherAssignmentDetailScreenSubmissionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ې',
      one: 'ه',
    );
    return '$count سپارن$_temp0';
  }

  @override
  String teacherAssignmentDetailScreenGradedCount(int count) {
    return '$count نمره ورکړل شوي';
  }

  @override
  String get teacherAssignmentDetailScreenStudentFallback => 'زده کوونکی';

  @override
  String teacherAssignmentDetailScreenSubmittedOn(String date) {
    return 'وسپارل شو $date';
  }

  @override
  String teacherAddAssignmentScreenGradeLabel(int count) {
    return 'ټولګی $count';
  }

  @override
  String teacherAddAssignmentScreenStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ي',
      one: 'ی',
    );
    return '$count زده کوونک$_temp0';
  }

  @override
  String teacherAddAssignmentScreenMembersWillReceive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ي',
      one: 'ی',
    );
    return '$count غړ$_temp0 به دا ترلاسه کړي';
  }

  @override
  String get teacherAddAssignmentScreenNoDueDate => 'د سپارلو نیټه نشته';

  @override
  String get teacherAddAssignmentScreenMaterialFallback => 'توکی';

  @override
  String teacherAddAssignmentScreenSelectedCount(int count) {
    return '$count ټاکل شوي';
  }

  @override
  String teacherClassroomsScreenGradeLabel(int grade) {
    return 'ټولګی $grade';
  }

  @override
  String get teacherClassroomsScreenNewClassroom => 'نوی ټولګی';

  @override
  String get assignmentsScreenAlreadyHandedIn => 'تاسو دا دنده دمخه سپارلې ده.';

  @override
  String get assignmentsScreenAddNoteOrFiles =>
      'یادښت زیات کړئ یا فایلونه ونښلوئ، بیا «وسپاره» کلیک کړئ.';

  @override
  String assignmentsScreenGradeLabel(String grade) {
    return 'نمره: $grade';
  }

  @override
  String assignmentsScreenFeedbackLabel(String feedback) {
    return 'نظر: $feedback';
  }

  @override
  String get assignmentsScreenReturnedForResolution =>
      'د بیا حل لپاره بیرته راستانه شو';

  @override
  String get assignmentsScreenAttachFile => 'فایل نښلول';

  @override
  String get assignmentsScreenAddMoreFiles => 'نور فایلونه زیاتول';

  @override
  String get assignmentsScreenHandingIn => 'سپارل کیږي…';

  @override
  String get assignmentsScreenHandIn => 'وسپاره';

  @override
  String get examDetailScreenCouldNotLoad =>
      'دا ازموینه اوس مهال نشي بار کیدای.';

  @override
  String get adminEditUserRoleStudent => 'زده کوونکی';

  @override
  String get adminEditUserRoleTeacher => 'ښوونکی';

  @override
  String get adminEditUserRoleSecretary => 'منشي';

  @override
  String get adminEditUserRoleParent => 'مور و پلار';

  @override
  String get adminEditUserRoleAdmin => 'اداره چي';

  @override
  String adminEditUserCohortMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'و',
      one: 'ې',
    );
    return 'د $count ډل$_temp0 غړی.';
  }

  @override
  String get adminEditUserSearchStudents => 'زده کوونکي ولټوئ…';

  @override
  String adminEditUserGradeSuffix(int grade) {
    return '(ټولګی $grade)';
  }

  @override
  String get solutionAssetPreviewSheetPdfDocument => 'PDF سند';

  @override
  String get solutionAssetPreviewSheetUnableToPreview =>
      'PDF نشي مخکتنه کیدای.';

  @override
  String classroomDetailSectionHeader(String title, int count) {
    return '$title ($count)';
  }

  @override
  String get classroomDetailTeacherSection => 'ښوونکی';

  @override
  String get classroomDetailStudentsSection => 'زده کوونکي';

  @override
  String get classroomDetailClassroomFallback => 'ټولګی';

  @override
  String get classroomDetailUntitled => 'بې سرلیکه';

  @override
  String get typingDotsPaused => 'ودرول شو';

  @override
  String get cmAiMessageStartPracticeSession => 'د تمرین ناسته پیل کړئ';

  @override
  String cmAiMessageQuestionCount(int count) {
    return '$count پوښتنې';
  }

  @override
  String get cmAiMessageDifficultyEasy => 'اسانه';

  @override
  String get cmAiMessageDifficultyHard => 'ګران';

  @override
  String get cmAiMessageDifficultyOlympiad => 'المپیاد';

  @override
  String get cmAiMessageDifficultyAdaptive => 'تطبیقي';

  @override
  String get cmAiMessageDifficultyMedium => 'منځنی';

  @override
  String get teacherCreateFormScreenParagraphType => 'پراګراف';

  @override
  String get teacherCreateFormScreenMultipleChoiceType => 'ګڼ ګروهیز';

  @override
  String get teacherCreateFormScreenCheckboxesType => 'د چک بکسونه';

  @override
  String get teacherCreateFormScreenRatingType => 'درجه بندي (۱–۵)';

  @override
  String get teacherCreateFormScreenLinearScaleType => 'خطي مقیاس';

  @override
  String get teacherCreateFormScreenDropdownType => 'ښکته کیدونکی';

  @override
  String get teacherCreateFormScreenDateType => 'نیټه';

  @override
  String teacherCohortsScreenSingleGrade(int grade) {
    return 'ټولګی $grade';
  }

  @override
  String teacherCohortsScreenGradeRange(int from, int to) {
    return 'ټولګی $from-$to';
  }

  @override
  String teacherCohortsScreenMultiGrade(String grades) {
    return 'ټولګي $grades';
  }

  @override
  String get teacherAddGradeScreenFailedCreateRecord =>
      'د نمرې ریکارډ جوړول ناکام شو.';

  @override
  String get phoneFieldLabel => 'تلیفون (اختیاري)';

  @override
  String get phoneFieldHelper =>
      'د SMS له لارې د پټنوم بیا تنظیمولو لپاره کارول کیږي';

  @override
  String get gradesScreenCouldNotLoad => 'نمرې بار نشوې.';

  @override
  String get gradesScreenTimeout => 'غوښتنه وخت تېر شو. خپل اتصال وګورئ.';

  @override
  String get gradesScreenNoConnection => 'اتصال نشته. د بیا هڅې لپاره کش کړئ.';

  @override
  String get examDetailScreenCountdownPassed => 'دا ازموینه تېره شوې ده';

  @override
  String get examDetailScreenCountdownToday => 'دا نن دی!';

  @override
  String get teacherCreateDiplomaScreenDefaultTitle => 'د لاسته راوړنې سند';

  @override
  String teacherMaterialAddedBy(String name) {
    return 'زیات شوی د $name لخوا';
  }

  @override
  String teacherMaterialAttachedTo(String period) {
    return 'نښلول شوی له $period سره';
  }

  @override
  String get adminPeopleAddMany => 'ډېر اضافه کړئ';

  @override
  String get adminAddManyPasteNames => 'نومونه پیست کړئ';

  @override
  String get adminAddManyApplyRole => 'د ټولو لپاره رول وټاکئ';

  @override
  String get adminAddManyApplyGrade => 'د ټولو لپاره درجه وټاکئ';

  @override
  String get adminAddManyParentLabel => 'والد';

  @override
  String get adminAddManyParentNone => 'هیڅ والد نشته';

  @override
  String get adminAddManyAddParent => 'والد اضافه کړئ';

  @override
  String get adminAddManyCreateParentGeneric => 'نوی والد جوړ کړئ';

  @override
  String get adminAddManyParentInBatch => 'پدې لیست کې نوي والدین';

  @override
  String get adminAddManyParentExisting => 'موجود والدین';

  @override
  String get adminAddManySearchParents => 'والدین ولټوئ…';

  @override
  String get adminAddManyNoParentsYet =>
      'هیڅ سمون لرونکی والد نشته — د جوړولو لپاره پورته یو نوم ولیکئ';

  @override
  String get adminAddManyUsernameTaken => 'کارن نوم لا دمخه نیول شوی';

  @override
  String get adminAddManyUsernameDupe => 'پدې لیست کې تکراري کارن نوم';

  @override
  String get adminUsernameAvailable => 'Username is available';

  @override
  String get adminUsernameInvalidFormat => 'Use 3+ letters, digits, or . _ -';

  @override
  String get adminUsernameSuggestionsLabel =>
      'Available suggestions — tap to use:';

  @override
  String adminAddManyCreateParent(String name) {
    return 'نوی والد جوړ کړئ \"$name\"';
  }

  @override
  String adminAddManyPastedRows(int count) {
    return '$count کرښې اضافه شوې';
  }

  @override
  String get teacherCreateClassroomNoStudentsInCohort =>
      'په ټاکل شوي کوهورت کې لا تر اوسه زده کوونکي نشته.';

  @override
  String get audienceSummaryResolving => 'د زده کوونکو موندل…';

  @override
  String audienceSummaryCount(int count) {
    return '$count به دا وویني';
  }

  @override
  String get audienceSummaryEmpty =>
      'هیڅ زده کوونکی د دې لیدونکو سره سمون نه خوري.';

  @override
  String audienceSummaryRestore(int count) {
    return '$count ړنګ شوي بیرته راوله';
  }

  @override
  String get scheduleUpcomingExam => 'راتلونکې ازموینه';

  @override
  String get scheduleNoUpcomingExams => 'هیڅ راتلونکې ازموینه نشته';

  @override
  String get navAverages => 'اوسطونه';

  @override
  String get navCertificates => 'سندونه';

  @override
  String get averagesTitle => 'اوسطونه';

  @override
  String get averagesAddTitle => 'نوی اوسط';

  @override
  String get averagesEditTitle => 'د اوسط سمون';

  @override
  String get averagesSelectCohort => 'ټولګی';

  @override
  String get averagesSelectSubject => 'مضمون';

  @override
  String get averagesNoSubjects => 'د دې ټولګي لپاره مضمونونه ونه موندل شول.';

  @override
  String get averagesEmpty =>
      'تر اوسه هیڅ اوسط نشته. د زیاتولو لپاره + کېکاږئ.';

  @override
  String averagesVariantCount(int count, int units) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بڼې',
      one: 'یوه بڼه',
    );
    return '$_temp0 · $units واحدونه';
  }

  @override
  String get averagesDeleteTitle => 'د اوسط ړنګول';

  @override
  String get averagesDeleteConfirm => 'دا اوسط ړنګ کړئ؟ بیرته نشي کېدی.';

  @override
  String get averagesDelete => 'ړنګول';

  @override
  String get averagesFieldTitle => 'سرليک';

  @override
  String get averagesFieldTitleHint => 'بېلګه: د ریاضي د ۵ واحدونو وروستۍ بڼه';

  @override
  String get averagesSemester => 'سمسټر';

  @override
  String get averagesUnits => 'واحدونه (وزن)';

  @override
  String get averagesUnitsHint =>
      '۰ که چېرې دې کچې ته وزن لرونکي واحدونه نه وي، لکه اوومه ټولګۍ';

  @override
  String get averagesBestFormatNote =>
      'سیسټم په اتومات ډول د دې ټولګي د هر زده‌کوونکي لپاره غوره بڼه ټاکي.';

  @override
  String get averagesNoGrades =>
      'د دې ټولګي او مضمون لپاره نمرې ونه موندل شوې.';

  @override
  String get averagesAddFormat => 'بڼه زیاته کړئ';

  @override
  String get averagesSave => 'ساتل';

  @override
  String get averagesFormat => 'بڼه';

  @override
  String get averagesAddGrade => 'نمره زیاته کړئ';

  @override
  String get averagesGrade => 'نمره';

  @override
  String averagesWeightSum(String sum) {
    return 'ټول: $sum%';
  }

  @override
  String get averagesTitleRequired => 'مهرباني وکړئ سرليک دننه کړئ.';

  @override
  String get averagesPickGradeForEachRow => 'د هرې کرښې لپاره یوه نمره وټاکئ.';

  @override
  String get averagesWeightMustBe100 => 'د هرې بڼې سلنه باید ۱۰۰٪ شي.';

  @override
  String get certificatesTitle => 'سندونه';

  @override
  String get certHomeroom => 'ټولګی (سرښوونکی)';

  @override
  String get certStudent => 'زده‌کوونکی';

  @override
  String get certDisplayName => 'په سند کې نوم';

  @override
  String get certNationalId => 'ملي پېژندپاڼه';

  @override
  String get certHomeroomTeacher => 'د ټولګي سرښوونکی';

  @override
  String get certPrincipal => 'مدير';

  @override
  String get certPublisherNote => 'یادښت (اختیاري)';

  @override
  String get certSemesterWeights => 'د سمسټرونو وزنونه';

  @override
  String get certLanguage => 'د سند ژبه';

  @override
  String get certGenerate => 'PDF جوړ کړئ';

  @override
  String get certWeightsMustBe100 => 'د سمسټرونو د وزنونو مجموعه باید ۱۰۰٪ شي.';

  @override
  String get certSelectStudentFirst => 'لومړی یو زده‌کوونکی وټاکئ.';

  @override
  String get certSaved => 'سند جوړ شو.';

  @override
  String get certPdfAnnualCertificate => 'کلنی سند';

  @override
  String get certPdfSubject => 'مضمون';

  @override
  String get certPdfFinal => 'وروستی';

  @override
  String get certPdfOverall => 'عمومي اوسط';

  @override
  String get certPdfAverage => 'اوسط';

  @override
  String get certPdfAbsences => 'غیرحاضري';

  @override
  String get certPdfLateness => 'ناوختي';

  @override
  String get certPdfHomeroomTeacher => 'د ټولګي سرښوونکی';

  @override
  String get certPdfPrincipal => 'مدير';

  @override
  String get certPdfNationalId => 'د پېژندپاڼې شمېره';

  @override
  String get certPdfDate => 'نېټه';

  @override
  String get certPdfGeneratedBy => 'جوړوونکی';

  @override
  String get certPdfName => 'نوم';

  @override
  String get certPdfClass => 'ټولګی';

  @override
  String get adminEditUserNationalId => 'ملي پېژندپاڼه';

  @override
  String get teacherCohortsScreenNoStudentsToAdd =>
      'ټول زده‌کوونکي دمخه په دې ټولګي کې دي.';
}

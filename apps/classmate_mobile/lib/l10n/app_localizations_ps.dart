// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Pushto Pashto (`ps`).
class AppLocalizationsPs extends AppLocalizations {
  AppLocalizationsPs([String locale = 'ps']) : super(locale);

  @override
  String get certAddTeacher => '‹‹Add teacher››';

  @override
  String get certSearchStudent => '‹‹Search students››';

  @override
  String get certNewCertificate => '‹‹New certificate››';

  @override
  String get certChooseStudent => 'Choose a student';

  @override
  String get certSelectClassFirst => 'Select a class first';

  @override
  String certCertificateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count certificates',
      one: '1 certificate',
      zero: 'No certificates',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get onbTeacher2Title => '‹‹Your classes, organized››';

  @override
  String get onbTeacher2Body =>
      '‹‹Your schedule, classrooms and student rosters — all in one place.››';

  @override
  String get onbTeacher3Title => '‹‹Grades & attendance, fast››';

  @override
  String get onbTeacher3Body =>
      '‹‹Take attendance and enter grades in seconds, right from your phone.››';

  @override
  String get onbTeacher4Title => '‹‹Reach everyone››';

  @override
  String get onbTeacher4Body =>
      '‹‹Post announcements and message students and parents instantly.››';

  @override
  String get onbAdmin2Title => '‹‹Run your school››';

  @override
  String get onbAdmin2Body =>
      '‹‹Manage people, classes and the timetable from one dashboard.››';

  @override
  String get onbAdmin3Title => '‹‹Set up in minutes››';

  @override
  String get onbAdmin3Body =>
      '‹‹Add students, teachers and classes in just a few taps.››';

  @override
  String get onbAdmin4Title => '‹‹Keep everyone in sync››';

  @override
  String get onbAdmin4Body =>
      '‹‹Broadcast announcements and message your whole school.››';

  @override
  String get onbSecretary2Title => '‹‹Students at your fingertips››';

  @override
  String get onbSecretary2Body =>
      '‹‹Look up any student and keep their details up to date.››';

  @override
  String get onbSecretary3Title => '‹‹Share the word››';

  @override
  String get onbSecretary3Body =>
      '‹‹Send announcements to the right classes in seconds.››';

  @override
  String get onbParent2Title => '‹‹Follow your child››';

  @override
  String get onbParent2Body =>
      '‹‹Their schedule, grades and attendance — always up to date.››';

  @override
  String get onbParent3Title => '‹‹Never miss a thing››';

  @override
  String get onbParent3Body =>
      '‹‹Get school announcements and updates the moment they happen.››';

  @override
  String get accountActionsTooltip => '‹‹Account options››';

  @override
  String get accountSwitchTo => '‹‹Switch to this account››';

  @override
  String get accountRemove => '‹‹Remove account››';

  @override
  String get accountRemoveConfirmTitle => '‹‹Remove account?››';

  @override
  String accountRemoveConfirmBody(String name) {
    return '‹‹$name will be removed from this device. You can sign in again anytime.››';
  }

  @override
  String onboardingWelcomeNamed(String name) {
    return '‹‹Welcome, $name!››';
  }

  @override
  String get practiceGenAlmostReady => '‹‹Almost ready…››';

  @override
  String practiceGenRemaining(int seconds) {
    return '‹‹≈ ${seconds}s left››';
  }

  @override
  String practiceGenEstimate(int min, int max) {
    return '‹‹Usually $min–${max}s››';
  }

  @override
  String get consentGateError =>
      '‹‹Couldn\'t save your choice. Please check your connection and try again.››';

  @override
  String get commonShowPassword => '‹‹Show password››';

  @override
  String get commonHidePassword => '‹‹Hide password››';

  @override
  String get adminEmailInvalid => '‹‹Enter a valid email address››';

  @override
  String get adminPhoneInvalid => '‹‹Enter a valid phone number››';

  @override
  String get adminFullNameLabel => '‹‹Full name››';

  @override
  String get adminHomeroomLabel => '‹‹Homeroom class››';

  @override
  String get adminHomeroomNone => '‹‹No homeroom class››';

  @override
  String get adminHomeroomNoneAvailable =>
      '‹‹No unassigned classes available››';

  @override
  String get adminHomeroomHint =>
      '‹‹This teacher becomes the homeroom teacher of the selected class.››';

  @override
  String get logoutConfirmTitle => '‹‹Log out?››';

  @override
  String get logoutConfirmBody =>
      '‹‹You\'ll need to sign in again to use ClassMate.››';

  @override
  String get pressBackAgainToExit => '‹‹Press back again to exit››';

  @override
  String get onboardingSkip => '‹‹Skip››';

  @override
  String get onboardingNext => '‹‹Next››';

  @override
  String get onboardingGetStarted => '‹‹Get started››';

  @override
  String get onboardingSlide1Title => '‹‹Welcome to ClassMate››';

  @override
  String get onboardingSlide1Body =>
      '‹‹Your smart school companion — everything for school, all in one place.››';

  @override
  String get onboardingSlide2Title => '‹‹Meet NOVA››';

  @override
  String get onboardingSlide2Body =>
      '‹‹Your AI tutor, ready to explain any topic and help you practice, anytime.››';

  @override
  String get onboardingSlide3Title => '‹‹Stay on top of everything››';

  @override
  String get onboardingSlide3Body =>
      '‹‹Schedule, grades, attendance and assignments — always up to date.››';

  @override
  String get onboardingSlide4Title => '‹‹Stay connected››';

  @override
  String get onboardingSlide4Body =>
      '‹‹Messages and announcements keep students, teachers and parents in sync.››';

  @override
  String get consentGateTitle => '‹‹Before you continue››';

  @override
  String get consentGateBody =>
      '‹‹To keep using ClassMate, please review and accept how we handle your data.››';

  @override
  String get consentGateLink => '‹‹Read the Privacy Policy & Terms››';

  @override
  String get consentGateAccept =>
      '‹‹I accept the Privacy Policy and Terms of Use››';

  @override
  String get consentGateGuardian =>
      '‹‹I have my parent or guardian\'s permission to use ClassMate››';

  @override
  String get consentGateContinue => '‹‹Agree & Continue››';

  @override
  String get menu => '‹‹Menu››';

  @override
  String get sectionCore => '‹‹Core››';

  @override
  String get sectionSchoolTools => '‹‹School Tools››';

  @override
  String get sectionAccount => '‹‹Account››';

  @override
  String get navSchedule => '‹‹Schedule››';

  @override
  String get navClassrooms => '‹‹Classrooms››';

  @override
  String get navPractice => '‹‹Practice››';

  @override
  String get navInsights => '‹‹Insights››';

  @override
  String get navNova => '‹‹NOVA››';

  @override
  String get navMessages => '‹‹Messages››';

  @override
  String get navAttendance => '‹‹Attendance››';

  @override
  String get navGrades => '‹‹Grades››';

  @override
  String get navAssignments => '‹‹Assignments››';

  @override
  String get navMeetings => '‹‹Meetings››';

  @override
  String get navAnnouncements => '‹‹Announcements››';

  @override
  String get navNotifications => '‹‹Notifications››';

  @override
  String get navSolutions => '‹‹Solutions››';

  @override
  String get navExams => '‹‹Exams››';

  @override
  String get navForms => '‹‹Forms››';

  @override
  String get navHome => '‹‹Home››';

  @override
  String get navTeacherWorkspace => '‹‹Teacher Workspace››';

  @override
  String get navTeacherAssessments => '‹‹Assessments & Grades››';

  @override
  String get navSavedQuestions => '‹‹Saved Questions››';

  @override
  String get navProfile => '‹‹Profile››';

  @override
  String get navSettings => '‹‹Settings››';

  @override
  String get navLogout => '‹‹Log out››';

  @override
  String get roleTeacher => '‹‹Teacher››';

  @override
  String get roleAdmin => '‹‹Admin››';

  @override
  String get roleSecretary => '‹‹Secretary››';

  @override
  String get roleParent => '‹‹Parent››';

  @override
  String get roleStudent => '‹‹Student››';

  @override
  String get titleSchedule => '‹‹Schedule››';

  @override
  String get titleClasses => '‹‹Classes››';

  @override
  String get titlePractice => '‹‹Practice››';

  @override
  String get titleInsights => '‹‹Insights››';

  @override
  String get titleNova => '‹‹NOVA››';

  @override
  String get titleMessages => '‹‹Messages››';

  @override
  String get titleSolutions => '‹‹Solutions››';

  @override
  String get titleBagrut => 'Bagrut';

  @override
  String get bagrutSearchHint => 'مضمونونه ولټوئ';

  @override
  String bagrutNoExams(Object subject) {
    return 'د $subject لپاره تر اوسه ازموینې نشته.';
  }

  @override
  String bagrutFilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فایلونه',
      one: '1 فایل',
      zero: 'فایلونه نشته',
    );
    return '$_temp0';
  }

  @override
  String get bagrutNoFiles => 'فایلونه نشته.';

  @override
  String get bagrutFileQuestions => 'پوښتنې';

  @override
  String get bagrutFileAnswers => 'ځوابونه';

  @override
  String get bagrutFileSolution => 'حل';

  @override
  String get bagrutFileAdvanced => 'بشپړ حل';

  @override
  String get titleExams => '‹‹Exams››';

  @override
  String get solutionsUploadAction => '‹‹Upload››';

  @override
  String get solutionsNoSubjectsAvailable => '‹‹No subjects available.››';

  @override
  String solutionsNoSubjectsMatch(Object query) {
    return '‹‹No subjects match \"$query\".››';
  }

  @override
  String solutionsBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books',
      one: '1 book',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get solutionsBooksTitle => '‹‹Books››';

  @override
  String get solutionsAddBookTitle => '‹‹Add a book››';

  @override
  String get solutionsBookTitleHint => '‹‹Book title...››';

  @override
  String get solutionsAddBookAction => '‹‹Add a book››';

  @override
  String get solutionsSearchBooks => '‹‹Search books››';

  @override
  String get solutionsChooseSubjectFirst => '‹‹Choose a subject first.››';

  @override
  String solutionsNoBooksYetBody(Object action) {
    return '‹‹No books yet.\nTap \"$action\" to add the first one.››';
  }

  @override
  String solutionsNoBooksMatch(Object query) {
    return '‹‹No books match \"$query\".››';
  }

  @override
  String get solutionsBookLabel => '‹‹Book››';

  @override
  String get solutionsPagesFilterHint =>
      '‹‹Enter a page and question number to filter, or leave blank to see all.››';

  @override
  String get solutionsPageNumberLabel => '‹‹Page number››';

  @override
  String get solutionsPageNumberHint => '‹‹e.g. 42››';

  @override
  String get solutionsQuestionNumberLabel => '‹‹Question number››';

  @override
  String get solutionsQuestionNumberHint => '‹‹e.g. 3a or 7››';

  @override
  String get solutionsViewSolutionsAction => '‹‹View solutions››';

  @override
  String solutionsPageQuestionSummary(Object page, Object question) {
    return '‹‹Page $page • Question $question››';
  }

  @override
  String get solutionsExactQuestionTitle =>
      '‹‹Solutions for this exact question››';

  @override
  String get solutionsExactQuestionEmptySubtitle =>
      '‹‹Nothing has been uploaded for this exact question yet. Be the first to help your classmates.››';

  @override
  String solutionsUploadsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uploads found',
      one: '1 upload found',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get solutionsExactQuestionEmptyBody =>
      '‹‹No exact match yet. You can upload one now, or check what classmates solved on this same page.››';

  @override
  String get solutionsLoadMoreAction => '‹‹Load more››';

  @override
  String get solutionsSamePageTitle =>
      '‹‹Other questions solved on this page››';

  @override
  String get solutionsSamePageEmptySubtitle =>
      '‹‹No neighboring questions were uploaded from this page yet.››';

  @override
  String get solutionsSamePageFallbackSubtitle =>
      '‹‹Useful fallback when your exact question has no upload yet.››';

  @override
  String get solutionsSamePageEmptyBody =>
      '‹‹No nearby uploads on this page yet. A fresh upload here would really help.››';

  @override
  String get solutionsVerifiedByNova => '‹‹Verified by NOVA››';

  @override
  String get solutionsUploadFileLimitReached => '‹‹10-file limit reached.››';

  @override
  String solutionsUploadFilesAddedLimit(int count) {
    return '‹‹Added $count — 10-file limit.››';
  }

  @override
  String get solutionsUploadCompleteFields =>
      '‹‹Complete subject, book, page, and question.››';

  @override
  String get solutionsUploadAddOneFile => '‹‹Add at least one image or PDF.››';

  @override
  String solutionsUploadFileFailed(Object error) {
    return '‹‹File upload failed: $error››';
  }

  @override
  String solutionsUploadCreateFailed(Object error) {
    return '‹‹Failed to create solution: $error››';
  }

  @override
  String get solutionsUploadSuccess => '‹‹Solution uploaded!››';

  @override
  String get solutionsUploadAddNewBookOption => '‹‹+ Add a new book...››';

  @override
  String get solutionsUploadAddBookShortAction => '‹‹Add››';

  @override
  String get solutionsUploadTitle => '‹‹Upload a solution››';

  @override
  String get solutionsUploadSubtitle =>
      '‹‹Real images or PDFs only. NOVA verification and moderation are applied after upload.››';

  @override
  String get solutionsUploadNoBooksAbove => '‹‹No books — add one above››';

  @override
  String get solutionsUploadCaptionOptional => '‹‹Caption (optional)››';

  @override
  String get solutionsUploadImagesAction => '‹‹Images››';

  @override
  String get solutionsUploadPdfAction => '‹‹PDF››';

  @override
  String solutionsUploadFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'files selected',
      one: 'file selected',
    );
    return '‹‹$count / 10 $_temp0››';
  }

  @override
  String get solutionsUploadSomeFilesFailed =>
      '‹‹Some files failed to upload.››';

  @override
  String get solutionsUploadRetryFailedFiles => '‹‹Retry failed files››';

  @override
  String get solutionsUploadSubmittingAction => '‹‹Uploading...››';

  @override
  String get solutionsUploadSubmitAction => '‹‹Upload solution››';

  @override
  String get settingsTitle => '‹‹Settings››';

  @override
  String get settingsSubtitle => '‹‹Appearance, language & account››';

  @override
  String get settingsAppearance => '‹‹Appearance››';

  @override
  String get settingsTheme => '‹‹Theme››';

  @override
  String get settingsLanguage => '‹‹Language››';

  @override
  String get settingsLanguageSystem => '‹‹System default››';

  @override
  String get settingsAccentColour => '‹‹Accent colour››';

  @override
  String get settingsAccentSubtitle => '‹‹Tint used across the whole app››';

  @override
  String get settingsReduceMotion => '‹‹Reduce motion››';

  @override
  String get settingsReduceMotionSubtitle =>
      '‹‹Fewer animations throughout the app››';

  @override
  String get settingsAccount => '‹‹Account››';

  @override
  String get settingsLogout => '‹‹Log out››';

  @override
  String get settingsLogoutSubtitle => '‹‹Sign out of this device››';

  @override
  String get settingsThemeSystem => '‹‹System default››';

  @override
  String get settingsThemeLight => '‹‹Light››';

  @override
  String get settingsThemeDark => '‹‹Dark››';

  @override
  String get settingsThemeCoffee => 'قهوه';

  @override
  String get settingsThemeMatcha => 'ماچا';

  @override
  String get settingsThemeRose => 'روزې';

  @override
  String get settingsThemeMidnight => 'نیمه شپه';

  @override
  String get settingsThemeNord => 'نورد';

  @override
  String get settingsThemeForest => 'ځنګل';

  @override
  String get settingsThemeSand => 'شګه';

  @override
  String get settingsThemeSky => 'اسمان';

  @override
  String get settingsThemeLavender => 'لیوېنډر';

  @override
  String get settingsThemePeach => 'شفتالو';

  @override
  String get settingsThemeMint => 'نعناع';

  @override
  String get settingsThemeDracula => 'ډراکولا';

  @override
  String get settingsThemeObsidian => 'اوبسیډین';

  @override
  String get settingsThemeWine => 'شراب';

  @override
  String get settingsThemeSolarized => 'سولرایزډ';

  @override
  String get settingsThemePlum => 'الوچه';

  @override
  String get settingsThemeOcean => 'سمندر';

  @override
  String get settingsLanguageSearchHint => '‹‹Search language...››';

  @override
  String get teacherWorkspaceSubtitle =>
      '‹‹Run attendance, rosters, and grading from the mobile app.››';

  @override
  String get teacherMetricSessionsToday => '‹‹Sessions today››';

  @override
  String get teacherMetricTeachingGroups => '‹‹Teaching groups››';

  @override
  String get teacherMetricAssessments => '‹‹Assessments››';

  @override
  String get teacherQuickActions => '‹‹Quick actions››';

  @override
  String get teacherNoDateAvailable => '‹‹No date available››';

  @override
  String get teacherNoTeachingSlotsToday =>
      '‹‹No teaching slots scheduled today.››';

  @override
  String get teacherUpcomingAssessments => '‹‹Upcoming assessments››';

  @override
  String get teacherUpcomingAssessmentsSubtitle =>
      '‹‹Live from the teacher grading system››';

  @override
  String get teacherNoAssessmentsYet => '‹‹No assessments created yet.››';

  @override
  String get teacherUnassignedSlot => '‹‹Unassigned slot››';

  @override
  String get teacherNoCohort => '‹‹No cohort››';

  @override
  String get teacherCourseFallback => '‹‹Course››';

  @override
  String teacherPeriod(Object number) {
    return '‹‹Period $number››';
  }

  @override
  String get teacherLoadErrorTitle => '‹‹Could not load teacher workspace››';

  @override
  String get teacherClassroomsLoadError =>
      '‹‹We could not load classrooms right now. Pull to refresh or try again.››';

  @override
  String get teacherClassroomsLoadTimeout =>
      '‹‹Classrooms are taking too long to load. Pull to refresh or try again in a moment.››';

  @override
  String get teacherClassroomsLoadNetwork =>
      '‹‹Classrooms could not connect right now. Check your connection and try again.››';

  @override
  String get teacherClassroomsSubtitle =>
      '‹‹Open the roster and generate a live join code for student entry.››';

  @override
  String get teacherClassroomsNoCohorts =>
      '‹‹No classroom cohorts are linked to this teacher yet.››';

  @override
  String teacherClassroomsCohort(Object cohortId) {
    return '‹‹Cohort $cohortId››';
  }

  @override
  String get teacherClassroomsGeneratingJoinCode => '‹‹Generating…››';

  @override
  String get teacherClassroomsCreateJoinCode => '‹‹Create join code››';

  @override
  String get teacherClassroomsLiveJoinCode => '‹‹Live join code››';

  @override
  String teacherClassroomsExpiresAt(Object value) {
    return '‹‹Expires $value››';
  }

  @override
  String get teacherClassroomsRoster => '‹‹Roster››';

  @override
  String get teacherClassroomsNoStudents =>
      '‹‹No students are enrolled in this classroom yet.››';

  @override
  String get teacherAttendanceLoadError =>
      '‹‹We could not load attendance right now. Pull to refresh or try again.››';

  @override
  String get teacherAttendanceLoadTimeout =>
      '‹‹Attendance is taking too long to load. Pull to refresh or try again in a moment.››';

  @override
  String get teacherAttendanceLoadNetwork =>
      '‹‹Attendance could not connect right now. Check your connection and try again.››';

  @override
  String get teacherAttendanceSubtitle =>
      '‹‹Pick a live session, mark the room, and save only changed rows.››';

  @override
  String get teacherAttendanceTodaySessions => '‹‹Today sessions››';

  @override
  String teacherAttendanceSessionSummary(
    Object cohort,
    Object grade,
    Object date,
    Object period,
  ) {
    return '‹‹$cohort • Grade $grade • $date • Period $period››';
  }

  @override
  String get teacherAttendanceChanged => '‹‹Changed››';

  @override
  String get teacherAttendanceNoteLabel => '‹‹Note››';

  @override
  String get teacherAttendanceClassNotesLabel => '‹‹Class notes››';

  @override
  String get teacherAttendanceClassNotesHint =>
      '‹‹What was covered in this session…››';

  @override
  String get teacherAttendanceSaving => '‹‹Saving…››';

  @override
  String get teacherAttendanceSaveAll => '‹‹Save attendance››';

  @override
  String teacherAttendanceSaveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes',
      one: '1 change',
    );
    return '‹‹Save $_temp0››';
  }

  @override
  String get teacherAttendanceSaved => '‹‹Attendance saved››';

  @override
  String get retry => '‹‹Retry››';

  @override
  String get scheduleRefreshTooFast =>
      '‹‹Schedule is refreshing too fast right now. Wait a moment and try again.››';

  @override
  String get scheduleSessionExpired =>
      '‹‹Your session has expired. Please sign in again.››';

  @override
  String get scheduleNotOnboarded =>
      '‹‹Your student profile is not fully set up yet. Ask your school admin to assign you to a class.››';

  @override
  String get scheduleLoadError => '‹‹Could not load schedule yet.››';

  @override
  String get scheduleSelectedDay => '‹‹Selected day››';

  @override
  String scheduleClassCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count classes',
      one: '1 class',
      zero: '0 classes',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get scheduleNextUp => '‹‹Next up››';

  @override
  String get scheduleNoMoreClasses => '‹‹No more classes››';

  @override
  String get scheduleNoClassesTitle => '‹‹No classes on this day››';

  @override
  String scheduleNoClassesSubtitle(Object day) {
    return '‹‹$day looks clear.››';
  }

  @override
  String get scheduleClassFallback => '‹‹Class››';

  @override
  String get scheduleNoSubjectLocation => '‹‹No subject or location yet››';

  @override
  String get scheduleNotes => '‹‹Notes››';

  @override
  String get scheduleGoToClassroom => '‹‹Go to Classroom››';

  @override
  String get loginTitle => '‹‹Mobile login for students and teachers››';

  @override
  String get loginSubtitle =>
      '‹‹Teacher accounts open the teacher workspace. Student accounts stay on the student experience.››';

  @override
  String get loginSignIn => '‹‹Sign in››';

  @override
  String get biometricSignIn => '‹‹Sign in with biometrics››';

  @override
  String get biometricEnable => '‹‹Enable biometric sign-in››';

  @override
  String get biometricReason => '‹‹Authenticate to sign in to ClassMate››';

  @override
  String get biometricEnableReason =>
      '‹‹Authenticate to enable biometric sign-in››';

  @override
  String get biometricSignInFaceId => '‹‹Sign in with Face ID››';

  @override
  String get biometricSignInFingerprint => '‹‹Sign in with fingerprint››';

  @override
  String get biometricOrSignInWith => '‹‹or sign in with››';

  @override
  String get biometricNotSetUp =>
      '‹‹No biometric sign-in set up yet. Turn on Face ID or fingerprint in Profile → Biometric sign-in.››';

  @override
  String get biometricNotRecognized =>
      '‹‹Biometric not recognized. Try again or sign in with your password.››';

  @override
  String get biometricFaceUnavailable =>
      '‹‹Face ID isn\'t available on this device.››';

  @override
  String get biometricFingerprintUnavailable =>
      '‹‹Fingerprint isn\'t available on this device.››';

  @override
  String get biometricNotAvailableOnDevice =>
      '‹‹Not available on this device››';

  @override
  String get biometricSectionTitle => '‹‹Biometric sign-in››';

  @override
  String get biometricSectionSubtitle =>
      '‹‹Turn on Face ID or your fingerprint to sign in faster. You\'ll confirm your password once.››';

  @override
  String get biometricFaceId => '‹‹Face ID››';

  @override
  String get biometricFaceIdDesc => '‹‹Use Face ID to sign in››';

  @override
  String get biometricFingerprint => '‹‹Fingerprint››';

  @override
  String get biometricFingerprintDesc => '‹‹Use your fingerprint to sign in››';

  @override
  String get biometricConfirmPasswordTitle => '‹‹Confirm your password››';

  @override
  String get biometricConfirmPasswordBody =>
      '‹‹Enter your password to turn on biometric sign-in.››';

  @override
  String get biometricPasswordIncorrect =>
      '‹‹Incorrect password. Please try again.››';

  @override
  String get biometricEnrollFailed =>
      '‹‹Couldn\'t verify your biometric. Make sure Face ID or a fingerprint is set up in your device settings.››';

  @override
  String get biometricEnterCredsFirst =>
      '‹‹Enter your email and password first, then enable biometric sign-in.››';

  @override
  String get biometricLoginFailed =>
      '‹‹Biometric sign-in failed. Please sign in with your password.››';

  @override
  String get biometricEnrollTitle => '‹‹Enable biometric sign-in?››';

  @override
  String get biometricEnrollBody =>
      '‹‹Use Face ID or your fingerprint to sign in faster next time.››';

  @override
  String get biometricEnrollYes => '‹‹Enable››';

  @override
  String get biometricEnrollNo => '‹‹Not now››';

  @override
  String get loginWelcomeTitle => '‹‹Welcome back››';

  @override
  String get loginWelcomeSubtitle => '‹‹Sign in to your ClassMate account.››';

  @override
  String get loginSigningIn => '‹‹Signing in...››';

  @override
  String get loginEmailLabel => '‹‹Email or username››';

  @override
  String get loginPasswordLabel => '‹‹Password››';

  @override
  String get profileNotAvailable => '‹‹Not available››';

  @override
  String get profileSchoolInfo => '‹‹School info››';

  @override
  String get profileFullName => '‹‹Full name››';

  @override
  String get profileRole => '‹‹Role››';

  @override
  String get profileSchoolId => '‹‹School ID››';

  @override
  String get profileCohortId => '‹‹Cohort ID››';

  @override
  String get profileMyCohorts => '‹‹My cohorts››';

  @override
  String get profileMyCohortsEmpty =>
      '‹‹You\'re not enrolled in any cohorts yet.››';

  @override
  String get profileAccountInfo => '‹‹Account info››';

  @override
  String get profileUsername => '‹‹Username››';

  @override
  String get profileUsernameHint => '‹‹your_username››';

  @override
  String get profileContactEmail => '‹‹Contact email››';

  @override
  String get profileEmailAddress => '‹‹Email address››';

  @override
  String get profileEmailHint => '‹‹you@example.com››';

  @override
  String get profileBirthday => '‹‹Birthday››';

  @override
  String get profileSecurity => '‹‹Security››';

  @override
  String get profileSelectBirthday => '‹‹Select your birthday››';

  @override
  String get profilePasswordUpdated => '‹‹Password updated››';

  @override
  String get profileSave => '‹‹Save››';

  @override
  String get profileEmptyValue => '‹‹—››';

  @override
  String get profileChangePassword => '‹‹Change password››';

  @override
  String get profileCurrentPassword => '‹‹Current password››';

  @override
  String get profileNewPassword => '‹‹New password››';

  @override
  String get profileConfirmNewPassword => '‹‹Confirm new password››';

  @override
  String get profileUpdatePassword => '‹‹Update password››';

  @override
  String get profilePasswordAllFieldsRequired => '‹‹All fields are required››';

  @override
  String get profilePasswordMinLength =>
      '‹‹New password must be at least 8 characters››';

  @override
  String get profilePasswordMismatch => '‹‹Passwords do not match››';

  @override
  String get profilePasswordNotAuthenticated => '‹‹Not authenticated››';

  @override
  String get profilePasswordIncorrect => '‹‹Current password is incorrect››';

  @override
  String get profilePasswordGenericError =>
      '‹‹Something went wrong. Please try again.››';

  @override
  String get editProfileTitle => '‹‹Edit profile››';

  @override
  String get editProfileSchool => '‹‹School››';

  @override
  String get editProfileSchoolPublic => '‹‹School public››';

  @override
  String get editProfileGradePublic => '‹‹Grade public››';

  @override
  String get editProfileMajors => '‹‹Majors››';

  @override
  String get editProfileMajorsPublic => '‹‹Majors public››';

  @override
  String get editProfileBio => '‹‹Bio››';

  @override
  String get editProfileBioPublic => '‹‹Bio public››';

  @override
  String get editProfileStatus => '‹‹Status››';

  @override
  String get editProfileStatusPublic => '‹‹Status public››';

  @override
  String get classroomsYourClassrooms => '‹‹Your classrooms››';

  @override
  String get classroomsReorder => '‹‹Reorder classrooms››';

  @override
  String classroomsCount(Object count) {
    return '‹‹$count classrooms››';
  }

  @override
  String get classroomsSearchHint => '‹‹Search classrooms››';

  @override
  String get classroomsNoSearchMatches => '‹‹No classrooms match your search››';

  @override
  String get classroomsClassroomLabel => '‹‹Classroom››';

  @override
  String get classroomsLoadingLatestMessage => '‹‹Loading latest message...››';

  @override
  String get classroomsTapToOpen => '‹‹Tap to open classroom››';

  @override
  String get classroomsNoMessagesYet => '‹‹No messages yet››';

  @override
  String get classroomsMessageFallback => '‹‹Message››';

  @override
  String get examsLoadError => '‹‹Could not load exams or forms››';

  @override
  String get examsAllFilter => '‹‹All››';

  @override
  String get examsFormsSubtitle =>
      '‹‹Review classroom forms, response windows, and follow-ups published by your school.››';

  @override
  String get examsOnlySubtitle =>
      '‹‹Track upcoming assessments, countdowns, and past exam records from your classes.››';

  @override
  String get examsUpcomingStat => '‹‹Upcoming exams››';

  @override
  String get examsOpenFormsStat => '‹‹Open forms››';

  @override
  String get examsCountdownPast => '‹‹Past››';

  @override
  String get examsCountdownTomorrow => '‹‹Tomorrow››';

  @override
  String examsCountdownInDays(Object days) {
    return '‹‹In $days days››';
  }

  @override
  String get examsNoExamsPublished => '‹‹No exams have been published yet.››';

  @override
  String get examsNoFormsPublished => '‹‹No forms have been published yet.››';

  @override
  String examsNoExamsForFilter(Object subject) {
    return '‹‹No exams are available for $subject right now.››';
  }

  @override
  String examsNoFormsForFilter(Object subject) {
    return '‹‹No forms are available for $subject right now.››';
  }

  @override
  String examsMaterialsCount(Object count) {
    return '‹‹$count materials››';
  }

  @override
  String get examsOpenState => '‹‹Open››';

  @override
  String get examsClosedState => '‹‹Closed››';

  @override
  String examsQuestionsCount(Object count) {
    return '‹‹$count questions››';
  }

  @override
  String examsResponsesCount(Object count) {
    return '‹‹$count responses››';
  }

  @override
  String get insightsTrendBaseline => '‹‹Baseline››';

  @override
  String get insightsTrendImproving => '‹‹Improving››';

  @override
  String get insightsTrendDropping => '‹‹Dropping››';

  @override
  String get insightsTrendStable => '‹‹Stable››';

  @override
  String get insightsHeadlineIntervention => '‹‹Intervention window is open››';

  @override
  String get insightsHeadlineSignals => '‹‹Several signals need tightening››';

  @override
  String get insightsHeadlineMomentum => '‹‹Momentum can compound this week››';

  @override
  String get insightsBodyAttendance =>
      '‹‹Protect attendance first. Better presence now will raise every other signal faster.››';

  @override
  String insightsBodyWeakTrend(Object subject) {
    return '‹‹$subject plus a falling practice trend is the biggest risk combo right now. Fix that before expanding.››';
  }

  @override
  String insightsBodyLeverage(Object subject) {
    return '‹‹$subject is your leverage point. Use it to build confidence while you patch weaker areas.››';
  }

  @override
  String get insightsBodyConsistency =>
      '‹‹Keep stacking short focused sessions. The next few days matter more than a perfect long-term plan.››';

  @override
  String get insightsInterventionScoreTitle => '‹‹Intervention score››';

  @override
  String insightsInterventionScoreBody(Object count) {
    return '‹‹$count active signals are shaping your next move.››';
  }

  @override
  String get insightsRecoveryPathTitle => '‹‹Fastest recovery path››';

  @override
  String get insightsRecoveryPathDefault =>
      '‹‹Attendance + consistency first.››';

  @override
  String insightsRecoveryPathTopic(Object topic, Object subject) {
    return '‹‹Revisit $topic in $subject before pushing harder.››';
  }

  @override
  String get insightsProjectedDirectionTitle => '‹‹Projected direction››';

  @override
  String insightsProjectedDirectionBody(Object trend) {
    return '‹‹$trend based on recent 7d vs 30d practice behavior.››';
  }

  @override
  String get insightsLoadingTitle => '‹‹Insights loading››';

  @override
  String get insightsLoadingSubtitle =>
      '‹‹Building your predictive dashboard.››';

  @override
  String get insightsNotReadyTitle => '‹‹Insights are not ready yet››';

  @override
  String get insightsEmptyTitle => '‹‹No insights yet››';

  @override
  String get insightsEmptySubtitle =>
      '‹‹Keep using practice and your school tools so ClassMate can build a clearer academic picture.››';

  @override
  String get insightsGradeAverage => '‹‹Grade avg››';

  @override
  String get insightsAccuracy => '‹‹Accuracy››';

  @override
  String get insightsOpenNova => '‹‹Open NOVA››';

  @override
  String get insightsOpenNovaPrompt =>
      '‹‹Help me fix my weakest area based on my latest ClassMate insights.››';

  @override
  String get insightsPredictiveRecoveryPlanTitle =>
      '‹‹Predictive recovery plan››';

  @override
  String get insightsPracticeNow => '‹‹Practice now››';

  @override
  String get insightsPredictiveModulesTitle => '‹‹Predictive modules››';

  @override
  String get insightsPredictiveModulesSubtitle =>
      '‹‹The strongest forward-looking signals from your current student data.››';

  @override
  String get insightsAnnouncementsPressureTitle => '‹‹Announcements pressure››';

  @override
  String get insightsAnnouncementsPressureSubtitle =>
      '‹‹The announcement engine is now feeding the dashboard directly.››';

  @override
  String get insightsAiCoachTitle => '‹‹AI coach summary››';

  @override
  String get insightsAiCoachLoadingSubtitle => '‹‹Loading AI guidance.››';

  @override
  String get insightsAiCoachUnavailableSubtitle =>
      '‹‹AI guidance is unavailable for this account right now.››';

  @override
  String get insightsAskNova => '‹‹Ask NOVA››';

  @override
  String get insightsAskNovaPrompt =>
      '‹‹Build me a recovery plan from my latest insights.››';

  @override
  String get insightsAiStudyCoachTitle => '‹‹AI study coach››';

  @override
  String get insightsSchoolToolsTitle => '‹‹School tools››';

  @override
  String get insightsSchoolToolsSubtitle =>
      '‹‹Jump directly into the student routes that now matter most.››';

  @override
  String get tutorUntitledChat => '‹‹Untitled chat››';

  @override
  String get tutorNewChat => '‹‹New chat››';

  @override
  String tutorFailedToOpenSeededChat(Object error) {
    return '‹‹Failed to open chat: $error››';
  }

  @override
  String tutorFailedToCreateChat(Object error) {
    return '‹‹Failed to create chat: $error››';
  }

  @override
  String get tutorRenameChatTitle => '‹‹Rename chat››';

  @override
  String get tutorChatNameHint => '‹‹Chat name››';

  @override
  String get tutorCancel => '‹‹Cancel››';

  @override
  String get tutorHide => '‹‹Hide››';

  @override
  String get tutorHideChatTitle => '‹‹Hide chat››';

  @override
  String get tutorHideChatSubtitle => '‹‹Hides this chat on this device.››';

  @override
  String get tutorHideChatConfirmTitle => '‹‹Hide chat?››';

  @override
  String get tutorHideChatConfirmBody =>
      '‹‹This hides the chat from the list on this device. The session stays on the backend.››';

  @override
  String get tutorTapToOpenHistory => '‹‹Tap to open history››';

  @override
  String get tutorAiTutorSubtitle => '‹‹Your AI tutor››';

  @override
  String get tutorHeroBody =>
      '‹‹Real chat history, cleaner threads, faster access.››';

  @override
  String get tutorStartFreshConversation => '‹‹Start a fresh conversation››';

  @override
  String get tutorSearchHistoryHint => '‹‹Search chat history››';

  @override
  String get chatComposerDefaultHint => '‹‹Message››';

  @override
  String get chatComposerReplyingToMessage => '‹‹Replying to message››';

  @override
  String get chatComposerReplyFallback => '‹‹Reply››';

  @override
  String get chatComposerMicHint =>
      '‹‹Tap for a quick voice note or hold to record››';

  @override
  String get chatComposerRecordingTitle => '‹‹Recording››';

  @override
  String get chatComposerReleaseToSend => '‹‹Let go to send››';

  @override
  String get chatComposerCancelTitle => '‹‹Cancel››';

  @override
  String get chatComposerLockTitle => '‹‹Lock››';

  @override
  String get chatComposerSlideLeftToCancel => '‹‹Slide left to cancel››';

  @override
  String get chatComposerSlideUpToLock => '‹‹Slide up to lock››';

  @override
  String get chatComposerReleaseToCancel => '‹‹Release to cancel››';

  @override
  String get chatComposerKeepSlidingToCancel => '‹‹Keep sliding to cancel››';

  @override
  String get chatComposerReleaseToLock => '‹‹Release to lock››';

  @override
  String get chatComposerRelease => '‹‹Release››';

  @override
  String get chatComposerLock => '‹‹Lock››';

  @override
  String get chatComposerRecordingPaused => '‹‹Recording paused››';

  @override
  String get chatComposerRecordingLocked => '‹‹Recording locked››';

  @override
  String get chatComposerResumeHint =>
      '‹‹Resume when you are ready to keep recording››';

  @override
  String get chatComposerLockedHint =>
      '‹‹Tap send when you are ready to share››';

  @override
  String get chatContextDismiss => '‹‹Dismiss››';

  @override
  String get chatContextCopyText => '‹‹Copy text››';

  @override
  String get chatContextDelete => '‹‹Delete››';

  @override
  String get chatMessageInfoShortTitle => '‹‹Info››';

  @override
  String get chatMessageInfoStatus => '‹‹Status››';

  @override
  String get chatMessageInfoStatusTime => '‹‹Status time››';

  @override
  String get chatMessageInfoSentAt => '‹‹Sent at››';

  @override
  String get chatMessageInfoDeliveredAt => '‹‹Delivered at››';

  @override
  String get chatMessageInfoSeenAt => '‹‹Seen at››';

  @override
  String get chatMessageInfoMessageType => '‹‹Message type››';

  @override
  String get chatMessageInfoTextType => '‹‹Text››';

  @override
  String get chatMessageInfoEdited => '‹‹Edited››';

  @override
  String get chatMessageInfoForwarded => '‹‹Forwarded››';

  @override
  String get chatMessageInfoVoiceDuration => '‹‹Voice duration››';

  @override
  String get chatMessageInfoSeenBy => '‹‹Seen by››';

  @override
  String get chatMessageInfoDeliveredTo => '‹‹Delivered to››';

  @override
  String get chatMessageInfoEmptyBody => '‹‹(empty)››';

  @override
  String get chatMessageInfoReadLess => '‹‹Read less››';

  @override
  String get chatMessageInfoReadMore => '‹‹Read more››';

  @override
  String get chatMessageInfoSeen => '‹‹Seen››';

  @override
  String get chatMessageInfoDelivered => '‹‹Delivered››';

  @override
  String get chatMessageInfoNotDelivered => '‹‹Not delivered››';

  @override
  String get chatMessageInfoSent => '‹‹Sent››';

  @override
  String get chatMessageInfoPending => '‹‹Pending››';

  @override
  String get chatMessageInfoNotSeen => '‹‹Not seen››';

  @override
  String get chatMessageInfoType => '‹‹Type››';

  @override
  String get chatMessageInfoDuration => '‹‹Duration››';

  @override
  String get chatMessageInfoYes => '‹‹Yes››';

  @override
  String get chatMessageInfoNo => '‹‹No››';

  @override
  String get chatMessageInfoDeleteState => '‹‹Delete state››';

  @override
  String get chatReactionDetailsTitle => '‹‹Reactions››';

  @override
  String get chatReactionAddAction => '‹‹Add reaction››';

  @override
  String get chatReactionEmptyState => '‹‹No reactions yet››';

  @override
  String get chatReactionSingle => '‹‹Reaction››';

  @override
  String get chatReactionTapToRemove => '‹‹Tap to remove››';

  @override
  String chatReactionYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' · $count',
      one: '',
    );
    return '‹‹You$_temp0››';
  }

  @override
  String chatReactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reactions',
      one: 'Reaction',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get chatEmojiPickerTitle => '‹‹Choose emoji››';

  @override
  String get chatEmojiPickerSearchHint => '‹‹Search emoji››';

  @override
  String get chatEmojiPickerEmptyState => '‹‹No emoji found››';

  @override
  String get chatCameraTitle => '‹‹Camera››';

  @override
  String get chatCameraUseAction => '‹‹Use››';

  @override
  String get chatCameraGalleryAction => '‹‹Gallery››';

  @override
  String chatCameraSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
      zero: '0 selected',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get chatMediaPreviewEmptyState => '‹‹Nothing to preview››';

  @override
  String get chatMediaPreviewDrawCropAction => '‹‹Draw & Crop››';

  @override
  String get chatMediaPreviewRotateLeftAction => '‹‹Rotate left››';

  @override
  String get chatMediaPreviewRotateRightAction => '‹‹Rotate right››';

  @override
  String get chatMediaPreviewMirrorAction => '‹‹Mirror››';

  @override
  String get chatMediaPreviewResetAction => '‹‹Reset››';

  @override
  String get chatMediaPreviewRemoveAction => '‹‹Remove››';

  @override
  String get chatMediaPreviewCaptionHint => '‹‹Add a caption...››';

  @override
  String tutorPlanSelectedPlaceholder(Object plan) {
    return '‹‹$plan selected. Payments stay in placeholder mode for now.››';
  }

  @override
  String get tutorFailedToLoadChats => '‹‹Failed to load chats››';

  @override
  String get tutorNoChatsYet => '‹‹No chats yet››';

  @override
  String get tutorNoChatsMatchSearch => '‹‹No chats match your search››';

  @override
  String get tutorCreateFirstChat => '‹‹Create first chat››';

  @override
  String get tutorPlansTitle => '‹‹NOVA plans››';

  @override
  String tutorPlansSubtitle(Object model) {
    return '‹‹Based on $model cost assumptions and hard monthly caps so usage stays profitable.››';
  }

  @override
  String get tutorPlanPriceFree => '‹‹Free››';

  @override
  String tutorPlanPriceMonthly(Object price) {
    return '‹‹\$$price/mo››';
  }

  @override
  String get tutorPromptsLeft => '‹‹Prompts left››';

  @override
  String get tutorUploadsLeft => '‹‹Uploads left››';

  @override
  String get tutorVoiceLeft => '‹‹Voice left››';

  @override
  String tutorUsageValue(Object remaining, Object total) {
    return '‹‹$remaining/$total››';
  }

  @override
  String tutorVoiceUsageValue(Object remaining, Object total) {
    return '‹‹$remaining/$total min››';
  }

  @override
  String get tutorPaymentMethodsTitle => '‹‹Payment methods››';

  @override
  String tutorPaymentMethodsSubtitle(Object plan) {
    return '‹‹Checkout is placeholder-only until the ClassMate bank account and processor are live. The selected plan is $plan.››';
  }

  @override
  String get tutorCardCheckoutTitle => '‹‹Card checkout››';

  @override
  String get tutorCardCheckoutSubtitle =>
      '‹‹Visa, Mastercard, AmEx placeholder gateway.››';

  @override
  String get tutorApplePayTitle => '‹‹Apple Pay››';

  @override
  String get tutorApplePaySubtitle =>
      '‹‹Placeholder wallet flow for iPhone and web.››';

  @override
  String get tutorBankTransferTitle => '‹‹Bank transfer››';

  @override
  String get tutorBankTransferSubtitle =>
      '‹‹ClassMate bank account pending. Details will be filled once opened.››';

  @override
  String get tutorPlanStarterName => '‹‹Starter››';

  @override
  String get tutorPlanStarterTagline =>
      '‹‹Enough for trial and light weekly revision.››';

  @override
  String get tutorPlanPlusName => '‹‹Plus››';

  @override
  String get tutorPlanPlusTagline =>
      '‹‹Best for one serious student using NOVA most days.››';

  @override
  String get tutorPlanProName => '‹‹Pro››';

  @override
  String get tutorPlanProTagline =>
      '‹‹Heavy daily use, full exam season, and long study sessions.››';

  @override
  String get tutorPlanSchoolSeatName => '‹‹School Seat››';

  @override
  String get tutorPlanSchoolSeatTagline =>
      '‹‹For rollout per student or staff seat inside a real school.››';

  @override
  String tutorPlanBulletPromptsMonthly(Object count) {
    return '‹‹$count NOVA prompts each month››';
  }

  @override
  String tutorPlanBulletPromptsPerSeatMonthly(Object count) {
    return '‹‹$count NOVA prompts per seat monthly››';
  }

  @override
  String tutorPlanBulletUploads(Object count) {
    return '‹‹$count image or file uploads››';
  }

  @override
  String tutorPlanBulletVoiceMinutes(Object count) {
    return '‹‹$count voice transcription minutes››';
  }

  @override
  String tutorEstimatedCostCeilingFree(Object cost) {
    return '‹‹Estimated cost ceiling: \$$cost/mo››';
  }

  @override
  String tutorEstimatedCostCeilingPaid(Object cost, Object margin) {
    return '‹‹Estimated cost ceiling: \$$cost/mo • margin $margin%››';
  }

  @override
  String tutorTimeMinutesShort(Object count) {
    return '‹‹${count}m››';
  }

  @override
  String tutorTimeHoursShort(Object count) {
    return '‹‹${count}h››';
  }

  @override
  String get tutorVoiceMessageFallback => '‹‹Voice message››';

  @override
  String get tutorFileFallback => '‹‹File››';

  @override
  String get tutorCopy => '‹‹Copy››';

  @override
  String get tutorEditMessage => '‹‹Edit message››';

  @override
  String get tutorCopied => '‹‹Copied››';

  @override
  String get tutorLoadedIntoComposer => '‹‹Loaded into composer››';

  @override
  String get tutorTakePhoto => '‹‹Take photo››';

  @override
  String get tutorRecordVideo => '‹‹Record video››';

  @override
  String get tutorChooseFromGallery => '‹‹Choose from gallery››';

  @override
  String get tutorPreviewTitle => '‹‹Preview››';

  @override
  String get tutorThinking => '‹‹Thinking...››';

  @override
  String get tutorDone => '‹‹Done.››';

  @override
  String get tutorFailedToStreamReply => '‹‹Failed to stream reply››';

  @override
  String get tutorUnsupportedFilesMessage =>
      '‹‹NOVA supports images, documents, and text. Video and audio files are not supported here.››';

  @override
  String get tutorNoAudioCaptured => '‹‹No audio captured.››';

  @override
  String get tutorVoiceLimitReachedTitle => '‹‹Voice limit reached››';

  @override
  String get tutorVoiceLimitReachedMessage =>
      '‹‹Your current NOVA plan does not have enough voice minutes left for this transcription cycle.››';

  @override
  String get tutorTranscriptionFailed =>
      '‹‹Transcription failed. Please try again.››';

  @override
  String get tutorMicrophonePermissionRequired =>
      '‹‹Microphone permission is required.››';

  @override
  String get tutorPlanLimitReachedTitle => '‹‹NOVA plan limit reached››';

  @override
  String get tutorPlanLimitReachedMessage =>
      '‹‹This month\'s prompt or upload allowance is exhausted for your current NOVA plan. Pick a higher plan in the NOVA home screen to continue.››';

  @override
  String get tutorSendFailed => '‹‹Send failed.››';

  @override
  String tutorCurrentPlanUsageSummary(
    Object plan,
    Object prompts,
    Object uploads,
    Object voice,
  ) {
    return '‹‹Current plan: $plan • $prompts prompts left • $uploads uploads left • $voice voice minutes left››';
  }

  @override
  String get tutorReviewPlansInHome => '‹‹Review plans in NOVA home››';

  @override
  String get tutorCouldNotOpenAttachment => '‹‹Could not open attachment.››';

  @override
  String get tutorAttachmentUnavailable => '‹‹Attachment unavailable.››';

  @override
  String get tutorImageUnavailable => '‹‹Image unavailable››';

  @override
  String get tutorYou => '‹‹You››';

  @override
  String get tutorRegenerate => '‹‹Regenerate››';

  @override
  String get tutorEmptyStateTitle => '‹‹Start with a real question››';

  @override
  String get tutorEmptyStateBody =>
      '‹‹Ask NOVA to explain a concept, turn notes into a table, compare ideas, or help you revise from an uploaded file.››';

  @override
  String get tutorPromptSuggestionSummarizeNotes =>
      '‹‹Summarize my lesson notes››';

  @override
  String get tutorPromptSuggestionRevisionTable => '‹‹Make a revision table››';

  @override
  String get tutorPromptSuggestionQuizMe => '‹‹Quiz me on this topic››';

  @override
  String get tutorMessageNovaHint => '‹‹Message NOVA››';

  @override
  String get tutorHeaderSubtitleReady =>
      '‹‹Structured answers, tables, and study help››';

  @override
  String get tutorYourNovaPlanTitle => '‹‹Your NOVA plan››';

  @override
  String get tutorYourNovaPlanMessage =>
      '‹‹Review prompt, upload, and voice limits here, then jump back to NOVA home if you want to switch plans.››';

  @override
  String get tutorExplainTitle => '‹‹NOVA Explain››';

  @override
  String get classroomsThreadTypeClassroom => '‹‹Classroom››';

  @override
  String get classroomsThreadTypeGroup => '‹‹Group››';

  @override
  String get classroomsThreadTypeDirectMessage => '‹‹Direct message››';

  @override
  String get classroomsThreadTypeDirectMessageShort => '‹‹DM››';

  @override
  String get messagesBlockedPeopleTitle => '‹‹Blocked people››';

  @override
  String get messagesStartChatAction => '‹‹Start chat››';

  @override
  String messagesLoadFailed(Object error) {
    return '‹‹Failed to load messages: $error››';
  }

  @override
  String get messagesSearchHint => '‹‹Search messages››';

  @override
  String get messagesNoResults => '‹‹No messages found››';

  @override
  String get messagesRequestsSection => '‹‹Requests››';

  @override
  String get messagesPendingApprovals => '‹‹Pending approvals››';

  @override
  String get messagesChatsSection => '‹‹Chats››';

  @override
  String get messagesAllChatsSection => '‹‹All chats››';

  @override
  String messagesConversationCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conversations',
      one: '1 conversation',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get messagesRequestReviewStatus => '‹‹Review››';

  @override
  String messagesPeopleLoadFailed(Object error) {
    return '‹‹Failed to load people: $error››';
  }

  @override
  String get messagesSearchPeopleHint => '‹‹Search people››';

  @override
  String get messagesNewGroupTitle => '‹‹New group››';

  @override
  String get messagesNewGroupSubtitle => '‹‹Create a group chat››';

  @override
  String get messagesGroupNameHint => '‹‹Group name››';

  @override
  String get messagesCreateGroupAction => '‹‹Create group››';

  @override
  String get messagesGroupMinMembers =>
      '‹‹Select at least 2 people for a group››';

  @override
  String get messagesBlockedPersonFallback => '‹‹this person››';

  @override
  String get messagesUnblockPersonTitle => '‹‹Unblock person?››';

  @override
  String messagesUnblockPersonBody(Object name) {
    return '‹‹Allow $name to message you again?››';
  }

  @override
  String get messagesUnblockAction => '‹‹Unblock››';

  @override
  String messagesUnblockedToast(Object name) {
    return '‹‹$name unblocked››';
  }

  @override
  String messagesBlockedPeopleLoadFailed(Object error) {
    return '‹‹Failed to load blocked people: $error››';
  }

  @override
  String get messagesNoBlockedPeople => '‹‹No blocked people››';

  @override
  String get messagesUnknownUser => '‹‹Unknown user››';

  @override
  String get messagesRequestTitle => '‹‹Request››';

  @override
  String messagesRequestLoadFailed(Object error) {
    return '‹‹Failed to load request: $error››';
  }

  @override
  String get messagesRequestBannerIncoming => '‹‹Message request››';

  @override
  String get messagesRequestBannerOutgoing => '‹‹Pending approval››';

  @override
  String get messagesBlockAction => '‹‹Block››';

  @override
  String get messagesApproveAction => '‹‹Approve››';

  @override
  String get messagesRequestUnlockHint =>
      '‹‹The chat unlocks after the receiver approves your first message.››';

  @override
  String get messagesThreadConversationFallback => '‹‹Conversation››';

  @override
  String get messagesThreadLeaveGroupTitle => '‹‹Leave group?››';

  @override
  String get messagesThreadLeaveGroupBody =>
      '‹‹You will stop receiving messages from this group.››';

  @override
  String get messagesThreadBlockPersonTitle => '‹‹Block person?››';

  @override
  String get messagesThreadBlockPersonBody =>
      '‹‹You will no longer be able to exchange messages with this person.››';

  @override
  String get messagesThreadPersonFallback => '‹‹Person››';

  @override
  String get messagesThreadProfileInfoUnavailable =>
      '‹‹Profile info unavailable››';

  @override
  String get messagesThreadParticipants => '‹‹Participants››';

  @override
  String get messagesThreadPeople => '‹‹People››';

  @override
  String get messagesThreadDeleteForMe => '‹‹Delete for me››';

  @override
  String get messagesThreadDeleteForEveryone => '‹‹Delete for everyone››';

  @override
  String get messagesThreadDeleteForEveryoneSubtitle =>
      '‹‹Removes for all participants››';

  @override
  String get messagesThreadSending => '‹‹Sending…››';

  @override
  String get messagesThreadWaitingForApproval => '‹‹Waiting for approval››';

  @override
  String get classroomsForwardSearchHint => '‹‹Search chats››';

  @override
  String get classroomsForwardNewChat => '‹‹New chat››';

  @override
  String classroomsForwardLoadError(Object error) {
    return '‹‹Failed to load chats: $error››';
  }

  @override
  String get classroomsForwardNoChatsFound => '‹‹No chats found››';

  @override
  String get classroomsForwardSectionClassrooms => '‹‹Classrooms››';

  @override
  String get classroomsForwardSectionDirectMessages => '‹‹Direct messages››';

  @override
  String get classroomsForwardCancel => '‹‹Cancel››';

  @override
  String get classroomsForwardAction => '‹‹Forward››';

  @override
  String classroomsForwardCount(Object count) {
    return '‹‹Forward ($count)››';
  }

  @override
  String get markRead => '‹‹Mark read››';

  @override
  String get markUnread => '‹‹Mark unread››';

  @override
  String get markAllRead => '‹‹Mark all read››';

  @override
  String get filters => '‹‹Filters››';

  @override
  String get source => '‹‹Source››';

  @override
  String get state => '‹‹State››';

  @override
  String get allSources => '‹‹All sources››';

  @override
  String get allStates => '‹‹All states››';

  @override
  String get unread => '‹‹Unread››';

  @override
  String get read => '‹‹Read››';

  @override
  String get clear => '‹‹Clear››';

  @override
  String get today => '‹‹Today››';

  @override
  String get yesterday => '‹‹Yesterday››';

  @override
  String get thisWeek => '‹‹This week››';

  @override
  String get earlier => '‹‹Earlier››';

  @override
  String get openDetails => '‹‹Open details››';

  @override
  String get total => '‹‹Total››';

  @override
  String get local => '‹‹Local››';

  @override
  String get server => '‹‹Server››';

  @override
  String get notificationsSourceSystem => '‹‹System››';

  @override
  String get notificationsHeroSubtitleStudent =>
      '‹‹Your notification hub for announcements, server updates, and useful academic activity as it happens.››';

  @override
  String get notificationsHeroSubtitleTeacher =>
      '‹‹Your teacher notification hub for announcements, server updates, and school activity as it happens.››';

  @override
  String get notificationsFiltersSubtitle =>
      '‹‹Focus by source or read state to triage fast.››';

  @override
  String get notificationsSearchSourcesHint => '‹‹Search sources››';

  @override
  String notificationsShowingSummary(Object shown, Object total) {
    return '‹‹Showing $shown of $total notifications.››';
  }

  @override
  String get notificationsEmptyForAccount =>
      '‹‹No notifications are available for this account right now.››';

  @override
  String get notificationsEmptyFiltered =>
      '‹‹No notifications match these filters right now. Clear filters to see the full feed.››';

  @override
  String get notificationsEmpty =>
      '‹‹No notifications are available right now.››';

  @override
  String get notificationsNewBadge => '‹‹New››';

  @override
  String get notificationsUnavailable =>
      '‹‹This notification is no longer available. Pull to refresh the inbox and try again.››';

  @override
  String get notificationsSeverityCritical => '‹‹Critical››';

  @override
  String get notificationsSeverityWarning => '‹‹Warning››';

  @override
  String get notificationsSeverityInfo => '‹‹Info››';

  @override
  String get announcementsLoadError =>
      '‹‹We could not load announcements right now. Pull to refresh or try again.››';

  @override
  String get announcementsLoadTimeout =>
      '‹‹Announcements are taking too long to load. Pull to refresh or try again in a moment.››';

  @override
  String get announcementsLoadNetwork =>
      '‹‹Announcements could not connect right now. Check your connection and try again.››';

  @override
  String get teacherDeleteClassroom => '‹‹Delete classroom››';

  @override
  String get teacherDeleteClassroomConfirm =>
      '‹‹This permanently deletes the classroom and all its chat, assignments, materials, meetings and member list. This cannot be undone.››';

  @override
  String get teacherClassroomDeleted => '‹‹Classroom deleted››';

  @override
  String get announcementsTabReceived => '‹‹Received››';

  @override
  String get announcementsTabPublished => '‹‹Published››';

  @override
  String get announcementsAudienceTeacher => '‹‹teacher››';

  @override
  String get announcementsAudienceAccount => '‹‹account››';

  @override
  String get announcementsAudienceTeacherWorkspace => '‹‹teacher workspace››';

  @override
  String get announcementsLoadFailedTitle => '‹‹Could not load announcements››';

  @override
  String get announcementsLoadFailedHint =>
      '‹‹Pull to refresh after the connection is stable.››';

  @override
  String announcementsHeroSubtitle(Object audience) {
    return '‹‹Published school, teacher, and system announcements available to this $audience.››';
  }

  @override
  String get announcementsLatestSourceLabel => '‹‹Latest source››';

  @override
  String get announcementsNone => '‹‹None››';

  @override
  String announcementsUnreadCountTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread announcements',
      one: '1 unread announcement',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get announcementsAllReadTitle => '‹‹Everything is read››';

  @override
  String announcementsEmptyForAudience(Object audience) {
    return '‹‹No announcements have been published to this $audience yet.››';
  }

  @override
  String announcementsLatestBody(Object title) {
    return '‹‹Latest: $title. Tap it to read the full content.››';
  }

  @override
  String get announcementsFiltersSubtitle =>
      '‹‹Narrow the inbox by source or by read state so you can focus on what still needs attention.››';

  @override
  String get announcementsAllAnnouncements => '‹‹All announcements››';

  @override
  String get announcementsSearchStatesHint => '‹‹Unread / Read››';

  @override
  String announcementsSummarySourceSegment(Object source) {
    return '‹‹ from $source››';
  }

  @override
  String announcementsSummaryStateSegment(Object state) {
    return '‹‹ in $state››';
  }

  @override
  String announcementsShowingSummary(
    Object shown,
    Object total,
    Object sourceSegment,
    Object stateSegment,
  ) {
    return '‹‹Showing $shown of $total announcements$sourceSegment$stateSegment.››';
  }

  @override
  String get announcementsNoMatchTitle =>
      '‹‹No announcements match these filters››';

  @override
  String get announcementsNoPublishedTitle =>
      '‹‹No published announcements yet››';

  @override
  String get announcementsNoMatchSubtitle =>
      '‹‹Try a different source or switch back to all announcements to bring more items into view.››';

  @override
  String get announcementsClearFiltersHint =>
      '‹‹Clear filters to see everything again.››';

  @override
  String get announcementsPullToRefreshHint =>
      '‹‹Pull to refresh after new school activity is published.››';

  @override
  String get announcementsInboxTitle => '‹‹Inbox››';

  @override
  String get announcementsInboxSubtitle =>
      '‹‹Only titles appear here for quick scanning. Tap any item to open the full announcement content.››';

  @override
  String get meetingsLoadError =>
      '‹‹We could not load meetings right now. Pull to refresh or try again.››';

  @override
  String get meetingsLoadTimeout =>
      '‹‹Meetings are taking too long to load. Pull to refresh or try again in a moment.››';

  @override
  String get meetingsLoadNetwork =>
      '‹‹Meetings could not connect right now. Check your connection and try again.››';

  @override
  String get meetingsHeroSubtitle =>
      '‹‹Every classroom meeting in one clean view, with attached links and a full-screen detail page when you need the context.››';

  @override
  String get meetingsJoinReadyMetric => '‹‹Join-ready››';

  @override
  String get meetingsNoLinkMetric => '‹‹No link››';

  @override
  String get meetingsNoPostedTitle => '‹‹No meetings posted yet››';

  @override
  String get meetingsEmptyForAccount =>
      '‹‹No meetings are scheduled for you right now. Pull down to check again.››';

  @override
  String meetingsLatestBody(Object title, Object updatedAt) {
    return '‹‹$title was updated $updatedAt. Open it for the attached link and classroom context.››';
  }

  @override
  String get meetingsPullToRefreshHint => '‹‹Pull down to check again.››';

  @override
  String get meetingsFiltersSubtitle =>
      '‹‹Narrow the list by subject or by whether the meeting already includes a link you can open.››';

  @override
  String get meetingsAccessLabel => '‹‹Access››';

  @override
  String get meetingsAllMeetings => '‹‹All meetings››';

  @override
  String get meetingsAccessReady => '‹‹Ready to join››';

  @override
  String get meetingsAccessNoLink => '‹‹No link››';

  @override
  String get meetingsAccessNoLinkYet => '‹‹No link yet››';

  @override
  String get meetingsAccessSearchHint => '‹‹Ready to join / No link yet››';

  @override
  String meetingsSummarySubjectSegment(Object subject) {
    return '‹‹ for $subject››';
  }

  @override
  String meetingsSummaryAccessSegment(Object state) {
    return '‹‹ in $state››';
  }

  @override
  String meetingsShowingSummary(
    Object shown,
    Object total,
    Object subjectSegment,
    Object accessSegment,
  ) {
    return '‹‹Showing $shown of $total meetings$subjectSegment$accessSegment.››';
  }

  @override
  String get meetingsNoMatchTitle => '‹‹No meetings match these filters››';

  @override
  String get meetingsNoMatchSubtitle =>
      '‹‹Try all subjects or include meetings without links to bring more results back into the list.››';

  @override
  String get meetingsListSubtitle =>
      '‹‹Tap any meeting to open the full-screen detail view and jump into its attached link when available.››';

  @override
  String meetingsDateTimeValue(Object date, Object time) {
    return '‹‹$date • $time››';
  }

  @override
  String meetingsSharedByValue(Object name) {
    return '‹‹Shared by $name››';
  }

  @override
  String get meetingsPreviewFallback =>
      '‹‹Open this meeting to see the attached link and the latest classroom details.››';

  @override
  String get meetingsNoValidLinkAttached =>
      '‹‹No valid meeting link is attached yet.››';

  @override
  String get meetingsCouldNotOpenLink => '‹‹Could not open the meeting link.››';

  @override
  String get meetingsNoLinkToCopy => '‹‹No meeting link to copy yet.››';

  @override
  String get meetingsLinkCopied => '‹‹Meeting link copied.››';

  @override
  String get meetingsUnavailableTitle => '‹‹Meeting unavailable››';

  @override
  String get meetingsUnavailableSubtitle =>
      '‹‹This meeting could not be found in the current feed. It may have been removed or is not available offline.››';

  @override
  String get meetingsUnavailableHint =>
      '‹‹Go back and refresh the meetings list.››';

  @override
  String get meetingsNoLinkAttachedYet => '‹‹No link attached yet››';

  @override
  String get meetingsAttachedLinkTitle => '‹‹Attached meeting link››';

  @override
  String get meetingsAttachedLinkMissingBody =>
      '‹‹This meeting is visible in your classroom feed, but no valid URL is attached in the current student payload.››';

  @override
  String get meetingsDetailsTitle => '‹‹Meeting details››';

  @override
  String get meetingsDetailsSubtitle =>
      '‹‹Everything student-relevant that is currently available in the classroom meeting payload.››';

  @override
  String get meetingsDetailClassroomLabel => '‹‹Classroom››';

  @override
  String get meetingsSharedByLabel => '‹‹Shared by››';

  @override
  String get meetingsIdLabel => '‹‹Meeting ID››';

  @override
  String get meetingsAttachedLinkSubtitle =>
      '‹‹Use the attached URL to join or copy the meeting link when your classroom provides one.››';

  @override
  String get meetingsOpening => '‹‹Opening››';

  @override
  String get meetingsOpenLink => '‹‹Open link››';

  @override
  String get meetingsCopyLink => '‹‹Copy link››';

  @override
  String get meetingsAccessPanelTitle => '‹‹Meeting access››';

  @override
  String get meetingsAccessPanelReadyBody =>
      '‹‹Open the attached URL in your browser or meeting app.››';

  @override
  String get meetingsEndedNote => 'This meeting has already taken place.';

  @override
  String get meetingsJoinAction => '‹‹Join››';

  @override
  String get announcementsDetailLoadFailedHint =>
      '‹‹Go back and try refreshing the announcements inbox.››';

  @override
  String get announcementsUnavailableTitle => '‹‹Announcement unavailable››';

  @override
  String announcementsUnavailableSubtitle(Object audience) {
    return '‹‹This announcement is no longer available in the published feed for this $audience.››';
  }

  @override
  String get announcementsUnavailableHint =>
      '‹‹Go back to the inbox to continue.››';

  @override
  String announcementsPublishedReadStateBody(Object audience) {
    return '‹‹This announcement was published to this $audience and your read state is stored locally on this device.››';
  }

  @override
  String get announcementsDetailsTitle => '‹‹Announcement details››';

  @override
  String get announcementsDetailsSubtitle =>
      '‹‹Published metadata for this announcement and its current read state.››';

  @override
  String get announcementsSeverityLabel => '‹‹Severity››';

  @override
  String get announcementsCreatedLabel => '‹‹Created››';

  @override
  String get announcementsIdLabel => '‹‹Announcement ID››';

  @override
  String get announcementsFullContentTitle => '‹‹Full content››';

  @override
  String get announcementsFullContentSubtitle =>
      '‹‹The complete announcement text appears here after you open the item from the inbox.››';

  @override
  String get announcementsReadStateTitle => '‹‹Read state››';

  @override
  String get announcementsReadStateBodyRead =>
      '‹‹This announcement is marked as read on this device.››';

  @override
  String get announcementsReadStateBodyUnread =>
      '‹‹This announcement is still unread on this device.››';

  @override
  String get alertsTitle => '‹‹Alerts››';

  @override
  String get alertsSubtitle =>
      '‹‹This is the page for things that need attention now, not just general updates.››';

  @override
  String get alertsAttendanceTitle => '‹‹Attendance needs attention››';

  @override
  String alertsAttendanceBody(Object rate) {
    return '‹‹Your attendance rate is $rate%. A couple of missed lessons can snowball fast.››';
  }

  @override
  String get alertsWeakestSubjectTitle => '‹‹Weakest subject signal››';

  @override
  String alertsWeakestSubjectBody(Object subject) {
    return '‹‹$subject currently needs the most attention based on your latest grades.››';
  }

  @override
  String get alertsPracticeWeakAreaTitle => '‹‹Practice weak area››';

  @override
  String alertsPracticeWeakAreaBody(Object topic, Object subject) {
    return '‹‹$topic in $subject is the clearest weak topic right now.››';
  }

  @override
  String get alertsPracticeTrendDroppedTitle => '‹‹Practice trend dropped››';

  @override
  String get alertsPracticeTrendDroppedBody =>
      '‹‹Your 7d performance is below your 30d baseline. Slow down and revisit fundamentals before pushing harder.››';

  @override
  String get alertsEmpty =>
      '‹‹You\'re clear right now. When something needs urgent attention, it\'ll show up here.››';

  @override
  String get student => '‹‹Student››';

  @override
  String get classroomDetailPhoto => '‹‹Photo››';

  @override
  String get classroomDetailVoiceNote => '‹‹Voice note››';

  @override
  String get classroomDetailVideo => '‹‹Video››';

  @override
  String get classroomDetailFile => '‹‹File››';

  @override
  String get classroomDetailEmptyValue => '‹‹(empty)››';

  @override
  String get classroomDetailAttachmentUnavailable =>
      '‹‹Attachment unavailable.››';

  @override
  String get classroomDetailAudioUnavailable => '‹‹Audio unavailable.››';

  @override
  String get classroomDetailCouldNotOpenAttachment =>
      '‹‹Could not open attachment.››';

  @override
  String get classroomDetailVoiceMessage => '‹‹Voice message››';

  @override
  String get classroomDetailVideoFile => '‹‹Video file››';

  @override
  String get classroomDetailAttachedFile => '‹‹Attached file››';

  @override
  String get classroomDetailAttachment => '‹‹Attachment››';

  @override
  String get classroomDetailPinAction => '‹‹Pin››';

  @override
  String get classroomDetailUnpinAction => '‹‹Unpin››';

  @override
  String get classroomDetailMessageInfoTitle => '‹‹Message info››';

  @override
  String get classroomDetailForwardedSingle => '‹‹Forwarded››';

  @override
  String classroomDetailForwardedMultiple(Object count) {
    return '‹‹Forwarded $count messages››';
  }

  @override
  String get classroomDetailCannotForwardPending =>
      '‹‹Cannot forward into a request chat until it is approved››';

  @override
  String get classroomDetailCouldNotForwardSelected =>
      '‹‹Could not forward selected messages››';

  @override
  String classroomDetailSelectedCount(Object count) {
    return '‹‹$count selected››';
  }

  @override
  String classroomDetailDeleteCount(Object count) {
    return '‹‹Delete ($count)››';
  }

  @override
  String get classroomDetailSelectAllTooltip => '‹‹Select all››';

  @override
  String get classroomDetailCancelTooltip => '‹‹Cancel››';

  @override
  String get classroomDetailMicrophoneAccessTitle =>
      '‹‹Microphone access needed››';

  @override
  String get classroomDetailMicrophoneAccessBody =>
      '‹‹Please allow microphone access in Settings -> ClassMate to send voice notes.››';

  @override
  String get classroomDetailOpenSettingsAction => '‹‹Open Settings››';

  @override
  String classroomDetailForwardTargetNext(Object label) {
    return '‹‹Forward target picker next: $label››';
  }

  @override
  String get classroomDetailEditMessageTitle => '‹‹Edit message››';

  @override
  String get classroomDetailEditMessageHint => '‹‹Edit your message...››';

  @override
  String get classroomDetailLeaveClassroomTitle => '‹‹Leave classroom?››';

  @override
  String get classroomDetailLeaveClassroomBody =>
      '‹‹You will be removed from this classroom.››';

  @override
  String get classroomDetailLeaveAction => '‹‹Leave››';

  @override
  String get classroomDetailNoAssignmentsTitle => '‹‹No assignments yet››';

  @override
  String get classroomDetailNoAssignmentsSubtitle =>
      '‹‹This classroom has no assignments right now.››';

  @override
  String get classroomDetailAssignmentFallback => '‹‹Assignment››';

  @override
  String get classroomDetailNoMaterialsTitle => '‹‹No materials yet››';

  @override
  String get classroomDetailNoMaterialsSubtitle =>
      '‹‹This classroom has no materials right now.››';

  @override
  String get classroomDetailMaterialFallback => '‹‹Material››';

  @override
  String get classroomDetailNoMeetingsTitle => '‹‹No meetings yet››';

  @override
  String get classroomDetailNoMeetingsSubtitle =>
      '‹‹This classroom has no meetings right now.››';

  @override
  String get classroomDetailMeetingFallback => '‹‹Meeting››';

  @override
  String get classroomDetailCouldNotLoadPeople => '‹‹Could not load people››';

  @override
  String get classroomDetailNoPeopleTitle => '‹‹No people yet››';

  @override
  String get classroomDetailNoPeopleSubtitle =>
      '‹‹Nobody is visible in this classroom yet.››';

  @override
  String get classroomDetailTabChat => '‹‹Chat››';

  @override
  String get classroomDetailTabMaterials => '‹‹Materials››';

  @override
  String get classroomDetailTabPeople => '‹‹People››';

  @override
  String get classroomChatMediaSendPhoto => '‹‹Send photo››';

  @override
  String get classroomChatMediaSendPhotoSubtitle =>
      '‹‹Share an image in the classroom chat››';

  @override
  String get classroomChatMediaSendVoiceMessage => '‹‹Send voice message››';

  @override
  String get classroomChatMediaSendVoiceMessageSubtitle =>
      '‹‹Record and send a voice note››';

  @override
  String get classroomDetailCouldNotLoadTab => '‹‹Could not load tab››';

  @override
  String get classroomDetailDeletedByYou => '‹‹You deleted this message››';

  @override
  String get classroomDetailDeletedMessage => '‹‹This message was deleted››';

  @override
  String get practiceSetupDifficultyEasy => '‹‹Easy››';

  @override
  String get practiceSetupDifficultyMedium => '‹‹Medium››';

  @override
  String get practiceSetupDifficultyHard => '‹‹Hard››';

  @override
  String get practiceSetupDifficultyOlympiad => '‹‹Olympiad››';

  @override
  String get practiceSetupDifficultyAdaptive => '‹‹Adaptive››';

  @override
  String get practiceSetupModeLabelPractice => '‹‹Practice››';

  @override
  String get practiceSetupModeLabelFlashcards => '‹‹Flashcards››';

  @override
  String get practiceSetupModeLabelSpeedRound => '‹‹Speed round››';

  @override
  String get practiceSetupModeLabelExamPrep => '‹‹Exam prep››';

  @override
  String get practiceSetupModeLabelConceptBuilder => '‹‹Concept builder››';

  @override
  String get practiceSetupModeLabelAdaptive => '‹‹Adaptive››';

  @override
  String get practiceSetupModeLabelBagrut => '‹‹Bagrut››';

  @override
  String get practiceSetupModeSubtitlePractice => '‹‹Balanced daily practice››';

  @override
  String get practiceSetupModeSubtitleFlashcards =>
      '‹‹Reveal and self-recall››';

  @override
  String get practiceSetupModeSubtitleSpeedRound => '‹‹Fast pressure drill››';

  @override
  String get practiceSetupModeSubtitleExamPrep => '‹‹Calm exam-style flow››';

  @override
  String get practiceSetupModeSubtitleConceptBuilder =>
      '‹‹Concept first, solve later››';

  @override
  String get practiceSetupModeSubtitleAdaptive => '‹‹Difficulty shifts live››';

  @override
  String get practiceSetupModeSubtitleBagrut => '‹‹Strict official style››';

  @override
  String get practiceSetupModeHelpPractice =>
      '‹‹Balanced mode: solve, check, explain, then keep moving.››';

  @override
  String get practiceSetupModeHelpFlashcards =>
      '‹‹Flashcards work best when you try to recall before revealing.››';

  @override
  String get practiceSetupModeHelpSpeedRound =>
      '‹‹Speed Round trains fast recall. Move quickly and trust strong instincts.››';

  @override
  String get practiceSetupModeHelpExamPrep =>
      '‹‹Exam Prep is calmer and more formal, like a real school session.››';

  @override
  String get practiceSetupModeHelpConceptBuilder =>
      '‹‹Concept Builder teaches the idea first, then asks you to apply it.››';

  @override
  String get practiceSetupModeHelpAdaptive =>
      '‹‹Adaptive mode changes the challenge level based on your performance.››';

  @override
  String get practiceSetupModeHelpBagrut =>
      '‹‹Bagrut mode focuses on strict exam-style solving and review.››';

  @override
  String get practiceSetupModeInfoTitle => '‹‹How each mode works››';

  @override
  String get practiceSetupHeroTitle => '‹‹Start a session››';

  @override
  String get practiceSetupHeroSubtitle =>
      '‹‹Choose a mode, timing, and difficulty.››';

  @override
  String get practiceSetupInfiniteLives => '‹‹Infinite lives››';

  @override
  String practiceSetupLivesCount(Object count) {
    return '‹‹$count lives››';
  }

  @override
  String get practiceSetupAiTiming => '‹‹AI timing››';

  @override
  String practiceSetupSecondsShort(Object seconds) {
    return '‹‹${seconds}s››';
  }

  @override
  String practiceSetupQuestionsCount(Object count) {
    return '‹‹$count questions››';
  }

  @override
  String practiceSetupSummarySubject(Object subject) {
    return '‹‹Subject: $subject››';
  }

  @override
  String practiceSetupSummaryTopic(Object topic) {
    return '‹‹Topic: $topic››';
  }

  @override
  String practiceSetupSummaryMode(Object mode) {
    return '‹‹Mode: $mode››';
  }

  @override
  String practiceSetupSummaryDifficulty(Object difficulty) {
    return '‹‹Difficulty: $difficulty››';
  }

  @override
  String practiceSetupSummaryQuestions(Object count) {
    return '‹‹Questions: $count››';
  }

  @override
  String practiceSetupSummaryTiming(Object timing) {
    return '‹‹Timing: $timing››';
  }

  @override
  String practiceSetupSummaryLives(Object lives) {
    return '‹‹Lives: $lives››';
  }

  @override
  String get practiceSetupSectionSubjectTopic => '‹‹Subject & topic››';

  @override
  String get practiceSetupFieldSubject => '‹‹Subject››';

  @override
  String get practiceSetupFieldSubjectHint => '‹‹Pick the subject››';

  @override
  String get practiceSetupChooseSubject => '‹‹Choose subject››';

  @override
  String get practiceSetupFieldCustomSubject => '‹‹Custom subject››';

  @override
  String get practiceSetupFieldCustomSubjectHint => '‹‹Type your own subject››';

  @override
  String get practiceSetupDialogCustomSubjectTitle => '‹‹Custom subject››';

  @override
  String get practiceSetupDialogEnterSubject => '‹‹Enter subject››';

  @override
  String get practiceSetupUseAction => '‹‹Use››';

  @override
  String get practiceSetupFieldTopic => '‹‹Topic››';

  @override
  String get practiceSetupFieldTopicHint => '‹‹Pick sub-topic››';

  @override
  String get practiceSetupChooseTopic => '‹‹Choose topic››';

  @override
  String get practiceSetupFieldCustomTopic => '‹‹Custom topic››';

  @override
  String get practiceSetupFieldCustomTopicHint => '‹‹Type your own topic››';

  @override
  String get practiceSetupDialogCustomTopicTitle => '‹‹Custom topic››';

  @override
  String get practiceSetupDialogEnterTopic => '‹‹Enter topic››';

  @override
  String get practiceSubjectMath => '‹‹Math››';

  @override
  String get practiceSubjectPhysics => '‹‹Physics››';

  @override
  String get practiceSubjectComputerScience => '‹‹Computer Science››';

  @override
  String get practiceSubjectChemistry => '‹‹Chemistry››';

  @override
  String get practiceSubjectBiology => '‹‹Biology››';

  @override
  String get practiceSubjectEnglish => '‹‹English››';

  @override
  String get practiceSubjectArabic => '‹‹Arabic››';

  @override
  String get practiceSubjectHebrew => '‹‹Hebrew››';

  @override
  String get practiceSubjectGeneralKnowledge => '‹‹General Knowledge››';

  @override
  String get practiceTopicAllTopics => '‹‹All topics››';

  @override
  String get practiceTopicAlgebra => '‹‹Algebra››';

  @override
  String get practiceTopicLinearEquations => '‹‹Linear equations››';

  @override
  String get practiceTopicQuadraticEquations => '‹‹Quadratic equations››';

  @override
  String get practiceTopicFunctions => '‹‹Functions››';

  @override
  String get practiceTopicGeometry => '‹‹Geometry››';

  @override
  String get practiceTopicTriangles => '‹‹Triangles››';

  @override
  String get practiceTopicCircles => '‹‹Circles››';

  @override
  String get practiceTopicAnalyticGeometry => '‹‹Analytic geometry››';

  @override
  String get practiceTopicTrigonometry => '‹‹Trigonometry››';

  @override
  String get practiceTopicProbability => '‹‹Probability››';

  @override
  String get practiceTopicStatistics => '‹‹Statistics››';

  @override
  String get practiceTopicSequences => '‹‹Sequences››';

  @override
  String get practiceTopicCalculus => '‹‹Calculus››';

  @override
  String get practiceTopicLimits => '‹‹Limits››';

  @override
  String get practiceTopicDerivatives => '‹‹Derivatives››';

  @override
  String get practiceTopicMechanics => '‹‹Mechanics››';

  @override
  String get practiceTopicKinematics => '‹‹Kinematics››';

  @override
  String get practiceTopicNewtonLaws => '‹‹Newton laws››';

  @override
  String get practiceTopicForces => '‹‹Forces››';

  @override
  String get practiceTopicEnergy => '‹‹Energy››';

  @override
  String get practiceTopicMomentum => '‹‹Momentum››';

  @override
  String get practiceTopicElectricity => '‹‹Electricity››';

  @override
  String get practiceTopicElectricField => '‹‹Electric field››';

  @override
  String get practiceTopicCircuits => '‹‹Circuits››';

  @override
  String get practiceTopicWaves => '‹‹Waves››';

  @override
  String get practiceTopicOptics => '‹‹Optics››';

  @override
  String get practiceTopicThermodynamics => '‹‹Thermodynamics››';

  @override
  String get practiceTopicConditions => '‹‹Conditions››';

  @override
  String get practiceTopicBooleanLogic => '‹‹Boolean logic››';

  @override
  String get practiceTopicIfElse => '‹‹If / Else››';

  @override
  String get practiceTopicNestedConditions => '‹‹Nested conditions››';

  @override
  String get practiceTopicLoops => '‹‹Loops››';

  @override
  String get practiceTopicVariables => '‹‹Variables››';

  @override
  String get practiceTopicArrays => '‹‹Arrays››';

  @override
  String get practiceTopicStrings => '‹‹Strings››';

  @override
  String get practiceTopicAlgorithms => '‹‹Algorithms››';

  @override
  String get practiceTopicComplexity => '‹‹Complexity››';

  @override
  String get practiceTopicRecursion => '‹‹Recursion››';

  @override
  String get practiceTopicAtoms => '‹‹Atoms››';

  @override
  String get practiceTopicPeriodicTable => '‹‹Periodic table››';

  @override
  String get practiceTopicChemicalBonds => '‹‹Chemical bonds››';

  @override
  String get practiceTopicReactions => '‹‹Reactions››';

  @override
  String get practiceTopicStoichiometry => '‹‹Stoichiometry››';

  @override
  String get practiceTopicAcidsAndBases => '‹‹Acids and bases››';

  @override
  String get practiceTopicOrganicChemistry => '‹‹Organic chemistry››';

  @override
  String get practiceTopicCells => '‹‹Cells››';

  @override
  String get practiceTopicGenetics => '‹‹Genetics››';

  @override
  String get practiceTopicHumanBody => '‹‹Human body››';

  @override
  String get practiceTopicEcology => '‹‹Ecology››';

  @override
  String get practiceTopicEvolution => '‹‹Evolution››';

  @override
  String get practiceTopicSystems => '‹‹Systems››';

  @override
  String get practiceTopicGrammar => '‹‹Grammar››';

  @override
  String get practiceTopicReadingComprehension => '‹‹Reading comprehension››';

  @override
  String get practiceTopicVocabulary => '‹‹Vocabulary››';

  @override
  String get practiceTopicTenses => '‹‹Tenses››';

  @override
  String get practiceTopicWriting => '‹‹Writing››';

  @override
  String get practiceTopicRhetoric => '‹‹Rhetoric››';

  @override
  String get practiceSetupSectionMode => '‹‹Mode››';

  @override
  String get practiceSetupSectionDifficulty => '‹‹Difficulty››';

  @override
  String get practiceSetupSectionControls => '‹‹Session controls››';

  @override
  String get practiceSetupQuestionsTitle => '‹‹Questions››';

  @override
  String get practiceSetupQuestionsCaption =>
      '‹‹How many generated questions to include››';

  @override
  String get practiceSetupTimingTitle => '‹‹Timing››';

  @override
  String get practiceSetupTimingCaption =>
      '‹‹Choose scope first, then AI, your own time, or infinite.››';

  @override
  String get practiceSetupTimingScopePerQuestion => '‹‹Per question››';

  @override
  String get practiceSetupTimingScopeWholeQuiz => '‹‹Whole quiz››';

  @override
  String get practiceSetupTimingModeAi => '‹‹AI››';

  @override
  String get practiceSetupTimingModeMyTime => '‹‹My time››';

  @override
  String get practiceSetupTimingModeInfinite => '‹‹Infinite››';

  @override
  String get practiceSetupTimingCustomPerQuestionTitle =>
      '‹‹Seconds per question››';

  @override
  String get practiceSetupTimingCustomPerQuestionCaption =>
      '‹‹Your own timer for each question››';

  @override
  String get practiceSetupTimingCustomQuizMinutesTitle => '‹‹Quiz minutes››';

  @override
  String get practiceSetupTimingCustomQuizMinutesCaption =>
      '‹‹Your own timer for the whole quiz››';

  @override
  String get practiceSetupInfiniteLivesTitle => '‹‹Infinite lives››';

  @override
  String get practiceSetupInfiniteLivesSubtitle =>
      '‹‹Never end the session because of wrong answers››';

  @override
  String get practiceSetupLivesTitle => '‹‹Lives››';

  @override
  String get practiceSetupLivesCaption =>
      '‹‹Mistakes allowed before the session ends››';

  @override
  String get practiceSetupTooltipHistory => '‹‹Practice history››';

  @override
  String get practiceHistoryTitle => '‹‹Practice history››';

  @override
  String get practiceHistoryClearTooltip => '‹‹Clear history››';

  @override
  String get practiceHistoryClearConfirmTitle => '‹‹Clear practice history?››';

  @override
  String get practiceHistoryClearConfirmBody =>
      '‹‹This removes all saved practice sessions from this device.››';

  @override
  String get practiceHistoryLoadError =>
      '‹‹Could not load practice history right now.››';

  @override
  String get practiceHistoryErrorPrefix => '‹‹Error:››';

  @override
  String get practiceHistoryEmpty => '‹‹No practice sessions yet.››';

  @override
  String get practiceHistoryDeleteConfirmTitle => '‹‹Delete this session?››';

  @override
  String get practiceHistoryDeleteConfirmBody =>
      '‹‹This removes only this saved practice session.››';

  @override
  String get practiceHistoryOpenReview => '‹‹Open review››';

  @override
  String get practiceHistoryDeleteSession => '‹‹Delete session››';

  @override
  String get practiceHistoryDebugTitle => '‹‹Practice history debug››';

  @override
  String get practiceAnalyticsTitle => '‹‹Practice analytics››';

  @override
  String get practiceAnalyticsSectionOverall => '‹‹Overall››';

  @override
  String get practiceAnalyticsRecentSessionsTitle => '‹‹Recent sessions››';

  @override
  String practiceAnalyticsRecentSessionsSummary(
    Object sessions,
    Object correct,
    Object answered,
    Object accuracy,
    Object xp,
  ) {
    return '‹‹$sessions sessions • $correct/$answered correct • $accuracy% • XP $xp››';
  }

  @override
  String get practiceAnalyticsSectionWeakestTopics => '‹‹Weakest topics››';

  @override
  String get practiceAnalyticsSectionStrongestTopics => '‹‹Strongest topics››';

  @override
  String get practiceAnalyticsSectionModePerformance => '‹‹Mode performance››';

  @override
  String get practiceAnalyticsNoTopicData => '‹‹No topic data yet››';

  @override
  String get practiceAnalyticsNoModeData => '‹‹No mode data yet››';

  @override
  String get savedQuestionsTopSubjectNone => '‹‹None yet››';

  @override
  String get savedQuestionsHeroSubtitle =>
      '‹‹Questions you saved during practice should feel easy to revisit. This page is the clean retry hub for them.››';

  @override
  String get savedQuestionsSavedMetric => '‹‹Saved››';

  @override
  String get savedQuestionsTopSubjectMetric => '‹‹Top subject››';

  @override
  String get savedQuestionsQuickActionsSubtitle =>
      '‹‹Jump straight back into practice or browse community solutions.››';

  @override
  String get savedQuestionsOpenPractice => '‹‹Open practice››';

  @override
  String get savedQuestionsOpenPracticeSubtitle =>
      '‹‹Start a fresh session and keep building momentum››';

  @override
  String get savedQuestionsOpenSolutions => '‹‹Open solutions››';

  @override
  String get savedQuestionsOpenSolutionsSubtitle =>
      '‹‹Browse uploaded solutions by subject, book, page, and question››';

  @override
  String get savedQuestionsQueueTitle => '‹‹Your saved queue››';

  @override
  String get savedQuestionsQueueSubtitle =>
      '‹‹Questions you save in practice appear here so you can reopen them quickly and keep working your weak spots.››';

  @override
  String get savedQuestionsEmptyTitle => '‹‹No saved questions yet››';

  @override
  String get savedQuestionsEmptySubtitle =>
      '‹‹Save a question from practice to revisit it later, open related solutions, and track the topics that still need work.››';

  @override
  String get savedQuestionsClearAction => '‹‹Clear saved questions››';

  @override
  String get savedQuestionsWhyItWorks => '‹‹Why it works››';

  @override
  String savedQuestionsHoursTarget(Object count) {
    return '‹‹$count h target››';
  }

  @override
  String savedQuestionsMinutesTarget(Object count) {
    return '‹‹$count min target››';
  }

  @override
  String savedQuestionsSecondsTarget(Object count) {
    return '‹‹$count sec target››';
  }

  @override
  String get practiceSetupTooltipAnalytics => '‹‹Practice analytics››';

  @override
  String get practiceSetupStopGenerating => '‹‹Stop Generating››';

  @override
  String get practiceSetupGenerating => '‹‹Generating...››';

  @override
  String get practiceSetupStartSession => '‹‹Start session››';

  @override
  String get practiceSetupSearchHint => '‹‹Search...››';

  @override
  String get practiceSessionModeDescriptionPractice =>
      '‹‹Balanced solving with instant checking and feedback.››';

  @override
  String get practiceSessionModeDescriptionFlashcards =>
      '‹‹Memory-first mode built for quick recall and retention.››';

  @override
  String get practiceSessionModeDescriptionSpeedRound =>
      '‹‹Fast, low-friction, timed pressure reps.››';

  @override
  String get practiceSessionModeDescriptionExamPrep =>
      '‹‹Formal exam-feel solving with less gamified pacing.››';

  @override
  String get practiceSessionModeDescriptionConceptBuilder =>
      '‹‹Understand the idea first, then solve with context.››';

  @override
  String get practiceSessionModeDescriptionAdaptive =>
      '‹‹Difficulty shifts based on how you perform.››';

  @override
  String get practiceSessionModeDescriptionBagrut =>
      '‹‹Official-style single-question formal Bagrut flow.››';

  @override
  String get practiceSessionLoadingPractice =>
      '‹‹Building your practice session››';

  @override
  String get practiceSessionLoadingFlashcards =>
      '‹‹Shuffling your flashcards››';

  @override
  String get practiceSessionLoadingSpeedRound => '‹‹Starting the speed round››';

  @override
  String get practiceSessionLoadingExamPrep =>
      '‹‹Preparing your exam session››';

  @override
  String get practiceSessionLoadingConceptBuilder =>
      '‹‹Loading concept coach››';

  @override
  String get practiceSessionLoadingAdaptive =>
      '‹‹Personalizing your challenge››';

  @override
  String get practiceSessionLoadingBagrut => '‹‹Preparing your Bagrut set››';

  @override
  String get practiceSessionLoadingDefault => '‹‹Preparing your session››';

  @override
  String practiceSessionCompleteTitle(Object mode) {
    return '‹‹$mode complete››';
  }

  @override
  String get practiceSessionMetricAnswered => '‹‹Answered››';

  @override
  String get practiceSessionMetricCorrect => '‹‹Correct››';

  @override
  String get practiceSessionMetricWrong => '‹‹Wrong››';

  @override
  String get practiceSessionMetricAccuracy => '‹‹Accuracy››';

  @override
  String get practiceSessionMetricTotal => '‹‹Total››';

  @override
  String get practiceSessionMetricXp => '‹‹XP››';

  @override
  String get practiceSessionMetricStreak => '‹‹Streak››';

  @override
  String get practiceSessionReviewLayoutStacked => '‹‹Stacked››';

  @override
  String get practiceSessionReviewLayoutFocus => '‹‹Focus››';

  @override
  String get practiceSessionFilterAll => '‹‹All››';

  @override
  String get practiceSessionFilterWrong => '‹‹Wrong››';

  @override
  String get practiceSessionFilterCorrect => '‹‹Correct››';

  @override
  String get practiceSessionReviewTitle => '‹‹Session review››';

  @override
  String get practiceSessionNoQuestionsForFilter =>
      '‹‹No questions match this filter yet.››';

  @override
  String get practiceSessionNoAnswer => '‹‹No answer››';

  @override
  String get practiceSessionUnknownAnswer => '‹‹Unknown››';

  @override
  String get practiceSessionReflectionTitle => '‹‹Reflection››';

  @override
  String get practiceSessionReflectionKnewIt => '‹‹Knew it››';

  @override
  String get practiceSessionReflectionReviewAgain => '‹‹Review again››';

  @override
  String get practiceSessionBackOfCard => '‹‹Back of card››';

  @override
  String get practiceSessionYourAnswer => '‹‹Your answer››';

  @override
  String get practiceSessionCorrectAnswer => '‹‹Correct answer››';

  @override
  String get practiceSessionExplanation => '‹‹Explanation››';

  @override
  String get practiceSessionBackToSetup => '‹‹Back to setup››';

  @override
  String get practiceSessionGeneralTopic => '‹‹General››';

  @override
  String practiceSessionQuestionProgress(Object current, Object total) {
    return '‹‹Question $current of $total››';
  }

  @override
  String get practiceSessionMetricTime => '‹‹Time››';

  @override
  String practiceSessionMatchmakingDifficulty(Object difficulty) {
    return '‹‹Difficulty: $difficulty››';
  }

  @override
  String get practiceModeActionPrevious => '‹‹Previous››';

  @override
  String get practiceModeActionCheckAnswer => '‹‹Check answer››';

  @override
  String get practiceModeActionNext => '‹‹Next››';

  @override
  String get practiceModeActionNextQuestion => '‹‹Next question››';

  @override
  String get practiceModeActionEndSession => '‹‹End session››';

  @override
  String get practiceModeActionEndQuestion => '‹‹End question››';

  @override
  String get practiceModeActionEndExam => '‹‹End exam››';

  @override
  String get practiceModeActionNovaHint => '‹‹NOVA hint››';

  @override
  String get practiceModeActionSaveQuestion => '‹‹Save question››';

  @override
  String get practiceModeActionSavedQuestion => '‹‹Saved››';

  @override
  String get practiceModeQuestionSavedToast => '‹‹Saved to your questions››';

  @override
  String get practiceModeQuestionRemovedToast =>
      '‹‹Removed from saved questions››';

  @override
  String get practiceModeActionReveal => '‹‹Reveal››';

  @override
  String get practiceModeActionShowSolution => '‹‹Show solution››';

  @override
  String get practiceModeActionHideSolution => '‹‹Hide solution››';

  @override
  String get practiceModeActionLockIn => '‹‹Lock in››';

  @override
  String get practiceModeActionCheckAdapt => '‹‹Check & adapt››';

  @override
  String get practiceModeActionContinue => '‹‹Continue››';

  @override
  String get practiceModeActionSolveIt => '‹‹Solve it››';

  @override
  String get practiceModeActionNextConcept => '‹‹Next concept››';

  @override
  String get practiceModeCardFront => '‹‹Front of card››';

  @override
  String get practiceModeRecallSummary => '‹‹Recall summary››';

  @override
  String get practiceModeFeelingPrompt => '‹‹How did that feel?››';

  @override
  String get practiceModeFeelingAgain => '‹‹Again››';

  @override
  String get practiceModeFeelingHard => '‹‹Hard››';

  @override
  String get practiceModeFeelingGood => '‹‹Good››';

  @override
  String get practiceModeFeelingEasy => '‹‹Easy››';

  @override
  String get practiceModeSpeedRoundBanner =>
      '‹‹Speed round · fast decisions, instant momentum››';

  @override
  String get practiceModeFastFeedback => '‹‹Fast feedback››';

  @override
  String get practiceModeExamPrepBanner =>
      '‹‹Exam prep · quieter layout, answers reviewed after moving forward››';

  @override
  String get practiceModeReview => '‹‹Review››';

  @override
  String get practiceModeBagrutBanner =>
      '‹‹Bagrut mode · official-style paper flow››';

  @override
  String get practiceModeOfficialSolution => '‹‹Official-style solution››';

  @override
  String get practiceModeAdaptiveWarmup => '‹‹Warm-up difficulty››';

  @override
  String get practiceModeAdaptiveTrendingUp => '‹‹Difficulty trending up››';

  @override
  String get practiceModeAdaptiveEasingDown => '‹‹Difficulty easing down››';

  @override
  String get practiceModeAdaptiveSteady => '‹‹Difficulty holding steady››';

  @override
  String get practiceModeAdaptiveFeedback => '‹‹Adaptive feedback››';

  @override
  String get practiceModeConceptFirst => '‹‹Concept first››';

  @override
  String get practiceModeNowSolveIt => '‹‹Now solve it››';

  @override
  String get practiceModeConceptTitle => '‹‹Concept››';

  @override
  String get practiceModeFeedbackCorrect => '‹‹Correct››';

  @override
  String get practiceModeFeedbackNotQuite => '‹‹Not quite››';

  @override
  String get practiceModeFallbackQuestion => '‹‹Question››';

  @override
  String get practiceModeNoExplanationYet =>
      '‹‹No explanation available yet.››';

  @override
  String get teacherGradesAssessmentCreated => '‹‹Assessment created››';

  @override
  String get teacherGradesEditAssessmentTitle => '‹‹Edit assessment››';

  @override
  String get teacherGradesFieldTitle => '‹‹Title››';

  @override
  String get teacherGradesFieldDate => '‹‹Date (YYYY-MM-DD)››';

  @override
  String get teacherGradesFieldMaxGrade => '‹‹Max grade››';

  @override
  String get teacherGradesAssessmentUpdated => '‹‹Assessment updated››';

  @override
  String get teacherGradesDeleteAssessmentTitle => '‹‹Delete assessment?››';

  @override
  String teacherGradesDeleteAssessmentBody(Object title) {
    return '‹‹This will remove $title and its grading entry from the teacher workspace.››';
  }

  @override
  String get teacherGradesDeleteAction => '‹‹Delete››';

  @override
  String get teacherGradesAssessmentDeleted => '‹‹Assessment deleted››';

  @override
  String get teacherGradesRosterLinkError =>
      '‹‹This assessment is not linked to a classroom roster.››';

  @override
  String get teacherGradesSaved => '‹‹Grades saved››';

  @override
  String get teacherGradesSubtitle =>
      '‹‹Create assessments and save grades against the live classroom roster.››';

  @override
  String get teacherGradesCreateAssessmentTitle => '‹‹Create assessment››';

  @override
  String get teacherGradesFieldCourse => '‹‹Course››';

  @override
  String get teacherGradesCreateAction => '‹‹Create››';

  @override
  String get teacherGradesNoStudentsLoaded =>
      '‹‹No students loaded for this assessment.››';

  @override
  String get teacherGradesFieldGrade => '‹‹Grade››';

  @override
  String teacherGradesMaxHint(Object grade) {
    return '‹‹Max $grade››';
  }

  @override
  String get teacherGradesSaving => '‹‹Saving…››';

  @override
  String teacherGradesSaveCount(Object count) {
    return '‹‹Save $count grades››';
  }

  @override
  String get assignmentsNoDueDate => '‹‹No due date››';

  @override
  String get assignmentsLoadError =>
      '‹‹We could not load assignments right now. Pull to refresh or try again.››';

  @override
  String get assignmentsLoadTimeout =>
      '‹‹Assignments are taking too long to load. Pull to refresh or try again in a moment.››';

  @override
  String get assignmentsLoadNetwork =>
      '‹‹Assignments could not connect right now. Check your connection and try again.››';

  @override
  String get assignmentsStatusOverdue => '‹‹Overdue››';

  @override
  String get assignmentsStatusGraded => '‹‹Graded››';

  @override
  String get assignmentsStatusDueSoon => '‹‹Due soon››';

  @override
  String get assignmentsStatusUpcoming => '‹‹Upcoming››';

  @override
  String get assignmentsPreviewFallback =>
      '‹‹Open this assignment to see the full instructions and prepare your work.››';

  @override
  String get assignmentsSubmissionPrepEmpty =>
      '‹‹Stage your note or files here.››';

  @override
  String assignmentsSubmissionPrepCount(Object count) {
    return '‹‹$count file(s) attached locally.››';
  }

  @override
  String get assignmentsHeroSubtitle =>
      '‹‹Every classroom assignment in one clean view, with a full-screen detail page and a dedicated place to prepare your work.››';

  @override
  String get assignmentsSubjectsMetric => '‹‹Subjects››';

  @override
  String get assignmentsNothingAssignedYet => '‹‹Nothing assigned yet››';

  @override
  String get assignmentsNoAssignmentsForAccount =>
      '‹‹No classroom assignments are available for this student account right now.››';

  @override
  String assignmentsNextThingBody(Object title, Object due) {
    return '‹‹$title is the next thing to look at. $due.››';
  }

  @override
  String get assignmentsPullToCheckAgain => '‹‹Pull down to check again.››';

  @override
  String get assignmentsFiltersSubtitle =>
      '‹‹Narrow the list by subject or urgency to focus on what matters first.››';

  @override
  String get assignmentsSubjectLabel => '‹‹Subject››';

  @override
  String get assignmentsAllSubjects => '‹‹All subjects››';

  @override
  String get assignmentsSearchSubjects => '‹‹Search subjects››';

  @override
  String get assignmentsStatusLabel => '‹‹Status››';

  @override
  String get assignmentsAllStatuses => '‹‹All statuses››';

  @override
  String get assignmentsSearchStatuses => '‹‹Search statuses››';

  @override
  String assignmentsShowingSummary(Object shown, Object total) {
    return '‹‹Showing $shown of $total assignments.››';
  }

  @override
  String get assignmentsNoFilterMatchesTitle =>
      '‹‹No assignments match these filters››';

  @override
  String get assignmentsNoFilterMatchesSubtitle =>
      '‹‹Try all subjects or a wider status view to bring more assignments back into the list.››';

  @override
  String get assignmentsClearFiltersHint =>
      '‹‹Clear filters to see everything again.››';

  @override
  String get assignmentsListSubtitle =>
      '‹‹Tap any assignment to open the full-screen detail view and prepare your work.››';

  @override
  String get assignmentsAddNoteBeforePrepare =>
      '‹‹Add a note or attach a file before preparing your work.››';

  @override
  String get assignmentsWorkDraftPrepared => '‹‹Work draft prepared.››';

  @override
  String get assignmentsWorkDraftPreparedWithFiles =>
      '‹‹Work draft prepared. Attached files are saved on this device.››';

  @override
  String get assignmentsUnavailableTitle => '‹‹Assignment unavailable››';

  @override
  String get assignmentsUnavailableSubtitle =>
      '‹‹This assignment could not be found in the current feed. It may have been removed or is not available offline.››';

  @override
  String get assignmentsUnavailableHint =>
      '‹‹Go back and refresh the assignments list.››';

  @override
  String get assignmentsOverdueBannerBody =>
      '‹‹This assignment is past its due date. Open your work area below to prepare what you want to turn in.››';

  @override
  String get assignmentsWorkAreaBannerBody =>
      '‹‹Use the work area below to stage files, write a note, and keep everything ready in one place.››';

  @override
  String get assignmentsDetailsSectionTitle => '‹‹Assignment details››';

  @override
  String get assignmentsDetailsSectionSubtitle =>
      '‹‹Everything student-relevant that is currently available in the classroom assignment payload.››';

  @override
  String get assignmentsDetailDueLabel => '‹‹Due››';

  @override
  String get assignmentsDetailClassroomLabel => '‹‹Classroom››';

  @override
  String get assignmentsDetailTeacherLabel => '‹‹Teacher››';

  @override
  String get assignmentsDetailPostedByLabel => '‹‹Posted by››';

  @override
  String get assignmentsDetailPublishedLabel => '‹‹Published››';

  @override
  String get assignmentsDetailUpdatedLabel => '‹‹Updated››';

  @override
  String get assignmentsDetailIdLabel => '‹‹Assignment ID››';

  @override
  String get assignmentsInstructionsTitle => '‹‹Instructions››';

  @override
  String get assignmentsInstructionsSubtitle =>
      '‹‹Full assignment text from the classroom feed, with the original wording preserved.››';

  @override
  String get assignmentsYourWorkTitle => '‹‹Your work››';

  @override
  String get assignmentsYourWorkSubtitle =>
      '‹‹Stage a note, attach files or docs, and keep your submission prep in one focused space.››';

  @override
  String get assignmentsPrivateNoteLabel => '‹‹Private work note››';

  @override
  String get assignmentsPrivateNoteHint =>
      '‹‹Add what you plan to submit, reminders for yourself, or a doc/link summary.››';

  @override
  String get assignmentsAddFiles => '‹‹Add files or docs››';

  @override
  String get assignmentsClearFiles => '‹‹Clear files››';

  @override
  String get assignmentsStagedDeviceHint =>
      '‹‹Files are staged on this device. Assignment file submission is not available in this app.››';

  @override
  String assignmentsLastPrepared(Object time) {
    return '‹‹Last prepared $time.››';
  }

  @override
  String get assignmentsSubmissionPrepTitle => '‹‹Submission prep››';

  @override
  String get assignmentsPreparing => '‹‹Preparing››';

  @override
  String get assignmentsPrepareWork => '‹‹Prepare work››';

  @override
  String get assignmentsLoadingSubtitle =>
      '‹‹Loading your classroom assignments.››';

  @override
  String get assignmentsPullToRefreshRetry =>
      '‹‹Pull to refresh or retry below.››';

  @override
  String get assignmentsFileSizeUnknown => '‹‹File››';

  @override
  String get assignmentsRemoveAttachment => '‹‹Remove››';

  @override
  String get assignmentsSubmitted => '‹‹Submitted››';

  @override
  String get attendanceUndated => '‹‹Undated››';

  @override
  String get attendanceLoadError =>
      '‹‹We could not load attendance right now. Pull to refresh or try again.››';

  @override
  String get attendanceLoadTimeout =>
      '‹‹Attendance is taking too long to load. Pull to refresh or try again in a moment.››';

  @override
  String get attendanceLoadNetwork =>
      '‹‹Attendance could not connect right now. Check your connection and try again.››';

  @override
  String get attendanceConsistencyBuilding => '‹‹Still building››';

  @override
  String get attendanceConsistencyExcellent => '‹‹Excellent consistency››';

  @override
  String get attendanceConsistencySteady => '‹‹Mostly steady››';

  @override
  String get attendanceConsistencyNeedsAttention => '‹‹Needs attention››';

  @override
  String get attendanceConsistencyRisk => '‹‹Attendance risk››';

  @override
  String get attendanceWatchRecentAbsences => '‹‹Recent absences››';

  @override
  String get attendanceWatchRepeatedLateness => '‹‹Repeated lateness››';

  @override
  String get attendanceWatchExcusedAddingUp => '‹‹Excused time adding up››';

  @override
  String get attendanceWatchNoFlags => '‹‹No current flags››';

  @override
  String get attendanceAllSubjectsLowercase => '‹‹all subjects››';

  @override
  String attendanceShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return '‹‹Showing $shown of $total marks for $subject in $range.››';
  }

  @override
  String get attendanceDayToneAbsent => '‹‹Absence day››';

  @override
  String get attendanceDayToneLate => '‹‹Late signal››';

  @override
  String get attendanceDayToneExcused => '‹‹Excused attendance››';

  @override
  String get attendanceDayToneClean => '‹‹Clean day››';

  @override
  String get attendanceLoadingSubtitle =>
      '‹‹Loading your latest attendance summary.››';

  @override
  String get attendanceUnavailableTitle => '‹‹Attendance unavailable››';

  @override
  String get attendanceHeroSubtitle =>
      '‹‹A clean read on your attendance rate, recent lessons, and anything that needs attention.››';

  @override
  String get attendanceMetricRate => '‹‹Rate››';

  @override
  String get attendanceMetricPresent => '‹‹Present marks››';

  @override
  String get attendanceMetricLate => '‹‹Late marks››';

  @override
  String get attendanceMetricAbsent => '‹‹Absent marks››';

  @override
  String attendanceHeroSignalBody(Object flag) {
    return '‹‹$flag. Attendance pressure can build quietly, so this view stays focused on what changed most recently.››';
  }

  @override
  String get attendanceNoSummary =>
      '‹‹No attendance summary is available for this student account yet.››';

  @override
  String get attendanceEmptyTitle => '‹‹No attendance records yet››';

  @override
  String get attendanceEmptySubtitle =>
      '‹‹No attendance records have been published for this student account yet.››';

  @override
  String get attendanceFiltersSubtitle =>
      '‹‹Use the same searchable picker style as settings to narrow the attendance view by subject or time window.››';

  @override
  String get attendanceTimeRangeLabel => '‹‹Time range››';

  @override
  String get attendanceSearchRanges =>
      '‹‹All time / 7 days / 30 days / 90 days››';

  @override
  String get attendanceNoFilteredMarksTitle =>
      '‹‹No marks match these filters››';

  @override
  String get attendanceNoFilteredMarksSubtitle =>
      '‹‹Try all subjects or a wider time range to bring more attendance marks back into view.››';

  @override
  String get attendanceQuickReadTitle => '‹‹Quick read››';

  @override
  String get attendanceQuickReadSubtitleFiltered =>
      '‹‹A fast summary for the filtered attendance marks shown below.››';

  @override
  String get attendanceQuickReadSubtitleAll =>
      '‹‹A fast summary based on the latest attendance records available.››';

  @override
  String get attendanceSummaryConsistency => '‹‹Consistency››';

  @override
  String get attendanceSummaryWatchFor => '‹‹Watch for››';

  @override
  String get attendanceSummaryExcused => '‹‹Excused marks››';

  @override
  String get attendanceSummaryMarksInView => '‹‹Marks in view››';

  @override
  String get attendanceSummaryRateInView => '‹‹Rate in view››';

  @override
  String get attendanceRecentDaysTitle => '‹‹Recent days››';

  @override
  String get attendanceRecentDaysSubtitleFiltered =>
      '‹‹Grouped by day for the filtered marks currently in view.››';

  @override
  String get attendanceRecentDaysSubtitleAll =>
      '‹‹Grouped by day so you can catch absence or lateness patterns faster.››';

  @override
  String get attendanceLessonCountSingle => '‹‹1 lesson››';

  @override
  String attendanceLessonCount(Object count) {
    return '‹‹$count lessons››';
  }

  @override
  String get attendanceStatusPresent => '‹‹Present››';

  @override
  String get attendanceStatusLate => '‹‹Late››';

  @override
  String get attendanceStatusAbsent => '‹‹Absent››';

  @override
  String get attendanceStatusExcused => '‹‹Excused››';

  @override
  String get attendanceStatusRecorded => '‹‹Recorded››';

  @override
  String get attendanceLessonFallback => '‹‹Lesson››';

  @override
  String get attendanceRangeAll => '‹‹All time››';

  @override
  String get attendanceRange7 => '‹‹Last 7 days››';

  @override
  String get attendanceRange30 => '‹‹Last 30 days››';

  @override
  String get attendanceRange90 => '‹‹Last 90 days››';

  @override
  String get attendanceRangeAllShort => '‹‹All time››';

  @override
  String get attendanceRange7Short => '‹‹7 days››';

  @override
  String get attendanceRange30Short => '‹‹30 days››';

  @override
  String get attendanceRange90Short => '‹‹90 days››';

  @override
  String get gradesLoadError =>
      '‹‹We could not load grades right now. Pull to refresh or try again.››';

  @override
  String get gradesLoadTimeout =>
      '‹‹Grades are taking too long to load. Pull to refresh or try again in a moment.››';

  @override
  String get gradesLoadNetwork =>
      '‹‹Grades could not connect right now. Check your connection and try again.››';

  @override
  String get gradesGeneralSubject => '‹‹General››';

  @override
  String get gradesBandBuilding => '‹‹Still building››';

  @override
  String get gradesBandExcellent => '‹‹Excellent››';

  @override
  String get gradesBandStrong => '‹‹Strong››';

  @override
  String get gradesBandOkay => '‹‹Okay››';

  @override
  String get gradesBandNeedsAttention => '‹‹Needs attention››';

  @override
  String get gradesBandRisk => '‹‹At risk››';

  @override
  String get gradesTrendRising => '‹‹Rising››';

  @override
  String get gradesTrendDropping => '‹‹Dropping››';

  @override
  String get gradesTrendStable => '‹‹Stable››';

  @override
  String gradesShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return '‹‹Showing $shown of $total recorded grades for $subject in $range.››';
  }

  @override
  String get gradesLoadingSubtitle =>
      '‹‹Loading your latest academic results.››';

  @override
  String get gradesUnavailableTitle => '‹‹Grades unavailable››';

  @override
  String get gradesHeroSubtitle =>
      '‹‹A clean read on your average, recent assessments, and which subjects need protection or recovery.››';

  @override
  String get gradesMetricAverage => '‹‹Average››';

  @override
  String get gradesMetricRecorded => '‹‹Recorded››';

  @override
  String get gradesMetricBestSubject => '‹‹Best subject››';

  @override
  String get gradesMetricNeedsWork => '‹‹Needs work››';

  @override
  String gradesLatestSignalBody(
    Object assessment,
    Object subject,
    Object grade,
    Object band,
  ) {
    return '‹‹$assessment in $subject landed at $grade. $band right now.››';
  }

  @override
  String get gradesSummaryAvailableNoRecent =>
      '‹‹A grade summary is available, but no recent assessments are visible in this view yet.››';

  @override
  String get gradesEmptyTitle => '‹‹No grades yet››';

  @override
  String get gradesEmptySubtitle =>
      '‹‹No grades have been published for this student account yet.››';

  @override
  String get gradesFiltersSubtitle =>
      '‹‹Use the same searchable picker style as settings to narrow grades by subject or time window.››';

  @override
  String get gradesNoFilteredTitle => '‹‹No grades match these filters››';

  @override
  String get gradesNoFilteredSubtitle =>
      '‹‹Try all subjects or a wider time range to bring more recorded grades back into view.››';

  @override
  String get gradesQuickReadTitle => '‹‹Quick read››';

  @override
  String get gradesQuickReadSubtitleFiltered =>
      '‹‹A fast summary for the grades currently in view.››';

  @override
  String get gradesQuickReadSubtitleAll =>
      '‹‹The fastest read on what to protect and what to recover.››';

  @override
  String get gradesWeakSpotLabel => '‹‹Current weak spot››';

  @override
  String get gradesNoWeakSignal => '‹‹No weak subject signal yet››';

  @override
  String gradesWeakSpotValue(Object subject) {
    return '‹‹$subject needs the first recovery block.››';
  }

  @override
  String get gradesStrengthLabel => '‹‹Current strength››';

  @override
  String get gradesNoStrengthSignal => '‹‹No strong subject signal yet››';

  @override
  String gradesStrengthValue(Object subject) {
    return '‹‹$subject is your confidence anchor right now.››';
  }

  @override
  String get gradesBandLabel => '‹‹Band››';

  @override
  String get gradesInViewLabel => '‹‹In view››';

  @override
  String gradesInViewCount(Object count) {
    return '‹‹$count recorded grades in this filter.››';
  }

  @override
  String gradesInViewAverage(Object count, Object average) {
    return '‹‹$count recorded grades averaging $average.››';
  }

  @override
  String get gradesLatestAssessmentsTitle => '‹‹Latest assessments››';

  @override
  String get gradesLatestAssessmentsSubtitleFiltered =>
      '‹‹Most recent recorded grades in the current filtered view.››';

  @override
  String get gradesLatestAssessmentsSubtitleAll =>
      '‹‹Most recent recorded grades in chronological order.››';

  @override
  String get gradesSubjectDrilldownTitle => '‹‹Subject drilldown››';

  @override
  String get gradesSubjectDrilldownSubtitleFiltered =>
      '‹‹Grouped by subject for the grades currently in view.››';

  @override
  String get gradesSubjectDrilldownSubtitleAll =>
      '‹‹Grouped by subject so trend and pressure stand out faster.››';

  @override
  String get gradesAssessmentFallback => '‹‹Assessment››';

  @override
  String get gradesChipBest => '‹‹Best››';

  @override
  String get gradesNoAverageYet => '‹‹No average yet››';

  @override
  String gradesRecentAverage(Object average) {
    return '‹‹Recent average: $average››';
  }

  @override
  String get actionCancel => '‹‹Cancel››';

  @override
  String get actionSave => '‹‹Save››';

  @override
  String get actionDelete => '‹‹Delete››';

  @override
  String get actionRemove => '‹‹Remove››';

  @override
  String get actionBlock => '‹‹Block››';

  @override
  String get actionCreate => '‹‹Create››';

  @override
  String get actionShare => '‹‹Share››';

  @override
  String get actionScheduleVerb => '‹‹Schedule››';

  @override
  String get actionAdd => '‹‹Add››';

  @override
  String get actionKeep => '‹‹Keep››';

  @override
  String get actionOpen => '‹‹Open››';

  @override
  String get actionPublish => '‹‹Publish››';

  @override
  String get actionPublishing => '‹‹Publishing…››';

  @override
  String get actionRefresh => '‹‹Refresh››';

  @override
  String get msgBlockTitle => '‹‹Block this person?››';

  @override
  String get msgBlockContent =>
      '‹‹They won\'t be able to message you and you won\'t see their messages.››';

  @override
  String get msgRenameGroup => '‹‹Rename group››';

  @override
  String get msgGroupName => '‹‹Group name››';

  @override
  String get msgMute => '‹‹Mute››';

  @override
  String get msgUnmute => '‹‹Unmute››';

  @override
  String get msgInviteCode => '‹‹Invite code››';

  @override
  String get msgCopyCode => '‹‹Copy code››';

  @override
  String get msgLeave => '‹‹Leave››';

  @override
  String get msgInviteCodeCopied => '‹‹Invite code copied››';

  @override
  String msgCodeCopied(Object code) {
    return '‹‹Code copied: $code››';
  }

  @override
  String msgParticipantsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants added',
      one: '1 participant added',
    );
    return '‹‹$_temp0››';
  }

  @override
  String msgMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get msgAdmin => '‹‹Admin››';

  @override
  String get msgRemoveFromGroup => '‹‹Remove from group››';

  @override
  String get msgMakeAdmin => '‹‹Make admin››';

  @override
  String get msgRemoveAdmin => '‹‹Remove admin››';

  @override
  String get msgOnlyAdmin => '‹‹Only admin — promote another first››';

  @override
  String msgRemoveMemberTitle(Object name) {
    return '‹‹Remove $name?››';
  }

  @override
  String get msgNotificationsMuted => '‹‹Notifications muted››';

  @override
  String get msgNotificationsUnmuted => '‹‹Notifications unmuted››';

  @override
  String get msgJoinGroupTitle => '‹‹Join a Group››';

  @override
  String get msgJoinGroupSubtitle =>
      '‹‹Enter the invite code from the group admin››';

  @override
  String get examTitle => '‹‹Exam››';

  @override
  String get examNotFound => '‹‹Exam not found››';

  @override
  String get examStudyWithNova => '‹‹Study with NOVA››';

  @override
  String get examOpenInsights => '‹‹Open Insights››';

  @override
  String get examAddToCalendar => '‹‹Add to calendar››';

  @override
  String get examCouldNotOpenCalendar => '‹‹Could not open calendar.››';

  @override
  String get formTitle => '‹‹Form››';

  @override
  String get formNotFound => '‹‹Form not found››';

  @override
  String get formClosed => '‹‹Closed››';

  @override
  String get formCompletion => '‹‹Completion››';

  @override
  String get formNoTextResponses => '‹‹No text responses yet.››';

  @override
  String get meetingsCouldNotLoad => '‹‹Could not load meetings››';

  @override
  String get meetingCouldNotLoad => '‹‹Could not load meeting››';

  @override
  String get insightsGenerateAction => '‹‹Generate Insights››';

  @override
  String get insightsRefreshAction => '‹‹Refresh››';

  @override
  String get teacherGoToClassroom => '‹‹Go to Classroom››';

  @override
  String get teacherMarkAttendance => '‹‹Mark Attendance››';

  @override
  String get teacherPostAssignment => '‹‹Post Assignment››';

  @override
  String get teacherNewAnnouncementAction => '‹‹New Announcement››';

  @override
  String get teacherViewFullWeekSchedule => '‹‹View full week schedule››';

  @override
  String get teacherGroupsLabel => '‹‹Groups››';

  @override
  String get teacherTestsLabel => '‹‹Tests››';

  @override
  String get teacherAnnounceLabel => '‹‹Announce››';

  @override
  String get teacherTitleAndMessageRequired =>
      '‹‹Title and message are required››';

  @override
  String get teacherAnnouncementPublished => '‹‹Announcement published››';

  @override
  String teacherFailedToPublish(Object error) {
    return '‹‹Failed to publish: $error››';
  }

  @override
  String get teacherAnnouncementSectionTitle => '‹‹Announcement››';

  @override
  String get teacherAudienceSectionTitle => '‹‹Audience››';

  @override
  String get teacherPinAnnouncement => '‹‹Pin announcement››';

  @override
  String get teacherPinnedAtTop => '‹‹Pinned announcements appear at the top››';

  @override
  String get teacherPublishAction => '‹‹Publish››';

  @override
  String get teacherPublishingAction => '‹‹Publishing…››';

  @override
  String get teacherAnnounceTitleLabel => '‹‹Title *››';

  @override
  String get teacherAnnounceTitleHint => '‹‹e.g. School event tomorrow››';

  @override
  String get teacherAnnounceMessageLabel => '‹‹Message *››';

  @override
  String get teacherAnnounceMessageHint =>
      '‹‹Write the full announcement here…››';

  @override
  String get teacherStudentsLabel => '‹‹Students››';

  @override
  String get teacherSearchStudents => '‹‹Search students…››';

  @override
  String get teacherNoStudentsLoaded => '‹‹No students found in this school.››';

  @override
  String get teacherActions => '‹‹QUICK ACTIONS››';

  @override
  String get teacherParentsLabel => '‹‹Parents››';

  @override
  String get teacherTeachersLabel => '‹‹Teachers››';

  @override
  String get teacherWeekScheduleTitle => '‹‹Week Schedule››';

  @override
  String get teacherCouldNotLoadSchedule => '‹‹Could not load schedule››';

  @override
  String get teacherAttendanceLast30 => '‹‹Attendance (last 30 days)››';

  @override
  String teacherAttendanceFrom(Object date) {
    return '‹‹From $date››';
  }

  @override
  String get teacherAttendanceChangeDate => '‹‹Change date››';

  @override
  String get teacherAttendanceNoSessions =>
      '‹‹No saved attendance sessions.\nMark attendance from the schedule.››';

  @override
  String get teacherRecentGrades => '‹‹Recent Grades››';

  @override
  String get teacherNoGradesRecorded => '‹‹No grades recorded yet››';

  @override
  String get teacherGradeAvg => '‹‹Grade Avg››';

  @override
  String get teacherSubmittedLabel => '‹‹Submitted››';

  @override
  String get teacherAnalyticsTitle => '‹‹Analytics››';

  @override
  String get teacherGradeReports => '‹‹Grade Reports››';

  @override
  String get teacherAvgLabel => '‹‹avg››';

  @override
  String teacherBelow60(Object count) {
    return '‹‹$count below 60%››';
  }

  @override
  String teacherGradedFraction(Object graded, Object total) {
    return '‹‹$graded/$total graded››';
  }

  @override
  String get teacherNoGradesEntered => '‹‹No grades entered yet››';

  @override
  String get teacherNewAssignment => '‹‹New Assignment››';

  @override
  String get teacherDeleteAssignment => '‹‹Delete assignment?››';

  @override
  String get teacherDeleteAssignmentContent =>
      '‹‹This will remove it for all students.››';

  @override
  String get teacherShareMaterialTitle => '‹‹Share Material››';

  @override
  String get teacherRemoveMaterial => '‹‹Remove material?››';

  @override
  String get teacherScheduleMeetingTitle => '‹‹Schedule Meeting››';

  @override
  String get teacherCancelMeetingTitle => '‹‹Cancel meeting?››';

  @override
  String get teacherCancelMeetingAction => '‹‹Cancel meeting››';

  @override
  String get teacherJoinMeeting => '‹‹Join meeting››';

  @override
  String get teacherAddStudentTitle => '‹‹Add Student››';

  @override
  String teacherRemoveStudentTitle(Object name) {
    return '‹‹Remove $name?››';
  }

  @override
  String get teacherRemoveStudentContent =>
      '‹‹This student will be removed from this classroom.››';

  @override
  String get teacherStudentAdded => '‹‹Student added››';

  @override
  String get teacherClassroomAnalyticsTitle => '‹‹Classroom Analytics››';

  @override
  String get teacherOpenAnalyticsAction => '‹‹Open Analytics››';

  @override
  String teacherStudentsCount(Object count) {
    return '‹‹Students ($count)››';
  }

  @override
  String get teacherAssignmentLabel => '‹‹Assignment››';

  @override
  String get teacherShareMaterialLabel => '‹‹Share material››';

  @override
  String get teacherAttendanceRateLabel => '‹‹Attendance rate››';

  @override
  String get teacherSelectSessionPrompt =>
      '‹‹Select a session below to start marking attendance››';

  @override
  String get teacherOpenAction => '‹‹Open››';

  @override
  String get chatDeleteForMe => '‹‹Delete for me››';

  @override
  String get chatDeleteForEveryone => '‹‹Delete for everyone››';

  @override
  String get chatMicNeeded => '‹‹Microphone access needed››';

  @override
  String get chatMicNeededBody =>
      '‹‹Please allow microphone access in Settings to send voice notes.››';

  @override
  String get chatOpenSettings => '‹‹Open Settings››';

  @override
  String get chatCopied => '‹‹Copied››';

  @override
  String get chatCouldNotSendMedia => '‹‹Could not send media.››';

  @override
  String get chatMediaWebUnsupported =>
      'Taking photos, recording, and attaching files aren\'t available in the web browser yet — please use the ClassMate mobile app.';

  @override
  String get chatCouldNotSendMessage => '‹‹Could not send message.››';

  @override
  String get chatCouldNotForward => '‹‹Could not forward selected messages››';

  @override
  String get chatSelectAll => '‹‹Select all››';

  @override
  String get chatDeselectAll => '‹‹Deselect all››';

  @override
  String get chatEditingMessage => '‹‹Editing message››';

  @override
  String get chatEditPlaceholder => '‹‹Edit message…››';

  @override
  String get chatMessageHint => '‹‹Message››';

  @override
  String get chatPin => '‹‹Pin››';

  @override
  String get chatUnpin => '‹‹Unpin››';

  @override
  String get chatPhoto => '‹‹Photo››';

  @override
  String get chatVideo => '‹‹Video››';

  @override
  String get chatMedia => '‹‹Media››';

  @override
  String get chatAudioFile => '‹‹Audio file››';

  @override
  String get chatVideoFile => '‹‹Video file››';

  @override
  String get chatAttachedFile => '‹‹Attached file››';

  @override
  String get chatFollowUp => '‹‹Follow-up››';

  @override
  String get chatCancelTooltip => '‹‹Cancel››';

  @override
  String get chatJoinGroup => '‹‹Join Group››';

  @override
  String get chatJoining => '‹‹Joining…››';

  @override
  String get chatJoinGroupTooltip => '‹‹Join group by code››';

  @override
  String get chatForwardNoChatAvailable => '‹‹No approved chats available››';

  @override
  String get chatFilterAll => '‹‹All››';

  @override
  String get novaDisclaimer =>
      '‹‹NOVA can make mistakes. Double-check important answers.››';

  @override
  String get novaTokenTip =>
      '‹‹Use your tokens carefully — they\'re meant for studying.››';

  @override
  String get practiceCustomDisclaimer =>
      '‹‹Custom topics are AI-generated on the fly. Questions may drift off-topic or be inaccurate for niche subjects. Verify unfamiliar answers independently.››';

  @override
  String get classroomsJoined => '‹‹You joined the classroom!››';

  @override
  String get classroomsJoinAction => '‹‹Join Classroom››';

  @override
  String get classroomsJoinTooltip => '‹‹Join a classroom››';

  @override
  String get classroomsJoinTitle => '‹‹Join a Classroom››';

  @override
  String get classroomsJoinSubtitle =>
      '‹‹Enter the code your teacher gave you››';

  @override
  String get classroomsCouldNotOpenLink => '‹‹Could not open link››';

  @override
  String get classroomsReorderTitle => '‹‹Reorder classrooms››';

  @override
  String get classroomsNoClassroomsToReorder => '‹‹No classrooms to reorder.››';

  @override
  String get teacherPostAnnouncementAction => '‹‹Post Announcement››';

  @override
  String get announcementAudienceEveryone => '‹‹Everyone››';

  @override
  String get teacherGreetingMorning => '‹‹Good morning››';

  @override
  String get teacherGreetingAfternoon => '‹‹Good afternoon››';

  @override
  String get teacherGreetingEvening => '‹‹Good evening››';

  @override
  String get teacherTodaysClasses => '‹‹Today\'s Classes››';

  @override
  String get teacherNoDate => '‹‹No date››';

  @override
  String get teacherUpcomingTestsSubtitle => '‹‹Next tests & quizzes››';

  @override
  String get teacherNoClassesThisWeek => '‹‹No classes this week››';

  @override
  String get teacherNoClassesThisWeekSub =>
      '‹‹Your schedule for this week is empty››';

  @override
  String get teacherTitleFieldLabel => '‹‹Title *››';

  @override
  String get teacherInstructionsLabel => '‹‹Instructions››';

  @override
  String get teacherLinkUrlLabel => '‹‹Link / URL *››';

  @override
  String get teacherLinkUrlHint => '‹‹https://...››';

  @override
  String get teacherDescriptionLabel => '‹‹Description››';

  @override
  String get teacherMeetingTitleLabel => '‹‹Meeting title *››';

  @override
  String get teacherMeetingLinkLabel => '‹‹Meeting link *››';

  @override
  String get teacherMeetingLinkHint => '‹‹Zoom / Meet / Teams link››';

  @override
  String get teacherStudentEmailLabel => '‹‹Student email or ID››';

  @override
  String get teacherTooltipRemoveStudent => '‹‹Remove from classroom››';

  @override
  String get teacherCouldNotLoad => '‹‹Could not load››';

  @override
  String get teacherNoAssignmentsYet => '‹‹No assignments yet››';

  @override
  String get teacherNoAssignmentsSub =>
      '‹‹Tap + to create the first assignment››';

  @override
  String get teacherNoMaterialsYet => '‹‹No materials yet››';

  @override
  String get teacherNoMaterialsSub =>
      '‹‹Share links, documents, or resources with your class››';

  @override
  String get teacherNoMeetingsScheduled => '‹‹No meetings scheduled››';

  @override
  String get teacherNoMeetingsSub => '‹‹Tap + to schedule a class meeting››';

  @override
  String get teacherAttendanceOther => '‹‹Other››';

  @override
  String get teacherTotal => '‹‹Total››';

  @override
  String get mediaOpenExternally => '‹‹Open externally››';

  @override
  String get mediaUnableToLoad => '‹‹Unable to load image››';

  @override
  String get searchHint => '‹‹Search...››';

  @override
  String get teacherInsightsTitle => '‹‹Student Insights››';

  @override
  String get teacherInsightsSubtitle =>
      '‹‹Select a student to view their academic insights.››';

  @override
  String get teacherInsightsNoStudents => '‹‹No students found.››';

  @override
  String get teacherInsightsSearchHint => '‹‹Search students…››';

  @override
  String get navDiplomas => '‹‹Diplomas››';

  @override
  String get diplomasComingSoon => '‹‹Diploma management is coming soon.››';

  @override
  String get teacherExamsTitle => '‹‹Exams››';

  @override
  String get teacherExamsUpcoming => '‹‹Upcoming››';

  @override
  String get teacherExamsPast => '‹‹Past››';

  @override
  String get teacherExamsEmpty =>
      '‹‹No assessments yet. Tap + to create one.››';

  @override
  String teacherExamsGraded(Object count) {
    return '‹‹$count graded››';
  }

  @override
  String get teacherFormsTitle => '‹‹Forms››';

  @override
  String get teacherFormsEmpty => '‹‹No forms yet. Tap + to create one.››';

  @override
  String teacherFormsResponses(Object count) {
    return '‹‹$count responses››';
  }

  @override
  String get teacherFormsPublished => '‹‹Published››';

  @override
  String get teacherFormsDraft => '‹‹Draft››';

  @override
  String get teacherFormsCreateTitle => '‹‹Create Form››';

  @override
  String get teacherFormsAddQuestion => '‹‹Add question››';

  @override
  String get teacherFormsQuestionHint => '‹‹Question text››';

  @override
  String get teacherFormsViewResponses => '‹‹View responses››';

  @override
  String get teacherFormsNoResponses => '‹‹No responses yet.››';

  @override
  String get diplomasTitle => '‹‹Diplomas››';

  @override
  String get diplomasEmpty =>
      '‹‹No certificates issued yet. Tap + to issue one.››';

  @override
  String get diplomasIssueTo => '‹‹Issue to››';

  @override
  String get diplomasStudentName => '‹‹Student name››';

  @override
  String get diplomasCertificateType => '‹‹Certificate type››';

  @override
  String get diplomasIssueDiploma => '‹‹Issue Certificate››';

  @override
  String diplomasIssuedOn(Object date) {
    return '‹‹Issued on $date››';
  }

  @override
  String get examDetailsSection => '‹‹Details››';

  @override
  String get examInfoTeacher => '‹‹Teacher››';

  @override
  String get examInfoAudience => '‹‹Audience››';

  @override
  String get examInfoDate => '‹‹Date››';

  @override
  String get examInfoTime => '‹‹Time››';

  @override
  String get examInfoPeriod => '‹‹Period››';

  @override
  String get examInfoDuration => '‹‹Duration››';

  @override
  String get examInfoSubject => '‹‹Subject››';

  @override
  String get examMaterialsSection => '‹‹Attached materials››';

  @override
  String get examNoMaterials => '‹‹No materials attached yet.››';

  @override
  String get examQuickActionsSection => '‹‹Quick actions››';

  @override
  String get examViewGradeTitle => '‹‹See your grade››';

  @override
  String get examViewGradeBody =>
      '‹‹This exam is complete. Check the grades tab for your result.››';

  @override
  String get examViewGradeAction => '‹‹Open Grades››';

  @override
  String get teacherGradesSaveAction => '‹‹Save››';

  @override
  String get teacherGradesNothingToSave => '‹‹No changes to save.››';

  @override
  String get teacherRetry => '‹‹Retry››';

  @override
  String get teacherExamGradesStudents => '‹‹students››';

  @override
  String get teacherExamGradesGraded => '‹‹graded››';

  @override
  String get teacherExamGradesNoStudents =>
      '‹‹No students targeted.\nEdit the exam to add an audience.››';

  @override
  String get teacherExamGradesEnterGrades => '‹‹Enter grades››';

  @override
  String get teacherExamClassAverage => '‹‹Class average››';

  @override
  String get teacherDeleteExamTitle => '‹‹Delete exam?››';

  @override
  String get teacherDeleteExamBody =>
      '‹‹This will permanently delete the exam.››';

  @override
  String get teacherMeetingsEmpty =>
      '‹‹No meetings yet.\nTap + to schedule one.››';

  @override
  String get teacherStudentsNoMatch => '‹‹No students match››';

  @override
  String get teacherMaterialsTitle => '‹‹Materials››';

  @override
  String get profileNamesTitle => '‹‹Name in languages››';

  @override
  String get profileDisplayNameLang => '‹‹Display name language››';

  @override
  String get navDashboard => '‹‹Dashboard››';

  @override
  String get navPeople => '‹‹Users››';

  @override
  String get navCohorts => '‹‹Cohorts››';

  @override
  String get navSchool => '‹‹School››';

  @override
  String get navSchools => 'ښوونځي';

  @override
  String get navManagers => 'مدیران';

  @override
  String get navBagrut => 'Bagrut';

  @override
  String get chatPreviewPhoto => 'انځور';

  @override
  String get chatPreviewVoice => 'غږیز پیغام';

  @override
  String get chatPreviewVideo => 'ویډیو';

  @override
  String get chatPreviewAttachment => 'ضمیمه';

  @override
  String get chatPreviewMessage => 'پیغام';

  @override
  String get chatPreviewYou => 'تاسو';

  @override
  String get adminDashboardTitle => '‹‹School Overview››';

  @override
  String get adminStudents => '‹‹Students››';

  @override
  String get adminTeachers => '‹‹Teachers››';

  @override
  String get adminParents => '‹‹Parents››';

  @override
  String get adminSecretaries => '‹‹Secretaries››';

  @override
  String get adminAdmins => '‹‹Admins››';

  @override
  String get adminTodaySessions => '‹‹Today\'s sessions››';

  @override
  String get adminQuickActions => '‹‹Quick Actions››';

  @override
  String get adminAttendanceLast30 => '‹‹Attendance — Last 30 Days››';

  @override
  String get adminNoAttendanceData =>
      '‹‹No attendance data for the last 30 days.››';

  @override
  String get adminAddUser => '‹‹Add User››';

  @override
  String get adminCreateUser => '‹‹Create››';

  @override
  String get adminFullName => '‹‹Full Name››';

  @override
  String get adminEmailAddress => '‹‹Email address››';

  @override
  String get adminRoleLabel => '‹‹Role››';

  @override
  String get adminUserCreated => '‹‹User Created››';

  @override
  String get adminTempPassword => '‹‹Temporary password››';

  @override
  String get adminCopied => '‹‹Copied to clipboard››';

  @override
  String get adminResetPassword => '‹‹Reset Password››';

  @override
  String get adminPasswordReset => '‹‹Password Reset››';

  @override
  String adminTempPasswordFor(Object name) {
    return '‹‹Temporary password for $name››';
  }

  @override
  String get adminDeleteUser => '‹‹Delete User››';

  @override
  String adminDeleteUserConfirm(Object name) {
    return '‹‹Delete $name? This cannot be undone.››';
  }

  @override
  String get adminDeleteCohort => '‹‹Delete Cohort››';

  @override
  String adminDeleteCohortConfirm(Object name) {
    return '‹‹Delete \"$name\"? All student memberships will be removed.››';
  }

  @override
  String get adminAddCohort => '‹‹Add Cohort››';

  @override
  String get adminNewCohort => '‹‹New Cohort››';

  @override
  String get adminCohortName => '‹‹Cohort Name (e.g. 10th-2)››';

  @override
  String get adminCohortGrade => '‹‹Grade››';

  @override
  String get adminRenameCohort => '‹‹Rename››';

  @override
  String get adminAddStudents => '‹‹Add Students››';

  @override
  String adminAddTo(Object name) {
    return '‹‹Add to $name››';
  }

  @override
  String get adminRemoveStudent => '‹‹Remove Student››';

  @override
  String adminRemoveStudentConfirm(Object name, Object cohort) {
    return '‹‹Remove $name from $cohort?››';
  }

  @override
  String get adminNoCohortsYet => '‹‹No cohorts yet››';

  @override
  String get adminNoStudentsInCohort => '‹‹No students in this cohort››';

  @override
  String adminStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students',
      one: '1 student',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get adminSearchStudents => '‹‹Search students…››';

  @override
  String get adminScheduleTitle => '‹‹Schedule››';

  @override
  String get adminScheduleAddPeriod => '‹‹Add period››';

  @override
  String get adminScheduleNewPeriod => '‹‹New Period››';

  @override
  String get adminScheduleDayLabel => '‹‹Day››';

  @override
  String adminSchedulePeriodLabel(Object period) {
    return '‹‹P$period››';
  }

  @override
  String get adminScheduleTeacherLabel => '‹‹Teacher››';

  @override
  String get adminScheduleNoneTeacher => '‹‹No teacher assigned››';

  @override
  String get adminScheduleCohortLabel => '‹‹Cohort / Students››';

  @override
  String get adminScheduleFrequencyLabel => '‹‹Frequency››';

  @override
  String get adminScheduleFreqWeekly => '‹‹Every week››';

  @override
  String get adminScheduleFreqBiweekly => '‹‹Every 2 weeks››';

  @override
  String get adminScheduleFreqMonthly => '‹‹Every 4 weeks››';

  @override
  String get adminScheduleFreqCustom => '‹‹Custom››';

  @override
  String adminScheduleFreqCustomLabel(int n) {
    return '‹‹Every $n weeks››';
  }

  @override
  String get adminScheduleAddSlot => '‹‹Add slot››';

  @override
  String get adminScheduleAddAnother => '‹‹Add another day / period››';

  @override
  String get adminScheduleSave => '‹‹Save››';

  @override
  String get adminScheduleSearchTeacher => '‹‹Search teachers…››';

  @override
  String get adminScheduleSearchCohort => '‹‹Search cohorts…››';

  @override
  String get adminScheduleSelectTeacher => '‹‹Select teacher››';

  @override
  String get adminScheduleSelectCohort => '‹‹Select cohort››';

  @override
  String get adminScheduleOrStudents => '‹‹Or pick individual students››';

  @override
  String get adminScheduleNoSlots => '‹‹No periods yet››';

  @override
  String get adminScheduleNoSlotsHint => '‹‹Tap + to add the first period››';

  @override
  String get adminSchoolSettingsTitle => '‹‹School Settings››';

  @override
  String get adminSchoolName => '‹‹School Name››';

  @override
  String get adminSchoolLogoUrl => '‹‹Logo URL (optional)››';

  @override
  String get adminSchoolLogoHint => '‹‹https://…››';

  @override
  String get adminSchoolSaved => '‹‹Saved››';

  @override
  String get adminSubjectsTitle => '‹‹Subjects››';

  @override
  String adminSubjectsGrade(int grade) {
    return '‹‹Grade $grade››';
  }

  @override
  String get adminSubjectsAddHint => '‹‹Add subject…››';

  @override
  String get adminSubjectsNoSubjects => '‹‹No subjects configured››';

  @override
  String get adminSubjectsAdd => '‹‹Add››';

  @override
  String get adminSubjectsRemove => '‹‹Remove››';

  @override
  String get adminSettingsTitle => '‹‹Settings››';

  @override
  String get adminSettingsBellSchedule => '‹‹Bell Schedule››';

  @override
  String get adminSettingsPeriodDefaults => '‹‹Period Defaults››';

  @override
  String get adminSettingsPeriodDefaultsSubtitle =>
      '‹‹Set bell times for each period››';

  @override
  String get adminDeleteConfirmCancel => '‹‹Cancel››';

  @override
  String get adminDeleteConfirmDelete => '‹‹Delete››';

  @override
  String get adminSave => '‹‹Save››';

  @override
  String get adminCancel => '‹‹Cancel››';

  @override
  String get adminSearchPeople => '‹‹Search by name…››';

  @override
  String adminNoResults(Object query) {
    return '‹‹No results for \"$query\"››';
  }

  @override
  String adminNoPeopleYet(Object role) {
    return '‹‹No $role yet››';
  }

  @override
  String get commonRetry => '‹‹Retry››';

  @override
  String get chatThreadLoadFailedTitle => 'دا خبرې اترې لوډ نه شوې';

  @override
  String get chatThreadLoadFailedBody =>
      'مهرباني وکړئ خپل انټرنېټ اتصال وګورئ او بیا هڅه وکړئ.';

  @override
  String get chatThreadLoadFailedBusy =>
      'سرور دا مهال یو څه بوخت دی. یوه شېبه صبر وکړئ، بیا هڅه وکړئ.';

  @override
  String get commonBack => '‹‹Back››';

  @override
  String get commonClose => '‹‹Close››';

  @override
  String get commonDownload => '‹‹Download››';

  @override
  String get commonOpenExternally => '‹‹Open externally››';

  @override
  String get commonSave => '‹‹Save››';

  @override
  String get commonCancel => '‹‹Cancel››';

  @override
  String get commonDone => '‹‹Done››';

  @override
  String get commonDelete => '‹‹Delete››';

  @override
  String get commonEdit => '‹‹Edit››';

  @override
  String get commonSearch => '‹‹Search…››';

  @override
  String get commonNoResults => 'No results';

  @override
  String get commonShare => '‹‹Share››';

  @override
  String get inboxActionPin => '‹‹Pin chat››';

  @override
  String get inboxActionUnpin => '‹‹Unpin chat››';

  @override
  String get inboxActionMute => '‹‹Mute››';

  @override
  String get inboxActionUnmute => '‹‹Unmute››';

  @override
  String get inboxActionMarkRead => '‹‹Mark as read››';

  @override
  String get inboxActionMarkUnread => '‹‹Mark as unread››';

  @override
  String get inboxActionClear => '‹‹Clear messages››';

  @override
  String get inboxActionClearConfirm =>
      '‹‹Delete all messages in this chat? This only clears your copy — the other side keeps theirs.››';

  @override
  String get inboxActionDeleteChat => '‹‹Delete chat››';

  @override
  String get inboxActionDeleteChatConfirm =>
      '‹‹Delete this chat? It disappears from your list and history; it comes back if they message you again.››';

  @override
  String get inboxActionBlock => '‹‹Block contact››';

  @override
  String get inboxActionBlockConfirm =>
      '‹‹Block this contact? They won\'t be able to message you anymore.››';

  @override
  String get cmailActionMarkRead => '‹‹Mark as read››';

  @override
  String get cmailActionMarkUnread => '‹‹Mark as unread››';

  @override
  String get cmailDeleteConfirm => '‹‹Delete this mail from your mailbox?››';

  @override
  String get commonLoading => '‹‹Loading…››';

  @override
  String get commonError => '‹‹Something went wrong››';

  @override
  String get commonTryAgain => '‹‹Try again››';

  @override
  String get studentMaterialsTitle => '‹‹Materials››';

  @override
  String get studentMaterialsEmptyTitle => '‹‹No materials shared yet››';

  @override
  String get studentMaterialsEmptyHint =>
      '‹‹Your teacher will share resources here.››';

  @override
  String get studentMaterialsLoadError => '‹‹Could not load materials››';

  @override
  String get studentAssignmentSubmittedSnackbar => '‹‹Assignment handed in!››';

  @override
  String get studentAssignmentSubmitFailed =>
      '‹‹Could not submit — please try again.››';

  @override
  String get studentAssignmentUploadFailed =>
      '‹‹File upload failed — please try again.››';

  @override
  String get studentAssignmentHandedInBadge => '‹‹Handed in››';

  @override
  String get studentAssignmentSubmitButton => '‹‹Hand in››';

  @override
  String get studentAssignmentSubmitting => '‹‹Handing in…››';

  @override
  String get studentAssignmentAttachFile => '‹‹Attach file››';

  @override
  String get studentAssignmentAddMoreFiles => '‹‹Add more files››';

  @override
  String get studentAssignmentYourSubmission => '‹‹Your submission››';

  @override
  String get studentAssignmentTeacherAttachments => '‹‹Attachments››';

  @override
  String secretaryWelcomeGreeting(Object name) {
    return '‹‹Hi $name 👋››';
  }

  @override
  String get secretaryYourTools => '‹‹Your tools››';

  @override
  String get secretaryReports => '‹‹Reports››';

  @override
  String get secretaryExportData => '‹‹Export Data››';

  @override
  String get secretaryHomeTile => '‹‹Home››';

  @override
  String parentHomeGreeting(Object name) {
    return '‹‹Hi $name 👋››';
  }

  @override
  String get parentYourTools => '‹‹Your tools››';

  @override
  String get parentNoChildLinked => '‹‹No child linked yet››';

  @override
  String get parentPickChildFirst => '‹‹Pick a child first››';

  @override
  String get parentNoApprovedChildren =>
      '‹‹No approved children yet. Ask your school to link your account.››';

  @override
  String get loginEmptyFieldsError =>
      '‹‹Please enter your email or username and password.››';

  @override
  String get loginConnectionError =>
      '‹‹No connection. Check your internet and try again.››';

  @override
  String get loginTimeoutError => '‹‹Request timed out. Please try again.››';

  @override
  String get loginForgotPasswordLink => '‹‹Forgot password?››';

  @override
  String get forgotPasswordTitle => '‹‹Reset your password››';

  @override
  String get forgotPasswordModeEmail => '‹‹Email››';

  @override
  String get forgotPasswordModeSms => '‹‹SMS››';

  @override
  String get forgotPasswordEmailSent =>
      '‹‹Reset link sent (if an account matches).››';

  @override
  String get forgotPasswordEmptyError =>
      '‹‹Enter your email or username to continue.››';

  @override
  String get forgotPasswordEmailButton => '‹‹Email me a reset link››';

  @override
  String get forgotPasswordSmsButton => '‹‹Text me a reset link››';

  @override
  String get forgotPasswordLinkExpires =>
      '‹‹The link expires in 1 hour and can only be used once.››';

  @override
  String get pushPermissionTitle => '‹‹Stay in the loop››';

  @override
  String get pushPermissionBody =>
      '‹‹Turn on notifications so you don\'t miss grades, messages, or schedule changes.››';

  @override
  String commonRequiredField(Object field) {
    return '‹‹$field required››';
  }

  @override
  String get commonAttachments => '‹‹Attachments››';

  @override
  String get commonAttachFile => '‹‹Attach file››';

  @override
  String get commonReplaceFile => '‹‹Replace file››';

  @override
  String get commonTitleRequired => '‹‹Title required››';

  @override
  String get commonPublish => '‹‹Publish››';

  @override
  String get commonContinue => '‹‹Continue››';

  @override
  String get commonNext => '‹‹Next››';

  @override
  String get commonStart => '‹‹Start››';

  @override
  String get commonEnd => '‹‹End››';

  @override
  String get commonRefresh => '‹‹Refresh››';

  @override
  String get commonRemove => '‹‹Remove››';

  @override
  String get commonOpen => '‹‹Open››';

  @override
  String get commonView => '‹‹View››';

  @override
  String get commonCopy => '‹‹Copy››';

  @override
  String get commonAdd => '‹‹Add››';

  @override
  String get commonOptional => '‹‹Optional››';

  @override
  String get commonRequired => '‹‹Required››';

  @override
  String get commonAuto => '‹‹Auto››';

  @override
  String get teacherShareButton => '‹‹Share››';

  @override
  String get teacherMaterialDetails => '‹‹Material Details››';

  @override
  String get teacherMaterialTitleLabel => '‹‹Title *››';

  @override
  String get teacherMaterialDescriptionLabel => '‹‹Description (optional)››';

  @override
  String get teacherMaterialContentSection => '‹‹Content››';

  @override
  String get teacherMaterialContentRequired =>
      '‹‹Please attach a file or add a link››';

  @override
  String teacherFilePickError(Object error) {
    return '‹‹Could not pick file: $error››';
  }

  @override
  String get teacherScheduleButton => '‹‹Schedule››';

  @override
  String get teacherMeetingTitleField => '‹‹Meeting title *››';

  @override
  String get teacherMeetingLinkField => '‹‹Meeting link *››';

  @override
  String get teacherMeetingLinkRequired => '‹‹Meeting link required››';

  @override
  String get teacherMeetingTitleRequired => '‹‹Meeting title required››';

  @override
  String get teacherMeetingDateTimeRequired =>
      '‹‹Start date and time required››';

  @override
  String get teacherMeetingStartDate => '‹‹Start date *››';

  @override
  String get teacherMeetingStartTime => '‹‹Start time *››';

  @override
  String get teacherMeetingEndDate => '‹‹End date (optional)››';

  @override
  String get teacherMeetingEndTime => '‹‹End time (optional)››';

  @override
  String get teacherClearEndTime => '‹‹Clear end time››';

  @override
  String get teacherAssignmentTitleField => '‹‹Title *››';

  @override
  String get teacherAssignmentInstructions => '‹‹Instructions (optional)››';

  @override
  String get teacherAssignmentDueDate => '‹‹Due date (optional)››';

  @override
  String get teacherAssignmentClearDueDate => '‹‹Clear due date››';

  @override
  String get teacherAssignmentMaxGrade => '‹‹Max grade (optional)››';

  @override
  String get teacherAssignmentPublished => '‹‹Assignment published.››';

  @override
  String get teacherAssignmentDraftSaved => '‹‹Draft saved.››';

  @override
  String get teacherCreateAssignment => '‹‹Create››';

  @override
  String get teacherExamSubject => '‹‹Subject *››';

  @override
  String get teacherExamDate => '‹‹Exam date *››';

  @override
  String get teacherSelectSubject => '‹‹Select subject››';

  @override
  String get teacherNoSubjectOption => '‹‹No subject››';

  @override
  String get teacherOtherSubjectOption => '‹‹Other››';

  @override
  String get teacherSearchClassrooms => '‹‹Search classrooms…››';

  @override
  String get teacherSearchMaterials => '‹‹Search materials…››';

  @override
  String get teacherClassroomName => '‹‹Classroom name *››';

  @override
  String get adminReportsOpenTab => '‹‹Open››';

  @override
  String get adminReportsResolvedTab => '‹‹Resolved››';

  @override
  String get adminReportsDismissedTab => '‹‹Dismissed››';

  @override
  String get adminReportsNoOpen => '‹‹No open reports››';

  @override
  String get adminReportsNoInView => '‹‹No reports in this view››';

  @override
  String get adminReportsMediaAttachment => '‹‹[Media attachment]››';

  @override
  String get adminReportsEmptyMessage => '‹‹(empty message)››';

  @override
  String get adminReportsDismiss => '‹‹Dismiss››';

  @override
  String get adminReportsResolve => '‹‹Resolve››';

  @override
  String adminReportsReason(Object reason) {
    return '‹‹Reason: $reason››';
  }

  @override
  String get chatReportTitle => '‹‹Report message››';

  @override
  String get chatReportButton => '‹‹Report››';

  @override
  String get chatReportSuccess =>
      '‹‹Reported. Thank you — an admin will review.››';

  @override
  String chatReportFailed(Object error) {
    return '‹‹Report failed: $error››';
  }

  @override
  String chatSendError(Object message) {
    return '‹‹Couldn\'t send: $message››';
  }

  @override
  String chatForwardLabel(Object count) {
    return '‹‹Forward $count››';
  }

  @override
  String chatDeleteLabel(Object count) {
    return '‹‹Delete $count››';
  }

  @override
  String chatSelectedCount(Object count) {
    return '‹‹$count selected››';
  }

  @override
  String get adminSetupSchoolSetup => '‹‹School Setup››';

  @override
  String get adminSetupComplete =>
      '‹‹You\'re all set. Tap any item to revisit or refine it.››';

  @override
  String get adminSetupInstructions =>
      '‹‹Complete these steps to fully set up your school.››';

  @override
  String get adminSetupLogoTitle => '‹‹Upload school logo››';

  @override
  String get adminSetupLogoSubtitle => '‹‹Appears in headers and the drawer››';

  @override
  String get adminSetupNameTitle => '‹‹Set school name››';

  @override
  String get adminSetupNameSubtitle =>
      '‹‹Shown to students, teachers, and parents››';

  @override
  String get adminSetupSubjectsTitle => '‹‹Define subjects››';

  @override
  String get adminSetupSubjectsSubtitle =>
      '‹‹At least one grade with subjects configured››';

  @override
  String get adminSetupBellTitle => '‹‹Set bell schedule››';

  @override
  String get adminSetupBellSubtitle => '‹‹Start/end times for each period››';

  @override
  String get adminSetupCohortsTitle => '‹‹Create cohorts››';

  @override
  String get adminSetupCohortsSubtitle => '‹‹Set up your class groups››';

  @override
  String get adminSetupStudentsTitle => '‹‹Add students››';

  @override
  String get adminSetupStudentsSubtitle =>
      '‹‹Create accounts or generate join codes››';

  @override
  String get adminSetupTeachersTitle => '‹‹Add teachers››';

  @override
  String get adminSetupTeachersSubtitle => '‹‹Create teacher accounts››';

  @override
  String get supportContactTitle => '‹‹Talk to us››';

  @override
  String get supportContactDescription =>
      '‹‹Can\'t find your answer below? Get in touch and we\'ll come back to you within a working day.››';

  @override
  String get supportEmailLabel => '‹‹Email››';

  @override
  String get supportPhoneLabel => '‹‹Phone››';

  @override
  String get supportSmsLabel => '‹‹Message››';

  @override
  String supportContactCopied(String value) {
    return 'Copied to clipboard: $value';
  }

  @override
  String get supportAiCardTitle => '‹‹Ask NOVA››';

  @override
  String get supportAiCardSubtitle =>
      '‹‹NOVA answers anything about using ClassMate — any time››';

  @override
  String get supportAiSheetTitle => '‹‹NOVA››';

  @override
  String get supportAiGreeting =>
      '‹‹Hi! I\'m NOVA, ClassMate\'s assistant. Ask me anything about using the app — logging in, your schedule, grades, messages, and more.››';

  @override
  String get supportAiInputHint => 'پوښتنه وکړئ…';

  @override
  String get supportAiDisclaimer =>
      'AI ممکن تېروتنې وکړي. د حساب، بلونو یا د ستونزو د راپور لپاره support@classmateapp.org ته برېښنالیک واستوئ.';

  @override
  String get supportAiError =>
      'بښنه غواړو — دا مهال مو ځواب نه شو درکولی. مهرباني وکړئ بیا هڅه وکړئ، یا پورته له ملاتړ سره اړیکه ونیسئ.';

  @override
  String get aboutWhatIsClassmate => '‹‹What is ClassMate?››';

  @override
  String get aboutClassmateDescription =>
      '‹‹ClassMate is the school operating system for students, teachers, administrators, and parents. One app, four roles, every part of the school day in a single place — schedule, attendance, grades, classrooms, assignments, messaging, and an AI study buddy.››';

  @override
  String get aboutMultilingualTitle =>
      '‹‹Built for schools that speak more than one language››';

  @override
  String get aboutMultilingualDescription =>
      '‹‹Every name, subject, and announcement can carry up to five language variants (English, Arabic, Hebrew, French, Russian). Students see the language they\'re most comfortable with; teachers manage in theirs.››';

  @override
  String get aboutPrivacyTitle => '‹‹Privacy first››';

  @override
  String get aboutPrivacyDescription =>
      '‹‹School data stays inside the school. Roles map cleanly onto what each person can see — teachers see their classrooms, admins see their school, parents see their children. No third-party trackers, no ad networks.››';

  @override
  String get aboutContactTitle => '‹‹Contact››';

  @override
  String get aboutContactDescription =>
      '‹‹Built by the ClassMate team.\nQuestions: support@classmateapp.org››';

  @override
  String aboutVersionLabel(Object version) {
    return '‹‹ClassMate · v$version››';
  }

  @override
  String get adminAddStudent => '‹‹Add student››';

  @override
  String get adminAddTeacher => '‹‹Add teacher››';

  @override
  String get adminAddParent => '‹‹Add parent››';

  @override
  String get adminAddSecretary => '‹‹Add secretary››';

  @override
  String get adminAddAdmin => '‹‹Add admin››';

  @override
  String get adminEditUser => '‹‹Edit user››';

  @override
  String get adminNoEmailPlaceholder => '‹‹(no email)››';

  @override
  String get adminNameEnglishRequired => '‹‹Full name (English) is required››';

  @override
  String get adminUsernameRequired => '‹‹Username is required››';

  @override
  String get adminPasswordMinLength =>
      '‹‹Password must be at least 8 characters (or leave blank to auto-generate)››';

  @override
  String adminUserCreatedMsg(Object name) {
    return '‹‹$name created.››';
  }

  @override
  String get adminCredsUsername => '‹‹Username››';

  @override
  String get adminCredsEmail => '‹‹Email››';

  @override
  String get adminCredsPassword => '‹‹Password››';

  @override
  String get adminShareCredsHint =>
      '‹‹Share these credentials with the student.››';

  @override
  String get adminCopyCredsButton => '‹‹Copy All››';

  @override
  String get adminGradeLabel => '‹‹Grade››';

  @override
  String adminCohortGradeFormat(Object grade) {
    return '‹‹Grade $grade››';
  }

  @override
  String get adminCreateAndAddStudents => '‹‹Create & Add Students››';

  @override
  String get adminAddStudentsTitle => '‹‹Add Students››';

  @override
  String get adminSkipAdding => '‹‹Skip››';

  @override
  String get adminInCohortBadge => '‹‹In cohort››';

  @override
  String get adminNoStudentsFoundCohort =>
      '‹‹No students found in this cohort\'s grades››';

  @override
  String get adminScheduleByCohort => '‹‹By Cohort ▾››';

  @override
  String get adminScheduleByStudent => '‹‹By Student ▾››';

  @override
  String get adminScheduleByGrade => '‹‹By Grade ▾››';

  @override
  String get navSupport => '‹‹Support››';

  @override
  String get navAbout => '‹‹About››';

  @override
  String get adminScheduleAddGrade => '‹‹Add grade››';

  @override
  String get adminScheduleAddCohort => '‹‹Add cohort››';

  @override
  String get adminScheduleAddStudent => '‹‹Add student››';

  @override
  String get adminScheduleClearFilters => '‹‹Clear››';

  @override
  String get adminSchedulePickSubjectRequired =>
      '‹‹Pick a subject before saving the period.››';

  @override
  String get adminSchedulePickDateOnce =>
      '‹‹Pick a date for a one-off period.››';

  @override
  String adminSchedulePickDateRecurring(Object freq) {
    return '‹‹Pick a start date for the every-$freq-weeks schedule.››';
  }

  @override
  String get adminSchoolLogoLabel => '‹‹School Logo››';

  @override
  String get adminSchoolLogoUploaded => '‹‹Logo uploaded››';

  @override
  String get adminSchoolNoLogoYet => '‹‹No logo yet››';

  @override
  String get adminSchoolLogoDescription =>
      '‹‹Appears next to your school name in the app drawer.››';

  @override
  String get adminSchoolLogoChange => '‹‹Change››';

  @override
  String get adminSchoolLogoUpload => '‹‹Upload››';

  @override
  String get adminSchoolLogoRemove => '‹‹Remove››';

  @override
  String get adminSchoolGradeRangeLabel => '‹‹Grade range››';

  @override
  String get adminSchoolGradeRangeDescription =>
      '‹‹Grades available across cohorts, students, and pickers.››';

  @override
  String get adminSchoolLowestGrade => '‹‹Lowest››';

  @override
  String get adminSchoolHighestGrade => '‹‹Highest››';

  @override
  String get adminSchoolSubjectsTitle => '‹‹School Subjects››';

  @override
  String get adminSchoolSubjectsDescription =>
      '‹‹Available to all teachers when creating assignments.››';

  @override
  String get adminSchoolNoTranslations => '‹‹Tap to add translations››';

  @override
  String get adminSchoolBellHint =>
      '‹‹Set start and end times for each period. Add or remove periods as needed.››';

  @override
  String get adminSchoolBellTitle => '‹‹Bell Schedule››';

  @override
  String get adminSchoolBellInfo =>
      '‹‹Set the start and end time for each period. These become the default times used when building the weekly schedule.››';

  @override
  String get adminSchoolStartTime => '‹‹Start››';

  @override
  String get adminSchoolEndTime => '‹‹End››';

  @override
  String get adminExportStudentsTab => '‹‹Students››';

  @override
  String get adminExportCohortsTab => '‹‹Cohorts››';

  @override
  String get adminExportGradesTab => '‹‹Grades››';

  @override
  String get adminExportOptionsTitle => '‹‹Export Options››';

  @override
  String get adminExportIncludePasswords => '‹‹Include Passwords››';

  @override
  String get adminExportLanguageLabel => '‹‹Name language in the export››';

  @override
  String get adminExportCsvButton => '‹‹Export CSV››';

  @override
  String get adminExportPdfButton => '‹‹Export PDF››';

  @override
  String get teacherCreateClassroomTooltip => '‹‹Create classroom››';

  @override
  String get teacherClassroomNameRequired => '‹‹Classroom name *››';

  @override
  String get teacherSubjectRequired => '‹‹Subject *››';

  @override
  String messagesStartChatError(Object error) {
    return '‹‹Could not start chat: $error››';
  }

  @override
  String messagesNoPeopleMatch(Object query) {
    return '‹‹No people match \"$query\"››';
  }

  @override
  String get messagesNoPeopleFound => '‹‹No people found››';

  @override
  String messagesPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get studentAssignmentValidationRequired =>
      '‹‹Add a note or attach a file before handing in.››';

  @override
  String get studentFormSubmittedBanner => '‹‹Your submitted answers››';

  @override
  String studentFormSubmitError(Object error) {
    return '‹‹Could not submit: $error››';
  }

  @override
  String studentFormFieldRequired(Object field) {
    return '‹‹Required: $field››';
  }

  @override
  String get studentFormClosedButton => '‹‹Form closed››';

  @override
  String get studentFormAlreadySubmittedButton => '‹‹Already submitted››';

  @override
  String get studentDiplomaEditTitle => '‹‹Edit Certificate››';

  @override
  String get studentDiplomaDeleteTitle => '‹‹Delete certificate?››';

  @override
  String studentDiplomaDeleteConfirm(Object name) {
    return '‹‹Remove certificate for \"$name\"?››';
  }

  @override
  String teacherDeleteItemConfirm(Object title) {
    return '‹‹Delete \"$title\"?››';
  }

  @override
  String get teacherPublishTooltip => '‹‹Publish››';

  @override
  String get teacherMeetingEnterTitle => '‹‹Please enter a title.››';

  @override
  String get teacherMeetingEnterLink => '‹‹Please enter a meeting link.››';

  @override
  String get teacherMeetingEnterValidUrl =>
      '‹‹Please enter a valid URL (e.g. https://zoom.us/j/...)››';

  @override
  String get teacherMeetingPickStartTime => '‹‹Please pick a start time.››';

  @override
  String get teacherMeetingVisibleToEveryone => '‹‹Visible to everyone››';

  @override
  String teacherMeetingDoneCount(int count) {
    return '‹‹Done ($count selected)››';
  }

  @override
  String get teacherDeleteAssignmentTitle => '‹‹Delete assignment?››';

  @override
  String get teacherDeleteAssignmentBody =>
      '‹‹This will permanently delete the assignment and all submissions.››';

  @override
  String get teacherEditTooltip => '‹‹Edit››';

  @override
  String get teacherDeleteTooltip => '‹‹Delete››';

  @override
  String get teacherClassroomBackTooltip => '‹‹Back››';

  @override
  String teacherClassroomGenericError(Object error) {
    return '‹‹Error: $error››';
  }

  @override
  String teacherClassroomAttachFailed(Object error) {
    return '‹‹Attach failed: $error››';
  }

  @override
  String get teacherClassroomFileUnavailable =>
      '‹‹This file is not available — the teacher should re-upload it.››';

  @override
  String get teacherClassroomCodeLabel => '‹‹Classroom code››';

  @override
  String get teacherClassroomCodeCopied => '‹‹Code copied››';

  @override
  String get teacherClassroomCopyCodeTooltip => '‹‹Copy code››';

  @override
  String teacherClassroomCouldNotAdd(Object emails) {
    return '‹‹Could not add: $emails — check their email address.››';
  }

  @override
  String get teacherClassroomAddStudents => '‹‹Add students››';

  @override
  String get teacherClassroomSearchNameGrade => '‹‹Search by name or grade…››';

  @override
  String get teacherClassroomNoStudentsFound => '‹‹No students found››';

  @override
  String get teacherClassroomNameSubjectRequired =>
      '‹‹Name and subject are required.››';

  @override
  String get teacherClassroomCreated => '‹‹Classroom created!››';

  @override
  String get teacherCustomSubjectLabel => '‹‹Custom subject *››';

  @override
  String get teacherCreateClassroomButton => '‹‹Create Classroom››';

  @override
  String get teacherCreateFormTitle => '‹‹Create Form››';

  @override
  String get teacherFormSaveDraft => '‹‹Save Draft››';

  @override
  String get teacherFormTitleHint => '‹‹Form title *››';

  @override
  String get teacherFormDescriptionHint => '‹‹Description (optional)››';

  @override
  String get teacherFormAcceptingResponses => '‹‹Accepting responses››';

  @override
  String get teacherFormAllowMultiple => '‹‹Allow multiple responses››';

  @override
  String get teacherFormAllowMultipleSubtitle =>
      '‹‹Off = once per student (default)››';

  @override
  String get teacherFormQuestionsSection => '‹‹Questions››';

  @override
  String get teacherFormAddQuestionButton => '‹‹Add question››';

  @override
  String teacherFormQuestionPlaceholder(Object index) {
    return '‹‹Question $index››';
  }

  @override
  String get teacherFormRequiredToggle => '‹‹Required››';

  @override
  String get teacherFormAddOptionButton => '‹‹Add option››';

  @override
  String get teacherFormMinLabel => '‹‹Min››';

  @override
  String get teacherFormMaxLabel => '‹‹Max››';

  @override
  String get teacherFormEnterTitle => '‹‹Please enter a form title.››';

  @override
  String teacherExamUploadFailedSkipped(Object name) {
    return '‹‹Upload failed for $name. File skipped.››';
  }

  @override
  String get teacherExamEnterTitle => '‹‹Please enter a title.››';

  @override
  String get teacherExamPickDate => '‹‹Please pick an exam date.››';

  @override
  String get teacherExamSelectSubject => '‹‹Please select a subject.››';

  @override
  String teacherSlotDetachFailed(Object error) {
    return '‹‹Detach failed: $error››';
  }

  @override
  String teacherSlotAttachFailed(Object error) {
    return '‹‹Attach failed: $error››';
  }

  @override
  String get teacherSlotAttachMaterial => '‹‹Attach material››';

  @override
  String get teacherSlotDetachTooltip => '‹‹Detach››';

  @override
  String get teacherDiplomaSelectStudent => '‹‹Select a student first.››';

  @override
  String get teacherDiplomaUploadingWait =>
      '‹‹Please wait — files are still uploading.››';

  @override
  String teacherDiplomaIssueFailed(Object error) {
    return '‹‹Failed to issue certificate: $error››';
  }

  @override
  String get teacherDiplomaCertTitleLabel => '‹‹Certificate title››';

  @override
  String get teacherDiplomaSearchStudent => '‹‹Search student…››';

  @override
  String get teacherProfileChatError => '‹‹Could not start chat››';

  @override
  String get teacherGradeAssignmentType => '‹‹Assignment››';

  @override
  String get teacherGradeExamType => '‹‹Exam››';

  @override
  String get teacherGradeOtherType => '‹‹Other››';

  @override
  String get teacherGradeOutOfLabel => '‹‹Out of (optional)››';

  @override
  String get teacherGradePublishedTitle => '‹‹Published››';

  @override
  String get teacherGradePublishedSubtitle => '‹‹Students can see this grade››';

  @override
  String get teacherMaterialPickSubject => '‹‹Please select a subject.››';

  @override
  String get teacherMaterialAddLink => '‹‹Add link››';

  @override
  String get teacherMaterialAddFile => '‹‹Add file››';

  @override
  String get teacherMaterialSearchStudentsGrade =>
      '‹‹Search students or grade...››';

  @override
  String teacherMaterialDoneSelected(int count) {
    return '‹‹Done ($count selected)››';
  }

  @override
  String get adminSubjectEnglishNameRequired => '‹‹English name is required››';

  @override
  String adminSubjectNameInLang(Object language) {
    return '‹‹Name in $language››';
  }

  @override
  String get adminSubjectResetButton => '‹‹Reset››';

  @override
  String get teacherAnnounceBroadcastTitle => '‹‹Broadcast to everyone?››';

  @override
  String get teacherAnnounceSendToEveryone => '‹‹Send to everyone››';

  @override
  String get teacherAnnounceNoCohorts => '‹‹No cohorts available››';

  @override
  String get teacherAnnounceNothingFound => '‹‹Nothing found››';

  @override
  String get teacherAnnounceNoParents => '‹‹No parents found at this school.››';

  @override
  String get teacherGradesToGrade => '‹‹To grade››';

  @override
  String get teacherGradesGraded => '‹‹Graded››';

  @override
  String get teacherSaveGradesButton => '‹‹Save Grades››';

  @override
  String get teacherAllowResubmitLabel => '‹‹Allow re-submit››';

  @override
  String get teacherAllowResubmitTitle => '‹‹Allow re-submit?››';

  @override
  String teacherAllowResubmitBody(Object name) {
    return '‹‹This will delete $name\'s submission so they can hand in again.››';
  }

  @override
  String get teacherAllowButton => '‹‹Allow››';

  @override
  String get teacherGradeFieldLabel => '‹‹Grade››';

  @override
  String get teacherFeedbackOptionalLabel => '‹‹Feedback (optional)››';

  @override
  String get teacherCreateClassroomFabLabel => '‹‹Create››';

  @override
  String get teacherLoadingStudents => '‹‹Loading students…››';

  @override
  String get teacherSearchHintShort => '‹‹Search…››';

  @override
  String get teacherCreateClassroomTitle => '‹‹New Classroom››';

  @override
  String teacherAssignmentUploadFailed(Object name) {
    return '‹‹Could not upload $name››';
  }

  @override
  String get teacherAssignmentEnterTitle => '‹‹Please enter a title.››';

  @override
  String get teacherAssignmentSelectSubject => '‹‹Please select a subject.››';

  @override
  String get teacherAssignmentInstructionsLabel =>
      '‹‹Instructions / Description››';

  @override
  String get teacherAttachFilesButton => '‹‹Attach files››';

  @override
  String get tutorDeleteConversationTitle => '‹‹Delete conversation?››';

  @override
  String get tutorDeleteConversationButton => '‹‹Delete permanently››';

  @override
  String tutorDeleteFailed(Object error) {
    return '‹‹Could not delete: $error››';
  }

  @override
  String get tutorDeleteMenuTitle => '‹‹Delete conversation››';

  @override
  String get tutorDeleteMenuSubtitle =>
      '‹‹Permanently removes it from the server››';

  @override
  String get accountVerifyButton => '‹‹Verify››';

  @override
  String get accountConfirmButton => '‹‹Confirm››';

  @override
  String get accountResendCode => '‹‹Resend code››';

  @override
  String get accountCodeResent => '‹‹Sent a fresh code.››';

  @override
  String get accountContinueButton => '‹‹Continue››';

  @override
  String get studentClassroomFileUnavailable =>
      '‹‹This file is not yet available.››';

  @override
  String get studentClassroomDeleteMaterial => '‹‹Delete material?››';

  @override
  String get studentClassroomCodeLabel => '‹‹Classroom code››';

  @override
  String get studentClassroomLeaveTooltip => '‹‹Leave classroom››';

  @override
  String get adminEditUserEnglishNameRequired => '‹‹English name required››';

  @override
  String get adminEditUserSaved => '‹‹Saved››';

  @override
  String adminEditUserPasswordChanged(Object name) {
    return '‹‹Password changed for $name.››';
  }

  @override
  String get adminEditUserLoginSection => '‹‹Login››';

  @override
  String get adminEditUserUsernameLabel => '‹‹Username››';

  @override
  String get adminEditUserEmailOptional => '‹‹Email (optional)››';

  @override
  String get adminEditUserChangePassword => '‹‹Change password››';

  @override
  String get adminEditUserNameSection => '‹‹Name››';

  @override
  String get adminEditUserAtLeastEnglish => '‹‹At least English required.››';

  @override
  String get adminEditUserGradeSection => '‹‹Grade››';

  @override
  String get adminEditUserCohortsSection => '‹‹Cohorts››';

  @override
  String get adminEditUserLinkedChildren => '‹‹Linked Children››';

  @override
  String get adminEditUserLinkButton => '‹‹Link››';

  @override
  String get adminEditUserNoChildren => '‹‹No children linked yet.››';

  @override
  String get adminEditUserSetPasswordTitle => '‹‹Set new password››';

  @override
  String get adminEditUserNewPasswordLabel => '‹‹New password››';

  @override
  String get adminEditUserConfirmPasswordLabel => '‹‹Confirm password››';

  @override
  String get adminEditUserSetPasswordButton => '‹‹Set password››';

  @override
  String get adminPeriodsTitle => '‹‹Manage Periods››';

  @override
  String get adminPeriodsAddPeriod => '‹‹Add Period››';

  @override
  String get adminPeriodsNoPeriods => '‹‹No periods yet››';

  @override
  String get adminPeriodsTapToAdd => '‹‹Tap + to add the first period››';

  @override
  String get adminPeriodsNewPeriod => '‹‹New Period››';

  @override
  String get adminPeriodsDayLabel => '‹‹Day››';

  @override
  String get adminPeriodsPeriodLabel => '‹‹Period››';

  @override
  String get adminPeriodsTimeLabel => '‹‹Time››';

  @override
  String get adminPeriodsTeacherLabel => '‹‹Teacher››';

  @override
  String get adminPeriodsClassroomOptional => '‹‹Classroom (optional)››';

  @override
  String get adminPeriodsCohortsLabel => '‹‹Cohorts››';

  @override
  String get adminPeriodsStudentsOptional => '‹‹Students (optional)››';

  @override
  String get adminPeriodsSearchByName => '‹‹Search by name…››';

  @override
  String commonErrorWith(Object error) {
    return '‹‹Error: $error››';
  }

  @override
  String commonAddCount(int count) {
    return '‹‹Add $count››';
  }

  @override
  String get teacherStudentGradesSaved => '‹‹Grades saved››';

  @override
  String get teacherStudentToGrade => '‹‹To grade››';

  @override
  String get teacherStudentGraded => '‹‹Graded››';

  @override
  String get classroomFileNotAvailable => '‹‹This file is not yet available.››';

  @override
  String get classroomDeleteMaterialTitle => '‹‹Delete material?››';

  @override
  String get classroomCodeLabel => '‹‹Classroom code››';

  @override
  String get plansCouldNotOpenSubscription =>
      '‹‹Could not open subscription settings.››';

  @override
  String plansFailedToOpen(Object error) {
    return '‹‹Failed to open: $error››';
  }

  @override
  String get plansManageSubscription => '‹‹Manage or cancel subscription››';

  @override
  String get plansUpgrade => '‹‹Upgrade››';

  @override
  String get plansTryAgain => '‹‹Try again››';

  @override
  String adminCohortsGradeOnly(String grade) {
    return '‹‹Grade $grade only››';
  }

  @override
  String adminCohortsGradeRangeOnly(int from, int to) {
    return '‹‹Grade $from-$to only››';
  }

  @override
  String get adminExportNeedStudents =>
      '‹‹Select at least one student or cohort first››';

  @override
  String adminExportButton(int count) {
    return '‹‹Export $count››';
  }

  @override
  String get adminExportNoStudents => '‹‹No students found››';

  @override
  String get adminExportIncludesPasswords =>
      '‹‹Export will reset & include passwords››';

  @override
  String get adminExportAnyway => '‹‹Export anyway››';

  @override
  String get adminExportPdfStudentDirectory => '‹‹Student Directory››';

  @override
  String adminExportPdfBy(String name) {
    return '‹‹By: $name››';
  }

  @override
  String adminExportPdfStudentsCount(int count) {
    return '‹‹$count students››';
  }

  @override
  String get adminExportPdfFooter => '‹‹Generated by ClassMate››';

  @override
  String get adminExportColumnIndex => '‹‹#››';

  @override
  String get adminExportColumnName => '‹‹Name››';

  @override
  String get adminExportColumnEmail => '‹‹Email››';

  @override
  String get adminExportColumnUsername => '‹‹Username››';

  @override
  String get adminExportColumnPhone => '‹‹Phone››';

  @override
  String get adminExportColumnGrade => '‹‹Grade››';

  @override
  String get adminExportColumnCohorts => '‹‹Cohorts››';

  @override
  String get adminExportColumnSchool => '‹‹School››';

  @override
  String get adminExportColumnPassword => '‹‹Password››';

  @override
  String get adminExportColumnNameEn => '‹‹Name (EN)››';

  @override
  String get adminExportColumnNameAr => '‹‹Name (AR)››';

  @override
  String get adminExportColumnNameHe => '‹‹Name (HE)››';

  @override
  String get adminExportColumnNameFr => '‹‹Name (FR)››';

  @override
  String get adminExportColumnNameRu => '‹‹Name (RU)››';

  @override
  String adminExportStudentsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students selected',
      one: '$count student selected',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get teacherMaterialEditTitle => '‹‹Edit Material››';

  @override
  String get teacherMaterialAddTitle => '‹‹Add Material››';

  @override
  String get teacherMaterialAudienceTitle => '‹‹Audience››';

  @override
  String get teacherMaterialAudienceClassrooms => '‹‹Classrooms››';

  @override
  String get teacherMaterialAudienceCohorts => '‹‹Cohorts››';

  @override
  String get teacherMaterialAudienceGrades => '‹‹Grades››';

  @override
  String get teacherMaterialAudienceStudents => '‹‹Students››';

  @override
  String get teacherMaterialDetailsTitle => '‹‹Details››';

  @override
  String get teacherMaterialSubjectRequired => '‹‹Subject *››';

  @override
  String get teacherMaterialSubjectSelect => '‹‹Select subject››';

  @override
  String get teacherMaterialSubjectOther => '‹‹Other››';

  @override
  String get teacherMaterialSubjectSearch => '‹‹Search subjects...››';

  @override
  String get teacherMaterialAttachmentsTitle => '‹‹Attachments››';

  @override
  String teacherMaterialAttachmentsWithCount(int count) {
    return '‹‹Attachments ($count)››';
  }

  @override
  String get teacherMaterialDeleteTitle => '‹‹Delete material?››';

  @override
  String get teacherMaterialListTitle => '‹‹Materials››';

  @override
  String teacherMaterialTotalCount(int count) {
    return '‹‹$count total››';
  }

  @override
  String get teacherMaterialRetry => '‹‹Retry››';

  @override
  String get teacherMaterialNoMaterials =>
      '‹‹No materials yet.\nTap + to add one.››';

  @override
  String get teacherMaterialPublished => '‹‹Published››';

  @override
  String get teacherMaterialDraft => '‹‹Draft››';

  @override
  String get teacherMaterialSearchHint => '‹‹Search…››';

  @override
  String teacherMaterialSelectedCount(int count) {
    return '‹‹$count selected››';
  }

  @override
  String teacherMaterialMembersWillReceive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members will receive this',
      one: '$count member will receive this',
    );
    return '‹‹$_temp0››';
  }

  @override
  String teacherMaterialStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students',
      one: '$count student',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get teacherMaterialPickerNone => '‹‹None››';

  @override
  String get teacherMaterialPickerCohortsTitle => '‹‹Select cohorts››';

  @override
  String get teacherMaterialPickerClassroomTitle => '‹‹Select classroom››';

  @override
  String get teacherMaterialPickerStudentsTitle => '‹‹Select students››';

  @override
  String get teacherMaterialPickerGradesTitle => '‹‹Select grades››';

  @override
  String get adminScheduleAddNew => '‹‹Add new››';

  @override
  String adminScheduleAddCount(int count) {
    return '‹‹Add ($count)››';
  }

  @override
  String get adminScheduleCaptionOptional => '‹‹Caption (optional)››';

  @override
  String get adminScheduleCaptionHint => '‹‹e.g. Exam review››';

  @override
  String get adminScheduleAudienceCohorts => '‹‹Cohorts››';

  @override
  String get adminScheduleAudienceStudents => '‹‹Students››';

  @override
  String get adminScheduleAudienceGrade => '‹‹Grade››';

  @override
  String get adminScheduleSearchStudents => '‹‹Search students…››';

  @override
  String get adminScheduleSearchSubjects => '‹‹Search school subjects…››';

  @override
  String get adminScheduleEveryPrefix => '‹‹Every ››';

  @override
  String get adminScheduleWeeksSuffix => '‹‹ weeks››';

  @override
  String adminScheduleSlotN(int index) {
    return '‹‹Slot $index››';
  }

  @override
  String adminScheduleSelectedCount(int count) {
    return '‹‹$count selected››';
  }

  @override
  String get adminScheduleConflictingPeriod => '‹‹Conflicting period››';

  @override
  String get adminScheduleKeepCurrent => '‹‹Keep current››';

  @override
  String get adminScheduleOverride => '‹‹Override››';

  @override
  String get adminScheduleShowBoth => '‹‹Show both››';

  @override
  String get adminScheduleDeletePeriodTitle => '‹‹Delete period?››';

  @override
  String get adminScheduleDeletePeriodBody =>
      '‹‹This removes the slot from the schedule. Past attendance stays.››';

  @override
  String get adminScheduleFailedToDelete => '‹‹Failed to delete period.››';

  @override
  String get adminSchedulePickSubjectFirst =>
      '‹‹Pick a subject before saving the period.››';

  @override
  String adminScheduleOverrideFailed(Object error) {
    return '‹‹Override failed: $error››';
  }

  @override
  String get adminScheduleFailedToCreateSlots => '‹‹Failed to create slots››';

  @override
  String adminScheduleCreatedSlots(int created, int total, String error) {
    return '‹‹Created $created/$total slots. $error››';
  }

  @override
  String adminScheduleSavedLabelOnlyError(Object error) {
    return '‹‹Saved as slot label only — couldn\'t add to library: $error››';
  }

  @override
  String get adminScheduleSavedLabelPickAudience =>
      '‹‹Saved as slot label. Pick an audience first to also add to the school library.››';

  @override
  String get commonNothingFound => '‹‹Nothing found››';

  @override
  String commonDownloadFailed(Object error) {
    return '‹‹Download failed: $error››';
  }

  @override
  String commonFailedWith(Object error) {
    return '‹‹Failed: $error››';
  }

  @override
  String get commonCreate => '‹‹Create››';

  @override
  String get commonAttachStudyMaterials => '‹‹Attach study materials››';

  @override
  String get teacherCreateClassroomNewTitle => '‹‹New Classroom››';

  @override
  String get teacherCreateClassroomLoadingStudents => '‹‹Loading students…››';

  @override
  String get teacherExamPublishedHint =>
      '‹‹Published — students can see this exam››';

  @override
  String teacherDoneSelected(int count) {
    return '‹‹Done ($count selected)››';
  }

  @override
  String get secretaryAllCohorts => '‹‹All cohorts››';

  @override
  String get secretaryClassrooms => '‹‹Classrooms››';

  @override
  String get adminPeopleGrade => '‹‹Grade››';

  @override
  String get adminSchoolSettingsTapToAddTranslations =>
      '‹‹Tap to add translations››';

  @override
  String adminSchoolSettingsAddPeriodNum(int num) {
    return '‹‹Add Period (P$num)››';
  }

  @override
  String get adminVisibleToEveryone => '‹‹Visible to everyone››';

  @override
  String get navMaterials => '‹‹Materials››';

  @override
  String get classMaterialsAddTitle => '‹‹Add material››';

  @override
  String get classMaterialsTitleLabel => '‹‹Title››';

  @override
  String get classMaterialsTitleHint => 'e.g. Chapter 3 worksheet';

  @override
  String classMaterialsFilesCount(int count) {
    return '‹‹$count files››';
  }

  @override
  String get classMaterialsLoadError => '‹‹Couldn\'t load materials››';

  @override
  String get classMaterialsEmpty =>
      '‹‹No materials yet — tap Add to share one.››';

  @override
  String get navPlans => '‹‹NOVA Plans››';

  @override
  String get navReports => '‹‹Reports››';

  @override
  String get navExportData => '‹‹Export Data››';

  @override
  String get sectionSecretaryTools => '‹‹Secretary Tools››';

  @override
  String get sectionSchoolToolsLabel => '‹‹School Tools››';

  @override
  String get sectionAdminTools => '‹‹Admin Tools››';

  @override
  String get chatVideoTrimTitle => '‹‹Trim video››';

  @override
  String get chatMediaPreviewTrimAction => '‹‹Trim››';

  @override
  String get commonUntitled => '‹‹Untitled››';

  @override
  String get plansMonthlyPlans => '‹‹Monthly plans››';

  @override
  String get plansTokenTopups => '‹‹Token top-ups››';

  @override
  String get plansTopupsSubtitle =>
      '‹‹One-time purchases. Never expire. Stack on top of your plan.››';

  @override
  String get plansCouldntLoadBalance => '‹‹Couldn\'t load your balance››';

  @override
  String get plansFreePlan => '‹‹Free plan››';

  @override
  String get planTierFree => '‹‹Free››';

  @override
  String get planTierBudget => '‹‹Budget››';

  @override
  String get planTierBalance => '‹‹Balance››';

  @override
  String get planTierCommitment => '‹‹Commitment››';

  @override
  String get topupPackSmall => '‹‹Small pack››';

  @override
  String get topupPackMedium => '‹‹Medium pack››';

  @override
  String get topupPackLarge => '‹‹Large pack››';

  @override
  String get topupPackMega => '‹‹Mega pack››';

  @override
  String get planBlurbFree => '‹‹Get a taste of NOVA. Resets every month.››';

  @override
  String get planBlurbBudget => '‹‹Daily homework help.››';

  @override
  String get planBlurbBalance => '‹‹For students who study every day.››';

  @override
  String get planBlurbCommitment => '‹‹Heavy practice + unlimited curiosity.››';

  @override
  String plansTokensPerMonth(String tokens) {
    return '‹‹$tokens tokens / month››';
  }

  @override
  String plansTokensOneTime(String tokens) {
    return '‹‹$tokens tokens››';
  }

  @override
  String get planPriceFree => '‹‹Free››';

  @override
  String get plansTokensRemaining => '‹‹tokens remaining››';

  @override
  String plansPlanResetsAt(String when) {
    return '‹‹Plan resets $when››';
  }

  @override
  String plansTopupTokensInfo(String tokens) {
    return '‹‹$tokens top-up tokens (no expiry)››';
  }

  @override
  String get plansHowTokensWorkTitle => '‹‹How tokens work››';

  @override
  String get plansHowTokensWorkBody =>
      '‹‹Tokens are how AI counts its work.\n• A short question ≈ 2,000 tokens\n• A long explanation or practice session ≈ 5,000–10,000\n• Image analysis costs a bit more\n\nYour monthly tokens reset on the 1st. Top-up tokens never expire.››';

  @override
  String get plansPerMonthSuffix => '‹‹ / mo››';

  @override
  String get plansCurrentBadge => '‹‹CURRENT››';

  @override
  String get plansCouldntLoadPlans => '‹‹Couldn\'t load plans››';

  @override
  String get paywallPlansUnavailable =>
      '‹‹Plans unavailable. Try again in a moment.››';

  @override
  String get paywallTopupUnavailable =>
      '‹‹Top-up unavailable. The store hasn\'t finished approving this product.››';

  @override
  String get paywallRestored => '‹‹Your subscription was restored.››';

  @override
  String get paywallNoRestores =>
      '‹‹No previous purchases found on this Apple ID.››';

  @override
  String paywallRestoreFailed(String error) {
    return '‹‹Restore failed: $error››';
  }

  @override
  String get paywallPurchasesRestricted =>
      '‹‹Purchases are restricted on this device.››';

  @override
  String get paywallPurchaseInvalid =>
      '‹‹This purchase isn\'t valid. Try a different payment method.››';

  @override
  String get paywallProductNotAvailable =>
      '‹‹This plan isn\'t available right now. Try again later.››';

  @override
  String get paywallNetworkError =>
      '‹‹Network issue. Check your connection and try again.››';

  @override
  String get paywallPaymentPending =>
      '‹‹Payment is pending approval (parental controls, etc.). It\'ll activate once approved.››';

  @override
  String get paywallStoreProblem =>
      '‹‹The App Store had a problem. Try again in a minute.››';

  @override
  String get paywallGenericError => '‹‹Something went wrong. Try again.››';

  @override
  String paywallWelcomeMessage(String plan) {
    return '‹‹Welcome to $plan! Tokens are on the way.››';
  }

  @override
  String get paywallWelcomeFallback => '‹‹your new plan››';

  @override
  String get paywallTopupAdded => '‹‹Top-up added. Tokens are on the way.››';

  @override
  String get paywallPurchaseProcessed =>
      '‹‹Purchase processed. Tokens will appear shortly.››';

  @override
  String paywallSubscribeTo(String plan) {
    return '‹‹Subscribe to $plan››';
  }

  @override
  String paywallBuyTopupNamed(String topup) {
    return '‹‹Buy $topup››';
  }

  @override
  String get paywallPlanFallback => '‹‹plan››';

  @override
  String get paywallTopupFallback => '‹‹top-up››';

  @override
  String get paywallTopupBlurb =>
      '‹‹One-time purchase. Tokens never expire and stack on top of your plan.››';

  @override
  String paywallPerMonthWithTokens(String tokens) {
    return '‹‹per month · $tokens››';
  }

  @override
  String paywallOneTimeWithTokens(String tokens) {
    return '‹‹one-time · $tokens››';
  }

  @override
  String get paywallSubscribeButton => '‹‹Subscribe››';

  @override
  String get paywallBuyButton => '‹‹Buy››';

  @override
  String get paywallRestoreButton => '‹‹Restore purchases››';

  @override
  String get paywallNotNow => '‹‹Not now››';

  @override
  String get paywallWebOnlyTitle => '‹‹Purchase on mobile››';

  @override
  String get paywallWebOnlyBody =>
      '‹‹Subscriptions and top-ups go through the App Store or Google Play. Open ClassMate on your iPhone, iPad, or Android phone to subscribe — your account and tokens are shared across devices.››';

  @override
  String get paywallWebOnlyDismiss => '‹‹Got it››';

  @override
  String get paywallTermsSubscription =>
      '‹‹By subscribing you agree to ClassMate\'s Terms and Privacy Policy. Subscriptions auto-renew monthly until cancelled. Manage anytime in your App Store account.››';

  @override
  String get paywallTermsTopup =>
      '‹‹By purchasing you agree to ClassMate\'s Terms and Privacy Policy. Top-up tokens are non-refundable once consumed.››';

  @override
  String get paywallTermsLink => '‹‹Terms of Use (EULA)››';

  @override
  String get paywallPrivacyLink => '‹‹Privacy Policy››';

  @override
  String get paywallFeatureTokens =>
      '‹‹Use tokens across NOVA chat and Practice sessions››';

  @override
  String get paywallFeatureImages =>
      '‹‹Image analysis and file upload included››';

  @override
  String get paywallFeatureReset =>
      '‹‹Tokens reset at the start of each month››';

  @override
  String get paywallFeatureCancel => '‹‹Cancel anytime — no commitment››';

  @override
  String get studentMaterialsGeneralSubject => '‹‹General››';

  @override
  String studentMaterialsResourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resources from your teachers',
      one: '$count resource from your teachers',
    );
    return '‹‹$_temp0››';
  }

  @override
  String classroomsCouldNotLoadWithError(String error) {
    return '‹‹Could not load classrooms\n$error››';
  }

  @override
  String get parentNoNotificationsYet => '‹‹No notifications yet.››';

  @override
  String forwardCouldNotLoadChats(Object error) {
    return '‹‹Could not load chats: $error››';
  }

  @override
  String get forwardNoChats => '‹‹No chats››';

  @override
  String get commonTitle => '‹‹Title››';

  @override
  String get commonNotes => '‹‹Notes››';

  @override
  String get commonEmail => '‹‹Email››';

  @override
  String get commonPassword => '‹‹Password››';

  @override
  String get commonNumberOfPages => '‹‹Number of pages››';

  @override
  String get messagesSearchByNameOrGrade => '‹‹Search by name or grade…››';

  @override
  String get meetingStartDateRequired => '‹‹Start date *››';

  @override
  String get meetingStartTimeRequired => '‹‹Start time *››';

  @override
  String get meetingEndDateOptional => '‹‹End date (optional)››';

  @override
  String get meetingEndTimeOptional => '‹‹End time (optional)››';

  @override
  String get teacherMaterialLinkUrlOptional => '‹‹Link / URL (optional)››';

  @override
  String get teacherSearchStudentsOrGrade => '‹‹Search students or grade…››';

  @override
  String get teacherSearchParentsOrChildren =>
      '‹‹Search parents or children…››';

  @override
  String get studentAssignmentAddNoteOptional => '‹‹Add a note (optional)…››';

  @override
  String get adminEditUserUsernameRequired => '‹‹Username *››';

  @override
  String get reportReasonOptional => '‹‹Reason (optional)››';

  @override
  String get forwardSearchChatsAndClassrooms =>
      '‹‹Search chats and classrooms…››';

  @override
  String get profileNewPhone => '‹‹New phone››';

  @override
  String get profileNewEmail => '‹‹New email››';

  @override
  String adminExportPasswordsWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'This resets $count students\' passwords to new ones and puts them in the file, so you can print and hand out the login cards. Their old passwords stop working. Anyone with the file can sign in as those students — share carefully and delete when done.',
      one:
          'This resets $count student\'s password to a new one and puts it in the file, so you can print and hand out the login card. Their old password stops working. Anyone with the file can sign in as that student — share carefully and delete when done.',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get pickerSelectStudents => '‹‹Select students››';

  @override
  String get pickerSelectCohorts => '‹‹Select cohorts››';

  @override
  String get pickerSelectGrades => '‹‹Select grades››';

  @override
  String get pickerSelectAll => '‹‹Select all››';

  @override
  String get pickerUnselectAll => '‹‹Unselect all››';

  @override
  String get pickerSelectClassroom => '‹‹Select classroom››';

  @override
  String get pickerSelectClasses => '‹‹Select classes››';

  @override
  String get drawerLoadingChildren => '‹‹Loading children…››';

  @override
  String get drawerCouldNotLoadChildren => '‹‹Could not load children››';

  @override
  String get drawerNoChildrenLinked => '‹‹No children linked››';

  @override
  String get drawerSwitchChild => '‹‹Switch child››';

  @override
  String get shellAssessmentCreated => '‹‹Assessment created››';

  @override
  String commonCouldNotOpenLink(String scheme) {
    return '‹‹Couldn\'t open $scheme link››';
  }

  @override
  String commonCouldntSend(String error) {
    return '‹‹Couldn\'t send: $error››';
  }

  @override
  String get teacherExamDetailsSection => '‹‹Exam Details››';

  @override
  String teacherExamStudyMaterialsWithCount(int count) {
    return '‹‹Study Materials ($count)››';
  }

  @override
  String get teacherMeetingDetailsSection => '‹‹Meeting Details››';

  @override
  String get teacherClassroomNameSection => '‹‹Classroom name››';

  @override
  String get teacherAddByCohortSection => '‹‹Add by cohort››';

  @override
  String get teacherAddIndividualStudentsSection =>
      '‹‹Add individual students››';

  @override
  String get teacherGradeTypeSection => '‹‹Grade type››';

  @override
  String get teacherOtherGradeSection => '‹‹Other grade››';

  @override
  String get teacherEnterGradesSection => '‹‹Enter grades››';

  @override
  String teacherAttachmentsWithCount(int count) {
    return '‹‹Attachments ($count)››';
  }

  @override
  String get studentFilesSharedByTeacher => '‹‹Files shared by your teacher››';

  @override
  String get studentYourSubmission => '‹‹Your submission››';

  @override
  String get studentFilesSharedWithAnnouncement =>
      '‹‹Files shared with this announcement.››';

  @override
  String get announcementGradeRiskTitle => '‹‹Grade risk detected››';

  @override
  String get announcementWeakSubjectTitle => '‹‹Weak subject detected››';

  @override
  String get announcementLowAttendanceTitle => '‹‹Low attendance››';

  @override
  String get announcementRepeatedLatenessTitle => '‹‹Repeated lateness››';

  @override
  String get announcementPracticeWeaknessTitle => '‹‹Practice weakness found››';

  @override
  String get announcementPracticeTrendDroppedTitle =>
      '‹‹Practice trend dropped››';

  @override
  String get announcementSolutionsActivityTitle =>
      '‹‹Solutions activity is live››';

  @override
  String get announcementAllGoodTitle => '‹‹All good››';

  @override
  String get supportSectionGettingStarted => '‹‹Getting started››';

  @override
  String get supportSectionAccountPassword => '‹‹Account & password››';

  @override
  String get supportSectionForStudents => '‹‹For students››';

  @override
  String get supportSectionForTeachers => '‹‹For teachers››';

  @override
  String get supportSectionForAdministrators => '‹‹For administrators››';

  @override
  String get supportSectionForParents => '‹‹For parents››';

  @override
  String get supportSectionPrivacyData => '‹‹Privacy & data››';

  @override
  String get novaDisclaimerCanMakeMistakes => '‹‹Can make mistakes››';

  @override
  String get novaDisclaimerEducationalUseOnly => '‹‹Educational use only››';

  @override
  String get novaDisclaimerYourPrivacy => '‹‹Your privacy››';

  @override
  String profileNameInLanguage(String language) {
    return '‹‹Name in $language››';
  }

  @override
  String get adminSettingsScheduleSubtitle =>
      '‹‹Assign teachers and cohorts to weekly time slots››';

  @override
  String get practiceModeBalancedSubtitle => '‹‹Balanced daily practice››';

  @override
  String get practiceModeRevealSubtitle => '‹‹Reveal and self-recall››';

  @override
  String get practiceModeFastSubtitle => '‹‹Fast pressure drill››';

  @override
  String get practiceModeExamSubtitle => '‹‹Calm exam-style flow››';

  @override
  String get practiceModeConceptSubtitle => '‹‹Concept first, solve later››';

  @override
  String get practiceModeAdaptiveSubtitle => '‹‹Difficulty shifts live››';

  @override
  String get practiceModeStrictSubtitle => '‹‹Strict official style››';

  @override
  String get commonCall => '‹‹Call››';

  @override
  String get tooltipClearEndTime => '‹‹Clear end time››';

  @override
  String get tooltipDeletePeriod => '‹‹Delete period››';

  @override
  String get tooltipLeaveClassroom => '‹‹Leave classroom››';

  @override
  String get announcementGradeRiskBody =>
      '‹‹Your average dropped below 70. Immediate action recommended.››';

  @override
  String announcementWeakSubjectBody(String subject) {
    return '‹‹$subject needs attention.››';
  }

  @override
  String get announcementLowAttendanceBody =>
      '‹‹Your attendance is dropping. This will impact grades.››';

  @override
  String get announcementLatenessBody => '‹‹You have multiple late arrivals.››';

  @override
  String announcementPracticeWeakTopicBody(String topic, String subject) {
    return '‹‹$topic in $subject is dragging your momentum.››';
  }

  @override
  String get announcementPracticeDropBody =>
      '‹‹Your recent practice is below your baseline. Slow down and rebuild.››';

  @override
  String announcementSolutionsActivityBody(int page, int question) {
    return '‹‹Your solution space is active on page $page, question $question. Check peer work or upload yours.››';
  }

  @override
  String get announcementAllGoodBody =>
      '‹‹No major academic risks detected right now.››';

  @override
  String get faqStartedQ1 => '‹‹How do I log in?››';

  @override
  String get faqStartedA1 =>
      '‹‹Tap \"Sign in\" on the welcome screen and enter the email or username your school administrator gave you, plus your temporary password. You\'ll be asked to set a new password the first time.››';

  @override
  String get faqStartedQ2 => '‹‹I don\'t have a login yet.››';

  @override
  String get faqStartedA2 =>
      '‹‹Your school administrator creates accounts. Ask them to add you in their admin app, or to share a join code if your school uses self-enrolment.››';

  @override
  String get faqStartedQ3 => '‹‹Can I use the app in my language?››';

  @override
  String get faqStartedA3 =>
      '‹‹Yes — ClassMate supports English, Arabic, Hebrew, French, and Russian. Open Settings to switch language. You can also set a preferred name language in Profile.››';

  @override
  String get faqStartedQ4 => '‹‹How do I switch between dark and light mode?››';

  @override
  String get faqStartedA4 =>
      '‹‹Open Settings from the drawer and toggle the appearance switch. The app respects your system preference by default.››';

  @override
  String get faqAccountQ1 => '‹‹I forgot my password.››';

  @override
  String get faqAccountA1 =>
      '‹‹Tap \"Forgot password?\" on the login screen. You\'ll get a reset link by email or a code by SMS. If neither channel is verified yet, ask your school administrator to issue you a new temporary password.››';

  @override
  String get faqAccountQ2 => '‹‹How do I change my password?››';

  @override
  String get faqAccountA2 =>
      '‹‹Open Profile from the drawer, scroll to Security, and tap the password row. You\'ll need your current password to set a new one.››';

  @override
  String get faqAccountQ3 => '‹‹How do I change my email or phone number?››';

  @override
  String get faqAccountA3 =>
      '‹‹Open Profile, tap the field you want to change, and follow the verification prompts. A code is sent to your CURRENT email/phone first to confirm it\'s really you, then you can set the new value.››';

  @override
  String get faqAccountQ4 =>
      '‹‹My school administrator can change my password — how does that work?››';

  @override
  String get faqAccountA4 =>
      '‹‹When an administrator resets your password, you\'ll get an email and SMS with a one-tap link to set your own password. The admin never sees what you choose.››';

  @override
  String get faqStudentsQ1 => '‹‹Where do I see my schedule?››';

  @override
  String get faqStudentsA1 =>
      '‹‹Schedule is the first item in the drawer. You\'ll see this week\'s periods, who teaches each one, and any changes the admin has posted.››';

  @override
  String get faqStudentsQ2 => '‹‹How do I join a classroom?››';

  @override
  String get faqStudentsA2 =>
      '‹‹A teacher will add you directly, or share a join code. To use a join code, open Classrooms from the drawer and tap \"Join with code\".››';

  @override
  String get faqStudentsQ3 => '‹‹How do attendance and grades work?››';

  @override
  String get faqStudentsA3 =>
      '‹‹Teachers mark attendance during the lesson. Open Attendance or Grades from the drawer to see your records. Parents linked to your account see the same data.››';

  @override
  String get faqStudentsQ4 => '‹‹What is Nova?››';

  @override
  String get faqStudentsA4 =>
      '‹‹Nova is your AI study buddy — ask it to explain a concept, generate a quiz, or walk through a problem step by step. Open Nova from the drawer to start a session.››';

  @override
  String get faqTeachersQ1 => '‹‹How do I create a classroom?››';

  @override
  String get faqTeachersA1 =>
      '‹‹Open Classrooms from the drawer and tap the + button. Give it a name and subject; students can be added by hand or via a join code.››';

  @override
  String get faqTeachersQ2 => '‹‹How do I mark attendance?››';

  @override
  String get faqTeachersA2 =>
      '‹‹Open Attendance from the drawer, pick the date and period, then tap each student to set their status. Changes save automatically.››';

  @override
  String get faqTeachersQ3 => '‹‹How do I assign homework?››';

  @override
  String get faqTeachersA3 =>
      '‹‹Open Assignments, tap +, fill in the title/due date/attachments, and pick a target (whole school, specific cohorts, or named students). Students see it instantly in their drawer.››';

  @override
  String get faqTeachersQ4 => '‹‹Can I issue a diploma or certificate?››';

  @override
  String get faqTeachersA4 =>
      '‹‹Yes — open Diplomas from the drawer, tap +, pick the student, fill in the title and details, and save. The student sees it in their own Diplomas section.››';

  @override
  String get faqAdminsQ1 => '‹‹Where do I start setting up a school?››';

  @override
  String get faqAdminsA1 =>
      '‹‹Open the Admin Dashboard. The School Setup widget at the top shows a 7-step checklist (logo, name, subjects, bell schedule, cohorts, students, teachers). Each step deep-links to where you complete it.››';

  @override
  String get faqAdminsQ2 => '‹‹How do cohorts work?››';

  @override
  String get faqAdminsA2 =>
      '‹‹A cohort is a group of students that share a schedule. Open Cohorts from the drawer to create them, assign students, and generate join codes. A single cohort can span multiple grades.››';

  @override
  String get faqAdminsQ3 => '‹‹Can a cohort cover more than one grade?››';

  @override
  String get faqAdminsA3 =>
      '‹‹Yes — when creating a cohort, select multiple grades. The cohort then appears in any of those grades\' filters and views, and announcements/templates targeted at any of those grades reach it.››';

  @override
  String get faqAdminsQ4 => '‹‹How do I build the weekly schedule?››';

  @override
  String get faqAdminsA4 =>
      '‹‹Open Schedule from the drawer. Tap any cell to add a period — pick the day/period, teacher, subject, and audience (cohort/student/grade). Bell-schedule times come from School Settings.››';

  @override
  String get faqAdminsQ5 => '‹‹How do I bulk-export students?››';

  @override
  String get faqAdminsA5 =>
      '‹‹Open Export Data from the drawer. Choose whether to select by student or by cohort, pick the rows, and tap Export. Optionally include current passwords during export.››';

  @override
  String get faqAdminsQ6 =>
      '‹‹A user asked me to reset their password. What do I do?››';

  @override
  String get faqAdminsA6 =>
      '‹‹You can either set their password directly (Profile of the user → Security) or wait for them to file a request via \"Forgot password\" and approve it from Password Requests in the drawer.››';

  @override
  String get faqParentsQ1 => '‹‹How do I link my account to my child?››';

  @override
  String get faqParentsA1 =>
      '‹‹Ask your child\'s school administrator to either add the link from their admin app, or share a one-time parent link code. Open Profile and enter the code under Family.››';

  @override
  String get faqParentsQ2 => '‹‹What can I see about my child?››';

  @override
  String get faqParentsA2 =>
      '‹‹Attendance, grades, announcements, and homework — exactly what your child sees plus the trends across time. You won\'t see private chats or Nova sessions.››';

  @override
  String get faqPrivacyQ1 => '‹‹Who can see my data?››';

  @override
  String get faqPrivacyA1 =>
      '‹‹Only people in your school. Teachers see their classrooms\' data, admins see school-wide data, parents see their linked children. We never sell data to advertisers.››';

  @override
  String get faqPrivacyQ2 => '‹‹How do I delete my account?››';

  @override
  String get faqPrivacyA2 =>
      '‹‹Ask your school administrator to delete it. They can remove the account from their admin app, which wipes your profile, schedule, and chats.››';

  @override
  String solutionsPagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '$count page',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get teacherMeetingEditTitle => '‹‹Edit Meeting››';

  @override
  String get teacherMeetingNewTitle => '‹‹Schedule Meeting››';

  @override
  String get teacherExamEditTitle => '‹‹Edit Exam››';

  @override
  String get teacherExamNewTitle => '‹‹Create Exam››';

  @override
  String get teacherAssignmentEditTitle => '‹‹Edit Assignment››';

  @override
  String get teacherAssignmentNewTitle => '‹‹New Assignment››';

  @override
  String get tooltipShowTabs => '‹‹Show tabs››';

  @override
  String get tooltipHideTabs => '‹‹Hide tabs››';

  @override
  String get examsCouldNotLoadForms => '‹‹Could not load forms››';

  @override
  String get examsCouldNotLoadExams => '‹‹Could not load exams››';

  @override
  String get messagesNoPeopleToAdd => '‹‹No people to add››';

  @override
  String commonNoResultsForQuery(String query) {
    return '‹‹No results for \"$query\"››';
  }

  @override
  String chatForwardedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Forwarded to $count chats',
      one: 'Forwarded to 1 chat',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get commonReadMore => '‹‹Read more››';

  @override
  String get commonReadLess => '‹‹Read less››';

  @override
  String get chatComposerSlideToCancel => '‹‹Slide to cancel››';

  @override
  String adminNoRoleYet(String role) {
    return '‹‹No $role yet››';
  }

  @override
  String get profileVerified => '‹‹Verified.››';

  @override
  String get profileUpdatedPendingVerification =>
      '‹‹Updated and pending re-verification.››';

  @override
  String get adminSearchCohorts => '‹‹Search cohorts…››';

  @override
  String get commonAdding => '‹‹Adding…››';

  @override
  String get teacherDiplomaIssuing => '‹‹Issuing…››';

  @override
  String get teacherDiplomaIssue => '‹‹Issue››';

  @override
  String get formAccepting => '‹‹Accepting››';

  @override
  String get profileVerifiedShort => '‹‹Verified››';

  @override
  String get profileUnverified => '‹‹Unverified››';

  @override
  String get notificationNewGradePosted => '‹‹📊 New grade posted››';

  @override
  String notificationNewGradePostedIn(String subject) {
    return '‹‹📊 New grade posted in $subject››';
  }

  @override
  String messagesAddParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count participants',
      one: 'Add 1 participant',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get notificationFallbackTitle => '‹‹Notification››';

  @override
  String adminCohortGradeRange(int from, int to) {
    return '‹‹Grade $from-$to››';
  }

  @override
  String adminCohortGradesList(String list) {
    return '‹‹Grades $list››';
  }

  @override
  String get adminExportHeaderTitle => '‹‹Export users››';

  @override
  String get adminExportHeaderSubtitle =>
      '‹‹Add filters as pills — every pill adds users to the export. Tap a pill to remove it.››';

  @override
  String get adminExportAddFilter => '‹‹Add filter››';

  @override
  String get adminExportEmptyState =>
      '‹‹Add a filter to start: pick a role, cohort, grade, or specific users.››';

  @override
  String get adminExportFilterRolesTab => '‹‹Roles››';

  @override
  String get adminExportFilterCohortsTab => '‹‹Cohorts››';

  @override
  String get adminExportFilterGradesTab => '‹‹Grades››';

  @override
  String get adminExportFilterUsersTab => '‹‹Users››';

  @override
  String get adminExportSelectAll => '‹‹Select all››';

  @override
  String adminExportSelectedCount(int selected, int total) {
    return '‹‹$selected of $total selected››';
  }

  @override
  String adminExportRolePickedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count picked',
      one: '$count picked',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get adminExportPillRolePrefix => '‹‹Role:››';

  @override
  String get adminExportPillCohortPrefix => '‹‹Cohort:››';

  @override
  String adminExportActiveFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active filters',
      one: '$count active filter',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get adminExportClearAll => '‹‹Clear all››';

  @override
  String get adminExportCounting => '‹‹Counting…››';

  @override
  String adminExportMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count users will be exported',
      one: '$count user will be exported',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get adminExportNoGradesConfigured =>
      '‹‹No grades configured for this school››';

  @override
  String get adminExportColumnRole => '‹‹Role››';

  @override
  String get adminExportRoleStudent => '‹‹Student››';

  @override
  String get adminExportRoleTeacher => '‹‹Teacher››';

  @override
  String get adminExportRoleParent => '‹‹Parent››';

  @override
  String get adminExportRoleSecretary => '‹‹Secretary››';

  @override
  String get adminExportRoleAdmin => '‹‹Admin››';

  @override
  String adminExportUsersSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count users selected',
      one: '$count user selected',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get adminExportPasswordsOn =>
      '‹‹Passwords will be reset and shown in the export — old passwords stop working. Handle the file securely.››';

  @override
  String get adminExportPasswordsOff =>
      '‹‹Export will not contain any passwords.››';

  @override
  String get adminExportPdfUserDirectory => '‹‹User Directory››';

  @override
  String adminExportPdfUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count users',
      one: '$count user',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get teacherAttachFromMaterials => '‹‹From materials››';

  @override
  String get teacherUploadFiles => '‹‹Upload files››';

  @override
  String get solSubjectMathematics => '‹‹Mathematics››';

  @override
  String get solSubjectComputerScience => '‹‹Computer Science››';

  @override
  String get solSubjectPhysics => '‹‹Physics››';

  @override
  String get solSubjectChemistry => '‹‹Chemistry››';

  @override
  String get solSubjectHebrew => '‹‹Hebrew››';

  @override
  String get solSubjectBiology => '‹‹Biology››';

  @override
  String get solSubjectHistory => '‹‹History››';

  @override
  String get solSubjectArabic => '‹‹Arabic››';

  @override
  String get solSubjectElectronics => '‹‹Electronics››';

  @override
  String get solSubjectMechanics => '‹‹Mechanics››';

  @override
  String get solSubjectFrench => '‹‹French››';

  @override
  String get solSubjectEnvironmentalScience => '‹‹Environmental Science››';

  @override
  String get solSubjectCommunicationCinema => '‹‹Communication and Cinema››';

  @override
  String get solSubjectCitizenship => '‹‹Citizenship››';

  @override
  String get solSubjectSociology => '‹‹Sociology››';

  @override
  String get solSubjectReligion => '‹‹Religion››';

  @override
  String get solSubjectGeography => '‹‹Geography››';

  @override
  String get solSubjectPsychology => '‹‹Psychology››';

  @override
  String get insightsSemesterTitle => '‹‹This semester››';

  @override
  String get insightsOnTimeSubmissions => '‹‹On-time work››';

  @override
  String get insightsSubmissionsTitle => '‹‹Submissions››';

  @override
  String get insightsOnTime => '‹‹On time››';

  @override
  String get insightsLate => '‹‹Late››';

  @override
  String get insightsMissing => '‹‹Missing››';

  @override
  String get insightsPending => '‹‹Pending››';

  @override
  String get insightsHandedInLabel => '‹‹handed in››';

  @override
  String get insightsLatestGrades => '‹‹Latest grades››';

  @override
  String get insightsReviewWithNova => '‹‹Review with Nova››';

  @override
  String get insightsReviewWithNovaPrompt =>
      '‹‹Give me a short, honest review of my performance this semester — grades, attendance, and submissions — and the one thing I should focus on next.››';

  @override
  String get insightsPracticeTitle => '‹‹Practice accuracy››';

  @override
  String get commonUnknown => '‹‹Unknown››';

  @override
  String get solutionsReportTitle => '‹‹Report this solution››';

  @override
  String get solutionsReportBody =>
      '‹‹Tell the admins what\'s wrong. The admins of both schools will review it.››';

  @override
  String get solutionsReportReasonHint => '‹‹Reason (optional)››';

  @override
  String get solutionsReportAction => '‹‹Report››';

  @override
  String get solutionsReportSubmitted => '‹‹Thanks — reported to the admins.››';

  @override
  String get solutionsReportAlready => '‹‹You already reported this.››';

  @override
  String solutionsBookPagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get solutionsNoBooksYetForStudents =>
      '‹‹No books here yet. Your teacher will add them.››';

  @override
  String get solutionsManageBooksTitle => '‹‹Manage books››';

  @override
  String get solutionsNoBooksManageHint =>
      '‹‹No books for this subject yet. Tap + to add one.››';

  @override
  String get solutionsDeleteBookTitle => '‹‹Delete book?››';

  @override
  String solutionsDeleteBookBody(String title) {
    return '‹‹Delete \"$title\"? This can\'t be undone.››';
  }

  @override
  String solutionsBookSaveFailed(String error) {
    return '‹‹Couldn\'t save: $error››';
  }

  @override
  String get solutionsBookDuplicateHint =>
      '‹‹Before adding, make sure this book isn’t already in the database.››';

  @override
  String get solutionsBookDuplicateTitle => '‹‹Possible duplicate book››';

  @override
  String solutionsBookDuplicateBody(String title) {
    return '‹‹A book named \"$title\" already exists. Make sure it isn’t the same one before adding it.››';
  }

  @override
  String get solutionsBookAddAnyway => '‹‹Add anyway››';

  @override
  String get solutionsBookNeedTitlePages => '‹‹Enter a title and page count.››';

  @override
  String get solutionsEditBookTitle => '‹‹Edit book››';

  @override
  String get solutionsBookCoverLabel => '‹‹Cover››';

  @override
  String solutionsGradeLabel(int grade) {
    return '‹‹Grade $grade››';
  }

  @override
  String get solutionsReportsTitle => '‹‹Reported solutions››';

  @override
  String get solutionsReportsEmpty => '‹‹No reports to review.››';

  @override
  String get solutionsReportPostedBy => '‹‹Posted by››';

  @override
  String get solutionsReportReportedBy => '‹‹Reported by››';

  @override
  String get solutionsReportReasonLabel => '‹‹Reason››';

  @override
  String get solutionsReportKeepAction => '‹‹Keep››';

  @override
  String get solutionsReportRemoveAction => '‹‹Remove››';

  @override
  String get solutionsReportStatusPending => '‹‹Pending››';

  @override
  String get solutionsReportStatusApproved => '‹‹Kept››';

  @override
  String get solutionsReportStatusRemoved => '‹‹Removed››';

  @override
  String get solutionsReportRemoved => '‹‹Solution removed.››';

  @override
  String get solutionsReportApproved => '‹‹Report dismissed — solution kept.››';

  @override
  String solutionsReportFailed(String error) {
    return '‹‹Couldn\'t report: $error››';
  }

  @override
  String get teacherAddGradeTitle => '‹‹Add Grade››';

  @override
  String get commonCohort => '‹‹Cohort››';

  @override
  String get teacherCreateNewExam => '‹‹Create new exam››';

  @override
  String get teacherCreateNewAssignment => '‹‹Create new assignment››';

  @override
  String get commonReturn => '‹‹Return››';

  @override
  String get reorderToolsTitle => '‹‹Reorder menu››';

  @override
  String get reorderToolsSubtitle =>
      '‹‹Drag to reorder your School Tools. The Core and Account sections stay put.››';

  @override
  String get reorderToolsReset => '‹‹Reset››';

  @override
  String get reorderToolsSettingsSection => '‹‹Menu››';

  @override
  String get reorderToolsSettingsSubtitle =>
      '‹‹Reorder the tools in your side menu››';

  @override
  String get drawerHoldToReorder => 'Hold an item to drag & reorder';

  @override
  String get adminSchoolGradeRangesDescription =>
      '‹‹Set which grades your school covers. Add multiple ranges if some grades are skipped (e.g. 4-6 and 9-12).››';

  @override
  String get adminSchoolAddGradeRange => '‹‹Add range››';

  @override
  String get teacherListStudents => '‹‹List students››';

  @override
  String get teacherNoStudentsInvolved => '‹‹No students in this period yet.››';

  @override
  String get messagesFilterAdmins => '‹‹Admins››';

  @override
  String get teacherAssignmentGradedStatus => '‹‹Graded››';

  @override
  String get teacherAssignmentReturnedStatus => '‹‹Returned for re-solution››';

  @override
  String get teacherAssignmentReturnAction => '‹‹Return for re-solution››';

  @override
  String teacherAssignmentReturnDialogBody(String name) {
    return '‹‹Send this submission back to $name to revise and hand in again? Any feedback you typed will be included.››';
  }

  @override
  String teacherGradesSavedOf(int saved, int total) {
    return '‹‹Saved $saved of $total.››';
  }

  @override
  String teacherGradesSkippedSuffix(int dropped) {
    return '‹‹$dropped student(s) skipped — not in a cohort.››';
  }

  @override
  String get adminPeopleGradeLevelRequired =>
      '‹‹Pick a grade level for this student.››';

  @override
  String teacherAddGradeLabel(int grade) {
    return '‹‹Grade $grade››';
  }

  @override
  String get teacherGradeOutOfHint => '‹‹e.g. 20››';

  @override
  String get plansDowngrade => '‹‹Downgrade››';

  @override
  String get plansDowngradeNote =>
      '‹‹Starts when your current plan ends — you keep it until then, no refund.››';

  @override
  String get semesterThis => '‹‹This semester››';

  @override
  String get semesterPrevious => '‹‹Previous››';

  @override
  String get showMore => '‹‹Show more››';

  @override
  String get adminSchoolSemestersLabel => '‹‹Semesters››';

  @override
  String get adminSchoolSemestersDescription =>
      '‹‹Split the school year into semesters by month. Grades, exams, meetings and more are grouped by semester automatically.››';

  @override
  String adminSchoolSemesterN(String n) {
    return '‹‹Semester $n››';
  }

  @override
  String get adminSchoolAddSemester => '‹‹Add semester››';

  @override
  String get semesterStarts => '‹‹Starts››';

  @override
  String get semesterEnds => '‹‹Ends››';

  @override
  String get commonWhen => '‹‹When››';

  @override
  String get commonFiles => '‹‹Files››';

  @override
  String get commonOnce => '‹‹Once››';

  @override
  String get commonNoneDash => '‹‹— None —››';

  @override
  String get commonNotesOptional => '‹‹Notes (optional)››';

  @override
  String get commonSubjectOptional => '‹‹Subject (optional)››';

  @override
  String get colorBlue => '‹‹Blue››';

  @override
  String get colorIndigo => '‹‹Indigo››';

  @override
  String get colorViolet => '‹‹Violet››';

  @override
  String get colorTeal => '‹‹Teal››';

  @override
  String get colorGreen => '‹‹Green››';

  @override
  String get colorOrange => '‹‹Orange››';

  @override
  String get colorRose => '‹‹Rose››';

  @override
  String get teacherAddClassNotes => '‹‹Add Class Notes››';

  @override
  String get teacherStudentsWithGrades => '‹‹Students with grades››';

  @override
  String get teacherOtherStudentsSameGrade =>
      '‹‹Other students in the same grade/cohort››';

  @override
  String get teacherChooseExam => '‹‹Choose exam››';

  @override
  String get teacherChooseAssignment => '‹‹Choose assignment››';

  @override
  String get teacherSearchExams => '‹‹Search exams…››';

  @override
  String get teacherSearchAssignments => '‹‹Search assignments…››';

  @override
  String get teacherSearchQuestionTypes => '‹‹Search question types…››';

  @override
  String get teacherOtherCustomSubject => '‹‹Other (type custom)››';

  @override
  String get adminLinkChild => '‹‹Link Child››';

  @override
  String get adminChooseStudentDash => '‹‹— Choose student —››';

  @override
  String get adminSelectStudentToLink => '‹‹Select student to link››';

  @override
  String get adminEditPeriod => '‹‹Edit period››';

  @override
  String get adminNotInAnyCohort =>
      '‹‹Not in any cohort yet — assign from the Cohorts screen.››';

  @override
  String get adminPasswordChangeWarning =>
      '‹‹The user will be signed in with this password next time they log in. Any pending password-reset links are invalidated.››';

  @override
  String get nameInEnglish => '‹‹Name in English››';

  @override
  String get nameInArabic => '‹‹Name in Arabic››';

  @override
  String get nameInHebrew => '‹‹Name in Hebrew››';

  @override
  String get nameInFrench => '‹‹Name in French››';

  @override
  String get nameInRussian => '‹‹Name in Russian››';

  @override
  String get passwordMinChars => '‹‹At least 8 characters.››';

  @override
  String get passwordsDoNotMatch => '‹‹Passwords don\'t match.››';

  @override
  String get adminWelcomeHeading => '‹‹Welcome to ClassMate››';

  @override
  String get diplomasNoFilesAttached =>
      '‹‹No files attached to this certificate.››';

  @override
  String get diplomasFilesProcessing =>
      '‹‹Files could not be opened — they may still be processing.››';

  @override
  String get novaOutOfTokens =>
      '‹‹You\'ve used all your tokens for this period. Upgrade or top up to keep chatting with NOVA.››';

  @override
  String get tutorDeleteConversationWarning =>
      '‹‹This will permanently delete the conversation and all its messages from the server. This cannot be undone.››';

  @override
  String get chatReportFlagWarning =>
      '‹‹This message will be flagged for review by an admin.››';

  @override
  String get solutionPreviewFailFallback =>
      '‹‹Open from the chat attachment if preview fails››';

  @override
  String get practiceNoInternet =>
      '‹‹No internet connection. Please try again.››';

  @override
  String get practiceGenerationFailed =>
      '‹‹Could not generate questions. Please try again.››';

  @override
  String get practiceTimingSecPerQuestion => '‹‹s / question››';

  @override
  String get practiceTimingMinPerQuiz => '‹‹min / quiz››';

  @override
  String adminScheduleFrequencyWeeks(Object freq) {
    return '‹‹×$freq wks››';
  }

  @override
  String gradeLevelLabel(Object grade) {
    return '‹‹Grade $grade››';
  }

  @override
  String adminPeriodOption(Object period) {
    return '‹‹Period $period››';
  }

  @override
  String cohortStudentsCount(int count) {
    return '‹‹$count students››';
  }

  @override
  String diplomasIssuedCount(Object count) {
    return '‹‹$count certificates issued››';
  }

  @override
  String get adminExportImportantHeading => '‹‹Important››';

  @override
  String get adminExportWelcomeBodyWithPw =>
      '‹‹These are your ClassMate account details. Sign in to the ClassMate app on iOS or Android using the username and password below. You can change your password in the app.››';

  @override
  String get adminExportWelcomeBodyNoPw =>
      '‹‹These are your ClassMate account details. Sign in to the ClassMate app on iOS or Android using your username.››';

  @override
  String get adminExportNotePrivate =>
      '‹‹Keep these credentials private. Do not share your password.››';

  @override
  String get adminExportNoteChangePw =>
      '‹‹Change your password after your first sign-in from Settings → Account.››';

  @override
  String get adminExportNoteLegal =>
      '‹‹By using ClassMate you accept our Terms of Service and Privacy Policy.››';

  @override
  String adminExportNoteHelp(String email) {
    return '‹‹Need help? Contact your school administrator or $email.››';
  }

  @override
  String get teacherGradeTitleHint => '‹‹e.g. Class participation, Quiz 3››';

  @override
  String get teacherClassroomNameHint => '‹‹e.g. Mathematics 10A››';

  @override
  String get novaAbout => '‹‹About NOVA››';

  @override
  String get parentNotifForYou => '‹‹For you››';

  @override
  String parentNotifAbout(String name) {
    return '‹‹About $name››';
  }

  @override
  String get navPrivacyPolicy => '‹‹Privacy Policy››';

  @override
  String get privacyPolicySubtitle => '‹‹How we protect your data››';

  @override
  String get semesterAllPrevious => '‹‹All previous››';

  @override
  String get semesterSelectTitle => '‹‹Select semester››';

  @override
  String get adminImportUsersScreenTitle => '‹‹Import users››';

  @override
  String get adminImportUsersScreenTabGrid => '‹‹Grid››';

  @override
  String get adminImportUsersScreenTabCsv => '‹‹CSV››';

  @override
  String adminImportUsersScreenLoadedRows(int count) {
    return '‹‹Loaded $count rows — review & edit, then Create››';
  }

  @override
  String get adminImportUsersScreenFillAtLeastOneName =>
      '‹‹Fill at least one name››';

  @override
  String adminImportUsersScreenFailed(String error) {
    return '‹‹Failed: $error››';
  }

  @override
  String get adminImportUsersScreenBackToGrid => '‹‹Back to grid››';

  @override
  String get adminImportUsersScreenGridIntro =>
      '‹‹Fill a row per person, or load a CSV from the CSV tab and fix anything here. Username is optional — we generate one if blank. For students, set the grade and (optionally) a parent\'s username to link them.››';

  @override
  String get adminImportUsersScreenAddRow => '‹‹Add row››';

  @override
  String adminImportUsersScreenCreateCount(int count) {
    return '‹‹Create ($count)››';
  }

  @override
  String get adminImportUsersScreenRole => '‹‹Role››';

  @override
  String get adminImportUsersScreenFullName => '‹‹Full name *››';

  @override
  String get adminImportUsersScreenUsername => '‹‹Username››';

  @override
  String get adminImportUsersScreenUsernameHint => '‹‹(auto if blank)››';

  @override
  String get adminImportUsersScreenGrade => '‹‹Grade››';

  @override
  String get adminImportUsersScreenParentUsername => '‹‹Parent username››';

  @override
  String get adminImportUsersScreenParentUsernameHint => '‹‹link (optional)››';

  @override
  String get adminImportUsersScreenCouldNotReadFile =>
      '‹‹Could not read that file.››';

  @override
  String get adminImportUsersScreenCsvIntro =>
      '‹‹Upload a CSV of your users. Column headers can be in any language — ClassMate detects what each column means, then loads the rows into the grid so you can review and fix anything before creating.››';

  @override
  String get adminImportUsersScreenChooseCsv => '‹‹Choose CSV file››';

  @override
  String get adminImportUsersScreenChooseDifferentFile =>
      '‹‹Choose a different file››';

  @override
  String adminImportUsersScreenSelectedFile(String fileName) {
    return '‹‹Selected: $fileName››';
  }

  @override
  String get adminImportUsersScreenRecognisedColumns =>
      '‹‹Recognised columns››';

  @override
  String get adminImportUsersScreenRecognisedColumnsBody =>
      '‹‹name · username · password · email · phone · role · grade · parent (a username) · children (usernames)\n\nRole words like \"student / طالب / תלמיד / élève / ученик\" all map correctly. Grade reads the number from \"Grade 10\", \"الصف 10\", \"כיתה 10\". Missing usernames or passwords are generated automatically.››';

  @override
  String adminImportUsersScreenDetectedRows(int count) {
    return '‹‹Detected — $count rows››';
  }

  @override
  String get adminImportUsersScreenNoColumnsDetected =>
      '‹‹No known columns detected — check your header row.››';

  @override
  String get adminImportUsersScreenTruncatedNotice =>
      '‹‹Showing the first 2000 rows for review.››';

  @override
  String get adminImportUsersScreenReviewEditInGrid =>
      '‹‹Review & edit in grid››';

  @override
  String get adminImportUsersScreenReviewEditHint =>
      '‹‹Opens the Grid tab pre-filled with these rows so you can fix any mistakes before creating.››';

  @override
  String adminImportUsersScreenResultSummary(int count, int links) {
    return '‹‹✓ Created $count users · $links links››';
  }

  @override
  String adminImportUsersScreenResultFailedSuffix(int failed) {
    return '‹‹ · $failed failed››';
  }

  @override
  String get adminImportUsersScreenFailedRows => '‹‹Failed rows››';

  @override
  String adminImportUsersScreenFailedRow(String row, String reason) {
    return '‹‹Row $row: $reason››';
  }

  @override
  String get adminImportUsersScreenCredentialsTitle =>
      '‹‹Credentials (hand these to your users)››';

  @override
  String get teacherCohortsScreenTitle => '‹‹Cohorts››';

  @override
  String get teacherCohortsScreenNewCohort => '‹‹New cohort››';

  @override
  String get teacherCohortsScreenLoadError => '‹‹Could not load cohorts.››';

  @override
  String get teacherCohortsScreenEmpty =>
      '‹‹No cohorts yet.\nTap \"New cohort\" to create one.››';

  @override
  String get teacherCohortsScreenCohortNameLabel => '‹‹Cohort name››';

  @override
  String get teacherCohortsScreenCohortNameHint => '‹‹e.g. 10-2››';

  @override
  String get teacherCohortsScreenGradesLabel => '‹‹Grade(s)››';

  @override
  String get teacherCohortsScreenGradesHint => '‹‹e.g. 10  or  7,8››';

  @override
  String get teacherCohortsScreenCancel => '‹‹Cancel››';

  @override
  String get teacherCohortsScreenCreate => '‹‹Create››';

  @override
  String get teacherCohortsScreenEnterNameAndGrade =>
      '‹‹Enter a name and at least one grade››';

  @override
  String get teacherCohortsScreenCohortCreated => '‹‹Cohort created››';

  @override
  String get teacherCohortsScreenFailed => '‹‹Failed››';

  @override
  String teacherCohortsScreenStudentsCount(int count) {
    return '‹‹$count students››';
  }

  @override
  String get teacherCohortsScreenRenameGrades => '‹‹Rename / grades››';

  @override
  String get teacherCohortsScreenDeleteCohort => '‹‹Delete cohort››';

  @override
  String get teacherCohortsScreenAddStudents => '‹‹Add students››';

  @override
  String get teacherCohortsScreenEditCohort => '‹‹Edit cohort››';

  @override
  String get teacherCohortsScreenSave => '‹‹Save››';

  @override
  String get teacherCohortsScreenSaved => '‹‹Saved››';

  @override
  String teacherCohortsScreenDeleteConfirmTitle(String name) {
    return '‹‹Delete \"$name\"?››';
  }

  @override
  String get teacherCohortsScreenDeleteConfirmBody =>
      '‹‹The cohort is removed and students are detached from it. Student accounts are not deleted.››';

  @override
  String get teacherCohortsScreenDelete => '‹‹Delete››';

  @override
  String get teacherCohortsScreenDeleted => '‹‹Deleted››';

  @override
  String get teacherCohortsScreenLoadStudentsError =>
      '‹‹Could not load students››';

  @override
  String teacherCohortsScreenAddNStudents(int count) {
    return '‹‹Add $count students››';
  }

  @override
  String teacherCohortsScreenAddedNStudents(int count) {
    return '‹‹Added $count students››';
  }

  @override
  String get teacherCohortsScreenNoStudentsYet => '‹‹No students yet.››';

  @override
  String get adminSettingsScreenBulkTools => '‹‹Bulk tools››';

  @override
  String get adminSettingsScreenImportUsers => '‹‹Import users››';

  @override
  String get adminSettingsScreenImportUsersSubtitle =>
      '‹‹Add many at once — grid or CSV››';

  @override
  String get adminSettingsScreenUpgradeGrades => '‹‹Upgrade grades››';

  @override
  String get adminSettingsScreenUpgradeGradesSubtitle =>
      '‹‹Promote every student one grade››';

  @override
  String get adminSettingsScreenUpgradeGradesTitle => '‹‹Upgrade all grades?››';

  @override
  String get adminSettingsScreenUpgradeGradesBody =>
      '‹‹Every student moves up one grade. Students already at the top grade are kept as graduating (never deleted) for you to handle. This is safe to run once at the start of the school year.››';

  @override
  String get adminSettingsScreenUpgradeConfirm => '‹‹Upgrade››';

  @override
  String adminSettingsScreenUpgradeSuccess(int promoted, int graduating) {
    return '‹‹Promoted $promoted students · $graduating graduating››';
  }

  @override
  String get adminSettingsScreenDangerZone => '‹‹Danger zone››';

  @override
  String get adminSettingsScreenResetSchedule => '‹‹Reset schedule››';

  @override
  String get adminSettingsScreenResetScheduleSubtitle =>
      '‹‹Delete all periods & overrides››';

  @override
  String get adminSettingsScreenResetScheduleTitle =>
      '‹‹Reset the whole schedule?››';

  @override
  String get adminSettingsScreenResetScheduleBody =>
      '‹‹This permanently deletes every period and one-off override for your school. Bell-schedule times are kept. This cannot be undone.››';

  @override
  String adminSettingsScreenResetScheduleSuccess(int slots) {
    return '‹‹Schedule cleared — $slots periods removed››';
  }

  @override
  String get adminSettingsScreenResetCohorts => '‹‹Reset cohorts››';

  @override
  String get adminSettingsScreenResetCohortsSubtitle =>
      '‹‹Delete all of your cohorts››';

  @override
  String get adminSettingsScreenResetCohortsTitle => '‹‹Delete all cohorts?››';

  @override
  String get adminSettingsScreenResetCohortsBody =>
      '‹‹This permanently deletes every cohort in your school and removes students from them. Student accounts are NOT deleted. This cannot be undone.››';

  @override
  String get adminSettingsScreenDeleteCohortsConfirm => '‹‹Delete cohorts››';

  @override
  String adminSettingsScreenResetCohortsSuccess(int deleted) {
    return '‹‹Deleted $deleted cohorts››';
  }

  @override
  String get adminSettingsScreenAppearanceSubtitle =>
      '‹‹Theme, colors, language››';

  @override
  String get adminSettingsScreenCancel => '‹‹Cancel››';

  @override
  String get adminSettingsScreenWorking => '‹‹Working…››';

  @override
  String adminSettingsScreenFailed(String error) {
    return '‹‹Failed: $error››';
  }

  @override
  String adminSchedulePickStartDate(int freq) {
    return '‹‹Pick a start date for the every-$freq-weeks schedule.››';
  }

  @override
  String get adminScheduleNoCohortsYet =>
      '‹‹No cohorts yet — create one first.››';

  @override
  String adminScheduleGradeWithCohort(String grade, String cohort) {
    return '‹‹Grade $grade · $cohort››';
  }

  @override
  String get adminScheduleDateOnLabel => '‹‹On››';

  @override
  String get adminScheduleDateStartsOnLabel => '‹‹Starts on››';

  @override
  String adminScheduleStudentCount(int count) {
    return '‹‹$count students››';
  }

  @override
  String get adminScheduleAudienceNone => '‹‹—››';

  @override
  String adminScheduleTeacherClashNamed(String name) {
    return '‹‹$name would have two classes at the same time.››';
  }

  @override
  String get adminScheduleTeacherClash =>
      '‹‹This teacher would have two classes at the same time.››';

  @override
  String adminScheduleStudentClashSingle(String name) {
    return '‹‹$name would have two periods at the same time:››';
  }

  @override
  String adminScheduleStudentClashMany(int count) {
    return '‹‹$count students would have two periods at the same time:››';
  }

  @override
  String get adminScheduleAStudent => '‹‹A student››';

  @override
  String adminScheduleAffected(String preview) {
    return '‹‹Affected: $preview››';
  }

  @override
  String get adminScheduleResolvePrompt => '‹‹How should this be resolved?››';

  @override
  String get adminScheduleResolvePromptStudents =>
      '‹‹How should this be resolved for those students?››';

  @override
  String adminScheduleStudentsInCohorts(int count, int cohortCount) {
    return '‹‹$count students in selected cohorts››';
  }

  @override
  String adminScheduleStudentsInGrade(int count, String grade) {
    return '‹‹$count students in Grade $grade››';
  }

  @override
  String get adminScheduleCustomizedNote =>
      '‹‹Customized — saved as individual students››';

  @override
  String adminScheduleMoreCount(int count) {
    return '‹‹+$count more››';
  }

  @override
  String get adminScheduleAddStudentsTitle => '‹‹Add students››';

  @override
  String get adminScheduleNoStudentsMatch => '‹‹No students match.››';

  @override
  String get adminScheduleNoPeriodsHere => '‹‹No periods here yet.››';

  @override
  String adminScheduleGradeRange(String from, String to) {
    return '‹‹Grade $from-$to››';
  }

  @override
  String adminScheduleGradesList(String grades) {
    return '‹‹Grades $grades››';
  }

  @override
  String get adminScheduleNoStudentsInCohorts =>
      '‹‹No students in these cohorts yet.››';

  @override
  String adminScheduleEveryNWeeks(int freq) {
    return '‹‹Every $freq weeks››';
  }

  @override
  String get adminScheduleColorLabel => '‹‹Color››';

  @override
  String get adminScheduleSubjectRequired => '‹‹Subject *››';

  @override
  String get adminScheduleNoSchoolSubjects =>
      '‹‹No school subjects yet. Tap \"Add new\" to define one.››';

  @override
  String get adminScheduleNoSubjectsMatch =>
      '‹‹No subjects match your search.››';

  @override
  String get teacherNewAnnouncementScreenBroadcastBody =>
      '‹‹No specific audience selected. This announcement will be visible to EVERY student, parent, teacher, secretary, and admin in the school.››';

  @override
  String teacherNewAnnouncementScreenGradeLabel(int grade) {
    return '‹‹Grade $grade››';
  }

  @override
  String get teacherNewAnnouncementScreenNoFilesAttached =>
      '‹‹No files attached.››';

  @override
  String teacherNewAnnouncementScreenSelectedCount(int count) {
    return '‹‹$count selected››';
  }

  @override
  String get teacherNewAnnouncementScreenAudienceHint =>
      '‹‹Pick a category, then the specific roles, grades, cohorts, or people. Selections from every category add up.››';

  @override
  String get teacherNewAnnouncementScreenLoadingStudents =>
      '‹‹Loading students…››';

  @override
  String get teacherNewAnnouncementScreenNoGradeLevels =>
      '‹‹No grade levels found yet.››';

  @override
  String get teacherNewAnnouncementScreenTapSelectCohorts =>
      '‹‹Tap to select cohorts…››';

  @override
  String teacherNewAnnouncementScreenCohortsSelected(int count) {
    return '‹‹$count cohorts selected››';
  }

  @override
  String get teacherNewAnnouncementScreenTapSelectStudents =>
      '‹‹Tap to select students…››';

  @override
  String teacherNewAnnouncementScreenStudentsSelected(int count) {
    return '‹‹$count students selected››';
  }

  @override
  String get teacherNewAnnouncementScreenTapSelectParents =>
      '‹‹Tap to select parents…››';

  @override
  String teacherNewAnnouncementScreenParentsSelected(int count) {
    return '‹‹$count parents selected››';
  }

  @override
  String get teacherNewAnnouncementScreenSelectedAudience =>
      '‹‹Selected audience››';

  @override
  String teacherNewAnnouncementScreenStudentsInCohorts(int count) {
    return '‹‹$count students in selected cohorts››';
  }

  @override
  String get teacherNewAnnouncementScreenSelectParents => '‹‹Select parents››';

  @override
  String teacherNewAnnouncementScreenChildrenSummary(
    int count,
    String summary,
  ) {
    return '‹‹$count children — $summary››';
  }

  @override
  String get teacherNewAnnouncementScreenNoLinkedChildren =>
      '‹‹No linked children››';

  @override
  String adminPeriodsScreenDayN(int dow) {
    return '‹‹Day $dow››';
  }

  @override
  String adminPeriodsScreenPeriodN(int period) {
    return '‹‹Period $period››';
  }

  @override
  String get adminPeriodsScreenPeriodDropdownLabel => '‹‹Period››';

  @override
  String get adminPeriodsScreenSelectTeacher => '‹‹Select teacher…››';

  @override
  String get adminPeriodsScreenNone => '‹‹— None —››';

  @override
  String get adminPeriodsScreenLinkClassroom => '‹‹Link to classroom…››';

  @override
  String adminPeriodsScreenCohortGradeName(String grade, String name) {
    return '‹‹G$grade — $name››';
  }

  @override
  String adminPeriodsScreenGradeN(String grade) {
    return '‹‹Grade $grade››';
  }

  @override
  String get roleBadgeStudent => '‹‹Student››';

  @override
  String get roleBadgeTeacher => '‹‹Teacher››';

  @override
  String get roleBadgeAdmin => '‹‹Admin››';

  @override
  String get roleBadgeSecretary => '‹‹Secretary››';

  @override
  String get roleBadgeParent => '‹‹Parent››';

  @override
  String get roleBadgeMember => '‹‹Member››';

  @override
  String get teacherSlotAttachmentsScreenEmptyTitle => '‹‹No attachments yet››';

  @override
  String get teacherSlotAttachmentsScreenEmptyBody =>
      '‹‹Attach materials so your students see them on this period\'s card.››';

  @override
  String get teacherSlotAttachmentsScreenMaterialFallback => '‹‹Material››';

  @override
  String get teacherSlotAttachmentsScreenSheetTitle => '‹‹Attach material››';

  @override
  String get teacherSlotAttachmentsScreenCreateNew => '‹‹Create new material››';

  @override
  String get teacherAddGradeScreenPickAudience =>
      '‹‹Pick at least one student, cohort, or grade.››';

  @override
  String get teacherAddGradeScreenEnterTitle =>
      '‹‹Enter a title for this grade.››';

  @override
  String get teacherAddGradeScreenPickExam => '‹‹Pick an exam.››';

  @override
  String get teacherAddGradeScreenPickAssignment => '‹‹Pick an assignment.››';

  @override
  String get teacherAddGradeScreenCouldNotResolveTitle =>
      '‹‹Could not resolve grade title.››';

  @override
  String teacherAddGradeScreenEnterNumericGrade(String name) {
    return '‹‹Enter a numeric grade for $name.››';
  }

  @override
  String teacherAddGradeScreenError(String error) {
    return '‹‹Error: $error››';
  }

  @override
  String get teacherAddGradeScreenTapSelectStudents =>
      '‹‹Tap to select students…››';

  @override
  String teacherAddGradeScreenStudentsSelected(int count) {
    return '‹‹$count student(s) selected››';
  }

  @override
  String get teacherAddGradeScreenTapSelectCohorts =>
      '‹‹Tap to select cohorts…››';

  @override
  String teacherAddGradeScreenCohortsSelected(int count) {
    return '‹‹$count cohort(s) selected››';
  }

  @override
  String teacherAddGradeScreenWillBeGraded(int count) {
    return '‹‹$count student(s) will be graded››';
  }

  @override
  String get teacherAddGradeScreenNoGradeLevels =>
      '‹‹No grade levels found on your students yet.››';

  @override
  String get teacherAddGradeScreenSelectAudienceExams =>
      '‹‹Select an audience first to filter exams.››';

  @override
  String teacherAddGradeScreenNoExamsReach(String audience) {
    return '‹‹No exams reach all selected $audience.››';
  }

  @override
  String get teacherAddGradeScreenSelectAudienceAssignments =>
      '‹‹Select an audience first to filter assignments.››';

  @override
  String teacherAddGradeScreenNoAssignmentsReach(String audience) {
    return '‹‹No assignments reach all selected $audience.››';
  }

  @override
  String get teacherAddGradeScreenSelectAudienceAbove =>
      '‹‹Select an audience above to enter grades.››';

  @override
  String get teacherAddGradeScreenSelectStudentsTitle => '‹‹Select students››';

  @override
  String teacherAddGradeScreenCountSelected(int count) {
    return '‹‹$count selected››';
  }

  @override
  String get teacherAddGradeScreenSelectCohortsTitle => '‹‹Select cohorts››';

  @override
  String get teacherAddGradeScreenAudienceCohorts => '‹‹cohorts››';

  @override
  String get teacherAddGradeScreenAudienceGrades => '‹‹grades››';

  @override
  String get teacherAddGradeScreenAudienceStudents => '‹‹students››';

  @override
  String get formDetailScreenCouldNotLoad =>
      '‹‹Could not load this form right now.››';

  @override
  String get formDetailScreenSubmitted => '‹‹Form submitted››';

  @override
  String get formDetailScreenSubmissionFailed => '‹‹Submission failed››';

  @override
  String get formDetailScreenAlreadySubmittedNote =>
      '‹‹You have already submitted this form.››';

  @override
  String get formDetailScreenSubmitting => '‹‹Submitting…››';

  @override
  String get formDetailScreenSubmitAgain => '‹‹Submit again››';

  @override
  String get formDetailScreenSubmitForm => '‹‹Submit form››';

  @override
  String formDetailScreenQuestionCount(int count) {
    return '‹‹$count questions››';
  }

  @override
  String get formDetailScreenMultiSubmit => '‹‹Multi-submit››';

  @override
  String get formDetailScreenOnePerStudent => '‹‹1 per student››';

  @override
  String get formDetailScreenRequired => '‹‹Required››';

  @override
  String get formDetailScreenYourAnswer => '‹‹Your answer››';

  @override
  String get formDetailScreenLongAnswerText => '‹‹Long answer text››';

  @override
  String get formDetailScreenSelect => '‹‹Select››';

  @override
  String get novaChatScreenAboutAiPoweredTitle => '‹‹AI-powered assistant››';

  @override
  String get novaChatScreenAboutAiPoweredBody =>
      '‹‹NOVA is built on large language model technology to help you study, understand concepts, and explore ideas.››';

  @override
  String get novaChatScreenAboutMistakesBody =>
      '‹‹NOVA may produce inaccurate, incomplete, or outdated information. Always verify important answers with your teacher or a trusted source.››';

  @override
  String get novaChatScreenAboutEducationalBody =>
      '‹‹NOVA is designed for learning support and is not a substitute for professional medical, legal, or financial advice.››';

  @override
  String get novaChatScreenAboutPrivacyBody =>
      '‹‹Conversations are used to generate responses. Do not share sensitive personal information.››';

  @override
  String get novaChatScreenDisclaimerTapToLearn =>
      '‹‹NOVA can make mistakes. Tap to learn more.››';

  @override
  String get userProfileSheetSchool => '‹‹School››';

  @override
  String get userProfileSheetClass => '‹‹Class››';

  @override
  String get userProfileSheetParents => '‹‹Parents››';

  @override
  String get userProfileSheetChildren => '‹‹Children››';

  @override
  String get scheduleScreenNotes => '‹‹Notes››';

  @override
  String get scheduleScreenMaterialFallback => '‹‹Material››';

  @override
  String get scheduleScreenNow => '‹‹NOW››';

  @override
  String scheduleScreenMaterialCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materials',
      one: '1 material',
    );
    return '‹‹$_temp0››';
  }

  @override
  String teacherFormResponsesScreenResponseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '‹‹$count response$_temp0››';
  }

  @override
  String get teacherFormResponsesScreenEmptyTitle => '‹‹No responses yet››';

  @override
  String get teacherFormResponsesScreenEmptySubtitle =>
      '‹‹Responses will appear here once students submit.››';

  @override
  String get teacherFormResponsesScreenStudentFallback => '‹‹Student››';

  @override
  String teacherFormResponsesScreenSubmittedAt(String date) {
    return '‹‹Submitted $date››';
  }

  @override
  String teacherCreateFormScreenQuestionNumber(String number) {
    return '‹‹Q$number››';
  }

  @override
  String get teacherCreateFormScreenShortAnswerPreview => '‹‹Short answer››';

  @override
  String get teacherCreateFormScreenLongAnswerPreview => '‹‹Long answer››';

  @override
  String get teacherCreateFormScreenDatePickerPreview => '‹‹Date picker››';

  @override
  String get teacherCreateFormScreenScaleTo => '‹‹to››';

  @override
  String get teacherMeetingsScreenNoneOption => '‹‹None››';

  @override
  String teacherMeetingsScreenGradeLabel(String grade) {
    return '‹‹Grade $grade››';
  }

  @override
  String teacherMeetingsScreenStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '‹‹$count student$_temp0››';
  }

  @override
  String get teacherMeetingsScreenPickStartTime => '‹‹Pick start time››';

  @override
  String get teacherMeetingsScreenPickEndTime => '‹‹Pick end time››';

  @override
  String teacherMeetingsScreenMembersWillReceive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '‹‹$count member$_temp0 will receive this››';
  }

  @override
  String get teacherAssignmentsScreenTitle => '‹‹Assignments››';

  @override
  String teacherAssignmentsScreenSummary(int total, int published) {
    return '‹‹$total total · $published published››';
  }

  @override
  String get teacherAssignmentsScreenEmpty =>
      '‹‹No assignments yet.\nTap + to create one.››';

  @override
  String teacherAssignmentsScreenSubmitted(int count) {
    return '‹‹$count submitted››';
  }

  @override
  String get audienceSectionCohorts => '‹‹Cohorts››';

  @override
  String get audienceSectionGrades => '‹‹Grades››';

  @override
  String audienceSectionGradeLabel(int grade) {
    return '‹‹Grade $grade››';
  }

  @override
  String get audienceSectionStudents => '‹‹Students››';

  @override
  String audienceSectionStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '‹‹$count student$_temp0››';
  }

  @override
  String audienceSectionMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '‹‹$count member$_temp0 will receive this››';
  }

  @override
  String audienceSectionSelectedCount(int count) {
    return '‹‹$count selected››';
  }

  @override
  String secretaryStudentsScreenStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '‹‹$count student$_temp0››';
  }

  @override
  String secretaryStudentsScreenAvg(String grade) {
    return '‹‹Avg $grade››';
  }

  @override
  String get secretaryStudentsScreenIdentity => '‹‹Identity››';

  @override
  String get secretaryStudentsScreenUsername => '‹‹Username››';

  @override
  String get secretaryStudentsScreenEmail => '‹‹Email››';

  @override
  String get secretaryStudentsScreenPhone => '‹‹Phone››';

  @override
  String get secretaryStudentsScreenCohort => '‹‹Cohort››';

  @override
  String get secretaryStudentsScreenGrade => '‹‹Grade››';

  @override
  String get secretaryStudentsScreenPrimaryCohort => '‹‹Primary cohort››';

  @override
  String secretaryStudentsScreenTeacher(String name) {
    return '‹‹Teacher: $name››';
  }

  @override
  String get chatMessageBubbleEdited => '‹‹edited››';

  @override
  String get chatMessageBubbleForwarded => '‹‹Forwarded››';

  @override
  String get chatMessageBubblePinned => '‹‹Pinned››';

  @override
  String get chatMessageBubbleReply => '‹‹Reply››';

  @override
  String get chatMessageBubbleMessage => '‹‹Message››';

  @override
  String get chatMessageBubbleDeletedMessage => '‹‹This message was deleted››';

  @override
  String get chatMessageBubbleImage => '‹‹Image››';

  @override
  String get chatMessageBubbleVideo => '‹‹Video››';

  @override
  String get chatMessageBubbleFile => '‹‹File››';

  @override
  String get chatMessageInfoPageReadSection => '‹‹Read››';

  @override
  String get chatMessageInfoPageNoOneRead => '‹‹No one has read this yet››';

  @override
  String get chatMessageInfoPageDeliveredSection => '‹‹Delivered››';

  @override
  String get chatMessageInfoPagePendingSection => '‹‹Pending››';

  @override
  String get chatMessageInfoPageUnknown => '‹‹Unknown››';

  @override
  String get profileEnterCodeTitle => '‹‹Enter the 6-digit code››';

  @override
  String profileCodeSentTo(String target) {
    return '‹‹Sent to $target. Expires in 15 minutes.››';
  }

  @override
  String get profileCodeSent => '‹‹Code sent. Expires in 15 minutes.››';

  @override
  String profileChangeContact(String label) {
    return '‹‹Change $label››';
  }

  @override
  String get profileVerifyNewContactInfo =>
      '‹‹A verification code will be sent to the value you enter — confirming you own it.››';

  @override
  String profileVerifyCurrentContactInfo(String label) {
    return '‹‹A verification code will be sent to your CURRENT $label so you can prove ownership before switching.››';
  }

  @override
  String get appShellReports => '‹‹Reports››';

  @override
  String get appShellExportData => '‹‹Export Data››';

  @override
  String get appShellAdmin => '‹‹Admin››';

  @override
  String get appShellViewingAs => '‹‹Viewing as ››';

  @override
  String get appShellSwitchChild => '‹‹Switch child››';

  @override
  String get messageThreadScreenGroupInviteSubtitle =>
      '‹‹You were invited to join this group.››';

  @override
  String get messageThreadScreenBlockedHint =>
      '‹‹You blocked this chat. Unblock from the blocked people list to chat again.››';

  @override
  String get messageThreadScreenCannotSendHint =>
      '‹‹You cannot send messages in this chat right now.››';

  @override
  String get messageThreadScreenTapForGroupInfo => '‹‹Tap for group info››';

  @override
  String get messageThreadScreenAddParticipantsTitle => '‹‹Add participants››';

  @override
  String teacherExamsScreenGradedCount(int count) {
    return '‹‹$count graded››';
  }

  @override
  String get teacherScheduleScreenNextUp => '‹‹Next up››';

  @override
  String teacherScheduleScreenPeriodLabel(String period) {
    return '‹‹Period $period››';
  }

  @override
  String teacherScheduleScreenGradeLabel(int grade) {
    return '‹‹Grade $grade››';
  }

  @override
  String teacherScheduleScreenMaterialsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count materials',
      one: '1 material',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get teacherClassroomAddAssignmentScreenTitle => '‹‹Add Assignment››';

  @override
  String get teacherClassroomAddAssignmentScreenDetails =>
      '‹‹Assignment Details››';

  @override
  String get teacherClassroomAddAssignmentScreenDueDateOptional =>
      '‹‹Due date (optional)››';

  @override
  String get teacherClassroomAddAssignmentScreenNotifyStudents =>
      '‹‹Notify students››';

  @override
  String get teacherClassroomAddAssignmentScreenUploading => '‹‹Uploading…››';

  @override
  String get teacherClassroomAddAssignmentScreenAttachFiles =>
      '‹‹Attach files››';

  @override
  String get teacherClassroomAddAssignmentScreenAddMoreFiles =>
      '‹‹Add more files››';

  @override
  String get diplomasScreenCertificate => '‹‹Certificate››';

  @override
  String diplomasScreenIssuedDate(String date) {
    return '‹‹Issued $date››';
  }

  @override
  String get diplomasScreenNoCertificatesReceived =>
      '‹‹No certificates received yet.››';

  @override
  String diplomasScreenFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '$count file',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get gradesScreenOutOf100 => '‹‹/ 100››';

  @override
  String gradesScreenShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '‹‹Show $count more grade$_temp0››';
  }

  @override
  String get gradesScreenShowLess => '‹‹Show less››';

  @override
  String gradesScreenScoreOutOf100(String score) {
    return '‹‹$score / 100››';
  }

  @override
  String get adminSchoolSettingsStart => '‹‹Start››';

  @override
  String get adminSchoolSettingsEnd => '‹‹End››';

  @override
  String get adminExportLayoutLabel => 'PDF layout';

  @override
  String get adminExportLayoutTable => 'Compact table';

  @override
  String get adminExportScreenEachUserAlone => '‹‹Each user alone››';

  @override
  String get adminExportScreenEachUserAloneOn =>
      '‹‹One full page per user, big readable card layout.››';

  @override
  String get adminExportScreenEachUserAloneOff =>
      '‹‹Compact table — every user is a row.››';

  @override
  String get adminExportScreenSeparateFilesOn => '‹‹Separate PDF per user››';

  @override
  String get adminExportScreenSeparateFilesOff =>
      '‹‹Single PDF, one page per user››';

  @override
  String adminExportScreenSeparateFilesOnDesc(int count) {
    return '‹‹You\'ll share $count PDF file(s) at once — each user gets their own.››';
  }

  @override
  String get adminExportScreenSeparateFilesOffDesc =>
      '‹‹Everyone in one PDF, each on their own page.››';

  @override
  String get adminSubjectDetailScreenSchoolSettings => '‹‹School Settings››';

  @override
  String get adminSubjectDetailScreenNewSubject => '‹‹New subject››';

  @override
  String get adminSubjectDetailScreenLangEnglish => '‹‹English››';

  @override
  String get adminSubjectDetailScreenLangArabic => '‹‹Arabic››';

  @override
  String get adminSubjectDetailScreenLangHebrew => '‹‹Hebrew››';

  @override
  String get adminSubjectDetailScreenLangFrench => '‹‹French››';

  @override
  String get adminSubjectDetailScreenLangRussian => '‹‹Russian››';

  @override
  String get adminSubjectDetailScreenColor => '‹‹Color››';

  @override
  String get parentHomeScreenGreetingFallback => '‹‹there››';

  @override
  String parentHomeScreenChildrenLoadError(String error) {
    return '‹‹Could not load your children: $error››';
  }

  @override
  String get parentHomeScreenMaterials => '‹‹Materials››';

  @override
  String get cmCodeBlockCopied => '‹‹Copied››';

  @override
  String get cmCodeBlockCopy => '‹‹Copy››';

  @override
  String get phoneFieldCountryCode => '‹‹Country code››';

  @override
  String get teacherClassroomAddMeetingScreenEndDateDefault =>
      '‹‹End date defaults to start date››';

  @override
  String get teacherAddMaterialScreenLinkHint => '‹‹https://…››';

  @override
  String get teacherAddMaterialScreenLinkFallback => '‹‹Link››';

  @override
  String get teacherAddMaterialScreenFileFallback => '‹‹File››';

  @override
  String get teacherCreateDiplomaScreenTitle => '‹‹Issue Certificate››';

  @override
  String get teacherCreateDiplomaScreenGradePrefix => '‹‹Grade››';

  @override
  String get teacherCreateDiplomaScreenAttachFiles =>
      '‹‹Attach certificate file(s)››';

  @override
  String get teacherCreateDiplomaScreenAddMoreFiles => '‹‹Add more files››';

  @override
  String get teacherAssignmentDetailScreenTitle => '‹‹Assignment››';

  @override
  String get teacherAssignmentDetailScreenNoSubmissions =>
      '‹‹No submissions yet››';

  @override
  String teacherAssignmentDetailScreenSubmissionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '‹‹$count submission$_temp0››';
  }

  @override
  String teacherAssignmentDetailScreenGradedCount(int count) {
    return '‹‹$count graded››';
  }

  @override
  String get teacherAssignmentDetailScreenStudentFallback => '‹‹Student››';

  @override
  String teacherAssignmentDetailScreenSubmittedOn(String date) {
    return '‹‹Submitted $date››';
  }

  @override
  String teacherAddAssignmentScreenGradeLabel(int count) {
    return '‹‹Grade $count››';
  }

  @override
  String teacherAddAssignmentScreenStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '‹‹$count student$_temp0››';
  }

  @override
  String teacherAddAssignmentScreenMembersWillReceive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '‹‹$count member$_temp0 will receive this››';
  }

  @override
  String get teacherAddAssignmentScreenNoDueDate => '‹‹No due date››';

  @override
  String get teacherAddAssignmentScreenMaterialFallback => '‹‹Material››';

  @override
  String teacherAddAssignmentScreenSelectedCount(int count) {
    return '‹‹$count selected››';
  }

  @override
  String teacherClassroomsScreenGradeLabel(int grade) {
    return '‹‹Grade $grade››';
  }

  @override
  String get teacherClassroomsScreenNewClassroom => '‹‹New Classroom››';

  @override
  String get assignmentsScreenAlreadyHandedIn =>
      '‹‹You have already handed in this assignment.››';

  @override
  String get assignmentsScreenAddNoteOrFiles =>
      '‹‹Add a note or attach files, then press Hand in.››';

  @override
  String assignmentsScreenGradeLabel(String grade) {
    return '‹‹Grade: $grade››';
  }

  @override
  String assignmentsScreenFeedbackLabel(String feedback) {
    return '‹‹Feedback: $feedback››';
  }

  @override
  String get assignmentsScreenReturnedForResolution =>
      '‹‹Returned for re-solution››';

  @override
  String get assignmentsScreenAttachFile => '‹‹Attach file››';

  @override
  String get assignmentsScreenAddMoreFiles => '‹‹Add more files››';

  @override
  String get assignmentsScreenHandingIn => '‹‹Handing in…››';

  @override
  String get assignmentsScreenHandIn => '‹‹Hand in››';

  @override
  String get examDetailScreenCouldNotLoad =>
      '‹‹Could not load this exam right now.››';

  @override
  String get adminEditUserRoleStudent => '‹‹Student››';

  @override
  String get adminEditUserRoleTeacher => '‹‹Teacher››';

  @override
  String get adminEditUserRoleSecretary => '‹‹Secretary››';

  @override
  String get adminEditUserRoleParent => '‹‹Parent››';

  @override
  String get adminEditUserRoleAdmin => '‹‹Admin››';

  @override
  String adminEditUserCohortMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    return '‹‹Member of $count cohort$_temp0.››';
  }

  @override
  String get adminEditUserSearchStudents => '‹‹Search students…››';

  @override
  String adminEditUserGradeSuffix(int grade) {
    return '‹‹(Grade $grade)››';
  }

  @override
  String get solutionAssetPreviewSheetPdfDocument => '‹‹PDF document››';

  @override
  String get solutionAssetPreviewSheetUnableToPreview =>
      '‹‹Unable to preview PDF.››';

  @override
  String classroomDetailSectionHeader(String title, int count) {
    return '‹‹$title ($count)››';
  }

  @override
  String get classroomDetailTeacherSection => '‹‹Teacher››';

  @override
  String get classroomDetailStudentsSection => '‹‹Students››';

  @override
  String get classroomDetailClassroomFallback => '‹‹Classroom››';

  @override
  String get classroomDetailUntitled => '‹‹Untitled››';

  @override
  String get typingDotsPaused => '‹‹Paused››';

  @override
  String get cmAiMessageStartPracticeSession => '‹‹Start practice session››';

  @override
  String cmAiMessageQuestionCount(int count) {
    return '‹‹$count questions››';
  }

  @override
  String get cmAiMessageDifficultyEasy => '‹‹Easy››';

  @override
  String get cmAiMessageDifficultyHard => '‹‹Hard››';

  @override
  String get cmAiMessageDifficultyOlympiad => '‹‹Olympiad››';

  @override
  String get cmAiMessageDifficultyAdaptive => '‹‹Adaptive››';

  @override
  String get cmAiMessageDifficultyMedium => '‹‹Medium››';

  @override
  String get teacherCreateFormScreenParagraphType => '‹‹Paragraph››';

  @override
  String get teacherCreateFormScreenMultipleChoiceType => '‹‹Multiple choice››';

  @override
  String get teacherCreateFormScreenCheckboxesType => '‹‹Checkboxes››';

  @override
  String get teacherCreateFormScreenRatingType => '‹‹Rating (1–5)››';

  @override
  String get teacherCreateFormScreenLinearScaleType => '‹‹Linear scale››';

  @override
  String get teacherCreateFormScreenDropdownType => '‹‹Dropdown››';

  @override
  String get teacherCreateFormScreenDateType => '‹‹Date››';

  @override
  String teacherCohortsScreenSingleGrade(int grade) {
    return '‹‹Grade $grade››';
  }

  @override
  String teacherCohortsScreenGradeRange(int from, int to) {
    return '‹‹Grade $from-$to››';
  }

  @override
  String teacherCohortsScreenMultiGrade(String grades) {
    return '‹‹Grades $grades››';
  }

  @override
  String get teacherAddGradeScreenFailedCreateRecord =>
      '‹‹Failed to create grade record.››';

  @override
  String get phoneFieldLabel => '‹‹Phone (optional)››';

  @override
  String get phoneFieldHelper => '‹‹Used for SMS password reset››';

  @override
  String get gradesScreenCouldNotLoad => '‹‹Could not load grades.››';

  @override
  String get gradesScreenTimeout =>
      '‹‹Request timed out. Check your connection.››';

  @override
  String get gradesScreenNoConnection => '‹‹No connection. Pull to retry.››';

  @override
  String get examDetailScreenCountdownPassed => '‹‹This exam has passed››';

  @override
  String get examDetailScreenCountdownToday => '‹‹It\'s today!››';

  @override
  String get teacherCreateDiplomaScreenDefaultTitle =>
      '‹‹Certificate of Achievement››';

  @override
  String teacherMaterialAddedBy(String name) {
    return '‹‹Added by $name››';
  }

  @override
  String teacherMaterialAttachedTo(String period) {
    return '‹‹Attached to $period››';
  }

  @override
  String get adminPeopleAddMany => '‹‹Add many››';

  @override
  String get adminAddManyPasteNames => '‹‹Paste names››';

  @override
  String get adminAddManyApplyRole => '‹‹Set role for all››';

  @override
  String get adminAddManyApplyGrade => '‹‹Set grade for all››';

  @override
  String get adminAddManyParentLabel => '‹‹Parent››';

  @override
  String get adminAddManyParentNone => '‹‹No parent››';

  @override
  String get adminAddManyAddParent => '‹‹Add parent››';

  @override
  String get adminAddManyCreateParentGeneric => '‹‹Create new parent››';

  @override
  String get adminAddManyParentInBatch => '‹‹New parents in this list››';

  @override
  String get adminAddManyParentExisting => '‹‹Existing parents››';

  @override
  String get adminAddManySearchParents => '‹‹Search parents…››';

  @override
  String get adminAddManyNoParentsYet =>
      '‹‹No matching parents — type a name above to create one››';

  @override
  String get adminAddManyUsernameTaken => '‹‹Username already taken››';

  @override
  String get adminAddManyUsernameDupe => '‹‹Duplicate username in this list››';

  @override
  String get adminUsernameAvailable => '‹‹Username is available››';

  @override
  String get adminUsernameInvalidFormat =>
      '‹‹Use 3+ letters, digits, or . _ -››';

  @override
  String get adminUsernameSuggestionsLabel =>
      '‹‹Available suggestions — tap to use:››';

  @override
  String adminAddManyCreateParent(String name) {
    return '‹‹Create new parent \"$name\"››';
  }

  @override
  String adminAddManyPastedRows(int count) {
    return '‹‹Added $count rows››';
  }

  @override
  String get teacherCreateClassroomNoStudentsInCohort =>
      '‹‹No students in the selected cohort yet.››';

  @override
  String get audienceSummaryResolving => '‹‹Finding students…››';

  @override
  String audienceSummaryCount(int count) {
    return '‹‹$count will see this››';
  }

  @override
  String get audienceSummaryEmpty => '‹‹No students match this audience.››';

  @override
  String audienceSummaryRestore(int count) {
    return '‹‹Restore $count removed››';
  }

  @override
  String get scheduleUpcomingExam => '‹‹Upcoming Exam››';

  @override
  String get scheduleNoUpcomingExams => '‹‹No upcoming exams››';

  @override
  String get navCertificates => '‹‹Certificates››';

  @override
  String get averagesDelete => '‹‹Delete››';

  @override
  String get averagesFieldTitle => '‹‹Title››';

  @override
  String get averagesSave => '‹‹Save››';

  @override
  String get certificatesTitle => '‹‹Certificates››';

  @override
  String get certHomeroom => '‹‹Class (homeroom)››';

  @override
  String get certStudent => '‹‹Student››';

  @override
  String get certDisplayName => '‹‹Name on certificate››';

  @override
  String get certNationalId => '‹‹National ID››';

  @override
  String get certHomeroomTeacher => '‹‹Homeroom teacher››';

  @override
  String get certPrincipal => '‹‹Principal››';

  @override
  String get certPublisherNote => '‹‹Note (optional)››';

  @override
  String get certSemesterWeights => '‹‹Semester weights››';

  @override
  String get certLanguage => '‹‹Certificate language››';

  @override
  String get certGenerate => '‹‹Generate PDF››';

  @override
  String get certWeightsMustBe100 => '‹‹Semester weights must total 100%.››';

  @override
  String get certSelectStudentFirst => '‹‹Select a student first.››';

  @override
  String get certSaved => '‹‹Certificate generated.››';

  @override
  String get certSaveAndPublish => '‹‹Save & publish››';

  @override
  String get certSaveDraft => '‹‹Save as draft››';

  @override
  String get examGradesPublished => '‹‹Grades published to students.››';

  @override
  String get examGradesPublishedShort => '‹‹Published››';

  @override
  String get examRepublish => '‹‹Republish››';

  @override
  String get certPreview => '‹‹Preview PDF››';

  @override
  String get certPublished => '‹‹Published to the student.››';

  @override
  String get certDraftSaved => '‹‹Saved as draft.››';

  @override
  String get certPublishing => '‹‹Publishing…››';

  @override
  String get certDownload => '‹‹Download››';

  @override
  String get certNoneYet => '‹‹No certificates yet.››';

  @override
  String get certMine => '‹‹My certificates››';

  @override
  String get certNoHomeroom =>
      '‹‹You are not a homeroom teacher of any class yet.››';

  @override
  String get certGrin => '‹‹Grades››';

  @override
  String get certPrintAll => '‹‹Print all››';

  @override
  String get certSelectCohortToPrint =>
      '‹‹Select a class to print all its certificates.››';

  @override
  String get certEditTitle => '‹‹Edit certificate››';

  @override
  String get certPdfAnnualCertificate => '‹‹Annual Certificate››';

  @override
  String get certPdfSubject => '‹‹Subject››';

  @override
  String get certPdfFinal => '‹‹Final››';

  @override
  String get certPdfOverall => '‹‹General Average››';

  @override
  String get certPdfAverage => '‹‹Average››';

  @override
  String get certPdfAbsences => '‹‹Absences››';

  @override
  String get certPdfLateness => '‹‹Lateness››';

  @override
  String get certPdfHomeroomTeacher => '‹‹Homeroom teacher››';

  @override
  String get certPdfPrincipal => '‹‹Principal››';

  @override
  String get certPdfNationalId => '‹‹ID No.››';

  @override
  String get certPdfDate => '‹‹Date››';

  @override
  String get certPdfGeneratedBy => '‹‹Created by››';

  @override
  String get certPdfName => '‹‹Name››';

  @override
  String get certPdfClass => '‹‹Class››';

  @override
  String get adminEditUserNationalId => '‹‹National ID››';

  @override
  String get teacherCohortsScreenNoStudentsToAdd =>
      '‹‹All students are already in this class.››';

  @override
  String get gradeWeightLabel => '‹‹Weight on average (%)››';

  @override
  String get gradeWeightHint =>
      '‹‹Optional — set what % this counts toward the subject average, or leave blank to set later.››';

  @override
  String get gradeSemesterLabel => '‹‹Semester››';

  @override
  String get gradeSemesterAuto => '‹‹Auto (by date)››';

  @override
  String get gradeDeleteTooltip => '‹‹Delete grade››';

  @override
  String get gradeDeleteTitle => '‹‹Delete grade››';

  @override
  String gradeDeleteConfirm(String title) {
    return '‹‹Delete the grade for “$title”?››';
  }

  @override
  String get cohortHomeroomLabel => '‹‹Homeroom class››';

  @override
  String get cohortHomeroomHint =>
      '‹‹Assign a homeroom teacher for this class.››';

  @override
  String get cohortHomeroomTeacher => '‹‹Homeroom teacher››';

  @override
  String get adminPrincipalLabel => '‹‹Principal››';

  @override
  String get adminPrincipalHint =>
      '‹‹This admin is a principal; certificates auto-fill their name by the student’s grade.››';

  @override
  String get adminPrincipalGrades => '‹‹Principal for grades››';

  @override
  String get certPdfTeacher => '‹‹Teacher››';

  @override
  String gradesHubSummary(int subjects, int students) {
    return '‹‹$subjects subjects · $students students››';
  }

  @override
  String get gradesHubSearchSubjects => '‹‹Search subjects››';

  @override
  String get gradesHubEmpty =>
      '‹‹No grades yet. Add a grade and the subject will appear here.››';

  @override
  String gradesHubStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students',
      one: '1 student',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get gradesSubjectStudentsTab => '‹‹Students››';

  @override
  String get gradesSubjectGradesTab => '‹‹Grades››';

  @override
  String get gradesSubjectNoGrades => '‹‹No grades in this subject yet.››';

  @override
  String get gradesPublishedShort => '‹‹Published››';

  @override
  String get gradesDraftShort => '‹‹Draft››';

  @override
  String gradesPublishTitle(Object title) {
    return '‹‹Publish “$title”››';
  }

  @override
  String gradesUnpublishTitle(Object title) {
    return '‹‹Unpublish “$title”››';
  }

  @override
  String get gradesPublishAction => '‹‹Publish››';

  @override
  String get gradesUnpublishAction => '‹‹Unpublish››';

  @override
  String get gradesPublishedToast =>
      '‹‹Grade published — students can now see it.››';

  @override
  String get gradesUnpublishedToast =>
      '‹‹Grade unpublished — hidden from students.››';

  @override
  String get navGradeScales => '‹‹Grade Scales››';

  @override
  String get gradeScaleAdd => '‹‹Add grade scale››';

  @override
  String get gradeScaleEdit => '‹‹Edit grade scale››';

  @override
  String get gradeScaleDeleteTitle => '‹‹Delete grade scale?››';

  @override
  String gradeScaleDeleteConfirm(Object name) {
    return '‹‹Delete “$name”? Assessments already graded on it keep their labels.››';
  }

  @override
  String get gradeScaleEmptyTitle => '‹‹No grade scales yet››';

  @override
  String get gradeScaleEmptyHint =>
      '‹‹Create a letter or word scale (e.g. A, A+, B) for younger grades. Teachers grading those grades pick a label instead of a number.››';

  @override
  String get gradeScaleAllGrades => '‹‹Applies to all grades››';

  @override
  String gradeScaleAppliesTo(Object grades) {
    return '‹‹Grades $grades››';
  }

  @override
  String get gradeScaleNameLabel => '‹‹Scale name››';

  @override
  String get gradeScaleNameHint => '‹‹e.g. Letter grades››';

  @override
  String get gradeScaleNameRequired => '‹‹Enter a scale name.››';

  @override
  String get gradeScaleGradeLevels => '‹‹Applies to grades››';

  @override
  String get gradeScaleGradeLevelsHint =>
      '‹‹Leave none selected to apply to all grades.››';

  @override
  String get gradeScaleLabels => '‹‹Labels››';

  @override
  String get gradeScaleLabelsHint =>
      '‹‹Add each label (e.g. A+) with an optional number (0–100) used for averages.››';

  @override
  String get gradeScaleLabelText => '‹‹Label››';

  @override
  String get gradeScaleLabelValue => '‹‹Value››';

  @override
  String get gradeScaleAddLabel => '‹‹Add label››';

  @override
  String get gradeScaleNeedTwoLabels => '‹‹Add at least two labels.››';

  @override
  String get gradeScalePickLabel => '‹‹Grade››';

  @override
  String get gradeScaleUseScale => '‹‹Grade scale››';

  @override
  String gradeScaleNumeric(Object max) {
    return '‹‹Number (0–$max)››';
  }

  @override
  String get accountSwitcherTitle => '‹‹Accounts››';

  @override
  String get accountAddAccount => '‹‹Add account››';

  @override
  String get accountSignOutThis => '‹‹Sign out this account››';

  @override
  String get averagesManageTooltip => '‹‹Manage averages››';

  @override
  String get averagesTitle => '‹‹Averages››';

  @override
  String get averagesAdd => '‹‹Add average››';

  @override
  String get averagesDeleteTitle => '‹‹Delete average››';

  @override
  String averagesDeleteConfirm(Object title) {
    return '‹‹Delete \"$title\"? This cannot be undone.››';
  }

  @override
  String get averagesCancel => '‹‹Cancel››';

  @override
  String get averagesEmptyTitle => '‹‹No averages yet››';

  @override
  String get averagesEmptyBody =>
      '‹‹Tap \"Add average\" to create a weighted grade formula for a subject.››';

  @override
  String get averagesFullYear => '‹‹Full year››';

  @override
  String averagesSemesterN(Object n) {
    return '‹‹Semester $n››';
  }

  @override
  String averagesFormatChip(Object index, Object total) {
    return '‹‹Format $index: $total%››';
  }

  @override
  String get averagesNoStudents => '‹‹No students to compute.››';

  @override
  String averagesFormatN(Object n) {
    return '‹‹Format $n››';
  }

  @override
  String get averagesErrTitle => '‹‹Enter a title.››';

  @override
  String get averagesErrSubject => '‹‹Choose a subject.››';

  @override
  String get averagesErrCohort => '‹‹Choose a cohort.››';

  @override
  String get averagesErrNoFormat => '‹‹Add at least one format.››';

  @override
  String averagesErrFormatNoGrade(Object n) {
    return '‹‹Format $n: pick at least one grade.››';
  }

  @override
  String averagesErrFormatSum(Object n, Object total) {
    return '‹‹Format $n: weights must sum to 100 (now $total%).››';
  }

  @override
  String get averagesNew => '‹‹New average››';

  @override
  String get averagesEdit => '‹‹Edit average››';

  @override
  String get averagesLabelSubject => '‹‹Subject››';

  @override
  String get averagesHintSubject => '‹‹Choose a subject››';

  @override
  String get averagesLabelCohort => '‹‹Cohort››';

  @override
  String get averagesHintCohort => '‹‹Choose a cohort››';

  @override
  String get averagesLabelUnits => '‹‹Units (optional)››';

  @override
  String get averagesFormats => '‹‹Formats››';

  @override
  String get averagesFormatsHelp =>
      '‹‹Each format\'s weights must sum to 100%. The best-scoring format is used per student.››';

  @override
  String get averagesAddFormat => '‹‹Add format››';

  @override
  String get averagesLabelFormatLabel => '‹‹Format label (optional)››';

  @override
  String get averagesAddGrade => '‹‹Add grade››';

  @override
  String averagesTotal(Object total) {
    return '‹‹Total: $total%››';
  }

  @override
  String get averagesLabelGrade => '‹‹Grade››';

  @override
  String get averagesHintPickFirst => '‹‹Pick subject & cohort first››';

  @override
  String get averagesHintGrade => '‹‹Choose a grade››';

  @override
  String get adminInsightsSearchHint => '‹‹Search students by name…››';

  @override
  String get adminInsightsNoStudents => '‹‹No students found.››';

  @override
  String get adminInsightsNoGrades => '‹‹No grades recorded yet.››';

  @override
  String get gradesEditGradeTitle => '‹‹Edit grade››';

  @override
  String gradeFormatN(String n) {
    return '‹‹Format $n››';
  }

  @override
  String get gradeAddFormat => '‹‹Add format››';

  @override
  String get gradesBreakdownAverage => '‹‹Average››';

  @override
  String get adminPrincipalRangeFrom => '‹‹From››';

  @override
  String get adminPrincipalRangeTo => '‹‹To››';

  @override
  String get adminPrincipalAddRange => '‹‹Add range››';

  @override
  String certPdfSemesterCertificate(String sem) {
    return '‹‹Semester Certificate — $sem››';
  }

  @override
  String get certPdfRemarks => '‹‹Homeroom teacher\'s remarks››';

  @override
  String get certTypeLabel => '‹‹Certificate type››';

  @override
  String get certTypeAnnual => '‹‹Annual››';

  @override
  String certTypeSemester(String sem) {
    return '‹‹End of $sem››';
  }

  @override
  String get certRoundWhole => '‹‹Round to whole number››';

  @override
  String get certRoundWholeHint =>
      '‹‹Below .5 rounds down, .5 and up rounds up. Turn off to show two decimals.››';

  @override
  String get teacherAddGradeSubjectRequired =>
      '‹‹Please choose a subject for this grade.››';

  @override
  String get gradesSubjectAveragesTab => '‹‹Averages››';

  @override
  String get gradesAveragesSummaryTitle => '‹‹Semester average››';

  @override
  String gradesAveragesSummaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weighted grades',
      one: '1 weighted grade',
      zero: 'No weighted grades yet',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get gradesAveragesTotalWeight => '‹‹Total weight››';

  @override
  String get gradesAveragesNoWeighted =>
      '‹‹No grades with a weight in this semester. Add one or set a % on a grade.››';

  @override
  String get gradesAvgPickTitle => '‹‹Add a grade to the average››';

  @override
  String gradesAvgPickSubtitle(String subject) {
    return '‹‹Pick a published grade in $subject, then set its weight, semester and format.››';
  }

  @override
  String get gradesAvgFilterAll => '‹‹All››';

  @override
  String gradesAvgFilterCohort(String name) {
    return '‹‹Cohort — $name››';
  }

  @override
  String get gradesAvgSearchHint => '‹‹Search grades››';

  @override
  String get gradesAvgNoResults => '‹‹No matching grades in this subject.››';

  @override
  String get gradesAvgInAverage => '‹‹In average››';

  @override
  String get notesTitle => '‹‹Notes››';

  @override
  String get notesSearchStudents => '‹‹Search students››';

  @override
  String get notesNoStudents => '‹‹No students found››';

  @override
  String notesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
      zero: 'No notes',
    );
    return '‹‹$_temp0››';
  }

  @override
  String get notesNewNote => '‹‹New note››';

  @override
  String get notesNoNotes => '‹‹No notes yet››';

  @override
  String get notesNoNotesHint =>
      '‹‹Tap + to write the first note about this student.››';

  @override
  String get notesDeleteTitle => '‹‹Delete note?››';

  @override
  String get notesDeleteBody => '‹‹This note will be permanently deleted.››';

  @override
  String get notesUntitled => '‹‹Untitled››';

  @override
  String get notesTitleHint => '‹‹Title››';

  @override
  String get notesBodyHint => '‹‹Start writing…››';

  @override
  String notesEditedBy(String name) {
    return '‹‹By $name››';
  }

  @override
  String get cmailTitle => '‹‹CMail››';

  @override
  String get cmailInbox => '‹‹Inbox››';

  @override
  String get cmailSentTab => '‹‹Sent››';

  @override
  String get cmailCompose => '‹‹New mail››';

  @override
  String get cmailEmptyInbox => '‹‹No mail yet››';

  @override
  String get cmailEmptyInboxHint =>
      '‹‹Mail from your school will appear here.››';

  @override
  String get cmailEmptySent => '‹‹Nothing sent yet››';

  @override
  String get cmailSubject => '‹‹Subject››';

  @override
  String get cmailBodyHint => '‹‹Write your message…››';

  @override
  String get cmailAudience => '‹‹To››';

  @override
  String get cmailAudienceSchool => '‹‹Everyone››';

  @override
  String get cmailAudienceStudents => '‹‹All students››';

  @override
  String get cmailAudienceTeachers => '‹‹All teachers››';

  @override
  String get cmailAudienceParents => '‹‹All parents››';

  @override
  String get cmailAudienceStaff => '‹‹Staff››';

  @override
  String get cmailAudienceGrades => '‹‹By grade››';

  @override
  String get cmailAudienceCohorts => '‹‹By class››';

  @override
  String get cmailAudienceUsers => '‹‹Specific people››';

  @override
  String get cmailPickGrades => '‹‹Pick grades››';

  @override
  String get cmailPickCohorts => '‹‹Pick classes››';

  @override
  String get cmailPickPeople => '‹‹Pick people››';

  @override
  String get cmailAttach => '‹‹Attach files››';

  @override
  String get cmailSendAction => '‹‹Send››';

  @override
  String get cmailSentOk => '‹‹Mail sent››';

  @override
  String get cmailDeleteTitle => '‹‹Delete mail?››';

  @override
  String get cmailDeleteForAll => '‹‹This deletes the mail for everyone.››';

  @override
  String get cmailDeleteForMe => '‹‹This removes the mail from your inbox.››';

  @override
  String cmailRecipients(num count) {
    return '‹‹$count recipients››';
  }

  @override
  String cmailReadStats(num read, num total) {
    return '‹‹$read of $total read››';
  }

  @override
  String get cmailSubjectRequired => '‹‹Subject is required››';

  @override
  String get cmailAudienceRequired => '‹‹Pick who this mail goes to››';

  @override
  String get cmailAttachments => '‹‹Attachments››';

  @override
  String cmailFrom(String name) {
    return '‹‹From $name››';
  }

  @override
  String get phoneLinkTitle => '‹‹Add your phone››';

  @override
  String get phoneLinkSubtitle =>
      '‹‹Protect your account with a phone number. We\'ll text you a verification code — it also lets you reset your password by SMS.››';

  @override
  String get phoneLinkFieldLabel => '‹‹Phone number››';

  @override
  String get phoneLinkSend => '‹‹Send code››';

  @override
  String get phoneLinkCodeLabel => '‹‹6-digit code››';

  @override
  String phoneLinkCodeSent(String phone) {
    return '‹‹Code sent to $phone››';
  }

  @override
  String get phoneLinkVerify => '‹‹Verify & link››';

  @override
  String get phoneLinkLater => '‹‹Later››';

  @override
  String get phoneLinkDone => '‹‹Phone linked!››';

  @override
  String get phoneLinkResend => '‹‹Resend code››';

  @override
  String get phoneLinkInvalid => '‹‹Enter a valid phone number››';

  @override
  String get hubParentsSection => '‹‹Parents››';

  @override
  String get hubNoParents => '‹‹No linked parents yet››';

  @override
  String get hubStudentSection => '‹‹Student››';

  @override
  String get hubAverageLabel => '‹‹Average››';

  @override
  String get hubAccuracyLabel => '‹‹Practice accuracy››';

  @override
  String get hubBestSubject => '‹‹Best subject››';

  @override
  String get hubWeakestSubject => '‹‹Weakest subject››';

  @override
  String get hubWeakTopics => '‹‹Weak topics››';

  @override
  String get hubStrongTopics => '‹‹Strong topics››';

  @override
  String get hubNoInsights => '‹‹No insights yet››';

  @override
  String get hubNoGrades => '‹‹No grades yet››';

  @override
  String get hubUnpublished => '‹‹Draft››';

  @override
  String get hubClass => '‹‹Class››';

  @override
  String get a11yBack => '‹‹Back››';

  @override
  String get a11yClose => '‹‹Close››';

  @override
  String get a11yCancel => '‹‹Cancel››';

  @override
  String get a11yDone => '‹‹Done››';

  @override
  String get a11ySave => '‹‹Save››';

  @override
  String get a11yEdit => '‹‹Edit››';

  @override
  String get a11yDelete => '‹‹Delete››';

  @override
  String get a11yRemove => '‹‹Remove››';

  @override
  String get a11yAdd => '‹‹Add››';

  @override
  String get a11yCreate => '‹‹Create››';

  @override
  String get a11ySend => '‹‹Send››';

  @override
  String get a11ySearch => '‹‹Search››';

  @override
  String get a11yClear => '‹‹Clear››';

  @override
  String get a11yFilter => '‹‹Filter››';

  @override
  String get a11ySort => '‹‹Sort››';

  @override
  String get a11yMore => '‹‹More options››';

  @override
  String get a11yMenu => '‹‹Menu››';

  @override
  String get a11yRefresh => '‹‹Refresh››';

  @override
  String get a11yRetry => '‹‹Retry››';

  @override
  String get a11yShare => '‹‹Share››';

  @override
  String get a11yCopy => '‹‹Copy››';

  @override
  String get a11yDownload => '‹‹Download››';

  @override
  String get a11yUpload => '‹‹Upload››';

  @override
  String get a11yAttach => '‹‹Attach file››';

  @override
  String get a11yAddPhoto => '‹‹Add photo››';

  @override
  String get a11yCamera => '‹‹Camera››';

  @override
  String get a11yMicrophone => '‹‹Voice input››';

  @override
  String get a11yPlay => '‹‹Play››';

  @override
  String get a11yPause => '‹‹Pause››';

  @override
  String get a11yNext => '‹‹Next››';

  @override
  String get a11yPrevious => '‹‹Previous››';

  @override
  String get a11yExpand => '‹‹Expand››';

  @override
  String get a11yCollapse => '‹‹Collapse››';

  @override
  String get a11yShow => '‹‹Show››';

  @override
  String get a11yHide => '‹‹Hide››';

  @override
  String get a11ySettings => '‹‹Settings››';

  @override
  String get a11yProfile => '‹‹Profile››';

  @override
  String get a11yNotifications => '‹‹Notifications››';

  @override
  String get a11yHelp => '‹‹Help››';

  @override
  String get a11yInfo => '‹‹Details››';

  @override
  String get a11yFavorite => '‹‹Favorite››';

  @override
  String get a11yPin => '‹‹Pin››';

  @override
  String get a11yUnpin => '‹‹Unpin››';

  @override
  String get a11yMute => '‹‹Mute››';

  @override
  String get a11yUnmute => '‹‹Unmute››';

  @override
  String get a11yMarkRead => '‹‹Mark as read››';

  @override
  String get a11yNewChat => '‹‹New chat››';

  @override
  String get a11yNewMessage => '‹‹New message››';

  @override
  String get a11yEmoji => '‹‹Emoji››';

  @override
  String get a11ySelectDate => '‹‹Select date››';

  @override
  String get a11yLogout => '‹‹Log out››';

  @override
  String get a11yAddAccount => '‹‹Add account››';

  @override
  String get a11yShowPassword => '‹‹Show password››';

  @override
  String get a11yHidePassword => '‹‹Hide password››';

  @override
  String get a11yScrollToBottom => '‹‹Scroll to bottom››';

  @override
  String get a11yOpen => '‹‹Open››';

  @override
  String get errStateOfflineTitle => 'تاسو آفلاین یاست';

  @override
  String get errStateOfflineBody =>
      'دا مهال ClassMate ته نه شو رسېدلی. خپل Wi-Fi یا موبایل ډېټا وګورئ، بیا هڅه وکړئ.';

  @override
  String get errStateServerTitle => 'زموږ په اړخ کې ستونزه رامنځته شوه';

  @override
  String get errStateServerBody =>
      'زموږ سرورونه له ستونزې سره مخ شول. دا ستاسو تېروتنه نه ده — مهرباني وکړئ یوه شېبه وروسته بیا هڅه وکړئ.';

  @override
  String get errStateNotFoundTitle => 'هغه مو ونه موندل';

  @override
  String get errStateNotFoundBody => 'دا توکی ښایي لېږدول شوی یا ړنګ شوی وي.';

  @override
  String get errStateForbiddenTitle => 'تاسو لاسرسی نه لرئ';

  @override
  String get errStateForbiddenBody =>
      'دا برخه ستاسو د حساب لپاره تړلې ده. که دا سمه نه بریښي، د خپل ښوونځي له اډمین څخه وپوښتئ.';

  @override
  String get errStateTimeoutTitle => 'دې ډېر وخت ونیوه';

  @override
  String get errStateTimeoutBody =>
      'غوښتنې وخت پای ته ورساوه یا سرور بوخت دی. یوه شېبه صبر وکړئ، بیا هڅه وکړئ.';

  @override
  String get errStateEmptyTitle => 'دلته تر اوسه څه نشته';

  @override
  String get errStateEmptyBody =>
      'کله چې د ښودلو لپاره څه وي، همدلته به ښکاره شي.';

  @override
  String get errStateGenericTitle => 'کومه ستونزه رامنځته شوه';

  @override
  String get errStateGenericBody =>
      'له ناڅاپي ستونزې سره مخ شو. بیا هڅه وکړئ — ډېری وخت په دویم ځل کار کوي.';

  @override
  String get updatePromptTitle => '‹‹Update available››';

  @override
  String get updatePromptBody =>
      '‹‹A new version of ClassMate is ready. Update now to get the latest features and fixes.››';

  @override
  String get updatePromptUpdate => '‹‹Update››';

  @override
  String get updatePromptLater => '‹‹Not now››';

  @override
  String get chatPublishAssignment => '‹‹New assignment››';

  @override
  String get chatPublishMaterial => '‹‹New material››';

  @override
  String get chatPublishMeeting => '‹‹New meeting››';

  @override
  String get chatPublishView => '‹‹View››';

  @override
  String get settingsAppFont => '‹‹App font››';

  @override
  String get settingsAppFontSubtitle =>
      '‹‹Choose the typeface used across the app››';

  @override
  String get settingsAppFontDefault => '‹‹Default››';

  @override
  String get settingsAppFontSpecimen =>
      '‹‹The quick brown fox jumps over the lazy dog››';

  @override
  String get onbWhatsInside => 'تاسو څه کولی شئ';

  @override
  String onbStepOf(int current, int total) {
    return '$current د $total';
  }

  @override
  String get onbBack => 'بېرته';

  @override
  String get onbSwipeHint => 'د لیدلو لپاره سوایپ کړئ';

  @override
  String get onbDeepWelcome =>
      'ستاسو مهال ویش، نمرې، کورنی کار، پیغامونه او یادښتونه ټول دلته دي — د ښوونځي لپاره یو ننوتل. دا یوه چټکه کتنه ده.';

  @override
  String get onbDeepNova =>
      'له NOVA څخه په خپلو کلمو هر څه وپوښتئ او ګام په ګام تشریح ترلاسه کړئ. هر موضوع په تمرین بدل کړئ، هغه پوښتنې وساتئ چې بیا کتل غواړئ، او د یوې ستونزمنې پوښتنې عکس واخلئ تر څو حل شي.';

  @override
  String get onbDeepTrack =>
      'د اپلیکېشن په پرانیستو سره د نن ورځې درسونه وګورئ، نمره سمدلاسه وګورئ چې خپره شي، خپله حاضري وګورئ، او ټولې دندې په یوه لیست کې وساتئ — د وخت نه مخکې یادونې سره.';

  @override
  String get onbDeepClassNotes =>
      'په iPad کې د Apple Pencil سره په لاس یادښتونه ولیکئ — سرپوښونه، د کاغذ بڼې، ټېپ، عکسونه او غږیز یادښتونه — بیا دلته یې ولولئ، لیکنه لویه کړئ، غږونه واورئ او هر ضمیمه پرانیزئ.';

  @override
  String get onbDeepConnect =>
      'مستقیم یو ښوونکي یا همصنفي ته پیغام ولیکئ، د ټولګي اعلانونه تعقیب کړئ، له کارت څخه آنلاین غونډې ته ورشئ، او خپل د ښوونځي CMail وکاروئ — د اپلیکېشن پرېښودو پرته.';

  @override
  String get onbDeepTeacherClasses =>
      'ټولګی پرانیزئ چې وګورئ څوک دي، په دوو ټکونو حاضري واخلئ، دندې او مواد ورکړئ، او د هر ګروپ لیست منظم وساتئ.';

  @override
  String get onbDeepTeacherGrading =>
      'په خپل معیار نمرې ورکړئ، چې تیار شوئ خپرې کړئ، او پرېږدئ چې Insights وښيي چې څوک وروسته پاتې کیږي — تر ستونزې مخکې.';

  @override
  String get onbDeepTeacherComms =>
      'یو اعلان ټول ګروپ ته خپور کړئ، مستقیم یو والدین یا شاګرد ته پیغام ولیکئ، غونډه وټاکئ، او د فورم له لارې ځوابونه راټول کړئ.';

  @override
  String get onbDeepAdminOps =>
      'ښوونځی له یوې دشبورډ څخه وچلوئ: مهال ویش جوړ کړئ، د نمرو معیارونه وټاکئ، راپورونه وګورئ او اړین معلومات صادر کړئ.';

  @override
  String get onbDeepAdminPeople =>
      'شاګردان، ښوونکي او والدین اضافه کړئ، په ګروپونو ووېشئ، والدین له ماشوم سره ونښلوئ، او د کال په پای کې سندونه ورکړئ.';

  @override
  String get onbDeepSecretary =>
      'ورځ روانه وساتئ: مهال ویش سم کړئ، د یو کس ریکارډ اضافه یا نوی کړئ، سندونه ورکړئ او ژر اعلان خپور کړئ.';

  @override
  String get onbDeepParentChild =>
      'د خپلو ماشومانو ترمنځ بدلون وکړئ او د هر یو مهال ویش، نمرې، حاضري او کورنی کار وګورئ — هماغه انځور چې ښوونځی ویني.';

  @override
  String get onbDeepParentAlerts =>
      'خبر شئ کله چې نمره خپره شي، غیر حاضري ثبت شي یا ښوونځی څه خپروي — او هماغه ځای کې ښوونکي ته ځواب ولیکئ.';

  @override
  String get settingsAddTheme => 'Add theme';

  @override
  String get settingsNewTheme => 'New theme';

  @override
  String get settingsThemeNameHint => 'My theme';

  @override
  String get settingsThemeAccentLabel => 'Accent';

  @override
  String get settingsCreateTheme => 'Create theme';

  @override
  String get settingsEditTheme => 'Edit theme';

  @override
  String get settingsSaveTheme => 'Save changes';

  @override
  String get settingsThemeNameRequired => 'Enter a name for your theme';

  @override
  String get settingsThemeNameDuplicate =>
      'You already have a theme with this name';

  @override
  String get settingsDeleteThemeTitle => 'Delete theme?';

  @override
  String settingsDeleteThemeBody(String name) {
    return '“$name” will be removed. This can\'t be undone.';
  }

  @override
  String get cnMoveToShelf => 'Move to shelf';

  @override
  String get cnNotOnShelf => 'Not on a shelf';

  @override
  String get cnDownloadAsPdf => 'Download as PDF';

  @override
  String get cnOpenPagesPng => 'Open pages as PNG';

  @override
  String get cnDownloadPagesPng => 'Download pages as PNG';

  @override
  String get cnDeleteNotebookSubtitle =>
      'Removes it from ClassNotes on all your devices';

  @override
  String get cnRenameNotebook => 'Rename notebook';

  @override
  String get cnNotebookTitleHint => 'Notebook title';

  @override
  String get cnRenamed => 'Renamed';

  @override
  String get cnTakenOffShelf => 'Taken off the shelf';

  @override
  String get cnMoved => 'Moved';

  @override
  String get cnBuildingPdf => 'Building PDF…';

  @override
  String get cnPreparingPages => 'Preparing pages…';

  @override
  String get cnNoSyncedPages =>
      'This notebook has no synced pages yet — open it on your iPad once.';

  @override
  String cnExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get cnDeleteNotebookTitle => 'Delete this notebook?';

  @override
  String cnDeleteNotebookBody(String title, num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString pages',
      one: '1 page',
    );
    return '\"$title\" and its $_temp0 will be removed from ClassNotes on every device. This can\'t be undone.';
  }

  @override
  String get cnDeleted => 'Deleted';

  @override
  String get cnRenameShelf => 'Rename shelf';

  @override
  String get cnShelfNameHint => 'Shelf name';

  @override
  String get cnDeleteShelf => 'Delete shelf';

  @override
  String get cnDeleteShelfSubtitle =>
      'Its notebooks stay — they just leave the shelf';

  @override
  String get cnShelfDeleted => 'Shelf deleted';

  @override
  String cnReorderFailed(String error) {
    return 'Couldn\'t save the new order: $error';
  }

  @override
  String cnGenericError(String error) {
    return 'That didn\'t work: $error';
  }

  @override
  String get cnAllShelf => 'All';

  @override
  String get cnDragToReorder => 'Drag to reorder your notebooks';

  @override
  String get cnManageHint =>
      'Tap ⋮ on a notebook to rename, download or delete it';

  @override
  String get cnArrange => 'Arrange';

  @override
  String get cnManage => 'Manage';

  @override
  String cnManageNamed(String title) {
    return 'Manage $title';
  }

  @override
  String get cnNotebookWord => 'notebook';

  @override
  String cnPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get cnEmptyTitle => 'No notebooks yet';

  @override
  String get cnEmptyBody =>
      'Your ClassNotes notebooks appear here — covers, paper and ink all follow your theme.';

  @override
  String get cnLoading => 'Loading your notebooks…';

  @override
  String get cnSignedOutTitle => 'Sign in to see your notebooks';

  @override
  String get cnSignedOutBody =>
      'Your ClassNotes library is tied to your ClassMate account.';

  @override
  String get cnErrorTitle => 'Couldn\'t load your notebooks';

  @override
  String get cnErrorBody => 'Check your connection and try again.';

  @override
  String teacherFormsCount(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString forms',
      one: '1 form',
    );
    return '$_temp0';
  }
}

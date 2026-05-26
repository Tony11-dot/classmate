// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get menu => 'Menu';

  @override
  String get sectionCore => 'Core';

  @override
  String get sectionSchoolTools => 'School Tools';

  @override
  String get sectionAccount => 'Account';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navClassrooms => 'Classrooms';

  @override
  String get navPractice => 'Practice';

  @override
  String get navInsights => 'Insights';

  @override
  String get navNova => 'NOVA';

  @override
  String get navMessages => 'Messages';

  @override
  String get navAttendance => 'Attendance';

  @override
  String get navGrades => 'Grades';

  @override
  String get navAssignments => 'Assignments';

  @override
  String get navMeetings => 'Meetings';

  @override
  String get navAnnouncements => 'Announcements';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navSolutions => 'Solutions';

  @override
  String get navExams => 'Exams';

  @override
  String get navForms => 'Forms';

  @override
  String get navHome => 'Home';

  @override
  String get navTeacherWorkspace => 'Teacher Workspace';

  @override
  String get navTeacherAssessments => 'Assessments & Grades';

  @override
  String get navSavedQuestions => 'Saved Questions';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get navLogout => 'Log out';

  @override
  String get roleTeacher => 'Teacher';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleSecretary => 'Secretary';

  @override
  String get roleParent => 'Parent';

  @override
  String get titleSchedule => 'Schedule';

  @override
  String get titleClasses => 'Classes';

  @override
  String get titlePractice => 'Practice';

  @override
  String get titleInsights => 'Insights';

  @override
  String get titleNova => 'NOVA';

  @override
  String get titleMessages => 'Messages';

  @override
  String get titleSolutions => 'Solutions';

  @override
  String get titleExams => 'Exams';

  @override
  String get solutionsUploadAction => 'Upload';

  @override
  String get solutionsNoSubjectsAvailable => 'No subjects available.';

  @override
  String solutionsNoSubjectsMatch(Object query) {
    return 'No subjects match \"$query\".';
  }

  @override
  String solutionsBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books',
      one: '1 book',
    );
    return '$_temp0';
  }

  @override
  String get solutionsBooksTitle => 'Books';

  @override
  String get solutionsAddBookTitle => 'Add a book';

  @override
  String get solutionsBookTitleHint => 'Book title...';

  @override
  String get solutionsAddBookAction => 'Add a book';

  @override
  String get solutionsSearchBooks => 'Search books';

  @override
  String get solutionsChooseSubjectFirst => 'Choose a subject first.';

  @override
  String solutionsNoBooksYetBody(Object action) {
    return 'No books yet.\nTap \"$action\" to add the first one.';
  }

  @override
  String solutionsNoBooksMatch(Object query) {
    return 'No books match \"$query\".';
  }

  @override
  String get solutionsBookLabel => 'Book';

  @override
  String get solutionsPagesFilterHint =>
      'Enter a page and question number to filter, or leave blank to see all.';

  @override
  String get solutionsPageNumberLabel => 'Page number';

  @override
  String get solutionsPageNumberHint => 'e.g. 42';

  @override
  String get solutionsQuestionNumberLabel => 'Question number';

  @override
  String get solutionsQuestionNumberHint => 'e.g. 3a or 7';

  @override
  String get solutionsViewSolutionsAction => 'View solutions';

  @override
  String solutionsPageQuestionSummary(Object page, Object question) {
    return 'Page $page • Question $question';
  }

  @override
  String get solutionsExactQuestionTitle => 'Solutions for this exact question';

  @override
  String get solutionsExactQuestionEmptySubtitle =>
      'Nothing has been uploaded for this exact question yet. Be the first to help your classmates.';

  @override
  String solutionsUploadsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uploads found',
      one: '1 upload found',
    );
    return '$_temp0';
  }

  @override
  String get solutionsExactQuestionEmptyBody =>
      'No exact match yet. You can upload one now, or check what classmates solved on this same page.';

  @override
  String get solutionsLoadMoreAction => 'Load more';

  @override
  String get solutionsSamePageTitle => 'Other questions solved on this page';

  @override
  String get solutionsSamePageEmptySubtitle =>
      'No neighboring questions were uploaded from this page yet.';

  @override
  String get solutionsSamePageFallbackSubtitle =>
      'Useful fallback when your exact question has no upload yet.';

  @override
  String get solutionsSamePageEmptyBody =>
      'No nearby uploads on this page yet. A fresh upload here would really help.';

  @override
  String get solutionsVerifiedByNova => 'Verified by NOVA';

  @override
  String get solutionsUploadFileLimitReached => '10-file limit reached.';

  @override
  String solutionsUploadFilesAddedLimit(int count) {
    return 'Added $count — 10-file limit.';
  }

  @override
  String get solutionsUploadCompleteFields =>
      'Complete subject, book, page, and question.';

  @override
  String get solutionsUploadAddOneFile => 'Add at least one image or PDF.';

  @override
  String solutionsUploadFileFailed(Object error) {
    return 'File upload failed: $error';
  }

  @override
  String solutionsUploadCreateFailed(Object error) {
    return 'Failed to create solution: $error';
  }

  @override
  String get solutionsUploadSuccess => 'Solution uploaded!';

  @override
  String get solutionsUploadAddNewBookOption => '+ Add a new book...';

  @override
  String get solutionsUploadAddBookShortAction => 'Add';

  @override
  String get solutionsUploadTitle => 'Upload a solution';

  @override
  String get solutionsUploadSubtitle =>
      'Real images or PDFs only. NOVA verification and moderation are applied after upload.';

  @override
  String get solutionsUploadNoBooksAbove => 'No books — add one above';

  @override
  String get solutionsUploadCaptionOptional => 'Caption (optional)';

  @override
  String get solutionsUploadImagesAction => 'Images';

  @override
  String get solutionsUploadPdfAction => 'PDF';

  @override
  String solutionsUploadFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'files selected',
      one: 'file selected',
    );
    return '$count / 10 $_temp0';
  }

  @override
  String get solutionsUploadSomeFilesFailed => 'Some files failed to upload.';

  @override
  String get solutionsUploadRetryFailedFiles => 'Retry failed files';

  @override
  String get solutionsUploadSubmittingAction => 'Uploading...';

  @override
  String get solutionsUploadSubmitAction => 'Upload solution';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Appearance, language & account';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsAccentColour => 'Accent colour';

  @override
  String get settingsAccentSubtitle => 'Tint used across the whole app';

  @override
  String get settingsReduceMotion => 'Reduce motion';

  @override
  String get settingsReduceMotionSubtitle =>
      'Fewer animations throughout the app';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsLogoutSubtitle => 'Sign out of this device';

  @override
  String get settingsThemeSystem => 'System default';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguageSearchHint => 'Search language...';

  @override
  String get teacherWorkspaceSubtitle =>
      'Run attendance, rosters, and grading from the mobile app.';

  @override
  String get teacherMetricSessionsToday => 'Sessions today';

  @override
  String get teacherMetricTeachingGroups => 'Teaching groups';

  @override
  String get teacherMetricAssessments => 'Assessments';

  @override
  String get teacherQuickActions => 'Quick actions';

  @override
  String get teacherNoDateAvailable => 'No date available';

  @override
  String get teacherNoTeachingSlotsToday =>
      'No teaching slots scheduled today.';

  @override
  String get teacherUpcomingAssessments => 'Upcoming assessments';

  @override
  String get teacherUpcomingAssessmentsSubtitle =>
      'Live from the teacher grading system';

  @override
  String get teacherNoAssessmentsYet => 'No assessments created yet.';

  @override
  String get teacherUnassignedSlot => 'Unassigned slot';

  @override
  String get teacherNoCohort => 'No cohort';

  @override
  String get teacherCourseFallback => 'Course';

  @override
  String teacherPeriod(Object number) {
    return 'Period $number';
  }

  @override
  String get teacherLoadErrorTitle => 'Could not load teacher workspace';

  @override
  String get teacherClassroomsLoadError =>
      'We could not load classrooms right now. Pull to refresh or try again.';

  @override
  String get teacherClassroomsLoadTimeout =>
      'Classrooms are taking too long to load. Pull to refresh or try again in a moment.';

  @override
  String get teacherClassroomsLoadNetwork =>
      'Classrooms could not connect right now. Check your connection and try again.';

  @override
  String get teacherClassroomsSubtitle =>
      'Open the roster and generate a live join code for student entry.';

  @override
  String get teacherClassroomsNoCohorts =>
      'No classroom cohorts are linked to this teacher yet.';

  @override
  String teacherClassroomsCohort(Object cohortId) {
    return 'Cohort $cohortId';
  }

  @override
  String get teacherClassroomsGeneratingJoinCode => 'Generating…';

  @override
  String get teacherClassroomsCreateJoinCode => 'Create join code';

  @override
  String get teacherClassroomsLiveJoinCode => 'Live join code';

  @override
  String teacherClassroomsExpiresAt(Object value) {
    return 'Expires $value';
  }

  @override
  String get teacherClassroomsRoster => 'Roster';

  @override
  String get teacherClassroomsNoStudents =>
      'No students are enrolled in this classroom yet.';

  @override
  String get teacherAttendanceLoadError =>
      'We could not load attendance right now. Pull to refresh or try again.';

  @override
  String get teacherAttendanceLoadTimeout =>
      'Attendance is taking too long to load. Pull to refresh or try again in a moment.';

  @override
  String get teacherAttendanceLoadNetwork =>
      'Attendance could not connect right now. Check your connection and try again.';

  @override
  String get teacherAttendanceSubtitle =>
      'Pick a live session, mark the room, and save only changed rows.';

  @override
  String get teacherAttendanceTodaySessions => 'Today sessions';

  @override
  String teacherAttendanceSessionSummary(
    Object cohort,
    Object grade,
    Object date,
    Object period,
  ) {
    return '$cohort • Grade $grade • $date • Period $period';
  }

  @override
  String get teacherAttendanceChanged => 'Changed';

  @override
  String get teacherAttendanceNoteLabel => 'Note';

  @override
  String get teacherAttendanceClassNotesLabel => 'Class notes';

  @override
  String get teacherAttendanceClassNotesHint =>
      'What was covered in this session…';

  @override
  String get teacherAttendanceSaving => 'Saving…';

  @override
  String get teacherAttendanceSaveAll => 'Save attendance';

  @override
  String teacherAttendanceSaveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes',
      one: '1 change',
    );
    return 'Save $_temp0';
  }

  @override
  String get teacherAttendanceSaved => 'Attendance saved';

  @override
  String get retry => 'Retry';

  @override
  String get scheduleRefreshTooFast =>
      'Schedule is refreshing too fast right now. Wait a moment and try again.';

  @override
  String get scheduleSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get scheduleNotOnboarded =>
      'Your student profile is not fully set up yet. Ask your school admin to assign you to a class.';

  @override
  String get scheduleLoadError => 'Could not load schedule yet.';

  @override
  String get scheduleSelectedDay => 'Selected day';

  @override
  String scheduleClassCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count classes',
      one: '1 class',
      zero: '0 classes',
    );
    return '$_temp0';
  }

  @override
  String get scheduleNextUp => 'Next up';

  @override
  String get scheduleNoMoreClasses => 'No more classes';

  @override
  String get scheduleNoClassesTitle => 'No classes on this day';

  @override
  String scheduleNoClassesSubtitle(Object day) {
    return '$day looks clear.';
  }

  @override
  String get scheduleClassFallback => 'Class';

  @override
  String get scheduleNoSubjectLocation => 'No subject or location yet';

  @override
  String get scheduleNotes => 'Notes';

  @override
  String get scheduleGoToClassroom => 'Go to Classroom';

  @override
  String get loginTitle => 'Mobile login for students and teachers';

  @override
  String get loginSubtitle =>
      'Teacher accounts open the teacher workspace. Student accounts stay on the student experience.';

  @override
  String get loginSignIn => 'Sign in';

  @override
  String get loginSigningIn => 'Signing in...';

  @override
  String get loginEmailLabel => 'Email or username';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get profileNotAvailable => 'Not available';

  @override
  String get profileSchoolInfo => 'School info';

  @override
  String get profileFullName => 'Full name';

  @override
  String get profileRole => 'Role';

  @override
  String get profileSchoolId => 'School ID';

  @override
  String get profileCohortId => 'Cohort ID';

  @override
  String get profileAccountInfo => 'Account info';

  @override
  String get profileUsername => 'Username';

  @override
  String get profileUsernameHint => 'your_username';

  @override
  String get profileContactEmail => 'Contact email';

  @override
  String get profileEmailAddress => 'Email address';

  @override
  String get profileEmailHint => 'you@example.com';

  @override
  String get profileBirthday => 'Birthday';

  @override
  String get profileSecurity => 'Security';

  @override
  String get profileSelectBirthday => 'Select your birthday';

  @override
  String get profilePasswordUpdated => 'Password updated';

  @override
  String get profileSave => 'Save';

  @override
  String get profileEmptyValue => '—';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profileCurrentPassword => 'Current password';

  @override
  String get profileNewPassword => 'New password';

  @override
  String get profileConfirmNewPassword => 'Confirm new password';

  @override
  String get profileUpdatePassword => 'Update password';

  @override
  String get profilePasswordAllFieldsRequired => 'All fields are required';

  @override
  String get profilePasswordMinLength =>
      'New password must be at least 8 characters';

  @override
  String get profilePasswordMismatch => 'Passwords do not match';

  @override
  String get profilePasswordNotAuthenticated => 'Not authenticated';

  @override
  String get profilePasswordIncorrect => 'Current password is incorrect';

  @override
  String get profilePasswordGenericError =>
      'Something went wrong. Please try again.';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get editProfileSchool => 'School';

  @override
  String get editProfileSchoolPublic => 'School public';

  @override
  String get editProfileGradePublic => 'Grade public';

  @override
  String get editProfileMajors => 'Majors';

  @override
  String get editProfileMajorsPublic => 'Majors public';

  @override
  String get editProfileBio => 'Bio';

  @override
  String get editProfileBioPublic => 'Bio public';

  @override
  String get editProfileStatus => 'Status';

  @override
  String get editProfileStatusPublic => 'Status public';

  @override
  String get classroomsYourClassrooms => 'Your classrooms';

  @override
  String get classroomsReorder => 'Reorder classrooms';

  @override
  String classroomsCount(Object count) {
    return '$count classrooms';
  }

  @override
  String get classroomsSearchHint => 'Search classrooms';

  @override
  String get classroomsNoSearchMatches => 'No classrooms match your search';

  @override
  String get classroomsClassroomLabel => 'Classroom';

  @override
  String get classroomsLoadingLatestMessage => 'Loading latest message...';

  @override
  String get classroomsTapToOpen => 'Tap to open classroom';

  @override
  String get classroomsNoMessagesYet => 'No messages yet';

  @override
  String get classroomsMessageFallback => 'Message';

  @override
  String get examsLoadError => 'Could not load exams or forms';

  @override
  String get examsAllFilter => 'All';

  @override
  String get examsFormsSubtitle =>
      'Review classroom forms, response windows, and follow-ups published by your school.';

  @override
  String get examsOnlySubtitle =>
      'Track upcoming assessments, countdowns, and past exam records from your classes.';

  @override
  String get examsUpcomingStat => 'Upcoming exams';

  @override
  String get examsOpenFormsStat => 'Open forms';

  @override
  String get examsCountdownPast => 'Past';

  @override
  String get examsCountdownTomorrow => 'Tomorrow';

  @override
  String examsCountdownInDays(Object days) {
    return 'In $days days';
  }

  @override
  String get examsNoExamsPublished => 'No exams have been published yet.';

  @override
  String get examsNoFormsPublished => 'No forms have been published yet.';

  @override
  String examsNoExamsForFilter(Object subject) {
    return 'No exams are available for $subject right now.';
  }

  @override
  String examsNoFormsForFilter(Object subject) {
    return 'No forms are available for $subject right now.';
  }

  @override
  String examsMaterialsCount(Object count) {
    return '$count materials';
  }

  @override
  String get examsOpenState => 'Open';

  @override
  String get examsClosedState => 'Closed';

  @override
  String examsQuestionsCount(Object count) {
    return '$count questions';
  }

  @override
  String examsResponsesCount(Object count) {
    return '$count responses';
  }

  @override
  String get insightsTrendBaseline => 'Baseline';

  @override
  String get insightsTrendImproving => 'Improving';

  @override
  String get insightsTrendDropping => 'Dropping';

  @override
  String get insightsTrendStable => 'Stable';

  @override
  String get insightsHeadlineIntervention => 'Intervention window is open';

  @override
  String get insightsHeadlineSignals => 'Several signals need tightening';

  @override
  String get insightsHeadlineMomentum => 'Momentum can compound this week';

  @override
  String get insightsBodyAttendance =>
      'Protect attendance first. Better presence now will raise every other signal faster.';

  @override
  String insightsBodyWeakTrend(Object subject) {
    return '$subject plus a falling practice trend is the biggest risk combo right now. Fix that before expanding.';
  }

  @override
  String insightsBodyLeverage(Object subject) {
    return '$subject is your leverage point. Use it to build confidence while you patch weaker areas.';
  }

  @override
  String get insightsBodyConsistency =>
      'Keep stacking short focused sessions. The next few days matter more than a perfect long-term plan.';

  @override
  String get insightsInterventionScoreTitle => 'Intervention score';

  @override
  String insightsInterventionScoreBody(Object count) {
    return '$count active signals are shaping your next move.';
  }

  @override
  String get insightsRecoveryPathTitle => 'Fastest recovery path';

  @override
  String get insightsRecoveryPathDefault => 'Attendance + consistency first.';

  @override
  String insightsRecoveryPathTopic(Object topic, Object subject) {
    return 'Revisit $topic in $subject before pushing harder.';
  }

  @override
  String get insightsProjectedDirectionTitle => 'Projected direction';

  @override
  String insightsProjectedDirectionBody(Object trend) {
    return '$trend based on recent 7d vs 30d practice behavior.';
  }

  @override
  String get insightsLoadingTitle => 'Insights loading';

  @override
  String get insightsLoadingSubtitle => 'Building your predictive dashboard.';

  @override
  String get insightsNotReadyTitle => 'Insights are not ready yet';

  @override
  String get insightsEmptyTitle => 'No insights yet';

  @override
  String get insightsEmptySubtitle =>
      'Keep using practice and your school tools so ClassMate can build a clearer academic picture.';

  @override
  String get insightsGradeAverage => 'Grade avg';

  @override
  String get insightsAccuracy => 'Accuracy';

  @override
  String get insightsOpenNova => 'Open NOVA';

  @override
  String get insightsOpenNovaPrompt =>
      'Help me fix my weakest area based on my latest ClassMate insights.';

  @override
  String get insightsPredictiveRecoveryPlanTitle => 'Predictive recovery plan';

  @override
  String get insightsPracticeNow => 'Practice now';

  @override
  String get insightsPredictiveModulesTitle => 'Predictive modules';

  @override
  String get insightsPredictiveModulesSubtitle =>
      'The strongest forward-looking signals from your current student data.';

  @override
  String get insightsAnnouncementsPressureTitle => 'Announcements pressure';

  @override
  String get insightsAnnouncementsPressureSubtitle =>
      'The announcement engine is now feeding the dashboard directly.';

  @override
  String get insightsAiCoachTitle => 'AI coach summary';

  @override
  String get insightsAiCoachLoadingSubtitle => 'Loading AI guidance.';

  @override
  String get insightsAiCoachUnavailableSubtitle =>
      'AI guidance is unavailable for this account right now.';

  @override
  String get insightsAskNova => 'Ask NOVA';

  @override
  String get insightsAskNovaPrompt =>
      'Build me a recovery plan from my latest insights.';

  @override
  String get insightsAiStudyCoachTitle => 'AI study coach';

  @override
  String get insightsSchoolToolsTitle => 'School tools';

  @override
  String get insightsSchoolToolsSubtitle =>
      'Jump directly into the student routes that now matter most.';

  @override
  String get tutorUntitledChat => 'Untitled chat';

  @override
  String get tutorNewChat => 'New chat';

  @override
  String tutorFailedToOpenSeededChat(Object error) {
    return 'Failed to open chat: $error';
  }

  @override
  String tutorFailedToCreateChat(Object error) {
    return 'Failed to create chat: $error';
  }

  @override
  String get tutorRenameChatTitle => 'Rename chat';

  @override
  String get tutorChatNameHint => 'Chat name';

  @override
  String get tutorCancel => 'Cancel';

  @override
  String get tutorHide => 'Hide';

  @override
  String get tutorHideChatTitle => 'Hide chat';

  @override
  String get tutorHideChatSubtitle => 'Hides this chat on this device.';

  @override
  String get tutorHideChatConfirmTitle => 'Hide chat?';

  @override
  String get tutorHideChatConfirmBody =>
      'This hides the chat from the list on this device. The session stays on the backend.';

  @override
  String get tutorTapToOpenHistory => 'Tap to open history';

  @override
  String get tutorAiTutorSubtitle => 'Your AI tutor';

  @override
  String get tutorHeroBody =>
      'Real chat history, cleaner threads, faster access.';

  @override
  String get tutorStartFreshConversation => 'Start a fresh conversation';

  @override
  String get tutorSearchHistoryHint => 'Search chat history';

  @override
  String get chatComposerDefaultHint => 'Message';

  @override
  String get chatComposerReplyingToMessage => 'Replying to message';

  @override
  String get chatComposerReplyFallback => 'Reply';

  @override
  String get chatComposerMicHint =>
      'Tap for a quick voice note or hold to record';

  @override
  String get chatComposerRecordingTitle => 'Recording';

  @override
  String get chatComposerReleaseToSend => 'Let go to send';

  @override
  String get chatComposerCancelTitle => 'Cancel';

  @override
  String get chatComposerLockTitle => 'Lock';

  @override
  String get chatComposerSlideLeftToCancel => 'Slide left to cancel';

  @override
  String get chatComposerSlideUpToLock => 'Slide up to lock';

  @override
  String get chatComposerReleaseToCancel => 'Release to cancel';

  @override
  String get chatComposerKeepSlidingToCancel => 'Keep sliding to cancel';

  @override
  String get chatComposerReleaseToLock => 'Release to lock';

  @override
  String get chatComposerRelease => 'Release';

  @override
  String get chatComposerLock => 'Lock';

  @override
  String get chatComposerRecordingPaused => 'Recording paused';

  @override
  String get chatComposerRecordingLocked => 'Recording locked';

  @override
  String get chatComposerResumeHint =>
      'Resume when you are ready to keep recording';

  @override
  String get chatComposerLockedHint => 'Tap send when you are ready to share';

  @override
  String get chatContextDismiss => 'Dismiss';

  @override
  String get chatContextCopyText => 'Copy text';

  @override
  String get chatContextDelete => 'Delete';

  @override
  String get chatMessageInfoShortTitle => 'Info';

  @override
  String get chatMessageInfoStatus => 'Status';

  @override
  String get chatMessageInfoStatusTime => 'Status time';

  @override
  String get chatMessageInfoSentAt => 'Sent at';

  @override
  String get chatMessageInfoDeliveredAt => 'Delivered at';

  @override
  String get chatMessageInfoSeenAt => 'Seen at';

  @override
  String get chatMessageInfoMessageType => 'Message type';

  @override
  String get chatMessageInfoTextType => 'Text';

  @override
  String get chatMessageInfoEdited => 'Edited';

  @override
  String get chatMessageInfoForwarded => 'Forwarded';

  @override
  String get chatMessageInfoVoiceDuration => 'Voice duration';

  @override
  String get chatMessageInfoSeenBy => 'Seen by';

  @override
  String get chatMessageInfoDeliveredTo => 'Delivered to';

  @override
  String get chatMessageInfoEmptyBody => '(empty)';

  @override
  String get chatMessageInfoReadLess => 'Read less';

  @override
  String get chatMessageInfoReadMore => 'Read more';

  @override
  String get chatMessageInfoSeen => 'Seen';

  @override
  String get chatMessageInfoDelivered => 'Delivered';

  @override
  String get chatMessageInfoNotDelivered => 'Not delivered';

  @override
  String get chatMessageInfoSent => 'Sent';

  @override
  String get chatMessageInfoPending => 'Pending';

  @override
  String get chatMessageInfoNotSeen => 'Not seen';

  @override
  String get chatMessageInfoType => 'Type';

  @override
  String get chatMessageInfoDuration => 'Duration';

  @override
  String get chatMessageInfoYes => 'Yes';

  @override
  String get chatMessageInfoNo => 'No';

  @override
  String get chatMessageInfoDeleteState => 'Delete state';

  @override
  String get chatReactionDetailsTitle => 'Reactions';

  @override
  String get chatReactionAddAction => 'Add reaction';

  @override
  String get chatReactionEmptyState => 'No reactions yet';

  @override
  String get chatReactionSingle => 'Reaction';

  @override
  String get chatReactionTapToRemove => 'Tap to remove';

  @override
  String chatReactionYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' · $count',
      one: '',
    );
    return 'You$_temp0';
  }

  @override
  String chatReactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reactions',
      one: 'Reaction',
    );
    return '$_temp0';
  }

  @override
  String get chatEmojiPickerTitle => 'Choose emoji';

  @override
  String get chatEmojiPickerSearchHint => 'Search emoji';

  @override
  String get chatEmojiPickerEmptyState => 'No emoji found';

  @override
  String get chatCameraTitle => 'Camera';

  @override
  String get chatCameraUseAction => 'Use';

  @override
  String get chatCameraGalleryAction => 'Gallery';

  @override
  String chatCameraSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
      zero: '0 selected',
    );
    return '$_temp0';
  }

  @override
  String get chatMediaPreviewEmptyState => 'Nothing to preview';

  @override
  String get chatMediaPreviewDrawCropAction => 'Draw & Crop';

  @override
  String get chatMediaPreviewRotateLeftAction => 'Rotate left';

  @override
  String get chatMediaPreviewRotateRightAction => 'Rotate right';

  @override
  String get chatMediaPreviewMirrorAction => 'Mirror';

  @override
  String get chatMediaPreviewResetAction => 'Reset';

  @override
  String get chatMediaPreviewRemoveAction => 'Remove';

  @override
  String get chatMediaPreviewCaptionHint => 'Add a caption...';

  @override
  String tutorPlanSelectedPlaceholder(Object plan) {
    return '$plan selected. Payments stay in placeholder mode for now.';
  }

  @override
  String get tutorFailedToLoadChats => 'Failed to load chats';

  @override
  String get tutorNoChatsYet => 'No chats yet';

  @override
  String get tutorNoChatsMatchSearch => 'No chats match your search';

  @override
  String get tutorCreateFirstChat => 'Create first chat';

  @override
  String get tutorPlansTitle => 'NOVA plans';

  @override
  String tutorPlansSubtitle(Object model) {
    return 'Based on $model cost assumptions and hard monthly caps so usage stays profitable.';
  }

  @override
  String get tutorPlanPriceFree => 'Free';

  @override
  String tutorPlanPriceMonthly(Object price) {
    return '\$$price/mo';
  }

  @override
  String get tutorPromptsLeft => 'Prompts left';

  @override
  String get tutorUploadsLeft => 'Uploads left';

  @override
  String get tutorVoiceLeft => 'Voice left';

  @override
  String tutorUsageValue(Object remaining, Object total) {
    return '$remaining/$total';
  }

  @override
  String tutorVoiceUsageValue(Object remaining, Object total) {
    return '$remaining/$total min';
  }

  @override
  String get tutorPaymentMethodsTitle => 'Payment methods';

  @override
  String tutorPaymentMethodsSubtitle(Object plan) {
    return 'Checkout is placeholder-only until the ClassMate bank account and processor are live. The selected plan is $plan.';
  }

  @override
  String get tutorCardCheckoutTitle => 'Card checkout';

  @override
  String get tutorCardCheckoutSubtitle =>
      'Visa, Mastercard, AmEx placeholder gateway.';

  @override
  String get tutorApplePayTitle => 'Apple Pay';

  @override
  String get tutorApplePaySubtitle =>
      'Placeholder wallet flow for iPhone and web.';

  @override
  String get tutorBankTransferTitle => 'Bank transfer';

  @override
  String get tutorBankTransferSubtitle =>
      'ClassMate bank account pending. Details will be filled once opened.';

  @override
  String get tutorPlanStarterName => 'Starter';

  @override
  String get tutorPlanStarterTagline =>
      'Enough for trial and light weekly revision.';

  @override
  String get tutorPlanPlusName => 'Plus';

  @override
  String get tutorPlanPlusTagline =>
      'Best for one serious student using NOVA most days.';

  @override
  String get tutorPlanProName => 'Pro';

  @override
  String get tutorPlanProTagline =>
      'Heavy daily use, full exam season, and long study sessions.';

  @override
  String get tutorPlanSchoolSeatName => 'School Seat';

  @override
  String get tutorPlanSchoolSeatTagline =>
      'For rollout per student or staff seat inside a real school.';

  @override
  String tutorPlanBulletPromptsMonthly(Object count) {
    return '$count NOVA prompts each month';
  }

  @override
  String tutorPlanBulletPromptsPerSeatMonthly(Object count) {
    return '$count NOVA prompts per seat monthly';
  }

  @override
  String tutorPlanBulletUploads(Object count) {
    return '$count image or file uploads';
  }

  @override
  String tutorPlanBulletVoiceMinutes(Object count) {
    return '$count voice transcription minutes';
  }

  @override
  String tutorEstimatedCostCeilingFree(Object cost) {
    return 'Estimated cost ceiling: \$$cost/mo';
  }

  @override
  String tutorEstimatedCostCeilingPaid(Object cost, Object margin) {
    return 'Estimated cost ceiling: \$$cost/mo • margin $margin%';
  }

  @override
  String tutorTimeMinutesShort(Object count) {
    return '${count}m';
  }

  @override
  String tutorTimeHoursShort(Object count) {
    return '${count}h';
  }

  @override
  String get tutorVoiceMessageFallback => 'Voice message';

  @override
  String get tutorFileFallback => 'File';

  @override
  String get tutorCopy => 'Copy';

  @override
  String get tutorEditMessage => 'Edit message';

  @override
  String get tutorCopied => 'Copied';

  @override
  String get tutorLoadedIntoComposer => 'Loaded into composer';

  @override
  String get tutorTakePhoto => 'Take photo';

  @override
  String get tutorRecordVideo => 'Record video';

  @override
  String get tutorChooseFromGallery => 'Choose from gallery';

  @override
  String get tutorPreviewTitle => 'Preview';

  @override
  String get tutorThinking => 'Thinking...';

  @override
  String get tutorDone => 'Done.';

  @override
  String get tutorFailedToStreamReply => 'Failed to stream reply';

  @override
  String get tutorUnsupportedFilesMessage =>
      'NOVA supports images, documents, and text. Video and audio files are not supported here.';

  @override
  String get tutorNoAudioCaptured => 'No audio captured.';

  @override
  String get tutorVoiceLimitReachedTitle => 'Voice limit reached';

  @override
  String get tutorVoiceLimitReachedMessage =>
      'Your current NOVA plan does not have enough voice minutes left for this transcription cycle.';

  @override
  String get tutorTranscriptionFailed =>
      'Transcription failed. Please try again.';

  @override
  String get tutorMicrophonePermissionRequired =>
      'Microphone permission is required.';

  @override
  String get tutorPlanLimitReachedTitle => 'NOVA plan limit reached';

  @override
  String get tutorPlanLimitReachedMessage =>
      'This month\'s prompt or upload allowance is exhausted for your current NOVA plan. Pick a higher plan in the NOVA home screen to continue.';

  @override
  String get tutorSendFailed => 'Send failed.';

  @override
  String tutorCurrentPlanUsageSummary(
    Object plan,
    Object prompts,
    Object uploads,
    Object voice,
  ) {
    return 'Current plan: $plan • $prompts prompts left • $uploads uploads left • $voice voice minutes left';
  }

  @override
  String get tutorReviewPlansInHome => 'Review plans in NOVA home';

  @override
  String get tutorCouldNotOpenAttachment => 'Could not open attachment.';

  @override
  String get tutorAttachmentUnavailable => 'Attachment unavailable.';

  @override
  String get tutorImageUnavailable => 'Image unavailable';

  @override
  String get tutorYou => 'You';

  @override
  String get tutorRegenerate => 'Regenerate';

  @override
  String get tutorEmptyStateTitle => 'Start with a real question';

  @override
  String get tutorEmptyStateBody =>
      'Ask NOVA to explain a concept, turn notes into a table, compare ideas, or help you revise from an uploaded file.';

  @override
  String get tutorPromptSuggestionSummarizeNotes => 'Summarize my lesson notes';

  @override
  String get tutorPromptSuggestionRevisionTable => 'Make a revision table';

  @override
  String get tutorPromptSuggestionQuizMe => 'Quiz me on this topic';

  @override
  String get tutorMessageNovaHint => 'Message NOVA';

  @override
  String get tutorHeaderSubtitleReady =>
      'Structured answers, tables, and study help';

  @override
  String get tutorYourNovaPlanTitle => 'Your NOVA plan';

  @override
  String get tutorYourNovaPlanMessage =>
      'Review prompt, upload, and voice limits here, then jump back to NOVA home if you want to switch plans.';

  @override
  String get tutorExplainTitle => 'NOVA Explain';

  @override
  String get classroomsThreadTypeClassroom => 'Classroom';

  @override
  String get classroomsThreadTypeGroup => 'Group';

  @override
  String get classroomsThreadTypeDirectMessage => 'Direct message';

  @override
  String get classroomsThreadTypeDirectMessageShort => 'DM';

  @override
  String get messagesBlockedPeopleTitle => 'Blocked people';

  @override
  String get messagesStartChatAction => 'Start chat';

  @override
  String messagesLoadFailed(Object error) {
    return 'Failed to load messages: $error';
  }

  @override
  String get messagesSearchHint => 'Search messages';

  @override
  String get messagesNoResults => 'No messages found';

  @override
  String get messagesRequestsSection => 'Requests';

  @override
  String get messagesPendingApprovals => 'Pending approvals';

  @override
  String get messagesChatsSection => 'Chats';

  @override
  String get messagesAllChatsSection => 'All chats';

  @override
  String messagesConversationCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conversations',
      one: '1 conversation',
    );
    return '$_temp0';
  }

  @override
  String get messagesRequestReviewStatus => 'Review';

  @override
  String messagesPeopleLoadFailed(Object error) {
    return 'Failed to load people: $error';
  }

  @override
  String get messagesSearchPeopleHint => 'Search people';

  @override
  String get messagesNewGroupTitle => 'New group';

  @override
  String get messagesNewGroupSubtitle => 'Create a group chat';

  @override
  String get messagesGroupNameHint => 'Group name';

  @override
  String get messagesCreateGroupAction => 'Create group';

  @override
  String get messagesBlockedPersonFallback => 'this person';

  @override
  String get messagesUnblockPersonTitle => 'Unblock person?';

  @override
  String messagesUnblockPersonBody(Object name) {
    return 'Allow $name to message you again?';
  }

  @override
  String get messagesUnblockAction => 'Unblock';

  @override
  String messagesUnblockedToast(Object name) {
    return '$name unblocked';
  }

  @override
  String messagesBlockedPeopleLoadFailed(Object error) {
    return 'Failed to load blocked people: $error';
  }

  @override
  String get messagesNoBlockedPeople => 'No blocked people';

  @override
  String get messagesUnknownUser => 'Unknown user';

  @override
  String get messagesRequestTitle => 'Request';

  @override
  String messagesRequestLoadFailed(Object error) {
    return 'Failed to load request: $error';
  }

  @override
  String get messagesRequestBannerIncoming => 'Message request';

  @override
  String get messagesRequestBannerOutgoing => 'Pending approval';

  @override
  String get messagesBlockAction => 'Block';

  @override
  String get messagesApproveAction => 'Approve';

  @override
  String get messagesRequestUnlockHint =>
      'The chat unlocks after the receiver approves your first message.';

  @override
  String get messagesThreadConversationFallback => 'Conversation';

  @override
  String get messagesThreadLeaveGroupTitle => 'Leave group?';

  @override
  String get messagesThreadLeaveGroupBody =>
      'You will stop receiving messages from this group.';

  @override
  String get messagesThreadBlockPersonTitle => 'Block person?';

  @override
  String get messagesThreadBlockPersonBody =>
      'You will no longer be able to exchange messages with this person.';

  @override
  String get messagesThreadPersonFallback => 'Person';

  @override
  String get messagesThreadProfileInfoUnavailable => 'Profile info unavailable';

  @override
  String get messagesThreadParticipants => 'Participants';

  @override
  String get messagesThreadPeople => 'People';

  @override
  String get messagesThreadDeleteForMe => 'Delete for me';

  @override
  String get messagesThreadDeleteForEveryone => 'Delete for everyone';

  @override
  String get messagesThreadDeleteForEveryoneSubtitle =>
      'Removes for all participants';

  @override
  String get messagesThreadSending => 'Sending…';

  @override
  String get messagesThreadWaitingForApproval => 'Waiting for approval';

  @override
  String get classroomsForwardSearchHint => 'Search chats';

  @override
  String get classroomsForwardNewChat => 'New chat';

  @override
  String classroomsForwardLoadError(Object error) {
    return 'Failed to load chats: $error';
  }

  @override
  String get classroomsForwardNoChatsFound => 'No chats found';

  @override
  String get classroomsForwardSectionClassrooms => 'Classrooms';

  @override
  String get classroomsForwardSectionDirectMessages => 'Direct messages';

  @override
  String get classroomsForwardCancel => 'Cancel';

  @override
  String get classroomsForwardAction => 'Forward';

  @override
  String classroomsForwardCount(Object count) {
    return 'Forward ($count)';
  }

  @override
  String get markRead => 'Mark read';

  @override
  String get markUnread => 'Mark unread';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get filters => 'Filters';

  @override
  String get source => 'Source';

  @override
  String get state => 'State';

  @override
  String get allSources => 'All sources';

  @override
  String get allStates => 'All states';

  @override
  String get unread => 'Unread';

  @override
  String get read => 'Read';

  @override
  String get clear => 'Clear';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This week';

  @override
  String get earlier => 'Earlier';

  @override
  String get openDetails => 'Open details';

  @override
  String get total => 'Total';

  @override
  String get local => 'Local';

  @override
  String get server => 'Server';

  @override
  String get notificationsSourceSystem => 'System';

  @override
  String get notificationsHeroSubtitleStudent =>
      'Your notification hub for announcements, server updates, and useful academic activity as it happens.';

  @override
  String get notificationsHeroSubtitleTeacher =>
      'Your teacher notification hub for announcements, server updates, and school activity as it happens.';

  @override
  String get notificationsFiltersSubtitle =>
      'Focus by source or read state to triage fast.';

  @override
  String get notificationsSearchSourcesHint => 'Search sources';

  @override
  String notificationsShowingSummary(Object shown, Object total) {
    return 'Showing $shown of $total notifications.';
  }

  @override
  String get notificationsEmptyForAccount =>
      'No notifications are available for this account right now.';

  @override
  String get notificationsEmptyFiltered =>
      'No notifications match these filters right now. Clear filters to see the full feed.';

  @override
  String get notificationsEmpty => 'No notifications are available right now.';

  @override
  String get notificationsNewBadge => 'New';

  @override
  String get notificationsUnavailable =>
      'This notification is no longer available. Pull to refresh the inbox and try again.';

  @override
  String get notificationsSeverityCritical => 'Critical';

  @override
  String get notificationsSeverityWarning => 'Warning';

  @override
  String get notificationsSeverityInfo => 'Info';

  @override
  String get announcementsLoadError =>
      'We could not load announcements right now. Pull to refresh or try again.';

  @override
  String get announcementsLoadTimeout =>
      'Announcements are taking too long to load. Pull to refresh or try again in a moment.';

  @override
  String get announcementsLoadNetwork =>
      'Announcements could not connect right now. Check your connection and try again.';

  @override
  String get announcementsAudienceTeacher => 'teacher';

  @override
  String get announcementsAudienceAccount => 'account';

  @override
  String get announcementsAudienceTeacherWorkspace => 'teacher workspace';

  @override
  String get announcementsLoadFailedTitle => 'Could not load announcements';

  @override
  String get announcementsLoadFailedHint =>
      'Pull to refresh after the connection is stable.';

  @override
  String announcementsHeroSubtitle(Object audience) {
    return 'Published school, teacher, and system announcements available to this $audience.';
  }

  @override
  String get announcementsLatestSourceLabel => 'Latest source';

  @override
  String get announcementsNone => 'None';

  @override
  String announcementsUnreadCountTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread announcements',
      one: '1 unread announcement',
    );
    return '$_temp0';
  }

  @override
  String get announcementsAllReadTitle => 'Everything is read';

  @override
  String announcementsEmptyForAudience(Object audience) {
    return 'No announcements have been published to this $audience yet.';
  }

  @override
  String announcementsLatestBody(Object title) {
    return 'Latest: $title. Tap it to read the full content.';
  }

  @override
  String get announcementsFiltersSubtitle =>
      'Narrow the inbox by source or by read state so you can focus on what still needs attention.';

  @override
  String get announcementsAllAnnouncements => 'All announcements';

  @override
  String get announcementsSearchStatesHint => 'Unread / Read';

  @override
  String announcementsSummarySourceSegment(Object source) {
    return ' from $source';
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
    return 'Showing $shown of $total announcements$sourceSegment$stateSegment.';
  }

  @override
  String get announcementsNoMatchTitle =>
      'No announcements match these filters';

  @override
  String get announcementsNoPublishedTitle => 'No published announcements yet';

  @override
  String get announcementsNoMatchSubtitle =>
      'Try a different source or switch back to all announcements to bring more items into view.';

  @override
  String get announcementsClearFiltersHint =>
      'Clear filters to see everything again.';

  @override
  String get announcementsPullToRefreshHint =>
      'Pull to refresh after new school activity is published.';

  @override
  String get announcementsInboxTitle => 'Inbox';

  @override
  String get announcementsInboxSubtitle =>
      'Only titles appear here for quick scanning. Tap any item to open the full announcement content.';

  @override
  String get meetingsLoadError =>
      'We could not load meetings right now. Pull to refresh or try again.';

  @override
  String get meetingsLoadTimeout =>
      'Meetings are taking too long to load. Pull to refresh or try again in a moment.';

  @override
  String get meetingsLoadNetwork =>
      'Meetings could not connect right now. Check your connection and try again.';

  @override
  String get meetingsHeroSubtitle =>
      'Every classroom meeting in one clean view, with attached links and a full-screen detail page when you need the context.';

  @override
  String get meetingsJoinReadyMetric => 'Join-ready';

  @override
  String get meetingsNoLinkMetric => 'No link';

  @override
  String get meetingsNoPostedTitle => 'No meetings posted yet';

  @override
  String get meetingsEmptyForAccount =>
      'No classroom meetings are available for this student account right now.';

  @override
  String meetingsLatestBody(Object title, Object updatedAt) {
    return '$title was updated $updatedAt. Open it for the attached link and classroom context.';
  }

  @override
  String get meetingsPullToRefreshHint => 'Pull down to check again.';

  @override
  String get meetingsFiltersSubtitle =>
      'Narrow the list by subject or by whether the meeting already includes a link you can open.';

  @override
  String get meetingsAccessLabel => 'Access';

  @override
  String get meetingsAllMeetings => 'All meetings';

  @override
  String get meetingsAccessReady => 'Ready to join';

  @override
  String get meetingsAccessNoLink => 'No link';

  @override
  String get meetingsAccessNoLinkYet => 'No link yet';

  @override
  String get meetingsAccessSearchHint => 'Ready to join / No link yet';

  @override
  String meetingsSummarySubjectSegment(Object subject) {
    return ' for $subject';
  }

  @override
  String meetingsSummaryAccessSegment(Object state) {
    return ' in $state';
  }

  @override
  String meetingsShowingSummary(
    Object shown,
    Object total,
    Object subjectSegment,
    Object accessSegment,
  ) {
    return 'Showing $shown of $total meetings$subjectSegment$accessSegment.';
  }

  @override
  String get meetingsNoMatchTitle => 'No meetings match these filters';

  @override
  String get meetingsNoMatchSubtitle =>
      'Try all subjects or include meetings without links to bring more results back into the list.';

  @override
  String get meetingsListSubtitle =>
      'Tap any meeting to open the full-screen detail view and jump into its attached link when available.';

  @override
  String meetingsDateTimeValue(Object date, Object time) {
    return '$date • $time';
  }

  @override
  String meetingsSharedByValue(Object name) {
    return 'Shared by $name';
  }

  @override
  String get meetingsPreviewFallback =>
      'Open this meeting to see the attached link and the latest classroom details.';

  @override
  String get meetingsNoValidLinkAttached =>
      'No valid meeting link is attached yet.';

  @override
  String get meetingsCouldNotOpenLink => 'Could not open the meeting link.';

  @override
  String get meetingsNoLinkToCopy => 'No meeting link to copy yet.';

  @override
  String get meetingsLinkCopied => 'Meeting link copied.';

  @override
  String get meetingsUnavailableTitle => 'Meeting unavailable';

  @override
  String get meetingsUnavailableSubtitle =>
      'This meeting could not be found in the current feed. It may have been removed or is not available offline.';

  @override
  String get meetingsUnavailableHint =>
      'Go back and refresh the meetings list.';

  @override
  String get meetingsNoLinkAttachedYet => 'No link attached yet';

  @override
  String get meetingsAttachedLinkTitle => 'Attached meeting link';

  @override
  String get meetingsAttachedLinkMissingBody =>
      'This meeting is visible in your classroom feed, but no valid URL is attached in the current student payload.';

  @override
  String get meetingsDetailsTitle => 'Meeting details';

  @override
  String get meetingsDetailsSubtitle =>
      'Everything student-relevant that is currently available in the classroom meeting payload.';

  @override
  String get meetingsDetailClassroomLabel => 'Classroom';

  @override
  String get meetingsSharedByLabel => 'Shared by';

  @override
  String get meetingsIdLabel => 'Meeting ID';

  @override
  String get meetingsAttachedLinkSubtitle =>
      'Use the attached URL to join or copy the meeting link when your classroom provides one.';

  @override
  String get meetingsOpening => 'Opening';

  @override
  String get meetingsOpenLink => 'Open link';

  @override
  String get meetingsCopyLink => 'Copy link';

  @override
  String get meetingsAccessPanelTitle => 'Meeting access';

  @override
  String get meetingsAccessPanelReadyBody =>
      'Open the attached URL in your browser or meeting app.';

  @override
  String get meetingsJoinAction => 'Join';

  @override
  String get announcementsDetailLoadFailedHint =>
      'Go back and try refreshing the announcements inbox.';

  @override
  String get announcementsUnavailableTitle => 'Announcement unavailable';

  @override
  String announcementsUnavailableSubtitle(Object audience) {
    return 'This announcement is no longer available in the published feed for this $audience.';
  }

  @override
  String get announcementsUnavailableHint =>
      'Go back to the inbox to continue.';

  @override
  String announcementsPublishedReadStateBody(Object audience) {
    return 'This announcement was published to this $audience and your read state is stored locally on this device.';
  }

  @override
  String get announcementsDetailsTitle => 'Announcement details';

  @override
  String get announcementsDetailsSubtitle =>
      'Published metadata for this announcement and its current read state.';

  @override
  String get announcementsSeverityLabel => 'Severity';

  @override
  String get announcementsCreatedLabel => 'Created';

  @override
  String get announcementsIdLabel => 'Announcement ID';

  @override
  String get announcementsFullContentTitle => 'Full content';

  @override
  String get announcementsFullContentSubtitle =>
      'The complete announcement text appears here after you open the item from the inbox.';

  @override
  String get announcementsReadStateTitle => 'Read state';

  @override
  String get announcementsReadStateBodyRead =>
      'This announcement is marked as read on this device.';

  @override
  String get announcementsReadStateBodyUnread =>
      'This announcement is still unread on this device.';

  @override
  String get alertsTitle => 'Alerts';

  @override
  String get alertsSubtitle =>
      'This is the page for things that need attention now, not just general updates.';

  @override
  String get alertsAttendanceTitle => 'Attendance needs attention';

  @override
  String alertsAttendanceBody(Object rate) {
    return 'Your attendance rate is $rate%. A couple of missed lessons can snowball fast.';
  }

  @override
  String get alertsWeakestSubjectTitle => 'Weakest subject signal';

  @override
  String alertsWeakestSubjectBody(Object subject) {
    return '$subject currently needs the most attention based on your latest grades.';
  }

  @override
  String get alertsPracticeWeakAreaTitle => 'Practice weak area';

  @override
  String alertsPracticeWeakAreaBody(Object topic, Object subject) {
    return '$topic in $subject is the clearest weak topic right now.';
  }

  @override
  String get alertsPracticeTrendDroppedTitle => 'Practice trend dropped';

  @override
  String get alertsPracticeTrendDroppedBody =>
      'Your 7d performance is below your 30d baseline. Slow down and revisit fundamentals before pushing harder.';

  @override
  String get alertsEmpty =>
      'You\'re clear right now. When something needs urgent attention, it\'ll show up here.';

  @override
  String get student => 'Student';

  @override
  String get classroomDetailPhoto => 'Photo';

  @override
  String get classroomDetailVoiceNote => 'Voice note';

  @override
  String get classroomDetailVideo => 'Video';

  @override
  String get classroomDetailFile => 'File';

  @override
  String get classroomDetailEmptyValue => '(empty)';

  @override
  String get classroomDetailAttachmentUnavailable => 'Attachment unavailable.';

  @override
  String get classroomDetailAudioUnavailable => 'Audio unavailable.';

  @override
  String get classroomDetailCouldNotOpenAttachment =>
      'Could not open attachment.';

  @override
  String get classroomDetailVoiceMessage => 'Voice message';

  @override
  String get classroomDetailVideoFile => 'Video file';

  @override
  String get classroomDetailAttachedFile => 'Attached file';

  @override
  String get classroomDetailAttachment => 'Attachment';

  @override
  String get classroomDetailPinAction => 'Pin';

  @override
  String get classroomDetailUnpinAction => 'Unpin';

  @override
  String get classroomDetailMessageInfoTitle => 'Message info';

  @override
  String get classroomDetailForwardedSingle => 'Forwarded';

  @override
  String classroomDetailForwardedMultiple(Object count) {
    return 'Forwarded $count messages';
  }

  @override
  String get classroomDetailCannotForwardPending =>
      'Cannot forward into a request chat until it is approved';

  @override
  String get classroomDetailCouldNotForwardSelected =>
      'Could not forward selected messages';

  @override
  String classroomDetailSelectedCount(Object count) {
    return '$count selected';
  }

  @override
  String classroomDetailDeleteCount(Object count) {
    return 'Delete ($count)';
  }

  @override
  String get classroomDetailSelectAllTooltip => 'Select all';

  @override
  String get classroomDetailCancelTooltip => 'Cancel';

  @override
  String get classroomDetailMicrophoneAccessTitle => 'Microphone access needed';

  @override
  String get classroomDetailMicrophoneAccessBody =>
      'Please allow microphone access in Settings -> ClassMate to send voice notes.';

  @override
  String get classroomDetailOpenSettingsAction => 'Open Settings';

  @override
  String classroomDetailForwardTargetNext(Object label) {
    return 'Forward target picker next: $label';
  }

  @override
  String get classroomDetailEditMessageTitle => 'Edit message';

  @override
  String get classroomDetailEditMessageHint => 'Edit your message...';

  @override
  String get classroomDetailLeaveClassroomTitle => 'Leave classroom?';

  @override
  String get classroomDetailLeaveClassroomBody =>
      'You will be removed from this classroom.';

  @override
  String get classroomDetailLeaveAction => 'Leave';

  @override
  String get classroomDetailNoAssignmentsTitle => 'No assignments yet';

  @override
  String get classroomDetailNoAssignmentsSubtitle =>
      'This classroom has no assignments right now.';

  @override
  String get classroomDetailAssignmentFallback => 'Assignment';

  @override
  String get classroomDetailNoMaterialsTitle => 'No materials yet';

  @override
  String get classroomDetailNoMaterialsSubtitle =>
      'This classroom has no materials right now.';

  @override
  String get classroomDetailMaterialFallback => 'Material';

  @override
  String get classroomDetailNoMeetingsTitle => 'No meetings yet';

  @override
  String get classroomDetailNoMeetingsSubtitle =>
      'This classroom has no meetings right now.';

  @override
  String get classroomDetailMeetingFallback => 'Meeting';

  @override
  String get classroomDetailCouldNotLoadPeople => 'Could not load people';

  @override
  String get classroomDetailNoPeopleTitle => 'No people yet';

  @override
  String get classroomDetailNoPeopleSubtitle =>
      'Nobody is visible in this classroom yet.';

  @override
  String get classroomDetailTabChat => 'Chat';

  @override
  String get classroomDetailTabMaterials => 'Materials';

  @override
  String get classroomDetailTabPeople => 'People';

  @override
  String get classroomChatMediaSendPhoto => 'Send photo';

  @override
  String get classroomChatMediaSendPhotoSubtitle =>
      'Share an image in the classroom chat';

  @override
  String get classroomChatMediaSendVoiceMessage => 'Send voice message';

  @override
  String get classroomChatMediaSendVoiceMessageSubtitle =>
      'Record and send a voice note';

  @override
  String get classroomDetailCouldNotLoadTab => 'Could not load tab';

  @override
  String get classroomDetailDeletedByYou => 'You deleted this message';

  @override
  String get classroomDetailDeletedMessage => 'This message was deleted';

  @override
  String get practiceSetupDifficultyEasy => 'Easy';

  @override
  String get practiceSetupDifficultyMedium => 'Medium';

  @override
  String get practiceSetupDifficultyHard => 'Hard';

  @override
  String get practiceSetupDifficultyOlympiad => 'Olympiad';

  @override
  String get practiceSetupDifficultyAdaptive => 'Adaptive';

  @override
  String get practiceSetupModeLabelPractice => 'Practice';

  @override
  String get practiceSetupModeLabelFlashcards => 'Flashcards';

  @override
  String get practiceSetupModeLabelSpeedRound => 'Speed round';

  @override
  String get practiceSetupModeLabelExamPrep => 'Exam prep';

  @override
  String get practiceSetupModeLabelConceptBuilder => 'Concept builder';

  @override
  String get practiceSetupModeLabelAdaptive => 'Adaptive';

  @override
  String get practiceSetupModeLabelBagrut => 'Bagrut';

  @override
  String get practiceSetupModeSubtitlePractice => 'Balanced daily practice';

  @override
  String get practiceSetupModeSubtitleFlashcards => 'Reveal and self-recall';

  @override
  String get practiceSetupModeSubtitleSpeedRound => 'Fast pressure drill';

  @override
  String get practiceSetupModeSubtitleExamPrep => 'Calm exam-style flow';

  @override
  String get practiceSetupModeSubtitleConceptBuilder =>
      'Concept first, solve later';

  @override
  String get practiceSetupModeSubtitleAdaptive => 'Difficulty shifts live';

  @override
  String get practiceSetupModeSubtitleBagrut => 'Strict official style';

  @override
  String get practiceSetupModeHelpPractice =>
      'Balanced mode: solve, check, explain, then keep moving.';

  @override
  String get practiceSetupModeHelpFlashcards =>
      'Flashcards work best when you try to recall before revealing.';

  @override
  String get practiceSetupModeHelpSpeedRound =>
      'Speed Round trains fast recall. Move quickly and trust strong instincts.';

  @override
  String get practiceSetupModeHelpExamPrep =>
      'Exam Prep is calmer and more formal, like a real school session.';

  @override
  String get practiceSetupModeHelpConceptBuilder =>
      'Concept Builder teaches the idea first, then asks you to apply it.';

  @override
  String get practiceSetupModeHelpAdaptive =>
      'Adaptive mode changes the challenge level based on your performance.';

  @override
  String get practiceSetupModeHelpBagrut =>
      'Bagrut mode focuses on strict exam-style solving and review.';

  @override
  String get practiceSetupModeInfoTitle => 'How each mode works';

  @override
  String get practiceSetupHeroTitle => 'Start a session';

  @override
  String get practiceSetupHeroSubtitle =>
      'Choose a mode, timing, and difficulty.';

  @override
  String get practiceSetupInfiniteLives => 'Infinite lives';

  @override
  String practiceSetupLivesCount(Object count) {
    return '$count lives';
  }

  @override
  String get practiceSetupAiTiming => 'AI timing';

  @override
  String practiceSetupSecondsShort(Object seconds) {
    return '${seconds}s';
  }

  @override
  String practiceSetupQuestionsCount(Object count) {
    return '$count questions';
  }

  @override
  String practiceSetupSummarySubject(Object subject) {
    return 'Subject: $subject';
  }

  @override
  String practiceSetupSummaryTopic(Object topic) {
    return 'Topic: $topic';
  }

  @override
  String practiceSetupSummaryMode(Object mode) {
    return 'Mode: $mode';
  }

  @override
  String practiceSetupSummaryDifficulty(Object difficulty) {
    return 'Difficulty: $difficulty';
  }

  @override
  String practiceSetupSummaryQuestions(Object count) {
    return 'Questions: $count';
  }

  @override
  String practiceSetupSummaryTiming(Object timing) {
    return 'Timing: $timing';
  }

  @override
  String practiceSetupSummaryLives(Object lives) {
    return 'Lives: $lives';
  }

  @override
  String get practiceSetupSectionSubjectTopic => 'Subject & topic';

  @override
  String get practiceSetupFieldSubject => 'Subject';

  @override
  String get practiceSetupFieldSubjectHint => 'Pick the subject';

  @override
  String get practiceSetupChooseSubject => 'Choose subject';

  @override
  String get practiceSetupFieldCustomSubject => 'Custom subject';

  @override
  String get practiceSetupFieldCustomSubjectHint => 'Type your own subject';

  @override
  String get practiceSetupDialogCustomSubjectTitle => 'Custom subject';

  @override
  String get practiceSetupDialogEnterSubject => 'Enter subject';

  @override
  String get practiceSetupUseAction => 'Use';

  @override
  String get practiceSetupFieldTopic => 'Topic';

  @override
  String get practiceSetupFieldTopicHint => 'Pick sub-topic';

  @override
  String get practiceSetupChooseTopic => 'Choose topic';

  @override
  String get practiceSetupFieldCustomTopic => 'Custom topic';

  @override
  String get practiceSetupFieldCustomTopicHint => 'Type your own topic';

  @override
  String get practiceSetupDialogCustomTopicTitle => 'Custom topic';

  @override
  String get practiceSetupDialogEnterTopic => 'Enter topic';

  @override
  String get practiceSubjectMath => 'Math';

  @override
  String get practiceSubjectPhysics => 'Physics';

  @override
  String get practiceSubjectComputerScience => 'Computer Science';

  @override
  String get practiceSubjectChemistry => 'Chemistry';

  @override
  String get practiceSubjectBiology => 'Biology';

  @override
  String get practiceSubjectEnglish => 'English';

  @override
  String get practiceSubjectArabic => 'Arabic';

  @override
  String get practiceSubjectHebrew => 'Hebrew';

  @override
  String get practiceSubjectGeneralKnowledge => 'General Knowledge';

  @override
  String get practiceTopicAllTopics => 'All topics';

  @override
  String get practiceTopicAlgebra => 'Algebra';

  @override
  String get practiceTopicLinearEquations => 'Linear equations';

  @override
  String get practiceTopicQuadraticEquations => 'Quadratic equations';

  @override
  String get practiceTopicFunctions => 'Functions';

  @override
  String get practiceTopicGeometry => 'Geometry';

  @override
  String get practiceTopicTriangles => 'Triangles';

  @override
  String get practiceTopicCircles => 'Circles';

  @override
  String get practiceTopicAnalyticGeometry => 'Analytic geometry';

  @override
  String get practiceTopicTrigonometry => 'Trigonometry';

  @override
  String get practiceTopicProbability => 'Probability';

  @override
  String get practiceTopicStatistics => 'Statistics';

  @override
  String get practiceTopicSequences => 'Sequences';

  @override
  String get practiceTopicCalculus => 'Calculus';

  @override
  String get practiceTopicLimits => 'Limits';

  @override
  String get practiceTopicDerivatives => 'Derivatives';

  @override
  String get practiceTopicMechanics => 'Mechanics';

  @override
  String get practiceTopicKinematics => 'Kinematics';

  @override
  String get practiceTopicNewtonLaws => 'Newton laws';

  @override
  String get practiceTopicForces => 'Forces';

  @override
  String get practiceTopicEnergy => 'Energy';

  @override
  String get practiceTopicMomentum => 'Momentum';

  @override
  String get practiceTopicElectricity => 'Electricity';

  @override
  String get practiceTopicElectricField => 'Electric field';

  @override
  String get practiceTopicCircuits => 'Circuits';

  @override
  String get practiceTopicWaves => 'Waves';

  @override
  String get practiceTopicOptics => 'Optics';

  @override
  String get practiceTopicThermodynamics => 'Thermodynamics';

  @override
  String get practiceTopicConditions => 'Conditions';

  @override
  String get practiceTopicBooleanLogic => 'Boolean logic';

  @override
  String get practiceTopicIfElse => 'If / Else';

  @override
  String get practiceTopicNestedConditions => 'Nested conditions';

  @override
  String get practiceTopicLoops => 'Loops';

  @override
  String get practiceTopicVariables => 'Variables';

  @override
  String get practiceTopicArrays => 'Arrays';

  @override
  String get practiceTopicStrings => 'Strings';

  @override
  String get practiceTopicAlgorithms => 'Algorithms';

  @override
  String get practiceTopicComplexity => 'Complexity';

  @override
  String get practiceTopicRecursion => 'Recursion';

  @override
  String get practiceTopicAtoms => 'Atoms';

  @override
  String get practiceTopicPeriodicTable => 'Periodic table';

  @override
  String get practiceTopicChemicalBonds => 'Chemical bonds';

  @override
  String get practiceTopicReactions => 'Reactions';

  @override
  String get practiceTopicStoichiometry => 'Stoichiometry';

  @override
  String get practiceTopicAcidsAndBases => 'Acids and bases';

  @override
  String get practiceTopicOrganicChemistry => 'Organic chemistry';

  @override
  String get practiceTopicCells => 'Cells';

  @override
  String get practiceTopicGenetics => 'Genetics';

  @override
  String get practiceTopicHumanBody => 'Human body';

  @override
  String get practiceTopicEcology => 'Ecology';

  @override
  String get practiceTopicEvolution => 'Evolution';

  @override
  String get practiceTopicSystems => 'Systems';

  @override
  String get practiceTopicGrammar => 'Grammar';

  @override
  String get practiceTopicReadingComprehension => 'Reading comprehension';

  @override
  String get practiceTopicVocabulary => 'Vocabulary';

  @override
  String get practiceTopicTenses => 'Tenses';

  @override
  String get practiceTopicWriting => 'Writing';

  @override
  String get practiceTopicRhetoric => 'Rhetoric';

  @override
  String get practiceSetupSectionMode => 'Mode';

  @override
  String get practiceSetupSectionDifficulty => 'Difficulty';

  @override
  String get practiceSetupSectionControls => 'Session controls';

  @override
  String get practiceSetupQuestionsTitle => 'Questions';

  @override
  String get practiceSetupQuestionsCaption =>
      'How many generated questions to include';

  @override
  String get practiceSetupTimingTitle => 'Timing';

  @override
  String get practiceSetupTimingCaption =>
      'Choose scope first, then AI, your own time, or infinite.';

  @override
  String get practiceSetupTimingScopePerQuestion => 'Per question';

  @override
  String get practiceSetupTimingScopeWholeQuiz => 'Whole quiz';

  @override
  String get practiceSetupTimingModeAi => 'AI';

  @override
  String get practiceSetupTimingModeMyTime => 'My time';

  @override
  String get practiceSetupTimingModeInfinite => 'Infinite';

  @override
  String get practiceSetupTimingCustomPerQuestionTitle =>
      'Seconds per question';

  @override
  String get practiceSetupTimingCustomPerQuestionCaption =>
      'Your own timer for each question';

  @override
  String get practiceSetupTimingCustomQuizMinutesTitle => 'Quiz minutes';

  @override
  String get practiceSetupTimingCustomQuizMinutesCaption =>
      'Your own timer for the whole quiz';

  @override
  String get practiceSetupInfiniteLivesTitle => 'Infinite lives';

  @override
  String get practiceSetupInfiniteLivesSubtitle =>
      'Never end the session because of wrong answers';

  @override
  String get practiceSetupLivesTitle => 'Lives';

  @override
  String get practiceSetupLivesCaption =>
      'Mistakes allowed before the session ends';

  @override
  String get practiceSetupTooltipHistory => 'Practice history';

  @override
  String get practiceHistoryTitle => 'Practice history';

  @override
  String get practiceHistoryClearTooltip => 'Clear history';

  @override
  String get practiceHistoryClearConfirmTitle => 'Clear practice history?';

  @override
  String get practiceHistoryClearConfirmBody =>
      'This removes all saved practice sessions from this device.';

  @override
  String get practiceHistoryLoadError =>
      'Could not load practice history right now.';

  @override
  String get practiceHistoryErrorPrefix => 'Error:';

  @override
  String get practiceHistoryEmpty => 'No practice sessions yet.';

  @override
  String get practiceHistoryDeleteConfirmTitle => 'Delete this session?';

  @override
  String get practiceHistoryDeleteConfirmBody =>
      'This removes only this saved practice session.';

  @override
  String get practiceHistoryOpenReview => 'Open review';

  @override
  String get practiceHistoryDeleteSession => 'Delete session';

  @override
  String get practiceHistoryDebugTitle => 'Practice history debug';

  @override
  String get practiceAnalyticsTitle => 'Practice analytics';

  @override
  String get practiceAnalyticsSectionOverall => 'Overall';

  @override
  String get practiceAnalyticsRecentSessionsTitle => 'Recent sessions';

  @override
  String practiceAnalyticsRecentSessionsSummary(
    Object sessions,
    Object correct,
    Object answered,
    Object accuracy,
    Object xp,
  ) {
    return '$sessions sessions • $correct/$answered correct • $accuracy% • XP $xp';
  }

  @override
  String get practiceAnalyticsSectionWeakestTopics => 'Weakest topics';

  @override
  String get practiceAnalyticsSectionStrongestTopics => 'Strongest topics';

  @override
  String get practiceAnalyticsSectionModePerformance => 'Mode performance';

  @override
  String get practiceAnalyticsNoTopicData => 'No topic data yet';

  @override
  String get practiceAnalyticsNoModeData => 'No mode data yet';

  @override
  String get savedQuestionsTopSubjectNone => 'None yet';

  @override
  String get savedQuestionsHeroSubtitle =>
      'Questions you saved during practice should feel easy to revisit. This page is the clean retry hub for them.';

  @override
  String get savedQuestionsSavedMetric => 'Saved';

  @override
  String get savedQuestionsTopSubjectMetric => 'Top subject';

  @override
  String get savedQuestionsQuickActionsSubtitle =>
      'Jump straight back into practice or browse community solutions.';

  @override
  String get savedQuestionsOpenPractice => 'Open practice';

  @override
  String get savedQuestionsOpenPracticeSubtitle =>
      'Start a fresh session and keep building momentum';

  @override
  String get savedQuestionsOpenSolutions => 'Open solutions';

  @override
  String get savedQuestionsOpenSolutionsSubtitle =>
      'Browse uploaded solutions by subject, book, page, and question';

  @override
  String get savedQuestionsQueueTitle => 'Your saved queue';

  @override
  String get savedQuestionsQueueSubtitle =>
      'Questions you save in practice appear here so you can reopen them quickly and keep working your weak spots.';

  @override
  String get savedQuestionsEmptyTitle => 'No saved questions yet';

  @override
  String get savedQuestionsEmptySubtitle =>
      'Save a question from practice to revisit it later, open related solutions, and track the topics that still need work.';

  @override
  String get savedQuestionsClearAction => 'Clear saved questions';

  @override
  String get savedQuestionsWhyItWorks => 'Why it works';

  @override
  String savedQuestionsHoursTarget(Object count) {
    return '$count h target';
  }

  @override
  String savedQuestionsMinutesTarget(Object count) {
    return '$count min target';
  }

  @override
  String savedQuestionsSecondsTarget(Object count) {
    return '$count sec target';
  }

  @override
  String get practiceSetupTooltipAnalytics => 'Practice analytics';

  @override
  String get practiceSetupStopGenerating => 'Stop Generating';

  @override
  String get practiceSetupGenerating => 'Generating...';

  @override
  String get practiceSetupStartSession => 'Start session';

  @override
  String get practiceSetupSearchHint => 'Search...';

  @override
  String get practiceSessionModeDescriptionPractice =>
      'Balanced solving with instant checking and feedback.';

  @override
  String get practiceSessionModeDescriptionFlashcards =>
      'Memory-first mode built for quick recall and retention.';

  @override
  String get practiceSessionModeDescriptionSpeedRound =>
      'Fast, low-friction, timed pressure reps.';

  @override
  String get practiceSessionModeDescriptionExamPrep =>
      'Formal exam-feel solving with less gamified pacing.';

  @override
  String get practiceSessionModeDescriptionConceptBuilder =>
      'Understand the idea first, then solve with context.';

  @override
  String get practiceSessionModeDescriptionAdaptive =>
      'Difficulty shifts based on how you perform.';

  @override
  String get practiceSessionModeDescriptionBagrut =>
      'Official-style single-question formal Bagrut flow.';

  @override
  String get practiceSessionLoadingPractice => 'Building your practice session';

  @override
  String get practiceSessionLoadingFlashcards => 'Shuffling your flashcards';

  @override
  String get practiceSessionLoadingSpeedRound => 'Starting the speed round';

  @override
  String get practiceSessionLoadingExamPrep => 'Preparing your exam session';

  @override
  String get practiceSessionLoadingConceptBuilder => 'Loading concept coach';

  @override
  String get practiceSessionLoadingAdaptive => 'Personalizing your challenge';

  @override
  String get practiceSessionLoadingBagrut => 'Preparing your Bagrut set';

  @override
  String get practiceSessionLoadingDefault => 'Preparing your session';

  @override
  String practiceSessionCompleteTitle(Object mode) {
    return '$mode complete';
  }

  @override
  String get practiceSessionMetricAnswered => 'Answered';

  @override
  String get practiceSessionMetricCorrect => 'Correct';

  @override
  String get practiceSessionMetricWrong => 'Wrong';

  @override
  String get practiceSessionMetricAccuracy => 'Accuracy';

  @override
  String get practiceSessionMetricTotal => 'Total';

  @override
  String get practiceSessionMetricXp => 'XP';

  @override
  String get practiceSessionMetricStreak => 'Streak';

  @override
  String get practiceSessionReviewLayoutStacked => 'Stacked';

  @override
  String get practiceSessionReviewLayoutFocus => 'Focus';

  @override
  String get practiceSessionFilterAll => 'All';

  @override
  String get practiceSessionFilterWrong => 'Wrong';

  @override
  String get practiceSessionFilterCorrect => 'Correct';

  @override
  String get practiceSessionReviewTitle => 'Session review';

  @override
  String get practiceSessionNoQuestionsForFilter =>
      'No questions match this filter yet.';

  @override
  String get practiceSessionNoAnswer => 'No answer';

  @override
  String get practiceSessionUnknownAnswer => 'Unknown';

  @override
  String get practiceSessionReflectionTitle => 'Reflection';

  @override
  String get practiceSessionReflectionKnewIt => 'Knew it';

  @override
  String get practiceSessionReflectionReviewAgain => 'Review again';

  @override
  String get practiceSessionBackOfCard => 'Back of card';

  @override
  String get practiceSessionYourAnswer => 'Your answer';

  @override
  String get practiceSessionCorrectAnswer => 'Correct answer';

  @override
  String get practiceSessionExplanation => 'Explanation';

  @override
  String get practiceSessionBackToSetup => 'Back to setup';

  @override
  String get practiceSessionGeneralTopic => 'General';

  @override
  String practiceSessionQuestionProgress(Object current, Object total) {
    return 'Question $current of $total';
  }

  @override
  String get practiceSessionMetricTime => 'Time';

  @override
  String practiceSessionMatchmakingDifficulty(Object difficulty) {
    return 'Difficulty: $difficulty';
  }

  @override
  String get practiceModeActionPrevious => 'Previous';

  @override
  String get practiceModeActionCheckAnswer => 'Check answer';

  @override
  String get practiceModeActionNext => 'Next';

  @override
  String get practiceModeActionNextQuestion => 'Next question';

  @override
  String get practiceModeActionEndSession => 'End session';

  @override
  String get practiceModeActionEndQuestion => 'End question';

  @override
  String get practiceModeActionEndExam => 'End exam';

  @override
  String get practiceModeActionNovaHint => 'NOVA hint';

  @override
  String get practiceModeActionReveal => 'Reveal';

  @override
  String get practiceModeActionShowSolution => 'Show solution';

  @override
  String get practiceModeActionHideSolution => 'Hide solution';

  @override
  String get practiceModeActionLockIn => 'Lock in';

  @override
  String get practiceModeActionCheckAdapt => 'Check & adapt';

  @override
  String get practiceModeActionContinue => 'Continue';

  @override
  String get practiceModeActionSolveIt => 'Solve it';

  @override
  String get practiceModeActionNextConcept => 'Next concept';

  @override
  String get practiceModeCardFront => 'Front of card';

  @override
  String get practiceModeRecallSummary => 'Recall summary';

  @override
  String get practiceModeFeelingPrompt => 'How did that feel?';

  @override
  String get practiceModeFeelingAgain => 'Again';

  @override
  String get practiceModeFeelingHard => 'Hard';

  @override
  String get practiceModeFeelingGood => 'Good';

  @override
  String get practiceModeFeelingEasy => 'Easy';

  @override
  String get practiceModeSpeedRoundBanner =>
      'Speed round · fast decisions, instant momentum';

  @override
  String get practiceModeFastFeedback => 'Fast feedback';

  @override
  String get practiceModeExamPrepBanner =>
      'Exam prep · quieter layout, answers reviewed after moving forward';

  @override
  String get practiceModeReview => 'Review';

  @override
  String get practiceModeBagrutBanner =>
      'Bagrut mode · official-style paper flow';

  @override
  String get practiceModeOfficialSolution => 'Official-style solution';

  @override
  String get practiceModeAdaptiveWarmup => 'Warm-up difficulty';

  @override
  String get practiceModeAdaptiveTrendingUp => 'Difficulty trending up';

  @override
  String get practiceModeAdaptiveEasingDown => 'Difficulty easing down';

  @override
  String get practiceModeAdaptiveSteady => 'Difficulty holding steady';

  @override
  String get practiceModeAdaptiveFeedback => 'Adaptive feedback';

  @override
  String get practiceModeConceptFirst => 'Concept first';

  @override
  String get practiceModeNowSolveIt => 'Now solve it';

  @override
  String get practiceModeConceptTitle => 'Concept';

  @override
  String get practiceModeFeedbackCorrect => 'Correct';

  @override
  String get practiceModeFeedbackNotQuite => 'Not quite';

  @override
  String get practiceModeFallbackQuestion => 'Question';

  @override
  String get practiceModeNoExplanationYet => 'No explanation available yet.';

  @override
  String get teacherGradesAssessmentCreated => 'Assessment created';

  @override
  String get teacherGradesEditAssessmentTitle => 'Edit assessment';

  @override
  String get teacherGradesFieldTitle => 'Title';

  @override
  String get teacherGradesFieldDate => 'Date (YYYY-MM-DD)';

  @override
  String get teacherGradesFieldMaxGrade => 'Max grade';

  @override
  String get teacherGradesAssessmentUpdated => 'Assessment updated';

  @override
  String get teacherGradesDeleteAssessmentTitle => 'Delete assessment?';

  @override
  String teacherGradesDeleteAssessmentBody(Object title) {
    return 'This will remove $title and its grading entry from the teacher workspace.';
  }

  @override
  String get teacherGradesDeleteAction => 'Delete';

  @override
  String get teacherGradesAssessmentDeleted => 'Assessment deleted';

  @override
  String get teacherGradesRosterLinkError =>
      'This assessment is not linked to a classroom roster.';

  @override
  String get teacherGradesSaved => 'Grades saved';

  @override
  String get teacherGradesSubtitle =>
      'Create assessments and save grades against the live classroom roster.';

  @override
  String get teacherGradesCreateAssessmentTitle => 'Create assessment';

  @override
  String get teacherGradesFieldCourse => 'Course';

  @override
  String get teacherGradesCreateAction => 'Create';

  @override
  String get teacherGradesNoStudentsLoaded =>
      'No students loaded for this assessment.';

  @override
  String get teacherGradesFieldGrade => 'Grade';

  @override
  String teacherGradesMaxHint(Object grade) {
    return 'Max $grade';
  }

  @override
  String get teacherGradesSaving => 'Saving…';

  @override
  String teacherGradesSaveCount(Object count) {
    return 'Save $count grades';
  }

  @override
  String get assignmentsNoDueDate => 'No due date';

  @override
  String get assignmentsLoadError =>
      'We could not load assignments right now. Pull to refresh or try again.';

  @override
  String get assignmentsLoadTimeout =>
      'Assignments are taking too long to load. Pull to refresh or try again in a moment.';

  @override
  String get assignmentsLoadNetwork =>
      'Assignments could not connect right now. Check your connection and try again.';

  @override
  String get assignmentsStatusOverdue => 'Overdue';

  @override
  String get assignmentsStatusDueSoon => 'Due soon';

  @override
  String get assignmentsStatusUpcoming => 'Upcoming';

  @override
  String get assignmentsPreviewFallback =>
      'Open this assignment to see the full instructions and prepare your work.';

  @override
  String get assignmentsSubmissionPrepEmpty => 'Stage your note or files here.';

  @override
  String assignmentsSubmissionPrepCount(Object count) {
    return '$count file(s) attached locally.';
  }

  @override
  String get assignmentsHeroSubtitle =>
      'Every classroom assignment in one clean view, with a full-screen detail page and a dedicated place to prepare your work.';

  @override
  String get assignmentsSubjectsMetric => 'Subjects';

  @override
  String get assignmentsNothingAssignedYet => 'Nothing assigned yet';

  @override
  String get assignmentsNoAssignmentsForAccount =>
      'No classroom assignments are available for this student account right now.';

  @override
  String assignmentsNextThingBody(Object title, Object due) {
    return '$title is the next thing to look at. $due.';
  }

  @override
  String get assignmentsPullToCheckAgain => 'Pull down to check again.';

  @override
  String get assignmentsFiltersSubtitle =>
      'Narrow the list by subject or urgency to focus on what matters first.';

  @override
  String get assignmentsSubjectLabel => 'Subject';

  @override
  String get assignmentsAllSubjects => 'All subjects';

  @override
  String get assignmentsSearchSubjects => 'Search subjects';

  @override
  String get assignmentsStatusLabel => 'Status';

  @override
  String get assignmentsAllStatuses => 'All statuses';

  @override
  String get assignmentsSearchStatuses => 'Search statuses';

  @override
  String assignmentsShowingSummary(Object shown, Object total) {
    return 'Showing $shown of $total assignments.';
  }

  @override
  String get assignmentsNoFilterMatchesTitle =>
      'No assignments match these filters';

  @override
  String get assignmentsNoFilterMatchesSubtitle =>
      'Try all subjects or a wider status view to bring more assignments back into the list.';

  @override
  String get assignmentsClearFiltersHint =>
      'Clear filters to see everything again.';

  @override
  String get assignmentsListSubtitle =>
      'Tap any assignment to open the full-screen detail view and prepare your work.';

  @override
  String get assignmentsAddNoteBeforePrepare =>
      'Add a note or attach a file before preparing your work.';

  @override
  String get assignmentsWorkDraftPrepared => 'Work draft prepared.';

  @override
  String get assignmentsWorkDraftPreparedWithFiles =>
      'Work draft prepared. Attached files are saved on this device.';

  @override
  String get assignmentsUnavailableTitle => 'Assignment unavailable';

  @override
  String get assignmentsUnavailableSubtitle =>
      'This assignment could not be found in the current feed. It may have been removed or is not available offline.';

  @override
  String get assignmentsUnavailableHint =>
      'Go back and refresh the assignments list.';

  @override
  String get assignmentsOverdueBannerBody =>
      'This assignment is past its due date. Open your work area below to prepare what you want to turn in.';

  @override
  String get assignmentsWorkAreaBannerBody =>
      'Use the work area below to stage files, write a note, and keep everything ready in one place.';

  @override
  String get assignmentsDetailsSectionTitle => 'Assignment details';

  @override
  String get assignmentsDetailsSectionSubtitle =>
      'Everything student-relevant that is currently available in the classroom assignment payload.';

  @override
  String get assignmentsDetailDueLabel => 'Due';

  @override
  String get assignmentsDetailClassroomLabel => 'Classroom';

  @override
  String get assignmentsDetailTeacherLabel => 'Teacher';

  @override
  String get assignmentsDetailPostedByLabel => 'Posted by';

  @override
  String get assignmentsDetailPublishedLabel => 'Published';

  @override
  String get assignmentsDetailUpdatedLabel => 'Updated';

  @override
  String get assignmentsDetailIdLabel => 'Assignment ID';

  @override
  String get assignmentsInstructionsTitle => 'Instructions';

  @override
  String get assignmentsInstructionsSubtitle =>
      'Full assignment text from the classroom feed, with the original wording preserved.';

  @override
  String get assignmentsYourWorkTitle => 'Your work';

  @override
  String get assignmentsYourWorkSubtitle =>
      'Stage a note, attach files or docs, and keep your submission prep in one focused space.';

  @override
  String get assignmentsPrivateNoteLabel => 'Private work note';

  @override
  String get assignmentsPrivateNoteHint =>
      'Add what you plan to submit, reminders for yourself, or a doc/link summary.';

  @override
  String get assignmentsAddFiles => 'Add files or docs';

  @override
  String get assignmentsClearFiles => 'Clear files';

  @override
  String get assignmentsStagedDeviceHint =>
      'Files are staged on this device. Assignment file submission is not available in this app.';

  @override
  String assignmentsLastPrepared(Object time) {
    return 'Last prepared $time.';
  }

  @override
  String get assignmentsSubmissionPrepTitle => 'Submission prep';

  @override
  String get assignmentsPreparing => 'Preparing';

  @override
  String get assignmentsPrepareWork => 'Prepare work';

  @override
  String get assignmentsLoadingSubtitle =>
      'Loading your classroom assignments.';

  @override
  String get assignmentsPullToRefreshRetry => 'Pull to refresh or retry below.';

  @override
  String get assignmentsFileSizeUnknown => 'File';

  @override
  String get assignmentsRemoveAttachment => 'Remove';

  @override
  String get assignmentsSubmitted => 'Submitted';

  @override
  String get attendanceUndated => 'Undated';

  @override
  String get attendanceLoadError =>
      'We could not load attendance right now. Pull to refresh or try again.';

  @override
  String get attendanceLoadTimeout =>
      'Attendance is taking too long to load. Pull to refresh or try again in a moment.';

  @override
  String get attendanceLoadNetwork =>
      'Attendance could not connect right now. Check your connection and try again.';

  @override
  String get attendanceConsistencyBuilding => 'Still building';

  @override
  String get attendanceConsistencyExcellent => 'Excellent consistency';

  @override
  String get attendanceConsistencySteady => 'Mostly steady';

  @override
  String get attendanceConsistencyNeedsAttention => 'Needs attention';

  @override
  String get attendanceConsistencyRisk => 'Attendance risk';

  @override
  String get attendanceWatchRecentAbsences => 'Recent absences';

  @override
  String get attendanceWatchRepeatedLateness => 'Repeated lateness';

  @override
  String get attendanceWatchExcusedAddingUp => 'Excused time adding up';

  @override
  String get attendanceWatchNoFlags => 'No current flags';

  @override
  String get attendanceAllSubjectsLowercase => 'all subjects';

  @override
  String attendanceShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return 'Showing $shown of $total marks for $subject in $range.';
  }

  @override
  String get attendanceDayToneAbsent => 'Absence day';

  @override
  String get attendanceDayToneLate => 'Late signal';

  @override
  String get attendanceDayToneExcused => 'Excused attendance';

  @override
  String get attendanceDayToneClean => 'Clean day';

  @override
  String get attendanceLoadingSubtitle =>
      'Loading your latest attendance summary.';

  @override
  String get attendanceUnavailableTitle => 'Attendance unavailable';

  @override
  String get attendanceHeroSubtitle =>
      'A clean read on your attendance rate, recent lessons, and anything that needs attention.';

  @override
  String get attendanceMetricRate => 'Rate';

  @override
  String get attendanceMetricPresent => 'Present marks';

  @override
  String get attendanceMetricLate => 'Late marks';

  @override
  String get attendanceMetricAbsent => 'Absent marks';

  @override
  String attendanceHeroSignalBody(Object flag) {
    return '$flag. Attendance pressure can build quietly, so this view stays focused on what changed most recently.';
  }

  @override
  String get attendanceNoSummary =>
      'No attendance summary is available for this student account yet.';

  @override
  String get attendanceEmptyTitle => 'No attendance records yet';

  @override
  String get attendanceEmptySubtitle =>
      'No attendance records have been published for this student account yet.';

  @override
  String get attendanceFiltersSubtitle =>
      'Use the same searchable picker style as settings to narrow the attendance view by subject or time window.';

  @override
  String get attendanceTimeRangeLabel => 'Time range';

  @override
  String get attendanceSearchRanges => 'All time / 7 days / 30 days / 90 days';

  @override
  String get attendanceNoFilteredMarksTitle => 'No marks match these filters';

  @override
  String get attendanceNoFilteredMarksSubtitle =>
      'Try all subjects or a wider time range to bring more attendance marks back into view.';

  @override
  String get attendanceQuickReadTitle => 'Quick read';

  @override
  String get attendanceQuickReadSubtitleFiltered =>
      'A fast summary for the filtered attendance marks shown below.';

  @override
  String get attendanceQuickReadSubtitleAll =>
      'A fast summary based on the latest attendance records available.';

  @override
  String get attendanceSummaryConsistency => 'Consistency';

  @override
  String get attendanceSummaryWatchFor => 'Watch for';

  @override
  String get attendanceSummaryExcused => 'Excused marks';

  @override
  String get attendanceSummaryMarksInView => 'Marks in view';

  @override
  String get attendanceSummaryRateInView => 'Rate in view';

  @override
  String get attendanceRecentDaysTitle => 'Recent days';

  @override
  String get attendanceRecentDaysSubtitleFiltered =>
      'Grouped by day for the filtered marks currently in view.';

  @override
  String get attendanceRecentDaysSubtitleAll =>
      'Grouped by day so you can catch absence or lateness patterns faster.';

  @override
  String get attendanceLessonCountSingle => '1 lesson';

  @override
  String attendanceLessonCount(Object count) {
    return '$count lessons';
  }

  @override
  String get attendanceStatusPresent => 'Present';

  @override
  String get attendanceStatusLate => 'Late';

  @override
  String get attendanceStatusAbsent => 'Absent';

  @override
  String get attendanceStatusExcused => 'Excused';

  @override
  String get attendanceStatusRecorded => 'Recorded';

  @override
  String get attendanceLessonFallback => 'Lesson';

  @override
  String get attendanceRangeAll => 'All time';

  @override
  String get attendanceRange7 => 'Last 7 days';

  @override
  String get attendanceRange30 => 'Last 30 days';

  @override
  String get attendanceRange90 => 'Last 90 days';

  @override
  String get attendanceRangeAllShort => 'All time';

  @override
  String get attendanceRange7Short => '7 days';

  @override
  String get attendanceRange30Short => '30 days';

  @override
  String get attendanceRange90Short => '90 days';

  @override
  String get gradesLoadError =>
      'We could not load grades right now. Pull to refresh or try again.';

  @override
  String get gradesLoadTimeout =>
      'Grades are taking too long to load. Pull to refresh or try again in a moment.';

  @override
  String get gradesLoadNetwork =>
      'Grades could not connect right now. Check your connection and try again.';

  @override
  String get gradesGeneralSubject => 'General';

  @override
  String get gradesBandBuilding => 'Still building';

  @override
  String get gradesBandExcellent => 'Excellent';

  @override
  String get gradesBandStrong => 'Strong';

  @override
  String get gradesBandOkay => 'Okay';

  @override
  String get gradesBandNeedsAttention => 'Needs attention';

  @override
  String get gradesBandRisk => 'At risk';

  @override
  String get gradesTrendRising => 'Rising';

  @override
  String get gradesTrendDropping => 'Dropping';

  @override
  String get gradesTrendStable => 'Stable';

  @override
  String gradesShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return 'Showing $shown of $total recorded grades for $subject in $range.';
  }

  @override
  String get gradesLoadingSubtitle => 'Loading your latest academic results.';

  @override
  String get gradesUnavailableTitle => 'Grades unavailable';

  @override
  String get gradesHeroSubtitle =>
      'A clean read on your average, recent assessments, and which subjects need protection or recovery.';

  @override
  String get gradesMetricAverage => 'Average';

  @override
  String get gradesMetricRecorded => 'Recorded';

  @override
  String get gradesMetricBestSubject => 'Best subject';

  @override
  String get gradesMetricNeedsWork => 'Needs work';

  @override
  String gradesLatestSignalBody(
    Object assessment,
    Object subject,
    Object grade,
    Object band,
  ) {
    return '$assessment in $subject landed at $grade. $band right now.';
  }

  @override
  String get gradesSummaryAvailableNoRecent =>
      'A grade summary is available, but no recent assessments are visible in this view yet.';

  @override
  String get gradesEmptyTitle => 'No grades yet';

  @override
  String get gradesEmptySubtitle =>
      'No grades have been published for this student account yet.';

  @override
  String get gradesFiltersSubtitle =>
      'Use the same searchable picker style as settings to narrow grades by subject or time window.';

  @override
  String get gradesNoFilteredTitle => 'No grades match these filters';

  @override
  String get gradesNoFilteredSubtitle =>
      'Try all subjects or a wider time range to bring more recorded grades back into view.';

  @override
  String get gradesQuickReadTitle => 'Quick read';

  @override
  String get gradesQuickReadSubtitleFiltered =>
      'A fast summary for the grades currently in view.';

  @override
  String get gradesQuickReadSubtitleAll =>
      'The fastest read on what to protect and what to recover.';

  @override
  String get gradesWeakSpotLabel => 'Current weak spot';

  @override
  String get gradesNoWeakSignal => 'No weak subject signal yet';

  @override
  String gradesWeakSpotValue(Object subject) {
    return '$subject needs the first recovery block.';
  }

  @override
  String get gradesStrengthLabel => 'Current strength';

  @override
  String get gradesNoStrengthSignal => 'No strong subject signal yet';

  @override
  String gradesStrengthValue(Object subject) {
    return '$subject is your confidence anchor right now.';
  }

  @override
  String get gradesBandLabel => 'Band';

  @override
  String get gradesInViewLabel => 'In view';

  @override
  String gradesInViewCount(Object count) {
    return '$count recorded grades in this filter.';
  }

  @override
  String gradesInViewAverage(Object count, Object average) {
    return '$count recorded grades averaging $average.';
  }

  @override
  String get gradesLatestAssessmentsTitle => 'Latest assessments';

  @override
  String get gradesLatestAssessmentsSubtitleFiltered =>
      'Most recent recorded grades in the current filtered view.';

  @override
  String get gradesLatestAssessmentsSubtitleAll =>
      'Most recent recorded grades in chronological order.';

  @override
  String get gradesSubjectDrilldownTitle => 'Subject drilldown';

  @override
  String get gradesSubjectDrilldownSubtitleFiltered =>
      'Grouped by subject for the grades currently in view.';

  @override
  String get gradesSubjectDrilldownSubtitleAll =>
      'Grouped by subject so trend and pressure stand out faster.';

  @override
  String get gradesAssessmentFallback => 'Assessment';

  @override
  String get gradesChipBest => 'Best';

  @override
  String get gradesNoAverageYet => 'No average yet';

  @override
  String gradesRecentAverage(Object average) {
    return 'Recent average: $average';
  }

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionBlock => 'Block';

  @override
  String get actionCreate => 'Create';

  @override
  String get actionShare => 'Share';

  @override
  String get actionScheduleVerb => 'Schedule';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionKeep => 'Keep';

  @override
  String get actionOpen => 'Open';

  @override
  String get actionPublish => 'Publish';

  @override
  String get actionPublishing => 'Publishing…';

  @override
  String get actionRefresh => 'Refresh';

  @override
  String get msgBlockTitle => 'Block this person?';

  @override
  String get msgBlockContent =>
      'They won\'t be able to message you and you won\'t see their messages.';

  @override
  String get msgRenameGroup => 'Rename group';

  @override
  String get msgGroupName => 'Group name';

  @override
  String get msgMute => 'Mute';

  @override
  String get msgUnmute => 'Unmute';

  @override
  String get msgInviteCode => 'Invite code';

  @override
  String get msgCopyCode => 'Copy code';

  @override
  String get msgLeave => 'Leave';

  @override
  String get msgInviteCodeCopied => 'Invite code copied';

  @override
  String msgCodeCopied(Object code) {
    return 'Code copied: $code';
  }

  @override
  String msgParticipantsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants added',
      one: '1 participant added',
    );
    return '$_temp0';
  }

  @override
  String msgMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get msgAdmin => 'Admin';

  @override
  String get msgRemoveFromGroup => 'Remove from group';

  @override
  String get msgMakeAdmin => 'Make admin';

  @override
  String get msgRemoveAdmin => 'Remove admin';

  @override
  String get msgOnlyAdmin => 'Only admin — promote another first';

  @override
  String msgRemoveMemberTitle(Object name) {
    return 'Remove $name?';
  }

  @override
  String get msgNotificationsMuted => 'Notifications muted';

  @override
  String get msgNotificationsUnmuted => 'Notifications unmuted';

  @override
  String get msgJoinGroupTitle => 'Join a Group';

  @override
  String get msgJoinGroupSubtitle =>
      'Enter the invite code from the group admin';

  @override
  String get examTitle => 'Exam';

  @override
  String get examNotFound => 'Exam not found';

  @override
  String get examStudyWithNova => 'Study with NOVA';

  @override
  String get examOpenInsights => 'Open Insights';

  @override
  String get examAddToCalendar => 'Add to calendar';

  @override
  String get examCouldNotOpenCalendar => 'Could not open calendar.';

  @override
  String get formTitle => 'Form';

  @override
  String get formNotFound => 'Form not found';

  @override
  String get formClosed => 'This form is closed.';

  @override
  String get formCompletion => 'Completion';

  @override
  String get formNoTextResponses => 'No text responses yet.';

  @override
  String get meetingsCouldNotLoad => 'Could not load meetings';

  @override
  String get meetingCouldNotLoad => 'Could not load meeting';

  @override
  String get insightsGenerateAction => 'Generate Insights';

  @override
  String get insightsRefreshAction => 'Refresh';

  @override
  String get teacherGoToClassroom => 'Go to Classroom';

  @override
  String get teacherMarkAttendance => 'Mark Attendance';

  @override
  String get teacherPostAssignment => 'Post Assignment';

  @override
  String get teacherNewAnnouncementAction => 'New Announcement';

  @override
  String get teacherViewFullWeekSchedule => 'View full week schedule';

  @override
  String get teacherGroupsLabel => 'Groups';

  @override
  String get teacherTestsLabel => 'Tests';

  @override
  String get teacherAnnounceLabel => 'Announce';

  @override
  String get teacherTitleAndMessageRequired => 'Title and message are required';

  @override
  String get teacherAnnouncementPublished => 'Announcement published';

  @override
  String teacherFailedToPublish(Object error) {
    return 'Failed to publish: $error';
  }

  @override
  String get teacherAnnouncementSectionTitle => 'Announcement';

  @override
  String get teacherAudienceSectionTitle => 'Audience';

  @override
  String get teacherPinAnnouncement => 'Pin announcement';

  @override
  String get teacherPinnedAtTop => 'Pinned announcements appear at the top';

  @override
  String get teacherPublishAction => 'Publish';

  @override
  String get teacherPublishingAction => 'Publishing…';

  @override
  String get teacherAnnounceTitleLabel => 'Title *';

  @override
  String get teacherAnnounceTitleHint => 'e.g. School event tomorrow';

  @override
  String get teacherAnnounceMessageLabel => 'Message *';

  @override
  String get teacherAnnounceMessageHint => 'Write the full announcement here…';

  @override
  String get teacherStudentsLabel => 'Students';

  @override
  String get teacherSearchStudents => 'Search students…';

  @override
  String get teacherNoStudentsLoaded => 'No students found in this school.';

  @override
  String get teacherActions => 'QUICK ACTIONS';

  @override
  String get teacherParentsLabel => 'Parents';

  @override
  String get teacherTeachersLabel => 'Teachers';

  @override
  String get teacherWeekScheduleTitle => 'Week Schedule';

  @override
  String get teacherCouldNotLoadSchedule => 'Could not load schedule';

  @override
  String get teacherAttendanceLast30 => 'Attendance (last 30 days)';

  @override
  String teacherAttendanceFrom(Object date) {
    return 'From $date';
  }

  @override
  String get teacherAttendanceChangeDate => 'Change date';

  @override
  String get teacherAttendanceNoSessions =>
      'No saved attendance sessions.\nMark attendance from the schedule.';

  @override
  String get teacherRecentGrades => 'Recent Grades';

  @override
  String get teacherNoGradesRecorded => 'No grades recorded yet';

  @override
  String get teacherGradeAvg => 'Grade Avg';

  @override
  String get teacherSubmittedLabel => 'Submitted';

  @override
  String get teacherAnalyticsTitle => 'Analytics';

  @override
  String get teacherGradeReports => 'Grade Reports';

  @override
  String get teacherAvgLabel => 'avg';

  @override
  String teacherBelow60(Object count) {
    return '$count below 60%';
  }

  @override
  String teacherGradedFraction(Object graded, Object total) {
    return '$graded/$total graded';
  }

  @override
  String get teacherNoGradesEntered => 'No grades entered yet';

  @override
  String get teacherNewAssignment => 'New Assignment';

  @override
  String get teacherDeleteAssignment => 'Delete assignment?';

  @override
  String get teacherDeleteAssignmentContent =>
      'This will remove it for all students.';

  @override
  String get teacherShareMaterialTitle => 'Share Material';

  @override
  String get teacherRemoveMaterial => 'Remove material?';

  @override
  String get teacherScheduleMeetingTitle => 'Schedule Meeting';

  @override
  String get teacherCancelMeetingTitle => 'Cancel meeting?';

  @override
  String get teacherCancelMeetingAction => 'Cancel meeting';

  @override
  String get teacherJoinMeeting => 'Join meeting';

  @override
  String get teacherAddStudentTitle => 'Add Student';

  @override
  String teacherRemoveStudentTitle(Object name) {
    return 'Remove $name?';
  }

  @override
  String get teacherRemoveStudentContent =>
      'This student will be removed from this classroom.';

  @override
  String get teacherStudentAdded => 'Student added';

  @override
  String get teacherClassroomAnalyticsTitle => 'Classroom Analytics';

  @override
  String get teacherOpenAnalyticsAction => 'Open Analytics';

  @override
  String teacherStudentsCount(Object count) {
    return 'Students ($count)';
  }

  @override
  String get teacherAssignmentLabel => 'Assignment';

  @override
  String get teacherShareMaterialLabel => 'Share material';

  @override
  String get teacherAttendanceRateLabel => 'Attendance rate';

  @override
  String get teacherSelectSessionPrompt =>
      'Select a session below to start marking attendance';

  @override
  String get teacherOpenAction => 'Open';

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

  @override
  String get teacherInsightsTitle => 'Student Insights';

  @override
  String get teacherInsightsSubtitle =>
      'Select a student to view their academic insights.';

  @override
  String get teacherInsightsNoStudents => 'No students found.';

  @override
  String get teacherInsightsSearchHint => 'Search students…';

  @override
  String get navDiplomas => 'Certificates';

  @override
  String get diplomasComingSoon => 'Diploma management is coming soon.';

  @override
  String get teacherExamsTitle => 'Exams';

  @override
  String get teacherExamsUpcoming => 'Upcoming';

  @override
  String get teacherExamsPast => 'Past';

  @override
  String get teacherExamsEmpty => 'No assessments yet. Tap + to create one.';

  @override
  String teacherExamsGraded(Object count) {
    return '$count graded';
  }

  @override
  String get teacherFormsTitle => 'Forms';

  @override
  String get teacherFormsEmpty => 'No forms yet. Tap + to create one.';

  @override
  String teacherFormsResponses(Object count) {
    return '$count responses';
  }

  @override
  String get teacherFormsPublished => 'Published';

  @override
  String get teacherFormsDraft => 'Draft';

  @override
  String get teacherFormsCreateTitle => 'Create Form';

  @override
  String get teacherFormsAddQuestion => 'Add question';

  @override
  String get teacherFormsQuestionHint => 'Question text';

  @override
  String get teacherFormsViewResponses => 'View responses';

  @override
  String get teacherFormsNoResponses => 'No responses yet.';

  @override
  String get diplomasTitle => 'Certificates';

  @override
  String get diplomasEmpty => 'No certificates issued yet. Tap + to issue one.';

  @override
  String get diplomasIssueTo => 'Issue to';

  @override
  String get diplomasStudentName => 'Student name';

  @override
  String get diplomasCertificateType => 'Certificate type';

  @override
  String get diplomasIssueDiploma => 'Issue Certificate';

  @override
  String diplomasIssuedOn(Object date) {
    return 'Issued on $date';
  }

  @override
  String get examDetailsSection => 'Details';

  @override
  String get examInfoTeacher => 'Teacher';

  @override
  String get examInfoAudience => 'Audience';

  @override
  String get examInfoDate => 'Date';

  @override
  String get examInfoTime => 'Time';

  @override
  String get examInfoPeriod => 'Period';

  @override
  String get examInfoDuration => 'Duration';

  @override
  String get examInfoSubject => 'Subject';

  @override
  String get examMaterialsSection => 'Attached materials';

  @override
  String get examNoMaterials => 'No materials attached yet.';

  @override
  String get examQuickActionsSection => 'Quick actions';

  @override
  String get examViewGradeTitle => 'See your grade';

  @override
  String get examViewGradeBody =>
      'This exam is complete. Check the grades tab for your result.';

  @override
  String get examViewGradeAction => 'Open Grades';

  @override
  String get teacherGradesSaveAction => 'Save';

  @override
  String get teacherGradesNothingToSave => 'No changes to save.';

  @override
  String get teacherRetry => 'Retry';

  @override
  String get teacherExamGradesStudents => 'students';

  @override
  String get teacherExamGradesGraded => 'graded';

  @override
  String get teacherExamGradesNoStudents =>
      'No students targeted.\nEdit the exam to add an audience.';

  @override
  String get teacherExamGradesEnterGrades => 'Enter grades';

  @override
  String get teacherDeleteExamTitle => 'Delete exam?';

  @override
  String get teacherDeleteExamBody => 'This will permanently delete the exam.';

  @override
  String get teacherMeetingsEmpty => 'No meetings yet.\nTap + to schedule one.';

  @override
  String get teacherStudentsNoMatch => 'No students match';

  @override
  String get teacherMaterialsTitle => 'Materials';

  @override
  String get profileNamesTitle => 'Name in languages';

  @override
  String get profileDisplayNameLang => 'Display name language';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navPeople => 'People';

  @override
  String get navCohorts => 'Cohorts';

  @override
  String get navSchool => 'School';

  @override
  String get adminDashboardTitle => 'School Overview';

  @override
  String get adminStudents => 'Students';

  @override
  String get adminTeachers => 'Teachers';

  @override
  String get adminParents => 'Parents';

  @override
  String get adminSecretaries => 'Secretaries';

  @override
  String get adminTodaySessions => 'Today\'s sessions';

  @override
  String get adminQuickActions => 'Quick Actions';

  @override
  String get adminAttendanceLast30 => 'Attendance — Last 30 Days';

  @override
  String get adminNoAttendanceData =>
      'No attendance data for the last 30 days.';

  @override
  String get adminAddUser => 'Add User';

  @override
  String get adminCreateUser => 'Create';

  @override
  String get adminFullName => 'Full Name';

  @override
  String get adminEmailAddress => 'Email address';

  @override
  String get adminRoleLabel => 'Role';

  @override
  String get adminUserCreated => 'User Created';

  @override
  String get adminTempPassword => 'Temporary password';

  @override
  String get adminCopied => 'Copied to clipboard';

  @override
  String get adminResetPassword => 'Reset Password';

  @override
  String get adminPasswordReset => 'Password Reset';

  @override
  String adminTempPasswordFor(Object name) {
    return 'Temporary password for $name';
  }

  @override
  String get adminDeleteUser => 'Delete User';

  @override
  String adminDeleteUserConfirm(Object name) {
    return 'Delete $name? This cannot be undone.';
  }

  @override
  String get adminDeleteCohort => 'Delete Cohort';

  @override
  String adminDeleteCohortConfirm(Object name) {
    return 'Delete \"$name\"? All student memberships will be removed.';
  }

  @override
  String get adminAddCohort => 'Add Cohort';

  @override
  String get adminNewCohort => 'New Cohort';

  @override
  String get adminCohortName => 'Cohort Name (e.g. 10th-2)';

  @override
  String get adminCohortGrade => 'Grade';

  @override
  String get adminRenameCohort => 'Rename';

  @override
  String get adminAddStudents => 'Add Students';

  @override
  String adminAddTo(Object name) {
    return 'Add to $name';
  }

  @override
  String get adminRemoveStudent => 'Remove Student';

  @override
  String adminRemoveStudentConfirm(Object name, Object cohort) {
    return 'Remove $name from $cohort?';
  }

  @override
  String get adminNoCohortsYet => 'No cohorts yet';

  @override
  String get adminNoStudentsInCohort => 'No students in this cohort';

  @override
  String adminStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students',
      one: '1 student',
    );
    return '$_temp0';
  }

  @override
  String get adminSearchStudents => 'Search students…';

  @override
  String get adminScheduleTitle => 'Schedule';

  @override
  String get adminScheduleAddPeriod => 'Add Period';

  @override
  String get adminScheduleNewPeriod => 'New Period';

  @override
  String get adminScheduleDayLabel => 'Day';

  @override
  String adminSchedulePeriodLabel(Object period) {
    return 'P$period';
  }

  @override
  String get adminScheduleTeacherLabel => 'Teacher';

  @override
  String get adminScheduleNoneTeacher => 'No teacher assigned';

  @override
  String get adminScheduleCohortLabel => 'Cohort / Students';

  @override
  String get adminScheduleFrequencyLabel => 'Frequency';

  @override
  String get adminScheduleFreqWeekly => 'Every week';

  @override
  String get adminScheduleFreqBiweekly => 'Every 2 weeks';

  @override
  String get adminScheduleFreqMonthly => 'Every 4 weeks';

  @override
  String get adminScheduleFreqCustom => 'Custom';

  @override
  String adminScheduleFreqCustomLabel(int n) {
    return 'Every $n weeks';
  }

  @override
  String get adminScheduleAddSlot => 'Add Slot';

  @override
  String get adminScheduleAddAnother => 'Add another day / period';

  @override
  String get adminScheduleSave => 'Save';

  @override
  String get adminScheduleSearchTeacher => 'Search teachers…';

  @override
  String get adminScheduleSearchCohort => 'Search cohorts…';

  @override
  String get adminScheduleSelectTeacher => 'Select teacher';

  @override
  String get adminScheduleSelectCohort => 'Select cohort';

  @override
  String get adminScheduleOrStudents => 'Or pick individual students';

  @override
  String get adminScheduleNoSlots => 'No periods yet';

  @override
  String get adminScheduleNoSlotsHint => 'Tap + to add the first period';

  @override
  String get adminSchoolSettingsTitle => 'School Settings';

  @override
  String get adminSchoolName => 'School Name';

  @override
  String get adminSchoolLogoUrl => 'Logo URL (optional)';

  @override
  String get adminSchoolLogoHint => 'https://…';

  @override
  String get adminSchoolSaved => 'Saved';

  @override
  String get adminSubjectsTitle => 'Subjects';

  @override
  String adminSubjectsGrade(int grade) {
    return 'Grade $grade';
  }

  @override
  String get adminSubjectsAddHint => 'Add subject…';

  @override
  String get adminSubjectsNoSubjects => 'No subjects configured';

  @override
  String get adminSubjectsAdd => 'Add';

  @override
  String get adminSubjectsRemove => 'Remove';

  @override
  String get adminSettingsTitle => 'Settings';

  @override
  String get adminSettingsBellSchedule => 'Bell Schedule';

  @override
  String get adminSettingsPeriodDefaults => 'Period Defaults';

  @override
  String get adminSettingsPeriodDefaultsSubtitle =>
      'Set bell times for each period';

  @override
  String get adminDeleteConfirmCancel => 'Cancel';

  @override
  String get adminDeleteConfirmDelete => 'Delete';

  @override
  String get adminSave => 'Save';

  @override
  String get adminCancel => 'Cancel';

  @override
  String get adminSearchPeople => 'Search by name…';

  @override
  String adminNoResults(Object query) {
    return 'No results for \"$query\"';
  }

  @override
  String adminNoPeopleYet(Object role) {
    return 'No $role yet';
  }

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonBack => 'Back';

  @override
  String get commonClose => 'Close';

  @override
  String get commonDownload => 'Download';

  @override
  String get commonOpenExternally => 'Open externally';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDone => 'Done';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonSearch => 'Search…';

  @override
  String get commonShare => 'Share';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get commonError => 'Something went wrong';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get studentMaterialsTitle => 'Materials';

  @override
  String get studentMaterialsEmptyTitle => 'No materials shared yet';

  @override
  String get studentMaterialsEmptyHint =>
      'Your teacher will share resources here.';

  @override
  String get studentMaterialsLoadError => 'Could not load materials';

  @override
  String get studentAssignmentSubmittedSnackbar => 'Assignment handed in!';

  @override
  String get studentAssignmentSubmitFailed =>
      'Could not submit — please try again.';

  @override
  String get studentAssignmentUploadFailed =>
      'File upload failed — please try again.';

  @override
  String get studentAssignmentHandedInBadge => 'Handed in';

  @override
  String get studentAssignmentSubmitButton => 'Hand in';

  @override
  String get studentAssignmentSubmitting => 'Handing in…';

  @override
  String get studentAssignmentAttachFile => 'Attach file';

  @override
  String get studentAssignmentAddMoreFiles => 'Add more files';

  @override
  String get studentAssignmentYourSubmission => 'Your submission';

  @override
  String get studentAssignmentTeacherAttachments => 'Attachments';

  @override
  String secretaryWelcomeGreeting(Object name) {
    return 'Hi $name 👋';
  }

  @override
  String get secretaryYourTools => 'Your tools';

  @override
  String get secretaryReports => 'Reports';

  @override
  String get secretaryExportData => 'Export Data';

  @override
  String get secretaryHomeTile => 'Home';

  @override
  String parentHomeGreeting(Object name) {
    return 'Hi $name 👋';
  }

  @override
  String get parentYourTools => 'Your tools';

  @override
  String get parentNoChildLinked => 'No child linked yet';

  @override
  String get parentPickChildFirst => 'Pick a child first';

  @override
  String get parentNoApprovedChildren =>
      'No approved children yet. Ask your school to link your account.';

  @override
  String get loginEmptyFieldsError =>
      'Please enter your email or username and password.';

  @override
  String get loginConnectionError =>
      'No connection. Check your internet and try again.';

  @override
  String get loginTimeoutError => 'Request timed out. Please try again.';

  @override
  String get loginForgotPasswordLink => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordModeEmail => 'Email';

  @override
  String get forgotPasswordModeSms => 'SMS';

  @override
  String get forgotPasswordModeAdmin => 'Admin';

  @override
  String get forgotPasswordEmailSent =>
      'Reset link sent (if an account matches).';

  @override
  String get forgotPasswordEmptyError =>
      'Enter your email or username to continue.';

  @override
  String get forgotPasswordEmailButton => 'Email me a reset link';

  @override
  String get forgotPasswordSmsButton => 'Text me a reset link';

  @override
  String get forgotPasswordLinkExpires =>
      'The link expires in 1 hour and can only be used once.';

  @override
  String get pushPermissionTitle => 'Stay in the loop';

  @override
  String get pushPermissionBody =>
      'Turn on notifications so you don\'t miss grades, messages, or schedule changes.';

  @override
  String commonRequiredField(Object field) {
    return '$field required';
  }

  @override
  String get commonAttachments => 'Attachments';

  @override
  String get commonAttachFile => 'Attach file';

  @override
  String get commonReplaceFile => 'Replace file';

  @override
  String get commonTitleRequired => 'Title required';

  @override
  String get commonPublish => 'Publish';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonNext => 'Next';

  @override
  String get commonStart => 'Start';

  @override
  String get commonEnd => 'End';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonRemove => 'Remove';

  @override
  String get commonOpen => 'Open';

  @override
  String get commonView => 'View';

  @override
  String get commonCopy => 'Copy';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonOptional => 'Optional';

  @override
  String get commonRequired => 'Required';

  @override
  String get commonAuto => 'Auto';

  @override
  String get teacherShareButton => 'Share';

  @override
  String get teacherMaterialDetails => 'Material Details';

  @override
  String get teacherMaterialTitleLabel => 'Title *';

  @override
  String get teacherMaterialDescriptionLabel => 'Description (optional)';

  @override
  String get teacherMaterialContentSection => 'Content';

  @override
  String get teacherMaterialContentRequired =>
      'Please attach a file or add a link';

  @override
  String teacherFilePickError(Object error) {
    return 'Could not pick file: $error';
  }

  @override
  String get teacherScheduleButton => 'Schedule';

  @override
  String get teacherMeetingTitleField => 'Meeting title *';

  @override
  String get teacherMeetingLinkField => 'Meeting link *';

  @override
  String get teacherMeetingLinkRequired => 'Meeting link required';

  @override
  String get teacherMeetingTitleRequired => 'Meeting title required';

  @override
  String get teacherMeetingDateTimeRequired => 'Start date and time required';

  @override
  String get teacherMeetingStartDate => 'Start date *';

  @override
  String get teacherMeetingStartTime => 'Start time *';

  @override
  String get teacherMeetingEndDate => 'End date (optional)';

  @override
  String get teacherMeetingEndTime => 'End time (optional)';

  @override
  String get teacherClearEndTime => 'Clear end time';

  @override
  String get teacherAssignmentTitleField => 'Title *';

  @override
  String get teacherAssignmentInstructions => 'Instructions (optional)';

  @override
  String get teacherAssignmentDueDate => 'Due date (optional)';

  @override
  String get teacherAssignmentClearDueDate => 'Clear due date';

  @override
  String get teacherAssignmentMaxGrade => 'Max grade (optional)';

  @override
  String get teacherAssignmentPublished => 'Assignment published.';

  @override
  String get teacherAssignmentDraftSaved => 'Draft saved.';

  @override
  String get teacherCreateAssignment => 'Create';

  @override
  String get teacherExamSubject => 'Subject *';

  @override
  String get teacherExamDate => 'Exam date *';

  @override
  String get teacherSelectSubject => 'Select subject';

  @override
  String get teacherNoSubjectOption => 'No subject';

  @override
  String get teacherOtherSubjectOption => 'Other';

  @override
  String get teacherSearchClassrooms => 'Search classrooms…';

  @override
  String get teacherSearchMaterials => 'Search materials…';

  @override
  String get teacherClassroomName => 'Classroom name *';

  @override
  String get adminReportsOpenTab => 'Open';

  @override
  String get adminReportsResolvedTab => 'Resolved';

  @override
  String get adminReportsDismissedTab => 'Dismissed';

  @override
  String get adminReportsNoOpen => 'No open reports';

  @override
  String get adminReportsNoInView => 'No reports in this view';

  @override
  String get adminReportsMediaAttachment => '[Media attachment]';

  @override
  String get adminReportsEmptyMessage => '(empty message)';

  @override
  String get adminReportsDismiss => 'Dismiss';

  @override
  String get adminReportsResolve => 'Resolve';

  @override
  String adminReportsReason(Object reason) {
    return 'Reason: $reason';
  }

  @override
  String get chatReportTitle => 'Report message';

  @override
  String get chatReportButton => 'Report';

  @override
  String get chatReportSuccess => 'Reported. Thank you — an admin will review.';

  @override
  String chatReportFailed(Object error) {
    return 'Report failed: $error';
  }

  @override
  String chatSendError(Object message) {
    return 'Couldn\'t send: $message';
  }

  @override
  String chatForwardLabel(Object count) {
    return 'Forward $count';
  }

  @override
  String chatDeleteLabel(Object count) {
    return 'Delete $count';
  }

  @override
  String chatSelectedCount(Object count) {
    return '$count selected';
  }

  @override
  String get adminPasswordReqEmpty => 'No pending requests';

  @override
  String get adminPasswordReqExplainer =>
      'Users you have approved or rejected won\'t appear here. Pending requests expire after 24 hours.';

  @override
  String get adminPasswordReqApproveTitle => 'Approve password change?';

  @override
  String adminPasswordReqApproveExplain(Object name) {
    return 'This sets $name\'s password to the one they typed (you don\'t see it).';
  }

  @override
  String adminPasswordReqVerifyWarning(Object name) {
    return 'Only approve if you have verified the requester is really $name — call them, or confirm in person. Anyone who knows a username can file this request.';
  }

  @override
  String get adminPasswordReqConfirmApprove => 'I verified — approve';

  @override
  String adminPasswordReqApproveSnackbar(Object name) {
    return 'Approved — $name can sign in now.';
  }

  @override
  String get adminPasswordReqRejectTitle => 'Reject password change?';

  @override
  String adminPasswordReqRejectExplain(Object name) {
    return '$name\'s password won\'t change. They can submit a new request if needed.';
  }

  @override
  String get adminPasswordReqRejectSnackbar => 'Rejected.';

  @override
  String get adminPasswordReqRejectButton => 'Reject';

  @override
  String get adminPasswordReqApproveButton => 'Approve';

  @override
  String get adminPasswordReqCardCopy =>
      'Wants their password changed. The new password is hidden.';

  @override
  String get adminPasswordReqCallTooltip => 'Call';

  @override
  String get adminPasswordReqSmsTooltip => 'SMS';

  @override
  String get adminSetupSchoolSetup => 'School Setup';

  @override
  String get adminSetupComplete =>
      'You\'re all set. Tap any item to revisit or refine it.';

  @override
  String get adminSetupInstructions =>
      'Complete these steps to fully set up your school.';

  @override
  String get adminSetupLogoTitle => 'Upload school logo';

  @override
  String get adminSetupLogoSubtitle => 'Appears in headers and the drawer';

  @override
  String get adminSetupNameTitle => 'Set school name';

  @override
  String get adminSetupNameSubtitle =>
      'Shown to students, teachers, and parents';

  @override
  String get adminSetupSubjectsTitle => 'Define subjects';

  @override
  String get adminSetupSubjectsSubtitle =>
      'At least one grade with subjects configured';

  @override
  String get adminSetupBellTitle => 'Set bell schedule';

  @override
  String get adminSetupBellSubtitle => 'Start/end times for each period';

  @override
  String get adminSetupCohortsTitle => 'Create cohorts';

  @override
  String get adminSetupCohortsSubtitle => 'Set up your class groups';

  @override
  String get adminSetupStudentsTitle => 'Add students';

  @override
  String get adminSetupStudentsSubtitle =>
      'Create accounts or generate join codes';

  @override
  String get adminSetupTeachersTitle => 'Add teachers';

  @override
  String get adminSetupTeachersSubtitle => 'Create teacher accounts';

  @override
  String get supportContactTitle => 'Talk to us';

  @override
  String get supportContactDescription =>
      'Can\'t find your answer below? Get in touch and we\'ll come back to you within a working day.';

  @override
  String get supportEmailLabel => 'Email';

  @override
  String get supportPhoneLabel => 'Phone';

  @override
  String get supportSmsLabel => 'Message';

  @override
  String get aboutWhatIsClassmate => 'What is ClassMate?';

  @override
  String get aboutClassmateDescription =>
      'ClassMate is the school operating system for students, teachers, administrators, and parents. One app, four roles, every part of the school day in a single place — schedule, attendance, grades, classrooms, assignments, messaging, and an AI study buddy.';

  @override
  String get aboutMultilingualTitle =>
      'Built for schools that speak more than one language';

  @override
  String get aboutMultilingualDescription =>
      'Every name, subject, and announcement can carry up to five language variants (English, Arabic, Hebrew, French, Russian). Students see the language they\'re most comfortable with; teachers manage in theirs.';

  @override
  String get aboutPrivacyTitle => 'Privacy first';

  @override
  String get aboutPrivacyDescription =>
      'School data stays inside the school. Roles map cleanly onto what each person can see — teachers see their classrooms, admins see their school, parents see their children. No third-party trackers, no ad networks.';

  @override
  String get aboutContactTitle => 'Contact';

  @override
  String get aboutContactDescription =>
      'Built by Tony Aboud and the ClassMate team.\nQuestions: tony@classmateapp.org';

  @override
  String aboutVersionLabel(Object version) {
    return 'ClassMate · v$version';
  }

  @override
  String get adminAddStudent => 'Add student';

  @override
  String get adminAddTeacher => 'Add teacher';

  @override
  String get adminAddParent => 'Add parent';

  @override
  String get adminAddSecretary => 'Add secretary';

  @override
  String get adminAddAdmin => 'Add admin';

  @override
  String get adminEditUser => 'Edit user';

  @override
  String get adminNoEmailPlaceholder => '(no email)';

  @override
  String get adminNameEnglishRequired => 'Full name (English) is required';

  @override
  String get adminUsernameRequired => 'Username is required';

  @override
  String get adminPasswordMinLength =>
      'Password must be at least 8 characters (or leave blank to auto-generate)';

  @override
  String adminUserCreatedMsg(Object name) {
    return '$name created.';
  }

  @override
  String get adminCredsUsername => 'Username';

  @override
  String get adminCredsEmail => 'Email';

  @override
  String get adminCredsPassword => 'Password';

  @override
  String get adminShareCredsHint => 'Share these credentials with the student.';

  @override
  String get adminCopyCredsButton => 'Copy All';

  @override
  String get adminGradeLabel => 'Grade';

  @override
  String adminCohortGradeFormat(Object grade) {
    return 'Grade $grade';
  }

  @override
  String get adminCreateAndAddStudents => 'Create & Add Students';

  @override
  String get adminAddStudentsTitle => 'Add Students';

  @override
  String get adminSkipAdding => 'Skip';

  @override
  String get adminInCohortBadge => 'In cohort';

  @override
  String get adminNoStudentsFoundCohort =>
      'No students found in this cohort\'s grades';

  @override
  String get adminScheduleByCohort => 'By Cohort ▾';

  @override
  String get adminScheduleByStudent => 'By Student ▾';

  @override
  String get adminScheduleAddGrade => 'Add grade';

  @override
  String get adminScheduleAddCohort => 'Add cohort';

  @override
  String get adminScheduleAddStudent => 'Add student';

  @override
  String get adminScheduleClearFilters => 'Clear';

  @override
  String get adminSchedulePickSubjectRequired =>
      'Pick a subject before saving the period.';

  @override
  String get adminSchedulePickDateOnce => 'Pick a date for a one-off period.';

  @override
  String adminSchedulePickDateRecurring(Object freq) {
    return 'Pick a start date for the every-$freq-weeks schedule.';
  }

  @override
  String get adminSchoolLogoLabel => 'School Logo';

  @override
  String get adminSchoolLogoUploaded => 'Logo uploaded';

  @override
  String get adminSchoolNoLogoYet => 'No logo yet';

  @override
  String get adminSchoolLogoDescription =>
      'Appears next to your school name in the app drawer.';

  @override
  String get adminSchoolLogoChange => 'Change';

  @override
  String get adminSchoolLogoUpload => 'Upload';

  @override
  String get adminSchoolLogoRemove => 'Remove';

  @override
  String get adminSchoolGradeRangeLabel => 'Grade range';

  @override
  String get adminSchoolGradeRangeDescription =>
      'Grades available across cohorts, students, and pickers.';

  @override
  String get adminSchoolLowestGrade => 'Lowest';

  @override
  String get adminSchoolHighestGrade => 'Highest';

  @override
  String get adminSchoolSubjectsTitle => 'School Subjects';

  @override
  String get adminSchoolSubjectsDescription =>
      'Available to all teachers when creating assignments.';

  @override
  String get adminSchoolNoTranslations => 'Tap to add translations';

  @override
  String get adminSchoolBellHint =>
      'Set start and end times for each period. Add or remove periods as needed.';

  @override
  String get adminSchoolBellInfo =>
      'Set the start and end time for each period. These become the default times used when building the weekly schedule.';

  @override
  String get adminSchoolStartTime => 'Start';

  @override
  String get adminSchoolEndTime => 'End';

  @override
  String get adminExportStudentsTab => 'Students';

  @override
  String get adminExportCohortsTab => 'Cohorts';

  @override
  String get adminExportGradesTab => 'Grades';

  @override
  String get adminExportOptionsTitle => 'Export Options';

  @override
  String get adminExportIncludePasswords => 'Include Passwords';

  @override
  String get adminExportCsvButton => 'Export CSV';

  @override
  String get adminExportPdfButton => 'Export PDF';

  @override
  String get teacherCreateClassroomTooltip => 'Create classroom';

  @override
  String get teacherClassroomNameRequired => 'Classroom name *';

  @override
  String get teacherSubjectRequired => 'Subject *';

  @override
  String messagesStartChatError(Object error) {
    return 'Could not start chat: $error';
  }

  @override
  String messagesNoPeopleMatch(Object query) {
    return 'No people match \"$query\"';
  }

  @override
  String get messagesNoPeopleFound => 'No people found';

  @override
  String messagesPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get studentAssignmentValidationRequired =>
      'Add a note or attach a file before handing in.';

  @override
  String get studentFormSubmittedBanner => 'Your submitted answers';

  @override
  String studentFormSubmitError(Object error) {
    return 'Could not submit: $error';
  }

  @override
  String studentFormFieldRequired(Object field) {
    return 'Required: $field';
  }

  @override
  String get studentFormClosedButton => 'Form closed';

  @override
  String get studentFormAlreadySubmittedButton => 'Already submitted';

  @override
  String get studentDiplomaEditTitle => 'Edit Certificate';

  @override
  String get studentDiplomaDeleteTitle => 'Delete certificate?';

  @override
  String studentDiplomaDeleteConfirm(Object name) {
    return 'Remove certificate for \"$name\"?';
  }

  @override
  String teacherDeleteItemConfirm(Object title) {
    return 'Delete \"$title\"?';
  }

  @override
  String get teacherPublishTooltip => 'Publish';

  @override
  String get teacherMeetingEnterTitle => 'Please enter a title.';

  @override
  String get teacherMeetingEnterLink => 'Please enter a meeting link.';

  @override
  String get teacherMeetingEnterValidUrl =>
      'Please enter a valid URL (e.g. https://zoom.us/j/...)';

  @override
  String get teacherMeetingPickStartTime => 'Please pick a start time.';

  @override
  String get teacherMeetingVisibleToEveryone => 'Visible to everyone';

  @override
  String teacherMeetingDoneCount(int count) {
    return 'Done ($count selected)';
  }

  @override
  String get teacherDeleteAssignmentTitle => 'Delete assignment?';

  @override
  String get teacherDeleteAssignmentBody =>
      'This will permanently delete the assignment and all submissions.';

  @override
  String get teacherEditTooltip => 'Edit';

  @override
  String get teacherDeleteTooltip => 'Delete';

  @override
  String get teacherClassroomBackTooltip => 'Back';

  @override
  String teacherClassroomGenericError(Object error) {
    return 'Error: $error';
  }

  @override
  String teacherClassroomAttachFailed(Object error) {
    return 'Attach failed: $error';
  }

  @override
  String get teacherClassroomFileUnavailable =>
      'This file is not available — the teacher should re-upload it.';

  @override
  String get teacherClassroomCodeLabel => 'Classroom code';

  @override
  String get teacherClassroomCodeCopied => 'Code copied';

  @override
  String get teacherClassroomCopyCodeTooltip => 'Copy code';

  @override
  String teacherClassroomCouldNotAdd(Object emails) {
    return 'Could not add: $emails — check their email address.';
  }

  @override
  String get teacherClassroomAddStudents => 'Add students';

  @override
  String get teacherClassroomSearchNameGrade => 'Search by name or grade…';

  @override
  String get teacherClassroomNoStudentsFound => 'No students found';

  @override
  String get teacherClassroomNameSubjectRequired =>
      'Name and subject are required.';

  @override
  String get teacherClassroomCreated => 'Classroom created!';

  @override
  String get teacherCustomSubjectLabel => 'Custom subject *';

  @override
  String get teacherCreateClassroomButton => 'Create Classroom';

  @override
  String get teacherCreateFormTitle => 'Create Form';

  @override
  String get teacherFormSaveDraft => 'Save Draft';

  @override
  String get teacherFormTitleHint => 'Form title *';

  @override
  String get teacherFormDescriptionHint => 'Description (optional)';

  @override
  String get teacherFormAcceptingResponses => 'Accepting responses';

  @override
  String get teacherFormAllowMultiple => 'Allow multiple responses';

  @override
  String get teacherFormAllowMultipleSubtitle =>
      'Off = once per student (default)';

  @override
  String get teacherFormQuestionsSection => 'Questions';

  @override
  String get teacherFormAddQuestionButton => 'Add question';

  @override
  String teacherFormQuestionPlaceholder(Object index) {
    return 'Question $index';
  }

  @override
  String get teacherFormRequiredToggle => 'Required';

  @override
  String get teacherFormAddOptionButton => 'Add option';

  @override
  String get teacherFormMinLabel => 'Min';

  @override
  String get teacherFormMaxLabel => 'Max';

  @override
  String get teacherFormEnterTitle => 'Please enter a form title.';

  @override
  String teacherExamUploadFailedSkipped(Object name) {
    return 'Upload failed for $name. File skipped.';
  }

  @override
  String get teacherExamEnterTitle => 'Please enter a title.';

  @override
  String get teacherExamPickDate => 'Please pick an exam date.';

  @override
  String get teacherExamSelectSubject => 'Please select a subject.';

  @override
  String teacherSlotDetachFailed(Object error) {
    return 'Detach failed: $error';
  }

  @override
  String teacherSlotAttachFailed(Object error) {
    return 'Attach failed: $error';
  }

  @override
  String get teacherSlotAttachMaterial => 'Attach material';

  @override
  String get teacherSlotDetachTooltip => 'Detach';

  @override
  String get teacherDiplomaSelectStudent => 'Select a student first.';

  @override
  String get teacherDiplomaUploadingWait =>
      'Please wait — files are still uploading.';

  @override
  String teacherDiplomaIssueFailed(Object error) {
    return 'Failed to issue certificate: $error';
  }

  @override
  String get teacherDiplomaCertTitleLabel => 'Certificate title';

  @override
  String get teacherDiplomaSearchStudent => 'Search student…';

  @override
  String get teacherProfileChatError => 'Could not start chat';

  @override
  String get teacherGradeAssignmentType => 'Assignment';

  @override
  String get teacherGradeExamType => 'Exam';

  @override
  String get teacherGradeOtherType => 'Other';

  @override
  String get teacherGradeOutOfLabel => 'Out of (optional)';

  @override
  String get teacherGradePublishedTitle => 'Published';

  @override
  String get teacherGradePublishedSubtitle => 'Students can see this grade';

  @override
  String get teacherMaterialPickSubject => 'Please select a subject.';

  @override
  String get teacherMaterialAddLink => 'Add link';

  @override
  String get teacherMaterialAddFile => 'Add file';

  @override
  String get teacherMaterialSearchStudentsGrade =>
      'Search students or grade...';

  @override
  String teacherMaterialDoneSelected(int count) {
    return 'Done ($count selected)';
  }
}

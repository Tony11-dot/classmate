import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('he'),
    Locale('pt'),
    Locale('ru'),
    Locale('tr'),
  ];

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @sectionCore.
  ///
  /// In en, this message translates to:
  /// **'Core'**
  String get sectionCore;

  /// No description provided for @sectionSchoolTools.
  ///
  /// In en, this message translates to:
  /// **'School Tools'**
  String get sectionSchoolTools;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @navSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navSchedule;

  /// No description provided for @navClassrooms.
  ///
  /// In en, this message translates to:
  /// **'Classrooms'**
  String get navClassrooms;

  /// No description provided for @navPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get navPractice;

  /// No description provided for @navInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get navInsights;

  /// No description provided for @navNova.
  ///
  /// In en, this message translates to:
  /// **'NOVA'**
  String get navNova;

  /// No description provided for @navMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// No description provided for @navAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get navAttendance;

  /// No description provided for @navGrades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get navGrades;

  /// No description provided for @navAssignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get navAssignments;

  /// No description provided for @navMeetings.
  ///
  /// In en, this message translates to:
  /// **'Meetings'**
  String get navMeetings;

  /// No description provided for @navAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get navAnnouncements;

  /// No description provided for @navNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// No description provided for @navSolutions.
  ///
  /// In en, this message translates to:
  /// **'Solutions'**
  String get navSolutions;

  /// No description provided for @navExams.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get navExams;

  /// No description provided for @navForms.
  ///
  /// In en, this message translates to:
  /// **'Forms'**
  String get navForms;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTeacherWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Teacher Workspace'**
  String get navTeacherWorkspace;

  /// No description provided for @navTeacherAssessments.
  ///
  /// In en, this message translates to:
  /// **'Assessments & Grades'**
  String get navTeacherAssessments;

  /// No description provided for @navSavedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Saved Questions'**
  String get navSavedQuestions;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get navLogout;

  /// No description provided for @roleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get roleTeacher;

  /// No description provided for @roleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleAdmin;

  /// No description provided for @roleSecretary.
  ///
  /// In en, this message translates to:
  /// **'Secretary'**
  String get roleSecretary;

  /// No description provided for @roleParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get roleParent;

  /// No description provided for @titleSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get titleSchedule;

  /// No description provided for @titleClasses.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get titleClasses;

  /// No description provided for @titlePractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get titlePractice;

  /// No description provided for @titleInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get titleInsights;

  /// No description provided for @titleNova.
  ///
  /// In en, this message translates to:
  /// **'NOVA'**
  String get titleNova;

  /// No description provided for @titleMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get titleMessages;

  /// No description provided for @titleSolutions.
  ///
  /// In en, this message translates to:
  /// **'Solutions'**
  String get titleSolutions;

  /// No description provided for @titleExams.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get titleExams;

  /// No description provided for @solutionsUploadAction.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get solutionsUploadAction;

  /// No description provided for @solutionsNoSubjectsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No subjects available.'**
  String get solutionsNoSubjectsAvailable;

  /// No description provided for @solutionsNoSubjectsMatch.
  ///
  /// In en, this message translates to:
  /// **'No subjects match \"{query}\".'**
  String solutionsNoSubjectsMatch(Object query);

  /// No description provided for @solutionsBookCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 book} other{{count} books}}'**
  String solutionsBookCount(int count);

  /// No description provided for @solutionsBooksTitle.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get solutionsBooksTitle;

  /// No description provided for @solutionsAddBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a book'**
  String get solutionsAddBookTitle;

  /// No description provided for @solutionsBookTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Book title...'**
  String get solutionsBookTitleHint;

  /// No description provided for @solutionsAddBookAction.
  ///
  /// In en, this message translates to:
  /// **'Add a book'**
  String get solutionsAddBookAction;

  /// No description provided for @solutionsSearchBooks.
  ///
  /// In en, this message translates to:
  /// **'Search books'**
  String get solutionsSearchBooks;

  /// No description provided for @solutionsChooseSubjectFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a subject first.'**
  String get solutionsChooseSubjectFirst;

  /// No description provided for @solutionsNoBooksYetBody.
  ///
  /// In en, this message translates to:
  /// **'No books yet.\nTap \"{action}\" to add the first one.'**
  String solutionsNoBooksYetBody(Object action);

  /// No description provided for @solutionsNoBooksMatch.
  ///
  /// In en, this message translates to:
  /// **'No books match \"{query}\".'**
  String solutionsNoBooksMatch(Object query);

  /// No description provided for @solutionsBookLabel.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get solutionsBookLabel;

  /// No description provided for @solutionsPagesFilterHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a page and question number to filter, or leave blank to see all.'**
  String get solutionsPagesFilterHint;

  /// No description provided for @solutionsPageNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Page number'**
  String get solutionsPageNumberLabel;

  /// No description provided for @solutionsPageNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 42'**
  String get solutionsPageNumberHint;

  /// No description provided for @solutionsQuestionNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Question number'**
  String get solutionsQuestionNumberLabel;

  /// No description provided for @solutionsQuestionNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 3a or 7'**
  String get solutionsQuestionNumberHint;

  /// No description provided for @solutionsViewSolutionsAction.
  ///
  /// In en, this message translates to:
  /// **'View solutions'**
  String get solutionsViewSolutionsAction;

  /// No description provided for @solutionsPageQuestionSummary.
  ///
  /// In en, this message translates to:
  /// **'Page {page} • Question {question}'**
  String solutionsPageQuestionSummary(Object page, Object question);

  /// No description provided for @solutionsExactQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Solutions for this exact question'**
  String get solutionsExactQuestionTitle;

  /// No description provided for @solutionsExactQuestionEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing has been uploaded for this exact question yet. Be the first to help your classmates.'**
  String get solutionsExactQuestionEmptySubtitle;

  /// No description provided for @solutionsUploadsFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 upload found} other{{count} uploads found}}'**
  String solutionsUploadsFound(int count);

  /// No description provided for @solutionsExactQuestionEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No exact match yet. You can upload one now, or check what classmates solved on this same page.'**
  String get solutionsExactQuestionEmptyBody;

  /// No description provided for @solutionsLoadMoreAction.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get solutionsLoadMoreAction;

  /// No description provided for @solutionsSamePageTitle.
  ///
  /// In en, this message translates to:
  /// **'Other questions solved on this page'**
  String get solutionsSamePageTitle;

  /// No description provided for @solutionsSamePageEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No neighboring questions were uploaded from this page yet.'**
  String get solutionsSamePageEmptySubtitle;

  /// No description provided for @solutionsSamePageFallbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Useful fallback when your exact question has no upload yet.'**
  String get solutionsSamePageFallbackSubtitle;

  /// No description provided for @solutionsSamePageEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'No nearby uploads on this page yet. A fresh upload here would really help.'**
  String get solutionsSamePageEmptyBody;

  /// No description provided for @solutionsVerifiedByNova.
  ///
  /// In en, this message translates to:
  /// **'Verified by NOVA'**
  String get solutionsVerifiedByNova;

  /// No description provided for @solutionsUploadFileLimitReached.
  ///
  /// In en, this message translates to:
  /// **'10-file limit reached.'**
  String get solutionsUploadFileLimitReached;

  /// No description provided for @solutionsUploadFilesAddedLimit.
  ///
  /// In en, this message translates to:
  /// **'Added {count} — 10-file limit.'**
  String solutionsUploadFilesAddedLimit(int count);

  /// No description provided for @solutionsUploadCompleteFields.
  ///
  /// In en, this message translates to:
  /// **'Complete subject, book, page, and question.'**
  String get solutionsUploadCompleteFields;

  /// No description provided for @solutionsUploadAddOneFile.
  ///
  /// In en, this message translates to:
  /// **'Add at least one image or PDF.'**
  String get solutionsUploadAddOneFile;

  /// No description provided for @solutionsUploadFileFailed.
  ///
  /// In en, this message translates to:
  /// **'File upload failed: {error}'**
  String solutionsUploadFileFailed(Object error);

  /// No description provided for @solutionsUploadCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create solution: {error}'**
  String solutionsUploadCreateFailed(Object error);

  /// No description provided for @solutionsUploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Solution uploaded!'**
  String get solutionsUploadSuccess;

  /// No description provided for @solutionsUploadAddNewBookOption.
  ///
  /// In en, this message translates to:
  /// **'+ Add a new book...'**
  String get solutionsUploadAddNewBookOption;

  /// No description provided for @solutionsUploadAddBookShortAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get solutionsUploadAddBookShortAction;

  /// No description provided for @solutionsUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload a solution'**
  String get solutionsUploadTitle;

  /// No description provided for @solutionsUploadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Real images or PDFs only. NOVA verification and moderation are applied after upload.'**
  String get solutionsUploadSubtitle;

  /// No description provided for @solutionsUploadNoBooksAbove.
  ///
  /// In en, this message translates to:
  /// **'No books — add one above'**
  String get solutionsUploadNoBooksAbove;

  /// No description provided for @solutionsUploadCaptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Caption (optional)'**
  String get solutionsUploadCaptionOptional;

  /// No description provided for @solutionsUploadImagesAction.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get solutionsUploadImagesAction;

  /// No description provided for @solutionsUploadPdfAction.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get solutionsUploadPdfAction;

  /// No description provided for @solutionsUploadFileCount.
  ///
  /// In en, this message translates to:
  /// **'{count} / 10 {count, plural, =1{file selected} other{files selected}}'**
  String solutionsUploadFileCount(int count);

  /// No description provided for @solutionsUploadSomeFilesFailed.
  ///
  /// In en, this message translates to:
  /// **'Some files failed to upload.'**
  String get solutionsUploadSomeFilesFailed;

  /// No description provided for @solutionsUploadRetryFailedFiles.
  ///
  /// In en, this message translates to:
  /// **'Retry failed files'**
  String get solutionsUploadRetryFailedFiles;

  /// No description provided for @solutionsUploadSubmittingAction.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get solutionsUploadSubmittingAction;

  /// No description provided for @solutionsUploadSubmitAction.
  ///
  /// In en, this message translates to:
  /// **'Upload solution'**
  String get solutionsUploadSubmitAction;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance, language & account'**
  String get settingsSubtitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsAccentColour.
  ///
  /// In en, this message translates to:
  /// **'Accent colour'**
  String get settingsAccentColour;

  /// No description provided for @settingsAccentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tint used across the whole app'**
  String get settingsAccentSubtitle;

  /// No description provided for @settingsReduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get settingsReduceMotion;

  /// No description provided for @settingsReduceMotionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fewer animations throughout the app'**
  String get settingsReduceMotionSubtitle;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of this device'**
  String get settingsLogoutSubtitle;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguageSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search language...'**
  String get settingsLanguageSearchHint;

  /// No description provided for @teacherWorkspaceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Run attendance, rosters, and grading from the mobile app.'**
  String get teacherWorkspaceSubtitle;

  /// No description provided for @teacherMetricSessionsToday.
  ///
  /// In en, this message translates to:
  /// **'Sessions today'**
  String get teacherMetricSessionsToday;

  /// No description provided for @teacherMetricTeachingGroups.
  ///
  /// In en, this message translates to:
  /// **'Teaching groups'**
  String get teacherMetricTeachingGroups;

  /// No description provided for @teacherMetricAssessments.
  ///
  /// In en, this message translates to:
  /// **'Assessments'**
  String get teacherMetricAssessments;

  /// No description provided for @teacherQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get teacherQuickActions;

  /// No description provided for @teacherNoDateAvailable.
  ///
  /// In en, this message translates to:
  /// **'No date available'**
  String get teacherNoDateAvailable;

  /// No description provided for @teacherNoTeachingSlotsToday.
  ///
  /// In en, this message translates to:
  /// **'No teaching slots scheduled today.'**
  String get teacherNoTeachingSlotsToday;

  /// No description provided for @teacherUpcomingAssessments.
  ///
  /// In en, this message translates to:
  /// **'Upcoming assessments'**
  String get teacherUpcomingAssessments;

  /// No description provided for @teacherUpcomingAssessmentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live from the teacher grading system'**
  String get teacherUpcomingAssessmentsSubtitle;

  /// No description provided for @teacherNoAssessmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No assessments created yet.'**
  String get teacherNoAssessmentsYet;

  /// No description provided for @teacherUnassignedSlot.
  ///
  /// In en, this message translates to:
  /// **'Unassigned slot'**
  String get teacherUnassignedSlot;

  /// No description provided for @teacherNoCohort.
  ///
  /// In en, this message translates to:
  /// **'No cohort'**
  String get teacherNoCohort;

  /// No description provided for @teacherCourseFallback.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get teacherCourseFallback;

  /// No description provided for @teacherPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period {number}'**
  String teacherPeriod(Object number);

  /// No description provided for @teacherLoadErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load teacher workspace'**
  String get teacherLoadErrorTitle;

  /// No description provided for @teacherClassroomsLoadError.
  ///
  /// In en, this message translates to:
  /// **'We could not load classrooms right now. Pull to refresh or try again.'**
  String get teacherClassroomsLoadError;

  /// No description provided for @teacherClassroomsLoadTimeout.
  ///
  /// In en, this message translates to:
  /// **'Classrooms are taking too long to load. Pull to refresh or try again in a moment.'**
  String get teacherClassroomsLoadTimeout;

  /// No description provided for @teacherClassroomsLoadNetwork.
  ///
  /// In en, this message translates to:
  /// **'Classrooms could not connect right now. Check your connection and try again.'**
  String get teacherClassroomsLoadNetwork;

  /// No description provided for @teacherClassroomsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open the roster and generate a live join code for student entry.'**
  String get teacherClassroomsSubtitle;

  /// No description provided for @teacherClassroomsNoCohorts.
  ///
  /// In en, this message translates to:
  /// **'No classroom cohorts are linked to this teacher yet.'**
  String get teacherClassroomsNoCohorts;

  /// No description provided for @teacherClassroomsCohort.
  ///
  /// In en, this message translates to:
  /// **'Cohort {cohortId}'**
  String teacherClassroomsCohort(Object cohortId);

  /// No description provided for @teacherClassroomsGeneratingJoinCode.
  ///
  /// In en, this message translates to:
  /// **'Generating…'**
  String get teacherClassroomsGeneratingJoinCode;

  /// No description provided for @teacherClassroomsCreateJoinCode.
  ///
  /// In en, this message translates to:
  /// **'Create join code'**
  String get teacherClassroomsCreateJoinCode;

  /// No description provided for @teacherClassroomsLiveJoinCode.
  ///
  /// In en, this message translates to:
  /// **'Live join code'**
  String get teacherClassroomsLiveJoinCode;

  /// No description provided for @teacherClassroomsExpiresAt.
  ///
  /// In en, this message translates to:
  /// **'Expires {value}'**
  String teacherClassroomsExpiresAt(Object value);

  /// No description provided for @teacherClassroomsRoster.
  ///
  /// In en, this message translates to:
  /// **'Roster'**
  String get teacherClassroomsRoster;

  /// No description provided for @teacherClassroomsNoStudents.
  ///
  /// In en, this message translates to:
  /// **'No students are enrolled in this classroom yet.'**
  String get teacherClassroomsNoStudents;

  /// No description provided for @teacherAttendanceLoadError.
  ///
  /// In en, this message translates to:
  /// **'We could not load attendance right now. Pull to refresh or try again.'**
  String get teacherAttendanceLoadError;

  /// No description provided for @teacherAttendanceLoadTimeout.
  ///
  /// In en, this message translates to:
  /// **'Attendance is taking too long to load. Pull to refresh or try again in a moment.'**
  String get teacherAttendanceLoadTimeout;

  /// No description provided for @teacherAttendanceLoadNetwork.
  ///
  /// In en, this message translates to:
  /// **'Attendance could not connect right now. Check your connection and try again.'**
  String get teacherAttendanceLoadNetwork;

  /// No description provided for @teacherAttendanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a live session, mark the room, and save only changed rows.'**
  String get teacherAttendanceSubtitle;

  /// No description provided for @teacherAttendanceTodaySessions.
  ///
  /// In en, this message translates to:
  /// **'Today sessions'**
  String get teacherAttendanceTodaySessions;

  /// No description provided for @teacherAttendanceSessionSummary.
  ///
  /// In en, this message translates to:
  /// **'{cohort} • Grade {grade} • {date} • Period {period}'**
  String teacherAttendanceSessionSummary(
    Object cohort,
    Object grade,
    Object date,
    Object period,
  );

  /// No description provided for @teacherAttendanceChanged.
  ///
  /// In en, this message translates to:
  /// **'Changed'**
  String get teacherAttendanceChanged;

  /// No description provided for @teacherAttendanceNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get teacherAttendanceNoteLabel;

  /// No description provided for @teacherAttendanceSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get teacherAttendanceSaving;

  /// No description provided for @teacherAttendanceSaveCount.
  ///
  /// In en, this message translates to:
  /// **'Save {count, plural, =1 {1 change} other {{count} changes}}'**
  String teacherAttendanceSaveCount(int count);

  /// No description provided for @teacherAttendanceSaved.
  ///
  /// In en, this message translates to:
  /// **'Attendance saved'**
  String get teacherAttendanceSaved;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @scheduleRefreshTooFast.
  ///
  /// In en, this message translates to:
  /// **'Schedule is refreshing too fast right now. Wait a moment and try again.'**
  String get scheduleRefreshTooFast;

  /// No description provided for @scheduleNotOnboarded.
  ///
  /// In en, this message translates to:
  /// **'Your student profile is not fully set up yet, so no schedule is available yet.'**
  String get scheduleNotOnboarded;

  /// No description provided for @scheduleLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load schedule yet.'**
  String get scheduleLoadError;

  /// No description provided for @scheduleSelectedDay.
  ///
  /// In en, this message translates to:
  /// **'Selected day'**
  String get scheduleSelectedDay;

  /// No description provided for @scheduleClassCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {0 classes} =1 {1 class} other {{count} classes}}'**
  String scheduleClassCount(num count);

  /// No description provided for @scheduleNextUp.
  ///
  /// In en, this message translates to:
  /// **'Next up'**
  String get scheduleNextUp;

  /// No description provided for @scheduleNoMoreClasses.
  ///
  /// In en, this message translates to:
  /// **'No more classes'**
  String get scheduleNoMoreClasses;

  /// No description provided for @scheduleNoClassesTitle.
  ///
  /// In en, this message translates to:
  /// **'No classes on this day'**
  String get scheduleNoClassesTitle;

  /// No description provided for @scheduleNoClassesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{day} looks clear.'**
  String scheduleNoClassesSubtitle(Object day);

  /// No description provided for @scheduleClassFallback.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get scheduleClassFallback;

  /// No description provided for @scheduleNoSubjectLocation.
  ///
  /// In en, this message translates to:
  /// **'No subject or location yet'**
  String get scheduleNoSubjectLocation;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile login for students and teachers'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Teacher accounts open the teacher workspace. Student accounts stay on the student experience.'**
  String get loginSubtitle;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSignIn;

  /// No description provided for @loginSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get loginSigningIn;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @profileNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get profileNotAvailable;

  /// No description provided for @profileSchoolInfo.
  ///
  /// In en, this message translates to:
  /// **'School info'**
  String get profileSchoolInfo;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileFullName;

  /// No description provided for @profileRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get profileRole;

  /// No description provided for @profileSchoolId.
  ///
  /// In en, this message translates to:
  /// **'School ID'**
  String get profileSchoolId;

  /// No description provided for @profileCohortId.
  ///
  /// In en, this message translates to:
  /// **'Cohort ID'**
  String get profileCohortId;

  /// No description provided for @profileAccountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account info'**
  String get profileAccountInfo;

  /// No description provided for @profileUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get profileUsername;

  /// No description provided for @profileUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'your_username'**
  String get profileUsernameHint;

  /// No description provided for @profileContactEmail.
  ///
  /// In en, this message translates to:
  /// **'Contact email'**
  String get profileContactEmail;

  /// No description provided for @profileEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get profileEmailAddress;

  /// No description provided for @profileEmailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get profileEmailHint;

  /// No description provided for @profileBirthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get profileBirthday;

  /// No description provided for @profileSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get profileSecurity;

  /// No description provided for @profileSelectBirthday.
  ///
  /// In en, this message translates to:
  /// **'Select your birthday'**
  String get profileSelectBirthday;

  /// No description provided for @profilePasswordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get profilePasswordUpdated;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileSave;

  /// No description provided for @profileEmptyValue.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get profileEmptyValue;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get profileChangePassword;

  /// No description provided for @profileCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get profileCurrentPassword;

  /// No description provided for @profileNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get profileNewPassword;

  /// No description provided for @profileConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get profileConfirmNewPassword;

  /// No description provided for @profileUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get profileUpdatePassword;

  /// No description provided for @profilePasswordAllFieldsRequired.
  ///
  /// In en, this message translates to:
  /// **'All fields are required'**
  String get profilePasswordAllFieldsRequired;

  /// No description provided for @profilePasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 8 characters'**
  String get profilePasswordMinLength;

  /// No description provided for @profilePasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get profilePasswordMismatch;

  /// No description provided for @profilePasswordNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Not authenticated'**
  String get profilePasswordNotAuthenticated;

  /// No description provided for @profilePasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect'**
  String get profilePasswordIncorrect;

  /// No description provided for @profilePasswordGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get profilePasswordGenericError;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get editProfileSchool;

  /// No description provided for @editProfileSchoolPublic.
  ///
  /// In en, this message translates to:
  /// **'School public'**
  String get editProfileSchoolPublic;

  /// No description provided for @editProfileGradePublic.
  ///
  /// In en, this message translates to:
  /// **'Grade public'**
  String get editProfileGradePublic;

  /// No description provided for @editProfileMajors.
  ///
  /// In en, this message translates to:
  /// **'Majors'**
  String get editProfileMajors;

  /// No description provided for @editProfileMajorsPublic.
  ///
  /// In en, this message translates to:
  /// **'Majors public'**
  String get editProfileMajorsPublic;

  /// No description provided for @editProfileBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get editProfileBio;

  /// No description provided for @editProfileBioPublic.
  ///
  /// In en, this message translates to:
  /// **'Bio public'**
  String get editProfileBioPublic;

  /// No description provided for @editProfileStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get editProfileStatus;

  /// No description provided for @editProfileStatusPublic.
  ///
  /// In en, this message translates to:
  /// **'Status public'**
  String get editProfileStatusPublic;

  /// No description provided for @classroomsYourClassrooms.
  ///
  /// In en, this message translates to:
  /// **'Your classrooms'**
  String get classroomsYourClassrooms;

  /// No description provided for @classroomsReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder classrooms'**
  String get classroomsReorder;

  /// No description provided for @classroomsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} classrooms'**
  String classroomsCount(Object count);

  /// No description provided for @classroomsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search classrooms'**
  String get classroomsSearchHint;

  /// No description provided for @classroomsNoSearchMatches.
  ///
  /// In en, this message translates to:
  /// **'No classrooms match your search'**
  String get classroomsNoSearchMatches;

  /// No description provided for @classroomsClassroomLabel.
  ///
  /// In en, this message translates to:
  /// **'Classroom'**
  String get classroomsClassroomLabel;

  /// No description provided for @classroomsLoadingLatestMessage.
  ///
  /// In en, this message translates to:
  /// **'Loading latest message...'**
  String get classroomsLoadingLatestMessage;

  /// No description provided for @classroomsTapToOpen.
  ///
  /// In en, this message translates to:
  /// **'Tap to open classroom'**
  String get classroomsTapToOpen;

  /// No description provided for @classroomsNoMessagesYet.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get classroomsNoMessagesYet;

  /// No description provided for @classroomsMessageFallback.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get classroomsMessageFallback;

  /// No description provided for @examsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load exams or forms'**
  String get examsLoadError;

  /// No description provided for @examsAllFilter.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get examsAllFilter;

  /// No description provided for @examsFormsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review classroom forms, response windows, and follow-ups published by your school.'**
  String get examsFormsSubtitle;

  /// No description provided for @examsOnlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track upcoming assessments, countdowns, and past exam records from your classes.'**
  String get examsOnlySubtitle;

  /// No description provided for @examsUpcomingStat.
  ///
  /// In en, this message translates to:
  /// **'Upcoming exams'**
  String get examsUpcomingStat;

  /// No description provided for @examsOpenFormsStat.
  ///
  /// In en, this message translates to:
  /// **'Open forms'**
  String get examsOpenFormsStat;

  /// No description provided for @examsCountdownPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get examsCountdownPast;

  /// No description provided for @examsCountdownTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get examsCountdownTomorrow;

  /// No description provided for @examsCountdownInDays.
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String examsCountdownInDays(Object days);

  /// No description provided for @examsNoExamsPublished.
  ///
  /// In en, this message translates to:
  /// **'No exams have been published yet.'**
  String get examsNoExamsPublished;

  /// No description provided for @examsNoFormsPublished.
  ///
  /// In en, this message translates to:
  /// **'No forms have been published yet.'**
  String get examsNoFormsPublished;

  /// No description provided for @examsNoExamsForFilter.
  ///
  /// In en, this message translates to:
  /// **'No exams are available for {subject} right now.'**
  String examsNoExamsForFilter(Object subject);

  /// No description provided for @examsNoFormsForFilter.
  ///
  /// In en, this message translates to:
  /// **'No forms are available for {subject} right now.'**
  String examsNoFormsForFilter(Object subject);

  /// No description provided for @examsMaterialsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} materials'**
  String examsMaterialsCount(Object count);

  /// No description provided for @examsOpenState.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get examsOpenState;

  /// No description provided for @examsClosedState.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get examsClosedState;

  /// No description provided for @examsQuestionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String examsQuestionsCount(Object count);

  /// No description provided for @examsResponsesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} responses'**
  String examsResponsesCount(Object count);

  /// No description provided for @insightsTrendBaseline.
  ///
  /// In en, this message translates to:
  /// **'Baseline'**
  String get insightsTrendBaseline;

  /// No description provided for @insightsTrendImproving.
  ///
  /// In en, this message translates to:
  /// **'Improving'**
  String get insightsTrendImproving;

  /// No description provided for @insightsTrendDropping.
  ///
  /// In en, this message translates to:
  /// **'Dropping'**
  String get insightsTrendDropping;

  /// No description provided for @insightsTrendStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get insightsTrendStable;

  /// No description provided for @insightsHeadlineIntervention.
  ///
  /// In en, this message translates to:
  /// **'Intervention window is open'**
  String get insightsHeadlineIntervention;

  /// No description provided for @insightsHeadlineSignals.
  ///
  /// In en, this message translates to:
  /// **'Several signals need tightening'**
  String get insightsHeadlineSignals;

  /// No description provided for @insightsHeadlineMomentum.
  ///
  /// In en, this message translates to:
  /// **'Momentum can compound this week'**
  String get insightsHeadlineMomentum;

  /// No description provided for @insightsBodyAttendance.
  ///
  /// In en, this message translates to:
  /// **'Protect attendance first. Better presence now will raise every other signal faster.'**
  String get insightsBodyAttendance;

  /// No description provided for @insightsBodyWeakTrend.
  ///
  /// In en, this message translates to:
  /// **'{subject} plus a falling practice trend is the biggest risk combo right now. Fix that before expanding.'**
  String insightsBodyWeakTrend(Object subject);

  /// No description provided for @insightsBodyLeverage.
  ///
  /// In en, this message translates to:
  /// **'{subject} is your leverage point. Use it to build confidence while you patch weaker areas.'**
  String insightsBodyLeverage(Object subject);

  /// No description provided for @insightsBodyConsistency.
  ///
  /// In en, this message translates to:
  /// **'Keep stacking short focused sessions. The next few days matter more than a perfect long-term plan.'**
  String get insightsBodyConsistency;

  /// No description provided for @insightsInterventionScoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Intervention score'**
  String get insightsInterventionScoreTitle;

  /// No description provided for @insightsInterventionScoreBody.
  ///
  /// In en, this message translates to:
  /// **'{count} active signals are shaping your next move.'**
  String insightsInterventionScoreBody(Object count);

  /// No description provided for @insightsRecoveryPathTitle.
  ///
  /// In en, this message translates to:
  /// **'Fastest recovery path'**
  String get insightsRecoveryPathTitle;

  /// No description provided for @insightsRecoveryPathDefault.
  ///
  /// In en, this message translates to:
  /// **'Attendance + consistency first.'**
  String get insightsRecoveryPathDefault;

  /// No description provided for @insightsRecoveryPathTopic.
  ///
  /// In en, this message translates to:
  /// **'Revisit {topic} in {subject} before pushing harder.'**
  String insightsRecoveryPathTopic(Object topic, Object subject);

  /// No description provided for @insightsProjectedDirectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Projected direction'**
  String get insightsProjectedDirectionTitle;

  /// No description provided for @insightsProjectedDirectionBody.
  ///
  /// In en, this message translates to:
  /// **'{trend} based on recent 7d vs 30d practice behavior.'**
  String insightsProjectedDirectionBody(Object trend);

  /// No description provided for @insightsLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights loading'**
  String get insightsLoadingTitle;

  /// No description provided for @insightsLoadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Building your predictive dashboard.'**
  String get insightsLoadingSubtitle;

  /// No description provided for @insightsNotReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights are not ready yet'**
  String get insightsNotReadyTitle;

  /// No description provided for @insightsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No insights yet'**
  String get insightsEmptyTitle;

  /// No description provided for @insightsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep using practice and your school tools so ClassMate can build a clearer academic picture.'**
  String get insightsEmptySubtitle;

  /// No description provided for @insightsGradeAverage.
  ///
  /// In en, this message translates to:
  /// **'Grade avg'**
  String get insightsGradeAverage;

  /// No description provided for @insightsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get insightsAccuracy;

  /// No description provided for @insightsOpenNova.
  ///
  /// In en, this message translates to:
  /// **'Open NOVA'**
  String get insightsOpenNova;

  /// No description provided for @insightsOpenNovaPrompt.
  ///
  /// In en, this message translates to:
  /// **'Help me fix my weakest area based on my latest ClassMate insights.'**
  String get insightsOpenNovaPrompt;

  /// No description provided for @insightsPredictiveRecoveryPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Predictive recovery plan'**
  String get insightsPredictiveRecoveryPlanTitle;

  /// No description provided for @insightsPracticeNow.
  ///
  /// In en, this message translates to:
  /// **'Practice now'**
  String get insightsPracticeNow;

  /// No description provided for @insightsPredictiveModulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Predictive modules'**
  String get insightsPredictiveModulesTitle;

  /// No description provided for @insightsPredictiveModulesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The strongest forward-looking signals from your current student data.'**
  String get insightsPredictiveModulesSubtitle;

  /// No description provided for @insightsAnnouncementsPressureTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcements pressure'**
  String get insightsAnnouncementsPressureTitle;

  /// No description provided for @insightsAnnouncementsPressureSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The announcement engine is now feeding the dashboard directly.'**
  String get insightsAnnouncementsPressureSubtitle;

  /// No description provided for @insightsAiCoachTitle.
  ///
  /// In en, this message translates to:
  /// **'AI coach summary'**
  String get insightsAiCoachTitle;

  /// No description provided for @insightsAiCoachLoadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Loading AI guidance.'**
  String get insightsAiCoachLoadingSubtitle;

  /// No description provided for @insightsAiCoachUnavailableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'AI guidance is unavailable for this account right now.'**
  String get insightsAiCoachUnavailableSubtitle;

  /// No description provided for @insightsAskNova.
  ///
  /// In en, this message translates to:
  /// **'Ask NOVA'**
  String get insightsAskNova;

  /// No description provided for @insightsAskNovaPrompt.
  ///
  /// In en, this message translates to:
  /// **'Build me a recovery plan from my latest insights.'**
  String get insightsAskNovaPrompt;

  /// No description provided for @insightsAiStudyCoachTitle.
  ///
  /// In en, this message translates to:
  /// **'AI study coach'**
  String get insightsAiStudyCoachTitle;

  /// No description provided for @insightsSchoolToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'School tools'**
  String get insightsSchoolToolsTitle;

  /// No description provided for @insightsSchoolToolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Jump directly into the student routes that now matter most.'**
  String get insightsSchoolToolsSubtitle;

  /// No description provided for @tutorUntitledChat.
  ///
  /// In en, this message translates to:
  /// **'Untitled chat'**
  String get tutorUntitledChat;

  /// No description provided for @tutorNewChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get tutorNewChat;

  /// No description provided for @tutorFailedToOpenSeededChat.
  ///
  /// In en, this message translates to:
  /// **'Failed to open chat: {error}'**
  String tutorFailedToOpenSeededChat(Object error);

  /// No description provided for @tutorFailedToCreateChat.
  ///
  /// In en, this message translates to:
  /// **'Failed to create chat: {error}'**
  String tutorFailedToCreateChat(Object error);

  /// No description provided for @tutorRenameChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename chat'**
  String get tutorRenameChatTitle;

  /// No description provided for @tutorChatNameHint.
  ///
  /// In en, this message translates to:
  /// **'Chat name'**
  String get tutorChatNameHint;

  /// No description provided for @tutorCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get tutorCancel;

  /// No description provided for @tutorHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get tutorHide;

  /// No description provided for @tutorHideChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide chat'**
  String get tutorHideChatTitle;

  /// No description provided for @tutorHideChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Hides this chat on this device.'**
  String get tutorHideChatSubtitle;

  /// No description provided for @tutorHideChatConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Hide chat?'**
  String get tutorHideChatConfirmTitle;

  /// No description provided for @tutorHideChatConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This hides the chat from the list on this device. The session stays on the backend.'**
  String get tutorHideChatConfirmBody;

  /// No description provided for @tutorTapToOpenHistory.
  ///
  /// In en, this message translates to:
  /// **'Tap to open history'**
  String get tutorTapToOpenHistory;

  /// No description provided for @tutorAiTutorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your AI tutor'**
  String get tutorAiTutorSubtitle;

  /// No description provided for @tutorHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Real chat history, cleaner threads, faster access.'**
  String get tutorHeroBody;

  /// No description provided for @tutorStartFreshConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a fresh conversation'**
  String get tutorStartFreshConversation;

  /// No description provided for @tutorSearchHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Search chat history'**
  String get tutorSearchHistoryHint;

  /// No description provided for @chatComposerDefaultHint.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatComposerDefaultHint;

  /// No description provided for @chatComposerReplyingToMessage.
  ///
  /// In en, this message translates to:
  /// **'Replying to message'**
  String get chatComposerReplyingToMessage;

  /// No description provided for @chatComposerReplyFallback.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get chatComposerReplyFallback;

  /// No description provided for @chatComposerMicHint.
  ///
  /// In en, this message translates to:
  /// **'Tap for a quick voice note or hold to record'**
  String get chatComposerMicHint;

  /// No description provided for @chatComposerRecordingTitle.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get chatComposerRecordingTitle;

  /// No description provided for @chatComposerReleaseToSend.
  ///
  /// In en, this message translates to:
  /// **'Let go to send'**
  String get chatComposerReleaseToSend;

  /// No description provided for @chatComposerCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get chatComposerCancelTitle;

  /// No description provided for @chatComposerLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get chatComposerLockTitle;

  /// No description provided for @chatComposerSlideLeftToCancel.
  ///
  /// In en, this message translates to:
  /// **'Slide left to cancel'**
  String get chatComposerSlideLeftToCancel;

  /// No description provided for @chatComposerSlideUpToLock.
  ///
  /// In en, this message translates to:
  /// **'Slide up to lock'**
  String get chatComposerSlideUpToLock;

  /// No description provided for @chatComposerReleaseToCancel.
  ///
  /// In en, this message translates to:
  /// **'Release to cancel'**
  String get chatComposerReleaseToCancel;

  /// No description provided for @chatComposerKeepSlidingToCancel.
  ///
  /// In en, this message translates to:
  /// **'Keep sliding to cancel'**
  String get chatComposerKeepSlidingToCancel;

  /// No description provided for @chatComposerReleaseToLock.
  ///
  /// In en, this message translates to:
  /// **'Release to lock'**
  String get chatComposerReleaseToLock;

  /// No description provided for @chatComposerRelease.
  ///
  /// In en, this message translates to:
  /// **'Release'**
  String get chatComposerRelease;

  /// No description provided for @chatComposerLock.
  ///
  /// In en, this message translates to:
  /// **'Lock'**
  String get chatComposerLock;

  /// No description provided for @chatComposerRecordingPaused.
  ///
  /// In en, this message translates to:
  /// **'Recording paused'**
  String get chatComposerRecordingPaused;

  /// No description provided for @chatComposerRecordingLocked.
  ///
  /// In en, this message translates to:
  /// **'Recording locked'**
  String get chatComposerRecordingLocked;

  /// No description provided for @chatComposerResumeHint.
  ///
  /// In en, this message translates to:
  /// **'Resume when you are ready to keep recording'**
  String get chatComposerResumeHint;

  /// No description provided for @chatComposerLockedHint.
  ///
  /// In en, this message translates to:
  /// **'Tap send when you are ready to share'**
  String get chatComposerLockedHint;

  /// No description provided for @chatContextDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get chatContextDismiss;

  /// No description provided for @chatContextCopyText.
  ///
  /// In en, this message translates to:
  /// **'Copy text'**
  String get chatContextCopyText;

  /// No description provided for @chatContextDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chatContextDelete;

  /// No description provided for @chatMessageInfoShortTitle.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get chatMessageInfoShortTitle;

  /// No description provided for @chatMessageInfoStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get chatMessageInfoStatus;

  /// No description provided for @chatMessageInfoStatusTime.
  ///
  /// In en, this message translates to:
  /// **'Status time'**
  String get chatMessageInfoStatusTime;

  /// No description provided for @chatMessageInfoSentAt.
  ///
  /// In en, this message translates to:
  /// **'Sent at'**
  String get chatMessageInfoSentAt;

  /// No description provided for @chatMessageInfoDeliveredAt.
  ///
  /// In en, this message translates to:
  /// **'Delivered at'**
  String get chatMessageInfoDeliveredAt;

  /// No description provided for @chatMessageInfoSeenAt.
  ///
  /// In en, this message translates to:
  /// **'Seen at'**
  String get chatMessageInfoSeenAt;

  /// No description provided for @chatMessageInfoMessageType.
  ///
  /// In en, this message translates to:
  /// **'Message type'**
  String get chatMessageInfoMessageType;

  /// No description provided for @chatMessageInfoTextType.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get chatMessageInfoTextType;

  /// No description provided for @chatMessageInfoEdited.
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get chatMessageInfoEdited;

  /// No description provided for @chatMessageInfoForwarded.
  ///
  /// In en, this message translates to:
  /// **'Forwarded'**
  String get chatMessageInfoForwarded;

  /// No description provided for @chatMessageInfoVoiceDuration.
  ///
  /// In en, this message translates to:
  /// **'Voice duration'**
  String get chatMessageInfoVoiceDuration;

  /// No description provided for @chatMessageInfoSeenBy.
  ///
  /// In en, this message translates to:
  /// **'Seen by'**
  String get chatMessageInfoSeenBy;

  /// No description provided for @chatMessageInfoDeliveredTo.
  ///
  /// In en, this message translates to:
  /// **'Delivered to'**
  String get chatMessageInfoDeliveredTo;

  /// No description provided for @chatMessageInfoEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'(empty)'**
  String get chatMessageInfoEmptyBody;

  /// No description provided for @chatMessageInfoReadLess.
  ///
  /// In en, this message translates to:
  /// **'Read less'**
  String get chatMessageInfoReadLess;

  /// No description provided for @chatMessageInfoReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get chatMessageInfoReadMore;

  /// No description provided for @chatMessageInfoSeen.
  ///
  /// In en, this message translates to:
  /// **'Seen'**
  String get chatMessageInfoSeen;

  /// No description provided for @chatMessageInfoDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get chatMessageInfoDelivered;

  /// No description provided for @chatMessageInfoNotDelivered.
  ///
  /// In en, this message translates to:
  /// **'Not delivered'**
  String get chatMessageInfoNotDelivered;

  /// No description provided for @chatMessageInfoSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get chatMessageInfoSent;

  /// No description provided for @chatMessageInfoPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get chatMessageInfoPending;

  /// No description provided for @chatMessageInfoNotSeen.
  ///
  /// In en, this message translates to:
  /// **'Not seen'**
  String get chatMessageInfoNotSeen;

  /// No description provided for @chatMessageInfoType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get chatMessageInfoType;

  /// No description provided for @chatMessageInfoDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get chatMessageInfoDuration;

  /// No description provided for @chatMessageInfoYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get chatMessageInfoYes;

  /// No description provided for @chatMessageInfoNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get chatMessageInfoNo;

  /// No description provided for @chatMessageInfoDeleteState.
  ///
  /// In en, this message translates to:
  /// **'Delete state'**
  String get chatMessageInfoDeleteState;

  /// No description provided for @chatReactionDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reactions'**
  String get chatReactionDetailsTitle;

  /// No description provided for @chatReactionAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add reaction'**
  String get chatReactionAddAction;

  /// No description provided for @chatReactionEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No reactions yet'**
  String get chatReactionEmptyState;

  /// No description provided for @chatReactionSingle.
  ///
  /// In en, this message translates to:
  /// **'Reaction'**
  String get chatReactionSingle;

  /// No description provided for @chatReactionTapToRemove.
  ///
  /// In en, this message translates to:
  /// **'Tap to remove'**
  String get chatReactionTapToRemove;

  /// No description provided for @chatReactionYouCount.
  ///
  /// In en, this message translates to:
  /// **'You{count, plural, =1 {} other { · {count}}}'**
  String chatReactionYouCount(int count);

  /// No description provided for @chatReactionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {Reaction} other {{count} reactions}}'**
  String chatReactionCount(int count);

  /// No description provided for @chatEmojiPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose emoji'**
  String get chatEmojiPickerTitle;

  /// No description provided for @chatEmojiPickerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search emoji'**
  String get chatEmojiPickerSearchHint;

  /// No description provided for @chatEmojiPickerEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No emoji found'**
  String get chatEmojiPickerEmptyState;

  /// No description provided for @chatCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get chatCameraTitle;

  /// No description provided for @chatCameraUseAction.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get chatCameraUseAction;

  /// No description provided for @chatCameraGalleryAction.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get chatCameraGalleryAction;

  /// No description provided for @chatCameraSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {0 selected} =1 {1 selected} other {{count} selected}}'**
  String chatCameraSelectedCount(int count);

  /// No description provided for @chatMediaPreviewEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Nothing to preview'**
  String get chatMediaPreviewEmptyState;

  /// No description provided for @chatMediaPreviewDrawCropAction.
  ///
  /// In en, this message translates to:
  /// **'Draw & Crop'**
  String get chatMediaPreviewDrawCropAction;

  /// No description provided for @chatMediaPreviewRotateLeftAction.
  ///
  /// In en, this message translates to:
  /// **'Rotate left'**
  String get chatMediaPreviewRotateLeftAction;

  /// No description provided for @chatMediaPreviewRotateRightAction.
  ///
  /// In en, this message translates to:
  /// **'Rotate right'**
  String get chatMediaPreviewRotateRightAction;

  /// No description provided for @chatMediaPreviewMirrorAction.
  ///
  /// In en, this message translates to:
  /// **'Mirror'**
  String get chatMediaPreviewMirrorAction;

  /// No description provided for @chatMediaPreviewResetAction.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get chatMediaPreviewResetAction;

  /// No description provided for @chatMediaPreviewRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get chatMediaPreviewRemoveAction;

  /// No description provided for @chatMediaPreviewCaptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add a caption...'**
  String get chatMediaPreviewCaptionHint;

  /// No description provided for @tutorPlanSelectedPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'{plan} selected. Payments stay in placeholder mode for now.'**
  String tutorPlanSelectedPlaceholder(Object plan);

  /// No description provided for @tutorFailedToLoadChats.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chats'**
  String get tutorFailedToLoadChats;

  /// No description provided for @tutorNoChatsYet.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get tutorNoChatsYet;

  /// No description provided for @tutorNoChatsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No chats match your search'**
  String get tutorNoChatsMatchSearch;

  /// No description provided for @tutorCreateFirstChat.
  ///
  /// In en, this message translates to:
  /// **'Create first chat'**
  String get tutorCreateFirstChat;

  /// No description provided for @tutorPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'NOVA plans'**
  String get tutorPlansTitle;

  /// No description provided for @tutorPlansSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on {model} cost assumptions and hard monthly caps so usage stays profitable.'**
  String tutorPlansSubtitle(Object model);

  /// No description provided for @tutorPlanPriceFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get tutorPlanPriceFree;

  /// No description provided for @tutorPlanPriceMonthly.
  ///
  /// In en, this message translates to:
  /// **'\${price}/mo'**
  String tutorPlanPriceMonthly(Object price);

  /// No description provided for @tutorPromptsLeft.
  ///
  /// In en, this message translates to:
  /// **'Prompts left'**
  String get tutorPromptsLeft;

  /// No description provided for @tutorUploadsLeft.
  ///
  /// In en, this message translates to:
  /// **'Uploads left'**
  String get tutorUploadsLeft;

  /// No description provided for @tutorVoiceLeft.
  ///
  /// In en, this message translates to:
  /// **'Voice left'**
  String get tutorVoiceLeft;

  /// No description provided for @tutorUsageValue.
  ///
  /// In en, this message translates to:
  /// **'{remaining}/{total}'**
  String tutorUsageValue(Object remaining, Object total);

  /// No description provided for @tutorVoiceUsageValue.
  ///
  /// In en, this message translates to:
  /// **'{remaining}/{total} min'**
  String tutorVoiceUsageValue(Object remaining, Object total);

  /// No description provided for @tutorPaymentMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment methods'**
  String get tutorPaymentMethodsTitle;

  /// No description provided for @tutorPaymentMethodsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Checkout is placeholder-only until the ClassMate bank account and processor are live. The selected plan is {plan}.'**
  String tutorPaymentMethodsSubtitle(Object plan);

  /// No description provided for @tutorCardCheckoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Card checkout'**
  String get tutorCardCheckoutTitle;

  /// No description provided for @tutorCardCheckoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visa, Mastercard, AmEx placeholder gateway.'**
  String get tutorCardCheckoutSubtitle;

  /// No description provided for @tutorApplePayTitle.
  ///
  /// In en, this message translates to:
  /// **'Apple Pay'**
  String get tutorApplePayTitle;

  /// No description provided for @tutorApplePaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Placeholder wallet flow for iPhone and web.'**
  String get tutorApplePaySubtitle;

  /// No description provided for @tutorBankTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get tutorBankTransferTitle;

  /// No description provided for @tutorBankTransferSubtitle.
  ///
  /// In en, this message translates to:
  /// **'ClassMate bank account pending. Details will be filled once opened.'**
  String get tutorBankTransferSubtitle;

  /// No description provided for @tutorPlanStarterName.
  ///
  /// In en, this message translates to:
  /// **'Starter'**
  String get tutorPlanStarterName;

  /// No description provided for @tutorPlanStarterTagline.
  ///
  /// In en, this message translates to:
  /// **'Enough for trial and light weekly revision.'**
  String get tutorPlanStarterTagline;

  /// No description provided for @tutorPlanPlusName.
  ///
  /// In en, this message translates to:
  /// **'Plus'**
  String get tutorPlanPlusName;

  /// No description provided for @tutorPlanPlusTagline.
  ///
  /// In en, this message translates to:
  /// **'Best for one serious student using NOVA most days.'**
  String get tutorPlanPlusTagline;

  /// No description provided for @tutorPlanProName.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get tutorPlanProName;

  /// No description provided for @tutorPlanProTagline.
  ///
  /// In en, this message translates to:
  /// **'Heavy daily use, full exam season, and long study sessions.'**
  String get tutorPlanProTagline;

  /// No description provided for @tutorPlanSchoolSeatName.
  ///
  /// In en, this message translates to:
  /// **'School Seat'**
  String get tutorPlanSchoolSeatName;

  /// No description provided for @tutorPlanSchoolSeatTagline.
  ///
  /// In en, this message translates to:
  /// **'For rollout per student or staff seat inside a real school.'**
  String get tutorPlanSchoolSeatTagline;

  /// No description provided for @tutorPlanBulletPromptsMonthly.
  ///
  /// In en, this message translates to:
  /// **'{count} NOVA prompts each month'**
  String tutorPlanBulletPromptsMonthly(Object count);

  /// No description provided for @tutorPlanBulletPromptsPerSeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'{count} NOVA prompts per seat monthly'**
  String tutorPlanBulletPromptsPerSeatMonthly(Object count);

  /// No description provided for @tutorPlanBulletUploads.
  ///
  /// In en, this message translates to:
  /// **'{count} image or file uploads'**
  String tutorPlanBulletUploads(Object count);

  /// No description provided for @tutorPlanBulletVoiceMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} voice transcription minutes'**
  String tutorPlanBulletVoiceMinutes(Object count);

  /// No description provided for @tutorEstimatedCostCeilingFree.
  ///
  /// In en, this message translates to:
  /// **'Estimated cost ceiling: \${cost}/mo'**
  String tutorEstimatedCostCeilingFree(Object cost);

  /// No description provided for @tutorEstimatedCostCeilingPaid.
  ///
  /// In en, this message translates to:
  /// **'Estimated cost ceiling: \${cost}/mo • margin {margin}%'**
  String tutorEstimatedCostCeilingPaid(Object cost, Object margin);

  /// No description provided for @tutorTimeMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String tutorTimeMinutesShort(Object count);

  /// No description provided for @tutorTimeHoursShort.
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String tutorTimeHoursShort(Object count);

  /// No description provided for @tutorVoiceMessageFallback.
  ///
  /// In en, this message translates to:
  /// **'Voice message'**
  String get tutorVoiceMessageFallback;

  /// No description provided for @tutorFileFallback.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get tutorFileFallback;

  /// No description provided for @tutorCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get tutorCopy;

  /// No description provided for @tutorEditMessage.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get tutorEditMessage;

  /// No description provided for @tutorCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get tutorCopied;

  /// No description provided for @tutorLoadedIntoComposer.
  ///
  /// In en, this message translates to:
  /// **'Loaded into composer'**
  String get tutorLoadedIntoComposer;

  /// No description provided for @tutorTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get tutorTakePhoto;

  /// No description provided for @tutorRecordVideo.
  ///
  /// In en, this message translates to:
  /// **'Record video'**
  String get tutorRecordVideo;

  /// No description provided for @tutorChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get tutorChooseFromGallery;

  /// No description provided for @tutorPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get tutorPreviewTitle;

  /// No description provided for @tutorThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking...'**
  String get tutorThinking;

  /// No description provided for @tutorDone.
  ///
  /// In en, this message translates to:
  /// **'Done.'**
  String get tutorDone;

  /// No description provided for @tutorFailedToStreamReply.
  ///
  /// In en, this message translates to:
  /// **'Failed to stream reply'**
  String get tutorFailedToStreamReply;

  /// No description provided for @tutorUnsupportedFilesMessage.
  ///
  /// In en, this message translates to:
  /// **'NOVA supports images, documents, and text. Video and audio files are not supported here.'**
  String get tutorUnsupportedFilesMessage;

  /// No description provided for @tutorNoAudioCaptured.
  ///
  /// In en, this message translates to:
  /// **'No audio captured.'**
  String get tutorNoAudioCaptured;

  /// No description provided for @tutorVoiceLimitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'Voice limit reached'**
  String get tutorVoiceLimitReachedTitle;

  /// No description provided for @tutorVoiceLimitReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your current NOVA plan does not have enough voice minutes left for this transcription cycle.'**
  String get tutorVoiceLimitReachedMessage;

  /// No description provided for @tutorTranscriptionFailed.
  ///
  /// In en, this message translates to:
  /// **'Transcription failed. Please try again.'**
  String get tutorTranscriptionFailed;

  /// No description provided for @tutorMicrophonePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required.'**
  String get tutorMicrophonePermissionRequired;

  /// No description provided for @tutorPlanLimitReachedTitle.
  ///
  /// In en, this message translates to:
  /// **'NOVA plan limit reached'**
  String get tutorPlanLimitReachedTitle;

  /// No description provided for @tutorPlanLimitReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'This month\'s prompt or upload allowance is exhausted for your current NOVA plan. Pick a higher plan in the NOVA home screen to continue.'**
  String get tutorPlanLimitReachedMessage;

  /// No description provided for @tutorSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Send failed.'**
  String get tutorSendFailed;

  /// No description provided for @tutorCurrentPlanUsageSummary.
  ///
  /// In en, this message translates to:
  /// **'Current plan: {plan} • {prompts} prompts left • {uploads} uploads left • {voice} voice minutes left'**
  String tutorCurrentPlanUsageSummary(
    Object plan,
    Object prompts,
    Object uploads,
    Object voice,
  );

  /// No description provided for @tutorReviewPlansInHome.
  ///
  /// In en, this message translates to:
  /// **'Review plans in NOVA home'**
  String get tutorReviewPlansInHome;

  /// No description provided for @tutorCouldNotOpenAttachment.
  ///
  /// In en, this message translates to:
  /// **'Could not open attachment.'**
  String get tutorCouldNotOpenAttachment;

  /// No description provided for @tutorAttachmentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Attachment unavailable.'**
  String get tutorAttachmentUnavailable;

  /// No description provided for @tutorImageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get tutorImageUnavailable;

  /// No description provided for @tutorYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get tutorYou;

  /// No description provided for @tutorRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate'**
  String get tutorRegenerate;

  /// No description provided for @tutorEmptyStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with a real question'**
  String get tutorEmptyStateTitle;

  /// No description provided for @tutorEmptyStateBody.
  ///
  /// In en, this message translates to:
  /// **'Ask NOVA to explain a concept, turn notes into a table, compare ideas, or help you revise from an uploaded file.'**
  String get tutorEmptyStateBody;

  /// No description provided for @tutorPromptSuggestionSummarizeNotes.
  ///
  /// In en, this message translates to:
  /// **'Summarize my lesson notes'**
  String get tutorPromptSuggestionSummarizeNotes;

  /// No description provided for @tutorPromptSuggestionRevisionTable.
  ///
  /// In en, this message translates to:
  /// **'Make a revision table'**
  String get tutorPromptSuggestionRevisionTable;

  /// No description provided for @tutorPromptSuggestionQuizMe.
  ///
  /// In en, this message translates to:
  /// **'Quiz me on this topic'**
  String get tutorPromptSuggestionQuizMe;

  /// No description provided for @tutorMessageNovaHint.
  ///
  /// In en, this message translates to:
  /// **'Message NOVA'**
  String get tutorMessageNovaHint;

  /// No description provided for @tutorHeaderSubtitleReady.
  ///
  /// In en, this message translates to:
  /// **'Structured answers, tables, and study help'**
  String get tutorHeaderSubtitleReady;

  /// No description provided for @tutorYourNovaPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Your NOVA plan'**
  String get tutorYourNovaPlanTitle;

  /// No description provided for @tutorYourNovaPlanMessage.
  ///
  /// In en, this message translates to:
  /// **'Review prompt, upload, and voice limits here, then jump back to NOVA home if you want to switch plans.'**
  String get tutorYourNovaPlanMessage;

  /// No description provided for @tutorExplainTitle.
  ///
  /// In en, this message translates to:
  /// **'NOVA Explain'**
  String get tutorExplainTitle;

  /// No description provided for @classroomsThreadTypeClassroom.
  ///
  /// In en, this message translates to:
  /// **'Classroom'**
  String get classroomsThreadTypeClassroom;

  /// No description provided for @classroomsThreadTypeGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get classroomsThreadTypeGroup;

  /// No description provided for @classroomsThreadTypeDirectMessage.
  ///
  /// In en, this message translates to:
  /// **'Direct message'**
  String get classroomsThreadTypeDirectMessage;

  /// No description provided for @classroomsThreadTypeDirectMessageShort.
  ///
  /// In en, this message translates to:
  /// **'DM'**
  String get classroomsThreadTypeDirectMessageShort;

  /// No description provided for @messagesBlockedPeopleTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked people'**
  String get messagesBlockedPeopleTitle;

  /// No description provided for @messagesStartChatAction.
  ///
  /// In en, this message translates to:
  /// **'Start chat'**
  String get messagesStartChatAction;

  /// No description provided for @messagesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load messages: {error}'**
  String messagesLoadFailed(Object error);

  /// No description provided for @messagesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search messages'**
  String get messagesSearchHint;

  /// No description provided for @messagesNoResults.
  ///
  /// In en, this message translates to:
  /// **'No messages found'**
  String get messagesNoResults;

  /// No description provided for @messagesRequestsSection.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get messagesRequestsSection;

  /// No description provided for @messagesPendingApprovals.
  ///
  /// In en, this message translates to:
  /// **'Pending approvals'**
  String get messagesPendingApprovals;

  /// No description provided for @messagesChatsSection.
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get messagesChatsSection;

  /// No description provided for @messagesAllChatsSection.
  ///
  /// In en, this message translates to:
  /// **'All chats'**
  String get messagesAllChatsSection;

  /// No description provided for @messagesConversationCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 conversation} other {{count} conversations}}'**
  String messagesConversationCount(num count);

  /// No description provided for @messagesRequestReviewStatus.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get messagesRequestReviewStatus;

  /// No description provided for @messagesPeopleLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load people: {error}'**
  String messagesPeopleLoadFailed(Object error);

  /// No description provided for @messagesSearchPeopleHint.
  ///
  /// In en, this message translates to:
  /// **'Search people'**
  String get messagesSearchPeopleHint;

  /// No description provided for @messagesNewGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get messagesNewGroupTitle;

  /// No description provided for @messagesNewGroupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a group chat'**
  String get messagesNewGroupSubtitle;

  /// No description provided for @messagesGroupNameHint.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get messagesGroupNameHint;

  /// No description provided for @messagesCreateGroupAction.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get messagesCreateGroupAction;

  /// No description provided for @messagesBlockedPersonFallback.
  ///
  /// In en, this message translates to:
  /// **'this person'**
  String get messagesBlockedPersonFallback;

  /// No description provided for @messagesUnblockPersonTitle.
  ///
  /// In en, this message translates to:
  /// **'Unblock person?'**
  String get messagesUnblockPersonTitle;

  /// No description provided for @messagesUnblockPersonBody.
  ///
  /// In en, this message translates to:
  /// **'Allow {name} to message you again?'**
  String messagesUnblockPersonBody(Object name);

  /// No description provided for @messagesUnblockAction.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get messagesUnblockAction;

  /// No description provided for @messagesUnblockedToast.
  ///
  /// In en, this message translates to:
  /// **'{name} unblocked'**
  String messagesUnblockedToast(Object name);

  /// No description provided for @messagesBlockedPeopleLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load blocked people: {error}'**
  String messagesBlockedPeopleLoadFailed(Object error);

  /// No description provided for @messagesNoBlockedPeople.
  ///
  /// In en, this message translates to:
  /// **'No blocked people'**
  String get messagesNoBlockedPeople;

  /// No description provided for @messagesUnknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown user'**
  String get messagesUnknownUser;

  /// No description provided for @messagesRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get messagesRequestTitle;

  /// No description provided for @messagesRequestLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load request: {error}'**
  String messagesRequestLoadFailed(Object error);

  /// No description provided for @messagesRequestBannerIncoming.
  ///
  /// In en, this message translates to:
  /// **'Message request'**
  String get messagesRequestBannerIncoming;

  /// No description provided for @messagesRequestBannerOutgoing.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get messagesRequestBannerOutgoing;

  /// No description provided for @messagesBlockAction.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get messagesBlockAction;

  /// No description provided for @messagesApproveAction.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get messagesApproveAction;

  /// No description provided for @messagesRequestUnlockHint.
  ///
  /// In en, this message translates to:
  /// **'The chat unlocks after the receiver approves your first message.'**
  String get messagesRequestUnlockHint;

  /// No description provided for @messagesThreadConversationFallback.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get messagesThreadConversationFallback;

  /// No description provided for @messagesThreadLeaveGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave group?'**
  String get messagesThreadLeaveGroupTitle;

  /// No description provided for @messagesThreadLeaveGroupBody.
  ///
  /// In en, this message translates to:
  /// **'You will stop receiving messages from this group.'**
  String get messagesThreadLeaveGroupBody;

  /// No description provided for @messagesThreadBlockPersonTitle.
  ///
  /// In en, this message translates to:
  /// **'Block person?'**
  String get messagesThreadBlockPersonTitle;

  /// No description provided for @messagesThreadBlockPersonBody.
  ///
  /// In en, this message translates to:
  /// **'You will no longer be able to exchange messages with this person.'**
  String get messagesThreadBlockPersonBody;

  /// No description provided for @messagesThreadPersonFallback.
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get messagesThreadPersonFallback;

  /// No description provided for @messagesThreadProfileInfoUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Profile info unavailable'**
  String get messagesThreadProfileInfoUnavailable;

  /// No description provided for @messagesThreadParticipants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get messagesThreadParticipants;

  /// No description provided for @messagesThreadPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get messagesThreadPeople;

  /// No description provided for @messagesThreadDeleteForMe.
  ///
  /// In en, this message translates to:
  /// **'Delete for me'**
  String get messagesThreadDeleteForMe;

  /// No description provided for @messagesThreadDeleteForEveryone.
  ///
  /// In en, this message translates to:
  /// **'Delete for everyone'**
  String get messagesThreadDeleteForEveryone;

  /// No description provided for @messagesThreadDeleteForEveryoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Removes for all participants'**
  String get messagesThreadDeleteForEveryoneSubtitle;

  /// No description provided for @messagesThreadSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get messagesThreadSending;

  /// No description provided for @messagesThreadWaitingForApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get messagesThreadWaitingForApproval;

  /// No description provided for @classroomsForwardSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search chats'**
  String get classroomsForwardSearchHint;

  /// No description provided for @classroomsForwardNewChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get classroomsForwardNewChat;

  /// No description provided for @classroomsForwardLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chats: {error}'**
  String classroomsForwardLoadError(Object error);

  /// No description provided for @classroomsForwardNoChatsFound.
  ///
  /// In en, this message translates to:
  /// **'No chats found'**
  String get classroomsForwardNoChatsFound;

  /// No description provided for @classroomsForwardSectionClassrooms.
  ///
  /// In en, this message translates to:
  /// **'Classrooms'**
  String get classroomsForwardSectionClassrooms;

  /// No description provided for @classroomsForwardSectionDirectMessages.
  ///
  /// In en, this message translates to:
  /// **'Direct messages'**
  String get classroomsForwardSectionDirectMessages;

  /// No description provided for @classroomsForwardCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get classroomsForwardCancel;

  /// No description provided for @classroomsForwardAction.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get classroomsForwardAction;

  /// No description provided for @classroomsForwardCount.
  ///
  /// In en, this message translates to:
  /// **'Forward ({count})'**
  String classroomsForwardCount(Object count);

  /// No description provided for @markRead.
  ///
  /// In en, this message translates to:
  /// **'Mark read'**
  String get markRead;

  /// No description provided for @markUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark unread'**
  String get markUnread;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @allSources.
  ///
  /// In en, this message translates to:
  /// **'All sources'**
  String get allSources;

  /// No description provided for @allStates.
  ///
  /// In en, this message translates to:
  /// **'All states'**
  String get allStates;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @earlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get earlier;

  /// No description provided for @openDetails.
  ///
  /// In en, this message translates to:
  /// **'Open details'**
  String get openDetails;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @local.
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get local;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

  /// No description provided for @notificationsSourceSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get notificationsSourceSystem;

  /// No description provided for @notificationsHeroSubtitleStudent.
  ///
  /// In en, this message translates to:
  /// **'Your notification hub for announcements, server updates, and useful academic activity as it happens.'**
  String get notificationsHeroSubtitleStudent;

  /// No description provided for @notificationsHeroSubtitleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Your teacher notification hub for announcements, server updates, and school activity as it happens.'**
  String get notificationsHeroSubtitleTeacher;

  /// No description provided for @notificationsFiltersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Focus by source or read state to triage fast.'**
  String get notificationsFiltersSubtitle;

  /// No description provided for @notificationsSearchSourcesHint.
  ///
  /// In en, this message translates to:
  /// **'Search sources'**
  String get notificationsSearchSourcesHint;

  /// No description provided for @notificationsShowingSummary.
  ///
  /// In en, this message translates to:
  /// **'Showing {shown} of {total} notifications.'**
  String notificationsShowingSummary(Object shown, Object total);

  /// No description provided for @notificationsEmptyForAccount.
  ///
  /// In en, this message translates to:
  /// **'No notifications are available for this account right now.'**
  String get notificationsEmptyForAccount;

  /// No description provided for @notificationsEmptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No notifications match these filters right now. Clear filters to see the full feed.'**
  String get notificationsEmptyFiltered;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications are available right now.'**
  String get notificationsEmpty;

  /// No description provided for @notificationsNewBadge.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notificationsNewBadge;

  /// No description provided for @notificationsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This notification is no longer available. Pull to refresh the inbox and try again.'**
  String get notificationsUnavailable;

  /// No description provided for @notificationsSeverityCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get notificationsSeverityCritical;

  /// No description provided for @notificationsSeverityWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get notificationsSeverityWarning;

  /// No description provided for @notificationsSeverityInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get notificationsSeverityInfo;

  /// No description provided for @announcementsLoadError.
  ///
  /// In en, this message translates to:
  /// **'We could not load announcements right now. Pull to refresh or try again.'**
  String get announcementsLoadError;

  /// No description provided for @announcementsLoadTimeout.
  ///
  /// In en, this message translates to:
  /// **'Announcements are taking too long to load. Pull to refresh or try again in a moment.'**
  String get announcementsLoadTimeout;

  /// No description provided for @announcementsLoadNetwork.
  ///
  /// In en, this message translates to:
  /// **'Announcements could not connect right now. Check your connection and try again.'**
  String get announcementsLoadNetwork;

  /// No description provided for @announcementsAudienceTeacher.
  ///
  /// In en, this message translates to:
  /// **'teacher'**
  String get announcementsAudienceTeacher;

  /// No description provided for @announcementsAudienceAccount.
  ///
  /// In en, this message translates to:
  /// **'account'**
  String get announcementsAudienceAccount;

  /// No description provided for @announcementsAudienceTeacherWorkspace.
  ///
  /// In en, this message translates to:
  /// **'teacher workspace'**
  String get announcementsAudienceTeacherWorkspace;

  /// No description provided for @announcementsLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load announcements'**
  String get announcementsLoadFailedTitle;

  /// No description provided for @announcementsLoadFailedHint.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh after the connection is stable.'**
  String get announcementsLoadFailedHint;

  /// No description provided for @announcementsHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Published school, teacher, and system announcements available to this {audience}.'**
  String announcementsHeroSubtitle(Object audience);

  /// No description provided for @announcementsLatestSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Latest source'**
  String get announcementsLatestSourceLabel;

  /// No description provided for @announcementsNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get announcementsNone;

  /// No description provided for @announcementsUnreadCountTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1 {1 unread announcement} other {{count} unread announcements}}'**
  String announcementsUnreadCountTitle(int count);

  /// No description provided for @announcementsAllReadTitle.
  ///
  /// In en, this message translates to:
  /// **'Everything is read'**
  String get announcementsAllReadTitle;

  /// No description provided for @announcementsEmptyForAudience.
  ///
  /// In en, this message translates to:
  /// **'No announcements have been published to this {audience} yet.'**
  String announcementsEmptyForAudience(Object audience);

  /// No description provided for @announcementsLatestBody.
  ///
  /// In en, this message translates to:
  /// **'Latest: {title}. Tap it to read the full content.'**
  String announcementsLatestBody(Object title);

  /// No description provided for @announcementsFiltersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Narrow the inbox by source or by read state so you can focus on what still needs attention.'**
  String get announcementsFiltersSubtitle;

  /// No description provided for @announcementsAllAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'All announcements'**
  String get announcementsAllAnnouncements;

  /// No description provided for @announcementsSearchStatesHint.
  ///
  /// In en, this message translates to:
  /// **'Unread / Read'**
  String get announcementsSearchStatesHint;

  /// No description provided for @announcementsSummarySourceSegment.
  ///
  /// In en, this message translates to:
  /// **' from {source}'**
  String announcementsSummarySourceSegment(Object source);

  /// No description provided for @announcementsSummaryStateSegment.
  ///
  /// In en, this message translates to:
  /// **' in {state}'**
  String announcementsSummaryStateSegment(Object state);

  /// No description provided for @announcementsShowingSummary.
  ///
  /// In en, this message translates to:
  /// **'Showing {shown} of {total} announcements{sourceSegment}{stateSegment}.'**
  String announcementsShowingSummary(
    Object shown,
    Object total,
    Object sourceSegment,
    Object stateSegment,
  );

  /// No description provided for @announcementsNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No announcements match these filters'**
  String get announcementsNoMatchTitle;

  /// No description provided for @announcementsNoPublishedTitle.
  ///
  /// In en, this message translates to:
  /// **'No published announcements yet'**
  String get announcementsNoPublishedTitle;

  /// No description provided for @announcementsNoMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try a different source or switch back to all announcements to bring more items into view.'**
  String get announcementsNoMatchSubtitle;

  /// No description provided for @announcementsClearFiltersHint.
  ///
  /// In en, this message translates to:
  /// **'Clear filters to see everything again.'**
  String get announcementsClearFiltersHint;

  /// No description provided for @announcementsPullToRefreshHint.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh after new school activity is published.'**
  String get announcementsPullToRefreshHint;

  /// No description provided for @announcementsInboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get announcementsInboxTitle;

  /// No description provided for @announcementsInboxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only titles appear here for quick scanning. Tap any item to open the full announcement content.'**
  String get announcementsInboxSubtitle;

  /// No description provided for @meetingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'We could not load meetings right now. Pull to refresh or try again.'**
  String get meetingsLoadError;

  /// No description provided for @meetingsLoadTimeout.
  ///
  /// In en, this message translates to:
  /// **'Meetings are taking too long to load. Pull to refresh or try again in a moment.'**
  String get meetingsLoadTimeout;

  /// No description provided for @meetingsLoadNetwork.
  ///
  /// In en, this message translates to:
  /// **'Meetings could not connect right now. Check your connection and try again.'**
  String get meetingsLoadNetwork;

  /// No description provided for @meetingsHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every classroom meeting in one clean view, with attached links and a full-screen detail page when you need the context.'**
  String get meetingsHeroSubtitle;

  /// No description provided for @meetingsJoinReadyMetric.
  ///
  /// In en, this message translates to:
  /// **'Join-ready'**
  String get meetingsJoinReadyMetric;

  /// No description provided for @meetingsNoLinkMetric.
  ///
  /// In en, this message translates to:
  /// **'No link'**
  String get meetingsNoLinkMetric;

  /// No description provided for @meetingsNoPostedTitle.
  ///
  /// In en, this message translates to:
  /// **'No meetings posted yet'**
  String get meetingsNoPostedTitle;

  /// No description provided for @meetingsEmptyForAccount.
  ///
  /// In en, this message translates to:
  /// **'No classroom meetings are available for this student account right now.'**
  String get meetingsEmptyForAccount;

  /// No description provided for @meetingsLatestBody.
  ///
  /// In en, this message translates to:
  /// **'{title} was updated {updatedAt}. Open it for the attached link and classroom context.'**
  String meetingsLatestBody(Object title, Object updatedAt);

  /// No description provided for @meetingsPullToRefreshHint.
  ///
  /// In en, this message translates to:
  /// **'Pull down to check again.'**
  String get meetingsPullToRefreshHint;

  /// No description provided for @meetingsFiltersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Narrow the list by subject or by whether the meeting already includes a link you can open.'**
  String get meetingsFiltersSubtitle;

  /// No description provided for @meetingsAccessLabel.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get meetingsAccessLabel;

  /// No description provided for @meetingsAllMeetings.
  ///
  /// In en, this message translates to:
  /// **'All meetings'**
  String get meetingsAllMeetings;

  /// No description provided for @meetingsAccessReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to join'**
  String get meetingsAccessReady;

  /// No description provided for @meetingsAccessNoLink.
  ///
  /// In en, this message translates to:
  /// **'No link'**
  String get meetingsAccessNoLink;

  /// No description provided for @meetingsAccessNoLinkYet.
  ///
  /// In en, this message translates to:
  /// **'No link yet'**
  String get meetingsAccessNoLinkYet;

  /// No description provided for @meetingsAccessSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Ready to join / No link yet'**
  String get meetingsAccessSearchHint;

  /// No description provided for @meetingsSummarySubjectSegment.
  ///
  /// In en, this message translates to:
  /// **' for {subject}'**
  String meetingsSummarySubjectSegment(Object subject);

  /// No description provided for @meetingsSummaryAccessSegment.
  ///
  /// In en, this message translates to:
  /// **' in {state}'**
  String meetingsSummaryAccessSegment(Object state);

  /// No description provided for @meetingsShowingSummary.
  ///
  /// In en, this message translates to:
  /// **'Showing {shown} of {total} meetings{subjectSegment}{accessSegment}.'**
  String meetingsShowingSummary(
    Object shown,
    Object total,
    Object subjectSegment,
    Object accessSegment,
  );

  /// No description provided for @meetingsNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No meetings match these filters'**
  String get meetingsNoMatchTitle;

  /// No description provided for @meetingsNoMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try all subjects or include meetings without links to bring more results back into the list.'**
  String get meetingsNoMatchSubtitle;

  /// No description provided for @meetingsListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap any meeting to open the full-screen detail view and jump into its attached link when available.'**
  String get meetingsListSubtitle;

  /// No description provided for @meetingsDateTimeValue.
  ///
  /// In en, this message translates to:
  /// **'{date} • {time}'**
  String meetingsDateTimeValue(Object date, Object time);

  /// No description provided for @meetingsSharedByValue.
  ///
  /// In en, this message translates to:
  /// **'Shared by {name}'**
  String meetingsSharedByValue(Object name);

  /// No description provided for @meetingsPreviewFallback.
  ///
  /// In en, this message translates to:
  /// **'Open this meeting to see the attached link and the latest classroom details.'**
  String get meetingsPreviewFallback;

  /// No description provided for @meetingsNoValidLinkAttached.
  ///
  /// In en, this message translates to:
  /// **'No valid meeting link is attached yet.'**
  String get meetingsNoValidLinkAttached;

  /// No description provided for @meetingsCouldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open the meeting link.'**
  String get meetingsCouldNotOpenLink;

  /// No description provided for @meetingsNoLinkToCopy.
  ///
  /// In en, this message translates to:
  /// **'No meeting link to copy yet.'**
  String get meetingsNoLinkToCopy;

  /// No description provided for @meetingsLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Meeting link copied.'**
  String get meetingsLinkCopied;

  /// No description provided for @meetingsUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Meeting unavailable'**
  String get meetingsUnavailableTitle;

  /// No description provided for @meetingsUnavailableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This meeting could not be found in the current feed. It may have been removed or is not available offline.'**
  String get meetingsUnavailableSubtitle;

  /// No description provided for @meetingsUnavailableHint.
  ///
  /// In en, this message translates to:
  /// **'Go back and refresh the meetings list.'**
  String get meetingsUnavailableHint;

  /// No description provided for @meetingsNoLinkAttachedYet.
  ///
  /// In en, this message translates to:
  /// **'No link attached yet'**
  String get meetingsNoLinkAttachedYet;

  /// No description provided for @meetingsAttachedLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Attached meeting link'**
  String get meetingsAttachedLinkTitle;

  /// No description provided for @meetingsAttachedLinkMissingBody.
  ///
  /// In en, this message translates to:
  /// **'This meeting is visible in your classroom feed, but no valid URL is attached in the current student payload.'**
  String get meetingsAttachedLinkMissingBody;

  /// No description provided for @meetingsDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Meeting details'**
  String get meetingsDetailsTitle;

  /// No description provided for @meetingsDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything student-relevant that is currently available in the classroom meeting payload.'**
  String get meetingsDetailsSubtitle;

  /// No description provided for @meetingsDetailClassroomLabel.
  ///
  /// In en, this message translates to:
  /// **'Classroom'**
  String get meetingsDetailClassroomLabel;

  /// No description provided for @meetingsSharedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Shared by'**
  String get meetingsSharedByLabel;

  /// No description provided for @meetingsIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Meeting ID'**
  String get meetingsIdLabel;

  /// No description provided for @meetingsAttachedLinkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the attached URL to join or copy the meeting link when your classroom provides one.'**
  String get meetingsAttachedLinkSubtitle;

  /// No description provided for @meetingsOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening'**
  String get meetingsOpening;

  /// No description provided for @meetingsOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Open link'**
  String get meetingsOpenLink;

  /// No description provided for @meetingsCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get meetingsCopyLink;

  /// No description provided for @meetingsAccessPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Meeting access'**
  String get meetingsAccessPanelTitle;

  /// No description provided for @meetingsAccessPanelReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Open the attached URL in your browser or meeting app.'**
  String get meetingsAccessPanelReadyBody;

  /// No description provided for @meetingsJoinAction.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get meetingsJoinAction;

  /// No description provided for @announcementsDetailLoadFailedHint.
  ///
  /// In en, this message translates to:
  /// **'Go back and try refreshing the announcements inbox.'**
  String get announcementsDetailLoadFailedHint;

  /// No description provided for @announcementsUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcement unavailable'**
  String get announcementsUnavailableTitle;

  /// No description provided for @announcementsUnavailableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This announcement is no longer available in the published feed for this {audience}.'**
  String announcementsUnavailableSubtitle(Object audience);

  /// No description provided for @announcementsUnavailableHint.
  ///
  /// In en, this message translates to:
  /// **'Go back to the inbox to continue.'**
  String get announcementsUnavailableHint;

  /// No description provided for @announcementsPublishedReadStateBody.
  ///
  /// In en, this message translates to:
  /// **'This announcement was published to this {audience} and your read state is stored locally on this device.'**
  String announcementsPublishedReadStateBody(Object audience);

  /// No description provided for @announcementsDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcement details'**
  String get announcementsDetailsTitle;

  /// No description provided for @announcementsDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Published metadata for this announcement and its current read state.'**
  String get announcementsDetailsSubtitle;

  /// No description provided for @announcementsSeverityLabel.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get announcementsSeverityLabel;

  /// No description provided for @announcementsCreatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get announcementsCreatedLabel;

  /// No description provided for @announcementsIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Announcement ID'**
  String get announcementsIdLabel;

  /// No description provided for @announcementsFullContentTitle.
  ///
  /// In en, this message translates to:
  /// **'Full content'**
  String get announcementsFullContentTitle;

  /// No description provided for @announcementsFullContentSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The complete announcement text appears here after you open the item from the inbox.'**
  String get announcementsFullContentSubtitle;

  /// No description provided for @announcementsReadStateTitle.
  ///
  /// In en, this message translates to:
  /// **'Read state'**
  String get announcementsReadStateTitle;

  /// No description provided for @announcementsReadStateBodyRead.
  ///
  /// In en, this message translates to:
  /// **'This announcement is marked as read on this device.'**
  String get announcementsReadStateBodyRead;

  /// No description provided for @announcementsReadStateBodyUnread.
  ///
  /// In en, this message translates to:
  /// **'This announcement is still unread on this device.'**
  String get announcementsReadStateBodyUnread;

  /// No description provided for @alertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alertsTitle;

  /// No description provided for @alertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This is the page for things that need attention now, not just general updates.'**
  String get alertsSubtitle;

  /// No description provided for @alertsAttendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance needs attention'**
  String get alertsAttendanceTitle;

  /// No description provided for @alertsAttendanceBody.
  ///
  /// In en, this message translates to:
  /// **'Your attendance rate is {rate}%. A couple of missed lessons can snowball fast.'**
  String alertsAttendanceBody(Object rate);

  /// No description provided for @alertsWeakestSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Weakest subject signal'**
  String get alertsWeakestSubjectTitle;

  /// No description provided for @alertsWeakestSubjectBody.
  ///
  /// In en, this message translates to:
  /// **'{subject} currently needs the most attention based on your latest grades.'**
  String alertsWeakestSubjectBody(Object subject);

  /// No description provided for @alertsPracticeWeakAreaTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice weak area'**
  String get alertsPracticeWeakAreaTitle;

  /// No description provided for @alertsPracticeWeakAreaBody.
  ///
  /// In en, this message translates to:
  /// **'{topic} in {subject} is the clearest weak topic right now.'**
  String alertsPracticeWeakAreaBody(Object topic, Object subject);

  /// No description provided for @alertsPracticeTrendDroppedTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice trend dropped'**
  String get alertsPracticeTrendDroppedTitle;

  /// No description provided for @alertsPracticeTrendDroppedBody.
  ///
  /// In en, this message translates to:
  /// **'Your 7d performance is below your 30d baseline. Slow down and revisit fundamentals before pushing harder.'**
  String get alertsPracticeTrendDroppedBody;

  /// No description provided for @alertsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You\'re clear right now. When something needs urgent attention, it\'ll show up here.'**
  String get alertsEmpty;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @classroomDetailPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get classroomDetailPhoto;

  /// No description provided for @classroomDetailVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Voice note'**
  String get classroomDetailVoiceNote;

  /// No description provided for @classroomDetailVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get classroomDetailVideo;

  /// No description provided for @classroomDetailFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get classroomDetailFile;

  /// No description provided for @classroomDetailEmptyValue.
  ///
  /// In en, this message translates to:
  /// **'(empty)'**
  String get classroomDetailEmptyValue;

  /// No description provided for @classroomDetailAttachmentUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Attachment unavailable.'**
  String get classroomDetailAttachmentUnavailable;

  /// No description provided for @classroomDetailAudioUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Audio unavailable.'**
  String get classroomDetailAudioUnavailable;

  /// No description provided for @classroomDetailCouldNotOpenAttachment.
  ///
  /// In en, this message translates to:
  /// **'Could not open attachment.'**
  String get classroomDetailCouldNotOpenAttachment;

  /// No description provided for @classroomDetailVoiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Voice message'**
  String get classroomDetailVoiceMessage;

  /// No description provided for @classroomDetailVideoFile.
  ///
  /// In en, this message translates to:
  /// **'Video file'**
  String get classroomDetailVideoFile;

  /// No description provided for @classroomDetailAttachedFile.
  ///
  /// In en, this message translates to:
  /// **'Attached file'**
  String get classroomDetailAttachedFile;

  /// No description provided for @classroomDetailAttachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get classroomDetailAttachment;

  /// No description provided for @classroomDetailPinAction.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get classroomDetailPinAction;

  /// No description provided for @classroomDetailUnpinAction.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get classroomDetailUnpinAction;

  /// No description provided for @classroomDetailMessageInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Message info'**
  String get classroomDetailMessageInfoTitle;

  /// No description provided for @classroomDetailForwardedSingle.
  ///
  /// In en, this message translates to:
  /// **'Forwarded'**
  String get classroomDetailForwardedSingle;

  /// No description provided for @classroomDetailForwardedMultiple.
  ///
  /// In en, this message translates to:
  /// **'Forwarded {count} messages'**
  String classroomDetailForwardedMultiple(Object count);

  /// No description provided for @classroomDetailCannotForwardPending.
  ///
  /// In en, this message translates to:
  /// **'Cannot forward into a request chat until it is approved'**
  String get classroomDetailCannotForwardPending;

  /// No description provided for @classroomDetailCouldNotForwardSelected.
  ///
  /// In en, this message translates to:
  /// **'Could not forward selected messages'**
  String get classroomDetailCouldNotForwardSelected;

  /// No description provided for @classroomDetailSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String classroomDetailSelectedCount(Object count);

  /// No description provided for @classroomDetailDeleteCount.
  ///
  /// In en, this message translates to:
  /// **'Delete ({count})'**
  String classroomDetailDeleteCount(Object count);

  /// No description provided for @classroomDetailSelectAllTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get classroomDetailSelectAllTooltip;

  /// No description provided for @classroomDetailCancelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get classroomDetailCancelTooltip;

  /// No description provided for @classroomDetailMicrophoneAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Microphone access needed'**
  String get classroomDetailMicrophoneAccessTitle;

  /// No description provided for @classroomDetailMicrophoneAccessBody.
  ///
  /// In en, this message translates to:
  /// **'Please allow microphone access in Settings -> ClassMate to send voice notes.'**
  String get classroomDetailMicrophoneAccessBody;

  /// No description provided for @classroomDetailOpenSettingsAction.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get classroomDetailOpenSettingsAction;

  /// No description provided for @classroomDetailForwardTargetNext.
  ///
  /// In en, this message translates to:
  /// **'Forward target picker next: {label}'**
  String classroomDetailForwardTargetNext(Object label);

  /// No description provided for @classroomDetailEditMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get classroomDetailEditMessageTitle;

  /// No description provided for @classroomDetailEditMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Edit your message...'**
  String get classroomDetailEditMessageHint;

  /// No description provided for @classroomDetailLeaveClassroomTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave classroom?'**
  String get classroomDetailLeaveClassroomTitle;

  /// No description provided for @classroomDetailLeaveClassroomBody.
  ///
  /// In en, this message translates to:
  /// **'You will be removed from this classroom.'**
  String get classroomDetailLeaveClassroomBody;

  /// No description provided for @classroomDetailLeaveAction.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get classroomDetailLeaveAction;

  /// No description provided for @classroomDetailNoAssignmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'No assignments yet'**
  String get classroomDetailNoAssignmentsTitle;

  /// No description provided for @classroomDetailNoAssignmentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This classroom has no assignments right now.'**
  String get classroomDetailNoAssignmentsSubtitle;

  /// No description provided for @classroomDetailAssignmentFallback.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get classroomDetailAssignmentFallback;

  /// No description provided for @classroomDetailNoMaterialsTitle.
  ///
  /// In en, this message translates to:
  /// **'No materials yet'**
  String get classroomDetailNoMaterialsTitle;

  /// No description provided for @classroomDetailNoMaterialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This classroom has no materials right now.'**
  String get classroomDetailNoMaterialsSubtitle;

  /// No description provided for @classroomDetailMaterialFallback.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get classroomDetailMaterialFallback;

  /// No description provided for @classroomDetailNoMeetingsTitle.
  ///
  /// In en, this message translates to:
  /// **'No meetings yet'**
  String get classroomDetailNoMeetingsTitle;

  /// No description provided for @classroomDetailNoMeetingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This classroom has no meetings right now.'**
  String get classroomDetailNoMeetingsSubtitle;

  /// No description provided for @classroomDetailMeetingFallback.
  ///
  /// In en, this message translates to:
  /// **'Meeting'**
  String get classroomDetailMeetingFallback;

  /// No description provided for @classroomDetailCouldNotLoadPeople.
  ///
  /// In en, this message translates to:
  /// **'Could not load people'**
  String get classroomDetailCouldNotLoadPeople;

  /// No description provided for @classroomDetailNoPeopleTitle.
  ///
  /// In en, this message translates to:
  /// **'No people yet'**
  String get classroomDetailNoPeopleTitle;

  /// No description provided for @classroomDetailNoPeopleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nobody is visible in this classroom yet.'**
  String get classroomDetailNoPeopleSubtitle;

  /// No description provided for @classroomDetailTabChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get classroomDetailTabChat;

  /// No description provided for @classroomDetailTabMaterials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get classroomDetailTabMaterials;

  /// No description provided for @classroomDetailTabPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get classroomDetailTabPeople;

  /// No description provided for @classroomChatMediaSendPhoto.
  ///
  /// In en, this message translates to:
  /// **'Send photo'**
  String get classroomChatMediaSendPhoto;

  /// No description provided for @classroomChatMediaSendPhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share an image in the classroom chat'**
  String get classroomChatMediaSendPhotoSubtitle;

  /// No description provided for @classroomChatMediaSendVoiceMessage.
  ///
  /// In en, this message translates to:
  /// **'Send voice message'**
  String get classroomChatMediaSendVoiceMessage;

  /// No description provided for @classroomChatMediaSendVoiceMessageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Record and send a voice note'**
  String get classroomChatMediaSendVoiceMessageSubtitle;

  /// No description provided for @classroomDetailCouldNotLoadTab.
  ///
  /// In en, this message translates to:
  /// **'Could not load tab'**
  String get classroomDetailCouldNotLoadTab;

  /// No description provided for @classroomDetailDeletedByYou.
  ///
  /// In en, this message translates to:
  /// **'You deleted this message'**
  String get classroomDetailDeletedByYou;

  /// No description provided for @classroomDetailDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'This message was deleted'**
  String get classroomDetailDeletedMessage;

  /// No description provided for @practiceSetupDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get practiceSetupDifficultyEasy;

  /// No description provided for @practiceSetupDifficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get practiceSetupDifficultyMedium;

  /// No description provided for @practiceSetupDifficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get practiceSetupDifficultyHard;

  /// No description provided for @practiceSetupDifficultyOlympiad.
  ///
  /// In en, this message translates to:
  /// **'Olympiad'**
  String get practiceSetupDifficultyOlympiad;

  /// No description provided for @practiceSetupDifficultyAdaptive.
  ///
  /// In en, this message translates to:
  /// **'Adaptive'**
  String get practiceSetupDifficultyAdaptive;

  /// No description provided for @practiceSetupModeLabelPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceSetupModeLabelPractice;

  /// No description provided for @practiceSetupModeLabelFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get practiceSetupModeLabelFlashcards;

  /// No description provided for @practiceSetupModeLabelSpeedRound.
  ///
  /// In en, this message translates to:
  /// **'Speed round'**
  String get practiceSetupModeLabelSpeedRound;

  /// No description provided for @practiceSetupModeLabelExamPrep.
  ///
  /// In en, this message translates to:
  /// **'Exam prep'**
  String get practiceSetupModeLabelExamPrep;

  /// No description provided for @practiceSetupModeLabelConceptBuilder.
  ///
  /// In en, this message translates to:
  /// **'Concept builder'**
  String get practiceSetupModeLabelConceptBuilder;

  /// No description provided for @practiceSetupModeLabelAdaptive.
  ///
  /// In en, this message translates to:
  /// **'Adaptive'**
  String get practiceSetupModeLabelAdaptive;

  /// No description provided for @practiceSetupModeLabelBagrut.
  ///
  /// In en, this message translates to:
  /// **'Bagrut'**
  String get practiceSetupModeLabelBagrut;

  /// No description provided for @practiceSetupModeSubtitlePractice.
  ///
  /// In en, this message translates to:
  /// **'Balanced daily practice'**
  String get practiceSetupModeSubtitlePractice;

  /// No description provided for @practiceSetupModeSubtitleFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Reveal and self-recall'**
  String get practiceSetupModeSubtitleFlashcards;

  /// No description provided for @practiceSetupModeSubtitleSpeedRound.
  ///
  /// In en, this message translates to:
  /// **'Fast pressure drill'**
  String get practiceSetupModeSubtitleSpeedRound;

  /// No description provided for @practiceSetupModeSubtitleExamPrep.
  ///
  /// In en, this message translates to:
  /// **'Calm exam-style flow'**
  String get practiceSetupModeSubtitleExamPrep;

  /// No description provided for @practiceSetupModeSubtitleConceptBuilder.
  ///
  /// In en, this message translates to:
  /// **'Concept first, solve later'**
  String get practiceSetupModeSubtitleConceptBuilder;

  /// No description provided for @practiceSetupModeSubtitleAdaptive.
  ///
  /// In en, this message translates to:
  /// **'Difficulty shifts live'**
  String get practiceSetupModeSubtitleAdaptive;

  /// No description provided for @practiceSetupModeSubtitleBagrut.
  ///
  /// In en, this message translates to:
  /// **'Strict official style'**
  String get practiceSetupModeSubtitleBagrut;

  /// No description provided for @practiceSetupModeHelpPractice.
  ///
  /// In en, this message translates to:
  /// **'Balanced mode: solve, check, explain, then keep moving.'**
  String get practiceSetupModeHelpPractice;

  /// No description provided for @practiceSetupModeHelpFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards work best when you try to recall before revealing.'**
  String get practiceSetupModeHelpFlashcards;

  /// No description provided for @practiceSetupModeHelpSpeedRound.
  ///
  /// In en, this message translates to:
  /// **'Speed Round trains fast recall. Move quickly and trust strong instincts.'**
  String get practiceSetupModeHelpSpeedRound;

  /// No description provided for @practiceSetupModeHelpExamPrep.
  ///
  /// In en, this message translates to:
  /// **'Exam Prep is calmer and more formal, like a real school session.'**
  String get practiceSetupModeHelpExamPrep;

  /// No description provided for @practiceSetupModeHelpConceptBuilder.
  ///
  /// In en, this message translates to:
  /// **'Concept Builder teaches the idea first, then asks you to apply it.'**
  String get practiceSetupModeHelpConceptBuilder;

  /// No description provided for @practiceSetupModeHelpAdaptive.
  ///
  /// In en, this message translates to:
  /// **'Adaptive mode changes the challenge level based on your performance.'**
  String get practiceSetupModeHelpAdaptive;

  /// No description provided for @practiceSetupModeHelpBagrut.
  ///
  /// In en, this message translates to:
  /// **'Bagrut mode focuses on strict exam-style solving and review.'**
  String get practiceSetupModeHelpBagrut;

  /// No description provided for @practiceSetupModeInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'How each mode works'**
  String get practiceSetupModeInfoTitle;

  /// No description provided for @practiceSetupHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a session'**
  String get practiceSetupHeroTitle;

  /// No description provided for @practiceSetupHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a mode, timing, and difficulty.'**
  String get practiceSetupHeroSubtitle;

  /// No description provided for @practiceSetupInfiniteLives.
  ///
  /// In en, this message translates to:
  /// **'Infinite lives'**
  String get practiceSetupInfiniteLives;

  /// No description provided for @practiceSetupLivesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} lives'**
  String practiceSetupLivesCount(Object count);

  /// No description provided for @practiceSetupAiTiming.
  ///
  /// In en, this message translates to:
  /// **'AI timing'**
  String get practiceSetupAiTiming;

  /// No description provided for @practiceSetupSecondsShort.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String practiceSetupSecondsShort(Object seconds);

  /// No description provided for @practiceSetupQuestionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String practiceSetupQuestionsCount(Object count);

  /// No description provided for @practiceSetupSummarySubject.
  ///
  /// In en, this message translates to:
  /// **'Subject: {subject}'**
  String practiceSetupSummarySubject(Object subject);

  /// No description provided for @practiceSetupSummaryTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic: {topic}'**
  String practiceSetupSummaryTopic(Object topic);

  /// No description provided for @practiceSetupSummaryMode.
  ///
  /// In en, this message translates to:
  /// **'Mode: {mode}'**
  String practiceSetupSummaryMode(Object mode);

  /// No description provided for @practiceSetupSummaryDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty: {difficulty}'**
  String practiceSetupSummaryDifficulty(Object difficulty);

  /// No description provided for @practiceSetupSummaryQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions: {count}'**
  String practiceSetupSummaryQuestions(Object count);

  /// No description provided for @practiceSetupSummaryTiming.
  ///
  /// In en, this message translates to:
  /// **'Timing: {timing}'**
  String practiceSetupSummaryTiming(Object timing);

  /// No description provided for @practiceSetupSummaryLives.
  ///
  /// In en, this message translates to:
  /// **'Lives: {lives}'**
  String practiceSetupSummaryLives(Object lives);

  /// No description provided for @practiceSetupSectionSubjectTopic.
  ///
  /// In en, this message translates to:
  /// **'Subject & topic'**
  String get practiceSetupSectionSubjectTopic;

  /// No description provided for @practiceSetupFieldSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get practiceSetupFieldSubject;

  /// No description provided for @practiceSetupFieldSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'Pick the subject'**
  String get practiceSetupFieldSubjectHint;

  /// No description provided for @practiceSetupChooseSubject.
  ///
  /// In en, this message translates to:
  /// **'Choose subject'**
  String get practiceSetupChooseSubject;

  /// No description provided for @practiceSetupFieldCustomSubject.
  ///
  /// In en, this message translates to:
  /// **'Custom subject'**
  String get practiceSetupFieldCustomSubject;

  /// No description provided for @practiceSetupFieldCustomSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'Type your own subject'**
  String get practiceSetupFieldCustomSubjectHint;

  /// No description provided for @practiceSetupDialogCustomSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom subject'**
  String get practiceSetupDialogCustomSubjectTitle;

  /// No description provided for @practiceSetupDialogEnterSubject.
  ///
  /// In en, this message translates to:
  /// **'Enter subject'**
  String get practiceSetupDialogEnterSubject;

  /// No description provided for @practiceSetupUseAction.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get practiceSetupUseAction;

  /// No description provided for @practiceSetupFieldTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get practiceSetupFieldTopic;

  /// No description provided for @practiceSetupFieldTopicHint.
  ///
  /// In en, this message translates to:
  /// **'Pick sub-topic'**
  String get practiceSetupFieldTopicHint;

  /// No description provided for @practiceSetupChooseTopic.
  ///
  /// In en, this message translates to:
  /// **'Choose topic'**
  String get practiceSetupChooseTopic;

  /// No description provided for @practiceSetupFieldCustomTopic.
  ///
  /// In en, this message translates to:
  /// **'Custom topic'**
  String get practiceSetupFieldCustomTopic;

  /// No description provided for @practiceSetupFieldCustomTopicHint.
  ///
  /// In en, this message translates to:
  /// **'Type your own topic'**
  String get practiceSetupFieldCustomTopicHint;

  /// No description provided for @practiceSetupDialogCustomTopicTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom topic'**
  String get practiceSetupDialogCustomTopicTitle;

  /// No description provided for @practiceSetupDialogEnterTopic.
  ///
  /// In en, this message translates to:
  /// **'Enter topic'**
  String get practiceSetupDialogEnterTopic;

  /// No description provided for @practiceSubjectMath.
  ///
  /// In en, this message translates to:
  /// **'Math'**
  String get practiceSubjectMath;

  /// No description provided for @practiceSubjectPhysics.
  ///
  /// In en, this message translates to:
  /// **'Physics'**
  String get practiceSubjectPhysics;

  /// No description provided for @practiceSubjectComputerScience.
  ///
  /// In en, this message translates to:
  /// **'Computer Science'**
  String get practiceSubjectComputerScience;

  /// No description provided for @practiceSubjectChemistry.
  ///
  /// In en, this message translates to:
  /// **'Chemistry'**
  String get practiceSubjectChemistry;

  /// No description provided for @practiceSubjectBiology.
  ///
  /// In en, this message translates to:
  /// **'Biology'**
  String get practiceSubjectBiology;

  /// No description provided for @practiceSubjectEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get practiceSubjectEnglish;

  /// No description provided for @practiceSubjectArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get practiceSubjectArabic;

  /// No description provided for @practiceSubjectHebrew.
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get practiceSubjectHebrew;

  /// No description provided for @practiceSubjectGeneralKnowledge.
  ///
  /// In en, this message translates to:
  /// **'General Knowledge'**
  String get practiceSubjectGeneralKnowledge;

  /// No description provided for @practiceTopicAllTopics.
  ///
  /// In en, this message translates to:
  /// **'All topics'**
  String get practiceTopicAllTopics;

  /// No description provided for @practiceTopicAlgebra.
  ///
  /// In en, this message translates to:
  /// **'Algebra'**
  String get practiceTopicAlgebra;

  /// No description provided for @practiceTopicLinearEquations.
  ///
  /// In en, this message translates to:
  /// **'Linear equations'**
  String get practiceTopicLinearEquations;

  /// No description provided for @practiceTopicQuadraticEquations.
  ///
  /// In en, this message translates to:
  /// **'Quadratic equations'**
  String get practiceTopicQuadraticEquations;

  /// No description provided for @practiceTopicFunctions.
  ///
  /// In en, this message translates to:
  /// **'Functions'**
  String get practiceTopicFunctions;

  /// No description provided for @practiceTopicGeometry.
  ///
  /// In en, this message translates to:
  /// **'Geometry'**
  String get practiceTopicGeometry;

  /// No description provided for @practiceTopicTriangles.
  ///
  /// In en, this message translates to:
  /// **'Triangles'**
  String get practiceTopicTriangles;

  /// No description provided for @practiceTopicCircles.
  ///
  /// In en, this message translates to:
  /// **'Circles'**
  String get practiceTopicCircles;

  /// No description provided for @practiceTopicAnalyticGeometry.
  ///
  /// In en, this message translates to:
  /// **'Analytic geometry'**
  String get practiceTopicAnalyticGeometry;

  /// No description provided for @practiceTopicTrigonometry.
  ///
  /// In en, this message translates to:
  /// **'Trigonometry'**
  String get practiceTopicTrigonometry;

  /// No description provided for @practiceTopicProbability.
  ///
  /// In en, this message translates to:
  /// **'Probability'**
  String get practiceTopicProbability;

  /// No description provided for @practiceTopicStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get practiceTopicStatistics;

  /// No description provided for @practiceTopicSequences.
  ///
  /// In en, this message translates to:
  /// **'Sequences'**
  String get practiceTopicSequences;

  /// No description provided for @practiceTopicCalculus.
  ///
  /// In en, this message translates to:
  /// **'Calculus'**
  String get practiceTopicCalculus;

  /// No description provided for @practiceTopicLimits.
  ///
  /// In en, this message translates to:
  /// **'Limits'**
  String get practiceTopicLimits;

  /// No description provided for @practiceTopicDerivatives.
  ///
  /// In en, this message translates to:
  /// **'Derivatives'**
  String get practiceTopicDerivatives;

  /// No description provided for @practiceTopicMechanics.
  ///
  /// In en, this message translates to:
  /// **'Mechanics'**
  String get practiceTopicMechanics;

  /// No description provided for @practiceTopicKinematics.
  ///
  /// In en, this message translates to:
  /// **'Kinematics'**
  String get practiceTopicKinematics;

  /// No description provided for @practiceTopicNewtonLaws.
  ///
  /// In en, this message translates to:
  /// **'Newton laws'**
  String get practiceTopicNewtonLaws;

  /// No description provided for @practiceTopicForces.
  ///
  /// In en, this message translates to:
  /// **'Forces'**
  String get practiceTopicForces;

  /// No description provided for @practiceTopicEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get practiceTopicEnergy;

  /// No description provided for @practiceTopicMomentum.
  ///
  /// In en, this message translates to:
  /// **'Momentum'**
  String get practiceTopicMomentum;

  /// No description provided for @practiceTopicElectricity.
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get practiceTopicElectricity;

  /// No description provided for @practiceTopicElectricField.
  ///
  /// In en, this message translates to:
  /// **'Electric field'**
  String get practiceTopicElectricField;

  /// No description provided for @practiceTopicCircuits.
  ///
  /// In en, this message translates to:
  /// **'Circuits'**
  String get practiceTopicCircuits;

  /// No description provided for @practiceTopicWaves.
  ///
  /// In en, this message translates to:
  /// **'Waves'**
  String get practiceTopicWaves;

  /// No description provided for @practiceTopicOptics.
  ///
  /// In en, this message translates to:
  /// **'Optics'**
  String get practiceTopicOptics;

  /// No description provided for @practiceTopicThermodynamics.
  ///
  /// In en, this message translates to:
  /// **'Thermodynamics'**
  String get practiceTopicThermodynamics;

  /// No description provided for @practiceTopicConditions.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get practiceTopicConditions;

  /// No description provided for @practiceTopicBooleanLogic.
  ///
  /// In en, this message translates to:
  /// **'Boolean logic'**
  String get practiceTopicBooleanLogic;

  /// No description provided for @practiceTopicIfElse.
  ///
  /// In en, this message translates to:
  /// **'If / Else'**
  String get practiceTopicIfElse;

  /// No description provided for @practiceTopicNestedConditions.
  ///
  /// In en, this message translates to:
  /// **'Nested conditions'**
  String get practiceTopicNestedConditions;

  /// No description provided for @practiceTopicLoops.
  ///
  /// In en, this message translates to:
  /// **'Loops'**
  String get practiceTopicLoops;

  /// No description provided for @practiceTopicVariables.
  ///
  /// In en, this message translates to:
  /// **'Variables'**
  String get practiceTopicVariables;

  /// No description provided for @practiceTopicArrays.
  ///
  /// In en, this message translates to:
  /// **'Arrays'**
  String get practiceTopicArrays;

  /// No description provided for @practiceTopicStrings.
  ///
  /// In en, this message translates to:
  /// **'Strings'**
  String get practiceTopicStrings;

  /// No description provided for @practiceTopicAlgorithms.
  ///
  /// In en, this message translates to:
  /// **'Algorithms'**
  String get practiceTopicAlgorithms;

  /// No description provided for @practiceTopicComplexity.
  ///
  /// In en, this message translates to:
  /// **'Complexity'**
  String get practiceTopicComplexity;

  /// No description provided for @practiceTopicRecursion.
  ///
  /// In en, this message translates to:
  /// **'Recursion'**
  String get practiceTopicRecursion;

  /// No description provided for @practiceTopicAtoms.
  ///
  /// In en, this message translates to:
  /// **'Atoms'**
  String get practiceTopicAtoms;

  /// No description provided for @practiceTopicPeriodicTable.
  ///
  /// In en, this message translates to:
  /// **'Periodic table'**
  String get practiceTopicPeriodicTable;

  /// No description provided for @practiceTopicChemicalBonds.
  ///
  /// In en, this message translates to:
  /// **'Chemical bonds'**
  String get practiceTopicChemicalBonds;

  /// No description provided for @practiceTopicReactions.
  ///
  /// In en, this message translates to:
  /// **'Reactions'**
  String get practiceTopicReactions;

  /// No description provided for @practiceTopicStoichiometry.
  ///
  /// In en, this message translates to:
  /// **'Stoichiometry'**
  String get practiceTopicStoichiometry;

  /// No description provided for @practiceTopicAcidsAndBases.
  ///
  /// In en, this message translates to:
  /// **'Acids and bases'**
  String get practiceTopicAcidsAndBases;

  /// No description provided for @practiceTopicOrganicChemistry.
  ///
  /// In en, this message translates to:
  /// **'Organic chemistry'**
  String get practiceTopicOrganicChemistry;

  /// No description provided for @practiceTopicCells.
  ///
  /// In en, this message translates to:
  /// **'Cells'**
  String get practiceTopicCells;

  /// No description provided for @practiceTopicGenetics.
  ///
  /// In en, this message translates to:
  /// **'Genetics'**
  String get practiceTopicGenetics;

  /// No description provided for @practiceTopicHumanBody.
  ///
  /// In en, this message translates to:
  /// **'Human body'**
  String get practiceTopicHumanBody;

  /// No description provided for @practiceTopicEcology.
  ///
  /// In en, this message translates to:
  /// **'Ecology'**
  String get practiceTopicEcology;

  /// No description provided for @practiceTopicEvolution.
  ///
  /// In en, this message translates to:
  /// **'Evolution'**
  String get practiceTopicEvolution;

  /// No description provided for @practiceTopicSystems.
  ///
  /// In en, this message translates to:
  /// **'Systems'**
  String get practiceTopicSystems;

  /// No description provided for @practiceTopicGrammar.
  ///
  /// In en, this message translates to:
  /// **'Grammar'**
  String get practiceTopicGrammar;

  /// No description provided for @practiceTopicReadingComprehension.
  ///
  /// In en, this message translates to:
  /// **'Reading comprehension'**
  String get practiceTopicReadingComprehension;

  /// No description provided for @practiceTopicVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get practiceTopicVocabulary;

  /// No description provided for @practiceTopicTenses.
  ///
  /// In en, this message translates to:
  /// **'Tenses'**
  String get practiceTopicTenses;

  /// No description provided for @practiceTopicWriting.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get practiceTopicWriting;

  /// No description provided for @practiceTopicRhetoric.
  ///
  /// In en, this message translates to:
  /// **'Rhetoric'**
  String get practiceTopicRhetoric;

  /// No description provided for @practiceSetupSectionMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get practiceSetupSectionMode;

  /// No description provided for @practiceSetupSectionDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get practiceSetupSectionDifficulty;

  /// No description provided for @practiceSetupSectionControls.
  ///
  /// In en, this message translates to:
  /// **'Session controls'**
  String get practiceSetupSectionControls;

  /// No description provided for @practiceSetupQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get practiceSetupQuestionsTitle;

  /// No description provided for @practiceSetupQuestionsCaption.
  ///
  /// In en, this message translates to:
  /// **'How many generated questions to include'**
  String get practiceSetupQuestionsCaption;

  /// No description provided for @practiceSetupTimingTitle.
  ///
  /// In en, this message translates to:
  /// **'Timing'**
  String get practiceSetupTimingTitle;

  /// No description provided for @practiceSetupTimingCaption.
  ///
  /// In en, this message translates to:
  /// **'Choose scope first, then AI, your own time, or infinite.'**
  String get practiceSetupTimingCaption;

  /// No description provided for @practiceSetupTimingScopePerQuestion.
  ///
  /// In en, this message translates to:
  /// **'Per question'**
  String get practiceSetupTimingScopePerQuestion;

  /// No description provided for @practiceSetupTimingScopeWholeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Whole quiz'**
  String get practiceSetupTimingScopeWholeQuiz;

  /// No description provided for @practiceSetupTimingModeAi.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get practiceSetupTimingModeAi;

  /// No description provided for @practiceSetupTimingModeMyTime.
  ///
  /// In en, this message translates to:
  /// **'My time'**
  String get practiceSetupTimingModeMyTime;

  /// No description provided for @practiceSetupTimingModeInfinite.
  ///
  /// In en, this message translates to:
  /// **'Infinite'**
  String get practiceSetupTimingModeInfinite;

  /// No description provided for @practiceSetupTimingCustomPerQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Seconds per question'**
  String get practiceSetupTimingCustomPerQuestionTitle;

  /// No description provided for @practiceSetupTimingCustomPerQuestionCaption.
  ///
  /// In en, this message translates to:
  /// **'Your own timer for each question'**
  String get practiceSetupTimingCustomPerQuestionCaption;

  /// No description provided for @practiceSetupTimingCustomQuizMinutesTitle.
  ///
  /// In en, this message translates to:
  /// **'Quiz minutes'**
  String get practiceSetupTimingCustomQuizMinutesTitle;

  /// No description provided for @practiceSetupTimingCustomQuizMinutesCaption.
  ///
  /// In en, this message translates to:
  /// **'Your own timer for the whole quiz'**
  String get practiceSetupTimingCustomQuizMinutesCaption;

  /// No description provided for @practiceSetupInfiniteLivesTitle.
  ///
  /// In en, this message translates to:
  /// **'Infinite lives'**
  String get practiceSetupInfiniteLivesTitle;

  /// No description provided for @practiceSetupInfiniteLivesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Never end the session because of wrong answers'**
  String get practiceSetupInfiniteLivesSubtitle;

  /// No description provided for @practiceSetupLivesTitle.
  ///
  /// In en, this message translates to:
  /// **'Lives'**
  String get practiceSetupLivesTitle;

  /// No description provided for @practiceSetupLivesCaption.
  ///
  /// In en, this message translates to:
  /// **'Mistakes allowed before the session ends'**
  String get practiceSetupLivesCaption;

  /// No description provided for @practiceSetupTooltipHistory.
  ///
  /// In en, this message translates to:
  /// **'Practice history'**
  String get practiceSetupTooltipHistory;

  /// No description provided for @practiceHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice history'**
  String get practiceHistoryTitle;

  /// No description provided for @practiceHistoryClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get practiceHistoryClearTooltip;

  /// No description provided for @practiceHistoryClearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear practice history?'**
  String get practiceHistoryClearConfirmTitle;

  /// No description provided for @practiceHistoryClearConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This removes all saved practice sessions from this device.'**
  String get practiceHistoryClearConfirmBody;

  /// No description provided for @practiceHistoryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load practice history right now.'**
  String get practiceHistoryLoadError;

  /// No description provided for @practiceHistoryErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error:'**
  String get practiceHistoryErrorPrefix;

  /// No description provided for @practiceHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No practice sessions yet.'**
  String get practiceHistoryEmpty;

  /// No description provided for @practiceHistoryDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this session?'**
  String get practiceHistoryDeleteConfirmTitle;

  /// No description provided for @practiceHistoryDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This removes only this saved practice session.'**
  String get practiceHistoryDeleteConfirmBody;

  /// No description provided for @practiceHistoryOpenReview.
  ///
  /// In en, this message translates to:
  /// **'Open review'**
  String get practiceHistoryOpenReview;

  /// No description provided for @practiceHistoryDeleteSession.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get practiceHistoryDeleteSession;

  /// No description provided for @practiceHistoryDebugTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice history debug'**
  String get practiceHistoryDebugTitle;

  /// No description provided for @practiceAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice analytics'**
  String get practiceAnalyticsTitle;

  /// No description provided for @practiceAnalyticsSectionOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get practiceAnalyticsSectionOverall;

  /// No description provided for @practiceAnalyticsRecentSessionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent sessions'**
  String get practiceAnalyticsRecentSessionsTitle;

  /// No description provided for @practiceAnalyticsRecentSessionsSummary.
  ///
  /// In en, this message translates to:
  /// **'{sessions} sessions • {correct}/{answered} correct • {accuracy}% • XP {xp}'**
  String practiceAnalyticsRecentSessionsSummary(
    Object sessions,
    Object correct,
    Object answered,
    Object accuracy,
    Object xp,
  );

  /// No description provided for @practiceAnalyticsSectionWeakestTopics.
  ///
  /// In en, this message translates to:
  /// **'Weakest topics'**
  String get practiceAnalyticsSectionWeakestTopics;

  /// No description provided for @practiceAnalyticsSectionStrongestTopics.
  ///
  /// In en, this message translates to:
  /// **'Strongest topics'**
  String get practiceAnalyticsSectionStrongestTopics;

  /// No description provided for @practiceAnalyticsSectionModePerformance.
  ///
  /// In en, this message translates to:
  /// **'Mode performance'**
  String get practiceAnalyticsSectionModePerformance;

  /// No description provided for @practiceAnalyticsNoTopicData.
  ///
  /// In en, this message translates to:
  /// **'No topic data yet'**
  String get practiceAnalyticsNoTopicData;

  /// No description provided for @practiceAnalyticsNoModeData.
  ///
  /// In en, this message translates to:
  /// **'No mode data yet'**
  String get practiceAnalyticsNoModeData;

  /// No description provided for @savedQuestionsTopSubjectNone.
  ///
  /// In en, this message translates to:
  /// **'None yet'**
  String get savedQuestionsTopSubjectNone;

  /// No description provided for @savedQuestionsHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Questions you saved during practice should feel easy to revisit. This page is the clean retry hub for them.'**
  String get savedQuestionsHeroSubtitle;

  /// No description provided for @savedQuestionsSavedMetric.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get savedQuestionsSavedMetric;

  /// No description provided for @savedQuestionsTopSubjectMetric.
  ///
  /// In en, this message translates to:
  /// **'Top subject'**
  String get savedQuestionsTopSubjectMetric;

  /// No description provided for @savedQuestionsQuickActionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Jump straight back into practice or browse community solutions.'**
  String get savedQuestionsQuickActionsSubtitle;

  /// No description provided for @savedQuestionsOpenPractice.
  ///
  /// In en, this message translates to:
  /// **'Open practice'**
  String get savedQuestionsOpenPractice;

  /// No description provided for @savedQuestionsOpenPracticeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a fresh session and keep building momentum'**
  String get savedQuestionsOpenPracticeSubtitle;

  /// No description provided for @savedQuestionsOpenSolutions.
  ///
  /// In en, this message translates to:
  /// **'Open solutions'**
  String get savedQuestionsOpenSolutions;

  /// No description provided for @savedQuestionsOpenSolutionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse uploaded solutions by subject, book, page, and question'**
  String get savedQuestionsOpenSolutionsSubtitle;

  /// No description provided for @savedQuestionsQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Your saved queue'**
  String get savedQuestionsQueueTitle;

  /// No description provided for @savedQuestionsQueueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Questions you save in practice appear here so you can reopen them quickly and keep working your weak spots.'**
  String get savedQuestionsQueueSubtitle;

  /// No description provided for @savedQuestionsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved questions yet'**
  String get savedQuestionsEmptyTitle;

  /// No description provided for @savedQuestionsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save a question from practice to revisit it later, open related solutions, and track the topics that still need work.'**
  String get savedQuestionsEmptySubtitle;

  /// No description provided for @savedQuestionsClearAction.
  ///
  /// In en, this message translates to:
  /// **'Clear saved questions'**
  String get savedQuestionsClearAction;

  /// No description provided for @savedQuestionsWhyItWorks.
  ///
  /// In en, this message translates to:
  /// **'Why it works'**
  String get savedQuestionsWhyItWorks;

  /// No description provided for @savedQuestionsHoursTarget.
  ///
  /// In en, this message translates to:
  /// **'{count} h target'**
  String savedQuestionsHoursTarget(Object count);

  /// No description provided for @savedQuestionsMinutesTarget.
  ///
  /// In en, this message translates to:
  /// **'{count} min target'**
  String savedQuestionsMinutesTarget(Object count);

  /// No description provided for @savedQuestionsSecondsTarget.
  ///
  /// In en, this message translates to:
  /// **'{count} sec target'**
  String savedQuestionsSecondsTarget(Object count);

  /// No description provided for @practiceSetupTooltipAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Practice analytics'**
  String get practiceSetupTooltipAnalytics;

  /// No description provided for @practiceSetupStopGenerating.
  ///
  /// In en, this message translates to:
  /// **'Stop Generating'**
  String get practiceSetupStopGenerating;

  /// No description provided for @practiceSetupGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get practiceSetupGenerating;

  /// No description provided for @practiceSetupStartSession.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get practiceSetupStartSession;

  /// No description provided for @practiceSetupSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get practiceSetupSearchHint;

  /// No description provided for @practiceSessionModeDescriptionPractice.
  ///
  /// In en, this message translates to:
  /// **'Balanced solving with instant checking and feedback.'**
  String get practiceSessionModeDescriptionPractice;

  /// No description provided for @practiceSessionModeDescriptionFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Memory-first mode built for quick recall and retention.'**
  String get practiceSessionModeDescriptionFlashcards;

  /// No description provided for @practiceSessionModeDescriptionSpeedRound.
  ///
  /// In en, this message translates to:
  /// **'Fast, low-friction, timed pressure reps.'**
  String get practiceSessionModeDescriptionSpeedRound;

  /// No description provided for @practiceSessionModeDescriptionExamPrep.
  ///
  /// In en, this message translates to:
  /// **'Formal exam-feel solving with less gamified pacing.'**
  String get practiceSessionModeDescriptionExamPrep;

  /// No description provided for @practiceSessionModeDescriptionConceptBuilder.
  ///
  /// In en, this message translates to:
  /// **'Understand the idea first, then solve with context.'**
  String get practiceSessionModeDescriptionConceptBuilder;

  /// No description provided for @practiceSessionModeDescriptionAdaptive.
  ///
  /// In en, this message translates to:
  /// **'Difficulty shifts based on how you perform.'**
  String get practiceSessionModeDescriptionAdaptive;

  /// No description provided for @practiceSessionModeDescriptionBagrut.
  ///
  /// In en, this message translates to:
  /// **'Official-style single-question formal Bagrut flow.'**
  String get practiceSessionModeDescriptionBagrut;

  /// No description provided for @practiceSessionLoadingPractice.
  ///
  /// In en, this message translates to:
  /// **'Building your practice session'**
  String get practiceSessionLoadingPractice;

  /// No description provided for @practiceSessionLoadingFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Shuffling your flashcards'**
  String get practiceSessionLoadingFlashcards;

  /// No description provided for @practiceSessionLoadingSpeedRound.
  ///
  /// In en, this message translates to:
  /// **'Starting the speed round'**
  String get practiceSessionLoadingSpeedRound;

  /// No description provided for @practiceSessionLoadingExamPrep.
  ///
  /// In en, this message translates to:
  /// **'Preparing your exam session'**
  String get practiceSessionLoadingExamPrep;

  /// No description provided for @practiceSessionLoadingConceptBuilder.
  ///
  /// In en, this message translates to:
  /// **'Loading concept coach'**
  String get practiceSessionLoadingConceptBuilder;

  /// No description provided for @practiceSessionLoadingAdaptive.
  ///
  /// In en, this message translates to:
  /// **'Personalizing your challenge'**
  String get practiceSessionLoadingAdaptive;

  /// No description provided for @practiceSessionLoadingBagrut.
  ///
  /// In en, this message translates to:
  /// **'Preparing your Bagrut set'**
  String get practiceSessionLoadingBagrut;

  /// No description provided for @practiceSessionLoadingDefault.
  ///
  /// In en, this message translates to:
  /// **'Preparing your session'**
  String get practiceSessionLoadingDefault;

  /// No description provided for @practiceSessionCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'{mode} complete'**
  String practiceSessionCompleteTitle(Object mode);

  /// No description provided for @practiceSessionMetricAnswered.
  ///
  /// In en, this message translates to:
  /// **'Answered'**
  String get practiceSessionMetricAnswered;

  /// No description provided for @practiceSessionMetricCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get practiceSessionMetricCorrect;

  /// No description provided for @practiceSessionMetricWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get practiceSessionMetricWrong;

  /// No description provided for @practiceSessionMetricAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get practiceSessionMetricAccuracy;

  /// No description provided for @practiceSessionMetricTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get practiceSessionMetricTotal;

  /// No description provided for @practiceSessionMetricXp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get practiceSessionMetricXp;

  /// No description provided for @practiceSessionMetricStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get practiceSessionMetricStreak;

  /// No description provided for @practiceSessionReviewLayoutStacked.
  ///
  /// In en, this message translates to:
  /// **'Stacked'**
  String get practiceSessionReviewLayoutStacked;

  /// No description provided for @practiceSessionReviewLayoutFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get practiceSessionReviewLayoutFocus;

  /// No description provided for @practiceSessionFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get practiceSessionFilterAll;

  /// No description provided for @practiceSessionFilterWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get practiceSessionFilterWrong;

  /// No description provided for @practiceSessionFilterCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get practiceSessionFilterCorrect;

  /// No description provided for @practiceSessionReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Session review'**
  String get practiceSessionReviewTitle;

  /// No description provided for @practiceSessionNoQuestionsForFilter.
  ///
  /// In en, this message translates to:
  /// **'No questions match this filter yet.'**
  String get practiceSessionNoQuestionsForFilter;

  /// No description provided for @practiceSessionNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get practiceSessionNoAnswer;

  /// No description provided for @practiceSessionUnknownAnswer.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get practiceSessionUnknownAnswer;

  /// No description provided for @practiceSessionReflectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reflection'**
  String get practiceSessionReflectionTitle;

  /// No description provided for @practiceSessionReflectionKnewIt.
  ///
  /// In en, this message translates to:
  /// **'Knew it'**
  String get practiceSessionReflectionKnewIt;

  /// No description provided for @practiceSessionReflectionReviewAgain.
  ///
  /// In en, this message translates to:
  /// **'Review again'**
  String get practiceSessionReflectionReviewAgain;

  /// No description provided for @practiceSessionBackOfCard.
  ///
  /// In en, this message translates to:
  /// **'Back of card'**
  String get practiceSessionBackOfCard;

  /// No description provided for @practiceSessionYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get practiceSessionYourAnswer;

  /// No description provided for @practiceSessionCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get practiceSessionCorrectAnswer;

  /// No description provided for @practiceSessionExplanation.
  ///
  /// In en, this message translates to:
  /// **'Explanation'**
  String get practiceSessionExplanation;

  /// No description provided for @practiceSessionBackToSetup.
  ///
  /// In en, this message translates to:
  /// **'Back to setup'**
  String get practiceSessionBackToSetup;

  /// No description provided for @practiceSessionGeneralTopic.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get practiceSessionGeneralTopic;

  /// No description provided for @practiceSessionQuestionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String practiceSessionQuestionProgress(Object current, Object total);

  /// No description provided for @practiceSessionMetricTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get practiceSessionMetricTime;

  /// No description provided for @practiceSessionMatchmakingDifficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty: {difficulty}'**
  String practiceSessionMatchmakingDifficulty(Object difficulty);

  /// No description provided for @practiceModeActionPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get practiceModeActionPrevious;

  /// No description provided for @practiceModeActionCheckAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check answer'**
  String get practiceModeActionCheckAnswer;

  /// No description provided for @practiceModeActionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get practiceModeActionNext;

  /// No description provided for @practiceModeActionNextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next question'**
  String get practiceModeActionNextQuestion;

  /// No description provided for @practiceModeActionEndSession.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get practiceModeActionEndSession;

  /// No description provided for @practiceModeActionEndQuestion.
  ///
  /// In en, this message translates to:
  /// **'End question'**
  String get practiceModeActionEndQuestion;

  /// No description provided for @practiceModeActionEndExam.
  ///
  /// In en, this message translates to:
  /// **'End exam'**
  String get practiceModeActionEndExam;

  /// No description provided for @practiceModeActionNovaHint.
  ///
  /// In en, this message translates to:
  /// **'NOVA hint'**
  String get practiceModeActionNovaHint;

  /// No description provided for @practiceModeActionReveal.
  ///
  /// In en, this message translates to:
  /// **'Reveal'**
  String get practiceModeActionReveal;

  /// No description provided for @practiceModeActionShowSolution.
  ///
  /// In en, this message translates to:
  /// **'Show solution'**
  String get practiceModeActionShowSolution;

  /// No description provided for @practiceModeActionHideSolution.
  ///
  /// In en, this message translates to:
  /// **'Hide solution'**
  String get practiceModeActionHideSolution;

  /// No description provided for @practiceModeActionLockIn.
  ///
  /// In en, this message translates to:
  /// **'Lock in'**
  String get practiceModeActionLockIn;

  /// No description provided for @practiceModeActionCheckAdapt.
  ///
  /// In en, this message translates to:
  /// **'Check & adapt'**
  String get practiceModeActionCheckAdapt;

  /// No description provided for @practiceModeActionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get practiceModeActionContinue;

  /// No description provided for @practiceModeActionSolveIt.
  ///
  /// In en, this message translates to:
  /// **'Solve it'**
  String get practiceModeActionSolveIt;

  /// No description provided for @practiceModeActionNextConcept.
  ///
  /// In en, this message translates to:
  /// **'Next concept'**
  String get practiceModeActionNextConcept;

  /// No description provided for @practiceModeCardFront.
  ///
  /// In en, this message translates to:
  /// **'Front of card'**
  String get practiceModeCardFront;

  /// No description provided for @practiceModeRecallSummary.
  ///
  /// In en, this message translates to:
  /// **'Recall summary'**
  String get practiceModeRecallSummary;

  /// No description provided for @practiceModeFeelingPrompt.
  ///
  /// In en, this message translates to:
  /// **'How did that feel?'**
  String get practiceModeFeelingPrompt;

  /// No description provided for @practiceModeFeelingAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get practiceModeFeelingAgain;

  /// No description provided for @practiceModeFeelingHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get practiceModeFeelingHard;

  /// No description provided for @practiceModeFeelingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get practiceModeFeelingGood;

  /// No description provided for @practiceModeFeelingEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get practiceModeFeelingEasy;

  /// No description provided for @practiceModeSpeedRoundBanner.
  ///
  /// In en, this message translates to:
  /// **'Speed round · fast decisions, instant momentum'**
  String get practiceModeSpeedRoundBanner;

  /// No description provided for @practiceModeFastFeedback.
  ///
  /// In en, this message translates to:
  /// **'Fast feedback'**
  String get practiceModeFastFeedback;

  /// No description provided for @practiceModeExamPrepBanner.
  ///
  /// In en, this message translates to:
  /// **'Exam prep · quieter layout, answers reviewed after moving forward'**
  String get practiceModeExamPrepBanner;

  /// No description provided for @practiceModeReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get practiceModeReview;

  /// No description provided for @practiceModeBagrutBanner.
  ///
  /// In en, this message translates to:
  /// **'Bagrut mode · official-style paper flow'**
  String get practiceModeBagrutBanner;

  /// No description provided for @practiceModeOfficialSolution.
  ///
  /// In en, this message translates to:
  /// **'Official-style solution'**
  String get practiceModeOfficialSolution;

  /// No description provided for @practiceModeAdaptiveWarmup.
  ///
  /// In en, this message translates to:
  /// **'Warm-up difficulty'**
  String get practiceModeAdaptiveWarmup;

  /// No description provided for @practiceModeAdaptiveTrendingUp.
  ///
  /// In en, this message translates to:
  /// **'Difficulty trending up'**
  String get practiceModeAdaptiveTrendingUp;

  /// No description provided for @practiceModeAdaptiveEasingDown.
  ///
  /// In en, this message translates to:
  /// **'Difficulty easing down'**
  String get practiceModeAdaptiveEasingDown;

  /// No description provided for @practiceModeAdaptiveSteady.
  ///
  /// In en, this message translates to:
  /// **'Difficulty holding steady'**
  String get practiceModeAdaptiveSteady;

  /// No description provided for @practiceModeAdaptiveFeedback.
  ///
  /// In en, this message translates to:
  /// **'Adaptive feedback'**
  String get practiceModeAdaptiveFeedback;

  /// No description provided for @practiceModeConceptFirst.
  ///
  /// In en, this message translates to:
  /// **'Concept first'**
  String get practiceModeConceptFirst;

  /// No description provided for @practiceModeNowSolveIt.
  ///
  /// In en, this message translates to:
  /// **'Now solve it'**
  String get practiceModeNowSolveIt;

  /// No description provided for @practiceModeConceptTitle.
  ///
  /// In en, this message translates to:
  /// **'Concept'**
  String get practiceModeConceptTitle;

  /// No description provided for @practiceModeFeedbackCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get practiceModeFeedbackCorrect;

  /// No description provided for @practiceModeFeedbackNotQuite.
  ///
  /// In en, this message translates to:
  /// **'Not quite'**
  String get practiceModeFeedbackNotQuite;

  /// No description provided for @practiceModeFallbackQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get practiceModeFallbackQuestion;

  /// No description provided for @practiceModeNoExplanationYet.
  ///
  /// In en, this message translates to:
  /// **'No explanation available yet.'**
  String get practiceModeNoExplanationYet;

  /// No description provided for @teacherGradesAssessmentCreated.
  ///
  /// In en, this message translates to:
  /// **'Assessment created'**
  String get teacherGradesAssessmentCreated;

  /// No description provided for @teacherGradesEditAssessmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit assessment'**
  String get teacherGradesEditAssessmentTitle;

  /// No description provided for @teacherGradesFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get teacherGradesFieldTitle;

  /// No description provided for @teacherGradesFieldDate.
  ///
  /// In en, this message translates to:
  /// **'Date (YYYY-MM-DD)'**
  String get teacherGradesFieldDate;

  /// No description provided for @teacherGradesFieldMaxGrade.
  ///
  /// In en, this message translates to:
  /// **'Max grade'**
  String get teacherGradesFieldMaxGrade;

  /// No description provided for @teacherGradesAssessmentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Assessment updated'**
  String get teacherGradesAssessmentUpdated;

  /// No description provided for @teacherGradesDeleteAssessmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete assessment?'**
  String get teacherGradesDeleteAssessmentTitle;

  /// No description provided for @teacherGradesDeleteAssessmentBody.
  ///
  /// In en, this message translates to:
  /// **'This will remove {title} and its grading entry from the teacher workspace.'**
  String teacherGradesDeleteAssessmentBody(Object title);

  /// No description provided for @teacherGradesDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get teacherGradesDeleteAction;

  /// No description provided for @teacherGradesAssessmentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Assessment deleted'**
  String get teacherGradesAssessmentDeleted;

  /// No description provided for @teacherGradesRosterLinkError.
  ///
  /// In en, this message translates to:
  /// **'This assessment is not linked to a classroom roster.'**
  String get teacherGradesRosterLinkError;

  /// No description provided for @teacherGradesSaved.
  ///
  /// In en, this message translates to:
  /// **'Grades saved'**
  String get teacherGradesSaved;

  /// No description provided for @teacherGradesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create assessments and save grades against the live classroom roster.'**
  String get teacherGradesSubtitle;

  /// No description provided for @teacherGradesCreateAssessmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Create assessment'**
  String get teacherGradesCreateAssessmentTitle;

  /// No description provided for @teacherGradesFieldCourse.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get teacherGradesFieldCourse;

  /// No description provided for @teacherGradesCreateAction.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get teacherGradesCreateAction;

  /// No description provided for @teacherGradesNoStudentsLoaded.
  ///
  /// In en, this message translates to:
  /// **'No students loaded for this assessment.'**
  String get teacherGradesNoStudentsLoaded;

  /// No description provided for @teacherGradesFieldGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get teacherGradesFieldGrade;

  /// No description provided for @teacherGradesMaxHint.
  ///
  /// In en, this message translates to:
  /// **'Max {grade}'**
  String teacherGradesMaxHint(Object grade);

  /// No description provided for @teacherGradesSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get teacherGradesSaving;

  /// No description provided for @teacherGradesSaveCount.
  ///
  /// In en, this message translates to:
  /// **'Save {count} grades'**
  String teacherGradesSaveCount(Object count);

  /// No description provided for @assignmentsNoDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get assignmentsNoDueDate;

  /// No description provided for @assignmentsLoadError.
  ///
  /// In en, this message translates to:
  /// **'We could not load assignments right now. Pull to refresh or try again.'**
  String get assignmentsLoadError;

  /// No description provided for @assignmentsLoadTimeout.
  ///
  /// In en, this message translates to:
  /// **'Assignments are taking too long to load. Pull to refresh or try again in a moment.'**
  String get assignmentsLoadTimeout;

  /// No description provided for @assignmentsLoadNetwork.
  ///
  /// In en, this message translates to:
  /// **'Assignments could not connect right now. Check your connection and try again.'**
  String get assignmentsLoadNetwork;

  /// No description provided for @assignmentsStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get assignmentsStatusOverdue;

  /// No description provided for @assignmentsStatusDueSoon.
  ///
  /// In en, this message translates to:
  /// **'Due soon'**
  String get assignmentsStatusDueSoon;

  /// No description provided for @assignmentsStatusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get assignmentsStatusUpcoming;

  /// No description provided for @assignmentsPreviewFallback.
  ///
  /// In en, this message translates to:
  /// **'Open this assignment to see the full instructions and prepare your work.'**
  String get assignmentsPreviewFallback;

  /// No description provided for @assignmentsSubmissionPrepEmpty.
  ///
  /// In en, this message translates to:
  /// **'Stage your note or files here.'**
  String get assignmentsSubmissionPrepEmpty;

  /// No description provided for @assignmentsSubmissionPrepCount.
  ///
  /// In en, this message translates to:
  /// **'{count} file(s) attached locally.'**
  String assignmentsSubmissionPrepCount(Object count);

  /// No description provided for @assignmentsHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every classroom assignment in one clean view, with a full-screen detail page and a dedicated place to prepare your work.'**
  String get assignmentsHeroSubtitle;

  /// No description provided for @assignmentsSubjectsMetric.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get assignmentsSubjectsMetric;

  /// No description provided for @assignmentsNothingAssignedYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing assigned yet'**
  String get assignmentsNothingAssignedYet;

  /// No description provided for @assignmentsNoAssignmentsForAccount.
  ///
  /// In en, this message translates to:
  /// **'No classroom assignments are available for this student account right now.'**
  String get assignmentsNoAssignmentsForAccount;

  /// No description provided for @assignmentsNextThingBody.
  ///
  /// In en, this message translates to:
  /// **'{title} is the next thing to look at. {due}.'**
  String assignmentsNextThingBody(Object title, Object due);

  /// No description provided for @assignmentsPullToCheckAgain.
  ///
  /// In en, this message translates to:
  /// **'Pull down to check again.'**
  String get assignmentsPullToCheckAgain;

  /// No description provided for @assignmentsFiltersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Narrow the list by subject or urgency to focus on what matters first.'**
  String get assignmentsFiltersSubtitle;

  /// No description provided for @assignmentsSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get assignmentsSubjectLabel;

  /// No description provided for @assignmentsAllSubjects.
  ///
  /// In en, this message translates to:
  /// **'All subjects'**
  String get assignmentsAllSubjects;

  /// No description provided for @assignmentsSearchSubjects.
  ///
  /// In en, this message translates to:
  /// **'Search subjects'**
  String get assignmentsSearchSubjects;

  /// No description provided for @assignmentsStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get assignmentsStatusLabel;

  /// No description provided for @assignmentsAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All statuses'**
  String get assignmentsAllStatuses;

  /// No description provided for @assignmentsSearchStatuses.
  ///
  /// In en, this message translates to:
  /// **'Search statuses'**
  String get assignmentsSearchStatuses;

  /// No description provided for @assignmentsShowingSummary.
  ///
  /// In en, this message translates to:
  /// **'Showing {shown} of {total} assignments.'**
  String assignmentsShowingSummary(Object shown, Object total);

  /// No description provided for @assignmentsNoFilterMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No assignments match these filters'**
  String get assignmentsNoFilterMatchesTitle;

  /// No description provided for @assignmentsNoFilterMatchesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try all subjects or a wider status view to bring more assignments back into the list.'**
  String get assignmentsNoFilterMatchesSubtitle;

  /// No description provided for @assignmentsClearFiltersHint.
  ///
  /// In en, this message translates to:
  /// **'Clear filters to see everything again.'**
  String get assignmentsClearFiltersHint;

  /// No description provided for @assignmentsListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap any assignment to open the full-screen detail view and prepare your work.'**
  String get assignmentsListSubtitle;

  /// No description provided for @assignmentsAddNoteBeforePrepare.
  ///
  /// In en, this message translates to:
  /// **'Add a note or attach a file before preparing your work.'**
  String get assignmentsAddNoteBeforePrepare;

  /// No description provided for @assignmentsWorkDraftPrepared.
  ///
  /// In en, this message translates to:
  /// **'Work draft prepared.'**
  String get assignmentsWorkDraftPrepared;

  /// No description provided for @assignmentsWorkDraftPreparedWithFiles.
  ///
  /// In en, this message translates to:
  /// **'Work draft prepared. Attached files are saved on this device.'**
  String get assignmentsWorkDraftPreparedWithFiles;

  /// No description provided for @assignmentsUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Assignment unavailable'**
  String get assignmentsUnavailableTitle;

  /// No description provided for @assignmentsUnavailableSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This assignment could not be found in the current feed. It may have been removed or is not available offline.'**
  String get assignmentsUnavailableSubtitle;

  /// No description provided for @assignmentsUnavailableHint.
  ///
  /// In en, this message translates to:
  /// **'Go back and refresh the assignments list.'**
  String get assignmentsUnavailableHint;

  /// No description provided for @assignmentsOverdueBannerBody.
  ///
  /// In en, this message translates to:
  /// **'This assignment is past its due date. Open your work area below to prepare what you want to turn in.'**
  String get assignmentsOverdueBannerBody;

  /// No description provided for @assignmentsWorkAreaBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Use the work area below to stage files, write a note, and keep everything ready in one place.'**
  String get assignmentsWorkAreaBannerBody;

  /// No description provided for @assignmentsDetailsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Assignment details'**
  String get assignmentsDetailsSectionTitle;

  /// No description provided for @assignmentsDetailsSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything student-relevant that is currently available in the classroom assignment payload.'**
  String get assignmentsDetailsSectionSubtitle;

  /// No description provided for @assignmentsDetailDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get assignmentsDetailDueLabel;

  /// No description provided for @assignmentsDetailClassroomLabel.
  ///
  /// In en, this message translates to:
  /// **'Classroom'**
  String get assignmentsDetailClassroomLabel;

  /// No description provided for @assignmentsDetailTeacherLabel.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get assignmentsDetailTeacherLabel;

  /// No description provided for @assignmentsDetailPostedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Posted by'**
  String get assignmentsDetailPostedByLabel;

  /// No description provided for @assignmentsDetailPublishedLabel.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get assignmentsDetailPublishedLabel;

  /// No description provided for @assignmentsDetailUpdatedLabel.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get assignmentsDetailUpdatedLabel;

  /// No description provided for @assignmentsDetailIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Assignment ID'**
  String get assignmentsDetailIdLabel;

  /// No description provided for @assignmentsInstructionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get assignmentsInstructionsTitle;

  /// No description provided for @assignmentsInstructionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Full assignment text from the classroom feed, with the original wording preserved.'**
  String get assignmentsInstructionsSubtitle;

  /// No description provided for @assignmentsYourWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'Your work'**
  String get assignmentsYourWorkTitle;

  /// No description provided for @assignmentsYourWorkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stage a note, attach files or docs, and keep your submission prep in one focused space.'**
  String get assignmentsYourWorkSubtitle;

  /// No description provided for @assignmentsPrivateNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Private work note'**
  String get assignmentsPrivateNoteLabel;

  /// No description provided for @assignmentsPrivateNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add what you plan to submit, reminders for yourself, or a doc/link summary.'**
  String get assignmentsPrivateNoteHint;

  /// No description provided for @assignmentsAddFiles.
  ///
  /// In en, this message translates to:
  /// **'Add files or docs'**
  String get assignmentsAddFiles;

  /// No description provided for @assignmentsClearFiles.
  ///
  /// In en, this message translates to:
  /// **'Clear files'**
  String get assignmentsClearFiles;

  /// No description provided for @assignmentsStagedDeviceHint.
  ///
  /// In en, this message translates to:
  /// **'Files are staged on this device. Assignment file submission is not available in this app.'**
  String get assignmentsStagedDeviceHint;

  /// No description provided for @assignmentsLastPrepared.
  ///
  /// In en, this message translates to:
  /// **'Last prepared {time}.'**
  String assignmentsLastPrepared(Object time);

  /// No description provided for @assignmentsSubmissionPrepTitle.
  ///
  /// In en, this message translates to:
  /// **'Submission prep'**
  String get assignmentsSubmissionPrepTitle;

  /// No description provided for @assignmentsPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get assignmentsPreparing;

  /// No description provided for @assignmentsPrepareWork.
  ///
  /// In en, this message translates to:
  /// **'Prepare work'**
  String get assignmentsPrepareWork;

  /// No description provided for @assignmentsLoadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Loading your classroom assignments.'**
  String get assignmentsLoadingSubtitle;

  /// No description provided for @assignmentsPullToRefreshRetry.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh or retry below.'**
  String get assignmentsPullToRefreshRetry;

  /// No description provided for @assignmentsFileSizeUnknown.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get assignmentsFileSizeUnknown;

  /// No description provided for @assignmentsRemoveAttachment.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get assignmentsRemoveAttachment;

  /// No description provided for @attendanceUndated.
  ///
  /// In en, this message translates to:
  /// **'Undated'**
  String get attendanceUndated;

  /// No description provided for @attendanceLoadError.
  ///
  /// In en, this message translates to:
  /// **'We could not load attendance right now. Pull to refresh or try again.'**
  String get attendanceLoadError;

  /// No description provided for @attendanceLoadTimeout.
  ///
  /// In en, this message translates to:
  /// **'Attendance is taking too long to load. Pull to refresh or try again in a moment.'**
  String get attendanceLoadTimeout;

  /// No description provided for @attendanceLoadNetwork.
  ///
  /// In en, this message translates to:
  /// **'Attendance could not connect right now. Check your connection and try again.'**
  String get attendanceLoadNetwork;

  /// No description provided for @attendanceConsistencyBuilding.
  ///
  /// In en, this message translates to:
  /// **'Still building'**
  String get attendanceConsistencyBuilding;

  /// No description provided for @attendanceConsistencyExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent consistency'**
  String get attendanceConsistencyExcellent;

  /// No description provided for @attendanceConsistencySteady.
  ///
  /// In en, this message translates to:
  /// **'Mostly steady'**
  String get attendanceConsistencySteady;

  /// No description provided for @attendanceConsistencyNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get attendanceConsistencyNeedsAttention;

  /// No description provided for @attendanceConsistencyRisk.
  ///
  /// In en, this message translates to:
  /// **'Attendance risk'**
  String get attendanceConsistencyRisk;

  /// No description provided for @attendanceWatchRecentAbsences.
  ///
  /// In en, this message translates to:
  /// **'Recent absences'**
  String get attendanceWatchRecentAbsences;

  /// No description provided for @attendanceWatchRepeatedLateness.
  ///
  /// In en, this message translates to:
  /// **'Repeated lateness'**
  String get attendanceWatchRepeatedLateness;

  /// No description provided for @attendanceWatchExcusedAddingUp.
  ///
  /// In en, this message translates to:
  /// **'Excused time adding up'**
  String get attendanceWatchExcusedAddingUp;

  /// No description provided for @attendanceWatchNoFlags.
  ///
  /// In en, this message translates to:
  /// **'No current flags'**
  String get attendanceWatchNoFlags;

  /// No description provided for @attendanceAllSubjectsLowercase.
  ///
  /// In en, this message translates to:
  /// **'all subjects'**
  String get attendanceAllSubjectsLowercase;

  /// No description provided for @attendanceShowingSummary.
  ///
  /// In en, this message translates to:
  /// **'Showing {shown} of {total} marks for {subject} in {range}.'**
  String attendanceShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  );

  /// No description provided for @attendanceDayToneAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absence day'**
  String get attendanceDayToneAbsent;

  /// No description provided for @attendanceDayToneLate.
  ///
  /// In en, this message translates to:
  /// **'Late signal'**
  String get attendanceDayToneLate;

  /// No description provided for @attendanceDayToneExcused.
  ///
  /// In en, this message translates to:
  /// **'Excused attendance'**
  String get attendanceDayToneExcused;

  /// No description provided for @attendanceDayToneClean.
  ///
  /// In en, this message translates to:
  /// **'Clean day'**
  String get attendanceDayToneClean;

  /// No description provided for @attendanceLoadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Loading your latest attendance summary.'**
  String get attendanceLoadingSubtitle;

  /// No description provided for @attendanceUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance unavailable'**
  String get attendanceUnavailableTitle;

  /// No description provided for @attendanceHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A clean read on your attendance rate, recent lessons, and anything that needs attention.'**
  String get attendanceHeroSubtitle;

  /// No description provided for @attendanceMetricRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get attendanceMetricRate;

  /// No description provided for @attendanceMetricPresent.
  ///
  /// In en, this message translates to:
  /// **'Present marks'**
  String get attendanceMetricPresent;

  /// No description provided for @attendanceMetricLate.
  ///
  /// In en, this message translates to:
  /// **'Late marks'**
  String get attendanceMetricLate;

  /// No description provided for @attendanceMetricAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent marks'**
  String get attendanceMetricAbsent;

  /// No description provided for @attendanceHeroSignalBody.
  ///
  /// In en, this message translates to:
  /// **'{flag}. Attendance pressure can build quietly, so this view stays focused on what changed most recently.'**
  String attendanceHeroSignalBody(Object flag);

  /// No description provided for @attendanceNoSummary.
  ///
  /// In en, this message translates to:
  /// **'No attendance summary is available for this student account yet.'**
  String get attendanceNoSummary;

  /// No description provided for @attendanceEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No attendance records yet'**
  String get attendanceEmptyTitle;

  /// No description provided for @attendanceEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No attendance records have been published for this student account yet.'**
  String get attendanceEmptySubtitle;

  /// No description provided for @attendanceFiltersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the same searchable picker style as settings to narrow the attendance view by subject or time window.'**
  String get attendanceFiltersSubtitle;

  /// No description provided for @attendanceTimeRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time range'**
  String get attendanceTimeRangeLabel;

  /// No description provided for @attendanceSearchRanges.
  ///
  /// In en, this message translates to:
  /// **'All time / 7 days / 30 days / 90 days'**
  String get attendanceSearchRanges;

  /// No description provided for @attendanceNoFilteredMarksTitle.
  ///
  /// In en, this message translates to:
  /// **'No marks match these filters'**
  String get attendanceNoFilteredMarksTitle;

  /// No description provided for @attendanceNoFilteredMarksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try all subjects or a wider time range to bring more attendance marks back into view.'**
  String get attendanceNoFilteredMarksSubtitle;

  /// No description provided for @attendanceQuickReadTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick read'**
  String get attendanceQuickReadTitle;

  /// No description provided for @attendanceQuickReadSubtitleFiltered.
  ///
  /// In en, this message translates to:
  /// **'A fast summary for the filtered attendance marks shown below.'**
  String get attendanceQuickReadSubtitleFiltered;

  /// No description provided for @attendanceQuickReadSubtitleAll.
  ///
  /// In en, this message translates to:
  /// **'A fast summary based on the latest attendance records available.'**
  String get attendanceQuickReadSubtitleAll;

  /// No description provided for @attendanceSummaryConsistency.
  ///
  /// In en, this message translates to:
  /// **'Consistency'**
  String get attendanceSummaryConsistency;

  /// No description provided for @attendanceSummaryWatchFor.
  ///
  /// In en, this message translates to:
  /// **'Watch for'**
  String get attendanceSummaryWatchFor;

  /// No description provided for @attendanceSummaryExcused.
  ///
  /// In en, this message translates to:
  /// **'Excused marks'**
  String get attendanceSummaryExcused;

  /// No description provided for @attendanceSummaryMarksInView.
  ///
  /// In en, this message translates to:
  /// **'Marks in view'**
  String get attendanceSummaryMarksInView;

  /// No description provided for @attendanceSummaryRateInView.
  ///
  /// In en, this message translates to:
  /// **'Rate in view'**
  String get attendanceSummaryRateInView;

  /// No description provided for @attendanceRecentDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent days'**
  String get attendanceRecentDaysTitle;

  /// No description provided for @attendanceRecentDaysSubtitleFiltered.
  ///
  /// In en, this message translates to:
  /// **'Grouped by day for the filtered marks currently in view.'**
  String get attendanceRecentDaysSubtitleFiltered;

  /// No description provided for @attendanceRecentDaysSubtitleAll.
  ///
  /// In en, this message translates to:
  /// **'Grouped by day so you can catch absence or lateness patterns faster.'**
  String get attendanceRecentDaysSubtitleAll;

  /// No description provided for @attendanceLessonCountSingle.
  ///
  /// In en, this message translates to:
  /// **'1 lesson'**
  String get attendanceLessonCountSingle;

  /// No description provided for @attendanceLessonCount.
  ///
  /// In en, this message translates to:
  /// **'{count} lessons'**
  String attendanceLessonCount(Object count);

  /// No description provided for @attendanceStatusPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get attendanceStatusPresent;

  /// No description provided for @attendanceStatusLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get attendanceStatusLate;

  /// No description provided for @attendanceStatusAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get attendanceStatusAbsent;

  /// No description provided for @attendanceStatusExcused.
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get attendanceStatusExcused;

  /// No description provided for @attendanceStatusRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get attendanceStatusRecorded;

  /// No description provided for @attendanceLessonFallback.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get attendanceLessonFallback;

  /// No description provided for @attendanceRangeAll.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get attendanceRangeAll;

  /// No description provided for @attendanceRange7.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get attendanceRange7;

  /// No description provided for @attendanceRange30.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get attendanceRange30;

  /// No description provided for @attendanceRange90.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get attendanceRange90;

  /// No description provided for @attendanceRangeAllShort.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get attendanceRangeAllShort;

  /// No description provided for @attendanceRange7Short.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get attendanceRange7Short;

  /// No description provided for @attendanceRange30Short.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get attendanceRange30Short;

  /// No description provided for @attendanceRange90Short.
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get attendanceRange90Short;

  /// No description provided for @gradesLoadError.
  ///
  /// In en, this message translates to:
  /// **'We could not load grades right now. Pull to refresh or try again.'**
  String get gradesLoadError;

  /// No description provided for @gradesLoadTimeout.
  ///
  /// In en, this message translates to:
  /// **'Grades are taking too long to load. Pull to refresh or try again in a moment.'**
  String get gradesLoadTimeout;

  /// No description provided for @gradesLoadNetwork.
  ///
  /// In en, this message translates to:
  /// **'Grades could not connect right now. Check your connection and try again.'**
  String get gradesLoadNetwork;

  /// No description provided for @gradesGeneralSubject.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get gradesGeneralSubject;

  /// No description provided for @gradesBandBuilding.
  ///
  /// In en, this message translates to:
  /// **'Still building'**
  String get gradesBandBuilding;

  /// No description provided for @gradesBandExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get gradesBandExcellent;

  /// No description provided for @gradesBandStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get gradesBandStrong;

  /// No description provided for @gradesBandOkay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get gradesBandOkay;

  /// No description provided for @gradesBandNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get gradesBandNeedsAttention;

  /// No description provided for @gradesBandRisk.
  ///
  /// In en, this message translates to:
  /// **'At risk'**
  String get gradesBandRisk;

  /// No description provided for @gradesTrendRising.
  ///
  /// In en, this message translates to:
  /// **'Rising'**
  String get gradesTrendRising;

  /// No description provided for @gradesTrendDropping.
  ///
  /// In en, this message translates to:
  /// **'Dropping'**
  String get gradesTrendDropping;

  /// No description provided for @gradesTrendStable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get gradesTrendStable;

  /// No description provided for @gradesShowingSummary.
  ///
  /// In en, this message translates to:
  /// **'Showing {shown} of {total} recorded grades for {subject} in {range}.'**
  String gradesShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  );

  /// No description provided for @gradesLoadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Loading your latest academic results.'**
  String get gradesLoadingSubtitle;

  /// No description provided for @gradesUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Grades unavailable'**
  String get gradesUnavailableTitle;

  /// No description provided for @gradesHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A clean read on your average, recent assessments, and which subjects need protection or recovery.'**
  String get gradesHeroSubtitle;

  /// No description provided for @gradesMetricAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get gradesMetricAverage;

  /// No description provided for @gradesMetricRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded'**
  String get gradesMetricRecorded;

  /// No description provided for @gradesMetricBestSubject.
  ///
  /// In en, this message translates to:
  /// **'Best subject'**
  String get gradesMetricBestSubject;

  /// No description provided for @gradesMetricNeedsWork.
  ///
  /// In en, this message translates to:
  /// **'Needs work'**
  String get gradesMetricNeedsWork;

  /// No description provided for @gradesLatestSignalBody.
  ///
  /// In en, this message translates to:
  /// **'{assessment} in {subject} landed at {grade}. {band} right now.'**
  String gradesLatestSignalBody(
    Object assessment,
    Object subject,
    Object grade,
    Object band,
  );

  /// No description provided for @gradesSummaryAvailableNoRecent.
  ///
  /// In en, this message translates to:
  /// **'A grade summary is available, but no recent assessments are visible in this view yet.'**
  String get gradesSummaryAvailableNoRecent;

  /// No description provided for @gradesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No grades yet'**
  String get gradesEmptyTitle;

  /// No description provided for @gradesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'No grades have been published for this student account yet.'**
  String get gradesEmptySubtitle;

  /// No description provided for @gradesFiltersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use the same searchable picker style as settings to narrow grades by subject or time window.'**
  String get gradesFiltersSubtitle;

  /// No description provided for @gradesNoFilteredTitle.
  ///
  /// In en, this message translates to:
  /// **'No grades match these filters'**
  String get gradesNoFilteredTitle;

  /// No description provided for @gradesNoFilteredSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try all subjects or a wider time range to bring more recorded grades back into view.'**
  String get gradesNoFilteredSubtitle;

  /// No description provided for @gradesQuickReadTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick read'**
  String get gradesQuickReadTitle;

  /// No description provided for @gradesQuickReadSubtitleFiltered.
  ///
  /// In en, this message translates to:
  /// **'A fast summary for the grades currently in view.'**
  String get gradesQuickReadSubtitleFiltered;

  /// No description provided for @gradesQuickReadSubtitleAll.
  ///
  /// In en, this message translates to:
  /// **'The fastest read on what to protect and what to recover.'**
  String get gradesQuickReadSubtitleAll;

  /// No description provided for @gradesWeakSpotLabel.
  ///
  /// In en, this message translates to:
  /// **'Current weak spot'**
  String get gradesWeakSpotLabel;

  /// No description provided for @gradesNoWeakSignal.
  ///
  /// In en, this message translates to:
  /// **'No weak subject signal yet'**
  String get gradesNoWeakSignal;

  /// No description provided for @gradesWeakSpotValue.
  ///
  /// In en, this message translates to:
  /// **'{subject} needs the first recovery block.'**
  String gradesWeakSpotValue(Object subject);

  /// No description provided for @gradesStrengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Current strength'**
  String get gradesStrengthLabel;

  /// No description provided for @gradesNoStrengthSignal.
  ///
  /// In en, this message translates to:
  /// **'No strong subject signal yet'**
  String get gradesNoStrengthSignal;

  /// No description provided for @gradesStrengthValue.
  ///
  /// In en, this message translates to:
  /// **'{subject} is your confidence anchor right now.'**
  String gradesStrengthValue(Object subject);

  /// No description provided for @gradesBandLabel.
  ///
  /// In en, this message translates to:
  /// **'Band'**
  String get gradesBandLabel;

  /// No description provided for @gradesInViewLabel.
  ///
  /// In en, this message translates to:
  /// **'In view'**
  String get gradesInViewLabel;

  /// No description provided for @gradesInViewCount.
  ///
  /// In en, this message translates to:
  /// **'{count} recorded grades in this filter.'**
  String gradesInViewCount(Object count);

  /// No description provided for @gradesInViewAverage.
  ///
  /// In en, this message translates to:
  /// **'{count} recorded grades averaging {average}.'**
  String gradesInViewAverage(Object count, Object average);

  /// No description provided for @gradesLatestAssessmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Latest assessments'**
  String get gradesLatestAssessmentsTitle;

  /// No description provided for @gradesLatestAssessmentsSubtitleFiltered.
  ///
  /// In en, this message translates to:
  /// **'Most recent recorded grades in the current filtered view.'**
  String get gradesLatestAssessmentsSubtitleFiltered;

  /// No description provided for @gradesLatestAssessmentsSubtitleAll.
  ///
  /// In en, this message translates to:
  /// **'Most recent recorded grades in chronological order.'**
  String get gradesLatestAssessmentsSubtitleAll;

  /// No description provided for @gradesSubjectDrilldownTitle.
  ///
  /// In en, this message translates to:
  /// **'Subject drilldown'**
  String get gradesSubjectDrilldownTitle;

  /// No description provided for @gradesSubjectDrilldownSubtitleFiltered.
  ///
  /// In en, this message translates to:
  /// **'Grouped by subject for the grades currently in view.'**
  String get gradesSubjectDrilldownSubtitleFiltered;

  /// No description provided for @gradesSubjectDrilldownSubtitleAll.
  ///
  /// In en, this message translates to:
  /// **'Grouped by subject so trend and pressure stand out faster.'**
  String get gradesSubjectDrilldownSubtitleAll;

  /// No description provided for @gradesAssessmentFallback.
  ///
  /// In en, this message translates to:
  /// **'Assessment'**
  String get gradesAssessmentFallback;

  /// No description provided for @gradesChipBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get gradesChipBest;

  /// No description provided for @gradesNoAverageYet.
  ///
  /// In en, this message translates to:
  /// **'No average yet'**
  String get gradesNoAverageYet;

  /// No description provided for @gradesRecentAverage.
  ///
  /// In en, this message translates to:
  /// **'Recent average: {average}'**
  String gradesRecentAverage(Object average);

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @actionBlock.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get actionBlock;

  /// No description provided for @actionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionScheduleVerb.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get actionScheduleVerb;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get actionKeep;

  /// No description provided for @actionOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get actionOpen;

  /// No description provided for @actionPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get actionPublish;

  /// No description provided for @actionPublishing.
  ///
  /// In en, this message translates to:
  /// **'Publishing…'**
  String get actionPublishing;

  /// No description provided for @actionRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get actionRefresh;

  /// No description provided for @msgBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block this person?'**
  String get msgBlockTitle;

  /// No description provided for @msgBlockContent.
  ///
  /// In en, this message translates to:
  /// **'They won\'t be able to message you and you won\'t see their messages.'**
  String get msgBlockContent;

  /// No description provided for @msgRenameGroup.
  ///
  /// In en, this message translates to:
  /// **'Rename group'**
  String get msgRenameGroup;

  /// No description provided for @msgGroupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get msgGroupName;

  /// No description provided for @msgMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get msgMute;

  /// No description provided for @msgUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get msgUnmute;

  /// No description provided for @msgInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get msgInviteCode;

  /// No description provided for @msgCopyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get msgCopyCode;

  /// No description provided for @msgLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get msgLeave;

  /// No description provided for @msgInviteCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied'**
  String get msgInviteCodeCopied;

  /// No description provided for @msgCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied: {code}'**
  String msgCodeCopied(Object code);

  /// No description provided for @msgParticipantsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 participant added} other{{count} participants added}}'**
  String msgParticipantsAdded(int count);

  /// No description provided for @msgMembersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String msgMembersCount(int count);

  /// No description provided for @msgAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get msgAdmin;

  /// No description provided for @msgRemoveFromGroup.
  ///
  /// In en, this message translates to:
  /// **'Remove from group'**
  String get msgRemoveFromGroup;

  /// No description provided for @msgMakeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Make admin'**
  String get msgMakeAdmin;

  /// No description provided for @msgRemoveAdmin.
  ///
  /// In en, this message translates to:
  /// **'Remove admin'**
  String get msgRemoveAdmin;

  /// No description provided for @msgOnlyAdmin.
  ///
  /// In en, this message translates to:
  /// **'Only admin — promote another first'**
  String get msgOnlyAdmin;

  /// No description provided for @msgRemoveMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String msgRemoveMemberTitle(Object name);

  /// No description provided for @msgNotificationsMuted.
  ///
  /// In en, this message translates to:
  /// **'Notifications muted'**
  String get msgNotificationsMuted;

  /// No description provided for @msgNotificationsUnmuted.
  ///
  /// In en, this message translates to:
  /// **'Notifications unmuted'**
  String get msgNotificationsUnmuted;

  /// No description provided for @msgJoinGroupTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a Group'**
  String get msgJoinGroupTitle;

  /// No description provided for @msgJoinGroupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the invite code from the group admin'**
  String get msgJoinGroupSubtitle;

  /// No description provided for @examTitle.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get examTitle;

  /// No description provided for @examNotFound.
  ///
  /// In en, this message translates to:
  /// **'Exam not found'**
  String get examNotFound;

  /// No description provided for @examStudyWithNova.
  ///
  /// In en, this message translates to:
  /// **'Study with NOVA'**
  String get examStudyWithNova;

  /// No description provided for @examOpenInsights.
  ///
  /// In en, this message translates to:
  /// **'Open Insights'**
  String get examOpenInsights;

  /// No description provided for @examAddToCalendar.
  ///
  /// In en, this message translates to:
  /// **'Add to calendar'**
  String get examAddToCalendar;

  /// No description provided for @examCouldNotOpenCalendar.
  ///
  /// In en, this message translates to:
  /// **'Could not open calendar.'**
  String get examCouldNotOpenCalendar;

  /// No description provided for @formTitle.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get formTitle;

  /// No description provided for @formNotFound.
  ///
  /// In en, this message translates to:
  /// **'Form not found'**
  String get formNotFound;

  /// No description provided for @formClosed.
  ///
  /// In en, this message translates to:
  /// **'This form is closed.'**
  String get formClosed;

  /// No description provided for @formCompletion.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get formCompletion;

  /// No description provided for @formNoTextResponses.
  ///
  /// In en, this message translates to:
  /// **'No text responses yet.'**
  String get formNoTextResponses;

  /// No description provided for @meetingsCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load meetings'**
  String get meetingsCouldNotLoad;

  /// No description provided for @meetingCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load meeting'**
  String get meetingCouldNotLoad;

  /// No description provided for @insightsGenerateAction.
  ///
  /// In en, this message translates to:
  /// **'Generate Insights'**
  String get insightsGenerateAction;

  /// No description provided for @insightsRefreshAction.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get insightsRefreshAction;

  /// No description provided for @teacherGoToClassroom.
  ///
  /// In en, this message translates to:
  /// **'Go to Classroom'**
  String get teacherGoToClassroom;

  /// No description provided for @teacherMarkAttendance.
  ///
  /// In en, this message translates to:
  /// **'Mark Attendance'**
  String get teacherMarkAttendance;

  /// No description provided for @teacherPostAssignment.
  ///
  /// In en, this message translates to:
  /// **'Post Assignment'**
  String get teacherPostAssignment;

  /// No description provided for @teacherNewAnnouncementAction.
  ///
  /// In en, this message translates to:
  /// **'New Announcement'**
  String get teacherNewAnnouncementAction;

  /// No description provided for @teacherViewFullWeekSchedule.
  ///
  /// In en, this message translates to:
  /// **'View full week schedule'**
  String get teacherViewFullWeekSchedule;

  /// No description provided for @teacherGroupsLabel.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get teacherGroupsLabel;

  /// No description provided for @teacherTestsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tests'**
  String get teacherTestsLabel;

  /// No description provided for @teacherAnnounceLabel.
  ///
  /// In en, this message translates to:
  /// **'Announce'**
  String get teacherAnnounceLabel;

  /// No description provided for @teacherTitleAndMessageRequired.
  ///
  /// In en, this message translates to:
  /// **'Title and message are required'**
  String get teacherTitleAndMessageRequired;

  /// No description provided for @teacherAnnouncementPublished.
  ///
  /// In en, this message translates to:
  /// **'Announcement published'**
  String get teacherAnnouncementPublished;

  /// No description provided for @teacherFailedToPublish.
  ///
  /// In en, this message translates to:
  /// **'Failed to publish: {error}'**
  String teacherFailedToPublish(Object error);

  /// No description provided for @teacherAnnouncementSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get teacherAnnouncementSectionTitle;

  /// No description provided for @teacherAudienceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Audience'**
  String get teacherAudienceSectionTitle;

  /// No description provided for @teacherPinAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Pin announcement'**
  String get teacherPinAnnouncement;

  /// No description provided for @teacherPinnedAtTop.
  ///
  /// In en, this message translates to:
  /// **'Pinned announcements appear at the top'**
  String get teacherPinnedAtTop;

  /// No description provided for @teacherPublishAction.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get teacherPublishAction;

  /// No description provided for @teacherPublishingAction.
  ///
  /// In en, this message translates to:
  /// **'Publishing…'**
  String get teacherPublishingAction;

  /// No description provided for @teacherAnnounceTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get teacherAnnounceTitleLabel;

  /// No description provided for @teacherAnnounceTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. School event tomorrow'**
  String get teacherAnnounceTitleHint;

  /// No description provided for @teacherAnnounceMessageLabel.
  ///
  /// In en, this message translates to:
  /// **'Message *'**
  String get teacherAnnounceMessageLabel;

  /// No description provided for @teacherAnnounceMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Write the full announcement here…'**
  String get teacherAnnounceMessageHint;

  /// No description provided for @teacherStudentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get teacherStudentsLabel;

  /// No description provided for @teacherParentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get teacherParentsLabel;

  /// No description provided for @teacherTeachersLabel.
  ///
  /// In en, this message translates to:
  /// **'Teachers'**
  String get teacherTeachersLabel;

  /// No description provided for @teacherWeekScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Week Schedule'**
  String get teacherWeekScheduleTitle;

  /// No description provided for @teacherCouldNotLoadSchedule.
  ///
  /// In en, this message translates to:
  /// **'Could not load schedule'**
  String get teacherCouldNotLoadSchedule;

  /// No description provided for @teacherAttendanceLast30.
  ///
  /// In en, this message translates to:
  /// **'Attendance (last 30 days)'**
  String get teacherAttendanceLast30;

  /// No description provided for @teacherRecentGrades.
  ///
  /// In en, this message translates to:
  /// **'Recent Grades'**
  String get teacherRecentGrades;

  /// No description provided for @teacherNoGradesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No grades recorded yet'**
  String get teacherNoGradesRecorded;

  /// No description provided for @teacherGradeAvg.
  ///
  /// In en, this message translates to:
  /// **'Grade Avg'**
  String get teacherGradeAvg;

  /// No description provided for @teacherSubmittedLabel.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get teacherSubmittedLabel;

  /// No description provided for @teacherAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get teacherAnalyticsTitle;

  /// No description provided for @teacherGradeReports.
  ///
  /// In en, this message translates to:
  /// **'Grade Reports'**
  String get teacherGradeReports;

  /// No description provided for @teacherAvgLabel.
  ///
  /// In en, this message translates to:
  /// **'avg'**
  String get teacherAvgLabel;

  /// No description provided for @teacherBelow60.
  ///
  /// In en, this message translates to:
  /// **'{count} below 60%'**
  String teacherBelow60(Object count);

  /// No description provided for @teacherGradedFraction.
  ///
  /// In en, this message translates to:
  /// **'{graded}/{total} graded'**
  String teacherGradedFraction(Object graded, Object total);

  /// No description provided for @teacherNoGradesEntered.
  ///
  /// In en, this message translates to:
  /// **'No grades entered yet'**
  String get teacherNoGradesEntered;

  /// No description provided for @teacherNewAssignment.
  ///
  /// In en, this message translates to:
  /// **'New Assignment'**
  String get teacherNewAssignment;

  /// No description provided for @teacherDeleteAssignment.
  ///
  /// In en, this message translates to:
  /// **'Delete assignment?'**
  String get teacherDeleteAssignment;

  /// No description provided for @teacherDeleteAssignmentContent.
  ///
  /// In en, this message translates to:
  /// **'This will remove it for all students.'**
  String get teacherDeleteAssignmentContent;

  /// No description provided for @teacherShareMaterialTitle.
  ///
  /// In en, this message translates to:
  /// **'Share Material'**
  String get teacherShareMaterialTitle;

  /// No description provided for @teacherRemoveMaterial.
  ///
  /// In en, this message translates to:
  /// **'Remove material?'**
  String get teacherRemoveMaterial;

  /// No description provided for @teacherScheduleMeetingTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule Meeting'**
  String get teacherScheduleMeetingTitle;

  /// No description provided for @teacherCancelMeetingTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel meeting?'**
  String get teacherCancelMeetingTitle;

  /// No description provided for @teacherCancelMeetingAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel meeting'**
  String get teacherCancelMeetingAction;

  /// No description provided for @teacherJoinMeeting.
  ///
  /// In en, this message translates to:
  /// **'Join meeting'**
  String get teacherJoinMeeting;

  /// No description provided for @teacherAddStudentTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Student'**
  String get teacherAddStudentTitle;

  /// No description provided for @teacherRemoveStudentTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String teacherRemoveStudentTitle(Object name);

  /// No description provided for @teacherRemoveStudentContent.
  ///
  /// In en, this message translates to:
  /// **'This student will be removed from this classroom.'**
  String get teacherRemoveStudentContent;

  /// No description provided for @teacherStudentAdded.
  ///
  /// In en, this message translates to:
  /// **'Student added'**
  String get teacherStudentAdded;

  /// No description provided for @teacherClassroomAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Classroom Analytics'**
  String get teacherClassroomAnalyticsTitle;

  /// No description provided for @teacherOpenAnalyticsAction.
  ///
  /// In en, this message translates to:
  /// **'Open Analytics'**
  String get teacherOpenAnalyticsAction;

  /// No description provided for @teacherStudentsCount.
  ///
  /// In en, this message translates to:
  /// **'Students ({count})'**
  String teacherStudentsCount(Object count);

  /// No description provided for @teacherAssignmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get teacherAssignmentLabel;

  /// No description provided for @teacherShareMaterialLabel.
  ///
  /// In en, this message translates to:
  /// **'Share material'**
  String get teacherShareMaterialLabel;

  /// No description provided for @teacherAttendanceRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Attendance rate'**
  String get teacherAttendanceRateLabel;

  /// No description provided for @teacherSelectSessionPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a session below to start marking attendance'**
  String get teacherSelectSessionPrompt;

  /// No description provided for @teacherOpenAction.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get teacherOpenAction;

  /// No description provided for @chatDeleteForMe.
  ///
  /// In en, this message translates to:
  /// **'Delete for me'**
  String get chatDeleteForMe;

  /// No description provided for @chatDeleteForEveryone.
  ///
  /// In en, this message translates to:
  /// **'Delete for everyone'**
  String get chatDeleteForEveryone;

  /// No description provided for @chatMicNeeded.
  ///
  /// In en, this message translates to:
  /// **'Microphone access needed'**
  String get chatMicNeeded;

  /// No description provided for @chatMicNeededBody.
  ///
  /// In en, this message translates to:
  /// **'Please allow microphone access in Settings to send voice notes.'**
  String get chatMicNeededBody;

  /// No description provided for @chatOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get chatOpenSettings;

  /// No description provided for @chatCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get chatCopied;

  /// No description provided for @chatCouldNotSendMedia.
  ///
  /// In en, this message translates to:
  /// **'Could not send media.'**
  String get chatCouldNotSendMedia;

  /// No description provided for @chatCouldNotSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not send message.'**
  String get chatCouldNotSendMessage;

  /// No description provided for @chatCouldNotForward.
  ///
  /// In en, this message translates to:
  /// **'Could not forward selected messages'**
  String get chatCouldNotForward;

  /// No description provided for @chatSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get chatSelectAll;

  /// No description provided for @chatDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get chatDeselectAll;

  /// No description provided for @chatEditingMessage.
  ///
  /// In en, this message translates to:
  /// **'Editing message'**
  String get chatEditingMessage;

  /// No description provided for @chatEditPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Edit message…'**
  String get chatEditPlaceholder;

  /// No description provided for @chatMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatMessageHint;

  /// No description provided for @chatPin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get chatPin;

  /// No description provided for @chatUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get chatUnpin;

  /// No description provided for @chatPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get chatPhoto;

  /// No description provided for @chatVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get chatVideo;

  /// No description provided for @chatMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get chatMedia;

  /// No description provided for @chatAudioFile.
  ///
  /// In en, this message translates to:
  /// **'Audio file'**
  String get chatAudioFile;

  /// No description provided for @chatVideoFile.
  ///
  /// In en, this message translates to:
  /// **'Video file'**
  String get chatVideoFile;

  /// No description provided for @chatAttachedFile.
  ///
  /// In en, this message translates to:
  /// **'Attached file'**
  String get chatAttachedFile;

  /// No description provided for @chatFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Follow-up'**
  String get chatFollowUp;

  /// No description provided for @chatCancelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get chatCancelTooltip;

  /// No description provided for @chatJoinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join Group'**
  String get chatJoinGroup;

  /// No description provided for @chatJoining.
  ///
  /// In en, this message translates to:
  /// **'Joining…'**
  String get chatJoining;

  /// No description provided for @chatJoinGroupTooltip.
  ///
  /// In en, this message translates to:
  /// **'Join group by code'**
  String get chatJoinGroupTooltip;

  /// No description provided for @chatForwardNoChatAvailable.
  ///
  /// In en, this message translates to:
  /// **'No approved chats available'**
  String get chatForwardNoChatAvailable;

  /// No description provided for @chatFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get chatFilterAll;

  /// No description provided for @novaDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'NOVA can make mistakes. Double-check important answers.'**
  String get novaDisclaimer;

  /// No description provided for @practiceCustomDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Custom topics are AI-generated on the fly. Questions may drift off-topic or be inaccurate for niche subjects. Verify unfamiliar answers independently.'**
  String get practiceCustomDisclaimer;

  /// No description provided for @classroomsJoined.
  ///
  /// In en, this message translates to:
  /// **'You joined the classroom!'**
  String get classroomsJoined;

  /// No description provided for @classroomsJoinAction.
  ///
  /// In en, this message translates to:
  /// **'Join Classroom'**
  String get classroomsJoinAction;

  /// No description provided for @classroomsJoinTooltip.
  ///
  /// In en, this message translates to:
  /// **'Join a classroom'**
  String get classroomsJoinTooltip;

  /// No description provided for @classroomsJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join a Classroom'**
  String get classroomsJoinTitle;

  /// No description provided for @classroomsJoinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the code your teacher gave you'**
  String get classroomsJoinSubtitle;

  /// No description provided for @classroomsCouldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get classroomsCouldNotOpenLink;

  /// No description provided for @classroomsReorderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reorder classrooms'**
  String get classroomsReorderTitle;

  /// No description provided for @classroomsNoClassroomsToReorder.
  ///
  /// In en, this message translates to:
  /// **'No classrooms to reorder.'**
  String get classroomsNoClassroomsToReorder;

  /// No description provided for @teacherPostAnnouncementAction.
  ///
  /// In en, this message translates to:
  /// **'Post Announcement'**
  String get teacherPostAnnouncementAction;

  /// No description provided for @announcementAudienceEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get announcementAudienceEveryone;

  /// No description provided for @teacherGreetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get teacherGreetingMorning;

  /// No description provided for @teacherGreetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get teacherGreetingAfternoon;

  /// No description provided for @teacherGreetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get teacherGreetingEvening;

  /// No description provided for @teacherTodaysClasses.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Classes'**
  String get teacherTodaysClasses;

  /// No description provided for @teacherNoDate.
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get teacherNoDate;

  /// No description provided for @teacherUpcomingTestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Next tests & quizzes'**
  String get teacherUpcomingTestsSubtitle;

  /// No description provided for @teacherNoClassesThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No classes this week'**
  String get teacherNoClassesThisWeek;

  /// No description provided for @teacherNoClassesThisWeekSub.
  ///
  /// In en, this message translates to:
  /// **'Your schedule for this week is empty'**
  String get teacherNoClassesThisWeekSub;

  /// No description provided for @teacherTitleFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get teacherTitleFieldLabel;

  /// No description provided for @teacherInstructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get teacherInstructionsLabel;

  /// No description provided for @teacherLinkUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Link / URL *'**
  String get teacherLinkUrlLabel;

  /// No description provided for @teacherLinkUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://...'**
  String get teacherLinkUrlHint;

  /// No description provided for @teacherDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get teacherDescriptionLabel;

  /// No description provided for @teacherMeetingTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Meeting title *'**
  String get teacherMeetingTitleLabel;

  /// No description provided for @teacherMeetingLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Meeting link *'**
  String get teacherMeetingLinkLabel;

  /// No description provided for @teacherMeetingLinkHint.
  ///
  /// In en, this message translates to:
  /// **'Zoom / Meet / Teams link'**
  String get teacherMeetingLinkHint;

  /// No description provided for @teacherStudentEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Student email or ID'**
  String get teacherStudentEmailLabel;

  /// No description provided for @teacherTooltipRemoveStudent.
  ///
  /// In en, this message translates to:
  /// **'Remove from classroom'**
  String get teacherTooltipRemoveStudent;

  /// No description provided for @teacherCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load'**
  String get teacherCouldNotLoad;

  /// No description provided for @teacherNoAssignmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No assignments yet'**
  String get teacherNoAssignmentsYet;

  /// No description provided for @teacherNoAssignmentsSub.
  ///
  /// In en, this message translates to:
  /// **'Tap + to create the first assignment'**
  String get teacherNoAssignmentsSub;

  /// No description provided for @teacherNoMaterialsYet.
  ///
  /// In en, this message translates to:
  /// **'No materials yet'**
  String get teacherNoMaterialsYet;

  /// No description provided for @teacherNoMaterialsSub.
  ///
  /// In en, this message translates to:
  /// **'Share links, documents, or resources with your class'**
  String get teacherNoMaterialsSub;

  /// No description provided for @teacherNoMeetingsScheduled.
  ///
  /// In en, this message translates to:
  /// **'No meetings scheduled'**
  String get teacherNoMeetingsScheduled;

  /// No description provided for @teacherNoMeetingsSub.
  ///
  /// In en, this message translates to:
  /// **'Tap + to schedule a class meeting'**
  String get teacherNoMeetingsSub;

  /// No description provided for @teacherAttendanceOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get teacherAttendanceOther;

  /// No description provided for @teacherTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get teacherTotal;

  /// No description provided for @mediaOpenExternally.
  ///
  /// In en, this message translates to:
  /// **'Open externally'**
  String get mediaOpenExternally;

  /// No description provided for @mediaUnableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load image'**
  String get mediaUnableToLoad;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'fr',
    'he',
    'pt',
    'ru',
    'tr',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'he':
      return AppLocalizationsHe();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

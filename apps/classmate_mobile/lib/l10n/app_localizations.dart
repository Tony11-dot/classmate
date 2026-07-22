import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_ps.dart';
import 'app_localizations_ru.dart';

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
    Locale('en'),
    Locale('fr'),
    Locale('he'),
    Locale('ps'),
    Locale('ru'),
  ];

  /// No description provided for @certAddTeacher.
  ///
  /// In en, this message translates to:
  /// **'Add teacher'**
  String get certAddTeacher;

  /// No description provided for @certSearchStudent.
  ///
  /// In en, this message translates to:
  /// **'Search students'**
  String get certSearchStudent;

  /// No description provided for @certNewCertificate.
  ///
  /// In en, this message translates to:
  /// **'New certificate'**
  String get certNewCertificate;

  /// No description provided for @certCertificateCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No certificates} =1{1 certificate} other{{count} certificates}}'**
  String certCertificateCount(int count);

  /// No description provided for @onbTeacher2Title.
  ///
  /// In en, this message translates to:
  /// **'Your classes, organized'**
  String get onbTeacher2Title;

  /// No description provided for @onbTeacher2Body.
  ///
  /// In en, this message translates to:
  /// **'Your schedule, classrooms and student rosters — all in one place.'**
  String get onbTeacher2Body;

  /// No description provided for @onbTeacher3Title.
  ///
  /// In en, this message translates to:
  /// **'Grades & attendance, fast'**
  String get onbTeacher3Title;

  /// No description provided for @onbTeacher3Body.
  ///
  /// In en, this message translates to:
  /// **'Take attendance and enter grades in seconds, right from your phone.'**
  String get onbTeacher3Body;

  /// No description provided for @onbTeacher4Title.
  ///
  /// In en, this message translates to:
  /// **'Reach everyone'**
  String get onbTeacher4Title;

  /// No description provided for @onbTeacher4Body.
  ///
  /// In en, this message translates to:
  /// **'Post announcements and message students and parents instantly.'**
  String get onbTeacher4Body;

  /// No description provided for @onbAdmin2Title.
  ///
  /// In en, this message translates to:
  /// **'Run your school'**
  String get onbAdmin2Title;

  /// No description provided for @onbAdmin2Body.
  ///
  /// In en, this message translates to:
  /// **'Manage people, classes and the timetable from one dashboard.'**
  String get onbAdmin2Body;

  /// No description provided for @onbAdmin3Title.
  ///
  /// In en, this message translates to:
  /// **'Set up in minutes'**
  String get onbAdmin3Title;

  /// No description provided for @onbAdmin3Body.
  ///
  /// In en, this message translates to:
  /// **'Add students, teachers and classes in just a few taps.'**
  String get onbAdmin3Body;

  /// No description provided for @onbAdmin4Title.
  ///
  /// In en, this message translates to:
  /// **'Keep everyone in sync'**
  String get onbAdmin4Title;

  /// No description provided for @onbAdmin4Body.
  ///
  /// In en, this message translates to:
  /// **'Broadcast announcements and message your whole school.'**
  String get onbAdmin4Body;

  /// No description provided for @onbSecretary2Title.
  ///
  /// In en, this message translates to:
  /// **'Students at your fingertips'**
  String get onbSecretary2Title;

  /// No description provided for @onbSecretary2Body.
  ///
  /// In en, this message translates to:
  /// **'Look up any student and keep their details up to date.'**
  String get onbSecretary2Body;

  /// No description provided for @onbSecretary3Title.
  ///
  /// In en, this message translates to:
  /// **'Share the word'**
  String get onbSecretary3Title;

  /// No description provided for @onbSecretary3Body.
  ///
  /// In en, this message translates to:
  /// **'Send announcements to the right classes in seconds.'**
  String get onbSecretary3Body;

  /// No description provided for @onbParent2Title.
  ///
  /// In en, this message translates to:
  /// **'Follow your child'**
  String get onbParent2Title;

  /// No description provided for @onbParent2Body.
  ///
  /// In en, this message translates to:
  /// **'Their schedule, grades and attendance — always up to date.'**
  String get onbParent2Body;

  /// No description provided for @onbParent3Title.
  ///
  /// In en, this message translates to:
  /// **'Never miss a thing'**
  String get onbParent3Title;

  /// No description provided for @onbParent3Body.
  ///
  /// In en, this message translates to:
  /// **'Get school announcements and updates the moment they happen.'**
  String get onbParent3Body;

  /// No description provided for @accountActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Account options'**
  String get accountActionsTooltip;

  /// No description provided for @accountSwitchTo.
  ///
  /// In en, this message translates to:
  /// **'Switch to this account'**
  String get accountSwitchTo;

  /// No description provided for @accountRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove account'**
  String get accountRemove;

  /// No description provided for @accountRemoveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove account?'**
  String get accountRemoveConfirmTitle;

  /// No description provided for @accountRemoveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed from this device. You can sign in again anytime.'**
  String accountRemoveConfirmBody(String name);

  /// No description provided for @onboardingWelcomeNamed.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String onboardingWelcomeNamed(String name);

  /// No description provided for @practiceGenAlmostReady.
  ///
  /// In en, this message translates to:
  /// **'Almost ready…'**
  String get practiceGenAlmostReady;

  /// No description provided for @practiceGenRemaining.
  ///
  /// In en, this message translates to:
  /// **'≈ {seconds}s left'**
  String practiceGenRemaining(int seconds);

  /// No description provided for @practiceGenEstimate.
  ///
  /// In en, this message translates to:
  /// **'Usually {min}–{max}s'**
  String practiceGenEstimate(int min, int max);

  /// No description provided for @consentGateError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save your choice. Please check your connection and try again.'**
  String get consentGateError;

  /// No description provided for @commonShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get commonShowPassword;

  /// No description provided for @commonHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get commonHidePassword;

  /// No description provided for @adminEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get adminEmailInvalid;

  /// No description provided for @adminPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get adminPhoneInvalid;

  /// No description provided for @adminFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get adminFullNameLabel;

  /// No description provided for @adminHomeroomLabel.
  ///
  /// In en, this message translates to:
  /// **'Homeroom class'**
  String get adminHomeroomLabel;

  /// No description provided for @adminHomeroomNone.
  ///
  /// In en, this message translates to:
  /// **'No homeroom class'**
  String get adminHomeroomNone;

  /// No description provided for @adminHomeroomNoneAvailable.
  ///
  /// In en, this message translates to:
  /// **'No unassigned classes available'**
  String get adminHomeroomNoneAvailable;

  /// No description provided for @adminHomeroomHint.
  ///
  /// In en, this message translates to:
  /// **'This teacher becomes the homeroom teacher of the selected class.'**
  String get adminHomeroomHint;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to sign in again to use ClassMate.'**
  String get logoutConfirmBody;

  /// No description provided for @pressBackAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get pressBackAgainToExit;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to ClassMate'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Body.
  ///
  /// In en, this message translates to:
  /// **'Your smart school companion — everything for school, all in one place.'**
  String get onboardingSlide1Body;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Meet NOVA'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Body.
  ///
  /// In en, this message translates to:
  /// **'Your AI tutor, ready to explain any topic and help you practice, anytime.'**
  String get onboardingSlide2Body;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Stay on top of everything'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Body.
  ///
  /// In en, this message translates to:
  /// **'Schedule, grades, attendance and assignments — always up to date.'**
  String get onboardingSlide3Body;

  /// No description provided for @onboardingSlide4Title.
  ///
  /// In en, this message translates to:
  /// **'Stay connected'**
  String get onboardingSlide4Title;

  /// No description provided for @onboardingSlide4Body.
  ///
  /// In en, this message translates to:
  /// **'Messages and announcements keep students, teachers and parents in sync.'**
  String get onboardingSlide4Body;

  /// Consent gate
  ///
  /// In en, this message translates to:
  /// **'Before you continue'**
  String get consentGateTitle;

  /// Consent gate
  ///
  /// In en, this message translates to:
  /// **'To keep using ClassMate, please review and accept how we handle your data.'**
  String get consentGateBody;

  /// Consent gate
  ///
  /// In en, this message translates to:
  /// **'Read the Privacy Policy & Terms'**
  String get consentGateLink;

  /// Consent gate
  ///
  /// In en, this message translates to:
  /// **'I accept the Privacy Policy and Terms of Use'**
  String get consentGateAccept;

  /// Consent gate
  ///
  /// In en, this message translates to:
  /// **'I have my parent or guardian\'s permission to use ClassMate'**
  String get consentGateGuardian;

  /// Consent gate
  ///
  /// In en, this message translates to:
  /// **'Agree & Continue'**
  String get consentGateContinue;

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

  /// No description provided for @roleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get roleStudent;

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

  /// No description provided for @titleBagrut.
  ///
  /// In en, this message translates to:
  /// **'Bagrut'**
  String get titleBagrut;

  /// No description provided for @bagrutSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search subjects'**
  String get bagrutSearchHint;

  /// No description provided for @bagrutNoExams.
  ///
  /// In en, this message translates to:
  /// **'No exams yet for {subject}.'**
  String bagrutNoExams(Object subject);

  /// No description provided for @bagrutFilesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No files} =1{1 file} other{{count} files}}'**
  String bagrutFilesCount(int count);

  /// No description provided for @bagrutNoFiles.
  ///
  /// In en, this message translates to:
  /// **'No files.'**
  String get bagrutNoFiles;

  /// No description provided for @bagrutFileQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get bagrutFileQuestions;

  /// No description provided for @bagrutFileAnswers.
  ///
  /// In en, this message translates to:
  /// **'Answers'**
  String get bagrutFileAnswers;

  /// No description provided for @bagrutFileSolution.
  ///
  /// In en, this message translates to:
  /// **'Solution'**
  String get bagrutFileSolution;

  /// No description provided for @bagrutFileAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Full solution'**
  String get bagrutFileAdvanced;

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

  /// No description provided for @settingsThemeCoffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get settingsThemeCoffee;

  /// No description provided for @settingsThemeMatcha.
  ///
  /// In en, this message translates to:
  /// **'Matcha'**
  String get settingsThemeMatcha;

  /// No description provided for @settingsThemeRose.
  ///
  /// In en, this message translates to:
  /// **'Rosé'**
  String get settingsThemeRose;

  /// No description provided for @settingsThemeMidnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get settingsThemeMidnight;

  /// No description provided for @settingsThemeNord.
  ///
  /// In en, this message translates to:
  /// **'Nord'**
  String get settingsThemeNord;

  /// No description provided for @settingsThemeForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get settingsThemeForest;

  /// No description provided for @settingsThemeSand.
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get settingsThemeSand;

  /// No description provided for @settingsThemeSky.
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get settingsThemeSky;

  /// No description provided for @settingsThemeLavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get settingsThemeLavender;

  /// No description provided for @settingsThemePeach.
  ///
  /// In en, this message translates to:
  /// **'Peach'**
  String get settingsThemePeach;

  /// No description provided for @settingsThemeMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get settingsThemeMint;

  /// No description provided for @settingsThemeDracula.
  ///
  /// In en, this message translates to:
  /// **'Dracula'**
  String get settingsThemeDracula;

  /// No description provided for @settingsThemeObsidian.
  ///
  /// In en, this message translates to:
  /// **'Obsidian'**
  String get settingsThemeObsidian;

  /// No description provided for @settingsThemeWine.
  ///
  /// In en, this message translates to:
  /// **'Wine'**
  String get settingsThemeWine;

  /// No description provided for @settingsThemeSolarized.
  ///
  /// In en, this message translates to:
  /// **'Solarized'**
  String get settingsThemeSolarized;

  /// No description provided for @settingsThemePlum.
  ///
  /// In en, this message translates to:
  /// **'Plum'**
  String get settingsThemePlum;

  /// No description provided for @settingsThemeOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get settingsThemeOcean;

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

  /// No description provided for @teacherAttendanceClassNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Class notes'**
  String get teacherAttendanceClassNotesLabel;

  /// No description provided for @teacherAttendanceClassNotesHint.
  ///
  /// In en, this message translates to:
  /// **'What was covered in this session…'**
  String get teacherAttendanceClassNotesHint;

  /// No description provided for @teacherAttendanceSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get teacherAttendanceSaving;

  /// No description provided for @teacherAttendanceSaveAll.
  ///
  /// In en, this message translates to:
  /// **'Save attendance'**
  String get teacherAttendanceSaveAll;

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

  /// No description provided for @scheduleSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get scheduleSessionExpired;

  /// No description provided for @scheduleNotOnboarded.
  ///
  /// In en, this message translates to:
  /// **'Your student profile is not fully set up yet. Ask your school admin to assign you to a class.'**
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

  /// No description provided for @scheduleNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get scheduleNotes;

  /// No description provided for @scheduleGoToClassroom.
  ///
  /// In en, this message translates to:
  /// **'Go to Classroom'**
  String get scheduleGoToClassroom;

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

  /// No description provided for @biometricSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with biometrics'**
  String get biometricSignIn;

  /// No description provided for @biometricEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable biometric sign-in'**
  String get biometricEnable;

  /// No description provided for @biometricReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to sign in to ClassMate'**
  String get biometricReason;

  /// No description provided for @biometricEnableReason.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to enable biometric sign-in'**
  String get biometricEnableReason;

  /// No description provided for @biometricSignInFaceId.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Face ID'**
  String get biometricSignInFaceId;

  /// No description provided for @biometricSignInFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Sign in with fingerprint'**
  String get biometricSignInFingerprint;

  /// No description provided for @biometricOrSignInWith.
  ///
  /// In en, this message translates to:
  /// **'or sign in with'**
  String get biometricOrSignInWith;

  /// No description provided for @biometricNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'No biometric sign-in set up yet. Turn on Face ID or fingerprint in Profile → Biometric sign-in.'**
  String get biometricNotSetUp;

  /// No description provided for @biometricNotRecognized.
  ///
  /// In en, this message translates to:
  /// **'Biometric not recognized. Try again or sign in with your password.'**
  String get biometricNotRecognized;

  /// No description provided for @biometricFaceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Face ID isn\'t available on this device.'**
  String get biometricFaceUnavailable;

  /// No description provided for @biometricFingerprintUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint isn\'t available on this device.'**
  String get biometricFingerprintUnavailable;

  /// No description provided for @biometricNotAvailableOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get biometricNotAvailableOnDevice;

  /// No description provided for @biometricSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Biometric sign-in'**
  String get biometricSectionTitle;

  /// No description provided for @biometricSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on Face ID or your fingerprint to sign in faster. You\'ll confirm your password once.'**
  String get biometricSectionSubtitle;

  /// No description provided for @biometricFaceId.
  ///
  /// In en, this message translates to:
  /// **'Face ID'**
  String get biometricFaceId;

  /// No description provided for @biometricFaceIdDesc.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID to sign in'**
  String get biometricFaceIdDesc;

  /// No description provided for @biometricFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get biometricFingerprint;

  /// No description provided for @biometricFingerprintDesc.
  ///
  /// In en, this message translates to:
  /// **'Use your fingerprint to sign in'**
  String get biometricFingerprintDesc;

  /// No description provided for @biometricConfirmPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get biometricConfirmPasswordTitle;

  /// No description provided for @biometricConfirmPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to turn on biometric sign-in.'**
  String get biometricConfirmPasswordBody;

  /// No description provided for @biometricPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get biometricPasswordIncorrect;

  /// No description provided for @biometricEnrollFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t verify your biometric. Make sure Face ID or a fingerprint is set up in your device settings.'**
  String get biometricEnrollFailed;

  /// No description provided for @biometricEnterCredsFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and password first, then enable biometric sign-in.'**
  String get biometricEnterCredsFirst;

  /// No description provided for @biometricLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Biometric sign-in failed. Please sign in with your password.'**
  String get biometricLoginFailed;

  /// No description provided for @biometricEnrollTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable biometric sign-in?'**
  String get biometricEnrollTitle;

  /// No description provided for @biometricEnrollBody.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID or your fingerprint to sign in faster next time.'**
  String get biometricEnrollBody;

  /// No description provided for @biometricEnrollYes.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get biometricEnrollYes;

  /// No description provided for @biometricEnrollNo.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get biometricEnrollNo;

  /// No description provided for @loginWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeTitle;

  /// No description provided for @loginWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your ClassMate account.'**
  String get loginWelcomeSubtitle;

  /// No description provided for @loginSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get loginSigningIn;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
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

  /// No description provided for @profileMyCohorts.
  ///
  /// In en, this message translates to:
  /// **'My cohorts'**
  String get profileMyCohorts;

  /// No description provided for @profileMyCohortsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You\'re not enrolled in any cohorts yet.'**
  String get profileMyCohortsEmpty;

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

  /// No description provided for @messagesGroupMinMembers.
  ///
  /// In en, this message translates to:
  /// **'Select at least 2 people for a group'**
  String get messagesGroupMinMembers;

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

  /// No description provided for @teacherDeleteClassroom.
  ///
  /// In en, this message translates to:
  /// **'Delete classroom'**
  String get teacherDeleteClassroom;

  /// No description provided for @teacherDeleteClassroomConfirm.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes the classroom and all its chat, assignments, materials, meetings and member list. This cannot be undone.'**
  String get teacherDeleteClassroomConfirm;

  /// No description provided for @teacherClassroomDeleted.
  ///
  /// In en, this message translates to:
  /// **'Classroom deleted'**
  String get teacherClassroomDeleted;

  /// No description provided for @announcementsTabReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get announcementsTabReceived;

  /// No description provided for @announcementsTabPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get announcementsTabPublished;

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
  /// **'No meetings are scheduled for you right now. Pull down to check again.'**
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

  /// No description provided for @practiceModeActionSaveQuestion.
  ///
  /// In en, this message translates to:
  /// **'Save question'**
  String get practiceModeActionSaveQuestion;

  /// No description provided for @practiceModeActionSavedQuestion.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get practiceModeActionSavedQuestion;

  /// No description provided for @practiceModeQuestionSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Saved to your questions'**
  String get practiceModeQuestionSavedToast;

  /// No description provided for @practiceModeQuestionRemovedToast.
  ///
  /// In en, this message translates to:
  /// **'Removed from saved questions'**
  String get practiceModeQuestionRemovedToast;

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

  /// No description provided for @assignmentsStatusGraded.
  ///
  /// In en, this message translates to:
  /// **'Graded'**
  String get assignmentsStatusGraded;

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

  /// No description provided for @assignmentsSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get assignmentsSubmitted;

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
  /// **'Closed'**
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

  /// No description provided for @teacherSearchStudents.
  ///
  /// In en, this message translates to:
  /// **'Search students…'**
  String get teacherSearchStudents;

  /// No description provided for @teacherNoStudentsLoaded.
  ///
  /// In en, this message translates to:
  /// **'No students found in this school.'**
  String get teacherNoStudentsLoaded;

  /// No description provided for @teacherActions.
  ///
  /// In en, this message translates to:
  /// **'QUICK ACTIONS'**
  String get teacherActions;

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

  /// No description provided for @teacherAttendanceFrom.
  ///
  /// In en, this message translates to:
  /// **'From {date}'**
  String teacherAttendanceFrom(Object date);

  /// No description provided for @teacherAttendanceChangeDate.
  ///
  /// In en, this message translates to:
  /// **'Change date'**
  String get teacherAttendanceChangeDate;

  /// No description provided for @teacherAttendanceNoSessions.
  ///
  /// In en, this message translates to:
  /// **'No saved attendance sessions.\nMark attendance from the schedule.'**
  String get teacherAttendanceNoSessions;

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

  /// No description provided for @novaTokenTip.
  ///
  /// In en, this message translates to:
  /// **'Use your tokens carefully — they\'re meant for studying.'**
  String get novaTokenTip;

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

  /// No description provided for @teacherInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Student Insights'**
  String get teacherInsightsTitle;

  /// No description provided for @teacherInsightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a student to view their academic insights.'**
  String get teacherInsightsSubtitle;

  /// No description provided for @teacherInsightsNoStudents.
  ///
  /// In en, this message translates to:
  /// **'No students found.'**
  String get teacherInsightsNoStudents;

  /// No description provided for @teacherInsightsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search students…'**
  String get teacherInsightsSearchHint;

  /// No description provided for @navDiplomas.
  ///
  /// In en, this message translates to:
  /// **'Diplomas'**
  String get navDiplomas;

  /// No description provided for @diplomasComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Diploma management is coming soon.'**
  String get diplomasComingSoon;

  /// No description provided for @teacherExamsTitle.
  ///
  /// In en, this message translates to:
  /// **'Exams'**
  String get teacherExamsTitle;

  /// No description provided for @teacherExamsUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get teacherExamsUpcoming;

  /// No description provided for @teacherExamsPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get teacherExamsPast;

  /// No description provided for @teacherExamsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No assessments yet. Tap + to create one.'**
  String get teacherExamsEmpty;

  /// No description provided for @teacherExamsGraded.
  ///
  /// In en, this message translates to:
  /// **'{count} graded'**
  String teacherExamsGraded(Object count);

  /// No description provided for @teacherFormsTitle.
  ///
  /// In en, this message translates to:
  /// **'Forms'**
  String get teacherFormsTitle;

  /// No description provided for @teacherFormsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No forms yet. Tap + to create one.'**
  String get teacherFormsEmpty;

  /// No description provided for @teacherFormsResponses.
  ///
  /// In en, this message translates to:
  /// **'{count} responses'**
  String teacherFormsResponses(Object count);

  /// No description provided for @teacherFormsPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get teacherFormsPublished;

  /// No description provided for @teacherFormsDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get teacherFormsDraft;

  /// No description provided for @teacherFormsCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Form'**
  String get teacherFormsCreateTitle;

  /// No description provided for @teacherFormsAddQuestion.
  ///
  /// In en, this message translates to:
  /// **'Add question'**
  String get teacherFormsAddQuestion;

  /// No description provided for @teacherFormsQuestionHint.
  ///
  /// In en, this message translates to:
  /// **'Question text'**
  String get teacherFormsQuestionHint;

  /// No description provided for @teacherFormsViewResponses.
  ///
  /// In en, this message translates to:
  /// **'View responses'**
  String get teacherFormsViewResponses;

  /// No description provided for @teacherFormsNoResponses.
  ///
  /// In en, this message translates to:
  /// **'No responses yet.'**
  String get teacherFormsNoResponses;

  /// No description provided for @diplomasTitle.
  ///
  /// In en, this message translates to:
  /// **'Diplomas'**
  String get diplomasTitle;

  /// No description provided for @diplomasEmpty.
  ///
  /// In en, this message translates to:
  /// **'No certificates issued yet. Tap + to issue one.'**
  String get diplomasEmpty;

  /// No description provided for @diplomasIssueTo.
  ///
  /// In en, this message translates to:
  /// **'Issue to'**
  String get diplomasIssueTo;

  /// No description provided for @diplomasStudentName.
  ///
  /// In en, this message translates to:
  /// **'Student name'**
  String get diplomasStudentName;

  /// No description provided for @diplomasCertificateType.
  ///
  /// In en, this message translates to:
  /// **'Certificate type'**
  String get diplomasCertificateType;

  /// No description provided for @diplomasIssueDiploma.
  ///
  /// In en, this message translates to:
  /// **'Issue Certificate'**
  String get diplomasIssueDiploma;

  /// No description provided for @diplomasIssuedOn.
  ///
  /// In en, this message translates to:
  /// **'Issued on {date}'**
  String diplomasIssuedOn(Object date);

  /// No description provided for @examDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get examDetailsSection;

  /// No description provided for @examInfoTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get examInfoTeacher;

  /// No description provided for @examInfoAudience.
  ///
  /// In en, this message translates to:
  /// **'Audience'**
  String get examInfoAudience;

  /// No description provided for @examInfoDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get examInfoDate;

  /// No description provided for @examInfoTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get examInfoTime;

  /// No description provided for @examInfoPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get examInfoPeriod;

  /// No description provided for @examInfoDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get examInfoDuration;

  /// No description provided for @examInfoSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get examInfoSubject;

  /// No description provided for @examMaterialsSection.
  ///
  /// In en, this message translates to:
  /// **'Attached materials'**
  String get examMaterialsSection;

  /// No description provided for @examNoMaterials.
  ///
  /// In en, this message translates to:
  /// **'No materials attached yet.'**
  String get examNoMaterials;

  /// No description provided for @examQuickActionsSection.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get examQuickActionsSection;

  /// No description provided for @examViewGradeTitle.
  ///
  /// In en, this message translates to:
  /// **'See your grade'**
  String get examViewGradeTitle;

  /// No description provided for @examViewGradeBody.
  ///
  /// In en, this message translates to:
  /// **'This exam is complete. Check the grades tab for your result.'**
  String get examViewGradeBody;

  /// No description provided for @examViewGradeAction.
  ///
  /// In en, this message translates to:
  /// **'Open Grades'**
  String get examViewGradeAction;

  /// No description provided for @teacherGradesSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get teacherGradesSaveAction;

  /// No description provided for @teacherGradesNothingToSave.
  ///
  /// In en, this message translates to:
  /// **'No changes to save.'**
  String get teacherGradesNothingToSave;

  /// No description provided for @teacherRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get teacherRetry;

  /// No description provided for @teacherExamGradesStudents.
  ///
  /// In en, this message translates to:
  /// **'students'**
  String get teacherExamGradesStudents;

  /// No description provided for @teacherExamGradesGraded.
  ///
  /// In en, this message translates to:
  /// **'graded'**
  String get teacherExamGradesGraded;

  /// No description provided for @teacherExamGradesNoStudents.
  ///
  /// In en, this message translates to:
  /// **'No students targeted.\nEdit the exam to add an audience.'**
  String get teacherExamGradesNoStudents;

  /// No description provided for @teacherExamGradesEnterGrades.
  ///
  /// In en, this message translates to:
  /// **'Enter grades'**
  String get teacherExamGradesEnterGrades;

  /// No description provided for @teacherExamClassAverage.
  ///
  /// In en, this message translates to:
  /// **'Class average'**
  String get teacherExamClassAverage;

  /// No description provided for @teacherDeleteExamTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete exam?'**
  String get teacherDeleteExamTitle;

  /// No description provided for @teacherDeleteExamBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the exam.'**
  String get teacherDeleteExamBody;

  /// No description provided for @teacherMeetingsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No meetings yet.\nTap + to schedule one.'**
  String get teacherMeetingsEmpty;

  /// No description provided for @teacherStudentsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'No students match'**
  String get teacherStudentsNoMatch;

  /// No description provided for @teacherMaterialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get teacherMaterialsTitle;

  /// No description provided for @profileNamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Name in languages'**
  String get profileNamesTitle;

  /// No description provided for @profileDisplayNameLang.
  ///
  /// In en, this message translates to:
  /// **'Display name language'**
  String get profileDisplayNameLang;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navPeople.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get navPeople;

  /// No description provided for @navCohorts.
  ///
  /// In en, this message translates to:
  /// **'Cohorts'**
  String get navCohorts;

  /// No description provided for @navSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get navSchool;

  /// No description provided for @navSchools.
  ///
  /// In en, this message translates to:
  /// **'Schools'**
  String get navSchools;

  /// No description provided for @navManagers.
  ///
  /// In en, this message translates to:
  /// **'Managers'**
  String get navManagers;

  /// No description provided for @navBagrut.
  ///
  /// In en, this message translates to:
  /// **'Bagrut'**
  String get navBagrut;

  /// No description provided for @chatPreviewPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get chatPreviewPhoto;

  /// No description provided for @chatPreviewVoice.
  ///
  /// In en, this message translates to:
  /// **'Voice message'**
  String get chatPreviewVoice;

  /// No description provided for @chatPreviewVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get chatPreviewVideo;

  /// No description provided for @chatPreviewAttachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get chatPreviewAttachment;

  /// No description provided for @chatPreviewMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatPreviewMessage;

  /// No description provided for @chatPreviewYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get chatPreviewYou;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'School Overview'**
  String get adminDashboardTitle;

  /// No description provided for @adminStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get adminStudents;

  /// No description provided for @adminTeachers.
  ///
  /// In en, this message translates to:
  /// **'Teachers'**
  String get adminTeachers;

  /// No description provided for @adminParents.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get adminParents;

  /// No description provided for @adminSecretaries.
  ///
  /// In en, this message translates to:
  /// **'Secretaries'**
  String get adminSecretaries;

  /// No description provided for @adminAdmins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get adminAdmins;

  /// No description provided for @adminTodaySessions.
  ///
  /// In en, this message translates to:
  /// **'Today\'s sessions'**
  String get adminTodaySessions;

  /// No description provided for @adminQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get adminQuickActions;

  /// No description provided for @adminAttendanceLast30.
  ///
  /// In en, this message translates to:
  /// **'Attendance — Last 30 Days'**
  String get adminAttendanceLast30;

  /// No description provided for @adminNoAttendanceData.
  ///
  /// In en, this message translates to:
  /// **'No attendance data for the last 30 days.'**
  String get adminNoAttendanceData;

  /// No description provided for @adminAddUser.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get adminAddUser;

  /// No description provided for @adminCreateUser.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get adminCreateUser;

  /// No description provided for @adminFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get adminFullName;

  /// No description provided for @adminEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get adminEmailAddress;

  /// No description provided for @adminRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminRoleLabel;

  /// No description provided for @adminUserCreated.
  ///
  /// In en, this message translates to:
  /// **'User Created'**
  String get adminUserCreated;

  /// No description provided for @adminTempPassword.
  ///
  /// In en, this message translates to:
  /// **'Temporary password'**
  String get adminTempPassword;

  /// No description provided for @adminCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get adminCopied;

  /// No description provided for @adminResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get adminResetPassword;

  /// No description provided for @adminPasswordReset.
  ///
  /// In en, this message translates to:
  /// **'Password Reset'**
  String get adminPasswordReset;

  /// No description provided for @adminTempPasswordFor.
  ///
  /// In en, this message translates to:
  /// **'Temporary password for {name}'**
  String adminTempPasswordFor(Object name);

  /// No description provided for @adminDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get adminDeleteUser;

  /// No description provided for @adminDeleteUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? This cannot be undone.'**
  String adminDeleteUserConfirm(Object name);

  /// No description provided for @adminDeleteCohort.
  ///
  /// In en, this message translates to:
  /// **'Delete Cohort'**
  String get adminDeleteCohort;

  /// No description provided for @adminDeleteCohortConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? All student memberships will be removed.'**
  String adminDeleteCohortConfirm(Object name);

  /// No description provided for @adminAddCohort.
  ///
  /// In en, this message translates to:
  /// **'Add Cohort'**
  String get adminAddCohort;

  /// No description provided for @adminNewCohort.
  ///
  /// In en, this message translates to:
  /// **'New Cohort'**
  String get adminNewCohort;

  /// No description provided for @adminCohortName.
  ///
  /// In en, this message translates to:
  /// **'Cohort Name (e.g. 10th-2)'**
  String get adminCohortName;

  /// No description provided for @adminCohortGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get adminCohortGrade;

  /// No description provided for @adminRenameCohort.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get adminRenameCohort;

  /// No description provided for @adminAddStudents.
  ///
  /// In en, this message translates to:
  /// **'Add Students'**
  String get adminAddStudents;

  /// No description provided for @adminAddTo.
  ///
  /// In en, this message translates to:
  /// **'Add to {name}'**
  String adminAddTo(Object name);

  /// No description provided for @adminRemoveStudent.
  ///
  /// In en, this message translates to:
  /// **'Remove Student'**
  String get adminRemoveStudent;

  /// No description provided for @adminRemoveStudentConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from {cohort}?'**
  String adminRemoveStudentConfirm(Object name, Object cohort);

  /// No description provided for @adminNoCohortsYet.
  ///
  /// In en, this message translates to:
  /// **'No cohorts yet'**
  String get adminNoCohortsYet;

  /// No description provided for @adminNoStudentsInCohort.
  ///
  /// In en, this message translates to:
  /// **'No students in this cohort'**
  String get adminNoStudentsInCohort;

  /// No description provided for @adminStudentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 student} other{{count} students}}'**
  String adminStudentCount(int count);

  /// No description provided for @adminSearchStudents.
  ///
  /// In en, this message translates to:
  /// **'Search students…'**
  String get adminSearchStudents;

  /// No description provided for @adminScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get adminScheduleTitle;

  /// No description provided for @adminScheduleAddPeriod.
  ///
  /// In en, this message translates to:
  /// **'Add period'**
  String get adminScheduleAddPeriod;

  /// No description provided for @adminScheduleNewPeriod.
  ///
  /// In en, this message translates to:
  /// **'New Period'**
  String get adminScheduleNewPeriod;

  /// No description provided for @adminScheduleDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get adminScheduleDayLabel;

  /// No description provided for @adminSchedulePeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'P{period}'**
  String adminSchedulePeriodLabel(Object period);

  /// No description provided for @adminScheduleTeacherLabel.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get adminScheduleTeacherLabel;

  /// No description provided for @adminScheduleNoneTeacher.
  ///
  /// In en, this message translates to:
  /// **'No teacher assigned'**
  String get adminScheduleNoneTeacher;

  /// No description provided for @adminScheduleCohortLabel.
  ///
  /// In en, this message translates to:
  /// **'Cohort / Students'**
  String get adminScheduleCohortLabel;

  /// No description provided for @adminScheduleFrequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get adminScheduleFrequencyLabel;

  /// No description provided for @adminScheduleFreqWeekly.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get adminScheduleFreqWeekly;

  /// No description provided for @adminScheduleFreqBiweekly.
  ///
  /// In en, this message translates to:
  /// **'Every 2 weeks'**
  String get adminScheduleFreqBiweekly;

  /// No description provided for @adminScheduleFreqMonthly.
  ///
  /// In en, this message translates to:
  /// **'Every 4 weeks'**
  String get adminScheduleFreqMonthly;

  /// No description provided for @adminScheduleFreqCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get adminScheduleFreqCustom;

  /// No description provided for @adminScheduleFreqCustomLabel.
  ///
  /// In en, this message translates to:
  /// **'Every {n} weeks'**
  String adminScheduleFreqCustomLabel(int n);

  /// No description provided for @adminScheduleAddSlot.
  ///
  /// In en, this message translates to:
  /// **'Add slot'**
  String get adminScheduleAddSlot;

  /// No description provided for @adminScheduleAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Add another day / period'**
  String get adminScheduleAddAnother;

  /// No description provided for @adminScheduleSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get adminScheduleSave;

  /// No description provided for @adminScheduleSearchTeacher.
  ///
  /// In en, this message translates to:
  /// **'Search teachers…'**
  String get adminScheduleSearchTeacher;

  /// No description provided for @adminScheduleSearchCohort.
  ///
  /// In en, this message translates to:
  /// **'Search cohorts…'**
  String get adminScheduleSearchCohort;

  /// No description provided for @adminScheduleSelectTeacher.
  ///
  /// In en, this message translates to:
  /// **'Select teacher'**
  String get adminScheduleSelectTeacher;

  /// No description provided for @adminScheduleSelectCohort.
  ///
  /// In en, this message translates to:
  /// **'Select cohort'**
  String get adminScheduleSelectCohort;

  /// No description provided for @adminScheduleOrStudents.
  ///
  /// In en, this message translates to:
  /// **'Or pick individual students'**
  String get adminScheduleOrStudents;

  /// No description provided for @adminScheduleNoSlots.
  ///
  /// In en, this message translates to:
  /// **'No periods yet'**
  String get adminScheduleNoSlots;

  /// No description provided for @adminScheduleNoSlotsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add the first period'**
  String get adminScheduleNoSlotsHint;

  /// No description provided for @adminSchoolSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'School Settings'**
  String get adminSchoolSettingsTitle;

  /// No description provided for @adminSchoolName.
  ///
  /// In en, this message translates to:
  /// **'School Name'**
  String get adminSchoolName;

  /// No description provided for @adminSchoolLogoUrl.
  ///
  /// In en, this message translates to:
  /// **'Logo URL (optional)'**
  String get adminSchoolLogoUrl;

  /// No description provided for @adminSchoolLogoHint.
  ///
  /// In en, this message translates to:
  /// **'https://…'**
  String get adminSchoolLogoHint;

  /// No description provided for @adminSchoolSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get adminSchoolSaved;

  /// No description provided for @adminSubjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get adminSubjectsTitle;

  /// No description provided for @adminSubjectsGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade {grade}'**
  String adminSubjectsGrade(int grade);

  /// No description provided for @adminSubjectsAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add subject…'**
  String get adminSubjectsAddHint;

  /// No description provided for @adminSubjectsNoSubjects.
  ///
  /// In en, this message translates to:
  /// **'No subjects configured'**
  String get adminSubjectsNoSubjects;

  /// No description provided for @adminSubjectsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get adminSubjectsAdd;

  /// No description provided for @adminSubjectsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get adminSubjectsRemove;

  /// No description provided for @adminSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get adminSettingsTitle;

  /// No description provided for @adminSettingsBellSchedule.
  ///
  /// In en, this message translates to:
  /// **'Bell Schedule'**
  String get adminSettingsBellSchedule;

  /// No description provided for @adminSettingsPeriodDefaults.
  ///
  /// In en, this message translates to:
  /// **'Period Defaults'**
  String get adminSettingsPeriodDefaults;

  /// No description provided for @adminSettingsPeriodDefaultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set bell times for each period'**
  String get adminSettingsPeriodDefaultsSubtitle;

  /// No description provided for @adminDeleteConfirmCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminDeleteConfirmCancel;

  /// No description provided for @adminDeleteConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get adminDeleteConfirmDelete;

  /// No description provided for @adminSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get adminSave;

  /// No description provided for @adminCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminCancel;

  /// No description provided for @adminSearchPeople.
  ///
  /// In en, this message translates to:
  /// **'Search by name…'**
  String get adminSearchPeople;

  /// No description provided for @adminNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String adminNoResults(Object query);

  /// No description provided for @adminNoPeopleYet.
  ///
  /// In en, this message translates to:
  /// **'No {role} yet'**
  String adminNoPeopleYet(Object role);

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @chatThreadLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this conversation'**
  String get chatThreadLoadFailedTitle;

  /// No description provided for @chatThreadLoadFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get chatThreadLoadFailedBody;

  /// No description provided for @chatThreadLoadFailedBusy.
  ///
  /// In en, this message translates to:
  /// **'The server is a little busy right now. Give it a moment, then retry.'**
  String get chatThreadLoadFailedBusy;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get commonDownload;

  /// No description provided for @commonOpenExternally.
  ///
  /// In en, this message translates to:
  /// **'Open externally'**
  String get commonOpenExternally;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get commonSearch;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @inboxActionPin.
  ///
  /// In en, this message translates to:
  /// **'Pin chat'**
  String get inboxActionPin;

  /// No description provided for @inboxActionUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin chat'**
  String get inboxActionUnpin;

  /// No description provided for @inboxActionMute.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get inboxActionMute;

  /// No description provided for @inboxActionUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get inboxActionUnmute;

  /// No description provided for @inboxActionMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get inboxActionMarkRead;

  /// No description provided for @inboxActionMarkUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get inboxActionMarkUnread;

  /// No description provided for @inboxActionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear messages'**
  String get inboxActionClear;

  /// No description provided for @inboxActionClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all messages in this chat? This only clears your copy — the other side keeps theirs.'**
  String get inboxActionClearConfirm;

  /// No description provided for @inboxActionDeleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete chat'**
  String get inboxActionDeleteChat;

  /// No description provided for @inboxActionDeleteChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this chat? It disappears from your list and history; it comes back if they message you again.'**
  String get inboxActionDeleteChatConfirm;

  /// No description provided for @inboxActionBlock.
  ///
  /// In en, this message translates to:
  /// **'Block contact'**
  String get inboxActionBlock;

  /// No description provided for @inboxActionBlockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Block this contact? They won\'t be able to message you anymore.'**
  String get inboxActionBlockConfirm;

  /// No description provided for @cmailActionMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get cmailActionMarkRead;

  /// No description provided for @cmailActionMarkUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get cmailActionMarkUnread;

  /// No description provided for @cmailDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this mail from your mailbox?'**
  String get cmailDeleteConfirm;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get commonError;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @studentMaterialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get studentMaterialsTitle;

  /// No description provided for @studentMaterialsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No materials shared yet'**
  String get studentMaterialsEmptyTitle;

  /// No description provided for @studentMaterialsEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Your teacher will share resources here.'**
  String get studentMaterialsEmptyHint;

  /// No description provided for @studentMaterialsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load materials'**
  String get studentMaterialsLoadError;

  /// No description provided for @studentAssignmentSubmittedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Assignment handed in!'**
  String get studentAssignmentSubmittedSnackbar;

  /// No description provided for @studentAssignmentSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not submit — please try again.'**
  String get studentAssignmentSubmitFailed;

  /// No description provided for @studentAssignmentUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'File upload failed — please try again.'**
  String get studentAssignmentUploadFailed;

  /// No description provided for @studentAssignmentHandedInBadge.
  ///
  /// In en, this message translates to:
  /// **'Handed in'**
  String get studentAssignmentHandedInBadge;

  /// No description provided for @studentAssignmentSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Hand in'**
  String get studentAssignmentSubmitButton;

  /// No description provided for @studentAssignmentSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Handing in…'**
  String get studentAssignmentSubmitting;

  /// No description provided for @studentAssignmentAttachFile.
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get studentAssignmentAttachFile;

  /// No description provided for @studentAssignmentAddMoreFiles.
  ///
  /// In en, this message translates to:
  /// **'Add more files'**
  String get studentAssignmentAddMoreFiles;

  /// No description provided for @studentAssignmentYourSubmission.
  ///
  /// In en, this message translates to:
  /// **'Your submission'**
  String get studentAssignmentYourSubmission;

  /// No description provided for @studentAssignmentTeacherAttachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get studentAssignmentTeacherAttachments;

  /// No description provided for @secretaryWelcomeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi {name} 👋'**
  String secretaryWelcomeGreeting(Object name);

  /// No description provided for @secretaryYourTools.
  ///
  /// In en, this message translates to:
  /// **'Your tools'**
  String get secretaryYourTools;

  /// No description provided for @secretaryReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get secretaryReports;

  /// No description provided for @secretaryExportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get secretaryExportData;

  /// No description provided for @secretaryHomeTile.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get secretaryHomeTile;

  /// No description provided for @parentHomeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi {name} 👋'**
  String parentHomeGreeting(Object name);

  /// No description provided for @parentYourTools.
  ///
  /// In en, this message translates to:
  /// **'Your tools'**
  String get parentYourTools;

  /// No description provided for @parentNoChildLinked.
  ///
  /// In en, this message translates to:
  /// **'No child linked yet'**
  String get parentNoChildLinked;

  /// No description provided for @parentPickChildFirst.
  ///
  /// In en, this message translates to:
  /// **'Pick a child first'**
  String get parentPickChildFirst;

  /// No description provided for @parentNoApprovedChildren.
  ///
  /// In en, this message translates to:
  /// **'No approved children yet. Ask your school to link your account.'**
  String get parentNoApprovedChildren;

  /// No description provided for @loginEmptyFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email or username and password.'**
  String get loginEmptyFieldsError;

  /// No description provided for @loginConnectionError.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your internet and try again.'**
  String get loginConnectionError;

  /// No description provided for @loginTimeoutError.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get loginTimeoutError;

  /// No description provided for @loginForgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPasswordLink;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordModeEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get forgotPasswordModeEmail;

  /// No description provided for @forgotPasswordModeSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get forgotPasswordModeSms;

  /// No description provided for @forgotPasswordEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent (if an account matches).'**
  String get forgotPasswordEmailSent;

  /// No description provided for @forgotPasswordEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Enter your email or username to continue.'**
  String get forgotPasswordEmptyError;

  /// No description provided for @forgotPasswordEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Email me a reset link'**
  String get forgotPasswordEmailButton;

  /// No description provided for @forgotPasswordSmsButton.
  ///
  /// In en, this message translates to:
  /// **'Text me a reset link'**
  String get forgotPasswordSmsButton;

  /// No description provided for @forgotPasswordLinkExpires.
  ///
  /// In en, this message translates to:
  /// **'The link expires in 1 hour and can only be used once.'**
  String get forgotPasswordLinkExpires;

  /// No description provided for @pushPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay in the loop'**
  String get pushPermissionTitle;

  /// No description provided for @pushPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Turn on notifications so you don\'t miss grades, messages, or schedule changes.'**
  String get pushPermissionBody;

  /// No description provided for @commonRequiredField.
  ///
  /// In en, this message translates to:
  /// **'{field} required'**
  String commonRequiredField(Object field);

  /// No description provided for @commonAttachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get commonAttachments;

  /// No description provided for @commonAttachFile.
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get commonAttachFile;

  /// No description provided for @commonReplaceFile.
  ///
  /// In en, this message translates to:
  /// **'Replace file'**
  String get commonReplaceFile;

  /// No description provided for @commonTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title required'**
  String get commonTitleRequired;

  /// No description provided for @commonPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get commonPublish;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get commonStart;

  /// No description provided for @commonEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get commonEnd;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get commonRemove;

  /// No description provided for @commonOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get commonOpen;

  /// No description provided for @commonView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get commonView;

  /// No description provided for @commonCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get commonCopy;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get commonOptional;

  /// No description provided for @commonRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get commonRequired;

  /// No description provided for @commonAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get commonAuto;

  /// No description provided for @teacherShareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get teacherShareButton;

  /// No description provided for @teacherMaterialDetails.
  ///
  /// In en, this message translates to:
  /// **'Material Details'**
  String get teacherMaterialDetails;

  /// No description provided for @teacherMaterialTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get teacherMaterialTitleLabel;

  /// No description provided for @teacherMaterialDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get teacherMaterialDescriptionLabel;

  /// No description provided for @teacherMaterialContentSection.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get teacherMaterialContentSection;

  /// No description provided for @teacherMaterialContentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please attach a file or add a link'**
  String get teacherMaterialContentRequired;

  /// No description provided for @teacherFilePickError.
  ///
  /// In en, this message translates to:
  /// **'Could not pick file: {error}'**
  String teacherFilePickError(Object error);

  /// No description provided for @teacherScheduleButton.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get teacherScheduleButton;

  /// No description provided for @teacherMeetingTitleField.
  ///
  /// In en, this message translates to:
  /// **'Meeting title *'**
  String get teacherMeetingTitleField;

  /// No description provided for @teacherMeetingLinkField.
  ///
  /// In en, this message translates to:
  /// **'Meeting link *'**
  String get teacherMeetingLinkField;

  /// No description provided for @teacherMeetingLinkRequired.
  ///
  /// In en, this message translates to:
  /// **'Meeting link required'**
  String get teacherMeetingLinkRequired;

  /// No description provided for @teacherMeetingTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Meeting title required'**
  String get teacherMeetingTitleRequired;

  /// No description provided for @teacherMeetingDateTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'Start date and time required'**
  String get teacherMeetingDateTimeRequired;

  /// No description provided for @teacherMeetingStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start date *'**
  String get teacherMeetingStartDate;

  /// No description provided for @teacherMeetingStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start time *'**
  String get teacherMeetingStartTime;

  /// No description provided for @teacherMeetingEndDate.
  ///
  /// In en, this message translates to:
  /// **'End date (optional)'**
  String get teacherMeetingEndDate;

  /// No description provided for @teacherMeetingEndTime.
  ///
  /// In en, this message translates to:
  /// **'End time (optional)'**
  String get teacherMeetingEndTime;

  /// No description provided for @teacherClearEndTime.
  ///
  /// In en, this message translates to:
  /// **'Clear end time'**
  String get teacherClearEndTime;

  /// No description provided for @teacherAssignmentTitleField.
  ///
  /// In en, this message translates to:
  /// **'Title *'**
  String get teacherAssignmentTitleField;

  /// No description provided for @teacherAssignmentInstructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions (optional)'**
  String get teacherAssignmentInstructions;

  /// No description provided for @teacherAssignmentDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date (optional)'**
  String get teacherAssignmentDueDate;

  /// No description provided for @teacherAssignmentClearDueDate.
  ///
  /// In en, this message translates to:
  /// **'Clear due date'**
  String get teacherAssignmentClearDueDate;

  /// No description provided for @teacherAssignmentMaxGrade.
  ///
  /// In en, this message translates to:
  /// **'Max grade (optional)'**
  String get teacherAssignmentMaxGrade;

  /// No description provided for @teacherAssignmentPublished.
  ///
  /// In en, this message translates to:
  /// **'Assignment published.'**
  String get teacherAssignmentPublished;

  /// No description provided for @teacherAssignmentDraftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved.'**
  String get teacherAssignmentDraftSaved;

  /// No description provided for @teacherCreateAssignment.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get teacherCreateAssignment;

  /// No description provided for @teacherExamSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject *'**
  String get teacherExamSubject;

  /// No description provided for @teacherExamDate.
  ///
  /// In en, this message translates to:
  /// **'Exam date *'**
  String get teacherExamDate;

  /// No description provided for @teacherSelectSubject.
  ///
  /// In en, this message translates to:
  /// **'Select subject'**
  String get teacherSelectSubject;

  /// No description provided for @teacherNoSubjectOption.
  ///
  /// In en, this message translates to:
  /// **'No subject'**
  String get teacherNoSubjectOption;

  /// No description provided for @teacherOtherSubjectOption.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get teacherOtherSubjectOption;

  /// No description provided for @teacherSearchClassrooms.
  ///
  /// In en, this message translates to:
  /// **'Search classrooms…'**
  String get teacherSearchClassrooms;

  /// No description provided for @teacherSearchMaterials.
  ///
  /// In en, this message translates to:
  /// **'Search materials…'**
  String get teacherSearchMaterials;

  /// No description provided for @teacherClassroomName.
  ///
  /// In en, this message translates to:
  /// **'Classroom name *'**
  String get teacherClassroomName;

  /// No description provided for @adminReportsOpenTab.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get adminReportsOpenTab;

  /// No description provided for @adminReportsResolvedTab.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get adminReportsResolvedTab;

  /// No description provided for @adminReportsDismissedTab.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get adminReportsDismissedTab;

  /// No description provided for @adminReportsNoOpen.
  ///
  /// In en, this message translates to:
  /// **'No open reports'**
  String get adminReportsNoOpen;

  /// No description provided for @adminReportsNoInView.
  ///
  /// In en, this message translates to:
  /// **'No reports in this view'**
  String get adminReportsNoInView;

  /// No description provided for @adminReportsMediaAttachment.
  ///
  /// In en, this message translates to:
  /// **'[Media attachment]'**
  String get adminReportsMediaAttachment;

  /// No description provided for @adminReportsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'(empty message)'**
  String get adminReportsEmptyMessage;

  /// No description provided for @adminReportsDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get adminReportsDismiss;

  /// No description provided for @adminReportsResolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get adminReportsResolve;

  /// No description provided for @adminReportsReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String adminReportsReason(Object reason);

  /// No description provided for @chatReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report message'**
  String get chatReportTitle;

  /// No description provided for @chatReportButton.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get chatReportButton;

  /// No description provided for @chatReportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reported. Thank you — an admin will review.'**
  String get chatReportSuccess;

  /// No description provided for @chatReportFailed.
  ///
  /// In en, this message translates to:
  /// **'Report failed: {error}'**
  String chatReportFailed(Object error);

  /// No description provided for @chatSendError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send: {message}'**
  String chatSendError(Object message);

  /// No description provided for @chatForwardLabel.
  ///
  /// In en, this message translates to:
  /// **'Forward {count}'**
  String chatForwardLabel(Object count);

  /// No description provided for @chatDeleteLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete {count}'**
  String chatDeleteLabel(Object count);

  /// No description provided for @chatSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String chatSelectedCount(Object count);

  /// No description provided for @adminSetupSchoolSetup.
  ///
  /// In en, this message translates to:
  /// **'School Setup'**
  String get adminSetupSchoolSetup;

  /// No description provided for @adminSetupComplete.
  ///
  /// In en, this message translates to:
  /// **'You\'re all set. Tap any item to revisit or refine it.'**
  String get adminSetupComplete;

  /// No description provided for @adminSetupInstructions.
  ///
  /// In en, this message translates to:
  /// **'Complete these steps to fully set up your school.'**
  String get adminSetupInstructions;

  /// No description provided for @adminSetupLogoTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload school logo'**
  String get adminSetupLogoTitle;

  /// No description provided for @adminSetupLogoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Appears in headers and the drawer'**
  String get adminSetupLogoSubtitle;

  /// No description provided for @adminSetupNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Set school name'**
  String get adminSetupNameTitle;

  /// No description provided for @adminSetupNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Shown to students, teachers, and parents'**
  String get adminSetupNameSubtitle;

  /// No description provided for @adminSetupSubjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'Define subjects'**
  String get adminSetupSubjectsTitle;

  /// No description provided for @adminSetupSubjectsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'At least one grade with subjects configured'**
  String get adminSetupSubjectsSubtitle;

  /// No description provided for @adminSetupBellTitle.
  ///
  /// In en, this message translates to:
  /// **'Set bell schedule'**
  String get adminSetupBellTitle;

  /// No description provided for @adminSetupBellSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start/end times for each period'**
  String get adminSetupBellSubtitle;

  /// No description provided for @adminSetupCohortsTitle.
  ///
  /// In en, this message translates to:
  /// **'Create cohorts'**
  String get adminSetupCohortsTitle;

  /// No description provided for @adminSetupCohortsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up your class groups'**
  String get adminSetupCohortsSubtitle;

  /// No description provided for @adminSetupStudentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add students'**
  String get adminSetupStudentsTitle;

  /// No description provided for @adminSetupStudentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create accounts or generate join codes'**
  String get adminSetupStudentsSubtitle;

  /// No description provided for @adminSetupTeachersTitle.
  ///
  /// In en, this message translates to:
  /// **'Add teachers'**
  String get adminSetupTeachersTitle;

  /// No description provided for @adminSetupTeachersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create teacher accounts'**
  String get adminSetupTeachersSubtitle;

  /// No description provided for @supportContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Talk to us'**
  String get supportContactTitle;

  /// No description provided for @supportContactDescription.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find your answer below? Get in touch and we\'ll come back to you within a working day.'**
  String get supportContactDescription;

  /// No description provided for @supportEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get supportEmailLabel;

  /// No description provided for @supportPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get supportPhoneLabel;

  /// No description provided for @supportSmsLabel.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get supportSmsLabel;

  /// No description provided for @supportAiCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get supportAiCardTitle;

  /// No description provided for @supportAiCardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Instant answers about using ClassMate — any time'**
  String get supportAiCardSubtitle;

  /// No description provided for @supportAiSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'ClassMate Assistant'**
  String get supportAiSheetTitle;

  /// No description provided for @supportAiGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m the ClassMate assistant. Ask me anything about using the app — logging in, your schedule, grades, messages, and more.'**
  String get supportAiGreeting;

  /// No description provided for @supportAiInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask a question…'**
  String get supportAiInputHint;

  /// No description provided for @supportAiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI can make mistakes. For account, billing, or bug reports, email support@classmateapp.org.'**
  String get supportAiDisclaimer;

  /// No description provided for @supportAiError.
  ///
  /// In en, this message translates to:
  /// **'Sorry — I couldn\'t answer that right now. Please try again, or contact support above.'**
  String get supportAiError;

  /// No description provided for @aboutWhatIsClassmate.
  ///
  /// In en, this message translates to:
  /// **'What is ClassMate?'**
  String get aboutWhatIsClassmate;

  /// No description provided for @aboutClassmateDescription.
  ///
  /// In en, this message translates to:
  /// **'ClassMate is the school operating system for students, teachers, administrators, and parents. One app, four roles, every part of the school day in a single place — schedule, attendance, grades, classrooms, assignments, messaging, and an AI study buddy.'**
  String get aboutClassmateDescription;

  /// No description provided for @aboutMultilingualTitle.
  ///
  /// In en, this message translates to:
  /// **'Built for schools that speak more than one language'**
  String get aboutMultilingualTitle;

  /// No description provided for @aboutMultilingualDescription.
  ///
  /// In en, this message translates to:
  /// **'Every name, subject, and announcement can carry up to five language variants (English, Arabic, Hebrew, French, Russian). Students see the language they\'re most comfortable with; teachers manage in theirs.'**
  String get aboutMultilingualDescription;

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy first'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacyDescription.
  ///
  /// In en, this message translates to:
  /// **'School data stays inside the school. Roles map cleanly onto what each person can see — teachers see their classrooms, admins see their school, parents see their children. No third-party trackers, no ad networks.'**
  String get aboutPrivacyDescription;

  /// No description provided for @aboutContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get aboutContactTitle;

  /// No description provided for @aboutContactDescription.
  ///
  /// In en, this message translates to:
  /// **'Built by the ClassMate team.\nQuestions: support@classmateapp.org'**
  String get aboutContactDescription;

  /// No description provided for @aboutVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'ClassMate · v{version}'**
  String aboutVersionLabel(Object version);

  /// No description provided for @adminAddStudent.
  ///
  /// In en, this message translates to:
  /// **'Add student'**
  String get adminAddStudent;

  /// No description provided for @adminAddTeacher.
  ///
  /// In en, this message translates to:
  /// **'Add teacher'**
  String get adminAddTeacher;

  /// No description provided for @adminAddParent.
  ///
  /// In en, this message translates to:
  /// **'Add parent'**
  String get adminAddParent;

  /// No description provided for @adminAddSecretary.
  ///
  /// In en, this message translates to:
  /// **'Add secretary'**
  String get adminAddSecretary;

  /// No description provided for @adminAddAdmin.
  ///
  /// In en, this message translates to:
  /// **'Add admin'**
  String get adminAddAdmin;

  /// No description provided for @adminEditUser.
  ///
  /// In en, this message translates to:
  /// **'Edit user'**
  String get adminEditUser;

  /// No description provided for @adminNoEmailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'(no email)'**
  String get adminNoEmailPlaceholder;

  /// No description provided for @adminNameEnglishRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name (English) is required'**
  String get adminNameEnglishRequired;

  /// No description provided for @adminUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required'**
  String get adminUsernameRequired;

  /// No description provided for @adminPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters (or leave blank to auto-generate)'**
  String get adminPasswordMinLength;

  /// No description provided for @adminUserCreatedMsg.
  ///
  /// In en, this message translates to:
  /// **'{name} created.'**
  String adminUserCreatedMsg(Object name);

  /// No description provided for @adminCredsUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get adminCredsUsername;

  /// No description provided for @adminCredsEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get adminCredsEmail;

  /// No description provided for @adminCredsPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get adminCredsPassword;

  /// No description provided for @adminShareCredsHint.
  ///
  /// In en, this message translates to:
  /// **'Share these credentials with the student.'**
  String get adminShareCredsHint;

  /// No description provided for @adminCopyCredsButton.
  ///
  /// In en, this message translates to:
  /// **'Copy All'**
  String get adminCopyCredsButton;

  /// No description provided for @adminGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get adminGradeLabel;

  /// No description provided for @adminCohortGradeFormat.
  ///
  /// In en, this message translates to:
  /// **'Grade {grade}'**
  String adminCohortGradeFormat(Object grade);

  /// No description provided for @adminCreateAndAddStudents.
  ///
  /// In en, this message translates to:
  /// **'Create & Add Students'**
  String get adminCreateAndAddStudents;

  /// No description provided for @adminAddStudentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Students'**
  String get adminAddStudentsTitle;

  /// No description provided for @adminSkipAdding.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get adminSkipAdding;

  /// No description provided for @adminInCohortBadge.
  ///
  /// In en, this message translates to:
  /// **'In cohort'**
  String get adminInCohortBadge;

  /// No description provided for @adminNoStudentsFoundCohort.
  ///
  /// In en, this message translates to:
  /// **'No students found in this cohort\'s grades'**
  String get adminNoStudentsFoundCohort;

  /// No description provided for @adminScheduleByCohort.
  ///
  /// In en, this message translates to:
  /// **'By Cohort ▾'**
  String get adminScheduleByCohort;

  /// No description provided for @adminScheduleByStudent.
  ///
  /// In en, this message translates to:
  /// **'By Student ▾'**
  String get adminScheduleByStudent;

  /// No description provided for @adminScheduleByGrade.
  ///
  /// In en, this message translates to:
  /// **'By Grade ▾'**
  String get adminScheduleByGrade;

  /// No description provided for @navSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get navSupport;

  /// No description provided for @navAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get navAbout;

  /// No description provided for @adminScheduleAddGrade.
  ///
  /// In en, this message translates to:
  /// **'Add grade'**
  String get adminScheduleAddGrade;

  /// No description provided for @adminScheduleAddCohort.
  ///
  /// In en, this message translates to:
  /// **'Add cohort'**
  String get adminScheduleAddCohort;

  /// No description provided for @adminScheduleAddStudent.
  ///
  /// In en, this message translates to:
  /// **'Add student'**
  String get adminScheduleAddStudent;

  /// No description provided for @adminScheduleClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get adminScheduleClearFilters;

  /// No description provided for @adminSchedulePickSubjectRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick a subject before saving the period.'**
  String get adminSchedulePickSubjectRequired;

  /// No description provided for @adminSchedulePickDateOnce.
  ///
  /// In en, this message translates to:
  /// **'Pick a date for a one-off period.'**
  String get adminSchedulePickDateOnce;

  /// No description provided for @adminSchedulePickDateRecurring.
  ///
  /// In en, this message translates to:
  /// **'Pick a start date for the every-{freq}-weeks schedule.'**
  String adminSchedulePickDateRecurring(Object freq);

  /// No description provided for @adminSchoolLogoLabel.
  ///
  /// In en, this message translates to:
  /// **'School Logo'**
  String get adminSchoolLogoLabel;

  /// No description provided for @adminSchoolLogoUploaded.
  ///
  /// In en, this message translates to:
  /// **'Logo uploaded'**
  String get adminSchoolLogoUploaded;

  /// No description provided for @adminSchoolNoLogoYet.
  ///
  /// In en, this message translates to:
  /// **'No logo yet'**
  String get adminSchoolNoLogoYet;

  /// No description provided for @adminSchoolLogoDescription.
  ///
  /// In en, this message translates to:
  /// **'Appears next to your school name in the app drawer.'**
  String get adminSchoolLogoDescription;

  /// No description provided for @adminSchoolLogoChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get adminSchoolLogoChange;

  /// No description provided for @adminSchoolLogoUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get adminSchoolLogoUpload;

  /// No description provided for @adminSchoolLogoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get adminSchoolLogoRemove;

  /// No description provided for @adminSchoolGradeRangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade range'**
  String get adminSchoolGradeRangeLabel;

  /// No description provided for @adminSchoolGradeRangeDescription.
  ///
  /// In en, this message translates to:
  /// **'Grades available across cohorts, students, and pickers.'**
  String get adminSchoolGradeRangeDescription;

  /// No description provided for @adminSchoolLowestGrade.
  ///
  /// In en, this message translates to:
  /// **'Lowest'**
  String get adminSchoolLowestGrade;

  /// No description provided for @adminSchoolHighestGrade.
  ///
  /// In en, this message translates to:
  /// **'Highest'**
  String get adminSchoolHighestGrade;

  /// No description provided for @adminSchoolSubjectsTitle.
  ///
  /// In en, this message translates to:
  /// **'School Subjects'**
  String get adminSchoolSubjectsTitle;

  /// No description provided for @adminSchoolSubjectsDescription.
  ///
  /// In en, this message translates to:
  /// **'Available to all teachers when creating assignments.'**
  String get adminSchoolSubjectsDescription;

  /// No description provided for @adminSchoolNoTranslations.
  ///
  /// In en, this message translates to:
  /// **'Tap to add translations'**
  String get adminSchoolNoTranslations;

  /// No description provided for @adminSchoolBellHint.
  ///
  /// In en, this message translates to:
  /// **'Set start and end times for each period. Add or remove periods as needed.'**
  String get adminSchoolBellHint;

  /// No description provided for @adminSchoolBellTitle.
  ///
  /// In en, this message translates to:
  /// **'Bell Schedule'**
  String get adminSchoolBellTitle;

  /// No description provided for @adminSchoolBellInfo.
  ///
  /// In en, this message translates to:
  /// **'Set the start and end time for each period. These become the default times used when building the weekly schedule.'**
  String get adminSchoolBellInfo;

  /// No description provided for @adminSchoolStartTime.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get adminSchoolStartTime;

  /// No description provided for @adminSchoolEndTime.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get adminSchoolEndTime;

  /// No description provided for @adminExportStudentsTab.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get adminExportStudentsTab;

  /// No description provided for @adminExportCohortsTab.
  ///
  /// In en, this message translates to:
  /// **'Cohorts'**
  String get adminExportCohortsTab;

  /// No description provided for @adminExportGradesTab.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get adminExportGradesTab;

  /// No description provided for @adminExportOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Options'**
  String get adminExportOptionsTitle;

  /// No description provided for @adminExportIncludePasswords.
  ///
  /// In en, this message translates to:
  /// **'Include Passwords'**
  String get adminExportIncludePasswords;

  /// No description provided for @adminExportLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Name language in the export'**
  String get adminExportLanguageLabel;

  /// No description provided for @adminExportCsvButton.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get adminExportCsvButton;

  /// No description provided for @adminExportPdfButton.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get adminExportPdfButton;

  /// No description provided for @teacherCreateClassroomTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create classroom'**
  String get teacherCreateClassroomTooltip;

  /// No description provided for @teacherClassroomNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Classroom name *'**
  String get teacherClassroomNameRequired;

  /// No description provided for @teacherSubjectRequired.
  ///
  /// In en, this message translates to:
  /// **'Subject *'**
  String get teacherSubjectRequired;

  /// No description provided for @messagesStartChatError.
  ///
  /// In en, this message translates to:
  /// **'Could not start chat: {error}'**
  String messagesStartChatError(Object error);

  /// No description provided for @messagesNoPeopleMatch.
  ///
  /// In en, this message translates to:
  /// **'No people match \"{query}\"'**
  String messagesNoPeopleMatch(Object query);

  /// No description provided for @messagesNoPeopleFound.
  ///
  /// In en, this message translates to:
  /// **'No people found'**
  String get messagesNoPeopleFound;

  /// No description provided for @messagesPeopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String messagesPeopleCount(int count);

  /// No description provided for @studentAssignmentValidationRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a note or attach a file before handing in.'**
  String get studentAssignmentValidationRequired;

  /// No description provided for @studentFormSubmittedBanner.
  ///
  /// In en, this message translates to:
  /// **'Your submitted answers'**
  String get studentFormSubmittedBanner;

  /// No description provided for @studentFormSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Could not submit: {error}'**
  String studentFormSubmitError(Object error);

  /// No description provided for @studentFormFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required: {field}'**
  String studentFormFieldRequired(Object field);

  /// No description provided for @studentFormClosedButton.
  ///
  /// In en, this message translates to:
  /// **'Form closed'**
  String get studentFormClosedButton;

  /// No description provided for @studentFormAlreadySubmittedButton.
  ///
  /// In en, this message translates to:
  /// **'Already submitted'**
  String get studentFormAlreadySubmittedButton;

  /// No description provided for @studentDiplomaEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Certificate'**
  String get studentDiplomaEditTitle;

  /// No description provided for @studentDiplomaDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete certificate?'**
  String get studentDiplomaDeleteTitle;

  /// No description provided for @studentDiplomaDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove certificate for \"{name}\"?'**
  String studentDiplomaDeleteConfirm(Object name);

  /// No description provided for @teacherDeleteItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String teacherDeleteItemConfirm(Object title);

  /// No description provided for @teacherPublishTooltip.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get teacherPublishTooltip;

  /// No description provided for @teacherMeetingEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title.'**
  String get teacherMeetingEnterTitle;

  /// No description provided for @teacherMeetingEnterLink.
  ///
  /// In en, this message translates to:
  /// **'Please enter a meeting link.'**
  String get teacherMeetingEnterLink;

  /// No description provided for @teacherMeetingEnterValidUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL (e.g. https://zoom.us/j/...)'**
  String get teacherMeetingEnterValidUrl;

  /// No description provided for @teacherMeetingPickStartTime.
  ///
  /// In en, this message translates to:
  /// **'Please pick a start time.'**
  String get teacherMeetingPickStartTime;

  /// No description provided for @teacherMeetingVisibleToEveryone.
  ///
  /// In en, this message translates to:
  /// **'Visible to everyone'**
  String get teacherMeetingVisibleToEveryone;

  /// No description provided for @teacherMeetingDoneCount.
  ///
  /// In en, this message translates to:
  /// **'Done ({count} selected)'**
  String teacherMeetingDoneCount(int count);

  /// No description provided for @teacherDeleteAssignmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete assignment?'**
  String get teacherDeleteAssignmentTitle;

  /// No description provided for @teacherDeleteAssignmentBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the assignment and all submissions.'**
  String get teacherDeleteAssignmentBody;

  /// No description provided for @teacherEditTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get teacherEditTooltip;

  /// No description provided for @teacherDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get teacherDeleteTooltip;

  /// No description provided for @teacherClassroomBackTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get teacherClassroomBackTooltip;

  /// No description provided for @teacherClassroomGenericError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String teacherClassroomGenericError(Object error);

  /// No description provided for @teacherClassroomAttachFailed.
  ///
  /// In en, this message translates to:
  /// **'Attach failed: {error}'**
  String teacherClassroomAttachFailed(Object error);

  /// No description provided for @teacherClassroomFileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This file is not available — the teacher should re-upload it.'**
  String get teacherClassroomFileUnavailable;

  /// No description provided for @teacherClassroomCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Classroom code'**
  String get teacherClassroomCodeLabel;

  /// No description provided for @teacherClassroomCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get teacherClassroomCodeCopied;

  /// No description provided for @teacherClassroomCopyCodeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get teacherClassroomCopyCodeTooltip;

  /// No description provided for @teacherClassroomCouldNotAdd.
  ///
  /// In en, this message translates to:
  /// **'Could not add: {emails} — check their email address.'**
  String teacherClassroomCouldNotAdd(Object emails);

  /// No description provided for @teacherClassroomAddStudents.
  ///
  /// In en, this message translates to:
  /// **'Add students'**
  String get teacherClassroomAddStudents;

  /// No description provided for @teacherClassroomSearchNameGrade.
  ///
  /// In en, this message translates to:
  /// **'Search by name or grade…'**
  String get teacherClassroomSearchNameGrade;

  /// No description provided for @teacherClassroomNoStudentsFound.
  ///
  /// In en, this message translates to:
  /// **'No students found'**
  String get teacherClassroomNoStudentsFound;

  /// No description provided for @teacherClassroomNameSubjectRequired.
  ///
  /// In en, this message translates to:
  /// **'Name and subject are required.'**
  String get teacherClassroomNameSubjectRequired;

  /// No description provided for @teacherClassroomCreated.
  ///
  /// In en, this message translates to:
  /// **'Classroom created!'**
  String get teacherClassroomCreated;

  /// No description provided for @teacherCustomSubjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom subject *'**
  String get teacherCustomSubjectLabel;

  /// No description provided for @teacherCreateClassroomButton.
  ///
  /// In en, this message translates to:
  /// **'Create Classroom'**
  String get teacherCreateClassroomButton;

  /// No description provided for @teacherCreateFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Form'**
  String get teacherCreateFormTitle;

  /// No description provided for @teacherFormSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get teacherFormSaveDraft;

  /// No description provided for @teacherFormTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Form title *'**
  String get teacherFormTitleHint;

  /// No description provided for @teacherFormDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get teacherFormDescriptionHint;

  /// No description provided for @teacherFormAcceptingResponses.
  ///
  /// In en, this message translates to:
  /// **'Accepting responses'**
  String get teacherFormAcceptingResponses;

  /// No description provided for @teacherFormAllowMultiple.
  ///
  /// In en, this message translates to:
  /// **'Allow multiple responses'**
  String get teacherFormAllowMultiple;

  /// No description provided for @teacherFormAllowMultipleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Off = once per student (default)'**
  String get teacherFormAllowMultipleSubtitle;

  /// No description provided for @teacherFormQuestionsSection.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get teacherFormQuestionsSection;

  /// No description provided for @teacherFormAddQuestionButton.
  ///
  /// In en, this message translates to:
  /// **'Add question'**
  String get teacherFormAddQuestionButton;

  /// No description provided for @teacherFormQuestionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Question {index}'**
  String teacherFormQuestionPlaceholder(Object index);

  /// No description provided for @teacherFormRequiredToggle.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get teacherFormRequiredToggle;

  /// No description provided for @teacherFormAddOptionButton.
  ///
  /// In en, this message translates to:
  /// **'Add option'**
  String get teacherFormAddOptionButton;

  /// No description provided for @teacherFormMinLabel.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get teacherFormMinLabel;

  /// No description provided for @teacherFormMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get teacherFormMaxLabel;

  /// No description provided for @teacherFormEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a form title.'**
  String get teacherFormEnterTitle;

  /// No description provided for @teacherExamUploadFailedSkipped.
  ///
  /// In en, this message translates to:
  /// **'Upload failed for {name}. File skipped.'**
  String teacherExamUploadFailedSkipped(Object name);

  /// No description provided for @teacherExamEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title.'**
  String get teacherExamEnterTitle;

  /// No description provided for @teacherExamPickDate.
  ///
  /// In en, this message translates to:
  /// **'Please pick an exam date.'**
  String get teacherExamPickDate;

  /// No description provided for @teacherExamSelectSubject.
  ///
  /// In en, this message translates to:
  /// **'Please select a subject.'**
  String get teacherExamSelectSubject;

  /// No description provided for @teacherSlotDetachFailed.
  ///
  /// In en, this message translates to:
  /// **'Detach failed: {error}'**
  String teacherSlotDetachFailed(Object error);

  /// No description provided for @teacherSlotAttachFailed.
  ///
  /// In en, this message translates to:
  /// **'Attach failed: {error}'**
  String teacherSlotAttachFailed(Object error);

  /// No description provided for @teacherSlotAttachMaterial.
  ///
  /// In en, this message translates to:
  /// **'Attach material'**
  String get teacherSlotAttachMaterial;

  /// No description provided for @teacherSlotDetachTooltip.
  ///
  /// In en, this message translates to:
  /// **'Detach'**
  String get teacherSlotDetachTooltip;

  /// No description provided for @teacherDiplomaSelectStudent.
  ///
  /// In en, this message translates to:
  /// **'Select a student first.'**
  String get teacherDiplomaSelectStudent;

  /// No description provided for @teacherDiplomaUploadingWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait — files are still uploading.'**
  String get teacherDiplomaUploadingWait;

  /// No description provided for @teacherDiplomaIssueFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to issue certificate: {error}'**
  String teacherDiplomaIssueFailed(Object error);

  /// No description provided for @teacherDiplomaCertTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Certificate title'**
  String get teacherDiplomaCertTitleLabel;

  /// No description provided for @teacherDiplomaSearchStudent.
  ///
  /// In en, this message translates to:
  /// **'Search student…'**
  String get teacherDiplomaSearchStudent;

  /// No description provided for @teacherProfileChatError.
  ///
  /// In en, this message translates to:
  /// **'Could not start chat'**
  String get teacherProfileChatError;

  /// No description provided for @teacherGradeAssignmentType.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get teacherGradeAssignmentType;

  /// No description provided for @teacherGradeExamType.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get teacherGradeExamType;

  /// No description provided for @teacherGradeOtherType.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get teacherGradeOtherType;

  /// No description provided for @teacherGradeOutOfLabel.
  ///
  /// In en, this message translates to:
  /// **'Out of (optional)'**
  String get teacherGradeOutOfLabel;

  /// No description provided for @teacherGradePublishedTitle.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get teacherGradePublishedTitle;

  /// No description provided for @teacherGradePublishedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Students can see this grade'**
  String get teacherGradePublishedSubtitle;

  /// No description provided for @teacherMaterialPickSubject.
  ///
  /// In en, this message translates to:
  /// **'Please select a subject.'**
  String get teacherMaterialPickSubject;

  /// No description provided for @teacherMaterialAddLink.
  ///
  /// In en, this message translates to:
  /// **'Add link'**
  String get teacherMaterialAddLink;

  /// No description provided for @teacherMaterialAddFile.
  ///
  /// In en, this message translates to:
  /// **'Add file'**
  String get teacherMaterialAddFile;

  /// No description provided for @teacherMaterialSearchStudentsGrade.
  ///
  /// In en, this message translates to:
  /// **'Search students or grade...'**
  String get teacherMaterialSearchStudentsGrade;

  /// No description provided for @teacherMaterialDoneSelected.
  ///
  /// In en, this message translates to:
  /// **'Done ({count} selected)'**
  String teacherMaterialDoneSelected(int count);

  /// No description provided for @adminSubjectEnglishNameRequired.
  ///
  /// In en, this message translates to:
  /// **'English name is required'**
  String get adminSubjectEnglishNameRequired;

  /// No description provided for @adminSubjectNameInLang.
  ///
  /// In en, this message translates to:
  /// **'Name in {language}'**
  String adminSubjectNameInLang(Object language);

  /// No description provided for @adminSubjectResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get adminSubjectResetButton;

  /// No description provided for @teacherAnnounceBroadcastTitle.
  ///
  /// In en, this message translates to:
  /// **'Broadcast to everyone?'**
  String get teacherAnnounceBroadcastTitle;

  /// No description provided for @teacherAnnounceSendToEveryone.
  ///
  /// In en, this message translates to:
  /// **'Send to everyone'**
  String get teacherAnnounceSendToEveryone;

  /// No description provided for @teacherAnnounceNoCohorts.
  ///
  /// In en, this message translates to:
  /// **'No cohorts available'**
  String get teacherAnnounceNoCohorts;

  /// No description provided for @teacherAnnounceNothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get teacherAnnounceNothingFound;

  /// No description provided for @teacherAnnounceNoParents.
  ///
  /// In en, this message translates to:
  /// **'No parents found at this school.'**
  String get teacherAnnounceNoParents;

  /// No description provided for @teacherGradesToGrade.
  ///
  /// In en, this message translates to:
  /// **'To grade'**
  String get teacherGradesToGrade;

  /// No description provided for @teacherGradesGraded.
  ///
  /// In en, this message translates to:
  /// **'Graded'**
  String get teacherGradesGraded;

  /// No description provided for @teacherSaveGradesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Grades'**
  String get teacherSaveGradesButton;

  /// No description provided for @teacherAllowResubmitLabel.
  ///
  /// In en, this message translates to:
  /// **'Allow re-submit'**
  String get teacherAllowResubmitLabel;

  /// No description provided for @teacherAllowResubmitTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow re-submit?'**
  String get teacherAllowResubmitTitle;

  /// No description provided for @teacherAllowResubmitBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete {name}\'s submission so they can hand in again.'**
  String teacherAllowResubmitBody(Object name);

  /// No description provided for @teacherAllowButton.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get teacherAllowButton;

  /// No description provided for @teacherGradeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get teacherGradeFieldLabel;

  /// No description provided for @teacherFeedbackOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Feedback (optional)'**
  String get teacherFeedbackOptionalLabel;

  /// No description provided for @teacherCreateClassroomFabLabel.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get teacherCreateClassroomFabLabel;

  /// No description provided for @teacherLoadingStudents.
  ///
  /// In en, this message translates to:
  /// **'Loading students…'**
  String get teacherLoadingStudents;

  /// No description provided for @teacherSearchHintShort.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get teacherSearchHintShort;

  /// No description provided for @teacherCreateClassroomTitle.
  ///
  /// In en, this message translates to:
  /// **'New Classroom'**
  String get teacherCreateClassroomTitle;

  /// No description provided for @teacherAssignmentUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload {name}'**
  String teacherAssignmentUploadFailed(Object name);

  /// No description provided for @teacherAssignmentEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title.'**
  String get teacherAssignmentEnterTitle;

  /// No description provided for @teacherAssignmentSelectSubject.
  ///
  /// In en, this message translates to:
  /// **'Please select a subject.'**
  String get teacherAssignmentSelectSubject;

  /// No description provided for @teacherAssignmentInstructionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Instructions / Description'**
  String get teacherAssignmentInstructionsLabel;

  /// No description provided for @teacherAttachFilesButton.
  ///
  /// In en, this message translates to:
  /// **'Attach files'**
  String get teacherAttachFilesButton;

  /// No description provided for @tutorDeleteConversationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation?'**
  String get tutorDeleteConversationTitle;

  /// No description provided for @tutorDeleteConversationButton.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get tutorDeleteConversationButton;

  /// No description provided for @tutorDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete: {error}'**
  String tutorDeleteFailed(Object error);

  /// No description provided for @tutorDeleteMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get tutorDeleteMenuTitle;

  /// No description provided for @tutorDeleteMenuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently removes it from the server'**
  String get tutorDeleteMenuSubtitle;

  /// No description provided for @accountVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get accountVerifyButton;

  /// No description provided for @accountConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get accountConfirmButton;

  /// No description provided for @accountResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get accountResendCode;

  /// No description provided for @accountCodeResent.
  ///
  /// In en, this message translates to:
  /// **'Sent a fresh code.'**
  String get accountCodeResent;

  /// No description provided for @accountContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get accountContinueButton;

  /// No description provided for @studentClassroomFileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This file is not yet available.'**
  String get studentClassroomFileUnavailable;

  /// No description provided for @studentClassroomDeleteMaterial.
  ///
  /// In en, this message translates to:
  /// **'Delete material?'**
  String get studentClassroomDeleteMaterial;

  /// No description provided for @studentClassroomCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Classroom code'**
  String get studentClassroomCodeLabel;

  /// No description provided for @studentClassroomLeaveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Leave classroom'**
  String get studentClassroomLeaveTooltip;

  /// No description provided for @adminEditUserEnglishNameRequired.
  ///
  /// In en, this message translates to:
  /// **'English name required'**
  String get adminEditUserEnglishNameRequired;

  /// No description provided for @adminEditUserSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get adminEditUserSaved;

  /// No description provided for @adminEditUserPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed for {name}.'**
  String adminEditUserPasswordChanged(Object name);

  /// No description provided for @adminEditUserLoginSection.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get adminEditUserLoginSection;

  /// No description provided for @adminEditUserUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get adminEditUserUsernameLabel;

  /// No description provided for @adminEditUserEmailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get adminEditUserEmailOptional;

  /// No description provided for @adminEditUserChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get adminEditUserChangePassword;

  /// No description provided for @adminEditUserNameSection.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get adminEditUserNameSection;

  /// No description provided for @adminEditUserAtLeastEnglish.
  ///
  /// In en, this message translates to:
  /// **'At least English required.'**
  String get adminEditUserAtLeastEnglish;

  /// No description provided for @adminEditUserGradeSection.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get adminEditUserGradeSection;

  /// No description provided for @adminEditUserCohortsSection.
  ///
  /// In en, this message translates to:
  /// **'Cohorts'**
  String get adminEditUserCohortsSection;

  /// No description provided for @adminEditUserLinkedChildren.
  ///
  /// In en, this message translates to:
  /// **'Linked Children'**
  String get adminEditUserLinkedChildren;

  /// No description provided for @adminEditUserLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get adminEditUserLinkButton;

  /// No description provided for @adminEditUserNoChildren.
  ///
  /// In en, this message translates to:
  /// **'No children linked yet.'**
  String get adminEditUserNoChildren;

  /// No description provided for @adminEditUserSetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get adminEditUserSetPasswordTitle;

  /// No description provided for @adminEditUserNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get adminEditUserNewPasswordLabel;

  /// No description provided for @adminEditUserConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get adminEditUserConfirmPasswordLabel;

  /// No description provided for @adminEditUserSetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Set password'**
  String get adminEditUserSetPasswordButton;

  /// No description provided for @adminPeriodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Periods'**
  String get adminPeriodsTitle;

  /// No description provided for @adminPeriodsAddPeriod.
  ///
  /// In en, this message translates to:
  /// **'Add Period'**
  String get adminPeriodsAddPeriod;

  /// No description provided for @adminPeriodsNoPeriods.
  ///
  /// In en, this message translates to:
  /// **'No periods yet'**
  String get adminPeriodsNoPeriods;

  /// No description provided for @adminPeriodsTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add the first period'**
  String get adminPeriodsTapToAdd;

  /// No description provided for @adminPeriodsNewPeriod.
  ///
  /// In en, this message translates to:
  /// **'New Period'**
  String get adminPeriodsNewPeriod;

  /// No description provided for @adminPeriodsDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get adminPeriodsDayLabel;

  /// No description provided for @adminPeriodsPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get adminPeriodsPeriodLabel;

  /// No description provided for @adminPeriodsTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get adminPeriodsTimeLabel;

  /// No description provided for @adminPeriodsTeacherLabel.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get adminPeriodsTeacherLabel;

  /// No description provided for @adminPeriodsClassroomOptional.
  ///
  /// In en, this message translates to:
  /// **'Classroom (optional)'**
  String get adminPeriodsClassroomOptional;

  /// No description provided for @adminPeriodsCohortsLabel.
  ///
  /// In en, this message translates to:
  /// **'Cohorts'**
  String get adminPeriodsCohortsLabel;

  /// No description provided for @adminPeriodsStudentsOptional.
  ///
  /// In en, this message translates to:
  /// **'Students (optional)'**
  String get adminPeriodsStudentsOptional;

  /// No description provided for @adminPeriodsSearchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name…'**
  String get adminPeriodsSearchByName;

  /// No description provided for @commonErrorWith.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String commonErrorWith(Object error);

  /// No description provided for @commonAddCount.
  ///
  /// In en, this message translates to:
  /// **'Add {count}'**
  String commonAddCount(int count);

  /// No description provided for @teacherStudentGradesSaved.
  ///
  /// In en, this message translates to:
  /// **'Grades saved'**
  String get teacherStudentGradesSaved;

  /// No description provided for @teacherStudentToGrade.
  ///
  /// In en, this message translates to:
  /// **'To grade'**
  String get teacherStudentToGrade;

  /// No description provided for @teacherStudentGraded.
  ///
  /// In en, this message translates to:
  /// **'Graded'**
  String get teacherStudentGraded;

  /// No description provided for @classroomFileNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This file is not yet available.'**
  String get classroomFileNotAvailable;

  /// No description provided for @classroomDeleteMaterialTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete material?'**
  String get classroomDeleteMaterialTitle;

  /// No description provided for @classroomCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Classroom code'**
  String get classroomCodeLabel;

  /// No description provided for @plansCouldNotOpenSubscription.
  ///
  /// In en, this message translates to:
  /// **'Could not open subscription settings.'**
  String get plansCouldNotOpenSubscription;

  /// No description provided for @plansFailedToOpen.
  ///
  /// In en, this message translates to:
  /// **'Failed to open: {error}'**
  String plansFailedToOpen(Object error);

  /// No description provided for @plansManageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage or cancel subscription'**
  String get plansManageSubscription;

  /// No description provided for @plansUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get plansUpgrade;

  /// No description provided for @plansTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get plansTryAgain;

  /// No description provided for @adminCohortsGradeOnly.
  ///
  /// In en, this message translates to:
  /// **'Grade {grade} only'**
  String adminCohortsGradeOnly(String grade);

  /// No description provided for @adminCohortsGradeRangeOnly.
  ///
  /// In en, this message translates to:
  /// **'Grade {from}-{to} only'**
  String adminCohortsGradeRangeOnly(int from, int to);

  /// No description provided for @adminExportNeedStudents.
  ///
  /// In en, this message translates to:
  /// **'Select at least one student or cohort first'**
  String get adminExportNeedStudents;

  /// No description provided for @adminExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export {count}'**
  String adminExportButton(int count);

  /// No description provided for @adminExportNoStudents.
  ///
  /// In en, this message translates to:
  /// **'No students found'**
  String get adminExportNoStudents;

  /// No description provided for @adminExportIncludesPasswords.
  ///
  /// In en, this message translates to:
  /// **'Export will reset & include passwords'**
  String get adminExportIncludesPasswords;

  /// No description provided for @adminExportAnyway.
  ///
  /// In en, this message translates to:
  /// **'Export anyway'**
  String get adminExportAnyway;

  /// No description provided for @adminExportPdfStudentDirectory.
  ///
  /// In en, this message translates to:
  /// **'Student Directory'**
  String get adminExportPdfStudentDirectory;

  /// No description provided for @adminExportPdfBy.
  ///
  /// In en, this message translates to:
  /// **'By: {name}'**
  String adminExportPdfBy(String name);

  /// No description provided for @adminExportPdfStudentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} students'**
  String adminExportPdfStudentsCount(int count);

  /// No description provided for @adminExportPdfFooter.
  ///
  /// In en, this message translates to:
  /// **'Generated by ClassMate'**
  String get adminExportPdfFooter;

  /// No description provided for @adminExportColumnIndex.
  ///
  /// In en, this message translates to:
  /// **'#'**
  String get adminExportColumnIndex;

  /// No description provided for @adminExportColumnName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get adminExportColumnName;

  /// No description provided for @adminExportColumnEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get adminExportColumnEmail;

  /// No description provided for @adminExportColumnUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get adminExportColumnUsername;

  /// No description provided for @adminExportColumnPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get adminExportColumnPhone;

  /// No description provided for @adminExportColumnGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get adminExportColumnGrade;

  /// No description provided for @adminExportColumnCohorts.
  ///
  /// In en, this message translates to:
  /// **'Cohorts'**
  String get adminExportColumnCohorts;

  /// No description provided for @adminExportColumnSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get adminExportColumnSchool;

  /// No description provided for @adminExportColumnPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get adminExportColumnPassword;

  /// No description provided for @adminExportColumnNameEn.
  ///
  /// In en, this message translates to:
  /// **'Name (EN)'**
  String get adminExportColumnNameEn;

  /// No description provided for @adminExportColumnNameAr.
  ///
  /// In en, this message translates to:
  /// **'Name (AR)'**
  String get adminExportColumnNameAr;

  /// No description provided for @adminExportColumnNameHe.
  ///
  /// In en, this message translates to:
  /// **'Name (HE)'**
  String get adminExportColumnNameHe;

  /// No description provided for @adminExportColumnNameFr.
  ///
  /// In en, this message translates to:
  /// **'Name (FR)'**
  String get adminExportColumnNameFr;

  /// No description provided for @adminExportColumnNameRu.
  ///
  /// In en, this message translates to:
  /// **'Name (RU)'**
  String get adminExportColumnNameRu;

  /// No description provided for @adminExportStudentsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} student selected} other{{count} students selected}}'**
  String adminExportStudentsSelected(int count);

  /// No description provided for @teacherMaterialEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Material'**
  String get teacherMaterialEditTitle;

  /// No description provided for @teacherMaterialAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Material'**
  String get teacherMaterialAddTitle;

  /// No description provided for @teacherMaterialAudienceTitle.
  ///
  /// In en, this message translates to:
  /// **'Audience'**
  String get teacherMaterialAudienceTitle;

  /// No description provided for @teacherMaterialAudienceClassrooms.
  ///
  /// In en, this message translates to:
  /// **'Classrooms'**
  String get teacherMaterialAudienceClassrooms;

  /// No description provided for @teacherMaterialAudienceCohorts.
  ///
  /// In en, this message translates to:
  /// **'Cohorts'**
  String get teacherMaterialAudienceCohorts;

  /// No description provided for @teacherMaterialAudienceGrades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get teacherMaterialAudienceGrades;

  /// No description provided for @teacherMaterialAudienceStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get teacherMaterialAudienceStudents;

  /// No description provided for @teacherMaterialDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get teacherMaterialDetailsTitle;

  /// No description provided for @teacherMaterialSubjectRequired.
  ///
  /// In en, this message translates to:
  /// **'Subject *'**
  String get teacherMaterialSubjectRequired;

  /// No description provided for @teacherMaterialSubjectSelect.
  ///
  /// In en, this message translates to:
  /// **'Select subject'**
  String get teacherMaterialSubjectSelect;

  /// No description provided for @teacherMaterialSubjectOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get teacherMaterialSubjectOther;

  /// No description provided for @teacherMaterialSubjectSearch.
  ///
  /// In en, this message translates to:
  /// **'Search subjects...'**
  String get teacherMaterialSubjectSearch;

  /// No description provided for @teacherMaterialAttachmentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get teacherMaterialAttachmentsTitle;

  /// No description provided for @teacherMaterialAttachmentsWithCount.
  ///
  /// In en, this message translates to:
  /// **'Attachments ({count})'**
  String teacherMaterialAttachmentsWithCount(int count);

  /// No description provided for @teacherMaterialDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete material?'**
  String get teacherMaterialDeleteTitle;

  /// No description provided for @teacherMaterialListTitle.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get teacherMaterialListTitle;

  /// No description provided for @teacherMaterialTotalCount.
  ///
  /// In en, this message translates to:
  /// **'{count} total'**
  String teacherMaterialTotalCount(int count);

  /// No description provided for @teacherMaterialRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get teacherMaterialRetry;

  /// No description provided for @teacherMaterialNoMaterials.
  ///
  /// In en, this message translates to:
  /// **'No materials yet.\nTap + to add one.'**
  String get teacherMaterialNoMaterials;

  /// No description provided for @teacherMaterialPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get teacherMaterialPublished;

  /// No description provided for @teacherMaterialDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get teacherMaterialDraft;

  /// No description provided for @teacherMaterialSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search…'**
  String get teacherMaterialSearchHint;

  /// No description provided for @teacherMaterialSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String teacherMaterialSelectedCount(int count);

  /// No description provided for @teacherMaterialMembersWillReceive.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} member will receive this} other{{count} members will receive this}}'**
  String teacherMaterialMembersWillReceive(int count);

  /// No description provided for @teacherMaterialStudentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} student} other{{count} students}}'**
  String teacherMaterialStudentCount(int count);

  /// No description provided for @teacherMaterialPickerNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get teacherMaterialPickerNone;

  /// No description provided for @teacherMaterialPickerCohortsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select cohorts'**
  String get teacherMaterialPickerCohortsTitle;

  /// No description provided for @teacherMaterialPickerClassroomTitle.
  ///
  /// In en, this message translates to:
  /// **'Select classroom'**
  String get teacherMaterialPickerClassroomTitle;

  /// No description provided for @teacherMaterialPickerStudentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select students'**
  String get teacherMaterialPickerStudentsTitle;

  /// No description provided for @teacherMaterialPickerGradesTitle.
  ///
  /// In en, this message translates to:
  /// **'Select grades'**
  String get teacherMaterialPickerGradesTitle;

  /// No description provided for @adminScheduleAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add new'**
  String get adminScheduleAddNew;

  /// No description provided for @adminScheduleAddCount.
  ///
  /// In en, this message translates to:
  /// **'Add ({count})'**
  String adminScheduleAddCount(int count);

  /// No description provided for @adminScheduleCaptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Caption (optional)'**
  String get adminScheduleCaptionOptional;

  /// No description provided for @adminScheduleCaptionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Exam review'**
  String get adminScheduleCaptionHint;

  /// No description provided for @adminScheduleAudienceCohorts.
  ///
  /// In en, this message translates to:
  /// **'Cohorts'**
  String get adminScheduleAudienceCohorts;

  /// No description provided for @adminScheduleAudienceStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get adminScheduleAudienceStudents;

  /// No description provided for @adminScheduleAudienceGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get adminScheduleAudienceGrade;

  /// No description provided for @adminScheduleSearchStudents.
  ///
  /// In en, this message translates to:
  /// **'Search students…'**
  String get adminScheduleSearchStudents;

  /// No description provided for @adminScheduleSearchSubjects.
  ///
  /// In en, this message translates to:
  /// **'Search school subjects…'**
  String get adminScheduleSearchSubjects;

  /// No description provided for @adminScheduleEveryPrefix.
  ///
  /// In en, this message translates to:
  /// **'Every '**
  String get adminScheduleEveryPrefix;

  /// No description provided for @adminScheduleWeeksSuffix.
  ///
  /// In en, this message translates to:
  /// **' weeks'**
  String get adminScheduleWeeksSuffix;

  /// No description provided for @adminScheduleSlotN.
  ///
  /// In en, this message translates to:
  /// **'Slot {index}'**
  String adminScheduleSlotN(int index);

  /// No description provided for @adminScheduleSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String adminScheduleSelectedCount(int count);

  /// No description provided for @adminScheduleConflictingPeriod.
  ///
  /// In en, this message translates to:
  /// **'Conflicting period'**
  String get adminScheduleConflictingPeriod;

  /// No description provided for @adminScheduleKeepCurrent.
  ///
  /// In en, this message translates to:
  /// **'Keep current'**
  String get adminScheduleKeepCurrent;

  /// No description provided for @adminScheduleOverride.
  ///
  /// In en, this message translates to:
  /// **'Override'**
  String get adminScheduleOverride;

  /// No description provided for @adminScheduleShowBoth.
  ///
  /// In en, this message translates to:
  /// **'Show both'**
  String get adminScheduleShowBoth;

  /// No description provided for @adminScheduleDeletePeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete period?'**
  String get adminScheduleDeletePeriodTitle;

  /// No description provided for @adminScheduleDeletePeriodBody.
  ///
  /// In en, this message translates to:
  /// **'This removes the slot from the schedule. Past attendance stays.'**
  String get adminScheduleDeletePeriodBody;

  /// No description provided for @adminScheduleFailedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete period.'**
  String get adminScheduleFailedToDelete;

  /// No description provided for @adminSchedulePickSubjectFirst.
  ///
  /// In en, this message translates to:
  /// **'Pick a subject before saving the period.'**
  String get adminSchedulePickSubjectFirst;

  /// No description provided for @adminScheduleOverrideFailed.
  ///
  /// In en, this message translates to:
  /// **'Override failed: {error}'**
  String adminScheduleOverrideFailed(Object error);

  /// No description provided for @adminScheduleFailedToCreateSlots.
  ///
  /// In en, this message translates to:
  /// **'Failed to create slots'**
  String get adminScheduleFailedToCreateSlots;

  /// No description provided for @adminScheduleCreatedSlots.
  ///
  /// In en, this message translates to:
  /// **'Created {created}/{total} slots. {error}'**
  String adminScheduleCreatedSlots(int created, int total, String error);

  /// No description provided for @adminScheduleSavedLabelOnlyError.
  ///
  /// In en, this message translates to:
  /// **'Saved as slot label only — couldn\'t add to library: {error}'**
  String adminScheduleSavedLabelOnlyError(Object error);

  /// No description provided for @adminScheduleSavedLabelPickAudience.
  ///
  /// In en, this message translates to:
  /// **'Saved as slot label. Pick an audience first to also add to the school library.'**
  String get adminScheduleSavedLabelPickAudience;

  /// No description provided for @commonNothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get commonNothingFound;

  /// No description provided for @commonDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String commonDownloadFailed(Object error);

  /// No description provided for @commonFailedWith.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String commonFailedWith(Object error);

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonAttachStudyMaterials.
  ///
  /// In en, this message translates to:
  /// **'Attach study materials'**
  String get commonAttachStudyMaterials;

  /// No description provided for @teacherCreateClassroomNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Classroom'**
  String get teacherCreateClassroomNewTitle;

  /// No description provided for @teacherCreateClassroomLoadingStudents.
  ///
  /// In en, this message translates to:
  /// **'Loading students…'**
  String get teacherCreateClassroomLoadingStudents;

  /// No description provided for @teacherExamPublishedHint.
  ///
  /// In en, this message translates to:
  /// **'Published — students can see this exam'**
  String get teacherExamPublishedHint;

  /// No description provided for @teacherDoneSelected.
  ///
  /// In en, this message translates to:
  /// **'Done ({count} selected)'**
  String teacherDoneSelected(int count);

  /// No description provided for @secretaryAllCohorts.
  ///
  /// In en, this message translates to:
  /// **'All cohorts'**
  String get secretaryAllCohorts;

  /// No description provided for @secretaryClassrooms.
  ///
  /// In en, this message translates to:
  /// **'Classrooms'**
  String get secretaryClassrooms;

  /// No description provided for @adminPeopleGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get adminPeopleGrade;

  /// No description provided for @adminSchoolSettingsTapToAddTranslations.
  ///
  /// In en, this message translates to:
  /// **'Tap to add translations'**
  String get adminSchoolSettingsTapToAddTranslations;

  /// No description provided for @adminSchoolSettingsAddPeriodNum.
  ///
  /// In en, this message translates to:
  /// **'Add Period (P{num})'**
  String adminSchoolSettingsAddPeriodNum(int num);

  /// No description provided for @adminVisibleToEveryone.
  ///
  /// In en, this message translates to:
  /// **'Visible to everyone'**
  String get adminVisibleToEveryone;

  /// No description provided for @navMaterials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get navMaterials;

  /// No description provided for @classMaterialsAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add material'**
  String get classMaterialsAddTitle;

  /// No description provided for @classMaterialsTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get classMaterialsTitleLabel;

  /// No description provided for @classMaterialsFilesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} files'**
  String classMaterialsFilesCount(int count);

  /// No description provided for @classMaterialsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load materials'**
  String get classMaterialsLoadError;

  /// No description provided for @classMaterialsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No materials yet — tap Add to share one.'**
  String get classMaterialsEmpty;

  /// No description provided for @navPlans.
  ///
  /// In en, this message translates to:
  /// **'NOVA Plans'**
  String get navPlans;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navExportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get navExportData;

  /// No description provided for @sectionSecretaryTools.
  ///
  /// In en, this message translates to:
  /// **'Secretary Tools'**
  String get sectionSecretaryTools;

  /// No description provided for @sectionSchoolToolsLabel.
  ///
  /// In en, this message translates to:
  /// **'School Tools'**
  String get sectionSchoolToolsLabel;

  /// No description provided for @sectionAdminTools.
  ///
  /// In en, this message translates to:
  /// **'Admin Tools'**
  String get sectionAdminTools;

  /// No description provided for @chatVideoTrimTitle.
  ///
  /// In en, this message translates to:
  /// **'Trim video'**
  String get chatVideoTrimTitle;

  /// No description provided for @chatMediaPreviewTrimAction.
  ///
  /// In en, this message translates to:
  /// **'Trim'**
  String get chatMediaPreviewTrimAction;

  /// No description provided for @commonUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get commonUntitled;

  /// No description provided for @plansMonthlyPlans.
  ///
  /// In en, this message translates to:
  /// **'Monthly plans'**
  String get plansMonthlyPlans;

  /// No description provided for @plansTokenTopups.
  ///
  /// In en, this message translates to:
  /// **'Token top-ups'**
  String get plansTokenTopups;

  /// No description provided for @plansTopupsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One-time purchases. Never expire. Stack on top of your plan.'**
  String get plansTopupsSubtitle;

  /// No description provided for @plansCouldntLoadBalance.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your balance'**
  String get plansCouldntLoadBalance;

  /// No description provided for @plansFreePlan.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get plansFreePlan;

  /// No description provided for @planTierFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get planTierFree;

  /// No description provided for @planTierBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get planTierBudget;

  /// No description provided for @planTierBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get planTierBalance;

  /// No description provided for @planTierCommitment.
  ///
  /// In en, this message translates to:
  /// **'Commitment'**
  String get planTierCommitment;

  /// No description provided for @topupPackSmall.
  ///
  /// In en, this message translates to:
  /// **'Small pack'**
  String get topupPackSmall;

  /// No description provided for @topupPackMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium pack'**
  String get topupPackMedium;

  /// No description provided for @topupPackLarge.
  ///
  /// In en, this message translates to:
  /// **'Large pack'**
  String get topupPackLarge;

  /// No description provided for @topupPackMega.
  ///
  /// In en, this message translates to:
  /// **'Mega pack'**
  String get topupPackMega;

  /// No description provided for @planBlurbFree.
  ///
  /// In en, this message translates to:
  /// **'Get a taste of NOVA. Resets every month.'**
  String get planBlurbFree;

  /// No description provided for @planBlurbBudget.
  ///
  /// In en, this message translates to:
  /// **'Daily homework help.'**
  String get planBlurbBudget;

  /// No description provided for @planBlurbBalance.
  ///
  /// In en, this message translates to:
  /// **'For students who study every day.'**
  String get planBlurbBalance;

  /// No description provided for @planBlurbCommitment.
  ///
  /// In en, this message translates to:
  /// **'Heavy practice + unlimited curiosity.'**
  String get planBlurbCommitment;

  /// No description provided for @plansTokensPerMonth.
  ///
  /// In en, this message translates to:
  /// **'{tokens} tokens / month'**
  String plansTokensPerMonth(String tokens);

  /// No description provided for @plansTokensOneTime.
  ///
  /// In en, this message translates to:
  /// **'{tokens} tokens'**
  String plansTokensOneTime(String tokens);

  /// No description provided for @planPriceFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get planPriceFree;

  /// No description provided for @plansTokensRemaining.
  ///
  /// In en, this message translates to:
  /// **'tokens remaining'**
  String get plansTokensRemaining;

  /// No description provided for @plansPlanResetsAt.
  ///
  /// In en, this message translates to:
  /// **'Plan resets {when}'**
  String plansPlanResetsAt(String when);

  /// No description provided for @plansTopupTokensInfo.
  ///
  /// In en, this message translates to:
  /// **'{tokens} top-up tokens (no expiry)'**
  String plansTopupTokensInfo(String tokens);

  /// No description provided for @plansHowTokensWorkTitle.
  ///
  /// In en, this message translates to:
  /// **'How tokens work'**
  String get plansHowTokensWorkTitle;

  /// No description provided for @plansHowTokensWorkBody.
  ///
  /// In en, this message translates to:
  /// **'Tokens are how AI counts its work.\n• A short question ≈ 2,000 tokens\n• A long explanation or practice session ≈ 5,000–10,000\n• Image analysis costs a bit more\n\nYour monthly tokens reset on the 1st. Top-up tokens never expire.'**
  String get plansHowTokensWorkBody;

  /// No description provided for @plansPerMonthSuffix.
  ///
  /// In en, this message translates to:
  /// **' / mo'**
  String get plansPerMonthSuffix;

  /// No description provided for @plansCurrentBadge.
  ///
  /// In en, this message translates to:
  /// **'CURRENT'**
  String get plansCurrentBadge;

  /// No description provided for @plansCouldntLoadPlans.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load plans'**
  String get plansCouldntLoadPlans;

  /// No description provided for @paywallPlansUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Plans unavailable. Try again in a moment.'**
  String get paywallPlansUnavailable;

  /// No description provided for @paywallTopupUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Top-up unavailable. The store hasn\'t finished approving this product.'**
  String get paywallTopupUnavailable;

  /// No description provided for @paywallRestored.
  ///
  /// In en, this message translates to:
  /// **'Your subscription was restored.'**
  String get paywallRestored;

  /// No description provided for @paywallNoRestores.
  ///
  /// In en, this message translates to:
  /// **'No previous purchases found on this Apple ID.'**
  String get paywallNoRestores;

  /// No description provided for @paywallRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String paywallRestoreFailed(String error);

  /// No description provided for @paywallPurchasesRestricted.
  ///
  /// In en, this message translates to:
  /// **'Purchases are restricted on this device.'**
  String get paywallPurchasesRestricted;

  /// No description provided for @paywallPurchaseInvalid.
  ///
  /// In en, this message translates to:
  /// **'This purchase isn\'t valid. Try a different payment method.'**
  String get paywallPurchaseInvalid;

  /// No description provided for @paywallProductNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This plan isn\'t available right now. Try again later.'**
  String get paywallProductNotAvailable;

  /// No description provided for @paywallNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network issue. Check your connection and try again.'**
  String get paywallNetworkError;

  /// No description provided for @paywallPaymentPending.
  ///
  /// In en, this message translates to:
  /// **'Payment is pending approval (parental controls, etc.). It\'ll activate once approved.'**
  String get paywallPaymentPending;

  /// No description provided for @paywallStoreProblem.
  ///
  /// In en, this message translates to:
  /// **'The App Store had a problem. Try again in a minute.'**
  String get paywallStoreProblem;

  /// No description provided for @paywallGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get paywallGenericError;

  /// No description provided for @paywallWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to {plan}! Tokens are on the way.'**
  String paywallWelcomeMessage(String plan);

  /// No description provided for @paywallWelcomeFallback.
  ///
  /// In en, this message translates to:
  /// **'your new plan'**
  String get paywallWelcomeFallback;

  /// No description provided for @paywallTopupAdded.
  ///
  /// In en, this message translates to:
  /// **'Top-up added. Tokens are on the way.'**
  String get paywallTopupAdded;

  /// No description provided for @paywallPurchaseProcessed.
  ///
  /// In en, this message translates to:
  /// **'Purchase processed. Tokens will appear shortly.'**
  String get paywallPurchaseProcessed;

  /// No description provided for @paywallSubscribeTo.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to {plan}'**
  String paywallSubscribeTo(String plan);

  /// No description provided for @paywallBuyTopupNamed.
  ///
  /// In en, this message translates to:
  /// **'Buy {topup}'**
  String paywallBuyTopupNamed(String topup);

  /// No description provided for @paywallPlanFallback.
  ///
  /// In en, this message translates to:
  /// **'plan'**
  String get paywallPlanFallback;

  /// No description provided for @paywallTopupFallback.
  ///
  /// In en, this message translates to:
  /// **'top-up'**
  String get paywallTopupFallback;

  /// No description provided for @paywallTopupBlurb.
  ///
  /// In en, this message translates to:
  /// **'One-time purchase. Tokens never expire and stack on top of your plan.'**
  String get paywallTopupBlurb;

  /// No description provided for @paywallPerMonthWithTokens.
  ///
  /// In en, this message translates to:
  /// **'per month · {tokens}'**
  String paywallPerMonthWithTokens(String tokens);

  /// No description provided for @paywallOneTimeWithTokens.
  ///
  /// In en, this message translates to:
  /// **'one-time · {tokens}'**
  String paywallOneTimeWithTokens(String tokens);

  /// No description provided for @paywallSubscribeButton.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get paywallSubscribeButton;

  /// No description provided for @paywallBuyButton.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get paywallBuyButton;

  /// No description provided for @paywallRestoreButton.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get paywallRestoreButton;

  /// No description provided for @paywallNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get paywallNotNow;

  /// No description provided for @paywallWebOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchase on mobile'**
  String get paywallWebOnlyTitle;

  /// No description provided for @paywallWebOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions and top-ups go through the App Store or Google Play. Open ClassMate on your iPhone, iPad, or Android phone to subscribe — your account and tokens are shared across devices.'**
  String get paywallWebOnlyBody;

  /// No description provided for @paywallWebOnlyDismiss.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get paywallWebOnlyDismiss;

  /// No description provided for @paywallTermsSubscription.
  ///
  /// In en, this message translates to:
  /// **'By subscribing you agree to ClassMate\'s Terms and Privacy Policy. Subscriptions auto-renew monthly until cancelled. Manage anytime in your App Store account.'**
  String get paywallTermsSubscription;

  /// No description provided for @paywallTermsTopup.
  ///
  /// In en, this message translates to:
  /// **'By purchasing you agree to ClassMate\'s Terms and Privacy Policy. Top-up tokens are non-refundable once consumed.'**
  String get paywallTermsTopup;

  /// No description provided for @paywallTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use (EULA)'**
  String get paywallTermsLink;

  /// No description provided for @paywallPrivacyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get paywallPrivacyLink;

  /// No description provided for @paywallFeatureTokens.
  ///
  /// In en, this message translates to:
  /// **'Use tokens across NOVA chat and Practice sessions'**
  String get paywallFeatureTokens;

  /// No description provided for @paywallFeatureImages.
  ///
  /// In en, this message translates to:
  /// **'Image analysis and file upload included'**
  String get paywallFeatureImages;

  /// No description provided for @paywallFeatureReset.
  ///
  /// In en, this message translates to:
  /// **'Tokens reset at the start of each month'**
  String get paywallFeatureReset;

  /// No description provided for @paywallFeatureCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime — no commitment'**
  String get paywallFeatureCancel;

  /// No description provided for @studentMaterialsGeneralSubject.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get studentMaterialsGeneralSubject;

  /// No description provided for @studentMaterialsResourceCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} resource from your teachers} other{{count} resources from your teachers}}'**
  String studentMaterialsResourceCount(int count);

  /// No description provided for @classroomsCouldNotLoadWithError.
  ///
  /// In en, this message translates to:
  /// **'Could not load classrooms\n{error}'**
  String classroomsCouldNotLoadWithError(String error);

  /// No description provided for @parentNoNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet.'**
  String get parentNoNotificationsYet;

  /// No description provided for @forwardCouldNotLoadChats.
  ///
  /// In en, this message translates to:
  /// **'Could not load chats: {error}'**
  String forwardCouldNotLoadChats(Object error);

  /// No description provided for @forwardNoChats.
  ///
  /// In en, this message translates to:
  /// **'No chats'**
  String get forwardNoChats;

  /// No description provided for @commonTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get commonTitle;

  /// No description provided for @commonNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get commonNotes;

  /// No description provided for @commonEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get commonEmail;

  /// No description provided for @commonPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get commonPassword;

  /// No description provided for @commonNumberOfPages.
  ///
  /// In en, this message translates to:
  /// **'Number of pages'**
  String get commonNumberOfPages;

  /// No description provided for @messagesSearchByNameOrGrade.
  ///
  /// In en, this message translates to:
  /// **'Search by name or grade…'**
  String get messagesSearchByNameOrGrade;

  /// No description provided for @meetingStartDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Start date *'**
  String get meetingStartDateRequired;

  /// No description provided for @meetingStartTimeRequired.
  ///
  /// In en, this message translates to:
  /// **'Start time *'**
  String get meetingStartTimeRequired;

  /// No description provided for @meetingEndDateOptional.
  ///
  /// In en, this message translates to:
  /// **'End date (optional)'**
  String get meetingEndDateOptional;

  /// No description provided for @meetingEndTimeOptional.
  ///
  /// In en, this message translates to:
  /// **'End time (optional)'**
  String get meetingEndTimeOptional;

  /// No description provided for @teacherMaterialLinkUrlOptional.
  ///
  /// In en, this message translates to:
  /// **'Link / URL (optional)'**
  String get teacherMaterialLinkUrlOptional;

  /// No description provided for @teacherSearchStudentsOrGrade.
  ///
  /// In en, this message translates to:
  /// **'Search students or grade…'**
  String get teacherSearchStudentsOrGrade;

  /// No description provided for @teacherSearchParentsOrChildren.
  ///
  /// In en, this message translates to:
  /// **'Search parents or children…'**
  String get teacherSearchParentsOrChildren;

  /// No description provided for @studentAssignmentAddNoteOptional.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)…'**
  String get studentAssignmentAddNoteOptional;

  /// No description provided for @adminEditUserUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username *'**
  String get adminEditUserUsernameRequired;

  /// No description provided for @reportReasonOptional.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get reportReasonOptional;

  /// No description provided for @forwardSearchChatsAndClassrooms.
  ///
  /// In en, this message translates to:
  /// **'Search chats and classrooms…'**
  String get forwardSearchChatsAndClassrooms;

  /// No description provided for @profileNewPhone.
  ///
  /// In en, this message translates to:
  /// **'New phone'**
  String get profileNewPhone;

  /// No description provided for @profileNewEmail.
  ///
  /// In en, this message translates to:
  /// **'New email'**
  String get profileNewEmail;

  /// No description provided for @adminExportPasswordsWarning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{This resets {count} student\'s password to a new one and puts it in the file, so you can print and hand out the login card. Their old password stops working. Anyone with the file can sign in as that student — share carefully and delete when done.} other{This resets {count} students\' passwords to new ones and puts them in the file, so you can print and hand out the login cards. Their old passwords stop working. Anyone with the file can sign in as those students — share carefully and delete when done.}}'**
  String adminExportPasswordsWarning(int count);

  /// No description provided for @pickerSelectStudents.
  ///
  /// In en, this message translates to:
  /// **'Select students'**
  String get pickerSelectStudents;

  /// No description provided for @pickerSelectCohorts.
  ///
  /// In en, this message translates to:
  /// **'Select cohorts'**
  String get pickerSelectCohorts;

  /// No description provided for @pickerSelectGrades.
  ///
  /// In en, this message translates to:
  /// **'Select grades'**
  String get pickerSelectGrades;

  /// No description provided for @pickerSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get pickerSelectAll;

  /// No description provided for @pickerUnselectAll.
  ///
  /// In en, this message translates to:
  /// **'Unselect all'**
  String get pickerUnselectAll;

  /// No description provided for @pickerSelectClassroom.
  ///
  /// In en, this message translates to:
  /// **'Select classroom'**
  String get pickerSelectClassroom;

  /// No description provided for @pickerSelectClasses.
  ///
  /// In en, this message translates to:
  /// **'Select classes'**
  String get pickerSelectClasses;

  /// No description provided for @drawerLoadingChildren.
  ///
  /// In en, this message translates to:
  /// **'Loading children…'**
  String get drawerLoadingChildren;

  /// No description provided for @drawerCouldNotLoadChildren.
  ///
  /// In en, this message translates to:
  /// **'Could not load children'**
  String get drawerCouldNotLoadChildren;

  /// No description provided for @drawerNoChildrenLinked.
  ///
  /// In en, this message translates to:
  /// **'No children linked'**
  String get drawerNoChildrenLinked;

  /// No description provided for @drawerSwitchChild.
  ///
  /// In en, this message translates to:
  /// **'Switch child'**
  String get drawerSwitchChild;

  /// No description provided for @shellAssessmentCreated.
  ///
  /// In en, this message translates to:
  /// **'Assessment created'**
  String get shellAssessmentCreated;

  /// No description provided for @commonCouldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open {scheme} link'**
  String commonCouldNotOpenLink(String scheme);

  /// No description provided for @commonCouldntSend.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t send: {error}'**
  String commonCouldntSend(String error);

  /// No description provided for @teacherExamDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Exam Details'**
  String get teacherExamDetailsSection;

  /// No description provided for @teacherExamStudyMaterialsWithCount.
  ///
  /// In en, this message translates to:
  /// **'Study Materials ({count})'**
  String teacherExamStudyMaterialsWithCount(int count);

  /// No description provided for @teacherMeetingDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Meeting Details'**
  String get teacherMeetingDetailsSection;

  /// No description provided for @teacherClassroomNameSection.
  ///
  /// In en, this message translates to:
  /// **'Classroom name'**
  String get teacherClassroomNameSection;

  /// No description provided for @teacherAddByCohortSection.
  ///
  /// In en, this message translates to:
  /// **'Add by cohort'**
  String get teacherAddByCohortSection;

  /// No description provided for @teacherAddIndividualStudentsSection.
  ///
  /// In en, this message translates to:
  /// **'Add individual students'**
  String get teacherAddIndividualStudentsSection;

  /// No description provided for @teacherGradeTypeSection.
  ///
  /// In en, this message translates to:
  /// **'Grade type'**
  String get teacherGradeTypeSection;

  /// No description provided for @teacherOtherGradeSection.
  ///
  /// In en, this message translates to:
  /// **'Other grade'**
  String get teacherOtherGradeSection;

  /// No description provided for @teacherEnterGradesSection.
  ///
  /// In en, this message translates to:
  /// **'Enter grades'**
  String get teacherEnterGradesSection;

  /// No description provided for @teacherAttachmentsWithCount.
  ///
  /// In en, this message translates to:
  /// **'Attachments ({count})'**
  String teacherAttachmentsWithCount(int count);

  /// No description provided for @studentFilesSharedByTeacher.
  ///
  /// In en, this message translates to:
  /// **'Files shared by your teacher'**
  String get studentFilesSharedByTeacher;

  /// No description provided for @studentYourSubmission.
  ///
  /// In en, this message translates to:
  /// **'Your submission'**
  String get studentYourSubmission;

  /// No description provided for @studentFilesSharedWithAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Files shared with this announcement.'**
  String get studentFilesSharedWithAnnouncement;

  /// No description provided for @announcementGradeRiskTitle.
  ///
  /// In en, this message translates to:
  /// **'Grade risk detected'**
  String get announcementGradeRiskTitle;

  /// No description provided for @announcementWeakSubjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Weak subject detected'**
  String get announcementWeakSubjectTitle;

  /// No description provided for @announcementLowAttendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Low attendance'**
  String get announcementLowAttendanceTitle;

  /// No description provided for @announcementRepeatedLatenessTitle.
  ///
  /// In en, this message translates to:
  /// **'Repeated lateness'**
  String get announcementRepeatedLatenessTitle;

  /// No description provided for @announcementPracticeWeaknessTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice weakness found'**
  String get announcementPracticeWeaknessTitle;

  /// No description provided for @announcementPracticeTrendDroppedTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice trend dropped'**
  String get announcementPracticeTrendDroppedTitle;

  /// No description provided for @announcementSolutionsActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Solutions activity is live'**
  String get announcementSolutionsActivityTitle;

  /// No description provided for @announcementAllGoodTitle.
  ///
  /// In en, this message translates to:
  /// **'All good'**
  String get announcementAllGoodTitle;

  /// No description provided for @supportSectionGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting started'**
  String get supportSectionGettingStarted;

  /// No description provided for @supportSectionAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Account & password'**
  String get supportSectionAccountPassword;

  /// No description provided for @supportSectionForStudents.
  ///
  /// In en, this message translates to:
  /// **'For students'**
  String get supportSectionForStudents;

  /// No description provided for @supportSectionForTeachers.
  ///
  /// In en, this message translates to:
  /// **'For teachers'**
  String get supportSectionForTeachers;

  /// No description provided for @supportSectionForAdministrators.
  ///
  /// In en, this message translates to:
  /// **'For administrators'**
  String get supportSectionForAdministrators;

  /// No description provided for @supportSectionForParents.
  ///
  /// In en, this message translates to:
  /// **'For parents'**
  String get supportSectionForParents;

  /// No description provided for @supportSectionPrivacyData.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data'**
  String get supportSectionPrivacyData;

  /// No description provided for @novaDisclaimerCanMakeMistakes.
  ///
  /// In en, this message translates to:
  /// **'Can make mistakes'**
  String get novaDisclaimerCanMakeMistakes;

  /// No description provided for @novaDisclaimerEducationalUseOnly.
  ///
  /// In en, this message translates to:
  /// **'Educational use only'**
  String get novaDisclaimerEducationalUseOnly;

  /// No description provided for @novaDisclaimerYourPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your privacy'**
  String get novaDisclaimerYourPrivacy;

  /// No description provided for @profileNameInLanguage.
  ///
  /// In en, this message translates to:
  /// **'Name in {language}'**
  String profileNameInLanguage(String language);

  /// No description provided for @adminSettingsScheduleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Assign teachers and cohorts to weekly time slots'**
  String get adminSettingsScheduleSubtitle;

  /// No description provided for @practiceModeBalancedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Balanced daily practice'**
  String get practiceModeBalancedSubtitle;

  /// No description provided for @practiceModeRevealSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reveal and self-recall'**
  String get practiceModeRevealSubtitle;

  /// No description provided for @practiceModeFastSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fast pressure drill'**
  String get practiceModeFastSubtitle;

  /// No description provided for @practiceModeExamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Calm exam-style flow'**
  String get practiceModeExamSubtitle;

  /// No description provided for @practiceModeConceptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Concept first, solve later'**
  String get practiceModeConceptSubtitle;

  /// No description provided for @practiceModeAdaptiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Difficulty shifts live'**
  String get practiceModeAdaptiveSubtitle;

  /// No description provided for @practiceModeStrictSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Strict official style'**
  String get practiceModeStrictSubtitle;

  /// No description provided for @commonCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get commonCall;

  /// No description provided for @tooltipClearEndTime.
  ///
  /// In en, this message translates to:
  /// **'Clear end time'**
  String get tooltipClearEndTime;

  /// No description provided for @tooltipDeletePeriod.
  ///
  /// In en, this message translates to:
  /// **'Delete period'**
  String get tooltipDeletePeriod;

  /// No description provided for @tooltipLeaveClassroom.
  ///
  /// In en, this message translates to:
  /// **'Leave classroom'**
  String get tooltipLeaveClassroom;

  /// No description provided for @announcementGradeRiskBody.
  ///
  /// In en, this message translates to:
  /// **'Your average dropped below 70. Immediate action recommended.'**
  String get announcementGradeRiskBody;

  /// No description provided for @announcementWeakSubjectBody.
  ///
  /// In en, this message translates to:
  /// **'{subject} needs attention.'**
  String announcementWeakSubjectBody(String subject);

  /// No description provided for @announcementLowAttendanceBody.
  ///
  /// In en, this message translates to:
  /// **'Your attendance is dropping. This will impact grades.'**
  String get announcementLowAttendanceBody;

  /// No description provided for @announcementLatenessBody.
  ///
  /// In en, this message translates to:
  /// **'You have multiple late arrivals.'**
  String get announcementLatenessBody;

  /// No description provided for @announcementPracticeWeakTopicBody.
  ///
  /// In en, this message translates to:
  /// **'{topic} in {subject} is dragging your momentum.'**
  String announcementPracticeWeakTopicBody(String topic, String subject);

  /// No description provided for @announcementPracticeDropBody.
  ///
  /// In en, this message translates to:
  /// **'Your recent practice is below your baseline. Slow down and rebuild.'**
  String get announcementPracticeDropBody;

  /// No description provided for @announcementSolutionsActivityBody.
  ///
  /// In en, this message translates to:
  /// **'Your solution space is active on page {page}, question {question}. Check peer work or upload yours.'**
  String announcementSolutionsActivityBody(int page, int question);

  /// No description provided for @announcementAllGoodBody.
  ///
  /// In en, this message translates to:
  /// **'No major academic risks detected right now.'**
  String get announcementAllGoodBody;

  /// No description provided for @faqStartedQ1.
  ///
  /// In en, this message translates to:
  /// **'How do I log in?'**
  String get faqStartedQ1;

  /// No description provided for @faqStartedA1.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Sign in\" on the welcome screen and enter the email or username your school administrator gave you, plus your temporary password. You\'ll be asked to set a new password the first time.'**
  String get faqStartedA1;

  /// No description provided for @faqStartedQ2.
  ///
  /// In en, this message translates to:
  /// **'I don\'t have a login yet.'**
  String get faqStartedQ2;

  /// No description provided for @faqStartedA2.
  ///
  /// In en, this message translates to:
  /// **'Your school administrator creates accounts. Ask them to add you in their admin app, or to share a join code if your school uses self-enrolment.'**
  String get faqStartedA2;

  /// No description provided for @faqStartedQ3.
  ///
  /// In en, this message translates to:
  /// **'Can I use the app in my language?'**
  String get faqStartedQ3;

  /// No description provided for @faqStartedA3.
  ///
  /// In en, this message translates to:
  /// **'Yes — ClassMate supports English, Arabic, Hebrew, French, and Russian. Open Settings to switch language. You can also set a preferred name language in Profile.'**
  String get faqStartedA3;

  /// No description provided for @faqStartedQ4.
  ///
  /// In en, this message translates to:
  /// **'How do I switch between dark and light mode?'**
  String get faqStartedQ4;

  /// No description provided for @faqStartedA4.
  ///
  /// In en, this message translates to:
  /// **'Open Settings from the drawer and toggle the appearance switch. The app respects your system preference by default.'**
  String get faqStartedA4;

  /// No description provided for @faqAccountQ1.
  ///
  /// In en, this message translates to:
  /// **'I forgot my password.'**
  String get faqAccountQ1;

  /// No description provided for @faqAccountA1.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Forgot password?\" on the login screen. You\'ll get a reset link by email or a code by SMS. If neither channel is verified yet, ask your school administrator to issue you a new temporary password.'**
  String get faqAccountA1;

  /// No description provided for @faqAccountQ2.
  ///
  /// In en, this message translates to:
  /// **'How do I change my password?'**
  String get faqAccountQ2;

  /// No description provided for @faqAccountA2.
  ///
  /// In en, this message translates to:
  /// **'Open Profile from the drawer, scroll to Security, and tap the password row. You\'ll need your current password to set a new one.'**
  String get faqAccountA2;

  /// No description provided for @faqAccountQ3.
  ///
  /// In en, this message translates to:
  /// **'How do I change my email or phone number?'**
  String get faqAccountQ3;

  /// No description provided for @faqAccountA3.
  ///
  /// In en, this message translates to:
  /// **'Open Profile, tap the field you want to change, and follow the verification prompts. A code is sent to your CURRENT email/phone first to confirm it\'s really you, then you can set the new value.'**
  String get faqAccountA3;

  /// No description provided for @faqAccountQ4.
  ///
  /// In en, this message translates to:
  /// **'My school administrator can change my password — how does that work?'**
  String get faqAccountQ4;

  /// No description provided for @faqAccountA4.
  ///
  /// In en, this message translates to:
  /// **'When an administrator resets your password, you\'ll get an email and SMS with a one-tap link to set your own password. The admin never sees what you choose.'**
  String get faqAccountA4;

  /// No description provided for @faqStudentsQ1.
  ///
  /// In en, this message translates to:
  /// **'Where do I see my schedule?'**
  String get faqStudentsQ1;

  /// No description provided for @faqStudentsA1.
  ///
  /// In en, this message translates to:
  /// **'Schedule is the first item in the drawer. You\'ll see this week\'s periods, who teaches each one, and any changes the admin has posted.'**
  String get faqStudentsA1;

  /// No description provided for @faqStudentsQ2.
  ///
  /// In en, this message translates to:
  /// **'How do I join a classroom?'**
  String get faqStudentsQ2;

  /// No description provided for @faqStudentsA2.
  ///
  /// In en, this message translates to:
  /// **'A teacher will add you directly, or share a join code. To use a join code, open Classrooms from the drawer and tap \"Join with code\".'**
  String get faqStudentsA2;

  /// No description provided for @faqStudentsQ3.
  ///
  /// In en, this message translates to:
  /// **'How do attendance and grades work?'**
  String get faqStudentsQ3;

  /// No description provided for @faqStudentsA3.
  ///
  /// In en, this message translates to:
  /// **'Teachers mark attendance during the lesson. Open Attendance or Grades from the drawer to see your records. Parents linked to your account see the same data.'**
  String get faqStudentsA3;

  /// No description provided for @faqStudentsQ4.
  ///
  /// In en, this message translates to:
  /// **'What is Nova?'**
  String get faqStudentsQ4;

  /// No description provided for @faqStudentsA4.
  ///
  /// In en, this message translates to:
  /// **'Nova is your AI study buddy — ask it to explain a concept, generate a quiz, or walk through a problem step by step. Open Nova from the drawer to start a session.'**
  String get faqStudentsA4;

  /// No description provided for @faqTeachersQ1.
  ///
  /// In en, this message translates to:
  /// **'How do I create a classroom?'**
  String get faqTeachersQ1;

  /// No description provided for @faqTeachersA1.
  ///
  /// In en, this message translates to:
  /// **'Open Classrooms from the drawer and tap the + button. Give it a name and subject; students can be added by hand or via a join code.'**
  String get faqTeachersA1;

  /// No description provided for @faqTeachersQ2.
  ///
  /// In en, this message translates to:
  /// **'How do I mark attendance?'**
  String get faqTeachersQ2;

  /// No description provided for @faqTeachersA2.
  ///
  /// In en, this message translates to:
  /// **'Open Attendance from the drawer, pick the date and period, then tap each student to set their status. Changes save automatically.'**
  String get faqTeachersA2;

  /// No description provided for @faqTeachersQ3.
  ///
  /// In en, this message translates to:
  /// **'How do I assign homework?'**
  String get faqTeachersQ3;

  /// No description provided for @faqTeachersA3.
  ///
  /// In en, this message translates to:
  /// **'Open Assignments, tap +, fill in the title/due date/attachments, and pick a target (whole school, specific cohorts, or named students). Students see it instantly in their drawer.'**
  String get faqTeachersA3;

  /// No description provided for @faqTeachersQ4.
  ///
  /// In en, this message translates to:
  /// **'Can I issue a diploma or certificate?'**
  String get faqTeachersQ4;

  /// No description provided for @faqTeachersA4.
  ///
  /// In en, this message translates to:
  /// **'Yes — open Diplomas from the drawer, tap +, pick the student, fill in the title and details, and save. The student sees it in their own Diplomas section.'**
  String get faqTeachersA4;

  /// No description provided for @faqAdminsQ1.
  ///
  /// In en, this message translates to:
  /// **'Where do I start setting up a school?'**
  String get faqAdminsQ1;

  /// No description provided for @faqAdminsA1.
  ///
  /// In en, this message translates to:
  /// **'Open the Admin Dashboard. The School Setup widget at the top shows a 7-step checklist (logo, name, subjects, bell schedule, cohorts, students, teachers). Each step deep-links to where you complete it.'**
  String get faqAdminsA1;

  /// No description provided for @faqAdminsQ2.
  ///
  /// In en, this message translates to:
  /// **'How do cohorts work?'**
  String get faqAdminsQ2;

  /// No description provided for @faqAdminsA2.
  ///
  /// In en, this message translates to:
  /// **'A cohort is a group of students that share a schedule. Open Cohorts from the drawer to create them, assign students, and generate join codes. A single cohort can span multiple grades.'**
  String get faqAdminsA2;

  /// No description provided for @faqAdminsQ3.
  ///
  /// In en, this message translates to:
  /// **'Can a cohort cover more than one grade?'**
  String get faqAdminsQ3;

  /// No description provided for @faqAdminsA3.
  ///
  /// In en, this message translates to:
  /// **'Yes — when creating a cohort, select multiple grades. The cohort then appears in any of those grades\' filters and views, and announcements/templates targeted at any of those grades reach it.'**
  String get faqAdminsA3;

  /// No description provided for @faqAdminsQ4.
  ///
  /// In en, this message translates to:
  /// **'How do I build the weekly schedule?'**
  String get faqAdminsQ4;

  /// No description provided for @faqAdminsA4.
  ///
  /// In en, this message translates to:
  /// **'Open Schedule from the drawer. Tap any cell to add a period — pick the day/period, teacher, subject, and audience (cohort/student/grade). Bell-schedule times come from School Settings.'**
  String get faqAdminsA4;

  /// No description provided for @faqAdminsQ5.
  ///
  /// In en, this message translates to:
  /// **'How do I bulk-export students?'**
  String get faqAdminsQ5;

  /// No description provided for @faqAdminsA5.
  ///
  /// In en, this message translates to:
  /// **'Open Export Data from the drawer. Choose whether to select by student or by cohort, pick the rows, and tap Export. Optionally include current passwords during export.'**
  String get faqAdminsA5;

  /// No description provided for @faqAdminsQ6.
  ///
  /// In en, this message translates to:
  /// **'A user asked me to reset their password. What do I do?'**
  String get faqAdminsQ6;

  /// No description provided for @faqAdminsA6.
  ///
  /// In en, this message translates to:
  /// **'You can either set their password directly (Profile of the user → Security) or wait for them to file a request via \"Forgot password\" and approve it from Password Requests in the drawer.'**
  String get faqAdminsA6;

  /// No description provided for @faqParentsQ1.
  ///
  /// In en, this message translates to:
  /// **'How do I link my account to my child?'**
  String get faqParentsQ1;

  /// No description provided for @faqParentsA1.
  ///
  /// In en, this message translates to:
  /// **'Ask your child\'s school administrator to either add the link from their admin app, or share a one-time parent link code. Open Profile and enter the code under Family.'**
  String get faqParentsA1;

  /// No description provided for @faqParentsQ2.
  ///
  /// In en, this message translates to:
  /// **'What can I see about my child?'**
  String get faqParentsQ2;

  /// No description provided for @faqParentsA2.
  ///
  /// In en, this message translates to:
  /// **'Attendance, grades, announcements, and homework — exactly what your child sees plus the trends across time. You won\'t see private chats or Nova sessions.'**
  String get faqParentsA2;

  /// No description provided for @faqPrivacyQ1.
  ///
  /// In en, this message translates to:
  /// **'Who can see my data?'**
  String get faqPrivacyQ1;

  /// No description provided for @faqPrivacyA1.
  ///
  /// In en, this message translates to:
  /// **'Only people in your school. Teachers see their classrooms\' data, admins see school-wide data, parents see their linked children. We never sell data to advertisers.'**
  String get faqPrivacyA1;

  /// No description provided for @faqPrivacyQ2.
  ///
  /// In en, this message translates to:
  /// **'How do I delete my account?'**
  String get faqPrivacyQ2;

  /// No description provided for @faqPrivacyA2.
  ///
  /// In en, this message translates to:
  /// **'Ask your school administrator to delete it. They can remove the account from their admin app, which wipes your profile, schedule, and chats.'**
  String get faqPrivacyA2;

  /// No description provided for @solutionsPagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} page} other{{count} pages}}'**
  String solutionsPagesCount(int count);

  /// No description provided for @teacherMeetingEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Meeting'**
  String get teacherMeetingEditTitle;

  /// No description provided for @teacherMeetingNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule Meeting'**
  String get teacherMeetingNewTitle;

  /// No description provided for @teacherExamEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Exam'**
  String get teacherExamEditTitle;

  /// No description provided for @teacherExamNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Exam'**
  String get teacherExamNewTitle;

  /// No description provided for @teacherAssignmentEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Assignment'**
  String get teacherAssignmentEditTitle;

  /// No description provided for @teacherAssignmentNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New Assignment'**
  String get teacherAssignmentNewTitle;

  /// No description provided for @tooltipShowTabs.
  ///
  /// In en, this message translates to:
  /// **'Show tabs'**
  String get tooltipShowTabs;

  /// No description provided for @tooltipHideTabs.
  ///
  /// In en, this message translates to:
  /// **'Hide tabs'**
  String get tooltipHideTabs;

  /// No description provided for @examsCouldNotLoadForms.
  ///
  /// In en, this message translates to:
  /// **'Could not load forms'**
  String get examsCouldNotLoadForms;

  /// No description provided for @examsCouldNotLoadExams.
  ///
  /// In en, this message translates to:
  /// **'Could not load exams'**
  String get examsCouldNotLoadExams;

  /// No description provided for @messagesNoPeopleToAdd.
  ///
  /// In en, this message translates to:
  /// **'No people to add'**
  String get messagesNoPeopleToAdd;

  /// No description provided for @commonNoResultsForQuery.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String commonNoResultsForQuery(String query);

  /// No description provided for @chatForwardedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Forwarded to 1 chat} other{Forwarded to {count} chats}}'**
  String chatForwardedCount(int count);

  /// No description provided for @commonReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get commonReadMore;

  /// No description provided for @commonReadLess.
  ///
  /// In en, this message translates to:
  /// **'Read less'**
  String get commonReadLess;

  /// No description provided for @chatComposerSlideToCancel.
  ///
  /// In en, this message translates to:
  /// **'Slide to cancel'**
  String get chatComposerSlideToCancel;

  /// No description provided for @adminNoRoleYet.
  ///
  /// In en, this message translates to:
  /// **'No {role} yet'**
  String adminNoRoleYet(String role);

  /// No description provided for @profileVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified.'**
  String get profileVerified;

  /// No description provided for @profileUpdatedPendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Updated and pending re-verification.'**
  String get profileUpdatedPendingVerification;

  /// No description provided for @adminSearchCohorts.
  ///
  /// In en, this message translates to:
  /// **'Search cohorts…'**
  String get adminSearchCohorts;

  /// No description provided for @commonAdding.
  ///
  /// In en, this message translates to:
  /// **'Adding…'**
  String get commonAdding;

  /// No description provided for @teacherDiplomaIssuing.
  ///
  /// In en, this message translates to:
  /// **'Issuing…'**
  String get teacherDiplomaIssuing;

  /// No description provided for @teacherDiplomaIssue.
  ///
  /// In en, this message translates to:
  /// **'Issue'**
  String get teacherDiplomaIssue;

  /// No description provided for @formAccepting.
  ///
  /// In en, this message translates to:
  /// **'Accepting'**
  String get formAccepting;

  /// No description provided for @profileVerifiedShort.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get profileVerifiedShort;

  /// No description provided for @profileUnverified.
  ///
  /// In en, this message translates to:
  /// **'Unverified'**
  String get profileUnverified;

  /// No description provided for @notificationNewGradePosted.
  ///
  /// In en, this message translates to:
  /// **'📊 New grade posted'**
  String get notificationNewGradePosted;

  /// No description provided for @notificationNewGradePostedIn.
  ///
  /// In en, this message translates to:
  /// **'📊 New grade posted in {subject}'**
  String notificationNewGradePostedIn(String subject);

  /// No description provided for @messagesAddParticipants.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Add 1 participant} other{Add {count} participants}}'**
  String messagesAddParticipants(int count);

  /// No description provided for @notificationFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationFallbackTitle;

  /// No description provided for @adminCohortGradeRange.
  ///
  /// In en, this message translates to:
  /// **'Grade {from}-{to}'**
  String adminCohortGradeRange(int from, int to);

  /// No description provided for @adminCohortGradesList.
  ///
  /// In en, this message translates to:
  /// **'Grades {list}'**
  String adminCohortGradesList(String list);

  /// No description provided for @adminExportHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Export users'**
  String get adminExportHeaderTitle;

  /// No description provided for @adminExportHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add filters as pills — every pill adds users to the export. Tap a pill to remove it.'**
  String get adminExportHeaderSubtitle;

  /// No description provided for @adminExportAddFilter.
  ///
  /// In en, this message translates to:
  /// **'Add filter'**
  String get adminExportAddFilter;

  /// No description provided for @adminExportEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Add a filter to start: pick a role, cohort, grade, or specific users.'**
  String get adminExportEmptyState;

  /// No description provided for @adminExportFilterRolesTab.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get adminExportFilterRolesTab;

  /// No description provided for @adminExportFilterCohortsTab.
  ///
  /// In en, this message translates to:
  /// **'Cohorts'**
  String get adminExportFilterCohortsTab;

  /// No description provided for @adminExportFilterGradesTab.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get adminExportFilterGradesTab;

  /// No description provided for @adminExportFilterUsersTab.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get adminExportFilterUsersTab;

  /// No description provided for @adminExportSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get adminExportSelectAll;

  /// No description provided for @adminExportSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {total} selected'**
  String adminExportSelectedCount(int selected, int total);

  /// No description provided for @adminExportRolePickedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} picked} other{{count} picked}}'**
  String adminExportRolePickedCount(int count);

  /// No description provided for @adminExportPillRolePrefix.
  ///
  /// In en, this message translates to:
  /// **'Role:'**
  String get adminExportPillRolePrefix;

  /// No description provided for @adminExportPillCohortPrefix.
  ///
  /// In en, this message translates to:
  /// **'Cohort:'**
  String get adminExportPillCohortPrefix;

  /// No description provided for @adminExportActiveFilters.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} active filter} other{{count} active filters}}'**
  String adminExportActiveFilters(int count);

  /// No description provided for @adminExportClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get adminExportClearAll;

  /// No description provided for @adminExportCounting.
  ///
  /// In en, this message translates to:
  /// **'Counting…'**
  String get adminExportCounting;

  /// No description provided for @adminExportMatchCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} user will be exported} other{{count} users will be exported}}'**
  String adminExportMatchCount(int count);

  /// No description provided for @adminExportNoGradesConfigured.
  ///
  /// In en, this message translates to:
  /// **'No grades configured for this school'**
  String get adminExportNoGradesConfigured;

  /// No description provided for @adminExportColumnRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminExportColumnRole;

  /// No description provided for @adminExportRoleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get adminExportRoleStudent;

  /// No description provided for @adminExportRoleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get adminExportRoleTeacher;

  /// No description provided for @adminExportRoleParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get adminExportRoleParent;

  /// No description provided for @adminExportRoleSecretary.
  ///
  /// In en, this message translates to:
  /// **'Secretary'**
  String get adminExportRoleSecretary;

  /// No description provided for @adminExportRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminExportRoleAdmin;

  /// No description provided for @adminExportUsersSelected.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} user selected} other{{count} users selected}}'**
  String adminExportUsersSelected(int count);

  /// No description provided for @adminExportPasswordsOn.
  ///
  /// In en, this message translates to:
  /// **'Passwords will be reset and shown in the export — old passwords stop working. Handle the file securely.'**
  String get adminExportPasswordsOn;

  /// No description provided for @adminExportPasswordsOff.
  ///
  /// In en, this message translates to:
  /// **'Export will not contain any passwords.'**
  String get adminExportPasswordsOff;

  /// No description provided for @adminExportPdfUserDirectory.
  ///
  /// In en, this message translates to:
  /// **'User Directory'**
  String get adminExportPdfUserDirectory;

  /// No description provided for @adminExportPdfUsersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} user} other{{count} users}}'**
  String adminExportPdfUsersCount(int count);

  /// No description provided for @teacherAttachFromMaterials.
  ///
  /// In en, this message translates to:
  /// **'From materials'**
  String get teacherAttachFromMaterials;

  /// No description provided for @teacherUploadFiles.
  ///
  /// In en, this message translates to:
  /// **'Upload files'**
  String get teacherUploadFiles;

  /// No description provided for @solSubjectMathematics.
  ///
  /// In en, this message translates to:
  /// **'Mathematics'**
  String get solSubjectMathematics;

  /// No description provided for @solSubjectComputerScience.
  ///
  /// In en, this message translates to:
  /// **'Computer Science'**
  String get solSubjectComputerScience;

  /// No description provided for @solSubjectPhysics.
  ///
  /// In en, this message translates to:
  /// **'Physics'**
  String get solSubjectPhysics;

  /// No description provided for @solSubjectChemistry.
  ///
  /// In en, this message translates to:
  /// **'Chemistry'**
  String get solSubjectChemistry;

  /// No description provided for @solSubjectHebrew.
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get solSubjectHebrew;

  /// No description provided for @solSubjectBiology.
  ///
  /// In en, this message translates to:
  /// **'Biology'**
  String get solSubjectBiology;

  /// No description provided for @solSubjectHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get solSubjectHistory;

  /// No description provided for @solSubjectArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get solSubjectArabic;

  /// No description provided for @solSubjectElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get solSubjectElectronics;

  /// No description provided for @solSubjectMechanics.
  ///
  /// In en, this message translates to:
  /// **'Mechanics'**
  String get solSubjectMechanics;

  /// No description provided for @solSubjectFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get solSubjectFrench;

  /// No description provided for @solSubjectEnvironmentalScience.
  ///
  /// In en, this message translates to:
  /// **'Environmental Science'**
  String get solSubjectEnvironmentalScience;

  /// No description provided for @solSubjectCommunicationCinema.
  ///
  /// In en, this message translates to:
  /// **'Communication and Cinema'**
  String get solSubjectCommunicationCinema;

  /// No description provided for @solSubjectCitizenship.
  ///
  /// In en, this message translates to:
  /// **'Citizenship'**
  String get solSubjectCitizenship;

  /// No description provided for @solSubjectSociology.
  ///
  /// In en, this message translates to:
  /// **'Sociology'**
  String get solSubjectSociology;

  /// No description provided for @solSubjectReligion.
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get solSubjectReligion;

  /// No description provided for @solSubjectGeography.
  ///
  /// In en, this message translates to:
  /// **'Geography'**
  String get solSubjectGeography;

  /// No description provided for @solSubjectPsychology.
  ///
  /// In en, this message translates to:
  /// **'Psychology'**
  String get solSubjectPsychology;

  /// No description provided for @insightsSemesterTitle.
  ///
  /// In en, this message translates to:
  /// **'This semester'**
  String get insightsSemesterTitle;

  /// No description provided for @insightsOnTimeSubmissions.
  ///
  /// In en, this message translates to:
  /// **'On-time work'**
  String get insightsOnTimeSubmissions;

  /// No description provided for @insightsSubmissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Submissions'**
  String get insightsSubmissionsTitle;

  /// No description provided for @insightsOnTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get insightsOnTime;

  /// No description provided for @insightsLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get insightsLate;

  /// No description provided for @insightsMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get insightsMissing;

  /// No description provided for @insightsPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get insightsPending;

  /// No description provided for @insightsHandedInLabel.
  ///
  /// In en, this message translates to:
  /// **'handed in'**
  String get insightsHandedInLabel;

  /// No description provided for @insightsLatestGrades.
  ///
  /// In en, this message translates to:
  /// **'Latest grades'**
  String get insightsLatestGrades;

  /// No description provided for @insightsReviewWithNova.
  ///
  /// In en, this message translates to:
  /// **'Review with Nova'**
  String get insightsReviewWithNova;

  /// No description provided for @insightsReviewWithNovaPrompt.
  ///
  /// In en, this message translates to:
  /// **'Give me a short, honest review of my performance this semester — grades, attendance, and submissions — and the one thing I should focus on next.'**
  String get insightsReviewWithNovaPrompt;

  /// No description provided for @insightsPracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice accuracy'**
  String get insightsPracticeTitle;

  /// No description provided for @commonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get commonUnknown;

  /// No description provided for @solutionsReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this solution'**
  String get solutionsReportTitle;

  /// No description provided for @solutionsReportBody.
  ///
  /// In en, this message translates to:
  /// **'Tell the admins what\'s wrong. The admins of both schools will review it.'**
  String get solutionsReportBody;

  /// No description provided for @solutionsReportReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get solutionsReportReasonHint;

  /// No description provided for @solutionsReportAction.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get solutionsReportAction;

  /// No description provided for @solutionsReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Thanks — reported to the admins.'**
  String get solutionsReportSubmitted;

  /// No description provided for @solutionsReportAlready.
  ///
  /// In en, this message translates to:
  /// **'You already reported this.'**
  String get solutionsReportAlready;

  /// No description provided for @solutionsBookPagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String solutionsBookPagesCount(int count);

  /// No description provided for @solutionsNoBooksYetForStudents.
  ///
  /// In en, this message translates to:
  /// **'No books here yet. Your teacher will add them.'**
  String get solutionsNoBooksYetForStudents;

  /// No description provided for @solutionsManageBooksTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage books'**
  String get solutionsManageBooksTitle;

  /// No description provided for @solutionsNoBooksManageHint.
  ///
  /// In en, this message translates to:
  /// **'No books for this subject yet. Tap + to add one.'**
  String get solutionsNoBooksManageHint;

  /// No description provided for @solutionsDeleteBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete book?'**
  String get solutionsDeleteBookTitle;

  /// No description provided for @solutionsDeleteBookBody.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? This can\'t be undone.'**
  String solutionsDeleteBookBody(String title);

  /// No description provided for @solutionsBookSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save: {error}'**
  String solutionsBookSaveFailed(String error);

  /// No description provided for @solutionsBookDuplicateHint.
  ///
  /// In en, this message translates to:
  /// **'Before adding, make sure this book isn’t already in the database.'**
  String get solutionsBookDuplicateHint;

  /// No description provided for @solutionsBookDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicate book'**
  String get solutionsBookDuplicateTitle;

  /// No description provided for @solutionsBookDuplicateBody.
  ///
  /// In en, this message translates to:
  /// **'A book named \"{title}\" already exists. Make sure it isn’t the same one before adding it.'**
  String solutionsBookDuplicateBody(String title);

  /// No description provided for @solutionsBookAddAnyway.
  ///
  /// In en, this message translates to:
  /// **'Add anyway'**
  String get solutionsBookAddAnyway;

  /// No description provided for @solutionsBookNeedTitlePages.
  ///
  /// In en, this message translates to:
  /// **'Enter a title and page count.'**
  String get solutionsBookNeedTitlePages;

  /// No description provided for @solutionsEditBookTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit book'**
  String get solutionsEditBookTitle;

  /// No description provided for @solutionsBookCoverLabel.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get solutionsBookCoverLabel;

  /// No description provided for @solutionsGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade {grade}'**
  String solutionsGradeLabel(int grade);

  /// No description provided for @solutionsReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reported solutions'**
  String get solutionsReportsTitle;

  /// No description provided for @solutionsReportsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reports to review.'**
  String get solutionsReportsEmpty;

  /// No description provided for @solutionsReportPostedBy.
  ///
  /// In en, this message translates to:
  /// **'Posted by'**
  String get solutionsReportPostedBy;

  /// No description provided for @solutionsReportReportedBy.
  ///
  /// In en, this message translates to:
  /// **'Reported by'**
  String get solutionsReportReportedBy;

  /// No description provided for @solutionsReportReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get solutionsReportReasonLabel;

  /// No description provided for @solutionsReportKeepAction.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get solutionsReportKeepAction;

  /// No description provided for @solutionsReportRemoveAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get solutionsReportRemoveAction;

  /// No description provided for @solutionsReportStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get solutionsReportStatusPending;

  /// No description provided for @solutionsReportStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Kept'**
  String get solutionsReportStatusApproved;

  /// No description provided for @solutionsReportStatusRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed'**
  String get solutionsReportStatusRemoved;

  /// No description provided for @solutionsReportRemoved.
  ///
  /// In en, this message translates to:
  /// **'Solution removed.'**
  String get solutionsReportRemoved;

  /// No description provided for @solutionsReportApproved.
  ///
  /// In en, this message translates to:
  /// **'Report dismissed — solution kept.'**
  String get solutionsReportApproved;

  /// No description provided for @solutionsReportFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t report: {error}'**
  String solutionsReportFailed(String error);

  /// No description provided for @teacherAddGradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Grade'**
  String get teacherAddGradeTitle;

  /// No description provided for @commonCohort.
  ///
  /// In en, this message translates to:
  /// **'Cohort'**
  String get commonCohort;

  /// No description provided for @teacherCreateNewExam.
  ///
  /// In en, this message translates to:
  /// **'Create new exam'**
  String get teacherCreateNewExam;

  /// No description provided for @teacherCreateNewAssignment.
  ///
  /// In en, this message translates to:
  /// **'Create new assignment'**
  String get teacherCreateNewAssignment;

  /// No description provided for @commonReturn.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get commonReturn;

  /// No description provided for @reorderToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reorder menu'**
  String get reorderToolsTitle;

  /// No description provided for @reorderToolsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder your School Tools. The Core and Account sections stay put.'**
  String get reorderToolsSubtitle;

  /// No description provided for @reorderToolsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reorderToolsReset;

  /// No description provided for @reorderToolsSettingsSection.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get reorderToolsSettingsSection;

  /// No description provided for @reorderToolsSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reorder the tools in your side menu'**
  String get reorderToolsSettingsSubtitle;

  /// No description provided for @adminSchoolGradeRangesDescription.
  ///
  /// In en, this message translates to:
  /// **'Set which grades your school covers. Add multiple ranges if some grades are skipped (e.g. 4-6 and 9-12).'**
  String get adminSchoolGradeRangesDescription;

  /// No description provided for @adminSchoolAddGradeRange.
  ///
  /// In en, this message translates to:
  /// **'Add range'**
  String get adminSchoolAddGradeRange;

  /// No description provided for @teacherListStudents.
  ///
  /// In en, this message translates to:
  /// **'List students'**
  String get teacherListStudents;

  /// No description provided for @teacherNoStudentsInvolved.
  ///
  /// In en, this message translates to:
  /// **'No students in this period yet.'**
  String get teacherNoStudentsInvolved;

  /// No description provided for @messagesFilterAdmins.
  ///
  /// In en, this message translates to:
  /// **'Admins'**
  String get messagesFilterAdmins;

  /// No description provided for @teacherAssignmentGradedStatus.
  ///
  /// In en, this message translates to:
  /// **'Graded'**
  String get teacherAssignmentGradedStatus;

  /// No description provided for @teacherAssignmentReturnedStatus.
  ///
  /// In en, this message translates to:
  /// **'Returned for re-solution'**
  String get teacherAssignmentReturnedStatus;

  /// No description provided for @teacherAssignmentReturnAction.
  ///
  /// In en, this message translates to:
  /// **'Return for re-solution'**
  String get teacherAssignmentReturnAction;

  /// No description provided for @teacherAssignmentReturnDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Send this submission back to {name} to revise and hand in again? Any feedback you typed will be included.'**
  String teacherAssignmentReturnDialogBody(String name);

  /// No description provided for @teacherGradesSavedOf.
  ///
  /// In en, this message translates to:
  /// **'Saved {saved} of {total}.'**
  String teacherGradesSavedOf(int saved, int total);

  /// No description provided for @teacherGradesSkippedSuffix.
  ///
  /// In en, this message translates to:
  /// **'{dropped} student(s) skipped — not in a cohort.'**
  String teacherGradesSkippedSuffix(int dropped);

  /// No description provided for @adminPeopleGradeLevelRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick a grade level for this student.'**
  String get adminPeopleGradeLevelRequired;

  /// No description provided for @teacherAddGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade {grade}'**
  String teacherAddGradeLabel(int grade);

  /// No description provided for @teacherGradeOutOfHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 20'**
  String get teacherGradeOutOfHint;

  /// No description provided for @plansDowngrade.
  ///
  /// In en, this message translates to:
  /// **'Downgrade'**
  String get plansDowngrade;

  /// No description provided for @plansDowngradeNote.
  ///
  /// In en, this message translates to:
  /// **'Starts when your current plan ends — you keep it until then, no refund.'**
  String get plansDowngradeNote;

  /// No description provided for @semesterThis.
  ///
  /// In en, this message translates to:
  /// **'This semester'**
  String get semesterThis;

  /// No description provided for @semesterPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get semesterPrevious;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// No description provided for @adminSchoolSemestersLabel.
  ///
  /// In en, this message translates to:
  /// **'Semesters'**
  String get adminSchoolSemestersLabel;

  /// No description provided for @adminSchoolSemestersDescription.
  ///
  /// In en, this message translates to:
  /// **'Split the school year into semesters by month. Grades, exams, meetings and more are grouped by semester automatically.'**
  String get adminSchoolSemestersDescription;

  /// No description provided for @adminSchoolSemesterN.
  ///
  /// In en, this message translates to:
  /// **'Semester {n}'**
  String adminSchoolSemesterN(String n);

  /// No description provided for @adminSchoolAddSemester.
  ///
  /// In en, this message translates to:
  /// **'Add semester'**
  String get adminSchoolAddSemester;

  /// No description provided for @semesterStarts.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get semesterStarts;

  /// No description provided for @semesterEnds.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get semesterEnds;

  /// commonWhen
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get commonWhen;

  /// commonFiles
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get commonFiles;

  /// commonOnce
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get commonOnce;

  /// commonNoneDash
  ///
  /// In en, this message translates to:
  /// **'— None —'**
  String get commonNoneDash;

  /// commonNotesOptional
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get commonNotesOptional;

  /// commonSubjectOptional
  ///
  /// In en, this message translates to:
  /// **'Subject (optional)'**
  String get commonSubjectOptional;

  /// colorBlue
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// colorIndigo
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get colorIndigo;

  /// colorViolet
  ///
  /// In en, this message translates to:
  /// **'Violet'**
  String get colorViolet;

  /// colorTeal
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorTeal;

  /// colorGreen
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// colorOrange
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// colorRose
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorRose;

  /// teacherAddClassNotes
  ///
  /// In en, this message translates to:
  /// **'Add Class Notes'**
  String get teacherAddClassNotes;

  /// teacherStudentsWithGrades
  ///
  /// In en, this message translates to:
  /// **'Students with grades'**
  String get teacherStudentsWithGrades;

  /// teacherOtherStudentsSameGrade
  ///
  /// In en, this message translates to:
  /// **'Other students in the same grade/cohort'**
  String get teacherOtherStudentsSameGrade;

  /// teacherChooseExam
  ///
  /// In en, this message translates to:
  /// **'Choose exam'**
  String get teacherChooseExam;

  /// teacherChooseAssignment
  ///
  /// In en, this message translates to:
  /// **'Choose assignment'**
  String get teacherChooseAssignment;

  /// teacherSearchExams
  ///
  /// In en, this message translates to:
  /// **'Search exams…'**
  String get teacherSearchExams;

  /// teacherSearchAssignments
  ///
  /// In en, this message translates to:
  /// **'Search assignments…'**
  String get teacherSearchAssignments;

  /// teacherSearchQuestionTypes
  ///
  /// In en, this message translates to:
  /// **'Search question types…'**
  String get teacherSearchQuestionTypes;

  /// teacherOtherCustomSubject
  ///
  /// In en, this message translates to:
  /// **'Other (type custom)'**
  String get teacherOtherCustomSubject;

  /// adminLinkChild
  ///
  /// In en, this message translates to:
  /// **'Link Child'**
  String get adminLinkChild;

  /// adminChooseStudentDash
  ///
  /// In en, this message translates to:
  /// **'— Choose student —'**
  String get adminChooseStudentDash;

  /// adminSelectStudentToLink
  ///
  /// In en, this message translates to:
  /// **'Select student to link'**
  String get adminSelectStudentToLink;

  /// adminEditPeriod
  ///
  /// In en, this message translates to:
  /// **'Edit period'**
  String get adminEditPeriod;

  /// adminNotInAnyCohort
  ///
  /// In en, this message translates to:
  /// **'Not in any cohort yet — assign from the Cohorts screen.'**
  String get adminNotInAnyCohort;

  /// adminPasswordChangeWarning
  ///
  /// In en, this message translates to:
  /// **'The user will be signed in with this password next time they log in. Any pending password-reset links are invalidated.'**
  String get adminPasswordChangeWarning;

  /// nameInEnglish
  ///
  /// In en, this message translates to:
  /// **'Name in English'**
  String get nameInEnglish;

  /// nameInArabic
  ///
  /// In en, this message translates to:
  /// **'Name in Arabic'**
  String get nameInArabic;

  /// nameInHebrew
  ///
  /// In en, this message translates to:
  /// **'Name in Hebrew'**
  String get nameInHebrew;

  /// nameInFrench
  ///
  /// In en, this message translates to:
  /// **'Name in French'**
  String get nameInFrench;

  /// nameInRussian
  ///
  /// In en, this message translates to:
  /// **'Name in Russian'**
  String get nameInRussian;

  /// passwordMinChars
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters.'**
  String get passwordMinChars;

  /// passwordsDoNotMatch
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match.'**
  String get passwordsDoNotMatch;

  /// adminWelcomeHeading
  ///
  /// In en, this message translates to:
  /// **'Welcome to ClassMate'**
  String get adminWelcomeHeading;

  /// diplomasNoFilesAttached
  ///
  /// In en, this message translates to:
  /// **'No files attached to this certificate.'**
  String get diplomasNoFilesAttached;

  /// diplomasFilesProcessing
  ///
  /// In en, this message translates to:
  /// **'Files could not be opened — they may still be processing.'**
  String get diplomasFilesProcessing;

  /// novaOutOfTokens
  ///
  /// In en, this message translates to:
  /// **'You\'ve used all your tokens for this period. Upgrade or top up to keep chatting with NOVA.'**
  String get novaOutOfTokens;

  /// tutorDeleteConversationWarning
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the conversation and all its messages from the server. This cannot be undone.'**
  String get tutorDeleteConversationWarning;

  /// chatReportFlagWarning
  ///
  /// In en, this message translates to:
  /// **'This message will be flagged for review by an admin.'**
  String get chatReportFlagWarning;

  /// solutionPreviewFailFallback
  ///
  /// In en, this message translates to:
  /// **'Open from the chat attachment if preview fails'**
  String get solutionPreviewFailFallback;

  /// practiceNoInternet
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please try again.'**
  String get practiceNoInternet;

  /// practiceGenerationFailed
  ///
  /// In en, this message translates to:
  /// **'Could not generate questions. Please try again.'**
  String get practiceGenerationFailed;

  /// practiceTimingSecPerQuestion
  ///
  /// In en, this message translates to:
  /// **'s / question'**
  String get practiceTimingSecPerQuestion;

  /// practiceTimingMinPerQuiz
  ///
  /// In en, this message translates to:
  /// **'min / quiz'**
  String get practiceTimingMinPerQuiz;

  /// adminScheduleFrequencyWeeks
  ///
  /// In en, this message translates to:
  /// **'×{freq} wks'**
  String adminScheduleFrequencyWeeks(Object freq);

  /// gradeLevelLabel
  ///
  /// In en, this message translates to:
  /// **'Grade {grade}'**
  String gradeLevelLabel(Object grade);

  /// adminPeriodOption
  ///
  /// In en, this message translates to:
  /// **'Period {period}'**
  String adminPeriodOption(Object period);

  /// cohortStudentsCount
  ///
  /// In en, this message translates to:
  /// **'{count} students'**
  String cohortStudentsCount(Object count);

  /// diplomasIssuedCount
  ///
  /// In en, this message translates to:
  /// **'{count} certificates issued'**
  String diplomasIssuedCount(Object count);

  /// adminExportImportantHeading
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get adminExportImportantHeading;

  /// adminExportWelcomeBodyWithPw
  ///
  /// In en, this message translates to:
  /// **'These are your ClassMate account details. Sign in to the ClassMate app on iOS or Android using the username and password below. You can change your password in the app.'**
  String get adminExportWelcomeBodyWithPw;

  /// adminExportWelcomeBodyNoPw
  ///
  /// In en, this message translates to:
  /// **'These are your ClassMate account details. Sign in to the ClassMate app on iOS or Android using your username.'**
  String get adminExportWelcomeBodyNoPw;

  /// adminExportNotePrivate
  ///
  /// In en, this message translates to:
  /// **'Keep these credentials private. Do not share your password.'**
  String get adminExportNotePrivate;

  /// adminExportNoteChangePw
  ///
  /// In en, this message translates to:
  /// **'Change your password after your first sign-in from Settings → Account.'**
  String get adminExportNoteChangePw;

  /// adminExportNoteLegal
  ///
  /// In en, this message translates to:
  /// **'By using ClassMate you accept our Terms of Service and Privacy Policy.'**
  String get adminExportNoteLegal;

  /// adminExportNoteHelp
  ///
  /// In en, this message translates to:
  /// **'Need help? Contact your school administrator or {email}.'**
  String adminExportNoteHelp(String email);

  /// teacherGradeTitleHint
  ///
  /// In en, this message translates to:
  /// **'e.g. Class participation, Quiz 3'**
  String get teacherGradeTitleHint;

  /// teacherClassroomNameHint
  ///
  /// In en, this message translates to:
  /// **'e.g. Mathematics 10A'**
  String get teacherClassroomNameHint;

  /// novaAbout
  ///
  /// In en, this message translates to:
  /// **'About NOVA'**
  String get novaAbout;

  /// parentNotifForYou
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get parentNotifForYou;

  /// parentNotifAbout
  ///
  /// In en, this message translates to:
  /// **'About {name}'**
  String parentNotifAbout(String name);

  /// navPrivacyPolicy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get navPrivacyPolicy;

  /// privacyPolicySubtitle
  ///
  /// In en, this message translates to:
  /// **'How we protect your data'**
  String get privacyPolicySubtitle;

  /// semesterAllPrevious
  ///
  /// In en, this message translates to:
  /// **'All previous'**
  String get semesterAllPrevious;

  /// semesterSelectTitle
  ///
  /// In en, this message translates to:
  /// **'Select semester'**
  String get semesterSelectTitle;

  /// No description provided for @adminImportUsersScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Import users'**
  String get adminImportUsersScreenTitle;

  /// No description provided for @adminImportUsersScreenTabGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get adminImportUsersScreenTabGrid;

  /// No description provided for @adminImportUsersScreenTabCsv.
  ///
  /// In en, this message translates to:
  /// **'CSV'**
  String get adminImportUsersScreenTabCsv;

  /// No description provided for @adminImportUsersScreenLoadedRows.
  ///
  /// In en, this message translates to:
  /// **'Loaded {count} rows — review & edit, then Create'**
  String adminImportUsersScreenLoadedRows(int count);

  /// No description provided for @adminImportUsersScreenFillAtLeastOneName.
  ///
  /// In en, this message translates to:
  /// **'Fill at least one name'**
  String get adminImportUsersScreenFillAtLeastOneName;

  /// No description provided for @adminImportUsersScreenFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String adminImportUsersScreenFailed(String error);

  /// No description provided for @adminImportUsersScreenBackToGrid.
  ///
  /// In en, this message translates to:
  /// **'Back to grid'**
  String get adminImportUsersScreenBackToGrid;

  /// No description provided for @adminImportUsersScreenGridIntro.
  ///
  /// In en, this message translates to:
  /// **'Fill a row per person, or load a CSV from the CSV tab and fix anything here. Username is optional — we generate one if blank. For students, set the grade and (optionally) a parent\'s username to link them.'**
  String get adminImportUsersScreenGridIntro;

  /// No description provided for @adminImportUsersScreenAddRow.
  ///
  /// In en, this message translates to:
  /// **'Add row'**
  String get adminImportUsersScreenAddRow;

  /// No description provided for @adminImportUsersScreenCreateCount.
  ///
  /// In en, this message translates to:
  /// **'Create ({count})'**
  String adminImportUsersScreenCreateCount(int count);

  /// No description provided for @adminImportUsersScreenRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get adminImportUsersScreenRole;

  /// No description provided for @adminImportUsersScreenFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name *'**
  String get adminImportUsersScreenFullName;

  /// No description provided for @adminImportUsersScreenUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get adminImportUsersScreenUsername;

  /// No description provided for @adminImportUsersScreenUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'(auto if blank)'**
  String get adminImportUsersScreenUsernameHint;

  /// No description provided for @adminImportUsersScreenGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get adminImportUsersScreenGrade;

  /// No description provided for @adminImportUsersScreenParentUsername.
  ///
  /// In en, this message translates to:
  /// **'Parent username'**
  String get adminImportUsersScreenParentUsername;

  /// No description provided for @adminImportUsersScreenParentUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'link (optional)'**
  String get adminImportUsersScreenParentUsernameHint;

  /// No description provided for @adminImportUsersScreenCouldNotReadFile.
  ///
  /// In en, this message translates to:
  /// **'Could not read that file.'**
  String get adminImportUsersScreenCouldNotReadFile;

  /// No description provided for @adminImportUsersScreenCsvIntro.
  ///
  /// In en, this message translates to:
  /// **'Upload a CSV of your users. Column headers can be in any language — ClassMate detects what each column means, then loads the rows into the grid so you can review and fix anything before creating.'**
  String get adminImportUsersScreenCsvIntro;

  /// No description provided for @adminImportUsersScreenChooseCsv.
  ///
  /// In en, this message translates to:
  /// **'Choose CSV file'**
  String get adminImportUsersScreenChooseCsv;

  /// No description provided for @adminImportUsersScreenChooseDifferentFile.
  ///
  /// In en, this message translates to:
  /// **'Choose a different file'**
  String get adminImportUsersScreenChooseDifferentFile;

  /// No description provided for @adminImportUsersScreenSelectedFile.
  ///
  /// In en, this message translates to:
  /// **'Selected: {fileName}'**
  String adminImportUsersScreenSelectedFile(String fileName);

  /// No description provided for @adminImportUsersScreenRecognisedColumns.
  ///
  /// In en, this message translates to:
  /// **'Recognised columns'**
  String get adminImportUsersScreenRecognisedColumns;

  /// No description provided for @adminImportUsersScreenRecognisedColumnsBody.
  ///
  /// In en, this message translates to:
  /// **'name · username · password · email · phone · role · grade · parent (a username) · children (usernames)\n\nRole words like \"student / طالب / תלמיד / élève / ученик\" all map correctly. Grade reads the number from \"Grade 10\", \"الصف 10\", \"כיתה 10\". Missing usernames or passwords are generated automatically.'**
  String get adminImportUsersScreenRecognisedColumnsBody;

  /// No description provided for @adminImportUsersScreenDetectedRows.
  ///
  /// In en, this message translates to:
  /// **'Detected — {count} rows'**
  String adminImportUsersScreenDetectedRows(int count);

  /// No description provided for @adminImportUsersScreenNoColumnsDetected.
  ///
  /// In en, this message translates to:
  /// **'No known columns detected — check your header row.'**
  String get adminImportUsersScreenNoColumnsDetected;

  /// No description provided for @adminImportUsersScreenTruncatedNotice.
  ///
  /// In en, this message translates to:
  /// **'Showing the first 2000 rows for review.'**
  String get adminImportUsersScreenTruncatedNotice;

  /// No description provided for @adminImportUsersScreenReviewEditInGrid.
  ///
  /// In en, this message translates to:
  /// **'Review & edit in grid'**
  String get adminImportUsersScreenReviewEditInGrid;

  /// No description provided for @adminImportUsersScreenReviewEditHint.
  ///
  /// In en, this message translates to:
  /// **'Opens the Grid tab pre-filled with these rows so you can fix any mistakes before creating.'**
  String get adminImportUsersScreenReviewEditHint;

  /// No description provided for @adminImportUsersScreenResultSummary.
  ///
  /// In en, this message translates to:
  /// **'✓ Created {count} users · {links} links'**
  String adminImportUsersScreenResultSummary(int count, int links);

  /// No description provided for @adminImportUsersScreenResultFailedSuffix.
  ///
  /// In en, this message translates to:
  /// **' · {failed} failed'**
  String adminImportUsersScreenResultFailedSuffix(int failed);

  /// No description provided for @adminImportUsersScreenFailedRows.
  ///
  /// In en, this message translates to:
  /// **'Failed rows'**
  String get adminImportUsersScreenFailedRows;

  /// No description provided for @adminImportUsersScreenFailedRow.
  ///
  /// In en, this message translates to:
  /// **'Row {row}: {reason}'**
  String adminImportUsersScreenFailedRow(String row, String reason);

  /// No description provided for @adminImportUsersScreenCredentialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credentials (hand these to your users)'**
  String get adminImportUsersScreenCredentialsTitle;

  /// No description provided for @teacherCohortsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Cohorts'**
  String get teacherCohortsScreenTitle;

  /// No description provided for @teacherCohortsScreenNewCohort.
  ///
  /// In en, this message translates to:
  /// **'New cohort'**
  String get teacherCohortsScreenNewCohort;

  /// No description provided for @teacherCohortsScreenLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load cohorts.'**
  String get teacherCohortsScreenLoadError;

  /// No description provided for @teacherCohortsScreenEmpty.
  ///
  /// In en, this message translates to:
  /// **'No cohorts yet.\nTap \"New cohort\" to create one.'**
  String get teacherCohortsScreenEmpty;

  /// No description provided for @teacherCohortsScreenCohortNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Cohort name'**
  String get teacherCohortsScreenCohortNameLabel;

  /// No description provided for @teacherCohortsScreenCohortNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 10-2'**
  String get teacherCohortsScreenCohortNameHint;

  /// No description provided for @teacherCohortsScreenGradesLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade(s)'**
  String get teacherCohortsScreenGradesLabel;

  /// No description provided for @teacherCohortsScreenGradesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 10  or  7,8'**
  String get teacherCohortsScreenGradesHint;

  /// No description provided for @teacherCohortsScreenCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get teacherCohortsScreenCancel;

  /// No description provided for @teacherCohortsScreenCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get teacherCohortsScreenCreate;

  /// No description provided for @teacherCohortsScreenEnterNameAndGrade.
  ///
  /// In en, this message translates to:
  /// **'Enter a name and at least one grade'**
  String get teacherCohortsScreenEnterNameAndGrade;

  /// No description provided for @teacherCohortsScreenCohortCreated.
  ///
  /// In en, this message translates to:
  /// **'Cohort created'**
  String get teacherCohortsScreenCohortCreated;

  /// No description provided for @teacherCohortsScreenFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get teacherCohortsScreenFailed;

  /// No description provided for @teacherCohortsScreenStudentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} students'**
  String teacherCohortsScreenStudentsCount(int count);

  /// No description provided for @teacherCohortsScreenRenameGrades.
  ///
  /// In en, this message translates to:
  /// **'Rename / grades'**
  String get teacherCohortsScreenRenameGrades;

  /// No description provided for @teacherCohortsScreenDeleteCohort.
  ///
  /// In en, this message translates to:
  /// **'Delete cohort'**
  String get teacherCohortsScreenDeleteCohort;

  /// No description provided for @teacherCohortsScreenAddStudents.
  ///
  /// In en, this message translates to:
  /// **'Add students'**
  String get teacherCohortsScreenAddStudents;

  /// No description provided for @teacherCohortsScreenEditCohort.
  ///
  /// In en, this message translates to:
  /// **'Edit cohort'**
  String get teacherCohortsScreenEditCohort;

  /// No description provided for @teacherCohortsScreenSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get teacherCohortsScreenSave;

  /// No description provided for @teacherCohortsScreenSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get teacherCohortsScreenSaved;

  /// No description provided for @teacherCohortsScreenDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String teacherCohortsScreenDeleteConfirmTitle(String name);

  /// No description provided for @teacherCohortsScreenDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The cohort is removed and students are detached from it. Student accounts are not deleted.'**
  String get teacherCohortsScreenDeleteConfirmBody;

  /// No description provided for @teacherCohortsScreenDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get teacherCohortsScreenDelete;

  /// No description provided for @teacherCohortsScreenDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get teacherCohortsScreenDeleted;

  /// No description provided for @teacherCohortsScreenLoadStudentsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load students'**
  String get teacherCohortsScreenLoadStudentsError;

  /// No description provided for @teacherCohortsScreenAddNStudents.
  ///
  /// In en, this message translates to:
  /// **'Add {count} students'**
  String teacherCohortsScreenAddNStudents(int count);

  /// No description provided for @teacherCohortsScreenAddedNStudents.
  ///
  /// In en, this message translates to:
  /// **'Added {count} students'**
  String teacherCohortsScreenAddedNStudents(int count);

  /// No description provided for @teacherCohortsScreenNoStudentsYet.
  ///
  /// In en, this message translates to:
  /// **'No students yet.'**
  String get teacherCohortsScreenNoStudentsYet;

  /// No description provided for @adminSettingsScreenBulkTools.
  ///
  /// In en, this message translates to:
  /// **'Bulk tools'**
  String get adminSettingsScreenBulkTools;

  /// No description provided for @adminSettingsScreenImportUsers.
  ///
  /// In en, this message translates to:
  /// **'Import users'**
  String get adminSettingsScreenImportUsers;

  /// No description provided for @adminSettingsScreenImportUsersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add many at once — grid or CSV'**
  String get adminSettingsScreenImportUsersSubtitle;

  /// No description provided for @adminSettingsScreenUpgradeGrades.
  ///
  /// In en, this message translates to:
  /// **'Upgrade grades'**
  String get adminSettingsScreenUpgradeGrades;

  /// No description provided for @adminSettingsScreenUpgradeGradesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Promote every student one grade'**
  String get adminSettingsScreenUpgradeGradesSubtitle;

  /// No description provided for @adminSettingsScreenUpgradeGradesTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade all grades?'**
  String get adminSettingsScreenUpgradeGradesTitle;

  /// No description provided for @adminSettingsScreenUpgradeGradesBody.
  ///
  /// In en, this message translates to:
  /// **'Every student moves up one grade. Students already at the top grade are kept as graduating (never deleted) for you to handle. This is safe to run once at the start of the school year.'**
  String get adminSettingsScreenUpgradeGradesBody;

  /// No description provided for @adminSettingsScreenUpgradeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get adminSettingsScreenUpgradeConfirm;

  /// No description provided for @adminSettingsScreenUpgradeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Promoted {promoted} students · {graduating} graduating'**
  String adminSettingsScreenUpgradeSuccess(int promoted, int graduating);

  /// No description provided for @adminSettingsScreenDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get adminSettingsScreenDangerZone;

  /// No description provided for @adminSettingsScreenResetSchedule.
  ///
  /// In en, this message translates to:
  /// **'Reset schedule'**
  String get adminSettingsScreenResetSchedule;

  /// No description provided for @adminSettingsScreenResetScheduleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all periods & overrides'**
  String get adminSettingsScreenResetScheduleSubtitle;

  /// No description provided for @adminSettingsScreenResetScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset the whole schedule?'**
  String get adminSettingsScreenResetScheduleTitle;

  /// No description provided for @adminSettingsScreenResetScheduleBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes every period and one-off override for your school. Bell-schedule times are kept. This cannot be undone.'**
  String get adminSettingsScreenResetScheduleBody;

  /// No description provided for @adminSettingsScreenResetScheduleSuccess.
  ///
  /// In en, this message translates to:
  /// **'Schedule cleared — {slots} periods removed'**
  String adminSettingsScreenResetScheduleSuccess(int slots);

  /// No description provided for @adminSettingsScreenResetCohorts.
  ///
  /// In en, this message translates to:
  /// **'Reset cohorts'**
  String get adminSettingsScreenResetCohorts;

  /// No description provided for @adminSettingsScreenResetCohortsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all of your cohorts'**
  String get adminSettingsScreenResetCohortsSubtitle;

  /// No description provided for @adminSettingsScreenResetCohortsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete all cohorts?'**
  String get adminSettingsScreenResetCohortsTitle;

  /// No description provided for @adminSettingsScreenResetCohortsBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes every cohort in your school and removes students from them. Student accounts are NOT deleted. This cannot be undone.'**
  String get adminSettingsScreenResetCohortsBody;

  /// No description provided for @adminSettingsScreenDeleteCohortsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete cohorts'**
  String get adminSettingsScreenDeleteCohortsConfirm;

  /// No description provided for @adminSettingsScreenResetCohortsSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted {deleted} cohorts'**
  String adminSettingsScreenResetCohortsSuccess(int deleted);

  /// No description provided for @adminSettingsScreenAppearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Theme, colors, language'**
  String get adminSettingsScreenAppearanceSubtitle;

  /// No description provided for @adminSettingsScreenCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get adminSettingsScreenCancel;

  /// No description provided for @adminSettingsScreenWorking.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get adminSettingsScreenWorking;

  /// No description provided for @adminSettingsScreenFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String adminSettingsScreenFailed(String error);

  /// No description provided for @adminSchedulePickStartDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a start date for the every-{freq}-weeks schedule.'**
  String adminSchedulePickStartDate(int freq);

  /// No description provided for @adminScheduleNoCohortsYet.
  ///
  /// In en, this message translates to:
  /// **'No cohorts yet — create one first.'**
  String get adminScheduleNoCohortsYet;

  /// No description provided for @adminScheduleGradeWithCohort.
  ///
  /// In en, this message translates to:
  /// **'Grade {grade} · {cohort}'**
  String adminScheduleGradeWithCohort(String grade, String cohort);

  /// No description provided for @adminScheduleDateOnLabel.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get adminScheduleDateOnLabel;

  /// No description provided for @adminScheduleDateStartsOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Starts on'**
  String get adminScheduleDateStartsOnLabel;

  /// No description provided for @adminScheduleStudentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} students'**
  String adminScheduleStudentCount(int count);

  /// No description provided for @adminScheduleAudienceNone.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get adminScheduleAudienceNone;

  /// No description provided for @adminScheduleTeacherClashNamed.
  ///
  /// In en, this message translates to:
  /// **'{name} would have two classes at the same time.'**
  String adminScheduleTeacherClashNamed(String name);

  /// No description provided for @adminScheduleTeacherClash.
  ///
  /// In en, this message translates to:
  /// **'This teacher would have two classes at the same time.'**
  String get adminScheduleTeacherClash;

  /// No description provided for @adminScheduleStudentClashSingle.
  ///
  /// In en, this message translates to:
  /// **'{name} would have two periods at the same time:'**
  String adminScheduleStudentClashSingle(String name);

  /// No description provided for @adminScheduleStudentClashMany.
  ///
  /// In en, this message translates to:
  /// **'{count} students would have two periods at the same time:'**
  String adminScheduleStudentClashMany(int count);

  /// No description provided for @adminScheduleAStudent.
  ///
  /// In en, this message translates to:
  /// **'A student'**
  String get adminScheduleAStudent;

  /// No description provided for @adminScheduleAffected.
  ///
  /// In en, this message translates to:
  /// **'Affected: {preview}'**
  String adminScheduleAffected(String preview);

  /// No description provided for @adminScheduleResolvePrompt.
  ///
  /// In en, this message translates to:
  /// **'How should this be resolved?'**
  String get adminScheduleResolvePrompt;

  /// No description provided for @adminScheduleResolvePromptStudents.
  ///
  /// In en, this message translates to:
  /// **'How should this be resolved for those students?'**
  String get adminScheduleResolvePromptStudents;

  /// No description provided for @adminScheduleStudentsInCohorts.
  ///
  /// In en, this message translates to:
  /// **'{count} students in selected cohorts'**
  String adminScheduleStudentsInCohorts(int count, int cohortCount);

  /// No description provided for @adminScheduleStudentsInGrade.
  ///
  /// In en, this message translates to:
  /// **'{count} students in Grade {grade}'**
  String adminScheduleStudentsInGrade(int count, String grade);

  /// No description provided for @adminScheduleCustomizedNote.
  ///
  /// In en, this message translates to:
  /// **'Customized — saved as individual students'**
  String get adminScheduleCustomizedNote;

  /// No description provided for @adminScheduleMoreCount.
  ///
  /// In en, this message translates to:
  /// **'+{count} more'**
  String adminScheduleMoreCount(int count);

  /// No description provided for @adminScheduleAddStudentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add students'**
  String get adminScheduleAddStudentsTitle;

  /// No description provided for @adminScheduleNoStudentsMatch.
  ///
  /// In en, this message translates to:
  /// **'No students match.'**
  String get adminScheduleNoStudentsMatch;

  /// No description provided for @adminScheduleNoPeriodsHere.
  ///
  /// In en, this message translates to:
  /// **'No periods here yet.'**
  String get adminScheduleNoPeriodsHere;

  /// No description provided for @adminScheduleGradeRange.
  ///
  /// In en, this message translates to:
  /// **'Grade {from}-{to}'**
  String adminScheduleGradeRange(String from, String to);

  /// No description provided for @adminScheduleGradesList.
  ///
  /// In en, this message translates to:
  /// **'Grades {grades}'**
  String adminScheduleGradesList(String grades);

  /// No description provided for @adminScheduleNoStudentsInCohorts.
  ///
  /// In en, this message translates to:
  /// **'No students in these cohorts yet.'**
  String get adminScheduleNoStudentsInCohorts;

  /// No description provided for @adminScheduleEveryNWeeks.
  ///
  /// In en, this message translates to:
  /// **'Every {freq} weeks'**
  String adminScheduleEveryNWeeks(int freq);

  /// No description provided for @adminScheduleColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get adminScheduleColorLabel;

  /// No description provided for @adminScheduleSubjectRequired.
  ///
  /// In en, this message translates to:
  /// **'Subject *'**
  String get adminScheduleSubjectRequired;

  /// No description provided for @adminScheduleNoSchoolSubjects.
  ///
  /// In en, this message translates to:
  /// **'No school subjects yet. Tap \"Add new\" to define one.'**
  String get adminScheduleNoSchoolSubjects;

  /// No description provided for @adminScheduleNoSubjectsMatch.
  ///
  /// In en, this message translates to:
  /// **'No subjects match your search.'**
  String get adminScheduleNoSubjectsMatch;

  /// No description provided for @teacherNewAnnouncementScreenBroadcastBody.
  ///
  /// In en, this message translates to:
  /// **'No specific audience selected. This announcement will be visible to EVERY student, parent, teacher, secretary, and admin in the school.'**
  String get teacherNewAnnouncementScreenBroadcastBody;

  /// No description provided for @teacherNewAnnouncementScreenGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade {grade}'**
  String teacherNewAnnouncementScreenGradeLabel(int grade);

  /// No description provided for @teacherNewAnnouncementScreenNoFilesAttached.
  ///
  /// In en, this message translates to:
  /// **'No files attached.'**
  String get teacherNewAnnouncementScreenNoFilesAttached;

  /// No description provided for @teacherNewAnnouncementScreenSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String teacherNewAnnouncementScreenSelectedCount(int count);

  /// No description provided for @teacherNewAnnouncementScreenAudienceHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a category, then the specific roles, grades, cohorts, or people. Selections from every category add up.'**
  String get teacherNewAnnouncementScreenAudienceHint;

  /// No description provided for @teacherNewAnnouncementScreenLoadingStudents.
  ///
  /// In en, this message translates to:
  /// **'Loading students…'**
  String get teacherNewAnnouncementScreenLoadingStudents;

  /// No description provided for @teacherNewAnnouncementScreenNoGradeLevels.
  ///
  /// In en, this message translates to:
  /// **'No grade levels found yet.'**
  String get teacherNewAnnouncementScreenNoGradeLevels;

  /// No description provided for @teacherNewAnnouncementScreenTapSelectCohorts.
  ///
  /// In en, this message translates to:
  /// **'Tap to select cohorts…'**
  String get teacherNewAnnouncementScreenTapSelectCohorts;

  /// No description provided for @teacherNewAnnouncementScreenCohortsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} cohorts selected'**
  String teacherNewAnnouncementScreenCohortsSelected(int count);

  /// No description provided for @teacherNewAnnouncementScreenTapSelectStudents.
  ///
  /// In en, this message translates to:
  /// **'Tap to select students…'**
  String get teacherNewAnnouncementScreenTapSelectStudents;

  /// No description provided for @teacherNewAnnouncementScreenStudentsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} students selected'**
  String teacherNewAnnouncementScreenStudentsSelected(int count);

  /// No description provided for @teacherNewAnnouncementScreenTapSelectParents.
  ///
  /// In en, this message translates to:
  /// **'Tap to select parents…'**
  String get teacherNewAnnouncementScreenTapSelectParents;

  /// No description provided for @teacherNewAnnouncementScreenParentsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} parents selected'**
  String teacherNewAnnouncementScreenParentsSelected(int count);

  /// No description provided for @teacherNewAnnouncementScreenSelectedAudience.
  ///
  /// In en, this message translates to:
  /// **'Selected audience'**
  String get teacherNewAnnouncementScreenSelectedAudience;

  /// No description provided for @teacherNewAnnouncementScreenStudentsInCohorts.
  ///
  /// In en, this message translates to:
  /// **'{count} students in selected cohorts'**
  String teacherNewAnnouncementScreenStudentsInCohorts(int count);

  /// No description provided for @teacherNewAnnouncementScreenSelectParents.
  ///
  /// In en, this message translates to:
  /// **'Select parents'**
  String get teacherNewAnnouncementScreenSelectParents;

  /// No description provided for @teacherNewAnnouncementScreenChildrenSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} children — {summary}'**
  String teacherNewAnnouncementScreenChildrenSummary(int count, String summary);

  /// No description provided for @teacherNewAnnouncementScreenNoLinkedChildren.
  ///
  /// In en, this message translates to:
  /// **'No linked children'**
  String get teacherNewAnnouncementScreenNoLinkedChildren;

  /// No description provided for @adminPeriodsScreenDayN.
  ///
  /// In en, this message translates to:
  /// **'Day {dow}'**
  String adminPeriodsScreenDayN(int dow);

  /// No description provided for @adminPeriodsScreenPeriodN.
  ///
  /// In en, this message translates to:
  /// **'Period {period}'**
  String adminPeriodsScreenPeriodN(int period);

  /// No description provided for @adminPeriodsScreenPeriodDropdownLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get adminPeriodsScreenPeriodDropdownLabel;

  /// No description provided for @adminPeriodsScreenSelectTeacher.
  ///
  /// In en, this message translates to:
  /// **'Select teacher…'**
  String get adminPeriodsScreenSelectTeacher;

  /// No description provided for @adminPeriodsScreenNone.
  ///
  /// In en, this message translates to:
  /// **'— None —'**
  String get adminPeriodsScreenNone;

  /// No description provided for @adminPeriodsScreenLinkClassroom.
  ///
  /// In en, this message translates to:
  /// **'Link to classroom…'**
  String get adminPeriodsScreenLinkClassroom;

  /// No description provided for @adminPeriodsScreenCohortGradeName.
  ///
  /// In en, this message translates to:
  /// **'G{grade} — {name}'**
  String adminPeriodsScreenCohortGradeName(String grade, String name);

  /// No description provided for @adminPeriodsScreenGradeN.
  ///
  /// In en, this message translates to:
  /// **'Grade {grade}'**
  String adminPeriodsScreenGradeN(String grade);

  /// No description provided for @roleBadgeStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get roleBadgeStudent;

  /// No description provided for @roleBadgeTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get roleBadgeTeacher;

  /// No description provided for @roleBadgeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get roleBadgeAdmin;

  /// No description provided for @roleBadgeSecretary.
  ///
  /// In en, this message translates to:
  /// **'Secretary'**
  String get roleBadgeSecretary;

  /// No description provided for @roleBadgeParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get roleBadgeParent;

  /// No description provided for @roleBadgeMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get roleBadgeMember;

  /// No description provided for @teacherSlotAttachmentsScreenEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No attachments yet'**
  String get teacherSlotAttachmentsScreenEmptyTitle;

  /// No description provided for @teacherSlotAttachmentsScreenEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Attach materials so your students see them on this period\'s card.'**
  String get teacherSlotAttachmentsScreenEmptyBody;

  /// No description provided for @teacherSlotAttachmentsScreenMaterialFallback.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get teacherSlotAttachmentsScreenMaterialFallback;

  /// No description provided for @teacherSlotAttachmentsScreenSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Attach material'**
  String get teacherSlotAttachmentsScreenSheetTitle;

  /// No description provided for @teacherSlotAttachmentsScreenCreateNew.
  ///
  /// In en, this message translates to:
  /// **'Create new material'**
  String get teacherSlotAttachmentsScreenCreateNew;

  /// No description provided for @teacherAddGradeScreenPickAudience.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one student, cohort, or grade.'**
  String get teacherAddGradeScreenPickAudience;

  /// No description provided for @teacherAddGradeScreenEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title for this grade.'**
  String get teacherAddGradeScreenEnterTitle;

  /// No description provided for @teacherAddGradeScreenPickExam.
  ///
  /// In en, this message translates to:
  /// **'Pick an exam.'**
  String get teacherAddGradeScreenPickExam;

  /// No description provided for @teacherAddGradeScreenPickAssignment.
  ///
  /// In en, this message translates to:
  /// **'Pick an assignment.'**
  String get teacherAddGradeScreenPickAssignment;

  /// No description provided for @teacherAddGradeScreenCouldNotResolveTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not resolve grade title.'**
  String get teacherAddGradeScreenCouldNotResolveTitle;

  /// No description provided for @teacherAddGradeScreenEnterNumericGrade.
  ///
  /// In en, this message translates to:
  /// **'Enter a numeric grade for {name}.'**
  String teacherAddGradeScreenEnterNumericGrade(String name);

  /// No description provided for @teacherAddGradeScreenError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String teacherAddGradeScreenError(String error);

  /// No description provided for @teacherAddGradeScreenTapSelectStudents.
  ///
  /// In en, this message translates to:
  /// **'Tap to select students…'**
  String get teacherAddGradeScreenTapSelectStudents;

  /// No description provided for @teacherAddGradeScreenStudentsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} student(s) selected'**
  String teacherAddGradeScreenStudentsSelected(int count);

  /// No description provided for @teacherAddGradeScreenTapSelectCohorts.
  ///
  /// In en, this message translates to:
  /// **'Tap to select cohorts…'**
  String get teacherAddGradeScreenTapSelectCohorts;

  /// No description provided for @teacherAddGradeScreenCohortsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} cohort(s) selected'**
  String teacherAddGradeScreenCohortsSelected(int count);

  /// No description provided for @teacherAddGradeScreenWillBeGraded.
  ///
  /// In en, this message translates to:
  /// **'{count} student(s) will be graded'**
  String teacherAddGradeScreenWillBeGraded(int count);

  /// No description provided for @teacherAddGradeScreenNoGradeLevels.
  ///
  /// In en, this message translates to:
  /// **'No grade levels found on your students yet.'**
  String get teacherAddGradeScreenNoGradeLevels;

  /// No description provided for @teacherAddGradeScreenSelectAudienceExams.
  ///
  /// In en, this message translates to:
  /// **'Select an audience first to filter exams.'**
  String get teacherAddGradeScreenSelectAudienceExams;

  /// No description provided for @teacherAddGradeScreenNoExamsReach.
  ///
  /// In en, this message translates to:
  /// **'No exams reach all selected {audience}.'**
  String teacherAddGradeScreenNoExamsReach(String audience);

  /// No description provided for @teacherAddGradeScreenSelectAudienceAssignments.
  ///
  /// In en, this message translates to:
  /// **'Select an audience first to filter assignments.'**
  String get teacherAddGradeScreenSelectAudienceAssignments;

  /// No description provided for @teacherAddGradeScreenNoAssignmentsReach.
  ///
  /// In en, this message translates to:
  /// **'No assignments reach all selected {audience}.'**
  String teacherAddGradeScreenNoAssignmentsReach(String audience);

  /// No description provided for @teacherAddGradeScreenSelectAudienceAbove.
  ///
  /// In en, this message translates to:
  /// **'Select an audience above to enter grades.'**
  String get teacherAddGradeScreenSelectAudienceAbove;

  /// No description provided for @teacherAddGradeScreenSelectStudentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select students'**
  String get teacherAddGradeScreenSelectStudentsTitle;

  /// No description provided for @teacherAddGradeScreenCountSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String teacherAddGradeScreenCountSelected(int count);

  /// No description provided for @teacherAddGradeScreenSelectCohortsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select cohorts'**
  String get teacherAddGradeScreenSelectCohortsTitle;

  /// No description provided for @teacherAddGradeScreenAudienceCohorts.
  ///
  /// In en, this message translates to:
  /// **'cohorts'**
  String get teacherAddGradeScreenAudienceCohorts;

  /// No description provided for @teacherAddGradeScreenAudienceGrades.
  ///
  /// In en, this message translates to:
  /// **'grades'**
  String get teacherAddGradeScreenAudienceGrades;

  /// No description provided for @teacherAddGradeScreenAudienceStudents.
  ///
  /// In en, this message translates to:
  /// **'students'**
  String get teacherAddGradeScreenAudienceStudents;

  /// No description provided for @formDetailScreenCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load this form right now.'**
  String get formDetailScreenCouldNotLoad;

  /// No description provided for @formDetailScreenSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Form submitted'**
  String get formDetailScreenSubmitted;

  /// No description provided for @formDetailScreenSubmissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Submission failed'**
  String get formDetailScreenSubmissionFailed;

  /// No description provided for @formDetailScreenAlreadySubmittedNote.
  ///
  /// In en, this message translates to:
  /// **'You have already submitted this form.'**
  String get formDetailScreenAlreadySubmittedNote;

  /// No description provided for @formDetailScreenSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get formDetailScreenSubmitting;

  /// No description provided for @formDetailScreenSubmitAgain.
  ///
  /// In en, this message translates to:
  /// **'Submit again'**
  String get formDetailScreenSubmitAgain;

  /// No description provided for @formDetailScreenSubmitForm.
  ///
  /// In en, this message translates to:
  /// **'Submit form'**
  String get formDetailScreenSubmitForm;

  /// No description provided for @formDetailScreenQuestionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String formDetailScreenQuestionCount(int count);

  /// No description provided for @formDetailScreenMultiSubmit.
  ///
  /// In en, this message translates to:
  /// **'Multi-submit'**
  String get formDetailScreenMultiSubmit;

  /// No description provided for @formDetailScreenOnePerStudent.
  ///
  /// In en, this message translates to:
  /// **'1 per student'**
  String get formDetailScreenOnePerStudent;

  /// No description provided for @formDetailScreenRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get formDetailScreenRequired;

  /// No description provided for @formDetailScreenYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get formDetailScreenYourAnswer;

  /// No description provided for @formDetailScreenLongAnswerText.
  ///
  /// In en, this message translates to:
  /// **'Long answer text'**
  String get formDetailScreenLongAnswerText;

  /// No description provided for @formDetailScreenSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get formDetailScreenSelect;

  /// No description provided for @novaChatScreenAboutAiPoweredTitle.
  ///
  /// In en, this message translates to:
  /// **'AI-powered assistant'**
  String get novaChatScreenAboutAiPoweredTitle;

  /// No description provided for @novaChatScreenAboutAiPoweredBody.
  ///
  /// In en, this message translates to:
  /// **'NOVA is built on large language model technology to help you study, understand concepts, and explore ideas.'**
  String get novaChatScreenAboutAiPoweredBody;

  /// No description provided for @novaChatScreenAboutMistakesBody.
  ///
  /// In en, this message translates to:
  /// **'NOVA may produce inaccurate, incomplete, or outdated information. Always verify important answers with your teacher or a trusted source.'**
  String get novaChatScreenAboutMistakesBody;

  /// No description provided for @novaChatScreenAboutEducationalBody.
  ///
  /// In en, this message translates to:
  /// **'NOVA is designed for learning support and is not a substitute for professional medical, legal, or financial advice.'**
  String get novaChatScreenAboutEducationalBody;

  /// No description provided for @novaChatScreenAboutPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Conversations are used to generate responses. Do not share sensitive personal information.'**
  String get novaChatScreenAboutPrivacyBody;

  /// No description provided for @novaChatScreenDisclaimerTapToLearn.
  ///
  /// In en, this message translates to:
  /// **'NOVA can make mistakes. Tap to learn more.'**
  String get novaChatScreenDisclaimerTapToLearn;

  /// No description provided for @userProfileSheetSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get userProfileSheetSchool;

  /// No description provided for @userProfileSheetClass.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get userProfileSheetClass;

  /// No description provided for @userProfileSheetParents.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get userProfileSheetParents;

  /// No description provided for @userProfileSheetChildren.
  ///
  /// In en, this message translates to:
  /// **'Children'**
  String get userProfileSheetChildren;

  /// No description provided for @scheduleScreenNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get scheduleScreenNotes;

  /// No description provided for @scheduleScreenMaterialFallback.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get scheduleScreenMaterialFallback;

  /// No description provided for @scheduleScreenNow.
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get scheduleScreenNow;

  /// No description provided for @scheduleScreenMaterialCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 material} other{{count} materials}}'**
  String scheduleScreenMaterialCount(int count);

  /// No description provided for @teacherFormResponsesScreenResponseCount.
  ///
  /// In en, this message translates to:
  /// **'{count} response{count, plural, =1{} other{s}}'**
  String teacherFormResponsesScreenResponseCount(int count);

  /// No description provided for @teacherFormResponsesScreenEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No responses yet'**
  String get teacherFormResponsesScreenEmptyTitle;

  /// No description provided for @teacherFormResponsesScreenEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Responses will appear here once students submit.'**
  String get teacherFormResponsesScreenEmptySubtitle;

  /// No description provided for @teacherFormResponsesScreenStudentFallback.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get teacherFormResponsesScreenStudentFallback;

  /// No description provided for @teacherFormResponsesScreenSubmittedAt.
  ///
  /// In en, this message translates to:
  /// **'Submitted {date}'**
  String teacherFormResponsesScreenSubmittedAt(String date);

  /// No description provided for @teacherCreateFormScreenQuestionNumber.
  ///
  /// In en, this message translates to:
  /// **'Q{number}'**
  String teacherCreateFormScreenQuestionNumber(String number);

  /// No description provided for @teacherCreateFormScreenShortAnswerPreview.
  ///
  /// In en, this message translates to:
  /// **'Short answer'**
  String get teacherCreateFormScreenShortAnswerPreview;

  /// No description provided for @teacherCreateFormScreenLongAnswerPreview.
  ///
  /// In en, this message translates to:
  /// **'Long answer'**
  String get teacherCreateFormScreenLongAnswerPreview;

  /// No description provided for @teacherCreateFormScreenDatePickerPreview.
  ///
  /// In en, this message translates to:
  /// **'Date picker'**
  String get teacherCreateFormScreenDatePickerPreview;

  /// No description provided for @teacherCreateFormScreenScaleTo.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get teacherCreateFormScreenScaleTo;

  /// No description provided for @teacherMeetingsScreenNoneOption.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get teacherMeetingsScreenNoneOption;

  /// No description provided for @teacherMeetingsScreenGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade {grade}'**
  String teacherMeetingsScreenGradeLabel(String grade);

  /// No description provided for @teacherMeetingsScreenStudentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} student{count, plural, =1{} other{s}}'**
  String teacherMeetingsScreenStudentCount(int count);

  /// No description provided for @teacherMeetingsScreenPickStartTime.
  ///
  /// In en, this message translates to:
  /// **'Pick start time'**
  String get teacherMeetingsScreenPickStartTime;

  /// No description provided for @teacherMeetingsScreenPickEndTime.
  ///
  /// In en, this message translates to:
  /// **'Pick end time'**
  String get teacherMeetingsScreenPickEndTime;

  /// No description provided for @teacherMeetingsScreenMembersWillReceive.
  ///
  /// In en, this message translates to:
  /// **'{count} member{count, plural, =1{} other{s}} will receive this'**
  String teacherMeetingsScreenMembersWillReceive(int count);

  /// No description provided for @teacherAssignmentsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get teacherAssignmentsScreenTitle;

  /// No description provided for @teacherAssignmentsScreenSummary.
  ///
  /// In en, this message translates to:
  /// **'{total} total · {published} published'**
  String teacherAssignmentsScreenSummary(int total, int published);

  /// No description provided for @teacherAssignmentsScreenEmpty.
  ///
  /// In en, this message translates to:
  /// **'No assignments yet.\nTap + to create one.'**
  String get teacherAssignmentsScreenEmpty;

  /// No description provided for @teacherAssignmentsScreenSubmitted.
  ///
  /// In en, this message translates to:
  /// **'{count} submitted'**
  String teacherAssignmentsScreenSubmitted(int count);

  /// No description provided for @audienceSectionCohorts.
  ///
  /// In en, this message translates to:
  /// **'Cohorts'**
  String get audienceSectionCohorts;

  /// No description provided for @audienceSectionGrades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get audienceSectionGrades;

  /// No description provided for @audienceSectionGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade {grade}'**
  String audienceSectionGradeLabel(int grade);

  /// No description provided for @audienceSectionStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get audienceSectionStudents;

  /// No description provided for @audienceSectionStudentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} student{count, plural, =1{} other{s}}'**
  String audienceSectionStudentCount(int count);

  /// No description provided for @audienceSectionMemberCount.
  ///
  /// In en, this message translates to:
  /// **'{count} member{count, plural, =1{} other{s}} will receive this'**
  String audienceSectionMemberCount(int count);

  /// No description provided for @audienceSectionSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String audienceSectionSelectedCount(int count);

  /// No description provided for @secretaryStudentsScreenStudentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} student{count, plural, =1{} other{s}}'**
  String secretaryStudentsScreenStudentCount(int count);

  /// No description provided for @secretaryStudentsScreenAvg.
  ///
  /// In en, this message translates to:
  /// **'Avg {grade}'**
  String secretaryStudentsScreenAvg(String grade);

  /// No description provided for @secretaryStudentsScreenIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get secretaryStudentsScreenIdentity;

  /// No description provided for @secretaryStudentsScreenUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get secretaryStudentsScreenUsername;

  /// No description provided for @secretaryStudentsScreenEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get secretaryStudentsScreenEmail;

  /// No description provided for @secretaryStudentsScreenPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get secretaryStudentsScreenPhone;

  /// No description provided for @secretaryStudentsScreenCohort.
  ///
  /// In en, this message translates to:
  /// **'Cohort'**
  String get secretaryStudentsScreenCohort;

  /// No description provided for @secretaryStudentsScreenGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get secretaryStudentsScreenGrade;

  /// No description provided for @secretaryStudentsScreenPrimaryCohort.
  ///
  /// In en, this message translates to:
  /// **'Primary cohort'**
  String get secretaryStudentsScreenPrimaryCohort;

  /// No description provided for @secretaryStudentsScreenTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher: {name}'**
  String secretaryStudentsScreenTeacher(String name);

  /// No description provided for @chatMessageBubbleEdited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get chatMessageBubbleEdited;

  /// No description provided for @chatMessageBubbleForwarded.
  ///
  /// In en, this message translates to:
  /// **'Forwarded'**
  String get chatMessageBubbleForwarded;

  /// No description provided for @chatMessageBubblePinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get chatMessageBubblePinned;

  /// No description provided for @chatMessageBubbleReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get chatMessageBubbleReply;

  /// No description provided for @chatMessageBubbleMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get chatMessageBubbleMessage;

  /// No description provided for @chatMessageBubbleDeletedMessage.
  ///
  /// In en, this message translates to:
  /// **'This message was deleted'**
  String get chatMessageBubbleDeletedMessage;

  /// No description provided for @chatMessageBubbleImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get chatMessageBubbleImage;

  /// No description provided for @chatMessageBubbleVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get chatMessageBubbleVideo;

  /// No description provided for @chatMessageBubbleFile.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get chatMessageBubbleFile;

  /// No description provided for @chatMessageInfoPageReadSection.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get chatMessageInfoPageReadSection;

  /// No description provided for @chatMessageInfoPageNoOneRead.
  ///
  /// In en, this message translates to:
  /// **'No one has read this yet'**
  String get chatMessageInfoPageNoOneRead;

  /// No description provided for @chatMessageInfoPageDeliveredSection.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get chatMessageInfoPageDeliveredSection;

  /// No description provided for @chatMessageInfoPagePendingSection.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get chatMessageInfoPagePendingSection;

  /// No description provided for @chatMessageInfoPageUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get chatMessageInfoPageUnknown;

  /// No description provided for @profileEnterCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code'**
  String get profileEnterCodeTitle;

  /// No description provided for @profileCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Sent to {target}. Expires in 15 minutes.'**
  String profileCodeSentTo(String target);

  /// No description provided for @profileCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent. Expires in 15 minutes.'**
  String get profileCodeSent;

  /// No description provided for @profileChangeContact.
  ///
  /// In en, this message translates to:
  /// **'Change {label}'**
  String profileChangeContact(String label);

  /// No description provided for @profileVerifyNewContactInfo.
  ///
  /// In en, this message translates to:
  /// **'A verification code will be sent to the value you enter — confirming you own it.'**
  String get profileVerifyNewContactInfo;

  /// No description provided for @profileVerifyCurrentContactInfo.
  ///
  /// In en, this message translates to:
  /// **'A verification code will be sent to your CURRENT {label} so you can prove ownership before switching.'**
  String profileVerifyCurrentContactInfo(String label);

  /// No description provided for @appShellReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get appShellReports;

  /// No description provided for @appShellExportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get appShellExportData;

  /// No description provided for @appShellAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get appShellAdmin;

  /// No description provided for @appShellViewingAs.
  ///
  /// In en, this message translates to:
  /// **'Viewing as '**
  String get appShellViewingAs;

  /// No description provided for @appShellSwitchChild.
  ///
  /// In en, this message translates to:
  /// **'Switch child'**
  String get appShellSwitchChild;

  /// No description provided for @messageThreadScreenGroupInviteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You were invited to join this group.'**
  String get messageThreadScreenGroupInviteSubtitle;

  /// No description provided for @messageThreadScreenBlockedHint.
  ///
  /// In en, this message translates to:
  /// **'You blocked this chat. Unblock from the blocked people list to chat again.'**
  String get messageThreadScreenBlockedHint;

  /// No description provided for @messageThreadScreenCannotSendHint.
  ///
  /// In en, this message translates to:
  /// **'You cannot send messages in this chat right now.'**
  String get messageThreadScreenCannotSendHint;

  /// No description provided for @messageThreadScreenTapForGroupInfo.
  ///
  /// In en, this message translates to:
  /// **'Tap for group info'**
  String get messageThreadScreenTapForGroupInfo;

  /// No description provided for @messageThreadScreenAddParticipantsTitle.
  ///
  /// In en, this message translates to:
  /// **'Add participants'**
  String get messageThreadScreenAddParticipantsTitle;

  /// No description provided for @teacherExamsScreenGradedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} graded'**
  String teacherExamsScreenGradedCount(int count);

  /// No description provided for @teacherScheduleScreenNextUp.
  ///
  /// In en, this message translates to:
  /// **'Next up'**
  String get teacherScheduleScreenNextUp;

  /// No description provided for @teacherScheduleScreenPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period {period}'**
  String teacherScheduleScreenPeriodLabel(String period);

  /// No description provided for @teacherScheduleScreenGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade {grade}'**
  String teacherScheduleScreenGradeLabel(int grade);

  /// No description provided for @teacherScheduleScreenMaterialsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 material} other{{count} materials}}'**
  String teacherScheduleScreenMaterialsCount(int count);

  /// No description provided for @teacherClassroomAddAssignmentScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Assignment'**
  String get teacherClassroomAddAssignmentScreenTitle;

  /// No description provided for @teacherClassroomAddAssignmentScreenDetails.
  ///
  /// In en, this message translates to:
  /// **'Assignment Details'**
  String get teacherClassroomAddAssignmentScreenDetails;

  /// No description provided for @teacherClassroomAddAssignmentScreenDueDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Due date (optional)'**
  String get teacherClassroomAddAssignmentScreenDueDateOptional;

  /// No description provided for @teacherClassroomAddAssignmentScreenNotifyStudents.
  ///
  /// In en, this message translates to:
  /// **'Notify students'**
  String get teacherClassroomAddAssignmentScreenNotifyStudents;

  /// No description provided for @teacherClassroomAddAssignmentScreenUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get teacherClassroomAddAssignmentScreenUploading;

  /// No description provided for @teacherClassroomAddAssignmentScreenAttachFiles.
  ///
  /// In en, this message translates to:
  /// **'Attach files'**
  String get teacherClassroomAddAssignmentScreenAttachFiles;

  /// No description provided for @teacherClassroomAddAssignmentScreenAddMoreFiles.
  ///
  /// In en, this message translates to:
  /// **'Add more files'**
  String get teacherClassroomAddAssignmentScreenAddMoreFiles;

  /// No description provided for @diplomasScreenCertificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get diplomasScreenCertificate;

  /// No description provided for @diplomasScreenIssuedDate.
  ///
  /// In en, this message translates to:
  /// **'Issued {date}'**
  String diplomasScreenIssuedDate(String date);

  /// No description provided for @diplomasScreenNoCertificatesReceived.
  ///
  /// In en, this message translates to:
  /// **'No certificates received yet.'**
  String get diplomasScreenNoCertificatesReceived;

  /// No description provided for @diplomasScreenFileCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} file} other{{count} files}}'**
  String diplomasScreenFileCount(int count);

  /// No description provided for @gradesScreenOutOf100.
  ///
  /// In en, this message translates to:
  /// **'/ 100'**
  String get gradesScreenOutOf100;

  /// No description provided for @gradesScreenShowMore.
  ///
  /// In en, this message translates to:
  /// **'Show {count} more grade{count, plural, =1{} other{s}}'**
  String gradesScreenShowMore(int count);

  /// No description provided for @gradesScreenShowLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get gradesScreenShowLess;

  /// No description provided for @gradesScreenScoreOutOf100.
  ///
  /// In en, this message translates to:
  /// **'{score} / 100'**
  String gradesScreenScoreOutOf100(String score);

  /// No description provided for @adminSchoolSettingsStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get adminSchoolSettingsStart;

  /// No description provided for @adminSchoolSettingsEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get adminSchoolSettingsEnd;

  /// No description provided for @adminExportScreenEachUserAlone.
  ///
  /// In en, this message translates to:
  /// **'Each user alone'**
  String get adminExportScreenEachUserAlone;

  /// No description provided for @adminExportScreenEachUserAloneOn.
  ///
  /// In en, this message translates to:
  /// **'One full page per user, big readable card layout.'**
  String get adminExportScreenEachUserAloneOn;

  /// No description provided for @adminExportScreenEachUserAloneOff.
  ///
  /// In en, this message translates to:
  /// **'Compact table — every user is a row.'**
  String get adminExportScreenEachUserAloneOff;

  /// No description provided for @adminExportScreenSeparateFilesOn.
  ///
  /// In en, this message translates to:
  /// **'Separate PDF per user'**
  String get adminExportScreenSeparateFilesOn;

  /// No description provided for @adminExportScreenSeparateFilesOff.
  ///
  /// In en, this message translates to:
  /// **'Single PDF, one page per user'**
  String get adminExportScreenSeparateFilesOff;

  /// No description provided for @adminExportScreenSeparateFilesOnDesc.
  ///
  /// In en, this message translates to:
  /// **'You\'ll share {count} PDF file(s) at once — each user gets their own.'**
  String adminExportScreenSeparateFilesOnDesc(int count);

  /// No description provided for @adminExportScreenSeparateFilesOffDesc.
  ///
  /// In en, this message translates to:
  /// **'Everyone in one PDF, each on their own page.'**
  String get adminExportScreenSeparateFilesOffDesc;

  /// No description provided for @adminSubjectDetailScreenSchoolSettings.
  ///
  /// In en, this message translates to:
  /// **'School Settings'**
  String get adminSubjectDetailScreenSchoolSettings;

  /// No description provided for @adminSubjectDetailScreenNewSubject.
  ///
  /// In en, this message translates to:
  /// **'New subject'**
  String get adminSubjectDetailScreenNewSubject;

  /// No description provided for @adminSubjectDetailScreenLangEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get adminSubjectDetailScreenLangEnglish;

  /// No description provided for @adminSubjectDetailScreenLangArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get adminSubjectDetailScreenLangArabic;

  /// No description provided for @adminSubjectDetailScreenLangHebrew.
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get adminSubjectDetailScreenLangHebrew;

  /// No description provided for @adminSubjectDetailScreenLangFrench.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get adminSubjectDetailScreenLangFrench;

  /// No description provided for @adminSubjectDetailScreenLangRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get adminSubjectDetailScreenLangRussian;

  /// No description provided for @adminSubjectDetailScreenColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get adminSubjectDetailScreenColor;

  /// No description provided for @parentHomeScreenGreetingFallback.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get parentHomeScreenGreetingFallback;

  /// No description provided for @parentHomeScreenChildrenLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your children: {error}'**
  String parentHomeScreenChildrenLoadError(String error);

  /// No description provided for @parentHomeScreenMaterials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get parentHomeScreenMaterials;

  /// No description provided for @cmCodeBlockCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get cmCodeBlockCopied;

  /// No description provided for @cmCodeBlockCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get cmCodeBlockCopy;

  /// No description provided for @phoneFieldCountryCode.
  ///
  /// In en, this message translates to:
  /// **'Country code'**
  String get phoneFieldCountryCode;

  /// No description provided for @teacherClassroomAddMeetingScreenEndDateDefault.
  ///
  /// In en, this message translates to:
  /// **'End date defaults to start date'**
  String get teacherClassroomAddMeetingScreenEndDateDefault;

  /// No description provided for @teacherAddMaterialScreenLinkHint.
  ///
  /// In en, this message translates to:
  /// **'https://…'**
  String get teacherAddMaterialScreenLinkHint;

  /// No description provided for @teacherAddMaterialScreenLinkFallback.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get teacherAddMaterialScreenLinkFallback;

  /// No description provided for @teacherAddMaterialScreenFileFallback.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get teacherAddMaterialScreenFileFallback;

  /// No description provided for @teacherCreateDiplomaScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Issue Certificate'**
  String get teacherCreateDiplomaScreenTitle;

  /// No description provided for @teacherCreateDiplomaScreenGradePrefix.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get teacherCreateDiplomaScreenGradePrefix;

  /// No description provided for @teacherCreateDiplomaScreenAttachFiles.
  ///
  /// In en, this message translates to:
  /// **'Attach certificate file(s)'**
  String get teacherCreateDiplomaScreenAttachFiles;

  /// No description provided for @teacherCreateDiplomaScreenAddMoreFiles.
  ///
  /// In en, this message translates to:
  /// **'Add more files'**
  String get teacherCreateDiplomaScreenAddMoreFiles;

  /// No description provided for @teacherAssignmentDetailScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get teacherAssignmentDetailScreenTitle;

  /// No description provided for @teacherAssignmentDetailScreenNoSubmissions.
  ///
  /// In en, this message translates to:
  /// **'No submissions yet'**
  String get teacherAssignmentDetailScreenNoSubmissions;

  /// No description provided for @teacherAssignmentDetailScreenSubmissionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} submission{count, plural, =1{} other{s}}'**
  String teacherAssignmentDetailScreenSubmissionCount(int count);

  /// No description provided for @teacherAssignmentDetailScreenGradedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} graded'**
  String teacherAssignmentDetailScreenGradedCount(int count);

  /// No description provided for @teacherAssignmentDetailScreenStudentFallback.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get teacherAssignmentDetailScreenStudentFallback;

  /// No description provided for @teacherAssignmentDetailScreenSubmittedOn.
  ///
  /// In en, this message translates to:
  /// **'Submitted {date}'**
  String teacherAssignmentDetailScreenSubmittedOn(String date);

  /// No description provided for @teacherAddAssignmentScreenGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade {count}'**
  String teacherAddAssignmentScreenGradeLabel(int count);

  /// No description provided for @teacherAddAssignmentScreenStudentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} student{count, plural, one {} other {s}}'**
  String teacherAddAssignmentScreenStudentCount(int count);

  /// No description provided for @teacherAddAssignmentScreenMembersWillReceive.
  ///
  /// In en, this message translates to:
  /// **'{count} member{count, plural, one {} other {s}} will receive this'**
  String teacherAddAssignmentScreenMembersWillReceive(int count);

  /// No description provided for @teacherAddAssignmentScreenNoDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get teacherAddAssignmentScreenNoDueDate;

  /// No description provided for @teacherAddAssignmentScreenMaterialFallback.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get teacherAddAssignmentScreenMaterialFallback;

  /// No description provided for @teacherAddAssignmentScreenSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String teacherAddAssignmentScreenSelectedCount(int count);

  /// No description provided for @teacherClassroomsScreenGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade {grade}'**
  String teacherClassroomsScreenGradeLabel(int grade);

  /// No description provided for @teacherClassroomsScreenNewClassroom.
  ///
  /// In en, this message translates to:
  /// **'New Classroom'**
  String get teacherClassroomsScreenNewClassroom;

  /// No description provided for @assignmentsScreenAlreadyHandedIn.
  ///
  /// In en, this message translates to:
  /// **'You have already handed in this assignment.'**
  String get assignmentsScreenAlreadyHandedIn;

  /// No description provided for @assignmentsScreenAddNoteOrFiles.
  ///
  /// In en, this message translates to:
  /// **'Add a note or attach files, then press Hand in.'**
  String get assignmentsScreenAddNoteOrFiles;

  /// No description provided for @assignmentsScreenGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade: {grade}'**
  String assignmentsScreenGradeLabel(String grade);

  /// No description provided for @assignmentsScreenFeedbackLabel.
  ///
  /// In en, this message translates to:
  /// **'Feedback: {feedback}'**
  String assignmentsScreenFeedbackLabel(String feedback);

  /// No description provided for @assignmentsScreenReturnedForResolution.
  ///
  /// In en, this message translates to:
  /// **'Returned for re-solution'**
  String get assignmentsScreenReturnedForResolution;

  /// No description provided for @assignmentsScreenAttachFile.
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get assignmentsScreenAttachFile;

  /// No description provided for @assignmentsScreenAddMoreFiles.
  ///
  /// In en, this message translates to:
  /// **'Add more files'**
  String get assignmentsScreenAddMoreFiles;

  /// No description provided for @assignmentsScreenHandingIn.
  ///
  /// In en, this message translates to:
  /// **'Handing in…'**
  String get assignmentsScreenHandingIn;

  /// No description provided for @assignmentsScreenHandIn.
  ///
  /// In en, this message translates to:
  /// **'Hand in'**
  String get assignmentsScreenHandIn;

  /// No description provided for @examDetailScreenCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load this exam right now.'**
  String get examDetailScreenCouldNotLoad;

  /// No description provided for @adminEditUserRoleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get adminEditUserRoleStudent;

  /// No description provided for @adminEditUserRoleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get adminEditUserRoleTeacher;

  /// No description provided for @adminEditUserRoleSecretary.
  ///
  /// In en, this message translates to:
  /// **'Secretary'**
  String get adminEditUserRoleSecretary;

  /// No description provided for @adminEditUserRoleParent.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get adminEditUserRoleParent;

  /// No description provided for @adminEditUserRoleAdmin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get adminEditUserRoleAdmin;

  /// No description provided for @adminEditUserCohortMemberCount.
  ///
  /// In en, this message translates to:
  /// **'Member of {count} cohort{count, plural, one{} other{s}}.'**
  String adminEditUserCohortMemberCount(int count);

  /// No description provided for @adminEditUserSearchStudents.
  ///
  /// In en, this message translates to:
  /// **'Search students…'**
  String get adminEditUserSearchStudents;

  /// No description provided for @adminEditUserGradeSuffix.
  ///
  /// In en, this message translates to:
  /// **'(Grade {grade})'**
  String adminEditUserGradeSuffix(int grade);

  /// No description provided for @solutionAssetPreviewSheetPdfDocument.
  ///
  /// In en, this message translates to:
  /// **'PDF document'**
  String get solutionAssetPreviewSheetPdfDocument;

  /// No description provided for @solutionAssetPreviewSheetUnableToPreview.
  ///
  /// In en, this message translates to:
  /// **'Unable to preview PDF.'**
  String get solutionAssetPreviewSheetUnableToPreview;

  /// No description provided for @classroomDetailSectionHeader.
  ///
  /// In en, this message translates to:
  /// **'{title} ({count})'**
  String classroomDetailSectionHeader(String title, int count);

  /// No description provided for @classroomDetailTeacherSection.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get classroomDetailTeacherSection;

  /// No description provided for @classroomDetailStudentsSection.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get classroomDetailStudentsSection;

  /// No description provided for @classroomDetailClassroomFallback.
  ///
  /// In en, this message translates to:
  /// **'Classroom'**
  String get classroomDetailClassroomFallback;

  /// No description provided for @classroomDetailUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get classroomDetailUntitled;

  /// No description provided for @typingDotsPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get typingDotsPaused;

  /// No description provided for @cmAiMessageStartPracticeSession.
  ///
  /// In en, this message translates to:
  /// **'Start practice session'**
  String get cmAiMessageStartPracticeSession;

  /// No description provided for @cmAiMessageQuestionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String cmAiMessageQuestionCount(int count);

  /// No description provided for @cmAiMessageDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get cmAiMessageDifficultyEasy;

  /// No description provided for @cmAiMessageDifficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get cmAiMessageDifficultyHard;

  /// No description provided for @cmAiMessageDifficultyOlympiad.
  ///
  /// In en, this message translates to:
  /// **'Olympiad'**
  String get cmAiMessageDifficultyOlympiad;

  /// No description provided for @cmAiMessageDifficultyAdaptive.
  ///
  /// In en, this message translates to:
  /// **'Adaptive'**
  String get cmAiMessageDifficultyAdaptive;

  /// No description provided for @cmAiMessageDifficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get cmAiMessageDifficultyMedium;

  /// No description provided for @teacherCreateFormScreenParagraphType.
  ///
  /// In en, this message translates to:
  /// **'Paragraph'**
  String get teacherCreateFormScreenParagraphType;

  /// No description provided for @teacherCreateFormScreenMultipleChoiceType.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice'**
  String get teacherCreateFormScreenMultipleChoiceType;

  /// No description provided for @teacherCreateFormScreenCheckboxesType.
  ///
  /// In en, this message translates to:
  /// **'Checkboxes'**
  String get teacherCreateFormScreenCheckboxesType;

  /// No description provided for @teacherCreateFormScreenRatingType.
  ///
  /// In en, this message translates to:
  /// **'Rating (1–5)'**
  String get teacherCreateFormScreenRatingType;

  /// No description provided for @teacherCreateFormScreenLinearScaleType.
  ///
  /// In en, this message translates to:
  /// **'Linear scale'**
  String get teacherCreateFormScreenLinearScaleType;

  /// No description provided for @teacherCreateFormScreenDropdownType.
  ///
  /// In en, this message translates to:
  /// **'Dropdown'**
  String get teacherCreateFormScreenDropdownType;

  /// No description provided for @teacherCreateFormScreenDateType.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get teacherCreateFormScreenDateType;

  /// No description provided for @teacherCohortsScreenSingleGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade {grade}'**
  String teacherCohortsScreenSingleGrade(int grade);

  /// No description provided for @teacherCohortsScreenGradeRange.
  ///
  /// In en, this message translates to:
  /// **'Grade {from}-{to}'**
  String teacherCohortsScreenGradeRange(int from, int to);

  /// No description provided for @teacherCohortsScreenMultiGrade.
  ///
  /// In en, this message translates to:
  /// **'Grades {grades}'**
  String teacherCohortsScreenMultiGrade(String grades);

  /// No description provided for @teacherAddGradeScreenFailedCreateRecord.
  ///
  /// In en, this message translates to:
  /// **'Failed to create grade record.'**
  String get teacherAddGradeScreenFailedCreateRecord;

  /// No description provided for @phoneFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phoneFieldLabel;

  /// No description provided for @phoneFieldHelper.
  ///
  /// In en, this message translates to:
  /// **'Used for SMS password reset'**
  String get phoneFieldHelper;

  /// No description provided for @gradesScreenCouldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load grades.'**
  String get gradesScreenCouldNotLoad;

  /// No description provided for @gradesScreenTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Check your connection.'**
  String get gradesScreenTimeout;

  /// No description provided for @gradesScreenNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection. Pull to retry.'**
  String get gradesScreenNoConnection;

  /// No description provided for @examDetailScreenCountdownPassed.
  ///
  /// In en, this message translates to:
  /// **'This exam has passed'**
  String get examDetailScreenCountdownPassed;

  /// No description provided for @examDetailScreenCountdownToday.
  ///
  /// In en, this message translates to:
  /// **'It\'s today!'**
  String get examDetailScreenCountdownToday;

  /// No description provided for @teacherCreateDiplomaScreenDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Certificate of Achievement'**
  String get teacherCreateDiplomaScreenDefaultTitle;

  /// No description provided for @teacherMaterialAddedBy.
  ///
  /// In en, this message translates to:
  /// **'Added by {name}'**
  String teacherMaterialAddedBy(String name);

  /// No description provided for @teacherMaterialAttachedTo.
  ///
  /// In en, this message translates to:
  /// **'Attached to {period}'**
  String teacherMaterialAttachedTo(String period);

  /// No description provided for @adminPeopleAddMany.
  ///
  /// In en, this message translates to:
  /// **'Add many'**
  String get adminPeopleAddMany;

  /// No description provided for @adminAddManyPasteNames.
  ///
  /// In en, this message translates to:
  /// **'Paste names'**
  String get adminAddManyPasteNames;

  /// No description provided for @adminAddManyApplyRole.
  ///
  /// In en, this message translates to:
  /// **'Set role for all'**
  String get adminAddManyApplyRole;

  /// No description provided for @adminAddManyApplyGrade.
  ///
  /// In en, this message translates to:
  /// **'Set grade for all'**
  String get adminAddManyApplyGrade;

  /// No description provided for @adminAddManyParentLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get adminAddManyParentLabel;

  /// No description provided for @adminAddManyParentNone.
  ///
  /// In en, this message translates to:
  /// **'No parent'**
  String get adminAddManyParentNone;

  /// No description provided for @adminAddManyAddParent.
  ///
  /// In en, this message translates to:
  /// **'Add parent'**
  String get adminAddManyAddParent;

  /// No description provided for @adminAddManyCreateParentGeneric.
  ///
  /// In en, this message translates to:
  /// **'Create new parent'**
  String get adminAddManyCreateParentGeneric;

  /// No description provided for @adminAddManyParentInBatch.
  ///
  /// In en, this message translates to:
  /// **'New parents in this list'**
  String get adminAddManyParentInBatch;

  /// No description provided for @adminAddManyParentExisting.
  ///
  /// In en, this message translates to:
  /// **'Existing parents'**
  String get adminAddManyParentExisting;

  /// No description provided for @adminAddManySearchParents.
  ///
  /// In en, this message translates to:
  /// **'Search parents…'**
  String get adminAddManySearchParents;

  /// No description provided for @adminAddManyNoParentsYet.
  ///
  /// In en, this message translates to:
  /// **'No matching parents — type a name above to create one'**
  String get adminAddManyNoParentsYet;

  /// No description provided for @adminAddManyUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username already taken'**
  String get adminAddManyUsernameTaken;

  /// No description provided for @adminAddManyUsernameDupe.
  ///
  /// In en, this message translates to:
  /// **'Duplicate username in this list'**
  String get adminAddManyUsernameDupe;

  /// No description provided for @adminUsernameAvailable.
  ///
  /// In en, this message translates to:
  /// **'Username is available'**
  String get adminUsernameAvailable;

  /// No description provided for @adminUsernameInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Use 3+ letters, digits, or . _ -'**
  String get adminUsernameInvalidFormat;

  /// No description provided for @adminUsernameSuggestionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Available suggestions — tap to use:'**
  String get adminUsernameSuggestionsLabel;

  /// No description provided for @adminAddManyCreateParent.
  ///
  /// In en, this message translates to:
  /// **'Create new parent \"{name}\"'**
  String adminAddManyCreateParent(String name);

  /// No description provided for @adminAddManyPastedRows.
  ///
  /// In en, this message translates to:
  /// **'Added {count} rows'**
  String adminAddManyPastedRows(int count);

  /// No description provided for @teacherCreateClassroomNoStudentsInCohort.
  ///
  /// In en, this message translates to:
  /// **'No students in the selected cohort yet.'**
  String get teacherCreateClassroomNoStudentsInCohort;

  /// No description provided for @audienceSummaryResolving.
  ///
  /// In en, this message translates to:
  /// **'Finding students…'**
  String get audienceSummaryResolving;

  /// No description provided for @audienceSummaryCount.
  ///
  /// In en, this message translates to:
  /// **'{count} will see this'**
  String audienceSummaryCount(int count);

  /// No description provided for @audienceSummaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No students match this audience.'**
  String get audienceSummaryEmpty;

  /// No description provided for @audienceSummaryRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore {count} removed'**
  String audienceSummaryRestore(int count);

  /// No description provided for @scheduleUpcomingExam.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Exam'**
  String get scheduleUpcomingExam;

  /// No description provided for @scheduleNoUpcomingExams.
  ///
  /// In en, this message translates to:
  /// **'No upcoming exams'**
  String get scheduleNoUpcomingExams;

  /// No description provided for @navCertificates.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get navCertificates;

  /// No description provided for @averagesDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get averagesDelete;

  /// No description provided for @averagesFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get averagesFieldTitle;

  /// No description provided for @averagesSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get averagesSave;

  /// No description provided for @certificatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Certificates'**
  String get certificatesTitle;

  /// No description provided for @certHomeroom.
  ///
  /// In en, this message translates to:
  /// **'Class (homeroom)'**
  String get certHomeroom;

  /// No description provided for @certStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get certStudent;

  /// No description provided for @certDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Name on certificate'**
  String get certDisplayName;

  /// No description provided for @certNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get certNationalId;

  /// No description provided for @certHomeroomTeacher.
  ///
  /// In en, this message translates to:
  /// **'Homeroom teacher'**
  String get certHomeroomTeacher;

  /// No description provided for @certPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get certPrincipal;

  /// No description provided for @certPublisherNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get certPublisherNote;

  /// No description provided for @certSemesterWeights.
  ///
  /// In en, this message translates to:
  /// **'Semester weights'**
  String get certSemesterWeights;

  /// No description provided for @certLanguage.
  ///
  /// In en, this message translates to:
  /// **'Certificate language'**
  String get certLanguage;

  /// No description provided for @certGenerate.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get certGenerate;

  /// No description provided for @certWeightsMustBe100.
  ///
  /// In en, this message translates to:
  /// **'Semester weights must total 100%.'**
  String get certWeightsMustBe100;

  /// No description provided for @certSelectStudentFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a student first.'**
  String get certSelectStudentFirst;

  /// No description provided for @certSaved.
  ///
  /// In en, this message translates to:
  /// **'Certificate generated.'**
  String get certSaved;

  /// No description provided for @certSaveAndPublish.
  ///
  /// In en, this message translates to:
  /// **'Save & publish'**
  String get certSaveAndPublish;

  /// No description provided for @certSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save as draft'**
  String get certSaveDraft;

  /// No description provided for @examGradesPublished.
  ///
  /// In en, this message translates to:
  /// **'Grades published to students.'**
  String get examGradesPublished;

  /// No description provided for @examGradesPublishedShort.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get examGradesPublishedShort;

  /// No description provided for @examRepublish.
  ///
  /// In en, this message translates to:
  /// **'Republish'**
  String get examRepublish;

  /// No description provided for @certPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview PDF'**
  String get certPreview;

  /// No description provided for @certPublished.
  ///
  /// In en, this message translates to:
  /// **'Published to the student.'**
  String get certPublished;

  /// No description provided for @certDraftSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved as draft.'**
  String get certDraftSaved;

  /// No description provided for @certPublishing.
  ///
  /// In en, this message translates to:
  /// **'Publishing…'**
  String get certPublishing;

  /// No description provided for @certDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get certDownload;

  /// No description provided for @certNoneYet.
  ///
  /// In en, this message translates to:
  /// **'No certificates yet.'**
  String get certNoneYet;

  /// No description provided for @certMine.
  ///
  /// In en, this message translates to:
  /// **'My certificates'**
  String get certMine;

  /// No description provided for @certNoHomeroom.
  ///
  /// In en, this message translates to:
  /// **'You are not a homeroom teacher of any class yet.'**
  String get certNoHomeroom;

  /// No description provided for @certGrin.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get certGrin;

  /// No description provided for @certPrintAll.
  ///
  /// In en, this message translates to:
  /// **'Print all'**
  String get certPrintAll;

  /// No description provided for @certSelectCohortToPrint.
  ///
  /// In en, this message translates to:
  /// **'Select a class to print all its certificates.'**
  String get certSelectCohortToPrint;

  /// No description provided for @certEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit certificate'**
  String get certEditTitle;

  /// No description provided for @certPdfAnnualCertificate.
  ///
  /// In en, this message translates to:
  /// **'Annual Certificate'**
  String get certPdfAnnualCertificate;

  /// No description provided for @certPdfSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get certPdfSubject;

  /// No description provided for @certPdfFinal.
  ///
  /// In en, this message translates to:
  /// **'Final'**
  String get certPdfFinal;

  /// No description provided for @certPdfOverall.
  ///
  /// In en, this message translates to:
  /// **'General Average'**
  String get certPdfOverall;

  /// No description provided for @certPdfAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get certPdfAverage;

  /// No description provided for @certPdfAbsences.
  ///
  /// In en, this message translates to:
  /// **'Absences'**
  String get certPdfAbsences;

  /// No description provided for @certPdfLateness.
  ///
  /// In en, this message translates to:
  /// **'Lateness'**
  String get certPdfLateness;

  /// No description provided for @certPdfHomeroomTeacher.
  ///
  /// In en, this message translates to:
  /// **'Homeroom teacher'**
  String get certPdfHomeroomTeacher;

  /// No description provided for @certPdfPrincipal.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get certPdfPrincipal;

  /// No description provided for @certPdfNationalId.
  ///
  /// In en, this message translates to:
  /// **'ID No.'**
  String get certPdfNationalId;

  /// No description provided for @certPdfDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get certPdfDate;

  /// No description provided for @certPdfGeneratedBy.
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get certPdfGeneratedBy;

  /// No description provided for @certPdfName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get certPdfName;

  /// No description provided for @certPdfClass.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get certPdfClass;

  /// No description provided for @adminEditUserNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get adminEditUserNationalId;

  /// No description provided for @teacherCohortsScreenNoStudentsToAdd.
  ///
  /// In en, this message translates to:
  /// **'All students are already in this class.'**
  String get teacherCohortsScreenNoStudentsToAdd;

  /// No description provided for @gradeWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight on average (%)'**
  String get gradeWeightLabel;

  /// No description provided for @gradeWeightHint.
  ///
  /// In en, this message translates to:
  /// **'Optional — set what % this counts toward the subject average, or leave blank to set later.'**
  String get gradeWeightHint;

  /// No description provided for @gradeSemesterLabel.
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get gradeSemesterLabel;

  /// No description provided for @gradeSemesterAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto (by date)'**
  String get gradeSemesterAuto;

  /// No description provided for @gradeDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete grade'**
  String get gradeDeleteTooltip;

  /// No description provided for @gradeDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete grade'**
  String get gradeDeleteTitle;

  /// No description provided for @gradeDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete the grade for “{title}”?'**
  String gradeDeleteConfirm(String title);

  /// No description provided for @cohortHomeroomLabel.
  ///
  /// In en, this message translates to:
  /// **'Homeroom class'**
  String get cohortHomeroomLabel;

  /// No description provided for @cohortHomeroomHint.
  ///
  /// In en, this message translates to:
  /// **'Assign a homeroom teacher for this class.'**
  String get cohortHomeroomHint;

  /// No description provided for @cohortHomeroomTeacher.
  ///
  /// In en, this message translates to:
  /// **'Homeroom teacher'**
  String get cohortHomeroomTeacher;

  /// No description provided for @adminPrincipalLabel.
  ///
  /// In en, this message translates to:
  /// **'Principal'**
  String get adminPrincipalLabel;

  /// No description provided for @adminPrincipalHint.
  ///
  /// In en, this message translates to:
  /// **'This admin is a principal; certificates auto-fill their name by the student’s grade.'**
  String get adminPrincipalHint;

  /// No description provided for @adminPrincipalGrades.
  ///
  /// In en, this message translates to:
  /// **'Principal for grades'**
  String get adminPrincipalGrades;

  /// No description provided for @certPdfTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get certPdfTeacher;

  /// No description provided for @gradesHubSummary.
  ///
  /// In en, this message translates to:
  /// **'{subjects} subjects · {students} students'**
  String gradesHubSummary(int subjects, int students);

  /// No description provided for @gradesHubSearchSubjects.
  ///
  /// In en, this message translates to:
  /// **'Search subjects'**
  String get gradesHubSearchSubjects;

  /// No description provided for @gradesHubEmpty.
  ///
  /// In en, this message translates to:
  /// **'No grades yet. Add a grade and the subject will appear here.'**
  String get gradesHubEmpty;

  /// No description provided for @gradesHubStudentCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 student} other{{count} students}}'**
  String gradesHubStudentCount(int count);

  /// No description provided for @gradesSubjectStudentsTab.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get gradesSubjectStudentsTab;

  /// No description provided for @gradesSubjectGradesTab.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get gradesSubjectGradesTab;

  /// No description provided for @gradesSubjectNoGrades.
  ///
  /// In en, this message translates to:
  /// **'No grades in this subject yet.'**
  String get gradesSubjectNoGrades;

  /// No description provided for @gradesPublishedShort.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get gradesPublishedShort;

  /// No description provided for @gradesDraftShort.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get gradesDraftShort;

  /// No description provided for @gradesPublishTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish “{title}”'**
  String gradesPublishTitle(Object title);

  /// No description provided for @gradesUnpublishTitle.
  ///
  /// In en, this message translates to:
  /// **'Unpublish “{title}”'**
  String gradesUnpublishTitle(Object title);

  /// No description provided for @gradesPublishAction.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get gradesPublishAction;

  /// No description provided for @gradesUnpublishAction.
  ///
  /// In en, this message translates to:
  /// **'Unpublish'**
  String get gradesUnpublishAction;

  /// No description provided for @gradesPublishedToast.
  ///
  /// In en, this message translates to:
  /// **'Grade published — students can now see it.'**
  String get gradesPublishedToast;

  /// No description provided for @gradesUnpublishedToast.
  ///
  /// In en, this message translates to:
  /// **'Grade unpublished — hidden from students.'**
  String get gradesUnpublishedToast;

  /// No description provided for @navGradeScales.
  ///
  /// In en, this message translates to:
  /// **'Grade Scales'**
  String get navGradeScales;

  /// No description provided for @gradeScaleAdd.
  ///
  /// In en, this message translates to:
  /// **'Add grade scale'**
  String get gradeScaleAdd;

  /// No description provided for @gradeScaleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit grade scale'**
  String get gradeScaleEdit;

  /// No description provided for @gradeScaleDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete grade scale?'**
  String get gradeScaleDeleteTitle;

  /// No description provided for @gradeScaleDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”? Assessments already graded on it keep their labels.'**
  String gradeScaleDeleteConfirm(Object name);

  /// No description provided for @gradeScaleEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No grade scales yet'**
  String get gradeScaleEmptyTitle;

  /// No description provided for @gradeScaleEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Create a letter or word scale (e.g. A, A+, B) for younger grades. Teachers grading those grades pick a label instead of a number.'**
  String get gradeScaleEmptyHint;

  /// No description provided for @gradeScaleAllGrades.
  ///
  /// In en, this message translates to:
  /// **'Applies to all grades'**
  String get gradeScaleAllGrades;

  /// No description provided for @gradeScaleAppliesTo.
  ///
  /// In en, this message translates to:
  /// **'Grades {grades}'**
  String gradeScaleAppliesTo(Object grades);

  /// No description provided for @gradeScaleNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Scale name'**
  String get gradeScaleNameLabel;

  /// No description provided for @gradeScaleNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Letter grades'**
  String get gradeScaleNameHint;

  /// No description provided for @gradeScaleNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a scale name.'**
  String get gradeScaleNameRequired;

  /// No description provided for @gradeScaleGradeLevels.
  ///
  /// In en, this message translates to:
  /// **'Applies to grades'**
  String get gradeScaleGradeLevels;

  /// No description provided for @gradeScaleGradeLevelsHint.
  ///
  /// In en, this message translates to:
  /// **'Leave none selected to apply to all grades.'**
  String get gradeScaleGradeLevelsHint;

  /// No description provided for @gradeScaleLabels.
  ///
  /// In en, this message translates to:
  /// **'Labels'**
  String get gradeScaleLabels;

  /// No description provided for @gradeScaleLabelsHint.
  ///
  /// In en, this message translates to:
  /// **'Add each label (e.g. A+) with an optional number (0–100) used for averages.'**
  String get gradeScaleLabelsHint;

  /// No description provided for @gradeScaleLabelText.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get gradeScaleLabelText;

  /// No description provided for @gradeScaleLabelValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get gradeScaleLabelValue;

  /// No description provided for @gradeScaleAddLabel.
  ///
  /// In en, this message translates to:
  /// **'Add label'**
  String get gradeScaleAddLabel;

  /// No description provided for @gradeScaleNeedTwoLabels.
  ///
  /// In en, this message translates to:
  /// **'Add at least two labels.'**
  String get gradeScaleNeedTwoLabels;

  /// No description provided for @gradeScalePickLabel.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get gradeScalePickLabel;

  /// No description provided for @gradeScaleUseScale.
  ///
  /// In en, this message translates to:
  /// **'Grade scale'**
  String get gradeScaleUseScale;

  /// No description provided for @gradeScaleNumeric.
  ///
  /// In en, this message translates to:
  /// **'Number (0–{max})'**
  String gradeScaleNumeric(Object max);

  /// No description provided for @accountSwitcherTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountSwitcherTitle;

  /// No description provided for @accountAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get accountAddAccount;

  /// No description provided for @accountSignOutThis.
  ///
  /// In en, this message translates to:
  /// **'Sign out this account'**
  String get accountSignOutThis;

  /// No description provided for @averagesManageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Manage averages'**
  String get averagesManageTooltip;

  /// No description provided for @averagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Averages'**
  String get averagesTitle;

  /// No description provided for @averagesAdd.
  ///
  /// In en, this message translates to:
  /// **'Add average'**
  String get averagesAdd;

  /// No description provided for @averagesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete average'**
  String get averagesDeleteTitle;

  /// No description provided for @averagesDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? This cannot be undone.'**
  String averagesDeleteConfirm(Object title);

  /// No description provided for @averagesCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get averagesCancel;

  /// No description provided for @averagesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No averages yet'**
  String get averagesEmptyTitle;

  /// No description provided for @averagesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Add average\" to create a weighted grade formula for a subject.'**
  String get averagesEmptyBody;

  /// No description provided for @averagesFullYear.
  ///
  /// In en, this message translates to:
  /// **'Full year'**
  String get averagesFullYear;

  /// No description provided for @averagesSemesterN.
  ///
  /// In en, this message translates to:
  /// **'Semester {n}'**
  String averagesSemesterN(Object n);

  /// No description provided for @averagesFormatChip.
  ///
  /// In en, this message translates to:
  /// **'Format {index}: {total}%'**
  String averagesFormatChip(Object index, Object total);

  /// No description provided for @averagesNoStudents.
  ///
  /// In en, this message translates to:
  /// **'No students to compute.'**
  String get averagesNoStudents;

  /// No description provided for @averagesFormatN.
  ///
  /// In en, this message translates to:
  /// **'Format {n}'**
  String averagesFormatN(Object n);

  /// No description provided for @averagesErrTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title.'**
  String get averagesErrTitle;

  /// No description provided for @averagesErrSubject.
  ///
  /// In en, this message translates to:
  /// **'Choose a subject.'**
  String get averagesErrSubject;

  /// No description provided for @averagesErrCohort.
  ///
  /// In en, this message translates to:
  /// **'Choose a cohort.'**
  String get averagesErrCohort;

  /// No description provided for @averagesErrNoFormat.
  ///
  /// In en, this message translates to:
  /// **'Add at least one format.'**
  String get averagesErrNoFormat;

  /// No description provided for @averagesErrFormatNoGrade.
  ///
  /// In en, this message translates to:
  /// **'Format {n}: pick at least one grade.'**
  String averagesErrFormatNoGrade(Object n);

  /// No description provided for @averagesErrFormatSum.
  ///
  /// In en, this message translates to:
  /// **'Format {n}: weights must sum to 100 (now {total}%).'**
  String averagesErrFormatSum(Object n, Object total);

  /// No description provided for @averagesNew.
  ///
  /// In en, this message translates to:
  /// **'New average'**
  String get averagesNew;

  /// No description provided for @averagesEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit average'**
  String get averagesEdit;

  /// No description provided for @averagesLabelSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get averagesLabelSubject;

  /// No description provided for @averagesHintSubject.
  ///
  /// In en, this message translates to:
  /// **'Choose a subject'**
  String get averagesHintSubject;

  /// No description provided for @averagesLabelCohort.
  ///
  /// In en, this message translates to:
  /// **'Cohort'**
  String get averagesLabelCohort;

  /// No description provided for @averagesHintCohort.
  ///
  /// In en, this message translates to:
  /// **'Choose a cohort'**
  String get averagesHintCohort;

  /// No description provided for @averagesLabelUnits.
  ///
  /// In en, this message translates to:
  /// **'Units (optional)'**
  String get averagesLabelUnits;

  /// No description provided for @averagesFormats.
  ///
  /// In en, this message translates to:
  /// **'Formats'**
  String get averagesFormats;

  /// No description provided for @averagesFormatsHelp.
  ///
  /// In en, this message translates to:
  /// **'Each format\'s weights must sum to 100%. The best-scoring format is used per student.'**
  String get averagesFormatsHelp;

  /// No description provided for @averagesAddFormat.
  ///
  /// In en, this message translates to:
  /// **'Add format'**
  String get averagesAddFormat;

  /// No description provided for @averagesLabelFormatLabel.
  ///
  /// In en, this message translates to:
  /// **'Format label (optional)'**
  String get averagesLabelFormatLabel;

  /// No description provided for @averagesAddGrade.
  ///
  /// In en, this message translates to:
  /// **'Add grade'**
  String get averagesAddGrade;

  /// No description provided for @averagesTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {total}%'**
  String averagesTotal(Object total);

  /// No description provided for @averagesLabelGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get averagesLabelGrade;

  /// No description provided for @averagesHintPickFirst.
  ///
  /// In en, this message translates to:
  /// **'Pick subject & cohort first'**
  String get averagesHintPickFirst;

  /// No description provided for @averagesHintGrade.
  ///
  /// In en, this message translates to:
  /// **'Choose a grade'**
  String get averagesHintGrade;

  /// No description provided for @adminInsightsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search students by name…'**
  String get adminInsightsSearchHint;

  /// No description provided for @adminInsightsNoStudents.
  ///
  /// In en, this message translates to:
  /// **'No students found.'**
  String get adminInsightsNoStudents;

  /// No description provided for @adminInsightsNoGrades.
  ///
  /// In en, this message translates to:
  /// **'No grades recorded yet.'**
  String get adminInsightsNoGrades;

  /// No description provided for @gradesEditGradeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit grade'**
  String get gradesEditGradeTitle;

  /// No description provided for @gradeFormatN.
  ///
  /// In en, this message translates to:
  /// **'Format {n}'**
  String gradeFormatN(String n);

  /// No description provided for @gradeAddFormat.
  ///
  /// In en, this message translates to:
  /// **'Add format'**
  String get gradeAddFormat;

  /// No description provided for @gradesBreakdownAverage.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get gradesBreakdownAverage;

  /// No description provided for @adminPrincipalRangeFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get adminPrincipalRangeFrom;

  /// No description provided for @adminPrincipalRangeTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get adminPrincipalRangeTo;

  /// No description provided for @adminPrincipalAddRange.
  ///
  /// In en, this message translates to:
  /// **'Add range'**
  String get adminPrincipalAddRange;

  /// No description provided for @certPdfSemesterCertificate.
  ///
  /// In en, this message translates to:
  /// **'Semester Certificate — {sem}'**
  String certPdfSemesterCertificate(String sem);

  /// No description provided for @certPdfRemarks.
  ///
  /// In en, this message translates to:
  /// **'Homeroom teacher\'s remarks'**
  String get certPdfRemarks;

  /// No description provided for @certTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Certificate type'**
  String get certTypeLabel;

  /// No description provided for @certTypeAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get certTypeAnnual;

  /// No description provided for @certTypeSemester.
  ///
  /// In en, this message translates to:
  /// **'End of {sem}'**
  String certTypeSemester(String sem);

  /// No description provided for @certRoundWhole.
  ///
  /// In en, this message translates to:
  /// **'Round to whole number'**
  String get certRoundWhole;

  /// No description provided for @certRoundWholeHint.
  ///
  /// In en, this message translates to:
  /// **'Below .5 rounds down, .5 and up rounds up. Turn off to show two decimals.'**
  String get certRoundWholeHint;

  /// No description provided for @teacherAddGradeSubjectRequired.
  ///
  /// In en, this message translates to:
  /// **'Please choose a subject for this grade.'**
  String get teacherAddGradeSubjectRequired;

  /// No description provided for @gradesSubjectAveragesTab.
  ///
  /// In en, this message translates to:
  /// **'Averages'**
  String get gradesSubjectAveragesTab;

  /// No description provided for @gradesAveragesSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Semester average'**
  String get gradesAveragesSummaryTitle;

  /// No description provided for @gradesAveragesSummaryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No weighted grades yet} =1{1 weighted grade} other{{count} weighted grades}}'**
  String gradesAveragesSummaryCount(int count);

  /// No description provided for @gradesAveragesTotalWeight.
  ///
  /// In en, this message translates to:
  /// **'Total weight'**
  String get gradesAveragesTotalWeight;

  /// No description provided for @gradesAveragesNoWeighted.
  ///
  /// In en, this message translates to:
  /// **'No grades with a weight in this semester. Add one or set a % on a grade.'**
  String get gradesAveragesNoWeighted;

  /// No description provided for @gradesAvgPickTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a grade to the average'**
  String get gradesAvgPickTitle;

  /// No description provided for @gradesAvgPickSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a published grade in {subject}, then set its weight, semester and format.'**
  String gradesAvgPickSubtitle(String subject);

  /// No description provided for @gradesAvgFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get gradesAvgFilterAll;

  /// No description provided for @gradesAvgFilterCohort.
  ///
  /// In en, this message translates to:
  /// **'Cohort — {name}'**
  String gradesAvgFilterCohort(String name);

  /// No description provided for @gradesAvgSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search grades'**
  String get gradesAvgSearchHint;

  /// No description provided for @gradesAvgNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching grades in this subject.'**
  String get gradesAvgNoResults;

  /// No description provided for @gradesAvgInAverage.
  ///
  /// In en, this message translates to:
  /// **'In average'**
  String get gradesAvgInAverage;

  /// No description provided for @notesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTitle;

  /// No description provided for @notesSearchStudents.
  ///
  /// In en, this message translates to:
  /// **'Search students'**
  String get notesSearchStudents;

  /// No description provided for @notesNoStudents.
  ///
  /// In en, this message translates to:
  /// **'No students found'**
  String get notesNoStudents;

  /// No description provided for @notesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No notes} =1{1 note} other{{count} notes}}'**
  String notesCount(num count);

  /// No description provided for @notesNewNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get notesNewNote;

  /// No description provided for @notesNoNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get notesNoNotes;

  /// No description provided for @notesNoNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to write the first note about this student.'**
  String get notesNoNotesHint;

  /// No description provided for @notesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete note?'**
  String get notesDeleteTitle;

  /// No description provided for @notesDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This note will be permanently deleted.'**
  String get notesDeleteBody;

  /// No description provided for @notesUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get notesUntitled;

  /// No description provided for @notesTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get notesTitleHint;

  /// No description provided for @notesBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Start writing…'**
  String get notesBodyHint;

  /// No description provided for @notesEditedBy.
  ///
  /// In en, this message translates to:
  /// **'By {name}'**
  String notesEditedBy(String name);

  /// No description provided for @cmailTitle.
  ///
  /// In en, this message translates to:
  /// **'CMail'**
  String get cmailTitle;

  /// No description provided for @cmailInbox.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get cmailInbox;

  /// No description provided for @cmailSentTab.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get cmailSentTab;

  /// No description provided for @cmailCompose.
  ///
  /// In en, this message translates to:
  /// **'New mail'**
  String get cmailCompose;

  /// No description provided for @cmailEmptyInbox.
  ///
  /// In en, this message translates to:
  /// **'No mail yet'**
  String get cmailEmptyInbox;

  /// No description provided for @cmailEmptyInboxHint.
  ///
  /// In en, this message translates to:
  /// **'Mail from your school will appear here.'**
  String get cmailEmptyInboxHint;

  /// No description provided for @cmailEmptySent.
  ///
  /// In en, this message translates to:
  /// **'Nothing sent yet'**
  String get cmailEmptySent;

  /// No description provided for @cmailSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get cmailSubject;

  /// No description provided for @cmailBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Write your message…'**
  String get cmailBodyHint;

  /// No description provided for @cmailAudience.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get cmailAudience;

  /// No description provided for @cmailAudienceSchool.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get cmailAudienceSchool;

  /// No description provided for @cmailAudienceStudents.
  ///
  /// In en, this message translates to:
  /// **'All students'**
  String get cmailAudienceStudents;

  /// No description provided for @cmailAudienceTeachers.
  ///
  /// In en, this message translates to:
  /// **'All teachers'**
  String get cmailAudienceTeachers;

  /// No description provided for @cmailAudienceParents.
  ///
  /// In en, this message translates to:
  /// **'All parents'**
  String get cmailAudienceParents;

  /// No description provided for @cmailAudienceStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get cmailAudienceStaff;

  /// No description provided for @cmailAudienceGrades.
  ///
  /// In en, this message translates to:
  /// **'By grade'**
  String get cmailAudienceGrades;

  /// No description provided for @cmailAudienceCohorts.
  ///
  /// In en, this message translates to:
  /// **'By class'**
  String get cmailAudienceCohorts;

  /// No description provided for @cmailAudienceUsers.
  ///
  /// In en, this message translates to:
  /// **'Specific people'**
  String get cmailAudienceUsers;

  /// No description provided for @cmailPickGrades.
  ///
  /// In en, this message translates to:
  /// **'Pick grades'**
  String get cmailPickGrades;

  /// No description provided for @cmailPickCohorts.
  ///
  /// In en, this message translates to:
  /// **'Pick classes'**
  String get cmailPickCohorts;

  /// No description provided for @cmailPickPeople.
  ///
  /// In en, this message translates to:
  /// **'Pick people'**
  String get cmailPickPeople;

  /// No description provided for @cmailAttach.
  ///
  /// In en, this message translates to:
  /// **'Attach files'**
  String get cmailAttach;

  /// No description provided for @cmailSendAction.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get cmailSendAction;

  /// No description provided for @cmailSentOk.
  ///
  /// In en, this message translates to:
  /// **'Mail sent'**
  String get cmailSentOk;

  /// No description provided for @cmailDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete mail?'**
  String get cmailDeleteTitle;

  /// No description provided for @cmailDeleteForAll.
  ///
  /// In en, this message translates to:
  /// **'This deletes the mail for everyone.'**
  String get cmailDeleteForAll;

  /// No description provided for @cmailDeleteForMe.
  ///
  /// In en, this message translates to:
  /// **'This removes the mail from your inbox.'**
  String get cmailDeleteForMe;

  /// No description provided for @cmailRecipients.
  ///
  /// In en, this message translates to:
  /// **'{count} recipients'**
  String cmailRecipients(num count);

  /// No description provided for @cmailReadStats.
  ///
  /// In en, this message translates to:
  /// **'{read} of {total} read'**
  String cmailReadStats(num read, num total);

  /// No description provided for @cmailSubjectRequired.
  ///
  /// In en, this message translates to:
  /// **'Subject is required'**
  String get cmailSubjectRequired;

  /// No description provided for @cmailAudienceRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick who this mail goes to'**
  String get cmailAudienceRequired;

  /// No description provided for @cmailAttachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get cmailAttachments;

  /// No description provided for @cmailFrom.
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String cmailFrom(String name);

  /// No description provided for @phoneLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your phone'**
  String get phoneLinkTitle;

  /// No description provided for @phoneLinkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Protect your account with a phone number. We\'ll text you a verification code — it also lets you reset your password by SMS.'**
  String get phoneLinkSubtitle;

  /// No description provided for @phoneLinkFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLinkFieldLabel;

  /// No description provided for @phoneLinkSend.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get phoneLinkSend;

  /// No description provided for @phoneLinkCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get phoneLinkCodeLabel;

  /// No description provided for @phoneLinkCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent to {phone}'**
  String phoneLinkCodeSent(String phone);

  /// No description provided for @phoneLinkVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify & link'**
  String get phoneLinkVerify;

  /// No description provided for @phoneLinkLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get phoneLinkLater;

  /// No description provided for @phoneLinkDone.
  ///
  /// In en, this message translates to:
  /// **'Phone linked!'**
  String get phoneLinkDone;

  /// No description provided for @phoneLinkResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get phoneLinkResend;

  /// No description provided for @phoneLinkInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get phoneLinkInvalid;

  /// No description provided for @hubParentsSection.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get hubParentsSection;

  /// No description provided for @hubNoParents.
  ///
  /// In en, this message translates to:
  /// **'No linked parents yet'**
  String get hubNoParents;

  /// No description provided for @hubStudentSection.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get hubStudentSection;

  /// No description provided for @hubAverageLabel.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get hubAverageLabel;

  /// No description provided for @hubAccuracyLabel.
  ///
  /// In en, this message translates to:
  /// **'Practice accuracy'**
  String get hubAccuracyLabel;

  /// No description provided for @hubBestSubject.
  ///
  /// In en, this message translates to:
  /// **'Best subject'**
  String get hubBestSubject;

  /// No description provided for @hubWeakestSubject.
  ///
  /// In en, this message translates to:
  /// **'Weakest subject'**
  String get hubWeakestSubject;

  /// No description provided for @hubWeakTopics.
  ///
  /// In en, this message translates to:
  /// **'Weak topics'**
  String get hubWeakTopics;

  /// No description provided for @hubStrongTopics.
  ///
  /// In en, this message translates to:
  /// **'Strong topics'**
  String get hubStrongTopics;

  /// No description provided for @hubNoInsights.
  ///
  /// In en, this message translates to:
  /// **'No insights yet'**
  String get hubNoInsights;

  /// No description provided for @hubNoGrades.
  ///
  /// In en, this message translates to:
  /// **'No grades yet'**
  String get hubNoGrades;

  /// No description provided for @hubUnpublished.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get hubUnpublished;

  /// No description provided for @hubClass.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get hubClass;

  /// Accessibility label for the Back button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get a11yBack;

  /// Accessibility label for the Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get a11yClose;

  /// Accessibility label for the Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get a11yCancel;

  /// Accessibility label for the Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get a11yDone;

  /// Accessibility label for the Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get a11ySave;

  /// Accessibility label for the Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get a11yEdit;

  /// Accessibility label for the Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get a11yDelete;

  /// Accessibility label for the Remove button
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get a11yRemove;

  /// Accessibility label for the Add button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get a11yAdd;

  /// Accessibility label for the Create button
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get a11yCreate;

  /// Accessibility label for the Send button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get a11ySend;

  /// Accessibility label for the Search button
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get a11ySearch;

  /// Accessibility label for the Clear button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get a11yClear;

  /// Accessibility label for the Filter button
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get a11yFilter;

  /// Accessibility label for the Sort button
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get a11ySort;

  /// Accessibility label for the More options button
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get a11yMore;

  /// Accessibility label for the Menu button
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get a11yMenu;

  /// Accessibility label for the Refresh button
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get a11yRefresh;

  /// Accessibility label for the Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get a11yRetry;

  /// Accessibility label for the Share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get a11yShare;

  /// Accessibility label for the Copy button
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get a11yCopy;

  /// Accessibility label for the Download button
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get a11yDownload;

  /// Accessibility label for the Upload button
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get a11yUpload;

  /// Accessibility label for the Attach file button
  ///
  /// In en, this message translates to:
  /// **'Attach file'**
  String get a11yAttach;

  /// Accessibility label for the Add photo button
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get a11yAddPhoto;

  /// Accessibility label for the Camera button
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get a11yCamera;

  /// Accessibility label for the Voice input button
  ///
  /// In en, this message translates to:
  /// **'Voice input'**
  String get a11yMicrophone;

  /// Accessibility label for the Play button
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get a11yPlay;

  /// Accessibility label for the Pause button
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get a11yPause;

  /// Accessibility label for the Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get a11yNext;

  /// Accessibility label for the Previous button
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get a11yPrevious;

  /// Accessibility label for the Expand button
  ///
  /// In en, this message translates to:
  /// **'Expand'**
  String get a11yExpand;

  /// Accessibility label for the Collapse button
  ///
  /// In en, this message translates to:
  /// **'Collapse'**
  String get a11yCollapse;

  /// Accessibility label for the Show button
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get a11yShow;

  /// Accessibility label for the Hide button
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get a11yHide;

  /// Accessibility label for the Settings button
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get a11ySettings;

  /// Accessibility label for the Profile button
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get a11yProfile;

  /// Accessibility label for the Notifications button
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get a11yNotifications;

  /// Accessibility label for the Help button
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get a11yHelp;

  /// Accessibility label for the Details button
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get a11yInfo;

  /// Accessibility label for the Favorite button
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get a11yFavorite;

  /// Accessibility label for the Pin button
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get a11yPin;

  /// Accessibility label for the Unpin button
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get a11yUnpin;

  /// Accessibility label for the Mute button
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get a11yMute;

  /// Accessibility label for the Unmute button
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get a11yUnmute;

  /// Accessibility label for the Mark as read button
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get a11yMarkRead;

  /// Accessibility label for the New chat button
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get a11yNewChat;

  /// Accessibility label for the New message button
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get a11yNewMessage;

  /// Accessibility label for the Emoji button
  ///
  /// In en, this message translates to:
  /// **'Emoji'**
  String get a11yEmoji;

  /// Accessibility label for the Select date button
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get a11ySelectDate;

  /// Accessibility label for the Log out button
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get a11yLogout;

  /// Accessibility label for the Add account button
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get a11yAddAccount;

  /// Accessibility label for the Show password button
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get a11yShowPassword;

  /// Accessibility label for the Hide password button
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get a11yHidePassword;

  /// Accessibility label for the Scroll to bottom button
  ///
  /// In en, this message translates to:
  /// **'Scroll to bottom'**
  String get a11yScrollToBottom;

  /// Accessibility label for the Open button
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get a11yOpen;

  /// Headline of the illustrated error state shown when the device has no connectivity
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get errStateOfflineTitle;

  /// Body copy of the offline illustrated error state
  ///
  /// In en, this message translates to:
  /// **'We can\'t reach ClassMate right now. Check your Wi-Fi or mobile data, then try again.'**
  String get errStateOfflineBody;

  /// Headline of the illustrated error state shown for 5xx server errors
  ///
  /// In en, this message translates to:
  /// **'Something broke on our side'**
  String get errStateServerTitle;

  /// Body copy of the server error illustrated state
  ///
  /// In en, this message translates to:
  /// **'Our servers hit a snag. It\'s not you — please try again in a moment.'**
  String get errStateServerBody;

  /// Headline of the illustrated error state shown for 404 not found
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that'**
  String get errStateNotFoundTitle;

  /// Body copy of the not found illustrated state
  ///
  /// In en, this message translates to:
  /// **'This item may have been moved or deleted.'**
  String get errStateNotFoundBody;

  /// Headline of the illustrated error state shown for 401/403 permission errors
  ///
  /// In en, this message translates to:
  /// **'You don\'t have access'**
  String get errStateForbiddenTitle;

  /// Body copy of the permission denied illustrated state
  ///
  /// In en, this message translates to:
  /// **'This area is locked for your account. If that seems wrong, ask your school admin.'**
  String get errStateForbiddenBody;

  /// Headline of the illustrated error state shown for timeouts and rate limits
  ///
  /// In en, this message translates to:
  /// **'That took too long'**
  String get errStateTimeoutTitle;

  /// Body copy of the timeout illustrated state
  ///
  /// In en, this message translates to:
  /// **'The request timed out or the server is busy. Give it a second, then retry.'**
  String get errStateTimeoutBody;

  /// Headline of the illustrated empty state shown when there is no content
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get errStateEmptyTitle;

  /// Body copy of the empty illustrated state
  ///
  /// In en, this message translates to:
  /// **'When there\'s something to show, it\'ll appear right here.'**
  String get errStateEmptyBody;

  /// Headline of the fallback illustrated error state
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errStateGenericTitle;

  /// Body copy of the fallback illustrated error state
  ///
  /// In en, this message translates to:
  /// **'We hit an unexpected hiccup. Try again — it usually works the second time.'**
  String get errStateGenericBody;

  /// No description provided for @updatePromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updatePromptTitle;

  /// No description provided for @updatePromptBody.
  ///
  /// In en, this message translates to:
  /// **'A new version of ClassMate is ready. Update now to get the latest features and fixes.'**
  String get updatePromptBody;

  /// No description provided for @updatePromptUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updatePromptUpdate;

  /// No description provided for @updatePromptLater.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get updatePromptLater;

  /// No description provided for @chatPublishAssignment.
  ///
  /// In en, this message translates to:
  /// **'New assignment'**
  String get chatPublishAssignment;

  /// No description provided for @chatPublishMaterial.
  ///
  /// In en, this message translates to:
  /// **'New material'**
  String get chatPublishMaterial;

  /// No description provided for @chatPublishMeeting.
  ///
  /// In en, this message translates to:
  /// **'New meeting'**
  String get chatPublishMeeting;

  /// No description provided for @chatPublishView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get chatPublishView;

  /// No description provided for @settingsAppFont.
  ///
  /// In en, this message translates to:
  /// **'App font'**
  String get settingsAppFont;

  /// No description provided for @settingsAppFontSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the typeface used across the app'**
  String get settingsAppFontSubtitle;

  /// No description provided for @settingsAppFontDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settingsAppFontDefault;

  /// No description provided for @settingsAppFontSpecimen.
  ///
  /// In en, this message translates to:
  /// **'The quick brown fox jumps over the lazy dog'**
  String get settingsAppFontSpecimen;
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
    'en',
    'fr',
    'he',
    'ps',
    'ru',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'he':
      return AppLocalizationsHe();
    case 'ps':
      return AppLocalizationsPs();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

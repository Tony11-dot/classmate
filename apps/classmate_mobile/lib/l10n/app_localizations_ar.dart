// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get menu => 'القائمة';

  @override
  String get sectionCore => 'الرئيسي';

  @override
  String get sectionSchoolTools => 'أدوات المدرسة';

  @override
  String get sectionAccount => 'الحساب';

  @override
  String get navSchedule => 'الجدول';

  @override
  String get navClassrooms => 'الفصول';

  @override
  String get navPractice => 'التدريب';

  @override
  String get navInsights => 'الإحصاءات';

  @override
  String get navNova => 'NOVA';

  @override
  String get navMessages => 'الرسائل';

  @override
  String get navAttendance => 'الحضور';

  @override
  String get navGrades => 'الدرجات';

  @override
  String get navAssignments => 'الواجبات';

  @override
  String get navMeetings => 'الاجتماعات';

  @override
  String get navAnnouncements => 'الإعلانات';

  @override
  String get navNotifications => 'الإشعارات';

  @override
  String get navSolutions => 'الحلول';

  @override
  String get navExams => 'الاختبارات';

  @override
  String get navForms => 'النماذج';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navTeacherWorkspace => 'مساحة المعلم';

  @override
  String get navTeacherAssessments => 'التقييمات والدرجات';

  @override
  String get navSavedQuestions => 'الأسئلة المحفوظة';

  @override
  String get navProfile => 'الملف الشخصي';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navLogout => 'تسجيل الخروج';

  @override
  String get roleTeacher => 'معلم';

  @override
  String get roleAdmin => 'مسؤول';

  @override
  String get roleSecretary => 'سكرتير';

  @override
  String get roleParent => 'ولي الأمر';

  @override
  String get titleSchedule => 'الجدول';

  @override
  String get titleClasses => 'الفصول';

  @override
  String get titlePractice => 'التدريب';

  @override
  String get titleInsights => 'الإحصاءات';

  @override
  String get titleNova => 'NOVA';

  @override
  String get titleMessages => 'الرسائل';

  @override
  String get titleSolutions => 'الحلول';

  @override
  String get titleExams => 'الاختبارات';

  @override
  String get solutionsUploadAction => 'تحميل';

  @override
  String get solutionsNoSubjectsAvailable => 'لا توجد مواضيع متاحة.';

  @override
  String solutionsNoSubjectsMatch(Object query) {
    return 'لا توجد مواضيع تطابق \"$query\".';
  }

  @override
  String solutionsBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count كتاب',
      one: 'كتاب واحد',
    );
    return '$_temp0';
  }

  @override
  String get solutionsBooksTitle => 'الكتب';

  @override
  String get solutionsAddBookTitle => 'إضافة كتاب';

  @override
  String get solutionsBookTitleHint => 'عنوان الكتاب...';

  @override
  String get solutionsAddBookAction => 'إضافة كتاب';

  @override
  String get solutionsSearchBooks => 'البحث عن الكتب';

  @override
  String get solutionsChooseSubjectFirst => 'اختر موضوعًا أولاً.';

  @override
  String solutionsNoBooksYetBody(Object action) {
    return 'لا توجد كتب حتى الآن.\nاضغط على \"$action\" لإضافة الأول.';
  }

  @override
  String solutionsNoBooksMatch(Object query) {
    return 'لا توجد كتب تطابق \"$query\".';
  }

  @override
  String get solutionsBookLabel => 'كتاب';

  @override
  String get solutionsPagesFilterHint =>
      'أدخل رقم الصفحة ورقم السؤال للتصفية، أو اترك حقل فارغًا لرؤية الكل.';

  @override
  String get solutionsPageNumberLabel => 'رقم الصفحة';

  @override
  String get solutionsPageNumberHint => 'مثال: 42';

  @override
  String get solutionsQuestionNumberLabel => 'رقم السؤال';

  @override
  String get solutionsQuestionNumberHint => 'مثال: 3a أو 7';

  @override
  String get solutionsViewSolutionsAction => 'عرض الحلول';

  @override
  String solutionsPageQuestionSummary(Object page, Object question) {
    return 'الصفحة $page • السؤال $question';
  }

  @override
  String get solutionsExactQuestionTitle => 'الحلول لهذا السؤال بالذات';

  @override
  String get solutionsExactQuestionEmptySubtitle =>
      'لم يتم تحميل أي شيء لهذا السؤال بالذات حتى الآن. كن أول من يساعد زملاءك.';

  @override
  String solutionsUploadsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم العثور على $count تحميلات',
      one: 'تم العثور على 1 تحميل',
    );
    return '$_temp0';
  }

  @override
  String get solutionsExactQuestionEmptyBody =>
      'لا توجد تطابقات دقيقة حتى الآن. يمكنك تحميل واحد الآن، أو التحقق مما حله زملاؤك في نفس الصفحة.';

  @override
  String get solutionsLoadMoreAction => 'تحميل المزيد';

  @override
  String get solutionsSamePageTitle => 'أسئلة أخرى تم حلها في هذه الصفحة';

  @override
  String get solutionsSamePageEmptySubtitle =>
      'لم يتم تحميل أي أسئلة مجاورة من هذه الصفحة حتى الآن.';

  @override
  String get solutionsSamePageFallbackSubtitle =>
      'بديل مفيد عندما لا يوجد تحميل لسؤالك بالذات.';

  @override
  String get solutionsSamePageEmptyBody =>
      'لا توجد تحميلات قريبة على هذه الصفحة حتى الآن. سيكون التحميل الجديد هنا مفيداً جداً.';

  @override
  String get solutionsVerifiedByNova => 'تم التحقق من قبل NOVA';

  @override
  String get solutionsUploadFileLimitReached => 'تم الوصول إلى حد 10 ملفات.';

  @override
  String solutionsUploadFilesAddedLimit(int count) {
    return 'تمت إضافة $count — حد 10 ملفات.';
  }

  @override
  String get solutionsUploadCompleteFields =>
      'أكمل الموضوع والكتاب والصفحة والسؤال.';

  @override
  String get solutionsUploadAddOneFile =>
      'أضف صورة واحدة على الأقل أو ملف PDF.';

  @override
  String solutionsUploadFileFailed(Object error) {
    return 'فشل تحميل الملف: $error';
  }

  @override
  String solutionsUploadCreateFailed(Object error) {
    return 'فشل إنشاء الحل: $error';
  }

  @override
  String get solutionsUploadSuccess => 'تم تحميل الحل!';

  @override
  String get solutionsUploadAddNewBookOption => '+ إضافة كتاب جديد...';

  @override
  String get solutionsUploadAddBookShortAction => 'إضافة';

  @override
  String get solutionsUploadTitle => 'تحميل حل';

  @override
  String get solutionsUploadSubtitle =>
      'صور حقيقية أو ملفات PDF فقط. يتم تطبيق التحقق من NOVA والتعديل بعد التحميل.';

  @override
  String get solutionsUploadNoBooksAbove => 'لا توجد كتب — أضف واحدة أعلاه';

  @override
  String get solutionsUploadCaptionOptional => 'التسمية التوضيحية (اختياري)';

  @override
  String get solutionsUploadImagesAction => 'الصور';

  @override
  String get solutionsUploadPdfAction => 'ملف PDF';

  @override
  String solutionsUploadFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ملفات محددة',
      one: 'ملف محدد',
    );
    return '$count / 10 $_temp0';
  }

  @override
  String get solutionsUploadSomeFilesFailed => 'فشل تحميل بعض الملفات.';

  @override
  String get solutionsUploadRetryFailedFiles => 'إعادة محاولة الملفات الفاشلة';

  @override
  String get solutionsUploadSubmittingAction => 'جاري التحميل...';

  @override
  String get solutionsUploadSubmitAction => 'تحميل الحل';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSubtitle => 'المظهر واللغة والحساب';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get settingsTheme => 'السمة';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsLanguageSystem => 'النظام الافتراضي';

  @override
  String get settingsAccentColour => 'لون التمييز';

  @override
  String get settingsAccentSubtitle => 'اللون المستخدم في التطبيق';

  @override
  String get settingsReduceMotion => 'تقليل الحركة';

  @override
  String get settingsReduceMotionSubtitle => 'تقليل التحريكات في التطبيق';

  @override
  String get settingsAccount => 'الحساب';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get settingsLogoutSubtitle => 'تسجيل الخروج من هذا الجهاز';

  @override
  String get settingsThemeSystem => 'النظام الافتراضي';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsLanguageSearchHint => 'ابحث عن لغة...';

  @override
  String get teacherWorkspaceSubtitle =>
      'شغّل الحضور والقوائم والتقييم من تطبيق الجوال.';

  @override
  String get teacherMetricSessionsToday => 'حصص اليوم';

  @override
  String get teacherMetricTeachingGroups => 'المجموعات التعليمية';

  @override
  String get teacherMetricAssessments => 'التقييمات';

  @override
  String get teacherQuickActions => 'إجراءات سريعة';

  @override
  String get teacherNoDateAvailable => 'لا يوجد تاريخ متاح';

  @override
  String get teacherNoTeachingSlotsToday => 'لا توجد حصص تدريس مجدولة اليوم.';

  @override
  String get teacherUpcomingAssessments => 'التقييمات القادمة';

  @override
  String get teacherUpcomingAssessmentsSubtitle =>
      'مباشرة من نظام درجات المعلم';

  @override
  String get teacherNoAssessmentsYet => 'لم يتم إنشاء تقييمات بعد.';

  @override
  String get teacherUnassignedSlot => 'حصة غير مخصصة';

  @override
  String get teacherNoCohort => 'لا توجد مجموعة';

  @override
  String get teacherCourseFallback => 'مقرر';

  @override
  String teacherPeriod(Object number) {
    return 'الحصة $number';
  }

  @override
  String get teacherLoadErrorTitle => 'تعذر تحميل مساحة المعلم';

  @override
  String get teacherClassroomsLoadError =>
      'لم نتمكن من تحميل الفصول الدراسية الآن. اسحب للتحديث أو حاول مجددًا.';

  @override
  String get teacherClassroomsLoadTimeout =>
      'يستغرق تحميل الفصول الدراسية وقتًا طويلاً. اسحب للتحديث أو حاول بعد قليل.';

  @override
  String get teacherClassroomsLoadNetwork =>
      'لا يمكن الاتصال بالفصول الدراسية الآن. تحقق من الاتصال وحاول مجددًا.';

  @override
  String get teacherClassroomsSubtitle =>
      'افتح قائمة الطلاب وأنشئ رمز دخول حي لدخول الطلاب.';

  @override
  String get teacherClassroomsNoCohorts =>
      'لم يتم ربط أي مجموعات دراسية بهذا المعلم بعد.';

  @override
  String teacherClassroomsCohort(Object cohortId) {
    return 'المجموعة $cohortId';
  }

  @override
  String get teacherClassroomsGeneratingJoinCode => 'جاري التوليد…';

  @override
  String get teacherClassroomsCreateJoinCode => 'إنشاء رمز الدخول';

  @override
  String get teacherClassroomsLiveJoinCode => 'رمز الدخول الحي';

  @override
  String teacherClassroomsExpiresAt(Object value) {
    return 'ينتهي $value';
  }

  @override
  String get teacherClassroomsRoster => 'قائمة الطلاب';

  @override
  String get teacherClassroomsNoStudents =>
      'لم يتم تسجيل أي طلاب في هذا الفصل الدراسي بعد.';

  @override
  String get teacherAttendanceLoadError =>
      'لم نتمكن من تحميل سجل الحضور الآن. اسحب لتحديث أو حاول مرة أخرى.';

  @override
  String get teacherAttendanceLoadTimeout =>
      'يستغرق تحميل سجل الحضور وقتاً طويلاً. اسحب لتحديث أو حاول مرة أخرى بعد قليل.';

  @override
  String get teacherAttendanceLoadNetwork =>
      'فشل الاتصال بسجل الحضور الآن. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get teacherAttendanceSubtitle =>
      'اختر جلسة حية، حدد الفصل، واحفظ الصفوف المتغيرة فقط.';

  @override
  String get teacherAttendanceTodaySessions => 'جلسات اليوم';

  @override
  String teacherAttendanceSessionSummary(
    Object cohort,
    Object grade,
    Object date,
    Object period,
  ) {
    return '$cohort • الصف $grade • $date • الفترة $period';
  }

  @override
  String get teacherAttendanceChanged => 'تم التغيير';

  @override
  String get teacherAttendanceNoteLabel => 'ملاحظة';

  @override
  String get teacherAttendanceClassNotesLabel => 'ملاحظات الحصة';

  @override
  String get teacherAttendanceClassNotesHint => 'ما تم تناوله في هذه الحصة…';

  @override
  String get teacherAttendanceSaving => 'جارٍ الحفظ…';

  @override
  String get teacherAttendanceSaveAll => 'حفظ الحضور';

  @override
  String teacherAttendanceSaveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تغييرات',
      one: 'تغيير واحد',
    );
    return 'احفظ $_temp0';
  }

  @override
  String get teacherAttendanceSaved => 'تم حفظ سجل الحضور';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get scheduleRefreshTooFast =>
      'يتم تحديث الجدول بسرعة كبيرة الآن. انتظر قليلاً ثم حاول مرة أخرى.';

  @override
  String get scheduleSessionExpired =>
      'انتهت صلاحية جلستك. يرجى تسجيل الدخول مجدداً.';

  @override
  String get scheduleNotOnboarded =>
      'ملف الطالب الخاص بك غير مكتمل. اطلب من مسؤول مدرستك تعيينك في فصل.';

  @override
  String get scheduleLoadError => 'تعذر تحميل الجدول حتى الآن.';

  @override
  String get scheduleSelectedDay => 'اليوم المحدد';

  @override
  String scheduleClassCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حصة',
      many: '$count حصة',
      few: '$count حصص',
      two: 'حصتان',
      one: 'حصة واحدة',
      zero: '0 حصص',
    );
    return '$_temp0';
  }

  @override
  String get scheduleNextUp => 'التالي';

  @override
  String get scheduleNoMoreClasses => 'لا توجد حصص أخرى';

  @override
  String get scheduleNoClassesTitle => 'لا توجد حصص في هذا اليوم';

  @override
  String scheduleNoClassesSubtitle(Object day) {
    return 'يبدو أن $day خالٍ.';
  }

  @override
  String get scheduleClassFallback => 'حصة';

  @override
  String get scheduleNoSubjectLocation => 'No subject or location yet';

  @override
  String get scheduleNotes => 'Notes';

  @override
  String get scheduleGoToClassroom => 'Go to Classroom';

  @override
  String get loginTitle => 'تسجيل الدخول للجوال للطلاب والمعلمين';

  @override
  String get loginSubtitle =>
      'حسابات المعلمين تفتح مساحة المعلم. حسابات الطلاب تبقى في تجربة الطالب.';

  @override
  String get loginSignIn => 'تسجيل الدخول';

  @override
  String get loginSigningIn => 'جارٍ تسجيل الدخول...';

  @override
  String get loginEmailLabel => 'البريد الإلكتروني';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get profileNotAvailable => 'غير متاح';

  @override
  String get profileSchoolInfo => 'معلومات المدرسة';

  @override
  String get profileFullName => 'الاسم الكامل';

  @override
  String get profileRole => 'الدور';

  @override
  String get profileSchoolId => 'معرّف المدرسة';

  @override
  String get profileCohortId => 'معرّف المجموعة';

  @override
  String get profileAccountInfo => 'معلومات الحساب';

  @override
  String get profileUsername => 'اسم المستخدم';

  @override
  String get profileUsernameHint => 'اسم_المستخدم';

  @override
  String get profileContactEmail => 'بريد التواصل';

  @override
  String get profileEmailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get profileEmailHint => 'you@example.com';

  @override
  String get profileBirthday => 'تاريخ الميلاد';

  @override
  String get profileSecurity => 'الأمان';

  @override
  String get profileSelectBirthday => 'اختر تاريخ ميلادك';

  @override
  String get profilePasswordUpdated => 'تم تحديث كلمة المرور';

  @override
  String get profileSave => 'حفظ';

  @override
  String get profileEmptyValue => '—';

  @override
  String get profileChangePassword => 'تغيير كلمة المرور';

  @override
  String get profileCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get profileNewPassword => 'كلمة المرور الجديدة';

  @override
  String get profileConfirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get profileUpdatePassword => 'تحديث كلمة المرور';

  @override
  String get profilePasswordAllFieldsRequired => 'جميع الحقول مطلوبة';

  @override
  String get profilePasswordMinLength =>
      'يجب أن تكون كلمة المرور الجديدة 8 أحرف على الأقل';

  @override
  String get profilePasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get profilePasswordNotAuthenticated => 'غير مسجل الدخول';

  @override
  String get profilePasswordIncorrect => 'كلمة المرور الحالية غير صحيحة';

  @override
  String get profilePasswordGenericError => 'حدث خطأ ما. حاول مرة أخرى.';

  @override
  String get editProfileTitle => 'تعديل الملف الشخصي';

  @override
  String get editProfileSchool => 'المدرسة';

  @override
  String get editProfileSchoolPublic => 'المدرسة عامة';

  @override
  String get editProfileGradePublic => 'الصف عام';

  @override
  String get editProfileMajors => 'التخصصات';

  @override
  String get editProfileMajorsPublic => 'التخصصات عامة';

  @override
  String get editProfileBio => 'نبذة';

  @override
  String get editProfileBioPublic => 'النبذة عامة';

  @override
  String get editProfileStatus => 'الحالة';

  @override
  String get editProfileStatusPublic => 'الحالة عامة';

  @override
  String get classroomsYourClassrooms => 'فصولك الدراسية';

  @override
  String get classroomsReorder => 'إعادة ترتيب الفصول';

  @override
  String classroomsCount(Object count) {
    return '$count فصول';
  }

  @override
  String get classroomsSearchHint => 'ابحث في الفصول';

  @override
  String get classroomsNoSearchMatches => 'لا توجد فصول تطابق بحثك';

  @override
  String get classroomsClassroomLabel => 'فصل';

  @override
  String get classroomsLoadingLatestMessage => 'جارٍ تحميل آخر رسالة...';

  @override
  String get classroomsTapToOpen => 'اضغط لفتح الفصل';

  @override
  String get classroomsNoMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get classroomsMessageFallback => 'رسالة';

  @override
  String get examsLoadError => 'تعذر تحميل الاختبارات أو النماذج';

  @override
  String get examsAllFilter => 'الكل';

  @override
  String get examsFormsSubtitle =>
      'راجع نماذج الصف وفترات الرد والمتابعات التي تنشرها المدرسة.';

  @override
  String get examsOnlySubtitle =>
      'تابع التقييمات القادمة والعد التنازلي وسجلات الاختبارات السابقة من فصولك.';

  @override
  String get examsUpcomingStat => 'الاختبارات القادمة';

  @override
  String get examsOpenFormsStat => 'النماذج المفتوحة';

  @override
  String get examsCountdownPast => 'منتهى';

  @override
  String get examsCountdownTomorrow => 'غدًا';

  @override
  String examsCountdownInDays(Object days) {
    return 'خلال $days أيام';
  }

  @override
  String get examsNoExamsPublished => 'لم يتم نشر أي اختبارات بعد.';

  @override
  String get examsNoFormsPublished => 'لم يتم نشر أي نماذج بعد.';

  @override
  String examsNoExamsForFilter(Object subject) {
    return 'لا توجد اختبارات متاحة لمادة $subject الآن.';
  }

  @override
  String examsNoFormsForFilter(Object subject) {
    return 'لا توجد نماذج متاحة لمادة $subject الآن.';
  }

  @override
  String examsMaterialsCount(Object count) {
    return '$count مواد';
  }

  @override
  String get examsOpenState => 'مفتوح';

  @override
  String get examsClosedState => 'مغلق';

  @override
  String examsQuestionsCount(Object count) {
    return '$count أسئلة';
  }

  @override
  String examsResponsesCount(Object count) {
    return '$count ردود';
  }

  @override
  String get insightsTrendBaseline => 'الأساس';

  @override
  String get insightsTrendImproving => 'يتحسن';

  @override
  String get insightsTrendDropping => 'يتراجع';

  @override
  String get insightsTrendStable => 'مستقر';

  @override
  String get insightsHeadlineIntervention => 'نافذة التدخل مفتوحة';

  @override
  String get insightsHeadlineSignals => 'عدة مؤشرات تحتاج إلى ضبط';

  @override
  String get insightsHeadlineMomentum => 'الزخم يمكن أن يتضاعف هذا الأسبوع';

  @override
  String get insightsBodyAttendance =>
      'احمِ الحضور أولاً. الحضور الأفضل الآن سيرفع كل مؤشر آخر بشكل أسرع.';

  @override
  String insightsBodyWeakTrend(Object subject) {
    return '$subject مع تراجع اتجاه التدريب هو أكبر مزيج خطورة الآن. أصلح ذلك قبل التوسع.';
  }

  @override
  String insightsBodyLeverage(Object subject) {
    return '$subject هي نقطة قوتك. استخدمها لبناء الثقة بينما تعالج الجوانب الأضعف.';
  }

  @override
  String get insightsBodyConsistency =>
      'واصل الجلسات القصيرة المركزة. الأيام القليلة القادمة أهم من خطة طويلة مثالية.';

  @override
  String get insightsInterventionScoreTitle => 'مؤشر التدخل';

  @override
  String insightsInterventionScoreBody(Object count) {
    return 'هناك $count إشارات نشطة تشكل خطوتك التالية.';
  }

  @override
  String get insightsRecoveryPathTitle => 'أسرع مسار للتعافي';

  @override
  String get insightsRecoveryPathDefault => 'الحضور + الاستمرارية أولاً.';

  @override
  String insightsRecoveryPathTopic(Object topic, Object subject) {
    return 'راجع $topic في $subject قبل أن تضغط أكثر.';
  }

  @override
  String get insightsProjectedDirectionTitle => 'الاتجاه المتوقع';

  @override
  String insightsProjectedDirectionBody(Object trend) {
    return '$trend بناءً على سلوك التدريب الأخير خلال 7 أيام مقابل 30 يومًا.';
  }

  @override
  String get insightsLoadingTitle => 'جارٍ تحميل الرؤى';

  @override
  String get insightsLoadingSubtitle => 'جارٍ بناء لوحتك التنبؤية.';

  @override
  String get insightsNotReadyTitle => 'الرؤى غير جاهزة بعد';

  @override
  String get insightsEmptyTitle => 'لا توجد رؤى بعد';

  @override
  String get insightsEmptySubtitle =>
      'واصل استخدام التدريب وأدوات المدرسة حتى يتمكن ClassMate من بناء صورة أكاديمية أوضح.';

  @override
  String get insightsGradeAverage => 'متوسط الدرجات';

  @override
  String get insightsAccuracy => 'الدقة';

  @override
  String get insightsOpenNova => 'افتح NOVA';

  @override
  String get insightsOpenNovaPrompt =>
      'ساعدني في إصلاح أضعف نقطة لدي بناءً على أحدث رؤى ClassMate.';

  @override
  String get insightsPredictiveRecoveryPlanTitle => 'خطة تعافٍ تنبؤية';

  @override
  String get insightsPracticeNow => 'تدرّب الآن';

  @override
  String get insightsPredictiveModulesTitle => 'الوحدات التنبؤية';

  @override
  String get insightsPredictiveModulesSubtitle =>
      'أقوى الإشارات المستقبلية من بياناتك الطلابية الحالية.';

  @override
  String get insightsAnnouncementsPressureTitle => 'ضغط الإعلانات';

  @override
  String get insightsAnnouncementsPressureSubtitle =>
      'محرك الإعلانات يغذي اللوحة الآن مباشرة.';

  @override
  String get insightsAiCoachTitle => 'ملخص المدرب الذكي';

  @override
  String get insightsAiCoachLoadingSubtitle =>
      'جارٍ تحميل إرشادات الذكاء الاصطناعي.';

  @override
  String get insightsAiCoachUnavailableSubtitle =>
      'إرشادات الذكاء الاصطناعي غير متاحة لهذا الحساب الآن.';

  @override
  String get insightsAskNova => 'اسأل NOVA';

  @override
  String get insightsAskNovaPrompt => 'ابنِ لي خطة تعافٍ من أحدث رؤاي.';

  @override
  String get insightsAiStudyCoachTitle => 'مدرب الدراسة الذكي';

  @override
  String get insightsSchoolToolsTitle => 'أدوات المدرسة';

  @override
  String get insightsSchoolToolsSubtitle =>
      'انتقل مباشرة إلى مسارات الطالب التي تهم الآن أكثر.';

  @override
  String get tutorUntitledChat => 'محادثة بلا عنوان';

  @override
  String get tutorNewChat => 'محادثة جديدة';

  @override
  String tutorFailedToOpenSeededChat(Object error) {
    return 'تعذر فتح المحادثة: $error';
  }

  @override
  String tutorFailedToCreateChat(Object error) {
    return 'تعذر إنشاء المحادثة: $error';
  }

  @override
  String get tutorRenameChatTitle => 'إعادة تسمية المحادثة';

  @override
  String get tutorChatNameHint => 'اسم المحادثة';

  @override
  String get tutorCancel => 'إلغاء';

  @override
  String get tutorHide => 'إخفاء';

  @override
  String get tutorHideChatTitle => 'إخفاء المحادثة';

  @override
  String get tutorHideChatSubtitle => 'يخفي هذه المحادثة على هذا الجهاز.';

  @override
  String get tutorHideChatConfirmTitle => 'إخفاء المحادثة؟';

  @override
  String get tutorHideChatConfirmBody =>
      'سيؤدي هذا إلى إخفاء المحادثة من القائمة على هذا الجهاز. ستبقى الجلسة على الخادم.';

  @override
  String get tutorTapToOpenHistory => 'اضغط لفتح السجل';

  @override
  String get tutorAiTutorSubtitle => 'معلّمك بالذكاء الاصطناعي';

  @override
  String get tutorHeroBody => 'سجل محادثات حقيقي، سلاسل أنظف، ووصول أسرع.';

  @override
  String get tutorStartFreshConversation => 'ابدأ محادثة جديدة';

  @override
  String get tutorSearchHistoryHint => 'ابحث في سجل المحادثات';

  @override
  String get chatComposerDefaultHint => 'رسالة';

  @override
  String get chatComposerReplyingToMessage => 'الرد على رسالة';

  @override
  String get chatComposerReplyFallback => 'رد';

  @override
  String get chatComposerMicHint =>
      'اضغط لرسالة صوتية سريعة أو استمر بالضغط للتسجيل';

  @override
  String get chatComposerRecordingTitle => 'جارٍ التسجيل';

  @override
  String get chatComposerReleaseToSend => 'اترك للإرسال';

  @override
  String get chatComposerCancelTitle => 'إلغاء';

  @override
  String get chatComposerLockTitle => 'قفل';

  @override
  String get chatComposerSlideLeftToCancel => 'اسحب لليسار للإلغاء';

  @override
  String get chatComposerSlideUpToLock => 'اسحب للأعلى للقفل';

  @override
  String get chatComposerReleaseToCancel => 'اترك للإلغاء';

  @override
  String get chatComposerKeepSlidingToCancel => 'استمر بالسحب للإلغاء';

  @override
  String get chatComposerReleaseToLock => 'اترك للقفل';

  @override
  String get chatComposerRelease => 'اترك';

  @override
  String get chatComposerLock => 'قفل';

  @override
  String get chatComposerRecordingPaused => 'التسجيل متوقف مؤقتًا';

  @override
  String get chatComposerRecordingLocked => 'التسجيل مقفل';

  @override
  String get chatComposerResumeHint =>
      'استأنف عندما تكون جاهزًا لمتابعة التسجيل';

  @override
  String get chatComposerLockedHint => 'اضغط إرسال عندما تكون جاهزًا للمشاركة';

  @override
  String get chatContextDismiss => 'إغلاق';

  @override
  String get chatContextCopyText => 'نسخ النص';

  @override
  String get chatContextDelete => 'حذف';

  @override
  String get chatMessageInfoShortTitle => 'معلومات';

  @override
  String get chatMessageInfoStatus => 'الحالة';

  @override
  String get chatMessageInfoStatusTime => 'وقت الحالة';

  @override
  String get chatMessageInfoSentAt => 'أُرسلت في';

  @override
  String get chatMessageInfoDeliveredAt => 'تم التسليم في';

  @override
  String get chatMessageInfoSeenAt => 'تمت المشاهدة في';

  @override
  String get chatMessageInfoMessageType => 'نوع الرسالة';

  @override
  String get chatMessageInfoTextType => 'نص';

  @override
  String get chatMessageInfoEdited => 'تم التعديل';

  @override
  String get chatMessageInfoForwarded => 'تمت إعادة التوجيه';

  @override
  String get chatMessageInfoVoiceDuration => 'مدة الصوت';

  @override
  String get chatMessageInfoSeenBy => 'شاهده';

  @override
  String get chatMessageInfoDeliveredTo => 'تم التسليم إلى';

  @override
  String get chatMessageInfoEmptyBody => '(فارغ)';

  @override
  String get chatMessageInfoReadLess => 'اقرأ أقل';

  @override
  String get chatMessageInfoReadMore => 'اقرأ المزيد';

  @override
  String get chatMessageInfoSeen => 'تمت المشاهدة';

  @override
  String get chatMessageInfoDelivered => 'تم التسليم';

  @override
  String get chatMessageInfoNotDelivered => 'لم يتم التسليم';

  @override
  String get chatMessageInfoSent => 'أُرسلت';

  @override
  String get chatMessageInfoPending => 'قيد الانتظار';

  @override
  String get chatMessageInfoNotSeen => 'لم تتم المشاهدة';

  @override
  String get chatMessageInfoType => 'النوع';

  @override
  String get chatMessageInfoDuration => 'المدة';

  @override
  String get chatMessageInfoYes => 'نعم';

  @override
  String get chatMessageInfoNo => 'لا';

  @override
  String get chatMessageInfoDeleteState => 'حالة الحذف';

  @override
  String get chatReactionDetailsTitle => 'التفاعلات';

  @override
  String get chatReactionAddAction => 'إضافة تفاعل';

  @override
  String get chatReactionEmptyState => 'لا توجد تفاعلات بعد';

  @override
  String get chatReactionSingle => 'تفاعل';

  @override
  String get chatReactionTapToRemove => 'اضغط للإزالة';

  @override
  String chatReactionYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' · $count',
      one: '',
    );
    return 'أنت$_temp0';
  }

  @override
  String chatReactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تفاعلات',
      one: 'تفاعل',
    );
    return '$_temp0';
  }

  @override
  String get chatEmojiPickerTitle => 'اختر رمزًا تعبيريًا';

  @override
  String get chatEmojiPickerSearchHint => 'ابحث عن رمز تعبيري';

  @override
  String get chatEmojiPickerEmptyState => 'لم يتم العثور على رموز تعبيرية';

  @override
  String get chatCameraTitle => 'الكاميرا';

  @override
  String get chatCameraUseAction => 'استخدام';

  @override
  String get chatCameraGalleryAction => 'المعرض';

  @override
  String chatCameraSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محدد',
      one: '1 محدد',
      zero: '0 محدد',
    );
    return '$_temp0';
  }

  @override
  String get chatMediaPreviewEmptyState => 'لا يوجد شيء للمعاينة';

  @override
  String get chatMediaPreviewDrawCropAction => 'رسم وقص';

  @override
  String get chatMediaPreviewRotateLeftAction => 'تدوير لليسار';

  @override
  String get chatMediaPreviewRotateRightAction => 'تدوير لليمين';

  @override
  String get chatMediaPreviewMirrorAction => 'عكس';

  @override
  String get chatMediaPreviewResetAction => 'إعادة تعيين';

  @override
  String get chatMediaPreviewRemoveAction => 'إزالة';

  @override
  String get chatMediaPreviewCaptionHint => 'أضف تعليقًا...';

  @override
  String tutorPlanSelectedPlaceholder(Object plan) {
    return 'تم اختيار $plan. ستبقى المدفوعات في الوضع التجريبي حاليًا.';
  }

  @override
  String get tutorFailedToLoadChats => 'تعذر تحميل المحادثات';

  @override
  String get tutorNoChatsYet => 'لا توجد محادثات بعد';

  @override
  String get tutorNoChatsMatchSearch => 'لا توجد محادثات تطابق بحثك';

  @override
  String get tutorCreateFirstChat => 'أنشئ أول محادثة';

  @override
  String get tutorPlansTitle => 'خطط NOVA';

  @override
  String tutorPlansSubtitle(Object model) {
    return 'تعتمد على افتراضات تكلفة $model وحدود شهرية صارمة حتى يبقى الاستخدام مربحًا.';
  }

  @override
  String get tutorPlanPriceFree => 'مجاني';

  @override
  String tutorPlanPriceMonthly(Object price) {
    return '\$$price/شهريًا';
  }

  @override
  String get tutorPromptsLeft => 'الطلبات المتبقية';

  @override
  String get tutorUploadsLeft => 'التحميلات المتبقية';

  @override
  String get tutorVoiceLeft => 'الدقائق الصوتية المتبقية';

  @override
  String tutorUsageValue(Object remaining, Object total) {
    return '$remaining/$total';
  }

  @override
  String tutorVoiceUsageValue(Object remaining, Object total) {
    return '$remaining/$total دقيقة';
  }

  @override
  String get tutorPaymentMethodsTitle => 'طرق الدفع';

  @override
  String tutorPaymentMethodsSubtitle(Object plan) {
    return 'الدفع ما زال تجريبيًا حتى يصبح حساب ClassMate البنكي ومعالج الدفع جاهزين. الخطة المختارة هي $plan.';
  }

  @override
  String get tutorCardCheckoutTitle => 'الدفع بالبطاقة';

  @override
  String get tutorCardCheckoutSubtitle =>
      'بوابة تجريبية لبطاقات Visa وMastercard وAmEx.';

  @override
  String get tutorApplePayTitle => 'Apple Pay';

  @override
  String get tutorApplePaySubtitle => 'تدفق محفظة تجريبي للآيفون والويب.';

  @override
  String get tutorBankTransferTitle => 'تحويل بنكي';

  @override
  String get tutorBankTransferSubtitle =>
      'حساب ClassMate البنكي قيد الانتظار. ستُستكمل التفاصيل عند فتحه.';

  @override
  String get tutorPlanStarterName => 'البداية';

  @override
  String get tutorPlanStarterTagline =>
      'يكفي للتجربة والمراجعة الأسبوعية الخفيفة.';

  @override
  String get tutorPlanPlusName => 'بلس';

  @override
  String get tutorPlanPlusTagline =>
      'الأفضل لطالب جاد يستخدم NOVA معظم الأيام.';

  @override
  String get tutorPlanProName => 'برو';

  @override
  String get tutorPlanProTagline =>
      'لاستخدام يومي كثيف وموسم اختبارات كامل وجلسات دراسة طويلة.';

  @override
  String get tutorPlanSchoolSeatName => 'مقعد مدرسي';

  @override
  String get tutorPlanSchoolSeatTagline =>
      'للتعميم لكل طالب أو موظف داخل مدرسة حقيقية.';

  @override
  String tutorPlanBulletPromptsMonthly(Object count) {
    return '$count طلبات NOVA كل شهر';
  }

  @override
  String tutorPlanBulletPromptsPerSeatMonthly(Object count) {
    return '$count طلبات NOVA لكل مقعد شهريًا';
  }

  @override
  String tutorPlanBulletUploads(Object count) {
    return '$count تحميلات صور أو ملفات';
  }

  @override
  String tutorPlanBulletVoiceMinutes(Object count) {
    return '$count دقائق تفريغ صوتي';
  }

  @override
  String tutorEstimatedCostCeilingFree(Object cost) {
    return 'السقف التقديري للتكلفة: \$$cost/شهريًا';
  }

  @override
  String tutorEstimatedCostCeilingPaid(Object cost, Object margin) {
    return 'السقف التقديري للتكلفة: \$$cost/شهريًا • هامش $margin%';
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
  String get tutorVoiceMessageFallback => 'رسالة صوتية';

  @override
  String get tutorFileFallback => 'ملف';

  @override
  String get tutorCopy => 'نسخ';

  @override
  String get tutorEditMessage => 'تعديل الرسالة';

  @override
  String get tutorCopied => 'تم النسخ';

  @override
  String get tutorLoadedIntoComposer => 'تم التحميل في المُنشئ';

  @override
  String get tutorTakePhoto => 'التقط صورة';

  @override
  String get tutorRecordVideo => 'سجل فيديو';

  @override
  String get tutorChooseFromGallery => 'اختر من المعرض';

  @override
  String get tutorPreviewTitle => 'معاينة';

  @override
  String get tutorThinking => 'جارٍ التفكير...';

  @override
  String get tutorDone => 'تم.';

  @override
  String get tutorFailedToStreamReply => 'تعذر بث الرد';

  @override
  String get tutorUnsupportedFilesMessage =>
      'يدعم NOVA الصور والمستندات والنصوص. لا يدعم الفيديو وملفات الصوت هنا.';

  @override
  String get tutorNoAudioCaptured => 'لم يتم التقاط صوت.';

  @override
  String get tutorVoiceLimitReachedTitle => 'تم بلوغ حد الصوت';

  @override
  String get tutorVoiceLimitReachedMessage =>
      'لا تحتوي خطتك الحالية في NOVA على دقائق صوت كافية لدورة التفريغ هذه.';

  @override
  String get tutorTranscriptionFailed => 'فشل التفريغ. حاول مرة أخرى.';

  @override
  String get tutorMicrophonePermissionRequired => 'يلزم إذن الميكروفون.';

  @override
  String get tutorPlanLimitReachedTitle => 'تم بلوغ حد خطة NOVA';

  @override
  String get tutorPlanLimitReachedMessage =>
      'تم استنفاد حصة هذا الشهر من الطلبات أو التحميلات لخطة NOVA الحالية. اختر خطة أعلى من شاشة NOVA الرئيسية للمتابعة.';

  @override
  String get tutorSendFailed => 'فشل الإرسال.';

  @override
  String tutorCurrentPlanUsageSummary(
    Object plan,
    Object prompts,
    Object uploads,
    Object voice,
  ) {
    return 'الخطة الحالية: $plan • المتبقي $prompts طلبات • المتبقي $uploads تحميلات • المتبقي $voice دقائق صوت';
  }

  @override
  String get tutorReviewPlansInHome => 'راجع الخطط في NOVA الرئيسية';

  @override
  String get tutorCouldNotOpenAttachment => 'تعذر فتح المرفق.';

  @override
  String get tutorAttachmentUnavailable => 'المرفق غير متاح.';

  @override
  String get tutorImageUnavailable => 'الصورة غير متاحة';

  @override
  String get tutorYou => 'أنت';

  @override
  String get tutorRegenerate => 'إعادة التوليد';

  @override
  String get tutorEmptyStateTitle => 'ابدأ بسؤال حقيقي';

  @override
  String get tutorEmptyStateBody =>
      'اطلب من NOVA شرح مفهوم، أو تحويل ملاحظاتك إلى جدول، أو مقارنة أفكار، أو مساعدتك على المراجعة من ملف مرفوع.';

  @override
  String get tutorPromptSuggestionSummarizeNotes => 'لخّص ملاحظات درسي';

  @override
  String get tutorPromptSuggestionRevisionTable => 'أنشئ جدول مراجعة';

  @override
  String get tutorPromptSuggestionQuizMe => 'اختبرني في هذا الموضوع';

  @override
  String get tutorMessageNovaHint => 'راسل NOVA';

  @override
  String get tutorHeaderSubtitleReady => 'إجابات منظمة، جداول، ومساعدة دراسية';

  @override
  String get tutorYourNovaPlanTitle => 'خطتك في NOVA';

  @override
  String get tutorYourNovaPlanMessage =>
      'راجع حدود الطلبات والتحميلات والصوت هنا، ثم ارجع إلى NOVA الرئيسية إذا أردت تبديل الخطة.';

  @override
  String get tutorExplainTitle => 'شرح NOVA';

  @override
  String get classroomsThreadTypeClassroom => 'فصل';

  @override
  String get classroomsThreadTypeGroup => 'مجموعة';

  @override
  String get classroomsThreadTypeDirectMessage => 'رسالة مباشرة';

  @override
  String get classroomsThreadTypeDirectMessageShort => 'مباشر';

  @override
  String get messagesBlockedPeopleTitle => 'الأشخاص المحظورون';

  @override
  String get messagesStartChatAction => 'بدء دردشة';

  @override
  String messagesLoadFailed(Object error) {
    return 'تعذر تحميل الرسائل: $error';
  }

  @override
  String get messagesSearchHint => 'ابحث في الرسائل';

  @override
  String get messagesNoResults => 'لم يتم العثور على رسائل';

  @override
  String get messagesRequestsSection => 'الطلبات';

  @override
  String get messagesPendingApprovals => 'الموافقات المعلقة';

  @override
  String get messagesChatsSection => 'الدردشات';

  @override
  String get messagesAllChatsSection => 'كل الدردشات';

  @override
  String messagesConversationCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محادثات',
      one: 'محادثة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get messagesRequestReviewStatus => 'مراجعة';

  @override
  String messagesPeopleLoadFailed(Object error) {
    return 'تعذر تحميل الأشخاص: $error';
  }

  @override
  String get messagesSearchPeopleHint => 'ابحث عن أشخاص';

  @override
  String get messagesNewGroupTitle => 'مجموعة جديدة';

  @override
  String get messagesNewGroupSubtitle => 'إنشاء دردشة جماعية';

  @override
  String get messagesGroupNameHint => 'اسم المجموعة';

  @override
  String get messagesCreateGroupAction => 'إنشاء مجموعة';

  @override
  String get messagesBlockedPersonFallback => 'هذا الشخص';

  @override
  String get messagesUnblockPersonTitle => 'إلغاء حظر الشخص؟';

  @override
  String messagesUnblockPersonBody(Object name) {
    return 'السماح لـ $name بمراسلتك مرة أخرى؟';
  }

  @override
  String get messagesUnblockAction => 'إلغاء الحظر';

  @override
  String messagesUnblockedToast(Object name) {
    return 'تم إلغاء حظر $name';
  }

  @override
  String messagesBlockedPeopleLoadFailed(Object error) {
    return 'تعذر تحميل الأشخاص المحظورين: $error';
  }

  @override
  String get messagesNoBlockedPeople => 'لا يوجد أشخاص محظورون';

  @override
  String get messagesUnknownUser => 'مستخدم غير معروف';

  @override
  String get messagesRequestTitle => 'طلب';

  @override
  String messagesRequestLoadFailed(Object error) {
    return 'تعذر تحميل الطلب: $error';
  }

  @override
  String get messagesRequestBannerIncoming => 'طلب رسالة';

  @override
  String get messagesRequestBannerOutgoing => 'موافقة معلقة';

  @override
  String get messagesBlockAction => 'حظر';

  @override
  String get messagesApproveAction => 'موافقة';

  @override
  String get messagesRequestUnlockHint =>
      'يتم فتح الدردشة بعد أن يوافق المستلم على رسالتك الأولى.';

  @override
  String get messagesThreadConversationFallback => 'محادثة';

  @override
  String get messagesThreadLeaveGroupTitle => 'مغادرة المجموعة؟';

  @override
  String get messagesThreadLeaveGroupBody =>
      'ستتوقف عن تلقي الرسائل من هذه المجموعة.';

  @override
  String get messagesThreadBlockPersonTitle => 'حظر هذا الشخص؟';

  @override
  String get messagesThreadBlockPersonBody =>
      'لن تتمكن بعد الآن من تبادل الرسائل مع هذا الشخص.';

  @override
  String get messagesThreadPersonFallback => 'شخص';

  @override
  String get messagesThreadProfileInfoUnavailable =>
      'معلومات الملف الشخصي غير متاحة';

  @override
  String get messagesThreadParticipants => 'المشاركون';

  @override
  String get messagesThreadPeople => 'الأشخاص';

  @override
  String get messagesThreadDeleteForMe => 'حذف لي فقط';

  @override
  String get messagesThreadDeleteForEveryone => 'حذف للجميع';

  @override
  String get messagesThreadDeleteForEveryoneSubtitle =>
      'يزيلها لجميع المشاركين';

  @override
  String get messagesThreadSending => 'جارٍ الإرسال…';

  @override
  String get messagesThreadWaitingForApproval => 'بانتظار الموافقة';

  @override
  String get classroomsForwardSearchHint => 'ابحث في المحادثات';

  @override
  String get classroomsForwardNewChat => 'محادثة جديدة';

  @override
  String classroomsForwardLoadError(Object error) {
    return 'تعذر تحميل المحادثات: $error';
  }

  @override
  String get classroomsForwardNoChatsFound => 'لم يتم العثور على محادثات';

  @override
  String get classroomsForwardSectionClassrooms => 'الفصول';

  @override
  String get classroomsForwardSectionDirectMessages => 'الرسائل المباشرة';

  @override
  String get classroomsForwardCancel => 'إلغاء';

  @override
  String get classroomsForwardAction => 'إعادة توجيه';

  @override
  String classroomsForwardCount(Object count) {
    return 'إعادة توجيه ($count)';
  }

  @override
  String get markRead => 'تمييز كمقروء';

  @override
  String get markUnread => 'تمييز كغير مقروء';

  @override
  String get markAllRead => 'تمييز الكل كمقروء';

  @override
  String get filters => 'الفلاتر';

  @override
  String get source => 'المصدر';

  @override
  String get state => 'الحالة';

  @override
  String get allSources => 'كل المصادر';

  @override
  String get allStates => 'كل الحالات';

  @override
  String get unread => 'غير مقروء';

  @override
  String get read => 'مقروء';

  @override
  String get clear => 'مسح';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get earlier => 'سابقاً';

  @override
  String get openDetails => 'فتح التفاصيل';

  @override
  String get total => 'الإجمالي';

  @override
  String get local => 'محلي';

  @override
  String get server => 'الخادم';

  @override
  String get notificationsSourceSystem => 'النظام';

  @override
  String get notificationsHeroSubtitleStudent =>
      'مركز إشعاراتك للإعلانات وتحديثات الخادم والنشاط الدراسي المهم فور حدوثه.';

  @override
  String get notificationsHeroSubtitleTeacher =>
      'مركز إشعارات المعلم للإعلانات وتحديثات الخادم ونشاط المدرسة فور حدوثه.';

  @override
  String get notificationsFiltersSubtitle =>
      'ركّز حسب المصدر أو حالة القراءة لفرز التنبيهات بسرعة.';

  @override
  String get notificationsSearchSourcesHint => 'ابحث في المصادر';

  @override
  String notificationsShowingSummary(Object shown, Object total) {
    return 'يتم عرض $shown من أصل $total إشعارًا.';
  }

  @override
  String get notificationsEmptyForAccount =>
      'لا توجد إشعارات متاحة لهذا الحساب الآن.';

  @override
  String get notificationsEmptyFiltered =>
      'لا توجد إشعارات تطابق هذه الفلاتر الآن. امسح الفلاتر لرؤية كل التنبيهات.';

  @override
  String get notificationsEmpty => 'لا توجد إشعارات متاحة الآن.';

  @override
  String get notificationsNewBadge => 'جديد';

  @override
  String get notificationsUnavailable =>
      'لم يعد هذا الإشعار متاحًا. اسحب لتحديث البريد الوارد ثم حاول مرة أخرى.';

  @override
  String get notificationsSeverityCritical => 'حرج';

  @override
  String get notificationsSeverityWarning => 'تحذير';

  @override
  String get notificationsSeverityInfo => 'معلومة';

  @override
  String get announcementsLoadError =>
      'لم نتمكن من تحميل الإعلانات الآن. اسحب لتحديث أو حاول مرة أخرى.';

  @override
  String get announcementsLoadTimeout =>
      'الإعلانات تستغرق وقتاً طويلاً للتحميل. اسحب لتحديث أو حاول بعد قليل.';

  @override
  String get announcementsLoadNetwork =>
      'لم تتمكن الإعلانات من الاتصال الآن. تحقق من الاتصال وحاول مرة أخرى.';

  @override
  String get announcementsAudienceTeacher => 'معلم';

  @override
  String get announcementsAudienceAccount => 'حساب';

  @override
  String get announcementsAudienceTeacherWorkspace => 'مساحة عمل المعلم';

  @override
  String get announcementsLoadFailedTitle => 'لم يتمكن من تحميل الإعلانات';

  @override
  String get announcementsLoadFailedHint => 'اسحب لتحديث بعد استقرار الاتصال.';

  @override
  String announcementsHeroSubtitle(Object audience) {
    return 'الإعلانات المنشورة من المدرسة والمعلم والنظام المتاحة لـ $audience.';
  }

  @override
  String get announcementsLatestSourceLabel => 'أحدث مصدر';

  @override
  String get announcementsNone => 'لا يوجد';

  @override
  String announcementsUnreadCountTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count إعلانات غير مقروءة',
      one: 'إعلان واحد غير مقروء',
    );
    return '$_temp0';
  }

  @override
  String get announcementsAllReadTitle => 'تمت قراءة الكل';

  @override
  String announcementsEmptyForAudience(Object audience) {
    return 'لم يتم نشر إعلانات لـ $audience حتى الآن.';
  }

  @override
  String announcementsLatestBody(Object title) {
    return 'الأحدث: $title. اضغط عليها لقراءة المحتوى كاملاً.';
  }

  @override
  String get announcementsFiltersSubtitle =>
      'ضيّق صندوق الوارد حسب المصدر أو حالة القراءة لتركيز على ما يحتاج الاهتمام.';

  @override
  String get announcementsAllAnnouncements => 'كل الإعلانات';

  @override
  String get announcementsSearchStatesHint => 'غير مقروء / مقروء';

  @override
  String announcementsSummarySourceSegment(Object source) {
    return ' من $source';
  }

  @override
  String announcementsSummaryStateSegment(Object state) {
    return ' في $state';
  }

  @override
  String announcementsShowingSummary(
    Object shown,
    Object total,
    Object sourceSegment,
    Object stateSegment,
  ) {
    return 'عرض $shown من $total إعلان$sourceSegment$stateSegment.';
  }

  @override
  String get announcementsNoMatchTitle => 'لا توجد إعلانات تطابق هذه المرشحات';

  @override
  String get announcementsNoPublishedTitle => 'لا توجد إعلانات منشورة حتى الآن';

  @override
  String get announcementsNoMatchSubtitle =>
      'جرّب مصدراً مختلفاً أو العودة إلى كل الإعلانات لإظهار المزيد من العناصر.';

  @override
  String get announcementsClearFiltersHint =>
      'امسح المرشحات لرؤية كل شيء مرة أخرى.';

  @override
  String get announcementsPullToRefreshHint =>
      'اسحب لتحديث بعد نشر نشاط مدرسي جديد.';

  @override
  String get announcementsInboxTitle => 'صندوق الوارد';

  @override
  String get announcementsInboxSubtitle =>
      'تظهر العناوين فقط هنا للمراجعة السريعة. اضغط على أي عنصر لفتح محتوى الإعلان كاملاً.';

  @override
  String get meetingsLoadError =>
      'لا يمكننا تحميل الاجتماعات الآن. اسحب للتحديث أو حاول مرة أخرى.';

  @override
  String get meetingsLoadTimeout =>
      'تستغرق الاجتماعات وقتاً طويلاً في التحميل. اسحب للتحديث أو حاول مرة أخرى بعد قليل.';

  @override
  String get meetingsLoadNetwork =>
      'لا يمكن الاتصال بالاجتماعات الآن. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get meetingsHeroSubtitle =>
      'كل حصص الفصل الدراسي في عرض واحد نظيف، مع الروابط المرفقة وصفحة تفاصيل ملء الشاشة عند الحاجة إلى السياق.';

  @override
  String get meetingsJoinReadyMetric => 'جاهز للانضمام';

  @override
  String get meetingsNoLinkMetric => 'بدون رابط';

  @override
  String get meetingsNoPostedTitle => 'لم يتم نشر أي حصص دراسية حتى الآن';

  @override
  String get meetingsEmptyForAccount =>
      'لا توجد حصص دراسية في الفصل متاحة لحساب الطالب هذا الآن.';

  @override
  String meetingsLatestBody(Object title, Object updatedAt) {
    return 'تم تحديث $title في $updatedAt. افتحه للحصول على الرابط المرفق وسياق الفصل الدراسي.';
  }

  @override
  String get meetingsPullToRefreshHint => 'اسحب لأسفل للتحقق مرة أخرى.';

  @override
  String get meetingsFiltersSubtitle =>
      'ضيق القائمة حسب المادة أو ما إذا كانت الحصة تتضمن بالفعل رابطاً يمكنك فتحه.';

  @override
  String get meetingsAccessLabel => 'الوصول';

  @override
  String get meetingsAllMeetings => 'جميع الحصص';

  @override
  String get meetingsAccessReady => 'جاهز للانضمام';

  @override
  String get meetingsAccessNoLink => 'بدون رابط';

  @override
  String get meetingsAccessNoLinkYet => 'لا يوجد رابط حتى الآن';

  @override
  String get meetingsAccessSearchHint =>
      'جاهز للانضمام / لا يوجد رابط حتى الآن';

  @override
  String meetingsSummarySubjectSegment(Object subject) {
    return ' للمادة $subject';
  }

  @override
  String meetingsSummaryAccessSegment(Object state) {
    return ' في حالة $state';
  }

  @override
  String meetingsShowingSummary(
    Object shown,
    Object total,
    Object subjectSegment,
    Object accessSegment,
  ) {
    return 'عرض $shown من $total حصة$subjectSegment$accessSegment.';
  }

  @override
  String get meetingsNoMatchTitle => 'لا توجد حصص تطابق هذه الفلاتر';

  @override
  String get meetingsNoMatchSubtitle =>
      'جرب جميع المواد أو أدرج حصصاً بدون روابط لجلب المزيد من النتائج إلى القائمة.';

  @override
  String get meetingsListSubtitle =>
      'انقر على أي حصة لفتح عرض التفاصيل ملء الشاشة والقفز إلى رابطها المرفق عند توفره.';

  @override
  String meetingsDateTimeValue(Object date, Object time) {
    return '$date • $time';
  }

  @override
  String meetingsSharedByValue(Object name) {
    return 'شاركها $name';
  }

  @override
  String get meetingsPreviewFallback =>
      'افتح هذه الحصة لمشاهدة الرابط المرفق وأحدث تفاصيل الفصل الدراسي.';

  @override
  String get meetingsNoValidLinkAttached =>
      'لم يتم إرفاق أي رابط حصة صالح حتى الآن.';

  @override
  String get meetingsCouldNotOpenLink => 'لا يمكن فتح رابط الحصة.';

  @override
  String get meetingsNoLinkToCopy => 'لا توجد حصة رابط للنسخ حتى الآن.';

  @override
  String get meetingsLinkCopied => 'تم نسخ رابط الحصة.';

  @override
  String get meetingsUnavailableTitle => 'الحصة غير متاحة';

  @override
  String get meetingsUnavailableSubtitle =>
      'لم يمكن العثور على هذه الحصة في التغذية الحالية. قد تكون قد تم حذفها أو غير متاحة بدون اتصال.';

  @override
  String get meetingsUnavailableHint => 'عد للخلف وقم بتحديث قائمة الحصص.';

  @override
  String get meetingsNoLinkAttachedYet => 'لم يتم إرفاق رابط حتى الآن';

  @override
  String get meetingsAttachedLinkTitle => 'رابط الحصة المرفق';

  @override
  String get meetingsAttachedLinkMissingBody =>
      'هذه الحصة مرئية في تغذية فصلك الدراسي، لكن لا يوجد عنوان URL صالح مرفق في حمولة الطالب الحالية.';

  @override
  String get meetingsDetailsTitle => 'تفاصيل الحصة';

  @override
  String get meetingsDetailsSubtitle =>
      'كل ما يتعلق بالطالب والمتاح حالياً في حمولة الحصة الدراسية في الفصل.';

  @override
  String get meetingsDetailClassroomLabel => 'الفصل الدراسي';

  @override
  String get meetingsSharedByLabel => 'شاركها';

  @override
  String get meetingsIdLabel => 'معرف الحصة';

  @override
  String get meetingsAttachedLinkSubtitle =>
      'استخدم العنوان المرفق للانضمام أو نسخ رابط الحصة عندما يوفره فصلك الدراسي.';

  @override
  String get meetingsOpening => 'جاري الفتح';

  @override
  String get meetingsOpenLink => 'فتح الرابط';

  @override
  String get meetingsCopyLink => 'نسخ الرابط';

  @override
  String get meetingsAccessPanelTitle => 'وصول الحصة';

  @override
  String get meetingsAccessPanelReadyBody =>
      'افتح عنوان URL المرفق في متصفحك أو تطبيق الاجتماع.';

  @override
  String get meetingsJoinAction => 'انضم';

  @override
  String get announcementsDetailLoadFailedHint =>
      'العودة وحاول تحديث صندوق الوارد للإعلانات.';

  @override
  String get announcementsUnavailableTitle => 'الإعلان غير متاح';

  @override
  String announcementsUnavailableSubtitle(Object audience) {
    return 'هذا الإعلان لم يعد متاحاً في الخلاصة المنشورة لـ $audience.';
  }

  @override
  String get announcementsUnavailableHint =>
      'العودة إلى صندوق الوارد للمتابعة.';

  @override
  String announcementsPublishedReadStateBody(Object audience) {
    return 'تم نشر هذا الإعلان لـ $audience وحالة القراءة مخزنة محلياً على هذا الجهاز.';
  }

  @override
  String get announcementsDetailsTitle => 'تفاصيل الإعلان';

  @override
  String get announcementsDetailsSubtitle =>
      'البيانات الوصفية المنشورة لهذا الإعلان وحالة القراءة الحالية.';

  @override
  String get announcementsSeverityLabel => 'الخطورة';

  @override
  String get announcementsCreatedLabel => 'تم الإنشاء';

  @override
  String get announcementsIdLabel => 'معرّف الإعلان';

  @override
  String get announcementsFullContentTitle => 'المحتوى الكامل';

  @override
  String get announcementsFullContentSubtitle =>
      'يظهر نص الإعلان كاملاً هنا بعد فتح العنصر من صندوق الوارد.';

  @override
  String get announcementsReadStateTitle => 'حالة القراءة';

  @override
  String get announcementsReadStateBodyRead =>
      'هذا الإعلان مضروب بعلامة مقروء على هذا الجهاز.';

  @override
  String get announcementsReadStateBodyUnread =>
      'هذا الإعلان لا يزال غير مقروء على هذا الجهاز.';

  @override
  String get alertsTitle => 'التنبيهات';

  @override
  String get alertsSubtitle =>
      'هذه الصفحة مخصصة للأشياء التي تحتاج إلى اهتمام الآن، وليس مجرد تحديثات عامة.';

  @override
  String get alertsAttendanceTitle => 'الحضور يحتاج إلى انتباه';

  @override
  String alertsAttendanceBody(Object rate) {
    return 'معدل حضورك هو $rate%. بضع حصص مفقودة قد تتراكم بسرعة.';
  }

  @override
  String get alertsWeakestSubjectTitle => 'إشارة أضعف مادة';

  @override
  String alertsWeakestSubjectBody(Object subject) {
    return 'تحتاج مادة $subject إلى أكبر قدر من الانتباه الآن بناءً على أحدث درجاتك.';
  }

  @override
  String get alertsPracticeWeakAreaTitle => 'منطقة ضعف في التدريب';

  @override
  String alertsPracticeWeakAreaBody(Object topic, Object subject) {
    return '$topic في $subject هو أوضح موضوع ضعيف لديك الآن.';
  }

  @override
  String get alertsPracticeTrendDroppedTitle => 'انخفض اتجاه التدريب';

  @override
  String get alertsPracticeTrendDroppedBody =>
      'أداؤك خلال 7 أيام أقل من خط الأساس خلال 30 يومًا. تمهّل وراجع الأساسيات قبل زيادة الضغط.';

  @override
  String get alertsEmpty =>
      'أنت بخير الآن. عندما يظهر شيء يحتاج إلى اهتمام عاجل، سيظهر هنا.';

  @override
  String get student => 'طالب';

  @override
  String get classroomDetailPhoto => 'صورة';

  @override
  String get classroomDetailVoiceNote => 'ملاحظة صوتية';

  @override
  String get classroomDetailVideo => 'فيديو';

  @override
  String get classroomDetailFile => 'ملف';

  @override
  String get classroomDetailEmptyValue => '(فارغ)';

  @override
  String get classroomDetailAttachmentUnavailable => 'المرفق غير متاح.';

  @override
  String get classroomDetailAudioUnavailable => 'الصوت غير متاح.';

  @override
  String get classroomDetailCouldNotOpenAttachment => 'تعذر فتح المرفق.';

  @override
  String get classroomDetailVoiceMessage => 'رسالة صوتية';

  @override
  String get classroomDetailVideoFile => 'ملف فيديو';

  @override
  String get classroomDetailAttachedFile => 'ملف مرفق';

  @override
  String get classroomDetailAttachment => 'مرفق';

  @override
  String get classroomDetailPinAction => 'تثبيت';

  @override
  String get classroomDetailUnpinAction => 'إلغاء التثبيت';

  @override
  String get classroomDetailMessageInfoTitle => 'معلومات الرسالة';

  @override
  String get classroomDetailForwardedSingle => 'تمت إعادة التوجيه';

  @override
  String classroomDetailForwardedMultiple(Object count) {
    return 'تمت إعادة توجيه $count رسائل';
  }

  @override
  String get classroomDetailCannotForwardPending =>
      'لا يمكن إعادة التوجيه إلى دردشة طلب قبل الموافقة عليها';

  @override
  String get classroomDetailCouldNotForwardSelected =>
      'تعذر إعادة توجيه الرسائل المحددة';

  @override
  String classroomDetailSelectedCount(Object count) {
    return 'تم تحديد $count';
  }

  @override
  String classroomDetailDeleteCount(Object count) {
    return 'حذف ($count)';
  }

  @override
  String get classroomDetailSelectAllTooltip => 'تحديد الكل';

  @override
  String get classroomDetailCancelTooltip => 'إلغاء';

  @override
  String get classroomDetailMicrophoneAccessTitle =>
      'يلزم الوصول إلى الميكروفون';

  @override
  String get classroomDetailMicrophoneAccessBody =>
      'يرجى السماح بالوصول إلى الميكروفون من الإعدادات -> ClassMate لإرسال الملاحظات الصوتية.';

  @override
  String get classroomDetailOpenSettingsAction => 'فتح الإعدادات';

  @override
  String classroomDetailForwardTargetNext(Object label) {
    return 'اختيار جهة إعادة التوجيه التالية: $label';
  }

  @override
  String get classroomDetailEditMessageTitle => 'تعديل الرسالة';

  @override
  String get classroomDetailEditMessageHint => 'عدّل رسالتك...';

  @override
  String get classroomDetailLeaveClassroomTitle => 'مغادرة الفصل؟';

  @override
  String get classroomDetailLeaveClassroomBody => 'ستتم إزالتك من هذا الفصل.';

  @override
  String get classroomDetailLeaveAction => 'مغادرة';

  @override
  String get classroomDetailNoAssignmentsTitle => 'لا توجد واجبات بعد';

  @override
  String get classroomDetailNoAssignmentsSubtitle =>
      'لا توجد واجبات في هذا الفصل حالياً.';

  @override
  String get classroomDetailAssignmentFallback => 'واجب';

  @override
  String get classroomDetailNoMaterialsTitle => 'لا توجد مواد بعد';

  @override
  String get classroomDetailNoMaterialsSubtitle =>
      'لا توجد مواد في هذا الفصل حالياً.';

  @override
  String get classroomDetailMaterialFallback => 'مادة';

  @override
  String get classroomDetailNoMeetingsTitle => 'لا توجد اجتماعات بعد';

  @override
  String get classroomDetailNoMeetingsSubtitle =>
      'لا توجد اجتماعات في هذا الفصل حالياً.';

  @override
  String get classroomDetailMeetingFallback => 'اجتماع';

  @override
  String get classroomDetailCouldNotLoadPeople => 'تعذر تحميل الأشخاص';

  @override
  String get classroomDetailNoPeopleTitle => 'لا يوجد أشخاص بعد';

  @override
  String get classroomDetailNoPeopleSubtitle => 'لا يظهر أحد في هذا الفصل بعد.';

  @override
  String get classroomDetailTabChat => 'الدردشة';

  @override
  String get classroomDetailTabMaterials => 'المواد';

  @override
  String get classroomDetailTabPeople => 'الأشخاص';

  @override
  String get classroomChatMediaSendPhoto => 'إرسال صورة';

  @override
  String get classroomChatMediaSendPhotoSubtitle => 'شارك صورة في دردشة الفصل';

  @override
  String get classroomChatMediaSendVoiceMessage => 'إرسال رسالة صوتية';

  @override
  String get classroomChatMediaSendVoiceMessageSubtitle =>
      'سجل وأرسل ملاحظة صوتية';

  @override
  String get classroomDetailCouldNotLoadTab => 'تعذر تحميل علامة التبويب';

  @override
  String get classroomDetailDeletedByYou => 'لقد حذفت هذه الرسالة';

  @override
  String get classroomDetailDeletedMessage => 'تم حذف هذه الرسالة';

  @override
  String get practiceSetupDifficultyEasy => 'سهل';

  @override
  String get practiceSetupDifficultyMedium => 'متوسط';

  @override
  String get practiceSetupDifficultyHard => 'صعب';

  @override
  String get practiceSetupDifficultyOlympiad => 'أولمبياد';

  @override
  String get practiceSetupDifficultyAdaptive => 'تكيفي';

  @override
  String get practiceSetupModeLabelPractice => 'تدريب';

  @override
  String get practiceSetupModeLabelFlashcards => 'بطاقات';

  @override
  String get practiceSetupModeLabelSpeedRound => 'جولة سريعة';

  @override
  String get practiceSetupModeLabelExamPrep => 'تحضير اختبار';

  @override
  String get practiceSetupModeLabelConceptBuilder => 'بناء المفهوم';

  @override
  String get practiceSetupModeLabelAdaptive => 'تكيفي';

  @override
  String get practiceSetupModeLabelBagrut => 'بجروت';

  @override
  String get practiceSetupModeSubtitlePractice => 'تدريب يومي متوازن';

  @override
  String get practiceSetupModeSubtitleFlashcards => 'اكشف وتذكّر بنفسك';

  @override
  String get practiceSetupModeSubtitleSpeedRound => 'تمرين ضغط سريع';

  @override
  String get practiceSetupModeSubtitleExamPrep => 'تدفق هادئ شبيه بالاختبار';

  @override
  String get practiceSetupModeSubtitleConceptBuilder => 'المفهوم أولاً ثم الحل';

  @override
  String get practiceSetupModeSubtitleAdaptive => 'الصعوبة تتغير مباشرة';

  @override
  String get practiceSetupModeSubtitleBagrut => 'أسلوب رسمي صارم';

  @override
  String get practiceSetupModeHelpPractice =>
      'وضع متوازن: حل، تحقق، اشرح، ثم واصل.';

  @override
  String get practiceSetupModeHelpFlashcards =>
      'تعمل البطاقات بشكل أفضل عندما تحاول التذكر قبل الكشف.';

  @override
  String get practiceSetupModeHelpSpeedRound =>
      'الجولة السريعة تدرب الاستدعاء السريع. تحرك بسرعة وثق بحدسك القوي.';

  @override
  String get practiceSetupModeHelpExamPrep =>
      'تحضير الاختبار أهدأ وأكثر رسمية، مثل حصة مدرسية حقيقية.';

  @override
  String get practiceSetupModeHelpConceptBuilder =>
      'بناء المفهوم يعلّم الفكرة أولاً ثم يطلب منك تطبيقها.';

  @override
  String get practiceSetupModeHelpAdaptive =>
      'الوضع التكيفي يغيّر مستوى التحدي حسب أدائك.';

  @override
  String get practiceSetupModeHelpBagrut =>
      'يركز وضع البجروت على الحل والمراجعة بأسلوب اختبار صارم.';

  @override
  String get practiceSetupModeInfoTitle => 'كيف يعمل كل وضع';

  @override
  String get practiceSetupHeroTitle => 'ابدأ جلسة';

  @override
  String get practiceSetupHeroSubtitle => 'اختر الوضع والتوقيت والصعوبة.';

  @override
  String get practiceSetupInfiniteLives => 'محاولات لا نهائية';

  @override
  String practiceSetupLivesCount(Object count) {
    return '$count محاولات';
  }

  @override
  String get practiceSetupAiTiming => 'توقيت الذكاء الاصطناعي';

  @override
  String practiceSetupSecondsShort(Object seconds) {
    return '$secondsث';
  }

  @override
  String practiceSetupQuestionsCount(Object count) {
    return '$count أسئلة';
  }

  @override
  String practiceSetupSummarySubject(Object subject) {
    return 'المادة: $subject';
  }

  @override
  String practiceSetupSummaryTopic(Object topic) {
    return 'الموضوع: $topic';
  }

  @override
  String practiceSetupSummaryMode(Object mode) {
    return 'الوضع: $mode';
  }

  @override
  String practiceSetupSummaryDifficulty(Object difficulty) {
    return 'الصعوبة: $difficulty';
  }

  @override
  String practiceSetupSummaryQuestions(Object count) {
    return 'الأسئلة: $count';
  }

  @override
  String practiceSetupSummaryTiming(Object timing) {
    return 'التوقيت: $timing';
  }

  @override
  String practiceSetupSummaryLives(Object lives) {
    return 'المحاولات: $lives';
  }

  @override
  String get practiceSetupSectionSubjectTopic => 'المادة والموضوع';

  @override
  String get practiceSetupFieldSubject => 'المادة';

  @override
  String get practiceSetupFieldSubjectHint => 'اختر المادة';

  @override
  String get practiceSetupChooseSubject => 'اختر المادة';

  @override
  String get practiceSetupFieldCustomSubject => 'مادة مخصصة';

  @override
  String get practiceSetupFieldCustomSubjectHint => 'اكتب مادّتك الخاصة';

  @override
  String get practiceSetupDialogCustomSubjectTitle => 'مادة مخصصة';

  @override
  String get practiceSetupDialogEnterSubject => 'أدخل المادة';

  @override
  String get practiceSetupUseAction => 'استخدام';

  @override
  String get practiceSetupFieldTopic => 'الموضوع';

  @override
  String get practiceSetupFieldTopicHint => 'اختر موضوعاً فرعياً';

  @override
  String get practiceSetupChooseTopic => 'اختر الموضوع';

  @override
  String get practiceSetupFieldCustomTopic => 'موضوع مخصص';

  @override
  String get practiceSetupFieldCustomTopicHint => 'اكتب موضوعك الخاص';

  @override
  String get practiceSetupDialogCustomTopicTitle => 'موضوع مخصص';

  @override
  String get practiceSetupDialogEnterTopic => 'أدخل الموضوع';

  @override
  String get practiceSubjectMath => 'الرياضيات';

  @override
  String get practiceSubjectPhysics => 'الفيزياء';

  @override
  String get practiceSubjectComputerScience => 'علوم الحاسوب';

  @override
  String get practiceSubjectChemistry => 'الكيمياء';

  @override
  String get practiceSubjectBiology => 'الأحياء';

  @override
  String get practiceSubjectEnglish => 'الإنجليزية';

  @override
  String get practiceSubjectArabic => 'العربية';

  @override
  String get practiceSubjectHebrew => 'العبرية';

  @override
  String get practiceSubjectGeneralKnowledge => 'معرفة عامة';

  @override
  String get practiceTopicAllTopics => 'كل المواضيع';

  @override
  String get practiceTopicAlgebra => 'الجبر';

  @override
  String get practiceTopicLinearEquations => 'المعادلات الخطية';

  @override
  String get practiceTopicQuadraticEquations => 'المعادلات التربيعية';

  @override
  String get practiceTopicFunctions => 'الدوال';

  @override
  String get practiceTopicGeometry => 'الهندسة';

  @override
  String get practiceTopicTriangles => 'المثلثات';

  @override
  String get practiceTopicCircles => 'الدوائر';

  @override
  String get practiceTopicAnalyticGeometry => 'الهندسة التحليلية';

  @override
  String get practiceTopicTrigonometry => 'حساب المثلثات';

  @override
  String get practiceTopicProbability => 'الاحتمالات';

  @override
  String get practiceTopicStatistics => 'الإحصاء';

  @override
  String get practiceTopicSequences => 'المتتاليات';

  @override
  String get practiceTopicCalculus => 'التفاضل والتكامل';

  @override
  String get practiceTopicLimits => 'النهايات';

  @override
  String get practiceTopicDerivatives => 'المشتقات';

  @override
  String get practiceTopicMechanics => 'الميكانيكا';

  @override
  String get practiceTopicKinematics => 'الحركة';

  @override
  String get practiceTopicNewtonLaws => 'قوانين نيوتن';

  @override
  String get practiceTopicForces => 'القوى';

  @override
  String get practiceTopicEnergy => 'الطاقة';

  @override
  String get practiceTopicMomentum => 'الزخم';

  @override
  String get practiceTopicElectricity => 'الكهرباء';

  @override
  String get practiceTopicElectricField => 'المجال الكهربائي';

  @override
  String get practiceTopicCircuits => 'الدوائر الكهربائية';

  @override
  String get practiceTopicWaves => 'الموجات';

  @override
  String get practiceTopicOptics => 'البصريات';

  @override
  String get practiceTopicThermodynamics => 'الديناميكا الحرارية';

  @override
  String get practiceTopicConditions => 'الشروط';

  @override
  String get practiceTopicBooleanLogic => 'المنطق البولياني';

  @override
  String get practiceTopicIfElse => 'إذا / وإلا';

  @override
  String get practiceTopicNestedConditions => 'شروط متداخلة';

  @override
  String get practiceTopicLoops => 'الحلقات';

  @override
  String get practiceTopicVariables => 'المتغيرات';

  @override
  String get practiceTopicArrays => 'المصفوفات';

  @override
  String get practiceTopicStrings => 'السلاسل النصية';

  @override
  String get practiceTopicAlgorithms => 'الخوارزميات';

  @override
  String get practiceTopicComplexity => 'التعقيد';

  @override
  String get practiceTopicRecursion => 'الاستدعاء الذاتي';

  @override
  String get practiceTopicAtoms => 'الذرات';

  @override
  String get practiceTopicPeriodicTable => 'الجدول الدوري';

  @override
  String get practiceTopicChemicalBonds => 'الروابط الكيميائية';

  @override
  String get practiceTopicReactions => 'التفاعلات';

  @override
  String get practiceTopicStoichiometry => 'الحسابات الكيميائية';

  @override
  String get practiceTopicAcidsAndBases => 'الأحماض والقواعد';

  @override
  String get practiceTopicOrganicChemistry => 'الكيمياء العضوية';

  @override
  String get practiceTopicCells => 'الخلايا';

  @override
  String get practiceTopicGenetics => 'الوراثة';

  @override
  String get practiceTopicHumanBody => 'جسم الإنسان';

  @override
  String get practiceTopicEcology => 'علم البيئة';

  @override
  String get practiceTopicEvolution => 'التطور';

  @override
  String get practiceTopicSystems => 'الأنظمة';

  @override
  String get practiceTopicGrammar => 'القواعد';

  @override
  String get practiceTopicReadingComprehension => 'فهم المقروء';

  @override
  String get practiceTopicVocabulary => 'المفردات';

  @override
  String get practiceTopicTenses => 'الأزمنة';

  @override
  String get practiceTopicWriting => 'الكتابة';

  @override
  String get practiceTopicRhetoric => 'البلاغة';

  @override
  String get practiceSetupSectionMode => 'الوضع';

  @override
  String get practiceSetupSectionDifficulty => 'الصعوبة';

  @override
  String get practiceSetupSectionControls => 'عناصر التحكم في الجلسة';

  @override
  String get practiceSetupQuestionsTitle => 'الأسئلة';

  @override
  String get practiceSetupQuestionsCaption =>
      'عدد الأسئلة المولدة التي تريد تضمينها';

  @override
  String get practiceSetupTimingTitle => 'التوقيت';

  @override
  String get practiceSetupTimingCaption =>
      'اختر النطاق أولاً، ثم الذكاء الاصطناعي أو وقتك الخاص أو اللانهائي.';

  @override
  String get practiceSetupTimingScopePerQuestion => 'لكل سؤال';

  @override
  String get practiceSetupTimingScopeWholeQuiz => 'للاختبار كله';

  @override
  String get practiceSetupTimingModeAi => 'ذكاء اصطناعي';

  @override
  String get practiceSetupTimingModeMyTime => 'وقتي';

  @override
  String get practiceSetupTimingModeInfinite => 'لا نهائي';

  @override
  String get practiceSetupTimingCustomPerQuestionTitle => 'ثوانٍ لكل سؤال';

  @override
  String get practiceSetupTimingCustomPerQuestionCaption =>
      'مؤقتك الخاص لكل سؤال';

  @override
  String get practiceSetupTimingCustomQuizMinutesTitle => 'دقائق الاختبار';

  @override
  String get practiceSetupTimingCustomQuizMinutesCaption =>
      'مؤقتك الخاص للاختبار كله';

  @override
  String get practiceSetupInfiniteLivesTitle => 'محاولات لا نهائية';

  @override
  String get practiceSetupInfiniteLivesSubtitle =>
      'لا تُنهِ الجلسة بسبب الإجابات الخاطئة';

  @override
  String get practiceSetupLivesTitle => 'المحاولات';

  @override
  String get practiceSetupLivesCaption =>
      'الأخطاء المسموح بها قبل انتهاء الجلسة';

  @override
  String get practiceSetupTooltipHistory => 'سجل التدريب';

  @override
  String get practiceHistoryTitle => 'سجل التدريب';

  @override
  String get practiceHistoryClearTooltip => 'مسح السجل';

  @override
  String get practiceHistoryClearConfirmTitle => 'مسح سجل الممارسة؟';

  @override
  String get practiceHistoryClearConfirmBody =>
      'هذا يزيل جميع جلسات التدريب المحفوظة من هذا الجهاز.';

  @override
  String get practiceHistoryLoadError => 'تعذر تحميل سجل الممارسة الآن.';

  @override
  String get practiceHistoryErrorPrefix => 'خطأ:';

  @override
  String get practiceHistoryEmpty => 'لا توجد جلسات ممارسة بعد.';

  @override
  String get practiceHistoryDeleteConfirmTitle => 'حذف هذه الجلسة؟';

  @override
  String get practiceHistoryDeleteConfirmBody =>
      'هذا يزيل جلسة الممارسة المحفوظة فقط.';

  @override
  String get practiceHistoryOpenReview => 'فتح المراجعة';

  @override
  String get practiceHistoryDeleteSession => 'حذف الجلسة';

  @override
  String get practiceHistoryDebugTitle => 'تصحيح سجل الممارسة';

  @override
  String get practiceAnalyticsTitle => 'تحليلات الممارسة';

  @override
  String get practiceAnalyticsSectionOverall => 'نظرة عامة';

  @override
  String get practiceAnalyticsRecentSessionsTitle => 'الجلسات الأخيرة';

  @override
  String practiceAnalyticsRecentSessionsSummary(
    Object sessions,
    Object correct,
    Object answered,
    Object accuracy,
    Object xp,
  ) {
    return '$sessions جلسة • $correct/$answered صحيحة • %$accuracy • خبرة $xp';
  }

  @override
  String get practiceAnalyticsSectionWeakestTopics => 'أضعف المواضيع';

  @override
  String get practiceAnalyticsSectionStrongestTopics => 'أقوى المواضيع';

  @override
  String get practiceAnalyticsSectionModePerformance => 'أداء الأوضاع';

  @override
  String get practiceAnalyticsNoTopicData => 'لا توجد بيانات مواضيع بعد';

  @override
  String get practiceAnalyticsNoModeData => 'لا توجد بيانات أوضاع بعد';

  @override
  String get savedQuestionsTopSubjectNone => 'لم تظهر بعد';

  @override
  String get savedQuestionsHeroSubtitle =>
      'الأسئلة التي حفظتها أثناء التدريب يجب أن تكون سهلة العودة إليها. هذه الصفحة هي مركز إعادة المحاولة النظيف لها.';

  @override
  String get savedQuestionsSavedMetric => 'محفوظ';

  @override
  String get savedQuestionsTopSubjectMetric => 'أفضل موضوع';

  @override
  String get savedQuestionsQuickActionsSubtitle =>
      'انتقل مباشرة إلى التدريب أو استعرض حلول المجتمع.';

  @override
  String get savedQuestionsOpenPractice => 'افتح التدريب';

  @override
  String get savedQuestionsOpenPracticeSubtitle =>
      'ابدأ جلسة جديدة واستمر في بناء الزخم';

  @override
  String get savedQuestionsOpenSolutions => 'افتح الحلول';

  @override
  String get savedQuestionsOpenSolutionsSubtitle =>
      'استعرض الحلول المرفوعة حسب الموضوع والكتاب والصفحة والسؤال';

  @override
  String get savedQuestionsQueueTitle => 'طابور الحفظ الخاص بك';

  @override
  String get savedQuestionsQueueSubtitle =>
      'الأسئلة التي تحفظها في التدريب تظهر هنا حتى تتمكن من إعادة فتحها بسرعة والاستمرار في العمل على نقاط ضعفك.';

  @override
  String get savedQuestionsEmptyTitle => 'لا توجد أسئلة محفوظة بعد';

  @override
  String get savedQuestionsEmptySubtitle =>
      'احفظ سؤالاً من التدريب لإعادة زيارته لاحقاً أو فتح الحلول ذات الصلة وتتبع المواضيع التي لا تزال بحاجة إلى عمل.';

  @override
  String get savedQuestionsClearAction => 'مسح الأسئلة المحفوظة';

  @override
  String get savedQuestionsWhyItWorks => 'لماذا يعمل';

  @override
  String savedQuestionsHoursTarget(Object count) {
    return 'الهدف: $count ساعة';
  }

  @override
  String savedQuestionsMinutesTarget(Object count) {
    return 'الهدف: $count دقيقة';
  }

  @override
  String savedQuestionsSecondsTarget(Object count) {
    return 'الهدف: $count ثانية';
  }

  @override
  String get practiceSetupTooltipAnalytics => 'تحليلات التدريب';

  @override
  String get practiceSetupStopGenerating => 'إيقاف التوليد';

  @override
  String get practiceSetupGenerating => 'جارٍ التوليد...';

  @override
  String get practiceSetupStartSession => 'ابدأ الجلسة';

  @override
  String get practiceSetupSearchHint => 'ابحث...';

  @override
  String get practiceSessionModeDescriptionPractice =>
      'حل متوازن مع تحقق فوري وملاحظات مباشرة.';

  @override
  String get practiceSessionModeDescriptionFlashcards =>
      'وضع يعتمد على الذاكرة للاسترجاع السريع والثبات.';

  @override
  String get practiceSessionModeDescriptionSpeedRound =>
      'تمارين ضغط سريعة وخفيفة ومؤقتة.';

  @override
  String get practiceSessionModeDescriptionExamPrep =>
      'حل بطابع اختبار رسمي وبإيقاع أقل لعبية.';

  @override
  String get practiceSessionModeDescriptionConceptBuilder =>
      'افهم الفكرة أولاً ثم حل ضمن السياق.';

  @override
  String get practiceSessionModeDescriptionAdaptive =>
      'تتغير الصعوبة حسب أدائك.';

  @override
  String get practiceSessionModeDescriptionBagrut =>
      'تدفق بجروت رسمي بسؤال واحد على النمط الرسمي.';

  @override
  String get practiceSessionLoadingPractice => 'جارٍ تجهيز جلسة التدريب';

  @override
  String get practiceSessionLoadingFlashcards => 'جارٍ خلط البطاقات';

  @override
  String get practiceSessionLoadingSpeedRound => 'جارٍ بدء الجولة السريعة';

  @override
  String get practiceSessionLoadingExamPrep => 'جارٍ تجهيز جلسة الاختبار';

  @override
  String get practiceSessionLoadingConceptBuilder => 'جارٍ تحميل مدرب المفاهيم';

  @override
  String get practiceSessionLoadingAdaptive => 'جارٍ تخصيص التحدي لك';

  @override
  String get practiceSessionLoadingBagrut => 'جارٍ تجهيز مجموعة البجروت';

  @override
  String get practiceSessionLoadingDefault => 'جارٍ تجهيز الجلسة';

  @override
  String practiceSessionCompleteTitle(Object mode) {
    return 'اكتمل $mode';
  }

  @override
  String get practiceSessionMetricAnswered => 'تمت الإجابة';

  @override
  String get practiceSessionMetricCorrect => 'صحيح';

  @override
  String get practiceSessionMetricWrong => 'خاطئ';

  @override
  String get practiceSessionMetricAccuracy => 'الدقة';

  @override
  String get practiceSessionMetricTotal => 'الإجمالي';

  @override
  String get practiceSessionMetricXp => 'XP';

  @override
  String get practiceSessionMetricStreak => 'السلسلة';

  @override
  String get practiceSessionReviewLayoutStacked => 'مكدس';

  @override
  String get practiceSessionReviewLayoutFocus => 'تركيز';

  @override
  String get practiceSessionFilterAll => 'الكل';

  @override
  String get practiceSessionFilterWrong => 'الخاطئة';

  @override
  String get practiceSessionFilterCorrect => 'الصحيحة';

  @override
  String get practiceSessionReviewTitle => 'مراجعة الجلسة';

  @override
  String get practiceSessionNoQuestionsForFilter =>
      'لا توجد أسئلة تطابق هذا الفلتر بعد.';

  @override
  String get practiceSessionNoAnswer => 'لا توجد إجابة';

  @override
  String get practiceSessionUnknownAnswer => 'غير معروف';

  @override
  String get practiceSessionReflectionTitle => 'مراجعة ذاتية';

  @override
  String get practiceSessionReflectionKnewIt => 'كنت أعرفها';

  @override
  String get practiceSessionReflectionReviewAgain => 'راجع مرة أخرى';

  @override
  String get practiceSessionBackOfCard => 'خلف البطاقة';

  @override
  String get practiceSessionYourAnswer => 'إجابتك';

  @override
  String get practiceSessionCorrectAnswer => 'الإجابة الصحيحة';

  @override
  String get practiceSessionExplanation => 'الشرح';

  @override
  String get practiceSessionBackToSetup => 'العودة إلى الإعداد';

  @override
  String get practiceSessionGeneralTopic => 'عام';

  @override
  String practiceSessionQuestionProgress(Object current, Object total) {
    return 'السؤال $current من $total';
  }

  @override
  String get practiceSessionMetricTime => 'الوقت';

  @override
  String practiceSessionMatchmakingDifficulty(Object difficulty) {
    return 'الصعوبة: $difficulty';
  }

  @override
  String get practiceModeActionPrevious => 'السابق';

  @override
  String get practiceModeActionCheckAnswer => 'تحقّق من الإجابة';

  @override
  String get practiceModeActionNext => 'التالي';

  @override
  String get practiceModeActionNextQuestion => 'السؤال التالي';

  @override
  String get practiceModeActionEndSession => 'إنهاء الجلسة';

  @override
  String get practiceModeActionEndQuestion => 'إنهاء السؤال';

  @override
  String get practiceModeActionEndExam => 'إنهاء الاختبار';

  @override
  String get practiceModeActionNovaHint => 'تلميح NOVA';

  @override
  String get practiceModeActionReveal => 'إظهار';

  @override
  String get practiceModeActionShowSolution => 'إظهار الحل';

  @override
  String get practiceModeActionHideSolution => 'إخفاء الحل';

  @override
  String get practiceModeActionLockIn => 'ثبّت الإجابة';

  @override
  String get practiceModeActionCheckAdapt => 'تحقّق وتكيّف';

  @override
  String get practiceModeActionContinue => 'متابعة';

  @override
  String get practiceModeActionSolveIt => 'حلّه';

  @override
  String get practiceModeActionNextConcept => 'المفهوم التالي';

  @override
  String get practiceModeCardFront => 'وجه البطاقة';

  @override
  String get practiceModeRecallSummary => 'ملخص التذكر';

  @override
  String get practiceModeFeelingPrompt => 'كيف كان ذلك؟';

  @override
  String get practiceModeFeelingAgain => 'مرة أخرى';

  @override
  String get practiceModeFeelingHard => 'صعب';

  @override
  String get practiceModeFeelingGood => 'جيد';

  @override
  String get practiceModeFeelingEasy => 'سهل';

  @override
  String get practiceModeSpeedRoundBanner =>
      'جولة السرعة · قرارات سريعة وزخم فوري';

  @override
  String get practiceModeFastFeedback => 'ملاحظات سريعة';

  @override
  String get practiceModeExamPrepBanner =>
      'تحضير الاختبار · تصميم أهدأ والإجابات تُراجع بعد المتابعة';

  @override
  String get practiceModeReview => 'مراجعة';

  @override
  String get practiceModeBagrutBanner => 'وضع البجروت · تدفق ورقة رسمي';

  @override
  String get practiceModeOfficialSolution => 'حل بأسلوب رسمي';

  @override
  String get practiceModeAdaptiveWarmup => 'صعوبة الإحماء';

  @override
  String get practiceModeAdaptiveTrendingUp => 'الصعوبة ترتفع';

  @override
  String get practiceModeAdaptiveEasingDown => 'الصعوبة تنخفض';

  @override
  String get practiceModeAdaptiveSteady => 'الصعوبة مستقرة';

  @override
  String get practiceModeAdaptiveFeedback => 'ملاحظات تكيفية';

  @override
  String get practiceModeConceptFirst => 'المفهوم أولاً';

  @override
  String get practiceModeNowSolveIt => 'الآن حلّه';

  @override
  String get practiceModeConceptTitle => 'مفهوم';

  @override
  String get practiceModeFeedbackCorrect => 'صحيح';

  @override
  String get practiceModeFeedbackNotQuite => 'ليس تماماً';

  @override
  String get practiceModeFallbackQuestion => 'سؤال';

  @override
  String get practiceModeNoExplanationYet => 'لا يوجد شرح متاح بعد.';

  @override
  String get teacherGradesAssessmentCreated => 'تم إنشاء التقييم';

  @override
  String get teacherGradesEditAssessmentTitle => 'تعديل التقييم';

  @override
  String get teacherGradesFieldTitle => 'العنوان';

  @override
  String get teacherGradesFieldDate => 'التاريخ (YYYY-MM-DD)';

  @override
  String get teacherGradesFieldMaxGrade => 'الدرجة القصوى';

  @override
  String get teacherGradesAssessmentUpdated => 'تم تحديث التقييم';

  @override
  String get teacherGradesDeleteAssessmentTitle => 'حذف التقييم؟';

  @override
  String teacherGradesDeleteAssessmentBody(Object title) {
    return 'سيؤدي هذا إلى إزالة $title وسجل درجاته من مساحة المعلم.';
  }

  @override
  String get teacherGradesDeleteAction => 'حذف';

  @override
  String get teacherGradesAssessmentDeleted => 'تم حذف التقييم';

  @override
  String get teacherGradesRosterLinkError =>
      'هذا التقييم غير مرتبط بقائمة فصل.';

  @override
  String get teacherGradesSaved => 'تم حفظ الدرجات';

  @override
  String get teacherGradesSubtitle =>
      'أنشئ التقييمات واحفظ الدرجات مقابل قائمة الفصل المباشرة.';

  @override
  String get teacherGradesCreateAssessmentTitle => 'إنشاء تقييم';

  @override
  String get teacherGradesFieldCourse => 'المقرر';

  @override
  String get teacherGradesCreateAction => 'إنشاء';

  @override
  String get teacherGradesNoStudentsLoaded =>
      'لم يتم تحميل أي طلاب لهذا التقييم.';

  @override
  String get teacherGradesFieldGrade => 'الدرجة';

  @override
  String teacherGradesMaxHint(Object grade) {
    return 'الحد الأقصى $grade';
  }

  @override
  String get teacherGradesSaving => 'جارٍ الحفظ…';

  @override
  String teacherGradesSaveCount(Object count) {
    return 'حفظ $count درجات';
  }

  @override
  String get assignmentsNoDueDate => 'لا توجد موعد نهائي';

  @override
  String get assignmentsLoadError =>
      'لم نتمكن من تحميل الواجبات الآن. اسحب للتحديث أو حاول مرة أخرى.';

  @override
  String get assignmentsLoadTimeout =>
      'تستغرق الواجبات وقتاً طويلاً للتحميل. اسحب للتحديث أو حاول مرة أخرى في قليل.';

  @override
  String get assignmentsLoadNetwork =>
      'تعذر الاتصال بالواجبات الآن. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get assignmentsStatusOverdue => 'متأخر';

  @override
  String get assignmentsStatusDueSoon => 'حان الموعد قريباً';

  @override
  String get assignmentsStatusUpcoming => 'قادم';

  @override
  String get assignmentsPreviewFallback =>
      'افتح هذا الواجب لرؤية الإرشادات كاملة والتحضير لعملك.';

  @override
  String get assignmentsSubmissionPrepEmpty => 'ضع ملاحظتك أو ملفاتك هنا.';

  @override
  String assignmentsSubmissionPrepCount(Object count) {
    return '$count ملف(ات) مرفقة محلياً.';
  }

  @override
  String get assignmentsHeroSubtitle =>
      'جميع واجبات الفصل الدراسي في عرض واحد نظيف، مع صفحة تفاصيل بملء الشاشة ومكان مخصص للتحضير.';

  @override
  String get assignmentsSubjectsMetric => 'المواد';

  @override
  String get assignmentsNothingAssignedYet => 'لم يتم تعيين أي شيء بعد';

  @override
  String get assignmentsNoAssignmentsForAccount =>
      'لا توجد واجبات في الفصل الدراسي متاحة لحساب الطالب هذا الآن.';

  @override
  String assignmentsNextThingBody(Object title, Object due) {
    return '$title هو الشيء التالي الذي يجب أن تنظر إليه. $due.';
  }

  @override
  String get assignmentsPullToCheckAgain => 'اسحب لأسفل للتحقق مرة أخرى.';

  @override
  String get assignmentsFiltersSubtitle =>
      'ضيّق القائمة حسب الموضوع أو الإلحاح للتركيز على ما يهم أولاً.';

  @override
  String get assignmentsSubjectLabel => 'الموضوع';

  @override
  String get assignmentsAllSubjects => 'جميع المواد';

  @override
  String get assignmentsSearchSubjects => 'البحث عن المواد';

  @override
  String get assignmentsStatusLabel => 'الحالة';

  @override
  String get assignmentsAllStatuses => 'جميع الحالات';

  @override
  String get assignmentsSearchStatuses => 'البحث عن الحالات';

  @override
  String assignmentsShowingSummary(Object shown, Object total) {
    return 'عرض $shown من $total واجب.';
  }

  @override
  String get assignmentsNoFilterMatchesTitle =>
      'لا توجد واجبات تطابق هذه المرشحات';

  @override
  String get assignmentsNoFilterMatchesSubtitle =>
      'جرّب جميع المواد أو عرض حالة أوسع لإرجاع المزيد من الواجبات إلى القائمة.';

  @override
  String get assignmentsClearFiltersHint =>
      'امسح المرشحات لرؤية كل شيء مرة أخرى.';

  @override
  String get assignmentsListSubtitle =>
      'انقر على أي واجب لفتح عرض التفاصيل بملء الشاشة والتحضير لعملك.';

  @override
  String get assignmentsAddNoteBeforePrepare =>
      'أضف ملاحظة أو أرفق ملف قبل التحضير.';

  @override
  String get assignmentsWorkDraftPrepared => 'تم تحضير مسودة العمل.';

  @override
  String get assignmentsWorkDraftPreparedWithFiles =>
      'تم تحضير مسودة العمل. يتم حفظ الملفات المرفقة على هذا الجهاز.';

  @override
  String get assignmentsUnavailableTitle => 'الواجب غير متاح';

  @override
  String get assignmentsUnavailableSubtitle =>
      'لم يتم العثور على هذا الواجب في الخلاصة الحالية. قد يكون قد تم حذفه أو غير متاح دون اتصال.';

  @override
  String get assignmentsUnavailableHint => 'عد وحدّث قائمة الواجبات.';

  @override
  String get assignmentsOverdueBannerBody =>
      'هذا الواجب متأخر عن موعده. افتح منطقة عملك أدناه للتحضير لما تريد تقديمه.';

  @override
  String get assignmentsWorkAreaBannerBody =>
      'استخدم منطقة العمل أدناه لتجميع الملفات وكتابة ملاحظة والحفاظ على كل شيء جاهزاً في مكان واحد.';

  @override
  String get assignmentsDetailsSectionTitle => 'تفاصيل الواجب';

  @override
  String get assignmentsDetailsSectionSubtitle =>
      'كل ما يتعلق بالطالب وهو متاح حالياً في حمولة واجب الفصل الدراسي.';

  @override
  String get assignmentsDetailDueLabel => 'الموعد النهائي';

  @override
  String get assignmentsDetailClassroomLabel => 'الفصل الدراسي';

  @override
  String get assignmentsDetailTeacherLabel => 'المعلم';

  @override
  String get assignmentsDetailPostedByLabel => 'منشور بواسطة';

  @override
  String get assignmentsDetailPublishedLabel => 'منشور';

  @override
  String get assignmentsDetailUpdatedLabel => 'محدّث';

  @override
  String get assignmentsDetailIdLabel => 'معرّف الواجب';

  @override
  String get assignmentsInstructionsTitle => 'الإرشادات';

  @override
  String get assignmentsInstructionsSubtitle =>
      'نص الواجب الكامل من خلاصة الفصل الدراسي، مع الحفاظ على الصيغة الأصلية.';

  @override
  String get assignmentsYourWorkTitle => 'عملك';

  @override
  String get assignmentsYourWorkSubtitle =>
      'جرّب ملاحظة أو أرفق ملفات أو مستندات وحافظ على تحضير الإرسال في مساحة مركزة واحدة.';

  @override
  String get assignmentsPrivateNoteLabel => 'ملاحظة عمل خاصة';

  @override
  String get assignmentsPrivateNoteHint =>
      'أضف ما تخطط لتقديمه أو تذكيرات لنفسك أو ملخص المستند/الرابط.';

  @override
  String get assignmentsAddFiles => 'إضافة ملفات أو مستندات';

  @override
  String get assignmentsClearFiles => 'امسح الملفات';

  @override
  String get assignmentsStagedDeviceHint =>
      'يتم تجميع الملفات على هذا الجهاز. لا يتوفر تقديم ملف الواجب في هذا التطبيق.';

  @override
  String assignmentsLastPrepared(Object time) {
    return 'آخر تحضير $time.';
  }

  @override
  String get assignmentsSubmissionPrepTitle => 'تحضير الإرسال';

  @override
  String get assignmentsPreparing => 'جاري التحضير';

  @override
  String get assignmentsPrepareWork => 'تحضير العمل';

  @override
  String get assignmentsLoadingSubtitle =>
      'جاري تحميل واجباتك في الفصل الدراسي.';

  @override
  String get assignmentsPullToRefreshRetry =>
      'اسحب للتحديث أو أعد المحاولة أدناه.';

  @override
  String get assignmentsFileSizeUnknown => 'ملف';

  @override
  String get assignmentsRemoveAttachment => 'إزالة الملف';

  @override
  String get assignmentsSubmitted => 'تم التسليم';

  @override
  String get attendanceUndated => 'غير مؤرخة';

  @override
  String get attendanceLoadError =>
      'تعذر تحميل الحضور الآن. اسحب للتحديث أو حاول مرة أخرى.';

  @override
  String get attendanceLoadTimeout =>
      'يستغرق تحميل الحضور وقتاً طويلاً. اسحب للتحديث أو حاول مرة أخرى بعد قليل.';

  @override
  String get attendanceLoadNetwork =>
      'تعذر الاتصال بالحضور الآن. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get attendanceConsistencyBuilding => 'جاري البناء';

  @override
  String get attendanceConsistencyExcellent => 'اتساق ممتاز';

  @override
  String get attendanceConsistencySteady => 'في الغالب مستقر';

  @override
  String get attendanceConsistencyNeedsAttention => 'يحتاج إلى الاهتمام';

  @override
  String get attendanceConsistencyRisk => 'خطر الحضور';

  @override
  String get attendanceWatchRecentAbsences => 'الغيابات الأخيرة';

  @override
  String get attendanceWatchRepeatedLateness => 'التأخر المتكرر';

  @override
  String get attendanceWatchExcusedAddingUp => 'الوقت المعذور يتراكم';

  @override
  String get attendanceWatchNoFlags => 'لا توجد علامات حالية';

  @override
  String get attendanceAllSubjectsLowercase => 'جميع المواد';

  @override
  String attendanceShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return 'عرض $shown من $total علامات في $subject في $range.';
  }

  @override
  String get attendanceDayToneAbsent => 'يوم الغياب';

  @override
  String get attendanceDayToneLate => 'إشارة التأخر';

  @override
  String get attendanceDayToneExcused => 'الحضور المعذور';

  @override
  String get attendanceDayToneClean => 'يوم نظيف';

  @override
  String get attendanceLoadingSubtitle =>
      'جاري تحميل ملخص الحضور الأحدث الخاص بك.';

  @override
  String get attendanceUnavailableTitle => 'الحضور غير متاح';

  @override
  String get attendanceHeroSubtitle =>
      'قراءة واضحة لمعدل الحضور الخاص بك والدروس الأخيرة وأي شيء يحتاج إلى الاهتمام.';

  @override
  String get attendanceMetricRate => 'المعدل';

  @override
  String get attendanceMetricPresent => 'علامات الحضور';

  @override
  String get attendanceMetricLate => 'علامات التأخر';

  @override
  String get attendanceMetricAbsent => 'علامات الغياب';

  @override
  String attendanceHeroSignalBody(Object flag) {
    return '$flag. يمكن لضغط الحضور أن يتراكم بهدوء، لذا تركز هذه الرؤية على ما تغير مؤخراً.';
  }

  @override
  String get attendanceNoSummary =>
      'لا يتوفر ملخص حضور لحساب هذا الطالب حتى الآن.';

  @override
  String get attendanceEmptyTitle => 'لا توجد سجلات حضور حتى الآن';

  @override
  String get attendanceEmptySubtitle =>
      'لم يتم نشر سجلات حضور لحساب هذا الطالب حتى الآن.';

  @override
  String get attendanceFiltersSubtitle =>
      'استخدم نفس نمط الانتقاء القابل للبحث مثل الإعدادات لتضييق عرض الحضور حسب الموضوع أو نطاق الوقت.';

  @override
  String get attendanceTimeRangeLabel => 'نطاق الوقت';

  @override
  String get attendanceSearchRanges =>
      'كل الوقت / 7 أيام / 30 يوماً / 90 يوماً';

  @override
  String get attendanceNoFilteredMarksTitle =>
      'لا توجد علامات تطابق هذه المرشحات';

  @override
  String get attendanceNoFilteredMarksSubtitle =>
      'جرب جميع المواد أو نطاق زمني أوسع لإعادة المزيد من علامات الحضور إلى العرض.';

  @override
  String get attendanceQuickReadTitle => 'قراءة سريعة';

  @override
  String get attendanceQuickReadSubtitleFiltered =>
      'ملخص سريع للعلامات المصفاة والمعروضة أدناه.';

  @override
  String get attendanceQuickReadSubtitleAll =>
      'ملخص سريع بناءً على آخر سجلات الحضور المتاحة.';

  @override
  String get attendanceSummaryConsistency => 'الاتساق';

  @override
  String get attendanceSummaryWatchFor => 'راقب';

  @override
  String get attendanceSummaryExcused => 'علامات معذورة';

  @override
  String get attendanceSummaryMarksInView => 'علامات في العرض';

  @override
  String get attendanceSummaryRateInView => 'المعدل في العرض';

  @override
  String get attendanceRecentDaysTitle => 'الأيام الأخيرة';

  @override
  String get attendanceRecentDaysSubtitleFiltered =>
      'مجمعة حسب اليوم للعلامات المصفاة الموجودة حالياً في العرض.';

  @override
  String get attendanceRecentDaysSubtitleAll =>
      'مجمعة حسب اليوم حتى تتمكن من اكتشاف أنماط الغياب أو التأخر بسرعة أكبر.';

  @override
  String get attendanceLessonCountSingle => 'درس واحد';

  @override
  String attendanceLessonCount(Object count) {
    return '$count دروس';
  }

  @override
  String get attendanceStatusPresent => 'حاضر';

  @override
  String get attendanceStatusLate => 'متأخر';

  @override
  String get attendanceStatusAbsent => 'غائب';

  @override
  String get attendanceStatusExcused => 'معذور';

  @override
  String get attendanceStatusRecorded => 'مسجل';

  @override
  String get attendanceLessonFallback => 'درس';

  @override
  String get attendanceRangeAll => 'كل الوقت';

  @override
  String get attendanceRange7 => 'آخر 7 أيام';

  @override
  String get attendanceRange30 => 'آخر 30 يوماً';

  @override
  String get attendanceRange90 => 'آخر 90 يوماً';

  @override
  String get attendanceRangeAllShort => 'كل الوقت';

  @override
  String get attendanceRange7Short => '7 أيام';

  @override
  String get attendanceRange30Short => '30 يوماً';

  @override
  String get attendanceRange90Short => '90 يوماً';

  @override
  String get gradesLoadError =>
      'لم نتمكن من تحميل الدرجات الآن. اسحب للتحديث أو حاول مجددًا.';

  @override
  String get gradesLoadTimeout =>
      'استغرقت الدرجات وقتًا طويلًا جدًا للتحميل. اسحب للتحديث أو حاول مرة أخرى بعد قليل.';

  @override
  String get gradesLoadNetwork =>
      'لم نتمكن من الاتصال بالدرجات الآن. تحقق من اتصالك وحاول مجددًا.';

  @override
  String get gradesGeneralSubject => 'عام';

  @override
  String get gradesBandBuilding => 'قيد الإنشاء';

  @override
  String get gradesBandExcellent => 'ممتاز';

  @override
  String get gradesBandStrong => 'قوي';

  @override
  String get gradesBandOkay => 'حسن';

  @override
  String get gradesBandNeedsAttention => 'يحتاج إلى اهتمام';

  @override
  String get gradesBandRisk => 'في خطر';

  @override
  String get gradesTrendRising => 'صاعد';

  @override
  String get gradesTrendDropping => 'هابط';

  @override
  String get gradesTrendStable => 'مستقر';

  @override
  String gradesShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return 'عرض $shown من $total درجات مسجلة لـ $subject في $range.';
  }

  @override
  String get gradesLoadingSubtitle => 'جاري تحميل أحدث نتائجك الأكاديمية.';

  @override
  String get gradesUnavailableTitle => 'الدرجات غير متاحة';

  @override
  String get gradesHeroSubtitle =>
      'قراءة واضحة لمتوسطك والتقييمات الحديثة والمواضيع التي تحتاج حماية أو استعادة.';

  @override
  String get gradesMetricAverage => 'المتوسط';

  @override
  String get gradesMetricRecorded => 'مسجل';

  @override
  String get gradesMetricBestSubject => 'أفضل مادة';

  @override
  String get gradesMetricNeedsWork => 'يحتاج إلى عمل';

  @override
  String gradesLatestSignalBody(
    Object assessment,
    Object subject,
    Object grade,
    Object band,
  ) {
    return '$assessment في $subject حصل على $grade. $band الآن.';
  }

  @override
  String get gradesSummaryAvailableNoRecent =>
      'ملخص الدرجات متاح، لكن لا توجد تقييمات حديثة مرئية في هذا العرض حتى الآن.';

  @override
  String get gradesEmptyTitle => 'لا توجد درجات بعد';

  @override
  String get gradesEmptySubtitle =>
      'لم يتم نشر أي درجات لحساب هذا الطالب حتى الآن.';

  @override
  String get gradesFiltersSubtitle =>
      'استخدم نفس أداة الاختيار القابلة للبحث مثل الإعدادات لتضييق الدرجات حسب المادة أو نافذة زمنية.';

  @override
  String get gradesNoFilteredTitle => 'لا توجد درجات تطابق هذه المرشحات';

  @override
  String get gradesNoFilteredSubtitle =>
      'جرب جميع المواضيع أو نطاق زمني أوسع لإعادة مزيد من الدرجات المسجلة.';

  @override
  String get gradesQuickReadTitle => 'قراءة سريعة';

  @override
  String get gradesQuickReadSubtitleFiltered =>
      'ملخص سريع للدرجات الحالية في العرض.';

  @override
  String get gradesQuickReadSubtitleAll =>
      'أسرع قراءة لما يجب حمايته واسترجاعه.';

  @override
  String get gradesWeakSpotLabel => 'نقطة ضعف حالية';

  @override
  String get gradesNoWeakSignal => 'لا توجد إشارة مادة ضعيفة حتى الآن';

  @override
  String gradesWeakSpotValue(Object subject) {
    return '$subject يحتاج إلى كتلة الاسترجاع الأولى.';
  }

  @override
  String get gradesStrengthLabel => 'نقطة قوة حالية';

  @override
  String get gradesNoStrengthSignal => 'لا توجد إشارة مادة قوية حتى الآن';

  @override
  String gradesStrengthValue(Object subject) {
    return '$subject هو مرساك الثقة الآن.';
  }

  @override
  String get gradesBandLabel => 'النطاق';

  @override
  String get gradesInViewLabel => 'في العرض';

  @override
  String gradesInViewCount(Object count) {
    return '$count درجات مسجلة في هذا المرشح.';
  }

  @override
  String gradesInViewAverage(Object count, Object average) {
    return '$count درجات مسجلة بمتوسط $average.';
  }

  @override
  String get gradesLatestAssessmentsTitle => 'أحدث التقييمات';

  @override
  String get gradesLatestAssessmentsSubtitleFiltered =>
      'أحدث الدرجات المسجلة في العرض المفلتر الحالي.';

  @override
  String get gradesLatestAssessmentsSubtitleAll =>
      'أحدث الدرجات المسجلة بترتيب زمني.';

  @override
  String get gradesSubjectDrilldownTitle => 'تفصيل المادة';

  @override
  String get gradesSubjectDrilldownSubtitleFiltered =>
      'مجمعة حسب المادة للدرجات الحالية في العرض.';

  @override
  String get gradesSubjectDrilldownSubtitleAll =>
      'مجمعة حسب المادة لتبرز الاتجاهات والضغط بشكل أسرع.';

  @override
  String get gradesAssessmentFallback => 'التقييم';

  @override
  String get gradesChipBest => 'الأفضل';

  @override
  String get gradesNoAverageYet => 'لا يوجد متوسط حتى الآن';

  @override
  String gradesRecentAverage(Object average) {
    return 'المتوسط الأخير: $average';
  }

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionSave => 'حفظ';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionRemove => 'إزالة';

  @override
  String get actionBlock => 'حظر';

  @override
  String get actionCreate => 'إنشاء';

  @override
  String get actionShare => 'مشاركة';

  @override
  String get actionScheduleVerb => 'جدولة';

  @override
  String get actionAdd => 'إضافة';

  @override
  String get actionKeep => 'الإبقاء';

  @override
  String get actionOpen => 'فتح';

  @override
  String get actionPublish => 'نشر';

  @override
  String get actionPublishing => 'جارٍ النشر…';

  @override
  String get actionRefresh => 'تحديث';

  @override
  String get msgBlockTitle => 'حظر هذا الشخص؟';

  @override
  String get msgBlockContent => 'لن يتمكن من مراسلتك ولن ترى رسائله.';

  @override
  String get msgRenameGroup => 'إعادة تسمية المجموعة';

  @override
  String get msgGroupName => 'اسم المجموعة';

  @override
  String get msgMute => 'كتم';

  @override
  String get msgUnmute => 'إلغاء الكتم';

  @override
  String get msgInviteCode => 'رمز الدعوة';

  @override
  String get msgCopyCode => 'نسخ الرمز';

  @override
  String get msgLeave => 'مغادرة';

  @override
  String get msgInviteCodeCopied => 'تم نسخ رمز الدعوة';

  @override
  String msgCodeCopied(Object code) {
    return 'تم نسخ الرمز: $code';
  }

  @override
  String msgParticipantsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تمت إضافة $count مشاركين',
      one: 'تمت إضافة مشارك واحد',
    );
    return '$_temp0';
  }

  @override
  String msgMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أعضاء',
      one: 'عضو واحد',
    );
    return '$_temp0';
  }

  @override
  String get msgAdmin => 'مشرف';

  @override
  String get msgRemoveFromGroup => 'إزالة من المجموعة';

  @override
  String get msgMakeAdmin => 'تعيين مشرفاً';

  @override
  String get msgRemoveAdmin => 'إلغاء الإشراف';

  @override
  String get msgOnlyAdmin => 'المشرف الوحيد — عيّن مشرفاً آخر أولاً';

  @override
  String msgRemoveMemberTitle(Object name) {
    return 'إزالة $name؟';
  }

  @override
  String get msgNotificationsMuted => 'تم كتم الإشعارات';

  @override
  String get msgNotificationsUnmuted => 'تم إلغاء كتم الإشعارات';

  @override
  String get msgJoinGroupTitle => 'الانضمام إلى مجموعة';

  @override
  String get msgJoinGroupSubtitle => 'أدخل رمز الدعوة من مشرف المجموعة';

  @override
  String get examTitle => 'الامتحان';

  @override
  String get examNotFound => 'الامتحان غير موجود';

  @override
  String get examStudyWithNova => 'الدراسة مع NOVA';

  @override
  String get examOpenInsights => 'فتح الرؤى';

  @override
  String get examAddToCalendar => 'إضافة إلى التقويم';

  @override
  String get examCouldNotOpenCalendar => 'تعذر فتح التقويم.';

  @override
  String get formTitle => 'النموذج';

  @override
  String get formNotFound => 'النموذج غير موجود';

  @override
  String get formClosed => 'هذا النموذج مغلق.';

  @override
  String get formCompletion => 'الإكمال';

  @override
  String get formNoTextResponses => 'لا توجد ردود نصية بعد.';

  @override
  String get meetingsCouldNotLoad => 'تعذر تحميل الاجتماعات';

  @override
  String get meetingCouldNotLoad => 'تعذر تحميل الاجتماع';

  @override
  String get insightsGenerateAction => 'إنشاء رؤى';

  @override
  String get insightsRefreshAction => 'تحديث';

  @override
  String get teacherGoToClassroom => 'الذهاب إلى الفصل';

  @override
  String get teacherMarkAttendance => 'تسجيل الحضور';

  @override
  String get teacherPostAssignment => 'نشر مهمة';

  @override
  String get teacherNewAnnouncementAction => 'إعلان جديد';

  @override
  String get teacherViewFullWeekSchedule => 'عرض جدول الأسبوع كاملاً';

  @override
  String get teacherGroupsLabel => 'المجموعات';

  @override
  String get teacherTestsLabel => 'الاختبارات';

  @override
  String get teacherAnnounceLabel => 'إعلان';

  @override
  String get teacherTitleAndMessageRequired => 'العنوان والرسالة مطلوبان';

  @override
  String get teacherAnnouncementPublished => 'تم نشر الإعلان';

  @override
  String teacherFailedToPublish(Object error) {
    return 'فشل النشر: $error';
  }

  @override
  String get teacherAnnouncementSectionTitle => 'إعلان';

  @override
  String get teacherAudienceSectionTitle => 'الجمهور';

  @override
  String get teacherPinAnnouncement => 'تثبيت الإعلان';

  @override
  String get teacherPinnedAtTop => 'تظهر الإعلانات المثبتة في الأعلى';

  @override
  String get teacherPublishAction => 'نشر';

  @override
  String get teacherPublishingAction => 'جارٍ النشر…';

  @override
  String get teacherAnnounceTitleLabel => 'العنوان *';

  @override
  String get teacherAnnounceTitleHint => 'مثال: حدث مدرسي غداً';

  @override
  String get teacherAnnounceMessageLabel => 'الرسالة *';

  @override
  String get teacherAnnounceMessageHint => 'اكتب الإعلان كاملاً هنا…';

  @override
  String get teacherStudentsLabel => 'الطلاب';

  @override
  String get teacherSearchStudents => 'بحث بالاسم أو الصف...';

  @override
  String get teacherNoStudentsLoaded => 'لا يوجد طلاب في هذه المدرسة.';

  @override
  String get teacherActions => 'إجراءات سريعة';

  @override
  String get teacherParentsLabel => 'أولياء الأمور';

  @override
  String get teacherTeachersLabel => 'المعلمون';

  @override
  String get teacherWeekScheduleTitle => 'جدول الأسبوع';

  @override
  String get teacherCouldNotLoadSchedule => 'تعذر تحميل الجدول';

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
  String get teacherRecentGrades => 'الدرجات الأخيرة';

  @override
  String get teacherNoGradesRecorded => 'لا توجد درجات مسجلة بعد';

  @override
  String get teacherGradeAvg => 'متوسط الدرجات';

  @override
  String get teacherSubmittedLabel => 'المُسلَّم';

  @override
  String get teacherAnalyticsTitle => 'التحليلات';

  @override
  String get teacherGradeReports => 'تقارير الدرجات';

  @override
  String get teacherAvgLabel => 'متوسط';

  @override
  String teacherBelow60(Object count) {
    return '$count أقل من 60%';
  }

  @override
  String teacherGradedFraction(Object graded, Object total) {
    return '$graded/$total تم تقييمه';
  }

  @override
  String get teacherNoGradesEntered => 'لم يتم إدخال درجات بعد';

  @override
  String get teacherNewAssignment => 'مهمة جديدة';

  @override
  String get teacherDeleteAssignment => 'حذف المهمة؟';

  @override
  String get teacherDeleteAssignmentContent => 'سيتم إزالتها لجميع الطلاب.';

  @override
  String get teacherShareMaterialTitle => 'مشاركة المادة';

  @override
  String get teacherRemoveMaterial => 'إزالة المادة؟';

  @override
  String get teacherScheduleMeetingTitle => 'جدولة اجتماع';

  @override
  String get teacherCancelMeetingTitle => 'إلغاء الاجتماع؟';

  @override
  String get teacherCancelMeetingAction => 'إلغاء الاجتماع';

  @override
  String get teacherJoinMeeting => 'الانضمام إلى الاجتماع';

  @override
  String get teacherAddStudentTitle => 'إضافة طالب';

  @override
  String teacherRemoveStudentTitle(Object name) {
    return 'إزالة $name؟';
  }

  @override
  String get teacherRemoveStudentContent =>
      'سيتم إزالة هذا الطالب من هذه الفصل الدراسي.';

  @override
  String get teacherStudentAdded => 'تمت إضافة الطالب';

  @override
  String get teacherClassroomAnalyticsTitle => 'تحليلات الفصل';

  @override
  String get teacherOpenAnalyticsAction => 'فتح التحليلات';

  @override
  String teacherStudentsCount(Object count) {
    return 'الطلاب ($count)';
  }

  @override
  String get teacherAssignmentLabel => 'مهمة';

  @override
  String get teacherShareMaterialLabel => 'مشاركة المادة';

  @override
  String get teacherAttendanceRateLabel => 'معدل الحضور';

  @override
  String get teacherSelectSessionPrompt => 'اختر جلسة أدناه لبدء تسجيل الحضور';

  @override
  String get teacherOpenAction => 'فتح';

  @override
  String get chatDeleteForMe => 'حذف بالنسبة لي';

  @override
  String get chatDeleteForEveryone => 'حذف للجميع';

  @override
  String get chatMicNeeded => 'مطلوب الوصول إلى الميكروفون';

  @override
  String get chatMicNeededBody =>
      'يرجى السماح بالوصول إلى الميكروفون في الإعدادات لإرسال الرسائل الصوتية.';

  @override
  String get chatOpenSettings => 'فتح الإعدادات';

  @override
  String get chatCopied => 'تم النسخ';

  @override
  String get chatCouldNotSendMedia => 'تعذر إرسال الوسائط.';

  @override
  String get chatCouldNotSendMessage => 'تعذر إرسال الرسالة.';

  @override
  String get chatCouldNotForward => 'تعذر إعادة توجيه الرسائل المحددة';

  @override
  String get chatSelectAll => 'تحديد الكل';

  @override
  String get chatDeselectAll => 'إلغاء تحديد الكل';

  @override
  String get chatEditingMessage => 'تحرير الرسالة';

  @override
  String get chatEditPlaceholder => 'تحرير الرسالة…';

  @override
  String get chatMessageHint => 'رسالة';

  @override
  String get chatPin => 'تثبيت';

  @override
  String get chatUnpin => 'إلغاء التثبيت';

  @override
  String get chatPhoto => 'صورة';

  @override
  String get chatVideo => 'فيديو';

  @override
  String get chatMedia => 'وسائط';

  @override
  String get chatAudioFile => 'ملف صوتي';

  @override
  String get chatVideoFile => 'ملف فيديو';

  @override
  String get chatAttachedFile => 'ملف مرفق';

  @override
  String get chatFollowUp => 'متابعة';

  @override
  String get chatCancelTooltip => 'إلغاء';

  @override
  String get chatJoinGroup => 'الانضمام إلى مجموعة';

  @override
  String get chatJoining => 'جارٍ الانضمام…';

  @override
  String get chatJoinGroupTooltip => 'الانضمام إلى مجموعة برمز';

  @override
  String get chatForwardNoChatAvailable => 'لا توجد محادثات موافق عليها';

  @override
  String get chatFilterAll => 'الكل';

  @override
  String get novaDisclaimer => 'قد تُخطئ NOVA. تحقق من الإجابات المهمة.';

  @override
  String get practiceCustomDisclaimer =>
      'الموضوعات المخصصة مُولَّدة بالذكاء الاصطناعي فورياً. قد تنحرف الأسئلة عن الموضوع أو تكون غير دقيقة للمواضيع المتخصصة. تحقق من الإجابات غير المألوفة باستقلالية.';

  @override
  String get classroomsJoined => 'لقد انضممت إلى الفصل الدراسي!';

  @override
  String get classroomsJoinAction => 'انضم إلى الفصل';

  @override
  String get classroomsJoinTooltip => 'انضم إلى فصل دراسي';

  @override
  String get classroomsJoinTitle => 'الانضمام إلى فصل دراسي';

  @override
  String get classroomsJoinSubtitle => 'أدخل الرمز الذي أعطاك إياه معلمك';

  @override
  String get classroomsCouldNotOpenLink => 'تعذر فتح الرابط';

  @override
  String get classroomsReorderTitle => 'إعادة ترتيب الفصول';

  @override
  String get classroomsNoClassroomsToReorder => 'لا توجد فصول لإعادة ترتيبها.';

  @override
  String get teacherPostAnnouncementAction => 'نشر إعلان';

  @override
  String get announcementAudienceEveryone => 'الجميع';

  @override
  String get teacherGreetingMorning => 'صباح الخير';

  @override
  String get teacherGreetingAfternoon => 'مساء الخير';

  @override
  String get teacherGreetingEvening => 'مساء الخير';

  @override
  String get teacherTodaysClasses => 'فصول اليوم';

  @override
  String get teacherNoDate => 'لا يوجد تاريخ';

  @override
  String get teacherUpcomingTestsSubtitle => 'الاختبارات القادمة';

  @override
  String get teacherNoClassesThisWeek => 'لا توجد فصول هذا الأسبوع';

  @override
  String get teacherNoClassesThisWeekSub => 'جدولك لهذا الأسبوع فارغ';

  @override
  String get teacherTitleFieldLabel => 'العنوان *';

  @override
  String get teacherInstructionsLabel => 'التعليمات';

  @override
  String get teacherLinkUrlLabel => 'الرابط / الرابط الإلكتروني *';

  @override
  String get teacherLinkUrlHint => 'https://...';

  @override
  String get teacherDescriptionLabel => 'الوصف';

  @override
  String get teacherMeetingTitleLabel => 'عنوان الاجتماع *';

  @override
  String get teacherMeetingLinkLabel => 'رابط الاجتماع *';

  @override
  String get teacherMeetingLinkHint => 'رابط Zoom / Meet / Teams';

  @override
  String get teacherStudentEmailLabel => 'بريد الطالب الإلكتروني أو معرفه';

  @override
  String get teacherTooltipRemoveStudent => 'إزالة من الفصل الدراسي';

  @override
  String get teacherCouldNotLoad => 'تعذر التحميل';

  @override
  String get teacherNoAssignmentsYet => 'لا توجد مهام بعد';

  @override
  String get teacherNoAssignmentsSub => 'اضغط + لإنشاء أول مهمة';

  @override
  String get teacherNoMaterialsYet => 'لا توجد مواد بعد';

  @override
  String get teacherNoMaterialsSub =>
      'شارك الروابط والمستندات والموارد مع فصلك';

  @override
  String get teacherNoMeetingsScheduled => 'لا توجد اجتماعات مجدولة';

  @override
  String get teacherNoMeetingsSub => 'اضغط + لجدولة اجتماع الفصل';

  @override
  String get teacherAttendanceOther => 'أخرى';

  @override
  String get teacherTotal => 'الإجمالي';

  @override
  String get mediaOpenExternally => 'فتح خارجياً';

  @override
  String get mediaUnableToLoad => 'تعذر تحميل الصورة';

  @override
  String get searchHint => 'بحث...';

  @override
  String get teacherInsightsTitle => 'رؤى الطلاب';

  @override
  String get teacherInsightsSubtitle => 'اختر طالباً لعرض رؤاه الأكاديمية.';

  @override
  String get teacherInsightsNoStudents => 'لم يتم العثور على طلاب.';

  @override
  String get teacherInsightsSearchHint => 'البحث عن طلاب…';

  @override
  String get navDiplomas => 'الشهادات';

  @override
  String get diplomasComingSoon => 'إدارة الشهادات قادمة قريباً.';

  @override
  String get teacherExamsTitle => 'الامتحانات';

  @override
  String get teacherExamsUpcoming => 'القادمة';

  @override
  String get teacherExamsPast => 'السابقة';

  @override
  String get teacherExamsEmpty => 'لا توجد تقييمات بعد. اضغط + لإنشاء واحد.';

  @override
  String teacherExamsGraded(Object count) {
    return '$count مُقيَّم';
  }

  @override
  String get teacherFormsTitle => 'النماذج';

  @override
  String get teacherFormsEmpty => 'لا توجد نماذج بعد. اضغط + لإنشاء نموذج.';

  @override
  String teacherFormsResponses(Object count) {
    return '$count استجابات';
  }

  @override
  String get teacherFormsPublished => 'منشور';

  @override
  String get teacherFormsDraft => 'مسودة';

  @override
  String get teacherFormsCreateTitle => 'إنشاء نموذج';

  @override
  String get teacherFormsAddQuestion => 'إضافة سؤال';

  @override
  String get teacherFormsQuestionHint => 'نص السؤال';

  @override
  String get teacherFormsViewResponses => 'عرض الردود';

  @override
  String get teacherFormsNoResponses => 'لا توجد ردود بعد.';

  @override
  String get diplomasTitle => 'الشهادات';

  @override
  String get diplomasEmpty =>
      'لم يتم إصدار أي شهادات بعد. اضغط + لإصدار شهادة.';

  @override
  String get diplomasIssueTo => 'إصدار إلى';

  @override
  String get diplomasStudentName => 'اسم الطالب';

  @override
  String get diplomasCertificateType => 'نوع الشهادة';

  @override
  String get diplomasIssueDiploma => 'إصدار الشهادة';

  @override
  String diplomasIssuedOn(Object date) {
    return 'صدر في $date';
  }

  @override
  String get examDetailsSection => 'التفاصيل';

  @override
  String get examInfoTeacher => 'المعلم';

  @override
  String get examInfoAudience => 'الجمهور';

  @override
  String get examInfoDate => 'التاريخ';

  @override
  String get examInfoTime => 'الوقت';

  @override
  String get examInfoPeriod => 'الحصة';

  @override
  String get examInfoDuration => 'المدة';

  @override
  String get examInfoSubject => 'المادة';

  @override
  String get examMaterialsSection => 'المواد المرفقة';

  @override
  String get examNoMaterials => 'لا توجد مواد مرفقة بعد.';

  @override
  String get examQuickActionsSection => 'إجراءات سريعة';

  @override
  String get examViewGradeTitle => 'اطلع على درجتك';

  @override
  String get examViewGradeBody =>
      'انتهى هذا الامتحان. تحقق من علامتك في تبويب الدرجات.';

  @override
  String get examViewGradeAction => 'فتح الدرجات';

  @override
  String get teacherGradesSaveAction => 'حفظ';

  @override
  String get teacherGradesNothingToSave => 'لا توجد تغييرات للحفظ.';

  @override
  String get teacherRetry => 'إعادة المحاولة';

  @override
  String get teacherExamGradesStudents => 'طلاب';

  @override
  String get teacherExamGradesGraded => 'مُقيَّم';

  @override
  String get teacherExamGradesNoStudents =>
      'لا يوجد طلاب مستهدفون.\nعدّل الامتحان لإضافة جمهور.';

  @override
  String get teacherExamGradesEnterGrades => 'إدخال الدرجات';

  @override
  String get teacherDeleteExamTitle => 'حذف الامتحان؟';

  @override
  String get teacherDeleteExamBody => 'سيتم حذف الامتحان نهائيًا.';

  @override
  String get teacherMeetingsEmpty =>
      'لا توجد اجتماعات بعد.\nاضغط + لجدولة واحد.';

  @override
  String get teacherStudentsNoMatch => 'لا يوجد طلاب مطابقون';

  @override
  String get teacherMaterialsTitle => 'المواد';

  @override
  String get profileNamesTitle => 'الاسم بلغات مختلفة';

  @override
  String get profileDisplayNameLang => 'لغة عرض الاسم';
}

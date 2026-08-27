// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get certAddTeacher => 'إضافة معلّم';

  @override
  String get certSearchStudent => 'البحث عن طالب';

  @override
  String get certNewCertificate => 'شهادة جديدة';

  @override
  String get certChooseStudent => 'اختر طالبًا';

  @override
  String get certSelectClassFirst => 'اختر صفًا أولاً';

  @override
  String certCertificateCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شهادات',
      one: 'شهادة واحدة',
      zero: 'لا توجد شهادات',
    );
    return '$_temp0';
  }

  @override
  String get onbTeacher2Title => 'صفوفك، منظّمة';

  @override
  String get onbTeacher2Body =>
      'جدولك وصفوفك وقوائم طلابك — كلها في مكان واحد.';

  @override
  String get onbTeacher3Title => 'العلامات والحضور بسرعة';

  @override
  String get onbTeacher3Body =>
      'سجّل الحضور وأدخل العلامات في ثوانٍ، من هاتفك مباشرة.';

  @override
  String get onbTeacher4Title => 'تواصل مع الجميع';

  @override
  String get onbTeacher4Body =>
      'انشر الإعلانات وراسل الطلاب وأولياء الأمور فورًا.';

  @override
  String get onbAdmin2Title => 'أدِر مدرستك';

  @override
  String get onbAdmin2Body => 'أدِر المستخدمين والصفوف والجدول من لوحة واحدة.';

  @override
  String get onbAdmin3Title => 'الإعداد في دقائق';

  @override
  String get onbAdmin3Body => 'أضف الطلاب والمعلمين والصفوف بنقرات قليلة.';

  @override
  String get onbAdmin4Title => 'أبقِ الجميع متزامنين';

  @override
  String get onbAdmin4Body => 'أرسل الإعلانات وراسل مدرستك بأكملها.';

  @override
  String get onbSecretary2Title => 'الطلاب بين يديك';

  @override
  String get onbSecretary2Body => 'ابحث عن أي طالب وحافظ على تحديث بياناته.';

  @override
  String get onbSecretary3Title => 'انشر الخبر';

  @override
  String get onbSecretary3Body =>
      'أرسل الإعلانات إلى الصفوف المناسبة في ثوانٍ.';

  @override
  String get onbParent2Title => 'تابِع طفلك';

  @override
  String get onbParent2Body => 'جدوله وعلاماته وحضوره — محدّثة دائمًا.';

  @override
  String get onbParent3Title => 'لا تفوّت شيئًا';

  @override
  String get onbParent3Body => 'استلم إعلانات المدرسة وتحديثاتها لحظة حدوثها.';

  @override
  String get accountActionsTooltip => 'خيارات الحساب';

  @override
  String get accountSwitchTo => 'التبديل إلى هذا الحساب';

  @override
  String get accountRemove => 'إزالة الحساب';

  @override
  String get accountRemoveConfirmTitle => 'إزالة الحساب؟';

  @override
  String accountRemoveConfirmBody(String name) {
    return 'ستتم إزالة $name من هذا الجهاز. يمكنك تسجيل الدخول مرة أخرى في أي وقت.';
  }

  @override
  String onboardingWelcomeNamed(String name) {
    return 'أهلاً بك، $name!';
  }

  @override
  String get practiceGenAlmostReady => 'أوشكنا على الانتهاء…';

  @override
  String practiceGenRemaining(int seconds) {
    return '≈ $seconds ثانية متبقية';
  }

  @override
  String practiceGenEstimate(int min, int max) {
    return 'عادةً $min–$max ثانية';
  }

  @override
  String get consentGateError =>
      'تعذّر حفظ اختيارك. تحقّق من اتصالك وحاول مرة أخرى.';

  @override
  String get commonShowPassword => 'إظهار كلمة المرور';

  @override
  String get commonHidePassword => 'إخفاء كلمة المرور';

  @override
  String get adminEmailInvalid => 'أدخل عنوان بريد إلكتروني صالحًا';

  @override
  String get adminPhoneInvalid => 'أدخل رقم هاتف صالحًا';

  @override
  String get adminFullNameLabel => 'الاسم الكامل';

  @override
  String get adminHomeroomLabel => 'صف التربية';

  @override
  String get adminHomeroomNone => 'بدون صف تربية';

  @override
  String get adminHomeroomNoneAvailable => 'لا توجد صفوف غير مُعيَّنة متاحة';

  @override
  String get adminHomeroomHint => 'سيصبح هذا المعلّم مربّي الصف المحدَّد.';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get logoutConfirmBody =>
      'ستحتاج إلى تسجيل الدخول مرة أخرى لاستخدام ClassMate.';

  @override
  String get pressBackAgainToExit => 'اضغط رجوع مرة أخرى للخروج';

  @override
  String get onboardingSkip => 'تخطّي';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingGetStarted => 'لنبدأ';

  @override
  String get onboardingSlide1Title => 'مرحبًا بك في ClassMate';

  @override
  String get onboardingSlide1Body =>
      'رفيقك المدرسي الذكي — كل ما يخص المدرسة في مكان واحد.';

  @override
  String get onboardingSlide2Title => 'تعرّف على NOVA';

  @override
  String get onboardingSlide2Body =>
      'معلّمك بالذكاء الاصطناعي، جاهز لشرح أي موضوع ومساعدتك على التدرّب في أي وقت.';

  @override
  String get onboardingSlide3Title => 'تابِع كل شيء أولًا بأول';

  @override
  String get onboardingSlide3Body =>
      'الجدول والعلامات والحضور والوظائف — محدَّثة دائمًا.';

  @override
  String get onboardingSlide4Title => 'ابقَ على تواصل';

  @override
  String get onboardingSlide4Body =>
      'الرسائل والإعلانات تُبقي الطلاب والمعلمين وأولياء الأمور على تناغم.';

  @override
  String get consentGateTitle => 'قبل المتابعة';

  @override
  String get consentGateBody =>
      'لمواصلة استخدام ClassMate، يُرجى مراجعة وقبول كيفية تعاملنا مع بياناتك.';

  @override
  String get consentGateLink => 'اقرأ سياسة الخصوصية وشروط الاستخدام';

  @override
  String get consentGateAccept => 'أوافق على سياسة الخصوصية وشروط الاستخدام';

  @override
  String get consentGateGuardian =>
      'لديّ إذن من أحد الوالدين أو الوصيّ لاستخدام ClassMate';

  @override
  String get consentGateContinue => 'الموافقة والمتابعة';

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
  String get navClassrooms => 'الصفوف';

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
  String get roleStudent => 'طالب';

  @override
  String get titleSchedule => 'الجدول';

  @override
  String get titleClasses => 'الصفوف';

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
  String get titleBagrut => 'بجروت';

  @override
  String get bagrutSearchHint => 'ابحث في المواد';

  @override
  String bagrutNoExams(Object subject) {
    return 'لا توجد امتحانات بعد لمادة $subject.';
  }

  @override
  String bagrutFilesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملف',
      many: '$count ملفًا',
      few: '$count ملفات',
      two: 'ملفان',
      one: 'ملف واحد',
      zero: 'لا توجد ملفات',
    );
    return '$_temp0';
  }

  @override
  String get bagrutNoFiles => 'لا توجد ملفات.';

  @override
  String get bagrutFileQuestions => 'الأسئلة';

  @override
  String get bagrutFileAnswers => 'الإجابات';

  @override
  String get bagrutFileSolution => 'الحل';

  @override
  String get bagrutFileAdvanced => 'الحل الكامل';

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
  String get settingsThemeCoffee => 'قهوة';

  @override
  String get settingsThemeMatcha => 'ماتشا';

  @override
  String get settingsThemeRose => 'روزيه';

  @override
  String get settingsThemeMidnight => 'منتصف الليل';

  @override
  String get settingsThemeNord => 'نورد';

  @override
  String get settingsThemeForest => 'غابة';

  @override
  String get settingsThemeSand => 'رمال';

  @override
  String get settingsThemeSky => 'سماء';

  @override
  String get settingsThemeLavender => 'لافندر';

  @override
  String get settingsThemePeach => 'خوخي';

  @override
  String get settingsThemeMint => 'نعناع';

  @override
  String get settingsThemeDracula => 'دراكولا';

  @override
  String get settingsThemeObsidian => 'أوبسيديان';

  @override
  String get settingsThemeWine => 'نبيذي';

  @override
  String get settingsThemeSolarized => 'سولارايزد';

  @override
  String get settingsThemePlum => 'برقوقي';

  @override
  String get settingsThemeOcean => 'محيط';

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
      'لم نتمكن من تحميل الصفوف الآن. اسحب للتحديث أو حاول مجددًا.';

  @override
  String get teacherClassroomsLoadTimeout =>
      'يستغرق تحميل الصفوف وقتًا طويلاً. اسحب للتحديث أو حاول بعد قليل.';

  @override
  String get teacherClassroomsLoadNetwork =>
      'لا يمكن الاتصال بالصفوف الآن. تحقق من الاتصال وحاول مجددًا.';

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
      'لم يتم تسجيل أي طلاب في هذا الصف بعد.';

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
      'ملف الطالب الخاص بك غير مكتمل. اطلب من مسؤول مدرستك تعيينك في صف.';

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
  String get scheduleNoSubjectLocation => 'لا يوجد موضوع أو موقع بعد';

  @override
  String get scheduleNotes => 'ملاحظات';

  @override
  String get scheduleGoToClassroom => 'الذهاب إلى الصف';

  @override
  String get loginTitle => 'تسجيل الدخول للجوال للطلاب والمعلمين';

  @override
  String get loginSubtitle =>
      'حسابات المعلمين تفتح مساحة المعلم. حسابات الطلاب تبقى في تجربة الطالب.';

  @override
  String get loginSignIn => 'تسجيل الدخول';

  @override
  String get biometricSignIn => 'تسجيل الدخول بالبصمة الحيوية';

  @override
  String get biometricEnable => 'تفعيل تسجيل الدخول بالبصمة الحيوية';

  @override
  String get biometricReason => 'تحقّق من هويتك لتسجيل الدخول إلى ClassMate';

  @override
  String get biometricEnableReason =>
      'تحقّق من هويتك لتفعيل تسجيل الدخول بالبصمة الحيوية';

  @override
  String get biometricSignInFaceId => 'تسجيل الدخول باستخدام Face ID';

  @override
  String get biometricSignInFingerprint => 'تسجيل الدخول ببصمة الإصبع';

  @override
  String get biometricOrSignInWith => 'أو سجّل الدخول باستخدام';

  @override
  String get biometricNotSetUp =>
      'لم يتم إعداد تسجيل الدخول بالبصمة الحيوية بعد. فعّل Face ID أو بصمة الإصبع من الملف الشخصي ← تسجيل الدخول بالبصمة الحيوية.';

  @override
  String get biometricNotRecognized =>
      'لم يتم التعرّف على البصمة الحيوية. حاول مرة أخرى أو سجّل الدخول بكلمة المرور.';

  @override
  String get biometricFaceUnavailable => 'Face ID غير متاح على هذا الجهاز.';

  @override
  String get biometricFingerprintUnavailable =>
      'بصمة الإصبع غير متاحة على هذا الجهاز.';

  @override
  String get biometricNotAvailableOnDevice => 'غير متاح على هذا الجهاز';

  @override
  String get biometricSectionTitle => 'تسجيل الدخول بالبصمة الحيوية';

  @override
  String get biometricSectionSubtitle =>
      'فعّل Face ID أو بصمة إصبعك لتسجيل الدخول بشكل أسرع. ستؤكّد كلمة المرور مرة واحدة.';

  @override
  String get biometricFaceId => 'Face ID';

  @override
  String get biometricFaceIdDesc => 'استخدم Face ID لتسجيل الدخول';

  @override
  String get biometricFingerprint => 'بصمة الإصبع';

  @override
  String get biometricFingerprintDesc => 'استخدم بصمة إصبعك لتسجيل الدخول';

  @override
  String get biometricConfirmPasswordTitle => 'تأكيد كلمة المرور';

  @override
  String get biometricConfirmPasswordBody =>
      'أدخل كلمة المرور لتفعيل تسجيل الدخول بالبصمة الحيوية.';

  @override
  String get biometricPasswordIncorrect =>
      'كلمة المرور غير صحيحة. يُرجى المحاولة مرة أخرى.';

  @override
  String get biometricEnrollFailed =>
      'تعذّر التحقّق من بصمتك الحيوية. تأكّد من إعداد Face ID أو بصمة إصبع في إعدادات جهازك.';

  @override
  String get biometricEnterCredsFirst =>
      'أدخل بريدك الإلكتروني وكلمة المرور أولاً، ثم فعّل تسجيل الدخول بالبصمة الحيوية.';

  @override
  String get biometricLoginFailed =>
      'فشل تسجيل الدخول بالبصمة الحيوية. يُرجى تسجيل الدخول بكلمة المرور.';

  @override
  String get biometricEnrollTitle => 'تفعيل تسجيل الدخول بالبصمة الحيوية؟';

  @override
  String get biometricEnrollBody =>
      'استخدم Face ID أو بصمة إصبعك لتسجيل الدخول بشكل أسرع في المرة القادمة.';

  @override
  String get biometricEnrollYes => 'تفعيل';

  @override
  String get biometricEnrollNo => 'ليس الآن';

  @override
  String get loginWelcomeTitle => 'مرحبًا بعودتك';

  @override
  String get loginWelcomeSubtitle => 'سجّل الدخول إلى حسابك في ClassMate.';

  @override
  String get loginSigningIn => 'جارٍ تسجيل الدخول...';

  @override
  String get loginEmailLabel => 'البريد الإلكتروني أو اسم المستخدم';

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
  String get profileMyCohorts => 'مجموعاتي';

  @override
  String get profileMyCohortsEmpty => 'لم يتم تسجيلك في أي مجموعة بعد.';

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
  String get classroomsYourClassrooms => 'صفوفك';

  @override
  String get classroomsReorder => 'إعادة ترتيب الصفوف';

  @override
  String classroomsCount(Object count) {
    return '$count صفوف';
  }

  @override
  String get classroomsSearchHint => 'ابحث في الصفوف';

  @override
  String get classroomsNoSearchMatches => 'لا توجد صفوف تطابق بحثك';

  @override
  String get classroomsClassroomLabel => 'صف';

  @override
  String get classroomsLoadingLatestMessage => 'جارٍ تحميل آخر رسالة...';

  @override
  String get classroomsTapToOpen => 'اضغط لفتح الصف';

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
  String get chatComposerReleaseToCancel => 'حرر للإلغاء';

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
  String get classroomsThreadTypeClassroom => 'صف';

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
  String get messagesGroupMinMembers => 'اختر شخصين على الأقل للمجموعة';

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
  String get classroomsForwardSectionClassrooms => 'الصفوف';

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
  String get teacherDeleteClassroom => 'حذف الصف';

  @override
  String get teacherDeleteClassroomConfirm =>
      'سيؤدي هذا إلى حذف الصف نهائيًا مع جميع محادثاته وواجباته وموادّه ولقاءاته وقائمة أعضائه. لا يمكن التراجع عن ذلك.';

  @override
  String get teacherClassroomDeleted => 'تم حذف الصف';

  @override
  String get announcementsTabReceived => 'الواردة';

  @override
  String get announcementsTabPublished => 'المنشورة';

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
  String get meetingsDetailClassroomLabel => 'الصف';

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
  String get classroomDetailLeaveClassroomTitle => 'مغادرة الصف؟';

  @override
  String get classroomDetailLeaveClassroomBody => 'ستتم إزالتك من هذا الصف.';

  @override
  String get classroomDetailLeaveAction => 'مغادرة';

  @override
  String get classroomDetailNoAssignmentsTitle => 'لا توجد واجبات بعد';

  @override
  String get classroomDetailNoAssignmentsSubtitle =>
      'لا توجد واجبات في هذا الصف حالياً.';

  @override
  String get classroomDetailAssignmentFallback => 'واجب';

  @override
  String get classroomDetailNoMaterialsTitle => 'لا توجد مواد بعد';

  @override
  String get classroomDetailNoMaterialsSubtitle =>
      'لا توجد مواد في هذا الصف حالياً.';

  @override
  String get classroomDetailMaterialFallback => 'مادة';

  @override
  String get classroomDetailNoMeetingsTitle => 'لا توجد اجتماعات بعد';

  @override
  String get classroomDetailNoMeetingsSubtitle =>
      'لا توجد اجتماعات في هذا الصف حالياً.';

  @override
  String get classroomDetailMeetingFallback => 'اجتماع';

  @override
  String get classroomDetailCouldNotLoadPeople => 'تعذر تحميل الأشخاص';

  @override
  String get classroomDetailNoPeopleTitle => 'لا يوجد أشخاص بعد';

  @override
  String get classroomDetailNoPeopleSubtitle => 'لا يظهر أحد في هذا الصف بعد.';

  @override
  String get classroomDetailTabChat => 'الدردشة';

  @override
  String get classroomDetailTabMaterials => 'المواد';

  @override
  String get classroomDetailTabPeople => 'الأشخاص';

  @override
  String get classroomChatMediaSendPhoto => 'إرسال صورة';

  @override
  String get classroomChatMediaSendPhotoSubtitle => 'شارك صورة في دردشة الصف';

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
  String get practiceModeActionSaveQuestion => 'حفظ السؤال';

  @override
  String get practiceModeActionSavedQuestion => 'محفوظ';

  @override
  String get practiceModeQuestionSavedToast => 'تم الحفظ في أسئلتك';

  @override
  String get practiceModeQuestionRemovedToast =>
      'تمت الإزالة من الأسئلة المحفوظة';

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
  String get teacherGradesRosterLinkError => 'هذا التقييم غير مرتبط بقائمة صف.';

  @override
  String get teacherGradesSaved => 'تم حفظ الدرجات';

  @override
  String get teacherGradesSubtitle =>
      'أنشئ التقييمات واحفظ الدرجات مقابل قائمة الصف المباشرة.';

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
  String get assignmentsStatusGraded => 'مُقيَّم';

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
  String get assignmentsDetailClassroomLabel => 'الصف';

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
  String get formClosed => 'مغلق';

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
  String get teacherGoToClassroom => 'الذهاب إلى الصف';

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
  String get teacherSearchStudents => 'ابحث عن الطلاب…';

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
  String get teacherAttendanceLast30 => 'الحضور (آخر 30 يومًا)';

  @override
  String teacherAttendanceFrom(Object date) {
    return 'من $date';
  }

  @override
  String get teacherAttendanceChangeDate => 'تغيير التاريخ';

  @override
  String get teacherAttendanceNoSessions =>
      'لا توجد جلسات حضور محفوظة.\nسجّل الحضور من الجدول.';

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
  String get teacherShareMaterialTitle => 'مشاركة مادة';

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
      'سيتم إزالة هذا الطالب من هذا الصف.';

  @override
  String get teacherStudentAdded => 'تمت إضافة الطالب';

  @override
  String get teacherClassroomAnalyticsTitle => 'تحليلات الصف';

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
  String get novaTokenTip => 'استخدم رموزك بعناية — فهي مخصصة للدراسة.';

  @override
  String get practiceCustomDisclaimer =>
      'الموضوعات المخصصة مُولَّدة بالذكاء الاصطناعي فورياً. قد تنحرف الأسئلة عن الموضوع أو تكون غير دقيقة للمواضيع المتخصصة. تحقق من الإجابات غير المألوفة باستقلالية.';

  @override
  String get classroomsJoined => 'لقد انضممت إلى الصف!';

  @override
  String get classroomsJoinAction => 'انضم إلى الصف';

  @override
  String get classroomsJoinTooltip => 'انضم إلى صف';

  @override
  String get classroomsJoinTitle => 'الانضمام إلى صف';

  @override
  String get classroomsJoinSubtitle => 'أدخل الرمز الذي أعطاك إياه معلمك';

  @override
  String get classroomsCouldNotOpenLink => 'تعذر فتح الرابط';

  @override
  String get classroomsReorderTitle => 'إعادة ترتيب الصفوف';

  @override
  String get classroomsNoClassroomsToReorder => 'لا توجد صفوف لإعادة ترتيبها.';

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
  String get teacherTodaysClasses => 'صفوف اليوم';

  @override
  String get teacherNoDate => 'لا يوجد تاريخ';

  @override
  String get teacherUpcomingTestsSubtitle => 'الاختبارات القادمة';

  @override
  String get teacherNoClassesThisWeek => 'لا توجد صفوف هذا الأسبوع';

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
  String get teacherTooltipRemoveStudent => 'إزالة من الصف';

  @override
  String get teacherCouldNotLoad => 'تعذر التحميل';

  @override
  String get teacherNoAssignmentsYet => 'لا توجد مهام بعد';

  @override
  String get teacherNoAssignmentsSub => 'اضغط + لإنشاء أول مهمة';

  @override
  String get teacherNoMaterialsYet => 'لا توجد مواد بعد';

  @override
  String get teacherNoMaterialsSub => 'شارك الروابط والمستندات والموارد مع صفك';

  @override
  String get teacherNoMeetingsScheduled => 'لا توجد اجتماعات مجدولة';

  @override
  String get teacherNoMeetingsSub => 'اضغط + لجدولة اجتماع الصف';

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
  String get navDiplomas => 'الدبلومات';

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
  String get teacherExamClassAverage => 'متوسط الصف';

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

  @override
  String get navDashboard => 'لوحة التحكم';

  @override
  String get navPeople => 'المستخدمون';

  @override
  String get navCohorts => 'المجموعات';

  @override
  String get navSchool => 'المدرسة';

  @override
  String get navSchools => 'المدارس';

  @override
  String get navManagers => 'المديرون';

  @override
  String get navBagrut => 'بجروت';

  @override
  String get chatPreviewPhoto => 'صورة';

  @override
  String get chatPreviewVoice => 'رسالة صوتية';

  @override
  String get chatPreviewVideo => 'فيديو';

  @override
  String get chatPreviewAttachment => 'مرفق';

  @override
  String get chatPreviewMessage => 'رسالة';

  @override
  String get chatPreviewYou => 'أنت';

  @override
  String get adminDashboardTitle => 'نظرة عامة على المدرسة';

  @override
  String get adminStudents => 'الطلاب';

  @override
  String get adminTeachers => 'المعلمون';

  @override
  String get adminParents => 'أولياء الأمور';

  @override
  String get adminSecretaries => 'الأمناء';

  @override
  String get adminAdmins => 'المسؤولون';

  @override
  String get adminTodaySessions => 'جلسات اليوم';

  @override
  String get adminQuickActions => 'إجراءات سريعة';

  @override
  String get adminAttendanceLast30 => 'الحضور — آخر 30 يومًا';

  @override
  String get adminNoAttendanceData => 'لا توجد بيانات حضور خلال آخر 30 يومًا.';

  @override
  String get adminAddUser => 'إضافة مستخدم';

  @override
  String get adminCreateUser => 'إنشاء';

  @override
  String get adminFullName => 'الاسم الكامل';

  @override
  String get adminEmailAddress => 'البريد الإلكتروني';

  @override
  String get adminRoleLabel => 'الدور';

  @override
  String get adminUserCreated => 'تم إنشاء المستخدم';

  @override
  String get adminTempPassword => 'كلمة مرور مؤقتة';

  @override
  String get adminCopied => 'تم النسخ إلى الحافظة';

  @override
  String get adminResetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get adminPasswordReset => 'إعادة تعيين كلمة المرور';

  @override
  String adminTempPasswordFor(Object name) {
    return 'كلمة المرور المؤقتة لـ $name';
  }

  @override
  String get adminDeleteUser => 'حذف المستخدم';

  @override
  String adminDeleteUserConfirm(Object name) {
    return 'حذف $name؟ لا يمكن التراجع عن هذا.';
  }

  @override
  String get adminDeleteCohort => 'حذف المجموعة';

  @override
  String adminDeleteCohortConfirm(Object name) {
    return 'حذف \"$name\"؟ ستُحذف جميع عضويات الطلاب.';
  }

  @override
  String get adminAddCohort => 'إضافة مجموعة';

  @override
  String get adminNewCohort => 'مجموعة جديدة';

  @override
  String get adminCohortName => 'اسم المجموعة (مثال: 10أ)';

  @override
  String get adminCohortGrade => 'الصف';

  @override
  String get adminRenameCohort => 'إعادة تسمية';

  @override
  String get adminAddStudents => 'إضافة طلاب';

  @override
  String adminAddTo(Object name) {
    return 'إضافة إلى $name';
  }

  @override
  String get adminRemoveStudent => 'إزالة الطالب';

  @override
  String adminRemoveStudentConfirm(Object name, Object cohort) {
    return 'إزالة $name من $cohort؟';
  }

  @override
  String get adminNoCohortsYet => 'لا توجد مجموعات بعد';

  @override
  String get adminNoStudentsInCohort => 'لا يوجد طلاب في هذه المجموعة';

  @override
  String adminStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلاب',
      one: 'طالب واحد',
    );
    return '$_temp0';
  }

  @override
  String get adminSearchStudents => 'ابحث عن الطلاب…';

  @override
  String get adminScheduleTitle => 'الجدول الدراسي';

  @override
  String get adminScheduleAddPeriod => 'إضافة حصة';

  @override
  String get adminScheduleNewPeriod => 'حصة جديدة';

  @override
  String get adminScheduleDayLabel => 'اليوم';

  @override
  String adminSchedulePeriodLabel(Object period) {
    return 'ح$period';
  }

  @override
  String get adminScheduleTeacherLabel => 'المعلم';

  @override
  String get adminScheduleNoneTeacher => 'لا يوجد معلم';

  @override
  String get adminScheduleCohortLabel => 'المجموعة / الطلاب';

  @override
  String get adminScheduleFrequencyLabel => 'التكرار';

  @override
  String get adminScheduleFreqWeekly => 'كل أسبوع';

  @override
  String get adminScheduleFreqBiweekly => 'كل أسبوعين';

  @override
  String get adminScheduleFreqMonthly => 'كل 4 أسابيع';

  @override
  String get adminScheduleFreqCustom => 'مخصص';

  @override
  String adminScheduleFreqCustomLabel(int n) {
    return 'كل $n أسابيع';
  }

  @override
  String get adminScheduleAddSlot => 'إضافة فترة';

  @override
  String get adminScheduleAddAnother => 'إضافة يوم / حصة أخرى';

  @override
  String get adminScheduleSave => 'حفظ';

  @override
  String get adminScheduleSearchTeacher => 'ابحث عن المعلمين…';

  @override
  String get adminScheduleSearchCohort => 'ابحث عن المجموعات…';

  @override
  String get adminScheduleSelectTeacher => 'اختر المعلم';

  @override
  String get adminScheduleSelectCohort => 'اختر المجموعة';

  @override
  String get adminScheduleOrStudents => 'أو اختر طلابًا بشكل فردي';

  @override
  String get adminScheduleNoSlots => 'لا توجد حصص بعد';

  @override
  String get adminScheduleNoSlotsHint => 'اضغط + لإضافة أول حصة';

  @override
  String get adminSchoolSettingsTitle => 'إعدادات المدرسة';

  @override
  String get adminSchoolName => 'اسم المدرسة';

  @override
  String get adminSchoolLogoUrl => 'رابط الشعار (اختياري)';

  @override
  String get adminSchoolLogoHint => 'https://…';

  @override
  String get adminSchoolSaved => 'تم الحفظ';

  @override
  String get adminSubjectsTitle => 'المواد الدراسية';

  @override
  String adminSubjectsGrade(int grade) {
    return 'الصف $grade';
  }

  @override
  String get adminSubjectsAddHint => 'أضف مادة…';

  @override
  String get adminSubjectsNoSubjects => 'لم يتم تكوين مواد دراسية';

  @override
  String get adminSubjectsAdd => 'إضافة';

  @override
  String get adminSubjectsRemove => 'إزالة';

  @override
  String get adminSettingsTitle => 'الإعدادات';

  @override
  String get adminSettingsBellSchedule => 'جرس المدرسة';

  @override
  String get adminSettingsPeriodDefaults => 'مواعيد الحصص الافتراضية';

  @override
  String get adminSettingsPeriodDefaultsSubtitle => 'ضبط أوقات كل حصة';

  @override
  String get adminDeleteConfirmCancel => 'إلغاء';

  @override
  String get adminDeleteConfirmDelete => 'حذف';

  @override
  String get adminSave => 'حفظ';

  @override
  String get adminCancel => 'إلغاء';

  @override
  String get adminSearchPeople => 'ابحث بالاسم…';

  @override
  String adminNoResults(Object query) {
    return 'لا نتائج لـ \"$query\"';
  }

  @override
  String adminNoPeopleYet(Object role) {
    return 'لا يوجد $role بعد';
  }

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get chatThreadLoadFailedTitle => 'تعذّر تحميل هذه المحادثة';

  @override
  String get chatThreadLoadFailedBody =>
      'يرجى التحقق من اتصالك بالإنترنت ثم المحاولة مرة أخرى.';

  @override
  String get chatThreadLoadFailedBusy =>
      'الخادم مشغول قليلًا الآن. انتظر لحظة ثم أعد المحاولة.';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonDownload => 'تنزيل';

  @override
  String get commonOpenExternally => 'فتح خارجيًا';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonDone => 'تم';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonSearch => 'بحث…';

  @override
  String get commonShare => 'مشاركة';

  @override
  String get inboxActionPin => 'تثبيت المحادثة';

  @override
  String get inboxActionUnpin => 'إلغاء التثبيت';

  @override
  String get inboxActionMute => 'كتم';

  @override
  String get inboxActionUnmute => 'إلغاء الكتم';

  @override
  String get inboxActionMarkRead => 'تعليم كمقروء';

  @override
  String get inboxActionMarkUnread => 'تعليم كغير مقروء';

  @override
  String get inboxActionClear => 'مسح الرسائل';

  @override
  String get inboxActionClearConfirm =>
      'حذف كل الرسائل في هذه المحادثة؟ هذا يمسح نسختك فقط — يحتفظ الطرف الآخر بنسخته.';

  @override
  String get inboxActionDeleteChat => 'حذف المحادثة';

  @override
  String get inboxActionDeleteChatConfirm =>
      'حذف هذه المحادثة؟ ستختفي من قائمتك وسجلك؛ وتعود إذا راسلوك مرة أخرى.';

  @override
  String get inboxActionBlock => 'حظر جهة الاتصال';

  @override
  String get inboxActionBlockConfirm =>
      'حظر جهة الاتصال هذه؟ لن يتمكنوا من مراسلتك بعد الآن.';

  @override
  String get cmailActionMarkRead => 'تعليم كمقروء';

  @override
  String get cmailActionMarkUnread => 'تعليم كغير مقروء';

  @override
  String get cmailDeleteConfirm => 'حذف هذا البريد من صندوق بريدك؟';

  @override
  String get commonLoading => 'جارٍ التحميل…';

  @override
  String get commonError => 'حدث خطأ ما';

  @override
  String get commonTryAgain => 'حاول مرة أخرى';

  @override
  String get studentMaterialsTitle => 'المواد';

  @override
  String get studentMaterialsEmptyTitle => 'لا توجد مواد بعد';

  @override
  String get studentMaterialsEmptyHint => 'سيشارك معلمك الموارد هنا.';

  @override
  String get studentMaterialsLoadError => 'تعذّر تحميل المواد';

  @override
  String get studentAssignmentSubmittedSnackbar => 'تم تسليم الواجب!';

  @override
  String get studentAssignmentSubmitFailed => 'تعذر التسليم — حاول مرة أخرى.';

  @override
  String get studentAssignmentUploadFailed => 'فشل رفع الملف — حاول مرة أخرى.';

  @override
  String get studentAssignmentHandedInBadge => 'تم التسليم';

  @override
  String get studentAssignmentSubmitButton => 'تسليم';

  @override
  String get studentAssignmentSubmitting => 'جارٍ التسليم…';

  @override
  String get studentAssignmentAttachFile => 'إرفاق ملف';

  @override
  String get studentAssignmentAddMoreFiles => 'إضافة ملفات أخرى';

  @override
  String get studentAssignmentYourSubmission => 'تسليمك';

  @override
  String get studentAssignmentTeacherAttachments => 'المرفقات';

  @override
  String secretaryWelcomeGreeting(Object name) {
    return 'مرحبًا $name 👋';
  }

  @override
  String get secretaryYourTools => 'أدواتك';

  @override
  String get secretaryReports => 'البلاغات';

  @override
  String get secretaryExportData => 'تصدير البيانات';

  @override
  String get secretaryHomeTile => 'الرئيسية';

  @override
  String parentHomeGreeting(Object name) {
    return 'مرحبًا $name 👋';
  }

  @override
  String get parentYourTools => 'أدواتك';

  @override
  String get parentNoChildLinked => 'لم يتم ربط أي طفل بعد';

  @override
  String get parentPickChildFirst => 'اختر طفلاً أولاً';

  @override
  String get parentNoApprovedChildren =>
      'لا يوجد أطفال معتمدون بعد. اطلب من مدرستك ربط حسابك.';

  @override
  String get loginEmptyFieldsError =>
      'يرجى إدخال البريد الإلكتروني أو اسم المستخدم وكلمة المرور.';

  @override
  String get loginConnectionError =>
      'لا يوجد اتصال. تحقق من الإنترنت وحاول مرة أخرى.';

  @override
  String get loginTimeoutError => 'انتهت مهلة الطلب. حاول مرة أخرى.';

  @override
  String get loginForgotPasswordLink => 'نسيت كلمة المرور؟';

  @override
  String get forgotPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordModeEmail => 'البريد';

  @override
  String get forgotPasswordModeSms => 'رسالة نصية';

  @override
  String get forgotPasswordEmailSent =>
      'تم إرسال رابط إعادة التعيين (إن وُجد حساب مطابق).';

  @override
  String get forgotPasswordEmptyError =>
      'أدخل بريدك الإلكتروني أو اسم المستخدم للمتابعة.';

  @override
  String get forgotPasswordEmailButton =>
      'أرسل لي رابط إعادة التعيين عبر البريد';

  @override
  String get forgotPasswordSmsButton => 'أرسل لي رابط إعادة التعيين برسالة';

  @override
  String get forgotPasswordLinkExpires =>
      'تنتهي صلاحية الرابط خلال ساعة ويمكن استخدامه مرة واحدة فقط.';

  @override
  String get pushPermissionTitle => 'ابقَ على اطلاع';

  @override
  String get pushPermissionBody =>
      'فعّل الإشعارات حتى لا تفوتك الدرجات أو الرسائل أو تغييرات الجدول.';

  @override
  String commonRequiredField(Object field) {
    return '$field مطلوب';
  }

  @override
  String get commonAttachments => 'المرفقات';

  @override
  String get commonAttachFile => 'إرفاق ملف';

  @override
  String get commonReplaceFile => 'استبدال الملف';

  @override
  String get commonTitleRequired => 'العنوان مطلوب';

  @override
  String get commonPublish => 'نشر';

  @override
  String get commonContinue => 'متابعة';

  @override
  String get commonNext => 'التالي';

  @override
  String get commonStart => 'بداية';

  @override
  String get commonEnd => 'نهاية';

  @override
  String get commonRefresh => 'تحديث';

  @override
  String get commonRemove => 'إزالة';

  @override
  String get commonOpen => 'فتح';

  @override
  String get commonView => 'عرض';

  @override
  String get commonCopy => 'نسخ';

  @override
  String get commonAdd => 'إضافة';

  @override
  String get commonOptional => 'اختياري';

  @override
  String get commonRequired => 'مطلوب';

  @override
  String get commonAuto => 'تلقائي';

  @override
  String get teacherShareButton => 'مشاركة';

  @override
  String get teacherMaterialDetails => 'تفاصيل المادة';

  @override
  String get teacherMaterialTitleLabel => 'العنوان *';

  @override
  String get teacherMaterialDescriptionLabel => 'الوصف (اختياري)';

  @override
  String get teacherMaterialContentSection => 'المحتوى';

  @override
  String get teacherMaterialContentRequired => 'يرجى إرفاق ملف أو إضافة رابط';

  @override
  String teacherFilePickError(Object error) {
    return 'تعذّر اختيار الملف: $error';
  }

  @override
  String get teacherScheduleButton => 'جدولة';

  @override
  String get teacherMeetingTitleField => 'عنوان الاجتماع *';

  @override
  String get teacherMeetingLinkField => 'رابط الاجتماع *';

  @override
  String get teacherMeetingLinkRequired => 'رابط الاجتماع مطلوب';

  @override
  String get teacherMeetingTitleRequired => 'عنوان الاجتماع مطلوب';

  @override
  String get teacherMeetingDateTimeRequired => 'تاريخ ووقت البداية مطلوبان';

  @override
  String get teacherMeetingStartDate => 'تاريخ البداية *';

  @override
  String get teacherMeetingStartTime => 'وقت البداية *';

  @override
  String get teacherMeetingEndDate => 'تاريخ النهاية (اختياري)';

  @override
  String get teacherMeetingEndTime => 'وقت النهاية (اختياري)';

  @override
  String get teacherClearEndTime => 'مسح وقت النهاية';

  @override
  String get teacherAssignmentTitleField => 'العنوان *';

  @override
  String get teacherAssignmentInstructions => 'التعليمات (اختياري)';

  @override
  String get teacherAssignmentDueDate => 'تاريخ التسليم (اختياري)';

  @override
  String get teacherAssignmentClearDueDate => 'مسح تاريخ التسليم';

  @override
  String get teacherAssignmentMaxGrade => 'الدرجة القصوى (اختياري)';

  @override
  String get teacherAssignmentPublished => 'تم نشر الواجب.';

  @override
  String get teacherAssignmentDraftSaved => 'تم حفظ المسودة.';

  @override
  String get teacherCreateAssignment => 'إنشاء';

  @override
  String get teacherExamSubject => 'المادة *';

  @override
  String get teacherExamDate => 'تاريخ الامتحان *';

  @override
  String get teacherSelectSubject => 'اختر مادة';

  @override
  String get teacherNoSubjectOption => 'بدون مادة';

  @override
  String get teacherOtherSubjectOption => 'أخرى';

  @override
  String get teacherSearchClassrooms => 'ابحث عن الصفوف…';

  @override
  String get teacherSearchMaterials => 'ابحث عن المواد…';

  @override
  String get teacherClassroomName => 'اسم الصف *';

  @override
  String get adminReportsOpenTab => 'مفتوحة';

  @override
  String get adminReportsResolvedTab => 'تم الحل';

  @override
  String get adminReportsDismissedTab => 'تم الرفض';

  @override
  String get adminReportsNoOpen => 'لا توجد بلاغات مفتوحة';

  @override
  String get adminReportsNoInView => 'لا توجد بلاغات في هذا العرض';

  @override
  String get adminReportsMediaAttachment => '[مرفق وسائط]';

  @override
  String get adminReportsEmptyMessage => '(رسالة فارغة)';

  @override
  String get adminReportsDismiss => 'رفض';

  @override
  String get adminReportsResolve => 'حل';

  @override
  String adminReportsReason(Object reason) {
    return 'السبب: $reason';
  }

  @override
  String get chatReportTitle => 'الإبلاغ عن رسالة';

  @override
  String get chatReportButton => 'إبلاغ';

  @override
  String get chatReportSuccess => 'تم الإبلاغ. شكرًا — سيراجعها المسؤول.';

  @override
  String chatReportFailed(Object error) {
    return 'فشل الإبلاغ: $error';
  }

  @override
  String chatSendError(Object message) {
    return 'تعذّر الإرسال: $message';
  }

  @override
  String chatForwardLabel(Object count) {
    return 'إعادة توجيه $count';
  }

  @override
  String chatDeleteLabel(Object count) {
    return 'حذف $count';
  }

  @override
  String chatSelectedCount(Object count) {
    return '$count محدد';
  }

  @override
  String get adminSetupSchoolSetup => 'إعداد المدرسة';

  @override
  String get adminSetupComplete =>
      'اكتمل الإعداد. اضغط أي عنصر لإعادة زيارته أو تعديله.';

  @override
  String get adminSetupInstructions =>
      'أكمل هذه الخطوات لإعداد مدرستك بالكامل.';

  @override
  String get adminSetupLogoTitle => 'رفع شعار المدرسة';

  @override
  String get adminSetupLogoSubtitle => 'يظهر في الترويسة والقائمة الجانبية';

  @override
  String get adminSetupNameTitle => 'تعيين اسم المدرسة';

  @override
  String get adminSetupNameSubtitle => 'يظهر للطلاب والمعلمين وأولياء الأمور';

  @override
  String get adminSetupSubjectsTitle => 'تعريف المواد';

  @override
  String get adminSetupSubjectsSubtitle => 'صف واحد على الأقل مع مواد مُعدّة';

  @override
  String get adminSetupBellTitle => 'تعيين جدول الحصص';

  @override
  String get adminSetupBellSubtitle => 'أوقات بداية ونهاية كل حصة';

  @override
  String get adminSetupCohortsTitle => 'إنشاء المجموعات';

  @override
  String get adminSetupCohortsSubtitle => 'إعداد مجموعات الصفوف';

  @override
  String get adminSetupStudentsTitle => 'إضافة طلاب';

  @override
  String get adminSetupStudentsSubtitle => 'إنشاء حسابات أو توليد رموز انضمام';

  @override
  String get adminSetupTeachersTitle => 'إضافة معلمين';

  @override
  String get adminSetupTeachersSubtitle => 'إنشاء حسابات للمعلمين';

  @override
  String get supportContactTitle => 'تواصل معنا';

  @override
  String get supportContactDescription =>
      'لم تجد إجابتك أدناه؟ تواصل معنا وسنردّ خلال يوم عمل.';

  @override
  String get supportEmailLabel => 'البريد الإلكتروني';

  @override
  String get supportPhoneLabel => 'الهاتف';

  @override
  String get supportSmsLabel => 'رسالة';

  @override
  String get supportAiCardTitle => 'اسأل NOVA';

  @override
  String get supportAiCardSubtitle =>
      'NOVA تجيب عن أي سؤال حول استخدام ClassMate — في أي وقت';

  @override
  String get supportAiSheetTitle => 'NOVA';

  @override
  String get supportAiGreeting =>
      'مرحبًا! أنا NOVA، مساعدة ClassMate. اسألني أي شيء عن استخدام التطبيق — تسجيل الدخول، جدولك، العلامات، الرسائل والمزيد.';

  @override
  String get supportAiInputHint => 'اطرح سؤالًا…';

  @override
  String get supportAiDisclaimer =>
      'قد يخطئ الذكاء الاصطناعي. لأمور الحساب أو الفوترة أو الإبلاغ عن الأخطاء، راسلنا على support@classmateapp.org.';

  @override
  String get supportAiError =>
      'عذرًا — لم أتمكن من الإجابة الآن. يرجى المحاولة مرة أخرى، أو التواصل مع الدعم أعلاه.';

  @override
  String get aboutWhatIsClassmate => 'ما هو ClassMate؟';

  @override
  String get aboutClassmateDescription =>
      'ClassMate هو نظام تشغيل المدرسة للطلاب والمعلمين والإداريين وأولياء الأمور. تطبيق واحد، أربعة أدوار، وكل ما يخصّ اليوم الدراسي في مكان واحد — الجدول، الحضور، العلامات، الصفوف، الواجبات، الرسائل، ورفيق دراسة بالذكاء الاصطناعي.';

  @override
  String get aboutMultilingualTitle => 'مبني للمدارس التي تتحدث أكثر من لغة';

  @override
  String get aboutMultilingualDescription =>
      'كل اسم ومادة وإعلان يمكنه حمل ما يصل إلى خمس لغات (الإنجليزية، العربية، العبرية، الفرنسية، الروسية). يرى الطلاب اللغة التي يفضّلونها، ويُدير المعلمون بلغتهم.';

  @override
  String get aboutPrivacyTitle => 'الخصوصية أولًا';

  @override
  String get aboutPrivacyDescription =>
      'تبقى بيانات المدرسة داخل المدرسة. تتوافق الأدوار مع ما يستطيع كل شخص رؤيته — المعلمون يرون صفوفهم، الإداريون يرون مدرستهم، أولياء الأمور يرون أبناءهم. لا متتبّعون من جهات خارجية، ولا شبكات إعلانات.';

  @override
  String get aboutContactTitle => 'تواصل';

  @override
  String get aboutContactDescription =>
      'صنعه فريق ClassMate.\nاستفسارات: support@classmateapp.org';

  @override
  String aboutVersionLabel(Object version) {
    return 'ClassMate · إصدار $version';
  }

  @override
  String get adminAddStudent => 'إضافة طالب';

  @override
  String get adminAddTeacher => 'إضافة معلم';

  @override
  String get adminAddParent => 'إضافة ولي أمر';

  @override
  String get adminAddSecretary => 'إضافة سكرتير';

  @override
  String get adminAddAdmin => 'إضافة مسؤول';

  @override
  String get adminEditUser => 'تعديل المستخدم';

  @override
  String get adminNoEmailPlaceholder => '(لا يوجد بريد)';

  @override
  String get adminNameEnglishRequired => 'الاسم الكامل (بالإنجليزية) مطلوب';

  @override
  String get adminUsernameRequired => 'اسم المستخدم مطلوب';

  @override
  String get adminPasswordMinLength =>
      'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل (أو اتركها فارغة للتوليد التلقائي)';

  @override
  String adminUserCreatedMsg(Object name) {
    return 'تم إنشاء $name.';
  }

  @override
  String get adminCredsUsername => 'اسم المستخدم';

  @override
  String get adminCredsEmail => 'البريد الإلكتروني';

  @override
  String get adminCredsPassword => 'كلمة المرور';

  @override
  String get adminShareCredsHint => 'شارك هذه البيانات مع الطالب.';

  @override
  String get adminCopyCredsButton => 'نسخ الكل';

  @override
  String get adminGradeLabel => 'الصف';

  @override
  String adminCohortGradeFormat(Object grade) {
    return 'الصف $grade';
  }

  @override
  String get adminCreateAndAddStudents => 'إنشاء وإضافة طلاب';

  @override
  String get adminAddStudentsTitle => 'إضافة طلاب';

  @override
  String get adminSkipAdding => 'تخطّي';

  @override
  String get adminInCohortBadge => 'ضمن المجموعة';

  @override
  String get adminNoStudentsFoundCohort => 'لا يوجد طلاب في صفوف هذه المجموعة';

  @override
  String get adminScheduleByCohort => 'حسب المجموعة ▾';

  @override
  String get adminScheduleByStudent => 'حسب الطالب ▾';

  @override
  String get adminScheduleByGrade => 'حسب الصف ▾';

  @override
  String get navSupport => 'الدعم';

  @override
  String get navAbout => 'حول';

  @override
  String get adminScheduleAddGrade => 'إضافة صف';

  @override
  String get adminScheduleAddCohort => 'إضافة مجموعة';

  @override
  String get adminScheduleAddStudent => 'إضافة طالب';

  @override
  String get adminScheduleClearFilters => 'مسح';

  @override
  String get adminSchedulePickSubjectRequired => 'اختر مادة قبل حفظ الحصة.';

  @override
  String get adminSchedulePickDateOnce => 'اختر تاريخًا لحصة لمرة واحدة.';

  @override
  String adminSchedulePickDateRecurring(Object freq) {
    return 'اختر تاريخ بداية للجدول كل $freq أسابيع.';
  }

  @override
  String get adminSchoolLogoLabel => 'شعار المدرسة';

  @override
  String get adminSchoolLogoUploaded => 'تم رفع الشعار';

  @override
  String get adminSchoolNoLogoYet => 'لا يوجد شعار بعد';

  @override
  String get adminSchoolLogoDescription =>
      'يظهر بجانب اسم المدرسة في القائمة الجانبية.';

  @override
  String get adminSchoolLogoChange => 'تغيير';

  @override
  String get adminSchoolLogoUpload => 'رفع';

  @override
  String get adminSchoolLogoRemove => 'إزالة';

  @override
  String get adminSchoolGradeRangeLabel => 'نطاق الصفوف';

  @override
  String get adminSchoolGradeRangeDescription =>
      'الصفوف المتاحة عبر المجموعات والطلاب والقوائم.';

  @override
  String get adminSchoolLowestGrade => 'الأدنى';

  @override
  String get adminSchoolHighestGrade => 'الأعلى';

  @override
  String get adminSchoolSubjectsTitle => 'مواد المدرسة';

  @override
  String get adminSchoolSubjectsDescription =>
      'متاحة لجميع المعلمين عند إنشاء الواجبات.';

  @override
  String get adminSchoolNoTranslations => 'اضغط لإضافة ترجمات';

  @override
  String get adminSchoolBellHint =>
      'حدّد أوقات بداية ونهاية كل حصة. أضف أو احذف حصصًا حسب الحاجة.';

  @override
  String get adminSchoolBellTitle => 'جدول الأجراس';

  @override
  String get adminSchoolBellInfo =>
      'حدّد وقت البداية والنهاية لكل حصة. تصبح هذه الأوقات الافتراضية المستخدمة عند بناء الجدول الأسبوعي.';

  @override
  String get adminSchoolStartTime => 'البداية';

  @override
  String get adminSchoolEndTime => 'النهاية';

  @override
  String get adminExportStudentsTab => 'الطلاب';

  @override
  String get adminExportCohortsTab => 'المجموعات';

  @override
  String get adminExportGradesTab => 'الصفوف';

  @override
  String get adminExportOptionsTitle => 'خيارات التصدير';

  @override
  String get adminExportIncludePasswords => 'تضمين كلمات المرور';

  @override
  String get adminExportLanguageLabel => 'لغة الأسماء في التصدير';

  @override
  String get adminExportCsvButton => 'تصدير CSV';

  @override
  String get adminExportPdfButton => 'تصدير PDF';

  @override
  String get teacherCreateClassroomTooltip => 'إنشاء صف';

  @override
  String get teacherClassroomNameRequired => 'اسم الصف *';

  @override
  String get teacherSubjectRequired => 'المادة *';

  @override
  String messagesStartChatError(Object error) {
    return 'تعذّر بدء المحادثة: $error';
  }

  @override
  String messagesNoPeopleMatch(Object query) {
    return 'لا يوجد أشخاص يطابقون \"$query\"';
  }

  @override
  String get messagesNoPeopleFound => 'لم يتم العثور على أشخاص';

  @override
  String messagesPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count أشخاص',
      one: 'شخص واحد',
    );
    return '$_temp0';
  }

  @override
  String get studentAssignmentValidationRequired =>
      'أضف ملاحظة أو أرفق ملفًا قبل التسليم.';

  @override
  String get studentFormSubmittedBanner => 'إجاباتك المُسلَّمة';

  @override
  String studentFormSubmitError(Object error) {
    return 'تعذّر التسليم: $error';
  }

  @override
  String studentFormFieldRequired(Object field) {
    return 'مطلوب: $field';
  }

  @override
  String get studentFormClosedButton => 'النموذج مغلق';

  @override
  String get studentFormAlreadySubmittedButton => 'تم التسليم مسبقًا';

  @override
  String get studentDiplomaEditTitle => 'تعديل الشهادة';

  @override
  String get studentDiplomaDeleteTitle => 'حذف الشهادة؟';

  @override
  String studentDiplomaDeleteConfirm(Object name) {
    return 'هل تريد إزالة شهادة \"$name\"؟';
  }

  @override
  String teacherDeleteItemConfirm(Object title) {
    return 'حذف \"$title\"؟';
  }

  @override
  String get teacherPublishTooltip => 'نشر';

  @override
  String get teacherMeetingEnterTitle => 'يرجى إدخال عنوان.';

  @override
  String get teacherMeetingEnterLink => 'يرجى إدخال رابط الاجتماع.';

  @override
  String get teacherMeetingEnterValidUrl =>
      'يرجى إدخال رابط صالح (مثال: https://zoom.us/j/...)';

  @override
  String get teacherMeetingPickStartTime => 'يرجى اختيار وقت البداية.';

  @override
  String get teacherMeetingVisibleToEveryone => 'مرئي للجميع';

  @override
  String teacherMeetingDoneCount(int count) {
    return 'تم ($count محدد)';
  }

  @override
  String get teacherDeleteAssignmentTitle => 'حذف الواجب؟';

  @override
  String get teacherDeleteAssignmentBody =>
      'سيؤدي ذلك إلى حذف الواجب وكل التسليمات نهائيًا.';

  @override
  String get teacherEditTooltip => 'تعديل';

  @override
  String get teacherDeleteTooltip => 'حذف';

  @override
  String get teacherClassroomBackTooltip => 'رجوع';

  @override
  String teacherClassroomGenericError(Object error) {
    return 'خطأ: $error';
  }

  @override
  String teacherClassroomAttachFailed(Object error) {
    return 'فشل الإرفاق: $error';
  }

  @override
  String get teacherClassroomFileUnavailable =>
      'هذا الملف غير متاح — يجب على المعلم إعادة رفعه.';

  @override
  String get teacherClassroomCodeLabel => 'رمز الصف';

  @override
  String get teacherClassroomCodeCopied => 'تم نسخ الرمز';

  @override
  String get teacherClassroomCopyCodeTooltip => 'نسخ الرمز';

  @override
  String teacherClassroomCouldNotAdd(Object emails) {
    return 'تعذّر إضافة: $emails — تحقق من بريدهم الإلكتروني.';
  }

  @override
  String get teacherClassroomAddStudents => 'إضافة طلاب';

  @override
  String get teacherClassroomSearchNameGrade => 'ابحث بالاسم أو الصف…';

  @override
  String get teacherClassroomNoStudentsFound => 'لم يتم العثور على طلاب';

  @override
  String get teacherClassroomNameSubjectRequired => 'الاسم والمادة مطلوبان.';

  @override
  String get teacherClassroomCreated => 'تم إنشاء الصف!';

  @override
  String get teacherCustomSubjectLabel => 'مادة مخصصة *';

  @override
  String get teacherCreateClassroomButton => 'إنشاء صف';

  @override
  String get teacherCreateFormTitle => 'إنشاء نموذج';

  @override
  String get teacherFormSaveDraft => 'حفظ مسودة';

  @override
  String get teacherFormTitleHint => 'عنوان النموذج *';

  @override
  String get teacherFormDescriptionHint => 'الوصف (اختياري)';

  @override
  String get teacherFormAcceptingResponses => 'يقبل الإجابات';

  @override
  String get teacherFormAllowMultiple => 'السماح بإجابات متعددة';

  @override
  String get teacherFormAllowMultipleSubtitle =>
      'معطّل = مرة واحدة لكل طالب (افتراضي)';

  @override
  String get teacherFormQuestionsSection => 'الأسئلة';

  @override
  String get teacherFormAddQuestionButton => 'إضافة سؤال';

  @override
  String teacherFormQuestionPlaceholder(Object index) {
    return 'السؤال $index';
  }

  @override
  String get teacherFormRequiredToggle => 'مطلوب';

  @override
  String get teacherFormAddOptionButton => 'إضافة خيار';

  @override
  String get teacherFormMinLabel => 'الحد الأدنى';

  @override
  String get teacherFormMaxLabel => 'الحد الأقصى';

  @override
  String get teacherFormEnterTitle => 'يرجى إدخال عنوان للنموذج.';

  @override
  String teacherExamUploadFailedSkipped(Object name) {
    return 'فشل رفع $name. تم تجاهل الملف.';
  }

  @override
  String get teacherExamEnterTitle => 'يرجى إدخال عنوان.';

  @override
  String get teacherExamPickDate => 'يرجى اختيار تاريخ الامتحان.';

  @override
  String get teacherExamSelectSubject => 'يرجى اختيار مادة.';

  @override
  String teacherSlotDetachFailed(Object error) {
    return 'فشل الفصل: $error';
  }

  @override
  String teacherSlotAttachFailed(Object error) {
    return 'فشل الإرفاق: $error';
  }

  @override
  String get teacherSlotAttachMaterial => 'إرفاق مادة';

  @override
  String get teacherSlotDetachTooltip => 'فصل';

  @override
  String get teacherDiplomaSelectStudent => 'اختر طالبًا أولاً.';

  @override
  String get teacherDiplomaUploadingWait =>
      'يرجى الانتظار — لا تزال الملفات تُرفع.';

  @override
  String teacherDiplomaIssueFailed(Object error) {
    return 'تعذّر إصدار الشهادة: $error';
  }

  @override
  String get teacherDiplomaCertTitleLabel => 'عنوان الشهادة';

  @override
  String get teacherDiplomaSearchStudent => 'ابحث عن طالب…';

  @override
  String get teacherProfileChatError => 'تعذّر بدء المحادثة';

  @override
  String get teacherGradeAssignmentType => 'واجب';

  @override
  String get teacherGradeExamType => 'امتحان';

  @override
  String get teacherGradeOtherType => 'أخرى';

  @override
  String get teacherGradeOutOfLabel => 'من (اختياري)';

  @override
  String get teacherGradePublishedTitle => 'منشورة';

  @override
  String get teacherGradePublishedSubtitle => 'يمكن للطلاب رؤية هذه الدرجة';

  @override
  String get teacherMaterialPickSubject => 'يرجى اختيار مادة.';

  @override
  String get teacherMaterialAddLink => 'إضافة رابط';

  @override
  String get teacherMaterialAddFile => 'إضافة ملف';

  @override
  String get teacherMaterialSearchStudentsGrade => 'ابحث عن الطلاب أو الصف...';

  @override
  String teacherMaterialDoneSelected(int count) {
    return 'تم ($count محدد)';
  }

  @override
  String get adminSubjectEnglishNameRequired => 'الاسم بالإنجليزية مطلوب';

  @override
  String adminSubjectNameInLang(Object language) {
    return 'الاسم بـ $language';
  }

  @override
  String get adminSubjectResetButton => 'إعادة تعيين';

  @override
  String get teacherAnnounceBroadcastTitle => 'إرسال للجميع؟';

  @override
  String get teacherAnnounceSendToEveryone => 'إرسال للجميع';

  @override
  String get teacherAnnounceNoCohorts => 'لا توجد مجموعات متاحة';

  @override
  String get teacherAnnounceNothingFound => 'لم يتم العثور على شيء';

  @override
  String get teacherAnnounceNoParents =>
      'لم يتم العثور على أولياء أمور في هذه المدرسة.';

  @override
  String get teacherGradesToGrade => 'للتقدير';

  @override
  String get teacherGradesGraded => 'تم التقدير';

  @override
  String get teacherSaveGradesButton => 'حفظ الدرجات';

  @override
  String get teacherAllowResubmitLabel => 'السماح بإعادة التسليم';

  @override
  String get teacherAllowResubmitTitle => 'السماح بإعادة التسليم؟';

  @override
  String teacherAllowResubmitBody(Object name) {
    return 'سيؤدي ذلك إلى حذف تسليم $name ليتمكن من التسليم مجددًا.';
  }

  @override
  String get teacherAllowButton => 'السماح';

  @override
  String get teacherGradeFieldLabel => 'الدرجة';

  @override
  String get teacherFeedbackOptionalLabel => 'ملاحظات (اختياري)';

  @override
  String get teacherCreateClassroomFabLabel => 'إنشاء';

  @override
  String get teacherLoadingStudents => 'جارٍ تحميل الطلاب…';

  @override
  String get teacherSearchHintShort => 'بحث…';

  @override
  String get teacherCreateClassroomTitle => 'صف جديد';

  @override
  String teacherAssignmentUploadFailed(Object name) {
    return 'تعذّر رفع $name';
  }

  @override
  String get teacherAssignmentEnterTitle => 'يرجى إدخال عنوان.';

  @override
  String get teacherAssignmentSelectSubject => 'يرجى اختيار مادة.';

  @override
  String get teacherAssignmentInstructionsLabel => 'التعليمات / الوصف';

  @override
  String get teacherAttachFilesButton => 'إرفاق ملفات';

  @override
  String get tutorDeleteConversationTitle => 'حذف المحادثة؟';

  @override
  String get tutorDeleteConversationButton => 'حذف نهائيًا';

  @override
  String tutorDeleteFailed(Object error) {
    return 'تعذّر الحذف: $error';
  }

  @override
  String get tutorDeleteMenuTitle => 'حذف المحادثة';

  @override
  String get tutorDeleteMenuSubtitle => 'يحذف المحادثة نهائيًا من الخادم';

  @override
  String get accountVerifyButton => 'تحقق';

  @override
  String get accountConfirmButton => 'تأكيد';

  @override
  String get accountResendCode => 'إعادة إرسال الرمز';

  @override
  String get accountCodeResent => 'تم إرسال رمز جديد.';

  @override
  String get accountContinueButton => 'متابعة';

  @override
  String get studentClassroomFileUnavailable => 'هذا الملف غير متاح حاليًا.';

  @override
  String get studentClassroomDeleteMaterial => 'حذف المادة؟';

  @override
  String get studentClassroomCodeLabel => 'رمز الصف';

  @override
  String get studentClassroomLeaveTooltip => 'مغادرة الصف';

  @override
  String get adminEditUserEnglishNameRequired => 'الاسم بالإنجليزية مطلوب';

  @override
  String get adminEditUserSaved => 'تم الحفظ';

  @override
  String adminEditUserPasswordChanged(Object name) {
    return 'تم تغيير كلمة المرور لـ $name.';
  }

  @override
  String get adminEditUserLoginSection => 'تسجيل الدخول';

  @override
  String get adminEditUserUsernameLabel => 'اسم المستخدم';

  @override
  String get adminEditUserEmailOptional => 'البريد الإلكتروني (اختياري)';

  @override
  String get adminEditUserChangePassword => 'تغيير كلمة المرور';

  @override
  String get adminEditUserNameSection => 'الاسم';

  @override
  String get adminEditUserAtLeastEnglish => 'الإنجليزية مطلوبة على الأقل.';

  @override
  String get adminEditUserGradeSection => 'الصف';

  @override
  String get adminEditUserCohortsSection => 'المجموعات';

  @override
  String get adminEditUserLinkedChildren => 'الأبناء المربوطون';

  @override
  String get adminEditUserLinkButton => 'ربط';

  @override
  String get adminEditUserNoChildren => 'لم يتم ربط أبناء بعد.';

  @override
  String get adminEditUserSetPasswordTitle => 'تعيين كلمة مرور جديدة';

  @override
  String get adminEditUserNewPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get adminEditUserConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get adminEditUserSetPasswordButton => 'تعيين كلمة المرور';

  @override
  String get adminPeriodsTitle => 'إدارة الحصص';

  @override
  String get adminPeriodsAddPeriod => 'إضافة حصة';

  @override
  String get adminPeriodsNoPeriods => 'لا توجد حصص بعد';

  @override
  String get adminPeriodsTapToAdd => 'اضغط + لإضافة أول حصة';

  @override
  String get adminPeriodsNewPeriod => 'حصة جديدة';

  @override
  String get adminPeriodsDayLabel => 'اليوم';

  @override
  String get adminPeriodsPeriodLabel => 'الحصة';

  @override
  String get adminPeriodsTimeLabel => 'الوقت';

  @override
  String get adminPeriodsTeacherLabel => 'المعلم';

  @override
  String get adminPeriodsClassroomOptional => 'الصف (اختياري)';

  @override
  String get adminPeriodsCohortsLabel => 'المجموعات';

  @override
  String get adminPeriodsStudentsOptional => 'الطلاب (اختياري)';

  @override
  String get adminPeriodsSearchByName => 'ابحث بالاسم…';

  @override
  String commonErrorWith(Object error) {
    return 'خطأ: $error';
  }

  @override
  String commonAddCount(int count) {
    return 'إضافة $count';
  }

  @override
  String get teacherStudentGradesSaved => 'تم حفظ الدرجات';

  @override
  String get teacherStudentToGrade => 'بانتظار التقدير';

  @override
  String get teacherStudentGraded => 'تم التقدير';

  @override
  String get classroomFileNotAvailable => 'هذا الملف غير متاح بعد.';

  @override
  String get classroomDeleteMaterialTitle => 'حذف المادة؟';

  @override
  String get classroomCodeLabel => 'رمز الصف';

  @override
  String get plansCouldNotOpenSubscription => 'تعذر فتح إعدادات الاشتراك.';

  @override
  String plansFailedToOpen(Object error) {
    return 'فشل الفتح: $error';
  }

  @override
  String get plansManageSubscription => 'إدارة الاشتراك أو إلغاؤه';

  @override
  String get plansUpgrade => 'ترقية';

  @override
  String get plansTryAgain => 'أعد المحاولة';

  @override
  String adminCohortsGradeOnly(String grade) {
    return 'الصف $grade فقط';
  }

  @override
  String adminCohortsGradeRangeOnly(int from, int to) {
    return 'الصفوف $from-$to فقط';
  }

  @override
  String get adminExportNeedStudents =>
      'اختر طالبًا واحدًا أو مجموعة على الأقل أولاً';

  @override
  String adminExportButton(int count) {
    return 'تصدير $count';
  }

  @override
  String get adminExportNoStudents => 'لم يتم العثور على طلاب';

  @override
  String get adminExportIncludesPasswords =>
      'سيؤدي التصدير إلى إعادة تعيين كلمات المرور وتضمينها';

  @override
  String get adminExportAnyway => 'تصدير على أي حال';

  @override
  String get adminExportPdfStudentDirectory => 'دليل الطلاب';

  @override
  String adminExportPdfBy(String name) {
    return 'بواسطة: $name';
  }

  @override
  String adminExportPdfStudentsCount(int count) {
    return '$count طالبًا';
  }

  @override
  String get adminExportPdfFooter => 'تم الإنشاء بواسطة ClassMate';

  @override
  String get adminExportColumnIndex => '#';

  @override
  String get adminExportColumnName => 'الاسم';

  @override
  String get adminExportColumnEmail => 'البريد الإلكتروني';

  @override
  String get adminExportColumnUsername => 'اسم المستخدم';

  @override
  String get adminExportColumnPhone => 'الهاتف';

  @override
  String get adminExportColumnGrade => 'الصف';

  @override
  String get adminExportColumnCohorts => 'المجموعات';

  @override
  String get adminExportColumnSchool => 'المدرسة';

  @override
  String get adminExportColumnPassword => 'كلمة المرور';

  @override
  String get adminExportColumnNameEn => 'الاسم (EN)';

  @override
  String get adminExportColumnNameAr => 'الاسم (AR)';

  @override
  String get adminExportColumnNameHe => 'الاسم (HE)';

  @override
  String get adminExportColumnNameFr => 'الاسم (FR)';

  @override
  String get adminExportColumnNameRu => 'الاسم (RU)';

  @override
  String adminExportStudentsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم اختيار $count طلاب',
      one: 'تم اختيار طالب واحد',
    );
    return '$_temp0';
  }

  @override
  String get teacherMaterialEditTitle => 'تعديل المادة';

  @override
  String get teacherMaterialAddTitle => 'إضافة مادة';

  @override
  String get teacherMaterialAudienceTitle => 'الجمهور';

  @override
  String get teacherMaterialAudienceClassrooms => 'الصفوف';

  @override
  String get teacherMaterialAudienceCohorts => 'المجموعات';

  @override
  String get teacherMaterialAudienceGrades => 'الصفوف الدراسية';

  @override
  String get teacherMaterialAudienceStudents => 'الطلاب';

  @override
  String get teacherMaterialDetailsTitle => 'التفاصيل';

  @override
  String get teacherMaterialSubjectRequired => 'المادة *';

  @override
  String get teacherMaterialSubjectSelect => 'اختر المادة';

  @override
  String get teacherMaterialSubjectOther => 'أخرى';

  @override
  String get teacherMaterialSubjectSearch => 'ابحث عن المواد...';

  @override
  String get teacherMaterialAttachmentsTitle => 'المرفقات';

  @override
  String teacherMaterialAttachmentsWithCount(int count) {
    return 'المرفقات ($count)';
  }

  @override
  String get teacherMaterialDeleteTitle => 'حذف المادة؟';

  @override
  String get teacherMaterialListTitle => 'المواد';

  @override
  String teacherMaterialTotalCount(int count) {
    return '$count إجمالي';
  }

  @override
  String get teacherMaterialRetry => 'إعادة المحاولة';

  @override
  String get teacherMaterialNoMaterials =>
      'لا توجد مواد بعد.\nاضغط + لإضافة واحدة.';

  @override
  String get teacherMaterialPublished => 'منشور';

  @override
  String get teacherMaterialDraft => 'مسودة';

  @override
  String get teacherMaterialSearchHint => 'بحث…';

  @override
  String teacherMaterialSelectedCount(int count) {
    return '$count محدد';
  }

  @override
  String teacherMaterialMembersWillReceive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيستلم $count أعضاء هذا',
      one: 'سيستلم عضو واحد هذا',
    );
    return '$_temp0';
  }

  @override
  String teacherMaterialStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلاب',
      one: 'طالب واحد',
    );
    return '$_temp0';
  }

  @override
  String get teacherMaterialPickerNone => 'لا شيء';

  @override
  String get teacherMaterialPickerCohortsTitle => 'اختر المجموعات';

  @override
  String get teacherMaterialPickerClassroomTitle => 'اختر الصف';

  @override
  String get teacherMaterialPickerStudentsTitle => 'اختر الطلاب';

  @override
  String get teacherMaterialPickerGradesTitle => 'اختر الصفوف';

  @override
  String get adminScheduleAddNew => 'إضافة جديد';

  @override
  String adminScheduleAddCount(int count) {
    return 'إضافة ($count)';
  }

  @override
  String get adminScheduleCaptionOptional => 'تسمية توضيحية (اختياري)';

  @override
  String get adminScheduleCaptionHint => 'مثل: مراجعة الامتحان';

  @override
  String get adminScheduleAudienceCohorts => 'المجموعات';

  @override
  String get adminScheduleAudienceStudents => 'الطلاب';

  @override
  String get adminScheduleAudienceGrade => 'الصف';

  @override
  String get adminScheduleSearchStudents => 'ابحث عن الطلاب…';

  @override
  String get adminScheduleSearchSubjects => 'ابحث في مواد المدرسة…';

  @override
  String get adminScheduleEveryPrefix => 'كل ';

  @override
  String get adminScheduleWeeksSuffix => ' أسابيع';

  @override
  String adminScheduleSlotN(int index) {
    return 'الفترة $index';
  }

  @override
  String adminScheduleSelectedCount(int count) {
    return 'تم اختيار $count';
  }

  @override
  String get adminScheduleConflictingPeriod => 'حصة متعارضة';

  @override
  String get adminScheduleKeepCurrent => 'احتفظ بالحالي';

  @override
  String get adminScheduleOverride => 'تجاوز';

  @override
  String get adminScheduleShowBoth => 'عرض الاثنين';

  @override
  String get adminScheduleDeletePeriodTitle => 'حذف الحصة؟';

  @override
  String get adminScheduleDeletePeriodBody =>
      'هذا يزيل الفترة من الجدول. يظل الحضور السابق محفوظًا.';

  @override
  String get adminScheduleFailedToDelete => 'فشل حذف الحصة.';

  @override
  String get adminSchedulePickSubjectFirst => 'اختر مادة قبل حفظ الحصة.';

  @override
  String adminScheduleOverrideFailed(Object error) {
    return 'فشل التجاوز: $error';
  }

  @override
  String get adminScheduleFailedToCreateSlots => 'فشل إنشاء الفترات';

  @override
  String adminScheduleCreatedSlots(int created, int total, String error) {
    return 'تم إنشاء $created/$total فترات. $error';
  }

  @override
  String adminScheduleSavedLabelOnlyError(Object error) {
    return 'تم الحفظ كتسمية فقط — تعذرت الإضافة إلى المكتبة: $error';
  }

  @override
  String get adminScheduleSavedLabelPickAudience =>
      'تم الحفظ كتسمية. اختر جمهورًا أولاً لإضافة المادة إلى مكتبة المدرسة أيضًا.';

  @override
  String get commonNothingFound => 'لم يتم العثور على شيء';

  @override
  String commonDownloadFailed(Object error) {
    return 'فشل التنزيل: $error';
  }

  @override
  String commonFailedWith(Object error) {
    return 'فشل: $error';
  }

  @override
  String get commonCreate => 'إنشاء';

  @override
  String get commonAttachStudyMaterials => 'إرفاق مواد الدراسة';

  @override
  String get teacherCreateClassroomNewTitle => 'صف جديد';

  @override
  String get teacherCreateClassroomLoadingStudents => 'جاري تحميل الطلاب…';

  @override
  String get teacherExamPublishedHint =>
      'منشور — يمكن للطلاب رؤية هذا الامتحان';

  @override
  String teacherDoneSelected(int count) {
    return 'تم ($count محدد)';
  }

  @override
  String get secretaryAllCohorts => 'جميع المجموعات';

  @override
  String get secretaryClassrooms => 'الصفوف';

  @override
  String get adminPeopleGrade => 'الصف';

  @override
  String get adminSchoolSettingsTapToAddTranslations => 'اضغط لإضافة الترجمات';

  @override
  String adminSchoolSettingsAddPeriodNum(int num) {
    return 'إضافة حصة (P$num)';
  }

  @override
  String get adminVisibleToEveryone => 'مرئي للجميع';

  @override
  String get navMaterials => 'المواد التعليمية';

  @override
  String get classMaterialsAddTitle => 'إضافة مادة';

  @override
  String get classMaterialsTitleLabel => 'العنوان';

  @override
  String classMaterialsFilesCount(int count) {
    return '$count ملفات';
  }

  @override
  String get classMaterialsLoadError => 'تعذّر تحميل المواد';

  @override
  String get classMaterialsEmpty => 'لا توجد مواد مشتركة بعد — كن أول من يضيف.';

  @override
  String get navPlans => 'خطط NOVA';

  @override
  String get navReports => 'البلاغات';

  @override
  String get navExportData => 'تصدير البيانات';

  @override
  String get sectionSecretaryTools => 'أدوات السكرتارية';

  @override
  String get sectionSchoolToolsLabel => 'أدوات المدرسة';

  @override
  String get sectionAdminTools => 'أدوات الإدارة';

  @override
  String get chatVideoTrimTitle => 'اقتطاع الفيديو';

  @override
  String get chatMediaPreviewTrimAction => 'اقتطاع';

  @override
  String get commonUntitled => 'بدون عنوان';

  @override
  String get plansMonthlyPlans => 'الخطط الشهرية';

  @override
  String get plansTokenTopups => 'حزم الرموز';

  @override
  String get plansTopupsSubtitle =>
      'عمليات شراء لمرة واحدة. لا تنتهي صلاحيتها. تُضاف فوق خطتك.';

  @override
  String get plansCouldntLoadBalance => 'تعذر تحميل رصيدك';

  @override
  String get plansFreePlan => 'الخطة المجانية';

  @override
  String get planTierFree => 'مجاني';

  @override
  String get planTierBudget => 'اقتصادي';

  @override
  String get planTierBalance => 'متوازن';

  @override
  String get planTierCommitment => 'التزام';

  @override
  String get topupPackSmall => 'حزمة صغيرة';

  @override
  String get topupPackMedium => 'حزمة متوسطة';

  @override
  String get topupPackLarge => 'حزمة كبيرة';

  @override
  String get topupPackMega => 'حزمة ضخمة';

  @override
  String get planBlurbFree => 'جرّب نوفا. يتم تجديده شهريًا.';

  @override
  String get planBlurbBudget => 'مساعدة يومية في الواجبات.';

  @override
  String get planBlurbBalance => 'للطلاب الذين يدرسون كل يوم.';

  @override
  String get planBlurbCommitment => 'تدريب مكثف + فضول بلا حدود.';

  @override
  String plansTokensPerMonth(String tokens) {
    return '$tokens رمزًا / شهر';
  }

  @override
  String plansTokensOneTime(String tokens) {
    return '$tokens رمزًا';
  }

  @override
  String get planPriceFree => 'مجاني';

  @override
  String get plansTokensRemaining => 'رموز متبقية';

  @override
  String plansPlanResetsAt(String when) {
    return 'تُعاد تهيئة الخطة $when';
  }

  @override
  String plansTopupTokensInfo(String tokens) {
    return '$tokens رموز إضافية (بدون انتهاء)';
  }

  @override
  String get plansHowTokensWorkTitle => 'كيف تعمل الرموز';

  @override
  String get plansHowTokensWorkBody =>
      'الرموز هي الطريقة التي يحسب بها الذكاء الاصطناعي عمله.\n• سؤال قصير ≈ 2,000 رمز\n• شرح طويل أو جلسة تدريب ≈ 5,000–10,000\n• تحليل الصور يكلف أكثر قليلاً\n\nتُعاد تهيئة رموزك الشهرية في اليوم الأول. الرموز الإضافية لا تنتهي أبدًا.';

  @override
  String get plansPerMonthSuffix => ' / شهريًا';

  @override
  String get plansCurrentBadge => 'الحالية';

  @override
  String get plansCouldntLoadPlans => 'تعذر تحميل الخطط';

  @override
  String get paywallPlansUnavailable =>
      'الخطط غير متاحة. حاول مرة أخرى بعد قليل.';

  @override
  String get paywallTopupUnavailable =>
      'الحزمة غير متاحة. لم يكتمل اعتماد المنتج من قبل المتجر.';

  @override
  String get paywallRestored => 'تمت استعادة اشتراكك.';

  @override
  String get paywallNoRestores =>
      'لم يتم العثور على مشتريات سابقة على معرف Apple هذا.';

  @override
  String paywallRestoreFailed(String error) {
    return 'فشلت الاستعادة: $error';
  }

  @override
  String get paywallPurchasesRestricted => 'المشتريات مقيدة على هذا الجهاز.';

  @override
  String get paywallPurchaseInvalid =>
      'هذه العملية غير صالحة. جرب طريقة دفع أخرى.';

  @override
  String get paywallProductNotAvailable =>
      'هذه الخطة غير متاحة الآن. حاول لاحقًا.';

  @override
  String get paywallNetworkError =>
      'مشكلة في الشبكة. تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get paywallPaymentPending =>
      'الدفع قيد الموافقة (الرقابة الأبوية، إلخ.). سيتم التفعيل بعد الموافقة.';

  @override
  String get paywallStoreProblem =>
      'حدثت مشكلة في App Store. حاول مرة أخرى بعد قليل.';

  @override
  String get paywallGenericError => 'حدث خطأ. حاول مرة أخرى.';

  @override
  String paywallWelcomeMessage(String plan) {
    return 'أهلاً بك في $plan! الرموز في الطريق.';
  }

  @override
  String get paywallWelcomeFallback => 'خطتك الجديدة';

  @override
  String get paywallTopupAdded => 'تمت إضافة الحزمة. الرموز في الطريق.';

  @override
  String get paywallPurchaseProcessed =>
      'تمت معالجة عملية الشراء. ستظهر الرموز قريبًا.';

  @override
  String paywallSubscribeTo(String plan) {
    return 'اشترك في $plan';
  }

  @override
  String paywallBuyTopupNamed(String topup) {
    return 'اشترِ $topup';
  }

  @override
  String get paywallPlanFallback => 'الخطة';

  @override
  String get paywallTopupFallback => 'الحزمة';

  @override
  String get paywallTopupBlurb =>
      'شراء لمرة واحدة. الرموز لا تنتهي صلاحيتها وتُضاف فوق خطتك.';

  @override
  String paywallPerMonthWithTokens(String tokens) {
    return 'شهريًا · $tokens';
  }

  @override
  String paywallOneTimeWithTokens(String tokens) {
    return 'لمرة واحدة · $tokens';
  }

  @override
  String get paywallSubscribeButton => 'اشتراك';

  @override
  String get paywallBuyButton => 'شراء';

  @override
  String get paywallRestoreButton => 'استعادة المشتريات';

  @override
  String get paywallNotNow => 'ليس الآن';

  @override
  String get paywallWebOnlyTitle => 'الشراء من الجوال';

  @override
  String get paywallWebOnlyBody =>
      'تتم الاشتراكات وعمليات الشحن عبر متجر App Store أو Google Play. افتح ClassMate على هاتفك أو جهازك اللوحي للاشتراك — حسابك ورصيدك مشتركان بين جميع الأجهزة.';

  @override
  String get paywallWebOnlyDismiss => 'حسنًا';

  @override
  String get paywallTermsSubscription =>
      'بالاشتراك فإنك توافق على شروط ClassMate وسياسة الخصوصية. تتجدد الاشتراكات شهريًا تلقائيًا حتى يتم إلغاؤها. تتم الإدارة في أي وقت من حساب App Store الخاص بك.';

  @override
  String get paywallTermsTopup =>
      'بالشراء فإنك توافق على شروط ClassMate وسياسة الخصوصية. الرموز الإضافية غير قابلة للاسترداد بعد الاستخدام.';

  @override
  String get paywallTermsLink => 'شروط الاستخدام (EULA)';

  @override
  String get paywallPrivacyLink => 'سياسة الخصوصية';

  @override
  String get paywallFeatureTokens => 'استخدم الرموز في NOVA والتمارين';

  @override
  String get paywallFeatureImages => 'تحليل الصور ورفع الملفات مشمولان';

  @override
  String get paywallFeatureReset => 'تُعاد تهيئة الرموز في بداية كل شهر';

  @override
  String get paywallFeatureCancel => 'ألغِ في أي وقت — دون التزام';

  @override
  String get studentMaterialsGeneralSubject => 'عام';

  @override
  String studentMaterialsResourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مصادر من معلميك',
      one: 'مصدر واحد من معلميك',
    );
    return '$_temp0';
  }

  @override
  String classroomsCouldNotLoadWithError(String error) {
    return 'تعذر تحميل الصفوف\n$error';
  }

  @override
  String get parentNoNotificationsYet => 'لا توجد إشعارات بعد.';

  @override
  String forwardCouldNotLoadChats(Object error) {
    return 'تعذر تحميل المحادثات: $error';
  }

  @override
  String get forwardNoChats => 'لا توجد محادثات';

  @override
  String get commonTitle => 'العنوان';

  @override
  String get commonNotes => 'ملاحظات';

  @override
  String get commonEmail => 'البريد الإلكتروني';

  @override
  String get commonPassword => 'كلمة المرور';

  @override
  String get commonNumberOfPages => 'عدد الصفحات';

  @override
  String get messagesSearchByNameOrGrade => 'ابحث بالاسم أو الصف…';

  @override
  String get meetingStartDateRequired => 'تاريخ البدء *';

  @override
  String get meetingStartTimeRequired => 'وقت البدء *';

  @override
  String get meetingEndDateOptional => 'تاريخ الانتهاء (اختياري)';

  @override
  String get meetingEndTimeOptional => 'وقت الانتهاء (اختياري)';

  @override
  String get teacherMaterialLinkUrlOptional => 'رابط / URL (اختياري)';

  @override
  String get teacherSearchStudentsOrGrade => 'ابحث عن الطلاب أو الصف…';

  @override
  String get teacherSearchParentsOrChildren => 'ابحث عن الأهالي أو الأبناء…';

  @override
  String get studentAssignmentAddNoteOptional => 'أضف ملاحظة (اختياري)…';

  @override
  String get adminEditUserUsernameRequired => 'اسم المستخدم *';

  @override
  String get reportReasonOptional => 'السبب (اختياري)';

  @override
  String get forwardSearchChatsAndClassrooms => 'ابحث في المحادثات والصفوف…';

  @override
  String get profileNewPhone => 'رقم هاتف جديد';

  @override
  String get profileNewEmail => 'بريد إلكتروني جديد';

  @override
  String adminExportPasswordsWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'يعيد هذا تعيين كلمات مرور $count طالب إلى كلمات جديدة ويضعها في الملف، لتتمكن من طباعة بطاقات الدخول وتوزيعها. تتوقف كلمات المرور القديمة عن العمل. أي شخص لديه الملف يمكنه تسجيل الدخول بصفة أولئك الطلاب — شارك بحذر واحذف عند الانتهاء.',
      many:
          'يعيد هذا تعيين كلمات مرور $count طالبًا إلى كلمات جديدة ويضعها في الملف، لتتمكن من طباعة بطاقات الدخول وتوزيعها. تتوقف كلمات المرور القديمة عن العمل. أي شخص لديه الملف يمكنه تسجيل الدخول بصفة أولئك الطلاب — شارك بحذر واحذف عند الانتهاء.',
      few:
          'يعيد هذا تعيين كلمات مرور $count طلاب إلى كلمات جديدة ويضعها في الملف، لتتمكن من طباعة بطاقات الدخول وتوزيعها. تتوقف كلمات المرور القديمة عن العمل. أي شخص لديه الملف يمكنه تسجيل الدخول بصفة أولئك الطلاب — شارك بحذر واحذف عند الانتهاء.',
      two:
          'يعيد هذا تعيين كلمتي مرور $count طالبين إلى كلمتين جديدتين ويضعهما في الملف، لتتمكن من طباعة بطاقات الدخول وتوزيعها. تتوقف كلمات المرور القديمة عن العمل. أي شخص لديه الملف يمكنه تسجيل الدخول بصفة أولئك الطلاب — شارك بحذر واحذف عند الانتهاء.',
      one:
          'يعيد هذا تعيين كلمة مرور الطالب إلى كلمة جديدة ويضعها في الملف، لتتمكن من طباعة بطاقة الدخول وتوزيعها. تتوقف كلمة المرور القديمة عن العمل. أي شخص لديه الملف يمكنه تسجيل الدخول بصفة ذلك الطالب — شارك بحذر واحذف عند الانتهاء.',
      zero: 'لا يوجد طلاب',
    );
    return '$_temp0';
  }

  @override
  String get pickerSelectStudents => 'اختر الطلاب';

  @override
  String get pickerSelectCohorts => 'اختر المجموعات';

  @override
  String get pickerSelectGrades => 'اختر الصفوف';

  @override
  String get pickerSelectAll => 'تحديد الكل';

  @override
  String get pickerUnselectAll => 'إلغاء تحديد الكل';

  @override
  String get pickerSelectClassroom => 'اختر الصف';

  @override
  String get pickerSelectClasses => 'اختر الصفوف';

  @override
  String get drawerLoadingChildren => 'جاري تحميل الأبناء…';

  @override
  String get drawerCouldNotLoadChildren => 'تعذر تحميل الأبناء';

  @override
  String get drawerNoChildrenLinked => 'لا يوجد أبناء مرتبطون';

  @override
  String get drawerSwitchChild => 'تبديل الابن';

  @override
  String get shellAssessmentCreated => 'تم إنشاء التقييم';

  @override
  String commonCouldNotOpenLink(String scheme) {
    return 'تعذر فتح رابط $scheme';
  }

  @override
  String commonCouldntSend(String error) {
    return 'تعذر الإرسال: $error';
  }

  @override
  String get teacherExamDetailsSection => 'تفاصيل الامتحان';

  @override
  String teacherExamStudyMaterialsWithCount(int count) {
    return 'مواد الدراسة ($count)';
  }

  @override
  String get teacherMeetingDetailsSection => 'تفاصيل الاجتماع';

  @override
  String get teacherClassroomNameSection => 'اسم الصف';

  @override
  String get teacherAddByCohortSection => 'إضافة بحسب المجموعة';

  @override
  String get teacherAddIndividualStudentsSection => 'إضافة طلاب فرديين';

  @override
  String get teacherGradeTypeSection => 'نوع الدرجة';

  @override
  String get teacherOtherGradeSection => 'درجة أخرى';

  @override
  String get teacherEnterGradesSection => 'أدخل الدرجات';

  @override
  String teacherAttachmentsWithCount(int count) {
    return 'المرفقات ($count)';
  }

  @override
  String get studentFilesSharedByTeacher => 'ملفات شاركها معلمك';

  @override
  String get studentYourSubmission => 'تسليمك';

  @override
  String get studentFilesSharedWithAnnouncement =>
      'ملفات مشاركة مع هذا الإعلان.';

  @override
  String get announcementGradeRiskTitle => 'تم رصد خطر في الدرجات';

  @override
  String get announcementWeakSubjectTitle => 'تم رصد مادة ضعيفة';

  @override
  String get announcementLowAttendanceTitle => 'حضور منخفض';

  @override
  String get announcementRepeatedLatenessTitle => 'تأخر متكرر';

  @override
  String get announcementPracticeWeaknessTitle => 'تم اكتشاف ضعف في التدريب';

  @override
  String get announcementPracticeTrendDroppedTitle => 'انخفض اتجاه التدريب';

  @override
  String get announcementSolutionsActivityTitle => 'نشاط الحلول مباشر';

  @override
  String get announcementAllGoodTitle => 'كل شيء بخير';

  @override
  String get supportSectionGettingStarted => 'البدء';

  @override
  String get supportSectionAccountPassword => 'الحساب وكلمة المرور';

  @override
  String get supportSectionForStudents => 'للطلاب';

  @override
  String get supportSectionForTeachers => 'للمعلمين';

  @override
  String get supportSectionForAdministrators => 'للإداريين';

  @override
  String get supportSectionForParents => 'للأهالي';

  @override
  String get supportSectionPrivacyData => 'الخصوصية والبيانات';

  @override
  String get novaDisclaimerCanMakeMistakes => 'قد يخطئ';

  @override
  String get novaDisclaimerEducationalUseOnly => 'للاستخدام التعليمي فقط';

  @override
  String get novaDisclaimerYourPrivacy => 'خصوصيتك';

  @override
  String profileNameInLanguage(String language) {
    return 'الاسم بـ$language';
  }

  @override
  String get adminSettingsScheduleSubtitle =>
      'تعيين المعلمين والمجموعات في فترات أسبوعية';

  @override
  String get practiceModeBalancedSubtitle => 'تدريب يومي متوازن';

  @override
  String get practiceModeRevealSubtitle => 'كشف واسترجاع ذاتي';

  @override
  String get practiceModeFastSubtitle => 'تدريب سريع بضغط';

  @override
  String get practiceModeExamSubtitle => 'تدفق هادئ بنمط الامتحان';

  @override
  String get practiceModeConceptSubtitle => 'المفهوم أولاً، الحل لاحقًا';

  @override
  String get practiceModeAdaptiveSubtitle => 'تتغير الصعوبة مباشرة';

  @override
  String get practiceModeStrictSubtitle => 'نمط رسمي صارم';

  @override
  String get commonCall => 'اتصال';

  @override
  String get tooltipClearEndTime => 'مسح وقت الانتهاء';

  @override
  String get tooltipDeletePeriod => 'حذف الحصة';

  @override
  String get tooltipLeaveClassroom => 'مغادرة الصف';

  @override
  String get announcementGradeRiskBody =>
      'انخفض معدلك إلى ما دون 70. ننصح باتخاذ إجراء فوري.';

  @override
  String announcementWeakSubjectBody(String subject) {
    return '$subject يحتاج إلى اهتمام.';
  }

  @override
  String get announcementLowAttendanceBody =>
      'حضورك في انخفاض. سيؤثر هذا على درجاتك.';

  @override
  String get announcementLatenessBody => 'لديك حالات تأخر متعددة.';

  @override
  String announcementPracticeWeakTopicBody(String topic, String subject) {
    return '$topic في $subject يبطئ تقدمك.';
  }

  @override
  String get announcementPracticeDropBody =>
      'تدريبك الأخير دون مستواك الأساسي. أبطئ وأعد البناء.';

  @override
  String announcementSolutionsActivityBody(int page, int question) {
    return 'مساحة الحلول الخاصة بك نشطة على الصفحة $page والسؤال $question. تحقق من عمل زملائك أو ارفع عملك.';
  }

  @override
  String get announcementAllGoodBody => 'لا توجد مخاطر أكاديمية كبيرة الآن.';

  @override
  String get faqStartedQ1 => 'كيف أسجل الدخول؟';

  @override
  String get faqStartedA1 =>
      'اضغط على \"تسجيل الدخول\" في شاشة الترحيب وأدخل البريد الإلكتروني أو اسم المستخدم الذي زودك به مدير المدرسة، بالإضافة إلى كلمة المرور المؤقتة. سيُطلب منك تعيين كلمة مرور جديدة في المرة الأولى.';

  @override
  String get faqStartedQ2 => 'ليس لدي حساب بعد.';

  @override
  String get faqStartedA2 =>
      'مدير المدرسة هو من ينشئ الحسابات. اطلب منه إضافتك في تطبيق الإدارة، أو مشاركة رمز انضمام إذا كانت مدرستك تستخدم التسجيل الذاتي.';

  @override
  String get faqStartedQ3 => 'هل يمكنني استخدام التطبيق بلغتي؟';

  @override
  String get faqStartedA3 =>
      'نعم — يدعم ClassMate الإنجليزية والعربية والعبرية والفرنسية والروسية. افتح الإعدادات لتغيير اللغة. يمكنك أيضًا تعيين لغة الاسم المفضل في الملف الشخصي.';

  @override
  String get faqStartedQ4 => 'كيف أبدل بين الوضع الليلي والنهاري؟';

  @override
  String get faqStartedA4 =>
      'افتح الإعدادات من القائمة الجانبية وبدل مفتاح المظهر. يحترم التطبيق تفضيل النظام لديك افتراضيًا.';

  @override
  String get faqAccountQ1 => 'نسيت كلمة المرور.';

  @override
  String get faqAccountA1 =>
      'اضغط على \"نسيت كلمة المرور؟\" في شاشة تسجيل الدخول. ستحصل على رابط إعادة تعيين عبر البريد الإلكتروني أو رمز عبر الرسائل النصية. إذا لم يكن أي من القناتين موثقًا بعد، اطلب من مدير المدرسة إصدار كلمة مرور مؤقتة جديدة.';

  @override
  String get faqAccountQ2 => 'كيف أغير كلمة المرور؟';

  @override
  String get faqAccountA2 =>
      'افتح الملف الشخصي من القائمة الجانبية، انتقل إلى الأمان، واضغط على صف كلمة المرور. ستحتاج إلى كلمة المرور الحالية لتعيين واحدة جديدة.';

  @override
  String get faqAccountQ3 => 'كيف أغير بريدي الإلكتروني أو رقم هاتفي؟';

  @override
  String get faqAccountA3 =>
      'افتح الملف الشخصي، اضغط على الحقل الذي تريد تغييره، واتبع تعليمات التحقق. سيُرسل رمز إلى بريدك/هاتفك الحالي أولاً للتأكد من هويتك، ثم يمكنك تعيين القيمة الجديدة.';

  @override
  String get faqAccountQ4 =>
      'يمكن لمدير المدرسة تغيير كلمة المرور — كيف يعمل ذلك؟';

  @override
  String get faqAccountA4 =>
      'عندما يعيد المدير تعيين كلمة المرور، ستحصل على بريد إلكتروني ورسالة نصية مع رابط بضغطة واحدة لتعيين كلمة مرورك الخاصة. لا يرى المدير أبدًا ما تختاره.';

  @override
  String get faqStudentsQ1 => 'أين أرى جدولي؟';

  @override
  String get faqStudentsA1 =>
      'الجدول هو العنصر الأول في القائمة الجانبية. سترى حصص هذا الأسبوع، من يدرس كل واحدة، وأي تغييرات نشرها المدير.';

  @override
  String get faqStudentsQ2 => 'كيف أنضم إلى صف؟';

  @override
  String get faqStudentsA2 =>
      'سيضيفك المعلم مباشرة، أو يشارك رمز انضمام. لاستخدام رمز انضمام، افتح الصفوف من القائمة الجانبية واضغط على \"الانضمام برمز\".';

  @override
  String get faqStudentsQ3 => 'كيف يعمل الحضور والدرجات؟';

  @override
  String get faqStudentsA3 =>
      'يسجل المعلمون الحضور خلال الدرس. افتح الحضور أو الدرجات من القائمة الجانبية لرؤية سجلاتك. يرى الأهالي المرتبطون بحسابك البيانات نفسها.';

  @override
  String get faqStudentsQ4 => 'ما هو Nova؟';

  @override
  String get faqStudentsA4 =>
      'Nova هو رفيق الدراسة بالذكاء الاصطناعي — اطلب منه شرح مفهوم، أو إنشاء اختبار، أو السير عبر مسألة خطوة بخطوة. افتح Nova من القائمة الجانبية لبدء جلسة.';

  @override
  String get faqTeachersQ1 => 'كيف أنشئ صفًا؟';

  @override
  String get faqTeachersA1 =>
      'افتح الصفوف من القائمة الجانبية واضغط على زر +. أعطه اسمًا ومادة؛ يمكن إضافة الطلاب يدويًا أو عبر رمز انضمام.';

  @override
  String get faqTeachersQ2 => 'كيف أسجل الحضور؟';

  @override
  String get faqTeachersA2 =>
      'افتح الحضور من القائمة الجانبية، اختر التاريخ والحصة، ثم اضغط على كل طالب لتعيين حالته. تُحفظ التغييرات تلقائيًا.';

  @override
  String get faqTeachersQ3 => 'كيف أُعين واجبات منزلية؟';

  @override
  String get faqTeachersA3 =>
      'افتح الواجبات، اضغط +، املأ العنوان/تاريخ الاستحقاق/المرفقات، واختر جمهورًا (المدرسة بأكملها، مجموعات محددة، أو طلاب بأسمائهم). يراها الطلاب فورًا في قائمتهم الجانبية.';

  @override
  String get faqTeachersQ4 => 'هل يمكنني إصدار شهادة أو دبلوم؟';

  @override
  String get faqTeachersA4 =>
      'نعم — افتح الشهادات من القائمة الجانبية، اضغط +، اختر الطالب، املأ العنوان والتفاصيل، واحفظ. يرى الطالب الشهادة في قسم الشهادات الخاص به.';

  @override
  String get faqAdminsQ1 => 'من أين أبدأ إعداد المدرسة؟';

  @override
  String get faqAdminsA1 =>
      'افتح لوحة الإدارة. تعرض أداة إعداد المدرسة في الأعلى قائمة من 7 خطوات (الشعار، الاسم، المواد، جدول الأجراس، المجموعات، الطلاب، المعلمون). كل خطوة ترتبط مباشرة بمكان إكمالها.';

  @override
  String get faqAdminsQ2 => 'كيف تعمل المجموعات؟';

  @override
  String get faqAdminsA2 =>
      'المجموعة هي مجموعة من الطلاب يشتركون في جدول. افتح المجموعات من القائمة الجانبية لإنشائها، تعيين الطلاب، وإنشاء رموز انضمام. يمكن لمجموعة واحدة أن تشمل عدة صفوف.';

  @override
  String get faqAdminsQ3 => 'هل يمكن لمجموعة أن تغطي أكثر من صف؟';

  @override
  String get faqAdminsA3 =>
      'نعم — عند إنشاء مجموعة، اختر صفوفًا متعددة. ستظهر المجموعة في مرشحات وعروض أي من تلك الصفوف، وستصل إليها الإعلانات/القوالب الموجهة لأي من تلك الصفوف.';

  @override
  String get faqAdminsQ4 => 'كيف أبني الجدول الأسبوعي؟';

  @override
  String get faqAdminsA4 =>
      'افتح الجدول من القائمة الجانبية. اضغط على أي خلية لإضافة فترة — اختر اليوم/الحصة، المعلم، المادة، والجمهور (مجموعة/طالب/صف). تأتي أوقات جدول الأجراس من إعدادات المدرسة.';

  @override
  String get faqAdminsQ5 => 'كيف أصدّر الطلاب بالجملة؟';

  @override
  String get faqAdminsA5 =>
      'افتح تصدير البيانات من القائمة الجانبية. اختر سواء التحديد حسب الطالب أو حسب المجموعة، اختر الصفوف، واضغط على تصدير. اختياريًا قم بتضمين كلمات المرور الحالية أثناء التصدير.';

  @override
  String get faqAdminsQ6 => 'طلب مستخدم إعادة تعيين كلمة المرور. ماذا أفعل؟';

  @override
  String get faqAdminsA6 =>
      'يمكنك إما تعيين كلمة المرور مباشرة (ملف المستخدم الشخصي → الأمان) أو الانتظار حتى يرسل طلبًا عبر \"نسيت كلمة المرور\" والموافقة عليه من طلبات كلمات المرور في القائمة الجانبية.';

  @override
  String get faqParentsQ1 => 'كيف أربط حسابي بطفلي؟';

  @override
  String get faqParentsA1 =>
      'اطلب من مدير مدرسة طفلك إضافة الرابط من تطبيق الإدارة، أو مشاركة رمز ربط الوالد لمرة واحدة. افتح الملف الشخصي وأدخل الرمز تحت العائلة.';

  @override
  String get faqParentsQ2 => 'ماذا أرى عن طفلي؟';

  @override
  String get faqParentsA2 =>
      'الحضور، الدرجات، الإعلانات، والواجبات المنزلية — تمامًا ما يراه طفلك بالإضافة إلى الاتجاهات عبر الوقت. لن ترى المحادثات الخاصة أو جلسات Nova.';

  @override
  String get faqPrivacyQ1 => 'من يمكنه رؤية بياناتي؟';

  @override
  String get faqPrivacyA1 =>
      'فقط الأشخاص في مدرستك. يرى المعلمون بيانات صفوفهم، يرى المديرون بيانات المدرسة بأكملها، يرى الأهالي أطفالهم المرتبطين. لا نبيع البيانات للمعلنين أبدًا.';

  @override
  String get faqPrivacyQ2 => 'كيف أحذف حسابي؟';

  @override
  String get faqPrivacyA2 =>
      'اطلب من مدير المدرسة حذفه. يمكنه إزالة الحساب من تطبيق الإدارة، مما يمسح ملفك الشخصي وجدولك ومحادثاتك.';

  @override
  String solutionsPagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صفحات',
      one: 'صفحة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get teacherMeetingEditTitle => 'تعديل الاجتماع';

  @override
  String get teacherMeetingNewTitle => 'جدولة اجتماع';

  @override
  String get teacherExamEditTitle => 'تعديل الامتحان';

  @override
  String get teacherExamNewTitle => 'إنشاء امتحان';

  @override
  String get teacherAssignmentEditTitle => 'تعديل الواجب';

  @override
  String get teacherAssignmentNewTitle => 'واجب جديد';

  @override
  String get tooltipShowTabs => 'إظهار التبويبات';

  @override
  String get tooltipHideTabs => 'إخفاء التبويبات';

  @override
  String get examsCouldNotLoadForms => 'تعذر تحميل النماذج';

  @override
  String get examsCouldNotLoadExams => 'تعذر تحميل الامتحانات';

  @override
  String get messagesNoPeopleToAdd => 'لا يوجد أشخاص للإضافة';

  @override
  String commonNoResultsForQuery(String query) {
    return 'لا توجد نتائج لـ \"$query\"';
  }

  @override
  String chatForwardedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم التحويل إلى $count محادثات',
      one: 'تم التحويل إلى محادثة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get commonReadMore => 'اقرأ المزيد';

  @override
  String get commonReadLess => 'اقرأ أقل';

  @override
  String get chatComposerSlideToCancel => 'اسحب للإلغاء';

  @override
  String adminNoRoleYet(String role) {
    return 'لا يوجد $role بعد';
  }

  @override
  String get profileVerified => 'تم التحقق.';

  @override
  String get profileUpdatedPendingVerification =>
      'تم التحديث وفي انتظار إعادة التحقق.';

  @override
  String get adminSearchCohorts => 'ابحث عن المجموعات…';

  @override
  String get commonAdding => 'جاري الإضافة…';

  @override
  String get teacherDiplomaIssuing => 'جاري الإصدار…';

  @override
  String get teacherDiplomaIssue => 'إصدار';

  @override
  String get formAccepting => 'قبول';

  @override
  String get profileVerifiedShort => 'موثق';

  @override
  String get profileUnverified => 'غير موثق';

  @override
  String get notificationNewGradePosted => '📊 تم نشر درجة جديدة';

  @override
  String notificationNewGradePostedIn(String subject) {
    return '📊 تم نشر درجة جديدة في $subject';
  }

  @override
  String messagesAddParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'إضافة $count مشاركين',
      one: 'إضافة مشارك واحد',
    );
    return '$_temp0';
  }

  @override
  String get notificationFallbackTitle => 'إشعار';

  @override
  String adminCohortGradeRange(int from, int to) {
    return 'الصف $from-$to';
  }

  @override
  String adminCohortGradesList(String list) {
    return 'الصفوف $list';
  }

  @override
  String get adminExportHeaderTitle => 'تصدير المستخدمين';

  @override
  String get adminExportHeaderSubtitle =>
      'أضف الفلاتر كشارات — كل شارة تضيف مستخدمين إلى التصدير. اضغط على شارة لإزالتها.';

  @override
  String get adminExportAddFilter => 'إضافة فلتر';

  @override
  String get adminExportEmptyState =>
      'أضف فلترًا للبدء: اختر دورًا أو مجموعة أو صفًا أو مستخدمين محددين.';

  @override
  String get adminExportFilterRolesTab => 'الأدوار';

  @override
  String get adminExportFilterCohortsTab => 'المجموعات';

  @override
  String get adminExportFilterGradesTab => 'الصفوف';

  @override
  String get adminExportFilterUsersTab => 'المستخدمون';

  @override
  String get adminExportSelectAll => 'تحديد الكل';

  @override
  String adminExportSelectedCount(int selected, int total) {
    return '$selected من $total محدد';
  }

  @override
  String adminExportRolePickedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count محدد',
      one: 'محدد واحد',
    );
    return '$_temp0';
  }

  @override
  String get adminExportPillRolePrefix => 'دور:';

  @override
  String get adminExportPillCohortPrefix => 'مجموعة:';

  @override
  String adminExportActiveFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count فلاتر نشطة',
      one: 'فلتر نشط واحد',
    );
    return '$_temp0';
  }

  @override
  String get adminExportClearAll => 'مسح الكل';

  @override
  String get adminExportCounting => 'جاري العد…';

  @override
  String adminExportMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سيتم تصدير $count مستخدمين',
      one: 'سيتم تصدير مستخدم واحد',
    );
    return '$_temp0';
  }

  @override
  String get adminExportNoGradesConfigured => 'لا توجد صفوف مكونة لهذه المدرسة';

  @override
  String get adminExportColumnRole => 'الدور';

  @override
  String get adminExportRoleStudent => 'طالب';

  @override
  String get adminExportRoleTeacher => 'معلم';

  @override
  String get adminExportRoleParent => 'ولي أمر';

  @override
  String get adminExportRoleSecretary => 'سكرتير';

  @override
  String get adminExportRoleAdmin => 'مدير';

  @override
  String adminExportUsersSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم اختيار $count مستخدمين',
      one: 'تم اختيار مستخدم واحد',
    );
    return '$_temp0';
  }

  @override
  String get adminExportPasswordsOn =>
      'ستتم إعادة تعيين كلمات المرور وعرضها في التصدير — تتوقف كلمات المرور القديمة عن العمل. تعامل مع الملف بأمان.';

  @override
  String get adminExportPasswordsOff => 'لن يحتوي التصدير على أي كلمات مرور.';

  @override
  String get adminExportPdfUserDirectory => 'دليل المستخدمين';

  @override
  String adminExportPdfUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مستخدمين',
      one: 'مستخدم واحد',
    );
    return '$_temp0';
  }

  @override
  String get teacherAttachFromMaterials => 'من المواد';

  @override
  String get teacherUploadFiles => 'رفع ملفات';

  @override
  String get solSubjectMathematics => 'الرياضيات';

  @override
  String get solSubjectComputerScience => 'علوم الحاسوب';

  @override
  String get solSubjectPhysics => 'الفيزياء';

  @override
  String get solSubjectChemistry => 'الكيمياء';

  @override
  String get solSubjectHebrew => 'العبرية';

  @override
  String get solSubjectBiology => 'الأحياء';

  @override
  String get solSubjectHistory => 'التاريخ';

  @override
  String get solSubjectArabic => 'العربية';

  @override
  String get solSubjectElectronics => 'الإلكترونيات';

  @override
  String get solSubjectMechanics => 'الميكانيكا';

  @override
  String get solSubjectFrench => 'الفرنسية';

  @override
  String get solSubjectEnvironmentalScience => 'علوم البيئة';

  @override
  String get solSubjectCommunicationCinema => 'الاتصال والسينما';

  @override
  String get solSubjectCitizenship => 'مدنيات';

  @override
  String get solSubjectSociology => 'علم الاجتماع';

  @override
  String get solSubjectReligion => 'الدين';

  @override
  String get solSubjectGeography => 'الجغرافيا';

  @override
  String get solSubjectPsychology => 'علم النفس';

  @override
  String get insightsSemesterTitle => 'هذا الفصل';

  @override
  String get insightsOnTimeSubmissions => 'تسليم في الوقت';

  @override
  String get insightsSubmissionsTitle => 'التسليمات';

  @override
  String get insightsOnTime => 'في الوقت';

  @override
  String get insightsLate => 'متأخر';

  @override
  String get insightsMissing => 'ناقص';

  @override
  String get insightsPending => 'قيد الانتظار';

  @override
  String get insightsHandedInLabel => 'تم تسليمها';

  @override
  String get insightsLatestGrades => 'أحدث العلامات';

  @override
  String get insightsReviewWithNova => 'مراجعة مع Nova';

  @override
  String get insightsReviewWithNovaPrompt =>
      'أعطني مراجعة قصيرة وصادقة عن أدائي هذا الفصل — العلامات والحضور والتسليمات — والشيء الوحيد الذي ينبغي أن أركّز عليه.';

  @override
  String get insightsPracticeTitle => 'دقة التمارين';

  @override
  String get commonUnknown => 'غير معروف';

  @override
  String get solutionsReportTitle => 'الإبلاغ عن هذا الحل';

  @override
  String get solutionsReportBody =>
      'أخبر المشرفين بالمشكلة. سيراجعها مشرفو المدرستين.';

  @override
  String get solutionsReportReasonHint => 'السبب (اختياري)';

  @override
  String get solutionsReportAction => 'إبلاغ';

  @override
  String get solutionsReportSubmitted => 'شكرًا — تم الإبلاغ للمشرفين.';

  @override
  String get solutionsReportAlready => 'لقد أبلغت عن هذا بالفعل.';

  @override
  String solutionsBookPagesCount(int count) {
    return '$count صفحة';
  }

  @override
  String get solutionsNoBooksYetForStudents =>
      'لا توجد كتب هنا بعد. سيضيفها معلمك.';

  @override
  String get solutionsManageBooksTitle => 'إدارة الكتب';

  @override
  String get solutionsNoBooksManageHint =>
      'لا توجد كتب لهذه المادة بعد. اضغط + للإضافة.';

  @override
  String get solutionsDeleteBookTitle => 'حذف الكتاب؟';

  @override
  String solutionsDeleteBookBody(String title) {
    return 'حذف \"$title\"؟ لا يمكن التراجع.';
  }

  @override
  String solutionsBookSaveFailed(String error) {
    return 'تعذّر الحفظ: $error';
  }

  @override
  String get solutionsBookDuplicateHint =>
      'قبل الإضافة، تأكد من أن هذا الكتاب غير موجود بالفعل في قاعدة البيانات.';

  @override
  String get solutionsBookDuplicateTitle => 'ربما يكون كتابًا مكررًا';

  @override
  String solutionsBookDuplicateBody(String title) {
    return 'يوجد بالفعل كتاب باسم \"$title\". تأكد من أنه ليس نفس الكتاب قبل إضافته.';
  }

  @override
  String get solutionsBookAddAnyway => 'أضف على أي حال';

  @override
  String get solutionsBookNeedTitlePages => 'أدخل عنوانًا وعدد الصفحات.';

  @override
  String get solutionsEditBookTitle => 'تعديل الكتاب';

  @override
  String get solutionsBookCoverLabel => 'غلاف';

  @override
  String solutionsGradeLabel(int grade) {
    return 'الصف $grade';
  }

  @override
  String get solutionsReportsTitle => 'الحلول المُبلّغ عنها';

  @override
  String get solutionsReportsEmpty => 'لا توجد بلاغات للمراجعة.';

  @override
  String get solutionsReportPostedBy => 'نشر بواسطة';

  @override
  String get solutionsReportReportedBy => 'أبلغ عنه';

  @override
  String get solutionsReportReasonLabel => 'السبب';

  @override
  String get solutionsReportKeepAction => 'إبقاء';

  @override
  String get solutionsReportRemoveAction => 'إزالة';

  @override
  String get solutionsReportStatusPending => 'قيد المراجعة';

  @override
  String get solutionsReportStatusApproved => 'تم الإبقاء';

  @override
  String get solutionsReportStatusRemoved => 'تمت الإزالة';

  @override
  String get solutionsReportRemoved => 'تمت إزالة الحل.';

  @override
  String get solutionsReportApproved => 'تم تجاهل البلاغ — تم إبقاء الحل.';

  @override
  String solutionsReportFailed(String error) {
    return 'تعذّر الإبلاغ: $error';
  }

  @override
  String get teacherAddGradeTitle => 'إضافة علامة';

  @override
  String get commonCohort => 'الفوج';

  @override
  String get teacherCreateNewExam => 'إنشاء امتحان جديد';

  @override
  String get teacherCreateNewAssignment => 'إنشاء واجب جديد';

  @override
  String get commonReturn => 'إرجاع';

  @override
  String get reorderToolsTitle => 'إعادة ترتيب القائمة';

  @override
  String get reorderToolsSubtitle =>
      'اسحب لإعادة ترتيب أدوات المدرسة. يبقى القسم الأساسي والحساب في مكانهما.';

  @override
  String get reorderToolsReset => 'إعادة تعيين';

  @override
  String get reorderToolsSettingsSection => 'القائمة';

  @override
  String get reorderToolsSettingsSubtitle =>
      'إعادة ترتيب الأدوات في القائمة الجانبية';

  @override
  String get drawerHoldToReorder => 'اضغط مطولاً على عنصر لسحبه وإعادة الترتيب';

  @override
  String get adminSchoolGradeRangesDescription =>
      'حدّد الصفوف التي تغطيها مدرستك. أضف أكثر من نطاق إذا كانت بعض الصفوف غير موجودة (مثل 4-6 و9-12).';

  @override
  String get adminSchoolAddGradeRange => 'إضافة نطاق';

  @override
  String get teacherListStudents => 'قائمة الطلاب';

  @override
  String get teacherNoStudentsInvolved => 'لا يوجد طلاب في هذه الحصة بعد.';

  @override
  String get messagesFilterAdmins => 'المشرفون';

  @override
  String get teacherAssignmentGradedStatus => 'تم التقييم';

  @override
  String get teacherAssignmentReturnedStatus => 'أُعيد لإعادة الحل';

  @override
  String get teacherAssignmentReturnAction => 'إعادة لإعادة الحل';

  @override
  String teacherAssignmentReturnDialogBody(String name) {
    return 'إعادة هذا التسليم إلى $name لمراجعته وتسليمه مجددًا؟ ستُرفق أي ملاحظات كتبتها.';
  }

  @override
  String teacherGradesSavedOf(int saved, int total) {
    return 'تم حفظ $saved من $total.';
  }

  @override
  String teacherGradesSkippedSuffix(int dropped) {
    return 'تم تخطّي $dropped طالب — غير مسجّلين في فوج.';
  }

  @override
  String get adminPeopleGradeLevelRequired => 'اختر صفًا لهذا الطالب.';

  @override
  String teacherAddGradeLabel(int grade) {
    return 'الصف $grade';
  }

  @override
  String get teacherGradeOutOfHint => 'مثال: 20';

  @override
  String get plansDowngrade => 'تخفيض الخطة';

  @override
  String get plansDowngradeNote =>
      'يبدأ عند انتهاء خطتك الحالية — تبقى لديك حتى ذلك الحين، دون استرداد.';

  @override
  String get semesterThis => 'هذا الفصل';

  @override
  String get semesterPrevious => 'السابقة';

  @override
  String get showMore => 'عرض المزيد';

  @override
  String get adminSchoolSemestersLabel => 'الفصول الدراسية';

  @override
  String get adminSchoolSemestersDescription =>
      'قسّم السنة الدراسية إلى فصول حسب الأشهر. تُجمَّع العلامات والامتحانات واللقاءات وغيرها حسب الفصل تلقائيًا.';

  @override
  String adminSchoolSemesterN(String n) {
    return 'الفصل $n';
  }

  @override
  String get adminSchoolAddSemester => 'إضافة فصل';

  @override
  String get semesterStarts => 'يبدأ';

  @override
  String get semesterEnds => 'ينتهي';

  @override
  String get commonWhen => 'الوقت';

  @override
  String get commonFiles => 'ملفات';

  @override
  String get commonOnce => 'مرة واحدة';

  @override
  String get commonNoneDash => '— لا شيء —';

  @override
  String get commonNotesOptional => 'ملاحظات (اختياري)';

  @override
  String get commonSubjectOptional => 'المادة (اختياري)';

  @override
  String get colorBlue => 'أزرق';

  @override
  String get colorIndigo => 'نيلي';

  @override
  String get colorViolet => 'بنفسجي';

  @override
  String get colorTeal => 'أزرق مخضر';

  @override
  String get colorGreen => 'أخضر';

  @override
  String get colorOrange => 'برتقالي';

  @override
  String get colorRose => 'وردي';

  @override
  String get teacherAddClassNotes => 'إضافة ملاحظات الحصة';

  @override
  String get teacherStudentsWithGrades => 'الطلاب الحاصلون على علامات';

  @override
  String get teacherOtherStudentsSameGrade => 'طلاب آخرون في نفس الصف/المجموعة';

  @override
  String get teacherChooseExam => 'اختر امتحاناً';

  @override
  String get teacherChooseAssignment => 'اختر واجباً';

  @override
  String get teacherSearchExams => 'ابحث عن امتحانات…';

  @override
  String get teacherSearchAssignments => 'ابحث عن واجبات…';

  @override
  String get teacherSearchQuestionTypes => 'ابحث عن أنواع الأسئلة…';

  @override
  String get teacherOtherCustomSubject => 'أخرى (إدخال مخصص)';

  @override
  String get adminLinkChild => 'ربط طفل';

  @override
  String get adminChooseStudentDash => '— اختر طالباً —';

  @override
  String get adminSelectStudentToLink => 'اختر طالباً للربط';

  @override
  String get adminEditPeriod => 'تعديل الحصة';

  @override
  String get adminNotInAnyCohort =>
      'ليس ضمن أي مجموعة بعد — يمكن التعيين من شاشة المجموعات.';

  @override
  String get adminPasswordChangeWarning =>
      'سيسجّل المستخدم الدخول بكلمة المرور هذه في المرة القادمة. وستُلغى أي روابط إعادة تعيين معلّقة.';

  @override
  String get nameInEnglish => 'الاسم بالإنجليزية';

  @override
  String get nameInArabic => 'الاسم بالعربية';

  @override
  String get nameInHebrew => 'الاسم بالعبرية';

  @override
  String get nameInFrench => 'الاسم بالفرنسية';

  @override
  String get nameInRussian => 'الاسم بالروسية';

  @override
  String get passwordMinChars => '8 أحرف على الأقل.';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get adminWelcomeHeading => 'مرحباً بك في ClassMate';

  @override
  String get diplomasNoFilesAttached => 'لا توجد ملفات مرفقة بهذه الشهادة.';

  @override
  String get diplomasFilesProcessing =>
      'تعذّر فتح الملفات — قد تكون لا تزال قيد المعالجة.';

  @override
  String get novaOutOfTokens =>
      'لقد استهلكت كل رصيدك لهذه الفترة. قم بالترقية أو الشحن لمواصلة الدردشة مع NOVA.';

  @override
  String get tutorDeleteConversationWarning =>
      'سيؤدي هذا إلى حذف المحادثة وجميع رسائلها نهائياً من الخادم. لا يمكن التراجع عن ذلك.';

  @override
  String get chatReportFlagWarning =>
      'سيتم الإبلاغ عن هذه الرسالة لمراجعتها من قبل مسؤول.';

  @override
  String get solutionPreviewFailFallback =>
      'افتحه من مرفق الدردشة إذا تعذّرت المعاينة';

  @override
  String get practiceNoInternet =>
      'لا يوجد اتصال بالإنترنت. يرجى المحاولة مرة أخرى.';

  @override
  String get practiceGenerationFailed =>
      'تعذّر إنشاء الأسئلة. يرجى المحاولة مرة أخرى.';

  @override
  String get practiceTimingSecPerQuestion => 'ث / سؤال';

  @override
  String get practiceTimingMinPerQuiz => 'د / اختبار';

  @override
  String adminScheduleFrequencyWeeks(Object freq) {
    return '×$freq أسبوع';
  }

  @override
  String gradeLevelLabel(Object grade) {
    return 'الصف $grade';
  }

  @override
  String adminPeriodOption(Object period) {
    return 'الحصة $period';
  }

  @override
  String cohortStudentsCount(int count) {
    return '$count طالب';
  }

  @override
  String diplomasIssuedCount(Object count) {
    return '$count شهادة صادرة';
  }

  @override
  String get adminExportImportantHeading => 'هام';

  @override
  String get adminExportWelcomeBodyWithPw =>
      'هذه تفاصيل حسابك في ClassMate. سجّل الدخول إلى تطبيق ClassMate على iOS أو Android باستخدام اسم المستخدم وكلمة المرور أدناه. يمكنك تغيير كلمة المرور داخل التطبيق.';

  @override
  String get adminExportWelcomeBodyNoPw =>
      'هذه تفاصيل حسابك في ClassMate. سجّل الدخول إلى تطبيق ClassMate على iOS أو Android باستخدام اسم المستخدم.';

  @override
  String get adminExportNotePrivate =>
      'احتفظ بهذه البيانات سرية. لا تشارك كلمة المرور.';

  @override
  String get adminExportNoteChangePw =>
      'غيّر كلمة المرور بعد أول تسجيل دخول من الإعدادات → الحساب.';

  @override
  String get adminExportNoteLegal =>
      'باستخدامك ClassMate فإنك توافق على شروط الخدمة وسياسة الخصوصية.';

  @override
  String adminExportNoteHelp(String email) {
    return 'بحاجة إلى مساعدة؟ تواصل مع مسؤول مدرستك أو عبر $email.';
  }

  @override
  String get teacherGradeTitleHint => 'مثال: المشاركة الصفية، اختبار 3';

  @override
  String get teacherClassroomNameHint => 'مثال: رياضيات 10أ';

  @override
  String get novaAbout => 'حول NOVA';

  @override
  String get parentNotifForYou => 'لك';

  @override
  String parentNotifAbout(String name) {
    return 'عن $name';
  }

  @override
  String get navPrivacyPolicy => 'سياسة الخصوصية';

  @override
  String get privacyPolicySubtitle => 'كيف نحمي بياناتك';

  @override
  String get semesterAllPrevious => 'كل السابقة';

  @override
  String get semesterSelectTitle => 'اختر الفصل';

  @override
  String get adminImportUsersScreenTitle => 'استيراد المستخدمين';

  @override
  String get adminImportUsersScreenTabGrid => 'جدول';

  @override
  String get adminImportUsersScreenTabCsv => 'CSV';

  @override
  String adminImportUsersScreenLoadedRows(int count) {
    return 'تم تحميل $count صفوف — راجِع وعدِّل، ثم أنشئ';
  }

  @override
  String get adminImportUsersScreenFillAtLeastOneName =>
      'أدخِل اسماً واحداً على الأقل';

  @override
  String adminImportUsersScreenFailed(String error) {
    return 'فشل: $error';
  }

  @override
  String get adminImportUsersScreenBackToGrid => 'العودة إلى الجدول';

  @override
  String get adminImportUsersScreenGridIntro =>
      'املأ صفاً لكل شخص، أو حمِّل ملف CSV من تبويب CSV وصحِّح أي شيء هنا. اسم المستخدم اختياري — سننشئ واحداً إذا تُرك فارغاً. بالنسبة للطلاب، حدِّد الصف و(اختيارياً) اسم مستخدم ولي الأمر لربطهم.';

  @override
  String get adminImportUsersScreenAddRow => 'إضافة صف';

  @override
  String adminImportUsersScreenCreateCount(int count) {
    return 'إنشاء ($count)';
  }

  @override
  String get adminImportUsersScreenRole => 'الدور';

  @override
  String get adminImportUsersScreenFullName => 'الاسم الكامل *';

  @override
  String get adminImportUsersScreenUsername => 'اسم المستخدم';

  @override
  String get adminImportUsersScreenUsernameHint => '(تلقائي إذا تُرك فارغاً)';

  @override
  String get adminImportUsersScreenGrade => 'الصف';

  @override
  String get adminImportUsersScreenParentUsername => 'اسم مستخدم ولي الأمر';

  @override
  String get adminImportUsersScreenParentUsernameHint => 'ربط (اختياري)';

  @override
  String get adminImportUsersScreenCouldNotReadFile =>
      'تعذّرت قراءة هذا الملف.';

  @override
  String get adminImportUsersScreenCsvIntro =>
      'حمِّل ملف CSV لمستخدميك. يمكن أن تكون عناوين الأعمدة بأي لغة — يكتشف ClassMate معنى كل عمود، ثم يحمِّل الصفوف إلى الجدول حتى تتمكن من المراجعة وتصحيح أي شيء قبل الإنشاء.';

  @override
  String get adminImportUsersScreenChooseCsv => 'اختيار ملف CSV';

  @override
  String get adminImportUsersScreenChooseDifferentFile => 'اختيار ملف آخر';

  @override
  String adminImportUsersScreenSelectedFile(String fileName) {
    return 'المُختار: $fileName';
  }

  @override
  String get adminImportUsersScreenRecognisedColumns =>
      'الأعمدة المُتعرَّف عليها';

  @override
  String get adminImportUsersScreenRecognisedColumnsBody =>
      'الاسم · اسم المستخدم · كلمة المرور · البريد الإلكتروني · الهاتف · الدور · الصف · ولي الأمر (اسم مستخدم) · الأبناء (أسماء مستخدمين)\n\nكلمات الدور مثل \"student / طالب / תלמיד / élève / ученик\" تُربط جميعها بشكل صحيح. يقرأ الصف الرقم من \"Grade 10\" و\"الصف 10\" و\"כיתה 10\". تُنشأ أسماء المستخدمين أو كلمات المرور المفقودة تلقائياً.';

  @override
  String adminImportUsersScreenDetectedRows(int count) {
    return 'تم الكشف — $count صفوف';
  }

  @override
  String get adminImportUsersScreenNoColumnsDetected =>
      'لم يتم الكشف عن أعمدة معروفة — تحقق من صف العناوين.';

  @override
  String get adminImportUsersScreenTruncatedNotice =>
      'عرض أول 2000 صف للمراجعة.';

  @override
  String get adminImportUsersScreenReviewEditInGrid =>
      'المراجعة والتعديل في الجدول';

  @override
  String get adminImportUsersScreenReviewEditHint =>
      'يفتح تبويب الجدول مملوءاً مسبقاً بهذه الصفوف حتى تتمكن من تصحيح أي أخطاء قبل الإنشاء.';

  @override
  String adminImportUsersScreenResultSummary(int count, int links) {
    return '✓ تم إنشاء $count مستخدمين · $links روابط';
  }

  @override
  String adminImportUsersScreenResultFailedSuffix(int failed) {
    return ' · $failed فشل';
  }

  @override
  String get adminImportUsersScreenFailedRows => 'الصفوف الفاشلة';

  @override
  String adminImportUsersScreenFailedRow(String row, String reason) {
    return 'الصف $row: $reason';
  }

  @override
  String get adminImportUsersScreenCredentialsTitle =>
      'بيانات الدخول (سلِّمها لمستخدميك)';

  @override
  String get teacherCohortsScreenTitle => 'المجموعات';

  @override
  String get teacherCohortsScreenNewCohort => 'مجموعة جديدة';

  @override
  String get teacherCohortsScreenLoadError => 'تعذّر تحميل المجموعات.';

  @override
  String get teacherCohortsScreenEmpty =>
      'لا توجد مجموعات بعد.\nانقر \"مجموعة جديدة\" لإنشاء واحدة.';

  @override
  String get teacherCohortsScreenCohortNameLabel => 'اسم المجموعة';

  @override
  String get teacherCohortsScreenCohortNameHint => 'مثال: 10-2';

  @override
  String get teacherCohortsScreenGradesLabel => 'الصف (الصفوف)';

  @override
  String get teacherCohortsScreenGradesHint => 'مثال: 10  أو  7,8';

  @override
  String get teacherCohortsScreenCancel => 'إلغاء';

  @override
  String get teacherCohortsScreenCreate => 'إنشاء';

  @override
  String get teacherCohortsScreenEnterNameAndGrade =>
      'أدخِل اسماً وصفاً واحداً على الأقل';

  @override
  String get teacherCohortsScreenCohortCreated => 'تم إنشاء المجموعة';

  @override
  String get teacherCohortsScreenFailed => 'فشل';

  @override
  String teacherCohortsScreenStudentsCount(int count) {
    return '$count طلاب';
  }

  @override
  String get teacherCohortsScreenRenameGrades => 'إعادة التسمية / الصفوف';

  @override
  String get teacherCohortsScreenDeleteCohort => 'حذف المجموعة';

  @override
  String get teacherCohortsScreenAddStudents => 'إضافة طلاب';

  @override
  String get teacherCohortsScreenEditCohort => 'تعديل المجموعة';

  @override
  String get teacherCohortsScreenSave => 'حفظ';

  @override
  String get teacherCohortsScreenSaved => 'تم الحفظ';

  @override
  String teacherCohortsScreenDeleteConfirmTitle(String name) {
    return 'حذف \"$name\"؟';
  }

  @override
  String get teacherCohortsScreenDeleteConfirmBody =>
      'تتم إزالة المجموعة وفصل الطلاب عنها. لا يتم حذف حسابات الطلاب.';

  @override
  String get teacherCohortsScreenDelete => 'حذف';

  @override
  String get teacherCohortsScreenDeleted => 'تم الحذف';

  @override
  String get teacherCohortsScreenLoadStudentsError => 'تعذّر تحميل الطلاب';

  @override
  String teacherCohortsScreenAddNStudents(int count) {
    return 'إضافة $count طلاب';
  }

  @override
  String teacherCohortsScreenAddedNStudents(int count) {
    return 'تمت إضافة $count طلاب';
  }

  @override
  String get teacherCohortsScreenNoStudentsYet => 'لا يوجد طلاب بعد.';

  @override
  String get adminSettingsScreenBulkTools => 'أدوات الدفعات';

  @override
  String get adminSettingsScreenImportUsers => 'استيراد المستخدمين';

  @override
  String get adminSettingsScreenImportUsersSubtitle =>
      'إضافة الكثير دفعة واحدة — جدول أو CSV';

  @override
  String get adminSettingsScreenUpgradeGrades => 'ترقية الصفوف';

  @override
  String get adminSettingsScreenUpgradeGradesSubtitle =>
      'ترقية كل طالب صفاً واحداً';

  @override
  String get adminSettingsScreenUpgradeGradesTitle => 'ترقية كل الصفوف؟';

  @override
  String get adminSettingsScreenUpgradeGradesBody =>
      'ينتقل كل طالب إلى صف أعلى. يُحتفظ بالطلاب الذين هم بالفعل في الصف الأعلى كمتخرجين (لا يُحذفون أبداً) لتتولى أمرهم. تشغيل هذا آمن مرة واحدة في بداية العام الدراسي.';

  @override
  String get adminSettingsScreenUpgradeConfirm => 'ترقية';

  @override
  String adminSettingsScreenUpgradeSuccess(int promoted, int graduating) {
    return 'تمت ترقية $promoted طالب · $graduating متخرج';
  }

  @override
  String get adminSettingsScreenDangerZone => 'منطقة الخطر';

  @override
  String get adminSettingsScreenResetSchedule => 'إعادة ضبط الجدول';

  @override
  String get adminSettingsScreenResetScheduleSubtitle =>
      'حذف كل الحصص والاستثناءات';

  @override
  String get adminSettingsScreenResetScheduleTitle =>
      'إعادة ضبط الجدول بالكامل؟';

  @override
  String get adminSettingsScreenResetScheduleBody =>
      'يؤدي هذا إلى حذف كل حصة وكل استثناء لمرة واحدة لمدرستك نهائياً. يُحتفظ بأوقات جرس الحصص. لا يمكن التراجع عن هذا.';

  @override
  String adminSettingsScreenResetScheduleSuccess(int slots) {
    return 'تم مسح الجدول — تمت إزالة $slots حصص';
  }

  @override
  String get adminSettingsScreenResetCohorts => 'إعادة ضبط المجموعات';

  @override
  String get adminSettingsScreenResetCohortsSubtitle => 'حذف كل مجموعاتك';

  @override
  String get adminSettingsScreenResetCohortsTitle => 'حذف كل المجموعات؟';

  @override
  String get adminSettingsScreenResetCohortsBody =>
      'يؤدي هذا إلى حذف كل مجموعة في مدرستك نهائياً وإزالة الطلاب منها. لا تُحذف حسابات الطلاب. لا يمكن التراجع عن هذا.';

  @override
  String get adminSettingsScreenDeleteCohortsConfirm => 'حذف المجموعات';

  @override
  String adminSettingsScreenResetCohortsSuccess(int deleted) {
    return 'تم حذف $deleted مجموعات';
  }

  @override
  String get adminSettingsScreenAppearanceSubtitle => 'السمة والألوان واللغة';

  @override
  String get adminSettingsScreenCancel => 'إلغاء';

  @override
  String get adminSettingsScreenWorking => 'جارٍ العمل…';

  @override
  String adminSettingsScreenFailed(String error) {
    return 'فشل: $error';
  }

  @override
  String adminSchedulePickStartDate(int freq) {
    return 'اختر تاريخ بدء لجدول كل $freq أسابيع.';
  }

  @override
  String get adminScheduleNoCohortsYet =>
      'لا توجد مجموعات بعد — أنشئ واحدة أولاً.';

  @override
  String adminScheduleGradeWithCohort(String grade, String cohort) {
    return 'الصف $grade · $cohort';
  }

  @override
  String get adminScheduleDateOnLabel => 'في';

  @override
  String get adminScheduleDateStartsOnLabel => 'يبدأ في';

  @override
  String adminScheduleStudentCount(int count) {
    return '$count طلاب';
  }

  @override
  String get adminScheduleAudienceNone => '—';

  @override
  String adminScheduleTeacherClashNamed(String name) {
    return 'سيكون لدى $name حصتان في الوقت نفسه.';
  }

  @override
  String get adminScheduleTeacherClash =>
      'سيكون لدى هذا المعلم حصتان في الوقت نفسه.';

  @override
  String adminScheduleStudentClashSingle(String name) {
    return 'سيكون لدى $name حصتان في الوقت نفسه:';
  }

  @override
  String adminScheduleStudentClashMany(int count) {
    return 'سيكون لدى $count طلاب حصتان في الوقت نفسه:';
  }

  @override
  String get adminScheduleAStudent => 'طالب';

  @override
  String adminScheduleAffected(String preview) {
    return 'المتأثرون: $preview';
  }

  @override
  String get adminScheduleResolvePrompt => 'كيف ينبغي حل هذا؟';

  @override
  String get adminScheduleResolvePromptStudents =>
      'كيف ينبغي حل هذا لهؤلاء الطلاب؟';

  @override
  String adminScheduleStudentsInCohorts(int count, int cohortCount) {
    return '$count طلاب في المجموعات المحددة';
  }

  @override
  String adminScheduleStudentsInGrade(int count, String grade) {
    return '$count طلاب في الصف $grade';
  }

  @override
  String get adminScheduleCustomizedNote => 'مخصص — محفوظ كطلاب أفراد';

  @override
  String adminScheduleMoreCount(int count) {
    return '+$count المزيد';
  }

  @override
  String get adminScheduleAddStudentsTitle => 'إضافة طلاب';

  @override
  String get adminScheduleNoStudentsMatch => 'لا يوجد طلاب مطابقون.';

  @override
  String get adminScheduleNoPeriodsHere => 'لا توجد حصص هنا بعد.';

  @override
  String adminScheduleGradeRange(String from, String to) {
    return 'الصف $from-$to';
  }

  @override
  String adminScheduleGradesList(String grades) {
    return 'الصفوف $grades';
  }

  @override
  String get adminScheduleNoStudentsInCohorts =>
      'لا يوجد طلاب في هذه المجموعات بعد.';

  @override
  String adminScheduleEveryNWeeks(int freq) {
    return 'كل $freq أسابيع';
  }

  @override
  String get adminScheduleColorLabel => 'اللون';

  @override
  String get adminScheduleSubjectRequired => 'المادة *';

  @override
  String get adminScheduleNoSchoolSubjects =>
      'لا توجد مواد دراسية بعد. انقر \"إضافة جديد\" لتعريف واحدة.';

  @override
  String get adminScheduleNoSubjectsMatch => 'لا توجد مواد مطابقة لبحثك.';

  @override
  String get teacherNewAnnouncementScreenBroadcastBody =>
      'لم يتم تحديد جمهور معين. سيكون هذا الإعلان مرئياً لكل طالب وولي أمر ومعلم وسكرتير ومسؤول في المدرسة.';

  @override
  String teacherNewAnnouncementScreenGradeLabel(int grade) {
    return 'الصف $grade';
  }

  @override
  String get teacherNewAnnouncementScreenNoFilesAttached =>
      'لا توجد ملفات مرفقة.';

  @override
  String teacherNewAnnouncementScreenSelectedCount(int count) {
    return '$count محدد';
  }

  @override
  String get teacherNewAnnouncementScreenAudienceHint =>
      'اختر فئة، ثم الأدوار أو الصفوف أو المجموعات أو الأشخاص المحددين. تتراكم التحديدات من كل فئة.';

  @override
  String get teacherNewAnnouncementScreenLoadingStudents =>
      'جارٍ تحميل الطلاب…';

  @override
  String get teacherNewAnnouncementScreenNoGradeLevels =>
      'لم يتم العثور على مستويات صفوف بعد.';

  @override
  String get teacherNewAnnouncementScreenTapSelectCohorts =>
      'انقر لتحديد المجموعات…';

  @override
  String teacherNewAnnouncementScreenCohortsSelected(int count) {
    return '$count مجموعات محددة';
  }

  @override
  String get teacherNewAnnouncementScreenTapSelectStudents =>
      'انقر لتحديد الطلاب…';

  @override
  String teacherNewAnnouncementScreenStudentsSelected(int count) {
    return '$count طلاب محددون';
  }

  @override
  String get teacherNewAnnouncementScreenTapSelectParents =>
      'انقر لتحديد أولياء الأمور…';

  @override
  String teacherNewAnnouncementScreenParentsSelected(int count) {
    return '$count أولياء أمور محددون';
  }

  @override
  String get teacherNewAnnouncementScreenSelectedAudience => 'الجمهور المحدد';

  @override
  String teacherNewAnnouncementScreenStudentsInCohorts(int count) {
    return '$count طلاب في المجموعات المحددة';
  }

  @override
  String get teacherNewAnnouncementScreenSelectParents => 'تحديد أولياء الأمور';

  @override
  String teacherNewAnnouncementScreenChildrenSummary(
    int count,
    String summary,
  ) {
    return '$count أبناء — $summary';
  }

  @override
  String get teacherNewAnnouncementScreenNoLinkedChildren =>
      'لا يوجد أبناء مرتبطون';

  @override
  String adminPeriodsScreenDayN(int dow) {
    return 'اليوم $dow';
  }

  @override
  String adminPeriodsScreenPeriodN(int period) {
    return 'الحصة $period';
  }

  @override
  String get adminPeriodsScreenPeriodDropdownLabel => 'الحصة';

  @override
  String get adminPeriodsScreenSelectTeacher => 'اختر معلماً…';

  @override
  String get adminPeriodsScreenNone => '— لا شيء —';

  @override
  String get adminPeriodsScreenLinkClassroom => 'الربط بصف دراسي…';

  @override
  String adminPeriodsScreenCohortGradeName(String grade, String name) {
    return 'ص$grade — $name';
  }

  @override
  String adminPeriodsScreenGradeN(String grade) {
    return 'الصف $grade';
  }

  @override
  String get roleBadgeStudent => 'طالب';

  @override
  String get roleBadgeTeacher => 'معلم';

  @override
  String get roleBadgeAdmin => 'مسؤول';

  @override
  String get roleBadgeSecretary => 'سكرتير';

  @override
  String get roleBadgeParent => 'ولي أمر';

  @override
  String get roleBadgeMember => 'عضو';

  @override
  String get teacherSlotAttachmentsScreenEmptyTitle => 'لا توجد مرفقات بعد';

  @override
  String get teacherSlotAttachmentsScreenEmptyBody =>
      'أرفِق المواد ليراها طلابك على بطاقة هذه الحصة.';

  @override
  String get teacherSlotAttachmentsScreenMaterialFallback => 'مادة';

  @override
  String get teacherSlotAttachmentsScreenSheetTitle => 'إرفاق مادة';

  @override
  String get teacherSlotAttachmentsScreenCreateNew => 'إنشاء مادة جديدة';

  @override
  String get teacherAddGradeScreenPickAudience =>
      'اختر طالباً أو مجموعة أو صفاً واحداً على الأقل.';

  @override
  String get teacherAddGradeScreenEnterTitle => 'أدخِل عنواناً لهذه الدرجة.';

  @override
  String get teacherAddGradeScreenPickExam => 'اختر امتحاناً.';

  @override
  String get teacherAddGradeScreenPickAssignment => 'اختر واجباً.';

  @override
  String get teacherAddGradeScreenCouldNotResolveTitle =>
      'تعذّر تحديد عنوان الدرجة.';

  @override
  String teacherAddGradeScreenEnterNumericGrade(String name) {
    return 'أدخِل درجة رقمية لـ $name.';
  }

  @override
  String teacherAddGradeScreenError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get teacherAddGradeScreenTapSelectStudents => 'انقر لتحديد الطلاب…';

  @override
  String teacherAddGradeScreenStudentsSelected(int count) {
    return '$count طالب (طلاب) محددون';
  }

  @override
  String get teacherAddGradeScreenTapSelectCohorts => 'انقر لتحديد المجموعات…';

  @override
  String teacherAddGradeScreenCohortsSelected(int count) {
    return '$count مجموعة (مجموعات) محددة';
  }

  @override
  String teacherAddGradeScreenWillBeGraded(int count) {
    return 'سيتم تقييم $count طالب (طلاب)';
  }

  @override
  String get teacherAddGradeScreenNoGradeLevels =>
      'لم يتم العثور على مستويات صفوف لدى طلابك بعد.';

  @override
  String get teacherAddGradeScreenSelectAudienceExams =>
      'حدد جمهوراً أولاً لتصفية الامتحانات.';

  @override
  String teacherAddGradeScreenNoExamsReach(String audience) {
    return 'لا توجد امتحانات تصل إلى كل $audience المحددين.';
  }

  @override
  String get teacherAddGradeScreenSelectAudienceAssignments =>
      'حدد جمهوراً أولاً لتصفية الواجبات.';

  @override
  String teacherAddGradeScreenNoAssignmentsReach(String audience) {
    return 'لا توجد واجبات تصل إلى كل $audience المحددين.';
  }

  @override
  String get teacherAddGradeScreenSelectAudienceAbove =>
      'حدد جمهوراً أعلاه لإدخال الدرجات.';

  @override
  String get teacherAddGradeScreenSelectStudentsTitle => 'تحديد الطلاب';

  @override
  String teacherAddGradeScreenCountSelected(int count) {
    return '$count محدد';
  }

  @override
  String get teacherAddGradeScreenSelectCohortsTitle => 'تحديد المجموعات';

  @override
  String get teacherAddGradeScreenAudienceCohorts => 'المجموعات';

  @override
  String get teacherAddGradeScreenAudienceGrades => 'الصفوف';

  @override
  String get teacherAddGradeScreenAudienceStudents => 'الطلاب';

  @override
  String get formDetailScreenCouldNotLoad => 'تعذّر تحميل هذا النموذج الآن.';

  @override
  String get formDetailScreenSubmitted => 'تم إرسال النموذج';

  @override
  String get formDetailScreenSubmissionFailed => 'فشل الإرسال';

  @override
  String get formDetailScreenAlreadySubmittedNote =>
      'لقد أرسلت هذا النموذج بالفعل.';

  @override
  String get formDetailScreenSubmitting => 'جارٍ الإرسال…';

  @override
  String get formDetailScreenSubmitAgain => 'إرسال مرة أخرى';

  @override
  String get formDetailScreenSubmitForm => 'إرسال النموذج';

  @override
  String formDetailScreenQuestionCount(int count) {
    return '$count أسئلة';
  }

  @override
  String get formDetailScreenMultiSubmit => 'إرسال متعدد';

  @override
  String get formDetailScreenOnePerStudent => 'واحد لكل طالب';

  @override
  String get formDetailScreenRequired => 'مطلوب';

  @override
  String get formDetailScreenYourAnswer => 'إجابتك';

  @override
  String get formDetailScreenLongAnswerText => 'نص إجابة طويلة';

  @override
  String get formDetailScreenSelect => 'اختر';

  @override
  String get novaChatScreenAboutAiPoweredTitle =>
      'مساعد مدعوم بالذكاء الاصطناعي';

  @override
  String get novaChatScreenAboutAiPoweredBody =>
      'تم بناء NOVA على تقنية نماذج اللغة الكبيرة لمساعدتك على الدراسة وفهم المفاهيم واستكشاف الأفكار.';

  @override
  String get novaChatScreenAboutMistakesBody =>
      'قد ينتج NOVA معلومات غير دقيقة أو غير كاملة أو قديمة. تحقق دائماً من الإجابات المهمة مع معلمك أو مصدر موثوق.';

  @override
  String get novaChatScreenAboutEducationalBody =>
      'تم تصميم NOVA لدعم التعلم وليس بديلاً عن المشورة الطبية أو القانونية أو المالية المهنية.';

  @override
  String get novaChatScreenAboutPrivacyBody =>
      'تُستخدم المحادثات لإنشاء الردود. لا تشارك معلومات شخصية حساسة.';

  @override
  String get novaChatScreenDisclaimerTapToLearn =>
      'قد يرتكب NOVA أخطاء. انقر لمعرفة المزيد.';

  @override
  String get userProfileSheetSchool => 'المدرسة';

  @override
  String get userProfileSheetClass => 'الصف';

  @override
  String get userProfileSheetParents => 'أولياء الأمور';

  @override
  String get userProfileSheetChildren => 'الأبناء';

  @override
  String get scheduleScreenNotes => 'ملاحظات';

  @override
  String get scheduleScreenMaterialFallback => 'مادة';

  @override
  String get scheduleScreenNow => 'الآن';

  @override
  String scheduleScreenMaterialCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مواد',
      one: 'مادة واحدة',
    );
    return '$_temp0';
  }

  @override
  String teacherFormResponsesScreenResponseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count ردّ$_temp0';
  }

  @override
  String get teacherFormResponsesScreenEmptyTitle => 'لا توجد ردود بعد';

  @override
  String get teacherFormResponsesScreenEmptySubtitle =>
      'ستظهر الردود هنا بمجرد إرسال الطلاب لها.';

  @override
  String get teacherFormResponsesScreenStudentFallback => 'طالب';

  @override
  String teacherFormResponsesScreenSubmittedAt(String date) {
    return 'أُرسل $date';
  }

  @override
  String teacherCreateFormScreenQuestionNumber(String number) {
    return 'س$number';
  }

  @override
  String get teacherCreateFormScreenShortAnswerPreview => 'إجابة قصيرة';

  @override
  String get teacherCreateFormScreenLongAnswerPreview => 'إجابة طويلة';

  @override
  String get teacherCreateFormScreenDatePickerPreview => 'منتقي التاريخ';

  @override
  String get teacherCreateFormScreenScaleTo => 'إلى';

  @override
  String get teacherMeetingsScreenNoneOption => 'لا شيء';

  @override
  String teacherMeetingsScreenGradeLabel(String grade) {
    return 'الصف $grade';
  }

  @override
  String teacherMeetingsScreenStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count طالب$_temp0';
  }

  @override
  String get teacherMeetingsScreenPickStartTime => 'اختر وقت البدء';

  @override
  String get teacherMeetingsScreenPickEndTime => 'اختر وقت الانتهاء';

  @override
  String teacherMeetingsScreenMembersWillReceive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'سيستلم هذا $count عضو$_temp0';
  }

  @override
  String get teacherAssignmentsScreenTitle => 'الواجبات';

  @override
  String teacherAssignmentsScreenSummary(int total, int published) {
    return '$total الإجمالي · $published منشور';
  }

  @override
  String get teacherAssignmentsScreenEmpty =>
      'لا توجد واجبات بعد.\nانقر + لإنشاء واحد.';

  @override
  String teacherAssignmentsScreenSubmitted(int count) {
    return '$count مُسلَّم';
  }

  @override
  String get audienceSectionCohorts => 'المجموعات';

  @override
  String get audienceSectionGrades => 'الصفوف';

  @override
  String audienceSectionGradeLabel(int grade) {
    return 'الصف $grade';
  }

  @override
  String get audienceSectionStudents => 'الطلاب';

  @override
  String audienceSectionStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count طالب$_temp0';
  }

  @override
  String audienceSectionMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'سيستلم هذا $count عضو$_temp0';
  }

  @override
  String audienceSectionSelectedCount(int count) {
    return '$count محدد';
  }

  @override
  String secretaryStudentsScreenStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count طالب$_temp0';
  }

  @override
  String secretaryStudentsScreenAvg(String grade) {
    return 'المعدل $grade';
  }

  @override
  String get secretaryStudentsScreenIdentity => 'الهوية';

  @override
  String get secretaryStudentsScreenUsername => 'اسم المستخدم';

  @override
  String get secretaryStudentsScreenEmail => 'البريد الإلكتروني';

  @override
  String get secretaryStudentsScreenPhone => 'الهاتف';

  @override
  String get secretaryStudentsScreenCohort => 'المجموعة';

  @override
  String get secretaryStudentsScreenGrade => 'الصف';

  @override
  String get secretaryStudentsScreenPrimaryCohort => 'المجموعة الأساسية';

  @override
  String secretaryStudentsScreenTeacher(String name) {
    return 'المعلم: $name';
  }

  @override
  String get chatMessageBubbleEdited => 'مُعدَّل';

  @override
  String get chatMessageBubbleForwarded => 'مُعاد توجيهه';

  @override
  String get chatMessageBubblePinned => 'مُثبَّت';

  @override
  String get chatMessageBubbleReply => 'رد';

  @override
  String get chatMessageBubbleMessage => 'رسالة';

  @override
  String get chatMessageBubbleDeletedMessage => 'تم حذف هذه الرسالة';

  @override
  String get chatMessageBubbleImage => 'صورة';

  @override
  String get chatMessageBubbleVideo => 'فيديو';

  @override
  String get chatMessageBubbleFile => 'ملف';

  @override
  String get chatMessageInfoPageReadSection => 'مقروء';

  @override
  String get chatMessageInfoPageNoOneRead => 'لم يقرأها أحد بعد';

  @override
  String get chatMessageInfoPageDeliveredSection => 'تم التسليم';

  @override
  String get chatMessageInfoPagePendingSection => 'قيد الانتظار';

  @override
  String get chatMessageInfoPageUnknown => 'غير معروف';

  @override
  String get profileEnterCodeTitle => 'أدخِل الرمز المكون من 6 أرقام';

  @override
  String profileCodeSentTo(String target) {
    return 'أُرسل إلى $target. تنتهي صلاحيته خلال 15 دقيقة.';
  }

  @override
  String get profileCodeSent => 'تم إرسال الرمز. تنتهي صلاحيته خلال 15 دقيقة.';

  @override
  String profileChangeContact(String label) {
    return 'تغيير $label';
  }

  @override
  String get profileVerifyNewContactInfo =>
      'سيُرسل رمز تحقق إلى القيمة التي تدخلها — لتأكيد ملكيتك لها.';

  @override
  String profileVerifyCurrentContactInfo(String label) {
    return 'سيُرسل رمز تحقق إلى $label الحالي الخاص بك حتى تثبت ملكيتك له قبل التبديل.';
  }

  @override
  String get appShellReports => 'التقارير';

  @override
  String get appShellExportData => 'تصدير البيانات';

  @override
  String get appShellAdmin => 'المسؤول';

  @override
  String get appShellViewingAs => 'العرض كـ ';

  @override
  String get appShellSwitchChild => 'تبديل الابن';

  @override
  String get messageThreadScreenGroupInviteSubtitle =>
      'تمت دعوتك للانضمام إلى هذه المجموعة.';

  @override
  String get messageThreadScreenBlockedHint =>
      'لقد حظرت هذه المحادثة. ألغِ الحظر من قائمة الأشخاص المحظورين للمحادثة مجدداً.';

  @override
  String get messageThreadScreenCannotSendHint =>
      'لا يمكنك إرسال رسائل في هذه المحادثة الآن.';

  @override
  String get messageThreadScreenTapForGroupInfo => 'انقر لمعلومات المجموعة';

  @override
  String get messageThreadScreenAddParticipantsTitle => 'إضافة مشاركين';

  @override
  String teacherExamsScreenGradedCount(int count) {
    return '$count مُقيَّم';
  }

  @override
  String get teacherScheduleScreenNextUp => 'التالي';

  @override
  String teacherScheduleScreenPeriodLabel(String period) {
    return 'الحصة $period';
  }

  @override
  String teacherScheduleScreenGradeLabel(int grade) {
    return 'الصف $grade';
  }

  @override
  String teacherScheduleScreenMaterialsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مواد',
      one: 'مادة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get teacherClassroomAddAssignmentScreenTitle => 'إضافة واجب';

  @override
  String get teacherClassroomAddAssignmentScreenDetails => 'تفاصيل الواجب';

  @override
  String get teacherClassroomAddAssignmentScreenDueDateOptional =>
      'تاريخ الاستحقاق (اختياري)';

  @override
  String get teacherClassroomAddAssignmentScreenNotifyStudents =>
      'إشعار الطلاب';

  @override
  String get teacherClassroomAddAssignmentScreenUploading => 'جارٍ الرفع…';

  @override
  String get teacherClassroomAddAssignmentScreenAttachFiles => 'إرفاق ملفات';

  @override
  String get teacherClassroomAddAssignmentScreenAddMoreFiles =>
      'إضافة المزيد من الملفات';

  @override
  String get diplomasScreenCertificate => 'شهادة';

  @override
  String diplomasScreenIssuedDate(String date) {
    return 'صدرت $date';
  }

  @override
  String get diplomasScreenNoCertificatesReceived =>
      'لم يتم استلام شهادات بعد.';

  @override
  String diplomasScreenFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملفات',
      one: '$count ملف',
    );
    return '$_temp0';
  }

  @override
  String get gradesScreenOutOf100 => '/ 100';

  @override
  String gradesScreenShowMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'عرض $count درجة$_temp0 أخرى';
  }

  @override
  String get gradesScreenShowLess => 'عرض أقل';

  @override
  String gradesScreenScoreOutOf100(String score) {
    return '$score / 100';
  }

  @override
  String get adminSchoolSettingsStart => 'البداية';

  @override
  String get adminSchoolSettingsEnd => 'النهاية';

  @override
  String get adminExportScreenEachUserAlone => 'كل مستخدم على حدة';

  @override
  String get adminExportScreenEachUserAloneOn =>
      'صفحة كاملة لكل مستخدم، تخطيط بطاقة كبير وسهل القراءة.';

  @override
  String get adminExportScreenEachUserAloneOff =>
      'جدول مدمج — كل مستخدم في صف.';

  @override
  String get adminExportScreenSeparateFilesOn => 'ملف PDF منفصل لكل مستخدم';

  @override
  String get adminExportScreenSeparateFilesOff =>
      'ملف PDF واحد، صفحة لكل مستخدم';

  @override
  String adminExportScreenSeparateFilesOnDesc(int count) {
    return 'ستشارك $count ملف PDF دفعة واحدة — لكل مستخدم ملفه الخاص.';
  }

  @override
  String get adminExportScreenSeparateFilesOffDesc =>
      'الجميع في ملف PDF واحد، كل في صفحته الخاصة.';

  @override
  String get adminSubjectDetailScreenSchoolSettings => 'إعدادات المدرسة';

  @override
  String get adminSubjectDetailScreenNewSubject => 'مادة جديدة';

  @override
  String get adminSubjectDetailScreenLangEnglish => 'الإنجليزية';

  @override
  String get adminSubjectDetailScreenLangArabic => 'العربية';

  @override
  String get adminSubjectDetailScreenLangHebrew => 'العبرية';

  @override
  String get adminSubjectDetailScreenLangFrench => 'الفرنسية';

  @override
  String get adminSubjectDetailScreenLangRussian => 'الروسية';

  @override
  String get adminSubjectDetailScreenColor => 'اللون';

  @override
  String get parentHomeScreenGreetingFallback => 'مرحباً';

  @override
  String parentHomeScreenChildrenLoadError(String error) {
    return 'تعذّر تحميل أبنائك: $error';
  }

  @override
  String get parentHomeScreenMaterials => 'المواد';

  @override
  String get cmCodeBlockCopied => 'تم النسخ';

  @override
  String get cmCodeBlockCopy => 'نسخ';

  @override
  String get phoneFieldCountryCode => 'رمز الدولة';

  @override
  String get teacherClassroomAddMeetingScreenEndDateDefault =>
      'تاريخ الانتهاء افتراضياً هو تاريخ البدء';

  @override
  String get teacherAddMaterialScreenLinkHint => 'https://…';

  @override
  String get teacherAddMaterialScreenLinkFallback => 'رابط';

  @override
  String get teacherAddMaterialScreenFileFallback => 'ملف';

  @override
  String get teacherCreateDiplomaScreenTitle => 'إصدار شهادة';

  @override
  String get teacherCreateDiplomaScreenGradePrefix => 'الصف';

  @override
  String get teacherCreateDiplomaScreenAttachFiles =>
      'إرفاق ملف (ملفات) الشهادة';

  @override
  String get teacherCreateDiplomaScreenAddMoreFiles =>
      'إضافة المزيد من الملفات';

  @override
  String get teacherAssignmentDetailScreenTitle => 'الواجب';

  @override
  String get teacherAssignmentDetailScreenNoSubmissions =>
      'لا توجد تسليمات بعد';

  @override
  String teacherAssignmentDetailScreenSubmissionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count تسليم$_temp0';
  }

  @override
  String teacherAssignmentDetailScreenGradedCount(int count) {
    return '$count مُقيَّم';
  }

  @override
  String get teacherAssignmentDetailScreenStudentFallback => 'طالب';

  @override
  String teacherAssignmentDetailScreenSubmittedOn(String date) {
    return 'أُرسل $date';
  }

  @override
  String teacherAddAssignmentScreenGradeLabel(int count) {
    return 'الصف $count';
  }

  @override
  String teacherAddAssignmentScreenStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return '$count طالب$_temp0';
  }

  @override
  String teacherAddAssignmentScreenMembersWillReceive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'سيستلم هذا $count عضو$_temp0';
  }

  @override
  String get teacherAddAssignmentScreenNoDueDate => 'لا يوجد تاريخ استحقاق';

  @override
  String get teacherAddAssignmentScreenMaterialFallback => 'مادة';

  @override
  String teacherAddAssignmentScreenSelectedCount(int count) {
    return '$count محدد';
  }

  @override
  String teacherClassroomsScreenGradeLabel(int grade) {
    return 'الصف $grade';
  }

  @override
  String get teacherClassroomsScreenNewClassroom => 'صف دراسي جديد';

  @override
  String get assignmentsScreenAlreadyHandedIn => 'لقد سلّمت هذا الواجب بالفعل.';

  @override
  String get assignmentsScreenAddNoteOrFiles =>
      'أضف ملاحظة أو أرفِق ملفات، ثم اضغط تسليم.';

  @override
  String assignmentsScreenGradeLabel(String grade) {
    return 'الدرجة: $grade';
  }

  @override
  String assignmentsScreenFeedbackLabel(String feedback) {
    return 'الملاحظات: $feedback';
  }

  @override
  String get assignmentsScreenReturnedForResolution => 'أُعيد لإعادة الحل';

  @override
  String get assignmentsScreenAttachFile => 'إرفاق ملف';

  @override
  String get assignmentsScreenAddMoreFiles => 'إضافة المزيد من الملفات';

  @override
  String get assignmentsScreenHandingIn => 'جارٍ التسليم…';

  @override
  String get assignmentsScreenHandIn => 'تسليم';

  @override
  String get examDetailScreenCouldNotLoad => 'تعذّر تحميل هذا الامتحان الآن.';

  @override
  String get adminEditUserRoleStudent => 'طالب';

  @override
  String get adminEditUserRoleTeacher => 'معلم';

  @override
  String get adminEditUserRoleSecretary => 'سكرتير';

  @override
  String get adminEditUserRoleParent => 'ولي أمر';

  @override
  String get adminEditUserRoleAdmin => 'مسؤول';

  @override
  String adminEditUserCohortMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '',
      one: '',
    );
    return 'عضو في $count مجموعة$_temp0.';
  }

  @override
  String get adminEditUserSearchStudents => 'البحث عن طلاب…';

  @override
  String adminEditUserGradeSuffix(int grade) {
    return '(الصف $grade)';
  }

  @override
  String get solutionAssetPreviewSheetPdfDocument => 'مستند PDF';

  @override
  String get solutionAssetPreviewSheetUnableToPreview =>
      'تعذّرت معاينة ملف PDF.';

  @override
  String classroomDetailSectionHeader(String title, int count) {
    return '$title ($count)';
  }

  @override
  String get classroomDetailTeacherSection => 'المعلم';

  @override
  String get classroomDetailStudentsSection => 'الطلاب';

  @override
  String get classroomDetailClassroomFallback => 'صف دراسي';

  @override
  String get classroomDetailUntitled => 'بدون عنوان';

  @override
  String get typingDotsPaused => 'متوقف مؤقتاً';

  @override
  String get cmAiMessageStartPracticeSession => 'بدء جلسة تدريب';

  @override
  String cmAiMessageQuestionCount(int count) {
    return '$count أسئلة';
  }

  @override
  String get cmAiMessageDifficultyEasy => 'سهل';

  @override
  String get cmAiMessageDifficultyHard => 'صعب';

  @override
  String get cmAiMessageDifficultyOlympiad => 'أولمبياد';

  @override
  String get cmAiMessageDifficultyAdaptive => 'تكيفي';

  @override
  String get cmAiMessageDifficultyMedium => 'متوسط';

  @override
  String get teacherCreateFormScreenParagraphType => 'فقرة';

  @override
  String get teacherCreateFormScreenMultipleChoiceType => 'اختيار من متعدد';

  @override
  String get teacherCreateFormScreenCheckboxesType => 'مربعات اختيار';

  @override
  String get teacherCreateFormScreenRatingType => 'تقييم (1–5)';

  @override
  String get teacherCreateFormScreenLinearScaleType => 'مقياس خطي';

  @override
  String get teacherCreateFormScreenDropdownType => 'قائمة منسدلة';

  @override
  String get teacherCreateFormScreenDateType => 'التاريخ';

  @override
  String teacherCohortsScreenSingleGrade(int grade) {
    return 'الصف $grade';
  }

  @override
  String teacherCohortsScreenGradeRange(int from, int to) {
    return 'الصفوف $from-$to';
  }

  @override
  String teacherCohortsScreenMultiGrade(String grades) {
    return 'الصفوف $grades';
  }

  @override
  String get teacherAddGradeScreenFailedCreateRecord =>
      'تعذّر إنشاء سجل الدرجة.';

  @override
  String get phoneFieldLabel => 'الهاتف (اختياري)';

  @override
  String get phoneFieldHelper =>
      'يُستخدم لإعادة تعيين كلمة المرور عبر الرسائل النصية';

  @override
  String get gradesScreenCouldNotLoad => 'تعذّر تحميل الدرجات.';

  @override
  String get gradesScreenTimeout => 'انتهت مهلة الطلب. تحقّق من اتصالك.';

  @override
  String get gradesScreenNoConnection => 'لا يوجد اتصال. اسحب لإعادة المحاولة.';

  @override
  String get examDetailScreenCountdownPassed => 'لقد انتهى هذا الامتحان';

  @override
  String get examDetailScreenCountdownToday => 'إنه اليوم!';

  @override
  String get teacherCreateDiplomaScreenDefaultTitle => 'شهادة تقدير';

  @override
  String teacherMaterialAddedBy(String name) {
    return 'أضافها $name';
  }

  @override
  String teacherMaterialAttachedTo(String period) {
    return 'مرفقة بـ $period';
  }

  @override
  String get adminPeopleAddMany => 'إضافة عدة أشخاص';

  @override
  String get adminAddManyPasteNames => 'لصق الأسماء';

  @override
  String get adminAddManyApplyRole => 'تعيين الدور للجميع';

  @override
  String get adminAddManyApplyGrade => 'تعيين الصف للجميع';

  @override
  String get adminAddManyParentLabel => 'ولي الأمر';

  @override
  String get adminAddManyParentNone => 'بدون ولي أمر';

  @override
  String get adminAddManyAddParent => 'إضافة ولي أمر';

  @override
  String get adminAddManyCreateParentGeneric => 'إنشاء ولي أمر جديد';

  @override
  String get adminAddManyParentInBatch => 'أولياء أمور جدد في هذه القائمة';

  @override
  String get adminAddManyParentExisting => 'أولياء الأمور الحاليون';

  @override
  String get adminAddManySearchParents => 'البحث عن أولياء الأمور…';

  @override
  String get adminAddManyNoParentsYet =>
      'لا يوجد أولياء أمور مطابقون — اكتب اسمًا أعلاه لإنشاء واحد';

  @override
  String get adminAddManyUsernameTaken => 'اسم المستخدم مستخدم بالفعل';

  @override
  String get adminAddManyUsernameDupe => 'اسم مستخدم مكرر في هذه القائمة';

  @override
  String get adminUsernameAvailable => 'اسم المستخدم متاح';

  @override
  String get adminUsernameInvalidFormat =>
      'استخدم 3 أحرف أو أكثر: حروف أو أرقام أو . _ -';

  @override
  String get adminUsernameSuggestionsLabel =>
      'اقتراحات متاحة — انقر للاستخدام:';

  @override
  String adminAddManyCreateParent(String name) {
    return 'إنشاء ولي أمر جديد \"$name\"';
  }

  @override
  String adminAddManyPastedRows(int count) {
    return 'تمت إضافة $count صف';
  }

  @override
  String get teacherCreateClassroomNoStudentsInCohort =>
      'لا يوجد طلاب في الفصل المحدد بعد.';

  @override
  String get audienceSummaryResolving => 'جارٍ العثور على الطلاب…';

  @override
  String audienceSummaryCount(int count) {
    return 'سيشاهدها $count';
  }

  @override
  String get audienceSummaryEmpty => 'لا يوجد طلاب مطابقون لهذا الجمهور.';

  @override
  String audienceSummaryRestore(int count) {
    return 'استعادة $count محذوف';
  }

  @override
  String get scheduleUpcomingExam => 'الامتحان القادم';

  @override
  String get scheduleNoUpcomingExams => 'لا توجد امتحانات قادمة';

  @override
  String get navCertificates => 'الشهادات';

  @override
  String get averagesDelete => 'حذف';

  @override
  String get averagesFieldTitle => 'العنوان';

  @override
  String get averagesSave => 'حفظ';

  @override
  String get certificatesTitle => 'الشهادات';

  @override
  String get certHomeroom => 'الصف (المربّي)';

  @override
  String get certStudent => 'الطالب';

  @override
  String get certDisplayName => 'الاسم على الشهادة';

  @override
  String get certNationalId => 'رقم الهوية';

  @override
  String get certHomeroomTeacher => 'مربّي/ة الصف';

  @override
  String get certPrincipal => 'مدير/ة المدرسة';

  @override
  String get certPublisherNote => 'ملاحظة (اختياري)';

  @override
  String get certSemesterWeights => 'أوزان الفصول';

  @override
  String get certLanguage => 'لغة الشهادة';

  @override
  String get certGenerate => 'إنشاء PDF';

  @override
  String get certWeightsMustBe100 => 'يجب أن يكون مجموع أوزان الفصول 100%.';

  @override
  String get certSelectStudentFirst => 'اختر طالبًا أولًا.';

  @override
  String get certSaved => 'تم إنشاء الشهادة.';

  @override
  String get certSaveAndPublish => 'حفظ ونشر';

  @override
  String get certSaveDraft => 'حفظ كمسودة';

  @override
  String get examGradesPublished => 'تم نشر الدرجات للطلاب.';

  @override
  String get examGradesPublishedShort => 'منشور';

  @override
  String get examRepublish => 'إعادة النشر';

  @override
  String get certPreview => 'معاينة PDF';

  @override
  String get certPublished => 'تم النشر للطالب.';

  @override
  String get certDraftSaved => 'تم الحفظ كمسودة.';

  @override
  String get certPublishing => 'جارٍ النشر…';

  @override
  String get certDownload => 'تنزيل';

  @override
  String get certNoneYet => 'لا توجد شهادات بعد.';

  @override
  String get certMine => 'شهاداتي';

  @override
  String get certNoHomeroom => 'لست مربي صف لأي صف بعد.';

  @override
  String get certGrin => 'الدرجات';

  @override
  String get certPrintAll => 'طباعة الكل';

  @override
  String get certSelectCohortToPrint => 'اختر صفًا لطباعة جميع شهاداته.';

  @override
  String get certEditTitle => 'تحرير الشهادة';

  @override
  String get certPdfAnnualCertificate => 'شهادة سنوية';

  @override
  String get certPdfSubject => 'الموضوع';

  @override
  String get certPdfFinal => 'النهائي';

  @override
  String get certPdfOverall => 'المعدل العام';

  @override
  String get certPdfAverage => 'المعدل';

  @override
  String get certPdfAbsences => 'الغيابات';

  @override
  String get certPdfLateness => 'التأخر';

  @override
  String get certPdfHomeroomTeacher => 'مربّي/ة الصف';

  @override
  String get certPdfPrincipal => 'مدير/ة المدرسة';

  @override
  String get certPdfNationalId => 'رقم الهوية';

  @override
  String get certPdfDate => 'التاريخ';

  @override
  String get certPdfGeneratedBy => 'أُنشئت بواسطة';

  @override
  String get certPdfName => 'الاسم';

  @override
  String get certPdfClass => 'الصف';

  @override
  String get adminEditUserNationalId => 'رقم الهوية';

  @override
  String get teacherCohortsScreenNoStudentsToAdd =>
      'جميع الطلاب موجودون بالفعل في هذا الصف.';

  @override
  String get gradeWeightLabel => 'الوزن في المعدل (%)';

  @override
  String get gradeWeightHint =>
      'اختياري — حدّد النسبة التي تُحتسب في معدل المادة، أو اتركه لضبطه لاحقًا.';

  @override
  String get gradeSemesterLabel => 'الفصل';

  @override
  String get gradeSemesterAuto => 'تلقائي (حسب التاريخ)';

  @override
  String get gradeDeleteTooltip => 'حذف العلامة';

  @override
  String get gradeDeleteTitle => 'حذف العلامة';

  @override
  String gradeDeleteConfirm(String title) {
    return 'حذف علامة “$title”؟';
  }

  @override
  String get cohortHomeroomLabel => 'صف تربية (مربّي)';

  @override
  String get cohortHomeroomHint => 'عيّن مربّي/ة الصف لهذا الصف.';

  @override
  String get cohortHomeroomTeacher => 'مربّي/ة الصف';

  @override
  String get adminPrincipalLabel => 'مدير/ة المدرسة';

  @override
  String get adminPrincipalHint =>
      'هذا المشرف مدير/ة؛ تُملأ الشهادات باسمه تلقائيًا حسب صف الطالب.';

  @override
  String get adminPrincipalGrades => 'مدير/ة للصفوف';

  @override
  String get certPdfTeacher => 'المعلّم';

  @override
  String gradesHubSummary(int subjects, int students) {
    return '$subjects مواد · $students طلاب';
  }

  @override
  String get gradesHubSearchSubjects => 'بحث في المواد';

  @override
  String get gradesHubEmpty =>
      'لا توجد علامات بعد. أضف علامة وستظهر المادة هنا.';

  @override
  String gradesHubStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلاب',
      one: 'طالب واحد',
    );
    return '$_temp0';
  }

  @override
  String get gradesSubjectStudentsTab => 'الطلاب';

  @override
  String get gradesSubjectGradesTab => 'العلامات';

  @override
  String get gradesSubjectNoGrades => 'لا توجد علامات في هذه المادة بعد.';

  @override
  String get gradesPublishedShort => 'منشور';

  @override
  String get gradesDraftShort => 'مسودة';

  @override
  String gradesPublishTitle(Object title) {
    return 'نشر “$title”';
  }

  @override
  String gradesUnpublishTitle(Object title) {
    return 'إلغاء نشر “$title”';
  }

  @override
  String get gradesPublishAction => 'نشر';

  @override
  String get gradesUnpublishAction => 'إلغاء النشر';

  @override
  String get gradesPublishedToast => 'تم نشر الدرجة — يمكن للطلاب رؤيتها الآن.';

  @override
  String get gradesUnpublishedToast => 'تم إلغاء نشر الدرجة — مخفية عن الطلاب.';

  @override
  String get navGradeScales => 'سلالم الدرجات';

  @override
  String get gradeScaleAdd => 'إضافة سلم درجات';

  @override
  String get gradeScaleEdit => 'تحرير سلم الدرجات';

  @override
  String get gradeScaleDeleteTitle => 'حذف سلم الدرجات؟';

  @override
  String gradeScaleDeleteConfirm(Object name) {
    return 'حذف “$name”؟ تحتفظ التقييمات التي صُححت وفقه بتسمياتها.';
  }

  @override
  String get gradeScaleEmptyTitle => 'لا توجد سلالم درجات بعد';

  @override
  String get gradeScaleEmptyHint =>
      'أنشئ سلم أحرف أو كلمات (مثل أ، أ+، ب) للصفوف الأصغر سنًا. يختار المعلمون الذين يقيّمون تلك الصفوف تسمية بدلاً من رقم.';

  @override
  String get gradeScaleAllGrades => 'ينطبق على جميع الصفوف';

  @override
  String gradeScaleAppliesTo(Object grades) {
    return 'الصفوف $grades';
  }

  @override
  String get gradeScaleNameLabel => 'اسم السلم';

  @override
  String get gradeScaleNameHint => 'مثل درجات الأحرف';

  @override
  String get gradeScaleNameRequired => 'أدخل اسمًا للسلم.';

  @override
  String get gradeScaleGradeLevels => 'ينطبق على الصفوف';

  @override
  String get gradeScaleGradeLevelsHint =>
      'لا تحدد أيًا منها لتطبيقه على جميع الصفوف.';

  @override
  String get gradeScaleLabels => 'التسميات';

  @override
  String get gradeScaleLabelsHint =>
      'أضف كل تسمية (مثل أ+) مع رقم اختياري (0–100) يُستخدم للمتوسطات.';

  @override
  String get gradeScaleLabelText => 'التسمية';

  @override
  String get gradeScaleLabelValue => 'القيمة';

  @override
  String get gradeScaleAddLabel => 'إضافة تسمية';

  @override
  String get gradeScaleNeedTwoLabels => 'أضف تسميتين على الأقل.';

  @override
  String get gradeScalePickLabel => 'الدرجة';

  @override
  String get gradeScaleUseScale => 'سلم الدرجات';

  @override
  String gradeScaleNumeric(Object max) {
    return 'رقم (0–$max)';
  }

  @override
  String get accountSwitcherTitle => 'الحسابات';

  @override
  String get accountAddAccount => 'إضافة حساب';

  @override
  String get accountSignOutThis => 'تسجيل الخروج من هذا الحساب';

  @override
  String get averagesManageTooltip => 'إدارة المتوسطات';

  @override
  String get averagesTitle => 'المتوسطات';

  @override
  String get averagesAdd => 'إضافة متوسط';

  @override
  String get averagesDeleteTitle => 'حذف المتوسط';

  @override
  String averagesDeleteConfirm(Object title) {
    return 'حذف \"$title\"؟ لا يمكن التراجع عن هذا.';
  }

  @override
  String get averagesCancel => 'إلغاء';

  @override
  String get averagesEmptyTitle => 'لا توجد متوسطات بعد';

  @override
  String get averagesEmptyBody =>
      'انقر على \"إضافة متوسط\" لإنشاء صيغة درجة مرجّحة لمادة.';

  @override
  String get averagesFullYear => 'السنة الكاملة';

  @override
  String averagesSemesterN(Object n) {
    return 'الفصل $n';
  }

  @override
  String averagesFormatChip(Object index, Object total) {
    return 'الصيغة $index: $total%';
  }

  @override
  String get averagesNoStudents => 'لا يوجد طلاب للحساب.';

  @override
  String averagesFormatN(Object n) {
    return 'الصيغة $n';
  }

  @override
  String get averagesErrTitle => 'أدخل عنوانًا.';

  @override
  String get averagesErrSubject => 'اختر مادة.';

  @override
  String get averagesErrCohort => 'اختر صفًا.';

  @override
  String get averagesErrNoFormat => 'أضف صيغة واحدة على الأقل.';

  @override
  String averagesErrFormatNoGrade(Object n) {
    return 'الصيغة $n: اختر درجة واحدة على الأقل.';
  }

  @override
  String averagesErrFormatSum(Object n, Object total) {
    return 'الصيغة $n: يجب أن يكون مجموع الأوزان 100 (الآن $total%).';
  }

  @override
  String get averagesNew => 'متوسط جديد';

  @override
  String get averagesEdit => 'تحرير المتوسط';

  @override
  String get averagesLabelSubject => 'المادة';

  @override
  String get averagesHintSubject => 'اختر مادة';

  @override
  String get averagesLabelCohort => 'الصف';

  @override
  String get averagesHintCohort => 'اختر صفًا';

  @override
  String get averagesLabelUnits => 'الوحدات (اختياري)';

  @override
  String get averagesFormats => 'الصيغ';

  @override
  String get averagesFormatsHelp =>
      'يجب أن يكون مجموع أوزان كل صيغة 100%. تُستخدم الصيغة الأعلى تسجيلاً لكل طالب.';

  @override
  String get averagesAddFormat => 'إضافة صيغة';

  @override
  String get averagesLabelFormatLabel => 'تسمية الصيغة (اختياري)';

  @override
  String get averagesAddGrade => 'إضافة درجة';

  @override
  String averagesTotal(Object total) {
    return 'المجموع: $total%';
  }

  @override
  String get averagesLabelGrade => 'الدرجة';

  @override
  String get averagesHintPickFirst => 'اختر المادة والصف أولاً';

  @override
  String get averagesHintGrade => 'اختر درجة';

  @override
  String get adminInsightsSearchHint => 'ابحث عن الطلاب بالاسم…';

  @override
  String get adminInsightsNoStudents => 'لم يُعثر على طلاب.';

  @override
  String get adminInsightsNoGrades => 'لم تُسجَّل درجات بعد.';

  @override
  String get gradesEditGradeTitle => 'تعديل العلامة';

  @override
  String gradeFormatN(String n) {
    return 'صيغة $n';
  }

  @override
  String get gradeAddFormat => 'إضافة صيغة';

  @override
  String get gradesBreakdownAverage => 'المعدل';

  @override
  String get adminPrincipalRangeFrom => 'من';

  @override
  String get adminPrincipalRangeTo => 'إلى';

  @override
  String get adminPrincipalAddRange => 'إضافة نطاق';

  @override
  String certPdfSemesterCertificate(String sem) {
    return 'شهادة فصلية — $sem';
  }

  @override
  String get certPdfRemarks => 'ملاحظات المربّي/ة';

  @override
  String get certTypeLabel => 'نوع الشهادة';

  @override
  String get certTypeAnnual => 'سنوية';

  @override
  String certTypeSemester(String sem) {
    return 'نهاية $sem';
  }

  @override
  String get certRoundWhole => 'تقريب إلى عدد صحيح';

  @override
  String get certRoundWholeHint =>
      'أقل من ٠٫٥ إلى الأسفل، ٠٫٥ فأكثر إلى الأعلى. أوقفه لعرض رقمين عشريين.';

  @override
  String get teacherAddGradeSubjectRequired => 'يرجى اختيار مادة لهذه العلامة.';

  @override
  String get gradesSubjectAveragesTab => 'المعدلات';

  @override
  String get gradesAveragesSummaryTitle => 'معدل الفصل';

  @override
  String gradesAveragesSummaryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count علامات موزونة',
      one: 'علامة موزونة واحدة',
      zero: 'لا توجد علامات موزونة بعد',
    );
    return '$_temp0';
  }

  @override
  String get gradesAveragesTotalWeight => 'مجموع الوزن';

  @override
  String get gradesAveragesNoWeighted =>
      'لا توجد علامات لها وزن في هذا الفصل. أضف واحدة أو حدّد نسبة على علامة.';

  @override
  String get gradesAvgPickTitle => 'أضف درجة إلى المتوسط';

  @override
  String gradesAvgPickSubtitle(String subject) {
    return 'اختر درجة منشورة في $subject، ثم حدد وزنها وفصلها وصيغتها.';
  }

  @override
  String get gradesAvgFilterAll => 'الكل';

  @override
  String gradesAvgFilterCohort(String name) {
    return 'الصف — $name';
  }

  @override
  String get gradesAvgSearchHint => 'ابحث عن الدرجات';

  @override
  String get gradesAvgNoResults => 'لا توجد درجات مطابقة في هذه المادة.';

  @override
  String get gradesAvgInAverage => 'ضمن المتوسط';

  @override
  String get notesTitle => 'ملاحظات';

  @override
  String get notesSearchStudents => 'ابحث عن الطلاب';

  @override
  String get notesNoStudents => 'لم يُعثر على طلاب';

  @override
  String notesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملاحظة',
      many: '$count ملاحظة',
      few: '$count ملاحظات',
      two: 'ملاحظتان',
      one: 'ملاحظة واحدة',
      zero: 'لا ملاحظات',
    );
    return '$_temp0';
  }

  @override
  String get notesNewNote => 'ملاحظة جديدة';

  @override
  String get notesNoNotes => 'لا توجد ملاحظات بعد';

  @override
  String get notesNoNotesHint => 'انقر على + لكتابة أول ملاحظة عن هذا الطالب.';

  @override
  String get notesDeleteTitle => 'حذف الملاحظة؟';

  @override
  String get notesDeleteBody => 'ستُحذف هذه الملاحظة نهائيًا.';

  @override
  String get notesUntitled => 'بدون عنوان';

  @override
  String get notesTitleHint => 'العنوان';

  @override
  String get notesBodyHint => 'ابدأ الكتابة…';

  @override
  String notesEditedBy(String name) {
    return 'بواسطة $name';
  }

  @override
  String get cmailTitle => 'CMail';

  @override
  String get cmailInbox => 'البريد الوارد';

  @override
  String get cmailSentTab => 'المُرسَل';

  @override
  String get cmailCompose => 'بريد جديد';

  @override
  String get cmailEmptyInbox => 'لا بريد بعد';

  @override
  String get cmailEmptyInboxHint => 'سيظهر البريد من مدرستك هنا.';

  @override
  String get cmailEmptySent => 'لم يُرسل شيء بعد';

  @override
  String get cmailSubject => 'الموضوع';

  @override
  String get cmailBodyHint => 'اكتب رسالتك…';

  @override
  String get cmailAudience => 'إلى';

  @override
  String get cmailAudienceSchool => 'الجميع';

  @override
  String get cmailAudienceStudents => 'جميع الطلاب';

  @override
  String get cmailAudienceTeachers => 'جميع المعلمين';

  @override
  String get cmailAudienceParents => 'جميع أولياء الأمور';

  @override
  String get cmailAudienceStaff => 'الطاقم';

  @override
  String get cmailAudienceGrades => 'حسب الصف';

  @override
  String get cmailAudienceCohorts => 'حسب الشعبة';

  @override
  String get cmailAudienceUsers => 'أشخاص محددون';

  @override
  String get cmailPickGrades => 'اختر الصفوف';

  @override
  String get cmailPickCohorts => 'اختر الشعب';

  @override
  String get cmailPickPeople => 'اختر الأشخاص';

  @override
  String get cmailAttach => 'إرفاق ملفات';

  @override
  String get cmailSendAction => 'إرسال';

  @override
  String get cmailSentOk => 'تم إرسال البريد';

  @override
  String get cmailDeleteTitle => 'حذف البريد؟';

  @override
  String get cmailDeleteForAll => 'هذا يحذف البريد للجميع.';

  @override
  String get cmailDeleteForMe => 'هذا يزيل البريد من صندوق الوارد الخاص بك.';

  @override
  String cmailRecipients(num count) {
    return '$count مستلمين';
  }

  @override
  String cmailReadStats(num read, num total) {
    return '$read من $total قرأوا';
  }

  @override
  String get cmailSubjectRequired => 'الموضوع مطلوب';

  @override
  String get cmailAudienceRequired => 'اختر إلى من يذهب هذا البريد';

  @override
  String get cmailAttachments => 'المرفقات';

  @override
  String cmailFrom(String name) {
    return 'من $name';
  }

  @override
  String get phoneLinkTitle => 'أضف هاتفك';

  @override
  String get phoneLinkSubtitle =>
      'احمِ حسابك برقم هاتف. سنرسل لك رمز تحقق برسالة نصية — كما يتيح لك إعادة تعيين كلمة مرورك عبر الرسائل القصيرة.';

  @override
  String get phoneLinkFieldLabel => 'رقم الهاتف';

  @override
  String get phoneLinkSend => 'إرسال الرمز';

  @override
  String get phoneLinkCodeLabel => 'رمز مكوّن من 6 أرقام';

  @override
  String phoneLinkCodeSent(String phone) {
    return 'أُرسل الرمز إلى $phone';
  }

  @override
  String get phoneLinkVerify => 'تحقق واربط';

  @override
  String get phoneLinkLater => 'لاحقًا';

  @override
  String get phoneLinkDone => 'تم ربط الهاتف!';

  @override
  String get phoneLinkResend => 'إعادة إرسال الرمز';

  @override
  String get phoneLinkInvalid => 'أدخل رقم هاتف صالحًا';

  @override
  String get hubParentsSection => 'أولياء الأمور';

  @override
  String get hubNoParents => 'لا يوجد أولياء أمور مرتبطون بعد';

  @override
  String get hubStudentSection => 'الطالب';

  @override
  String get hubAverageLabel => 'المتوسط';

  @override
  String get hubAccuracyLabel => 'دقة التدريب';

  @override
  String get hubBestSubject => 'أفضل مادة';

  @override
  String get hubWeakestSubject => 'أضعف مادة';

  @override
  String get hubWeakTopics => 'المواضيع الضعيفة';

  @override
  String get hubStrongTopics => 'المواضيع القوية';

  @override
  String get hubNoInsights => 'لا توجد رؤى بعد';

  @override
  String get hubNoGrades => 'لا توجد درجات بعد';

  @override
  String get hubUnpublished => 'مسودة';

  @override
  String get hubClass => 'الصف';

  @override
  String get a11yBack => 'رجوع';

  @override
  String get a11yClose => 'إغلاق';

  @override
  String get a11yCancel => 'إلغاء';

  @override
  String get a11yDone => 'تم';

  @override
  String get a11ySave => 'حفظ';

  @override
  String get a11yEdit => 'تعديل';

  @override
  String get a11yDelete => 'حذف';

  @override
  String get a11yRemove => 'إزالة';

  @override
  String get a11yAdd => 'إضافة';

  @override
  String get a11yCreate => 'إنشاء';

  @override
  String get a11ySend => 'إرسال';

  @override
  String get a11ySearch => 'بحث';

  @override
  String get a11yClear => 'مسح';

  @override
  String get a11yFilter => 'تصفية';

  @override
  String get a11ySort => 'فرز';

  @override
  String get a11yMore => 'خيارات إضافية';

  @override
  String get a11yMenu => 'القائمة';

  @override
  String get a11yRefresh => 'تحديث';

  @override
  String get a11yRetry => 'إعادة المحاولة';

  @override
  String get a11yShare => 'مشاركة';

  @override
  String get a11yCopy => 'نسخ';

  @override
  String get a11yDownload => 'تنزيل';

  @override
  String get a11yUpload => 'رفع';

  @override
  String get a11yAttach => 'إرفاق ملف';

  @override
  String get a11yAddPhoto => 'إضافة صورة';

  @override
  String get a11yCamera => 'الكاميرا';

  @override
  String get a11yMicrophone => 'إدخال صوتي';

  @override
  String get a11yPlay => 'تشغيل';

  @override
  String get a11yPause => 'إيقاف مؤقت';

  @override
  String get a11yNext => 'التالي';

  @override
  String get a11yPrevious => 'السابق';

  @override
  String get a11yExpand => 'توسيع';

  @override
  String get a11yCollapse => 'طي';

  @override
  String get a11yShow => 'إظهار';

  @override
  String get a11yHide => 'إخفاء';

  @override
  String get a11ySettings => 'الإعدادات';

  @override
  String get a11yProfile => 'الملف الشخصي';

  @override
  String get a11yNotifications => 'الإشعارات';

  @override
  String get a11yHelp => 'مساعدة';

  @override
  String get a11yInfo => 'التفاصيل';

  @override
  String get a11yFavorite => 'المفضلة';

  @override
  String get a11yPin => 'تثبيت';

  @override
  String get a11yUnpin => 'إلغاء التثبيت';

  @override
  String get a11yMute => 'كتم';

  @override
  String get a11yUnmute => 'إلغاء الكتم';

  @override
  String get a11yMarkRead => 'وضع علامة كمقروء';

  @override
  String get a11yNewChat => 'محادثة جديدة';

  @override
  String get a11yNewMessage => 'رسالة جديدة';

  @override
  String get a11yEmoji => 'رمز تعبيري';

  @override
  String get a11ySelectDate => 'اختيار التاريخ';

  @override
  String get a11yLogout => 'تسجيل الخروج';

  @override
  String get a11yAddAccount => 'إضافة حساب';

  @override
  String get a11yShowPassword => 'إظهار كلمة المرور';

  @override
  String get a11yHidePassword => 'إخفاء كلمة المرور';

  @override
  String get a11yScrollToBottom => 'التمرير إلى الأسفل';

  @override
  String get a11yOpen => 'فتح';

  @override
  String get errStateOfflineTitle => 'أنت غير متصل بالإنترنت';

  @override
  String get errStateOfflineBody =>
      'يتعذّر الوصول إلى ClassMate حاليًا. تحقق من شبكة Wi-Fi أو بيانات الهاتف، ثم حاول مرة أخرى.';

  @override
  String get errStateServerTitle => 'حدث خلل من جهتنا';

  @override
  String get errStateServerBody =>
      'واجهت خوادمنا مشكلة. الخطأ ليس منك — يرجى المحاولة مرة أخرى بعد لحظات.';

  @override
  String get errStateNotFoundTitle => 'لم نتمكن من العثور على ذلك';

  @override
  String get errStateNotFoundBody => 'ربما تم نقل هذا العنصر أو حذفه.';

  @override
  String get errStateForbiddenTitle => 'ليس لديك صلاحية الوصول';

  @override
  String get errStateForbiddenBody =>
      'هذا القسم مقفل لحسابك. إن بدا لك ذلك خطأً، تواصل مع مسؤول مدرستك.';

  @override
  String get errStateTimeoutTitle => 'استغرق ذلك وقتًا طويلًا';

  @override
  String get errStateTimeoutBody =>
      'انتهت مهلة الطلب أو أن الخادم مشغول. انتظر قليلًا ثم أعد المحاولة.';

  @override
  String get errStateEmptyTitle => 'لا يوجد شيء هنا بعد';

  @override
  String get errStateEmptyBody => 'عندما يتوفر شيء لعرضه، سيظهر هنا مباشرة.';

  @override
  String get errStateGenericTitle => 'حدث خطأ ما';

  @override
  String get errStateGenericBody =>
      'واجهنا خللًا غير متوقع. حاول مرة أخرى — غالبًا ما ينجح الأمر في المحاولة الثانية.';

  @override
  String get updatePromptTitle => 'يتوفر تحديث';

  @override
  String get updatePromptBody =>
      'إصدار جديد من ClassMate جاهز. حدِّث الآن للحصول على أحدث الميزات والإصلاحات.';

  @override
  String get updatePromptUpdate => 'تحديث';

  @override
  String get updatePromptLater => 'ليس الآن';

  @override
  String get chatPublishAssignment => 'واجب جديد';

  @override
  String get chatPublishMaterial => 'مادة تعليمية جديدة';

  @override
  String get chatPublishMeeting => 'اجتماع جديد';

  @override
  String get chatPublishView => 'عرض';

  @override
  String get settingsAppFont => 'خط التطبيق';

  @override
  String get settingsAppFontSubtitle =>
      'اختر نوع الخط المستخدم في جميع أنحاء التطبيق';

  @override
  String get settingsAppFontDefault => 'افتراضي';

  @override
  String get settingsAppFontSpecimen => 'نص تجريبي لمعاينة شكل الخط في التطبيق';

  @override
  String get onbWhatsInside => 'ما يمكنك فعله';

  @override
  String onbStepOf(int current, int total) {
    return '$current من $total';
  }

  @override
  String get onbBack => 'رجوع';

  @override
  String get onbSwipeHint => 'اسحب للاستكشاف';

  @override
  String get onbDeepWelcome =>
      'جدولك ودرجاتك وواجباتك ورسائلك ودفاترك كلها هنا — تسجيل دخول واحد للمدرسة. هذه نظرة سريعة على ما بالداخل.';

  @override
  String get onbDeepNova =>
      'اسأل NOVA أي شيء بكلماتك واحصل على شرح خطوة بخطوة. حوّل أي موضوع إلى أسئلة تدريب، واحفظ ما تريد مراجعته، وصوّر سؤالًا تعطلت فيه ليُحلّ معك.';

  @override
  String get onbDeepTrack =>
      'شاهد دروس اليوم بمجرد فتح التطبيق، وتحقق من الدرجة عند نشرها، وتابع حضورك، واحتفظ بكل مواعيد التسليم في قائمة واحدة — مع تذكير قبل الموعد.';

  @override
  String get onbDeepClassNotes =>
      'اكتب ملاحظاتك بخط اليد بقلم Apple Pencil على الآيباد — أغلفة وأنماط ورق وأشرطة وصور وملاحظات صوتية — ثم اقرأها هنا وكبّر الخط وشغّل التسجيلات وافتح مرفقاتك.';

  @override
  String get onbDeepConnect =>
      'راسل معلمًا أو زميلًا مباشرة، وتابع إعلانات الصف، وانضم إلى اجتماع عبر الإنترنت من بطاقته، واستخدم بريد CMail المدرسي — دون مغادرة التطبيق.';

  @override
  String get onbDeepTeacherClasses =>
      'افتح الصف لترى من فيه، وسجّل الحضور بلمستين، ووزّع الواجبات والمواد، واحتفظ بقوائم كل مجموعة منظمة.';

  @override
  String get onbDeepTeacherGrading =>
      'أدخل الدرجات وفق مقياسك، وانشرها عندما تكون مستعدًا، ودع التحليلات تُظهر من يتراجع قبل أن تصبح مشكلة.';

  @override
  String get onbDeepTeacherComms =>
      'انشر إعلانًا لمجموعة كاملة، وراسل وليّ أمر أو طالبًا مباشرة، وحدّد موعد اجتماع، واجمع الردود عبر نموذج.';

  @override
  String get onbDeepAdminOps =>
      'أدر المدرسة من لوحة واحدة: ابنِ الجدول، وحدّد مقاييس الدرجات، وراجع التقارير، وصدّر ما تحتاجه من بيانات.';

  @override
  String get onbDeepAdminPeople =>
      'أضف الطلاب والمعلمين وأولياء الأمور، ووزّعهم على المجموعات، واربط وليّ أمر بطفله، وأصدر الشهادات عند انتهاء العام.';

  @override
  String get onbDeepSecretary =>
      'أدر اليوم الدراسي: عدّل الجدول، وأضف أو حدّث سجل شخص، وأصدر الشهادات، وانشر إعلانًا بسرعة.';

  @override
  String get onbDeepParentChild =>
      'تنقّل بين أبنائك وشاهد لكل واحد جدوله ودرجاته وحضوره وواجباته — الصورة نفسها التي تراها المدرسة.';

  @override
  String get onbDeepParentAlerts =>
      'تُبلَّغ عند نشر درجة أو تسجيل غياب أو نشر المدرسة لإعلان — وتردّ على المعلم من المكان نفسه.';

  @override
  String get settingsAddTheme => 'إضافة سمة';

  @override
  String get settingsNewTheme => 'سمة جديدة';

  @override
  String get settingsThemeNameHint => 'السمة الخاصة بي';

  @override
  String get settingsThemeAccentLabel => 'اللون المميّز';

  @override
  String get settingsCreateTheme => 'إنشاء السمة';

  @override
  String get cnMoveToShelf => 'نقل إلى رف';

  @override
  String get cnNotOnShelf => 'ليست على رف';

  @override
  String get cnDownloadAsPdf => 'تنزيل كملف PDF';

  @override
  String get cnOpenPagesPng => 'فتح الصفحات كـ PNG';

  @override
  String get cnDownloadPagesPng => 'تنزيل الصفحات كـ PNG';

  @override
  String get cnDeleteNotebookSubtitle => 'يزيلها من ClassNotes على كل أجهزتك';

  @override
  String get cnRenameNotebook => 'إعادة تسمية الدفتر';

  @override
  String get cnNotebookTitleHint => 'عنوان الدفتر';

  @override
  String get cnRenamed => 'تمت إعادة التسمية';

  @override
  String get cnTakenOffShelf => 'أُزيلت من الرف';

  @override
  String get cnMoved => 'تم النقل';

  @override
  String get cnBuildingPdf => 'جارٍ إنشاء ملف PDF…';

  @override
  String get cnPreparingPages => 'جارٍ تجهيز الصفحات…';

  @override
  String get cnNoSyncedPages =>
      'لا توجد صفحات متزامنة لهذا الدفتر بعد — افتحه على جهاز iPad مرة واحدة.';

  @override
  String cnExportFailed(String error) {
    return 'فشل التصدير: $error';
  }

  @override
  String get cnDeleteNotebookTitle => 'حذف هذا الدفتر؟';

  @override
  String cnDeleteNotebookBody(String title, num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString صفحة',
    );
    return 'سيُحذف «$title» و$_temp0 من ClassNotes على كل جهاز. لا يمكن التراجع عن ذلك.';
  }

  @override
  String get cnDeleted => 'تم الحذف';

  @override
  String get cnRenameShelf => 'إعادة تسمية الرف';

  @override
  String get cnShelfNameHint => 'اسم الرف';

  @override
  String get cnDeleteShelf => 'حذف الرف';

  @override
  String get cnDeleteShelfSubtitle => 'تبقى الدفاتر — إنها فقط تغادر الرف';

  @override
  String get cnShelfDeleted => 'تم حذف الرف';

  @override
  String cnReorderFailed(String error) {
    return 'تعذّر حفظ الترتيب الجديد: $error';
  }

  @override
  String cnGenericError(String error) {
    return 'لم ينجح ذلك: $error';
  }

  @override
  String get cnAllShelf => 'الكل';

  @override
  String get cnDragToReorder => 'اسحب لإعادة ترتيب دفاترك';

  @override
  String get cnManageHint => 'اضغط ⋮ على دفتر لإعادة تسميته أو تنزيله أو حذفه';

  @override
  String get cnArrange => 'ترتيب';

  @override
  String get cnManage => 'إدارة';

  @override
  String cnManageNamed(String title) {
    return 'إدارة $title';
  }

  @override
  String get cnNotebookWord => 'دفتر';

  @override
  String cnPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count صفحة',
      one: 'صفحة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get cnEmptyTitle => 'لا توجد دفاتر بعد';

  @override
  String get cnEmptyBody =>
      'تظهر دفاتر ClassNotes الخاصة بك هنا — الأغلفة والورق والحبر تتبع مظهرك.';

  @override
  String get cnLoading => 'جارٍ تحميل دفاترك…';

  @override
  String get cnSignedOutTitle => 'سجّل الدخول لرؤية دفاترك';

  @override
  String get cnSignedOutBody =>
      'مكتبة ClassNotes مرتبطة بحساب ClassMate الخاص بك.';

  @override
  String get cnErrorTitle => 'تعذّر تحميل دفاترك';

  @override
  String get cnErrorBody => 'تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String teacherFormsCount(num count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString نموذج',
    );
    return '$_temp0';
  }
}

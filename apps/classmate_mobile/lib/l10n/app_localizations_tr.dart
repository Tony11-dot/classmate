// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get menu => 'Menü';

  @override
  String get sectionCore => 'Ana Özellikler';

  @override
  String get sectionSchoolTools => 'Okul Araçları';

  @override
  String get sectionAccount => 'Hesap';

  @override
  String get navSchedule => 'Program';

  @override
  String get navClassrooms => 'Sınıflar';

  @override
  String get navPractice => 'Pratik';

  @override
  String get navInsights => 'Analitik';

  @override
  String get navNova => 'NOVA';

  @override
  String get navMessages => 'Mesajlar';

  @override
  String get navAttendance => 'Devam';

  @override
  String get navGrades => 'Notlar';

  @override
  String get navAssignments => 'Ödevler';

  @override
  String get navMeetings => 'Toplantılar';

  @override
  String get navAnnouncements => 'Duyurular';

  @override
  String get navNotifications => 'Bildirimler';

  @override
  String get navSolutions => 'Çözümler';

  @override
  String get navExams => 'Sınavlar';

  @override
  String get navForms => 'Formlar';

  @override
  String get navHome => 'Ana sayfa';

  @override
  String get navTeacherWorkspace => 'Öğretmen Alanı';

  @override
  String get navTeacherAssessments => 'Değerlendirmeler ve Notlar';

  @override
  String get navSavedQuestions => 'Kaydedilen Sorular';

  @override
  String get navProfile => 'Profil';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get navLogout => 'Çıkış yap';

  @override
  String get roleTeacher => 'Öğretmen';

  @override
  String get roleAdmin => 'Yönetici';

  @override
  String get roleSecretary => 'Sekreter';

  @override
  String get roleParent => 'Veli';

  @override
  String get titleSchedule => 'Program';

  @override
  String get titleClasses => 'Sınıflar';

  @override
  String get titlePractice => 'Pratik';

  @override
  String get titleInsights => 'Analitik';

  @override
  String get titleNova => 'NOVA';

  @override
  String get titleMessages => 'Mesajlar';

  @override
  String get titleSolutions => 'Çözümler';

  @override
  String get titleExams => 'Sınavlar';

  @override
  String get solutionsUploadAction => 'Yükle';

  @override
  String get solutionsNoSubjectsAvailable => 'Hiçbir konu mevcut değil.';

  @override
  String solutionsNoSubjectsMatch(Object query) {
    return 'Hiçbir konu \"$query\" ile eşleşmiyor.';
  }

  @override
  String solutionsBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kitap',
      one: '1 kitap',
    );
    return '$_temp0';
  }

  @override
  String get solutionsBooksTitle => 'Kitaplar';

  @override
  String get solutionsAddBookTitle => 'Kitap ekle';

  @override
  String get solutionsBookTitleHint => 'Kitap başlığı...';

  @override
  String get solutionsAddBookAction => 'Kitap ekle';

  @override
  String get solutionsSearchBooks => 'Kitapları ara';

  @override
  String get solutionsChooseSubjectFirst => 'Önce bir konu seçin.';

  @override
  String solutionsNoBooksYetBody(Object action) {
    return 'Henüz kitap yok.\n\"$action\" öğesine dokunarak ilkini ekleyin.';
  }

  @override
  String solutionsNoBooksMatch(Object query) {
    return 'Hiçbir kitap \"$query\" ile eşleşmiyor.';
  }

  @override
  String get solutionsBookLabel => 'Kitap';

  @override
  String get solutionsPagesFilterHint =>
      'Filtrelemek için bir sayfa ve soru numarası girin veya tümünü görmek için boş bırakın.';

  @override
  String get solutionsPageNumberLabel => 'Sayfa numarası';

  @override
  String get solutionsPageNumberHint => 'örn. 42';

  @override
  String get solutionsQuestionNumberLabel => 'Soru numarası';

  @override
  String get solutionsQuestionNumberHint => 'örn. 3a veya 7';

  @override
  String get solutionsViewSolutionsAction => 'Çözümleri görüntüle';

  @override
  String solutionsPageQuestionSummary(Object page, Object question) {
    return 'Sayfa $page • Soru $question';
  }

  @override
  String get solutionsExactQuestionTitle => 'Bu tam soru için çözümler';

  @override
  String get solutionsExactQuestionEmptySubtitle =>
      'Bu tam soru için henüz hiçbir şey yüklenmedi. Sınıf arkadaşlarınıza ilk yardımcı olun.';

  @override
  String solutionsUploadsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yükleme bulundu',
      one: '1 yükleme bulundu',
    );
    return '$_temp0';
  }

  @override
  String get solutionsExactQuestionEmptyBody =>
      'Henüz tam bir eşleşme yok. Şimdi bir tane yükleyebilir veya sınıf arkadaşlarınızın bu aynı sayfada neler çözdüğünü kontrol edebilirsiniz.';

  @override
  String get solutionsLoadMoreAction => 'Daha fazla yükle';

  @override
  String get solutionsSamePageTitle => 'Bu sayfada çözülen diğer sorular';

  @override
  String get solutionsSamePageEmptySubtitle =>
      'Bu sayfadan henüz komşu sorular yüklenmedi.';

  @override
  String get solutionsSamePageFallbackSubtitle =>
      'Tam sorunuzun henüz yüklemesi olmadığında yararlı bir geri dönüş.';

  @override
  String get solutionsSamePageEmptyBody =>
      'Bu sayfada henüz yakın yüklemeler yok. Burada yeni bir yükleme gerçekten yararlı olacaktır.';

  @override
  String get solutionsVerifiedByNova => 'NOVA tarafından doğrulanmış';

  @override
  String get solutionsUploadFileLimitReached => '10 dosya sınırı ulaşıldı.';

  @override
  String solutionsUploadFilesAddedLimit(int count) {
    return '$count eklendi — 10 dosya sınırı.';
  }

  @override
  String get solutionsUploadCompleteFields =>
      'Konu, kitap, sayfa ve soruyu tamamlayın.';

  @override
  String get solutionsUploadAddOneFile => 'En az bir resim veya PDF ekleyin.';

  @override
  String solutionsUploadFileFailed(Object error) {
    return 'Dosya yüklemesi başarısız: $error';
  }

  @override
  String solutionsUploadCreateFailed(Object error) {
    return 'Çözüm oluşturma başarısız: $error';
  }

  @override
  String get solutionsUploadSuccess => 'Çözüm yüklendi!';

  @override
  String get solutionsUploadAddNewBookOption => '+ Yeni kitap ekle...';

  @override
  String get solutionsUploadAddBookShortAction => 'Ekle';

  @override
  String get solutionsUploadTitle => 'Çözüm yükle';

  @override
  String get solutionsUploadSubtitle =>
      'Yalnızca gerçek resimler veya PDF\'ler. NOVA doğrulaması ve yönetim yüklemeden sonra uygulanır.';

  @override
  String get solutionsUploadNoBooksAbove =>
      'Kitap yok — yukarıda birini ekleyin';

  @override
  String get solutionsUploadCaptionOptional => 'Başlık (isteğe bağlı)';

  @override
  String get solutionsUploadImagesAction => 'Resimler';

  @override
  String get solutionsUploadPdfAction => 'PDF';

  @override
  String solutionsUploadFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dosya seçildi',
      one: 'dosya seçildi',
    );
    return '$count / 10 $_temp0';
  }

  @override
  String get solutionsUploadSomeFilesFailed => 'Bazı dosyalar yüklenemedi.';

  @override
  String get solutionsUploadRetryFailedFiles =>
      'Başarısız dosyaları yeniden deneyin';

  @override
  String get solutionsUploadSubmittingAction => 'Yükleniyor...';

  @override
  String get solutionsUploadSubmitAction => 'Çözüm yükle';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsSubtitle => 'Görünüm, dil ve hesap';

  @override
  String get settingsAppearance => 'Görünüm';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLanguageSystem => 'Sistem varsayılanı';

  @override
  String get settingsAccentColour => 'Vurgu rengi';

  @override
  String get settingsAccentSubtitle => 'Uygulamada kullanılan renk tonu';

  @override
  String get settingsReduceMotion => 'Hareketi azalt';

  @override
  String get settingsReduceMotionSubtitle => 'Daha az animasyon';

  @override
  String get settingsAccount => 'Hesap';

  @override
  String get settingsLogout => 'Çıkış yap';

  @override
  String get settingsLogoutSubtitle => 'Bu cihazdan çıkış yap';

  @override
  String get settingsThemeSystem => 'Sistem varsayılanı';

  @override
  String get settingsThemeLight => 'Açık';

  @override
  String get settingsThemeDark => 'Koyu';

  @override
  String get settingsLanguageSearchHint => 'Dil ara...';

  @override
  String get teacherWorkspaceSubtitle =>
      'Devam, yoklama ve notlandırmayı mobil uygulamadan yönetin.';

  @override
  String get teacherMetricSessionsToday => 'Bugünkü dersler';

  @override
  String get teacherMetricTeachingGroups => 'Öğretim grupları';

  @override
  String get teacherMetricAssessments => 'Değerlendirmeler';

  @override
  String get teacherQuickActions => 'Hızlı işlemler';

  @override
  String get teacherNoDateAvailable => 'Tarih yok';

  @override
  String get teacherNoTeachingSlotsToday => 'Bugün planlanmış ders yok.';

  @override
  String get teacherUpcomingAssessments => 'Yaklaşan değerlendirmeler';

  @override
  String get teacherUpcomingAssessmentsSubtitle =>
      'Öğretmen notlandırma sisteminden canlı';

  @override
  String get teacherNoAssessmentsYet => 'Henüz değerlendirme oluşturulmadı.';

  @override
  String get teacherUnassignedSlot => 'Atanmamış ders';

  @override
  String get teacherNoCohort => 'Grup yok';

  @override
  String get teacherCourseFallback => 'Ders';

  @override
  String teacherPeriod(Object number) {
    return 'Ders $number';
  }

  @override
  String get teacherLoadErrorTitle => 'Öğretmen alanı yüklenemedi';

  @override
  String get teacherClassroomsLoadError =>
      'Şu anda sınıfları yükleyemedik. Yenilemek için aşağı doğru çekin veya yeniden deneyin.';

  @override
  String get teacherClassroomsLoadTimeout =>
      'Sınıfların yüklenmesi çok uzun sürüyor. Yenilemek için aşağı doğru çekin veya biraz sonra yeniden deneyin.';

  @override
  String get teacherClassroomsLoadNetwork =>
      'Sınıflar şu anda bağlanamamış. Bağlantınızı kontrol edin ve yeniden deneyin.';

  @override
  String get teacherClassroomsSubtitle =>
      'Kayıt listesini açın ve öğrenci girişi için canlı bir katılım kodu oluşturun.';

  @override
  String get teacherClassroomsNoCohorts =>
      'Bu öğretmene henüz bağlı sınıf kohortları yok.';

  @override
  String teacherClassroomsCohort(Object cohortId) {
    return 'Kohort $cohortId';
  }

  @override
  String get teacherClassroomsGeneratingJoinCode => 'Oluşturuluyor…';

  @override
  String get teacherClassroomsCreateJoinCode => 'Katılım kodu oluştur';

  @override
  String get teacherClassroomsLiveJoinCode => 'Canlı katılım kodu';

  @override
  String teacherClassroomsExpiresAt(Object value) {
    return '$value tarihinde sona eriyor';
  }

  @override
  String get teacherClassroomsRoster => 'Kayıt listesi';

  @override
  String get teacherClassroomsNoStudents =>
      'Bu sınıfa henüz hiç öğrenci kayıtlı değildir.';

  @override
  String get teacherAttendanceLoadError =>
      'Şu anda yoklama yüklenemedi. Yenilemek için çekin veya tekrar deneyin.';

  @override
  String get teacherAttendanceLoadTimeout =>
      'Yoklama yüklenmesi çok uzun sürüyor. Yenilemek için çekin veya bir süre sonra tekrar deneyin.';

  @override
  String get teacherAttendanceLoadNetwork =>
      'Yoklama şu anda bağlanamadı. Bağlantınızı kontrol edin ve tekrar deneyin.';

  @override
  String get teacherAttendanceSubtitle =>
      'Canlı bir oturumu seçin, odayı işaretleyin ve yalnızca değişen satırları kaydedin.';

  @override
  String get teacherAttendanceTodaySessions => 'Bugünün oturumları';

  @override
  String teacherAttendanceSessionSummary(
    Object cohort,
    Object grade,
    Object date,
    Object period,
  ) {
    return '$cohort • Sınıf $grade • $date • Ders $period';
  }

  @override
  String get teacherAttendanceChanged => 'Değiştirildi';

  @override
  String get teacherAttendanceNoteLabel => 'Not';

  @override
  String get teacherAttendanceSaving => 'Kaydediliyor…';

  @override
  String teacherAttendanceSaveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count değişiklik',
      one: '1 değişiklik',
    );
    return 'Kaydet $_temp0';
  }

  @override
  String get teacherAttendanceSaved => 'Yoklama kaydedildi';

  @override
  String get retry => 'Yeniden dene';

  @override
  String get scheduleRefreshTooFast =>
      'Program şu anda çok hızlı yenileniyor. Biraz bekleyip tekrar deneyin.';

  @override
  String get scheduleNotOnboarded =>
      'Öğrenci profilin henüz tamamen kurulmamış, bu yüzden henüz bir program görünmüyor.';

  @override
  String get scheduleLoadError => 'Program henüz yüklenemedi.';

  @override
  String get scheduleSelectedDay => 'Seçili gün';

  @override
  String scheduleClassCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ders',
      one: '1 ders',
      zero: '0 ders',
    );
    return '$_temp0';
  }

  @override
  String get scheduleNextUp => 'Sıradaki';

  @override
  String get scheduleNoMoreClasses => 'Başka ders yok';

  @override
  String get scheduleNoClassesTitle => 'Bu günde ders yok';

  @override
  String scheduleNoClassesSubtitle(Object day) {
    return '$day boş görünüyor.';
  }

  @override
  String get scheduleClassFallback => 'Ders';

  @override
  String get scheduleNoSubjectLocation => 'Henüz ders veya konum yok';

  @override
  String get loginTitle => 'Öğrenciler ve öğretmenler için mobil giriş';

  @override
  String get loginSubtitle =>
      'Öğretmen hesapları öğretmen alanını açar. Öğrenci hesapları öğrenci deneyiminde kalır.';

  @override
  String get loginSignIn => 'Giriş yap';

  @override
  String get loginSigningIn => 'Giriş yapılıyor...';

  @override
  String get loginEmailLabel => 'E-posta';

  @override
  String get loginPasswordLabel => 'Şifre';

  @override
  String get profileNotAvailable => 'Mevcut değil';

  @override
  String get profileSchoolInfo => 'Okul bilgileri';

  @override
  String get profileFullName => 'Tam ad';

  @override
  String get profileRole => 'Rol';

  @override
  String get profileSchoolId => 'Okul kimliği';

  @override
  String get profileCohortId => 'Grup kimliği';

  @override
  String get profileAccountInfo => 'Hesap bilgileri';

  @override
  String get profileUsername => 'Kullanıcı adı';

  @override
  String get profileUsernameHint => 'your_username';

  @override
  String get profileContactEmail => 'İletişim e-postası';

  @override
  String get profileEmailAddress => 'E-posta adresi';

  @override
  String get profileEmailHint => 'you@example.com';

  @override
  String get profileBirthday => 'Doğum günü';

  @override
  String get profileSecurity => 'Güvenlik';

  @override
  String get profileSelectBirthday => 'Doğum gününüzü seçin';

  @override
  String get profilePasswordUpdated => 'Şifre güncellendi';

  @override
  String get profileSave => 'Kaydet';

  @override
  String get profileEmptyValue => '—';

  @override
  String get profileChangePassword => 'Şifreyi değiştir';

  @override
  String get profileCurrentPassword => 'Mevcut şifre';

  @override
  String get profileNewPassword => 'Yeni şifre';

  @override
  String get profileConfirmNewPassword => 'Yeni şifreyi onayla';

  @override
  String get profileUpdatePassword => 'Şifreyi güncelle';

  @override
  String get profilePasswordAllFieldsRequired => 'Tüm alanlar zorunludur';

  @override
  String get profilePasswordMinLength =>
      'Yeni şifre en az 8 karakter olmalıdır';

  @override
  String get profilePasswordMismatch => 'Şifreler eşleşmiyor';

  @override
  String get profilePasswordNotAuthenticated => 'Kimlik doğrulanmadı';

  @override
  String get profilePasswordIncorrect => 'Mevcut şifre yanlış';

  @override
  String get profilePasswordGenericError =>
      'Bir şeyler yanlış gitti. Lütfen tekrar deneyin.';

  @override
  String get editProfileTitle => 'Profili düzenle';

  @override
  String get editProfileSchool => 'Okul';

  @override
  String get editProfileSchoolPublic => 'Okul herkese açık';

  @override
  String get editProfileGradePublic => 'Sınıf herkese açık';

  @override
  String get editProfileMajors => 'Bölümler';

  @override
  String get editProfileMajorsPublic => 'Bölümler herkese açık';

  @override
  String get editProfileBio => 'Biyografi';

  @override
  String get editProfileBioPublic => 'Biyografi herkese açık';

  @override
  String get editProfileStatus => 'Durum';

  @override
  String get editProfileStatusPublic => 'Durum herkese açık';

  @override
  String get classroomsYourClassrooms => 'Sınıfların';

  @override
  String get classroomsReorder => 'Sınıfları yeniden sırala';

  @override
  String classroomsCount(Object count) {
    return '$count sınıf';
  }

  @override
  String get classroomsSearchHint => 'Sınıflarda ara';

  @override
  String get classroomsNoSearchMatches => 'Aramana uyan sınıf yok';

  @override
  String get classroomsClassroomLabel => 'Sınıf';

  @override
  String get classroomsLoadingLatestMessage => 'Son mesaj yükleniyor...';

  @override
  String get classroomsTapToOpen => 'Sınıfı açmak için dokun';

  @override
  String get classroomsNoMessagesYet => 'Henüz mesaj yok';

  @override
  String get classroomsMessageFallback => 'Mesaj';

  @override
  String get examsLoadError => 'Sınavlar veya formlar yüklenemedi';

  @override
  String get examsAllFilter => 'Tümü';

  @override
  String get examsFormsSubtitle =>
      'Okulunuzun yayımladığı sınıf formlarını, yanıt pencerelerini ve takipleri inceleyin.';

  @override
  String get examsOnlySubtitle =>
      'Sınıflarınızdaki yaklaşan değerlendirmeleri, geri sayımları ve geçmiş sınav kayıtlarını takip edin.';

  @override
  String get examsUpcomingStat => 'Yaklaşan sınavlar';

  @override
  String get examsOpenFormsStat => 'Açık formlar';

  @override
  String get examsCountdownPast => 'Geçti';

  @override
  String get examsCountdownTomorrow => 'Yarın';

  @override
  String examsCountdownInDays(Object days) {
    return '$days gün içinde';
  }

  @override
  String get examsNoExamsPublished => 'Henüz sınav yayımlanmadı.';

  @override
  String get examsNoFormsPublished => 'Henüz form yayımlanmadı.';

  @override
  String examsNoExamsForFilter(Object subject) {
    return 'Şu anda $subject için sınav yok.';
  }

  @override
  String examsNoFormsForFilter(Object subject) {
    return 'Şu anda $subject için form yok.';
  }

  @override
  String examsMaterialsCount(Object count) {
    return '$count materyal';
  }

  @override
  String get examsOpenState => 'Açık';

  @override
  String get examsClosedState => 'Kapalı';

  @override
  String examsQuestionsCount(Object count) {
    return '$count soru';
  }

  @override
  String examsResponsesCount(Object count) {
    return '$count yanıt';
  }

  @override
  String get insightsTrendBaseline => 'Başlangıç';

  @override
  String get insightsTrendImproving => 'İyileşiyor';

  @override
  String get insightsTrendDropping => 'Düşüyor';

  @override
  String get insightsTrendStable => 'Dengeli';

  @override
  String get insightsHeadlineIntervention => 'Müdahale penceresi açık';

  @override
  String get insightsHeadlineSignals => 'Birden fazla sinyal sıkılaştırılmalı';

  @override
  String get insightsHeadlineMomentum => 'Momentum bu hafta büyüyebilir';

  @override
  String get insightsBodyAttendance =>
      'Önce devamı koruyun. Şimdi daha iyi katılım, diğer tüm sinyalleri daha hızlı yükseltir.';

  @override
  String insightsBodyWeakTrend(Object subject) {
    return '$subject ile düşen bir pratik eğilimi şu anda en büyük risk birleşimi. Genişlemeden önce bunu düzeltin.';
  }

  @override
  String insightsBodyLeverage(Object subject) {
    return '$subject sizin kaldıraç noktanız. Daha zayıf alanları güçlendirirken bunu güven oluşturmak için kullanın.';
  }

  @override
  String get insightsBodyConsistency =>
      'Kısa ve odaklı oturumlar eklemeye devam edin. Önümüzdeki birkaç gün, kusursuz uzun vadeli bir plandan daha önemli.';

  @override
  String get insightsInterventionScoreTitle => 'Müdahale puanı';

  @override
  String insightsInterventionScoreBody(Object count) {
    return '$count aktif sinyal bir sonraki adımınızı şekillendiriyor.';
  }

  @override
  String get insightsRecoveryPathTitle => 'En hızlı toparlanma yolu';

  @override
  String get insightsRecoveryPathDefault => 'Önce devam + tutarlılık.';

  @override
  String insightsRecoveryPathTopic(Object topic, Object subject) {
    return 'Daha fazla zorlamadan önce $subject içinde $topic konusuna geri dönün.';
  }

  @override
  String get insightsProjectedDirectionTitle => 'Beklenen yön';

  @override
  String insightsProjectedDirectionBody(Object trend) {
    return 'Son 7 gün ile 30 gün pratik davranışına göre $trend.';
  }

  @override
  String get insightsLoadingTitle => 'Analizler yükleniyor';

  @override
  String get insightsLoadingSubtitle =>
      'Tahmine dayalı paneliniz hazırlanıyor.';

  @override
  String get insightsNotReadyTitle => 'Analizler henüz hazır değil';

  @override
  String get insightsEmptyTitle => 'Henüz analiz yok';

  @override
  String get insightsEmptySubtitle =>
      'ClassMate\'in daha net bir akademik tablo kurabilmesi için pratik ve okul araçlarını kullanmaya devam edin.';

  @override
  String get insightsGradeAverage => 'Not ort.';

  @override
  String get insightsAccuracy => 'Doğruluk';

  @override
  String get insightsOpenNova => 'NOVA\'yı aç';

  @override
  String get insightsOpenNovaPrompt =>
      'En son ClassMate analizlerime göre en zayıf alanımı düzeltmeme yardım et.';

  @override
  String get insightsPredictiveRecoveryPlanTitle => 'Öngörülü toparlanma planı';

  @override
  String get insightsPracticeNow => 'Şimdi pratik yap';

  @override
  String get insightsPredictiveModulesTitle => 'Öngörü modülleri';

  @override
  String get insightsPredictiveModulesSubtitle =>
      'Mevcut öğrenci verilerinizden gelen en güçlü ileriye dönük sinyaller.';

  @override
  String get insightsAnnouncementsPressureTitle => 'Duyuru baskısı';

  @override
  String get insightsAnnouncementsPressureSubtitle =>
      'Duyuru motoru artık paneli doğrudan besliyor.';

  @override
  String get insightsAiCoachTitle => 'Yapay zeka koç özeti';

  @override
  String get insightsAiCoachLoadingSubtitle => 'Yapay zeka rehberi yükleniyor.';

  @override
  String get insightsAiCoachUnavailableSubtitle =>
      'Yapay zeka rehberi şu anda bu hesap için kullanılamıyor.';

  @override
  String get insightsAskNova => 'NOVA\'ya sor';

  @override
  String get insightsAskNovaPrompt =>
      'En son analizlerime göre bana bir toparlanma planı hazırla.';

  @override
  String get insightsAiStudyCoachTitle => 'Yapay zeka çalışma koçu';

  @override
  String get insightsSchoolToolsTitle => 'Okul araçları';

  @override
  String get insightsSchoolToolsSubtitle =>
      'Şu anda en önemli öğrenci rotalarına doğrudan atlayın.';

  @override
  String get tutorUntitledChat => 'Adsız sohbet';

  @override
  String get tutorNewChat => 'Yeni sohbet';

  @override
  String tutorFailedToOpenSeededChat(Object error) {
    return 'Sohbet açılamadı: $error';
  }

  @override
  String tutorFailedToCreateChat(Object error) {
    return 'Sohbet oluşturulamadı: $error';
  }

  @override
  String get tutorRenameChatTitle => 'Sohbeti yeniden adlandır';

  @override
  String get tutorChatNameHint => 'Sohbet adı';

  @override
  String get tutorCancel => 'İptal';

  @override
  String get tutorHide => 'Gizle';

  @override
  String get tutorHideChatTitle => 'Sohbeti gizle';

  @override
  String get tutorHideChatSubtitle => 'Bu cihazda bu sohbeti gizler.';

  @override
  String get tutorHideChatConfirmTitle => 'Sohbet gizlensin mi?';

  @override
  String get tutorHideChatConfirmBody =>
      'Bu işlem sohbeti bu cihazdaki listeden gizler. Oturum arka uçta kalır.';

  @override
  String get tutorTapToOpenHistory => 'Geçmişi açmak için dokun';

  @override
  String get tutorAiTutorSubtitle => 'Yapay zeka öğretmenin';

  @override
  String get tutorHeroBody =>
      'Gerçek sohbet geçmişi, daha temiz diziler, daha hızlı erişim.';

  @override
  String get tutorStartFreshConversation => 'Yeni bir konuşma başlat';

  @override
  String get tutorSearchHistoryHint => 'Sohbet geçmişinde ara';

  @override
  String get chatComposerDefaultHint => 'Mesaj';

  @override
  String get chatComposerReplyingToMessage => 'Mesaja yanıt veriliyor';

  @override
  String get chatComposerReplyFallback => 'Yanıt';

  @override
  String get chatComposerMicHint =>
      'Hızlı sesli not için dokun ya da kaydetmek için basılı tut';

  @override
  String get chatComposerRecordingTitle => 'Kaydediliyor';

  @override
  String get chatComposerReleaseToSend => 'Göndermek için bırak';

  @override
  String get chatComposerCancelTitle => 'İptal';

  @override
  String get chatComposerLockTitle => 'Kilitle';

  @override
  String get chatComposerSlideLeftToCancel => 'İptal etmek için sola kaydır';

  @override
  String get chatComposerSlideUpToLock => 'Kilitlemek için yukarı kaydır';

  @override
  String get chatComposerReleaseToCancel => 'İptal etmek için bırak';

  @override
  String get chatComposerKeepSlidingToCancel =>
      'İptal etmek için kaydırmaya devam et';

  @override
  String get chatComposerReleaseToLock => 'Kilitlemek için bırak';

  @override
  String get chatComposerRelease => 'Bırak';

  @override
  String get chatComposerLock => 'Kilit';

  @override
  String get chatComposerRecordingPaused => 'Kayıt duraklatıldı';

  @override
  String get chatComposerRecordingLocked => 'Kayıt kilitlendi';

  @override
  String get chatComposerResumeHint =>
      'Kayda devam etmek için hazır olduğunda sürdür';

  @override
  String get chatComposerLockedHint =>
      'Paylaşmaya hazır olduğunda gönder\'e dokun';

  @override
  String get chatContextDismiss => 'Kapat';

  @override
  String get chatContextCopyText => 'Metni kopyala';

  @override
  String get chatContextDelete => 'Sil';

  @override
  String get chatMessageInfoShortTitle => 'Bilgi';

  @override
  String get chatMessageInfoStatus => 'Durum';

  @override
  String get chatMessageInfoStatusTime => 'Durum zamanı';

  @override
  String get chatMessageInfoSentAt => 'Gönderilme zamanı';

  @override
  String get chatMessageInfoDeliveredAt => 'Teslim edilme zamanı';

  @override
  String get chatMessageInfoSeenAt => 'Görülme zamanı';

  @override
  String get chatMessageInfoMessageType => 'Mesaj türü';

  @override
  String get chatMessageInfoTextType => 'Metin';

  @override
  String get chatMessageInfoEdited => 'Düzenlendi';

  @override
  String get chatMessageInfoForwarded => 'İletildi';

  @override
  String get chatMessageInfoVoiceDuration => 'Ses süresi';

  @override
  String get chatMessageInfoSeenBy => 'Görenler';

  @override
  String get chatMessageInfoDeliveredTo => 'Teslim edilenler';

  @override
  String get chatMessageInfoEmptyBody => '(boş)';

  @override
  String get chatMessageInfoReadLess => 'Daha az oku';

  @override
  String get chatMessageInfoReadMore => 'Daha fazla oku';

  @override
  String get chatMessageInfoSeen => 'Görüldü';

  @override
  String get chatMessageInfoDelivered => 'Teslim edildi';

  @override
  String get chatMessageInfoNotDelivered => 'Teslim edilmedi';

  @override
  String get chatMessageInfoSent => 'Gönderildi';

  @override
  String get chatMessageInfoPending => 'Bekliyor';

  @override
  String get chatMessageInfoNotSeen => 'Görülmedi';

  @override
  String get chatMessageInfoType => 'Tür';

  @override
  String get chatMessageInfoDuration => 'Süre';

  @override
  String get chatMessageInfoYes => 'Evet';

  @override
  String get chatMessageInfoNo => 'Hayır';

  @override
  String get chatMessageInfoDeleteState => 'Silinme durumu';

  @override
  String get chatReactionDetailsTitle => 'Tepkiler';

  @override
  String get chatReactionAddAction => 'Tepki ekle';

  @override
  String get chatReactionEmptyState => 'Henüz tepki yok';

  @override
  String get chatReactionSingle => 'Tepki';

  @override
  String get chatReactionTapToRemove => 'Kaldırmak için dokun';

  @override
  String chatReactionYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' · $count',
      one: '',
    );
    return 'Sen$_temp0';
  }

  @override
  String chatReactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tepki',
      one: 'Tepki',
    );
    return '$_temp0';
  }

  @override
  String get chatEmojiPickerTitle => 'Emoji seç';

  @override
  String get chatEmojiPickerSearchHint => 'Emoji ara';

  @override
  String get chatEmojiPickerEmptyState => 'Emoji bulunamadı';

  @override
  String get chatCameraTitle => 'Kamera';

  @override
  String get chatCameraUseAction => 'Kullan';

  @override
  String get chatCameraGalleryAction => 'Galeri';

  @override
  String chatCameraSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seçildi',
      one: '1 seçildi',
      zero: '0 seçildi',
    );
    return '$_temp0';
  }

  @override
  String get chatMediaPreviewEmptyState => 'Önizlenecek bir şey yok';

  @override
  String get chatMediaPreviewDrawCropAction => 'Çiz ve kırp';

  @override
  String get chatMediaPreviewRotateLeftAction => 'Sola döndür';

  @override
  String get chatMediaPreviewRotateRightAction => 'Sağa döndür';

  @override
  String get chatMediaPreviewMirrorAction => 'Aynala';

  @override
  String get chatMediaPreviewResetAction => 'Sıfırla';

  @override
  String get chatMediaPreviewRemoveAction => 'Kaldır';

  @override
  String get chatMediaPreviewCaptionHint => 'Açıklama ekle...';

  @override
  String tutorPlanSelectedPlaceholder(Object plan) {
    return '$plan seçildi. Ödemeler şimdilik yer tutucu modunda kalıyor.';
  }

  @override
  String get tutorFailedToLoadChats => 'Sohbetler yüklenemedi';

  @override
  String get tutorNoChatsYet => 'Henüz sohbet yok';

  @override
  String get tutorNoChatsMatchSearch => 'Aramana uyan sohbet yok';

  @override
  String get tutorCreateFirstChat => 'İlk sohbeti oluştur';

  @override
  String get tutorPlansTitle => 'NOVA planları';

  @override
  String tutorPlansSubtitle(Object model) {
    return 'Kullanımın karlı kalması için $model maliyet varsayımlarına ve sıkı aylık sınırlara dayanır.';
  }

  @override
  String get tutorPlanPriceFree => 'Ücretsiz';

  @override
  String tutorPlanPriceMonthly(Object price) {
    return '\$$price/ay';
  }

  @override
  String get tutorPromptsLeft => 'Kalan istemler';

  @override
  String get tutorUploadsLeft => 'Kalan yüklemeler';

  @override
  String get tutorVoiceLeft => 'Kalan ses süresi';

  @override
  String tutorUsageValue(Object remaining, Object total) {
    return '$remaining/$total';
  }

  @override
  String tutorVoiceUsageValue(Object remaining, Object total) {
    return '$remaining/$total dk';
  }

  @override
  String get tutorPaymentMethodsTitle => 'Ödeme yöntemleri';

  @override
  String tutorPaymentMethodsSubtitle(Object plan) {
    return 'ClassMate banka hesabı ve işlemcisi aktif olana kadar ödeme yer tutucu olarak kalır. Seçili plan $plan.';
  }

  @override
  String get tutorCardCheckoutTitle => 'Kartla ödeme';

  @override
  String get tutorCardCheckoutSubtitle =>
      'Visa, Mastercard, AmEx için yer tutucu ağ geçidi.';

  @override
  String get tutorApplePayTitle => 'Apple Pay';

  @override
  String get tutorApplePaySubtitle =>
      'iPhone ve web için yer tutucu cüzdan akışı.';

  @override
  String get tutorBankTransferTitle => 'Banka transferi';

  @override
  String get tutorBankTransferSubtitle =>
      'ClassMate banka hesabı beklemede. Açılınca ayrıntılar eklenecek.';

  @override
  String get tutorPlanStarterName => 'Başlangıç';

  @override
  String get tutorPlanStarterTagline =>
      'Deneme ve hafif haftalık tekrar için yeterli.';

  @override
  String get tutorPlanPlusName => 'Plus';

  @override
  String get tutorPlanPlusTagline =>
      'NOVA\'yı çoğu gün kullanan ciddi bir öğrenci için en iyisi.';

  @override
  String get tutorPlanProName => 'Pro';

  @override
  String get tutorPlanProTagline =>
      'Yoğun günlük kullanım, tam sınav dönemi ve uzun çalışma oturumları için.';

  @override
  String get tutorPlanSchoolSeatName => 'Okul koltuğu';

  @override
  String get tutorPlanSchoolSeatTagline =>
      'Gerçek bir okul içinde öğrenci veya personel başına yaygınlaştırma için.';

  @override
  String tutorPlanBulletPromptsMonthly(Object count) {
    return 'Her ay $count NOVA istemi';
  }

  @override
  String tutorPlanBulletPromptsPerSeatMonthly(Object count) {
    return 'Koltuk başına aylık $count NOVA istemi';
  }

  @override
  String tutorPlanBulletUploads(Object count) {
    return '$count görsel veya dosya yükleme';
  }

  @override
  String tutorPlanBulletVoiceMinutes(Object count) {
    return '$count dakika ses dökümü';
  }

  @override
  String tutorEstimatedCostCeilingFree(Object cost) {
    return 'Tahmini maliyet tavanı: \$$cost/ay';
  }

  @override
  String tutorEstimatedCostCeilingPaid(Object cost, Object margin) {
    return 'Tahmini maliyet tavanı: \$$cost/ay • marj %$margin';
  }

  @override
  String tutorTimeMinutesShort(Object count) {
    return '${count}d';
  }

  @override
  String tutorTimeHoursShort(Object count) {
    return '${count}s';
  }

  @override
  String get tutorVoiceMessageFallback => 'Sesli mesaj';

  @override
  String get tutorFileFallback => 'Dosya';

  @override
  String get tutorCopy => 'Kopyala';

  @override
  String get tutorEditMessage => 'Mesajı düzenle';

  @override
  String get tutorCopied => 'Kopyalandı';

  @override
  String get tutorLoadedIntoComposer => 'Yazma alanına yüklendi';

  @override
  String get tutorTakePhoto => 'Fotoğraf çek';

  @override
  String get tutorRecordVideo => 'Video kaydet';

  @override
  String get tutorChooseFromGallery => 'Galeriden seç';

  @override
  String get tutorPreviewTitle => 'Önizleme';

  @override
  String get tutorThinking => 'Düşünüyor...';

  @override
  String get tutorDone => 'Tamamlandı.';

  @override
  String get tutorFailedToStreamReply => 'Yanıt akışı başarısız oldu';

  @override
  String get tutorUnsupportedFilesMessage =>
      'NOVA görselleri, belgeleri ve metni destekler. Video ve ses dosyaları burada desteklenmez.';

  @override
  String get tutorNoAudioCaptured => 'Ses yakalanmadı.';

  @override
  String get tutorVoiceLimitReachedTitle => 'Ses sınırına ulaşıldı';

  @override
  String get tutorVoiceLimitReachedMessage =>
      'Mevcut NOVA planınız bu yazıya dökme döngüsü için yeterli ses dakikasına sahip değil.';

  @override
  String get tutorTranscriptionFailed =>
      'Döküm başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get tutorMicrophonePermissionRequired => 'Mikrofon izni gereklidir.';

  @override
  String get tutorPlanLimitReachedTitle => 'NOVA plan sınırına ulaşıldı';

  @override
  String get tutorPlanLimitReachedMessage =>
      'Bu ayki istem veya yükleme hakkınız mevcut NOVA planınız için tükendi. Devam etmek için NOVA ana ekranından daha yüksek bir plan seçin.';

  @override
  String get tutorSendFailed => 'Gönderme başarısız oldu.';

  @override
  String tutorCurrentPlanUsageSummary(
    Object plan,
    Object prompts,
    Object uploads,
    Object voice,
  ) {
    return 'Geçerli plan: $plan • $prompts istem kaldı • $uploads yükleme kaldı • $voice ses dakikası kaldı';
  }

  @override
  String get tutorReviewPlansInHome => 'Planları NOVA ana sayfasında incele';

  @override
  String get tutorCouldNotOpenAttachment => 'Ek açılamadı.';

  @override
  String get tutorAttachmentUnavailable => 'Ek kullanılamıyor.';

  @override
  String get tutorImageUnavailable => 'Görsel kullanılamıyor';

  @override
  String get tutorYou => 'Sen';

  @override
  String get tutorRegenerate => 'Yeniden üret';

  @override
  String get tutorEmptyStateTitle => 'Gerçek bir soruyla başla';

  @override
  String get tutorEmptyStateBody =>
      'NOVA\'dan bir kavramı açıklamasını, notları tabloya dönüştürmesini, fikirleri karşılaştırmasını veya yüklediğin bir dosyadan tekrar yapmana yardım etmesini iste.';

  @override
  String get tutorPromptSuggestionSummarizeNotes => 'Ders notlarımı özetle';

  @override
  String get tutorPromptSuggestionRevisionTable => 'Bir tekrar tablosu yap';

  @override
  String get tutorPromptSuggestionQuizMe => 'Bu konuda bana quiz yap';

  @override
  String get tutorMessageNovaHint => 'NOVA\'ya mesaj yaz';

  @override
  String get tutorHeaderSubtitleReady =>
      'Yapılandırılmış yanıtlar, tablolar ve çalışma desteği';

  @override
  String get tutorYourNovaPlanTitle => 'NOVA planın';

  @override
  String get tutorYourNovaPlanMessage =>
      'İstem, yükleme ve ses sınırlarını burada inceleyin; plan değiştirmek isterseniz sonra NOVA ana ekranına dönün.';

  @override
  String get tutorExplainTitle => 'NOVA Açıklar';

  @override
  String get classroomsThreadTypeClassroom => 'Sınıf';

  @override
  String get classroomsThreadTypeGroup => 'Grup';

  @override
  String get classroomsThreadTypeDirectMessage => 'Doğrudan mesaj';

  @override
  String get classroomsThreadTypeDirectMessageShort => 'DM';

  @override
  String get messagesBlockedPeopleTitle => 'Engellenen kişiler';

  @override
  String get messagesStartChatAction => 'Sohbet başlat';

  @override
  String messagesLoadFailed(Object error) {
    return 'Mesajlar yüklenemedi: $error';
  }

  @override
  String get messagesSearchHint => 'Mesaj ara';

  @override
  String get messagesNoResults => 'Mesaj bulunamadı';

  @override
  String get messagesRequestsSection => 'İstekler';

  @override
  String get messagesPendingApprovals => 'Bekleyen onaylar';

  @override
  String get messagesChatsSection => 'Sohbetler';

  @override
  String get messagesAllChatsSection => 'Tüm sohbetler';

  @override
  String messagesConversationCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konuşma',
      one: '1 konuşma',
    );
    return '$_temp0';
  }

  @override
  String get messagesRequestReviewStatus => 'İncele';

  @override
  String messagesPeopleLoadFailed(Object error) {
    return 'Kişiler yüklenemedi: $error';
  }

  @override
  String get messagesSearchPeopleHint => 'Kişi ara';

  @override
  String get messagesNewGroupTitle => 'Yeni grup';

  @override
  String get messagesNewGroupSubtitle => 'Bir grup sohbeti oluştur';

  @override
  String get messagesGroupNameHint => 'Grup adı';

  @override
  String get messagesCreateGroupAction => 'Grup oluştur';

  @override
  String get messagesBlockedPersonFallback => 'bu kişi';

  @override
  String get messagesUnblockPersonTitle => 'Kişinin engeli kaldırılsın mı?';

  @override
  String messagesUnblockPersonBody(Object name) {
    return '$name sana tekrar mesaj gönderebilsin mi?';
  }

  @override
  String get messagesUnblockAction => 'Engeli kaldır';

  @override
  String messagesUnblockedToast(Object name) {
    return '$name engeli kaldırıldı';
  }

  @override
  String messagesBlockedPeopleLoadFailed(Object error) {
    return 'Engellenen kişiler yüklenemedi: $error';
  }

  @override
  String get messagesNoBlockedPeople => 'Engellenen kişi yok';

  @override
  String get messagesUnknownUser => 'Bilinmeyen kullanıcı';

  @override
  String get messagesRequestTitle => 'İstek';

  @override
  String messagesRequestLoadFailed(Object error) {
    return 'İstek yüklenemedi: $error';
  }

  @override
  String get messagesRequestBannerIncoming => 'Mesaj isteği';

  @override
  String get messagesRequestBannerOutgoing => 'Bekleyen onay';

  @override
  String get messagesBlockAction => 'Engelle';

  @override
  String get messagesApproveAction => 'Onayla';

  @override
  String get messagesRequestUnlockHint =>
      'Alıcı ilk mesajını onayladıktan sonra sohbet açılır.';

  @override
  String get messagesThreadConversationFallback => 'Sohbet';

  @override
  String get messagesThreadLeaveGroupTitle => 'Gruptan ayrılsın mı?';

  @override
  String get messagesThreadLeaveGroupBody =>
      'Bu gruptan artık mesaj almayacaksın.';

  @override
  String get messagesThreadBlockPersonTitle => 'Bu kişi engellensin mi?';

  @override
  String get messagesThreadBlockPersonBody =>
      'Bu kişiyle artık mesaj alışverişi yapamayacaksın.';

  @override
  String get messagesThreadPersonFallback => 'Kişi';

  @override
  String get messagesThreadProfileInfoUnavailable =>
      'Profil bilgisi kullanılamıyor';

  @override
  String get messagesThreadParticipants => 'Katılımcılar';

  @override
  String get messagesThreadPeople => 'Kişiler';

  @override
  String get messagesThreadDeleteForMe => 'Benim için sil';

  @override
  String get messagesThreadDeleteForEveryone => 'Herkes için sil';

  @override
  String get messagesThreadDeleteForEveryoneSubtitle =>
      'Tüm katılımcılar için kaldırır';

  @override
  String get messagesThreadSending => 'Gönderiliyor…';

  @override
  String get messagesThreadWaitingForApproval => 'Onay bekleniyor';

  @override
  String get classroomsForwardSearchHint => 'Sohbetlerde ara';

  @override
  String get classroomsForwardNewChat => 'Yeni sohbet';

  @override
  String classroomsForwardLoadError(Object error) {
    return 'Sohbetler yüklenemedi: $error';
  }

  @override
  String get classroomsForwardNoChatsFound => 'Sohbet bulunamadı';

  @override
  String get classroomsForwardSectionClassrooms => 'Sınıflar';

  @override
  String get classroomsForwardSectionDirectMessages => 'Doğrudan mesajlar';

  @override
  String get classroomsForwardCancel => 'İptal';

  @override
  String get classroomsForwardAction => 'İlet';

  @override
  String classroomsForwardCount(Object count) {
    return 'İlet ($count)';
  }

  @override
  String get markRead => 'Okundu işaretle';

  @override
  String get markUnread => 'Okunmadı işaretle';

  @override
  String get markAllRead => 'Tümünü okundu işaretle';

  @override
  String get filters => 'Filtreler';

  @override
  String get source => 'Kaynak';

  @override
  String get state => 'Durum';

  @override
  String get allSources => 'Tüm kaynaklar';

  @override
  String get allStates => 'Tüm durumlar';

  @override
  String get unread => 'Okunmadı';

  @override
  String get read => 'Okundu';

  @override
  String get clear => 'Temizle';

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String get thisWeek => 'Bu hafta';

  @override
  String get earlier => 'Daha önce';

  @override
  String get openDetails => 'Detayları aç';

  @override
  String get total => 'Toplam';

  @override
  String get local => 'Yerel';

  @override
  String get server => 'Sunucu';

  @override
  String get notificationsSourceSystem => 'Sistem';

  @override
  String get notificationsHeroSubtitleStudent =>
      'Duyurular, sunucu güncellemeleri ve faydalı akademik hareketler için bildirim merkeziniz.';

  @override
  String get notificationsHeroSubtitleTeacher =>
      'Duyurular, sunucu güncellemeleri ve okul hareketleri için öğretmen bildirim merkeziniz.';

  @override
  String get notificationsFiltersSubtitle =>
      'Daha hızlı ayıklamak için kaynağa veya okundu durumuna göre odaklanın.';

  @override
  String get notificationsSearchSourcesHint => 'Kaynaklarda ara';

  @override
  String notificationsShowingSummary(Object shown, Object total) {
    return '$total bildirimin $shown tanesi gösteriliyor.';
  }

  @override
  String get notificationsEmptyForAccount =>
      'Bu hesap için şu anda kullanılabilir bildirim yok.';

  @override
  String get notificationsEmptyFiltered =>
      'Bu filtrelere uyan bildirim yok. Tüm akışı görmek için filtreleri temizleyin.';

  @override
  String get notificationsEmpty => 'Şu anda kullanılabilir bildirim yok.';

  @override
  String get notificationsNewBadge => 'Yeni';

  @override
  String get notificationsUnavailable =>
      'Bu bildirim artık kullanılamıyor. Gelen kutusunu yenileyip tekrar deneyin.';

  @override
  String get notificationsSeverityCritical => 'Kritik';

  @override
  String get notificationsSeverityWarning => 'Uyarı';

  @override
  String get notificationsSeverityInfo => 'Bilgi';

  @override
  String get announcementsLoadError =>
      'Duyuruları şu anda yükleyemiyoruz. Yenilemek için aşağıya çekin veya tekrar deneyin.';

  @override
  String get announcementsLoadTimeout =>
      'Duyurular yüklemesi çok uzun sürüyor. Yenilemek için aşağıya çekin veya birazdan tekrar deneyin.';

  @override
  String get announcementsLoadNetwork =>
      'Duyurular şu anda bağlanamadı. Bağlantınızı kontrol edin ve tekrar deneyin.';

  @override
  String get announcementsAudienceTeacher => 'öğretmen';

  @override
  String get announcementsAudienceAccount => 'hesap';

  @override
  String get announcementsAudienceTeacherWorkspace => 'öğretmen çalışma alanı';

  @override
  String get announcementsLoadFailedTitle => 'Duyurular yüklenemedi';

  @override
  String get announcementsLoadFailedHint =>
      'Bağlantı kararlı olduktan sonra yenilemek için aşağıya çekin.';

  @override
  String announcementsHeroSubtitle(Object audience) {
    return 'Okul, öğretmen ve sistem tarafından yayımlanan duyurular $audience için mevcuttur.';
  }

  @override
  String get announcementsLatestSourceLabel => 'En son kaynak';

  @override
  String get announcementsNone => 'Yok';

  @override
  String announcementsUnreadCountTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count okunmamış duyurular',
      one: '1 okunmamış duyuru',
    );
    return '$_temp0';
  }

  @override
  String get announcementsAllReadTitle => 'Her şey okundu';

  @override
  String announcementsEmptyForAudience(Object audience) {
    return '$audience için henüz duyuru yayımlanmadı.';
  }

  @override
  String announcementsLatestBody(Object title) {
    return 'En son: $title. Tam içeriği okumak için dokunun.';
  }

  @override
  String get announcementsFiltersSubtitle =>
      'Dikkat gerektiren şeylere odaklanabilmek için gelen kutusu\'nu kaynağa veya okuma durumuna göre daraltın.';

  @override
  String get announcementsAllAnnouncements => 'Tüm duyurular';

  @override
  String get announcementsSearchStatesHint => 'Okunmamış / Okundu';

  @override
  String announcementsSummarySourceSegment(Object source) {
    return ' $source adresinden';
  }

  @override
  String announcementsSummaryStateSegment(Object state) {
    return ' $state konumunda';
  }

  @override
  String announcementsShowingSummary(
    Object shown,
    Object total,
    Object sourceSegment,
    Object stateSegment,
  ) {
    return '$shown/$total duyurusu gösteriliyor$sourceSegment$stateSegment.';
  }

  @override
  String get announcementsNoMatchTitle => 'Bu filtrelerle eşleşen duyuru yok';

  @override
  String get announcementsNoPublishedTitle => 'Henüz yayımlanan duyuru yok';

  @override
  String get announcementsNoMatchSubtitle =>
      'Farklı bir kaynağı deneyin veya daha fazla öğeyi görünüme getirmek için tüm duyurulara geri dönün.';

  @override
  String get announcementsClearFiltersHint =>
      'Her şeyi tekrar görmek için filtreleri temizleyin.';

  @override
  String get announcementsPullToRefreshHint =>
      'Yeni okul aktivitesi yayımlandıktan sonra yenilemek için aşağıya çekin.';

  @override
  String get announcementsInboxTitle => 'Gelen kutusu';

  @override
  String get announcementsInboxSubtitle =>
      'Hızlı tarama için burada yalnızca başlıklar görünür. Tam duyuru içeriğini açmak için herhangi bir öğeye dokunun.';

  @override
  String get meetingsLoadError =>
      'Şu anda toplantılar yüklenemedi. Yenilemek için çekin veya tekrar deneyin.';

  @override
  String get meetingsLoadTimeout =>
      'Toplantılar yüklemesi çok uzun sürüyor. Yenilemek için çekin veya biraz sonra tekrar deneyin.';

  @override
  String get meetingsLoadNetwork =>
      'Şu anda toplantılara bağlanılamadı. Bağlantınızı kontrol edin ve tekrar deneyin.';

  @override
  String get meetingsHeroSubtitle =>
      'Tüm sınıf toplantıları temiz bir görünümde, ekli bağlantılarla ve bağlam gerektiğinde tam ekran detay sayfasıyla.';

  @override
  String get meetingsJoinReadyMetric => 'Katılmaya hazır';

  @override
  String get meetingsNoLinkMetric => 'Bağlantı yok';

  @override
  String get meetingsNoPostedTitle => 'Henüz toplantı yayınlanmadı';

  @override
  String get meetingsEmptyForAccount =>
      'Şu anda bu öğrenci hesabı için sınıf toplantısı bulunmamaktadır.';

  @override
  String meetingsLatestBody(Object title, Object updatedAt) {
    return '$title güncellendi $updatedAt. Ekli bağlantı ve sınıf bağlamı için açın.';
  }

  @override
  String get meetingsPullToRefreshHint =>
      'Tekrar kontrol etmek için aşağı çekin.';

  @override
  String get meetingsFiltersSubtitle =>
      'Listeyi konuya göre veya toplantının zaten açabileceğiniz bir bağlantı içerip içermediğine göre daraltın.';

  @override
  String get meetingsAccessLabel => 'Erişim';

  @override
  String get meetingsAllMeetings => 'Tüm toplantılar';

  @override
  String get meetingsAccessReady => 'Katılmaya hazır';

  @override
  String get meetingsAccessNoLink => 'Bağlantı yok';

  @override
  String get meetingsAccessNoLinkYet => 'Henüz bağlantı yok';

  @override
  String get meetingsAccessSearchHint => 'Katılmaya hazır / Henüz bağlantı yok';

  @override
  String meetingsSummarySubjectSegment(Object subject) {
    return ' $subject için';
  }

  @override
  String meetingsSummaryAccessSegment(Object state) {
    return ' $state içinde';
  }

  @override
  String meetingsShowingSummary(
    Object shown,
    Object total,
    Object subjectSegment,
    Object accessSegment,
  ) {
    return '$shown / $total toplantı gösteriliyor$subjectSegment$accessSegment.';
  }

  @override
  String get meetingsNoMatchTitle => 'Bu filtrelere uygun toplantı yok';

  @override
  String get meetingsNoMatchSubtitle =>
      'Tüm konuları deneyin veya listeye daha fazla sonuç getirmek için bağlantısı olmayan toplantıları ekleyin.';

  @override
  String get meetingsListSubtitle =>
      'Tam ekran detay görünümünü açmak ve mevcut olduğunda ekli bağlantısına atlamak için herhangi bir toplantıya dokunun.';

  @override
  String meetingsDateTimeValue(Object date, Object time) {
    return '$date • $time';
  }

  @override
  String meetingsSharedByValue(Object name) {
    return 'Paylaşan: $name';
  }

  @override
  String get meetingsPreviewFallback =>
      'Ekli bağlantıyı ve en son sınıf ayrıntılarını görmek için bu toplantıyı açın.';

  @override
  String get meetingsNoValidLinkAttached =>
      'Henüz geçerli bir toplantı bağlantısı eklenmedi.';

  @override
  String get meetingsCouldNotOpenLink => 'Toplantı bağlantısı açılamadı.';

  @override
  String get meetingsNoLinkToCopy => 'Kopyalanacak toplantı bağlantısı yok.';

  @override
  String get meetingsLinkCopied => 'Toplantı bağlantısı kopyalandı.';

  @override
  String get meetingsUnavailableTitle => 'Toplantı kullanılamıyor';

  @override
  String get meetingsUnavailableSubtitle =>
      'Bu toplantı mevcut akışta bulunamadı. Silinmiş olabilir veya çevrimdışı olarak kullanılamaz.';

  @override
  String get meetingsUnavailableHint =>
      'Geri dönün ve toplantı listesini yenileyin.';

  @override
  String get meetingsNoLinkAttachedYet => 'Henüz bağlantı eklenmedi';

  @override
  String get meetingsAttachedLinkTitle => 'Ekli toplantı bağlantısı';

  @override
  String get meetingsAttachedLinkMissingBody =>
      'Bu toplantı sınıf akışınızda görünür, ancak mevcut öğrenci yükünde geçerli bir URL eklenmemiştir.';

  @override
  String get meetingsDetailsTitle => 'Toplantı ayrıntıları';

  @override
  String get meetingsDetailsSubtitle =>
      'Sınıf toplantısı yükünde şu anda mevcut olan ve öğrenci için alakalı olan her şey.';

  @override
  String get meetingsDetailClassroomLabel => 'Sınıf';

  @override
  String get meetingsSharedByLabel => 'Paylaşan';

  @override
  String get meetingsIdLabel => 'Toplantı Kimliği';

  @override
  String get meetingsAttachedLinkSubtitle =>
      'Katılmak için ekli URL\'yi kullanın veya sınıfınız sağladığında toplantı bağlantısını kopyalayın.';

  @override
  String get meetingsOpening => 'Açılıyor';

  @override
  String get meetingsOpenLink => 'Bağlantıyı aç';

  @override
  String get meetingsCopyLink => 'Bağlantıyı kopyala';

  @override
  String get meetingsAccessPanelTitle => 'Toplantı erişimi';

  @override
  String get meetingsAccessPanelReadyBody =>
      'Ekli URL\'yi tarayıcınızda veya toplantı uygulamasında açın.';

  @override
  String get meetingsJoinAction => 'Katıl';

  @override
  String get announcementsDetailLoadFailedHint =>
      'Geri dönün ve duyurular gelen kutusunu yenilemeyi deneyin.';

  @override
  String get announcementsUnavailableTitle => 'Duyuru kullanılamıyor';

  @override
  String announcementsUnavailableSubtitle(Object audience) {
    return 'Bu duyuru artık $audience için yayımlanan akışta kullanılamıyor.';
  }

  @override
  String get announcementsUnavailableHint =>
      'Devam etmek için gelen kutusuna geri dönün.';

  @override
  String announcementsPublishedReadStateBody(Object audience) {
    return 'Bu duyuru $audience için yayımlandı ve okuma durumunuz bu cihazda yerel olarak depolanır.';
  }

  @override
  String get announcementsDetailsTitle => 'Duyuru ayrıntıları';

  @override
  String get announcementsDetailsSubtitle =>
      'Bu duyuru için yayımlanan meta veriler ve geçerli okuma durumu.';

  @override
  String get announcementsSeverityLabel => 'Önem derecesi';

  @override
  String get announcementsCreatedLabel => 'Oluşturuldu';

  @override
  String get announcementsIdLabel => 'Duyuru Kimliği';

  @override
  String get announcementsFullContentTitle => 'Tam içerik';

  @override
  String get announcementsFullContentSubtitle =>
      'Gelen kutusundan öğeyi açtıktan sonra tam duyuru metni burada görünür.';

  @override
  String get announcementsReadStateTitle => 'Okuma durumu';

  @override
  String get announcementsReadStateBodyRead =>
      'Bu duyuru bu cihazda okundu olarak işaretlenmiştir.';

  @override
  String get announcementsReadStateBodyUnread =>
      'Bu duyuru bu cihazda hala okunmamıştır.';

  @override
  String get alertsTitle => 'Uyarılar';

  @override
  String get alertsSubtitle =>
      'Bu sayfa genel güncellemelerden çok şimdi dikkat gerektiren şeyler içindir.';

  @override
  String get alertsAttendanceTitle => 'Devamsızlık dikkat istiyor';

  @override
  String alertsAttendanceBody(Object rate) {
    return 'Devam oranınız %$rate. Birkaç kaçırılan ders hızla birikebilir.';
  }

  @override
  String get alertsWeakestSubjectTitle => 'En zayıf ders sinyali';

  @override
  String alertsWeakestSubjectBody(Object subject) {
    return 'Son notlarınıza göre şu anda en çok dikkat gerektiren ders $subject.';
  }

  @override
  String get alertsPracticeWeakAreaTitle => 'Pratikte zayıf alan';

  @override
  String alertsPracticeWeakAreaBody(Object topic, Object subject) {
    return '$subject içindeki $topic, şu anda en belirgin zayıf konunuz.';
  }

  @override
  String get alertsPracticeTrendDroppedTitle => 'Pratik eğilimi düştü';

  @override
  String get alertsPracticeTrendDroppedBody =>
      '7 günlük performansınız 30 günlük temel seviyenizin altında. Daha fazla zorlamadan önce yavaşlayın ve temellere dönün.';

  @override
  String get alertsEmpty =>
      'Şu anda her şey yolunda. Acil dikkat gerektiren bir şey olursa burada görünür.';

  @override
  String get student => 'Öğrenci';

  @override
  String get classroomDetailPhoto => 'Fotoğraf';

  @override
  String get classroomDetailVoiceNote => 'Sesli not';

  @override
  String get classroomDetailVideo => 'Video';

  @override
  String get classroomDetailFile => 'Dosya';

  @override
  String get classroomDetailEmptyValue => '(boş)';

  @override
  String get classroomDetailAttachmentUnavailable => 'Ek kullanılamıyor.';

  @override
  String get classroomDetailAudioUnavailable => 'Ses kullanılamıyor.';

  @override
  String get classroomDetailCouldNotOpenAttachment => 'Ek açılamadı.';

  @override
  String get classroomDetailVoiceMessage => 'Sesli mesaj';

  @override
  String get classroomDetailVideoFile => 'Video dosyası';

  @override
  String get classroomDetailAttachedFile => 'Ekli dosya';

  @override
  String get classroomDetailAttachment => 'Ek';

  @override
  String get classroomDetailPinAction => 'Sabitle';

  @override
  String get classroomDetailUnpinAction => 'Sabitlemeyi kaldır';

  @override
  String get classroomDetailMessageInfoTitle => 'Mesaj bilgisi';

  @override
  String get classroomDetailForwardedSingle => 'İletildi';

  @override
  String classroomDetailForwardedMultiple(Object count) {
    return '$count mesaj iletildi';
  }

  @override
  String get classroomDetailCannotForwardPending =>
      'Onaylanana kadar istek sohbetine iletilemez';

  @override
  String get classroomDetailCouldNotForwardSelected =>
      'Seçilen mesajlar iletilemedi';

  @override
  String classroomDetailSelectedCount(Object count) {
    return '$count seçildi';
  }

  @override
  String classroomDetailDeleteCount(Object count) {
    return 'Sil ($count)';
  }

  @override
  String get classroomDetailSelectAllTooltip => 'Tümünü seç';

  @override
  String get classroomDetailCancelTooltip => 'İptal';

  @override
  String get classroomDetailMicrophoneAccessTitle => 'Mikrofon erişimi gerekli';

  @override
  String get classroomDetailMicrophoneAccessBody =>
      'Sesli not göndermek için lütfen Ayarlar -> ClassMate içinde mikrofon erişimine izin verin.';

  @override
  String get classroomDetailOpenSettingsAction => 'Ayarları aç';

  @override
  String classroomDetailForwardTargetNext(Object label) {
    return 'Sonraki iletme hedefi: $label';
  }

  @override
  String get classroomDetailEditMessageTitle => 'Mesajı düzenle';

  @override
  String get classroomDetailEditMessageHint => 'Mesajını düzenle...';

  @override
  String get classroomDetailLeaveClassroomTitle => 'Sınıftan ayrılsın mı?';

  @override
  String get classroomDetailLeaveClassroomBody => 'Bu sınıftan çıkarılacaksın.';

  @override
  String get classroomDetailLeaveAction => 'Ayrıl';

  @override
  String get classroomDetailNoAssignmentsTitle => 'Henüz ödev yok';

  @override
  String get classroomDetailNoAssignmentsSubtitle =>
      'Bu sınıfta şu anda ödev yok.';

  @override
  String get classroomDetailAssignmentFallback => 'Ödev';

  @override
  String get classroomDetailNoMaterialsTitle => 'Henüz materyal yok';

  @override
  String get classroomDetailNoMaterialsSubtitle =>
      'Bu sınıfta şu anda materyal yok.';

  @override
  String get classroomDetailMaterialFallback => 'Materyal';

  @override
  String get classroomDetailNoMeetingsTitle => 'Henüz toplantı yok';

  @override
  String get classroomDetailNoMeetingsSubtitle =>
      'Bu sınıfta şu anda toplantı yok.';

  @override
  String get classroomDetailMeetingFallback => 'Toplantı';

  @override
  String get classroomDetailCouldNotLoadPeople => 'Kişiler yüklenemedi';

  @override
  String get classroomDetailNoPeopleTitle => 'Henüz kişi yok';

  @override
  String get classroomDetailNoPeopleSubtitle =>
      'Bu sınıfta henüz kimse görünmüyor.';

  @override
  String get classroomDetailTabChat => 'Sohbet';

  @override
  String get classroomDetailTabMaterials => 'Materyaller';

  @override
  String get classroomDetailTabPeople => 'Kişiler';

  @override
  String get classroomChatMediaSendPhoto => 'Fotoğraf gönder';

  @override
  String get classroomChatMediaSendPhotoSubtitle =>
      'Sınıf sohbetinde bir görsel paylaş';

  @override
  String get classroomChatMediaSendVoiceMessage => 'Sesli mesaj gönder';

  @override
  String get classroomChatMediaSendVoiceMessageSubtitle =>
      'Bir ses notu kaydet ve gönder';

  @override
  String get classroomDetailCouldNotLoadTab => 'Sekme yüklenemedi';

  @override
  String get classroomDetailDeletedByYou => 'Bu mesajı sildin';

  @override
  String get classroomDetailDeletedMessage => 'Bu mesaj silindi';

  @override
  String get practiceSetupDifficultyEasy => 'Kolay';

  @override
  String get practiceSetupDifficultyMedium => 'Orta';

  @override
  String get practiceSetupDifficultyHard => 'Zor';

  @override
  String get practiceSetupDifficultyOlympiad => 'Olimpiyat';

  @override
  String get practiceSetupDifficultyAdaptive => 'Uyarlanabilir';

  @override
  String get practiceSetupModeLabelPractice => 'Alıştırma';

  @override
  String get practiceSetupModeLabelFlashcards => 'Kartlar';

  @override
  String get practiceSetupModeLabelSpeedRound => 'Hız turu';

  @override
  String get practiceSetupModeLabelExamPrep => 'Sınav hazırlığı';

  @override
  String get practiceSetupModeLabelConceptBuilder => 'Kavram kurucu';

  @override
  String get practiceSetupModeLabelAdaptive => 'Uyarlanabilir';

  @override
  String get practiceSetupModeLabelBagrut => 'Bagrut';

  @override
  String get practiceSetupModeSubtitlePractice => 'Dengeli günlük çalışma';

  @override
  String get practiceSetupModeSubtitleFlashcards => 'Göster ve kendin hatırla';

  @override
  String get practiceSetupModeSubtitleSpeedRound => 'Hızlı baskı alıştırması';

  @override
  String get practiceSetupModeSubtitleExamPrep => 'Sakin sınav tarzı akış';

  @override
  String get practiceSetupModeSubtitleConceptBuilder =>
      'Önce kavram, sonra çözüm';

  @override
  String get practiceSetupModeSubtitleAdaptive => 'Zorluk canlı değişir';

  @override
  String get practiceSetupModeSubtitleBagrut => 'Katı resmi stil';

  @override
  String get practiceSetupModeHelpPractice =>
      'Dengeli mod: çöz, kontrol et, açıkla ve devam et.';

  @override
  String get practiceSetupModeHelpFlashcards =>
      'Kartlar, göstermeden önce hatırlamaya çalıştığında en iyi çalışır.';

  @override
  String get practiceSetupModeHelpSpeedRound =>
      'Hız turu hızlı hatırlamayı çalıştırır. Hızlı ilerle ve güçlü sezgilerine güven.';

  @override
  String get practiceSetupModeHelpExamPrep =>
      'Sınav hazırlığı daha sakin ve daha resmidir; gerçek bir okul oturumu gibidir.';

  @override
  String get practiceSetupModeHelpConceptBuilder =>
      'Kavram kurucu önce fikri öğretir, sonra uygulamanı ister.';

  @override
  String get practiceSetupModeHelpAdaptive =>
      'Uyarlanabilir mod, performansına göre zorluk seviyesini değiştirir.';

  @override
  String get practiceSetupModeHelpBagrut =>
      'Bagrut modu katı sınav tarzı çözüm ve gözden geçirmeye odaklanır.';

  @override
  String get practiceSetupModeInfoTitle => 'Her mod nasıl çalışır';

  @override
  String get practiceSetupHeroTitle => 'Bir oturum başlat';

  @override
  String get practiceSetupHeroSubtitle => 'Bir mod, süre ve zorluk seç.';

  @override
  String get practiceSetupInfiniteLives => 'Sonsuz can';

  @override
  String practiceSetupLivesCount(Object count) {
    return '$count can';
  }

  @override
  String get practiceSetupAiTiming => 'YZ zamanlaması';

  @override
  String practiceSetupSecondsShort(Object seconds) {
    return '${seconds}sn';
  }

  @override
  String practiceSetupQuestionsCount(Object count) {
    return '$count soru';
  }

  @override
  String practiceSetupSummarySubject(Object subject) {
    return 'Ders: $subject';
  }

  @override
  String practiceSetupSummaryTopic(Object topic) {
    return 'Konu: $topic';
  }

  @override
  String practiceSetupSummaryMode(Object mode) {
    return 'Mod: $mode';
  }

  @override
  String practiceSetupSummaryDifficulty(Object difficulty) {
    return 'Zorluk: $difficulty';
  }

  @override
  String practiceSetupSummaryQuestions(Object count) {
    return 'Sorular: $count';
  }

  @override
  String practiceSetupSummaryTiming(Object timing) {
    return 'Süre: $timing';
  }

  @override
  String practiceSetupSummaryLives(Object lives) {
    return 'Can: $lives';
  }

  @override
  String get practiceSetupSectionSubjectTopic => 'Ders ve konu';

  @override
  String get practiceSetupFieldSubject => 'Ders';

  @override
  String get practiceSetupFieldSubjectHint => 'Dersi seç';

  @override
  String get practiceSetupChooseSubject => 'Ders seç';

  @override
  String get practiceSetupFieldCustomSubject => 'Özel ders';

  @override
  String get practiceSetupFieldCustomSubjectHint => 'Kendi dersini yaz';

  @override
  String get practiceSetupDialogCustomSubjectTitle => 'Özel ders';

  @override
  String get practiceSetupDialogEnterSubject => 'Dersi gir';

  @override
  String get practiceSetupUseAction => 'Kullan';

  @override
  String get practiceSetupFieldTopic => 'Konu';

  @override
  String get practiceSetupFieldTopicHint => 'Alt konuyu seç';

  @override
  String get practiceSetupChooseTopic => 'Konu seç';

  @override
  String get practiceSetupFieldCustomTopic => 'Özel konu';

  @override
  String get practiceSetupFieldCustomTopicHint => 'Kendi konunu yaz';

  @override
  String get practiceSetupDialogCustomTopicTitle => 'Özel konu';

  @override
  String get practiceSetupDialogEnterTopic => 'Konuyu gir';

  @override
  String get practiceSubjectMath => 'Matematik';

  @override
  String get practiceSubjectPhysics => 'Fizik';

  @override
  String get practiceSubjectComputerScience => 'Bilgisayar Bilimi';

  @override
  String get practiceSubjectChemistry => 'Kimya';

  @override
  String get practiceSubjectBiology => 'Biyoloji';

  @override
  String get practiceSubjectEnglish => 'İngilizce';

  @override
  String get practiceSubjectArabic => 'Arapça';

  @override
  String get practiceSubjectHebrew => 'İbranice';

  @override
  String get practiceSubjectGeneralKnowledge => 'Genel kültür';

  @override
  String get practiceTopicAllTopics => 'Tüm konular';

  @override
  String get practiceTopicAlgebra => 'Cebir';

  @override
  String get practiceTopicLinearEquations => 'Doğrusal denklemler';

  @override
  String get practiceTopicQuadraticEquations => 'İkinci dereceden denklemler';

  @override
  String get practiceTopicFunctions => 'Fonksiyonlar';

  @override
  String get practiceTopicGeometry => 'Geometri';

  @override
  String get practiceTopicTriangles => 'Üçgenler';

  @override
  String get practiceTopicCircles => 'Çemberler';

  @override
  String get practiceTopicAnalyticGeometry => 'Analitik geometri';

  @override
  String get practiceTopicTrigonometry => 'Trigonometri';

  @override
  String get practiceTopicProbability => 'Olasılık';

  @override
  String get practiceTopicStatistics => 'İstatistik';

  @override
  String get practiceTopicSequences => 'Diziler';

  @override
  String get practiceTopicCalculus => 'Kalkülüs';

  @override
  String get practiceTopicLimits => 'Limitler';

  @override
  String get practiceTopicDerivatives => 'Türevler';

  @override
  String get practiceTopicMechanics => 'Mekanik';

  @override
  String get practiceTopicKinematics => 'Kinematik';

  @override
  String get practiceTopicNewtonLaws => 'Newton yasaları';

  @override
  String get practiceTopicForces => 'Kuvvetler';

  @override
  String get practiceTopicEnergy => 'Enerji';

  @override
  String get practiceTopicMomentum => 'Momentum';

  @override
  String get practiceTopicElectricity => 'Elektrik';

  @override
  String get practiceTopicElectricField => 'Elektrik alanı';

  @override
  String get practiceTopicCircuits => 'Devreler';

  @override
  String get practiceTopicWaves => 'Dalgalar';

  @override
  String get practiceTopicOptics => 'Optik';

  @override
  String get practiceTopicThermodynamics => 'Termodinamik';

  @override
  String get practiceTopicConditions => 'Koşullar';

  @override
  String get practiceTopicBooleanLogic => 'Boole mantığı';

  @override
  String get practiceTopicIfElse => 'Eğer / Değilse';

  @override
  String get practiceTopicNestedConditions => 'İç içe koşullar';

  @override
  String get practiceTopicLoops => 'Döngüler';

  @override
  String get practiceTopicVariables => 'Değişkenler';

  @override
  String get practiceTopicArrays => 'Arrayler';

  @override
  String get practiceTopicStrings => 'Dizgeler';

  @override
  String get practiceTopicAlgorithms => 'Algoritmalar';

  @override
  String get practiceTopicComplexity => 'Karmaşıklık';

  @override
  String get practiceTopicRecursion => 'Özyineleme';

  @override
  String get practiceTopicAtoms => 'Atomlar';

  @override
  String get practiceTopicPeriodicTable => 'Periyodik tablo';

  @override
  String get practiceTopicChemicalBonds => 'Kimyasal bağlar';

  @override
  String get practiceTopicReactions => 'Tepkimeler';

  @override
  String get practiceTopicStoichiometry => 'Stokiyometri';

  @override
  String get practiceTopicAcidsAndBases => 'Asitler ve bazlar';

  @override
  String get practiceTopicOrganicChemistry => 'Organik kimya';

  @override
  String get practiceTopicCells => 'Hücreler';

  @override
  String get practiceTopicGenetics => 'Genetik';

  @override
  String get practiceTopicHumanBody => 'İnsan vücudu';

  @override
  String get practiceTopicEcology => 'Ekoloji';

  @override
  String get practiceTopicEvolution => 'Evrim';

  @override
  String get practiceTopicSystems => 'Sistemler';

  @override
  String get practiceTopicGrammar => 'Dil bilgisi';

  @override
  String get practiceTopicReadingComprehension => 'Okuduğunu anlama';

  @override
  String get practiceTopicVocabulary => 'Kelime bilgisi';

  @override
  String get practiceTopicTenses => 'Zamanlar';

  @override
  String get practiceTopicWriting => 'Yazma';

  @override
  String get practiceTopicRhetoric => 'Retorik';

  @override
  String get practiceSetupSectionMode => 'Mod';

  @override
  String get practiceSetupSectionDifficulty => 'Zorluk';

  @override
  String get practiceSetupSectionControls => 'Oturum kontrolleri';

  @override
  String get practiceSetupQuestionsTitle => 'Sorular';

  @override
  String get practiceSetupQuestionsCaption =>
      'Kaç üretilmiş sorunun ekleneceği';

  @override
  String get practiceSetupTimingTitle => 'Zamanlama';

  @override
  String get practiceSetupTimingCaption =>
      'Önce kapsamı seç, sonra YZ, kendi süren veya sonsuz.';

  @override
  String get practiceSetupTimingScopePerQuestion => 'Soru başına';

  @override
  String get practiceSetupTimingScopeWholeQuiz => 'Tüm test';

  @override
  String get practiceSetupTimingModeAi => 'YZ';

  @override
  String get practiceSetupTimingModeMyTime => 'Benim sürem';

  @override
  String get practiceSetupTimingModeInfinite => 'Sonsuz';

  @override
  String get practiceSetupTimingCustomPerQuestionTitle => 'Soru başına saniye';

  @override
  String get practiceSetupTimingCustomPerQuestionCaption =>
      'Her soru için kendi süren';

  @override
  String get practiceSetupTimingCustomQuizMinutesTitle => 'Test dakikaları';

  @override
  String get practiceSetupTimingCustomQuizMinutesCaption =>
      'Tüm test için kendi süren';

  @override
  String get practiceSetupInfiniteLivesTitle => 'Sonsuz can';

  @override
  String get practiceSetupInfiniteLivesSubtitle =>
      'Yanlış cevaplar yüzünden oturumu bitirme';

  @override
  String get practiceSetupLivesTitle => 'Can';

  @override
  String get practiceSetupLivesCaption =>
      'Oturum bitmeden önce izin verilen hata sayısı';

  @override
  String get practiceSetupTooltipHistory => 'Alıştırma geçmişi';

  @override
  String get practiceHistoryTitle => 'Pratik Geçmişi';

  @override
  String get practiceHistoryClearTooltip => 'Geçmişi Temizle';

  @override
  String get practiceHistoryClearConfirmTitle =>
      'Pratik geçmişi temizlensin mi?';

  @override
  String get practiceHistoryClearConfirmBody =>
      'Bu, bu cihazdan kaydedilen tüm pratik oturumlarını kaldırır.';

  @override
  String get practiceHistoryLoadError => 'Pratik geçmişi şu anda yüklenemedi.';

  @override
  String get practiceHistoryErrorPrefix => 'Hata:';

  @override
  String get practiceHistoryEmpty => 'Henüz pratik oturumu yok.';

  @override
  String get practiceHistoryDeleteConfirmTitle => 'Bu oturum silinsin mi?';

  @override
  String get practiceHistoryDeleteConfirmBody =>
      'Bu, yalnızca bu kaydedilen pratik oturumunu kaldırır.';

  @override
  String get practiceHistoryOpenReview => 'İncelemeyi Aç';

  @override
  String get practiceHistoryDeleteSession => 'Oturumu Sil';

  @override
  String get practiceHistoryDebugTitle => 'Pratik geçmişi hata ayıklama';

  @override
  String get practiceAnalyticsTitle => 'Pratik analizleri';

  @override
  String get practiceAnalyticsSectionOverall => 'Genel';

  @override
  String get practiceAnalyticsRecentSessionsTitle => 'Son oturumlar';

  @override
  String practiceAnalyticsRecentSessionsSummary(
    Object sessions,
    Object correct,
    Object answered,
    Object accuracy,
    Object xp,
  ) {
    return '$sessions oturum • $correct/$answered doğru • %$accuracy • XP $xp';
  }

  @override
  String get practiceAnalyticsSectionWeakestTopics => 'En zayıf konular';

  @override
  String get practiceAnalyticsSectionStrongestTopics => 'En güçlü konular';

  @override
  String get practiceAnalyticsSectionModePerformance => 'Mod performansı';

  @override
  String get practiceAnalyticsNoTopicData => 'Henüz konu verisi yok';

  @override
  String get practiceAnalyticsNoModeData => 'Henüz mod verisi yok';

  @override
  String get savedQuestionsTopSubjectNone => 'Henüz yok';

  @override
  String get savedQuestionsHeroSubtitle =>
      'Pratik sırasında kaydettiğiniz sorular yeniden ziyaret edilmesi kolay olmalıdır. Bu sayfa, onlar için temiz yeniden deneme merkezidir.';

  @override
  String get savedQuestionsSavedMetric => 'Kaydedildi';

  @override
  String get savedQuestionsTopSubjectMetric => 'En iyi konu';

  @override
  String get savedQuestionsQuickActionsSubtitle =>
      'Doğrudan pratiğe dönün veya topluluk çözümlerine göz atın.';

  @override
  String get savedQuestionsOpenPractice => 'Pratiği aç';

  @override
  String get savedQuestionsOpenPracticeSubtitle =>
      'Yeni bir oturum başlatın ve momentum oluşturmaya devam edin';

  @override
  String get savedQuestionsOpenSolutions => 'Çözümleri aç';

  @override
  String get savedQuestionsOpenSolutionsSubtitle =>
      'Konu, kitap, sayfa ve soru alanlarına göre yüklenen çözümlere göz atın';

  @override
  String get savedQuestionsQueueTitle => 'Kaydedilen kuyruğunuz';

  @override
  String get savedQuestionsQueueSubtitle =>
      'Pratikte kaydettiğiniz sorular burada görünür, böylece bunları hızlı bir şekilde yeniden açabilir ve zayıf yönleriniz üzerinde çalışmaya devam edebilirsiniz.';

  @override
  String get savedQuestionsEmptyTitle => 'Henüz kaydedilmiş soru yok';

  @override
  String get savedQuestionsEmptySubtitle =>
      'Pratikten bir soruyu kaydedin, daha sonra tekrar ziyaret edin, ilgili çözümleri açın ve hala çalışma gerektiren konuları izleyin.';

  @override
  String get savedQuestionsClearAction => 'Kaydedilen soruları temizle';

  @override
  String get savedQuestionsWhyItWorks => 'Neden işe yarıyor';

  @override
  String savedQuestionsHoursTarget(Object count) {
    return '$count s hedef';
  }

  @override
  String savedQuestionsMinutesTarget(Object count) {
    return '$count dk hedef';
  }

  @override
  String savedQuestionsSecondsTarget(Object count) {
    return '$count sn hedef';
  }

  @override
  String get practiceSetupTooltipAnalytics => 'Alıştırma analitiği';

  @override
  String get practiceSetupStopGenerating => 'Üretimi durdur';

  @override
  String get practiceSetupGenerating => 'Üretiliyor...';

  @override
  String get practiceSetupStartSession => 'Oturumu başlat';

  @override
  String get practiceSetupSearchHint => 'Ara...';

  @override
  String get practiceSessionModeDescriptionPractice =>
      'Anında kontrol ve geri bildirimle dengeli çözüm.';

  @override
  String get practiceSessionModeDescriptionFlashcards =>
      'Hızlı hatırlama ve kalıcılık için hafıza odaklı mod.';

  @override
  String get practiceSessionModeDescriptionSpeedRound =>
      'Hızlı, düşük sürtünmeli, süreli baskı tekrarları.';

  @override
  String get practiceSessionModeDescriptionExamPrep =>
      'Daha az oyunlaştırılmış, resmi sınav hissiyle çözüm.';

  @override
  String get practiceSessionModeDescriptionConceptBuilder =>
      'Önce fikri anla, sonra bağlam içinde çöz.';

  @override
  String get practiceSessionModeDescriptionAdaptive =>
      'Zorluk performansına göre değişir.';

  @override
  String get practiceSessionModeDescriptionBagrut =>
      'Tek soruluk resmi Bagrut akışı.';

  @override
  String get practiceSessionLoadingPractice =>
      'Alıştırma oturumun hazırlanıyor';

  @override
  String get practiceSessionLoadingFlashcards => 'Kartların karıştırılıyor';

  @override
  String get practiceSessionLoadingSpeedRound => 'Hız turu başlıyor';

  @override
  String get practiceSessionLoadingExamPrep => 'Sınav oturumun hazırlanıyor';

  @override
  String get practiceSessionLoadingConceptBuilder => 'Kavram koçu yükleniyor';

  @override
  String get practiceSessionLoadingAdaptive =>
      'Meydan okuma sana göre ayarlanıyor';

  @override
  String get practiceSessionLoadingBagrut => 'Bagrut setin hazırlanıyor';

  @override
  String get practiceSessionLoadingDefault => 'Oturumun hazırlanıyor';

  @override
  String practiceSessionCompleteTitle(Object mode) {
    return '$mode tamamlandı';
  }

  @override
  String get practiceSessionMetricAnswered => 'Yanıtlandı';

  @override
  String get practiceSessionMetricCorrect => 'Doğru';

  @override
  String get practiceSessionMetricWrong => 'Yanlış';

  @override
  String get practiceSessionMetricAccuracy => 'Doğruluk';

  @override
  String get practiceSessionMetricTotal => 'Toplam';

  @override
  String get practiceSessionMetricXp => 'XP';

  @override
  String get practiceSessionMetricStreak => 'Seri';

  @override
  String get practiceSessionReviewLayoutStacked => 'Yığın';

  @override
  String get practiceSessionReviewLayoutFocus => 'Odak';

  @override
  String get practiceSessionFilterAll => 'Tümü';

  @override
  String get practiceSessionFilterWrong => 'Yanlış';

  @override
  String get practiceSessionFilterCorrect => 'Doğru';

  @override
  String get practiceSessionReviewTitle => 'Oturum incelemesi';

  @override
  String get practiceSessionNoQuestionsForFilter =>
      'Henüz bu filtreye uyan soru yok.';

  @override
  String get practiceSessionNoAnswer => 'Cevap yok';

  @override
  String get practiceSessionUnknownAnswer => 'Bilinmiyor';

  @override
  String get practiceSessionReflectionTitle => 'Yansıma';

  @override
  String get practiceSessionReflectionKnewIt => 'Biliyordum';

  @override
  String get practiceSessionReflectionReviewAgain => 'Yeniden gözden geçir';

  @override
  String get practiceSessionBackOfCard => 'Kartın arkası';

  @override
  String get practiceSessionYourAnswer => 'Cevabın';

  @override
  String get practiceSessionCorrectAnswer => 'Doğru cevap';

  @override
  String get practiceSessionExplanation => 'Açıklama';

  @override
  String get practiceSessionBackToSetup => 'Kuruluma dön';

  @override
  String get practiceSessionGeneralTopic => 'Genel';

  @override
  String practiceSessionQuestionProgress(Object current, Object total) {
    return 'Soru $current / $total';
  }

  @override
  String get practiceSessionMetricTime => 'Süre';

  @override
  String practiceSessionMatchmakingDifficulty(Object difficulty) {
    return 'Zorluk: $difficulty';
  }

  @override
  String get practiceModeActionPrevious => 'Önceki';

  @override
  String get practiceModeActionCheckAnswer => 'Cevabı kontrol et';

  @override
  String get practiceModeActionNext => 'Sonraki';

  @override
  String get practiceModeActionNextQuestion => 'Sonraki soru';

  @override
  String get practiceModeActionEndSession => 'Oturumu bitir';

  @override
  String get practiceModeActionEndQuestion => 'Soruyu bitir';

  @override
  String get practiceModeActionEndExam => 'Sınavı bitir';

  @override
  String get practiceModeActionNovaHint => 'NOVA ipucu';

  @override
  String get practiceModeActionReveal => 'Göster';

  @override
  String get practiceModeActionShowSolution => 'Çözümü göster';

  @override
  String get practiceModeActionHideSolution => 'Çözümü gizle';

  @override
  String get practiceModeActionLockIn => 'Sabitle';

  @override
  String get practiceModeActionCheckAdapt => 'Kontrol et ve uyum sağla';

  @override
  String get practiceModeActionContinue => 'Devam et';

  @override
  String get practiceModeActionSolveIt => 'Çöz';

  @override
  String get practiceModeActionNextConcept => 'Sonraki kavram';

  @override
  String get practiceModeCardFront => 'Kartın önü';

  @override
  String get practiceModeRecallSummary => 'Hatırlama özeti';

  @override
  String get practiceModeFeelingPrompt => 'Nasıl hissettirdi?';

  @override
  String get practiceModeFeelingAgain => 'Tekrar';

  @override
  String get practiceModeFeelingHard => 'Zor';

  @override
  String get practiceModeFeelingGood => 'İyi';

  @override
  String get practiceModeFeelingEasy => 'Kolay';

  @override
  String get practiceModeSpeedRoundBanner =>
      'Hız turu · hızlı kararlar, anında ivme';

  @override
  String get practiceModeFastFeedback => 'Hızlı geri bildirim';

  @override
  String get practiceModeExamPrepBanner =>
      'Sınav hazırlığı · daha sakin düzen, cevaplar ilerledikten sonra gözden geçirilir';

  @override
  String get practiceModeReview => 'İnceleme';

  @override
  String get practiceModeBagrutBanner => 'Bagrut modu · resmi sınav akışı';

  @override
  String get practiceModeOfficialSolution => 'Resmi tarzda çözüm';

  @override
  String get practiceModeAdaptiveWarmup => 'Isınma zorluğu';

  @override
  String get practiceModeAdaptiveTrendingUp => 'Zorluk artıyor';

  @override
  String get practiceModeAdaptiveEasingDown => 'Zorluk azalıyor';

  @override
  String get practiceModeAdaptiveSteady => 'Zorluk sabit';

  @override
  String get practiceModeAdaptiveFeedback => 'Uyarlanabilir geri bildirim';

  @override
  String get practiceModeConceptFirst => 'Önce kavram';

  @override
  String get practiceModeNowSolveIt => 'Şimdi çöz';

  @override
  String get practiceModeConceptTitle => 'Kavram';

  @override
  String get practiceModeFeedbackCorrect => 'Doğru';

  @override
  String get practiceModeFeedbackNotQuite => 'Tam değil';

  @override
  String get practiceModeFallbackQuestion => 'Soru';

  @override
  String get practiceModeNoExplanationYet => 'Henüz açıklama yok.';

  @override
  String get teacherGradesAssessmentCreated => 'Değerlendirme oluşturuldu';

  @override
  String get teacherGradesEditAssessmentTitle => 'Değerlendirmeyi düzenle';

  @override
  String get teacherGradesFieldTitle => 'Başlık';

  @override
  String get teacherGradesFieldDate => 'Tarih (YYYY-MM-DD)';

  @override
  String get teacherGradesFieldMaxGrade => 'Maksimum not';

  @override
  String get teacherGradesAssessmentUpdated => 'Değerlendirme güncellendi';

  @override
  String get teacherGradesDeleteAssessmentTitle => 'Değerlendirme silinsin mi?';

  @override
  String teacherGradesDeleteAssessmentBody(Object title) {
    return 'Bu işlem $title kaydını ve not girişini öğretmen alanından kaldırır.';
  }

  @override
  String get teacherGradesDeleteAction => 'Sil';

  @override
  String get teacherGradesAssessmentDeleted => 'Değerlendirme silindi';

  @override
  String get teacherGradesRosterLinkError =>
      'Bu değerlendirme bir sınıf listesine bağlı değil.';

  @override
  String get teacherGradesSaved => 'Notlar kaydedildi';

  @override
  String get teacherGradesSubtitle =>
      'Canlı sınıf listesine göre değerlendirmeler oluştur ve notları kaydet.';

  @override
  String get teacherGradesCreateAssessmentTitle => 'Değerlendirme oluştur';

  @override
  String get teacherGradesFieldCourse => 'Ders';

  @override
  String get teacherGradesCreateAction => 'Oluştur';

  @override
  String get teacherGradesNoStudentsLoaded =>
      'Bu değerlendirme için öğrenci yüklenmedi.';

  @override
  String get teacherGradesFieldGrade => 'Not';

  @override
  String teacherGradesMaxHint(Object grade) {
    return 'Maks. $grade';
  }

  @override
  String get teacherGradesSaving => 'Kaydediliyor…';

  @override
  String teacherGradesSaveCount(Object count) {
    return '$count notu kaydet';
  }

  @override
  String get assignmentsNoDueDate => 'Son tarih yok';

  @override
  String get assignmentsLoadError =>
      'Şu anda ödevleri yükleyemedik. Yenilemek için çekin veya tekrar deneyin.';

  @override
  String get assignmentsLoadTimeout =>
      'Ödevlerin yüklenmesi çok uzun sürüyor. Yenilemek için çekin veya birazdan tekrar deneyin.';

  @override
  String get assignmentsLoadNetwork =>
      'Şu anda ödevlere bağlanılamadı. Bağlantınızı kontrol edin ve tekrar deneyin.';

  @override
  String get assignmentsStatusOverdue => 'Gecikmiş';

  @override
  String get assignmentsStatusDueSoon => 'Yakında teslim';

  @override
  String get assignmentsStatusUpcoming => 'Yaklaşan';

  @override
  String get assignmentsPreviewFallback =>
      'Tam talimatları görmek ve çalışmanızı hazırlamak için bu ödevi açın.';

  @override
  String get assignmentsSubmissionPrepEmpty =>
      'Notunuzu veya dosyalarınızı buraya yükleyin.';

  @override
  String assignmentsSubmissionPrepCount(Object count) {
    return '$count dosya yerel olarak eklenmiş.';
  }

  @override
  String get assignmentsHeroSubtitle =>
      'Tüm sınıf ödevleri tek bir temiz görünümde, tam ekran ayrıntı sayfası ve çalışmanızı hazırlayacak özel bir alanla birlikte.';

  @override
  String get assignmentsSubjectsMetric => 'Dersler';

  @override
  String get assignmentsNothingAssignedYet => 'Henüz hiçbir şey atanmadı';

  @override
  String get assignmentsNoAssignmentsForAccount =>
      'Şu anda bu öğrenci hesabı için hiçbir sınıf ödevi mevcut değildir.';

  @override
  String assignmentsNextThingBody(Object title, Object due) {
    return '$title bakılması gereken sonraki şeydir. $due.';
  }

  @override
  String get assignmentsPullToCheckAgain =>
      'Tekrar kontrol etmek için aşağı çekin.';

  @override
  String get assignmentsFiltersSubtitle =>
      'Listeyi derse veya aciliyete göre daraltarak önemli olanı önce vurgulayın.';

  @override
  String get assignmentsSubjectLabel => 'Ders';

  @override
  String get assignmentsAllSubjects => 'Tüm dersler';

  @override
  String get assignmentsSearchSubjects => 'Dersleri ara';

  @override
  String get assignmentsStatusLabel => 'Durum';

  @override
  String get assignmentsAllStatuses => 'Tüm durumlar';

  @override
  String get assignmentsSearchStatuses => 'Durumları ara';

  @override
  String assignmentsShowingSummary(Object shown, Object total) {
    return '$total ödevin $shown tanesi gösteriliyor.';
  }

  @override
  String get assignmentsNoFilterMatchesTitle =>
      'Bu filtrelerle eşleşen ödev yok';

  @override
  String get assignmentsNoFilterMatchesSubtitle =>
      'Listeye daha fazla ödev getirmek için tüm dersleri veya daha geniş bir durum görünümünü deneyin.';

  @override
  String get assignmentsClearFiltersHint =>
      'Her şeyi tekrar görmek için filtreleri temizleyin.';

  @override
  String get assignmentsListSubtitle =>
      'Tam ekran ayrıntı görünümünü açmak ve çalışmanızı hazırlamak için herhangi bir ödeve dokunun.';

  @override
  String get assignmentsAddNoteBeforePrepare =>
      'Çalışmanızı hazırlamadan önce not ekleyin veya dosya takı edin.';

  @override
  String get assignmentsWorkDraftPrepared => 'Çalışma taslağı hazırlandı.';

  @override
  String get assignmentsWorkDraftPreparedWithFiles =>
      'Çalışma taslağı hazırlandı. Ekli dosyalar bu cihazda kaydedilir.';

  @override
  String get assignmentsUnavailableTitle => 'Ödev kullanılamıyor';

  @override
  String get assignmentsUnavailableSubtitle =>
      'Bu ödev geçerli akışta bulunamadı. Kaldırılmış olabilir veya çevrimdışı kullanılamaz.';

  @override
  String get assignmentsUnavailableHint =>
      'Geri dönün ve ödev listesini yenileyin.';

  @override
  String get assignmentsOverdueBannerBody =>
      'Bu ödev son tarihini geçti. Teslim etmek istediğiniz şeyi hazırlamak için aşağıda çalışma alanınızı açın.';

  @override
  String get assignmentsWorkAreaBannerBody =>
      'Dosyaları düzenlemek, not yazmak ve her şeyi tek bir yerde hazır tutmak için aşağıdaki çalışma alanını kullanın.';

  @override
  String get assignmentsDetailsSectionTitle => 'Ödev ayrıntıları';

  @override
  String get assignmentsDetailsSectionSubtitle =>
      'Şu anda sınıf ödevi yükünde bulunan öğrenci için ilgili her şey.';

  @override
  String get assignmentsDetailDueLabel => 'Son tarih';

  @override
  String get assignmentsDetailClassroomLabel => 'Sınıf';

  @override
  String get assignmentsDetailTeacherLabel => 'Öğretmen';

  @override
  String get assignmentsDetailPostedByLabel => 'Yayınlayan';

  @override
  String get assignmentsDetailPublishedLabel => 'Yayınlandı';

  @override
  String get assignmentsDetailUpdatedLabel => 'Güncellendi';

  @override
  String get assignmentsDetailIdLabel => 'Ödev Kimliği';

  @override
  String get assignmentsInstructionsTitle => 'Talimatlar';

  @override
  String get assignmentsInstructionsSubtitle =>
      'Sınıf akışından tam ödev metni, orijinal ifade korunmuş şekilde.';

  @override
  String get assignmentsYourWorkTitle => 'Sizin çalışmanız';

  @override
  String get assignmentsYourWorkSubtitle =>
      'Not düzenleyin, dosya veya belge ekleyin ve teslim etme hazırlığınızı odaklı bir alanda tutun.';

  @override
  String get assignmentsPrivateNoteLabel => 'Özel çalışma notu';

  @override
  String get assignmentsPrivateNoteHint =>
      'Teslim etmeyi planladığınızı, kendinize yönelik hatırlatıcıları veya belge/bağlantı özetini ekleyin.';

  @override
  String get assignmentsAddFiles => 'Dosya veya belge ekle';

  @override
  String get assignmentsClearFiles => 'Dosyaları temizle';

  @override
  String get assignmentsStagedDeviceHint =>
      'Dosyalar bu cihazda düzenlenir. Ödev dosya teslimi bu uygulamada kullanılamaz.';

  @override
  String assignmentsLastPrepared(Object time) {
    return 'Son hazırlanan $time.';
  }

  @override
  String get assignmentsSubmissionPrepTitle => 'Teslim hazırlığı';

  @override
  String get assignmentsPreparing => 'Hazırlanıyor';

  @override
  String get assignmentsPrepareWork => 'Çalışmayı hazırla';

  @override
  String get assignmentsLoadingSubtitle => 'Sınıf ödevleriniz yükleniyor.';

  @override
  String get assignmentsPullToRefreshRetry =>
      'Yenilemek için çekin veya aşağıdan tekrar deneyin.';

  @override
  String get assignmentsFileSizeUnknown => 'Dosya';

  @override
  String get assignmentsRemoveAttachment => 'Eki kaldır';

  @override
  String get attendanceUndated => 'Tarihlenmemiş';

  @override
  String get attendanceLoadError =>
      'Şu anda katılımı yükleyemedik. Yenilemek için aşağı çekin veya tekrar deneyin.';

  @override
  String get attendanceLoadTimeout =>
      'Katılım yükleme işlemi çok uzun sürüyor. Yenilemek için aşağı çekin veya biraz sonra tekrar deneyin.';

  @override
  String get attendanceLoadNetwork =>
      'Katılım şu anda bağlanamıyor. Bağlantınızı kontrol edin ve tekrar deneyin.';

  @override
  String get attendanceConsistencyBuilding => 'Hala inşa aşamasında';

  @override
  String get attendanceConsistencyExcellent => 'Mükemmel tutarlılık';

  @override
  String get attendanceConsistencySteady => 'Çoğunlukla sabit';

  @override
  String get attendanceConsistencyNeedsAttention => 'Dikkat gerekiyor';

  @override
  String get attendanceConsistencyRisk => 'Katılım riski';

  @override
  String get attendanceWatchRecentAbsences => 'Son devamsızlıklar';

  @override
  String get attendanceWatchRepeatedLateness => 'Tekrarlanan geç kalmalar';

  @override
  String get attendanceWatchExcusedAddingUp => 'Mazeretli zaman birikuyor';

  @override
  String get attendanceWatchNoFlags => 'Mevcut bayrak yok';

  @override
  String get attendanceAllSubjectsLowercase => 'tüm dersler';

  @override
  String attendanceShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return '$range içinde $subject için $total işaretin $shown tanesini gösteriliyor.';
  }

  @override
  String get attendanceDayToneAbsent => 'Devamsızlık günü';

  @override
  String get attendanceDayToneLate => 'Geç kalma sinyali';

  @override
  String get attendanceDayToneExcused => 'Mazeretli katılım';

  @override
  String get attendanceDayToneClean => 'Temiz gün';

  @override
  String get attendanceLoadingSubtitle => 'En son katılım özeti yükleniyor.';

  @override
  String get attendanceUnavailableTitle => 'Katılım kullanılamıyor';

  @override
  String get attendanceHeroSubtitle =>
      'Katılım oranınız, son dersler ve dikkat gerektiren herhangi bir şey hakkında net bir okuma.';

  @override
  String get attendanceMetricRate => 'Oran';

  @override
  String get attendanceMetricPresent => 'Katılım işaretleri';

  @override
  String get attendanceMetricLate => 'Geç kalma işaretleri';

  @override
  String get attendanceMetricAbsent => 'Devamsızlık işaretleri';

  @override
  String attendanceHeroSignalBody(Object flag) {
    return '$flag. Katılım baskısı sessizce birikebilir, bu nedenle bu görünüm en son değişenlere odaklanır.';
  }

  @override
  String get attendanceNoSummary =>
      'Bu öğrenci hesabı için henüz katılım özeti kullanılamıyor.';

  @override
  String get attendanceEmptyTitle => 'Henüz katılım kaydı yok';

  @override
  String get attendanceEmptySubtitle =>
      'Bu öğrenci hesabı için henüz herhangi bir katılım kaydı yayınlanmamıştır.';

  @override
  String get attendanceFiltersSubtitle =>
      'Katılım görünümünü derse veya zaman penceresine göre daraltmak için ayarlarla aynı aranabilir seçici stilini kullanın.';

  @override
  String get attendanceTimeRangeLabel => 'Zaman aralığı';

  @override
  String get attendanceSearchRanges => 'Tüm zaman / 7 gün / 30 gün / 90 gün';

  @override
  String get attendanceNoFilteredMarksTitle =>
      'Bu filtrelerle eşleşen işaret yok';

  @override
  String get attendanceNoFilteredMarksSubtitle =>
      'Daha fazla katılım işaretini görünüme geri getirmek için tüm dersleri veya daha geniş bir zaman aralığı deneyin.';

  @override
  String get attendanceQuickReadTitle => 'Hızlı okuma';

  @override
  String get attendanceQuickReadSubtitleFiltered =>
      'Aşağıda gösterilen filtrelenmiş katılım işaretleri için hızlı bir özet.';

  @override
  String get attendanceQuickReadSubtitleAll =>
      'Mevcut en son katılım kayıtlarına dayalı hızlı bir özet.';

  @override
  String get attendanceSummaryConsistency => 'Tutarlılık';

  @override
  String get attendanceSummaryWatchFor => 'Dikkat et';

  @override
  String get attendanceSummaryExcused => 'Mazeretli işaretler';

  @override
  String get attendanceSummaryMarksInView => 'Görünümdeki işaretler';

  @override
  String get attendanceSummaryRateInView => 'Görünümdeki oran';

  @override
  String get attendanceRecentDaysTitle => 'Son günler';

  @override
  String get attendanceRecentDaysSubtitleFiltered =>
      'Şu anda görünümdeki filtrelenmiş işaretler için güne göre gruplandırılmış.';

  @override
  String get attendanceRecentDaysSubtitleAll =>
      'Devamsızlık veya geç kalma desenlerini daha hızlı yakalamak için güne göre gruplandırılmış.';

  @override
  String get attendanceLessonCountSingle => '1 ders';

  @override
  String attendanceLessonCount(Object count) {
    return '$count ders';
  }

  @override
  String get attendanceStatusPresent => 'Katılımcı';

  @override
  String get attendanceStatusLate => 'Geç';

  @override
  String get attendanceStatusAbsent => 'Devamsız';

  @override
  String get attendanceStatusExcused => 'Mazeretli';

  @override
  String get attendanceStatusRecorded => 'Kaydedilmiş';

  @override
  String get attendanceLessonFallback => 'Ders';

  @override
  String get attendanceRangeAll => 'Tüm zaman';

  @override
  String get attendanceRange7 => 'Son 7 gün';

  @override
  String get attendanceRange30 => 'Son 30 gün';

  @override
  String get attendanceRange90 => 'Son 90 gün';

  @override
  String get attendanceRangeAllShort => 'Tüm zaman';

  @override
  String get attendanceRange7Short => '7 gün';

  @override
  String get attendanceRange30Short => '30 gün';

  @override
  String get attendanceRange90Short => '90 gün';

  @override
  String get gradesLoadError =>
      'Notlar şu anda yüklenemedi. Yenilemek için aşağı çekin veya tekrar deneyin.';

  @override
  String get gradesLoadTimeout =>
      'Notlar yüklenmesi çok uzun sürüyor. Yenilemek için aşağı çekin veya birkaç saniye sonra tekrar deneyin.';

  @override
  String get gradesLoadNetwork =>
      'Notlara şu anda bağlanılamadı. Bağlantınızı kontrol edin ve tekrar deneyin.';

  @override
  String get gradesGeneralSubject => 'Genel';

  @override
  String get gradesBandBuilding => 'Hâlâ oluşturuluyor';

  @override
  String get gradesBandExcellent => 'Mükemmel';

  @override
  String get gradesBandStrong => 'Güçlü';

  @override
  String get gradesBandOkay => 'Tamam';

  @override
  String get gradesBandNeedsAttention => 'Dikkat gerektiriyor';

  @override
  String get gradesBandRisk => 'Risk altında';

  @override
  String get gradesTrendRising => 'Yükselen';

  @override
  String get gradesTrendDropping => 'Düşen';

  @override
  String get gradesTrendStable => 'Sabit';

  @override
  String gradesShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return '$range içinde $subject için kaydedilen $total nottan $shown tanesi gösteriliyor.';
  }

  @override
  String get gradesLoadingSubtitle =>
      'En son akademik sonuçlarınız yükleniyor.';

  @override
  String get gradesUnavailableTitle => 'Notlar kullanılamıyor';

  @override
  String get gradesHeroSubtitle =>
      'Ortalama, son değerlendirmeler ve hangi derslerin koruma veya kurtarma gerektirdiğinin net bir özeti.';

  @override
  String get gradesMetricAverage => 'Ortalama';

  @override
  String get gradesMetricRecorded => 'Kaydedildi';

  @override
  String get gradesMetricBestSubject => 'En iyi ders';

  @override
  String get gradesMetricNeedsWork => 'Çalışma gerekli';

  @override
  String gradesLatestSignalBody(
    Object assessment,
    Object subject,
    Object grade,
    Object band,
  ) {
    return '$subject içindeki $assessment $grade aldı. $band şu anda.';
  }

  @override
  String get gradesSummaryAvailableNoRecent =>
      'Not özeti mevcut, ancak bu görünümde henüz son değerlendirmeler görünmüyor.';

  @override
  String get gradesEmptyTitle => 'Henüz not yok';

  @override
  String get gradesEmptySubtitle =>
      'Bu öğrenci hesabı için henüz hiçbir not yayınlanmadı.';

  @override
  String get gradesFiltersSubtitle =>
      'Notları derse veya zaman penceresine göre daraltmak için ayarlar gibi aynı aranabilir seçici stilini kullanın.';

  @override
  String get gradesNoFilteredTitle => 'Bu filtrelerle eşleşen notlar yok';

  @override
  String get gradesNoFilteredSubtitle =>
      'Daha fazla kaydedilen notu geri getirmek için tüm dersleri veya daha geniş bir zaman aralığını deneyin.';

  @override
  String get gradesQuickReadTitle => 'Hızlı okuma';

  @override
  String get gradesQuickReadSubtitleFiltered =>
      'Şu anda görüntüde olan notların hızlı bir özeti.';

  @override
  String get gradesQuickReadSubtitleAll =>
      'Korumak ve kurtarmak için neyin en hızlı okuması.';

  @override
  String get gradesWeakSpotLabel => 'Geçerli zayıf nokta';

  @override
  String get gradesNoWeakSignal => 'Henüz zayıf ders sinyali yok';

  @override
  String gradesWeakSpotValue(Object subject) {
    return '$subject ilk kurtarma bloğuna ihtiyaç duyuyor.';
  }

  @override
  String get gradesStrengthLabel => 'Geçerli güç';

  @override
  String get gradesNoStrengthSignal => 'Henüz güçlü ders sinyali yok';

  @override
  String gradesStrengthValue(Object subject) {
    return '$subject şu anda sizin güven çapalanız.';
  }

  @override
  String get gradesBandLabel => 'Bant';

  @override
  String get gradesInViewLabel => 'Görünümde';

  @override
  String gradesInViewCount(Object count) {
    return 'Bu filtrede $count kaydedilen not.';
  }

  @override
  String gradesInViewAverage(Object count, Object average) {
    return 'Bu filtrede $count kaydedilen not, ortalama $average.';
  }

  @override
  String get gradesLatestAssessmentsTitle => 'Son değerlendirmeler';

  @override
  String get gradesLatestAssessmentsSubtitleFiltered =>
      'Geçerli filtrelenmiş görünümde en son kaydedilen notlar.';

  @override
  String get gradesLatestAssessmentsSubtitleAll =>
      'Kronolojik sırada en son kaydedilen notlar.';

  @override
  String get gradesSubjectDrilldownTitle => 'Ders detayı';

  @override
  String get gradesSubjectDrilldownSubtitleFiltered =>
      'Şu anda görüntüdeki notlar için derse göre gruplandırılmış.';

  @override
  String get gradesSubjectDrilldownSubtitleAll =>
      'Eğilim ve baskı daha hızlı ortaya çıksın diye derse göre gruplandırılmış.';

  @override
  String get gradesAssessmentFallback => 'Değerlendirme';

  @override
  String get gradesChipBest => 'En iyi';

  @override
  String get gradesNoAverageYet => 'Henüz ortalama yok';

  @override
  String gradesRecentAverage(Object average) {
    return 'Son ortalama: $average';
  }

  @override
  String get actionCancel => 'İptal';

  @override
  String get actionSave => 'Kaydet';

  @override
  String get actionDelete => 'Sil';

  @override
  String get actionRemove => 'Kaldır';

  @override
  String get actionBlock => 'Engelle';

  @override
  String get actionCreate => 'Oluştur';

  @override
  String get actionShare => 'Paylaş';

  @override
  String get actionScheduleVerb => 'Planla';

  @override
  String get actionAdd => 'Ekle';

  @override
  String get actionKeep => 'Tut';

  @override
  String get actionOpen => 'Aç';

  @override
  String get actionPublish => 'Yayınla';

  @override
  String get actionPublishing => 'Yayınlanıyor…';

  @override
  String get actionRefresh => 'Yenile';

  @override
  String get msgBlockTitle => 'Bu kişiyi engelle?';

  @override
  String get msgBlockContent =>
      'Sana mesaj gönderemeyecek ve onun mesajlarını görmeyeceksin.';

  @override
  String get msgRenameGroup => 'Grubu yeniden adlandır';

  @override
  String get msgGroupName => 'Grup adı';

  @override
  String get msgMute => 'Sessiz';

  @override
  String get msgUnmute => 'Sesi aç';

  @override
  String get msgInviteCode => 'Davet kodu';

  @override
  String get msgCopyCode => 'Kodu kopyala';

  @override
  String get msgLeave => 'Ayrıl';

  @override
  String get msgInviteCodeCopied => 'Davet kodu kopyalandı';

  @override
  String msgCodeCopied(Object code) {
    return 'Kod kopyalandı: $code';
  }

  @override
  String msgParticipantsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count katılımcı eklendi',
      one: '1 katılımcı eklendi',
    );
    return '$_temp0';
  }

  @override
  String msgMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count üye',
      one: '1 üye',
    );
    return '$_temp0';
  }

  @override
  String get msgAdmin => 'Yönetici';

  @override
  String get msgRemoveFromGroup => 'Gruptan çıkar';

  @override
  String get msgMakeAdmin => 'Yönetici yap';

  @override
  String get msgRemoveAdmin => 'Yöneticilik al';

  @override
  String get msgOnlyAdmin => 'Tek yönetici — önce başkasını yönetici yap';

  @override
  String msgRemoveMemberTitle(Object name) {
    return '$name kaldırılsın mı?';
  }

  @override
  String get msgNotificationsMuted => 'Bildirimler sessize alındı';

  @override
  String get msgNotificationsUnmuted => 'Bildirimler açıldı';

  @override
  String get msgJoinGroupTitle => 'Gruba Katıl';

  @override
  String get msgJoinGroupSubtitle => 'Grup yöneticisinden davet kodunu girin';

  @override
  String get examTitle => 'Sınav';

  @override
  String get examNotFound => 'Sınav bulunamadı';

  @override
  String get examStudyWithNova => 'NOVA ile çalış';

  @override
  String get examOpenInsights => 'Analizleri aç';

  @override
  String get examAddToCalendar => 'Takvime ekle';

  @override
  String get examCouldNotOpenCalendar => 'Takvim açılamadı.';

  @override
  String get formTitle => 'Form';

  @override
  String get formNotFound => 'Form bulunamadı';

  @override
  String get formClosed => 'Bu form kapalı.';

  @override
  String get formCompletion => 'Tamamlama';

  @override
  String get formNoTextResponses => 'Henüz metin yanıtı yok.';

  @override
  String get meetingsCouldNotLoad => 'Toplantılar yüklenemedi';

  @override
  String get meetingCouldNotLoad => 'Toplantı yüklenemedi';

  @override
  String get insightsGenerateAction => 'Analiz oluştur';

  @override
  String get insightsRefreshAction => 'Yenile';

  @override
  String get teacherGoToClassroom => 'Sınıfa git';

  @override
  String get teacherMarkAttendance => 'Devam işaretle';

  @override
  String get teacherPostAssignment => 'Ödev yayınla';

  @override
  String get teacherNewAnnouncementAction => 'Yeni duyuru';

  @override
  String get teacherViewFullWeekSchedule => 'Haftalık programı görüntüle';

  @override
  String get teacherGroupsLabel => 'Gruplar';

  @override
  String get teacherTestsLabel => 'Testler';

  @override
  String get teacherAnnounceLabel => 'Duyur';

  @override
  String get teacherTitleAndMessageRequired => 'Başlık ve mesaj gereklidir';

  @override
  String get teacherAnnouncementPublished => 'Duyuru yayınlandı';

  @override
  String teacherFailedToPublish(Object error) {
    return 'Yayınlama başarısız: $error';
  }

  @override
  String get teacherAnnouncementSectionTitle => 'Duyuru';

  @override
  String get teacherAudienceSectionTitle => 'Hedef kitle';

  @override
  String get teacherPinAnnouncement => 'Duyuruyu sabitle';

  @override
  String get teacherPinnedAtTop => 'Sabitlenmiş duyurular üstte görünür';

  @override
  String get teacherPublishAction => 'Yayınla';

  @override
  String get teacherPublishingAction => 'Yayınlanıyor…';

  @override
  String get teacherAnnounceTitleLabel => 'Başlık *';

  @override
  String get teacherAnnounceTitleHint => 'ör. Yarın okul etkinliği';

  @override
  String get teacherAnnounceMessageLabel => 'Mesaj *';

  @override
  String get teacherAnnounceMessageHint => 'Duyurunun tamamını buraya yazın…';

  @override
  String get teacherStudentsLabel => 'Öğrenciler';

  @override
  String get teacherParentsLabel => 'Veliler';

  @override
  String get teacherTeachersLabel => 'Öğretmenler';

  @override
  String get teacherWeekScheduleTitle => 'Haftalık program';

  @override
  String get teacherCouldNotLoadSchedule => 'Program yüklenemedi';

  @override
  String get teacherAttendanceLast30 => 'Devam (son 30 gün)';

  @override
  String get teacherRecentGrades => 'Son notlar';

  @override
  String get teacherNoGradesRecorded => 'Henüz not kaydedilmedi';

  @override
  String get teacherGradeAvg => 'Not ort.';

  @override
  String get teacherSubmittedLabel => 'Teslim edildi';

  @override
  String get teacherAnalyticsTitle => 'Analizler';

  @override
  String get teacherGradeReports => 'Not raporları';

  @override
  String get teacherAvgLabel => 'ort.';

  @override
  String teacherBelow60(Object count) {
    return '$count 60% altında';
  }

  @override
  String teacherGradedFraction(Object graded, Object total) {
    return '$graded/$total notlandırıldı';
  }

  @override
  String get teacherNoGradesEntered => 'Henüz not girilmedi';

  @override
  String get teacherNewAssignment => 'Yeni ödev';

  @override
  String get teacherDeleteAssignment => 'Ödev silinsin mi?';

  @override
  String get teacherDeleteAssignmentContent =>
      'Bu, tüm öğrenciler için kaldırılacak.';

  @override
  String get teacherShareMaterialTitle => 'Materyal paylaş';

  @override
  String get teacherRemoveMaterial => 'Materyal kaldırılsın mı?';

  @override
  String get teacherScheduleMeetingTitle => 'Toplantı planla';

  @override
  String get teacherCancelMeetingTitle => 'Toplantı iptal edilsin mi?';

  @override
  String get teacherCancelMeetingAction => 'Toplantıyı iptal et';

  @override
  String get teacherJoinMeeting => 'Toplantıya katıl';

  @override
  String get teacherAddStudentTitle => 'Öğrenci ekle';

  @override
  String teacherRemoveStudentTitle(Object name) {
    return '$name kaldırılsın mı?';
  }

  @override
  String get teacherRemoveStudentContent =>
      'Bu öğrenci bu sınıftan kaldırılacak.';

  @override
  String get teacherStudentAdded => 'Öğrenci eklendi';

  @override
  String get teacherClassroomAnalyticsTitle => 'Sınıf analizleri';

  @override
  String get teacherOpenAnalyticsAction => 'Analizleri aç';

  @override
  String teacherStudentsCount(Object count) {
    return 'Öğrenciler ($count)';
  }

  @override
  String get teacherAssignmentLabel => 'Ödev';

  @override
  String get teacherShareMaterialLabel => 'Materyal paylaş';

  @override
  String get teacherAttendanceRateLabel => 'Devam oranı';

  @override
  String get teacherSelectSessionPrompt =>
      'Devamı işaretlemek için aşağıdan bir oturum seçin';

  @override
  String get teacherOpenAction => 'Aç';

  @override
  String get chatDeleteForMe => 'Benim için sil';

  @override
  String get chatDeleteForEveryone => 'Herkes için sil';

  @override
  String get chatMicNeeded => 'Mikrofon erişimi gerekiyor';

  @override
  String get chatMicNeededBody =>
      'Sesli not göndermek için Ayarlar\'da mikrofon erişimine izin verin.';

  @override
  String get chatOpenSettings => 'Ayarları Aç';

  @override
  String get chatCopied => 'Kopyalandı';

  @override
  String get chatCouldNotSendMedia => 'Medya gönderilemedi.';

  @override
  String get chatCouldNotSendMessage => 'Mesaj gönderilemedi.';

  @override
  String get chatCouldNotForward => 'Seçilen mesajlar iletilemedi';

  @override
  String get chatSelectAll => 'Tümünü seç';

  @override
  String get chatDeselectAll => 'Seçimi kaldır';

  @override
  String get chatEditingMessage => 'Mesaj düzenleniyor';

  @override
  String get chatEditPlaceholder => 'Mesajı düzenle…';

  @override
  String get chatMessageHint => 'Mesaj';

  @override
  String get chatPin => 'Sabitle';

  @override
  String get chatUnpin => 'Sabitlemeyi kaldır';

  @override
  String get chatPhoto => 'Fotoğraf';

  @override
  String get chatVideo => 'Video';

  @override
  String get chatMedia => 'Medya';

  @override
  String get chatAudioFile => 'Ses dosyası';

  @override
  String get chatVideoFile => 'Video dosyası';

  @override
  String get chatAttachedFile => 'Ekli dosya';

  @override
  String get chatFollowUp => 'Takip';

  @override
  String get chatCancelTooltip => 'İptal';

  @override
  String get chatJoinGroup => 'Gruba Katıl';

  @override
  String get chatJoining => 'Katılınıyor…';

  @override
  String get chatJoinGroupTooltip => 'Kodla gruba katıl';

  @override
  String get chatForwardNoChatAvailable => 'Onaylı sohbet yok';

  @override
  String get chatFilterAll => 'Tümü';

  @override
  String get novaDisclaimer =>
      'NOVA hata yapabilir. Önemli yanıtları doğrulayın.';

  @override
  String get practiceCustomDisclaimer =>
      'Özel konular yapay zeka tarafından anında oluşturulur. Sorular konudan sapabilir veya niş konular için yanlış olabilir. Tanıdık olmayan yanıtları bağımsız olarak doğrulayın.';

  @override
  String get classroomsJoined => 'Sınıfa katıldınız!';

  @override
  String get classroomsJoinAction => 'Sınıfa Katıl';

  @override
  String get classroomsJoinTooltip => 'Bir sınıfa katıl';

  @override
  String get classroomsJoinTitle => 'Bir Sınıfa Katıl';

  @override
  String get classroomsJoinSubtitle => 'Öğretmeninizin verdiği kodu girin';

  @override
  String get classroomsCouldNotOpenLink => 'Bağlantı açılamadı';

  @override
  String get classroomsReorderTitle => 'Sınıfları yeniden sırala';

  @override
  String get classroomsNoClassroomsToReorder =>
      'Yeniden sıralanacak sınıf yok.';

  @override
  String get teacherPostAnnouncementAction => 'Duyuru yayınla';

  @override
  String get announcementAudienceEveryone => 'Herkes';

  @override
  String get teacherGreetingMorning => 'Günaydın';

  @override
  String get teacherGreetingAfternoon => 'İyi günler';

  @override
  String get teacherGreetingEvening => 'İyi akşamlar';

  @override
  String get teacherTodaysClasses => 'Bugünün Dersleri';

  @override
  String get teacherNoDate => 'Tarih yok';

  @override
  String get teacherUpcomingTestsSubtitle => 'Yaklaşan testler ve quizler';

  @override
  String get teacherNoClassesThisWeek => 'Bu hafta ders yok';

  @override
  String get teacherNoClassesThisWeekSub => 'Bu haftaki programınız boş';

  @override
  String get teacherTitleFieldLabel => 'Başlık *';

  @override
  String get teacherInstructionsLabel => 'Talimatlar';

  @override
  String get teacherLinkUrlLabel => 'Bağlantı / URL *';

  @override
  String get teacherLinkUrlHint => 'https://...';

  @override
  String get teacherDescriptionLabel => 'Açıklama';

  @override
  String get teacherMeetingTitleLabel => 'Toplantı başlığı *';

  @override
  String get teacherMeetingLinkLabel => 'Toplantı bağlantısı *';

  @override
  String get teacherMeetingLinkHint => 'Zoom / Meet / Teams bağlantısı';

  @override
  String get teacherStudentEmailLabel => 'Öğrenci e-postası veya kimliği';

  @override
  String get teacherTooltipRemoveStudent => 'Sınıftan kaldır';

  @override
  String get teacherCouldNotLoad => 'Yüklenemedi';

  @override
  String get teacherNoAssignmentsYet => 'Henüz ödev yok';

  @override
  String get teacherNoAssignmentsSub =>
      'İlk ödevi oluşturmak için + simgesine dokunun';

  @override
  String get teacherNoMaterialsYet => 'Henüz materyal yok';

  @override
  String get teacherNoMaterialsSub =>
      'Sınıfınızla bağlantılar, belgeler veya kaynaklar paylaşın';

  @override
  String get teacherNoMeetingsScheduled => 'Toplantı planlanmadı';

  @override
  String get teacherNoMeetingsSub =>
      'Sınıf toplantısı planlamak için + simgesine dokunun';

  @override
  String get teacherAttendanceOther => 'Diğer';

  @override
  String get teacherTotal => 'Toplam';

  @override
  String get mediaOpenExternally => 'Harici olarak aç';

  @override
  String get mediaUnableToLoad => 'Görüntü yüklenemedi';

  @override
  String get searchHint => 'Ara...';

  @override
  String get teacherInsightsTitle => 'Öğrenci Analizleri';

  @override
  String get teacherInsightsSubtitle =>
      'Akademik bilgilerini görmek için bir öğrenci seçin.';

  @override
  String get teacherInsightsNoStudents => 'Öğrenci bulunamadı.';

  @override
  String get teacherInsightsSearchHint => 'Öğrenci ara…';

  @override
  String get navDiplomas => 'Diplomalar';

  @override
  String get diplomasComingSoon => 'Diploma yönetimi yakında geliyor.';

  @override
  String get examDetailsSection => 'Ayrıntılar';

  @override
  String get examInfoTeacher => 'Öğretmen';

  @override
  String get examInfoAudience => 'Hedef kitle';

  @override
  String get examInfoDate => 'Tarih';

  @override
  String get examInfoTime => 'Saat';

  @override
  String get examInfoPeriod => 'Ders';

  @override
  String get examInfoDuration => 'Süre';

  @override
  String get examInfoSubject => 'Ders';

  @override
  String get examMaterialsSection => 'Ekli materyaller';

  @override
  String get examNoMaterials => 'Henüz ekli materyal yok.';

  @override
  String get examQuickActionsSection => 'Hızlı işlemler';

  @override
  String get examViewGradeTitle => 'Notunu gör';

  @override
  String get examViewGradeBody =>
      'Bu sınav tamamlandı. Sonucunuz için notlar sekmesini kontrol edin.';

  @override
  String get examViewGradeAction => 'Notları Aç';
}

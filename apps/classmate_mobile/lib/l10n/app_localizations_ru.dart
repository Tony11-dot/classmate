// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get menu => 'Меню';

  @override
  String get sectionCore => 'Основное';

  @override
  String get sectionSchoolTools => 'Школьные инструменты';

  @override
  String get sectionAccount => 'Аккаунт';

  @override
  String get navSchedule => 'Расписание';

  @override
  String get navClassrooms => 'Классы';

  @override
  String get navPractice => 'Практика';

  @override
  String get navInsights => 'Аналитика';

  @override
  String get navNova => 'NOVA';

  @override
  String get navMessages => 'Сообщения';

  @override
  String get navAttendance => 'Посещаемость';

  @override
  String get navGrades => 'Оценки';

  @override
  String get navAssignments => 'Задания';

  @override
  String get navMeetings => 'Занятия';

  @override
  String get navAnnouncements => 'Объявления';

  @override
  String get navNotifications => 'Уведомления';

  @override
  String get navSolutions => 'Решения';

  @override
  String get navExams => 'Экзамены';

  @override
  String get navForms => 'Формы';

  @override
  String get navHome => 'Главная';

  @override
  String get navTeacherWorkspace => 'Рабочее пространство';

  @override
  String get navTeacherAssessments => 'Оценивание и оценки';

  @override
  String get navSavedQuestions => 'Сохранённые вопросы';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navSettings => 'Настройки';

  @override
  String get navLogout => 'Выйти';

  @override
  String get roleTeacher => 'Учитель';

  @override
  String get roleAdmin => 'Администратор';

  @override
  String get roleSecretary => 'Секретарь';

  @override
  String get roleParent => 'Родитель';

  @override
  String get titleSchedule => 'Расписание';

  @override
  String get titleClasses => 'Классы';

  @override
  String get titlePractice => 'Практика';

  @override
  String get titleInsights => 'Аналитика';

  @override
  String get titleNova => 'NOVA';

  @override
  String get titleMessages => 'Сообщения';

  @override
  String get titleSolutions => 'Решения';

  @override
  String get titleExams => 'Экзамены';

  @override
  String get solutionsUploadAction => 'Загрузить';

  @override
  String get solutionsNoSubjectsAvailable => 'Предметы недоступны.';

  @override
  String solutionsNoSubjectsMatch(Object query) {
    return 'Предметы не найдены: «$query».';
  }

  @override
  String solutionsBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count книг',
      few: '$count книги',
      one: '1 книга',
    );
    return '$_temp0';
  }

  @override
  String get solutionsBooksTitle => 'Книги';

  @override
  String get solutionsAddBookTitle => 'Добавить книгу';

  @override
  String get solutionsBookTitleHint => 'Название книги…';

  @override
  String get solutionsAddBookAction => 'Добавить книгу';

  @override
  String get solutionsSearchBooks => 'Поиск книг';

  @override
  String get solutionsChooseSubjectFirst => 'Сначала выберите предмет.';

  @override
  String solutionsNoBooksYetBody(Object action) {
    return 'Книг пока нет.\nНажмите «$action», чтобы добавить первую.';
  }

  @override
  String solutionsNoBooksMatch(Object query) {
    return 'Книги не найдены: «$query».';
  }

  @override
  String get solutionsBookLabel => 'Книга';

  @override
  String get solutionsPagesFilterHint =>
      'Введите номер страницы и вопроса для фильтрации или оставьте пустым.';

  @override
  String get solutionsPageNumberLabel => 'Номер страницы';

  @override
  String get solutionsPageNumberHint => 'например, 42';

  @override
  String get solutionsQuestionNumberLabel => 'Номер вопроса';

  @override
  String get solutionsQuestionNumberHint => 'например, 3а или 7';

  @override
  String get solutionsViewSolutionsAction => 'Смотреть решения';

  @override
  String solutionsPageQuestionSummary(Object page, Object question) {
    return 'Стр. $page · Вопрос $question';
  }

  @override
  String get solutionsExactQuestionTitle => 'Решения для этого вопроса';

  @override
  String get solutionsExactQuestionEmptySubtitle =>
      'Для этого вопроса ещё ничего не загружено';

  @override
  String solutionsUploadsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count решений найдено',
      few: '$count решения найдено',
      one: '1 решение найдено',
    );
    return '$_temp0';
  }

  @override
  String get solutionsExactQuestionEmptyBody =>
      'Точного совпадения нет. Загрузите решение или проверьте соседние вопросы.';

  @override
  String get solutionsLoadMoreAction => 'Загрузить ещё';

  @override
  String get solutionsSamePageTitle => 'Другие вопросы на этой странице';

  @override
  String get solutionsSamePageEmptySubtitle =>
      'С этой страницы вопросов ещё не загружено';

  @override
  String get solutionsSamePageFallbackSubtitle =>
      'Дополнительный источник, если решение вашего вопроса ещё не загружено.';

  @override
  String get solutionsSamePageEmptyBody =>
      'На этой странице пока нет загрузок. Добавьте первую — это поможет другим.';

  @override
  String get solutionsVerifiedByNova => 'Проверено NOVA';

  @override
  String get solutionsUploadFileLimitReached => 'Достигнут лимит 10 файлов.';

  @override
  String solutionsUploadFilesAddedLimit(int count) {
    return 'Добавлено $count — лимит 10 файлов.';
  }

  @override
  String get solutionsUploadCompleteFields =>
      'Заполните предмет, книгу, страницу и вопрос.';

  @override
  String get solutionsUploadAddOneFile =>
      'Добавьте хотя бы одно изображение или PDF.';

  @override
  String solutionsUploadFileFailed(Object error) {
    return 'Ошибка загрузки файла: $error';
  }

  @override
  String solutionsUploadCreateFailed(Object error) {
    return 'Не удалось создать решение: $error';
  }

  @override
  String get solutionsUploadSuccess => 'Загружено успешно';

  @override
  String get solutionsUploadAddNewBookOption => '+ Добавить новую книгу…';

  @override
  String get solutionsUploadAddBookShortAction => 'Добавить';

  @override
  String get solutionsUploadTitle => 'Загрузить решение';

  @override
  String get solutionsUploadSubtitle =>
      'Только изображения и PDF. NOVA проверяет и модерирует загрузки.';

  @override
  String get solutionsUploadNoBooksAbove => 'Книг нет — добавьте выше';

  @override
  String get solutionsUploadCaptionOptional => 'Подпись (необязательно)';

  @override
  String get solutionsUploadImagesAction => 'Изображения';

  @override
  String get solutionsUploadPdfAction => 'PDF';

  @override
  String solutionsUploadFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'файлов выбрано',
      few: 'файла выбрано',
      one: 'файл выбран',
    );
    return '$count / 10 $_temp0';
  }

  @override
  String get solutionsUploadSomeFilesFailed =>
      'Некоторые файлы не загрузились.';

  @override
  String get solutionsUploadRetryFailedFiles =>
      'Повторить для неудачных файлов';

  @override
  String get solutionsUploadSubmittingAction => 'Загрузка…';

  @override
  String get solutionsUploadSubmitAction => 'Загрузить решение';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsSubtitle => 'Оформление, язык и аккаунт';

  @override
  String get settingsAppearance => 'Оформление';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSystem => 'Как в системе';

  @override
  String get settingsAccentColour => 'Акцентный цвет';

  @override
  String get settingsAccentSubtitle =>
      'Оттенок, используемый во всём приложении';

  @override
  String get settingsReduceMotion => 'Уменьшить анимацию';

  @override
  String get settingsReduceMotionSubtitle =>
      'Меньше анимаций во всём приложении';

  @override
  String get settingsAccount => 'Аккаунт';

  @override
  String get settingsLogout => 'Выйти';

  @override
  String get settingsLogoutSubtitle => 'Выйти на этом устройстве';

  @override
  String get settingsThemeSystem => 'Как в системе';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsLanguageSearchHint => 'Поиск языка...';

  @override
  String get teacherWorkspaceSubtitle =>
      'Посещаемость, списки и оценки в мобильном приложении.';

  @override
  String get teacherMetricSessionsToday => 'Уроков сегодня';

  @override
  String get teacherMetricTeachingGroups => 'Групп';

  @override
  String get teacherMetricAssessments => 'Контрольных работ';

  @override
  String get teacherQuickActions => 'Быстрые действия';

  @override
  String get teacherNoDateAvailable => 'Дата недоступна';

  @override
  String get teacherNoTeachingSlotsToday => 'Уроков на сегодня нет.';

  @override
  String get teacherUpcomingAssessments => 'Предстоящие проверки';

  @override
  String get teacherUpcomingAssessmentsSubtitle => 'Из журнала оценивания';

  @override
  String get teacherNoAssessmentsYet => 'Контрольных работ ещё нет.';

  @override
  String get teacherUnassignedSlot => 'Свободный слот';

  @override
  String get teacherNoCohort => 'Класс не назначен';

  @override
  String get teacherCourseFallback => 'Предмет';

  @override
  String teacherPeriod(Object number) {
    return 'Период $number';
  }

  @override
  String get teacherLoadErrorTitle =>
      'Не удалось загрузить рабочее пространство';

  @override
  String get teacherClassroomsLoadError =>
      'Не удалось загрузить классы. Потяните для обновления.';

  @override
  String get teacherClassroomsLoadTimeout =>
      'Загрузка классов заняла слишком долго. Потяните для обновления.';

  @override
  String get teacherClassroomsLoadNetwork =>
      'Нет подключения. Проверьте сеть и попробуйте снова.';

  @override
  String get teacherClassroomsSubtitle => 'Ваши учебные пространства';

  @override
  String get teacherClassroomsNoCohorts =>
      'К этому учителю ещё не привязаны классы.';

  @override
  String teacherClassroomsCohort(Object cohortId) {
    return 'Класс $cohortId';
  }

  @override
  String get teacherClassroomsGeneratingJoinCode => 'Создание…';

  @override
  String get teacherClassroomsCreateJoinCode => 'Создать код входа';

  @override
  String get teacherClassroomsLiveJoinCode => 'Активный код входа';

  @override
  String teacherClassroomsExpiresAt(Object value) {
    return 'Истекает $value';
  }

  @override
  String get teacherClassroomsRoster => 'Список учеников';

  @override
  String get teacherClassroomsNoStudents => 'В этом классе пока нет учеников.';

  @override
  String get teacherAttendanceLoadError =>
      'Не удалось загрузить посещаемость. Потяните для обновления.';

  @override
  String get teacherAttendanceLoadTimeout =>
      'Загрузка посещаемости заняла слишком долго.';

  @override
  String get teacherAttendanceLoadNetwork => 'Нет подключения. Проверьте сеть.';

  @override
  String get teacherAttendanceSubtitle => 'Журнал посещаемости';

  @override
  String get teacherAttendanceTodaySessions => 'Уроки сегодня';

  @override
  String teacherAttendanceSessionSummary(
    Object cohort,
    Object grade,
    Object date,
    Object period,
  ) {
    return '$cohort · $grade класс · $date · Период $period';
  }

  @override
  String get teacherAttendanceChanged => 'Изменено';

  @override
  String get teacherAttendanceNoteLabel => 'Заметка';

  @override
  String get teacherAttendanceClassNotesLabel => 'Заметки урока';

  @override
  String get teacherAttendanceClassNotesHint => 'Что прошли на этом уроке…';

  @override
  String get teacherAttendanceSaving => 'Сохранение…';

  @override
  String get teacherAttendanceSaveAll => 'Сохранить посещаемость';

  @override
  String teacherAttendanceSaveCount(int count) {
    return 'Сохранить $count записей';
  }

  @override
  String get teacherAttendanceSaved => 'Посещаемость сохранена';

  @override
  String get retry => 'Повторить';

  @override
  String get scheduleRefreshTooFast => 'Слишком часто. Подождите.';

  @override
  String get scheduleSessionExpired =>
      'Срок сессии истёк. Пожалуйста, войдите снова.';

  @override
  String get scheduleNotOnboarded =>
      'Профиль ученика ещё не настроен. Попросите администратора школы назначить вас в класс.';

  @override
  String get scheduleLoadError => 'Не удалось загрузить расписание';

  @override
  String get scheduleSelectedDay => 'Сегодня';

  @override
  String scheduleClassCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count уроков',
      few: '$count урока',
      one: '1 урок',
    );
    return '$_temp0';
  }

  @override
  String get scheduleNextUp => 'Следующий';

  @override
  String get scheduleNoMoreClasses => 'Уроков больше нет';

  @override
  String get scheduleNoClassesTitle => 'В этот день уроков нет';

  @override
  String scheduleNoClassesSubtitle(Object day) {
    return '$day свободен.';
  }

  @override
  String get scheduleClassFallback => 'Урок';

  @override
  String get scheduleNoSubjectLocation => 'No subject or location yet';

  @override
  String get scheduleNotes => 'Notes';

  @override
  String get scheduleGoToClassroom => 'Go to Classroom';

  @override
  String get loginTitle => 'Вход для учеников и учителей';

  @override
  String get loginSubtitle => 'Войдите, чтобы продолжить';

  @override
  String get loginSignIn => 'Войти';

  @override
  String get loginSigningIn => 'Вход…';

  @override
  String get loginEmailLabel => 'Email или имя пользователя';

  @override
  String get loginPasswordLabel => 'Пароль';

  @override
  String get profileNotAvailable => 'Недоступно';

  @override
  String get profileSchoolInfo => 'Информация о школе';

  @override
  String get profileFullName => 'Полное имя';

  @override
  String get profileRole => 'Роль';

  @override
  String get profileSchoolId => 'ID школы';

  @override
  String get profileCohortId => 'ID группы';

  @override
  String get profileAccountInfo => 'Данные аккаунта';

  @override
  String get profileUsername => 'Имя пользователя';

  @override
  String get profileUsernameHint => 'имя_пользователя';

  @override
  String get profileContactEmail => 'Контактный email';

  @override
  String get profileEmailAddress => 'Email адрес';

  @override
  String get profileEmailHint => 'вы@example.com';

  @override
  String get profileBirthday => 'Дата рождения';

  @override
  String get profileSecurity => 'Безопасность';

  @override
  String get profileSelectBirthday => 'Выберите дату рождения';

  @override
  String get profilePasswordUpdated => 'Пароль обновлён';

  @override
  String get profileSave => 'Сохранить';

  @override
  String get profileEmptyValue => '—';

  @override
  String get profileChangePassword => 'Изменить пароль';

  @override
  String get profileCurrentPassword => 'Текущий пароль';

  @override
  String get profileNewPassword => 'Новый пароль';

  @override
  String get profileConfirmNewPassword => 'Подтвердите новый пароль';

  @override
  String get profileUpdatePassword => 'Обновить пароль';

  @override
  String get profilePasswordAllFieldsRequired => 'Все поля обязательны';

  @override
  String get profilePasswordMinLength =>
      'Новый пароль должен содержать не менее 8 символов';

  @override
  String get profilePasswordMismatch => 'Пароли не совпадают';

  @override
  String get profilePasswordNotAuthenticated => 'Нет авторизации';

  @override
  String get profilePasswordIncorrect => 'Текущий пароль неверный';

  @override
  String get profilePasswordGenericError =>
      'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get editProfileTitle => 'Редактировать профиль';

  @override
  String get editProfileSchool => 'Школа';

  @override
  String get editProfileSchoolPublic => 'Школа видна всем';

  @override
  String get editProfileGradePublic => 'Класс виден всем';

  @override
  String get editProfileMajors => 'Специализации';

  @override
  String get editProfileMajorsPublic => 'Специализации видны всем';

  @override
  String get editProfileBio => 'О себе';

  @override
  String get editProfileBioPublic => 'Биография видна всем';

  @override
  String get editProfileStatus => 'Статус';

  @override
  String get editProfileStatusPublic => 'Статус виден всем';

  @override
  String get classroomsYourClassrooms => 'Ваши классы';

  @override
  String get classroomsReorder => 'Изменить порядок классов';

  @override
  String classroomsCount(Object count) {
    return '$count классов';
  }

  @override
  String get classroomsSearchHint => 'Поиск классов…';

  @override
  String get classroomsNoSearchMatches => 'Классы не найдены';

  @override
  String get classroomsClassroomLabel => 'Класс';

  @override
  String get classroomsLoadingLatestMessage => 'Загрузка последнего сообщения…';

  @override
  String get classroomsTapToOpen => 'Нажмите, чтобы открыть класс';

  @override
  String get classroomsNoMessagesYet => 'Сообщений пока нет';

  @override
  String get classroomsMessageFallback => 'Сообщение';

  @override
  String get examsLoadError => 'Не удалось загрузить экзамены';

  @override
  String get examsAllFilter => 'Все';

  @override
  String get examsFormsSubtitle => 'Формы и опросы';

  @override
  String get examsOnlySubtitle => 'Предстоящие и прошедшие экзамены';

  @override
  String get examsUpcomingStat => 'Предстоящих';

  @override
  String get examsOpenFormsStat => 'Открытых форм';

  @override
  String get examsCountdownPast => 'Прошёл';

  @override
  String get examsCountdownTomorrow => 'Завтра';

  @override
  String examsCountdownInDays(Object days) {
    return 'Через $days дн.';
  }

  @override
  String get examsNoExamsPublished => 'Экзаменов пока нет.';

  @override
  String get examsNoFormsPublished => 'Форм пока нет.';

  @override
  String examsNoExamsForFilter(Object subject) {
    return 'Экзаменов по предмету «$subject» нет.';
  }

  @override
  String examsNoFormsForFilter(Object subject) {
    return 'Форм по предмету «$subject» нет.';
  }

  @override
  String examsMaterialsCount(Object count) {
    return '$count материалов';
  }

  @override
  String get examsOpenState => 'Открыт';

  @override
  String get examsClosedState => 'Закрыт';

  @override
  String examsQuestionsCount(Object count) {
    return '$count вопросов';
  }

  @override
  String examsResponsesCount(Object count) {
    return '$count ответов';
  }

  @override
  String get insightsTrendBaseline => 'Исходный уровень';

  @override
  String get insightsTrendImproving => 'Улучшается';

  @override
  String get insightsTrendDropping => 'Падает';

  @override
  String get insightsTrendStable => 'Стабильно';

  @override
  String get insightsHeadlineIntervention => 'Время для вмешательства';

  @override
  String get insightsHeadlineSignals => 'Несколько сигналов требуют внимания';

  @override
  String get insightsHeadlineMomentum => 'Отличный момент для рывка';

  @override
  String get insightsBodyAttendance =>
      'Сначала улучшите посещаемость — это быстро повлияет на все остальные показатели.';

  @override
  String insightsBodyWeakTrend(Object subject) {
    return '$subject и падающий тренд практики — главная зона риска. Начните с этого.';
  }

  @override
  String insightsBodyLeverage(Object subject) {
    return '$subject — ваша точка опоры. Используйте его для уверенности.';
  }

  @override
  String get insightsBodyConsistency =>
      'Продолжайте короткие фокусные сессии. Ближайшие дни важнее одной идеальной недели.';

  @override
  String get insightsInterventionScoreTitle => 'Оценка ситуации';

  @override
  String insightsInterventionScoreBody(Object count) {
    return '$count активных сигналов определяют следующий шаг.';
  }

  @override
  String get insightsRecoveryPathTitle => 'Быстрый путь к восстановлению';

  @override
  String get insightsRecoveryPathDefault =>
      'Сначала посещаемость и стабильность.';

  @override
  String insightsRecoveryPathTopic(Object topic, Object subject) {
    return 'Повторите тему $topic по предмету $subject.';
  }

  @override
  String get insightsProjectedDirectionTitle => 'Прогноз';

  @override
  String insightsProjectedDirectionBody(Object trend) {
    return '$trend на основе последних 7 и 30 дней практики.';
  }

  @override
  String get insightsLoadingTitle => 'Загрузка аналитики';

  @override
  String get insightsLoadingSubtitle => 'Строим ваш предиктивный дашборд.';

  @override
  String get insightsNotReadyTitle => 'Аналитика ещё не готова';

  @override
  String get insightsEmptyTitle => 'Аналитики пока нет';

  @override
  String get insightsEmptySubtitle =>
      'Используйте практику и школьные инструменты, чтобы ClassMate мог анализировать ваш прогресс.';

  @override
  String get insightsGradeAverage => 'Ср. балл';

  @override
  String get insightsAccuracy => 'Точность';

  @override
  String get insightsOpenNova => 'Открыть NOVA';

  @override
  String get insightsOpenNovaPrompt =>
      'Помоги мне улучшить слабую область на основе моей аналитики ClassMate.';

  @override
  String get insightsPredictiveRecoveryPlanTitle =>
      'Предиктивный план восстановления';

  @override
  String get insightsPracticeNow => 'Практиковать сейчас';

  @override
  String get insightsPredictiveModulesTitle => 'Предиктивный анализ';

  @override
  String get insightsPredictiveModulesSubtitle => 'Прогноз успеваемости';

  @override
  String get insightsAnnouncementsPressureTitle => 'Нагрузка';

  @override
  String get insightsAnnouncementsPressureSubtitle =>
      'Текущая учебная нагрузка';

  @override
  String get insightsAiCoachTitle => 'Советы AI-наставника';

  @override
  String get insightsAiCoachLoadingSubtitle => 'Загрузка советов AI.';

  @override
  String get insightsAiCoachUnavailableSubtitle =>
      'AI-советы для этого аккаунта пока недоступны.';

  @override
  String get insightsAskNova => 'Спросить NOVA';

  @override
  String get insightsAskNovaPrompt =>
      'Составь мне план восстановления на основе моей аналитики.';

  @override
  String get insightsAiStudyCoachTitle => 'AI-наставник';

  @override
  String get insightsSchoolToolsTitle => 'Школьные инструменты';

  @override
  String get insightsSchoolToolsSubtitle =>
      'Перейдите напрямую к важным разделам.';

  @override
  String get tutorUntitledChat => 'Чат без названия';

  @override
  String get tutorNewChat => 'Новый чат';

  @override
  String tutorFailedToOpenSeededChat(Object error) {
    return 'Не удалось открыть чат: $error';
  }

  @override
  String tutorFailedToCreateChat(Object error) {
    return 'Не удалось создать чат: $error';
  }

  @override
  String get tutorRenameChatTitle => 'Переименовать чат';

  @override
  String get tutorChatNameHint => 'Название чата';

  @override
  String get tutorCancel => 'Отмена';

  @override
  String get tutorHide => 'Скрыть';

  @override
  String get tutorHideChatTitle => 'Скрыть чат';

  @override
  String get tutorHideChatSubtitle => 'Скрывает этот чат на устройстве.';

  @override
  String get tutorHideChatConfirmTitle => 'Скрыть чат?';

  @override
  String get tutorHideChatConfirmBody =>
      'Чат исчезнет из списка на этом устройстве, но останется на сервере.';

  @override
  String get tutorTapToOpenHistory => 'Нажмите для просмотра истории';

  @override
  String get tutorAiTutorSubtitle => 'Ваш персональный AI-репетитор';

  @override
  String get tutorHeroBody => 'История чатов, удобные темы, быстрый доступ.';

  @override
  String get tutorStartFreshConversation => 'Начать новый разговор';

  @override
  String get tutorSearchHistoryHint => 'Поиск в истории чатов';

  @override
  String get chatComposerDefaultHint => 'Написать сообщение…';

  @override
  String get chatComposerReplyingToMessage => 'Ответ на сообщение';

  @override
  String get chatComposerReplyFallback => 'Ответить';

  @override
  String get chatComposerMicHint =>
      'Нажмите для голосовой заметки или удержите для записи';

  @override
  String get chatComposerRecordingTitle => 'Запись';

  @override
  String get chatComposerReleaseToSend => 'Отпустите для отправки';

  @override
  String get chatComposerCancelTitle => 'Отмена';

  @override
  String get chatComposerLockTitle => 'Блокировка';

  @override
  String get chatComposerSlideLeftToCancel => 'Смахните влево для отмены';

  @override
  String get chatComposerSlideUpToLock => 'Смахните вверх для блокировки';

  @override
  String get chatComposerReleaseToCancel => 'Отпустите для отмены';

  @override
  String get chatComposerKeepSlidingToCancel =>
      'Продолжайте смахивать для отмены';

  @override
  String get chatComposerReleaseToLock => 'Отпустите для блокировки';

  @override
  String get chatComposerRelease => 'Отпустить';

  @override
  String get chatComposerLock => 'Заблокировать';

  @override
  String get chatComposerRecordingPaused => 'Запись на паузе';

  @override
  String get chatComposerRecordingLocked => 'Запись заблокирована';

  @override
  String get chatComposerResumeHint =>
      'Нажмите продолжить, когда будете готовы';

  @override
  String get chatComposerLockedHint => 'Нажмите отправить, когда будете готовы';

  @override
  String get chatContextDismiss => 'Закрыть';

  @override
  String get chatContextCopyText => 'Копировать текст';

  @override
  String get chatContextDelete => 'Удалить';

  @override
  String get chatMessageInfoShortTitle => 'Инфо';

  @override
  String get chatMessageInfoStatus => 'Статус';

  @override
  String get chatMessageInfoStatusTime => 'Время статуса';

  @override
  String get chatMessageInfoSentAt => 'Отправлено';

  @override
  String get chatMessageInfoDeliveredAt => 'Доставлено в';

  @override
  String get chatMessageInfoSeenAt => 'Прочитано в';

  @override
  String get chatMessageInfoMessageType => 'Тип сообщения';

  @override
  String get chatMessageInfoTextType => 'Текст';

  @override
  String get chatMessageInfoEdited => 'Изменено';

  @override
  String get chatMessageInfoForwarded => 'Переслано';

  @override
  String get chatMessageInfoVoiceDuration => 'Длина голосового';

  @override
  String get chatMessageInfoSeenBy => 'Прочитано';

  @override
  String get chatMessageInfoDeliveredTo => 'Доставлено';

  @override
  String get chatMessageInfoEmptyBody => '(пусто)';

  @override
  String get chatMessageInfoReadLess => 'Свернуть';

  @override
  String get chatMessageInfoReadMore => 'Развернуть';

  @override
  String get chatMessageInfoSeen => 'Прочитано';

  @override
  String get chatMessageInfoDelivered => 'Доставлено';

  @override
  String get chatMessageInfoNotDelivered => 'Не доставлено';

  @override
  String get chatMessageInfoSent => 'Отправлено';

  @override
  String get chatMessageInfoPending => 'Ожидание';

  @override
  String get chatMessageInfoNotSeen => 'Не прочитано';

  @override
  String get chatMessageInfoType => 'Тип';

  @override
  String get chatMessageInfoDuration => 'Длительность';

  @override
  String get chatMessageInfoYes => 'Да';

  @override
  String get chatMessageInfoNo => 'Нет';

  @override
  String get chatMessageInfoDeleteState => 'Состояние удаления';

  @override
  String get chatReactionDetailsTitle => 'Реакции';

  @override
  String get chatReactionAddAction => 'Добавить реакцию';

  @override
  String get chatReactionEmptyState => 'Реакций пока нет';

  @override
  String get chatReactionSingle => 'Реакция';

  @override
  String get chatReactionTapToRemove => 'Нажмите для удаления';

  @override
  String chatReactionYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' · $count',
      one: '',
    );
    return 'Вы$_temp0';
  }

  @override
  String chatReactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count реакции',
      one: 'Реакция',
    );
    return '$_temp0';
  }

  @override
  String get chatEmojiPickerTitle => 'Эмодзи';

  @override
  String get chatEmojiPickerSearchHint => 'Поиск эмодзи';

  @override
  String get chatEmojiPickerEmptyState => 'Эмодзи не найдены';

  @override
  String get chatCameraTitle => 'Камера';

  @override
  String get chatCameraUseAction => 'Использовать';

  @override
  String get chatCameraGalleryAction => 'Галерея';

  @override
  String chatCameraSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count выбрано',
      one: '1 выбрано',
      zero: '0 выбрано',
    );
    return '$_temp0';
  }

  @override
  String get chatMediaPreviewEmptyState => 'Нечего показывать';

  @override
  String get chatMediaPreviewDrawCropAction => 'Рисовать и обрезать';

  @override
  String get chatMediaPreviewRotateLeftAction => 'Повернуть влево';

  @override
  String get chatMediaPreviewRotateRightAction => 'Повернуть вправо';

  @override
  String get chatMediaPreviewMirrorAction => 'Отразить';

  @override
  String get chatMediaPreviewResetAction => 'Сбросить';

  @override
  String get chatMediaPreviewRemoveAction => 'Удалить';

  @override
  String get chatMediaPreviewCaptionHint => 'Добавить подпись…';

  @override
  String tutorPlanSelectedPlaceholder(Object plan) {
    return '$plan выбран. Оплата пока в тестовом режиме.';
  }

  @override
  String get tutorFailedToLoadChats => 'Не удалось загрузить чаты';

  @override
  String get tutorNoChatsYet => 'Чатов пока нет';

  @override
  String get tutorNoChatsMatchSearch => 'Чаты не найдены';

  @override
  String get tutorCreateFirstChat => 'Создать первый чат';

  @override
  String get tutorPlansTitle => 'Планы NOVA';

  @override
  String tutorPlansSubtitle(Object model) {
    return 'На основе стоимости $model с ежемесячными лимитами.';
  }

  @override
  String get tutorPlanPriceFree => 'Бесплатно';

  @override
  String tutorPlanPriceMonthly(Object price) {
    return '$price\$/мес';
  }

  @override
  String get tutorPromptsLeft => 'Запросов осталось';

  @override
  String get tutorUploadsLeft => 'Загрузок осталось';

  @override
  String get tutorVoiceLeft => 'Осталось голосовых';

  @override
  String tutorUsageValue(Object remaining, Object total) {
    return '$remaining/$total';
  }

  @override
  String tutorVoiceUsageValue(Object remaining, Object total) {
    return '$remaining/$total мин';
  }

  @override
  String get tutorPaymentMethodsTitle => 'Способы оплаты';

  @override
  String tutorPaymentMethodsSubtitle(Object plan) {
    return 'Оплата в тестовом режиме. Тариф: $plan.';
  }

  @override
  String get tutorCardCheckoutTitle => 'Карта';

  @override
  String get tutorCardCheckoutSubtitle =>
      'Visa, Mastercard, AmEx — тестовый шлюз.';

  @override
  String get tutorApplePayTitle => 'Apple Pay';

  @override
  String get tutorApplePaySubtitle => 'Тестовый кошелёк для iPhone и веба.';

  @override
  String get tutorBankTransferTitle => 'Банковский перевод';

  @override
  String get tutorBankTransferSubtitle =>
      'Банковский счёт ClassMate открывается. Реквизиты появятся позже.';

  @override
  String get tutorPlanStarterName => 'Starter';

  @override
  String get tutorPlanStarterTagline => 'Начните работу с AI-репетитором';

  @override
  String get tutorPlanPlusName => 'Plus';

  @override
  String get tutorPlanPlusTagline => 'Расширенные возможности NOVA';

  @override
  String get tutorPlanProName => 'Pro';

  @override
  String get tutorPlanProTagline => 'Максимальные возможности NOVA';

  @override
  String get tutorPlanSchoolSeatName => 'Школьное место';

  @override
  String get tutorPlanSchoolSeatTagline =>
      'Для школ — оплата за ученика или сотрудника.';

  @override
  String tutorPlanBulletPromptsMonthly(Object count) {
    return '$count запросов NOVA в месяц';
  }

  @override
  String tutorPlanBulletPromptsPerSeatMonthly(Object count) {
    return '$count запросов NOVA на место в месяц';
  }

  @override
  String tutorPlanBulletUploads(Object count) {
    return '$count загрузок изображений или файлов';
  }

  @override
  String tutorPlanBulletVoiceMinutes(Object count) {
    return '$count минут голосовой транскрипции';
  }

  @override
  String tutorEstimatedCostCeilingFree(Object cost) {
    return 'Оценочный потолок затрат: $cost\$/мес';
  }

  @override
  String tutorEstimatedCostCeilingPaid(Object cost, Object margin) {
    return 'Оценочный потолок затрат: $cost\$/мес · маржа $margin%';
  }

  @override
  String tutorTimeMinutesShort(Object count) {
    return '$countм';
  }

  @override
  String tutorTimeHoursShort(Object count) {
    return '$countч';
  }

  @override
  String get tutorVoiceMessageFallback => 'Голосовое сообщение';

  @override
  String get tutorFileFallback => 'Файл';

  @override
  String get tutorCopy => 'Копировать';

  @override
  String get tutorEditMessage => 'Редактировать';

  @override
  String get tutorCopied => 'Скопировано';

  @override
  String get tutorLoadedIntoComposer => 'Загружено в поле ввода';

  @override
  String get tutorTakePhoto => 'Сделать фото';

  @override
  String get tutorRecordVideo => 'Записать видео';

  @override
  String get tutorChooseFromGallery => 'Выбрать из галереи';

  @override
  String get tutorPreviewTitle => 'Предпросмотр';

  @override
  String get tutorThinking => 'Думаю…';

  @override
  String get tutorDone => 'Готово.';

  @override
  String get tutorFailedToStreamReply => 'Ошибка получения ответа';

  @override
  String get tutorUnsupportedFilesMessage =>
      'NOVA поддерживает изображения, документы и текст. Видео и аудио не поддерживаются.';

  @override
  String get tutorNoAudioCaptured => 'Аудио не записано.';

  @override
  String get tutorVoiceLimitReachedTitle => 'Голосовой лимит исчерпан';

  @override
  String get tutorVoiceLimitReachedMessage =>
      'В вашем плане NOVA не хватает голосовых минут для этой транскрипции.';

  @override
  String get tutorTranscriptionFailed =>
      'Транскрипция не удалась. Попробуйте ещё раз.';

  @override
  String get tutorMicrophonePermissionRequired =>
      'Требуется доступ к микрофону.';

  @override
  String get tutorPlanLimitReachedTitle => 'Лимит плана NOVA исчерпан';

  @override
  String get tutorPlanLimitReachedMessage =>
      'Лимит запросов или загрузок на этот месяц исчерпан.';

  @override
  String get tutorSendFailed => 'Ошибка отправки.';

  @override
  String tutorCurrentPlanUsageSummary(
    Object plan,
    Object prompts,
    Object uploads,
    Object voice,
  ) {
    return 'План: $plan · $prompts запросов · $uploads загрузок · $voice';
  }

  @override
  String get tutorReviewPlansInHome => 'Просмотреть планы в NOVA';

  @override
  String get tutorCouldNotOpenAttachment => 'Не удалось открыть вложение.';

  @override
  String get tutorAttachmentUnavailable => 'Вложение недоступно.';

  @override
  String get tutorImageUnavailable => 'Изображение недоступно';

  @override
  String get tutorYou => 'Вы';

  @override
  String get tutorRegenerate => 'Повторить';

  @override
  String get tutorEmptyStateTitle => 'Задайте вопрос';

  @override
  String get tutorEmptyStateBody =>
      'Попросите NOVA объяснить концепцию, сделать таблицу или помочь с подготовкой.';

  @override
  String get tutorPromptSuggestionSummarizeNotes =>
      'Суммируй мои заметки к уроку';

  @override
  String get tutorPromptSuggestionRevisionTable =>
      'Сделай таблицу для повторения';

  @override
  String get tutorPromptSuggestionQuizMe => 'Проверь меня по этой теме';

  @override
  String get tutorMessageNovaHint => 'Напишите NOVA…';

  @override
  String get tutorHeaderSubtitleReady =>
      'Структурированные ответы, таблицы и помощь в учёбе';

  @override
  String get tutorYourNovaPlanTitle => 'Ваш план NOVA';

  @override
  String get tutorYourNovaPlanMessage =>
      'Просмотрите лимиты запросов, загрузок и голоса, затем вернитесь в NOVA.';

  @override
  String get tutorExplainTitle => 'NOVA Объясняет';

  @override
  String get classroomsThreadTypeClassroom => 'Класс';

  @override
  String get classroomsThreadTypeGroup => 'Группа';

  @override
  String get classroomsThreadTypeDirectMessage => 'Личное сообщение';

  @override
  String get classroomsThreadTypeDirectMessageShort => 'DM';

  @override
  String get messagesBlockedPeopleTitle => 'Заблокированные';

  @override
  String get messagesStartChatAction => 'Начать чат';

  @override
  String messagesLoadFailed(Object error) {
    return 'Не удалось загрузить сообщения: $error';
  }

  @override
  String get messagesSearchHint => 'Поиск сообщений…';

  @override
  String get messagesNoResults => 'Сообщений не найдено';

  @override
  String get messagesRequestsSection => 'Запросы';

  @override
  String get messagesPendingApprovals => 'Ожидают подтверждения';

  @override
  String get messagesChatsSection => 'Чаты';

  @override
  String get messagesAllChatsSection => 'Все чаты';

  @override
  String messagesConversationCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count разговоров',
      few: '$count разговора',
      one: '1 разговор',
    );
    return '$_temp0';
  }

  @override
  String get messagesRequestReviewStatus => 'Рассмотреть';

  @override
  String messagesPeopleLoadFailed(Object error) {
    return 'Не удалось загрузить людей: $error';
  }

  @override
  String get messagesSearchPeopleHint => 'Поиск людей';

  @override
  String get messagesNewGroupTitle => 'Новая группа';

  @override
  String get messagesNewGroupSubtitle => 'Создать групповой чат';

  @override
  String get messagesGroupNameHint => 'Название группы';

  @override
  String get messagesCreateGroupAction => 'Создать группу';

  @override
  String get messagesBlockedPersonFallback => 'этого пользователя';

  @override
  String get messagesUnblockPersonTitle => 'Разблокировать?';

  @override
  String messagesUnblockPersonBody(Object name) {
    return 'Разрешить $name писать вам снова?';
  }

  @override
  String get messagesUnblockAction => 'Разблокировать';

  @override
  String messagesUnblockedToast(Object name) {
    return '$name разблокирован';
  }

  @override
  String messagesBlockedPeopleLoadFailed(Object error) {
    return 'Не удалось загрузить заблокированных: $error';
  }

  @override
  String get messagesNoBlockedPeople => 'Заблокированных нет';

  @override
  String get messagesUnknownUser => 'Неизвестный пользователь';

  @override
  String get messagesRequestTitle => 'Запрос сообщения';

  @override
  String messagesRequestLoadFailed(Object error) {
    return 'Не удалось загрузить запрос: $error';
  }

  @override
  String get messagesRequestBannerIncoming => 'Запрос на сообщение';

  @override
  String get messagesRequestBannerOutgoing => 'Ожидает подтверждения';

  @override
  String get messagesBlockAction => 'Заблокировать';

  @override
  String get messagesApproveAction => 'Одобрить';

  @override
  String get messagesRequestUnlockHint =>
      'Чат откроется, когда получатель одобрит ваше первое сообщение.';

  @override
  String get messagesThreadConversationFallback => 'Разговор';

  @override
  String get messagesThreadLeaveGroupTitle => 'Покинуть группу?';

  @override
  String get messagesThreadLeaveGroupBody =>
      'Вы перестанете получать сообщения из этой группы.';

  @override
  String get messagesThreadBlockPersonTitle => 'Заблокировать пользователя?';

  @override
  String get messagesThreadBlockPersonBody =>
      'Вы больше не сможете обмениваться сообщениями с этим пользователем.';

  @override
  String get messagesThreadPersonFallback => 'Пользователь';

  @override
  String get messagesThreadProfileInfoUnavailable => 'Профиль недоступен';

  @override
  String get messagesThreadParticipants => 'Участники';

  @override
  String get messagesThreadPeople => 'Люди';

  @override
  String get messagesThreadDeleteForMe => 'Удалить для меня';

  @override
  String get messagesThreadDeleteForEveryone => 'Удалить для всех';

  @override
  String get messagesThreadDeleteForEveryoneSubtitle =>
      'Удаляет для всех участников';

  @override
  String get messagesThreadSending => 'Отправка…';

  @override
  String get messagesThreadWaitingForApproval => 'Ожидает подтверждения';

  @override
  String get classroomsForwardSearchHint => 'Поиск классов или чатов…';

  @override
  String get classroomsForwardNewChat => 'Новый чат';

  @override
  String classroomsForwardLoadError(Object error) {
    return 'Не удалось загрузить чаты: $error';
  }

  @override
  String get classroomsForwardNoChatsFound => 'Чаты не найдены';

  @override
  String get classroomsForwardSectionClassrooms => 'Классы';

  @override
  String get classroomsForwardSectionDirectMessages => 'Личные сообщения';

  @override
  String get classroomsForwardCancel => 'Отмена';

  @override
  String get classroomsForwardAction => 'Переслать';

  @override
  String classroomsForwardCount(Object count) {
    return 'Переслать ($count)';
  }

  @override
  String get markRead => 'Отметить как прочитанное';

  @override
  String get markUnread => 'Отметить как непрочитанное';

  @override
  String get markAllRead => 'Отметить всё как прочитанное';

  @override
  String get filters => 'Фильтры';

  @override
  String get source => 'Источник';

  @override
  String get state => 'Статус';

  @override
  String get allSources => 'Все источники';

  @override
  String get allStates => 'Все статусы';

  @override
  String get unread => 'Непрочитанные';

  @override
  String get read => 'Прочитанные';

  @override
  String get clear => 'Очистить';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get thisWeek => 'На этой неделе';

  @override
  String get earlier => 'Ранее';

  @override
  String get openDetails => 'Открыть';

  @override
  String get total => 'Всего';

  @override
  String get local => 'Локальные';

  @override
  String get server => 'Сервер';

  @override
  String get notificationsSourceSystem => 'Система';

  @override
  String get notificationsHeroSubtitleStudent =>
      'Ваш центр уведомлений для объявлений, обновлений сервера и важной учебной активности в реальном времени.';

  @override
  String get notificationsHeroSubtitleTeacher =>
      'Ваш учительский центр уведомлений для объявлений, обновлений сервера и школьной активности в реальном времени.';

  @override
  String get notificationsFiltersSubtitle =>
      'Фильтруйте по источнику или статусу прочтения, чтобы быстрее разбирать входящие.';

  @override
  String get notificationsSearchSourcesHint => 'Поиск источников';

  @override
  String notificationsShowingSummary(Object shown, Object total) {
    return 'Показано $shown из $total уведомлений.';
  }

  @override
  String get notificationsEmptyForAccount =>
      'Для этого аккаунта сейчас нет уведомлений.';

  @override
  String get notificationsEmptyFiltered =>
      'По этим фильтрам уведомлений нет. Очистите фильтры, чтобы увидеть всю ленту.';

  @override
  String get notificationsEmpty => 'Сейчас уведомлений нет.';

  @override
  String get notificationsNewBadge => 'Новое';

  @override
  String get notificationsUnavailable =>
      'Это уведомление больше недоступно. Обновите список и попробуйте снова.';

  @override
  String get notificationsSeverityCritical => 'Критично';

  @override
  String get notificationsSeverityWarning => 'Предупреждение';

  @override
  String get notificationsSeverityInfo => 'Инфо';

  @override
  String get announcementsLoadError => 'Не удалось загрузить объявления';

  @override
  String get announcementsLoadTimeout => 'Превышено время ожидания';

  @override
  String get announcementsLoadNetwork => 'Нет подключения';

  @override
  String get announcementsAudienceTeacher => 'Учитель';

  @override
  String get announcementsAudienceAccount => 'Аккаунт';

  @override
  String get announcementsAudienceTeacherWorkspace => 'Рабочее пространство';

  @override
  String get announcementsLoadFailedTitle => 'Ошибка загрузки';

  @override
  String get announcementsLoadFailedHint => 'Потяните для повтора';

  @override
  String announcementsHeroSubtitle(Object audience) {
    return 'Объявления для $audience.';
  }

  @override
  String get announcementsLatestSourceLabel => 'Источник';

  @override
  String get announcementsNone => 'Нет';

  @override
  String announcementsUnreadCountTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count непрочитанных',
      few: '$count непрочитанных',
      one: '1 непрочитанное',
    );
    return '$_temp0';
  }

  @override
  String get announcementsAllReadTitle => 'Всё прочитано';

  @override
  String announcementsEmptyForAudience(Object audience) {
    return 'Объявлений для $audience пока нет.';
  }

  @override
  String announcementsLatestBody(Object title) {
    return 'Последнее: $title. Нажмите для прочтения.';
  }

  @override
  String get announcementsFiltersSubtitle => 'Фильтровать объявления';

  @override
  String get announcementsAllAnnouncements => 'Все объявления';

  @override
  String get announcementsSearchStatesHint => 'Поиск статусов';

  @override
  String announcementsSummarySourceSegment(Object source) {
    return 'источник: $source';
  }

  @override
  String announcementsSummaryStateSegment(Object state) {
    return 'статус: $state';
  }

  @override
  String announcementsShowingSummary(
    Object shown,
    Object total,
    Object sourceSegment,
    Object stateSegment,
  ) {
    return 'Показано $shown из $total объявлений$sourceSegment$stateSegment.';
  }

  @override
  String get announcementsNoMatchTitle => 'Ничего не найдено';

  @override
  String get announcementsNoPublishedTitle => 'Объявлений нет';

  @override
  String get announcementsNoMatchSubtitle => 'Попробуйте изменить фильтры.';

  @override
  String get announcementsClearFiltersHint => 'Очистить фильтры';

  @override
  String get announcementsPullToRefreshHint => 'Потяните для обновления';

  @override
  String get announcementsInboxTitle => 'Входящие';

  @override
  String get announcementsInboxSubtitle => 'Все объявления';

  @override
  String get meetingsLoadError => 'Не удалось загрузить занятия';

  @override
  String get meetingsLoadTimeout => 'Превышено время ожидания';

  @override
  String get meetingsLoadNetwork => 'Нет подключения';

  @override
  String get meetingsHeroSubtitle => 'Онлайн-занятия';

  @override
  String get meetingsJoinReadyMetric => 'Доступно';

  @override
  String get meetingsNoLinkMetric => 'Без ссылки';

  @override
  String get meetingsNoPostedTitle => 'Занятий пока нет';

  @override
  String get meetingsEmptyForAccount => 'Для вашего аккаунта занятий пока нет.';

  @override
  String meetingsLatestBody(Object title, Object updatedAt) {
    return '$title обновлено $updatedAt. Откройте для получения ссылки.';
  }

  @override
  String get meetingsPullToRefreshHint => 'Потяните для обновления.';

  @override
  String get meetingsFiltersSubtitle => 'Фильтр по предмету или наличию ссылки';

  @override
  String get meetingsAccessLabel => 'Доступ';

  @override
  String get meetingsAllMeetings => 'Все занятия';

  @override
  String get meetingsAccessReady => 'Доступно';

  @override
  String get meetingsAccessNoLink => 'Без ссылки';

  @override
  String get meetingsAccessNoLinkYet => 'Ссылки ещё нет';

  @override
  String get meetingsAccessSearchHint => 'Доступно / Без ссылки';

  @override
  String meetingsSummarySubjectSegment(Object subject) {
    return ' по $subject';
  }

  @override
  String meetingsSummaryAccessSegment(Object state) {
    return ' ($state)';
  }

  @override
  String meetingsShowingSummary(
    Object shown,
    Object total,
    Object subjectSegment,
    Object accessSegment,
  ) {
    return 'Показано $shown из $total занятий$subjectSegment$accessSegment.';
  }

  @override
  String get meetingsNoMatchTitle => 'Занятий не найдено';

  @override
  String get meetingsNoMatchSubtitle => 'Попробуйте изменить фильтры.';

  @override
  String get meetingsListSubtitle =>
      'Нажмите на занятие для просмотра деталей и ссылки.';

  @override
  String meetingsDateTimeValue(Object date, Object time) {
    return '$date · $time';
  }

  @override
  String meetingsSharedByValue(Object name) {
    return 'Поделился: $name';
  }

  @override
  String get meetingsPreviewFallback =>
      'Откройте занятие для просмотра ссылки и деталей класса.';

  @override
  String get meetingsNoValidLinkAttached =>
      'Действительной ссылки на занятие пока нет.';

  @override
  String get meetingsCouldNotOpenLink => 'Не удалось открыть ссылку.';

  @override
  String get meetingsNoLinkToCopy => 'Ссылки на занятие пока нет.';

  @override
  String get meetingsLinkCopied => 'Ссылка скопирована.';

  @override
  String get meetingsUnavailableTitle => 'Занятия недоступны';

  @override
  String get meetingsUnavailableSubtitle =>
      'Занятие не найдено. Возможно, оно было удалено или изменено.';

  @override
  String get meetingsUnavailableHint => 'Вернитесь и обновите список занятий.';

  @override
  String get meetingsNoLinkAttachedYet => 'Ссылка ещё не добавлена';

  @override
  String get meetingsAttachedLinkTitle => 'Ссылка на занятие';

  @override
  String get meetingsAttachedLinkMissingBody =>
      'Ссылка на занятие пока не добавлена.';

  @override
  String get meetingsDetailsTitle => 'Подробности';

  @override
  String get meetingsDetailsSubtitle => 'Информация о занятии';

  @override
  String get meetingsDetailClassroomLabel => 'Класс';

  @override
  String get meetingsSharedByLabel => 'Поделился';

  @override
  String get meetingsIdLabel => 'ID занятия';

  @override
  String get meetingsAttachedLinkSubtitle =>
      'Используйте ссылку для подключения или скопируйте её.';

  @override
  String get meetingsOpening => 'Открытие';

  @override
  String get meetingsOpenLink => 'Открыть';

  @override
  String get meetingsCopyLink => 'Копировать ссылку';

  @override
  String get meetingsAccessPanelTitle => 'Доступ к занятию';

  @override
  String get meetingsAccessPanelReadyBody =>
      'Откройте ссылку в браузере или приложении.';

  @override
  String get meetingsJoinAction => 'Войти';

  @override
  String get announcementsDetailLoadFailedHint =>
      'Не удалось загрузить объявление';

  @override
  String get announcementsUnavailableTitle => 'Объявления недоступны';

  @override
  String announcementsUnavailableSubtitle(Object audience) {
    return 'Объявление недоступно для $audience.';
  }

  @override
  String get announcementsUnavailableHint => 'Потяните для обновления';

  @override
  String announcementsPublishedReadStateBody(Object audience) {
    return 'Опубликовано для $audience.';
  }

  @override
  String get announcementsDetailsTitle => 'Подробности';

  @override
  String get announcementsDetailsSubtitle => '';

  @override
  String get announcementsSeverityLabel => 'Важность';

  @override
  String get announcementsCreatedLabel => 'Создано';

  @override
  String get announcementsIdLabel => 'ID';

  @override
  String get announcementsFullContentTitle => 'Содержание';

  @override
  String get announcementsFullContentSubtitle => 'Полный текст объявления';

  @override
  String get announcementsReadStateTitle => 'Статус';

  @override
  String get announcementsReadStateBodyRead => 'Прочитано';

  @override
  String get announcementsReadStateBodyUnread => 'Непрочитано';

  @override
  String get alertsTitle => 'Оповещения';

  @override
  String get alertsSubtitle => 'Важные сигналы';

  @override
  String get alertsAttendanceTitle => 'Посещаемость';

  @override
  String alertsAttendanceBody(Object rate) {
    return 'Ваш процент посещаемости: $rate%. Следите за пропусками.';
  }

  @override
  String get alertsWeakestSubjectTitle => 'Слабый предмет';

  @override
  String alertsWeakestSubjectBody(Object subject) {
    return '$subject требует наибольшего внимания по данным оценок.';
  }

  @override
  String get alertsPracticeWeakAreaTitle => 'Слабое место';

  @override
  String alertsPracticeWeakAreaBody(Object topic, Object subject) {
    return '$topic по предмету $subject — слабая тема прямо сейчас.';
  }

  @override
  String get alertsPracticeTrendDroppedTitle => 'Результаты снизились';

  @override
  String get alertsPracticeTrendDroppedBody =>
      'Ваши результаты практики снижаются';

  @override
  String get alertsEmpty => 'Оповещений нет';

  @override
  String get student => 'Ученик';

  @override
  String get classroomDetailPhoto => 'Фото';

  @override
  String get classroomDetailVoiceNote => 'Голосовая заметка';

  @override
  String get classroomDetailVideo => 'Видео';

  @override
  String get classroomDetailFile => 'Файл';

  @override
  String get classroomDetailEmptyValue => '(пусто)';

  @override
  String get classroomDetailAttachmentUnavailable => 'Вложение недоступно.';

  @override
  String get classroomDetailAudioUnavailable => 'Аудио недоступно.';

  @override
  String get classroomDetailCouldNotOpenAttachment =>
      'Не удалось открыть вложение.';

  @override
  String get classroomDetailVoiceMessage => 'Голосовое сообщение';

  @override
  String get classroomDetailVideoFile => 'Видеофайл';

  @override
  String get classroomDetailAttachedFile => 'Прикреплённый файл';

  @override
  String get classroomDetailAttachment => 'Вложение';

  @override
  String get classroomDetailPinAction => 'Закрепить';

  @override
  String get classroomDetailUnpinAction => 'Открепить';

  @override
  String get classroomDetailMessageInfoTitle => 'Информация о сообщении';

  @override
  String get classroomDetailForwardedSingle => 'Переслано';

  @override
  String classroomDetailForwardedMultiple(Object count) {
    return 'Переслано $count сообщений';
  }

  @override
  String get classroomDetailCannotForwardPending =>
      'Нельзя переслать в чат, ожидающий одобрения';

  @override
  String get classroomDetailCouldNotForwardSelected =>
      'Не удалось переслать выбранные сообщения';

  @override
  String classroomDetailSelectedCount(Object count) {
    return 'Выбрано: $count';
  }

  @override
  String classroomDetailDeleteCount(Object count) {
    return 'Удалить ($count)';
  }

  @override
  String get classroomDetailSelectAllTooltip => 'Выбрать все';

  @override
  String get classroomDetailCancelTooltip => 'Отмена';

  @override
  String get classroomDetailMicrophoneAccessTitle =>
      'Необходим доступ к микрофону';

  @override
  String get classroomDetailMicrophoneAccessBody =>
      'Разрешите доступ к микрофону в Настройки → ClassMate для голосовых заметок.';

  @override
  String get classroomDetailOpenSettingsAction => 'Открыть настройки';

  @override
  String classroomDetailForwardTargetNext(Object label) {
    return 'Следующий получатель: $label';
  }

  @override
  String get classroomDetailEditMessageTitle => 'Редактировать сообщение';

  @override
  String get classroomDetailEditMessageHint => 'Редактировать сообщение…';

  @override
  String get classroomDetailLeaveClassroomTitle => 'Покинуть класс?';

  @override
  String get classroomDetailLeaveClassroomBody =>
      'Вы будете удалены из этого класса.';

  @override
  String get classroomDetailLeaveAction => 'Покинуть';

  @override
  String get classroomDetailNoAssignmentsTitle => 'Заданий пока нет';

  @override
  String get classroomDetailNoAssignmentsSubtitle =>
      'В этом классе заданий нет.';

  @override
  String get classroomDetailAssignmentFallback => 'Задание';

  @override
  String get classroomDetailNoMaterialsTitle => 'Материалов пока нет';

  @override
  String get classroomDetailNoMaterialsSubtitle =>
      'В этом классе материалов нет.';

  @override
  String get classroomDetailMaterialFallback => 'Материал';

  @override
  String get classroomDetailNoMeetingsTitle => 'Занятий пока нет';

  @override
  String get classroomDetailNoMeetingsSubtitle => 'В этом классе занятий нет.';

  @override
  String get classroomDetailMeetingFallback => 'Занятие';

  @override
  String get classroomDetailCouldNotLoadPeople =>
      'Не удалось загрузить участников';

  @override
  String get classroomDetailNoPeopleTitle => 'Участников пока нет';

  @override
  String get classroomDetailNoPeopleSubtitle =>
      'В этом классе пока нет участников.';

  @override
  String get classroomDetailTabChat => 'Чат';

  @override
  String get classroomDetailTabMaterials => 'Материалы';

  @override
  String get classroomDetailTabPeople => 'Участники';

  @override
  String get classroomChatMediaSendPhoto => 'Отправить фото';

  @override
  String get classroomChatMediaSendPhotoSubtitle =>
      'Поделиться изображением в чате класса';

  @override
  String get classroomChatMediaSendVoiceMessage => 'Отправить голосовое';

  @override
  String get classroomChatMediaSendVoiceMessageSubtitle =>
      'Записать и отправить голосовую заметку';

  @override
  String get classroomDetailCouldNotLoadTab => 'Не удалось загрузить вкладку';

  @override
  String get classroomDetailDeletedByYou => 'Вы удалили это сообщение';

  @override
  String get classroomDetailDeletedMessage => 'Сообщение удалено';

  @override
  String get practiceSetupDifficultyEasy => 'Лёгкий';

  @override
  String get practiceSetupDifficultyMedium => 'Средний';

  @override
  String get practiceSetupDifficultyHard => 'Сложный';

  @override
  String get practiceSetupDifficultyOlympiad => 'Олимпиадный';

  @override
  String get practiceSetupDifficultyAdaptive => 'Адаптивный';

  @override
  String get practiceSetupModeLabelPractice => 'Практика';

  @override
  String get practiceSetupModeLabelFlashcards => 'Карточки';

  @override
  String get practiceSetupModeLabelSpeedRound => 'Скоростной раунд';

  @override
  String get practiceSetupModeLabelExamPrep => 'Подготовка к экзамену';

  @override
  String get practiceSetupModeLabelConceptBuilder => 'Изучение концепций';

  @override
  String get practiceSetupModeLabelAdaptive => 'Адаптивный';

  @override
  String get practiceSetupModeLabelBagrut => 'Багрут';

  @override
  String get practiceSetupModeSubtitlePractice =>
      'Сбалансированная ежедневная практика';

  @override
  String get practiceSetupModeSubtitleFlashcards => 'Карточки и самопроверка';

  @override
  String get practiceSetupModeSubtitleSpeedRound => 'Быстрые ответы';

  @override
  String get practiceSetupModeSubtitleExamPrep =>
      'Спокойный экзаменационный режим';

  @override
  String get practiceSetupModeSubtitleConceptBuilder => 'Изучение тем пошагово';

  @override
  String get practiceSetupModeSubtitleAdaptive =>
      'Подстраивается под ваш уровень';

  @override
  String get practiceSetupModeSubtitleBagrut => 'Формат экзамена';

  @override
  String get practiceSetupModeHelpPractice =>
      'Решайте, проверяйте, разбирайте — и двигайтесь дальше.';

  @override
  String get practiceSetupModeHelpFlashcards =>
      'Сначала попробуйте вспомнить ответ, потом открывайте карточку.';

  @override
  String get practiceSetupModeHelpSpeedRound =>
      'Скоростной раунд тренирует быстрое вспоминание. Доверяйте инстинктам.';

  @override
  String get practiceSetupModeHelpExamPrep =>
      'Подготовка к экзамену — спокойный формат, как настоящее занятие.';

  @override
  String get practiceSetupModeHelpConceptBuilder =>
      'Сначала изучите идею, потом применяйте её.';

  @override
  String get practiceSetupModeHelpAdaptive =>
      'Адаптивный режим меняет сложность в зависимости от результатов.';

  @override
  String get practiceSetupModeHelpBagrut =>
      'Режим Багрут — строгий экзаменационный стиль с разбором.';

  @override
  String get practiceSetupModeInfoTitle => 'Подробнее о режиме';

  @override
  String get practiceSetupHeroTitle => 'Начать сессию';

  @override
  String get practiceSetupHeroSubtitle => 'Выберите режим, время и сложность.';

  @override
  String get practiceSetupInfiniteLives => 'Бесконечные попытки';

  @override
  String practiceSetupLivesCount(Object count) {
    return '$count попыток';
  }

  @override
  String get practiceSetupAiTiming => 'Время AI';

  @override
  String practiceSetupSecondsShort(Object seconds) {
    return '$seconds с';
  }

  @override
  String practiceSetupQuestionsCount(Object count) {
    return '$count вопросов';
  }

  @override
  String practiceSetupSummarySubject(Object subject) {
    return 'Предмет: $subject';
  }

  @override
  String practiceSetupSummaryTopic(Object topic) {
    return 'Тема: $topic';
  }

  @override
  String practiceSetupSummaryMode(Object mode) {
    return 'Режим: $mode';
  }

  @override
  String practiceSetupSummaryDifficulty(Object difficulty) {
    return 'Сложность: $difficulty';
  }

  @override
  String practiceSetupSummaryQuestions(Object count) {
    return 'Вопросов: $count';
  }

  @override
  String practiceSetupSummaryTiming(Object timing) {
    return 'Время: $timing';
  }

  @override
  String practiceSetupSummaryLives(Object lives) {
    return 'Попытки: $lives';
  }

  @override
  String get practiceSetupSectionSubjectTopic => 'Предмет и тема';

  @override
  String get practiceSetupFieldSubject => 'Предмет';

  @override
  String get practiceSetupFieldSubjectHint => 'Выберите предмет';

  @override
  String get practiceSetupChooseSubject => 'Выберите предмет';

  @override
  String get practiceSetupFieldCustomSubject => 'Свой предмет';

  @override
  String get practiceSetupFieldCustomSubjectHint => 'Введите предмет';

  @override
  String get practiceSetupDialogCustomSubjectTitle => 'Свой предмет';

  @override
  String get practiceSetupDialogEnterSubject => 'Введите предмет';

  @override
  String get practiceSetupUseAction => 'Использовать';

  @override
  String get practiceSetupFieldTopic => 'Тема';

  @override
  String get practiceSetupFieldTopicHint => 'Выберите подтему';

  @override
  String get practiceSetupChooseTopic => 'Выберите тему';

  @override
  String get practiceSetupFieldCustomTopic => 'Своя тема';

  @override
  String get practiceSetupFieldCustomTopicHint => 'Введите тему';

  @override
  String get practiceSetupDialogCustomTopicTitle => 'Своя тема';

  @override
  String get practiceSetupDialogEnterTopic => 'Введите тему';

  @override
  String get practiceSubjectMath => 'Математика';

  @override
  String get practiceSubjectPhysics => 'Физика';

  @override
  String get practiceSubjectComputerScience => 'Информатика';

  @override
  String get practiceSubjectChemistry => 'Химия';

  @override
  String get practiceSubjectBiology => 'Биология';

  @override
  String get practiceSubjectEnglish => 'Английский';

  @override
  String get practiceSubjectArabic => 'Арабский';

  @override
  String get practiceSubjectHebrew => 'Иврит';

  @override
  String get practiceSubjectGeneralKnowledge => 'Общие знания';

  @override
  String get practiceTopicAllTopics => 'Все темы';

  @override
  String get practiceTopicAlgebra => 'Алгебра';

  @override
  String get practiceTopicLinearEquations => 'Линейные уравнения';

  @override
  String get practiceTopicQuadraticEquations => 'Квадратные уравнения';

  @override
  String get practiceTopicFunctions => 'Функции';

  @override
  String get practiceTopicGeometry => 'Геометрия';

  @override
  String get practiceTopicTriangles => 'Треугольники';

  @override
  String get practiceTopicCircles => 'Окружности';

  @override
  String get practiceTopicAnalyticGeometry => 'Аналитическая геометрия';

  @override
  String get practiceTopicTrigonometry => 'Тригонометрия';

  @override
  String get practiceTopicProbability => 'Теория вероятностей';

  @override
  String get practiceTopicStatistics => 'Статистика';

  @override
  String get practiceTopicSequences => 'Последовательности';

  @override
  String get practiceTopicCalculus => 'Математический анализ';

  @override
  String get practiceTopicLimits => 'Пределы';

  @override
  String get practiceTopicDerivatives => 'Производные';

  @override
  String get practiceTopicMechanics => 'Механика';

  @override
  String get practiceTopicKinematics => 'Кинематика';

  @override
  String get practiceTopicNewtonLaws => 'Законы Ньютона';

  @override
  String get practiceTopicForces => 'Силы';

  @override
  String get practiceTopicEnergy => 'Энергия';

  @override
  String get practiceTopicMomentum => 'Импульс';

  @override
  String get practiceTopicElectricity => 'Электричество';

  @override
  String get practiceTopicElectricField => 'Электрическое поле';

  @override
  String get practiceTopicCircuits => 'Электрические цепи';

  @override
  String get practiceTopicWaves => 'Волны';

  @override
  String get practiceTopicOptics => 'Оптика';

  @override
  String get practiceTopicThermodynamics => 'Термодинамика';

  @override
  String get practiceTopicConditions => 'Условия';

  @override
  String get practiceTopicBooleanLogic => 'Булева логика';

  @override
  String get practiceTopicIfElse => 'Условные операторы';

  @override
  String get practiceTopicNestedConditions => 'Вложенные условия';

  @override
  String get practiceTopicLoops => 'Циклы';

  @override
  String get practiceTopicVariables => 'Переменные';

  @override
  String get practiceTopicArrays => 'Массивы';

  @override
  String get practiceTopicStrings => 'Строки';

  @override
  String get practiceTopicAlgorithms => 'Алгоритмы';

  @override
  String get practiceTopicComplexity => 'Сложность алгоритмов';

  @override
  String get practiceTopicRecursion => 'Рекурсия';

  @override
  String get practiceTopicAtoms => 'Атомы';

  @override
  String get practiceTopicPeriodicTable => 'Периодическая таблица';

  @override
  String get practiceTopicChemicalBonds => 'Химические связи';

  @override
  String get practiceTopicReactions => 'Реакции';

  @override
  String get practiceTopicStoichiometry => 'Стехиометрия';

  @override
  String get practiceTopicAcidsAndBases => 'Кислоты и основания';

  @override
  String get practiceTopicOrganicChemistry => 'Органическая химия';

  @override
  String get practiceTopicCells => 'Клетки';

  @override
  String get practiceTopicGenetics => 'Генетика';

  @override
  String get practiceTopicHumanBody => 'Тело человека';

  @override
  String get practiceTopicEcology => 'Экология';

  @override
  String get practiceTopicEvolution => 'Эволюция';

  @override
  String get practiceTopicSystems => 'Системы';

  @override
  String get practiceTopicGrammar => 'Грамматика';

  @override
  String get practiceTopicReadingComprehension => 'Понимание текста';

  @override
  String get practiceTopicVocabulary => 'Лексика';

  @override
  String get practiceTopicTenses => 'Глагольные времена';

  @override
  String get practiceTopicWriting => 'Письмо';

  @override
  String get practiceTopicRhetoric => 'Риторика';

  @override
  String get practiceSetupSectionMode => 'Режим';

  @override
  String get practiceSetupSectionDifficulty => 'Сложность';

  @override
  String get practiceSetupSectionControls => 'Параметры сессии';

  @override
  String get practiceSetupQuestionsTitle => 'Вопросы';

  @override
  String get practiceSetupQuestionsCaption => 'Количество вопросов в сессии';

  @override
  String get practiceSetupTimingTitle => 'Время';

  @override
  String get practiceSetupTimingCaption =>
      'Выберите тип таймера: AI, свой или без ограничений.';

  @override
  String get practiceSetupTimingScopePerQuestion => 'На каждый вопрос';

  @override
  String get practiceSetupTimingScopeWholeQuiz => 'На весь тест';

  @override
  String get practiceSetupTimingModeAi => 'AI';

  @override
  String get practiceSetupTimingModeMyTime => 'Моё время';

  @override
  String get practiceSetupTimingModeInfinite => 'Без ограничений';

  @override
  String get practiceSetupTimingCustomPerQuestionTitle => 'Секунд на вопрос';

  @override
  String get practiceSetupTimingCustomPerQuestionCaption =>
      'Свой таймер для каждого вопроса';

  @override
  String get practiceSetupTimingCustomQuizMinutesTitle => 'Минут на тест';

  @override
  String get practiceSetupTimingCustomQuizMinutesCaption =>
      'Свой таймер для всего теста';

  @override
  String get practiceSetupInfiniteLivesTitle => 'Бесконечные попытки';

  @override
  String get practiceSetupInfiniteLivesSubtitle =>
      'Сессия не заканчивается из-за ошибок';

  @override
  String get practiceSetupLivesTitle => 'Попытки';

  @override
  String get practiceSetupLivesCaption =>
      'Допустимое количество ошибок до завершения сессии';

  @override
  String get practiceSetupTooltipHistory => 'История практики';

  @override
  String get practiceHistoryTitle => 'История практики';

  @override
  String get practiceHistoryClearTooltip => 'Очистить историю';

  @override
  String get practiceHistoryClearConfirmTitle => 'Очистить историю?';

  @override
  String get practiceHistoryClearConfirmBody =>
      'Все сохранённые сессии практики будут удалены с этого устройства.';

  @override
  String get practiceHistoryLoadError =>
      'Не удалось загрузить историю практики.';

  @override
  String get practiceHistoryErrorPrefix => 'Ошибка:';

  @override
  String get practiceHistoryEmpty => 'Сессий практики пока нет.';

  @override
  String get practiceHistoryDeleteConfirmTitle => 'Удалить сессию?';

  @override
  String get practiceHistoryDeleteConfirmBody =>
      'Это удалит только эту сохранённую сессию практики.';

  @override
  String get practiceHistoryOpenReview => 'Открыть обзор';

  @override
  String get practiceHistoryDeleteSession => 'Удалить сессию';

  @override
  String get practiceHistoryDebugTitle => 'Отладка истории практики';

  @override
  String get practiceAnalyticsTitle => 'Аналитика практики';

  @override
  String get practiceAnalyticsSectionOverall => 'Общее';

  @override
  String get practiceAnalyticsRecentSessionsTitle => 'Последние сессии';

  @override
  String practiceAnalyticsRecentSessionsSummary(
    Object sessions,
    Object correct,
    Object answered,
    Object accuracy,
    Object xp,
  ) {
    return '$sessions сессий · $correct/$answered правильно · $accuracy% · XP $xp';
  }

  @override
  String get practiceAnalyticsSectionWeakestTopics => 'Самые слабые темы';

  @override
  String get practiceAnalyticsSectionStrongestTopics => 'Самые сильные темы';

  @override
  String get practiceAnalyticsSectionModePerformance => 'Результаты по режимам';

  @override
  String get practiceAnalyticsNoTopicData => 'Данных по темам пока нет';

  @override
  String get practiceAnalyticsNoModeData => 'Данных по режимам пока нет';

  @override
  String get savedQuestionsTopSubjectNone => 'Пока нет';

  @override
  String get savedQuestionsHeroSubtitle =>
      'Вопросы, сохранённые во время практики.';

  @override
  String get savedQuestionsSavedMetric => 'Сохранено';

  @override
  String get savedQuestionsTopSubjectMetric => 'Лучший предмет';

  @override
  String get savedQuestionsQuickActionsSubtitle =>
      'Сразу перейти к практике или решениям.';

  @override
  String get savedQuestionsOpenPractice => 'Открыть практику';

  @override
  String get savedQuestionsOpenPracticeSubtitle => 'Начать новую сессию';

  @override
  String get savedQuestionsOpenSolutions => 'Открыть решения';

  @override
  String get savedQuestionsOpenSolutionsSubtitle =>
      'Просмотр загруженных решений по предмету и странице';

  @override
  String get savedQuestionsQueueTitle => 'Ваша очередь';

  @override
  String get savedQuestionsQueueSubtitle =>
      'Сохранённые вопросы для быстрого повторения.';

  @override
  String get savedQuestionsEmptyTitle => 'Сохранённых вопросов нет';

  @override
  String get savedQuestionsEmptySubtitle =>
      'Сохраните вопрос из практики для последующего изучения.';

  @override
  String get savedQuestionsClearAction => 'Очистить сохранённые';

  @override
  String get savedQuestionsWhyItWorks => 'Почему это работает';

  @override
  String savedQuestionsHoursTarget(Object count) {
    return 'Цель: $count ч.';
  }

  @override
  String savedQuestionsMinutesTarget(Object count) {
    return 'Цель: $count мин.';
  }

  @override
  String savedQuestionsSecondsTarget(Object count) {
    return 'Цель: $count сек.';
  }

  @override
  String get practiceSetupTooltipAnalytics => 'Аналитика практики';

  @override
  String get practiceSetupStopGenerating => 'Остановить';

  @override
  String get practiceSetupGenerating => 'Генерация…';

  @override
  String get practiceSetupStartSession => 'Начать сессию';

  @override
  String get practiceSetupSearchHint => 'Поиск…';

  @override
  String get practiceSessionModeDescriptionPractice =>
      'Сбалансированное решение с мгновенной проверкой.';

  @override
  String get practiceSessionModeDescriptionFlashcards =>
      'Режим памяти для быстрого вспоминания.';

  @override
  String get practiceSessionModeDescriptionSpeedRound =>
      'Быстрые повторения под давлением времени.';

  @override
  String get practiceSessionModeDescriptionExamPrep =>
      'Формальный экзаменационный стиль без игровых элементов.';

  @override
  String get practiceSessionModeDescriptionConceptBuilder =>
      'Сначала поймите идею, затем применяйте.';

  @override
  String get practiceSessionModeDescriptionAdaptive =>
      'Сложность меняется в зависимости от результатов.';

  @override
  String get practiceSessionModeDescriptionBagrut =>
      'Официальный одиночный вопрос в стиле Багрут.';

  @override
  String get practiceSessionLoadingPractice => 'Создание сессии практики';

  @override
  String get practiceSessionLoadingFlashcards => 'Перемешивание карточек';

  @override
  String get practiceSessionLoadingSpeedRound => 'Запуск скоростного раунда';

  @override
  String get practiceSessionLoadingExamPrep =>
      'Подготовка экзаменационной сессии';

  @override
  String get practiceSessionLoadingConceptBuilder =>
      'Загрузка коуча по концепциям';

  @override
  String get practiceSessionLoadingAdaptive => 'Персонализация уровня';

  @override
  String get practiceSessionLoadingBagrut => 'Подготовка набора для Багрут';

  @override
  String get practiceSessionLoadingDefault => 'Подготовка сессии';

  @override
  String practiceSessionCompleteTitle(Object mode) {
    return '$mode завершён';
  }

  @override
  String get practiceSessionMetricAnswered => 'Отвечено';

  @override
  String get practiceSessionMetricCorrect => 'Правильно';

  @override
  String get practiceSessionMetricWrong => 'Неправильно';

  @override
  String get practiceSessionMetricAccuracy => 'Точность';

  @override
  String get practiceSessionMetricTotal => 'Всего';

  @override
  String get practiceSessionMetricXp => 'XP';

  @override
  String get practiceSessionMetricStreak => 'Серия';

  @override
  String get practiceSessionReviewLayoutStacked => 'Стопкой';

  @override
  String get practiceSessionReviewLayoutFocus => 'Фокус';

  @override
  String get practiceSessionFilterAll => 'Все';

  @override
  String get practiceSessionFilterWrong => 'Неверные';

  @override
  String get practiceSessionFilterCorrect => 'Верные';

  @override
  String get practiceSessionReviewTitle => 'Обзор сессии';

  @override
  String get practiceSessionNoQuestionsForFilter =>
      'Вопросов по этому фильтру нет.';

  @override
  String get practiceSessionNoAnswer => 'Без ответа';

  @override
  String get practiceSessionUnknownAnswer => 'Неизвестно';

  @override
  String get practiceSessionReflectionTitle => 'Самоанализ';

  @override
  String get practiceSessionReflectionKnewIt => 'Знал';

  @override
  String get practiceSessionReflectionReviewAgain => 'Повторить';

  @override
  String get practiceSessionBackOfCard => 'Обратная сторона';

  @override
  String get practiceSessionYourAnswer => 'Ваш ответ';

  @override
  String get practiceSessionCorrectAnswer => 'Правильный ответ';

  @override
  String get practiceSessionExplanation => 'Пояснение';

  @override
  String get practiceSessionBackToSetup => 'К настройкам';

  @override
  String get practiceSessionGeneralTopic => 'Общее';

  @override
  String practiceSessionQuestionProgress(Object current, Object total) {
    return 'Вопрос $current из $total';
  }

  @override
  String get practiceSessionMetricTime => 'Время';

  @override
  String practiceSessionMatchmakingDifficulty(Object difficulty) {
    return 'Сложность: $difficulty';
  }

  @override
  String get practiceModeActionPrevious => 'Назад';

  @override
  String get practiceModeActionCheckAnswer => 'Проверить ответ';

  @override
  String get practiceModeActionNext => 'Далее';

  @override
  String get practiceModeActionNextQuestion => 'Следующий вопрос';

  @override
  String get practiceModeActionEndSession => 'Завершить сессию';

  @override
  String get practiceModeActionEndQuestion => 'Завершить вопрос';

  @override
  String get practiceModeActionEndExam => 'Завершить экзамен';

  @override
  String get practiceModeActionNovaHint => 'Подсказка NOVA';

  @override
  String get practiceModeActionReveal => 'Открыть';

  @override
  String get practiceModeActionShowSolution => 'Показать решение';

  @override
  String get practiceModeActionHideSolution => 'Скрыть решение';

  @override
  String get practiceModeActionLockIn => 'Зафиксировать';

  @override
  String get practiceModeActionCheckAdapt => 'Проверить и адаптировать';

  @override
  String get practiceModeActionContinue => 'Продолжить';

  @override
  String get practiceModeActionSolveIt => 'Решить';

  @override
  String get practiceModeActionNextConcept => 'Следующая концепция';

  @override
  String get practiceModeCardFront => 'Лицевая сторона';

  @override
  String get practiceModeRecallSummary => 'Итоги вспоминания';

  @override
  String get practiceModeFeelingPrompt => 'Как вам это далось?';

  @override
  String get practiceModeFeelingAgain => 'Ещё раз';

  @override
  String get practiceModeFeelingHard => 'Сложно';

  @override
  String get practiceModeFeelingGood => 'Хорошо';

  @override
  String get practiceModeFeelingEasy => 'Легко';

  @override
  String get practiceModeSpeedRoundBanner =>
      'Скоростной раунд · быстрые решения, мгновенный прогресс';

  @override
  String get practiceModeFastFeedback => 'Быстрая обратная связь';

  @override
  String get practiceModeExamPrepBanner =>
      'Подготовка к экзамену · спокойный формат, ответы после перехода';

  @override
  String get practiceModeReview => 'Разбор';

  @override
  String get practiceModeBagrutBanner =>
      'Режим Багрут · официальный экзаменационный формат';

  @override
  String get practiceModeOfficialSolution => 'Официальное решение';

  @override
  String get practiceModeAdaptiveWarmup => 'Разминочная сложность';

  @override
  String get practiceModeAdaptiveTrendingUp => 'Сложность растёт';

  @override
  String get practiceModeAdaptiveEasingDown => 'Сложность снижается';

  @override
  String get practiceModeAdaptiveSteady => 'Сложность стабильна';

  @override
  String get practiceModeAdaptiveFeedback => 'Адаптивная обратная связь';

  @override
  String get practiceModeConceptFirst => 'Сначала концепция';

  @override
  String get practiceModeNowSolveIt => 'Теперь решите';

  @override
  String get practiceModeConceptTitle => 'Концепция';

  @override
  String get practiceModeFeedbackCorrect => 'Правильно';

  @override
  String get practiceModeFeedbackNotQuite => 'Не совсем';

  @override
  String get practiceModeFallbackQuestion => 'Вопрос';

  @override
  String get practiceModeNoExplanationYet => 'Пояснение пока недоступно.';

  @override
  String get teacherGradesAssessmentCreated => 'Контрольная работа создана';

  @override
  String get teacherGradesEditAssessmentTitle => 'Редактировать работу';

  @override
  String get teacherGradesFieldTitle => 'Название';

  @override
  String get teacherGradesFieldDate => 'Дата (ГГГГ-ММ-ДД)';

  @override
  String get teacherGradesFieldMaxGrade => 'Максимальная оценка';

  @override
  String get teacherGradesAssessmentUpdated => 'Работа обновлена';

  @override
  String get teacherGradesDeleteAssessmentTitle =>
      'Удалить контрольную работу?';

  @override
  String teacherGradesDeleteAssessmentBody(Object title) {
    return 'Это удалит $title и все оценки из журнала.';
  }

  @override
  String get teacherGradesDeleteAction => 'Удалить';

  @override
  String get teacherGradesAssessmentDeleted => 'Контрольная работа удалена';

  @override
  String get teacherGradesRosterLinkError =>
      'Эта работа не связана со списком класса.';

  @override
  String get teacherGradesSaved => 'Оценки сохранены';

  @override
  String get teacherGradesSubtitle => 'Журнал оценок';

  @override
  String get teacherGradesCreateAssessmentTitle => 'Создать контрольную работу';

  @override
  String get teacherGradesFieldCourse => 'Предмет';

  @override
  String get teacherGradesCreateAction => 'Создать';

  @override
  String get teacherGradesNoStudentsLoaded =>
      'Ученики для этой работы не загружены.';

  @override
  String get teacherGradesFieldGrade => 'Оценка';

  @override
  String teacherGradesMaxHint(Object grade) {
    return 'Макс. $grade';
  }

  @override
  String get teacherGradesSaving => 'Сохранение…';

  @override
  String teacherGradesSaveCount(Object count) {
    return 'Сохранить оценки ($count)';
  }

  @override
  String get assignmentsNoDueDate => 'Без срока';

  @override
  String get assignmentsLoadError => 'Не удалось загрузить задания';

  @override
  String get assignmentsLoadTimeout => 'Превышено время ожидания';

  @override
  String get assignmentsLoadNetwork => 'Нет подключения';

  @override
  String get assignmentsStatusOverdue => 'Просрочено';

  @override
  String get assignmentsStatusDueSoon => 'Скоро срок';

  @override
  String get assignmentsStatusUpcoming => 'Предстоящее';

  @override
  String get assignmentsPreviewFallback => 'Файл';

  @override
  String get assignmentsSubmissionPrepEmpty => 'Нет подготовленных материалов';

  @override
  String assignmentsSubmissionPrepCount(Object count) {
    return '$count файл(ов) прикреплено локально.';
  }

  @override
  String get assignmentsHeroSubtitle => 'Ваши задания';

  @override
  String get assignmentsSubjectsMetric => 'Предметов';

  @override
  String get assignmentsNothingAssignedYet => 'Заданий пока нет';

  @override
  String get assignmentsNoAssignmentsForAccount =>
      'Для вашего аккаунта заданий нет';

  @override
  String assignmentsNextThingBody(Object title, Object due) {
    return '$title — следующее задание. $due.';
  }

  @override
  String get assignmentsPullToCheckAgain => 'Потяните для обновления';

  @override
  String get assignmentsFiltersSubtitle => 'Фильтровать задания';

  @override
  String get assignmentsSubjectLabel => 'Предмет';

  @override
  String get assignmentsAllSubjects => 'Все предметы';

  @override
  String get assignmentsSearchSubjects => 'Поиск предметов';

  @override
  String get assignmentsStatusLabel => 'Статус';

  @override
  String get assignmentsAllStatuses => 'Все статусы';

  @override
  String get assignmentsSearchStatuses => 'Поиск статусов';

  @override
  String assignmentsShowingSummary(Object shown, Object total) {
    return 'Показано $shown из $total заданий.';
  }

  @override
  String get assignmentsNoFilterMatchesTitle => 'Заданий не найдено';

  @override
  String get assignmentsNoFilterMatchesSubtitle =>
      'Попробуйте изменить фильтры.';

  @override
  String get assignmentsClearFiltersHint => 'Очистить фильтры';

  @override
  String get assignmentsListSubtitle => 'Все задания';

  @override
  String get assignmentsAddNoteBeforePrepare =>
      'Добавьте заметку перед подготовкой';

  @override
  String get assignmentsWorkDraftPrepared => 'Черновик готов';

  @override
  String get assignmentsWorkDraftPreparedWithFiles =>
      'Черновик с файлами готов';

  @override
  String get assignmentsUnavailableTitle => 'Задания недоступны';

  @override
  String get assignmentsUnavailableSubtitle => 'Попробуйте позже';

  @override
  String get assignmentsUnavailableHint => 'Потяните вниз для обновления';

  @override
  String get assignmentsOverdueBannerBody => 'Есть просроченные задания';

  @override
  String get assignmentsWorkAreaBannerBody =>
      'Ваша рабочая область для подготовки';

  @override
  String get assignmentsDetailsSectionTitle => 'Подробности';

  @override
  String get assignmentsDetailsSectionSubtitle => 'Данные задания';

  @override
  String get assignmentsDetailDueLabel => 'Срок';

  @override
  String get assignmentsDetailClassroomLabel => 'Класс';

  @override
  String get assignmentsDetailTeacherLabel => 'Учитель';

  @override
  String get assignmentsDetailPostedByLabel => 'Опубликовал';

  @override
  String get assignmentsDetailPublishedLabel => 'Опубликовано';

  @override
  String get assignmentsDetailUpdatedLabel => 'Обновлено';

  @override
  String get assignmentsDetailIdLabel => 'ID';

  @override
  String get assignmentsInstructionsTitle => 'Инструкции';

  @override
  String get assignmentsInstructionsSubtitle => 'Описание задания';

  @override
  String get assignmentsYourWorkTitle => 'Ваша работа';

  @override
  String get assignmentsYourWorkSubtitle => 'Подготовка и прикрепление файлов';

  @override
  String get assignmentsPrivateNoteLabel => 'Личная заметка';

  @override
  String get assignmentsPrivateNoteHint => 'Только для вас…';

  @override
  String get assignmentsAddFiles => 'Добавить файлы';

  @override
  String get assignmentsClearFiles => 'Удалить файлы';

  @override
  String get assignmentsStagedDeviceHint =>
      'Файлы хранятся локально на устройстве';

  @override
  String assignmentsLastPrepared(Object time) {
    return 'Последняя подготовка: $time.';
  }

  @override
  String get assignmentsSubmissionPrepTitle => 'Подготовка';

  @override
  String get assignmentsPreparing => 'Подготовка…';

  @override
  String get assignmentsPrepareWork => 'Подготовить';

  @override
  String get assignmentsLoadingSubtitle => 'Загрузка заданий…';

  @override
  String get assignmentsPullToRefreshRetry => 'Потяните для повтора';

  @override
  String get assignmentsFileSizeUnknown => 'Размер неизвестен';

  @override
  String get assignmentsRemoveAttachment => 'Удалить вложение';

  @override
  String get assignmentsSubmitted => 'Сдано';

  @override
  String get attendanceUndated => 'Без даты';

  @override
  String get attendanceLoadError => 'Не удалось загрузить посещаемость';

  @override
  String get attendanceLoadTimeout => 'Превышено время ожидания';

  @override
  String get attendanceLoadNetwork => 'Нет подключения';

  @override
  String get attendanceConsistencyBuilding => 'Формируется';

  @override
  String get attendanceConsistencyExcellent => 'Отлично';

  @override
  String get attendanceConsistencySteady => 'Стабильно';

  @override
  String get attendanceConsistencyNeedsAttention => 'Требует внимания';

  @override
  String get attendanceConsistencyRisk => 'Риск';

  @override
  String get attendanceWatchRecentAbsences => 'Недавние пропуски';

  @override
  String get attendanceWatchRepeatedLateness => 'Систематические опоздания';

  @override
  String get attendanceWatchExcusedAddingUp => 'Накапливаются уважит. причины';

  @override
  String get attendanceWatchNoFlags => 'Всё хорошо';

  @override
  String get attendanceAllSubjectsLowercase => 'все предметы';

  @override
  String attendanceShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return 'Показано $shown из $total записей по $subject за $range.';
  }

  @override
  String get attendanceDayToneAbsent => 'Отсутствие';

  @override
  String get attendanceDayToneLate => 'Опоздание';

  @override
  String get attendanceDayToneExcused => 'Уважит. причина';

  @override
  String get attendanceDayToneClean => 'Без отметок';

  @override
  String get attendanceLoadingSubtitle => 'Загрузка данных…';

  @override
  String get attendanceUnavailableTitle => 'Посещаемость недоступна';

  @override
  String get attendanceHeroSubtitle => 'Журнал посещаемости';

  @override
  String get attendanceMetricRate => 'Процент';

  @override
  String get attendanceMetricPresent => 'Присутствовал';

  @override
  String get attendanceMetricLate => 'Опоздал';

  @override
  String get attendanceMetricAbsent => 'Отсутствовал';

  @override
  String attendanceHeroSignalBody(Object flag) {
    return '$flag. Следите за посещаемостью.';
  }

  @override
  String get attendanceNoSummary => 'Нет данных';

  @override
  String get attendanceEmptyTitle => 'Записей нет';

  @override
  String get attendanceEmptySubtitle => 'Данные появятся после первого урока.';

  @override
  String get attendanceFiltersSubtitle => 'Фильтровать записи';

  @override
  String get attendanceTimeRangeLabel => 'Период';

  @override
  String get attendanceSearchRanges => 'Поиск периодов';

  @override
  String get attendanceNoFilteredMarksTitle => 'Записей не найдено';

  @override
  String get attendanceNoFilteredMarksSubtitle =>
      'Попробуйте изменить фильтры.';

  @override
  String get attendanceQuickReadTitle => 'Сводка';

  @override
  String get attendanceQuickReadSubtitleFiltered =>
      'По отфильтрованным записям';

  @override
  String get attendanceQuickReadSubtitleAll => 'По всем записям';

  @override
  String get attendanceSummaryConsistency => 'Стабильность';

  @override
  String get attendanceSummaryWatchFor => 'На заметку';

  @override
  String get attendanceSummaryExcused => 'Уважит. причин';

  @override
  String get attendanceSummaryMarksInView => 'Записей';

  @override
  String get attendanceSummaryRateInView => 'Процент';

  @override
  String get attendanceRecentDaysTitle => 'Последние дни';

  @override
  String get attendanceRecentDaysSubtitleFiltered => 'Отфильтрованные записи';

  @override
  String get attendanceRecentDaysSubtitleAll => 'Последние записи';

  @override
  String get attendanceLessonCountSingle => '1 урок';

  @override
  String attendanceLessonCount(Object count) {
    return '$count уроков';
  }

  @override
  String get attendanceStatusPresent => 'Присутствует';

  @override
  String get attendanceStatusLate => 'Опоздал';

  @override
  String get attendanceStatusAbsent => 'Отсутствует';

  @override
  String get attendanceStatusExcused => 'Уважит. причина';

  @override
  String get attendanceStatusRecorded => 'Записано';

  @override
  String get attendanceLessonFallback => 'Урок';

  @override
  String get attendanceRangeAll => 'За всё время';

  @override
  String get attendanceRange7 => 'Последние 7 дней';

  @override
  String get attendanceRange30 => 'Последние 30 дней';

  @override
  String get attendanceRange90 => 'Последние 90 дней';

  @override
  String get attendanceRangeAllShort => 'всё время';

  @override
  String get attendanceRange7Short => '7 дней';

  @override
  String get attendanceRange30Short => '30 дней';

  @override
  String get attendanceRange90Short => '90 дней';

  @override
  String get gradesLoadError => 'Не удалось загрузить оценки';

  @override
  String get gradesLoadTimeout => 'Превышено время ожидания';

  @override
  String get gradesLoadNetwork => 'Нет подключения';

  @override
  String get gradesGeneralSubject => 'Общее';

  @override
  String get gradesBandBuilding => 'Формируется';

  @override
  String get gradesBandExcellent => 'Отлично';

  @override
  String get gradesBandStrong => 'Хорошо';

  @override
  String get gradesBandOkay => 'Удовлетворительно';

  @override
  String get gradesBandNeedsAttention => 'Требует внимания';

  @override
  String get gradesBandRisk => 'Риск';

  @override
  String get gradesTrendRising => 'Растёт';

  @override
  String get gradesTrendDropping => 'Падает';

  @override
  String get gradesTrendStable => 'Стабильно';

  @override
  String gradesShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return 'Показано $shown из $total оценок по $subject за $range.';
  }

  @override
  String get gradesLoadingSubtitle => 'Загрузка оценок…';

  @override
  String get gradesUnavailableTitle => 'Оценки недоступны';

  @override
  String get gradesHeroSubtitle => 'Ваши оценки';

  @override
  String get gradesMetricAverage => 'Средний балл';

  @override
  String get gradesMetricRecorded => 'Всего оценок';

  @override
  String get gradesMetricBestSubject => 'Лучший предмет';

  @override
  String get gradesMetricNeedsWork => 'Требует работы';

  @override
  String gradesLatestSignalBody(
    Object assessment,
    Object subject,
    Object grade,
    Object band,
  ) {
    return '$assessment по $subject: $grade. Уровень: $band.';
  }

  @override
  String get gradesSummaryAvailableNoRecent => 'Нет последних оценок';

  @override
  String get gradesEmptyTitle => 'Оценок пока нет';

  @override
  String get gradesEmptySubtitle => 'Оценки появятся после проверки работ.';

  @override
  String get gradesFiltersSubtitle => 'Фильтровать оценки';

  @override
  String get gradesNoFilteredTitle => 'Оценок не найдено';

  @override
  String get gradesNoFilteredSubtitle => 'Попробуйте изменить фильтры.';

  @override
  String get gradesQuickReadTitle => 'Сводка';

  @override
  String get gradesQuickReadSubtitleFiltered => 'По отфильтрованным оценкам';

  @override
  String get gradesQuickReadSubtitleAll => 'По всем оценкам';

  @override
  String get gradesWeakSpotLabel => 'Слабое место';

  @override
  String get gradesNoWeakSignal => 'Слабых мест нет';

  @override
  String gradesWeakSpotValue(Object subject) {
    return 'Нужно внимание: $subject';
  }

  @override
  String get gradesStrengthLabel => 'Сильная сторона';

  @override
  String get gradesNoStrengthSignal => 'Нет данных';

  @override
  String gradesStrengthValue(Object subject) {
    return '$subject';
  }

  @override
  String get gradesBandLabel => 'Уровень';

  @override
  String get gradesInViewLabel => 'В просмотре';

  @override
  String gradesInViewCount(Object count) {
    return '$count оценок в этом фильтре.';
  }

  @override
  String gradesInViewAverage(Object count, Object average) {
    return '$count оценок, средний балл $average.';
  }

  @override
  String get gradesLatestAssessmentsTitle => 'Последние оценки';

  @override
  String get gradesLatestAssessmentsSubtitleFiltered =>
      'Отфильтрованные оценки';

  @override
  String get gradesLatestAssessmentsSubtitleAll => 'Все недавние оценки';

  @override
  String get gradesSubjectDrilldownTitle => 'По предметам';

  @override
  String get gradesSubjectDrilldownSubtitleFiltered =>
      'По отфильтрованным предметам';

  @override
  String get gradesSubjectDrilldownSubtitleAll => 'По всем предметам';

  @override
  String get gradesAssessmentFallback => 'Оценивание';

  @override
  String get gradesChipBest => 'Лучший';

  @override
  String get gradesNoAverageYet => 'Среднего балла пока нет';

  @override
  String gradesRecentAverage(Object average) {
    return 'Средний балл: $average';
  }

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionRemove => 'Убрать';

  @override
  String get actionBlock => 'Заблокировать';

  @override
  String get actionCreate => 'Создать';

  @override
  String get actionShare => 'Поделиться';

  @override
  String get actionScheduleVerb => 'Запланировать';

  @override
  String get actionAdd => 'Добавить';

  @override
  String get actionKeep => 'Оставить';

  @override
  String get actionOpen => 'Открыть';

  @override
  String get actionPublish => 'Опубликовать';

  @override
  String get actionPublishing => 'Публикация…';

  @override
  String get actionRefresh => 'Обновить';

  @override
  String get msgBlockTitle => 'Заблокировать этого пользователя?';

  @override
  String get msgBlockContent =>
      'Он не сможет писать вам, и вы не будете видеть его сообщения.';

  @override
  String get msgRenameGroup => 'Переименовать группу';

  @override
  String get msgGroupName => 'Название группы';

  @override
  String get msgMute => 'Отключить звук';

  @override
  String get msgUnmute => 'Включить звук';

  @override
  String get msgInviteCode => 'Код приглашения';

  @override
  String get msgCopyCode => 'Скопировать код';

  @override
  String get msgLeave => 'Выйти';

  @override
  String get msgInviteCodeCopied => 'Код приглашения скопирован';

  @override
  String msgCodeCopied(Object code) {
    return 'Код скопирован: $code';
  }

  @override
  String msgParticipantsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Добавлено $count участников',
      one: 'Добавлен 1 участник',
    );
    return '$_temp0';
  }

  @override
  String msgMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участников',
      one: '1 участник',
    );
    return '$_temp0';
  }

  @override
  String get msgAdmin => 'Администратор';

  @override
  String get msgRemoveFromGroup => 'Удалить из группы';

  @override
  String get msgMakeAdmin => 'Назначить администратором';

  @override
  String get msgRemoveAdmin => 'Снять права администратора';

  @override
  String get msgOnlyAdmin =>
      'Единственный администратор — сначала повысьте другого';

  @override
  String msgRemoveMemberTitle(Object name) {
    return 'Удалить $name?';
  }

  @override
  String get msgNotificationsMuted => 'Уведомления отключены';

  @override
  String get msgNotificationsUnmuted => 'Уведомления включены';

  @override
  String get msgJoinGroupTitle => 'Вступить в группу';

  @override
  String get msgJoinGroupSubtitle =>
      'Введите код приглашения от администратора группы';

  @override
  String get examTitle => 'Экзамен';

  @override
  String get examNotFound => 'Экзамен не найден';

  @override
  String get examStudyWithNova => 'Учиться с NOVA';

  @override
  String get examOpenInsights => 'Открыть аналитику';

  @override
  String get examAddToCalendar => 'Добавить в календарь';

  @override
  String get examCouldNotOpenCalendar => 'Не удалось открыть календарь.';

  @override
  String get formTitle => 'Форма';

  @override
  String get formNotFound => 'Форма не найдена';

  @override
  String get formClosed => 'Эта форма закрыта.';

  @override
  String get formCompletion => 'Завершение';

  @override
  String get formNoTextResponses => 'Текстовых ответов пока нет.';

  @override
  String get meetingsCouldNotLoad => 'Не удалось загрузить встречи';

  @override
  String get meetingCouldNotLoad => 'Не удалось загрузить встречу';

  @override
  String get insightsGenerateAction => 'Создать аналитику';

  @override
  String get insightsRefreshAction => 'Обновить';

  @override
  String get teacherGoToClassroom => 'Перейти в класс';

  @override
  String get teacherMarkAttendance => 'Отметить посещаемость';

  @override
  String get teacherPostAssignment => 'Опубликовать задание';

  @override
  String get teacherNewAnnouncementAction => 'Новое объявление';

  @override
  String get teacherViewFullWeekSchedule => 'Просмотреть недельное расписание';

  @override
  String get teacherGroupsLabel => 'Группы';

  @override
  String get teacherTestsLabel => 'Тесты';

  @override
  String get teacherAnnounceLabel => 'Объявить';

  @override
  String get teacherTitleAndMessageRequired =>
      'Заголовок и сообщение обязательны';

  @override
  String get teacherAnnouncementPublished => 'Объявление опубликовано';

  @override
  String teacherFailedToPublish(Object error) {
    return 'Ошибка публикации: $error';
  }

  @override
  String get teacherAnnouncementSectionTitle => 'Объявление';

  @override
  String get teacherAudienceSectionTitle => 'Аудитория';

  @override
  String get teacherPinAnnouncement => 'Закрепить объявление';

  @override
  String get teacherPinnedAtTop =>
      'Закреплённые объявления отображаются вверху';

  @override
  String get teacherPublishAction => 'Опубликовать';

  @override
  String get teacherPublishingAction => 'Публикация…';

  @override
  String get teacherAnnounceTitleLabel => 'Заголовок *';

  @override
  String get teacherAnnounceTitleHint => 'напр. Школьное мероприятие завтра';

  @override
  String get teacherAnnounceMessageLabel => 'Сообщение *';

  @override
  String get teacherAnnounceMessageHint => 'Напишите полное объявление здесь…';

  @override
  String get teacherStudentsLabel => 'Ученики';

  @override
  String get teacherSearchStudents => 'Поиск учеников…';

  @override
  String get teacherNoStudentsLoaded => 'В этой школе нет учеников.';

  @override
  String get teacherActions => 'БЫСТРЫЕ ДЕЙСТВИЯ';

  @override
  String get teacherParentsLabel => 'Родители';

  @override
  String get teacherTeachersLabel => 'Учителя';

  @override
  String get teacherWeekScheduleTitle => 'Недельное расписание';

  @override
  String get teacherCouldNotLoadSchedule => 'Не удалось загрузить расписание';

  @override
  String get teacherAttendanceLast30 => 'Последние 30 дней';

  @override
  String teacherAttendanceFrom(Object date) {
    return 'С $date';
  }

  @override
  String get teacherAttendanceChangeDate => 'Изменить дату';

  @override
  String get teacherAttendanceNoSessions => 'Занятий не найдено';

  @override
  String get teacherRecentGrades => 'Последние оценки';

  @override
  String get teacherNoGradesRecorded => 'Оценок пока нет';

  @override
  String get teacherGradeAvg => 'Средний балл';

  @override
  String get teacherSubmittedLabel => 'Сдано';

  @override
  String get teacherAnalyticsTitle => 'Аналитика';

  @override
  String get teacherGradeReports => 'Отчёты об оценках';

  @override
  String get teacherAvgLabel => 'ср.';

  @override
  String teacherBelow60(Object count) {
    return '$count ниже 60%';
  }

  @override
  String teacherGradedFraction(Object graded, Object total) {
    return '$graded/$total оценено';
  }

  @override
  String get teacherNoGradesEntered => 'Оценки ещё не введены';

  @override
  String get teacherNewAssignment => 'Новое задание';

  @override
  String get teacherDeleteAssignment => 'Удалить задание?';

  @override
  String get teacherDeleteAssignmentContent =>
      'Задание будет удалено для всех учеников.';

  @override
  String get teacherShareMaterialTitle => 'Поделиться материалом';

  @override
  String get teacherRemoveMaterial => 'Убрать материал?';

  @override
  String get teacherScheduleMeetingTitle => 'Запланировать встречу';

  @override
  String get teacherCancelMeetingTitle => 'Отменить встречу?';

  @override
  String get teacherCancelMeetingAction => 'Отменить встречу';

  @override
  String get teacherJoinMeeting => 'Присоединиться к встрече';

  @override
  String get teacherAddStudentTitle => 'Добавить ученика';

  @override
  String teacherRemoveStudentTitle(Object name) {
    return 'Удалить $name?';
  }

  @override
  String get teacherRemoveStudentContent =>
      'Этот ученик будет удалён из класса.';

  @override
  String get teacherStudentAdded => 'Ученик добавлен';

  @override
  String get teacherClassroomAnalyticsTitle => 'Аналитика класса';

  @override
  String get teacherOpenAnalyticsAction => 'Открыть аналитику';

  @override
  String teacherStudentsCount(Object count) {
    return 'Ученики ($count)';
  }

  @override
  String get teacherAssignmentLabel => 'Задание';

  @override
  String get teacherShareMaterialLabel => 'Поделиться материалом';

  @override
  String get teacherAttendanceRateLabel => 'Уровень посещаемости';

  @override
  String get teacherSelectSessionPrompt =>
      'Выберите сессию ниже, чтобы начать отмечать посещаемость';

  @override
  String get teacherOpenAction => 'Открыть';

  @override
  String get chatDeleteForMe => 'Удалить для меня';

  @override
  String get chatDeleteForEveryone => 'Удалить для всех';

  @override
  String get chatMicNeeded => 'Требуется доступ к микрофону';

  @override
  String get chatMicNeededBody =>
      'Пожалуйста, разрешите доступ к микрофону в Настройках для отправки голосовых заметок.';

  @override
  String get chatOpenSettings => 'Открыть Настройки';

  @override
  String get chatCopied => 'Скопировано';

  @override
  String get chatCouldNotSendMedia => 'Не удалось отправить медиафайл.';

  @override
  String get chatCouldNotSendMessage => 'Не удалось отправить сообщение.';

  @override
  String get chatCouldNotForward => 'Не удалось переслать выбранные сообщения';

  @override
  String get chatSelectAll => 'Выбрать все';

  @override
  String get chatDeselectAll => 'Снять выделение';

  @override
  String get chatEditingMessage => 'Редактирование сообщения';

  @override
  String get chatEditPlaceholder => 'Изменить сообщение…';

  @override
  String get chatMessageHint => 'Сообщение';

  @override
  String get chatPin => 'Закрепить';

  @override
  String get chatUnpin => 'Открепить';

  @override
  String get chatPhoto => 'Фото';

  @override
  String get chatVideo => 'Видео';

  @override
  String get chatMedia => 'Медиа';

  @override
  String get chatAudioFile => 'Аудиофайл';

  @override
  String get chatVideoFile => 'Видеофайл';

  @override
  String get chatAttachedFile => 'Прикреплённый файл';

  @override
  String get chatFollowUp => 'Продолжение';

  @override
  String get chatCancelTooltip => 'Отмена';

  @override
  String get chatJoinGroup => 'Вступить в группу';

  @override
  String get chatJoining => 'Вступление…';

  @override
  String get chatJoinGroupTooltip => 'Вступить в группу по коду';

  @override
  String get chatForwardNoChatAvailable => 'Нет доступных одобренных чатов';

  @override
  String get chatFilterAll => 'Все';

  @override
  String get novaDisclaimer =>
      'NOVA может ошибаться. Проверяйте важные ответы.';

  @override
  String get practiceCustomDisclaimer =>
      'Пользовательские темы создаются ИИ на лету. Вопросы могут отклоняться от темы или быть неточными для нишевых предметов. Проверяйте незнакомые ответы самостоятельно.';

  @override
  String get classroomsJoined => 'Вы вошли в класс!';

  @override
  String get classroomsJoinAction => 'Войти в класс';

  @override
  String get classroomsJoinTooltip => 'Войти в класс';

  @override
  String get classroomsJoinTitle => 'Войти в класс';

  @override
  String get classroomsJoinSubtitle => 'Введите код, который дал вам учитель';

  @override
  String get classroomsCouldNotOpenLink => 'Не удалось открыть ссылку';

  @override
  String get classroomsReorderTitle => 'Изменить порядок классов';

  @override
  String get classroomsNoClassroomsToReorder =>
      'Нет классов для изменения порядка.';

  @override
  String get teacherPostAnnouncementAction => 'Опубликовать объявление';

  @override
  String get announcementAudienceEveryone => 'Все';

  @override
  String get teacherGreetingMorning => 'Доброе утро';

  @override
  String get teacherGreetingAfternoon => 'Добрый день';

  @override
  String get teacherGreetingEvening => 'Добрый вечер';

  @override
  String get teacherTodaysClasses => 'Сегодняшние занятия';

  @override
  String get teacherNoDate => 'Нет даты';

  @override
  String get teacherUpcomingTestsSubtitle => 'Ближайшие тесты и контрольные';

  @override
  String get teacherNoClassesThisWeek => 'Нет занятий на этой неделе';

  @override
  String get teacherNoClassesThisWeekSub =>
      'Ваше расписание на эту неделю пустое';

  @override
  String get teacherTitleFieldLabel => 'Заголовок *';

  @override
  String get teacherInstructionsLabel => 'Инструкции';

  @override
  String get teacherLinkUrlLabel => 'Ссылка / URL *';

  @override
  String get teacherLinkUrlHint => 'Введите ссылку…';

  @override
  String get teacherDescriptionLabel => 'Описание';

  @override
  String get teacherMeetingTitleLabel => 'Название встречи *';

  @override
  String get teacherMeetingLinkLabel => 'Ссылка на встречу *';

  @override
  String get teacherMeetingLinkHint => 'Ссылка Zoom / Meet / Teams';

  @override
  String get teacherStudentEmailLabel => 'Email или ID студента';

  @override
  String get teacherTooltipRemoveStudent => 'Удалить из класса';

  @override
  String get teacherCouldNotLoad => 'Не удалось загрузить';

  @override
  String get teacherNoAssignmentsYet => 'Заданий пока нет';

  @override
  String get teacherNoAssignmentsSub =>
      'Нажмите +, чтобы создать первое задание';

  @override
  String get teacherNoMaterialsYet => 'Материалов пока нет';

  @override
  String get teacherNoMaterialsSub =>
      'Поделитесь ссылками, документами и ресурсами с классом';

  @override
  String get teacherNoMeetingsScheduled => 'Встреч не запланировано';

  @override
  String get teacherNoMeetingsSub =>
      'Нажмите +, чтобы запланировать встречу класса';

  @override
  String get teacherAttendanceOther => 'Другое';

  @override
  String get teacherTotal => 'Итого';

  @override
  String get mediaOpenExternally => 'Открыть во внешнем приложении';

  @override
  String get mediaUnableToLoad => 'Не удалось загрузить изображение';

  @override
  String get searchHint => 'Поиск...';

  @override
  String get teacherInsightsTitle => 'Успеваемость студентов';

  @override
  String get teacherInsightsSubtitle =>
      'Выберите студента для просмотра его академических данных.';

  @override
  String get teacherInsightsNoStudents => 'Студенты не найдены.';

  @override
  String get teacherInsightsSearchHint => 'Поиск студентов…';

  @override
  String get navDiplomas => 'Сертификаты';

  @override
  String get diplomasComingSoon => 'Управление дипломами скоро появится.';

  @override
  String get teacherExamsTitle => 'Экзамены';

  @override
  String get teacherExamsUpcoming => 'Предстоящие';

  @override
  String get teacherExamsPast => 'Прошедшие';

  @override
  String get teacherExamsEmpty => 'Оценок пока нет. Нажмите + чтобы создать.';

  @override
  String teacherExamsGraded(Object count) {
    return '$count оценено';
  }

  @override
  String get teacherFormsTitle => 'Формы';

  @override
  String get teacherFormsEmpty => 'Форм пока нет. Нажмите + для создания.';

  @override
  String teacherFormsResponses(Object count) {
    return '$count ответов';
  }

  @override
  String get teacherFormsPublished => 'Опубликовано';

  @override
  String get teacherFormsDraft => 'Черновик';

  @override
  String get teacherFormsCreateTitle => 'Создать форму';

  @override
  String get teacherFormsAddQuestion => 'Добавить вопрос';

  @override
  String get teacherFormsQuestionHint => 'Текст вопроса';

  @override
  String get teacherFormsViewResponses => 'Посмотреть ответы';

  @override
  String get teacherFormsNoResponses => 'Ответов пока нет.';

  @override
  String get diplomasTitle => 'Сертификаты';

  @override
  String get diplomasEmpty => 'Дипломы ещё не выданы. Нажмите + чтобы выдать.';

  @override
  String get diplomasIssueTo => 'Выдать кому';

  @override
  String get diplomasStudentName => 'Имя студента';

  @override
  String get diplomasCertificateType => 'Тип сертификата';

  @override
  String get diplomasIssueDiploma => 'Выдать сертификат';

  @override
  String diplomasIssuedOn(Object date) {
    return 'Выдан $date';
  }

  @override
  String get examDetailsSection => 'Детали';

  @override
  String get examInfoTeacher => 'Учитель';

  @override
  String get examInfoAudience => 'Аудитория';

  @override
  String get examInfoDate => 'Дата';

  @override
  String get examInfoTime => 'Время';

  @override
  String get examInfoPeriod => 'Урок';

  @override
  String get examInfoDuration => 'Длительность';

  @override
  String get examInfoSubject => 'Предмет';

  @override
  String get examMaterialsSection => 'Прикреплённые материалы';

  @override
  String get examNoMaterials => 'Материалы не прикреплены.';

  @override
  String get examQuickActionsSection => 'Быстрые действия';

  @override
  String get examViewGradeTitle => 'Посмотреть оценку';

  @override
  String get examViewGradeBody =>
      'Экзамен завершён. Проверьте свою оценку во вкладке оценок.';

  @override
  String get examViewGradeAction => 'Открыть оценки';

  @override
  String get teacherGradesSaveAction => 'Сохранить';

  @override
  String get teacherGradesNothingToSave => 'Нет изменений для сохранения.';

  @override
  String get teacherRetry => 'Повторить';

  @override
  String get teacherExamGradesStudents => 'учеников';

  @override
  String get teacherExamGradesGraded => 'оценено';

  @override
  String get teacherExamGradesNoStudents =>
      'Нет выбранных учеников.\nОтредактируйте экзамен, чтобы добавить аудиторию.';

  @override
  String get teacherExamGradesEnterGrades => 'Ввести оценки';

  @override
  String get teacherDeleteExamTitle => 'Удалить экзамен?';

  @override
  String get teacherDeleteExamBody => 'Экзамен будет удалён навсегда.';

  @override
  String get teacherMeetingsEmpty =>
      'Встреч пока нет.\nНажмите + чтобы запланировать.';

  @override
  String get teacherStudentsNoMatch => 'Ученики не найдены';

  @override
  String get teacherMaterialsTitle => 'Материалы';

  @override
  String get profileNamesTitle => 'Имя на языках';

  @override
  String get profileDisplayNameLang => 'Язык отображения';

  @override
  String get navDashboard => 'Панель управления';

  @override
  String get navPeople => 'Люди';

  @override
  String get navCohorts => 'Группы';

  @override
  String get navSchool => 'Школа';

  @override
  String get adminDashboardTitle => 'Обзор школы';

  @override
  String get adminStudents => 'Ученики';

  @override
  String get adminTeachers => 'Учителя';

  @override
  String get adminParents => 'Родители';

  @override
  String get adminSecretaries => 'Секретари';

  @override
  String get adminTodaySessions => 'Занятия сегодня';

  @override
  String get adminQuickActions => 'Быстрые действия';

  @override
  String get adminAttendanceLast30 => 'Посещаемость — последние 30 дней';

  @override
  String get adminNoAttendanceData =>
      'Нет данных о посещаемости за последние 30 дней.';

  @override
  String get adminAddUser => 'Добавить пользователя';

  @override
  String get adminCreateUser => 'Создать';

  @override
  String get adminFullName => 'Полное имя';

  @override
  String get adminEmailAddress => 'Электронная почта';

  @override
  String get adminRoleLabel => 'Роль';

  @override
  String get adminUserCreated => 'Пользователь создан';

  @override
  String get adminTempPassword => 'Временный пароль';

  @override
  String get adminCopied => 'Скопировано в буфер обмена';

  @override
  String get adminResetPassword => 'Сбросить пароль';

  @override
  String get adminPasswordReset => 'Сброс пароля';

  @override
  String adminTempPasswordFor(Object name) {
    return 'Временный пароль для $name';
  }

  @override
  String get adminDeleteUser => 'Удалить пользователя';

  @override
  String adminDeleteUserConfirm(Object name) {
    return 'Удалить $name? Это действие нельзя отменить.';
  }

  @override
  String get adminDeleteCohort => 'Удалить группу';

  @override
  String adminDeleteCohortConfirm(Object name) {
    return 'Удалить \"$name\"? Все участники будут удалены.';
  }

  @override
  String get adminAddCohort => 'Добавить группу';

  @override
  String get adminNewCohort => 'Новая группа';

  @override
  String get adminCohortName => 'Название группы (напр. 10-2)';

  @override
  String get adminCohortGrade => 'Класс';

  @override
  String get adminRenameCohort => 'Переименовать';

  @override
  String get adminAddStudents => 'Добавить учеников';

  @override
  String adminAddTo(Object name) {
    return 'Добавить в $name';
  }

  @override
  String get adminRemoveStudent => 'Удалить ученика';

  @override
  String adminRemoveStudentConfirm(Object name, Object cohort) {
    return 'Удалить $name из $cohort?';
  }

  @override
  String get adminNoCohortsYet => 'Нет групп';

  @override
  String get adminNoStudentsInCohort => 'В этой группе нет учеников';

  @override
  String adminStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учеников',
      one: '1 ученик',
    );
    return '$_temp0';
  }

  @override
  String get adminSearchStudents => 'Поиск учеников…';

  @override
  String get adminScheduleTitle => 'Расписание';

  @override
  String get adminScheduleAddPeriod => 'Добавить урок';

  @override
  String get adminScheduleNewPeriod => 'Новый урок';

  @override
  String get adminScheduleDayLabel => 'День';

  @override
  String adminSchedulePeriodLabel(Object period) {
    return 'У$period';
  }

  @override
  String get adminScheduleTeacherLabel => 'Учитель';

  @override
  String get adminScheduleNoneTeacher => 'Нет учителя';

  @override
  String get adminScheduleCohortLabel => 'Группа / Ученики';

  @override
  String get adminScheduleFrequencyLabel => 'Частота';

  @override
  String get adminScheduleFreqWeekly => 'Каждую неделю';

  @override
  String get adminScheduleFreqBiweekly => 'Каждые 2 недели';

  @override
  String get adminScheduleFreqMonthly => 'Каждые 4 недели';

  @override
  String get adminScheduleFreqCustom => 'Настроить';

  @override
  String adminScheduleFreqCustomLabel(int n) {
    return 'Каждые $n недели';
  }

  @override
  String get adminScheduleAddSlot => 'Добавить слот';

  @override
  String get adminScheduleAddAnother => 'Добавить ещё день / урок';

  @override
  String get adminScheduleSave => 'Сохранить';

  @override
  String get adminScheduleSearchTeacher => 'Поиск учителей…';

  @override
  String get adminScheduleSearchCohort => 'Поиск групп…';

  @override
  String get adminScheduleSelectTeacher => 'Выбрать учителя';

  @override
  String get adminScheduleSelectCohort => 'Выбрать группу';

  @override
  String get adminScheduleOrStudents => 'Или выбрать учеников отдельно';

  @override
  String get adminScheduleNoSlots => 'Нет уроков';

  @override
  String get adminScheduleNoSlotsHint =>
      'Нажмите + для добавления первого урока';

  @override
  String get adminSchoolSettingsTitle => 'Настройки школы';

  @override
  String get adminSchoolName => 'Название школы';

  @override
  String get adminSchoolLogoUrl => 'URL логотипа (необязательно)';

  @override
  String get adminSchoolLogoHint => 'https://…';

  @override
  String get adminSchoolSaved => 'Сохранено';

  @override
  String get adminSubjectsTitle => 'Предметы';

  @override
  String adminSubjectsGrade(int grade) {
    return 'Класс $grade';
  }

  @override
  String get adminSubjectsAddHint => 'Добавить предмет…';

  @override
  String get adminSubjectsNoSubjects => 'Предметы не настроены';

  @override
  String get adminSubjectsAdd => 'Добавить';

  @override
  String get adminSubjectsRemove => 'Удалить';

  @override
  String get adminSettingsTitle => 'Настройки';

  @override
  String get adminSettingsBellSchedule => 'Звонок';

  @override
  String get adminSettingsPeriodDefaults => 'Расписание звонков';

  @override
  String get adminSettingsPeriodDefaultsSubtitle =>
      'Установить время для каждого урока';

  @override
  String get adminDeleteConfirmCancel => 'Отмена';

  @override
  String get adminDeleteConfirmDelete => 'Удалить';

  @override
  String get adminSave => 'Сохранить';

  @override
  String get adminCancel => 'Отмена';

  @override
  String get adminSearchPeople => 'Поиск по имени…';

  @override
  String adminNoResults(Object query) {
    return 'Нет результатов для \"$query\"';
  }

  @override
  String adminNoPeopleYet(Object role) {
    return 'Нет $role';
  }

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonDownload => 'Скачать';

  @override
  String get commonOpenExternally => 'Открыть внешне';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get commonSearch => 'Поиск…';

  @override
  String get commonShare => 'Поделиться';

  @override
  String get commonLoading => 'Загрузка…';

  @override
  String get commonError => 'Что-то пошло не так';

  @override
  String get commonTryAgain => 'Попробуйте снова';

  @override
  String get studentMaterialsTitle => 'Материалы';

  @override
  String get studentMaterialsEmptyTitle => 'Материалы ещё не добавлены';

  @override
  String get studentMaterialsEmptyHint => 'Учитель добавит материалы здесь.';

  @override
  String get studentMaterialsLoadError => 'Не удалось загрузить материалы';

  @override
  String get studentAssignmentSubmittedSnackbar => 'Задание сдано!';

  @override
  String get studentAssignmentSubmitFailed =>
      'Не удалось сдать — попробуйте снова.';

  @override
  String get studentAssignmentUploadFailed =>
      'Не удалось загрузить файл — попробуйте снова.';

  @override
  String get studentAssignmentHandedInBadge => 'Сдано';

  @override
  String get studentAssignmentSubmitButton => 'Сдать';

  @override
  String get studentAssignmentSubmitting => 'Сдаём…';

  @override
  String get studentAssignmentAttachFile => 'Прикрепить файл';

  @override
  String get studentAssignmentAddMoreFiles => 'Добавить ещё файлы';

  @override
  String get studentAssignmentYourSubmission => 'Ваша работа';

  @override
  String get studentAssignmentTeacherAttachments => 'Вложения';

  @override
  String secretaryWelcomeGreeting(Object name) {
    return 'Привет, $name 👋';
  }

  @override
  String get secretaryYourTools => 'Ваши инструменты';

  @override
  String get secretaryReports => 'Жалобы';

  @override
  String get secretaryExportData => 'Экспорт данных';

  @override
  String get secretaryHomeTile => 'Главная';

  @override
  String parentHomeGreeting(Object name) {
    return 'Привет, $name 👋';
  }

  @override
  String get parentYourTools => 'Ваши инструменты';

  @override
  String get parentNoChildLinked => 'Дети ещё не привязаны';

  @override
  String get parentPickChildFirst => 'Сначала выберите ребёнка';

  @override
  String get parentNoApprovedChildren =>
      'Подтверждённых детей пока нет. Попросите школу привязать ваш аккаунт.';

  @override
  String get loginEmptyFieldsError =>
      'Введите email или имя пользователя и пароль.';

  @override
  String get loginConnectionError =>
      'Нет подключения. Проверьте интернет и попробуйте снова.';

  @override
  String get loginTimeoutError => 'Время запроса истекло. Попробуйте снова.';

  @override
  String get loginForgotPasswordLink => 'Забыли пароль?';

  @override
  String get forgotPasswordTitle => 'Сброс пароля';

  @override
  String get forgotPasswordModeEmail => 'Email';

  @override
  String get forgotPasswordModeSms => 'SMS';

  @override
  String get forgotPasswordModeAdmin => 'Администратор';

  @override
  String get forgotPasswordEmailSent =>
      'Ссылка для сброса отправлена (если аккаунт найден).';

  @override
  String get forgotPasswordEmptyError =>
      'Введите email или имя пользователя, чтобы продолжить.';

  @override
  String get forgotPasswordEmailButton => 'Отправить ссылку по email';

  @override
  String get forgotPasswordSmsButton => 'Отправить ссылку по SMS';

  @override
  String get forgotPasswordLinkExpires =>
      'Срок действия ссылки — 1 час, использовать можно только один раз.';

  @override
  String get pushPermissionTitle => 'Будьте в курсе';

  @override
  String get pushPermissionBody =>
      'Включите уведомления, чтобы не пропустить оценки, сообщения или изменения в расписании.';

  @override
  String commonRequiredField(Object field) {
    return '$field обязательно';
  }

  @override
  String get commonAttachments => 'Вложения';

  @override
  String get commonAttachFile => 'Прикрепить файл';

  @override
  String get commonReplaceFile => 'Заменить файл';

  @override
  String get commonTitleRequired => 'Название обязательно';

  @override
  String get commonPublish => 'Опубликовать';

  @override
  String get commonContinue => 'Продолжить';

  @override
  String get commonNext => 'Далее';

  @override
  String get commonStart => 'Начало';

  @override
  String get commonEnd => 'Конец';

  @override
  String get commonRefresh => 'Обновить';

  @override
  String get commonRemove => 'Удалить';

  @override
  String get commonOpen => 'Открыть';

  @override
  String get commonView => 'Просмотр';

  @override
  String get commonCopy => 'Копировать';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get commonOptional => 'Необязательно';

  @override
  String get commonRequired => 'Обязательно';

  @override
  String get commonAuto => 'Авто';

  @override
  String get teacherShareButton => 'Поделиться';

  @override
  String get teacherMaterialDetails => 'Сведения о материале';

  @override
  String get teacherMaterialTitleLabel => 'Название *';

  @override
  String get teacherMaterialDescriptionLabel => 'Описание (необязательно)';

  @override
  String get teacherMaterialContentSection => 'Содержимое';

  @override
  String get teacherMaterialContentRequired =>
      'Прикрепите файл или добавьте ссылку';

  @override
  String teacherFilePickError(Object error) {
    return 'Не удалось выбрать файл: $error';
  }

  @override
  String get teacherScheduleButton => 'Запланировать';

  @override
  String get teacherMeetingTitleField => 'Название встречи *';

  @override
  String get teacherMeetingLinkField => 'Ссылка на встречу *';

  @override
  String get teacherMeetingLinkRequired => 'Ссылка на встречу обязательна';

  @override
  String get teacherMeetingTitleRequired => 'Название встречи обязательно';

  @override
  String get teacherMeetingDateTimeRequired =>
      'Дата и время начала обязательны';

  @override
  String get teacherMeetingStartDate => 'Дата начала *';

  @override
  String get teacherMeetingStartTime => 'Время начала *';

  @override
  String get teacherMeetingEndDate => 'Дата окончания (необязательно)';

  @override
  String get teacherMeetingEndTime => 'Время окончания (необязательно)';

  @override
  String get teacherClearEndTime => 'Очистить время окончания';

  @override
  String get teacherAssignmentTitleField => 'Название *';

  @override
  String get teacherAssignmentInstructions => 'Инструкции (необязательно)';

  @override
  String get teacherAssignmentDueDate => 'Срок сдачи (необязательно)';

  @override
  String get teacherAssignmentClearDueDate => 'Очистить срок';

  @override
  String get teacherAssignmentMaxGrade => 'Максимальная оценка (необязательно)';

  @override
  String get teacherAssignmentPublished => 'Задание опубликовано.';

  @override
  String get teacherAssignmentDraftSaved => 'Черновик сохранён.';

  @override
  String get teacherCreateAssignment => 'Создать';

  @override
  String get teacherExamSubject => 'Предмет *';

  @override
  String get teacherExamDate => 'Дата экзамена *';

  @override
  String get teacherSelectSubject => 'Выберите предмет';

  @override
  String get teacherNoSubjectOption => 'Без предмета';

  @override
  String get teacherOtherSubjectOption => 'Другое';

  @override
  String get teacherSearchClassrooms => 'Поиск классов…';

  @override
  String get teacherSearchMaterials => 'Поиск материалов…';

  @override
  String get teacherClassroomName => 'Название класса *';

  @override
  String get adminReportsOpenTab => 'Открытые';

  @override
  String get adminReportsResolvedTab => 'Решённые';

  @override
  String get adminReportsDismissedTab => 'Отклонённые';

  @override
  String get adminReportsNoOpen => 'Нет открытых жалоб';

  @override
  String get adminReportsNoInView => 'Нет жалоб в этом виде';

  @override
  String get adminReportsMediaAttachment => '[Медиа-вложение]';

  @override
  String get adminReportsEmptyMessage => '(пустое сообщение)';

  @override
  String get adminReportsDismiss => 'Отклонить';

  @override
  String get adminReportsResolve => 'Решить';

  @override
  String adminReportsReason(Object reason) {
    return 'Причина: $reason';
  }

  @override
  String get chatReportTitle => 'Пожаловаться на сообщение';

  @override
  String get chatReportButton => 'Пожаловаться';

  @override
  String get chatReportSuccess =>
      'Жалоба отправлена. Спасибо — администратор рассмотрит.';

  @override
  String chatReportFailed(Object error) {
    return 'Не удалось отправить жалобу: $error';
  }

  @override
  String chatSendError(Object message) {
    return 'Не удалось отправить: $message';
  }

  @override
  String chatForwardLabel(Object count) {
    return 'Переслать $count';
  }

  @override
  String chatDeleteLabel(Object count) {
    return 'Удалить $count';
  }

  @override
  String chatSelectedCount(Object count) {
    return 'Выбрано: $count';
  }

  @override
  String get adminPasswordReqEmpty => 'Нет ожидающих запросов';

  @override
  String get adminPasswordReqExplainer =>
      'Пользователи, которых вы одобрили или отклонили, здесь не появятся. Ожидающие запросы истекают через 24 часа.';

  @override
  String get adminPasswordReqApproveTitle => 'Одобрить смену пароля?';

  @override
  String adminPasswordReqApproveExplain(Object name) {
    return 'Это установит пароль $name тот, который он ввёл (вы его не видите).';
  }

  @override
  String adminPasswordReqVerifyWarning(Object name) {
    return 'Одобряйте только если вы убедились, что заявитель действительно $name — позвоните ему или подтвердите лично. Любой, кто знает имя пользователя, может подать такой запрос.';
  }

  @override
  String get adminPasswordReqConfirmApprove => 'Подтвердил — одобрить';

  @override
  String adminPasswordReqApproveSnackbar(Object name) {
    return 'Одобрено — $name теперь может войти.';
  }

  @override
  String get adminPasswordReqRejectTitle => 'Отклонить смену пароля?';

  @override
  String adminPasswordReqRejectExplain(Object name) {
    return 'Пароль $name не изменится. При необходимости он может подать новый запрос.';
  }

  @override
  String get adminPasswordReqRejectSnackbar => 'Отклонено.';

  @override
  String get adminPasswordReqRejectButton => 'Отклонить';

  @override
  String get adminPasswordReqApproveButton => 'Одобрить';

  @override
  String get adminPasswordReqCardCopy =>
      'Хочет сменить пароль. Новый пароль скрыт.';

  @override
  String get adminPasswordReqCallTooltip => 'Позвонить';

  @override
  String get adminPasswordReqSmsTooltip => 'SMS';

  @override
  String get adminSetupSchoolSetup => 'Настройка школы';

  @override
  String get adminSetupComplete =>
      'Всё готово. Нажмите на любой пункт, чтобы вернуться или уточнить.';

  @override
  String get adminSetupInstructions =>
      'Завершите эти шаги для полной настройки школы.';

  @override
  String get adminSetupLogoTitle => 'Загрузить логотип школы';

  @override
  String get adminSetupLogoSubtitle =>
      'Отображается в заголовках и боковом меню';

  @override
  String get adminSetupNameTitle => 'Указать название школы';

  @override
  String get adminSetupNameSubtitle => 'Видно ученикам, учителям и родителям';

  @override
  String get adminSetupSubjectsTitle => 'Определить предметы';

  @override
  String get adminSetupSubjectsSubtitle =>
      'Минимум один класс с настроенными предметами';

  @override
  String get adminSetupBellTitle => 'Настроить расписание звонков';

  @override
  String get adminSetupBellSubtitle => 'Время начала и окончания каждого урока';

  @override
  String get adminSetupCohortsTitle => 'Создать группы';

  @override
  String get adminSetupCohortsSubtitle => 'Настройте группы классов';

  @override
  String get adminSetupStudentsTitle => 'Добавить учеников';

  @override
  String get adminSetupStudentsSubtitle =>
      'Создайте аккаунты или сгенерируйте коды присоединения';

  @override
  String get adminSetupTeachersTitle => 'Добавить учителей';

  @override
  String get adminSetupTeachersSubtitle => 'Создайте аккаунты учителей';

  @override
  String get supportContactTitle => 'Свяжитесь с нами';

  @override
  String get supportContactDescription =>
      'Не нашли ответ ниже? Напишите нам, и мы ответим в течение рабочего дня.';

  @override
  String get supportEmailLabel => 'Email';

  @override
  String get supportPhoneLabel => 'Телефон';

  @override
  String get supportSmsLabel => 'Сообщение';

  @override
  String get aboutWhatIsClassmate => 'Что такое ClassMate?';

  @override
  String get aboutClassmateDescription =>
      'ClassMate — это операционная система школы для учеников, учителей, администраторов и родителей. Одно приложение, четыре роли, все стороны учебного дня в одном месте — расписание, посещаемость, оценки, классы, задания, сообщения и AI-помощник.';

  @override
  String get aboutMultilingualTitle =>
      'Создано для школ, где говорят на нескольких языках';

  @override
  String get aboutMultilingualDescription =>
      'Каждое имя, предмет и объявление может иметь до пяти языковых вариантов (английский, арабский, иврит, французский, русский). Ученики видят язык, который им удобнее; учителя управляют на своём.';

  @override
  String get aboutPrivacyTitle => 'Сначала конфиденциальность';

  @override
  String get aboutPrivacyDescription =>
      'Данные школы остаются в школе. Роли чётко соответствуют тому, что каждый видит — учителя видят свои классы, администраторы — свою школу, родители — своих детей. Без сторонних трекеров и рекламных сетей.';

  @override
  String get aboutContactTitle => 'Контакты';

  @override
  String get aboutContactDescription =>
      'Создано Tony Aboud и командой ClassMate.\nВопросы: tony@classmateapp.org';

  @override
  String aboutVersionLabel(Object version) {
    return 'ClassMate · в. $version';
  }

  @override
  String get adminAddStudent => 'Добавить ученика';

  @override
  String get adminAddTeacher => 'Добавить учителя';

  @override
  String get adminAddParent => 'Добавить родителя';

  @override
  String get adminAddSecretary => 'Добавить секретаря';

  @override
  String get adminAddAdmin => 'Добавить администратора';

  @override
  String get adminEditUser => 'Изменить пользователя';

  @override
  String get adminNoEmailPlaceholder => '(нет email)';

  @override
  String get adminNameEnglishRequired => 'Требуется полное имя (на английском)';

  @override
  String get adminUsernameRequired => 'Требуется имя пользователя';

  @override
  String get adminPasswordMinLength =>
      'Пароль должен содержать не менее 8 символов (или оставьте пустым для авто-генерации)';

  @override
  String adminUserCreatedMsg(Object name) {
    return '$name создан.';
  }

  @override
  String get adminCredsUsername => 'Имя пользователя';

  @override
  String get adminCredsEmail => 'Email';

  @override
  String get adminCredsPassword => 'Пароль';

  @override
  String get adminShareCredsHint => 'Передайте эти данные ученику.';

  @override
  String get adminCopyCredsButton => 'Копировать всё';

  @override
  String get adminGradeLabel => 'Класс';

  @override
  String adminCohortGradeFormat(Object grade) {
    return 'Класс $grade';
  }

  @override
  String get adminCreateAndAddStudents => 'Создать и добавить учеников';

  @override
  String get adminAddStudentsTitle => 'Добавить учеников';

  @override
  String get adminSkipAdding => 'Пропустить';

  @override
  String get adminInCohortBadge => 'В группе';

  @override
  String get adminNoStudentsFoundCohort =>
      'Ученики не найдены в классах этой группы';

  @override
  String get adminScheduleByCohort => 'По группе ▾';

  @override
  String get adminScheduleByStudent => 'По ученику ▾';

  @override
  String get adminScheduleAddGrade => 'Добавить класс';

  @override
  String get adminScheduleAddCohort => 'Добавить группу';

  @override
  String get adminScheduleAddStudent => 'Добавить ученика';

  @override
  String get adminScheduleClearFilters => 'Очистить';

  @override
  String get adminSchedulePickSubjectRequired =>
      'Выберите предмет перед сохранением урока.';

  @override
  String get adminSchedulePickDateOnce => 'Выберите дату для разового урока.';

  @override
  String adminSchedulePickDateRecurring(Object freq) {
    return 'Выберите дату начала для расписания каждые $freq нед.';
  }

  @override
  String get adminSchoolLogoLabel => 'Логотип школы';

  @override
  String get adminSchoolLogoUploaded => 'Логотип загружен';

  @override
  String get adminSchoolNoLogoYet => 'Логотипа ещё нет';

  @override
  String get adminSchoolLogoDescription =>
      'Отображается рядом с названием школы в боковом меню.';

  @override
  String get adminSchoolLogoChange => 'Изменить';

  @override
  String get adminSchoolLogoUpload => 'Загрузить';

  @override
  String get adminSchoolLogoRemove => 'Удалить';

  @override
  String get adminSchoolGradeRangeLabel => 'Диапазон классов';

  @override
  String get adminSchoolGradeRangeDescription =>
      'Классы, доступные в группах, учениках и выпадающих списках.';

  @override
  String get adminSchoolLowestGrade => 'Минимум';

  @override
  String get adminSchoolHighestGrade => 'Максимум';

  @override
  String get adminSchoolSubjectsTitle => 'Предметы школы';

  @override
  String get adminSchoolSubjectsDescription =>
      'Доступны всем учителям при создании заданий.';

  @override
  String get adminSchoolNoTranslations => 'Нажмите, чтобы добавить переводы';

  @override
  String get adminSchoolBellHint =>
      'Установите время начала и окончания каждого урока. Добавьте или удалите уроки по необходимости.';

  @override
  String get adminSchoolBellInfo =>
      'Установите время начала и окончания каждого урока. Это время будет использоваться по умолчанию при построении недельного расписания.';

  @override
  String get adminSchoolStartTime => 'Начало';

  @override
  String get adminSchoolEndTime => 'Конец';

  @override
  String get adminExportStudentsTab => 'Ученики';

  @override
  String get adminExportCohortsTab => 'Группы';

  @override
  String get adminExportGradesTab => 'Классы';

  @override
  String get adminExportOptionsTitle => 'Параметры экспорта';

  @override
  String get adminExportIncludePasswords => 'Включить пароли';

  @override
  String get adminExportCsvButton => 'Экспорт CSV';

  @override
  String get adminExportPdfButton => 'Экспорт PDF';

  @override
  String get teacherCreateClassroomTooltip => 'Создать класс';

  @override
  String get teacherClassroomNameRequired => 'Название класса *';

  @override
  String get teacherSubjectRequired => 'Предмет *';

  @override
  String messagesStartChatError(Object error) {
    return 'Не удалось начать чат: $error';
  }

  @override
  String messagesNoPeopleMatch(Object query) {
    return 'Никто не соответствует запросу «$query»';
  }

  @override
  String get messagesNoPeopleFound => 'Никого не найдено';

  @override
  String messagesPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count человек',
      many: '$count человек',
      few: '$count человека',
      one: '1 человек',
    );
    return '$_temp0';
  }

  @override
  String get studentAssignmentValidationRequired =>
      'Добавьте заметку или прикрепите файл перед сдачей.';

  @override
  String get studentFormSubmittedBanner => 'Ваши отправленные ответы';

  @override
  String studentFormSubmitError(Object error) {
    return 'Не удалось отправить: $error';
  }

  @override
  String studentFormFieldRequired(Object field) {
    return 'Обязательно: $field';
  }

  @override
  String get studentFormClosedButton => 'Форма закрыта';

  @override
  String get studentFormAlreadySubmittedButton => 'Уже отправлено';

  @override
  String get studentDiplomaEditTitle => 'Изменить сертификат';

  @override
  String get studentDiplomaDeleteTitle => 'Удалить сертификат?';

  @override
  String studentDiplomaDeleteConfirm(Object name) {
    return 'Удалить сертификат для «$name»?';
  }

  @override
  String teacherDeleteItemConfirm(Object title) {
    return 'Удалить «$title»?';
  }

  @override
  String get teacherPublishTooltip => 'Опубликовать';

  @override
  String get teacherMeetingEnterTitle => 'Пожалуйста, введите название.';

  @override
  String get teacherMeetingEnterLink =>
      'Пожалуйста, введите ссылку на встречу.';

  @override
  String get teacherMeetingEnterValidUrl =>
      'Пожалуйста, введите корректный URL (например, https://zoom.us/j/...)';

  @override
  String get teacherMeetingPickStartTime =>
      'Пожалуйста, выберите время начала.';

  @override
  String get teacherMeetingVisibleToEveryone => 'Видно всем';

  @override
  String teacherMeetingDoneCount(int count) {
    return 'Готово (выбрано $count)';
  }

  @override
  String get teacherDeleteAssignmentTitle => 'Удалить задание?';

  @override
  String get teacherDeleteAssignmentBody =>
      'Это навсегда удалит задание и все сданные работы.';

  @override
  String get teacherEditTooltip => 'Изменить';

  @override
  String get teacherDeleteTooltip => 'Удалить';

  @override
  String get teacherClassroomBackTooltip => 'Назад';

  @override
  String teacherClassroomGenericError(Object error) {
    return 'Ошибка: $error';
  }

  @override
  String teacherClassroomAttachFailed(Object error) {
    return 'Не удалось прикрепить: $error';
  }

  @override
  String get teacherClassroomFileUnavailable =>
      'Этот файл недоступен — учителю нужно загрузить его заново.';

  @override
  String get teacherClassroomCodeLabel => 'Код класса';

  @override
  String get teacherClassroomCodeCopied => 'Код скопирован';

  @override
  String get teacherClassroomCopyCodeTooltip => 'Копировать код';

  @override
  String teacherClassroomCouldNotAdd(Object emails) {
    return 'Не удалось добавить: $emails — проверьте их email.';
  }

  @override
  String get teacherClassroomAddStudents => 'Добавить учеников';

  @override
  String get teacherClassroomSearchNameGrade => 'Поиск по имени или классу…';

  @override
  String get teacherClassroomNoStudentsFound => 'Ученики не найдены';

  @override
  String get teacherClassroomNameSubjectRequired => 'Требуется имя и предмет.';

  @override
  String get teacherClassroomCreated => 'Класс создан!';

  @override
  String get teacherCustomSubjectLabel => 'Свой предмет *';

  @override
  String get teacherCreateClassroomButton => 'Создать класс';

  @override
  String get teacherCreateFormTitle => 'Создание формы';

  @override
  String get teacherFormSaveDraft => 'Сохранить черновик';

  @override
  String get teacherFormTitleHint => 'Название формы *';

  @override
  String get teacherFormDescriptionHint => 'Описание (необязательно)';

  @override
  String get teacherFormAcceptingResponses => 'Принимает ответы';

  @override
  String get teacherFormAllowMultiple => 'Разрешить несколько ответов';

  @override
  String get teacherFormAllowMultipleSubtitle =>
      'Выкл. = один раз на ученика (по умолчанию)';

  @override
  String get teacherFormQuestionsSection => 'Вопросы';

  @override
  String get teacherFormAddQuestionButton => 'Добавить вопрос';

  @override
  String teacherFormQuestionPlaceholder(Object index) {
    return 'Вопрос $index';
  }

  @override
  String get teacherFormRequiredToggle => 'Обязательный';

  @override
  String get teacherFormAddOptionButton => 'Добавить вариант';

  @override
  String get teacherFormMinLabel => 'Мин';

  @override
  String get teacherFormMaxLabel => 'Макс';

  @override
  String get teacherFormEnterTitle => 'Пожалуйста, введите название формы.';

  @override
  String teacherExamUploadFailedSkipped(Object name) {
    return 'Не удалось загрузить $name. Файл пропущен.';
  }

  @override
  String get teacherExamEnterTitle => 'Пожалуйста, введите название.';

  @override
  String get teacherExamPickDate => 'Пожалуйста, выберите дату экзамена.';

  @override
  String get teacherExamSelectSubject => 'Пожалуйста, выберите предмет.';

  @override
  String teacherSlotDetachFailed(Object error) {
    return 'Не удалось открепить: $error';
  }

  @override
  String teacherSlotAttachFailed(Object error) {
    return 'Не удалось прикрепить: $error';
  }

  @override
  String get teacherSlotAttachMaterial => 'Прикрепить материал';

  @override
  String get teacherSlotDetachTooltip => 'Открепить';

  @override
  String get teacherDiplomaSelectStudent => 'Сначала выберите ученика.';

  @override
  String get teacherDiplomaUploadingWait =>
      'Пожалуйста, подождите — файлы ещё загружаются.';

  @override
  String teacherDiplomaIssueFailed(Object error) {
    return 'Не удалось выдать сертификат: $error';
  }

  @override
  String get teacherDiplomaCertTitleLabel => 'Название сертификата';

  @override
  String get teacherDiplomaSearchStudent => 'Поиск ученика…';

  @override
  String get teacherProfileChatError => 'Не удалось начать чат';

  @override
  String get teacherGradeAssignmentType => 'Задание';

  @override
  String get teacherGradeExamType => 'Экзамен';

  @override
  String get teacherGradeOtherType => 'Другое';

  @override
  String get teacherGradeOutOfLabel => 'Из (необязательно)';

  @override
  String get teacherGradePublishedTitle => 'Опубликовано';

  @override
  String get teacherGradePublishedSubtitle => 'Ученики видят эту оценку';

  @override
  String get teacherMaterialPickSubject => 'Пожалуйста, выберите предмет.';

  @override
  String get teacherMaterialAddLink => 'Добавить ссылку';

  @override
  String get teacherMaterialAddFile => 'Добавить файл';

  @override
  String get teacherMaterialSearchStudentsGrade =>
      'Поиск учеников или класса...';

  @override
  String teacherMaterialDoneSelected(int count) {
    return 'Готово (выбрано $count)';
  }

  @override
  String get adminSubjectEnglishNameRequired =>
      'Требуется название на английском';

  @override
  String adminSubjectNameInLang(Object language) {
    return 'Название на $language';
  }

  @override
  String get adminSubjectResetButton => 'Сбросить';

  @override
  String get teacherAnnounceBroadcastTitle => 'Отправить всем?';

  @override
  String get teacherAnnounceSendToEveryone => 'Отправить всем';

  @override
  String get teacherAnnounceNoCohorts => 'Нет доступных групп';

  @override
  String get teacherAnnounceNothingFound => 'Ничего не найдено';

  @override
  String get teacherAnnounceNoParents => 'В этой школе не найдено родителей.';
}

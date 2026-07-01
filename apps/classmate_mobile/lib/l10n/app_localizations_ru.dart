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
  String get roleStudent => 'Ученик';

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
  String get scheduleNoSubjectLocation => 'Пока нет предмета или места';

  @override
  String get scheduleNotes => 'Заметки';

  @override
  String get scheduleGoToClassroom => 'Перейти к классу';

  @override
  String get loginTitle => 'Вход для учеников и учителей';

  @override
  String get loginSubtitle => 'Войдите, чтобы продолжить';

  @override
  String get loginSignIn => 'Войти';

  @override
  String get biometricSignIn => 'Вход по биометрии';

  @override
  String get biometricEnable => 'Включить вход по биометрии';

  @override
  String get biometricReason => 'Пройдите аутентификацию для входа в ClassMate';

  @override
  String get biometricEnableReason =>
      'Пройдите аутентификацию, чтобы включить вход по биометрии';

  @override
  String get biometricSignInFaceId => 'Вход с Face ID';

  @override
  String get biometricSignInFingerprint => 'Вход по отпечатку пальца';

  @override
  String get biometricOrSignInWith => 'или войдите с помощью';

  @override
  String get biometricNotSetUp =>
      'Вход по биометрии ещё не настроен. Включите Face ID или отпечаток пальца в разделе «Профиль» → «Вход по биометрии».';

  @override
  String get biometricNotRecognized =>
      'Биометрия не распознана. Попробуйте ещё раз или войдите с паролем.';

  @override
  String get biometricFaceUnavailable =>
      'Face ID недоступен на этом устройстве.';

  @override
  String get biometricFingerprintUnavailable =>
      'Отпечаток пальца недоступен на этом устройстве.';

  @override
  String get biometricNotAvailableOnDevice => 'Недоступно на этом устройстве';

  @override
  String get biometricSectionTitle => 'Вход по биометрии';

  @override
  String get biometricSectionSubtitle =>
      'Включите Face ID или отпечаток пальца, чтобы входить быстрее. Пароль нужно будет подтвердить один раз.';

  @override
  String get biometricFaceId => 'Face ID';

  @override
  String get biometricFaceIdDesc => 'Использовать Face ID для входа';

  @override
  String get biometricFingerprint => 'Отпечаток пальца';

  @override
  String get biometricFingerprintDesc =>
      'Использовать отпечаток пальца для входа';

  @override
  String get biometricConfirmPasswordTitle => 'Подтвердите пароль';

  @override
  String get biometricConfirmPasswordBody =>
      'Введите пароль, чтобы включить вход по биометрии.';

  @override
  String get biometricPasswordIncorrect =>
      'Неверный пароль. Попробуйте ещё раз.';

  @override
  String get biometricEnrollFailed =>
      'Не удалось проверить биометрию. Убедитесь, что Face ID или отпечаток пальца настроены в настройках устройства.';

  @override
  String get biometricEnterCredsFirst =>
      'Сначала введите email и пароль, затем включите вход по биометрии.';

  @override
  String get biometricLoginFailed =>
      'Не удалось войти по биометрии. Войдите с паролем.';

  @override
  String get biometricEnrollTitle => 'Включить вход по биометрии?';

  @override
  String get biometricEnrollBody =>
      'Используйте Face ID или отпечаток пальца, чтобы в следующий раз входить быстрее.';

  @override
  String get biometricEnrollYes => 'Включить';

  @override
  String get biometricEnrollNo => 'Не сейчас';

  @override
  String get loginWelcomeTitle => 'С возвращением';

  @override
  String get loginWelcomeSubtitle => 'Войдите в свой аккаунт ClassMate.';

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
  String get profileMyCohorts => 'Мои группы';

  @override
  String get profileMyCohortsEmpty => 'Вы пока не состоите ни в одной группе.';

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
  String get messagesGroupMinMembers => 'Select at least 2 people for a group';

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
  String get teacherDeleteClassroom => 'Удалить класс';

  @override
  String get teacherDeleteClassroomConfirm =>
      'Это безвозвратно удалит класс и весь его чат, задания, материалы, встречи и список участников. Отменить нельзя.';

  @override
  String get teacherClassroomDeleted => 'Класс удалён';

  @override
  String get announcementsTabReceived => 'Полученные';

  @override
  String get announcementsTabPublished => 'Опубликованные';

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
  String get practiceModeActionSaveQuestion => 'Сохранить вопрос';

  @override
  String get practiceModeActionSavedQuestion => 'Сохранено';

  @override
  String get practiceModeQuestionSavedToast => 'Сохранено в ваших вопросах';

  @override
  String get practiceModeQuestionRemovedToast =>
      'Удалено из сохранённых вопросов';

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
  String get assignmentsStatusGraded => 'Оценено';

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
  String get formClosed => 'Закрыт';

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
  String get navPeople => 'Пользователи';

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
  String get adminAdmins => 'Администраторы';

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
      'Создано командой ClassMate.\nВопросы: support@classmateapp.org';

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
  String get adminScheduleByGrade => 'По классу ▾';

  @override
  String get navSupport => 'Поддержка';

  @override
  String get navAbout => 'О приложении';

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
  String get adminSchoolBellTitle => 'Расписание звонков';

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
  String get adminExportLanguageLabel => 'Язык имён в экспорте';

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

  @override
  String get teacherGradesToGrade => 'К оценке';

  @override
  String get teacherGradesGraded => 'Оценено';

  @override
  String get teacherSaveGradesButton => 'Сохранить оценки';

  @override
  String get teacherAllowResubmitLabel => 'Разрешить пересдачу';

  @override
  String get teacherAllowResubmitTitle => 'Разрешить пересдачу?';

  @override
  String teacherAllowResubmitBody(Object name) {
    return 'Это удалит работу $name, чтобы он мог сдать ещё раз.';
  }

  @override
  String get teacherAllowButton => 'Разрешить';

  @override
  String get teacherGradeFieldLabel => 'Оценка';

  @override
  String get teacherFeedbackOptionalLabel => 'Отзыв (необязательно)';

  @override
  String get teacherCreateClassroomFabLabel => 'Создать';

  @override
  String get teacherLoadingStudents => 'Загрузка учеников…';

  @override
  String get teacherSearchHintShort => 'Поиск…';

  @override
  String get teacherCreateClassroomTitle => 'Новый класс';

  @override
  String teacherAssignmentUploadFailed(Object name) {
    return 'Не удалось загрузить $name';
  }

  @override
  String get teacherAssignmentEnterTitle => 'Пожалуйста, введите название.';

  @override
  String get teacherAssignmentSelectSubject => 'Пожалуйста, выберите предмет.';

  @override
  String get teacherAssignmentInstructionsLabel => 'Инструкции / Описание';

  @override
  String get teacherAttachFilesButton => 'Прикрепить файлы';

  @override
  String get tutorDeleteConversationTitle => 'Удалить разговор?';

  @override
  String get tutorDeleteConversationButton => 'Удалить навсегда';

  @override
  String tutorDeleteFailed(Object error) {
    return 'Не удалось удалить: $error';
  }

  @override
  String get tutorDeleteMenuTitle => 'Удалить разговор';

  @override
  String get tutorDeleteMenuSubtitle => 'Безвозвратно удаляет с сервера';

  @override
  String get accountVerifyButton => 'Проверить';

  @override
  String get accountConfirmButton => 'Подтвердить';

  @override
  String get accountResendCode => 'Отправить код снова';

  @override
  String get accountCodeResent => 'Отправлен новый код.';

  @override
  String get accountContinueButton => 'Продолжить';

  @override
  String get studentClassroomFileUnavailable => 'Этот файл пока недоступен.';

  @override
  String get studentClassroomDeleteMaterial => 'Удалить материал?';

  @override
  String get studentClassroomCodeLabel => 'Код класса';

  @override
  String get studentClassroomLeaveTooltip => 'Покинуть класс';

  @override
  String get adminEditUserEnglishNameRequired => 'Требуется имя на английском';

  @override
  String get adminEditUserSaved => 'Сохранено';

  @override
  String adminEditUserPasswordChanged(Object name) {
    return 'Пароль для $name изменён.';
  }

  @override
  String get adminEditUserLoginSection => 'Вход';

  @override
  String get adminEditUserUsernameLabel => 'Имя пользователя';

  @override
  String get adminEditUserEmailOptional => 'Email (необязательно)';

  @override
  String get adminEditUserChangePassword => 'Сменить пароль';

  @override
  String get adminEditUserNameSection => 'Имя';

  @override
  String get adminEditUserAtLeastEnglish => 'Минимум на английском.';

  @override
  String get adminEditUserGradeSection => 'Класс';

  @override
  String get adminEditUserCohortsSection => 'Группы';

  @override
  String get adminEditUserLinkedChildren => 'Привязанные дети';

  @override
  String get adminEditUserLinkButton => 'Привязать';

  @override
  String get adminEditUserNoChildren => 'Дети ещё не привязаны.';

  @override
  String get adminEditUserSetPasswordTitle => 'Установить новый пароль';

  @override
  String get adminEditUserNewPasswordLabel => 'Новый пароль';

  @override
  String get adminEditUserConfirmPasswordLabel => 'Подтвердите пароль';

  @override
  String get adminEditUserSetPasswordButton => 'Установить пароль';

  @override
  String get adminPeriodsTitle => 'Управление уроками';

  @override
  String get adminPeriodsAddPeriod => 'Добавить урок';

  @override
  String get adminPeriodsNoPeriods => 'Уроков пока нет';

  @override
  String get adminPeriodsTapToAdd => 'Нажмите +, чтобы добавить первый урок';

  @override
  String get adminPeriodsNewPeriod => 'Новый урок';

  @override
  String get adminPeriodsDayLabel => 'День';

  @override
  String get adminPeriodsPeriodLabel => 'Урок';

  @override
  String get adminPeriodsTimeLabel => 'Время';

  @override
  String get adminPeriodsTeacherLabel => 'Учитель';

  @override
  String get adminPeriodsClassroomOptional => 'Класс (необязательно)';

  @override
  String get adminPeriodsCohortsLabel => 'Группы';

  @override
  String get adminPeriodsStudentsOptional => 'Ученики (необязательно)';

  @override
  String get adminPeriodsSearchByName => 'Поиск по имени…';

  @override
  String commonErrorWith(Object error) {
    return 'Ошибка: $error';
  }

  @override
  String commonAddCount(int count) {
    return 'Добавить $count';
  }

  @override
  String get teacherStudentGradesSaved => 'Оценки сохранены';

  @override
  String get teacherStudentToGrade => 'Ожидает оценки';

  @override
  String get teacherStudentGraded => 'Оценено';

  @override
  String get classroomFileNotAvailable => 'Этот файл пока недоступен.';

  @override
  String get classroomDeleteMaterialTitle => 'Удалить материал?';

  @override
  String get classroomCodeLabel => 'Код класса';

  @override
  String get plansCouldNotOpenSubscription =>
      'Не удалось открыть настройки подписки.';

  @override
  String plansFailedToOpen(Object error) {
    return 'Не удалось открыть: $error';
  }

  @override
  String get plansManageSubscription => 'Управление подпиской или отмена';

  @override
  String get plansUpgrade => 'Улучшить';

  @override
  String get plansTryAgain => 'Повторить';

  @override
  String adminCohortsGradeOnly(String grade) {
    return 'Только $grade класс';
  }

  @override
  String adminCohortsGradeRangeOnly(int from, int to) {
    return 'Только классы $from-$to';
  }

  @override
  String get adminExportNeedStudents =>
      'Сначала выберите хотя бы одного ученика или группу';

  @override
  String adminExportButton(int count) {
    return 'Экспортировать $count';
  }

  @override
  String get adminExportNoStudents => 'Ученики не найдены';

  @override
  String get adminExportIncludesPasswords => 'Экспорт будет включать пароли';

  @override
  String get adminExportAnyway => 'Всё равно экспортировать';

  @override
  String get adminExportPdfStudentDirectory => 'Справочник учеников';

  @override
  String adminExportPdfBy(String name) {
    return 'От: $name';
  }

  @override
  String adminExportPdfStudentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учеников',
      many: '$count учеников',
      few: '$count ученика',
      one: '$count ученик',
    );
    return '$_temp0';
  }

  @override
  String get adminExportPdfFooter => 'Создано в ClassMate';

  @override
  String get adminExportColumnIndex => '№';

  @override
  String get adminExportColumnName => 'Имя';

  @override
  String get adminExportColumnEmail => 'Эл. почта';

  @override
  String get adminExportColumnUsername => 'Логин';

  @override
  String get adminExportColumnPhone => 'Телефон';

  @override
  String get adminExportColumnGrade => 'Класс';

  @override
  String get adminExportColumnCohorts => 'Группы';

  @override
  String get adminExportColumnSchool => 'Школа';

  @override
  String get adminExportColumnPassword => 'Пароль';

  @override
  String get adminExportColumnNameEn => 'Имя (EN)';

  @override
  String get adminExportColumnNameAr => 'Имя (AR)';

  @override
  String get adminExportColumnNameHe => 'Имя (HE)';

  @override
  String get adminExportColumnNameFr => 'Имя (FR)';

  @override
  String get adminExportColumnNameRu => 'Имя (RU)';

  @override
  String adminExportStudentsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано $count учеников',
      many: 'Выбрано $count учеников',
      few: 'Выбрано $count ученика',
      one: 'Выбран $count ученик',
    );
    return '$_temp0';
  }

  @override
  String get teacherMaterialEditTitle => 'Изменить материал';

  @override
  String get teacherMaterialAddTitle => 'Добавить материал';

  @override
  String get teacherMaterialAudienceTitle => 'Аудитория';

  @override
  String get teacherMaterialAudienceClassrooms => 'Классы';

  @override
  String get teacherMaterialAudienceCohorts => 'Группы';

  @override
  String get teacherMaterialAudienceGrades => 'Параллели';

  @override
  String get teacherMaterialAudienceStudents => 'Ученики';

  @override
  String get teacherMaterialDetailsTitle => 'Детали';

  @override
  String get teacherMaterialSubjectRequired => 'Предмет *';

  @override
  String get teacherMaterialSubjectSelect => 'Выберите предмет';

  @override
  String get teacherMaterialSubjectOther => 'Другой';

  @override
  String get teacherMaterialSubjectSearch => 'Поиск предметов...';

  @override
  String get teacherMaterialAttachmentsTitle => 'Вложения';

  @override
  String teacherMaterialAttachmentsWithCount(int count) {
    return 'Вложения ($count)';
  }

  @override
  String get teacherMaterialDeleteTitle => 'Удалить материал?';

  @override
  String get teacherMaterialListTitle => 'Материалы';

  @override
  String teacherMaterialTotalCount(int count) {
    return 'Всего $count';
  }

  @override
  String get teacherMaterialRetry => 'Повторить';

  @override
  String get teacherMaterialNoMaterials =>
      'Материалов пока нет.\nНажмите +, чтобы добавить.';

  @override
  String get teacherMaterialPublished => 'Опубликован';

  @override
  String get teacherMaterialDraft => 'Черновик';

  @override
  String get teacherMaterialSearchHint => 'Поиск…';

  @override
  String teacherMaterialSelectedCount(int count) {
    return 'Выбрано $count';
  }

  @override
  String teacherMaterialMembersWillReceive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участников получат это',
      many: '$count участников получат это',
      few: '$count участника получат это',
      one: '$count участник получит это',
    );
    return '$_temp0';
  }

  @override
  String teacherMaterialStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учеников',
      many: '$count учеников',
      few: '$count ученика',
      one: '$count ученик',
    );
    return '$_temp0';
  }

  @override
  String get teacherMaterialPickerNone => 'Нет';

  @override
  String get teacherMaterialPickerCohortsTitle => 'Выберите группы';

  @override
  String get teacherMaterialPickerClassroomTitle => 'Выберите класс';

  @override
  String get teacherMaterialPickerStudentsTitle => 'Выберите учеников';

  @override
  String get teacherMaterialPickerGradesTitle => 'Выберите параллели';

  @override
  String get adminScheduleAddNew => 'Добавить';

  @override
  String adminScheduleAddCount(int count) {
    return 'Добавить ($count)';
  }

  @override
  String get adminScheduleCaptionOptional => 'Подпись (необязательно)';

  @override
  String get adminScheduleCaptionHint => 'напр. Повторение к экзамену';

  @override
  String get adminScheduleAudienceCohorts => 'Группы';

  @override
  String get adminScheduleAudienceStudents => 'Ученики';

  @override
  String get adminScheduleAudienceGrade => 'Класс';

  @override
  String get adminScheduleSearchStudents => 'Поиск учеников…';

  @override
  String get adminScheduleSearchSubjects => 'Поиск предметов школы…';

  @override
  String get adminScheduleEveryPrefix => 'Каждые ';

  @override
  String get adminScheduleWeeksSuffix => ' недели';

  @override
  String adminScheduleSlotN(int index) {
    return 'Слот $index';
  }

  @override
  String adminScheduleSelectedCount(int count) {
    return 'Выбрано $count';
  }

  @override
  String get adminScheduleConflictingPeriod => 'Конфликтующий урок';

  @override
  String get adminScheduleKeepCurrent => 'Оставить текущий';

  @override
  String get adminScheduleOverride => 'Заменить';

  @override
  String get adminScheduleShowBoth => 'Показать оба';

  @override
  String get adminScheduleDeletePeriodTitle => 'Удалить урок?';

  @override
  String get adminScheduleDeletePeriodBody =>
      'Это удалит слот из расписания. Прошлая посещаемость сохраняется.';

  @override
  String get adminScheduleFailedToDelete => 'Не удалось удалить урок.';

  @override
  String get adminSchedulePickSubjectFirst =>
      'Выберите предмет перед сохранением урока.';

  @override
  String adminScheduleOverrideFailed(Object error) {
    return 'Замена не удалась: $error';
  }

  @override
  String get adminScheduleFailedToCreateSlots => 'Не удалось создать слоты';

  @override
  String adminScheduleCreatedSlots(int created, int total, String error) {
    return 'Создано $created/$total слотов. $error';
  }

  @override
  String adminScheduleSavedLabelOnlyError(Object error) {
    return 'Сохранено как метка — не удалось добавить в библиотеку: $error';
  }

  @override
  String get adminScheduleSavedLabelPickAudience =>
      'Сохранено как метка. Сначала выберите аудиторию, чтобы добавить также в библиотеку школы.';

  @override
  String get commonNothingFound => 'Ничего не найдено';

  @override
  String commonDownloadFailed(Object error) {
    return 'Не удалось скачать: $error';
  }

  @override
  String commonFailedWith(Object error) {
    return 'Не удалось: $error';
  }

  @override
  String get commonCreate => 'Создать';

  @override
  String get commonAttachStudyMaterials => 'Прикрепить учебные материалы';

  @override
  String get teacherCreateClassroomNewTitle => 'Новый класс';

  @override
  String get teacherCreateClassroomLoadingStudents => 'Загрузка учеников…';

  @override
  String get teacherExamPublishedHint =>
      'Опубликован — ученики видят этот экзамен';

  @override
  String teacherDoneSelected(int count) {
    return 'Готово (выбрано $count)';
  }

  @override
  String get secretaryAllCohorts => 'Все группы';

  @override
  String get secretaryClassrooms => 'Классы';

  @override
  String get adminPeopleGrade => 'Класс';

  @override
  String get adminSchoolSettingsTapToAddTranslations =>
      'Нажмите, чтобы добавить переводы';

  @override
  String adminSchoolSettingsAddPeriodNum(int num) {
    return 'Добавить урок (P$num)';
  }

  @override
  String get adminVisibleToEveryone => 'Видно всем';

  @override
  String get navMaterials => 'Материалы';

  @override
  String get classMaterialsAddTitle => 'Добавить материал';

  @override
  String get classMaterialsTitleLabel => 'Название';

  @override
  String classMaterialsFilesCount(int count) {
    return '$count файлов';
  }

  @override
  String get classMaterialsLoadError => 'Не удалось загрузить материалы';

  @override
  String get classMaterialsEmpty =>
      'Пока нет общих материалов — добавьте первым.';

  @override
  String get navPlans => 'Планы NOVA';

  @override
  String get navReports => 'Жалобы';

  @override
  String get navExportData => 'Экспорт данных';

  @override
  String get sectionSecretaryTools => 'Инструменты секретаря';

  @override
  String get sectionSchoolToolsLabel => 'Инструменты школы';

  @override
  String get sectionAdminTools => 'Инструменты администратора';

  @override
  String get chatVideoTrimTitle => 'Обрезать видео';

  @override
  String get chatMediaPreviewTrimAction => 'Обрезать';

  @override
  String get commonUntitled => 'Без названия';

  @override
  String get plansMonthlyPlans => 'Месячные планы';

  @override
  String get plansTokenTopups => 'Пакеты токенов';

  @override
  String get plansTopupsSubtitle =>
      'Разовые покупки. Не истекают. Добавляются к вашему плану.';

  @override
  String get plansCouldntLoadBalance => 'Не удалось загрузить ваш баланс';

  @override
  String get plansFreePlan => 'Бесплатный план';

  @override
  String get planTierFree => 'Бесплатно';

  @override
  String get planTierBudget => 'Экономный';

  @override
  String get planTierBalance => 'Сбалансированный';

  @override
  String get planTierCommitment => 'Максимальный';

  @override
  String get topupPackSmall => 'Маленький пакет';

  @override
  String get topupPackMedium => 'Средний пакет';

  @override
  String get topupPackLarge => 'Большой пакет';

  @override
  String get topupPackMega => 'Огромный пакет';

  @override
  String get planBlurbFree => 'Попробуйте NOVA. Обновляется каждый месяц.';

  @override
  String get planBlurbBudget => 'Ежедневная помощь с домашкой.';

  @override
  String get planBlurbBalance =>
      'Для учеников, которые занимаются каждый день.';

  @override
  String get planBlurbCommitment =>
      'Интенсивная практика + безграничное любопытство.';

  @override
  String plansTokensPerMonth(String tokens) {
    return '$tokens токенов / месяц';
  }

  @override
  String plansTokensOneTime(String tokens) {
    return '$tokens токенов';
  }

  @override
  String get planPriceFree => 'Бесплатно';

  @override
  String get plansTokensRemaining => 'токенов осталось';

  @override
  String plansPlanResetsAt(String when) {
    return 'План обнуляется $when';
  }

  @override
  String plansTopupTokensInfo(String tokens) {
    return '$tokens токенов пакета (без срока)';
  }

  @override
  String get plansHowTokensWorkTitle => 'Как работают токены';

  @override
  String get plansHowTokensWorkBody =>
      'Токены — это то, как ИИ измеряет свою работу.\n• Короткий вопрос ≈ 2 000 токенов\n• Длинное объяснение или тренировка ≈ 5 000–10 000\n• Анализ изображений стоит чуть больше\n\nМесячные токены обнуляются 1-го числа. Токены пакетов никогда не истекают.';

  @override
  String get plansPerMonthSuffix => ' / мес';

  @override
  String get plansCurrentBadge => 'ТЕКУЩИЙ';

  @override
  String get plansCouldntLoadPlans => 'Не удалось загрузить планы';

  @override
  String get paywallPlansUnavailable =>
      'Планы недоступны. Попробуйте через мгновение.';

  @override
  String get paywallTopupUnavailable =>
      'Пакет недоступен. Магазин ещё не одобрил этот продукт.';

  @override
  String get paywallRestored => 'Ваша подписка восстановлена.';

  @override
  String get paywallNoRestores =>
      'Прошлые покупки на этом Apple ID не найдены.';

  @override
  String paywallRestoreFailed(String error) {
    return 'Не удалось восстановить: $error';
  }

  @override
  String get paywallPurchasesRestricted =>
      'Покупки ограничены на этом устройстве.';

  @override
  String get paywallPurchaseInvalid =>
      'Эта покупка недействительна. Попробуйте другой способ оплаты.';

  @override
  String get paywallProductNotAvailable =>
      'Этот план сейчас недоступен. Попробуйте позже.';

  @override
  String get paywallNetworkError =>
      'Проблема с сетью. Проверьте соединение и повторите.';

  @override
  String get paywallPaymentPending =>
      'Оплата ожидает одобрения (родительский контроль и т.п.). Активируется после одобрения.';

  @override
  String get paywallStoreProblem =>
      'Возникла проблема в App Store. Повторите через минуту.';

  @override
  String get paywallGenericError => 'Что-то пошло не так. Повторите.';

  @override
  String paywallWelcomeMessage(String plan) {
    return 'Добро пожаловать в $plan! Токены уже в пути.';
  }

  @override
  String get paywallWelcomeFallback => 'ваш новый план';

  @override
  String get paywallTopupAdded => 'Пакет добавлен. Токены уже в пути.';

  @override
  String get paywallPurchaseProcessed =>
      'Покупка обработана. Токены скоро появятся.';

  @override
  String paywallSubscribeTo(String plan) {
    return 'Подписаться на $plan';
  }

  @override
  String paywallBuyTopupNamed(String topup) {
    return 'Купить $topup';
  }

  @override
  String get paywallPlanFallback => 'план';

  @override
  String get paywallTopupFallback => 'пакет';

  @override
  String get paywallTopupBlurb =>
      'Разовая покупка. Токены не истекают и добавляются к вашему плану.';

  @override
  String paywallPerMonthWithTokens(String tokens) {
    return 'в месяц · $tokens';
  }

  @override
  String paywallOneTimeWithTokens(String tokens) {
    return 'разово · $tokens';
  }

  @override
  String get paywallSubscribeButton => 'Подписаться';

  @override
  String get paywallBuyButton => 'Купить';

  @override
  String get paywallRestoreButton => 'Восстановить покупки';

  @override
  String get paywallNotNow => 'Не сейчас';

  @override
  String get paywallWebOnlyTitle => 'Покупка через мобильное приложение';

  @override
  String get paywallWebOnlyBody =>
      'Подписки и пополнения оформляются через App Store или Google Play. Откройте ClassMate на iPhone, iPad или Android, чтобы оформить подписку — ваш аккаунт и токены синхронизируются между устройствами.';

  @override
  String get paywallWebOnlyDismiss => 'Понятно';

  @override
  String get paywallTermsSubscription =>
      'Подписываясь, вы соглашаетесь с Условиями и Политикой конфиденциальности ClassMate. Подписки продлеваются автоматически каждый месяц до отмены. Управление в любое время через ваш аккаунт App Store.';

  @override
  String get paywallTermsTopup =>
      'Покупая, вы соглашаетесь с Условиями и Политикой конфиденциальности ClassMate. Токены пакетов не подлежат возврату после использования.';

  @override
  String get paywallTermsLink => 'Условия использования (EULA)';

  @override
  String get paywallPrivacyLink => 'Политика конфиденциальности';

  @override
  String get paywallFeatureTokens => 'Используйте токены в NOVA и тренировках';

  @override
  String get paywallFeatureImages =>
      'Анализ изображений и загрузка файлов включены';

  @override
  String get paywallFeatureReset => 'Токены обнуляются в начале каждого месяца';

  @override
  String get paywallFeatureCancel => 'Отмена в любое время — без обязательств';

  @override
  String get studentMaterialsGeneralSubject => 'Общие';

  @override
  String studentMaterialsResourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count материалов от ваших учителей',
      many: '$count материалов от ваших учителей',
      few: '$count материала от ваших учителей',
      one: '$count материал от ваших учителей',
    );
    return '$_temp0';
  }

  @override
  String classroomsCouldNotLoadWithError(String error) {
    return 'Не удалось загрузить классы\n$error';
  }

  @override
  String get parentNoNotificationsYet => 'Уведомлений пока нет.';

  @override
  String forwardCouldNotLoadChats(Object error) {
    return 'Не удалось загрузить чаты: $error';
  }

  @override
  String get forwardNoChats => 'Нет чатов';

  @override
  String get commonTitle => 'Заголовок';

  @override
  String get commonNotes => 'Заметки';

  @override
  String get commonEmail => 'Эл. почта';

  @override
  String get commonPassword => 'Пароль';

  @override
  String get commonNumberOfPages => 'Количество страниц';

  @override
  String get messagesSearchByNameOrGrade => 'Поиск по имени или классу…';

  @override
  String get meetingStartDateRequired => 'Дата начала *';

  @override
  String get meetingStartTimeRequired => 'Время начала *';

  @override
  String get meetingEndDateOptional => 'Дата окончания (необязательно)';

  @override
  String get meetingEndTimeOptional => 'Время окончания (необязательно)';

  @override
  String get teacherMaterialLinkUrlOptional => 'Ссылка / URL (необязательно)';

  @override
  String get teacherSearchStudentsOrGrade => 'Поиск учеников или класса…';

  @override
  String get teacherSearchParentsOrChildren => 'Поиск родителей или детей…';

  @override
  String get studentAssignmentAddNoteOptional =>
      'Добавить заметку (необязательно)…';

  @override
  String get adminEditUserUsernameRequired => 'Логин *';

  @override
  String get reportReasonOptional => 'Причина (необязательно)';

  @override
  String get forwardSearchChatsAndClassrooms => 'Поиск чатов и классов…';

  @override
  String get profileNewPhone => 'Новый телефон';

  @override
  String get profileNewEmail => 'Новая эл. почта';

  @override
  String adminExportPasswordsWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Файл будет содержать данные входа $count учеников, включая текущие пароли. Любой, у кого есть файл, может войти как один из этих учеников — делитесь осторожно и удаляйте после использования. Строки для аккаунтов, созданных до последнего обновления, могут показывать пустой пароль, пока каждый пользователь не войдёт снова или не сбросит его.',
      many:
          'Файл будет содержать данные входа $count учеников, включая текущие пароли. Любой, у кого есть файл, может войти как один из этих учеников — делитесь осторожно и удаляйте после использования. Строки для аккаунтов, созданных до последнего обновления, могут показывать пустой пароль, пока каждый пользователь не войдёт снова или не сбросит его.',
      few:
          'Файл будет содержать данные входа $count учеников, включая текущие пароли. Любой, у кого есть файл, может войти как один из этих учеников — делитесь осторожно и удаляйте после использования. Строки для аккаунтов, созданных до последнего обновления, могут показывать пустой пароль, пока каждый пользователь не войдёт снова или не сбросит его.',
      one:
          'Файл будет содержать данные входа $count ученика, включая текущий пароль. Любой, у кого есть файл, может войти как этот ученик — делитесь осторожно и удаляйте после использования. Строки для аккаунтов, созданных до последнего обновления, могут показывать пустой пароль, пока пользователь не войдёт снова или не сбросит его.',
    );
    return '$_temp0';
  }

  @override
  String get pickerSelectStudents => 'Выберите учеников';

  @override
  String get pickerSelectCohorts => 'Выберите группы';

  @override
  String get pickerSelectGrades => 'Выберите классы';

  @override
  String get pickerSelectClassroom => 'Выберите класс';

  @override
  String get pickerSelectClasses => 'Выберите классы';

  @override
  String get drawerLoadingChildren => 'Загрузка детей…';

  @override
  String get drawerCouldNotLoadChildren => 'Не удалось загрузить детей';

  @override
  String get drawerNoChildrenLinked => 'Нет привязанных детей';

  @override
  String get drawerSwitchChild => 'Сменить ребёнка';

  @override
  String get shellAssessmentCreated => 'Оценка создана';

  @override
  String commonCouldNotOpenLink(String scheme) {
    return 'Не удалось открыть ссылку $scheme';
  }

  @override
  String commonCouldntSend(String error) {
    return 'Не удалось отправить: $error';
  }

  @override
  String get teacherExamDetailsSection => 'Детали экзамена';

  @override
  String teacherExamStudyMaterialsWithCount(int count) {
    return 'Учебные материалы ($count)';
  }

  @override
  String get teacherMeetingDetailsSection => 'Детали встречи';

  @override
  String get teacherClassroomNameSection => 'Название класса';

  @override
  String get teacherAddByCohortSection => 'Добавить по группе';

  @override
  String get teacherAddIndividualStudentsSection =>
      'Добавить отдельных учеников';

  @override
  String get teacherGradeTypeSection => 'Тип оценки';

  @override
  String get teacherOtherGradeSection => 'Другая оценка';

  @override
  String get teacherEnterGradesSection => 'Введите оценки';

  @override
  String teacherAttachmentsWithCount(int count) {
    return 'Вложения ($count)';
  }

  @override
  String get studentFilesSharedByTeacher => 'Файлы, поделённые учителем';

  @override
  String get studentYourSubmission => 'Ваша работа';

  @override
  String get studentFilesSharedWithAnnouncement =>
      'Файлы, прикреплённые к этому объявлению.';

  @override
  String get announcementGradeRiskTitle => 'Обнаружен риск по оценкам';

  @override
  String get announcementWeakSubjectTitle => 'Обнаружен слабый предмет';

  @override
  String get announcementLowAttendanceTitle => 'Низкая посещаемость';

  @override
  String get announcementRepeatedLatenessTitle => 'Повторные опоздания';

  @override
  String get announcementPracticeWeaknessTitle =>
      'Обнаружены слабые места в тренировке';

  @override
  String get announcementPracticeTrendDroppedTitle => 'Тренд тренировок упал';

  @override
  String get announcementSolutionsActivityTitle =>
      'Активность Solutions в эфире';

  @override
  String get announcementAllGoodTitle => 'Всё в порядке';

  @override
  String get supportSectionGettingStarted => 'Начало работы';

  @override
  String get supportSectionAccountPassword => 'Аккаунт и пароль';

  @override
  String get supportSectionForStudents => 'Для учеников';

  @override
  String get supportSectionForTeachers => 'Для учителей';

  @override
  String get supportSectionForAdministrators => 'Для администраторов';

  @override
  String get supportSectionForParents => 'Для родителей';

  @override
  String get supportSectionPrivacyData => 'Конфиденциальность и данные';

  @override
  String get novaDisclaimerCanMakeMistakes => 'Может ошибаться';

  @override
  String get novaDisclaimerEducationalUseOnly => 'Только для учебных целей';

  @override
  String get novaDisclaimerYourPrivacy => 'Ваша приватность';

  @override
  String profileNameInLanguage(String language) {
    return 'Имя на $language';
  }

  @override
  String get adminSettingsScheduleSubtitle =>
      'Привязать учителей и группы к еженедельным временным слотам';

  @override
  String get practiceModeBalancedSubtitle =>
      'Сбалансированная ежедневная тренировка';

  @override
  String get practiceModeRevealSubtitle => 'Открытие и самопроверка';

  @override
  String get practiceModeFastSubtitle => 'Быстрая тренировка под давлением';

  @override
  String get practiceModeExamSubtitle => 'Спокойный экзаменационный поток';

  @override
  String get practiceModeConceptSubtitle => 'Сначала концепция, потом решение';

  @override
  String get practiceModeAdaptiveSubtitle =>
      'Сложность меняется в реальном времени';

  @override
  String get practiceModeStrictSubtitle => 'Строгий официальный стиль';

  @override
  String get commonCall => 'Позвонить';

  @override
  String get tooltipClearEndTime => 'Очистить время окончания';

  @override
  String get tooltipDeletePeriod => 'Удалить урок';

  @override
  String get tooltipLeaveClassroom => 'Покинуть класс';

  @override
  String get announcementGradeRiskBody =>
      'Ваш средний балл упал ниже 70. Рекомендуется немедленное действие.';

  @override
  String announcementWeakSubjectBody(String subject) {
    return '$subject требует внимания.';
  }

  @override
  String get announcementLowAttendanceBody =>
      'Ваша посещаемость падает. Это повлияет на оценки.';

  @override
  String get announcementLatenessBody => 'У вас несколько опозданий.';

  @override
  String announcementPracticeWeakTopicBody(String topic, String subject) {
    return '$topic в $subject замедляет ваш прогресс.';
  }

  @override
  String get announcementPracticeDropBody =>
      'Ваша недавняя практика ниже базового уровня. Замедлитесь и пересоберитесь.';

  @override
  String announcementSolutionsActivityBody(int page, int question) {
    return 'Ваше пространство решений активно на странице $page, вопрос $question. Проверьте работы сверстников или загрузите свою.';
  }

  @override
  String get announcementAllGoodBody =>
      'Серьёзных академических рисков сейчас не обнаружено.';

  @override
  String get faqStartedQ1 => 'Как мне войти?';

  @override
  String get faqStartedA1 =>
      'Нажмите «Войти» на экране приветствия и введите электронную почту или имя пользователя, которые дал вам школьный администратор, плюс временный пароль. В первый раз вас попросят установить новый пароль.';

  @override
  String get faqStartedQ2 => 'У меня ещё нет аккаунта.';

  @override
  String get faqStartedA2 =>
      'Аккаунты создаёт школьный администратор. Попросите его добавить вас в приложении администратора или поделиться кодом присоединения, если в школе используется самостоятельная регистрация.';

  @override
  String get faqStartedQ3 =>
      'Могу ли я использовать приложение на своём языке?';

  @override
  String get faqStartedA3 =>
      'Да — ClassMate поддерживает английский, арабский, иврит, французский и русский. Откройте Настройки, чтобы сменить язык. Также можно установить предпочитаемый язык имени в Профиле.';

  @override
  String get faqStartedQ4 =>
      'Как переключаться между тёмным и светлым режимом?';

  @override
  String get faqStartedA4 =>
      'Откройте Настройки из меню и переключите переключатель внешнего вида. По умолчанию приложение следует системным настройкам.';

  @override
  String get faqAccountQ1 => 'Я забыл пароль.';

  @override
  String get faqAccountA1 =>
      'Нажмите «Забыли пароль?» на экране входа. Вы получите ссылку для сброса по электронной почте или код по SMS. Если ни один канал ещё не подтверждён, попросите школьного администратора выдать новый временный пароль.';

  @override
  String get faqAccountQ2 => 'Как сменить пароль?';

  @override
  String get faqAccountA2 =>
      'Откройте Профиль из меню, прокрутите до Безопасности, и нажмите строку пароля. Вам понадобится текущий пароль, чтобы установить новый.';

  @override
  String get faqAccountQ3 =>
      'Как сменить электронную почту или номер телефона?';

  @override
  String get faqAccountA3 =>
      'Откройте Профиль, нажмите на поле, которое хотите изменить, и следуйте подсказкам проверки. Сначала на ВАШУ текущую почту/телефон отправляется код для подтверждения личности, затем вы можете задать новое значение.';

  @override
  String get faqAccountQ4 =>
      'Школьный администратор может сменить мой пароль — как это работает?';

  @override
  String get faqAccountA4 =>
      'Когда администратор сбрасывает ваш пароль, вы получите письмо и SMS со ссылкой в одно нажатие для установки собственного пароля. Администратор никогда не видит, что вы выбираете.';

  @override
  String get faqStudentsQ1 => 'Где я вижу своё расписание?';

  @override
  String get faqStudentsA1 =>
      'Расписание — первый пункт в меню. Вы увидите уроки этой недели, кто их ведёт, и любые изменения, опубликованные администратором.';

  @override
  String get faqStudentsQ2 => 'Как присоединиться к классу?';

  @override
  String get faqStudentsA2 =>
      'Учитель добавит вас напрямую или поделится кодом присоединения. Чтобы использовать код, откройте Классы из меню и нажмите «Присоединиться с кодом».';

  @override
  String get faqStudentsQ3 => 'Как работают посещаемость и оценки?';

  @override
  String get faqStudentsA3 =>
      'Учителя отмечают посещаемость во время урока. Откройте Посещаемость или Оценки из меню, чтобы увидеть свои записи. Родители, привязанные к вашему аккаунту, видят те же данные.';

  @override
  String get faqStudentsQ4 => 'Что такое Nova?';

  @override
  String get faqStudentsA4 =>
      'Nova — это ваш ИИ-помощник по учёбе. Попросите его объяснить понятие, создать тест или разобрать задачу шаг за шагом. Откройте Nova из меню, чтобы начать сессию.';

  @override
  String get faqTeachersQ1 => 'Как создать класс?';

  @override
  String get faqTeachersA1 =>
      'Откройте Классы из меню и нажмите кнопку +. Дайте классу название и предмет; учеников можно добавить вручную или с помощью кода присоединения.';

  @override
  String get faqTeachersQ2 => 'Как отмечать посещаемость?';

  @override
  String get faqTeachersA2 =>
      'Откройте Посещаемость из меню, выберите дату и урок, затем нажмите на каждого ученика, чтобы установить его статус. Изменения сохраняются автоматически.';

  @override
  String get faqTeachersQ3 => 'Как назначить домашнее задание?';

  @override
  String get faqTeachersA3 =>
      'Откройте Задания, нажмите +, заполните заголовок/срок/вложения, и выберите цель (вся школа, конкретные группы или названные ученики). Ученики мгновенно увидят это в своём меню.';

  @override
  String get faqTeachersQ4 => 'Могу ли я выдать диплом или сертификат?';

  @override
  String get faqTeachersA4 =>
      'Да — откройте Дипломы из меню, нажмите +, выберите ученика, заполните заголовок и детали, и сохраните. Ученик увидит его в своём разделе Дипломов.';

  @override
  String get faqAdminsQ1 => 'С чего начать настройку школы?';

  @override
  String get faqAdminsA1 =>
      'Откройте Панель администратора. Виджет Настройка школы вверху показывает чек-лист из 7 шагов (логотип, название, предметы, расписание звонков, группы, ученики, учителя). Каждый шаг ведёт прямо туда, где вы его завершаете.';

  @override
  String get faqAdminsQ2 => 'Как работают группы?';

  @override
  String get faqAdminsA2 =>
      'Группа — это набор учеников с общим расписанием. Откройте Группы из меню, чтобы создавать их, назначать учеников и генерировать коды присоединения. Одна группа может охватывать несколько классов.';

  @override
  String get faqAdminsQ3 => 'Может ли группа охватывать более одного класса?';

  @override
  String get faqAdminsA3 =>
      'Да — при создании группы выберите несколько классов. Группа появится в фильтрах и видах любого из этих классов, и объявления/шаблоны, направленные на любой из этих классов, дойдут до неё.';

  @override
  String get faqAdminsQ4 => 'Как составить недельное расписание?';

  @override
  String get faqAdminsA4 =>
      'Откройте Расписание из меню. Нажмите на любую ячейку, чтобы добавить урок — выберите день/урок, учителя, предмет и аудиторию (группа/ученик/класс). Время звонков берётся из Настроек школы.';

  @override
  String get faqAdminsQ5 => 'Как массово экспортировать учеников?';

  @override
  String get faqAdminsA5 =>
      'Откройте Экспорт данных из меню. Выберите, выбирать по ученику или по группе, выберите строки и нажмите Экспортировать. По желанию включите текущие пароли при экспорте.';

  @override
  String get faqAdminsQ6 =>
      'Пользователь попросил сбросить пароль. Что делать?';

  @override
  String get faqAdminsA6 =>
      'Вы можете установить пароль напрямую (Профиль пользователя → Безопасность) или дождаться, пока он подаст запрос через «Забыли пароль», и одобрить его из Запросов пароля в меню.';

  @override
  String get faqParentsQ1 => 'Как связать мой аккаунт с ребёнком?';

  @override
  String get faqParentsA1 =>
      'Попросите школьного администратора ребёнка добавить связь из приложения администратора или поделиться одноразовым кодом связи родителя. Откройте Профиль и введите код в разделе Семья.';

  @override
  String get faqParentsQ2 => 'Что я могу видеть о своём ребёнке?';

  @override
  String get faqParentsA2 =>
      'Посещаемость, оценки, объявления и домашние задания — ровно то, что видит ваш ребёнок, плюс динамика во времени. Личные чаты и сессии Nova не видны.';

  @override
  String get faqPrivacyQ1 => 'Кто может видеть мои данные?';

  @override
  String get faqPrivacyA1 =>
      'Только люди в вашей школе. Учителя видят данные своих классов, администраторы — данные по всей школе, родители — связанных детей. Мы никогда не продаём данные рекламодателям.';

  @override
  String get faqPrivacyQ2 => 'Как удалить аккаунт?';

  @override
  String get faqPrivacyA2 =>
      'Попросите школьного администратора удалить его. Он может удалить аккаунт из приложения администратора, что стирает ваш профиль, расписание и чаты.';

  @override
  String solutionsPagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count страниц',
      many: '$count страниц',
      few: '$count страницы',
      one: '$count страница',
    );
    return '$_temp0';
  }

  @override
  String get teacherMeetingEditTitle => 'Изменить встречу';

  @override
  String get teacherMeetingNewTitle => 'Назначить встречу';

  @override
  String get teacherExamEditTitle => 'Изменить экзамен';

  @override
  String get teacherExamNewTitle => 'Создать экзамен';

  @override
  String get teacherAssignmentEditTitle => 'Изменить задание';

  @override
  String get teacherAssignmentNewTitle => 'Новое задание';

  @override
  String get tooltipShowTabs => 'Показать вкладки';

  @override
  String get tooltipHideTabs => 'Скрыть вкладки';

  @override
  String get examsCouldNotLoadForms => 'Не удалось загрузить формы';

  @override
  String get examsCouldNotLoadExams => 'Не удалось загрузить экзамены';

  @override
  String get messagesNoPeopleToAdd => 'Нет людей для добавления';

  @override
  String commonNoResultsForQuery(String query) {
    return 'Нет результатов для «$query»';
  }

  @override
  String chatForwardedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Переслано в $count чатов',
      many: 'Переслано в $count чатов',
      few: 'Переслано в $count чата',
      one: 'Переслано в 1 чат',
    );
    return '$_temp0';
  }

  @override
  String get commonReadMore => 'Читать дальше';

  @override
  String get commonReadLess => 'Скрыть';

  @override
  String get chatComposerSlideToCancel => 'Сдвиньте для отмены';

  @override
  String adminNoRoleYet(String role) {
    return 'Нет ещё $role';
  }

  @override
  String get profileVerified => 'Подтверждено.';

  @override
  String get profileUpdatedPendingVerification =>
      'Обновлено, ожидает повторной проверки.';

  @override
  String get adminSearchCohorts => 'Поиск групп…';

  @override
  String get commonAdding => 'Добавление…';

  @override
  String get teacherDiplomaIssuing => 'Выдача…';

  @override
  String get teacherDiplomaIssue => 'Выдать';

  @override
  String get formAccepting => 'Принимает';

  @override
  String get profileVerifiedShort => 'Подтверждено';

  @override
  String get profileUnverified => 'Не подтверждено';

  @override
  String get notificationNewGradePosted => 'Опубликована новая оценка';

  @override
  String notificationNewGradePostedIn(String subject) {
    return 'Опубликована новая оценка по $subject';
  }

  @override
  String messagesAddParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Добавить $count участников',
      many: 'Добавить $count участников',
      few: 'Добавить $count участников',
      one: 'Добавить 1 участника',
    );
    return '$_temp0';
  }

  @override
  String get notificationFallbackTitle => 'Уведомление';

  @override
  String adminCohortGradeRange(int from, int to) {
    return 'Класс $from-$to';
  }

  @override
  String adminCohortGradesList(String list) {
    return 'Классы $list';
  }

  @override
  String get adminExportHeaderTitle => 'Экспорт пользователей';

  @override
  String get adminExportHeaderSubtitle =>
      'Добавляйте фильтры как метки — каждая метка добавляет пользователей в экспорт. Нажмите на метку, чтобы убрать её.';

  @override
  String get adminExportAddFilter => 'Добавить фильтр';

  @override
  String get adminExportEmptyState =>
      'Добавьте фильтр для начала: выберите роль, группу, класс или конкретных пользователей.';

  @override
  String get adminExportFilterRolesTab => 'Роли';

  @override
  String get adminExportFilterCohortsTab => 'Группы';

  @override
  String get adminExportFilterGradesTab => 'Классы';

  @override
  String get adminExportFilterUsersTab => 'Пользователи';

  @override
  String get adminExportSelectAll => 'Выбрать всех';

  @override
  String adminExportSelectedCount(int selected, int total) {
    return 'Выбрано $selected из $total';
  }

  @override
  String adminExportRolePickedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'выбрано $count',
      many: 'выбрано $count',
      few: 'выбрано $count',
      one: 'выбран $count',
    );
    return '$_temp0';
  }

  @override
  String get adminExportPillRolePrefix => 'Роль:';

  @override
  String get adminExportPillCohortPrefix => 'Группа:';

  @override
  String adminExportActiveFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count активных фильтров',
      many: '$count активных фильтров',
      few: '$count активных фильтра',
      one: '$count активный фильтр',
    );
    return '$_temp0';
  }

  @override
  String get adminExportClearAll => 'Очистить всё';

  @override
  String get adminExportCounting => 'Подсчёт…';

  @override
  String adminExportMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Будут экспортированы $count пользователей',
      many: 'Будут экспортированы $count пользователей',
      few: 'Будут экспортированы $count пользователя',
      one: 'Будет экспортирован $count пользователь',
    );
    return '$_temp0';
  }

  @override
  String get adminExportNoGradesConfigured =>
      'В этой школе нет настроенных классов';

  @override
  String get adminExportColumnRole => 'Роль';

  @override
  String get adminExportRoleStudent => 'Ученик';

  @override
  String get adminExportRoleTeacher => 'Учитель';

  @override
  String get adminExportRoleParent => 'Родитель';

  @override
  String get adminExportRoleSecretary => 'Секретарь';

  @override
  String get adminExportRoleAdmin => 'Администратор';

  @override
  String adminExportUsersSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано $count пользователей',
      many: 'Выбрано $count пользователей',
      few: 'Выбрано $count пользователя',
      one: 'Выбран $count пользователь',
    );
    return '$_temp0';
  }

  @override
  String get adminExportPasswordsOn =>
      'Пароли будут видны в экспорте — обращайтесь с файлом безопасно.';

  @override
  String get adminExportPasswordsOff => 'Экспорт не будет содержать паролей.';

  @override
  String get adminExportPdfUserDirectory => 'Справочник пользователей';

  @override
  String adminExportPdfUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пользователей',
      many: '$count пользователей',
      few: '$count пользователя',
      one: '$count пользователь',
    );
    return '$_temp0';
  }

  @override
  String get teacherAttachFromMaterials => 'Из материалов';

  @override
  String get teacherUploadFiles => 'Загрузить файлы';

  @override
  String get solSubjectMathematics => 'Математика';

  @override
  String get solSubjectComputerScience => 'Информатика';

  @override
  String get solSubjectPhysics => 'Физика';

  @override
  String get solSubjectChemistry => 'Химия';

  @override
  String get solSubjectHebrew => 'Иврит';

  @override
  String get solSubjectBiology => 'Биология';

  @override
  String get solSubjectHistory => 'История';

  @override
  String get solSubjectArabic => 'Арабский';

  @override
  String get solSubjectElectronics => 'Электроника';

  @override
  String get solSubjectMechanics => 'Механика';

  @override
  String get solSubjectFrench => 'Французский';

  @override
  String get solSubjectEnvironmentalScience => 'Экология';

  @override
  String get solSubjectCommunicationCinema => 'Коммуникация и кино';

  @override
  String get solSubjectCitizenship => 'Граждановедение';

  @override
  String get solSubjectSociology => 'Социология';

  @override
  String get solSubjectReligion => 'Религия';

  @override
  String get solSubjectGeography => 'География';

  @override
  String get solSubjectPsychology => 'Психология';

  @override
  String get insightsSemesterTitle => 'Этот семестр';

  @override
  String get insightsOnTimeSubmissions => 'Сдано вовремя';

  @override
  String get insightsSubmissionsTitle => 'Сдачи';

  @override
  String get insightsOnTime => 'Вовремя';

  @override
  String get insightsLate => 'С опозданием';

  @override
  String get insightsMissing => 'Пропущено';

  @override
  String get insightsPending => 'Ожидает';

  @override
  String get insightsHandedInLabel => 'сдано';

  @override
  String get insightsLatestGrades => 'Последние оценки';

  @override
  String get insightsReviewWithNova => 'Разбор с Nova';

  @override
  String get insightsReviewWithNovaPrompt =>
      'Дай краткий и честный разбор моей успеваемости в этом семестре — оценки, посещаемость и сдачи — и главное, на чём мне сосредоточиться.';

  @override
  String get insightsPracticeTitle => 'Точность практики';

  @override
  String get commonUnknown => 'Неизвестно';

  @override
  String get solutionsReportTitle => 'Пожаловаться на решение';

  @override
  String get solutionsReportBody =>
      'Опишите проблему. Её рассмотрят администраторы обеих школ.';

  @override
  String get solutionsReportReasonHint => 'Причина (необязательно)';

  @override
  String get solutionsReportAction => 'Пожаловаться';

  @override
  String get solutionsReportSubmitted =>
      'Спасибо — жалоба отправлена администраторам.';

  @override
  String get solutionsReportAlready => 'Вы уже пожаловались на это.';

  @override
  String solutionsBookPagesCount(int count) {
    return '$count стр.';
  }

  @override
  String get solutionsNoBooksYetForStudents =>
      'Здесь пока нет книг. Их добавит ваш учитель.';

  @override
  String get solutionsManageBooksTitle => 'Управление книгами';

  @override
  String get solutionsNoBooksManageHint =>
      'Для этого предмета пока нет книг. Нажмите +, чтобы добавить.';

  @override
  String get solutionsDeleteBookTitle => 'Удалить книгу?';

  @override
  String solutionsDeleteBookBody(String title) {
    return 'Удалить «$title»? Это нельзя отменить.';
  }

  @override
  String solutionsBookSaveFailed(String error) {
    return 'Не удалось сохранить: $error';
  }

  @override
  String get solutionsBookDuplicateHint =>
      'Перед добавлением убедитесь, что этой книги ещё нет в базе.';

  @override
  String get solutionsBookDuplicateTitle => 'Возможный дубликат книги';

  @override
  String solutionsBookDuplicateBody(String title) {
    return 'Книга с названием «$title» уже существует. Убедитесь, что это не та же книга, прежде чем добавлять.';
  }

  @override
  String get solutionsBookAddAnyway => 'Всё равно добавить';

  @override
  String get solutionsBookNeedTitlePages => 'Укажите название и число страниц.';

  @override
  String get solutionsEditBookTitle => 'Редактировать книгу';

  @override
  String get solutionsBookCoverLabel => 'Обложка';

  @override
  String solutionsGradeLabel(int grade) {
    return 'Класс $grade';
  }

  @override
  String get solutionsReportsTitle => 'Жалобы на решения';

  @override
  String get solutionsReportsEmpty => 'Нет жалоб для рассмотрения.';

  @override
  String get solutionsReportPostedBy => 'Автор';

  @override
  String get solutionsReportReportedBy => 'Пожаловался';

  @override
  String get solutionsReportReasonLabel => 'Причина';

  @override
  String get solutionsReportKeepAction => 'Оставить';

  @override
  String get solutionsReportRemoveAction => 'Удалить';

  @override
  String get solutionsReportStatusPending => 'На рассмотрении';

  @override
  String get solutionsReportStatusApproved => 'Оставлено';

  @override
  String get solutionsReportStatusRemoved => 'Удалено';

  @override
  String get solutionsReportRemoved => 'Решение удалено.';

  @override
  String get solutionsReportApproved => 'Жалоба отклонена — решение оставлено.';

  @override
  String solutionsReportFailed(String error) {
    return 'Не удалось пожаловаться: $error';
  }

  @override
  String get teacherAddGradeTitle => 'Добавить оценку';

  @override
  String get commonCohort => 'Группа';

  @override
  String get teacherCreateNewExam => 'Создать экзамен';

  @override
  String get teacherCreateNewAssignment => 'Создать задание';

  @override
  String get commonReturn => 'Вернуть';

  @override
  String get reorderToolsTitle => 'Порядок меню';

  @override
  String get reorderToolsSubtitle =>
      'Перетаскивайте, чтобы изменить порядок раздела School Tools. Разделы Core и Account остаются на месте.';

  @override
  String get reorderToolsReset => 'Сброс';

  @override
  String get reorderToolsSettingsSection => 'Меню';

  @override
  String get reorderToolsSettingsSubtitle =>
      'Изменить порядок инструментов в боковом меню';

  @override
  String get adminSchoolGradeRangesDescription =>
      'Укажите, какие классы есть в школе. Добавьте несколько диапазонов, если некоторые классы отсутствуют (например, 4-6 и 9-12).';

  @override
  String get adminSchoolAddGradeRange => 'Добавить диапазон';

  @override
  String get teacherListStudents => 'Список учеников';

  @override
  String get teacherNoStudentsInvolved => 'В этом уроке пока нет учеников.';

  @override
  String get messagesFilterAdmins => 'Администраторы';

  @override
  String get teacherAssignmentGradedStatus => 'Оценено';

  @override
  String get teacherAssignmentReturnedStatus => 'Возвращено на доработку';

  @override
  String get teacherAssignmentReturnAction => 'Вернуть на доработку';

  @override
  String teacherAssignmentReturnDialogBody(String name) {
    return 'Вернуть эту работу ученику $name на доработку и повторную сдачу? Все ваши комментарии будут включены.';
  }

  @override
  String teacherGradesSavedOf(int saved, int total) {
    return 'Сохранено $saved из $total.';
  }

  @override
  String teacherGradesSkippedSuffix(int dropped) {
    return '$dropped ученик(ов) пропущено — не в группе.';
  }

  @override
  String get adminPeopleGradeLevelRequired =>
      'Выберите класс для этого ученика.';

  @override
  String teacherAddGradeLabel(int grade) {
    return 'Класс $grade';
  }

  @override
  String get teacherGradeOutOfHint => 'напр. 20';

  @override
  String get plansDowngrade => 'Понизить план';

  @override
  String get plansDowngradeNote =>
      'Начнётся после окончания текущего плана — он сохранится до тех пор, без возврата средств.';

  @override
  String get semesterThis => 'Текущий семестр';

  @override
  String get semesterPrevious => 'Предыдущие';

  @override
  String get showMore => 'Показать ещё';

  @override
  String get adminSchoolSemestersLabel => 'Семестры';

  @override
  String get adminSchoolSemestersDescription =>
      'Разделите учебный год на семестры по месяцам. Оценки, экзамены, встречи и прочее группируются по семестрам автоматически.';

  @override
  String adminSchoolSemesterN(String n) {
    return 'Семестр $n';
  }

  @override
  String get adminSchoolAddSemester => 'Добавить семестр';

  @override
  String get semesterStarts => 'Начало';

  @override
  String get semesterEnds => 'Конец';

  @override
  String get commonWhen => 'Когда';

  @override
  String get commonFiles => 'Файлы';

  @override
  String get commonOnce => 'Один раз';

  @override
  String get commonNoneDash => '— Нет —';

  @override
  String get commonNotesOptional => 'Заметки (необязательно)';

  @override
  String get commonSubjectOptional => 'Предмет (необязательно)';

  @override
  String get colorBlue => 'Синий';

  @override
  String get colorIndigo => 'Индиго';

  @override
  String get colorViolet => 'Фиолетовый';

  @override
  String get colorTeal => 'Бирюзовый';

  @override
  String get colorGreen => 'Зелёный';

  @override
  String get colorOrange => 'Оранжевый';

  @override
  String get colorRose => 'Розовый';

  @override
  String get teacherAddClassNotes => 'Добавить заметки к уроку';

  @override
  String get teacherStudentsWithGrades => 'Ученики с оценками';

  @override
  String get teacherOtherStudentsSameGrade =>
      'Другие ученики того же класса/группы';

  @override
  String get teacherChooseExam => 'Выберите экзамен';

  @override
  String get teacherChooseAssignment => 'Выберите задание';

  @override
  String get teacherSearchExams => 'Поиск экзаменов…';

  @override
  String get teacherSearchAssignments => 'Поиск заданий…';

  @override
  String get teacherSearchQuestionTypes => 'Поиск типов вопросов…';

  @override
  String get teacherOtherCustomSubject => 'Другое (свой вариант)';

  @override
  String get adminLinkChild => 'Привязать ребёнка';

  @override
  String get adminChooseStudentDash => '— Выберите ученика —';

  @override
  String get adminSelectStudentToLink => 'Выберите ученика для привязки';

  @override
  String get adminEditPeriod => 'Изменить период';

  @override
  String get adminNotInAnyCohort =>
      'Пока не состоит в группе — назначьте на экране «Группы».';

  @override
  String get adminPasswordChangeWarning =>
      'При следующем входе пользователь войдёт с этим паролем. Все ожидающие ссылки для сброса станут недействительными.';

  @override
  String get nameInEnglish => 'Имя на английском';

  @override
  String get nameInArabic => 'Имя на арабском';

  @override
  String get nameInHebrew => 'Имя на иврите';

  @override
  String get nameInFrench => 'Имя на французском';

  @override
  String get nameInRussian => 'Имя на русском';

  @override
  String get passwordMinChars => 'Не менее 8 символов.';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают.';

  @override
  String get adminWelcomeHeading => 'Добро пожаловать в ClassMate';

  @override
  String get diplomasNoFilesAttached =>
      'К этому сертификату не прикреплены файлы.';

  @override
  String get diplomasFilesProcessing =>
      'Не удалось открыть файлы — возможно, они ещё обрабатываются.';

  @override
  String get novaOutOfTokens =>
      'Вы израсходовали все токены за этот период. Обновите план или пополните, чтобы продолжить общение с NOVA.';

  @override
  String get tutorDeleteConversationWarning =>
      'Это навсегда удалит беседу и все её сообщения с сервера. Отменить будет нельзя.';

  @override
  String get chatReportFlagWarning =>
      'Это сообщение будет отправлено на проверку администратору.';

  @override
  String get solutionPreviewFailFallback =>
      'Откройте из вложения в чате, если предпросмотр не работает';

  @override
  String get practiceNoInternet =>
      'Нет подключения к интернету. Повторите попытку.';

  @override
  String get practiceGenerationFailed =>
      'Не удалось сгенерировать вопросы. Повторите попытку.';

  @override
  String get practiceTimingSecPerQuestion => 'с / вопрос';

  @override
  String get practiceTimingMinPerQuiz => 'мин / тест';

  @override
  String adminScheduleFrequencyWeeks(Object freq) {
    return '×$freq нед';
  }

  @override
  String gradeLevelLabel(Object grade) {
    return 'Класс $grade';
  }

  @override
  String adminPeriodOption(Object period) {
    return 'Период $period';
  }

  @override
  String cohortStudentsCount(Object count) {
    return '$count учеников';
  }

  @override
  String diplomasIssuedCount(Object count) {
    return 'Выдано сертификатов: $count';
  }

  @override
  String get adminExportImportantHeading => 'Важно';

  @override
  String get adminExportWelcomeBodyWithPw =>
      'Это данные вашей учётной записи ClassMate. Войдите в приложение ClassMate на iOS или Android, используя имя пользователя и пароль ниже. Пароль можно изменить в приложении.';

  @override
  String get adminExportWelcomeBodyNoPw =>
      'Это данные вашей учётной записи ClassMate. Войдите в приложение ClassMate на iOS или Android, используя имя пользователя.';

  @override
  String get adminExportNotePrivate =>
      'Храните эти данные в секрете. Не сообщайте пароль.';

  @override
  String get adminExportNoteChangePw =>
      'Смените пароль после первого входа в разделе «Настройки → Аккаунт».';

  @override
  String get adminExportNoteLegal =>
      'Используя ClassMate, вы принимаете Условия использования и Политику конфиденциальности.';

  @override
  String adminExportNoteHelp(String email) {
    return 'Нужна помощь? Обратитесь к администратору школы или на $email.';
  }

  @override
  String get teacherGradeTitleHint => 'напр. Работа на уроке, Тест 3';

  @override
  String get teacherClassroomNameHint => 'напр. Математика 10A';

  @override
  String get novaAbout => 'О NOVA';

  @override
  String get parentNotifForYou => 'Вам';

  @override
  String parentNotifAbout(String name) {
    return 'О $name';
  }

  @override
  String get navPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get privacyPolicySubtitle => 'Как мы защищаем ваши данные';

  @override
  String get semesterAllPrevious => 'Все предыдущие';

  @override
  String get semesterSelectTitle => 'Выберите семестр';

  @override
  String get adminImportUsersScreenTitle => 'Импорт пользователей';

  @override
  String get adminImportUsersScreenTabGrid => 'Таблица';

  @override
  String get adminImportUsersScreenTabCsv => 'CSV';

  @override
  String adminImportUsersScreenLoadedRows(int count) {
    return 'Загружено строк: $count — проверьте и отредактируйте, затем нажмите «Создать»';
  }

  @override
  String get adminImportUsersScreenFillAtLeastOneName =>
      'Укажите хотя бы одно имя';

  @override
  String adminImportUsersScreenFailed(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get adminImportUsersScreenBackToGrid => 'Назад к таблице';

  @override
  String get adminImportUsersScreenGridIntro =>
      'Заполняйте по строке на человека или загрузите CSV на вкладке CSV и поправьте всё здесь. Имя пользователя необязательно — если оставить пустым, мы создадим его автоматически. Для учеников укажите класс и (по желанию) имя пользователя родителя, чтобы связать их.';

  @override
  String get adminImportUsersScreenAddRow => 'Добавить строку';

  @override
  String adminImportUsersScreenCreateCount(int count) {
    return 'Создать ($count)';
  }

  @override
  String get adminImportUsersScreenRole => 'Роль';

  @override
  String get adminImportUsersScreenFullName => 'Полное имя *';

  @override
  String get adminImportUsersScreenUsername => 'Имя пользователя';

  @override
  String get adminImportUsersScreenUsernameHint =>
      '(автоматически, если пусто)';

  @override
  String get adminImportUsersScreenGrade => 'Класс';

  @override
  String get adminImportUsersScreenParentUsername =>
      'Имя пользователя родителя';

  @override
  String get adminImportUsersScreenParentUsernameHint =>
      'связь (необязательно)';

  @override
  String get adminImportUsersScreenCouldNotReadFile =>
      'Не удалось прочитать этот файл.';

  @override
  String get adminImportUsersScreenCsvIntro =>
      'Загрузите CSV со списком пользователей. Заголовки столбцов могут быть на любом языке — ClassMate определит, что означает каждый столбец, и загрузит строки в таблицу, чтобы вы могли всё проверить и исправить перед созданием.';

  @override
  String get adminImportUsersScreenChooseCsv => 'Выбрать файл CSV';

  @override
  String get adminImportUsersScreenChooseDifferentFile => 'Выбрать другой файл';

  @override
  String adminImportUsersScreenSelectedFile(String fileName) {
    return 'Выбрано: $fileName';
  }

  @override
  String get adminImportUsersScreenRecognisedColumns => 'Распознанные столбцы';

  @override
  String get adminImportUsersScreenRecognisedColumnsBody =>
      'имя · имя пользователя · пароль · эл. почта · телефон · роль · класс · родитель (имя пользователя) · дети (имена пользователей)\n\nСлова ролей, такие как «student / طالب / תלמיד / élève / ученик», распознаются корректно. Класс считывается как число из «Grade 10», «الصف 10», «כיתה 10». Отсутствующие имена пользователей и пароли создаются автоматически.';

  @override
  String adminImportUsersScreenDetectedRows(int count) {
    return 'Обнаружено — строк: $count';
  }

  @override
  String get adminImportUsersScreenNoColumnsDetected =>
      'Известные столбцы не обнаружены — проверьте строку заголовков.';

  @override
  String get adminImportUsersScreenTruncatedNotice =>
      'Показаны первые 2000 строк для проверки.';

  @override
  String get adminImportUsersScreenReviewEditInGrid =>
      'Проверить и изменить в таблице';

  @override
  String get adminImportUsersScreenReviewEditHint =>
      'Откроет вкладку «Таблица» с уже заполненными строками, чтобы вы могли исправить ошибки перед созданием.';

  @override
  String adminImportUsersScreenResultSummary(int count, int links) {
    return '✓ Создано пользователей: $count · связей: $links';
  }

  @override
  String adminImportUsersScreenResultFailedSuffix(int failed) {
    return ' · с ошибкой: $failed';
  }

  @override
  String get adminImportUsersScreenFailedRows => 'Строки с ошибками';

  @override
  String adminImportUsersScreenFailedRow(String row, String reason) {
    return 'Строка $row: $reason';
  }

  @override
  String get adminImportUsersScreenCredentialsTitle =>
      'Учётные данные (передайте их пользователям)';

  @override
  String get teacherCohortsScreenTitle => 'Группы';

  @override
  String get teacherCohortsScreenNewCohort => 'Новая группа';

  @override
  String get teacherCohortsScreenLoadError => 'Не удалось загрузить группы.';

  @override
  String get teacherCohortsScreenEmpty =>
      'Групп пока нет.\nНажмите «Новая группа», чтобы создать её.';

  @override
  String get teacherCohortsScreenCohortNameLabel => 'Название группы';

  @override
  String get teacherCohortsScreenCohortNameHint => 'например, 10-2';

  @override
  String get teacherCohortsScreenGradesLabel => 'Класс(ы)';

  @override
  String get teacherCohortsScreenGradesHint => 'например, 10  или  7,8';

  @override
  String get teacherCohortsScreenCancel => 'Отмена';

  @override
  String get teacherCohortsScreenCreate => 'Создать';

  @override
  String get teacherCohortsScreenEnterNameAndGrade =>
      'Укажите название и хотя бы один класс';

  @override
  String get teacherCohortsScreenCohortCreated => 'Группа создана';

  @override
  String get teacherCohortsScreenFailed => 'Ошибка';

  @override
  String teacherCohortsScreenStudentsCount(int count) {
    return 'Учеников: $count';
  }

  @override
  String get teacherCohortsScreenRenameGrades => 'Переименовать / классы';

  @override
  String get teacherCohortsScreenDeleteCohort => 'Удалить группу';

  @override
  String get teacherCohortsScreenAddStudents => 'Добавить учеников';

  @override
  String get teacherCohortsScreenEditCohort => 'Изменить группу';

  @override
  String get teacherCohortsScreenSave => 'Сохранить';

  @override
  String get teacherCohortsScreenSaved => 'Сохранено';

  @override
  String teacherCohortsScreenDeleteConfirmTitle(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get teacherCohortsScreenDeleteConfirmBody =>
      'Группа будет удалена, а ученики откреплены от неё. Учётные записи учеников не удаляются.';

  @override
  String get teacherCohortsScreenDelete => 'Удалить';

  @override
  String get teacherCohortsScreenDeleted => 'Удалено';

  @override
  String get teacherCohortsScreenLoadStudentsError =>
      'Не удалось загрузить учеников';

  @override
  String teacherCohortsScreenAddNStudents(int count) {
    return 'Добавить учеников: $count';
  }

  @override
  String teacherCohortsScreenAddedNStudents(int count) {
    return 'Добавлено учеников: $count';
  }

  @override
  String get teacherCohortsScreenNoStudentsYet => 'Учеников пока нет.';

  @override
  String get adminSettingsScreenBulkTools => 'Массовые операции';

  @override
  String get adminSettingsScreenImportUsers => 'Импорт пользователей';

  @override
  String get adminSettingsScreenImportUsersSubtitle =>
      'Добавьте многих сразу — таблица или CSV';

  @override
  String get adminSettingsScreenUpgradeGrades => 'Повысить классы';

  @override
  String get adminSettingsScreenUpgradeGradesSubtitle =>
      'Перевести каждого ученика на класс выше';

  @override
  String get adminSettingsScreenUpgradeGradesTitle => 'Повысить все классы?';

  @override
  String get adminSettingsScreenUpgradeGradesBody =>
      'Каждый ученик переводится на класс выше. Ученики, уже находящиеся в выпускном классе, помечаются как выпускники (никогда не удаляются), чтобы вы могли решить, что с ними делать. Эту операцию безопасно выполнять один раз в начале учебного года.';

  @override
  String get adminSettingsScreenUpgradeConfirm => 'Повысить';

  @override
  String adminSettingsScreenUpgradeSuccess(int promoted, int graduating) {
    return 'Переведено учеников: $promoted · выпускников: $graduating';
  }

  @override
  String get adminSettingsScreenDangerZone => 'Опасная зона';

  @override
  String get adminSettingsScreenResetSchedule => 'Сбросить расписание';

  @override
  String get adminSettingsScreenResetScheduleSubtitle =>
      'Удалить все уроки и исключения';

  @override
  String get adminSettingsScreenResetScheduleTitle =>
      'Сбросить всё расписание?';

  @override
  String get adminSettingsScreenResetScheduleBody =>
      'Это безвозвратно удалит каждый урок и разовое исключение для вашей школы. Время звонков сохраняется. Это действие нельзя отменить.';

  @override
  String adminSettingsScreenResetScheduleSuccess(int slots) {
    return 'Расписание очищено — удалено уроков: $slots';
  }

  @override
  String get adminSettingsScreenResetCohorts => 'Сбросить группы';

  @override
  String get adminSettingsScreenResetCohortsSubtitle =>
      'Удалить все ваши группы';

  @override
  String get adminSettingsScreenResetCohortsTitle => 'Удалить все группы?';

  @override
  String get adminSettingsScreenResetCohortsBody =>
      'Это безвозвратно удалит каждую группу в вашей школе и открепит от них учеников. Учётные записи учеников НЕ удаляются. Это действие нельзя отменить.';

  @override
  String get adminSettingsScreenDeleteCohortsConfirm => 'Удалить группы';

  @override
  String adminSettingsScreenResetCohortsSuccess(int deleted) {
    return 'Удалено групп: $deleted';
  }

  @override
  String get adminSettingsScreenAppearanceSubtitle => 'Тема, цвета, язык';

  @override
  String get adminSettingsScreenCancel => 'Отмена';

  @override
  String get adminSettingsScreenWorking => 'Выполняется…';

  @override
  String adminSettingsScreenFailed(String error) {
    return 'Ошибка: $error';
  }

  @override
  String adminSchedulePickStartDate(int freq) {
    return 'Выберите дату начала для расписания «каждые $freq нед.».';
  }

  @override
  String get adminScheduleNoCohortsYet =>
      'Групп пока нет — сначала создайте одну.';

  @override
  String adminScheduleGradeWithCohort(String grade, String cohort) {
    return 'Класс $grade · $cohort';
  }

  @override
  String get adminScheduleDateOnLabel => 'Дата';

  @override
  String get adminScheduleDateStartsOnLabel => 'Начинается';

  @override
  String adminScheduleStudentCount(int count) {
    return 'Учеников: $count';
  }

  @override
  String get adminScheduleAudienceNone => '—';

  @override
  String adminScheduleTeacherClashNamed(String name) {
    return 'У $name будет два урока одновременно.';
  }

  @override
  String get adminScheduleTeacherClash =>
      'У этого учителя будет два урока одновременно.';

  @override
  String adminScheduleStudentClashSingle(String name) {
    return 'У $name будет два урока одновременно:';
  }

  @override
  String adminScheduleStudentClashMany(int count) {
    return 'У $count учеников будет два урока одновременно:';
  }

  @override
  String get adminScheduleAStudent => 'Ученик';

  @override
  String adminScheduleAffected(String preview) {
    return 'Затронуто: $preview';
  }

  @override
  String get adminScheduleResolvePrompt => 'Как это разрешить?';

  @override
  String get adminScheduleResolvePromptStudents =>
      'Как это разрешить для этих учеников?';

  @override
  String adminScheduleStudentsInCohorts(int count, int cohortCount) {
    return 'Учеников в выбранных группах: $count';
  }

  @override
  String adminScheduleStudentsInGrade(int count, String grade) {
    return 'Учеников в классе $grade: $count';
  }

  @override
  String get adminScheduleCustomizedNote =>
      'Настроено — сохранено как отдельные ученики';

  @override
  String adminScheduleMoreCount(int count) {
    return '+$count ещё';
  }

  @override
  String get adminScheduleAddStudentsTitle => 'Добавить учеников';

  @override
  String get adminScheduleNoStudentsMatch => 'Нет подходящих учеников.';

  @override
  String get adminScheduleNoPeriodsHere => 'Здесь пока нет уроков.';

  @override
  String adminScheduleGradeRange(String from, String to) {
    return 'Классы $from-$to';
  }

  @override
  String adminScheduleGradesList(String grades) {
    return 'Классы $grades';
  }

  @override
  String get adminScheduleNoStudentsInCohorts =>
      'В этих группах пока нет учеников.';

  @override
  String adminScheduleEveryNWeeks(int freq) {
    return 'Каждые $freq нед.';
  }

  @override
  String get adminScheduleColorLabel => 'Цвет';

  @override
  String get adminScheduleSubjectRequired => 'Предмет *';

  @override
  String get adminScheduleNoSchoolSubjects =>
      'Школьных предметов пока нет. Нажмите «Добавить», чтобы создать.';

  @override
  String get adminScheduleNoSubjectsMatch => 'Нет предметов по вашему запросу.';

  @override
  String get teacherNewAnnouncementScreenBroadcastBody =>
      'Конкретная аудитория не выбрана. Это объявление будет видно КАЖДОМУ ученику, родителю, учителю, секретарю и администратору в школе.';

  @override
  String teacherNewAnnouncementScreenGradeLabel(int grade) {
    return 'Класс $grade';
  }

  @override
  String get teacherNewAnnouncementScreenNoFilesAttached =>
      'Файлы не прикреплены.';

  @override
  String teacherNewAnnouncementScreenSelectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get teacherNewAnnouncementScreenAudienceHint =>
      'Выберите категорию, затем конкретные роли, классы, группы или людей. Выбор из всех категорий суммируется.';

  @override
  String get teacherNewAnnouncementScreenLoadingStudents =>
      'Загрузка учеников…';

  @override
  String get teacherNewAnnouncementScreenNoGradeLevels =>
      'Уровни классов пока не найдены.';

  @override
  String get teacherNewAnnouncementScreenTapSelectCohorts =>
      'Нажмите, чтобы выбрать группы…';

  @override
  String teacherNewAnnouncementScreenCohortsSelected(int count) {
    return 'Выбрано групп: $count';
  }

  @override
  String get teacherNewAnnouncementScreenTapSelectStudents =>
      'Нажмите, чтобы выбрать учеников…';

  @override
  String teacherNewAnnouncementScreenStudentsSelected(int count) {
    return 'Выбрано учеников: $count';
  }

  @override
  String get teacherNewAnnouncementScreenTapSelectParents =>
      'Нажмите, чтобы выбрать родителей…';

  @override
  String teacherNewAnnouncementScreenParentsSelected(int count) {
    return 'Выбрано родителей: $count';
  }

  @override
  String get teacherNewAnnouncementScreenSelectedAudience =>
      'Выбранная аудитория';

  @override
  String teacherNewAnnouncementScreenStudentsInCohorts(int count) {
    return 'Учеников в выбранных группах: $count';
  }

  @override
  String get teacherNewAnnouncementScreenSelectParents => 'Выбрать родителей';

  @override
  String teacherNewAnnouncementScreenChildrenSummary(
    int count,
    String summary,
  ) {
    return 'Детей: $count — $summary';
  }

  @override
  String get teacherNewAnnouncementScreenNoLinkedChildren =>
      'Нет связанных детей';

  @override
  String adminPeriodsScreenDayN(int dow) {
    return 'День $dow';
  }

  @override
  String adminPeriodsScreenPeriodN(int period) {
    return 'Урок $period';
  }

  @override
  String get adminPeriodsScreenPeriodDropdownLabel => 'Урок';

  @override
  String get adminPeriodsScreenSelectTeacher => 'Выберите учителя…';

  @override
  String get adminPeriodsScreenNone => '— Нет —';

  @override
  String get adminPeriodsScreenLinkClassroom => 'Связать с классом…';

  @override
  String adminPeriodsScreenCohortGradeName(String grade, String name) {
    return '$grade кл. — $name';
  }

  @override
  String adminPeriodsScreenGradeN(String grade) {
    return 'Класс $grade';
  }

  @override
  String get roleBadgeStudent => 'Ученик';

  @override
  String get roleBadgeTeacher => 'Учитель';

  @override
  String get roleBadgeAdmin => 'Администратор';

  @override
  String get roleBadgeSecretary => 'Секретарь';

  @override
  String get roleBadgeParent => 'Родитель';

  @override
  String get roleBadgeMember => 'Участник';

  @override
  String get teacherSlotAttachmentsScreenEmptyTitle => 'Вложений пока нет';

  @override
  String get teacherSlotAttachmentsScreenEmptyBody =>
      'Прикрепите материалы, чтобы ученики видели их на карточке этого урока.';

  @override
  String get teacherSlotAttachmentsScreenMaterialFallback => 'Материал';

  @override
  String get teacherSlotAttachmentsScreenSheetTitle => 'Прикрепить материал';

  @override
  String get teacherSlotAttachmentsScreenCreateNew => 'Создать новый материал';

  @override
  String get teacherAddGradeScreenPickAudience =>
      'Выберите хотя бы одного ученика, группу или класс.';

  @override
  String get teacherAddGradeScreenEnterTitle => 'Введите название этой оценки.';

  @override
  String get teacherAddGradeScreenPickExam => 'Выберите экзамен.';

  @override
  String get teacherAddGradeScreenPickAssignment => 'Выберите задание.';

  @override
  String get teacherAddGradeScreenCouldNotResolveTitle =>
      'Не удалось определить название оценки.';

  @override
  String teacherAddGradeScreenEnterNumericGrade(String name) {
    return 'Введите числовую оценку для $name.';
  }

  @override
  String teacherAddGradeScreenError(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get teacherAddGradeScreenTapSelectStudents =>
      'Нажмите, чтобы выбрать учеников…';

  @override
  String teacherAddGradeScreenStudentsSelected(int count) {
    return 'Выбрано учеников: $count';
  }

  @override
  String get teacherAddGradeScreenTapSelectCohorts =>
      'Нажмите, чтобы выбрать группы…';

  @override
  String teacherAddGradeScreenCohortsSelected(int count) {
    return 'Выбрано групп: $count';
  }

  @override
  String teacherAddGradeScreenWillBeGraded(int count) {
    return 'Будет оценено учеников: $count';
  }

  @override
  String get teacherAddGradeScreenNoGradeLevels =>
      'У ваших учеников пока не найдены уровни классов.';

  @override
  String get teacherAddGradeScreenSelectAudienceExams =>
      'Сначала выберите аудиторию, чтобы отфильтровать экзамены.';

  @override
  String teacherAddGradeScreenNoExamsReach(String audience) {
    return 'Нет экзаменов, охватывающих всех выбранных: $audience.';
  }

  @override
  String get teacherAddGradeScreenSelectAudienceAssignments =>
      'Сначала выберите аудиторию, чтобы отфильтровать задания.';

  @override
  String teacherAddGradeScreenNoAssignmentsReach(String audience) {
    return 'Нет заданий, охватывающих всех выбранных: $audience.';
  }

  @override
  String get teacherAddGradeScreenSelectAudienceAbove =>
      'Выберите аудиторию выше, чтобы ввести оценки.';

  @override
  String get teacherAddGradeScreenSelectStudentsTitle => 'Выбрать учеников';

  @override
  String teacherAddGradeScreenCountSelected(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get teacherAddGradeScreenSelectCohortsTitle => 'Выбрать группы';

  @override
  String get teacherAddGradeScreenAudienceCohorts => 'групп';

  @override
  String get teacherAddGradeScreenAudienceGrades => 'классов';

  @override
  String get teacherAddGradeScreenAudienceStudents => 'учеников';

  @override
  String get formDetailScreenCouldNotLoad =>
      'Не удалось загрузить эту форму сейчас.';

  @override
  String get formDetailScreenSubmitted => 'Форма отправлена';

  @override
  String get formDetailScreenSubmissionFailed => 'Не удалось отправить';

  @override
  String get formDetailScreenAlreadySubmittedNote =>
      'Вы уже отправили эту форму.';

  @override
  String get formDetailScreenSubmitting => 'Отправка…';

  @override
  String get formDetailScreenSubmitAgain => 'Отправить снова';

  @override
  String get formDetailScreenSubmitForm => 'Отправить форму';

  @override
  String formDetailScreenQuestionCount(int count) {
    return 'Вопросов: $count';
  }

  @override
  String get formDetailScreenMultiSubmit => 'Несколько отправок';

  @override
  String get formDetailScreenOnePerStudent => '1 на ученика';

  @override
  String get formDetailScreenRequired => 'Обязательно';

  @override
  String get formDetailScreenYourAnswer => 'Ваш ответ';

  @override
  String get formDetailScreenLongAnswerText => 'Развёрнутый ответ';

  @override
  String get formDetailScreenSelect => 'Выбрать';

  @override
  String get novaChatScreenAboutAiPoweredTitle => 'Помощник на основе ИИ';

  @override
  String get novaChatScreenAboutAiPoweredBody =>
      'NOVA построена на технологии больших языковых моделей, чтобы помогать вам учиться, понимать концепции и исследовать идеи.';

  @override
  String get novaChatScreenAboutMistakesBody =>
      'NOVA может выдавать неточную, неполную или устаревшую информацию. Всегда проверяйте важные ответы у учителя или из надёжного источника.';

  @override
  String get novaChatScreenAboutEducationalBody =>
      'NOVA создана для поддержки в учёбе и не заменяет профессиональную медицинскую, юридическую или финансовую консультацию.';

  @override
  String get novaChatScreenAboutPrivacyBody =>
      'Беседы используются для формирования ответов. Не делитесь конфиденциальной личной информацией.';

  @override
  String get novaChatScreenDisclaimerTapToLearn =>
      'NOVA может ошибаться. Нажмите, чтобы узнать больше.';

  @override
  String get userProfileSheetSchool => 'Школа';

  @override
  String get userProfileSheetClass => 'Класс';

  @override
  String get userProfileSheetParents => 'Родители';

  @override
  String get userProfileSheetChildren => 'Дети';

  @override
  String get scheduleScreenNotes => 'Заметки';

  @override
  String get scheduleScreenMaterialFallback => 'Материал';

  @override
  String get scheduleScreenNow => 'СЕЙЧАС';

  @override
  String scheduleScreenMaterialCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count материалов',
      one: '1 материал',
    );
    return '$_temp0';
  }

  @override
  String teacherFormResponsesScreenResponseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ответов',
      one: '1 ответ',
    );
    return '$_temp0';
  }

  @override
  String get teacherFormResponsesScreenEmptyTitle => 'Ответов пока нет';

  @override
  String get teacherFormResponsesScreenEmptySubtitle =>
      'Ответы появятся здесь, как только ученики их отправят.';

  @override
  String get teacherFormResponsesScreenStudentFallback => 'Ученик';

  @override
  String teacherFormResponsesScreenSubmittedAt(String date) {
    return 'Отправлено $date';
  }

  @override
  String teacherCreateFormScreenQuestionNumber(String number) {
    return 'В$number';
  }

  @override
  String get teacherCreateFormScreenShortAnswerPreview => 'Краткий ответ';

  @override
  String get teacherCreateFormScreenLongAnswerPreview => 'Развёрнутый ответ';

  @override
  String get teacherCreateFormScreenDatePickerPreview => 'Выбор даты';

  @override
  String get teacherCreateFormScreenScaleTo => 'до';

  @override
  String get teacherMeetingsScreenNoneOption => 'Нет';

  @override
  String teacherMeetingsScreenGradeLabel(String grade) {
    return 'Класс $grade';
  }

  @override
  String teacherMeetingsScreenStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учеников',
      one: '1 ученик',
    );
    return '$_temp0';
  }

  @override
  String get teacherMeetingsScreenPickStartTime => 'Выберите время начала';

  @override
  String get teacherMeetingsScreenPickEndTime => 'Выберите время окончания';

  @override
  String teacherMeetingsScreenMembersWillReceive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участников получат это',
      one: '1 участник получит это',
    );
    return '$_temp0';
  }

  @override
  String get teacherAssignmentsScreenTitle => 'Задания';

  @override
  String teacherAssignmentsScreenSummary(int total, int published) {
    return 'Всего: $total · опубликовано: $published';
  }

  @override
  String get teacherAssignmentsScreenEmpty =>
      'Заданий пока нет.\nНажмите +, чтобы создать.';

  @override
  String teacherAssignmentsScreenSubmitted(int count) {
    return 'Сдано: $count';
  }

  @override
  String get audienceSectionCohorts => 'Группы';

  @override
  String get audienceSectionGrades => 'Классы';

  @override
  String audienceSectionGradeLabel(int grade) {
    return 'Класс $grade';
  }

  @override
  String get audienceSectionStudents => 'Ученики';

  @override
  String audienceSectionStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учеников',
      one: '1 ученик',
    );
    return '$_temp0';
  }

  @override
  String audienceSectionMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участников получат это',
      one: '1 участник получит это',
    );
    return '$_temp0';
  }

  @override
  String audienceSectionSelectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String secretaryStudentsScreenStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учеников',
      one: '1 ученик',
    );
    return '$_temp0';
  }

  @override
  String secretaryStudentsScreenAvg(String grade) {
    return 'Средн. $grade';
  }

  @override
  String get secretaryStudentsScreenIdentity => 'Личные данные';

  @override
  String get secretaryStudentsScreenUsername => 'Имя пользователя';

  @override
  String get secretaryStudentsScreenEmail => 'Эл. почта';

  @override
  String get secretaryStudentsScreenPhone => 'Телефон';

  @override
  String get secretaryStudentsScreenCohort => 'Группа';

  @override
  String get secretaryStudentsScreenGrade => 'Класс';

  @override
  String get secretaryStudentsScreenPrimaryCohort => 'Основная группа';

  @override
  String secretaryStudentsScreenTeacher(String name) {
    return 'Учитель: $name';
  }

  @override
  String get chatMessageBubbleEdited => 'изменено';

  @override
  String get chatMessageBubbleForwarded => 'Переслано';

  @override
  String get chatMessageBubblePinned => 'Закреплено';

  @override
  String get chatMessageBubbleReply => 'Ответить';

  @override
  String get chatMessageBubbleMessage => 'Сообщение';

  @override
  String get chatMessageBubbleDeletedMessage => 'Это сообщение было удалено';

  @override
  String get chatMessageBubbleImage => 'Изображение';

  @override
  String get chatMessageBubbleVideo => 'Видео';

  @override
  String get chatMessageBubbleFile => 'Файл';

  @override
  String get chatMessageInfoPageReadSection => 'Прочитано';

  @override
  String get chatMessageInfoPageNoOneRead => 'Пока никто не прочитал';

  @override
  String get chatMessageInfoPageDeliveredSection => 'Доставлено';

  @override
  String get chatMessageInfoPagePendingSection => 'Ожидает';

  @override
  String get chatMessageInfoPageUnknown => 'Неизвестно';

  @override
  String get profileEnterCodeTitle => 'Введите 6-значный код';

  @override
  String profileCodeSentTo(String target) {
    return 'Отправлено на $target. Истекает через 15 минут.';
  }

  @override
  String get profileCodeSent => 'Код отправлен. Истекает через 15 минут.';

  @override
  String profileChangeContact(String label) {
    return 'Изменить $label';
  }

  @override
  String get profileVerifyNewContactInfo =>
      'Код подтверждения будет отправлен на введённое вами значение — чтобы подтвердить, что оно принадлежит вам.';

  @override
  String profileVerifyCurrentContactInfo(String label) {
    return 'Код подтверждения будет отправлен на ваш ТЕКУЩИЙ $label, чтобы подтвердить владение перед сменой.';
  }

  @override
  String get appShellReports => 'Жалобы';

  @override
  String get appShellExportData => 'Экспорт данных';

  @override
  String get appShellAdmin => 'Администрирование';

  @override
  String get appShellViewingAs => 'Просмотр как ';

  @override
  String get appShellSwitchChild => 'Сменить ребёнка';

  @override
  String get messageThreadScreenGroupInviteSubtitle =>
      'Вас пригласили в эту группу.';

  @override
  String get messageThreadScreenBlockedHint =>
      'Вы заблокировали этот чат. Разблокируйте из списка заблокированных, чтобы снова общаться.';

  @override
  String get messageThreadScreenCannotSendHint =>
      'Сейчас вы не можете отправлять сообщения в этом чате.';

  @override
  String get messageThreadScreenTapForGroupInfo =>
      'Нажмите для информации о группе';

  @override
  String get messageThreadScreenAddParticipantsTitle => 'Добавить участников';

  @override
  String teacherExamsScreenGradedCount(int count) {
    return 'Оценено: $count';
  }

  @override
  String get teacherScheduleScreenNextUp => 'Далее';

  @override
  String teacherScheduleScreenPeriodLabel(String period) {
    return 'Урок $period';
  }

  @override
  String teacherScheduleScreenGradeLabel(int grade) {
    return 'Класс $grade';
  }

  @override
  String teacherScheduleScreenMaterialsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count материалов',
      one: '1 материал',
    );
    return '$_temp0';
  }

  @override
  String get teacherClassroomAddAssignmentScreenTitle => 'Добавить задание';

  @override
  String get teacherClassroomAddAssignmentScreenDetails => 'Детали задания';

  @override
  String get teacherClassroomAddAssignmentScreenDueDateOptional =>
      'Срок сдачи (необязательно)';

  @override
  String get teacherClassroomAddAssignmentScreenNotifyStudents =>
      'Уведомить учеников';

  @override
  String get teacherClassroomAddAssignmentScreenUploading => 'Загрузка…';

  @override
  String get teacherClassroomAddAssignmentScreenAttachFiles =>
      'Прикрепить файлы';

  @override
  String get teacherClassroomAddAssignmentScreenAddMoreFiles =>
      'Добавить ещё файлы';

  @override
  String get diplomasScreenCertificate => 'Сертификат';

  @override
  String diplomasScreenIssuedDate(String date) {
    return 'Выдан $date';
  }

  @override
  String get diplomasScreenNoCertificatesReceived =>
      'Сертификатов пока не получено.';

  @override
  String diplomasScreenFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count файлов',
      one: '$count файл',
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
      other: '$count оценок',
      one: '$count оценку',
    );
    return 'Показать ещё $_temp0';
  }

  @override
  String get gradesScreenShowLess => 'Свернуть';

  @override
  String gradesScreenScoreOutOf100(String score) {
    return '$score / 100';
  }

  @override
  String get adminSchoolSettingsStart => 'Начало';

  @override
  String get adminSchoolSettingsEnd => 'Конец';

  @override
  String get adminExportScreenEachUserAlone => 'Каждый пользователь отдельно';

  @override
  String get adminExportScreenEachUserAloneOn =>
      'По одной полной странице на пользователя, крупная читаемая карточка.';

  @override
  String get adminExportScreenEachUserAloneOff =>
      'Компактная таблица — каждый пользователь в строке.';

  @override
  String get adminExportScreenSeparateFilesOn =>
      'Отдельный PDF на пользователя';

  @override
  String get adminExportScreenSeparateFilesOff =>
      'Единый PDF, по странице на пользователя';

  @override
  String adminExportScreenSeparateFilesOnDesc(int count) {
    return 'Вы отправите $count файл(ов) PDF сразу — у каждого пользователя свой.';
  }

  @override
  String get adminExportScreenSeparateFilesOffDesc =>
      'Все в одном PDF, каждый на своей странице.';

  @override
  String get adminSubjectDetailScreenSchoolSettings => 'Настройки школы';

  @override
  String get adminSubjectDetailScreenNewSubject => 'Новый предмет';

  @override
  String get adminSubjectDetailScreenLangEnglish => 'Английский';

  @override
  String get adminSubjectDetailScreenLangArabic => 'Арабский';

  @override
  String get adminSubjectDetailScreenLangHebrew => 'Иврит';

  @override
  String get adminSubjectDetailScreenLangFrench => 'Французский';

  @override
  String get adminSubjectDetailScreenLangRussian => 'Русский';

  @override
  String get adminSubjectDetailScreenColor => 'Цвет';

  @override
  String get parentHomeScreenGreetingFallback => 'друг';

  @override
  String parentHomeScreenChildrenLoadError(String error) {
    return 'Не удалось загрузить ваших детей: $error';
  }

  @override
  String get parentHomeScreenMaterials => 'Материалы';

  @override
  String get cmCodeBlockCopied => 'Скопировано';

  @override
  String get cmCodeBlockCopy => 'Копировать';

  @override
  String get phoneFieldCountryCode => 'Код страны';

  @override
  String get teacherClassroomAddMeetingScreenEndDateDefault =>
      'Дата окончания по умолчанию равна дате начала';

  @override
  String get teacherAddMaterialScreenLinkHint => 'https://…';

  @override
  String get teacherAddMaterialScreenLinkFallback => 'Ссылка';

  @override
  String get teacherAddMaterialScreenFileFallback => 'Файл';

  @override
  String get teacherCreateDiplomaScreenTitle => 'Выдать сертификат';

  @override
  String get teacherCreateDiplomaScreenGradePrefix => 'Класс';

  @override
  String get teacherCreateDiplomaScreenAttachFiles =>
      'Прикрепить файл(ы) сертификата';

  @override
  String get teacherCreateDiplomaScreenAddMoreFiles => 'Добавить ещё файлы';

  @override
  String get teacherAssignmentDetailScreenTitle => 'Задание';

  @override
  String get teacherAssignmentDetailScreenNoSubmissions => 'Сдач пока нет';

  @override
  String teacherAssignmentDetailScreenSubmissionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сдач',
      one: '1 сдача',
    );
    return '$_temp0';
  }

  @override
  String teacherAssignmentDetailScreenGradedCount(int count) {
    return 'Оценено: $count';
  }

  @override
  String get teacherAssignmentDetailScreenStudentFallback => 'Ученик';

  @override
  String teacherAssignmentDetailScreenSubmittedOn(String date) {
    return 'Сдано $date';
  }

  @override
  String teacherAddAssignmentScreenGradeLabel(int count) {
    return 'Класс $count';
  }

  @override
  String teacherAddAssignmentScreenStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count учеников',
      one: '1 ученик',
    );
    return '$_temp0';
  }

  @override
  String teacherAddAssignmentScreenMembersWillReceive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count участников получат это',
      one: '1 участник получит это',
    );
    return '$_temp0';
  }

  @override
  String get teacherAddAssignmentScreenNoDueDate => 'Без срока сдачи';

  @override
  String get teacherAddAssignmentScreenMaterialFallback => 'Материал';

  @override
  String teacherAddAssignmentScreenSelectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String teacherClassroomsScreenGradeLabel(int grade) {
    return 'Класс $grade';
  }

  @override
  String get teacherClassroomsScreenNewClassroom => 'Новый класс';

  @override
  String get assignmentsScreenAlreadyHandedIn => 'Вы уже сдали это задание.';

  @override
  String get assignmentsScreenAddNoteOrFiles =>
      'Добавьте заметку или прикрепите файлы, затем нажмите «Сдать».';

  @override
  String assignmentsScreenGradeLabel(String grade) {
    return 'Оценка: $grade';
  }

  @override
  String assignmentsScreenFeedbackLabel(String feedback) {
    return 'Отзыв: $feedback';
  }

  @override
  String get assignmentsScreenReturnedForResolution =>
      'Возвращено на доработку';

  @override
  String get assignmentsScreenAttachFile => 'Прикрепить файл';

  @override
  String get assignmentsScreenAddMoreFiles => 'Добавить ещё файлы';

  @override
  String get assignmentsScreenHandingIn => 'Сдача…';

  @override
  String get assignmentsScreenHandIn => 'Сдать';

  @override
  String get examDetailScreenCouldNotLoad =>
      'Не удалось загрузить этот экзамен сейчас.';

  @override
  String get adminEditUserRoleStudent => 'Ученик';

  @override
  String get adminEditUserRoleTeacher => 'Учитель';

  @override
  String get adminEditUserRoleSecretary => 'Секретарь';

  @override
  String get adminEditUserRoleParent => 'Родитель';

  @override
  String get adminEditUserRoleAdmin => 'Администратор';

  @override
  String adminEditUserCohortMemberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count группах',
      one: '$count группе',
    );
    return 'Состоит в $_temp0.';
  }

  @override
  String get adminEditUserSearchStudents => 'Поиск учеников…';

  @override
  String adminEditUserGradeSuffix(int grade) {
    return '(Класс $grade)';
  }

  @override
  String get solutionAssetPreviewSheetPdfDocument => 'Документ PDF';

  @override
  String get solutionAssetPreviewSheetUnableToPreview =>
      'Не удалось показать предпросмотр PDF.';

  @override
  String classroomDetailSectionHeader(String title, int count) {
    return '$title ($count)';
  }

  @override
  String get classroomDetailTeacherSection => 'Учитель';

  @override
  String get classroomDetailStudentsSection => 'Ученики';

  @override
  String get classroomDetailClassroomFallback => 'Класс';

  @override
  String get classroomDetailUntitled => 'Без названия';

  @override
  String get typingDotsPaused => 'Приостановлено';

  @override
  String get cmAiMessageStartPracticeSession => 'Начать тренировку';

  @override
  String cmAiMessageQuestionCount(int count) {
    return 'Вопросов: $count';
  }

  @override
  String get cmAiMessageDifficultyEasy => 'Лёгкий';

  @override
  String get cmAiMessageDifficultyHard => 'Сложный';

  @override
  String get cmAiMessageDifficultyOlympiad => 'Олимпиадный';

  @override
  String get cmAiMessageDifficultyAdaptive => 'Адаптивный';

  @override
  String get cmAiMessageDifficultyMedium => 'Средний';

  @override
  String get teacherCreateFormScreenParagraphType => 'Абзац';

  @override
  String get teacherCreateFormScreenMultipleChoiceType => 'Один из вариантов';

  @override
  String get teacherCreateFormScreenCheckboxesType => 'Флажки';

  @override
  String get teacherCreateFormScreenRatingType => 'Оценка (1–5)';

  @override
  String get teacherCreateFormScreenLinearScaleType => 'Линейная шкала';

  @override
  String get teacherCreateFormScreenDropdownType => 'Раскрывающийся список';

  @override
  String get teacherCreateFormScreenDateType => 'Дата';

  @override
  String teacherCohortsScreenSingleGrade(int grade) {
    return '$grade класс';
  }

  @override
  String teacherCohortsScreenGradeRange(int from, int to) {
    return '$from-$to классы';
  }

  @override
  String teacherCohortsScreenMultiGrade(String grades) {
    return 'Классы $grades';
  }

  @override
  String get teacherAddGradeScreenFailedCreateRecord =>
      'Не удалось создать запись об оценке.';

  @override
  String get phoneFieldLabel => 'Телефон (необязательно)';

  @override
  String get phoneFieldHelper => 'Используется для сброса пароля по SMS';

  @override
  String get gradesScreenCouldNotLoad => 'Не удалось загрузить оценки.';

  @override
  String get gradesScreenTimeout =>
      'Истекло время ожидания. Проверьте подключение.';

  @override
  String get gradesScreenNoConnection =>
      'Нет подключения. Потяните, чтобы повторить.';

  @override
  String get examDetailScreenCountdownPassed => 'Этот экзамен уже прошёл';

  @override
  String get examDetailScreenCountdownToday => 'Сегодня!';

  @override
  String get teacherCreateDiplomaScreenDefaultTitle =>
      'Свидетельство о достижении';

  @override
  String teacherMaterialAddedBy(String name) {
    return 'Добавил(а): $name';
  }

  @override
  String teacherMaterialAttachedTo(String period) {
    return 'Прикреплено к $period';
  }

  @override
  String get adminPeopleAddMany => 'Добавить нескольких';

  @override
  String get adminAddManyPasteNames => 'Вставить имена';

  @override
  String get adminAddManyApplyRole => 'Задать роль для всех';

  @override
  String get adminAddManyApplyGrade => 'Задать класс для всех';

  @override
  String get adminAddManyParentLabel => 'Родитель';

  @override
  String get adminAddManyParentNone => 'Без родителя';

  @override
  String get adminAddManyAddParent => 'Добавить родителя';

  @override
  String get adminAddManyCreateParentGeneric => 'Создать нового родителя';

  @override
  String get adminAddManyParentInBatch => 'Новые родители в этом списке';

  @override
  String get adminAddManyParentExisting => 'Существующие родители';

  @override
  String get adminAddManySearchParents => 'Поиск родителей…';

  @override
  String get adminAddManyNoParentsYet =>
      'Нет подходящих родителей — введите имя выше, чтобы создать';

  @override
  String get adminAddManyUsernameTaken => 'Имя пользователя уже занято';

  @override
  String get adminAddManyUsernameDupe =>
      'Повтор имени пользователя в этом списке';

  @override
  String get adminUsernameAvailable => 'Username is available';

  @override
  String get adminUsernameInvalidFormat => 'Use 3+ letters, digits, or . _ -';

  @override
  String get adminUsernameSuggestionsLabel =>
      'Available suggestions — tap to use:';

  @override
  String adminAddManyCreateParent(String name) {
    return 'Создать нового родителя \"$name\"';
  }

  @override
  String adminAddManyPastedRows(int count) {
    return 'Добавлено строк: $count';
  }

  @override
  String get teacherCreateClassroomNoStudentsInCohort =>
      'В выбранной когорте пока нет учеников.';

  @override
  String get audienceSummaryResolving => 'Поиск учеников…';

  @override
  String audienceSummaryCount(int count) {
    return '$count увидят это';
  }

  @override
  String get audienceSummaryEmpty =>
      'Нет учеников, соответствующих этой аудитории.';

  @override
  String audienceSummaryRestore(int count) {
    return 'Восстановить $count';
  }

  @override
  String get scheduleUpcomingExam => 'Ближайший экзамен';

  @override
  String get scheduleNoUpcomingExams => 'Нет предстоящих экзаменов';

  @override
  String get navAverages => 'Средние баллы';

  @override
  String get navCertificates => 'Сертификаты';

  @override
  String get averagesTitle => 'Средние баллы';

  @override
  String get averagesAddTitle => 'Новый средний балл';

  @override
  String get averagesEditTitle => 'Изменить средний балл';

  @override
  String get averagesSelectCohort => 'Класс';

  @override
  String get averagesSelectSubject => 'Предмет';

  @override
  String get averagesNoSubjects => 'Для этого класса предметы не найдены.';

  @override
  String get averagesEmpty =>
      'Пока нет средних баллов. Нажмите +, чтобы добавить.';

  @override
  String averagesVariantCount(int count, int units) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count форматов',
      one: '1 формат',
    );
    return '$_temp0 · $units ед.';
  }

  @override
  String get averagesDeleteTitle => 'Удалить средний балл';

  @override
  String get averagesDeleteConfirm =>
      'Удалить этот средний балл? Действие необратимо.';

  @override
  String get averagesDelete => 'Удалить';

  @override
  String get averagesFieldTitle => 'Название';

  @override
  String get averagesFieldTitleHint =>
      'напр. Итоговая формула по математике, 5 ед.';

  @override
  String get averagesSemester => 'Семестр';

  @override
  String get averagesUnits => 'Единицы (вес)';

  @override
  String get averagesUnitsHint =>
      '0, если на этом уровне нет взвешенных единиц, напр. 7 класс';

  @override
  String get averagesBestFormatNote =>
      'Система автоматически выбирает наиболее подходящий формат для каждого ученика класса.';

  @override
  String get averagesNoGrades =>
      'Оценки для этого класса и предмета не найдены.';

  @override
  String get averagesAddFormat => 'Добавить формат';

  @override
  String get averagesSave => 'Сохранить';

  @override
  String get averagesFormat => 'Формат';

  @override
  String get averagesAddGrade => 'Добавить оценку';

  @override
  String get averagesGrade => 'Оценка';

  @override
  String averagesWeightSum(String sum) {
    return 'Итого: $sum%';
  }

  @override
  String get averagesTitleRequired => 'Введите название.';

  @override
  String get averagesPickGradeForEachRow =>
      'Выберите оценку для каждой строки.';

  @override
  String get averagesWeightMustBe100 =>
      'Сумма процентов в каждом формате должна быть 100%.';

  @override
  String get certificatesTitle => 'Сертификаты';

  @override
  String get certHomeroom => 'Класс (классный руководитель)';

  @override
  String get certStudent => 'Ученик';

  @override
  String get certDisplayName => 'Имя в сертификате';

  @override
  String get certNationalId => 'Удостоверение личности';

  @override
  String get certHomeroomTeacher => 'Классный руководитель';

  @override
  String get certPrincipal => 'Директор';

  @override
  String get certPublisherNote => 'Примечание (необязательно)';

  @override
  String get certSemesterWeights => 'Веса семестров';

  @override
  String get certLanguage => 'Язык сертификата';

  @override
  String get certGenerate => 'Создать PDF';

  @override
  String get certWeightsMustBe100 => 'Сумма весов семестров должна быть 100%.';

  @override
  String get certSelectStudentFirst => 'Сначала выберите ученика.';

  @override
  String get certSaved => 'Сертификат создан.';

  @override
  String get certPdfAnnualCertificate => 'Годовой сертификат';

  @override
  String get certPdfSubject => 'Предмет';

  @override
  String get certPdfFinal => 'Итог';

  @override
  String get certPdfOverall => 'Общий средний балл';

  @override
  String get certPdfAverage => 'Средний балл';

  @override
  String get certPdfAbsences => 'Пропуски';

  @override
  String get certPdfLateness => 'Опоздания';

  @override
  String get certPdfHomeroomTeacher => 'Классный руководитель';

  @override
  String get certPdfPrincipal => 'Директор';

  @override
  String get certPdfNationalId => '№ удостоверения';

  @override
  String get certPdfDate => 'Дата';

  @override
  String get certPdfGeneratedBy => 'Создано';

  @override
  String get certPdfName => 'Имя';

  @override
  String get certPdfClass => 'Класс';

  @override
  String get adminEditUserNationalId => 'Удостоверение личности';

  @override
  String get teacherCohortsScreenNoStudentsToAdd =>
      'Все ученики уже в этом классе.';

  @override
  String get gradeWeightLabel => 'Вес в среднем (%)';

  @override
  String get gradeWeightHint =>
      'Необязательно — задайте, какой % учитывается в среднем по предмету, или оставьте пустым.';

  @override
  String get gradeSemesterLabel => 'Семестр';

  @override
  String get gradeSemesterAuto => 'Авто (по дате)';

  @override
  String get gradeDeleteTooltip => 'Удалить оценку';

  @override
  String get gradeDeleteTitle => 'Удалить оценку';

  @override
  String gradeDeleteConfirm(String title) {
    return 'Удалить оценку за «$title»?';
  }

  @override
  String get cohortHomeroomLabel => 'Классное руководство';

  @override
  String get cohortHomeroomHint =>
      'Назначьте классного руководителя для этого класса.';

  @override
  String get cohortHomeroomTeacher => 'Классный руководитель';

  @override
  String get adminPrincipalLabel => 'Директор';

  @override
  String get adminPrincipalHint =>
      'Этот администратор — директор; в сертификатах его имя подставляется по классу ученика.';

  @override
  String get adminPrincipalGrades => 'Директор для классов';

  @override
  String get certPdfTeacher => 'Учитель';
}

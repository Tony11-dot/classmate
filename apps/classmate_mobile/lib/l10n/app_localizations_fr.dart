// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get menu => 'Menu';

  @override
  String get sectionCore => 'Principal';

  @override
  String get sectionSchoolTools => 'Outils scolaires';

  @override
  String get sectionAccount => 'Compte';

  @override
  String get navSchedule => 'Emploi du temps';

  @override
  String get navClassrooms => 'Salles de classe';

  @override
  String get navPractice => 'Entraînement';

  @override
  String get navInsights => 'Analyses';

  @override
  String get navNova => 'NOVA';

  @override
  String get navMessages => 'Messages';

  @override
  String get navAttendance => 'Assiduité';

  @override
  String get navGrades => 'Notes';

  @override
  String get navAssignments => 'Devoirs';

  @override
  String get navMeetings => 'Réunions';

  @override
  String get navAnnouncements => 'Annonces';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get navSolutions => 'Solutions';

  @override
  String get navExams => 'Examens';

  @override
  String get navForms => 'Formulaires';

  @override
  String get navHome => 'Accueil';

  @override
  String get navTeacherWorkspace => 'Espace enseignant';

  @override
  String get navTeacherAssessments => 'Évaluations et notes';

  @override
  String get navSavedQuestions => 'Questions sauvegardées';

  @override
  String get navProfile => 'Profil';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navLogout => 'Se déconnecter';

  @override
  String get roleTeacher => 'Enseignant';

  @override
  String get roleAdmin => 'Admin';

  @override
  String get roleSecretary => 'Secrétaire';

  @override
  String get roleParent => 'Parent';

  @override
  String get titleSchedule => 'Emploi du temps';

  @override
  String get titleClasses => 'Classes';

  @override
  String get titlePractice => 'Entraînement';

  @override
  String get titleInsights => 'Analyses';

  @override
  String get titleNova => 'NOVA';

  @override
  String get titleMessages => 'Messages';

  @override
  String get titleSolutions => 'Solutions';

  @override
  String get titleExams => 'Examens';

  @override
  String get solutionsUploadAction => 'Télécharger';

  @override
  String get solutionsNoSubjectsAvailable => 'Aucun sujet disponible.';

  @override
  String solutionsNoSubjectsMatch(Object query) {
    return 'Aucun sujet ne correspond à \"$query\".';
  }

  @override
  String solutionsBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livres',
      one: '1 livre',
    );
    return '$_temp0';
  }

  @override
  String get solutionsBooksTitle => 'Livres';

  @override
  String get solutionsAddBookTitle => 'Ajouter un livre';

  @override
  String get solutionsBookTitleHint => 'Titre du livre...';

  @override
  String get solutionsAddBookAction => 'Ajouter un livre';

  @override
  String get solutionsSearchBooks => 'Rechercher des livres';

  @override
  String get solutionsChooseSubjectFirst => 'Choisissez d\'abord un sujet.';

  @override
  String solutionsNoBooksYetBody(Object action) {
    return 'Aucun livre pour le moment.\nAppuyez sur \"$action\" pour en ajouter le premier.';
  }

  @override
  String solutionsNoBooksMatch(Object query) {
    return 'Aucun livre ne correspond à \"$query\".';
  }

  @override
  String get solutionsBookLabel => 'Livre';

  @override
  String get solutionsPagesFilterHint =>
      'Entrez un numéro de page et de question pour filtrer, ou laissez vide pour voir tous.';

  @override
  String get solutionsPageNumberLabel => 'Numéro de page';

  @override
  String get solutionsPageNumberHint => 'par ex. 42';

  @override
  String get solutionsQuestionNumberLabel => 'Numéro de question';

  @override
  String get solutionsQuestionNumberHint => 'par ex. 3a ou 7';

  @override
  String get solutionsViewSolutionsAction => 'Afficher les solutions';

  @override
  String solutionsPageQuestionSummary(Object page, Object question) {
    return 'Page $page • Question $question';
  }

  @override
  String get solutionsExactQuestionTitle =>
      'Solutions pour cette question exacte';

  @override
  String get solutionsExactQuestionEmptySubtitle =>
      'Rien n\'a encore été téléchargé pour cette question exacte. Soyez le premier à aider vos camarades de classe.';

  @override
  String solutionsUploadsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count téléchargements trouvés',
      one: '1 téléchargement trouvé',
    );
    return '$_temp0';
  }

  @override
  String get solutionsExactQuestionEmptyBody =>
      'Pas de correspondance exacte pour le moment. Vous pouvez en télécharger un maintenant ou voir ce que vos camarades ont résolu sur cette même page.';

  @override
  String get solutionsLoadMoreAction => 'Charger plus';

  @override
  String get solutionsSamePageTitle =>
      'Autres questions résolues sur cette page';

  @override
  String get solutionsSamePageEmptySubtitle =>
      'Aucune question voisine n\'a encore été téléchargée à partir de cette page.';

  @override
  String get solutionsSamePageFallbackSubtitle =>
      'Un fallback utile lorsque votre question exacte n\'a pas encore de téléchargement.';

  @override
  String get solutionsSamePageEmptyBody =>
      'Aucun téléchargement à proximité sur cette page pour le moment. Un nouveau téléchargement ici serait vraiment utile.';

  @override
  String get solutionsVerifiedByNova => 'Vérifié par NOVA';

  @override
  String get solutionsUploadFileLimitReached =>
      'Limite de 10 fichiers atteinte.';

  @override
  String solutionsUploadFilesAddedLimit(int count) {
    return '$count ajouté — limite de 10 fichiers.';
  }

  @override
  String get solutionsUploadCompleteFields =>
      'Complétez le sujet, le livre, la page et la question.';

  @override
  String get solutionsUploadAddOneFile =>
      'Ajoutez au moins une image ou un PDF.';

  @override
  String solutionsUploadFileFailed(Object error) {
    return 'Échec du téléchargement du fichier : $error';
  }

  @override
  String solutionsUploadCreateFailed(Object error) {
    return 'Échec de la création de la solution : $error';
  }

  @override
  String get solutionsUploadSuccess => 'Solution téléchargée !';

  @override
  String get solutionsUploadAddNewBookOption => '+ Ajouter un nouveau livre...';

  @override
  String get solutionsUploadAddBookShortAction => 'Ajouter';

  @override
  String get solutionsUploadTitle => 'Télécharger une solution';

  @override
  String get solutionsUploadSubtitle =>
      'Images réelles ou PDF uniquement. La vérification NOVA et la modération sont appliquées après le téléchargement.';

  @override
  String get solutionsUploadNoBooksAbove =>
      'Aucun livre — en ajouter un ci-dessus';

  @override
  String get solutionsUploadCaptionOptional => 'Légende (optionnel)';

  @override
  String get solutionsUploadImagesAction => 'Images';

  @override
  String get solutionsUploadPdfAction => 'PDF';

  @override
  String solutionsUploadFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fichiers sélectionnés',
      one: 'fichier sélectionné',
    );
    return '$count / 10 $_temp0';
  }

  @override
  String get solutionsUploadSomeFilesFailed =>
      'Certains fichiers n\'ont pas pu être téléchargés.';

  @override
  String get solutionsUploadRetryFailedFiles =>
      'Réessayer les fichiers défaillants';

  @override
  String get solutionsUploadSubmittingAction => 'Téléchargement en cours...';

  @override
  String get solutionsUploadSubmitAction => 'Télécharger la solution';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsSubtitle => 'Apparence, langue et compte';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Par défaut du système';

  @override
  String get settingsAccentColour => 'Couleur d\'accentuation';

  @override
  String get settingsAccentSubtitle => 'Teinte utilisée dans toute l\'app';

  @override
  String get settingsReduceMotion => 'Réduire les animations';

  @override
  String get settingsReduceMotionSubtitle => 'Moins d\'animations dans l\'app';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get settingsLogoutSubtitle => 'Se déconnecter de cet appareil';

  @override
  String get settingsThemeSystem => 'Par défaut du système';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsLanguageSearchHint => 'Rechercher une langue...';

  @override
  String get teacherWorkspaceSubtitle =>
      'Gérez la présence, les groupes et l\'évaluation depuis l\'application mobile.';

  @override
  String get teacherMetricSessionsToday => 'Séances du jour';

  @override
  String get teacherMetricTeachingGroups => 'Groupes d\'enseignement';

  @override
  String get teacherMetricAssessments => 'Évaluations';

  @override
  String get teacherQuickActions => 'Actions rapides';

  @override
  String get teacherNoDateAvailable => 'Aucune date disponible';

  @override
  String get teacherNoTeachingSlotsToday =>
      'Aucune séance prévue aujourd\'hui.';

  @override
  String get teacherUpcomingAssessments => 'Évaluations à venir';

  @override
  String get teacherUpcomingAssessmentsSubtitle =>
      'En direct du système de notation enseignant';

  @override
  String get teacherNoAssessmentsYet =>
      'Aucune évaluation créée pour le moment.';

  @override
  String get teacherUnassignedSlot => 'Créneau non attribué';

  @override
  String get teacherNoCohort => 'Aucun groupe';

  @override
  String get teacherCourseFallback => 'Cours';

  @override
  String teacherPeriod(Object number) {
    return 'Période $number';
  }

  @override
  String get teacherLoadErrorTitle =>
      'Impossible de charger l\'espace enseignant';

  @override
  String get teacherClassroomsLoadError =>
      'Nous n\'avons pas pu charger les salles de classe maintenant. Tirez pour rafraîchir ou réessayez.';

  @override
  String get teacherClassroomsLoadTimeout =>
      'Le chargement des salles de classe prend trop de temps. Tirez pour rafraîchir ou réessayez dans un moment.';

  @override
  String get teacherClassroomsLoadNetwork =>
      'Les salles de classe n\'ont pas pu se connecter pour le moment. Vérifiez votre connexion et réessayez.';

  @override
  String get teacherClassroomsSubtitle =>
      'Ouvrez la liste et générez un code de participation en direct pour l\'entrée des étudiants.';

  @override
  String get teacherClassroomsNoCohorts =>
      'Aucune cohorte de classe n\'est liée à cet enseignant pour l\'instant.';

  @override
  String teacherClassroomsCohort(Object cohortId) {
    return 'Cohorte $cohortId';
  }

  @override
  String get teacherClassroomsGeneratingJoinCode => 'Génération en cours…';

  @override
  String get teacherClassroomsCreateJoinCode =>
      'Créer un code de participation';

  @override
  String get teacherClassroomsLiveJoinCode => 'Code de participation en direct';

  @override
  String teacherClassroomsExpiresAt(Object value) {
    return 'Expire $value';
  }

  @override
  String get teacherClassroomsRoster => 'Liste';

  @override
  String get teacherClassroomsNoStudents =>
      'Aucun étudiant n\'est inscrit dans cette salle de classe pour l\'instant.';

  @override
  String get teacherAttendanceLoadError =>
      'Impossible de charger la présence en ce moment. Tirez pour rafraîchir ou réessayez.';

  @override
  String get teacherAttendanceLoadTimeout =>
      'Le chargement de la présence prend trop de temps. Tirez pour rafraîchir ou réessayez dans un instant.';

  @override
  String get teacherAttendanceLoadNetwork =>
      'La présence n\'a pas pu se connecter en ce moment. Vérifiez votre connexion et réessayez.';

  @override
  String get teacherAttendanceSubtitle =>
      'Sélectionnez une session en direct, marquez la salle et enregistrez uniquement les lignes modifiées.';

  @override
  String get teacherAttendanceTodaySessions => 'Séances d\'aujourd\'hui';

  @override
  String teacherAttendanceSessionSummary(
    Object cohort,
    Object grade,
    Object date,
    Object period,
  ) {
    return '$cohort • Classe $grade • $date • Cours $period';
  }

  @override
  String get teacherAttendanceChanged => 'Modifié';

  @override
  String get teacherAttendanceNoteLabel => 'Remarque';

  @override
  String get teacherAttendanceSaving => 'Enregistrement…';

  @override
  String teacherAttendanceSaveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifications',
      one: '1 modification',
    );
    return 'Enregistrer $_temp0';
  }

  @override
  String get teacherAttendanceSaved => 'Présence enregistrée';

  @override
  String get retry => 'Réessayer';

  @override
  String get scheduleRefreshTooFast =>
      'L\'emploi du temps se rafraîchit trop vite en ce moment. Attendez un instant puis réessayez.';

  @override
  String get scheduleNotOnboarded =>
      'Votre profil élève n\'est pas encore entièrement configuré, donc aucun emploi du temps n\'est disponible pour le moment.';

  @override
  String get scheduleLoadError =>
      'Impossible de charger l\'emploi du temps pour le moment.';

  @override
  String get scheduleSelectedDay => 'Jour sélectionné';

  @override
  String scheduleClassCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cours',
      one: '1 cours',
      zero: '0 cours',
    );
    return '$_temp0';
  }

  @override
  String get scheduleNextUp => 'À venir';

  @override
  String get scheduleNoMoreClasses => 'Plus de cours';

  @override
  String get scheduleNoClassesTitle => 'Aucun cours ce jour-là';

  @override
  String scheduleNoClassesSubtitle(Object day) {
    return '$day semble libre.';
  }

  @override
  String get scheduleClassFallback => 'Cours';

  @override
  String get scheduleNoSubjectLocation => 'Pas encore de matière ni de lieu';

  @override
  String get loginTitle => 'Connexion mobile pour élèves et enseignants';

  @override
  String get loginSubtitle =>
      'Les comptes enseignants ouvrent l\'espace enseignant. Les comptes élèves restent dans l\'expérience élève.';

  @override
  String get loginSignIn => 'Se connecter';

  @override
  String get loginSigningIn => 'Connexion en cours...';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get profileNotAvailable => 'Non disponible';

  @override
  String get profileSchoolInfo => 'Infos école';

  @override
  String get profileFullName => 'Nom complet';

  @override
  String get profileRole => 'Rôle';

  @override
  String get profileSchoolId => 'ID école';

  @override
  String get profileCohortId => 'ID cohorte';

  @override
  String get profileAccountInfo => 'Infos du compte';

  @override
  String get profileUsername => 'Nom d\'utilisateur';

  @override
  String get profileUsernameHint => 'your_username';

  @override
  String get profileContactEmail => 'E-mail de contact';

  @override
  String get profileEmailAddress => 'Adresse e-mail';

  @override
  String get profileEmailHint => 'you@example.com';

  @override
  String get profileBirthday => 'Date de naissance';

  @override
  String get profileSecurity => 'Sécurité';

  @override
  String get profileSelectBirthday => 'Sélectionnez votre date de naissance';

  @override
  String get profilePasswordUpdated => 'Mot de passe mis à jour';

  @override
  String get profileSave => 'Enregistrer';

  @override
  String get profileEmptyValue => '—';

  @override
  String get profileChangePassword => 'Changer le mot de passe';

  @override
  String get profileCurrentPassword => 'Mot de passe actuel';

  @override
  String get profileNewPassword => 'Nouveau mot de passe';

  @override
  String get profileConfirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get profileUpdatePassword => 'Mettre à jour le mot de passe';

  @override
  String get profilePasswordAllFieldsRequired =>
      'Tous les champs sont obligatoires';

  @override
  String get profilePasswordMinLength =>
      'Le nouveau mot de passe doit contenir au moins 8 caractères';

  @override
  String get profilePasswordMismatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get profilePasswordNotAuthenticated => 'Non authentifié';

  @override
  String get profilePasswordIncorrect => 'Le mot de passe actuel est incorrect';

  @override
  String get profilePasswordGenericError =>
      'Une erreur s\'est produite. Réessayez.';

  @override
  String get editProfileTitle => 'Modifier le profil';

  @override
  String get editProfileSchool => 'École';

  @override
  String get editProfileSchoolPublic => 'École publique';

  @override
  String get editProfileGradePublic => 'Niveau public';

  @override
  String get editProfileMajors => 'Spécialités';

  @override
  String get editProfileMajorsPublic => 'Spécialités publiques';

  @override
  String get editProfileBio => 'Bio';

  @override
  String get editProfileBioPublic => 'Bio publique';

  @override
  String get editProfileStatus => 'Statut';

  @override
  String get editProfileStatusPublic => 'Statut public';

  @override
  String get classroomsYourClassrooms => 'Vos classes';

  @override
  String get classroomsReorder => 'Réorganiser les classes';

  @override
  String classroomsCount(Object count) {
    return '$count classes';
  }

  @override
  String get classroomsSearchHint => 'Rechercher des classes';

  @override
  String get classroomsNoSearchMatches =>
      'Aucune classe ne correspond à votre recherche';

  @override
  String get classroomsClassroomLabel => 'Classe';

  @override
  String get classroomsLoadingLatestMessage =>
      'Chargement du dernier message...';

  @override
  String get classroomsTapToOpen => 'Touchez pour ouvrir la classe';

  @override
  String get classroomsNoMessagesYet => 'Pas encore de messages';

  @override
  String get classroomsMessageFallback => 'Message';

  @override
  String get examsLoadError =>
      'Impossible de charger les examens ou les formulaires';

  @override
  String get examsAllFilter => 'Tous';

  @override
  String get examsFormsSubtitle =>
      'Consultez les formulaires de classe, les fenêtres de réponse et les suivis publiés par votre école.';

  @override
  String get examsOnlySubtitle =>
      'Suivez les évaluations à venir, les comptes à rebours et l\'historique des examens de vos classes.';

  @override
  String get examsUpcomingStat => 'Examens à venir';

  @override
  String get examsOpenFormsStat => 'Formulaires ouverts';

  @override
  String get examsCountdownPast => 'Passé';

  @override
  String get examsCountdownTomorrow => 'Demain';

  @override
  String examsCountdownInDays(Object days) {
    return 'Dans $days jours';
  }

  @override
  String get examsNoExamsPublished => 'Aucun examen n\'a encore été publié.';

  @override
  String get examsNoFormsPublished =>
      'Aucun formulaire n\'a encore été publié.';

  @override
  String examsNoExamsForFilter(Object subject) {
    return 'Aucun examen n\'est disponible pour $subject pour le moment.';
  }

  @override
  String examsNoFormsForFilter(Object subject) {
    return 'Aucun formulaire n\'est disponible pour $subject pour le moment.';
  }

  @override
  String examsMaterialsCount(Object count) {
    return '$count documents';
  }

  @override
  String get examsOpenState => 'Ouvert';

  @override
  String get examsClosedState => 'Fermé';

  @override
  String examsQuestionsCount(Object count) {
    return '$count questions';
  }

  @override
  String examsResponsesCount(Object count) {
    return '$count réponses';
  }

  @override
  String get insightsTrendBaseline => 'Référence';

  @override
  String get insightsTrendImproving => 'En amélioration';

  @override
  String get insightsTrendDropping => 'En baisse';

  @override
  String get insightsTrendStable => 'Stable';

  @override
  String get insightsHeadlineIntervention =>
      'La fenêtre d\'intervention est ouverte';

  @override
  String get insightsHeadlineSignals =>
      'Plusieurs signaux doivent être resserrés';

  @override
  String get insightsHeadlineMomentum =>
      'L\'élan peut se renforcer cette semaine';

  @override
  String get insightsBodyAttendance =>
      'Protégez d\'abord l\'assiduité. Une meilleure présence maintenant fera progresser tous les autres signaux plus vite.';

  @override
  String insightsBodyWeakTrend(Object subject) {
    return '$subject avec une baisse de la tendance de pratique est actuellement la combinaison de risque la plus forte. Corrigez cela avant d\'élargir.';
  }

  @override
  String insightsBodyLeverage(Object subject) {
    return '$subject est votre point d\'appui. Servez-vous-en pour gagner en confiance pendant que vous corrigez les points plus faibles.';
  }

  @override
  String get insightsBodyConsistency =>
      'Continuez à accumuler de courtes sessions ciblées. Les prochains jours comptent plus qu\'un plan parfait à long terme.';

  @override
  String get insightsInterventionScoreTitle => 'Score d\'intervention';

  @override
  String insightsInterventionScoreBody(Object count) {
    return '$count signaux actifs orientent votre prochaine décision.';
  }

  @override
  String get insightsRecoveryPathTitle => 'Chemin de reprise le plus rapide';

  @override
  String get insightsRecoveryPathDefault => 'Assiduité + régularité d\'abord.';

  @override
  String insightsRecoveryPathTopic(Object topic, Object subject) {
    return 'Revenez sur $topic en $subject avant d\'accélérer davantage.';
  }

  @override
  String get insightsProjectedDirectionTitle => 'Direction projetée';

  @override
  String insightsProjectedDirectionBody(Object trend) {
    return '$trend selon le comportement récent de pratique sur 7 jours contre 30 jours.';
  }

  @override
  String get insightsLoadingTitle => 'Chargement des analyses';

  @override
  String get insightsLoadingSubtitle =>
      'Construction de votre tableau de bord prédictif.';

  @override
  String get insightsNotReadyTitle => 'Les analyses ne sont pas encore prêtes';

  @override
  String get insightsEmptyTitle => 'Aucune analyse pour le moment';

  @override
  String get insightsEmptySubtitle =>
      'Continuez à utiliser l\'entraînement et les outils scolaires pour que ClassMate puisse construire une image académique plus claire.';

  @override
  String get insightsGradeAverage => 'Moyenne';

  @override
  String get insightsAccuracy => 'Précision';

  @override
  String get insightsOpenNova => 'Ouvrir NOVA';

  @override
  String get insightsOpenNovaPrompt =>
      'Aide-moi à corriger mon point le plus faible en me basant sur mes dernières analyses ClassMate.';

  @override
  String get insightsPredictiveRecoveryPlanTitle => 'Plan de reprise prédictif';

  @override
  String get insightsPracticeNow => 'S\'entraîner maintenant';

  @override
  String get insightsPredictiveModulesTitle => 'Modules prédictifs';

  @override
  String get insightsPredictiveModulesSubtitle =>
      'Les signaux prospectifs les plus forts de vos données étudiantes actuelles.';

  @override
  String get insightsAnnouncementsPressureTitle => 'Pression des annonces';

  @override
  String get insightsAnnouncementsPressureSubtitle =>
      'Le moteur d\'annonces alimente désormais directement le tableau de bord.';

  @override
  String get insightsAiCoachTitle => 'Résumé du coach IA';

  @override
  String get insightsAiCoachLoadingSubtitle => 'Chargement des conseils IA.';

  @override
  String get insightsAiCoachUnavailableSubtitle =>
      'Les conseils IA ne sont pas disponibles pour ce compte actuellement.';

  @override
  String get insightsAskNova => 'Demander à NOVA';

  @override
  String get insightsAskNovaPrompt =>
      'Construis-moi un plan de reprise à partir de mes dernières analyses.';

  @override
  String get insightsAiStudyCoachTitle => 'Coach d\'étude IA';

  @override
  String get insightsSchoolToolsTitle => 'Outils scolaires';

  @override
  String get insightsSchoolToolsSubtitle =>
      'Accédez directement aux routes étudiantes qui comptent le plus maintenant.';

  @override
  String get tutorUntitledChat => 'Discussion sans titre';

  @override
  String get tutorNewChat => 'Nouvelle discussion';

  @override
  String tutorFailedToOpenSeededChat(Object error) {
    return 'Impossible d\'ouvrir la discussion : $error';
  }

  @override
  String tutorFailedToCreateChat(Object error) {
    return 'Impossible de créer la discussion : $error';
  }

  @override
  String get tutorRenameChatTitle => 'Renommer la discussion';

  @override
  String get tutorChatNameHint => 'Nom de la discussion';

  @override
  String get tutorCancel => 'Annuler';

  @override
  String get tutorHide => 'Masquer';

  @override
  String get tutorHideChatTitle => 'Masquer la discussion';

  @override
  String get tutorHideChatSubtitle =>
      'Masque cette discussion sur cet appareil.';

  @override
  String get tutorHideChatConfirmTitle => 'Masquer la discussion ?';

  @override
  String get tutorHideChatConfirmBody =>
      'Cela masque la discussion de la liste sur cet appareil. La session reste sur le backend.';

  @override
  String get tutorTapToOpenHistory => 'Touchez pour ouvrir l\'historique';

  @override
  String get tutorAiTutorSubtitle => 'Votre tuteur IA';

  @override
  String get tutorHeroBody =>
      'Historique réel des discussions, fils plus propres, accès plus rapide.';

  @override
  String get tutorStartFreshConversation =>
      'Commencer une nouvelle conversation';

  @override
  String get tutorSearchHistoryHint => 'Rechercher dans l\'historique';

  @override
  String get chatComposerDefaultHint => 'Message';

  @override
  String get chatComposerReplyingToMessage => 'Réponse à un message';

  @override
  String get chatComposerReplyFallback => 'Réponse';

  @override
  String get chatComposerMicHint =>
      'Touchez pour une note vocale rapide ou maintenez pour enregistrer';

  @override
  String get chatComposerRecordingTitle => 'Enregistrement';

  @override
  String get chatComposerReleaseToSend => 'Relâchez pour envoyer';

  @override
  String get chatComposerCancelTitle => 'Annuler';

  @override
  String get chatComposerLockTitle => 'Verrouiller';

  @override
  String get chatComposerSlideLeftToCancel => 'Glissez à gauche pour annuler';

  @override
  String get chatComposerSlideUpToLock =>
      'Glissez vers le haut pour verrouiller';

  @override
  String get chatComposerReleaseToCancel => 'Relâchez pour annuler';

  @override
  String get chatComposerKeepSlidingToCancel =>
      'Continuez à glisser pour annuler';

  @override
  String get chatComposerReleaseToLock => 'Relâchez pour verrouiller';

  @override
  String get chatComposerRelease => 'Relâcher';

  @override
  String get chatComposerLock => 'Verrou';

  @override
  String get chatComposerRecordingPaused => 'Enregistrement en pause';

  @override
  String get chatComposerRecordingLocked => 'Enregistrement verrouillé';

  @override
  String get chatComposerResumeHint =>
      'Reprenez quand vous êtes prêt à continuer';

  @override
  String get chatComposerLockedHint =>
      'Touchez envoyer quand vous êtes prêt à partager';

  @override
  String get chatContextDismiss => 'Fermer';

  @override
  String get chatContextCopyText => 'Copier le texte';

  @override
  String get chatContextDelete => 'Supprimer';

  @override
  String get chatMessageInfoShortTitle => 'Infos';

  @override
  String get chatMessageInfoStatus => 'Statut';

  @override
  String get chatMessageInfoStatusTime => 'Heure du statut';

  @override
  String get chatMessageInfoSentAt => 'Envoyé à';

  @override
  String get chatMessageInfoDeliveredAt => 'Distribué à';

  @override
  String get chatMessageInfoSeenAt => 'Vu à';

  @override
  String get chatMessageInfoMessageType => 'Type de message';

  @override
  String get chatMessageInfoTextType => 'Texte';

  @override
  String get chatMessageInfoEdited => 'Modifié';

  @override
  String get chatMessageInfoForwarded => 'Transféré';

  @override
  String get chatMessageInfoVoiceDuration => 'Durée vocale';

  @override
  String get chatMessageInfoSeenBy => 'Vu par';

  @override
  String get chatMessageInfoDeliveredTo => 'Distribué à';

  @override
  String get chatMessageInfoEmptyBody => '(vide)';

  @override
  String get chatMessageInfoReadLess => 'Réduire';

  @override
  String get chatMessageInfoReadMore => 'Lire plus';

  @override
  String get chatMessageInfoSeen => 'Vu';

  @override
  String get chatMessageInfoDelivered => 'Distribué';

  @override
  String get chatMessageInfoNotDelivered => 'Non distribué';

  @override
  String get chatMessageInfoSent => 'Envoyé';

  @override
  String get chatMessageInfoPending => 'En attente';

  @override
  String get chatMessageInfoNotSeen => 'Non vu';

  @override
  String get chatMessageInfoType => 'Type';

  @override
  String get chatMessageInfoDuration => 'Durée';

  @override
  String get chatMessageInfoYes => 'Oui';

  @override
  String get chatMessageInfoNo => 'Non';

  @override
  String get chatMessageInfoDeleteState => 'État de suppression';

  @override
  String get chatReactionDetailsTitle => 'Réactions';

  @override
  String get chatReactionAddAction => 'Ajouter une réaction';

  @override
  String get chatReactionEmptyState => 'Aucune réaction pour le moment';

  @override
  String get chatReactionSingle => 'Réaction';

  @override
  String get chatReactionTapToRemove => 'Touchez pour retirer';

  @override
  String chatReactionYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' · $count',
      one: '',
    );
    return 'Vous$_temp0';
  }

  @override
  String chatReactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réactions',
      one: 'Réaction',
    );
    return '$_temp0';
  }

  @override
  String get chatEmojiPickerTitle => 'Choisir un emoji';

  @override
  String get chatEmojiPickerSearchHint => 'Rechercher un emoji';

  @override
  String get chatEmojiPickerEmptyState => 'Aucun emoji trouvé';

  @override
  String get chatCameraTitle => 'Caméra';

  @override
  String get chatCameraUseAction => 'Utiliser';

  @override
  String get chatCameraGalleryAction => 'Galerie';

  @override
  String chatCameraSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnés',
      one: '1 sélectionné',
      zero: '0 sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get chatMediaPreviewEmptyState => 'Rien à prévisualiser';

  @override
  String get chatMediaPreviewDrawCropAction => 'Dessiner et rogner';

  @override
  String get chatMediaPreviewRotateLeftAction => 'Tourner à gauche';

  @override
  String get chatMediaPreviewRotateRightAction => 'Tourner à droite';

  @override
  String get chatMediaPreviewMirrorAction => 'Miroir';

  @override
  String get chatMediaPreviewResetAction => 'Réinitialiser';

  @override
  String get chatMediaPreviewRemoveAction => 'Retirer';

  @override
  String get chatMediaPreviewCaptionHint => 'Ajouter une légende...';

  @override
  String tutorPlanSelectedPlaceholder(Object plan) {
    return '$plan sélectionné. Les paiements restent en mode fictif pour le moment.';
  }

  @override
  String get tutorFailedToLoadChats => 'Impossible de charger les discussions';

  @override
  String get tutorNoChatsYet => 'Aucune discussion pour le moment';

  @override
  String get tutorNoChatsMatchSearch =>
      'Aucune discussion ne correspond à votre recherche';

  @override
  String get tutorCreateFirstChat => 'Créer la première discussion';

  @override
  String get tutorPlansTitle => 'Forfaits NOVA';

  @override
  String tutorPlansSubtitle(Object model) {
    return 'Basé sur les hypothèses de coût de $model et des plafonds mensuels stricts pour que l\'usage reste rentable.';
  }

  @override
  String get tutorPlanPriceFree => 'Gratuit';

  @override
  String tutorPlanPriceMonthly(Object price) {
    return '\$$price/mois';
  }

  @override
  String get tutorPromptsLeft => 'Prompts restants';

  @override
  String get tutorUploadsLeft => 'Envois restants';

  @override
  String get tutorVoiceLeft => 'Voix restante';

  @override
  String tutorUsageValue(Object remaining, Object total) {
    return '$remaining/$total';
  }

  @override
  String tutorVoiceUsageValue(Object remaining, Object total) {
    return '$remaining/$total min';
  }

  @override
  String get tutorPaymentMethodsTitle => 'Moyens de paiement';

  @override
  String tutorPaymentMethodsSubtitle(Object plan) {
    return 'Le paiement reste fictif jusqu\'à ce que le compte bancaire et le processeur de ClassMate soient actifs. Le forfait sélectionné est $plan.';
  }

  @override
  String get tutorCardCheckoutTitle => 'Paiement par carte';

  @override
  String get tutorCardCheckoutSubtitle =>
      'Passerelle fictive Visa, Mastercard et AmEx.';

  @override
  String get tutorApplePayTitle => 'Apple Pay';

  @override
  String get tutorApplePaySubtitle =>
      'Flux de portefeuille fictif pour iPhone et web.';

  @override
  String get tutorBankTransferTitle => 'Virement bancaire';

  @override
  String get tutorBankTransferSubtitle =>
      'Compte bancaire ClassMate en attente. Les détails seront ajoutés une fois ouvert.';

  @override
  String get tutorPlanStarterName => 'Starter';

  @override
  String get tutorPlanStarterTagline =>
      'Suffisant pour un essai et une légère révision hebdomadaire.';

  @override
  String get tutorPlanPlusName => 'Plus';

  @override
  String get tutorPlanPlusTagline =>
      'Idéal pour un élève sérieux qui utilise NOVA la plupart des jours.';

  @override
  String get tutorPlanProName => 'Pro';

  @override
  String get tutorPlanProTagline =>
      'Usage quotidien intensif, pleine saison d\'examens et longues sessions d\'étude.';

  @override
  String get tutorPlanSchoolSeatName => 'Siège école';

  @override
  String get tutorPlanSchoolSeatTagline =>
      'Pour un déploiement par élève ou membre du personnel dans une vraie école.';

  @override
  String tutorPlanBulletPromptsMonthly(Object count) {
    return '$count prompts NOVA par mois';
  }

  @override
  String tutorPlanBulletPromptsPerSeatMonthly(Object count) {
    return '$count prompts NOVA par siège chaque mois';
  }

  @override
  String tutorPlanBulletUploads(Object count) {
    return '$count envois d\'image ou de fichier';
  }

  @override
  String tutorPlanBulletVoiceMinutes(Object count) {
    return '$count minutes de transcription vocale';
  }

  @override
  String tutorEstimatedCostCeilingFree(Object cost) {
    return 'Plafond de coût estimé : \$$cost/mois';
  }

  @override
  String tutorEstimatedCostCeilingPaid(Object cost, Object margin) {
    return 'Plafond de coût estimé : \$$cost/mois • marge $margin%';
  }

  @override
  String tutorTimeMinutesShort(Object count) {
    return '$count min';
  }

  @override
  String tutorTimeHoursShort(Object count) {
    return '$count h';
  }

  @override
  String get tutorVoiceMessageFallback => 'Message vocal';

  @override
  String get tutorFileFallback => 'Fichier';

  @override
  String get tutorCopy => 'Copier';

  @override
  String get tutorEditMessage => 'Modifier le message';

  @override
  String get tutorCopied => 'Copié';

  @override
  String get tutorLoadedIntoComposer => 'Chargé dans le champ de saisie';

  @override
  String get tutorTakePhoto => 'Prendre une photo';

  @override
  String get tutorRecordVideo => 'Enregistrer une vidéo';

  @override
  String get tutorChooseFromGallery => 'Choisir depuis la galerie';

  @override
  String get tutorPreviewTitle => 'Aperçu';

  @override
  String get tutorThinking => 'Réflexion en cours...';

  @override
  String get tutorDone => 'Terminé.';

  @override
  String get tutorFailedToStreamReply => 'Impossible de diffuser la réponse';

  @override
  String get tutorUnsupportedFilesMessage =>
      'NOVA prend en charge les images, les documents et le texte. Les fichiers vidéo et audio ne sont pas pris en charge ici.';

  @override
  String get tutorNoAudioCaptured => 'Aucun audio capturé.';

  @override
  String get tutorVoiceLimitReachedTitle => 'Limite vocale atteinte';

  @override
  String get tutorVoiceLimitReachedMessage =>
      'Votre forfait NOVA actuel n\'a pas assez de minutes vocales pour ce cycle de transcription.';

  @override
  String get tutorTranscriptionFailed =>
      'La transcription a échoué. Veuillez réessayer.';

  @override
  String get tutorMicrophonePermissionRequired =>
      'L\'autorisation du micro est requise.';

  @override
  String get tutorPlanLimitReachedTitle => 'Limite du forfait NOVA atteinte';

  @override
  String get tutorPlanLimitReachedMessage =>
      'Le quota mensuel de prompts ou d\'envois de votre forfait NOVA actuel est épuisé. Choisissez un forfait supérieur sur l\'accueil NOVA pour continuer.';

  @override
  String get tutorSendFailed => 'Échec de l\'envoi.';

  @override
  String tutorCurrentPlanUsageSummary(
    Object plan,
    Object prompts,
    Object uploads,
    Object voice,
  ) {
    return 'Forfait actuel : $plan • $prompts prompts restants • $uploads envois restants • $voice minutes vocales restantes';
  }

  @override
  String get tutorReviewPlansInHome => 'Voir les forfaits dans l\'accueil NOVA';

  @override
  String get tutorCouldNotOpenAttachment =>
      'Impossible d\'ouvrir la pièce jointe.';

  @override
  String get tutorAttachmentUnavailable => 'Pièce jointe indisponible.';

  @override
  String get tutorImageUnavailable => 'Image indisponible';

  @override
  String get tutorYou => 'Vous';

  @override
  String get tutorRegenerate => 'Regénérer';

  @override
  String get tutorEmptyStateTitle => 'Commencez par une vraie question';

  @override
  String get tutorEmptyStateBody =>
      'Demandez à NOVA d\'expliquer un concept, de transformer des notes en tableau, de comparer des idées ou de vous aider à réviser depuis un fichier importé.';

  @override
  String get tutorPromptSuggestionSummarizeNotes => 'Résume mes notes de cours';

  @override
  String get tutorPromptSuggestionRevisionTable =>
      'Fais un tableau de révision';

  @override
  String get tutorPromptSuggestionQuizMe => 'Interroge-moi sur ce sujet';

  @override
  String get tutorMessageNovaHint => 'Message à NOVA';

  @override
  String get tutorHeaderSubtitleReady =>
      'Réponses structurées, tableaux et aide à l\'étude';

  @override
  String get tutorYourNovaPlanTitle => 'Votre forfait NOVA';

  @override
  String get tutorYourNovaPlanMessage =>
      'Consultez ici vos limites de prompts, d\'envois et de voix, puis revenez à l\'accueil NOVA si vous souhaitez changer de forfait.';

  @override
  String get tutorExplainTitle => 'NOVA explique';

  @override
  String get classroomsThreadTypeClassroom => 'Classe';

  @override
  String get classroomsThreadTypeGroup => 'Groupe';

  @override
  String get classroomsThreadTypeDirectMessage => 'Message direct';

  @override
  String get classroomsThreadTypeDirectMessageShort => 'DM';

  @override
  String get messagesBlockedPeopleTitle => 'Personnes bloquées';

  @override
  String get messagesStartChatAction => 'Démarrer une discussion';

  @override
  String messagesLoadFailed(Object error) {
    return 'Impossible de charger les messages : $error';
  }

  @override
  String get messagesSearchHint => 'Rechercher des messages';

  @override
  String get messagesNoResults => 'Aucun message trouvé';

  @override
  String get messagesRequestsSection => 'Demandes';

  @override
  String get messagesPendingApprovals => 'Approbations en attente';

  @override
  String get messagesChatsSection => 'Discussions';

  @override
  String get messagesAllChatsSection => 'Toutes les discussions';

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
  String get messagesRequestReviewStatus => 'Voir';

  @override
  String messagesPeopleLoadFailed(Object error) {
    return 'Impossible de charger les personnes : $error';
  }

  @override
  String get messagesSearchPeopleHint => 'Rechercher des personnes';

  @override
  String get messagesNewGroupTitle => 'Nouveau groupe';

  @override
  String get messagesNewGroupSubtitle => 'Créer une discussion de groupe';

  @override
  String get messagesGroupNameHint => 'Nom du groupe';

  @override
  String get messagesCreateGroupAction => 'Créer le groupe';

  @override
  String get messagesBlockedPersonFallback => 'cette personne';

  @override
  String get messagesUnblockPersonTitle => 'Débloquer cette personne ?';

  @override
  String messagesUnblockPersonBody(Object name) {
    return 'Autoriser $name à vous envoyer de nouveau des messages ?';
  }

  @override
  String get messagesUnblockAction => 'Débloquer';

  @override
  String messagesUnblockedToast(Object name) {
    return '$name débloqué';
  }

  @override
  String messagesBlockedPeopleLoadFailed(Object error) {
    return 'Impossible de charger les personnes bloquées : $error';
  }

  @override
  String get messagesNoBlockedPeople => 'Aucune personne bloquée';

  @override
  String get messagesUnknownUser => 'Utilisateur inconnu';

  @override
  String get messagesRequestTitle => 'Demande';

  @override
  String messagesRequestLoadFailed(Object error) {
    return 'Impossible de charger la demande : $error';
  }

  @override
  String get messagesRequestBannerIncoming => 'Demande de message';

  @override
  String get messagesRequestBannerOutgoing => 'Approbation en attente';

  @override
  String get messagesBlockAction => 'Bloquer';

  @override
  String get messagesApproveAction => 'Approuver';

  @override
  String get messagesRequestUnlockHint =>
      'La discussion se déverrouille après que le destinataire a approuvé votre premier message.';

  @override
  String get messagesThreadConversationFallback => 'Discussion';

  @override
  String get messagesThreadLeaveGroupTitle => 'Quitter le groupe ?';

  @override
  String get messagesThreadLeaveGroupBody =>
      'Vous ne recevrez plus de messages de ce groupe.';

  @override
  String get messagesThreadBlockPersonTitle => 'Bloquer cette personne ?';

  @override
  String get messagesThreadBlockPersonBody =>
      'Vous ne pourrez plus échanger de messages avec cette personne.';

  @override
  String get messagesThreadPersonFallback => 'Personne';

  @override
  String get messagesThreadProfileInfoUnavailable =>
      'Informations du profil indisponibles';

  @override
  String get messagesThreadParticipants => 'Participants';

  @override
  String get messagesThreadPeople => 'Personnes';

  @override
  String get messagesThreadDeleteForMe => 'Supprimer pour moi';

  @override
  String get messagesThreadDeleteForEveryone => 'Supprimer pour tout le monde';

  @override
  String get messagesThreadDeleteForEveryoneSubtitle =>
      'Supprime pour tous les participants';

  @override
  String get messagesThreadSending => 'Envoi en cours…';

  @override
  String get messagesThreadWaitingForApproval => 'En attente d\'approbation';

  @override
  String get classroomsForwardSearchHint => 'Rechercher des discussions';

  @override
  String get classroomsForwardNewChat => 'Nouvelle discussion';

  @override
  String classroomsForwardLoadError(Object error) {
    return 'Impossible de charger les discussions : $error';
  }

  @override
  String get classroomsForwardNoChatsFound => 'Aucune discussion trouvée';

  @override
  String get classroomsForwardSectionClassrooms => 'Classes';

  @override
  String get classroomsForwardSectionDirectMessages => 'Messages directs';

  @override
  String get classroomsForwardCancel => 'Annuler';

  @override
  String get classroomsForwardAction => 'Transférer';

  @override
  String classroomsForwardCount(Object count) {
    return 'Transférer ($count)';
  }

  @override
  String get markRead => 'Marquer comme lu';

  @override
  String get markUnread => 'Marquer comme non lu';

  @override
  String get markAllRead => 'Tout marquer comme lu';

  @override
  String get filters => 'Filtres';

  @override
  String get source => 'Source';

  @override
  String get state => 'État';

  @override
  String get allSources => 'Toutes les sources';

  @override
  String get allStates => 'Tous les états';

  @override
  String get unread => 'Non lu';

  @override
  String get read => 'Lu';

  @override
  String get clear => 'Effacer';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get earlier => 'Précédemment';

  @override
  String get openDetails => 'Voir les détails';

  @override
  String get total => 'Total';

  @override
  String get local => 'Local';

  @override
  String get server => 'Serveur';

  @override
  String get notificationsSourceSystem => 'Système';

  @override
  String get notificationsHeroSubtitleStudent =>
      'Votre centre de notifications pour les annonces, les mises à jour serveur et l\'activité scolaire utile au fil de l\'eau.';

  @override
  String get notificationsHeroSubtitleTeacher =>
      'Votre centre de notifications enseignant pour les annonces, les mises à jour serveur et l\'activité scolaire au fil de l\'eau.';

  @override
  String get notificationsFiltersSubtitle =>
      'Filtrez par source ou par état de lecture pour trier plus vite.';

  @override
  String get notificationsSearchSourcesHint => 'Rechercher des sources';

  @override
  String notificationsShowingSummary(Object shown, Object total) {
    return 'Affichage de $shown notifications sur $total.';
  }

  @override
  String get notificationsEmptyForAccount =>
      'Aucune notification n\'est disponible pour ce compte pour le moment.';

  @override
  String get notificationsEmptyFiltered =>
      'Aucune notification ne correspond à ces filtres pour le moment. Effacez les filtres pour voir tout le flux.';

  @override
  String get notificationsEmpty =>
      'Aucune notification n\'est disponible pour le moment.';

  @override
  String get notificationsNewBadge => 'Nouveau';

  @override
  String get notificationsUnavailable =>
      'Cette notification n\'est plus disponible. Actualisez la boîte de réception puis réessayez.';

  @override
  String get notificationsSeverityCritical => 'Critique';

  @override
  String get notificationsSeverityWarning => 'Alerte';

  @override
  String get notificationsSeverityInfo => 'Info';

  @override
  String get announcementsLoadError =>
      'Impossible de charger les annonces en ce moment. Tirez pour actualiser ou réessayez.';

  @override
  String get announcementsLoadTimeout =>
      'Les annonces prennent trop de temps à charger. Tirez pour actualiser ou réessayez dans un moment.';

  @override
  String get announcementsLoadNetwork =>
      'Les annonces n\'ont pas pu se connecter en ce moment. Vérifiez votre connexion et réessayez.';

  @override
  String get announcementsAudienceTeacher => 'enseignant';

  @override
  String get announcementsAudienceAccount => 'compte';

  @override
  String get announcementsAudienceTeacherWorkspace =>
      'espace de travail enseignant';

  @override
  String get announcementsLoadFailedTitle =>
      'Impossible de charger les annonces';

  @override
  String get announcementsLoadFailedHint =>
      'Tirez pour actualiser une fois la connexion stable.';

  @override
  String announcementsHeroSubtitle(Object audience) {
    return 'Annonces publiées de l\'école, de l\'enseignant et du système disponibles pour $audience.';
  }

  @override
  String get announcementsLatestSourceLabel => 'Dernière source';

  @override
  String get announcementsNone => 'Aucune';

  @override
  String announcementsUnreadCountTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count annonces non lues',
      one: '1 annonce non lue',
    );
    return '$_temp0';
  }

  @override
  String get announcementsAllReadTitle => 'Tout est lu';

  @override
  String announcementsEmptyForAudience(Object audience) {
    return 'Aucune annonce n\'a été publiée pour $audience pour le moment.';
  }

  @override
  String announcementsLatestBody(Object title) {
    return 'Dernière : $title. Appuyez dessus pour lire le contenu complet.';
  }

  @override
  String get announcementsFiltersSubtitle =>
      'Réduisez la boîte de réception par source ou par état de lecture pour vous concentrer sur ce qui nécessite encore une attention.';

  @override
  String get announcementsAllAnnouncements => 'Toutes les annonces';

  @override
  String get announcementsSearchStatesHint => 'Non lu / Lu';

  @override
  String announcementsSummarySourceSegment(Object source) {
    return ' de $source';
  }

  @override
  String announcementsSummaryStateSegment(Object state) {
    return ' en $state';
  }

  @override
  String announcementsShowingSummary(
    Object shown,
    Object total,
    Object sourceSegment,
    Object stateSegment,
  ) {
    return 'Affichage de $shown sur $total annonces$sourceSegment$stateSegment.';
  }

  @override
  String get announcementsNoMatchTitle =>
      'Aucune annonce ne correspond à ces filtres';

  @override
  String get announcementsNoPublishedTitle =>
      'Aucune annonce publiée pour le moment';

  @override
  String get announcementsNoMatchSubtitle =>
      'Essayez une source différente ou revenez à toutes les annonces pour afficher plus d\'éléments.';

  @override
  String get announcementsClearFiltersHint =>
      'Effacez les filtres pour tout voir à nouveau.';

  @override
  String get announcementsPullToRefreshHint =>
      'Tirez pour actualiser après la publication d\'une nouvelle activité scolaire.';

  @override
  String get announcementsInboxTitle => 'Boîte de réception';

  @override
  String get announcementsInboxSubtitle =>
      'Seuls les titres apparaissent ici pour un balayage rapide. Appuyez sur un élément pour ouvrir le contenu complet de l\'annonce.';

  @override
  String get meetingsLoadError =>
      'Impossible de charger les réunions pour le moment. Tirez pour actualiser ou réessayez.';

  @override
  String get meetingsLoadTimeout =>
      'Les réunions prennent trop de temps à charger. Tirez pour actualiser ou réessayez dans un instant.';

  @override
  String get meetingsLoadNetwork =>
      'Impossible de se connecter aux réunions pour le moment. Vérifiez votre connexion et réessayez.';

  @override
  String get meetingsHeroSubtitle =>
      'Toutes les réunions de classe dans une vue épurée, avec des liens joints et une page de détails en plein écran quand vous avez besoin du contexte.';

  @override
  String get meetingsJoinReadyMetric => 'Prêt à rejoindre';

  @override
  String get meetingsNoLinkMetric => 'Sans lien';

  @override
  String get meetingsNoPostedTitle => 'Aucune réunion publiée pour le moment';

  @override
  String get meetingsEmptyForAccount =>
      'Aucune réunion de classe n\'est disponible pour ce compte étudiant pour le moment.';

  @override
  String meetingsLatestBody(Object title, Object updatedAt) {
    return '$title a été mis à jour $updatedAt. Ouvrez-le pour le lien joint et le contexte de classe.';
  }

  @override
  String get meetingsPullToRefreshHint =>
      'Tirez vers le bas pour vérifier à nouveau.';

  @override
  String get meetingsFiltersSubtitle =>
      'Réduisez la liste par matière ou selon que la réunion contient déjà un lien que vous pouvez ouvrir.';

  @override
  String get meetingsAccessLabel => 'Accès';

  @override
  String get meetingsAllMeetings => 'Toutes les réunions';

  @override
  String get meetingsAccessReady => 'Prêt à rejoindre';

  @override
  String get meetingsAccessNoLink => 'Sans lien';

  @override
  String get meetingsAccessNoLinkYet => 'Pas de lien pour le moment';

  @override
  String get meetingsAccessSearchHint =>
      'Prêt à rejoindre / Pas de lien pour le moment';

  @override
  String meetingsSummarySubjectSegment(Object subject) {
    return ' pour $subject';
  }

  @override
  String meetingsSummaryAccessSegment(Object state) {
    return ' en $state';
  }

  @override
  String meetingsShowingSummary(
    Object shown,
    Object total,
    Object subjectSegment,
    Object accessSegment,
  ) {
    return 'Affichage de $shown sur $total réunions$subjectSegment$accessSegment.';
  }

  @override
  String get meetingsNoMatchTitle =>
      'Aucune réunion ne correspond à ces filtres';

  @override
  String get meetingsNoMatchSubtitle =>
      'Essayez toutes les matières ou incluez les réunions sans liens pour obtenir plus de résultats dans la liste.';

  @override
  String get meetingsListSubtitle =>
      'Appuyez sur n\'importe quelle réunion pour ouvrir la vue de détails en plein écran et accéder à son lien joint si disponible.';

  @override
  String meetingsDateTimeValue(Object date, Object time) {
    return '$date • $time';
  }

  @override
  String meetingsSharedByValue(Object name) {
    return 'Partagée par $name';
  }

  @override
  String get meetingsPreviewFallback =>
      'Ouvrez cette réunion pour voir le lien joint et les derniers détails de classe.';

  @override
  String get meetingsNoValidLinkAttached =>
      'Aucun lien de réunion valide n\'est joint pour le moment.';

  @override
  String get meetingsCouldNotOpenLink =>
      'Impossible d\'ouvrir le lien de réunion.';

  @override
  String get meetingsNoLinkToCopy =>
      'Aucun lien de réunion à copier pour le moment.';

  @override
  String get meetingsLinkCopied => 'Lien de réunion copié.';

  @override
  String get meetingsUnavailableTitle => 'Réunion indisponible';

  @override
  String get meetingsUnavailableSubtitle =>
      'Cette réunion est introuvable dans le flux actuel. Elle a peut-être été supprimée ou n\'est pas disponible hors ligne.';

  @override
  String get meetingsUnavailableHint =>
      'Retournez en arrière et actualisez la liste des réunions.';

  @override
  String get meetingsNoLinkAttachedYet => 'Aucun lien joint pour le moment';

  @override
  String get meetingsAttachedLinkTitle => 'Lien de réunion joint';

  @override
  String get meetingsAttachedLinkMissingBody =>
      'Cette réunion est visible dans votre flux de classe, mais aucune URL valide n\'est jointe dans la charge de l\'étudiant actuelle.';

  @override
  String get meetingsDetailsTitle => 'Détails de la réunion';

  @override
  String get meetingsDetailsSubtitle =>
      'Tout ce qui est pertinent pour l\'étudiant et actuellement disponible dans la charge de réunion de classe.';

  @override
  String get meetingsDetailClassroomLabel => 'Classe';

  @override
  String get meetingsSharedByLabel => 'Partagée par';

  @override
  String get meetingsIdLabel => 'ID de réunion';

  @override
  String get meetingsAttachedLinkSubtitle =>
      'Utilisez l\'URL jointe pour rejoindre ou copiez le lien de réunion lorsque votre classe en fournit un.';

  @override
  String get meetingsOpening => 'Ouverture en cours';

  @override
  String get meetingsOpenLink => 'Ouvrir le lien';

  @override
  String get meetingsCopyLink => 'Copier le lien';

  @override
  String get meetingsAccessPanelTitle => 'Accès à la réunion';

  @override
  String get meetingsAccessPanelReadyBody =>
      'Ouvrez l\'URL jointe dans votre navigateur ou votre application de réunion.';

  @override
  String get meetingsJoinAction => 'Rejoindre';

  @override
  String get announcementsDetailLoadFailedHint =>
      'Retournez et essayez d\'actualiser la boîte de réception des annonces.';

  @override
  String get announcementsUnavailableTitle => 'Annonce indisponible';

  @override
  String announcementsUnavailableSubtitle(Object audience) {
    return 'Cette annonce n\'est plus disponible dans le flux publié pour $audience.';
  }

  @override
  String get announcementsUnavailableHint =>
      'Retournez à la boîte de réception pour continuer.';

  @override
  String announcementsPublishedReadStateBody(Object audience) {
    return 'Cette annonce a été publiée pour $audience et votre état de lecture est stocké localement sur cet appareil.';
  }

  @override
  String get announcementsDetailsTitle => 'Détails de l\'annonce';

  @override
  String get announcementsDetailsSubtitle =>
      'Métadonnées publiées pour cette annonce et son état de lecture actuel.';

  @override
  String get announcementsSeverityLabel => 'Gravité';

  @override
  String get announcementsCreatedLabel => 'Créé';

  @override
  String get announcementsIdLabel => 'ID d\'annonce';

  @override
  String get announcementsFullContentTitle => 'Contenu complet';

  @override
  String get announcementsFullContentSubtitle =>
      'Le texte complet de l\'annonce s\'affiche ici après avoir ouvert l\'élément à partir de la boîte de réception.';

  @override
  String get announcementsReadStateTitle => 'État de lecture';

  @override
  String get announcementsReadStateBodyRead =>
      'Cette annonce est marquée comme lue sur cet appareil.';

  @override
  String get announcementsReadStateBodyUnread =>
      'Cette annonce est toujours non lue sur cet appareil.';

  @override
  String get alertsTitle => 'Alertes';

  @override
  String get alertsSubtitle =>
      'Cette page regroupe ce qui demande une attention immédiate, pas seulement les mises à jour générales.';

  @override
  String get alertsAttendanceTitle => 'L\'assiduité demande de l\'attention';

  @override
  String alertsAttendanceBody(Object rate) {
    return 'Votre taux de présence est de $rate%. Quelques cours manqués peuvent vite s\'accumuler.';
  }

  @override
  String get alertsWeakestSubjectTitle => 'Signal de matière la plus faible';

  @override
  String alertsWeakestSubjectBody(Object subject) {
    return '$subject demande actuellement le plus d\'attention selon vos dernières notes.';
  }

  @override
  String get alertsPracticeWeakAreaTitle => 'Zone faible en pratique';

  @override
  String alertsPracticeWeakAreaBody(Object topic, Object subject) {
    return '$topic en $subject est actuellement votre point faible le plus clair.';
  }

  @override
  String get alertsPracticeTrendDroppedTitle =>
      'La tendance de pratique baisse';

  @override
  String get alertsPracticeTrendDroppedBody =>
      'Votre performance sur 7 jours est inférieure à votre base sur 30 jours. Ralentissez et revenez aux fondamentaux avant de pousser davantage.';

  @override
  String get alertsEmpty =>
      'Tout est calme pour l\'instant. Si quelque chose demande une attention urgente, cela apparaîtra ici.';

  @override
  String get student => 'Étudiant';

  @override
  String get classroomDetailPhoto => 'Photo';

  @override
  String get classroomDetailVoiceNote => 'Note vocale';

  @override
  String get classroomDetailVideo => 'Vidéo';

  @override
  String get classroomDetailFile => 'Fichier';

  @override
  String get classroomDetailEmptyValue => '(vide)';

  @override
  String get classroomDetailAttachmentUnavailable =>
      'Pièce jointe indisponible.';

  @override
  String get classroomDetailAudioUnavailable => 'Audio indisponible.';

  @override
  String get classroomDetailCouldNotOpenAttachment =>
      'Impossible d’ouvrir la pièce jointe.';

  @override
  String get classroomDetailVoiceMessage => 'Message vocal';

  @override
  String get classroomDetailVideoFile => 'Fichier vidéo';

  @override
  String get classroomDetailAttachedFile => 'Fichier joint';

  @override
  String get classroomDetailAttachment => 'Pièce jointe';

  @override
  String get classroomDetailPinAction => 'Épingler';

  @override
  String get classroomDetailUnpinAction => 'Désépingler';

  @override
  String get classroomDetailMessageInfoTitle => 'Infos du message';

  @override
  String get classroomDetailForwardedSingle => 'Transféré';

  @override
  String classroomDetailForwardedMultiple(Object count) {
    return '$count messages transférés';
  }

  @override
  String get classroomDetailCannotForwardPending =>
      'Impossible de transférer dans une demande de chat avant son approbation';

  @override
  String get classroomDetailCouldNotForwardSelected =>
      'Impossible de transférer les messages sélectionnés';

  @override
  String classroomDetailSelectedCount(Object count) {
    return '$count sélectionnés';
  }

  @override
  String classroomDetailDeleteCount(Object count) {
    return 'Supprimer ($count)';
  }

  @override
  String get classroomDetailSelectAllTooltip => 'Tout sélectionner';

  @override
  String get classroomDetailCancelTooltip => 'Annuler';

  @override
  String get classroomDetailMicrophoneAccessTitle => 'Accès au micro requis';

  @override
  String get classroomDetailMicrophoneAccessBody =>
      'Veuillez autoriser l’accès au micro dans Réglages -> ClassMate pour envoyer des notes vocales.';

  @override
  String get classroomDetailOpenSettingsAction => 'Ouvrir les réglages';

  @override
  String classroomDetailForwardTargetNext(Object label) {
    return 'Sélecteur de transfert ensuite : $label';
  }

  @override
  String get classroomDetailEditMessageTitle => 'Modifier le message';

  @override
  String get classroomDetailEditMessageHint => 'Modifiez votre message...';

  @override
  String get classroomDetailLeaveClassroomTitle => 'Quitter la classe ?';

  @override
  String get classroomDetailLeaveClassroomBody =>
      'Vous serez retiré de cette classe.';

  @override
  String get classroomDetailLeaveAction => 'Quitter';

  @override
  String get classroomDetailNoAssignmentsTitle => 'Aucun devoir pour l’instant';

  @override
  String get classroomDetailNoAssignmentsSubtitle =>
      'Cette classe n’a aucun devoir pour le moment.';

  @override
  String get classroomDetailAssignmentFallback => 'Devoir';

  @override
  String get classroomDetailNoMaterialsTitle => 'Aucun support pour l’instant';

  @override
  String get classroomDetailNoMaterialsSubtitle =>
      'Cette classe n’a aucun support pour le moment.';

  @override
  String get classroomDetailMaterialFallback => 'Support';

  @override
  String get classroomDetailNoMeetingsTitle => 'Aucune réunion pour l’instant';

  @override
  String get classroomDetailNoMeetingsSubtitle =>
      'Cette classe n’a aucune réunion pour le moment.';

  @override
  String get classroomDetailMeetingFallback => 'Réunion';

  @override
  String get classroomDetailCouldNotLoadPeople =>
      'Impossible de charger les participants';

  @override
  String get classroomDetailNoPeopleTitle => 'Personne pour l’instant';

  @override
  String get classroomDetailNoPeopleSubtitle =>
      'Personne n’est encore visible dans cette classe.';

  @override
  String get classroomDetailTabChat => 'Discussion';

  @override
  String get classroomDetailTabMaterials => 'Supports';

  @override
  String get classroomDetailTabPeople => 'Participants';

  @override
  String get classroomChatMediaSendPhoto => 'Envoyer une photo';

  @override
  String get classroomChatMediaSendPhotoSubtitle =>
      'Partager une image dans la discussion de la classe';

  @override
  String get classroomChatMediaSendVoiceMessage => 'Envoyer un message vocal';

  @override
  String get classroomChatMediaSendVoiceMessageSubtitle =>
      'Enregistrer et envoyer une note vocale';

  @override
  String get classroomDetailCouldNotLoadTab => 'Impossible de charger l’onglet';

  @override
  String get classroomDetailDeletedByYou => 'Vous avez supprimé ce message';

  @override
  String get classroomDetailDeletedMessage => 'Ce message a été supprimé';

  @override
  String get practiceSetupDifficultyEasy => 'Facile';

  @override
  String get practiceSetupDifficultyMedium => 'Moyen';

  @override
  String get practiceSetupDifficultyHard => 'Difficile';

  @override
  String get practiceSetupDifficultyOlympiad => 'Olympiade';

  @override
  String get practiceSetupDifficultyAdaptive => 'Adaptatif';

  @override
  String get practiceSetupModeLabelPractice => 'Entraînement';

  @override
  String get practiceSetupModeLabelFlashcards => 'Flashcards';

  @override
  String get practiceSetupModeLabelSpeedRound => 'Round rapide';

  @override
  String get practiceSetupModeLabelExamPrep => 'Prépa examen';

  @override
  String get practiceSetupModeLabelConceptBuilder => 'Construction de concept';

  @override
  String get practiceSetupModeLabelAdaptive => 'Adaptatif';

  @override
  String get practiceSetupModeLabelBagrut => 'Bagrut';

  @override
  String get practiceSetupModeSubtitlePractice =>
      'Pratique quotidienne équilibrée';

  @override
  String get practiceSetupModeSubtitleFlashcards => 'Révélation et auto-rappel';

  @override
  String get practiceSetupModeSubtitleSpeedRound =>
      'Exercice rapide sous pression';

  @override
  String get practiceSetupModeSubtitleExamPrep => 'Flux calme type examen';

  @override
  String get practiceSetupModeSubtitleConceptBuilder =>
      'Concept d’abord, résoudre ensuite';

  @override
  String get practiceSetupModeSubtitleAdaptive =>
      'La difficulté évolue en direct';

  @override
  String get practiceSetupModeSubtitleBagrut => 'Style officiel strict';

  @override
  String get practiceSetupModeHelpPractice =>
      'Mode équilibré : résoudre, vérifier, expliquer, puis continuer.';

  @override
  String get practiceSetupModeHelpFlashcards =>
      'Les flashcards marchent mieux quand vous essayez de vous rappeler avant de révéler.';

  @override
  String get practiceSetupModeHelpSpeedRound =>
      'Le round rapide entraîne le rappel instantané. Allez vite et faites confiance à vos bons instincts.';

  @override
  String get practiceSetupModeHelpExamPrep =>
      'La prépa examen est plus calme et plus formelle, comme une vraie séance scolaire.';

  @override
  String get practiceSetupModeHelpConceptBuilder =>
      'La construction de concept enseigne l’idée d’abord puis vous demande de l’appliquer.';

  @override
  String get practiceSetupModeHelpAdaptive =>
      'Le mode adaptatif change le niveau de difficulté selon vos performances.';

  @override
  String get practiceSetupModeHelpBagrut =>
      'Le mode Bagrut se concentre sur une résolution stricte et une révision de style examen.';

  @override
  String get practiceSetupModeInfoTitle => 'Comment fonctionne chaque mode';

  @override
  String get practiceSetupHeroTitle => 'Commencer une session';

  @override
  String get practiceSetupHeroSubtitle =>
      'Choisissez un mode, le timing et la difficulté.';

  @override
  String get practiceSetupInfiniteLives => 'Vies infinies';

  @override
  String practiceSetupLivesCount(Object count) {
    return '$count vies';
  }

  @override
  String get practiceSetupAiTiming => 'Timing IA';

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
    return 'Matière : $subject';
  }

  @override
  String practiceSetupSummaryTopic(Object topic) {
    return 'Sujet : $topic';
  }

  @override
  String practiceSetupSummaryMode(Object mode) {
    return 'Mode : $mode';
  }

  @override
  String practiceSetupSummaryDifficulty(Object difficulty) {
    return 'Difficulté : $difficulty';
  }

  @override
  String practiceSetupSummaryQuestions(Object count) {
    return 'Questions : $count';
  }

  @override
  String practiceSetupSummaryTiming(Object timing) {
    return 'Timing : $timing';
  }

  @override
  String practiceSetupSummaryLives(Object lives) {
    return 'Vies : $lives';
  }

  @override
  String get practiceSetupSectionSubjectTopic => 'Matière et sujet';

  @override
  String get practiceSetupFieldSubject => 'Matière';

  @override
  String get practiceSetupFieldSubjectHint => 'Choisir la matière';

  @override
  String get practiceSetupChooseSubject => 'Choisir la matière';

  @override
  String get practiceSetupFieldCustomSubject => 'Matière personnalisée';

  @override
  String get practiceSetupFieldCustomSubjectHint =>
      'Saisissez votre propre matière';

  @override
  String get practiceSetupDialogCustomSubjectTitle => 'Matière personnalisée';

  @override
  String get practiceSetupDialogEnterSubject => 'Saisir la matière';

  @override
  String get practiceSetupUseAction => 'Utiliser';

  @override
  String get practiceSetupFieldTopic => 'Sujet';

  @override
  String get practiceSetupFieldTopicHint => 'Choisir un sous-sujet';

  @override
  String get practiceSetupChooseTopic => 'Choisir le sujet';

  @override
  String get practiceSetupFieldCustomTopic => 'Sujet personnalisé';

  @override
  String get practiceSetupFieldCustomTopicHint =>
      'Saisissez votre propre sujet';

  @override
  String get practiceSetupDialogCustomTopicTitle => 'Sujet personnalisé';

  @override
  String get practiceSetupDialogEnterTopic => 'Saisir le sujet';

  @override
  String get practiceSubjectMath => 'Mathématiques';

  @override
  String get practiceSubjectPhysics => 'Physique';

  @override
  String get practiceSubjectComputerScience => 'Informatique';

  @override
  String get practiceSubjectChemistry => 'Chimie';

  @override
  String get practiceSubjectBiology => 'Biologie';

  @override
  String get practiceSubjectEnglish => 'Anglais';

  @override
  String get practiceSubjectArabic => 'Arabe';

  @override
  String get practiceSubjectHebrew => 'Hébreu';

  @override
  String get practiceSubjectGeneralKnowledge => 'Culture générale';

  @override
  String get practiceTopicAllTopics => 'Tous les sujets';

  @override
  String get practiceTopicAlgebra => 'Algèbre';

  @override
  String get practiceTopicLinearEquations => 'Équations linéaires';

  @override
  String get practiceTopicQuadraticEquations => 'Équations quadratiques';

  @override
  String get practiceTopicFunctions => 'Fonctions';

  @override
  String get practiceTopicGeometry => 'Géométrie';

  @override
  String get practiceTopicTriangles => 'Triangles';

  @override
  String get practiceTopicCircles => 'Cercles';

  @override
  String get practiceTopicAnalyticGeometry => 'Géométrie analytique';

  @override
  String get practiceTopicTrigonometry => 'Trigonométrie';

  @override
  String get practiceTopicProbability => 'Probabilités';

  @override
  String get practiceTopicStatistics => 'Statistiques';

  @override
  String get practiceTopicSequences => 'Suites';

  @override
  String get practiceTopicCalculus => 'Calcul différentiel';

  @override
  String get practiceTopicLimits => 'Limites';

  @override
  String get practiceTopicDerivatives => 'Dérivées';

  @override
  String get practiceTopicMechanics => 'Mécanique';

  @override
  String get practiceTopicKinematics => 'Cinématique';

  @override
  String get practiceTopicNewtonLaws => 'Lois de Newton';

  @override
  String get practiceTopicForces => 'Forces';

  @override
  String get practiceTopicEnergy => 'Énergie';

  @override
  String get practiceTopicMomentum => 'Quantité de mouvement';

  @override
  String get practiceTopicElectricity => 'Électricité';

  @override
  String get practiceTopicElectricField => 'Champ électrique';

  @override
  String get practiceTopicCircuits => 'Circuits';

  @override
  String get practiceTopicWaves => 'Ondes';

  @override
  String get practiceTopicOptics => 'Optique';

  @override
  String get practiceTopicThermodynamics => 'Thermodynamique';

  @override
  String get practiceTopicConditions => 'Conditions';

  @override
  String get practiceTopicBooleanLogic => 'Logique booléenne';

  @override
  String get practiceTopicIfElse => 'Si / Sinon';

  @override
  String get practiceTopicNestedConditions => 'Conditions imbriquées';

  @override
  String get practiceTopicLoops => 'Boucles';

  @override
  String get practiceTopicVariables => 'Variables';

  @override
  String get practiceTopicArrays => 'Tableaux';

  @override
  String get practiceTopicStrings => 'Chaînes';

  @override
  String get practiceTopicAlgorithms => 'Algorithmes';

  @override
  String get practiceTopicComplexity => 'Complexité';

  @override
  String get practiceTopicRecursion => 'Récursion';

  @override
  String get practiceTopicAtoms => 'Atomes';

  @override
  String get practiceTopicPeriodicTable => 'Tableau périodique';

  @override
  String get practiceTopicChemicalBonds => 'Liaisons chimiques';

  @override
  String get practiceTopicReactions => 'Réactions';

  @override
  String get practiceTopicStoichiometry => 'Stœchiométrie';

  @override
  String get practiceTopicAcidsAndBases => 'Acides et bases';

  @override
  String get practiceTopicOrganicChemistry => 'Chimie organique';

  @override
  String get practiceTopicCells => 'Cellules';

  @override
  String get practiceTopicGenetics => 'Génétique';

  @override
  String get practiceTopicHumanBody => 'Corps humain';

  @override
  String get practiceTopicEcology => 'Écologie';

  @override
  String get practiceTopicEvolution => 'Évolution';

  @override
  String get practiceTopicSystems => 'Systèmes';

  @override
  String get practiceTopicGrammar => 'Grammaire';

  @override
  String get practiceTopicReadingComprehension => 'Compréhension de lecture';

  @override
  String get practiceTopicVocabulary => 'Vocabulaire';

  @override
  String get practiceTopicTenses => 'Temps verbaux';

  @override
  String get practiceTopicWriting => 'Écriture';

  @override
  String get practiceTopicRhetoric => 'Rhétorique';

  @override
  String get practiceSetupSectionMode => 'Mode';

  @override
  String get practiceSetupSectionDifficulty => 'Difficulté';

  @override
  String get practiceSetupSectionControls => 'Contrôles de session';

  @override
  String get practiceSetupQuestionsTitle => 'Questions';

  @override
  String get practiceSetupQuestionsCaption =>
      'Combien de questions générées inclure';

  @override
  String get practiceSetupTimingTitle => 'Timing';

  @override
  String get practiceSetupTimingCaption =>
      'Choisissez d’abord la portée, puis IA, votre temps ou infini.';

  @override
  String get practiceSetupTimingScopePerQuestion => 'Par question';

  @override
  String get practiceSetupTimingScopeWholeQuiz => 'Quiz entier';

  @override
  String get practiceSetupTimingModeAi => 'IA';

  @override
  String get practiceSetupTimingModeMyTime => 'Mon temps';

  @override
  String get practiceSetupTimingModeInfinite => 'Infini';

  @override
  String get practiceSetupTimingCustomPerQuestionTitle =>
      'Secondes par question';

  @override
  String get practiceSetupTimingCustomPerQuestionCaption =>
      'Votre propre minuteur pour chaque question';

  @override
  String get practiceSetupTimingCustomQuizMinutesTitle => 'Minutes du quiz';

  @override
  String get practiceSetupTimingCustomQuizMinutesCaption =>
      'Votre propre minuteur pour tout le quiz';

  @override
  String get practiceSetupInfiniteLivesTitle => 'Vies infinies';

  @override
  String get practiceSetupInfiniteLivesSubtitle =>
      'Ne terminez jamais la session à cause de mauvaises réponses';

  @override
  String get practiceSetupLivesTitle => 'Vies';

  @override
  String get practiceSetupLivesCaption =>
      'Erreurs autorisées avant la fin de la session';

  @override
  String get practiceSetupTooltipHistory => 'Historique d’entraînement';

  @override
  String get practiceHistoryTitle => 'Historique de pratique';

  @override
  String get practiceHistoryClearTooltip => 'Effacer l\'historique';

  @override
  String get practiceHistoryClearConfirmTitle =>
      'Effacer l\'historique de pratique ?';

  @override
  String get practiceHistoryClearConfirmBody =>
      'Cela supprime toutes les sessions de pratique enregistrées de cet appareil.';

  @override
  String get practiceHistoryLoadError =>
      'Impossible de charger l\'historique de pratique pour le moment.';

  @override
  String get practiceHistoryErrorPrefix => 'Erreur :';

  @override
  String get practiceHistoryEmpty =>
      'Aucune session de pratique pour l\'instant.';

  @override
  String get practiceHistoryDeleteConfirmTitle => 'Supprimer cette session ?';

  @override
  String get practiceHistoryDeleteConfirmBody =>
      'Cela supprime uniquement cette session de pratique enregistrée.';

  @override
  String get practiceHistoryOpenReview => 'Ouvrir l\'examen';

  @override
  String get practiceHistoryDeleteSession => 'Supprimer la session';

  @override
  String get practiceHistoryDebugTitle =>
      'Débogage de l’historique de pratique';

  @override
  String get practiceAnalyticsTitle => 'Analyses de pratique';

  @override
  String get practiceAnalyticsSectionOverall => 'Vue d’ensemble';

  @override
  String get practiceAnalyticsRecentSessionsTitle => 'Sessions récentes';

  @override
  String practiceAnalyticsRecentSessionsSummary(
    Object sessions,
    Object correct,
    Object answered,
    Object accuracy,
    Object xp,
  ) {
    return '$sessions sessions • $correct/$answered correctes • $accuracy% • XP $xp';
  }

  @override
  String get practiceAnalyticsSectionWeakestTopics => 'Sujets les plus faibles';

  @override
  String get practiceAnalyticsSectionStrongestTopics => 'Sujets les plus forts';

  @override
  String get practiceAnalyticsSectionModePerformance => 'Performance par mode';

  @override
  String get practiceAnalyticsNoTopicData =>
      'Aucune donnée de sujet pour l’instant';

  @override
  String get practiceAnalyticsNoModeData =>
      'Aucune donnée de mode pour l’instant';

  @override
  String get savedQuestionsTopSubjectNone => 'Rien encore';

  @override
  String get savedQuestionsHeroSubtitle =>
      'Les questions que vous avez enregistrées pendant la pratique doivent être faciles à revisiter. Cette page est le hub de réessai propre pour les revisiter.';

  @override
  String get savedQuestionsSavedMetric => 'Enregistré';

  @override
  String get savedQuestionsTopSubjectMetric => 'Meilleur sujet';

  @override
  String get savedQuestionsQuickActionsSubtitle =>
      'Retournez directement à la pratique ou parcourez les solutions communautaires.';

  @override
  String get savedQuestionsOpenPractice => 'Ouvrir la pratique';

  @override
  String get savedQuestionsOpenPracticeSubtitle =>
      'Commencez une nouvelle session et continuez à développer votre élan';

  @override
  String get savedQuestionsOpenSolutions => 'Ouvrir les solutions';

  @override
  String get savedQuestionsOpenSolutionsSubtitle =>
      'Parcourez les solutions téléchargées par sujet, livre, page et question';

  @override
  String get savedQuestionsQueueTitle => 'Votre file d\'attente enregistrée';

  @override
  String get savedQuestionsQueueSubtitle =>
      'Les questions que vous enregistrez lors de la pratique apparaissent ici afin que vous puissiez les rouvrir rapidement et continuer à travailler vos points faibles.';

  @override
  String get savedQuestionsEmptyTitle =>
      'Aucune question enregistrée pour le moment';

  @override
  String get savedQuestionsEmptySubtitle =>
      'Enregistrez une question à partir de la pratique pour la revisiter plus tard, ouvrez les solutions connexes et suivez les sujets qui ont encore besoin de travail.';

  @override
  String get savedQuestionsClearAction => 'Effacer les questions enregistrées';

  @override
  String get savedQuestionsWhyItWorks => 'Pourquoi ça marche';

  @override
  String savedQuestionsHoursTarget(Object count) {
    return '$count h cible';
  }

  @override
  String savedQuestionsMinutesTarget(Object count) {
    return '$count min cible';
  }

  @override
  String savedQuestionsSecondsTarget(Object count) {
    return '$count sec cible';
  }

  @override
  String get practiceSetupTooltipAnalytics => 'Analyse d’entraînement';

  @override
  String get practiceSetupStopGenerating => 'Arrêter la génération';

  @override
  String get practiceSetupGenerating => 'Génération...';

  @override
  String get practiceSetupStartSession => 'Commencer la session';

  @override
  String get practiceSetupSearchHint => 'Rechercher...';

  @override
  String get practiceSessionModeDescriptionPractice =>
      'Résolution équilibrée avec vérification et retour immédiats.';

  @override
  String get practiceSessionModeDescriptionFlashcards =>
      'Mode mémoire conçu pour le rappel rapide et la rétention.';

  @override
  String get practiceSessionModeDescriptionSpeedRound =>
      'Répétitions rapides, fluides et sous pression.';

  @override
  String get practiceSessionModeDescriptionExamPrep =>
      'Résolution type examen plus formelle et moins ludifiée.';

  @override
  String get practiceSessionModeDescriptionConceptBuilder =>
      'Comprendre l’idée d’abord, puis résoudre avec contexte.';

  @override
  String get practiceSessionModeDescriptionAdaptive =>
      'La difficulté change selon vos performances.';

  @override
  String get practiceSessionModeDescriptionBagrut =>
      'Flux Bagrut officiel à question unique.';

  @override
  String get practiceSessionLoadingPractice =>
      'Préparation de votre session de pratique';

  @override
  String get practiceSessionLoadingFlashcards => 'Mélange de vos flashcards';

  @override
  String get practiceSessionLoadingSpeedRound => 'Démarrage de la ronde rapide';

  @override
  String get practiceSessionLoadingExamPrep =>
      'Préparation de votre session d’examen';

  @override
  String get practiceSessionLoadingConceptBuilder =>
      'Chargement du coach de concepts';

  @override
  String get practiceSessionLoadingAdaptive => 'Personnalisation de votre défi';

  @override
  String get practiceSessionLoadingBagrut =>
      'Préparation de votre série Bagrut';

  @override
  String get practiceSessionLoadingDefault => 'Préparation de votre session';

  @override
  String practiceSessionCompleteTitle(Object mode) {
    return '$mode terminé';
  }

  @override
  String get practiceSessionMetricAnswered => 'Répondues';

  @override
  String get practiceSessionMetricCorrect => 'Correctes';

  @override
  String get practiceSessionMetricWrong => 'Fausses';

  @override
  String get practiceSessionMetricAccuracy => 'Précision';

  @override
  String get practiceSessionMetricTotal => 'Total';

  @override
  String get practiceSessionMetricXp => 'XP';

  @override
  String get practiceSessionMetricStreak => 'Série';

  @override
  String get practiceSessionReviewLayoutStacked => 'Empilé';

  @override
  String get practiceSessionReviewLayoutFocus => 'Focus';

  @override
  String get practiceSessionFilterAll => 'Toutes';

  @override
  String get practiceSessionFilterWrong => 'Fausses';

  @override
  String get practiceSessionFilterCorrect => 'Correctes';

  @override
  String get practiceSessionReviewTitle => 'Revue de session';

  @override
  String get practiceSessionNoQuestionsForFilter =>
      'Aucune question ne correspond encore à ce filtre.';

  @override
  String get practiceSessionNoAnswer => 'Aucune réponse';

  @override
  String get practiceSessionUnknownAnswer => 'Inconnue';

  @override
  String get practiceSessionReflectionTitle => 'Réflexion';

  @override
  String get practiceSessionReflectionKnewIt => 'Je le savais';

  @override
  String get practiceSessionReflectionReviewAgain => 'Revoir encore';

  @override
  String get practiceSessionBackOfCard => 'Dos de la carte';

  @override
  String get practiceSessionYourAnswer => 'Votre réponse';

  @override
  String get practiceSessionCorrectAnswer => 'Bonne réponse';

  @override
  String get practiceSessionExplanation => 'Explication';

  @override
  String get practiceSessionBackToSetup => 'Retour à la configuration';

  @override
  String get practiceSessionGeneralTopic => 'Général';

  @override
  String practiceSessionQuestionProgress(Object current, Object total) {
    return 'Question $current sur $total';
  }

  @override
  String get practiceSessionMetricTime => 'Temps';

  @override
  String practiceSessionMatchmakingDifficulty(Object difficulty) {
    return 'Difficulté : $difficulty';
  }

  @override
  String get practiceModeActionPrevious => 'Précédent';

  @override
  String get practiceModeActionCheckAnswer => 'Vérifier la réponse';

  @override
  String get practiceModeActionNext => 'Suivant';

  @override
  String get practiceModeActionNextQuestion => 'Question suivante';

  @override
  String get practiceModeActionEndSession => 'Terminer la session';

  @override
  String get practiceModeActionEndQuestion => 'Terminer la question';

  @override
  String get practiceModeActionEndExam => 'Terminer l\'examen';

  @override
  String get practiceModeActionNovaHint => 'Indice NOVA';

  @override
  String get practiceModeActionReveal => 'Révéler';

  @override
  String get practiceModeActionShowSolution => 'Afficher la solution';

  @override
  String get practiceModeActionHideSolution => 'Masquer la solution';

  @override
  String get practiceModeActionLockIn => 'Valider';

  @override
  String get practiceModeActionCheckAdapt => 'Vérifier et adapter';

  @override
  String get practiceModeActionContinue => 'Continuer';

  @override
  String get practiceModeActionSolveIt => 'Résoudre';

  @override
  String get practiceModeActionNextConcept => 'Concept suivant';

  @override
  String get practiceModeCardFront => 'Recto de la carte';

  @override
  String get practiceModeRecallSummary => 'Résumé du rappel';

  @override
  String get practiceModeFeelingPrompt => 'Quel effet cela a fait ?';

  @override
  String get practiceModeFeelingAgain => 'Encore';

  @override
  String get practiceModeFeelingHard => 'Difficile';

  @override
  String get practiceModeFeelingGood => 'Bien';

  @override
  String get practiceModeFeelingEasy => 'Facile';

  @override
  String get practiceModeSpeedRoundBanner =>
      'Speed round · décisions rapides, élan immédiat';

  @override
  String get practiceModeFastFeedback => 'Retour rapide';

  @override
  String get practiceModeExamPrepBanner =>
      'Prépa examen · interface plus calme, réponses revues après avoir avancé';

  @override
  String get practiceModeReview => 'Révision';

  @override
  String get practiceModeBagrutBanner =>
      'Mode Bagrut · déroulé de sujet officiel';

  @override
  String get practiceModeOfficialSolution => 'Solution de style officiel';

  @override
  String get practiceModeAdaptiveWarmup => 'Difficulté d’échauffement';

  @override
  String get practiceModeAdaptiveTrendingUp => 'Difficulté en hausse';

  @override
  String get practiceModeAdaptiveEasingDown => 'Difficulté en baisse';

  @override
  String get practiceModeAdaptiveSteady => 'Difficulté stable';

  @override
  String get practiceModeAdaptiveFeedback => 'Retour adaptatif';

  @override
  String get practiceModeConceptFirst => 'Concept d\'abord';

  @override
  String get practiceModeNowSolveIt => 'Maintenant, résous-le';

  @override
  String get practiceModeConceptTitle => 'Concept';

  @override
  String get practiceModeFeedbackCorrect => 'Correct';

  @override
  String get practiceModeFeedbackNotQuite => 'Pas tout à fait';

  @override
  String get practiceModeFallbackQuestion => 'Question';

  @override
  String get practiceModeNoExplanationYet =>
      'Aucune explication disponible pour l’instant.';

  @override
  String get teacherGradesAssessmentCreated => 'Évaluation créée';

  @override
  String get teacherGradesEditAssessmentTitle => 'Modifier l’évaluation';

  @override
  String get teacherGradesFieldTitle => 'Titre';

  @override
  String get teacherGradesFieldDate => 'Date (YYYY-MM-DD)';

  @override
  String get teacherGradesFieldMaxGrade => 'Note maximale';

  @override
  String get teacherGradesAssessmentUpdated => 'Évaluation mise à jour';

  @override
  String get teacherGradesDeleteAssessmentTitle => 'Supprimer l’évaluation ?';

  @override
  String teacherGradesDeleteAssessmentBody(Object title) {
    return 'Cela supprimera $title et son entrée de notes de l’espace enseignant.';
  }

  @override
  String get teacherGradesDeleteAction => 'Supprimer';

  @override
  String get teacherGradesAssessmentDeleted => 'Évaluation supprimée';

  @override
  String get teacherGradesRosterLinkError =>
      'Cette évaluation n’est pas liée à une liste de classe.';

  @override
  String get teacherGradesSaved => 'Notes enregistrées';

  @override
  String get teacherGradesSubtitle =>
      'Créez des évaluations et enregistrez les notes à partir de la liste de classe en direct.';

  @override
  String get teacherGradesCreateAssessmentTitle => 'Créer une évaluation';

  @override
  String get teacherGradesFieldCourse => 'Cours';

  @override
  String get teacherGradesCreateAction => 'Créer';

  @override
  String get teacherGradesNoStudentsLoaded =>
      'Aucun élève chargé pour cette évaluation.';

  @override
  String get teacherGradesFieldGrade => 'Note';

  @override
  String teacherGradesMaxHint(Object grade) {
    return 'Max $grade';
  }

  @override
  String get teacherGradesSaving => 'Enregistrement…';

  @override
  String teacherGradesSaveCount(Object count) {
    return 'Enregistrer $count notes';
  }

  @override
  String get assignmentsNoDueDate => 'Aucune date limite';

  @override
  String get assignmentsLoadError =>
      'Impossible de charger les devoirs maintenant. Tirez pour actualiser ou réessayez.';

  @override
  String get assignmentsLoadTimeout =>
      'Les devoirs prennent trop de temps à charger. Tirez pour actualiser ou réessayez dans un instant.';

  @override
  String get assignmentsLoadNetwork =>
      'Impossible de se connecter aux devoirs. Vérifiez votre connexion et réessayez.';

  @override
  String get assignmentsStatusOverdue => 'En retard';

  @override
  String get assignmentsStatusDueSoon => 'Bientôt à rendre';

  @override
  String get assignmentsStatusUpcoming => 'À venir';

  @override
  String get assignmentsPreviewFallback =>
      'Ouvrez ce devoir pour voir les instructions complètes et préparer votre travail.';

  @override
  String get assignmentsSubmissionPrepEmpty =>
      'Placez votre note ou vos fichiers ici.';

  @override
  String assignmentsSubmissionPrepCount(Object count) {
    return '$count fichier(s) joint(s) localement.';
  }

  @override
  String get assignmentsHeroSubtitle =>
      'Tous les devoirs de classe dans une seule vue claire, avec une page de détails en plein écran et un espace dédié pour préparer votre travail.';

  @override
  String get assignmentsSubjectsMetric => 'Matières';

  @override
  String get assignmentsNothingAssignedYet =>
      'Rien n\'a été assigné pour le moment';

  @override
  String get assignmentsNoAssignmentsForAccount =>
      'Aucun devoir de classe n\'est actuellement disponible pour ce compte d\'élève.';

  @override
  String assignmentsNextThingBody(Object title, Object due) {
    return '$title est la prochaine chose à examiner. $due.';
  }

  @override
  String get assignmentsPullToCheckAgain =>
      'Tirez vers le bas pour vérifier à nouveau.';

  @override
  String get assignmentsFiltersSubtitle =>
      'Affinez la liste par matière ou urgence pour vous concentrer sur ce qui compte en premier.';

  @override
  String get assignmentsSubjectLabel => 'Matière';

  @override
  String get assignmentsAllSubjects => 'Toutes les matières';

  @override
  String get assignmentsSearchSubjects => 'Rechercher des matières';

  @override
  String get assignmentsStatusLabel => 'Statut';

  @override
  String get assignmentsAllStatuses => 'Tous les statuts';

  @override
  String get assignmentsSearchStatuses => 'Rechercher des statuts';

  @override
  String assignmentsShowingSummary(Object shown, Object total) {
    return 'Affichage de $shown sur $total devoirs.';
  }

  @override
  String get assignmentsNoFilterMatchesTitle =>
      'Aucun devoir ne correspond à ces filtres';

  @override
  String get assignmentsNoFilterMatchesSubtitle =>
      'Essayez toutes les matières ou une vue de statut plus large pour ramener plus de devoirs dans la liste.';

  @override
  String get assignmentsClearFiltersHint =>
      'Effacez les filtres pour tout voir à nouveau.';

  @override
  String get assignmentsListSubtitle =>
      'Appuyez sur un devoir pour ouvrir la vue détails en plein écran et préparer votre travail.';

  @override
  String get assignmentsAddNoteBeforePrepare =>
      'Ajoutez une note ou joignez un fichier avant de préparer votre travail.';

  @override
  String get assignmentsWorkDraftPrepared => 'Brouillon de travail préparé.';

  @override
  String get assignmentsWorkDraftPreparedWithFiles =>
      'Brouillon de travail préparé. Les fichiers joints sont enregistrés sur cet appareil.';

  @override
  String get assignmentsUnavailableTitle => 'Devoir indisponible';

  @override
  String get assignmentsUnavailableSubtitle =>
      'Ce devoir n\'a pas pu être trouvé dans le flux actuel. Il a peut-être été supprimé ou n\'est pas disponible hors ligne.';

  @override
  String get assignmentsUnavailableHint =>
      'Revenez et actualisez la liste des devoirs.';

  @override
  String get assignmentsOverdueBannerBody =>
      'Ce devoir a dépassé sa date limite. Ouvrez votre espace de travail ci-dessous pour préparer ce que vous voulez remettre.';

  @override
  String get assignmentsWorkAreaBannerBody =>
      'Utilisez l\'espace de travail ci-dessous pour organiser des fichiers, écrire une note et garder tout prêt au même endroit.';

  @override
  String get assignmentsDetailsSectionTitle => 'Détails du devoir';

  @override
  String get assignmentsDetailsSectionSubtitle =>
      'Tout ce qui est pertinent pour l\'élève et actuellement disponible dans la charge utile du devoir de classe.';

  @override
  String get assignmentsDetailDueLabel => 'À rendre';

  @override
  String get assignmentsDetailClassroomLabel => 'Classe';

  @override
  String get assignmentsDetailTeacherLabel => 'Professeur';

  @override
  String get assignmentsDetailPostedByLabel => 'Publié par';

  @override
  String get assignmentsDetailPublishedLabel => 'Publié';

  @override
  String get assignmentsDetailUpdatedLabel => 'Mis à jour';

  @override
  String get assignmentsDetailIdLabel => 'ID du devoir';

  @override
  String get assignmentsInstructionsTitle => 'Instructions';

  @override
  String get assignmentsInstructionsSubtitle =>
      'Texte complet du devoir du flux de classe, avec le libellé d\'origine préservé.';

  @override
  String get assignmentsYourWorkTitle => 'Votre travail';

  @override
  String get assignmentsYourWorkSubtitle =>
      'Organisez une note, joignez des fichiers ou des documents et gardez votre préparation de soumission dans un espace concentré.';

  @override
  String get assignmentsPrivateNoteLabel => 'Note de travail privée';

  @override
  String get assignmentsPrivateNoteHint =>
      'Ajoutez ce que vous envisagez de soumettre, des rappels pour vous-même ou un résumé de document/lien.';

  @override
  String get assignmentsAddFiles => 'Ajouter des fichiers ou des documents';

  @override
  String get assignmentsClearFiles => 'Effacer les fichiers';

  @override
  String get assignmentsStagedDeviceHint =>
      'Les fichiers sont organisés sur cet appareil. La soumission de fichiers de devoir n\'est pas disponible dans cette application.';

  @override
  String assignmentsLastPrepared(Object time) {
    return 'Dernière préparation $time.';
  }

  @override
  String get assignmentsSubmissionPrepTitle => 'Préparation de la soumission';

  @override
  String get assignmentsPreparing => 'Préparation en cours';

  @override
  String get assignmentsPrepareWork => 'Préparer le travail';

  @override
  String get assignmentsLoadingSubtitle =>
      'Chargement de vos devoirs de classe.';

  @override
  String get assignmentsPullToRefreshRetry =>
      'Tirez pour actualiser ou réessayez ci-dessous.';

  @override
  String get assignmentsFileSizeUnknown => 'Fichier';

  @override
  String get assignmentsRemoveAttachment => 'Supprimer la pièce jointe';

  @override
  String get attendanceUndated => 'Sans date';

  @override
  String get attendanceLoadError =>
      'Impossible de charger la présence maintenant. Faites glisser pour actualiser ou réessayez.';

  @override
  String get attendanceLoadTimeout =>
      'La présence prend trop de temps à charger. Faites glisser pour actualiser ou réessayez dans un instant.';

  @override
  String get attendanceLoadNetwork =>
      'La présence ne peut pas se connecter maintenant. Vérifiez votre connexion et réessayez.';

  @override
  String get attendanceConsistencyBuilding => 'Encore en construction';

  @override
  String get attendanceConsistencyExcellent => 'Excellente cohérence';

  @override
  String get attendanceConsistencySteady => 'Plutôt stable';

  @override
  String get attendanceConsistencyNeedsAttention => 'Nécessite de l\'attention';

  @override
  String get attendanceConsistencyRisk => 'Risque de présence';

  @override
  String get attendanceWatchRecentAbsences => 'Absences récentes';

  @override
  String get attendanceWatchRepeatedLateness => 'Retards répétés';

  @override
  String get attendanceWatchExcusedAddingUp => 'Le temps excusé s\'accumule';

  @override
  String get attendanceWatchNoFlags => 'Aucun signalement actuel';

  @override
  String get attendanceAllSubjectsLowercase => 'toutes les matières';

  @override
  String attendanceShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return 'Affichage de $shown sur $total notes pour $subject dans $range.';
  }

  @override
  String get attendanceDayToneAbsent => 'Jour d\'absence';

  @override
  String get attendanceDayToneLate => 'Signal de retard';

  @override
  String get attendanceDayToneExcused => 'Présence excusée';

  @override
  String get attendanceDayToneClean => 'Jour propre';

  @override
  String get attendanceLoadingSubtitle =>
      'Chargement de votre dernier résumé de présence.';

  @override
  String get attendanceUnavailableTitle => 'Présence non disponible';

  @override
  String get attendanceHeroSubtitle =>
      'Une lecture claire de votre taux de présence, des cours récents et de tout ce qui nécessite de l\'attention.';

  @override
  String get attendanceMetricRate => 'Taux';

  @override
  String get attendanceMetricPresent => 'Notes de présence';

  @override
  String get attendanceMetricLate => 'Notes de retard';

  @override
  String get attendanceMetricAbsent => 'Notes d\'absence';

  @override
  String attendanceHeroSignalBody(Object flag) {
    return '$flag. La pression de présence peut s\'accumuler tranquillement, donc cette vue se concentre sur ce qui a changé le plus récemment.';
  }

  @override
  String get attendanceNoSummary =>
      'Aucun résumé de présence n\'est disponible pour ce compte d\'étudiant pour l\'instant.';

  @override
  String get attendanceEmptyTitle => 'Pas encore de dossiers de présence';

  @override
  String get attendanceEmptySubtitle =>
      'Aucun dossier de présence n\'a été publié pour ce compte d\'étudiant pour l\'instant.';

  @override
  String get attendanceFiltersSubtitle =>
      'Utilisez le même style de sélecteur recherchable que celui des paramètres pour affiner l\'affichage de la présence par matière ou période.';

  @override
  String get attendanceTimeRangeLabel => 'Période';

  @override
  String get attendanceSearchRanges =>
      'Tout le temps / 7 jours / 30 jours / 90 jours';

  @override
  String get attendanceNoFilteredMarksTitle =>
      'Aucune note ne correspond à ces filtres';

  @override
  String get attendanceNoFilteredMarksSubtitle =>
      'Essayez toutes les matières ou une période plus large pour afficher davantage de notes de présence.';

  @override
  String get attendanceQuickReadTitle => 'Lecture rapide';

  @override
  String get attendanceQuickReadSubtitleFiltered =>
      'Un résumé rapide des notes de présence filtrées affichées ci-dessous.';

  @override
  String get attendanceQuickReadSubtitleAll =>
      'Un résumé rapide basé sur les derniers dossiers de présence disponibles.';

  @override
  String get attendanceSummaryConsistency => 'Cohérence';

  @override
  String get attendanceSummaryWatchFor => 'À surveiller';

  @override
  String get attendanceSummaryExcused => 'Notes excusées';

  @override
  String get attendanceSummaryMarksInView => 'Notes en vue';

  @override
  String get attendanceSummaryRateInView => 'Taux en vue';

  @override
  String get attendanceRecentDaysTitle => 'Jours récents';

  @override
  String get attendanceRecentDaysSubtitleFiltered =>
      'Regroupés par jour pour les notes filtrées actuellement en vue.';

  @override
  String get attendanceRecentDaysSubtitleAll =>
      'Regroupés par jour pour que vous puissiez détecter plus rapidement les absences ou les retards.';

  @override
  String get attendanceLessonCountSingle => '1 cours';

  @override
  String attendanceLessonCount(Object count) {
    return '$count cours';
  }

  @override
  String get attendanceStatusPresent => 'Présent';

  @override
  String get attendanceStatusLate => 'En retard';

  @override
  String get attendanceStatusAbsent => 'Absent';

  @override
  String get attendanceStatusExcused => 'Excusé';

  @override
  String get attendanceStatusRecorded => 'Enregistré';

  @override
  String get attendanceLessonFallback => 'Cours';

  @override
  String get attendanceRangeAll => 'Tout le temps';

  @override
  String get attendanceRange7 => '7 derniers jours';

  @override
  String get attendanceRange30 => '30 derniers jours';

  @override
  String get attendanceRange90 => '90 derniers jours';

  @override
  String get attendanceRangeAllShort => 'Tout le temps';

  @override
  String get attendanceRange7Short => '7 jours';

  @override
  String get attendanceRange30Short => '30 jours';

  @override
  String get attendanceRange90Short => '90 jours';

  @override
  String get gradesLoadError =>
      'Nous n\'avons pas pu charger les notes en ce moment. Tirez pour actualiser ou réessayez.';

  @override
  String get gradesLoadTimeout =>
      'Les notes prennent trop longtemps à charger. Tirez pour actualiser ou réessayez dans un instant.';

  @override
  String get gradesLoadNetwork =>
      'Les notes n\'ont pas pu se connecter en ce moment. Vérifiez votre connexion et réessayez.';

  @override
  String get gradesGeneralSubject => 'Général';

  @override
  String get gradesBandBuilding => 'En cours de construction';

  @override
  String get gradesBandExcellent => 'Excellent';

  @override
  String get gradesBandStrong => 'Fort';

  @override
  String get gradesBandOkay => 'Correct';

  @override
  String get gradesBandNeedsAttention => 'Demande de l\'attention';

  @override
  String get gradesBandRisk => 'À risque';

  @override
  String get gradesTrendRising => 'En hausse';

  @override
  String get gradesTrendDropping => 'En baisse';

  @override
  String get gradesTrendStable => 'Stable';

  @override
  String gradesShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return 'Affichage de $shown sur $total notes enregistrées pour $subject dans $range.';
  }

  @override
  String get gradesLoadingSubtitle =>
      'Chargement de vos derniers résultats académiques.';

  @override
  String get gradesUnavailableTitle => 'Notes indisponibles';

  @override
  String get gradesHeroSubtitle =>
      'Un aperçu clair de votre moyenne, des évaluations récentes et des matières nécessitant une protection ou une récupération.';

  @override
  String get gradesMetricAverage => 'Moyenne';

  @override
  String get gradesMetricRecorded => 'Enregistré';

  @override
  String get gradesMetricBestSubject => 'Meilleure matière';

  @override
  String get gradesMetricNeedsWork => 'Nécessite du travail';

  @override
  String gradesLatestSignalBody(
    Object assessment,
    Object subject,
    Object grade,
    Object band,
  ) {
    return '$assessment en $subject a obtenu $grade. $band en ce moment.';
  }

  @override
  String get gradesSummaryAvailableNoRecent =>
      'Un résumé des notes est disponible, mais aucune évaluation récente n\'est visible dans cette vue pour l\'instant.';

  @override
  String get gradesEmptyTitle => 'Pas encore de notes';

  @override
  String get gradesEmptySubtitle =>
      'Aucune note n\'a été publiée pour ce compte d\'étudiant pour l\'instant.';

  @override
  String get gradesFiltersSubtitle =>
      'Utilisez le même sélecteur consultable que dans les paramètres pour affiner les notes par matière ou période.';

  @override
  String get gradesNoFilteredTitle => 'Aucune note ne correspond à ces filtres';

  @override
  String get gradesNoFilteredSubtitle =>
      'Essayez toutes les matières ou une période plus large pour ramener plus de notes enregistrées.';

  @override
  String get gradesQuickReadTitle => 'Lecture rapide';

  @override
  String get gradesQuickReadSubtitleFiltered =>
      'Un résumé rapide des notes actuellement affichées.';

  @override
  String get gradesQuickReadSubtitleAll =>
      'La lecture la plus rapide de ce qu\'il faut protéger et récupérer.';

  @override
  String get gradesWeakSpotLabel => 'Point faible actuel';

  @override
  String get gradesNoWeakSignal => 'Pas encore de signal de matière faible';

  @override
  String gradesWeakSpotValue(Object subject) {
    return '$subject a besoin du premier bloc de récupération.';
  }

  @override
  String get gradesStrengthLabel => 'Force actuelle';

  @override
  String get gradesNoStrengthSignal => 'Pas encore de signal de matière forte';

  @override
  String gradesStrengthValue(Object subject) {
    return '$subject est votre point d\'ancrage de confiance en ce moment.';
  }

  @override
  String get gradesBandLabel => 'Bande';

  @override
  String get gradesInViewLabel => 'En vue';

  @override
  String gradesInViewCount(Object count) {
    return '$count notes enregistrées dans ce filtre.';
  }

  @override
  String gradesInViewAverage(Object count, Object average) {
    return '$count notes enregistrées avec une moyenne de $average.';
  }

  @override
  String get gradesLatestAssessmentsTitle => 'Dernières évaluations';

  @override
  String get gradesLatestAssessmentsSubtitleFiltered =>
      'Notes enregistrées les plus récentes dans la vue filtrée actuelle.';

  @override
  String get gradesLatestAssessmentsSubtitleAll =>
      'Notes enregistrées les plus récentes par ordre chronologique.';

  @override
  String get gradesSubjectDrilldownTitle => 'Détail de la matière';

  @override
  String get gradesSubjectDrilldownSubtitleFiltered =>
      'Regroupées par matière pour les notes actuellement affichées.';

  @override
  String get gradesSubjectDrilldownSubtitleAll =>
      'Regroupées par matière pour que la tendance et la pression ressortent plus rapidement.';

  @override
  String get gradesAssessmentFallback => 'Évaluation';

  @override
  String get gradesChipBest => 'Meilleur';

  @override
  String get gradesNoAverageYet => 'Pas de moyenne pour l\'instant';

  @override
  String gradesRecentAverage(Object average) {
    return 'Moyenne récente : $average';
  }

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionRemove => 'Retirer';

  @override
  String get actionBlock => 'Bloquer';

  @override
  String get actionCreate => 'Créer';

  @override
  String get actionShare => 'Partager';

  @override
  String get actionScheduleVerb => 'Planifier';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionKeep => 'Conserver';

  @override
  String get actionOpen => 'Ouvrir';

  @override
  String get actionPublish => 'Publier';

  @override
  String get actionPublishing => 'Publication en cours…';

  @override
  String get actionRefresh => 'Actualiser';

  @override
  String get msgBlockTitle => 'Bloquer cette personne ?';

  @override
  String get msgBlockContent =>
      'Elle ne pourra plus vous envoyer de messages et vous ne verrez plus les siens.';

  @override
  String get msgRenameGroup => 'Renommer le groupe';

  @override
  String get msgGroupName => 'Nom du groupe';

  @override
  String get msgMute => 'Muet';

  @override
  String get msgUnmute => 'Réactiver';

  @override
  String get msgInviteCode => 'Code d\'invitation';

  @override
  String get msgCopyCode => 'Copier le code';

  @override
  String get msgLeave => 'Quitter';

  @override
  String get msgInviteCodeCopied => 'Code d\'invitation copié';

  @override
  String msgCodeCopied(Object code) {
    return 'Code copié : $code';
  }

  @override
  String msgParticipantsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count participants ajoutés',
      one: '1 participant ajouté',
    );
    return '$_temp0';
  }

  @override
  String msgMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
    );
    return '$_temp0';
  }

  @override
  String get msgAdmin => 'Admin';

  @override
  String get msgRemoveFromGroup => 'Retirer du groupe';

  @override
  String get msgMakeAdmin => 'Nommer admin';

  @override
  String get msgRemoveAdmin => 'Retirer les droits admin';

  @override
  String get msgOnlyAdmin => 'Seul admin — promouvoir quelqu\'un d\'abord';

  @override
  String msgRemoveMemberTitle(Object name) {
    return 'Retirer $name ?';
  }

  @override
  String get msgNotificationsMuted => 'Notifications désactivées';

  @override
  String get msgNotificationsUnmuted => 'Notifications réactivées';

  @override
  String get msgJoinGroupTitle => 'Rejoindre un groupe';

  @override
  String get msgJoinGroupSubtitle =>
      'Entrez le code d\'invitation de l\'admin du groupe';

  @override
  String get examTitle => 'Examen';

  @override
  String get examNotFound => 'Examen introuvable';

  @override
  String get examStudyWithNova => 'Étudier avec NOVA';

  @override
  String get examOpenInsights => 'Ouvrir les analyses';

  @override
  String get examAddToCalendar => 'Ajouter au calendrier';

  @override
  String get examCouldNotOpenCalendar => 'Impossible d\'ouvrir le calendrier.';

  @override
  String get formTitle => 'Formulaire';

  @override
  String get formNotFound => 'Formulaire introuvable';

  @override
  String get formClosed => 'Ce formulaire est fermé.';

  @override
  String get formCompletion => 'Complétion';

  @override
  String get formNoTextResponses => 'Aucune réponse textuelle pour l\'instant.';

  @override
  String get meetingsCouldNotLoad => 'Impossible de charger les réunions';

  @override
  String get meetingCouldNotLoad => 'Impossible de charger la réunion';

  @override
  String get insightsGenerateAction => 'Générer des analyses';

  @override
  String get insightsRefreshAction => 'Actualiser';

  @override
  String get teacherGoToClassroom => 'Aller en classe';

  @override
  String get teacherMarkAttendance => 'Marquer les présences';

  @override
  String get teacherPostAssignment => 'Publier un devoir';

  @override
  String get teacherNewAnnouncementAction => 'Nouvelle annonce';

  @override
  String get teacherViewFullWeekSchedule => 'Voir le planning de la semaine';

  @override
  String get teacherGroupsLabel => 'Groupes';

  @override
  String get teacherTestsLabel => 'Tests';

  @override
  String get teacherAnnounceLabel => 'Annoncer';

  @override
  String get teacherTitleAndMessageRequired =>
      'Le titre et le message sont obligatoires';

  @override
  String get teacherAnnouncementPublished => 'Annonce publiée';

  @override
  String teacherFailedToPublish(Object error) {
    return 'Échec de la publication : $error';
  }

  @override
  String get teacherAnnouncementSectionTitle => 'Annonce';

  @override
  String get teacherAudienceSectionTitle => 'Audience';

  @override
  String get teacherPinAnnouncement => 'Épingler l\'annonce';

  @override
  String get teacherPinnedAtTop =>
      'Les annonces épinglées apparaissent en haut';

  @override
  String get teacherPublishAction => 'Publier';

  @override
  String get teacherPublishingAction => 'Publication en cours…';

  @override
  String get teacherAnnounceTitleLabel => 'Titre *';

  @override
  String get teacherAnnounceTitleHint => 'ex. Événement scolaire demain';

  @override
  String get teacherAnnounceMessageLabel => 'Message *';

  @override
  String get teacherAnnounceMessageHint => 'Rédigez l\'annonce complète ici…';

  @override
  String get teacherStudentsLabel => 'Élèves';

  @override
  String get teacherParentsLabel => 'Parents';

  @override
  String get teacherTeachersLabel => 'Enseignants';

  @override
  String get teacherWeekScheduleTitle => 'Planning de la semaine';

  @override
  String get teacherCouldNotLoadSchedule => 'Impossible de charger le planning';

  @override
  String get teacherAttendanceLast30 => 'Présences (30 derniers jours)';

  @override
  String get teacherRecentGrades => 'Notes récentes';

  @override
  String get teacherNoGradesRecorded =>
      'Aucune note enregistrée pour l\'instant';

  @override
  String get teacherGradeAvg => 'Moy. notes';

  @override
  String get teacherSubmittedLabel => 'Rendu';

  @override
  String get teacherAnalyticsTitle => 'Analyses';

  @override
  String get teacherGradeReports => 'Rapports de notes';

  @override
  String get teacherAvgLabel => 'moy.';

  @override
  String teacherBelow60(Object count) {
    return '$count en dessous de 60%';
  }

  @override
  String teacherGradedFraction(Object graded, Object total) {
    return '$graded/$total noté(s)';
  }

  @override
  String get teacherNoGradesEntered => 'Aucune note saisie pour l\'instant';

  @override
  String get teacherNewAssignment => 'Nouveau devoir';

  @override
  String get teacherDeleteAssignment => 'Supprimer le devoir ?';

  @override
  String get teacherDeleteAssignmentContent =>
      'Cela le supprimera pour tous les élèves.';

  @override
  String get teacherShareMaterialTitle => 'Partager le matériel';

  @override
  String get teacherRemoveMaterial => 'Retirer le matériel ?';

  @override
  String get teacherScheduleMeetingTitle => 'Planifier une réunion';

  @override
  String get teacherCancelMeetingTitle => 'Annuler la réunion ?';

  @override
  String get teacherCancelMeetingAction => 'Annuler la réunion';

  @override
  String get teacherJoinMeeting => 'Rejoindre la réunion';

  @override
  String get teacherAddStudentTitle => 'Ajouter un élève';

  @override
  String teacherRemoveStudentTitle(Object name) {
    return 'Retirer $name ?';
  }

  @override
  String get teacherRemoveStudentContent =>
      'Cet élève sera retiré de cette classe.';

  @override
  String get teacherStudentAdded => 'Élève ajouté';

  @override
  String get teacherClassroomAnalyticsTitle => 'Analyses de la classe';

  @override
  String get teacherOpenAnalyticsAction => 'Ouvrir les analyses';

  @override
  String teacherStudentsCount(Object count) {
    return 'Élèves ($count)';
  }

  @override
  String get teacherAssignmentLabel => 'Devoir';

  @override
  String get teacherShareMaterialLabel => 'Partager le matériel';

  @override
  String get teacherAttendanceRateLabel => 'Taux de présence';

  @override
  String get teacherSelectSessionPrompt =>
      'Sélectionnez une session ci-dessous pour commencer à marquer les présences';

  @override
  String get teacherOpenAction => 'Ouvrir';

  @override
  String get chatDeleteForMe => 'Supprimer pour moi';

  @override
  String get chatDeleteForEveryone => 'Supprimer pour tout le monde';

  @override
  String get chatMicNeeded => 'Accès au microphone requis';

  @override
  String get chatMicNeededBody =>
      'Veuillez autoriser l\'accès au microphone dans les Réglages pour envoyer des messages vocaux.';

  @override
  String get chatOpenSettings => 'Ouvrir les Réglages';

  @override
  String get chatCopied => 'Copié';

  @override
  String get chatCouldNotSendMedia => 'Impossible d\'envoyer le média.';

  @override
  String get chatCouldNotSendMessage => 'Impossible d\'envoyer le message.';

  @override
  String get chatCouldNotForward =>
      'Impossible de transférer les messages sélectionnés';

  @override
  String get chatSelectAll => 'Tout sélectionner';

  @override
  String get chatDeselectAll => 'Tout désélectionner';

  @override
  String get chatEditingMessage => 'Modification du message';

  @override
  String get chatEditPlaceholder => 'Modifier le message…';

  @override
  String get chatMessageHint => 'Message';

  @override
  String get chatPin => 'Épingler';

  @override
  String get chatUnpin => 'Désépingler';

  @override
  String get chatPhoto => 'Photo';

  @override
  String get chatVideo => 'Vidéo';

  @override
  String get chatMedia => 'Médias';

  @override
  String get chatAudioFile => 'Fichier audio';

  @override
  String get chatVideoFile => 'Fichier vidéo';

  @override
  String get chatAttachedFile => 'Fichier joint';

  @override
  String get chatFollowUp => 'Suite';

  @override
  String get chatCancelTooltip => 'Annuler';

  @override
  String get chatJoinGroup => 'Rejoindre le groupe';

  @override
  String get chatJoining => 'Connexion…';

  @override
  String get chatJoinGroupTooltip => 'Rejoindre un groupe par code';

  @override
  String get chatForwardNoChatAvailable =>
      'Aucune discussion approuvée disponible';

  @override
  String get chatFilterAll => 'Tous';

  @override
  String get novaDisclaimer =>
      'NOVA peut se tromper. Vérifiez les réponses importantes.';

  @override
  String get practiceCustomDisclaimer =>
      'Les sujets personnalisés sont générés par l\'IA à la volée. Les questions peuvent dériver hors sujet ou être inexactes pour des sujets de niche. Vérifiez les réponses inconnues de manière indépendante.';

  @override
  String get classroomsJoined => 'Vous avez rejoint la classe !';

  @override
  String get classroomsJoinAction => 'Rejoindre la classe';

  @override
  String get classroomsJoinTooltip => 'Rejoindre une classe';

  @override
  String get classroomsJoinTitle => 'Rejoindre une classe';

  @override
  String get classroomsJoinSubtitle =>
      'Entrez le code que votre enseignant vous a donné';

  @override
  String get classroomsCouldNotOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get classroomsReorderTitle => 'Réorganiser les classes';

  @override
  String get classroomsNoClassroomsToReorder => 'Aucune classe à réorganiser.';

  @override
  String get teacherPostAnnouncementAction => 'Publier une annonce';

  @override
  String get announcementAudienceEveryone => 'Tout le monde';

  @override
  String get teacherGreetingMorning => 'Bonjour';

  @override
  String get teacherGreetingAfternoon => 'Bon après-midi';

  @override
  String get teacherGreetingEvening => 'Bonsoir';

  @override
  String get teacherTodaysClasses => 'Cours d\'aujourd\'hui';

  @override
  String get teacherNoDate => 'Aucune date';

  @override
  String get teacherUpcomingTestsSubtitle => 'Prochains tests et contrôles';

  @override
  String get teacherNoClassesThisWeek => 'Aucun cours cette semaine';

  @override
  String get teacherNoClassesThisWeekSub =>
      'Votre emploi du temps de cette semaine est vide';

  @override
  String get teacherTitleFieldLabel => 'Titre *';

  @override
  String get teacherInstructionsLabel => 'Instructions';

  @override
  String get teacherLinkUrlLabel => 'Lien / URL *';

  @override
  String get teacherLinkUrlHint => 'https://...';

  @override
  String get teacherDescriptionLabel => 'Description';

  @override
  String get teacherMeetingTitleLabel => 'Titre de la réunion *';

  @override
  String get teacherMeetingLinkLabel => 'Lien de la réunion *';

  @override
  String get teacherMeetingLinkHint => 'Lien Zoom / Meet / Teams';

  @override
  String get teacherStudentEmailLabel => 'E-mail ou ID de l\'élève';

  @override
  String get teacherTooltipRemoveStudent => 'Retirer de la classe';

  @override
  String get teacherCouldNotLoad => 'Impossible de charger';

  @override
  String get teacherNoAssignmentsYet => 'Aucun devoir pour l\'instant';

  @override
  String get teacherNoAssignmentsSub =>
      'Appuyez sur + pour créer le premier devoir';

  @override
  String get teacherNoMaterialsYet => 'Aucun matériel pour l\'instant';

  @override
  String get teacherNoMaterialsSub =>
      'Partagez des liens, des documents ou des ressources avec votre classe';

  @override
  String get teacherNoMeetingsScheduled => 'Aucune réunion planifiée';

  @override
  String get teacherNoMeetingsSub =>
      'Appuyez sur + pour planifier une réunion de classe';

  @override
  String get teacherAttendanceOther => 'Autre';

  @override
  String get teacherTotal => 'Total';

  @override
  String get mediaOpenExternally => 'Ouvrir en externe';

  @override
  String get mediaUnableToLoad => 'Impossible de charger l\'image';

  @override
  String get searchHint => 'Rechercher...';

  @override
  String get teacherInsightsTitle => 'Aperçus des élèves';

  @override
  String get teacherInsightsSubtitle =>
      'Sélectionnez un élève pour voir ses informations académiques.';

  @override
  String get teacherInsightsNoStudents => 'Aucun élève trouvé.';

  @override
  String get teacherInsightsSearchHint => 'Rechercher des élèves…';
}

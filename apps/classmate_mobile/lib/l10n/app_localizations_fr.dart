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
  String get navSchedule => 'Agenda';

  @override
  String get navClassrooms => 'Classes';

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
  String get roleStudent => 'Élève';

  @override
  String get titleSchedule => 'Agenda';

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
      'Saisissez un numéro de page et de question pour filtrer, ou laissez vide pour tout afficher.';

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
  String get teacherAttendanceClassNotesLabel => 'Notes de cours';

  @override
  String get teacherAttendanceClassNotesHint =>
      'Ce qui a été couvert dans cette session…';

  @override
  String get teacherAttendanceSaving => 'Enregistrement…';

  @override
  String get teacherAttendanceSaveAll => 'Enregistrer la présence';

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
  String get scheduleSessionExpired =>
      'Votre session a expiré. Veuillez vous reconnecter.';

  @override
  String get scheduleNotOnboarded =>
      'Votre profil élève n\'est pas encore configuré. Demandez à l\'administrateur de votre école de vous affecter à une classe.';

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
  String get scheduleNotes => 'Notes';

  @override
  String get scheduleGoToClassroom => 'Aller à la classe';

  @override
  String get loginTitle => 'Connexion mobile pour élèves et enseignants';

  @override
  String get loginSubtitle =>
      'Les comptes enseignants ouvrent l\'espace enseignant. Les comptes élèves restent dans l\'expérience élève.';

  @override
  String get loginSignIn => 'Se connecter';

  @override
  String get loginWelcomeTitle => 'Bon retour';

  @override
  String get loginWelcomeSubtitle => 'Connectez-vous à votre compte ClassMate.';

  @override
  String get loginSigningIn => 'Connexion en cours...';

  @override
  String get loginEmailLabel => 'E-mail ou nom d\'utilisateur';

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
  String get profileMyCohorts => 'Mes cohortes';

  @override
  String get profileMyCohortsEmpty =>
      'Vous n\'êtes inscrit dans aucune cohorte pour le moment.';

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
  String get editProfileSchoolPublic => 'École visible';

  @override
  String get editProfileGradePublic => 'Niveau visible';

  @override
  String get editProfileMajors => 'Spécialités';

  @override
  String get editProfileMajorsPublic => 'Spécialités visibles';

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
  String get chatComposerReplyFallback => 'Répondre';

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
  String get chatComposerReleaseToCancel => 'Relâcher pour annuler';

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
  String get teacherDeleteClassroom => 'Supprimer la classe';

  @override
  String get teacherDeleteClassroomConfirm =>
      'Cette action supprime définitivement la classe ainsi que tout son chat, ses devoirs, ses supports, ses réunions et sa liste de membres. Action irréversible.';

  @override
  String get teacherClassroomDeleted => 'Classe supprimée';

  @override
  String get announcementsTabReceived => 'Reçues';

  @override
  String get announcementsTabPublished => 'Publiées';

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
  String get meetingsJoinReadyMetric => 'Rejoindre';

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
  String get teacherGradesFieldDate => 'Date (AAAA-MM-JJ)';

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
  String get assignmentsSubmitted => 'Rendu';

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
  String get gradesBandBuilding => 'En construction';

  @override
  String get gradesBandExcellent => 'Excellent';

  @override
  String get gradesBandStrong => 'Fort';

  @override
  String get gradesBandOkay => 'Correct';

  @override
  String get gradesBandNeedsAttention => 'À surveiller';

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
  String get formClosed => 'Fermé';

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
  String get teacherSearchStudents => 'Rechercher des élèves…';

  @override
  String get teacherNoStudentsLoaded => 'Aucun élève trouvé dans cette école.';

  @override
  String get teacherActions => 'ACTIONS RAPIDES';

  @override
  String get teacherParentsLabel => 'Parents';

  @override
  String get teacherTeachersLabel => 'Enseignants';

  @override
  String get teacherWeekScheduleTitle => 'Planning de la semaine';

  @override
  String get teacherCouldNotLoadSchedule => 'Impossible de charger le planning';

  @override
  String get teacherAttendanceLast30 => 'Présence (30 derniers jours)';

  @override
  String teacherAttendanceFrom(Object date) {
    return 'À partir du $date';
  }

  @override
  String get teacherAttendanceChangeDate => 'Changer la date';

  @override
  String get teacherAttendanceNoSessions =>
      'Aucune session de présence enregistrée.\nMarquez la présence depuis l\'emploi du temps.';

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
  String get teacherShareMaterialTitle => 'Partager une ressource';

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

  @override
  String get navDiplomas => 'Certificats';

  @override
  String get diplomasComingSoon => 'La gestion des diplômes arrive bientôt.';

  @override
  String get teacherExamsTitle => 'Examens';

  @override
  String get teacherExamsUpcoming => 'À venir';

  @override
  String get teacherExamsPast => 'Passés';

  @override
  String get teacherExamsEmpty =>
      'Aucune évaluation pour l\'instant. Appuyez sur + pour en créer une.';

  @override
  String teacherExamsGraded(Object count) {
    return '$count noté(s)';
  }

  @override
  String get teacherFormsTitle => 'Formulaires';

  @override
  String get teacherFormsEmpty =>
      'Aucun formulaire. Appuyez sur + pour en créer un.';

  @override
  String teacherFormsResponses(Object count) {
    return '$count réponses';
  }

  @override
  String get teacherFormsPublished => 'Publié';

  @override
  String get teacherFormsDraft => 'Brouillon';

  @override
  String get teacherFormsCreateTitle => 'Créer un formulaire';

  @override
  String get teacherFormsAddQuestion => 'Ajouter une question';

  @override
  String get teacherFormsQuestionHint => 'Texte de la question';

  @override
  String get teacherFormsViewResponses => 'Voir les réponses';

  @override
  String get teacherFormsNoResponses => 'Aucune réponse pour l\'instant.';

  @override
  String get diplomasTitle => 'Certificats';

  @override
  String get diplomasEmpty =>
      'Aucun certificat émis. Appuyez sur + pour en émettre un.';

  @override
  String get diplomasIssueTo => 'Émettre pour';

  @override
  String get diplomasStudentName => 'Nom de l\'élève';

  @override
  String get diplomasCertificateType => 'Type de certificat';

  @override
  String get diplomasIssueDiploma => 'Émettre le certificat';

  @override
  String diplomasIssuedOn(Object date) {
    return 'Émis le $date';
  }

  @override
  String get examDetailsSection => 'Détails';

  @override
  String get examInfoTeacher => 'Professeur';

  @override
  String get examInfoAudience => 'Audience';

  @override
  String get examInfoDate => 'Date';

  @override
  String get examInfoTime => 'Heure';

  @override
  String get examInfoPeriod => 'Période';

  @override
  String get examInfoDuration => 'Durée';

  @override
  String get examInfoSubject => 'Matière';

  @override
  String get examMaterialsSection => 'Documents joints';

  @override
  String get examNoMaterials => 'Aucun document joint pour l\'instant.';

  @override
  String get examQuickActionsSection => 'Actions rapides';

  @override
  String get examViewGradeTitle => 'Voir ta note';

  @override
  String get examViewGradeBody =>
      'Cet examen est terminé. Consultez l\'onglet notes pour ton résultat.';

  @override
  String get examViewGradeAction => 'Ouvrir les notes';

  @override
  String get teacherGradesSaveAction => 'Enregistrer';

  @override
  String get teacherGradesNothingToSave => 'Aucune modification à enregistrer.';

  @override
  String get teacherRetry => 'Réessayer';

  @override
  String get teacherExamGradesStudents => 'élèves';

  @override
  String get teacherExamGradesGraded => 'notés';

  @override
  String get teacherExamGradesNoStudents =>
      'Aucun élève ciblé.\nModifiez l\'examen pour ajouter un public.';

  @override
  String get teacherExamGradesEnterGrades => 'Saisir les notes';

  @override
  String get teacherDeleteExamTitle => 'Supprimer l\'examen ?';

  @override
  String get teacherDeleteExamBody =>
      'Cet examen sera définitivement supprimé.';

  @override
  String get teacherMeetingsEmpty =>
      'Aucune réunion pour l\'instant.\nAppuyez sur + pour en planifier une.';

  @override
  String get teacherStudentsNoMatch => 'Aucun élève ne correspond';

  @override
  String get teacherMaterialsTitle => 'Supports de cours';

  @override
  String get profileNamesTitle => 'Nom en langues';

  @override
  String get profileDisplayNameLang => 'Langue d\'affichage';

  @override
  String get navDashboard => 'Tableau de bord';

  @override
  String get navPeople => 'Utilisateurs';

  @override
  String get navCohorts => 'Cohortes';

  @override
  String get navSchool => 'École';

  @override
  String get adminDashboardTitle => 'Vue d\'ensemble de l\'école';

  @override
  String get adminStudents => 'Élèves';

  @override
  String get adminTeachers => 'Enseignants';

  @override
  String get adminParents => 'Parents';

  @override
  String get adminSecretaries => 'Secrétaires';

  @override
  String get adminAdmins => 'Administrateurs';

  @override
  String get adminTodaySessions => 'Sessions d\'aujourd\'hui';

  @override
  String get adminQuickActions => 'Actions rapides';

  @override
  String get adminAttendanceLast30 => 'Présence — 30 derniers jours';

  @override
  String get adminNoAttendanceData =>
      'Aucune donnée de présence pour les 30 derniers jours.';

  @override
  String get adminAddUser => 'Ajouter un utilisateur';

  @override
  String get adminCreateUser => 'Créer';

  @override
  String get adminFullName => 'Nom complet';

  @override
  String get adminEmailAddress => 'Adresse e-mail';

  @override
  String get adminRoleLabel => 'Rôle';

  @override
  String get adminUserCreated => 'Utilisateur créé';

  @override
  String get adminTempPassword => 'Mot de passe temporaire';

  @override
  String get adminCopied => 'Copié dans le presse-papiers';

  @override
  String get adminResetPassword => 'Réinitialiser le mot de passe';

  @override
  String get adminPasswordReset => 'Réinitialisation du mot de passe';

  @override
  String adminTempPasswordFor(Object name) {
    return 'Mot de passe temporaire pour $name';
  }

  @override
  String get adminDeleteUser => 'Supprimer l\'utilisateur';

  @override
  String adminDeleteUserConfirm(Object name) {
    return 'Supprimer $name ? Cette action est irréversible.';
  }

  @override
  String get adminDeleteCohort => 'Supprimer la cohorte';

  @override
  String adminDeleteCohortConfirm(Object name) {
    return 'Supprimer \"$name\" ? Toutes les adhésions d\'élèves seront supprimées.';
  }

  @override
  String get adminAddCohort => 'Ajouter une cohorte';

  @override
  String get adminNewCohort => 'Nouvelle cohorte';

  @override
  String get adminCohortName => 'Nom (ex. 10ème-2)';

  @override
  String get adminCohortGrade => 'Niveau';

  @override
  String get adminRenameCohort => 'Renommer';

  @override
  String get adminAddStudents => 'Ajouter des élèves';

  @override
  String adminAddTo(Object name) {
    return 'Ajouter à $name';
  }

  @override
  String get adminRemoveStudent => 'Retirer l\'élève';

  @override
  String adminRemoveStudentConfirm(Object name, Object cohort) {
    return 'Retirer $name de $cohort ?';
  }

  @override
  String get adminNoCohortsYet => 'Aucune cohorte pour l\'instant';

  @override
  String get adminNoStudentsInCohort => 'Aucun élève dans cette cohorte';

  @override
  String adminStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count élèves',
      one: '1 élève',
    );
    return '$_temp0';
  }

  @override
  String get adminSearchStudents => 'Rechercher des élèves…';

  @override
  String get adminScheduleTitle => 'Emploi du temps';

  @override
  String get adminScheduleAddPeriod => 'Ajouter une période';

  @override
  String get adminScheduleNewPeriod => 'Nouveau cours';

  @override
  String get adminScheduleDayLabel => 'Jour';

  @override
  String adminSchedulePeriodLabel(Object period) {
    return 'P$period';
  }

  @override
  String get adminScheduleTeacherLabel => 'Enseignant';

  @override
  String get adminScheduleNoneTeacher => 'Aucun enseignant';

  @override
  String get adminScheduleCohortLabel => 'Cohorte / Élèves';

  @override
  String get adminScheduleFrequencyLabel => 'Fréquence';

  @override
  String get adminScheduleFreqWeekly => 'Chaque semaine';

  @override
  String get adminScheduleFreqBiweekly => 'Toutes les 2 semaines';

  @override
  String get adminScheduleFreqMonthly => 'Toutes les 4 semaines';

  @override
  String get adminScheduleFreqCustom => 'Personnalisé';

  @override
  String adminScheduleFreqCustomLabel(int n) {
    return 'Toutes les $n semaines';
  }

  @override
  String get adminScheduleAddSlot => 'Ajouter un créneau';

  @override
  String get adminScheduleAddAnother => 'Ajouter un autre jour / cours';

  @override
  String get adminScheduleSave => 'Enregistrer';

  @override
  String get adminScheduleSearchTeacher => 'Rechercher des enseignants…';

  @override
  String get adminScheduleSearchCohort => 'Rechercher des cohortes…';

  @override
  String get adminScheduleSelectTeacher => 'Sélectionner un enseignant';

  @override
  String get adminScheduleSelectCohort => 'Sélectionner une cohorte';

  @override
  String get adminScheduleOrStudents =>
      'Ou choisir des élèves individuellement';

  @override
  String get adminScheduleNoSlots => 'Aucun cours pour l\'instant';

  @override
  String get adminScheduleNoSlotsHint =>
      'Appuyez sur + pour ajouter le premier cours';

  @override
  String get adminSchoolSettingsTitle => 'Paramètres de l\'école';

  @override
  String get adminSchoolName => 'Nom de l\'école';

  @override
  String get adminSchoolLogoUrl => 'URL du logo (optionnel)';

  @override
  String get adminSchoolLogoHint => 'https://…';

  @override
  String get adminSchoolSaved => 'Enregistré';

  @override
  String get adminSubjectsTitle => 'Matières';

  @override
  String adminSubjectsGrade(int grade) {
    return 'Niveau $grade';
  }

  @override
  String get adminSubjectsAddHint => 'Ajouter une matière…';

  @override
  String get adminSubjectsNoSubjects => 'Aucune matière configurée';

  @override
  String get adminSubjectsAdd => 'Ajouter';

  @override
  String get adminSubjectsRemove => 'Retirer';

  @override
  String get adminSettingsTitle => 'Paramètres';

  @override
  String get adminSettingsBellSchedule => 'Sonnerie';

  @override
  String get adminSettingsPeriodDefaults => 'Horaires par défaut';

  @override
  String get adminSettingsPeriodDefaultsSubtitle =>
      'Définir les horaires de chaque cours';

  @override
  String get adminDeleteConfirmCancel => 'Annuler';

  @override
  String get adminDeleteConfirmDelete => 'Supprimer';

  @override
  String get adminSave => 'Enregistrer';

  @override
  String get adminCancel => 'Annuler';

  @override
  String get adminSearchPeople => 'Rechercher par nom…';

  @override
  String adminNoResults(Object query) {
    return 'Aucun résultat pour \"$query\"';
  }

  @override
  String adminNoPeopleYet(Object role) {
    return 'Aucun $role pour l\'instant';
  }

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonDownload => 'Télécharger';

  @override
  String get commonOpenExternally => 'Ouvrir en externe';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDone => 'Terminé';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonSearch => 'Rechercher…';

  @override
  String get commonShare => 'Partager';

  @override
  String get commonLoading => 'Chargement…';

  @override
  String get commonError => 'Une erreur est survenue';

  @override
  String get commonTryAgain => 'Réessayer';

  @override
  String get studentMaterialsTitle => 'Ressources';

  @override
  String get studentMaterialsEmptyTitle =>
      'Aucune ressource partagée pour l\'instant';

  @override
  String get studentMaterialsEmptyHint =>
      'Votre enseignant partagera des ressources ici.';

  @override
  String get studentMaterialsLoadError =>
      'Impossible de charger les ressources';

  @override
  String get studentAssignmentSubmittedSnackbar => 'Devoir remis !';

  @override
  String get studentAssignmentSubmitFailed =>
      'Impossible de remettre — réessayez.';

  @override
  String get studentAssignmentUploadFailed =>
      'Échec de l\'envoi du fichier — réessayez.';

  @override
  String get studentAssignmentHandedInBadge => 'Remis';

  @override
  String get studentAssignmentSubmitButton => 'Remettre';

  @override
  String get studentAssignmentSubmitting => 'Envoi en cours…';

  @override
  String get studentAssignmentAttachFile => 'Joindre un fichier';

  @override
  String get studentAssignmentAddMoreFiles => 'Ajouter d\'autres fichiers';

  @override
  String get studentAssignmentYourSubmission => 'Votre remise';

  @override
  String get studentAssignmentTeacherAttachments => 'Pièces jointes';

  @override
  String secretaryWelcomeGreeting(Object name) {
    return 'Bonjour $name 👋';
  }

  @override
  String get secretaryYourTools => 'Vos outils';

  @override
  String get secretaryReports => 'Signalements';

  @override
  String get secretaryExportData => 'Exporter les données';

  @override
  String get secretaryHomeTile => 'Accueil';

  @override
  String parentHomeGreeting(Object name) {
    return 'Bonjour $name 👋';
  }

  @override
  String get parentYourTools => 'Vos outils';

  @override
  String get parentNoChildLinked => 'Aucun enfant lié pour l\'instant';

  @override
  String get parentPickChildFirst => 'Choisissez d\'abord un enfant';

  @override
  String get parentNoApprovedChildren =>
      'Aucun enfant approuvé pour l\'instant. Demandez à votre école de lier votre compte.';

  @override
  String get loginEmptyFieldsError =>
      'Veuillez saisir votre e-mail ou nom d\'utilisateur et votre mot de passe.';

  @override
  String get loginConnectionError =>
      'Pas de connexion. Vérifiez votre internet et réessayez.';

  @override
  String get loginTimeoutError => 'Délai de la requête dépassé. Réessayez.';

  @override
  String get loginForgotPasswordLink => 'Mot de passe oublié ?';

  @override
  String get forgotPasswordTitle => 'Réinitialiser votre mot de passe';

  @override
  String get forgotPasswordModeEmail => 'E-mail';

  @override
  String get forgotPasswordModeSms => 'SMS';

  @override
  String get forgotPasswordModeAdmin => 'Administrateur';

  @override
  String get forgotPasswordEmailSent =>
      'Lien de réinitialisation envoyé (si un compte correspond).';

  @override
  String get forgotPasswordEmptyError =>
      'Saisissez votre e-mail ou nom d\'utilisateur pour continuer.';

  @override
  String get forgotPasswordEmailButton => 'M\'envoyer un lien par e-mail';

  @override
  String get forgotPasswordSmsButton => 'M\'envoyer un lien par SMS';

  @override
  String get forgotPasswordLinkExpires =>
      'Le lien expire dans 1 heure et ne peut être utilisé qu\'une seule fois.';

  @override
  String get pushPermissionTitle => 'Restez informé';

  @override
  String get pushPermissionBody =>
      'Activez les notifications pour ne rien manquer des notes, messages ou changements d\'emploi du temps.';

  @override
  String commonRequiredField(Object field) {
    return '$field requis';
  }

  @override
  String get commonAttachments => 'Pièces jointes';

  @override
  String get commonAttachFile => 'Joindre un fichier';

  @override
  String get commonReplaceFile => 'Remplacer le fichier';

  @override
  String get commonTitleRequired => 'Titre requis';

  @override
  String get commonPublish => 'Publier';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonStart => 'Début';

  @override
  String get commonEnd => 'Fin';

  @override
  String get commonRefresh => 'Actualiser';

  @override
  String get commonRemove => 'Retirer';

  @override
  String get commonOpen => 'Ouvrir';

  @override
  String get commonView => 'Voir';

  @override
  String get commonCopy => 'Copier';

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get commonOptional => 'Optionnel';

  @override
  String get commonRequired => 'Obligatoire';

  @override
  String get commonAuto => 'Auto';

  @override
  String get teacherShareButton => 'Partager';

  @override
  String get teacherMaterialDetails => 'Détails de la ressource';

  @override
  String get teacherMaterialTitleLabel => 'Titre *';

  @override
  String get teacherMaterialDescriptionLabel => 'Description (optionnel)';

  @override
  String get teacherMaterialContentSection => 'Contenu';

  @override
  String get teacherMaterialContentRequired =>
      'Veuillez joindre un fichier ou ajouter un lien';

  @override
  String teacherFilePickError(Object error) {
    return 'Impossible de choisir le fichier : $error';
  }

  @override
  String get teacherScheduleButton => 'Planifier';

  @override
  String get teacherMeetingTitleField => 'Titre de la réunion *';

  @override
  String get teacherMeetingLinkField => 'Lien de la réunion *';

  @override
  String get teacherMeetingLinkRequired => 'Lien de la réunion requis';

  @override
  String get teacherMeetingTitleRequired => 'Titre de la réunion requis';

  @override
  String get teacherMeetingDateTimeRequired =>
      'Date et heure de début requises';

  @override
  String get teacherMeetingStartDate => 'Date de début *';

  @override
  String get teacherMeetingStartTime => 'Heure de début *';

  @override
  String get teacherMeetingEndDate => 'Date de fin (optionnel)';

  @override
  String get teacherMeetingEndTime => 'Heure de fin (optionnel)';

  @override
  String get teacherClearEndTime => 'Effacer l\'heure de fin';

  @override
  String get teacherAssignmentTitleField => 'Titre *';

  @override
  String get teacherAssignmentInstructions => 'Instructions (optionnel)';

  @override
  String get teacherAssignmentDueDate => 'Date d\'échéance (optionnel)';

  @override
  String get teacherAssignmentClearDueDate => 'Effacer la date d\'échéance';

  @override
  String get teacherAssignmentMaxGrade => 'Note maximale (optionnel)';

  @override
  String get teacherAssignmentPublished => 'Devoir publié.';

  @override
  String get teacherAssignmentDraftSaved => 'Brouillon enregistré.';

  @override
  String get teacherCreateAssignment => 'Créer';

  @override
  String get teacherExamSubject => 'Matière *';

  @override
  String get teacherExamDate => 'Date de l\'examen *';

  @override
  String get teacherSelectSubject => 'Choisir une matière';

  @override
  String get teacherNoSubjectOption => 'Aucune matière';

  @override
  String get teacherOtherSubjectOption => 'Autre';

  @override
  String get teacherSearchClassrooms => 'Rechercher des classes…';

  @override
  String get teacherSearchMaterials => 'Rechercher des ressources…';

  @override
  String get teacherClassroomName => 'Nom de la classe *';

  @override
  String get adminReportsOpenTab => 'Ouvert';

  @override
  String get adminReportsResolvedTab => 'Résolu';

  @override
  String get adminReportsDismissedTab => 'Rejeté';

  @override
  String get adminReportsNoOpen => 'Aucun signalement ouvert';

  @override
  String get adminReportsNoInView => 'Aucun signalement dans cette vue';

  @override
  String get adminReportsMediaAttachment => '[Pièce jointe média]';

  @override
  String get adminReportsEmptyMessage => '(message vide)';

  @override
  String get adminReportsDismiss => 'Rejeter';

  @override
  String get adminReportsResolve => 'Résoudre';

  @override
  String adminReportsReason(Object reason) {
    return 'Motif : $reason';
  }

  @override
  String get chatReportTitle => 'Signaler le message';

  @override
  String get chatReportButton => 'Signaler';

  @override
  String get chatReportSuccess =>
      'Signalé. Merci — un administrateur l\'examinera.';

  @override
  String chatReportFailed(Object error) {
    return 'Échec du signalement : $error';
  }

  @override
  String chatSendError(Object message) {
    return 'Impossible d\'envoyer : $message';
  }

  @override
  String chatForwardLabel(Object count) {
    return 'Transférer $count';
  }

  @override
  String chatDeleteLabel(Object count) {
    return 'Supprimer $count';
  }

  @override
  String chatSelectedCount(Object count) {
    return '$count sélectionné(s)';
  }

  @override
  String get adminPasswordReqEmpty => 'Aucune demande en attente';

  @override
  String get adminPasswordReqExplainer =>
      'Les utilisateurs que vous avez approuvés ou rejetés n\'apparaîtront pas ici. Les demandes en attente expirent après 24 heures.';

  @override
  String get adminPasswordReqApproveTitle =>
      'Approuver le changement de mot de passe ?';

  @override
  String adminPasswordReqApproveExplain(Object name) {
    return 'Cela définit le mot de passe de $name sur celui qu\'il a saisi (vous ne le voyez pas).';
  }

  @override
  String adminPasswordReqVerifyWarning(Object name) {
    return 'N\'approuvez que si vous avez vérifié que le demandeur est bien $name — appelez-le ou confirmez en personne. Toute personne connaissant un nom d\'utilisateur peut soumettre cette demande.';
  }

  @override
  String get adminPasswordReqConfirmApprove => 'J\'ai vérifié — approuver';

  @override
  String adminPasswordReqApproveSnackbar(Object name) {
    return 'Approuvé — $name peut se connecter maintenant.';
  }

  @override
  String get adminPasswordReqRejectTitle =>
      'Rejeter le changement de mot de passe ?';

  @override
  String adminPasswordReqRejectExplain(Object name) {
    return 'Le mot de passe de $name ne changera pas. Il pourra soumettre une nouvelle demande si nécessaire.';
  }

  @override
  String get adminPasswordReqRejectSnackbar => 'Rejeté.';

  @override
  String get adminPasswordReqRejectButton => 'Rejeter';

  @override
  String get adminPasswordReqApproveButton => 'Approuver';

  @override
  String get adminPasswordReqCardCopy =>
      'Souhaite changer son mot de passe. Le nouveau mot de passe est masqué.';

  @override
  String get adminPasswordReqCallTooltip => 'Appeler';

  @override
  String get adminPasswordReqSmsTooltip => 'SMS';

  @override
  String get adminSetupSchoolSetup => 'Configuration de l\'école';

  @override
  String get adminSetupComplete =>
      'Tout est prêt. Appuyez sur n\'importe quel élément pour le revoir ou l\'affiner.';

  @override
  String get adminSetupInstructions =>
      'Complétez ces étapes pour configurer entièrement votre école.';

  @override
  String get adminSetupLogoTitle => 'Téléverser le logo de l\'école';

  @override
  String get adminSetupLogoSubtitle =>
      'Apparaît dans les en-têtes et le menu latéral';

  @override
  String get adminSetupNameTitle => 'Définir le nom de l\'école';

  @override
  String get adminSetupNameSubtitle =>
      'Affiché aux élèves, enseignants et parents';

  @override
  String get adminSetupSubjectsTitle => 'Définir les matières';

  @override
  String get adminSetupSubjectsSubtitle =>
      'Au moins un niveau avec des matières configurées';

  @override
  String get adminSetupBellTitle => 'Définir les horaires';

  @override
  String get adminSetupBellSubtitle => 'Heures de début/fin de chaque cours';

  @override
  String get adminSetupCohortsTitle => 'Créer des groupes';

  @override
  String get adminSetupCohortsSubtitle => 'Configurez vos groupes de classe';

  @override
  String get adminSetupStudentsTitle => 'Ajouter des élèves';

  @override
  String get adminSetupStudentsSubtitle =>
      'Créez des comptes ou générez des codes d\'inscription';

  @override
  String get adminSetupTeachersTitle => 'Ajouter des enseignants';

  @override
  String get adminSetupTeachersSubtitle =>
      'Créez des comptes pour les enseignants';

  @override
  String get supportContactTitle => 'Parlez-nous';

  @override
  String get supportContactDescription =>
      'Vous ne trouvez pas votre réponse ci-dessous ? Contactez-nous et nous reviendrons vers vous dans la journée ouvrée.';

  @override
  String get supportEmailLabel => 'E-mail';

  @override
  String get supportPhoneLabel => 'Téléphone';

  @override
  String get supportSmsLabel => 'Message';

  @override
  String get aboutWhatIsClassmate => 'Qu\'est-ce que ClassMate ?';

  @override
  String get aboutClassmateDescription =>
      'ClassMate est le système d\'exploitation scolaire pour les élèves, enseignants, administrateurs et parents. Une seule application, quatre rôles, et chaque aspect de la journée d\'école au même endroit — emploi du temps, présence, notes, classes, devoirs, messagerie, et un assistant d\'étude IA.';

  @override
  String get aboutMultilingualTitle =>
      'Conçu pour les écoles qui parlent plus d\'une langue';

  @override
  String get aboutMultilingualDescription =>
      'Chaque nom, matière et annonce peut porter jusqu\'à cinq variantes linguistiques (anglais, arabe, hébreu, français, russe). Les élèves voient la langue avec laquelle ils sont le plus à l\'aise ; les enseignants gèrent dans la leur.';

  @override
  String get aboutPrivacyTitle => 'Confidentialité d\'abord';

  @override
  String get aboutPrivacyDescription =>
      'Les données de l\'école restent dans l\'école. Les rôles correspondent à ce que chacun peut voir — les enseignants voient leurs classes, les administrateurs voient leur école, les parents voient leurs enfants. Aucun traqueur tiers, aucun réseau publicitaire.';

  @override
  String get aboutContactTitle => 'Contact';

  @override
  String get aboutContactDescription =>
      'Conçu par Tony Aboud et l\'équipe ClassMate.\nQuestions : tony@classmateapp.org';

  @override
  String aboutVersionLabel(Object version) {
    return 'ClassMate · v$version';
  }

  @override
  String get adminAddStudent => 'Ajouter un élève';

  @override
  String get adminAddTeacher => 'Ajouter un enseignant';

  @override
  String get adminAddParent => 'Ajouter un parent';

  @override
  String get adminAddSecretary => 'Ajouter un secrétaire';

  @override
  String get adminAddAdmin => 'Ajouter un administrateur';

  @override
  String get adminEditUser => 'Modifier l\'utilisateur';

  @override
  String get adminNoEmailPlaceholder => '(aucun e-mail)';

  @override
  String get adminNameEnglishRequired =>
      'Le nom complet (en anglais) est requis';

  @override
  String get adminUsernameRequired => 'Le nom d\'utilisateur est requis';

  @override
  String get adminPasswordMinLength =>
      'Le mot de passe doit comporter au moins 8 caractères (ou laissez vide pour génération automatique)';

  @override
  String adminUserCreatedMsg(Object name) {
    return '$name créé(e).';
  }

  @override
  String get adminCredsUsername => 'Nom d\'utilisateur';

  @override
  String get adminCredsEmail => 'E-mail';

  @override
  String get adminCredsPassword => 'Mot de passe';

  @override
  String get adminShareCredsHint => 'Partagez ces identifiants avec l\'élève.';

  @override
  String get adminCopyCredsButton => 'Tout copier';

  @override
  String get adminGradeLabel => 'Niveau';

  @override
  String adminCohortGradeFormat(Object grade) {
    return 'Niveau $grade';
  }

  @override
  String get adminCreateAndAddStudents => 'Créer et ajouter des élèves';

  @override
  String get adminAddStudentsTitle => 'Ajouter des élèves';

  @override
  String get adminSkipAdding => 'Passer';

  @override
  String get adminInCohortBadge => 'Dans le groupe';

  @override
  String get adminNoStudentsFoundCohort =>
      'Aucun élève trouvé dans les niveaux de ce groupe';

  @override
  String get adminScheduleByCohort => 'Par groupe ▾';

  @override
  String get adminScheduleByStudent => 'Par élève ▾';

  @override
  String get adminScheduleByGrade => 'Par niveau ▾';

  @override
  String get navSupport => 'Assistance';

  @override
  String get navAbout => 'À propos';

  @override
  String get adminScheduleAddGrade => 'Ajouter un niveau';

  @override
  String get adminScheduleAddCohort => 'Ajouter un groupe';

  @override
  String get adminScheduleAddStudent => 'Ajouter un élève';

  @override
  String get adminScheduleClearFilters => 'Effacer';

  @override
  String get adminSchedulePickSubjectRequired =>
      'Choisissez une matière avant d\'enregistrer le créneau.';

  @override
  String get adminSchedulePickDateOnce =>
      'Choisissez une date pour un créneau ponctuel.';

  @override
  String adminSchedulePickDateRecurring(Object freq) {
    return 'Choisissez une date de début pour le planning toutes les $freq semaines.';
  }

  @override
  String get adminSchoolLogoLabel => 'Logo de l\'école';

  @override
  String get adminSchoolLogoUploaded => 'Logo téléversé';

  @override
  String get adminSchoolNoLogoYet => 'Pas encore de logo';

  @override
  String get adminSchoolLogoDescription =>
      'Apparaît à côté du nom de votre école dans le menu latéral.';

  @override
  String get adminSchoolLogoChange => 'Modifier';

  @override
  String get adminSchoolLogoUpload => 'Téléverser';

  @override
  String get adminSchoolLogoRemove => 'Retirer';

  @override
  String get adminSchoolGradeRangeLabel => 'Plage de niveaux';

  @override
  String get adminSchoolGradeRangeDescription =>
      'Niveaux disponibles dans les groupes, élèves et sélecteurs.';

  @override
  String get adminSchoolLowestGrade => 'Plus bas';

  @override
  String get adminSchoolHighestGrade => 'Plus haut';

  @override
  String get adminSchoolSubjectsTitle => 'Matières de l\'école';

  @override
  String get adminSchoolSubjectsDescription =>
      'Disponibles à tous les enseignants lors de la création de devoirs.';

  @override
  String get adminSchoolNoTranslations =>
      'Appuyez pour ajouter des traductions';

  @override
  String get adminSchoolBellHint =>
      'Définissez les heures de début et de fin de chaque créneau. Ajoutez ou retirez des créneaux selon les besoins.';

  @override
  String get adminSchoolBellTitle => 'Sonneries';

  @override
  String get adminSchoolBellInfo =>
      'Définissez l\'heure de début et de fin de chaque créneau. Ce sont les horaires par défaut utilisés lors de la construction de l\'emploi du temps hebdomadaire.';

  @override
  String get adminSchoolStartTime => 'Début';

  @override
  String get adminSchoolEndTime => 'Fin';

  @override
  String get adminExportStudentsTab => 'Élèves';

  @override
  String get adminExportCohortsTab => 'Groupes';

  @override
  String get adminExportGradesTab => 'Niveaux';

  @override
  String get adminExportOptionsTitle => 'Options d\'export';

  @override
  String get adminExportIncludePasswords => 'Inclure les mots de passe';

  @override
  String get adminExportLanguageLabel => 'Langue des noms dans l\'export';

  @override
  String get adminExportCsvButton => 'Exporter en CSV';

  @override
  String get adminExportPdfButton => 'Exporter en PDF';

  @override
  String get teacherCreateClassroomTooltip => 'Créer une classe';

  @override
  String get teacherClassroomNameRequired => 'Nom de la classe *';

  @override
  String get teacherSubjectRequired => 'Matière *';

  @override
  String messagesStartChatError(Object error) {
    return 'Impossible de démarrer la conversation : $error';
  }

  @override
  String messagesNoPeopleMatch(Object query) {
    return 'Aucune personne ne correspond à « $query »';
  }

  @override
  String get messagesNoPeopleFound => 'Aucune personne trouvée';

  @override
  String messagesPeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
    );
    return '$_temp0';
  }

  @override
  String get studentAssignmentValidationRequired =>
      'Ajoutez une note ou joignez un fichier avant de remettre.';

  @override
  String get studentFormSubmittedBanner => 'Vos réponses soumises';

  @override
  String studentFormSubmitError(Object error) {
    return 'Impossible de soumettre : $error';
  }

  @override
  String studentFormFieldRequired(Object field) {
    return 'Requis : $field';
  }

  @override
  String get studentFormClosedButton => 'Formulaire fermé';

  @override
  String get studentFormAlreadySubmittedButton => 'Déjà soumis';

  @override
  String get studentDiplomaEditTitle => 'Modifier le certificat';

  @override
  String get studentDiplomaDeleteTitle => 'Supprimer le certificat ?';

  @override
  String studentDiplomaDeleteConfirm(Object name) {
    return 'Retirer le certificat de « $name » ?';
  }

  @override
  String teacherDeleteItemConfirm(Object title) {
    return 'Supprimer « $title » ?';
  }

  @override
  String get teacherPublishTooltip => 'Publier';

  @override
  String get teacherMeetingEnterTitle => 'Veuillez saisir un titre.';

  @override
  String get teacherMeetingEnterLink => 'Veuillez saisir un lien de réunion.';

  @override
  String get teacherMeetingEnterValidUrl =>
      'Veuillez saisir une URL valide (ex. https://zoom.us/j/...)';

  @override
  String get teacherMeetingPickStartTime =>
      'Veuillez choisir une heure de début.';

  @override
  String get teacherMeetingVisibleToEveryone => 'Visible par tous';

  @override
  String teacherMeetingDoneCount(int count) {
    return 'Terminé ($count sélectionné(s))';
  }

  @override
  String get teacherDeleteAssignmentTitle => 'Supprimer le devoir ?';

  @override
  String get teacherDeleteAssignmentBody =>
      'Cela supprimera définitivement le devoir et toutes les remises.';

  @override
  String get teacherEditTooltip => 'Modifier';

  @override
  String get teacherDeleteTooltip => 'Supprimer';

  @override
  String get teacherClassroomBackTooltip => 'Retour';

  @override
  String teacherClassroomGenericError(Object error) {
    return 'Erreur : $error';
  }

  @override
  String teacherClassroomAttachFailed(Object error) {
    return 'Échec de la pièce jointe : $error';
  }

  @override
  String get teacherClassroomFileUnavailable =>
      'Ce fichier n\'est pas disponible — l\'enseignant doit le réimporter.';

  @override
  String get teacherClassroomCodeLabel => 'Code de la classe';

  @override
  String get teacherClassroomCodeCopied => 'Code copié';

  @override
  String get teacherClassroomCopyCodeTooltip => 'Copier le code';

  @override
  String teacherClassroomCouldNotAdd(Object emails) {
    return 'Impossible d\'ajouter : $emails — vérifiez leur adresse e-mail.';
  }

  @override
  String get teacherClassroomAddStudents => 'Ajouter des élèves';

  @override
  String get teacherClassroomSearchNameGrade => 'Rechercher par nom ou niveau…';

  @override
  String get teacherClassroomNoStudentsFound => 'Aucun élève trouvé';

  @override
  String get teacherClassroomNameSubjectRequired =>
      'Le nom et la matière sont requis.';

  @override
  String get teacherClassroomCreated => 'Classe créée !';

  @override
  String get teacherCustomSubjectLabel => 'Matière personnalisée *';

  @override
  String get teacherCreateClassroomButton => 'Créer une classe';

  @override
  String get teacherCreateFormTitle => 'Créer un formulaire';

  @override
  String get teacherFormSaveDraft => 'Enregistrer un brouillon';

  @override
  String get teacherFormTitleHint => 'Titre du formulaire *';

  @override
  String get teacherFormDescriptionHint => 'Description (optionnel)';

  @override
  String get teacherFormAcceptingResponses => 'Accepte les réponses';

  @override
  String get teacherFormAllowMultiple => 'Autoriser plusieurs réponses';

  @override
  String get teacherFormAllowMultipleSubtitle =>
      'Désactivé = une fois par élève (par défaut)';

  @override
  String get teacherFormQuestionsSection => 'Questions';

  @override
  String get teacherFormAddQuestionButton => 'Ajouter une question';

  @override
  String teacherFormQuestionPlaceholder(Object index) {
    return 'Question $index';
  }

  @override
  String get teacherFormRequiredToggle => 'Obligatoire';

  @override
  String get teacherFormAddOptionButton => 'Ajouter une option';

  @override
  String get teacherFormMinLabel => 'Min';

  @override
  String get teacherFormMaxLabel => 'Max';

  @override
  String get teacherFormEnterTitle => 'Veuillez saisir un titre de formulaire.';

  @override
  String teacherExamUploadFailedSkipped(Object name) {
    return 'Échec de l\'envoi de $name. Fichier ignoré.';
  }

  @override
  String get teacherExamEnterTitle => 'Veuillez saisir un titre.';

  @override
  String get teacherExamPickDate => 'Veuillez choisir une date d\'examen.';

  @override
  String get teacherExamSelectSubject => 'Veuillez choisir une matière.';

  @override
  String teacherSlotDetachFailed(Object error) {
    return 'Échec du détachement : $error';
  }

  @override
  String teacherSlotAttachFailed(Object error) {
    return 'Échec de la pièce jointe : $error';
  }

  @override
  String get teacherSlotAttachMaterial => 'Joindre une ressource';

  @override
  String get teacherSlotDetachTooltip => 'Détacher';

  @override
  String get teacherDiplomaSelectStudent => 'Sélectionnez d\'abord un élève.';

  @override
  String get teacherDiplomaUploadingWait =>
      'Veuillez patienter — les fichiers sont encore en cours d\'envoi.';

  @override
  String teacherDiplomaIssueFailed(Object error) {
    return 'Impossible de délivrer le certificat : $error';
  }

  @override
  String get teacherDiplomaCertTitleLabel => 'Titre du certificat';

  @override
  String get teacherDiplomaSearchStudent => 'Rechercher un élève…';

  @override
  String get teacherProfileChatError =>
      'Impossible de démarrer la conversation';

  @override
  String get teacherGradeAssignmentType => 'Devoir';

  @override
  String get teacherGradeExamType => 'Examen';

  @override
  String get teacherGradeOtherType => 'Autre';

  @override
  String get teacherGradeOutOfLabel => 'Sur (optionnel)';

  @override
  String get teacherGradePublishedTitle => 'Publiée';

  @override
  String get teacherGradePublishedSubtitle => 'Les élèves voient cette note';

  @override
  String get teacherMaterialPickSubject => 'Veuillez choisir une matière.';

  @override
  String get teacherMaterialAddLink => 'Ajouter un lien';

  @override
  String get teacherMaterialAddFile => 'Ajouter un fichier';

  @override
  String get teacherMaterialSearchStudentsGrade =>
      'Rechercher des élèves ou un niveau...';

  @override
  String teacherMaterialDoneSelected(int count) {
    return 'Terminé ($count sélectionné(s))';
  }

  @override
  String get adminSubjectEnglishNameRequired => 'Le nom en anglais est requis';

  @override
  String adminSubjectNameInLang(Object language) {
    return 'Nom en $language';
  }

  @override
  String get adminSubjectResetButton => 'Réinitialiser';

  @override
  String get teacherAnnounceBroadcastTitle => 'Diffuser à tout le monde ?';

  @override
  String get teacherAnnounceSendToEveryone => 'Envoyer à tous';

  @override
  String get teacherAnnounceNoCohorts => 'Aucun groupe disponible';

  @override
  String get teacherAnnounceNothingFound => 'Rien trouvé';

  @override
  String get teacherAnnounceNoParents =>
      'Aucun parent trouvé dans cette école.';

  @override
  String get teacherGradesToGrade => 'À noter';

  @override
  String get teacherGradesGraded => 'Notée';

  @override
  String get teacherSaveGradesButton => 'Enregistrer les notes';

  @override
  String get teacherAllowResubmitLabel => 'Autoriser la re-soumission';

  @override
  String get teacherAllowResubmitTitle => 'Autoriser la re-soumission ?';

  @override
  String teacherAllowResubmitBody(Object name) {
    return 'Cela supprimera la remise de $name pour qu\'il puisse remettre à nouveau.';
  }

  @override
  String get teacherAllowButton => 'Autoriser';

  @override
  String get teacherGradeFieldLabel => 'Note';

  @override
  String get teacherFeedbackOptionalLabel => 'Commentaire (optionnel)';

  @override
  String get teacherCreateClassroomFabLabel => 'Créer';

  @override
  String get teacherLoadingStudents => 'Chargement des élèves…';

  @override
  String get teacherSearchHintShort => 'Rechercher…';

  @override
  String get teacherCreateClassroomTitle => 'Nouvelle classe';

  @override
  String teacherAssignmentUploadFailed(Object name) {
    return 'Impossible d\'envoyer $name';
  }

  @override
  String get teacherAssignmentEnterTitle => 'Veuillez saisir un titre.';

  @override
  String get teacherAssignmentSelectSubject => 'Veuillez choisir une matière.';

  @override
  String get teacherAssignmentInstructionsLabel => 'Instructions / Description';

  @override
  String get teacherAttachFilesButton => 'Joindre des fichiers';

  @override
  String get tutorDeleteConversationTitle => 'Supprimer la conversation ?';

  @override
  String get tutorDeleteConversationButton => 'Supprimer définitivement';

  @override
  String tutorDeleteFailed(Object error) {
    return 'Impossible de supprimer : $error';
  }

  @override
  String get tutorDeleteMenuTitle => 'Supprimer la conversation';

  @override
  String get tutorDeleteMenuSubtitle => 'La supprime définitivement du serveur';

  @override
  String get accountVerifyButton => 'Vérifier';

  @override
  String get accountConfirmButton => 'Confirmer';

  @override
  String get accountResendCode => 'Renvoyer le code';

  @override
  String get accountCodeResent => 'Nouveau code envoyé.';

  @override
  String get accountContinueButton => 'Continuer';

  @override
  String get studentClassroomFileUnavailable =>
      'Ce fichier n\'est pas encore disponible.';

  @override
  String get studentClassroomDeleteMaterial => 'Supprimer la ressource ?';

  @override
  String get studentClassroomCodeLabel => 'Code de la classe';

  @override
  String get studentClassroomLeaveTooltip => 'Quitter la classe';

  @override
  String get adminEditUserEnglishNameRequired => 'Le nom en anglais est requis';

  @override
  String get adminEditUserSaved => 'Enregistré';

  @override
  String adminEditUserPasswordChanged(Object name) {
    return 'Mot de passe de $name modifié.';
  }

  @override
  String get adminEditUserLoginSection => 'Connexion';

  @override
  String get adminEditUserUsernameLabel => 'Nom d\'utilisateur';

  @override
  String get adminEditUserEmailOptional => 'E-mail (optionnel)';

  @override
  String get adminEditUserChangePassword => 'Changer le mot de passe';

  @override
  String get adminEditUserNameSection => 'Nom';

  @override
  String get adminEditUserAtLeastEnglish => 'L\'anglais est au moins requis.';

  @override
  String get adminEditUserGradeSection => 'Niveau';

  @override
  String get adminEditUserCohortsSection => 'Groupes';

  @override
  String get adminEditUserLinkedChildren => 'Enfants liés';

  @override
  String get adminEditUserLinkButton => 'Lier';

  @override
  String get adminEditUserNoChildren => 'Aucun enfant lié pour l\'instant.';

  @override
  String get adminEditUserSetPasswordTitle => 'Définir un nouveau mot de passe';

  @override
  String get adminEditUserNewPasswordLabel => 'Nouveau mot de passe';

  @override
  String get adminEditUserConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get adminEditUserSetPasswordButton => 'Définir le mot de passe';

  @override
  String get adminPeriodsTitle => 'Gérer les créneaux';

  @override
  String get adminPeriodsAddPeriod => 'Ajouter un créneau';

  @override
  String get adminPeriodsNoPeriods => 'Aucun créneau pour l\'instant';

  @override
  String get adminPeriodsTapToAdd =>
      'Appuyez sur + pour ajouter le premier créneau';

  @override
  String get adminPeriodsNewPeriod => 'Nouveau créneau';

  @override
  String get adminPeriodsDayLabel => 'Jour';

  @override
  String get adminPeriodsPeriodLabel => 'Créneau';

  @override
  String get adminPeriodsTimeLabel => 'Heure';

  @override
  String get adminPeriodsTeacherLabel => 'Enseignant';

  @override
  String get adminPeriodsClassroomOptional => 'Classe (optionnel)';

  @override
  String get adminPeriodsCohortsLabel => 'Groupes';

  @override
  String get adminPeriodsStudentsOptional => 'Élèves (optionnel)';

  @override
  String get adminPeriodsSearchByName => 'Rechercher par nom…';

  @override
  String commonErrorWith(Object error) {
    return 'Erreur : $error';
  }

  @override
  String commonAddCount(int count) {
    return 'Ajouter $count';
  }

  @override
  String get teacherStudentGradesSaved => 'Notes enregistrées';

  @override
  String get teacherStudentToGrade => 'À noter';

  @override
  String get teacherStudentGraded => 'Noté';

  @override
  String get classroomFileNotAvailable =>
      'Ce fichier n\'est pas encore disponible.';

  @override
  String get classroomDeleteMaterialTitle => 'Supprimer le document ?';

  @override
  String get classroomCodeLabel => 'Code de classe';

  @override
  String get plansCouldNotOpenSubscription =>
      'Impossible d\'ouvrir les paramètres d\'abonnement.';

  @override
  String plansFailedToOpen(Object error) {
    return 'Échec de l\'ouverture : $error';
  }

  @override
  String get plansManageSubscription => 'Gérer ou annuler l\'abonnement';

  @override
  String get plansUpgrade => 'Améliorer';

  @override
  String get plansTryAgain => 'Réessayer';

  @override
  String adminCohortsGradeOnly(String grade) {
    return 'Niveau $grade uniquement';
  }

  @override
  String adminCohortsGradeRangeOnly(int from, int to) {
    return 'Niveaux $from-$to uniquement';
  }

  @override
  String get adminExportNeedStudents =>
      'Sélectionnez d\'abord au moins un élève ou un groupe';

  @override
  String adminExportButton(int count) {
    return 'Exporter $count';
  }

  @override
  String get adminExportNoStudents => 'Aucun élève trouvé';

  @override
  String get adminExportIncludesPasswords =>
      'L\'exportation inclura les mots de passe';

  @override
  String get adminExportAnyway => 'Exporter quand même';

  @override
  String get adminExportPdfStudentDirectory => 'Annuaire des élèves';

  @override
  String adminExportPdfBy(String name) {
    return 'Par : $name';
  }

  @override
  String adminExportPdfStudentsCount(int count) {
    return '$count élèves';
  }

  @override
  String get adminExportPdfFooter => 'Généré par ClassMate';

  @override
  String get adminExportColumnIndex => '#';

  @override
  String get adminExportColumnName => 'Nom';

  @override
  String get adminExportColumnEmail => 'E-mail';

  @override
  String get adminExportColumnUsername => 'Nom d\'utilisateur';

  @override
  String get adminExportColumnPhone => 'Téléphone';

  @override
  String get adminExportColumnGrade => 'Niveau';

  @override
  String get adminExportColumnCohorts => 'Groupes';

  @override
  String get adminExportColumnSchool => 'École';

  @override
  String get adminExportColumnPassword => 'Mot de passe';

  @override
  String get adminExportColumnNameEn => 'Nom (EN)';

  @override
  String get adminExportColumnNameAr => 'Nom (AR)';

  @override
  String get adminExportColumnNameHe => 'Nom (HE)';

  @override
  String get adminExportColumnNameFr => 'Nom (FR)';

  @override
  String get adminExportColumnNameRu => 'Nom (RU)';

  @override
  String adminExportStudentsSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count élèves sélectionnés',
      one: '$count élève sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get teacherMaterialEditTitle => 'Modifier le document';

  @override
  String get teacherMaterialAddTitle => 'Ajouter un document';

  @override
  String get teacherMaterialAudienceTitle => 'Audience';

  @override
  String get teacherMaterialAudienceClassrooms => 'Classes';

  @override
  String get teacherMaterialAudienceCohorts => 'Groupes';

  @override
  String get teacherMaterialAudienceGrades => 'Niveaux';

  @override
  String get teacherMaterialAudienceStudents => 'Élèves';

  @override
  String get teacherMaterialDetailsTitle => 'Détails';

  @override
  String get teacherMaterialSubjectRequired => 'Matière *';

  @override
  String get teacherMaterialSubjectSelect => 'Sélectionner une matière';

  @override
  String get teacherMaterialSubjectOther => 'Autre';

  @override
  String get teacherMaterialSubjectSearch => 'Rechercher des matières...';

  @override
  String get teacherMaterialAttachmentsTitle => 'Pièces jointes';

  @override
  String teacherMaterialAttachmentsWithCount(int count) {
    return 'Pièces jointes ($count)';
  }

  @override
  String get teacherMaterialDeleteTitle => 'Supprimer le document ?';

  @override
  String get teacherMaterialListTitle => 'Documents';

  @override
  String teacherMaterialTotalCount(int count) {
    return '$count au total';
  }

  @override
  String get teacherMaterialRetry => 'Réessayer';

  @override
  String get teacherMaterialNoMaterials =>
      'Aucun document pour l\'instant.\nAppuyez sur + pour en ajouter un.';

  @override
  String get teacherMaterialPublished => 'Publié';

  @override
  String get teacherMaterialDraft => 'Brouillon';

  @override
  String get teacherMaterialSearchHint => 'Rechercher…';

  @override
  String teacherMaterialSelectedCount(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String teacherMaterialMembersWillReceive(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres recevront ceci',
      one: '$count membre recevra ceci',
    );
    return '$_temp0';
  }

  @override
  String teacherMaterialStudentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count élèves',
      one: '$count élève',
    );
    return '$_temp0';
  }

  @override
  String get teacherMaterialPickerNone => 'Aucun';

  @override
  String get teacherMaterialPickerCohortsTitle => 'Sélectionner les groupes';

  @override
  String get teacherMaterialPickerClassroomTitle => 'Sélectionner la classe';

  @override
  String get teacherMaterialPickerStudentsTitle => 'Sélectionner les élèves';

  @override
  String get teacherMaterialPickerGradesTitle => 'Sélectionner les niveaux';

  @override
  String get adminScheduleAddNew => 'Ajouter';

  @override
  String adminScheduleAddCount(int count) {
    return 'Ajouter ($count)';
  }

  @override
  String get adminScheduleCaptionOptional => 'Légende (optionnel)';

  @override
  String get adminScheduleCaptionHint => 'ex. Révision d\'examen';

  @override
  String get adminScheduleAudienceCohorts => 'Groupes';

  @override
  String get adminScheduleAudienceStudents => 'Élèves';

  @override
  String get adminScheduleAudienceGrade => 'Niveau';

  @override
  String get adminScheduleSearchStudents => 'Rechercher des élèves…';

  @override
  String get adminScheduleSearchSubjects => 'Rechercher des matières…';

  @override
  String get adminScheduleEveryPrefix => 'Toutes les ';

  @override
  String get adminScheduleWeeksSuffix => ' semaines';

  @override
  String adminScheduleSlotN(int index) {
    return 'Créneau $index';
  }

  @override
  String adminScheduleSelectedCount(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String get adminScheduleConflictingPeriod => 'Période en conflit';

  @override
  String get adminScheduleKeepCurrent => 'Garder l\'actuel';

  @override
  String get adminScheduleOverride => 'Remplacer';

  @override
  String get adminScheduleShowBoth => 'Afficher les deux';

  @override
  String get adminScheduleDeletePeriodTitle => 'Supprimer la période ?';

  @override
  String get adminScheduleDeletePeriodBody =>
      'Cela retire le créneau du planning. Les présences passées restent.';

  @override
  String get adminScheduleFailedToDelete =>
      'Échec de la suppression de la période.';

  @override
  String get adminSchedulePickSubjectFirst =>
      'Choisissez une matière avant d\'enregistrer la période.';

  @override
  String adminScheduleOverrideFailed(Object error) {
    return 'Échec du remplacement : $error';
  }

  @override
  String get adminScheduleFailedToCreateSlots =>
      'Échec de la création des créneaux';

  @override
  String adminScheduleCreatedSlots(int created, int total, String error) {
    return '$created/$total créneaux créés. $error';
  }

  @override
  String adminScheduleSavedLabelOnlyError(Object error) {
    return 'Enregistré comme étiquette uniquement — impossible d\'ajouter à la bibliothèque : $error';
  }

  @override
  String get adminScheduleSavedLabelPickAudience =>
      'Enregistré comme étiquette. Choisissez d\'abord une audience pour ajouter aussi à la bibliothèque de l\'école.';

  @override
  String get commonNothingFound => 'Rien trouvé';

  @override
  String commonDownloadFailed(Object error) {
    return 'Échec du téléchargement : $error';
  }

  @override
  String commonFailedWith(Object error) {
    return 'Échec : $error';
  }

  @override
  String get commonCreate => 'Créer';

  @override
  String get commonAttachStudyMaterials => 'Joindre des supports de cours';

  @override
  String get teacherCreateClassroomNewTitle => 'Nouvelle classe';

  @override
  String get teacherCreateClassroomLoadingStudents => 'Chargement des élèves…';

  @override
  String get teacherExamPublishedHint =>
      'Publié — les élèves peuvent voir cet examen';

  @override
  String teacherDoneSelected(int count) {
    return 'Terminé ($count sélectionné(s))';
  }

  @override
  String get secretaryAllCohorts => 'Tous les groupes';

  @override
  String get secretaryClassrooms => 'Classes';

  @override
  String get adminPasswordReqTitle => 'Demandes de mot de passe';

  @override
  String get adminPasswordReqBlurb =>
      'Utilisateurs de votre établissement qui demandent votre approbation pour changer leur mot de passe.';

  @override
  String adminPasswordReqWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count utilisateurs en attente de votre approbation.',
      one: '1 utilisateur en attente de votre approbation.',
    );
    return '$_temp0';
  }

  @override
  String get adminPasswordReqWantsChange =>
      'Souhaite changer son mot de passe. Le nouveau mot de passe est caché.';

  @override
  String get adminPasswordReqReject => 'Refuser';

  @override
  String get adminPasswordReqApprove => 'Approuver';

  @override
  String get adminPeopleGrade => 'Niveau';

  @override
  String get adminSchoolSettingsTapToAddTranslations =>
      'Toucher pour ajouter des traductions';

  @override
  String adminSchoolSettingsAddPeriodNum(int num) {
    return 'Ajouter une période (P$num)';
  }

  @override
  String get adminVisibleToEveryone => 'Visible par tous';

  @override
  String get navMaterials => 'Supports de cours';

  @override
  String get navPlans => 'Forfaits NOVA';

  @override
  String get navReports => 'Signalements';

  @override
  String get navExportData => 'Exporter les données';

  @override
  String get navPasswordRequests => 'Demandes de mot de passe';

  @override
  String get sectionSecretaryTools => 'Outils du secrétariat';

  @override
  String get sectionSchoolToolsLabel => 'Outils de l\'école';

  @override
  String get sectionAdminTools => 'Outils d\'administration';

  @override
  String get chatVideoTrimTitle => 'Rogner la vidéo';

  @override
  String get chatMediaPreviewTrimAction => 'Rogner';

  @override
  String get commonUntitled => 'Sans titre';

  @override
  String get plansMonthlyPlans => 'Forfaits mensuels';

  @override
  String get plansTokenTopups => 'Recharges de jetons';

  @override
  String get plansTopupsSubtitle =>
      'Achats uniques. Sans expiration. Cumulables avec votre forfait.';

  @override
  String get plansCouldntLoadBalance => 'Impossible de charger votre solde';

  @override
  String get plansFreePlan => 'Forfait gratuit';

  @override
  String get planTierFree => 'Gratuit';

  @override
  String get planTierBudget => 'Économique';

  @override
  String get planTierBalance => 'Équilibré';

  @override
  String get planTierCommitment => 'Engagement';

  @override
  String get topupPackSmall => 'Petit pack';

  @override
  String get topupPackMedium => 'Pack moyen';

  @override
  String get topupPackLarge => 'Grand pack';

  @override
  String get topupPackMega => 'Méga pack';

  @override
  String get planBlurbFree => 'Découvrez NOVA. Renouvellement mensuel.';

  @override
  String get planBlurbBudget => 'Aide quotidienne aux devoirs.';

  @override
  String get planBlurbBalance => 'Pour les élèves qui étudient tous les jours.';

  @override
  String get planBlurbCommitment => 'Pratique intensive + curiosité illimitée.';

  @override
  String plansTokensPerMonth(String tokens) {
    return '$tokens jetons / mois';
  }

  @override
  String plansTokensOneTime(String tokens) {
    return '$tokens jetons';
  }

  @override
  String get planPriceFree => 'Gratuit';

  @override
  String get plansTokensRemaining => 'jetons restants';

  @override
  String plansPlanResetsAt(String when) {
    return 'Le forfait se réinitialise $when';
  }

  @override
  String plansTopupTokensInfo(String tokens) {
    return '$tokens jetons de recharge (sans expiration)';
  }

  @override
  String get plansHowTokensWorkTitle => 'Comment fonctionnent les jetons';

  @override
  String get plansHowTokensWorkBody =>
      'Les jetons mesurent le travail de l\'IA.\n• Une question courte ≈ 2 000 jetons\n• Une explication longue ou une session de pratique ≈ 5 000–10 000\n• L\'analyse d\'images coûte un peu plus\n\nVos jetons mensuels se réinitialisent le 1er. Les jetons de recharge n\'expirent jamais.';

  @override
  String get plansPerMonthSuffix => ' / mois';

  @override
  String get plansCurrentBadge => 'ACTUEL';

  @override
  String get plansCouldntLoadPlans => 'Impossible de charger les forfaits';

  @override
  String get paywallPlansUnavailable =>
      'Forfaits indisponibles. Réessayez dans un instant.';

  @override
  String get paywallTopupUnavailable =>
      'Recharge indisponible. Le store n\'a pas fini d\'approuver ce produit.';

  @override
  String get paywallRestored => 'Votre abonnement a été restauré.';

  @override
  String get paywallNoRestores =>
      'Aucun achat précédent trouvé sur cet identifiant Apple.';

  @override
  String paywallRestoreFailed(String error) {
    return 'Échec de la restauration : $error';
  }

  @override
  String get paywallPurchasesRestricted =>
      'Les achats sont restreints sur cet appareil.';

  @override
  String get paywallPurchaseInvalid =>
      'Cet achat n\'est pas valide. Essayez un autre moyen de paiement.';

  @override
  String get paywallProductNotAvailable =>
      'Ce forfait n\'est pas disponible pour le moment. Réessayez plus tard.';

  @override
  String get paywallNetworkError =>
      'Problème réseau. Vérifiez votre connexion et réessayez.';

  @override
  String get paywallPaymentPending =>
      'Paiement en attente d\'approbation (contrôle parental, etc.). Il sera activé après approbation.';

  @override
  String get paywallStoreProblem =>
      'Un problème est survenu sur l\'App Store. Réessayez dans une minute.';

  @override
  String get paywallGenericError => 'Une erreur est survenue. Réessayez.';

  @override
  String paywallWelcomeMessage(String plan) {
    return 'Bienvenue dans $plan ! Les jetons arrivent.';
  }

  @override
  String get paywallWelcomeFallback => 'votre nouveau forfait';

  @override
  String get paywallTopupAdded => 'Recharge ajoutée. Les jetons arrivent.';

  @override
  String get paywallPurchaseProcessed =>
      'Achat traité. Les jetons apparaîtront bientôt.';

  @override
  String paywallSubscribeTo(String plan) {
    return 'S\'abonner à $plan';
  }

  @override
  String paywallBuyTopupNamed(String topup) {
    return 'Acheter $topup';
  }

  @override
  String get paywallPlanFallback => 'forfait';

  @override
  String get paywallTopupFallback => 'recharge';

  @override
  String get paywallTopupBlurb =>
      'Achat unique. Les jetons n\'expirent jamais et s\'ajoutent à votre forfait.';

  @override
  String paywallPerMonthWithTokens(String tokens) {
    return 'par mois · $tokens';
  }

  @override
  String paywallOneTimeWithTokens(String tokens) {
    return 'unique · $tokens';
  }

  @override
  String get paywallSubscribeButton => 'S\'abonner';

  @override
  String get paywallBuyButton => 'Acheter';

  @override
  String get paywallRestoreButton => 'Restaurer les achats';

  @override
  String get paywallNotNow => 'Pas maintenant';

  @override
  String get paywallWebOnlyTitle => 'Achetez sur mobile';

  @override
  String get paywallWebOnlyBody =>
      'Les abonnements et recharges passent par l\'App Store ou Google Play. Ouvrez ClassMate sur votre iPhone, iPad ou téléphone Android pour vous abonner — votre compte et vos jetons sont partagés entre tous les appareils.';

  @override
  String get paywallWebOnlyDismiss => 'Compris';

  @override
  String get paywallTermsSubscription =>
      'En vous abonnant, vous acceptez les Conditions et la Politique de confidentialité de ClassMate. Les abonnements se renouvellent automatiquement chaque mois jusqu\'à annulation. Gérez à tout moment depuis votre compte App Store.';

  @override
  String get paywallTermsTopup =>
      'En achetant, vous acceptez les Conditions et la Politique de confidentialité de ClassMate. Les jetons de recharge ne sont pas remboursables une fois consommés.';

  @override
  String get paywallTermsLink => 'Conditions d\'utilisation (EULA)';

  @override
  String get paywallPrivacyLink => 'Politique de confidentialité';

  @override
  String get paywallFeatureTokens =>
      'Utilisez les jetons dans NOVA et les sessions de pratique';

  @override
  String get paywallFeatureImages =>
      'Analyse d\'images et envoi de fichiers inclus';

  @override
  String get paywallFeatureReset =>
      'Les jetons se réinitialisent au début de chaque mois';

  @override
  String get paywallFeatureCancel => 'Annulez à tout moment — sans engagement';

  @override
  String get studentMaterialsGeneralSubject => 'Général';

  @override
  String studentMaterialsResourceCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ressources de vos enseignants',
      one: '$count ressource de vos enseignants',
    );
    return '$_temp0';
  }

  @override
  String classroomsCouldNotLoadWithError(String error) {
    return 'Impossible de charger les classes\n$error';
  }

  @override
  String get parentNoNotificationsYet => 'Aucune notification pour l\'instant.';

  @override
  String forwardCouldNotLoadChats(Object error) {
    return 'Impossible de charger les discussions : $error';
  }

  @override
  String get forwardNoChats => 'Aucune discussion';

  @override
  String get forgotPasswordFindAdmins =>
      'Trouver les administrateurs de mon école';

  @override
  String forgotPasswordChooseAdmin(String school) {
    return 'Choisissez un administrateur dans $school :';
  }

  @override
  String get forgotPasswordSendRequest => 'Envoyer la demande de mot de passe';

  @override
  String get commonTitle => 'Titre';

  @override
  String get commonNotes => 'Notes';

  @override
  String get commonEmail => 'E-mail';

  @override
  String get commonPassword => 'Mot de passe';

  @override
  String get commonNumberOfPages => 'Nombre de pages';

  @override
  String get messagesSearchByNameOrGrade => 'Rechercher par nom ou niveau…';

  @override
  String get meetingStartDateRequired => 'Date de début *';

  @override
  String get meetingStartTimeRequired => 'Heure de début *';

  @override
  String get meetingEndDateOptional => 'Date de fin (optionnel)';

  @override
  String get meetingEndTimeOptional => 'Heure de fin (optionnel)';

  @override
  String get teacherMaterialLinkUrlOptional => 'Lien / URL (optionnel)';

  @override
  String get teacherSearchStudentsOrGrade => 'Rechercher élèves ou niveau…';

  @override
  String get teacherSearchParentsOrChildren => 'Rechercher parents ou enfants…';

  @override
  String get studentAssignmentAddNoteOptional =>
      'Ajouter une note (optionnel)…';

  @override
  String get adminEditUserUsernameRequired => 'Nom d\'utilisateur *';

  @override
  String get reportReasonOptional => 'Raison (optionnel)';

  @override
  String get forwardSearchChatsAndClassrooms =>
      'Rechercher discussions et classes…';

  @override
  String get profileNewPhone => 'Nouveau téléphone';

  @override
  String get profileNewEmail => 'Nouvel e-mail';

  @override
  String get forgotPasswordYourPhone =>
      'Votre téléphone (pour que l\'administrateur puisse vérifier votre identité)';

  @override
  String get forgotPasswordPhoneHelper =>
      'L\'administrateur appellera ou enverra un SMS à ce numéro avant d\'approuver.';

  @override
  String get forgotPasswordNewPasswordHelper =>
      'Au moins 8 caractères. Stocké chiffré — votre administrateur ne le verra pas.';

  @override
  String adminExportPasswordsWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Le fichier contiendra les identifiants de connexion de $count élèves, y compris les mots de passe actuels. Toute personne ayant le fichier peut se connecter en tant que l\'un de ces élèves — partagez avec précaution et supprimez après usage. Les lignes des comptes créés avant la dernière mise à jour peuvent afficher un mot de passe vide jusqu\'à la prochaine connexion ou réinitialisation de chaque utilisateur.',
      one:
          'Le fichier contiendra les identifiants de connexion d\'$count élève, y compris le mot de passe actuel. Toute personne ayant le fichier peut se connecter en tant que cet élève — partagez avec précaution et supprimez après usage. Les lignes des comptes créés avant la dernière mise à jour peuvent afficher un mot de passe vide jusqu\'à la prochaine connexion ou réinitialisation de l\'utilisateur.',
    );
    return '$_temp0';
  }

  @override
  String get pickerSelectStudents => 'Sélectionner les élèves';

  @override
  String get pickerSelectCohorts => 'Sélectionner les groupes';

  @override
  String get pickerSelectGrades => 'Sélectionner les niveaux';

  @override
  String get pickerSelectClassroom => 'Sélectionner la classe';

  @override
  String get pickerSelectClasses => 'Sélectionner les classes';

  @override
  String get drawerLoadingChildren => 'Chargement des enfants…';

  @override
  String get drawerCouldNotLoadChildren => 'Impossible de charger les enfants';

  @override
  String get drawerNoChildrenLinked => 'Aucun enfant lié';

  @override
  String get drawerSwitchChild => 'Changer d\'enfant';

  @override
  String get shellAssessmentCreated => 'Évaluation créée';

  @override
  String commonCouldNotOpenLink(String scheme) {
    return 'Impossible d\'ouvrir le lien $scheme';
  }

  @override
  String commonCouldntSend(String error) {
    return 'Échec de l\'envoi : $error';
  }

  @override
  String get teacherExamDetailsSection => 'Détails de l\'examen';

  @override
  String teacherExamStudyMaterialsWithCount(int count) {
    return 'Supports d\'étude ($count)';
  }

  @override
  String get teacherMeetingDetailsSection => 'Détails de la réunion';

  @override
  String get teacherClassroomNameSection => 'Nom de la classe';

  @override
  String get teacherAddByCohortSection => 'Ajouter par groupe';

  @override
  String get teacherAddIndividualStudentsSection =>
      'Ajouter des élèves individuels';

  @override
  String get teacherGradeTypeSection => 'Type de note';

  @override
  String get teacherOtherGradeSection => 'Autre note';

  @override
  String get teacherEnterGradesSection => 'Saisir les notes';

  @override
  String teacherAttachmentsWithCount(int count) {
    return 'Pièces jointes ($count)';
  }

  @override
  String get studentFilesSharedByTeacher =>
      'Fichiers partagés par votre enseignant';

  @override
  String get studentYourSubmission => 'Votre soumission';

  @override
  String get studentFilesSharedWithAnnouncement =>
      'Fichiers partagés avec cette annonce.';

  @override
  String get announcementGradeRiskTitle => 'Risque de note détecté';

  @override
  String get announcementWeakSubjectTitle => 'Matière faible détectée';

  @override
  String get announcementLowAttendanceTitle => 'Faible présence';

  @override
  String get announcementRepeatedLatenessTitle => 'Retards répétés';

  @override
  String get announcementPracticeWeaknessTitle =>
      'Faiblesse de pratique détectée';

  @override
  String get announcementPracticeTrendDroppedTitle =>
      'Tendance de pratique en baisse';

  @override
  String get announcementSolutionsActivityTitle =>
      'Activité Solutions en direct';

  @override
  String get announcementAllGoodTitle => 'Tout va bien';

  @override
  String get supportSectionGettingStarted => 'Commencer';

  @override
  String get supportSectionAccountPassword => 'Compte et mot de passe';

  @override
  String get supportSectionForStudents => 'Pour les élèves';

  @override
  String get supportSectionForTeachers => 'Pour les enseignants';

  @override
  String get supportSectionForAdministrators => 'Pour les administrateurs';

  @override
  String get supportSectionForParents => 'Pour les parents';

  @override
  String get supportSectionPrivacyData => 'Confidentialité et données';

  @override
  String get novaDisclaimerCanMakeMistakes => 'Peut faire des erreurs';

  @override
  String get novaDisclaimerEducationalUseOnly => 'Usage éducatif uniquement';

  @override
  String get novaDisclaimerYourPrivacy => 'Votre vie privée';

  @override
  String profileNameInLanguage(String language) {
    return 'Nom en $language';
  }

  @override
  String get adminSettingsScheduleSubtitle =>
      'Assigner enseignants et groupes aux créneaux hebdomadaires';

  @override
  String get practiceModeBalancedSubtitle => 'Pratique quotidienne équilibrée';

  @override
  String get practiceModeRevealSubtitle => 'Révéler et auto-restituer';

  @override
  String get practiceModeFastSubtitle => 'Exercice rapide sous pression';

  @override
  String get practiceModeExamSubtitle => 'Flux calme façon examen';

  @override
  String get practiceModeConceptSubtitle =>
      'Concept d\'abord, résolution ensuite';

  @override
  String get practiceModeAdaptiveSubtitle => 'La difficulté change en direct';

  @override
  String get practiceModeStrictSubtitle => 'Style officiel strict';

  @override
  String get commonCall => 'Appeler';

  @override
  String get tooltipClearEndTime => 'Effacer l\'heure de fin';

  @override
  String get tooltipDeletePeriod => 'Supprimer la période';

  @override
  String get tooltipLeaveClassroom => 'Quitter la classe';

  @override
  String get announcementGradeRiskBody =>
      'Votre moyenne est tombée sous 70. Action immédiate recommandée.';

  @override
  String announcementWeakSubjectBody(String subject) {
    return '$subject nécessite votre attention.';
  }

  @override
  String get announcementLowAttendanceBody =>
      'Votre présence diminue. Cela impactera vos notes.';

  @override
  String get announcementLatenessBody => 'Vous avez plusieurs retards.';

  @override
  String announcementPracticeWeakTopicBody(String topic, String subject) {
    return '$topic en $subject ralentit votre élan.';
  }

  @override
  String get announcementPracticeDropBody =>
      'Votre pratique récente est en dessous de votre niveau. Ralentissez et reconstruisez.';

  @override
  String announcementSolutionsActivityBody(int page, int question) {
    return 'Votre espace de solutions est actif à la page $page, question $question. Consultez le travail des pairs ou téléversez le vôtre.';
  }

  @override
  String get announcementAllGoodBody =>
      'Aucun risque académique majeur détecté pour le moment.';

  @override
  String get faqStartedQ1 => 'Comment je me connecte ?';

  @override
  String get faqStartedA1 =>
      'Appuyez sur « Se connecter » sur l\'écran d\'accueil et saisissez l\'e-mail ou le nom d\'utilisateur que votre administrateur scolaire vous a donné, ainsi que votre mot de passe temporaire. Vous serez invité à définir un nouveau mot de passe la première fois.';

  @override
  String get faqStartedQ2 => 'Je n\'ai pas encore de compte.';

  @override
  String get faqStartedA2 =>
      'Votre administrateur scolaire crée les comptes. Demandez-lui de vous ajouter dans son application d\'administration, ou de partager un code d\'inscription si votre école utilise l\'auto-inscription.';

  @override
  String get faqStartedQ3 => 'Puis-je utiliser l\'application dans ma langue ?';

  @override
  String get faqStartedA3 =>
      'Oui — ClassMate prend en charge l\'anglais, l\'arabe, l\'hébreu, le français et le russe. Ouvrez Paramètres pour changer de langue. Vous pouvez aussi définir une langue de nom préférée dans le Profil.';

  @override
  String get faqStartedQ4 =>
      'Comment basculer entre les modes sombre et clair ?';

  @override
  String get faqStartedA4 =>
      'Ouvrez Paramètres dans le menu et basculez l\'interrupteur d\'apparence. L\'application respecte votre préférence système par défaut.';

  @override
  String get faqAccountQ1 => 'J\'ai oublié mon mot de passe.';

  @override
  String get faqAccountA1 =>
      'Appuyez sur « Mot de passe oublié ? » sur l\'écran de connexion. Vous recevrez un lien de réinitialisation par e-mail ou un code par SMS. Si aucun canal n\'est encore vérifié, demandez à votre administrateur scolaire un nouveau mot de passe temporaire.';

  @override
  String get faqAccountQ2 => 'Comment changer mon mot de passe ?';

  @override
  String get faqAccountA2 =>
      'Ouvrez Profil dans le menu, faites défiler jusqu\'à Sécurité, et appuyez sur la ligne du mot de passe. Vous aurez besoin de votre mot de passe actuel pour en définir un nouveau.';

  @override
  String get faqAccountQ3 =>
      'Comment changer mon e-mail ou mon numéro de téléphone ?';

  @override
  String get faqAccountA3 =>
      'Ouvrez Profil, appuyez sur le champ à modifier, et suivez les invites de vérification. Un code est envoyé d\'abord à votre e-mail/téléphone ACTUEL pour confirmer votre identité, puis vous pouvez définir la nouvelle valeur.';

  @override
  String get faqAccountQ4 =>
      'Mon administrateur scolaire peut changer mon mot de passe — comment ça marche ?';

  @override
  String get faqAccountA4 =>
      'Quand un administrateur réinitialise votre mot de passe, vous recevrez un e-mail et un SMS avec un lien en un clic pour définir votre propre mot de passe. L\'administrateur ne voit jamais ce que vous choisissez.';

  @override
  String get faqStudentsQ1 => 'Où vois-je mon emploi du temps ?';

  @override
  String get faqStudentsA1 =>
      'L\'emploi du temps est le premier élément du menu. Vous verrez les périodes de cette semaine, qui enseigne chacune, et tout changement publié par l\'administrateur.';

  @override
  String get faqStudentsQ2 => 'Comment rejoindre une classe ?';

  @override
  String get faqStudentsA2 =>
      'Un enseignant vous ajoutera directement, ou partagera un code d\'inscription. Pour utiliser un code, ouvrez Classes dans le menu et appuyez sur « Rejoindre avec un code ».';

  @override
  String get faqStudentsQ3 =>
      'Comment fonctionnent les présences et les notes ?';

  @override
  String get faqStudentsA3 =>
      'Les enseignants marquent les présences pendant le cours. Ouvrez Présences ou Notes dans le menu pour voir vos relevés. Les parents liés à votre compte voient les mêmes données.';

  @override
  String get faqStudentsQ4 => 'Qu\'est-ce que Nova ?';

  @override
  String get faqStudentsA4 =>
      'Nova est votre assistant d\'étude IA — demandez-lui d\'expliquer un concept, de générer un quiz, ou de parcourir un problème étape par étape. Ouvrez Nova dans le menu pour démarrer une session.';

  @override
  String get faqTeachersQ1 => 'Comment créer une classe ?';

  @override
  String get faqTeachersA1 =>
      'Ouvrez Classes dans le menu et appuyez sur le bouton +. Donnez-lui un nom et une matière ; les élèves peuvent être ajoutés manuellement ou via un code d\'inscription.';

  @override
  String get faqTeachersQ2 => 'Comment marquer les présences ?';

  @override
  String get faqTeachersA2 =>
      'Ouvrez Présences dans le menu, choisissez la date et la période, puis appuyez sur chaque élève pour définir son statut. Les changements sont enregistrés automatiquement.';

  @override
  String get faqTeachersQ3 => 'Comment assigner des devoirs ?';

  @override
  String get faqTeachersA3 =>
      'Ouvrez Devoirs, appuyez sur +, remplissez le titre/date limite/pièces jointes, et choisissez une cible (toute l\'école, groupes spécifiques, ou élèves nommés). Les élèves le voient instantanément dans leur menu.';

  @override
  String get faqTeachersQ4 => 'Puis-je émettre un diplôme ou un certificat ?';

  @override
  String get faqTeachersA4 =>
      'Oui — ouvrez Diplômes dans le menu, appuyez sur +, choisissez l\'élève, remplissez le titre et les détails, et enregistrez. L\'élève le voit dans sa propre section Diplômes.';

  @override
  String get faqAdminsQ1 => 'Par où commencer pour configurer une école ?';

  @override
  String get faqAdminsA1 =>
      'Ouvrez le Tableau de bord Admin. Le widget Configuration de l\'école en haut montre une liste de 7 étapes (logo, nom, matières, horaires des cloches, groupes, élèves, enseignants). Chaque étape vous mène directement où la compléter.';

  @override
  String get faqAdminsQ2 => 'Comment fonctionnent les groupes ?';

  @override
  String get faqAdminsA2 =>
      'Un groupe est un ensemble d\'élèves qui partagent un emploi du temps. Ouvrez Groupes dans le menu pour les créer, assigner des élèves, et générer des codes d\'inscription. Un seul groupe peut couvrir plusieurs niveaux.';

  @override
  String get faqAdminsQ3 => 'Un groupe peut-il couvrir plus d\'un niveau ?';

  @override
  String get faqAdminsA3 =>
      'Oui — lors de la création d\'un groupe, sélectionnez plusieurs niveaux. Le groupe apparaît alors dans les filtres et vues de chacun de ces niveaux, et les annonces/modèles ciblant l\'un de ces niveaux l\'atteignent.';

  @override
  String get faqAdminsQ4 =>
      'Comment construire l\'emploi du temps hebdomadaire ?';

  @override
  String get faqAdminsA4 =>
      'Ouvrez Emploi du temps dans le menu. Appuyez sur n\'importe quelle cellule pour ajouter une période — choisissez le jour/période, l\'enseignant, la matière, et l\'audience (groupe/élève/niveau). Les horaires des cloches viennent des Paramètres de l\'école.';

  @override
  String get faqAdminsQ5 => 'Comment exporter les élèves en masse ?';

  @override
  String get faqAdminsA5 =>
      'Ouvrez Exporter les données dans le menu. Choisissez de sélectionner par élève ou par groupe, choisissez les lignes, et appuyez sur Exporter. Optionnellement, incluez les mots de passe actuels lors de l\'export.';

  @override
  String get faqAdminsQ6 =>
      'Un utilisateur m\'a demandé de réinitialiser son mot de passe. Que faire ?';

  @override
  String get faqAdminsA6 =>
      'Vous pouvez soit définir son mot de passe directement (Profil de l\'utilisateur → Sécurité) soit attendre qu\'il dépose une demande via « Mot de passe oublié » et l\'approuver depuis Demandes de mot de passe dans le menu.';

  @override
  String get faqParentsQ1 => 'Comment lier mon compte à mon enfant ?';

  @override
  String get faqParentsA1 =>
      'Demandez à l\'administrateur scolaire de votre enfant d\'ajouter le lien depuis son application d\'administration, ou de partager un code de lien parent à usage unique. Ouvrez Profil et entrez le code sous Famille.';

  @override
  String get faqParentsQ2 => 'Que puis-je voir sur mon enfant ?';

  @override
  String get faqParentsA2 =>
      'Présences, notes, annonces et devoirs — exactement ce que voit votre enfant plus les tendances dans le temps. Vous ne verrez pas les conversations privées ni les sessions Nova.';

  @override
  String get faqPrivacyQ1 => 'Qui peut voir mes données ?';

  @override
  String get faqPrivacyA1 =>
      'Seules les personnes de votre école. Les enseignants voient les données de leurs classes, les administrateurs voient les données de toute l\'école, les parents voient leurs enfants liés. Nous ne vendons jamais de données à des annonceurs.';

  @override
  String get faqPrivacyQ2 => 'Comment supprimer mon compte ?';

  @override
  String get faqPrivacyA2 =>
      'Demandez à votre administrateur scolaire de le supprimer. Il peut retirer le compte depuis son application d\'administration, ce qui efface votre profil, votre emploi du temps et vos conversations.';

  @override
  String solutionsPagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '$count page',
    );
    return '$_temp0';
  }

  @override
  String get teacherMeetingEditTitle => 'Modifier la réunion';

  @override
  String get teacherMeetingNewTitle => 'Planifier une réunion';

  @override
  String get teacherExamEditTitle => 'Modifier l\'examen';

  @override
  String get teacherExamNewTitle => 'Créer un examen';

  @override
  String get teacherAssignmentEditTitle => 'Modifier le devoir';

  @override
  String get teacherAssignmentNewTitle => 'Nouveau devoir';

  @override
  String get tooltipShowTabs => 'Afficher les onglets';

  @override
  String get tooltipHideTabs => 'Masquer les onglets';

  @override
  String get examsCouldNotLoadForms => 'Impossible de charger les formulaires';

  @override
  String get examsCouldNotLoadExams => 'Impossible de charger les examens';

  @override
  String get messagesNoPeopleToAdd => 'Aucune personne à ajouter';

  @override
  String commonNoResultsForQuery(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String chatForwardedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Transféré à $count discussions',
      one: 'Transféré à 1 discussion',
    );
    return '$_temp0';
  }

  @override
  String get commonReadMore => 'Lire plus';

  @override
  String get commonReadLess => 'Lire moins';

  @override
  String get chatComposerSlideToCancel => 'Glisser pour annuler';

  @override
  String adminNoRoleYet(String role) {
    return 'Aucun $role pour l\'instant';
  }

  @override
  String get profileVerified => 'Vérifié.';

  @override
  String get profileUpdatedPendingVerification =>
      'Mis à jour, en attente de re-vérification.';

  @override
  String get adminSearchCohorts => 'Rechercher des groupes…';

  @override
  String get commonAdding => 'Ajout en cours…';

  @override
  String get teacherDiplomaIssuing => 'Émission…';

  @override
  String get teacherDiplomaIssue => 'Émettre';

  @override
  String get formAccepting => 'Accepte';

  @override
  String get profileVerifiedShort => 'Vérifié';

  @override
  String get profileUnverified => 'Non vérifié';

  @override
  String get notificationNewGradePosted => 'Nouvelle note publiée';

  @override
  String notificationNewGradePostedIn(String subject) {
    return 'Nouvelle note publiée en $subject';
  }

  @override
  String messagesAddParticipants(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouter $count participants',
      one: 'Ajouter 1 participant',
    );
    return '$_temp0';
  }

  @override
  String get notificationFallbackTitle => 'Notification';

  @override
  String adminCohortGradeRange(int from, int to) {
    return 'Niveau $from-$to';
  }

  @override
  String adminCohortGradesList(String list) {
    return 'Niveaux $list';
  }

  @override
  String get adminExportHeaderTitle => 'Exporter les utilisateurs';

  @override
  String get adminExportHeaderSubtitle =>
      'Ajoutez des filtres sous forme de puces — chaque puce ajoute des utilisateurs à l\'export. Appuyez sur une puce pour la retirer.';

  @override
  String get adminExportAddFilter => 'Ajouter un filtre';

  @override
  String get adminExportEmptyState =>
      'Ajoutez un filtre pour commencer : choisissez un rôle, un groupe, un niveau ou des utilisateurs spécifiques.';

  @override
  String get adminExportFilterRolesTab => 'Rôles';

  @override
  String get adminExportFilterCohortsTab => 'Groupes';

  @override
  String get adminExportFilterGradesTab => 'Niveaux';

  @override
  String get adminExportFilterUsersTab => 'Utilisateurs';

  @override
  String get adminExportSelectAll => 'Tout sélectionner';

  @override
  String adminExportSelectedCount(int selected, int total) {
    return '$selected sur $total sélectionnés';
  }

  @override
  String adminExportRolePickedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnés',
      one: '1 sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get adminExportPillRolePrefix => 'Rôle :';

  @override
  String get adminExportPillCohortPrefix => 'Groupe :';

  @override
  String adminExportActiveFilters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count filtres actifs',
      one: '$count filtre actif',
    );
    return '$_temp0';
  }

  @override
  String get adminExportClearAll => 'Tout effacer';

  @override
  String get adminExportCounting => 'Comptage…';

  @override
  String adminExportMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count utilisateurs seront exportés',
      one: '$count utilisateur sera exporté',
    );
    return '$_temp0';
  }

  @override
  String get adminExportNoGradesConfigured =>
      'Aucun niveau configuré pour cette école';

  @override
  String get adminExportColumnRole => 'Rôle';

  @override
  String get adminExportRoleStudent => 'Élève';

  @override
  String get adminExportRoleTeacher => 'Enseignant';

  @override
  String get adminExportRoleParent => 'Parent';

  @override
  String get adminExportRoleSecretary => 'Secrétaire';

  @override
  String get adminExportRoleAdmin => 'Administrateur';

  @override
  String adminExportUsersSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count utilisateurs sélectionnés',
      one: '$count utilisateur sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get adminExportPasswordsOn =>
      'Les mots de passe seront visibles dans l\'export — manipulez le fichier avec précaution.';

  @override
  String get adminExportPasswordsOff =>
      'L\'export ne contiendra aucun mot de passe.';

  @override
  String get adminExportPdfUserDirectory => 'Annuaire des utilisateurs';

  @override
  String adminExportPdfUsersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count utilisateurs',
      one: '$count utilisateur',
    );
    return '$_temp0';
  }

  @override
  String get teacherAttachFromMaterials => 'Depuis les supports';

  @override
  String get teacherUploadFiles => 'Téléverser des fichiers';

  @override
  String get solSubjectMathematics => 'Mathématiques';

  @override
  String get solSubjectComputerScience => 'Informatique';

  @override
  String get solSubjectPhysics => 'Physique';

  @override
  String get solSubjectChemistry => 'Chimie';

  @override
  String get solSubjectHebrew => 'Hébreu';

  @override
  String get solSubjectBiology => 'Biologie';

  @override
  String get solSubjectHistory => 'Histoire';

  @override
  String get solSubjectArabic => 'Arabe';

  @override
  String get solSubjectElectronics => 'Électronique';

  @override
  String get solSubjectMechanics => 'Mécanique';

  @override
  String get solSubjectFrench => 'Français';

  @override
  String get solSubjectEnvironmentalScience => 'Sciences de l\'environnement';

  @override
  String get solSubjectCommunicationCinema => 'Communication et cinéma';

  @override
  String get solSubjectCitizenship => 'Éducation civique';

  @override
  String get solSubjectSociology => 'Sociologie';

  @override
  String get solSubjectReligion => 'Religion';

  @override
  String get solSubjectGeography => 'Géographie';

  @override
  String get commonUnknown => 'Inconnu';

  @override
  String get solutionsReportTitle => 'Signaler cette solution';

  @override
  String get solutionsReportBody =>
      'Indiquez le problème aux administrateurs. Les admins des deux écoles l\'examineront.';

  @override
  String get solutionsReportReasonHint => 'Motif (facultatif)';

  @override
  String get solutionsReportAction => 'Signaler';

  @override
  String get solutionsReportSubmitted => 'Merci — signalé aux administrateurs.';

  @override
  String get solutionsReportAlready => 'Vous avez déjà signalé ceci.';

  @override
  String solutionsBookPagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get solutionsNoBooksYetForStudents =>
      'Aucun livre ici pour l\'instant. Votre enseignant les ajoutera.';

  @override
  String get solutionsManageBooksTitle => 'Gérer les livres';

  @override
  String get solutionsNoBooksManageHint =>
      'Aucun livre pour cette matière. Touchez + pour en ajouter un.';

  @override
  String get solutionsDeleteBookTitle => 'Supprimer le livre ?';

  @override
  String solutionsDeleteBookBody(String title) {
    return 'Supprimer « $title » ? Action irréversible.';
  }

  @override
  String solutionsBookSaveFailed(String error) {
    return 'Échec de l\'enregistrement : $error';
  }

  @override
  String get solutionsBookNeedTitlePages =>
      'Saisissez un titre et un nombre de pages.';

  @override
  String get solutionsEditBookTitle => 'Modifier le livre';

  @override
  String get solutionsBookCoverLabel => 'Couverture';

  @override
  String solutionsGradeLabel(int grade) {
    return 'Niveau $grade';
  }

  @override
  String get solutionsReportsTitle => 'Solutions signalées';

  @override
  String get solutionsReportsEmpty => 'Aucun signalement à examiner.';

  @override
  String get solutionsReportPostedBy => 'Publié par';

  @override
  String get solutionsReportReportedBy => 'Signalé par';

  @override
  String get solutionsReportReasonLabel => 'Motif';

  @override
  String get solutionsReportKeepAction => 'Conserver';

  @override
  String get solutionsReportRemoveAction => 'Supprimer';

  @override
  String get solutionsReportStatusPending => 'En attente';

  @override
  String get solutionsReportStatusApproved => 'Conservé';

  @override
  String get solutionsReportStatusRemoved => 'Supprimé';

  @override
  String get solutionsReportRemoved => 'Solution supprimée.';

  @override
  String get solutionsReportApproved =>
      'Signalement rejeté — solution conservée.';

  @override
  String solutionsReportFailed(String error) {
    return 'Échec du signalement : $error';
  }

  @override
  String get teacherAddGradeTitle => 'Ajouter une note';

  @override
  String get commonCohort => 'Cohorte';

  @override
  String get teacherCreateNewExam => 'Créer un examen';

  @override
  String get teacherCreateNewAssignment => 'Créer un devoir';

  @override
  String get commonReturn => 'Retourner';

  @override
  String get reorderToolsTitle => 'Réorganiser le menu';

  @override
  String get reorderToolsSubtitle =>
      'Faites glisser pour réorganiser vos outils scolaires. Les sections principale et compte restent en place.';

  @override
  String get reorderToolsReset => 'Réinitialiser';

  @override
  String get reorderToolsSettingsSection => 'Menu';

  @override
  String get reorderToolsSettingsSubtitle =>
      'Réorganiser les outils du menu latéral';

  @override
  String get adminSchoolGradeRangesDescription =>
      'Définissez les niveaux couverts par votre école. Ajoutez plusieurs plages si certains niveaux sont absents (ex. 4-6 et 9-12).';

  @override
  String get adminSchoolAddGradeRange => 'Ajouter une plage';

  @override
  String get teacherListStudents => 'Liste des élèves';

  @override
  String get teacherNoStudentsInvolved =>
      'Aucun élève dans ce créneau pour l\'instant.';

  @override
  String get messagesFilterAdmins => 'Admins';

  @override
  String get teacherAssignmentGradedStatus => 'Noté';

  @override
  String get teacherAssignmentReturnedStatus => 'Renvoyé pour correction';

  @override
  String get teacherAssignmentReturnAction => 'Renvoyer pour correction';

  @override
  String teacherAssignmentReturnDialogBody(String name) {
    return 'Renvoyer cette remise à $name pour révision et nouvelle remise ? Tout commentaire saisi sera inclus.';
  }

  @override
  String teacherGradesSavedOf(int saved, int total) {
    return '$saved sur $total enregistrés.';
  }

  @override
  String teacherGradesSkippedSuffix(int dropped) {
    return '$dropped élève(s) ignoré(s) — pas dans une cohorte.';
  }

  @override
  String get adminPeopleGradeLevelRequired =>
      'Choisissez un niveau pour cet élève.';

  @override
  String teacherAddGradeLabel(int grade) {
    return 'Niveau $grade';
  }

  @override
  String get teacherGradeOutOfHint => 'ex. 20';

  @override
  String get plansDowngrade => 'Rétrograder';

  @override
  String get plansDowngradeNote =>
      'Prend effet à la fin de votre plan actuel — vous le gardez jusque-là, sans remboursement.';

  @override
  String get semesterThis => 'Ce semestre';

  @override
  String get semesterPrevious => 'Précédents';

  @override
  String get showMore => 'Afficher plus';

  @override
  String get adminSchoolSemestersLabel => 'Semestres';

  @override
  String get adminSchoolSemestersDescription =>
      'Divisez l\'année scolaire en semestres par mois. Notes, examens, réunions et plus sont regroupés par semestre automatiquement.';

  @override
  String adminSchoolSemesterN(String n) {
    return 'Semestre $n';
  }

  @override
  String get adminSchoolAddSemester => 'Ajouter un semestre';

  @override
  String get semesterStarts => 'Début';

  @override
  String get semesterEnds => 'Fin';

  @override
  String get commonWhen => 'Quand';

  @override
  String get commonFiles => 'Fichiers';

  @override
  String get commonOnce => 'Une fois';

  @override
  String get commonNoneDash => '— Aucun —';

  @override
  String get commonNotesOptional => 'Notes (facultatif)';

  @override
  String get commonSubjectOptional => 'Matière (facultatif)';

  @override
  String get colorBlue => 'Bleu';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorViolet => 'Violet';

  @override
  String get colorTeal => 'Sarcelle';

  @override
  String get colorGreen => 'Vert';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorRose => 'Rose';

  @override
  String get teacherAddClassNotes => 'Ajouter des notes de cours';

  @override
  String get teacherStudentsWithGrades => 'Élèves avec notes';

  @override
  String get teacherOtherStudentsSameGrade =>
      'Autres élèves de la même classe/cohorte';

  @override
  String get teacherChooseExam => 'Choisir un examen';

  @override
  String get teacherChooseAssignment => 'Choisir un devoir';

  @override
  String get teacherSearchExams => 'Rechercher des examens…';

  @override
  String get teacherSearchAssignments => 'Rechercher des devoirs…';

  @override
  String get teacherSearchQuestionTypes => 'Rechercher des types de questions…';

  @override
  String get teacherOtherCustomSubject => 'Autre (saisie libre)';

  @override
  String get adminLinkChild => 'Associer un enfant';

  @override
  String get adminChooseStudentDash => '— Choisir un élève —';

  @override
  String get adminSelectStudentToLink => 'Sélectionner l\'élève à associer';

  @override
  String get adminEditPeriod => 'Modifier la période';

  @override
  String get adminNotInAnyCohort =>
      'Pas encore dans une cohorte — à assigner depuis l\'écran Cohortes.';

  @override
  String get adminPasswordChangeWarning =>
      'L\'utilisateur se connectera avec ce mot de passe à sa prochaine connexion. Tout lien de réinitialisation en attente sera invalidé.';

  @override
  String get nameInEnglish => 'Nom en anglais';

  @override
  String get nameInArabic => 'Nom en arabe';

  @override
  String get nameInHebrew => 'Nom en hébreu';

  @override
  String get nameInFrench => 'Nom en français';

  @override
  String get nameInRussian => 'Nom en russe';

  @override
  String get passwordMinChars => 'Au moins 8 caractères.';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get adminWelcomeHeading => 'Bienvenue sur ClassMate';

  @override
  String get forgotPasswordSendRequestTo => 'Envoyer la demande à';

  @override
  String get forgotPasswordChooseAdminDash => '— Choisir un admin —';

  @override
  String get diplomasNoFilesAttached => 'Aucun fichier joint à ce certificat.';

  @override
  String get diplomasFilesProcessing =>
      'Impossible d\'ouvrir les fichiers — ils sont peut-être encore en traitement.';

  @override
  String get novaOutOfTokens =>
      'Vous avez utilisé tous vos jetons pour cette période. Améliorez votre offre ou rechargez pour continuer avec NOVA.';

  @override
  String get tutorDeleteConversationWarning =>
      'Cela supprimera définitivement la conversation et tous ses messages du serveur. Cette action est irréversible.';

  @override
  String get chatReportFlagWarning =>
      'Ce message sera signalé pour examen par un administrateur.';

  @override
  String get solutionPreviewFailFallback =>
      'Ouvrez depuis la pièce jointe du chat si l\'aperçu échoue';

  @override
  String get practiceNoInternet =>
      'Pas de connexion Internet. Veuillez réessayer.';

  @override
  String get practiceGenerationFailed =>
      'Impossible de générer les questions. Veuillez réessayer.';

  @override
  String get practiceTimingSecPerQuestion => 's / question';

  @override
  String get practiceTimingMinPerQuiz => 'min / quiz';

  @override
  String adminScheduleFrequencyWeeks(Object freq) {
    return '×$freq sem';
  }

  @override
  String gradeLevelLabel(Object grade) {
    return 'Niveau $grade';
  }

  @override
  String adminPeriodOption(Object period) {
    return 'Période $period';
  }

  @override
  String adminPasswordRequestHoursLeft(Object hours) {
    return '${hours}h restant';
  }

  @override
  String cohortStudentsCount(Object count) {
    return '$count élèves';
  }

  @override
  String diplomasIssuedCount(Object count) {
    return '$count certificats délivrés';
  }

  @override
  String get adminExportImportantHeading => 'Important';

  @override
  String get adminExportWelcomeBodyWithPw =>
      'Voici les détails de votre compte ClassMate. Connectez-vous à l\'application ClassMate sur iOS ou Android avec le nom d\'utilisateur et le mot de passe ci-dessous. Vous pourrez changer votre mot de passe dans l\'application.';

  @override
  String get adminExportWelcomeBodyNoPw =>
      'Voici les détails de votre compte ClassMate. Connectez-vous à l\'application ClassMate sur iOS ou Android avec votre nom d\'utilisateur.';

  @override
  String get adminExportNotePrivate =>
      'Gardez ces identifiants confidentiels. Ne partagez pas votre mot de passe.';

  @override
  String get adminExportNoteChangePw =>
      'Changez votre mot de passe après la première connexion dans Paramètres → Compte.';

  @override
  String get adminExportNoteLegal =>
      'En utilisant ClassMate, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.';

  @override
  String adminExportNoteHelp(String email) {
    return 'Besoin d\'aide ? Contactez l\'administrateur de votre école ou $email.';
  }

  @override
  String get teacherGradeTitleHint => 'ex. Participation en classe, Quiz 3';

  @override
  String get teacherClassroomNameHint => 'ex. Mathématiques 10A';

  @override
  String get novaAbout => 'À propos de NOVA';

  @override
  String get parentNotifForYou => 'Pour vous';

  @override
  String parentNotifAbout(String name) {
    return 'À propos de $name';
  }

  @override
  String get navPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get privacyPolicySubtitle => 'Comment nous protégeons vos données';

  @override
  String get semesterAllPrevious => 'Tout le précédent';

  @override
  String get semesterSelectTitle => 'Choisir le semestre';
}

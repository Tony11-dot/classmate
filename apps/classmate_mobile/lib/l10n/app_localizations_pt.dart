// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get menu => 'Menu';

  @override
  String get sectionCore => 'Principal';

  @override
  String get sectionSchoolTools => 'Ferramentas escolares';

  @override
  String get sectionAccount => 'Conta';

  @override
  String get navSchedule => 'Horário';

  @override
  String get navClassrooms => 'Salas de aula';

  @override
  String get navPractice => 'Prática';

  @override
  String get navInsights => 'Análises';

  @override
  String get navNova => 'NOVA';

  @override
  String get navMessages => 'Mensagens';

  @override
  String get navAttendance => 'Frequência';

  @override
  String get navGrades => 'Notas';

  @override
  String get navAssignments => 'Tarefas';

  @override
  String get navMeetings => 'Reuniões';

  @override
  String get navAnnouncements => 'Anúncios';

  @override
  String get navNotifications => 'Notificações';

  @override
  String get navSolutions => 'Soluções';

  @override
  String get navExams => 'Exames';

  @override
  String get navForms => 'Formulários';

  @override
  String get navHome => 'Início';

  @override
  String get navTeacherWorkspace => 'Espaço do professor';

  @override
  String get navTeacherAssessments => 'Avaliações e notas';

  @override
  String get navSavedQuestions => 'Perguntas salvas';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navSettings => 'Configurações';

  @override
  String get navLogout => 'Sair';

  @override
  String get roleTeacher => 'Professor';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get roleSecretary => 'Secretária';

  @override
  String get roleParent => 'Responsável';

  @override
  String get titleSchedule => 'Horário';

  @override
  String get titleClasses => 'Salas';

  @override
  String get titlePractice => 'Prática';

  @override
  String get titleInsights => 'Análises';

  @override
  String get titleNova => 'NOVA';

  @override
  String get titleMessages => 'Mensagens';

  @override
  String get titleSolutions => 'Soluções';

  @override
  String get titleExams => 'Exames';

  @override
  String get solutionsUploadAction => 'Enviar';

  @override
  String get solutionsNoSubjectsAvailable => 'Nenhum assunto disponível.';

  @override
  String solutionsNoSubjectsMatch(Object query) {
    return 'Nenhum assunto corresponde a \"$query\".';
  }

  @override
  String solutionsBookCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livros',
      one: '1 livro',
    );
    return '$_temp0';
  }

  @override
  String get solutionsBooksTitle => 'Livros';

  @override
  String get solutionsAddBookTitle => 'Adicionar um livro';

  @override
  String get solutionsBookTitleHint => 'Título do livro...';

  @override
  String get solutionsAddBookAction => 'Adicionar um livro';

  @override
  String get solutionsSearchBooks => 'Pesquisar livros';

  @override
  String get solutionsChooseSubjectFirst => 'Escolha um assunto primeiro.';

  @override
  String solutionsNoBooksYetBody(Object action) {
    return 'Nenhum livro ainda.\nToque em \"$action\" para adicionar o primeiro.';
  }

  @override
  String solutionsNoBooksMatch(Object query) {
    return 'Nenhum livro corresponde a \"$query\".';
  }

  @override
  String get solutionsBookLabel => 'Livro';

  @override
  String get solutionsPagesFilterHint =>
      'Digite um número de página e pergunta para filtrar, ou deixe em branco para ver todos.';

  @override
  String get solutionsPageNumberLabel => 'Número da página';

  @override
  String get solutionsPageNumberHint => 'por ex. 42';

  @override
  String get solutionsQuestionNumberLabel => 'Número da pergunta';

  @override
  String get solutionsQuestionNumberHint => 'por ex. 3a ou 7';

  @override
  String get solutionsViewSolutionsAction => 'Ver soluções';

  @override
  String solutionsPageQuestionSummary(Object page, Object question) {
    return 'Página $page • Pergunta $question';
  }

  @override
  String get solutionsExactQuestionTitle => 'Soluções para esta pergunta exata';

  @override
  String get solutionsExactQuestionEmptySubtitle =>
      'Nada foi enviado para esta pergunta exata ainda. Seja o primeiro a ajudar seus colegas de classe.';

  @override
  String solutionsUploadsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count envios encontrados',
      one: '1 envio encontrado',
    );
    return '$_temp0';
  }

  @override
  String get solutionsExactQuestionEmptyBody =>
      'Nenhuma correspondência exata ainda. Você pode enviar uma agora ou verificar o que seus colegas resolveram nesta mesma página.';

  @override
  String get solutionsLoadMoreAction => 'Carregar mais';

  @override
  String get solutionsSamePageTitle =>
      'Outras perguntas resolvidas nesta página';

  @override
  String get solutionsSamePageEmptySubtitle =>
      'Nenhuma pergunta vizinha foi enviada desta página ainda.';

  @override
  String get solutionsSamePageFallbackSubtitle =>
      'Um fallback útil quando sua pergunta exata não tem envio ainda.';

  @override
  String get solutionsSamePageEmptyBody =>
      'Nenhum envio próximo nesta página ainda. Um novo envio aqui seria realmente útil.';

  @override
  String get solutionsVerifiedByNova => 'Verificado pela NOVA';

  @override
  String get solutionsUploadFileLimitReached =>
      'Limite de 10 arquivos atingido.';

  @override
  String solutionsUploadFilesAddedLimit(int count) {
    return 'Adicionado $count — limite de 10 arquivos.';
  }

  @override
  String get solutionsUploadCompleteFields =>
      'Complete assunto, livro, página e pergunta.';

  @override
  String get solutionsUploadAddOneFile =>
      'Adicione pelo menos uma imagem ou PDF.';

  @override
  String solutionsUploadFileFailed(Object error) {
    return 'Falha no upload do arquivo: $error';
  }

  @override
  String solutionsUploadCreateFailed(Object error) {
    return 'Falha ao criar solução: $error';
  }

  @override
  String get solutionsUploadSuccess => 'Solução enviada!';

  @override
  String get solutionsUploadAddNewBookOption => '+ Adicionar um novo livro...';

  @override
  String get solutionsUploadAddBookShortAction => 'Adicionar';

  @override
  String get solutionsUploadTitle => 'Carregar uma solução';

  @override
  String get solutionsUploadSubtitle =>
      'Apenas imagens ou PDFs reais. Verificação NOVA e moderação são aplicadas após o upload.';

  @override
  String get solutionsUploadNoBooksAbove => 'Sem livros — adicione um acima';

  @override
  String get solutionsUploadCaptionOptional => 'Legenda (opcional)';

  @override
  String get solutionsUploadImagesAction => 'Imagens';

  @override
  String get solutionsUploadPdfAction => 'PDF';

  @override
  String solutionsUploadFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'arquivos selecionados',
      one: 'arquivo selecionado',
    );
    return '$count / 10 $_temp0';
  }

  @override
  String get solutionsUploadSomeFilesFailed =>
      'Alguns arquivos falharam no upload.';

  @override
  String get solutionsUploadRetryFailedFiles =>
      'Tentar novamente arquivos com falha';

  @override
  String get solutionsUploadSubmittingAction => 'Enviando...';

  @override
  String get solutionsUploadSubmitAction => 'Carregar solução';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsSubtitle => 'Aparência, idioma e conta';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Padrão do sistema';

  @override
  String get settingsAccentColour => 'Cor de destaque';

  @override
  String get settingsAccentSubtitle => 'Tom usado em todo o app';

  @override
  String get settingsReduceMotion => 'Reduzir movimento';

  @override
  String get settingsReduceMotionSubtitle => 'Menos animações no app';

  @override
  String get settingsAccount => 'Conta';

  @override
  String get settingsLogout => 'Sair';

  @override
  String get settingsLogoutSubtitle => 'Sair deste dispositivo';

  @override
  String get settingsThemeSystem => 'Padrão do sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Escuro';

  @override
  String get settingsLanguageSearchHint => 'Buscar idioma...';

  @override
  String get teacherWorkspaceSubtitle =>
      'Controle presença, turmas e notas pelo app móvel.';

  @override
  String get teacherMetricSessionsToday => 'Aulas hoje';

  @override
  String get teacherMetricTeachingGroups => 'Grupos de ensino';

  @override
  String get teacherMetricAssessments => 'Avaliações';

  @override
  String get teacherQuickActions => 'Ações rápidas';

  @override
  String get teacherNoDateAvailable => 'Nenhuma data disponível';

  @override
  String get teacherNoTeachingSlotsToday => 'Nenhuma aula agendada para hoje.';

  @override
  String get teacherUpcomingAssessments => 'Próximas avaliações';

  @override
  String get teacherUpcomingAssessmentsSubtitle =>
      'Ao vivo do sistema de notas do professor';

  @override
  String get teacherNoAssessmentsYet => 'Nenhuma avaliação criada ainda.';

  @override
  String get teacherUnassignedSlot => 'Aula não atribuída';

  @override
  String get teacherNoCohort => 'Sem turma';

  @override
  String get teacherCourseFallback => 'Curso';

  @override
  String teacherPeriod(Object number) {
    return 'Período $number';
  }

  @override
  String get teacherLoadErrorTitle =>
      'Não foi possível carregar o espaço do professor';

  @override
  String get teacherClassroomsLoadError =>
      'Não conseguimos carregar as salas de aula agora. Deslize para atualizar ou tente novamente.';

  @override
  String get teacherClassroomsLoadTimeout =>
      'As salas de aula estão demorando muito para carregar. Deslize para atualizar ou tente novamente em um momento.';

  @override
  String get teacherClassroomsLoadNetwork =>
      'As salas de aula não conseguiram se conectar agora. Verifique sua conexão e tente novamente.';

  @override
  String get teacherClassroomsSubtitle =>
      'Abra a lista de chamada e gere um código de entrada ao vivo para entrada de alunos.';

  @override
  String get teacherClassroomsNoCohorts =>
      'Nenhuma coorte de sala de aula está vinculada a este professor ainda.';

  @override
  String teacherClassroomsCohort(Object cohortId) {
    return 'Coorte $cohortId';
  }

  @override
  String get teacherClassroomsGeneratingJoinCode => 'Gerando…';

  @override
  String get teacherClassroomsCreateJoinCode => 'Criar código de entrada';

  @override
  String get teacherClassroomsLiveJoinCode => 'Código de entrada ao vivo';

  @override
  String teacherClassroomsExpiresAt(Object value) {
    return 'Expira $value';
  }

  @override
  String get teacherClassroomsRoster => 'Lista de chamada';

  @override
  String get teacherClassroomsNoStudents =>
      'Nenhum aluno está inscrito nesta sala de aula ainda.';

  @override
  String get teacherAttendanceLoadError =>
      'Não conseguimos carregar a frequência agora. Puxe para atualizar ou tente novamente.';

  @override
  String get teacherAttendanceLoadTimeout =>
      'A frequência está demorando muito para carregar. Puxe para atualizar ou tente novamente em um momento.';

  @override
  String get teacherAttendanceLoadNetwork =>
      'A frequência não conseguiu se conectar agora. Verifique sua conexão e tente novamente.';

  @override
  String get teacherAttendanceSubtitle =>
      'Selecione uma sessão ao vivo, marque a sala e salve apenas as linhas alteradas.';

  @override
  String get teacherAttendanceTodaySessions => 'Sessões de hoje';

  @override
  String teacherAttendanceSessionSummary(
    Object cohort,
    Object grade,
    Object date,
    Object period,
  ) {
    return '$cohort • Série $grade • $date • Período $period';
  }

  @override
  String get teacherAttendanceChanged => 'Alterado';

  @override
  String get teacherAttendanceNoteLabel => 'Observação';

  @override
  String get teacherAttendanceSaving => 'Salvando…';

  @override
  String teacherAttendanceSaveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alterações',
      one: '1 alteração',
    );
    return 'Salvar $_temp0';
  }

  @override
  String get teacherAttendanceSaved => 'Frequência salva';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get scheduleRefreshTooFast =>
      'O horário está sendo atualizado rápido demais agora. Espere um momento e tente novamente.';

  @override
  String get scheduleNotOnboarded =>
      'O perfil do aluno ainda não está totalmente configurado, então nenhum horário está disponível ainda.';

  @override
  String get scheduleLoadError => 'Ainda não foi possível carregar o horário.';

  @override
  String get scheduleSelectedDay => 'Dia selecionado';

  @override
  String scheduleClassCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aulas',
      one: '1 aula',
      zero: '0 aulas',
    );
    return '$_temp0';
  }

  @override
  String get scheduleNextUp => 'Próxima';

  @override
  String get scheduleNoMoreClasses => 'Sem mais aulas';

  @override
  String get scheduleNoClassesTitle => 'Não há aulas neste dia';

  @override
  String scheduleNoClassesSubtitle(Object day) {
    return '$day parece livre.';
  }

  @override
  String get scheduleClassFallback => 'Aula';

  @override
  String get scheduleNoSubjectLocation => 'Ainda sem matéria ou local';

  @override
  String get loginTitle => 'Login móvel para estudantes e professores';

  @override
  String get loginSubtitle =>
      'Contas de professor abrem o espaço do professor. Contas de estudante permanecem na experiência do estudante.';

  @override
  String get loginSignIn => 'Entrar';

  @override
  String get loginSigningIn => 'Entrando...';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginPasswordLabel => 'Senha';

  @override
  String get profileNotAvailable => 'Não disponível';

  @override
  String get profileSchoolInfo => 'Informações da escola';

  @override
  String get profileFullName => 'Nome completo';

  @override
  String get profileRole => 'Função';

  @override
  String get profileSchoolId => 'ID da escola';

  @override
  String get profileCohortId => 'ID da turma';

  @override
  String get profileAccountInfo => 'Informações da conta';

  @override
  String get profileUsername => 'Nome de usuário';

  @override
  String get profileUsernameHint => 'your_username';

  @override
  String get profileContactEmail => 'E-mail de contato';

  @override
  String get profileEmailAddress => 'Endereço de e-mail';

  @override
  String get profileEmailHint => 'you@example.com';

  @override
  String get profileBirthday => 'Aniversário';

  @override
  String get profileSecurity => 'Segurança';

  @override
  String get profileSelectBirthday => 'Selecione sua data de nascimento';

  @override
  String get profilePasswordUpdated => 'Senha atualizada';

  @override
  String get profileSave => 'Salvar';

  @override
  String get profileEmptyValue => '—';

  @override
  String get profileChangePassword => 'Alterar senha';

  @override
  String get profileCurrentPassword => 'Senha atual';

  @override
  String get profileNewPassword => 'Nova senha';

  @override
  String get profileConfirmNewPassword => 'Confirmar nova senha';

  @override
  String get profileUpdatePassword => 'Atualizar senha';

  @override
  String get profilePasswordAllFieldsRequired =>
      'Todos os campos são obrigatórios';

  @override
  String get profilePasswordMinLength =>
      'A nova senha deve ter pelo menos 8 caracteres';

  @override
  String get profilePasswordMismatch => 'As senhas não coincidem';

  @override
  String get profilePasswordNotAuthenticated => 'Não autenticado';

  @override
  String get profilePasswordIncorrect => 'A senha atual está incorreta';

  @override
  String get profilePasswordGenericError => 'Algo deu errado. Tente novamente.';

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get editProfileSchool => 'Escola';

  @override
  String get editProfileSchoolPublic => 'Escola pública';

  @override
  String get editProfileGradePublic => 'Série pública';

  @override
  String get editProfileMajors => 'Áreas principais';

  @override
  String get editProfileMajorsPublic => 'Áreas principais públicas';

  @override
  String get editProfileBio => 'Bio';

  @override
  String get editProfileBioPublic => 'Bio pública';

  @override
  String get editProfileStatus => 'Status';

  @override
  String get editProfileStatusPublic => 'Status público';

  @override
  String get classroomsYourClassrooms => 'Suas salas';

  @override
  String get classroomsReorder => 'Reordenar salas';

  @override
  String classroomsCount(Object count) {
    return '$count salas';
  }

  @override
  String get classroomsSearchHint => 'Buscar salas';

  @override
  String get classroomsNoSearchMatches =>
      'Nenhuma sala corresponde à sua busca';

  @override
  String get classroomsClassroomLabel => 'Sala';

  @override
  String get classroomsLoadingLatestMessage =>
      'Carregando a última mensagem...';

  @override
  String get classroomsTapToOpen => 'Toque para abrir a sala';

  @override
  String get classroomsNoMessagesYet => 'Ainda não há mensagens';

  @override
  String get classroomsMessageFallback => 'Mensagem';

  @override
  String get examsLoadError =>
      'Não foi possível carregar provas ou formulários';

  @override
  String get examsAllFilter => 'Todos';

  @override
  String get examsFormsSubtitle =>
      'Revise formulários da turma, janelas de resposta e acompanhamentos publicados pela sua escola.';

  @override
  String get examsOnlySubtitle =>
      'Acompanhe avaliações futuras, contagens regressivas e registros de provas passadas das suas turmas.';

  @override
  String get examsUpcomingStat => 'Próximas provas';

  @override
  String get examsOpenFormsStat => 'Formulários abertos';

  @override
  String get examsCountdownPast => 'Passado';

  @override
  String get examsCountdownTomorrow => 'Amanhã';

  @override
  String examsCountdownInDays(Object days) {
    return 'Em $days dias';
  }

  @override
  String get examsNoExamsPublished => 'Nenhuma prova foi publicada ainda.';

  @override
  String get examsNoFormsPublished => 'Nenhum formulário foi publicado ainda.';

  @override
  String examsNoExamsForFilter(Object subject) {
    return 'Nenhuma prova está disponível para $subject agora.';
  }

  @override
  String examsNoFormsForFilter(Object subject) {
    return 'Nenhum formulário está disponível para $subject agora.';
  }

  @override
  String examsMaterialsCount(Object count) {
    return '$count materiais';
  }

  @override
  String get examsOpenState => 'Aberto';

  @override
  String get examsClosedState => 'Fechado';

  @override
  String examsQuestionsCount(Object count) {
    return '$count perguntas';
  }

  @override
  String examsResponsesCount(Object count) {
    return '$count respostas';
  }

  @override
  String get insightsTrendBaseline => 'Base';

  @override
  String get insightsTrendImproving => 'Melhorando';

  @override
  String get insightsTrendDropping => 'Caindo';

  @override
  String get insightsTrendStable => 'Estável';

  @override
  String get insightsHeadlineIntervention =>
      'A janela de intervenção está aberta';

  @override
  String get insightsHeadlineSignals => 'Vários sinais precisam de ajuste';

  @override
  String get insightsHeadlineMomentum => 'O impulso pode crescer esta semana';

  @override
  String get insightsBodyAttendance =>
      'Proteja a frequência primeiro. Melhor presença agora elevará todos os outros sinais mais rápido.';

  @override
  String insightsBodyWeakTrend(Object subject) {
    return '$subject junto com uma queda na prática é a maior combinação de risco agora. Corrija isso antes de expandir.';
  }

  @override
  String insightsBodyLeverage(Object subject) {
    return '$subject é seu ponto de alavanca. Use isso para ganhar confiança enquanto corrige áreas mais fracas.';
  }

  @override
  String get insightsBodyConsistency =>
      'Continue acumulando sessões curtas e focadas. Os próximos dias importam mais do que um plano perfeito de longo prazo.';

  @override
  String get insightsInterventionScoreTitle => 'Pontuação de intervenção';

  @override
  String insightsInterventionScoreBody(Object count) {
    return '$count sinais ativos estão moldando seu próximo passo.';
  }

  @override
  String get insightsRecoveryPathTitle => 'Caminho mais rápido de recuperação';

  @override
  String get insightsRecoveryPathDefault =>
      'Frequência + consistência primeiro.';

  @override
  String insightsRecoveryPathTopic(Object topic, Object subject) {
    return 'Revise $topic em $subject antes de aumentar a pressão.';
  }

  @override
  String get insightsProjectedDirectionTitle => 'Direção projetada';

  @override
  String insightsProjectedDirectionBody(Object trend) {
    return '$trend com base no comportamento recente de prática de 7 dias contra 30 dias.';
  }

  @override
  String get insightsLoadingTitle => 'Carregando análises';

  @override
  String get insightsLoadingSubtitle => 'Montando seu painel preditivo.';

  @override
  String get insightsNotReadyTitle => 'As análises ainda não estão prontas';

  @override
  String get insightsEmptyTitle => 'Ainda não há análises';

  @override
  String get insightsEmptySubtitle =>
      'Continue usando prática e suas ferramentas escolares para que o ClassMate monte uma visão acadêmica mais clara.';

  @override
  String get insightsGradeAverage => 'Média';

  @override
  String get insightsAccuracy => 'Precisão';

  @override
  String get insightsOpenNova => 'Abrir NOVA';

  @override
  String get insightsOpenNovaPrompt =>
      'Ajude-me a corrigir minha área mais fraca com base nas minhas últimas análises do ClassMate.';

  @override
  String get insightsPredictiveRecoveryPlanTitle =>
      'Plano preditivo de recuperação';

  @override
  String get insightsPracticeNow => 'Praticar agora';

  @override
  String get insightsPredictiveModulesTitle => 'Módulos preditivos';

  @override
  String get insightsPredictiveModulesSubtitle =>
      'Os sinais mais fortes de futuro vindos dos seus dados atuais de estudante.';

  @override
  String get insightsAnnouncementsPressureTitle => 'Pressão dos anúncios';

  @override
  String get insightsAnnouncementsPressureSubtitle =>
      'O mecanismo de anúncios agora alimenta o painel diretamente.';

  @override
  String get insightsAiCoachTitle => 'Resumo do coach de IA';

  @override
  String get insightsAiCoachLoadingSubtitle => 'Carregando orientação de IA.';

  @override
  String get insightsAiCoachUnavailableSubtitle =>
      'A orientação de IA não está disponível para esta conta agora.';

  @override
  String get insightsAskNova => 'Perguntar à NOVA';

  @override
  String get insightsAskNovaPrompt =>
      'Monte para mim um plano de recuperação com base nas minhas últimas análises.';

  @override
  String get insightsAiStudyCoachTitle => 'Coach de estudo com IA';

  @override
  String get insightsSchoolToolsTitle => 'Ferramentas escolares';

  @override
  String get insightsSchoolToolsSubtitle =>
      'Vá direto para as rotas de estudante que mais importam agora.';

  @override
  String get tutorUntitledChat => 'Chat sem título';

  @override
  String get tutorNewChat => 'Novo chat';

  @override
  String tutorFailedToOpenSeededChat(Object error) {
    return 'Não foi possível abrir o chat: $error';
  }

  @override
  String tutorFailedToCreateChat(Object error) {
    return 'Não foi possível criar o chat: $error';
  }

  @override
  String get tutorRenameChatTitle => 'Renomear chat';

  @override
  String get tutorChatNameHint => 'Nome do chat';

  @override
  String get tutorCancel => 'Cancelar';

  @override
  String get tutorHide => 'Ocultar';

  @override
  String get tutorHideChatTitle => 'Ocultar chat';

  @override
  String get tutorHideChatSubtitle => 'Oculta este chat neste dispositivo.';

  @override
  String get tutorHideChatConfirmTitle => 'Ocultar chat?';

  @override
  String get tutorHideChatConfirmBody =>
      'Isso oculta o chat da lista neste dispositivo. A sessão continua no backend.';

  @override
  String get tutorTapToOpenHistory => 'Toque para abrir o histórico';

  @override
  String get tutorAiTutorSubtitle => 'Seu tutor de IA';

  @override
  String get tutorHeroBody =>
      'Histórico real de chat, tópicos mais limpos, acesso mais rápido.';

  @override
  String get tutorStartFreshConversation => 'Começar uma nova conversa';

  @override
  String get tutorSearchHistoryHint => 'Buscar no histórico de chats';

  @override
  String get chatComposerDefaultHint => 'Mensagem';

  @override
  String get chatComposerReplyingToMessage => 'Respondendo à mensagem';

  @override
  String get chatComposerReplyFallback => 'Responder';

  @override
  String get chatComposerMicHint =>
      'Toque para uma nota de voz rápida ou segure para gravar';

  @override
  String get chatComposerRecordingTitle => 'Gravando';

  @override
  String get chatComposerReleaseToSend => 'Solte para enviar';

  @override
  String get chatComposerCancelTitle => 'Cancelar';

  @override
  String get chatComposerLockTitle => 'Bloquear';

  @override
  String get chatComposerSlideLeftToCancel =>
      'Deslize para a esquerda para cancelar';

  @override
  String get chatComposerSlideUpToLock => 'Deslize para cima para bloquear';

  @override
  String get chatComposerReleaseToCancel => 'Solte para cancelar';

  @override
  String get chatComposerKeepSlidingToCancel =>
      'Continue deslizando para cancelar';

  @override
  String get chatComposerReleaseToLock => 'Solte para bloquear';

  @override
  String get chatComposerRelease => 'Soltar';

  @override
  String get chatComposerLock => 'Bloquear';

  @override
  String get chatComposerRecordingPaused => 'Gravação pausada';

  @override
  String get chatComposerRecordingLocked => 'Gravação bloqueada';

  @override
  String get chatComposerResumeHint =>
      'Retome quando estiver pronto para continuar gravando';

  @override
  String get chatComposerLockedHint =>
      'Toque em enviar quando estiver pronto para compartilhar';

  @override
  String get chatContextDismiss => 'Fechar';

  @override
  String get chatContextCopyText => 'Copiar texto';

  @override
  String get chatContextDelete => 'Excluir';

  @override
  String get chatMessageInfoShortTitle => 'Info';

  @override
  String get chatMessageInfoStatus => 'Status';

  @override
  String get chatMessageInfoStatusTime => 'Hora do status';

  @override
  String get chatMessageInfoSentAt => 'Enviado em';

  @override
  String get chatMessageInfoDeliveredAt => 'Entregue em';

  @override
  String get chatMessageInfoSeenAt => 'Visto em';

  @override
  String get chatMessageInfoMessageType => 'Tipo de mensagem';

  @override
  String get chatMessageInfoTextType => 'Texto';

  @override
  String get chatMessageInfoEdited => 'Editado';

  @override
  String get chatMessageInfoForwarded => 'Encaminhado';

  @override
  String get chatMessageInfoVoiceDuration => 'Duração do áudio';

  @override
  String get chatMessageInfoSeenBy => 'Visto por';

  @override
  String get chatMessageInfoDeliveredTo => 'Entregue a';

  @override
  String get chatMessageInfoEmptyBody => '(vazio)';

  @override
  String get chatMessageInfoReadLess => 'Ler menos';

  @override
  String get chatMessageInfoReadMore => 'Ler mais';

  @override
  String get chatMessageInfoSeen => 'Visto';

  @override
  String get chatMessageInfoDelivered => 'Entregue';

  @override
  String get chatMessageInfoNotDelivered => 'Não entregue';

  @override
  String get chatMessageInfoSent => 'Enviado';

  @override
  String get chatMessageInfoPending => 'Pendente';

  @override
  String get chatMessageInfoNotSeen => 'Não visto';

  @override
  String get chatMessageInfoType => 'Tipo';

  @override
  String get chatMessageInfoDuration => 'Duração';

  @override
  String get chatMessageInfoYes => 'Sim';

  @override
  String get chatMessageInfoNo => 'Não';

  @override
  String get chatMessageInfoDeleteState => 'Estado de exclusão';

  @override
  String get chatReactionDetailsTitle => 'Reações';

  @override
  String get chatReactionAddAction => 'Adicionar reação';

  @override
  String get chatReactionEmptyState => 'Ainda não há reações';

  @override
  String get chatReactionSingle => 'Reação';

  @override
  String get chatReactionTapToRemove => 'Toque para remover';

  @override
  String chatReactionYouCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: ' · $count',
      one: '',
    );
    return 'Você$_temp0';
  }

  @override
  String chatReactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reações',
      one: 'Reação',
    );
    return '$_temp0';
  }

  @override
  String get chatEmojiPickerTitle => 'Escolher emoji';

  @override
  String get chatEmojiPickerSearchHint => 'Buscar emoji';

  @override
  String get chatEmojiPickerEmptyState => 'Nenhum emoji encontrado';

  @override
  String get chatCameraTitle => 'Câmera';

  @override
  String get chatCameraUseAction => 'Usar';

  @override
  String get chatCameraGalleryAction => 'Galeria';

  @override
  String chatCameraSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selecionados',
      one: '1 selecionado',
      zero: '0 selecionados',
    );
    return '$_temp0';
  }

  @override
  String get chatMediaPreviewEmptyState => 'Nada para visualizar';

  @override
  String get chatMediaPreviewDrawCropAction => 'Desenhar e recortar';

  @override
  String get chatMediaPreviewRotateLeftAction => 'Girar à esquerda';

  @override
  String get chatMediaPreviewRotateRightAction => 'Girar à direita';

  @override
  String get chatMediaPreviewMirrorAction => 'Espelhar';

  @override
  String get chatMediaPreviewResetAction => 'Redefinir';

  @override
  String get chatMediaPreviewRemoveAction => 'Remover';

  @override
  String get chatMediaPreviewCaptionHint => 'Adicionar uma legenda...';

  @override
  String tutorPlanSelectedPlaceholder(Object plan) {
    return '$plan selecionado. Os pagamentos continuam em modo de placeholder por enquanto.';
  }

  @override
  String get tutorFailedToLoadChats => 'Não foi possível carregar os chats';

  @override
  String get tutorNoChatsYet => 'Ainda não há chats';

  @override
  String get tutorNoChatsMatchSearch => 'Nenhum chat corresponde à sua busca';

  @override
  String get tutorCreateFirstChat => 'Criar o primeiro chat';

  @override
  String get tutorPlansTitle => 'Planos NOVA';

  @override
  String tutorPlansSubtitle(Object model) {
    return 'Baseado nas premissas de custo do $model e em limites mensais rígidos para manter o uso lucrativo.';
  }

  @override
  String get tutorPlanPriceFree => 'Grátis';

  @override
  String tutorPlanPriceMonthly(Object price) {
    return '\$$price/mês';
  }

  @override
  String get tutorPromptsLeft => 'Prompts restantes';

  @override
  String get tutorUploadsLeft => 'Envios restantes';

  @override
  String get tutorVoiceLeft => 'Voz restante';

  @override
  String tutorUsageValue(Object remaining, Object total) {
    return '$remaining/$total';
  }

  @override
  String tutorVoiceUsageValue(Object remaining, Object total) {
    return '$remaining/$total min';
  }

  @override
  String get tutorPaymentMethodsTitle => 'Métodos de pagamento';

  @override
  String tutorPaymentMethodsSubtitle(Object plan) {
    return 'O checkout fica em placeholder até que a conta bancária e o processador do ClassMate estejam ativos. O plano selecionado é $plan.';
  }

  @override
  String get tutorCardCheckoutTitle => 'Pagamento com cartão';

  @override
  String get tutorCardCheckoutSubtitle =>
      'Gateway placeholder para Visa, Mastercard e AmEx.';

  @override
  String get tutorApplePayTitle => 'Apple Pay';

  @override
  String get tutorApplePaySubtitle =>
      'Fluxo de carteira placeholder para iPhone e web.';

  @override
  String get tutorBankTransferTitle => 'Transferência bancária';

  @override
  String get tutorBankTransferSubtitle =>
      'Conta bancária do ClassMate pendente. Os detalhes serão preenchidos quando for aberta.';

  @override
  String get tutorPlanStarterName => 'Starter';

  @override
  String get tutorPlanStarterTagline =>
      'Suficiente para teste e revisão semanal leve.';

  @override
  String get tutorPlanPlusName => 'Plus';

  @override
  String get tutorPlanPlusTagline =>
      'Melhor para um estudante sério que usa a NOVA na maioria dos dias.';

  @override
  String get tutorPlanProName => 'Pro';

  @override
  String get tutorPlanProTagline =>
      'Uso diário intenso, temporada completa de provas e longas sessões de estudo.';

  @override
  String get tutorPlanSchoolSeatName => 'Assento escolar';

  @override
  String get tutorPlanSchoolSeatTagline =>
      'Para implantação por aluno ou membro da equipe dentro de uma escola real.';

  @override
  String tutorPlanBulletPromptsMonthly(Object count) {
    return '$count prompts NOVA por mês';
  }

  @override
  String tutorPlanBulletPromptsPerSeatMonthly(Object count) {
    return '$count prompts NOVA por assento por mês';
  }

  @override
  String tutorPlanBulletUploads(Object count) {
    return '$count envios de imagem ou arquivo';
  }

  @override
  String tutorPlanBulletVoiceMinutes(Object count) {
    return '$count minutos de transcrição de voz';
  }

  @override
  String tutorEstimatedCostCeilingFree(Object cost) {
    return 'Teto estimado de custo: \$$cost/mês';
  }

  @override
  String tutorEstimatedCostCeilingPaid(Object cost, Object margin) {
    return 'Teto estimado de custo: \$$cost/mês • margem $margin%';
  }

  @override
  String tutorTimeMinutesShort(Object count) {
    return '${count}min';
  }

  @override
  String tutorTimeHoursShort(Object count) {
    return '${count}h';
  }

  @override
  String get tutorVoiceMessageFallback => 'Mensagem de voz';

  @override
  String get tutorFileFallback => 'Arquivo';

  @override
  String get tutorCopy => 'Copiar';

  @override
  String get tutorEditMessage => 'Editar mensagem';

  @override
  String get tutorCopied => 'Copiado';

  @override
  String get tutorLoadedIntoComposer => 'Carregado no compositor';

  @override
  String get tutorTakePhoto => 'Tirar foto';

  @override
  String get tutorRecordVideo => 'Gravar vídeo';

  @override
  String get tutorChooseFromGallery => 'Escolher da galeria';

  @override
  String get tutorPreviewTitle => 'Prévia';

  @override
  String get tutorThinking => 'Pensando...';

  @override
  String get tutorDone => 'Concluído.';

  @override
  String get tutorFailedToStreamReply => 'Falha ao transmitir a resposta';

  @override
  String get tutorUnsupportedFilesMessage =>
      'A NOVA suporta imagens, documentos e texto. Arquivos de vídeo e áudio não são suportados aqui.';

  @override
  String get tutorNoAudioCaptured => 'Nenhum áudio capturado.';

  @override
  String get tutorVoiceLimitReachedTitle => 'Limite de voz atingido';

  @override
  String get tutorVoiceLimitReachedMessage =>
      'Seu plano atual da NOVA não tem minutos de voz suficientes para este ciclo de transcrição.';

  @override
  String get tutorTranscriptionFailed =>
      'A transcrição falhou. Tente novamente.';

  @override
  String get tutorMicrophonePermissionRequired =>
      'Permissão de microfone é necessária.';

  @override
  String get tutorPlanLimitReachedTitle => 'Limite do plano NOVA atingido';

  @override
  String get tutorPlanLimitReachedMessage =>
      'A cota mensal de prompts ou uploads do seu plano NOVA atual se esgotou. Escolha um plano superior na tela inicial da NOVA para continuar.';

  @override
  String get tutorSendFailed => 'Falha no envio.';

  @override
  String tutorCurrentPlanUsageSummary(
    Object plan,
    Object prompts,
    Object uploads,
    Object voice,
  ) {
    return 'Plano atual: $plan • $prompts prompts restantes • $uploads envios restantes • $voice minutos de voz restantes';
  }

  @override
  String get tutorReviewPlansInHome => 'Rever planos na tela inicial da NOVA';

  @override
  String get tutorCouldNotOpenAttachment => 'Não foi possível abrir o anexo.';

  @override
  String get tutorAttachmentUnavailable => 'Anexo indisponível.';

  @override
  String get tutorImageUnavailable => 'Imagem indisponível';

  @override
  String get tutorYou => 'Você';

  @override
  String get tutorRegenerate => 'Gerar novamente';

  @override
  String get tutorEmptyStateTitle => 'Comece com uma pergunta real';

  @override
  String get tutorEmptyStateBody =>
      'Peça à NOVA para explicar um conceito, transformar anotações em uma tabela, comparar ideias ou ajudar você a revisar a partir de um arquivo enviado.';

  @override
  String get tutorPromptSuggestionSummarizeNotes =>
      'Resuma minhas anotações da aula';

  @override
  String get tutorPromptSuggestionRevisionTable => 'Faça uma tabela de revisão';

  @override
  String get tutorPromptSuggestionQuizMe =>
      'Faça um quiz comigo sobre este tema';

  @override
  String get tutorMessageNovaHint => 'Mensagem para a NOVA';

  @override
  String get tutorHeaderSubtitleReady =>
      'Respostas estruturadas, tabelas e ajuda de estudo';

  @override
  String get tutorYourNovaPlanTitle => 'Seu plano NOVA';

  @override
  String get tutorYourNovaPlanMessage =>
      'Revise aqui seus limites de prompts, uploads e voz, depois volte para a tela inicial da NOVA se quiser trocar de plano.';

  @override
  String get tutorExplainTitle => 'NOVA Explica';

  @override
  String get classroomsThreadTypeClassroom => 'Sala';

  @override
  String get classroomsThreadTypeGroup => 'Grupo';

  @override
  String get classroomsThreadTypeDirectMessage => 'Mensagem direta';

  @override
  String get classroomsThreadTypeDirectMessageShort => 'DM';

  @override
  String get messagesBlockedPeopleTitle => 'Pessoas bloqueadas';

  @override
  String get messagesStartChatAction => 'Iniciar chat';

  @override
  String messagesLoadFailed(Object error) {
    return 'Falha ao carregar mensagens: $error';
  }

  @override
  String get messagesSearchHint => 'Pesquisar mensagens';

  @override
  String get messagesNoResults => 'Nenhuma mensagem encontrada';

  @override
  String get messagesRequestsSection => 'Solicitações';

  @override
  String get messagesPendingApprovals => 'Aprovações pendentes';

  @override
  String get messagesChatsSection => 'Conversas';

  @override
  String get messagesAllChatsSection => 'Todas as conversas';

  @override
  String messagesConversationCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conversas',
      one: '1 conversa',
    );
    return '$_temp0';
  }

  @override
  String get messagesRequestReviewStatus => 'Revisar';

  @override
  String messagesPeopleLoadFailed(Object error) {
    return 'Falha ao carregar pessoas: $error';
  }

  @override
  String get messagesSearchPeopleHint => 'Pesquisar pessoas';

  @override
  String get messagesNewGroupTitle => 'Novo grupo';

  @override
  String get messagesNewGroupSubtitle => 'Criar um chat em grupo';

  @override
  String get messagesGroupNameHint => 'Nome do grupo';

  @override
  String get messagesCreateGroupAction => 'Criar grupo';

  @override
  String get messagesBlockedPersonFallback => 'essa pessoa';

  @override
  String get messagesUnblockPersonTitle => 'Desbloquear pessoa?';

  @override
  String messagesUnblockPersonBody(Object name) {
    return 'Permitir que $name envie mensagens para você novamente?';
  }

  @override
  String get messagesUnblockAction => 'Desbloquear';

  @override
  String messagesUnblockedToast(Object name) {
    return '$name desbloqueado';
  }

  @override
  String messagesBlockedPeopleLoadFailed(Object error) {
    return 'Falha ao carregar pessoas bloqueadas: $error';
  }

  @override
  String get messagesNoBlockedPeople => 'Nenhuma pessoa bloqueada';

  @override
  String get messagesUnknownUser => 'Usuário desconhecido';

  @override
  String get messagesRequestTitle => 'Solicitação';

  @override
  String messagesRequestLoadFailed(Object error) {
    return 'Falha ao carregar solicitação: $error';
  }

  @override
  String get messagesRequestBannerIncoming => 'Solicitação de mensagem';

  @override
  String get messagesRequestBannerOutgoing => 'Aprovação pendente';

  @override
  String get messagesBlockAction => 'Bloquear';

  @override
  String get messagesApproveAction => 'Aprovar';

  @override
  String get messagesRequestUnlockHint =>
      'O chat será liberado depois que o destinatário aprovar sua primeira mensagem.';

  @override
  String get messagesThreadConversationFallback => 'Conversa';

  @override
  String get messagesThreadLeaveGroupTitle => 'Sair do grupo?';

  @override
  String get messagesThreadLeaveGroupBody =>
      'Você deixará de receber mensagens deste grupo.';

  @override
  String get messagesThreadBlockPersonTitle => 'Bloquear esta pessoa?';

  @override
  String get messagesThreadBlockPersonBody =>
      'Você não poderá mais trocar mensagens com esta pessoa.';

  @override
  String get messagesThreadPersonFallback => 'Pessoa';

  @override
  String get messagesThreadProfileInfoUnavailable =>
      'Informações do perfil indisponíveis';

  @override
  String get messagesThreadParticipants => 'Participantes';

  @override
  String get messagesThreadPeople => 'Pessoas';

  @override
  String get messagesThreadDeleteForMe => 'Excluir para mim';

  @override
  String get messagesThreadDeleteForEveryone => 'Excluir para todos';

  @override
  String get messagesThreadDeleteForEveryoneSubtitle =>
      'Remove para todos os participantes';

  @override
  String get messagesThreadSending => 'Enviando…';

  @override
  String get messagesThreadWaitingForApproval => 'Aguardando aprovação';

  @override
  String get classroomsForwardSearchHint => 'Buscar chats';

  @override
  String get classroomsForwardNewChat => 'Novo chat';

  @override
  String classroomsForwardLoadError(Object error) {
    return 'Não foi possível carregar os chats: $error';
  }

  @override
  String get classroomsForwardNoChatsFound => 'Nenhum chat encontrado';

  @override
  String get classroomsForwardSectionClassrooms => 'Salas';

  @override
  String get classroomsForwardSectionDirectMessages => 'Mensagens diretas';

  @override
  String get classroomsForwardCancel => 'Cancelar';

  @override
  String get classroomsForwardAction => 'Encaminhar';

  @override
  String classroomsForwardCount(Object count) {
    return 'Encaminhar ($count)';
  }

  @override
  String get markRead => 'Marcar como lido';

  @override
  String get markUnread => 'Marcar como não lido';

  @override
  String get markAllRead => 'Marcar tudo como lido';

  @override
  String get filters => 'Filtros';

  @override
  String get source => 'Fonte';

  @override
  String get state => 'Estado';

  @override
  String get allSources => 'Todas as fontes';

  @override
  String get allStates => 'Todos os estados';

  @override
  String get unread => 'Não lido';

  @override
  String get read => 'Lido';

  @override
  String get clear => 'Limpar';

  @override
  String get today => 'Hoje';

  @override
  String get yesterday => 'Ontem';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get earlier => 'Anteriormente';

  @override
  String get openDetails => 'Abrir detalhes';

  @override
  String get total => 'Total';

  @override
  String get local => 'Local';

  @override
  String get server => 'Servidor';

  @override
  String get notificationsSourceSystem => 'Sistema';

  @override
  String get notificationsHeroSubtitleStudent =>
      'Seu centro de notificações para avisos, atualizações do servidor e atividade acadêmica útil em tempo real.';

  @override
  String get notificationsHeroSubtitleTeacher =>
      'Seu centro de notificações do professor para avisos, atualizações do servidor e atividade escolar em tempo real.';

  @override
  String get notificationsFiltersSubtitle =>
      'Filtre por origem ou estado de leitura para priorizar mais rápido.';

  @override
  String get notificationsSearchSourcesHint => 'Buscar origens';

  @override
  String notificationsShowingSummary(Object shown, Object total) {
    return 'Mostrando $shown de $total notificações.';
  }

  @override
  String get notificationsEmptyForAccount =>
      'Nenhuma notificação está disponível para esta conta agora.';

  @override
  String get notificationsEmptyFiltered =>
      'Nenhuma notificação corresponde a estes filtros agora. Limpe os filtros para ver o feed completo.';

  @override
  String get notificationsEmpty => 'Nenhuma notificação está disponível agora.';

  @override
  String get notificationsNewBadge => 'Novo';

  @override
  String get notificationsUnavailable =>
      'Esta notificação não está mais disponível. Atualize a caixa de entrada e tente novamente.';

  @override
  String get notificationsSeverityCritical => 'Crítico';

  @override
  String get notificationsSeverityWarning => 'Aviso';

  @override
  String get notificationsSeverityInfo => 'Info';

  @override
  String get announcementsLoadError =>
      'Não conseguimos carregar os anúncios agora. Puxe para atualizar ou tente novamente.';

  @override
  String get announcementsLoadTimeout =>
      'Os anúncios estão demorando muito para carregar. Puxe para atualizar ou tente novamente em um momento.';

  @override
  String get announcementsLoadNetwork =>
      'Os anúncios não puderam se conectar agora. Verifique sua conexão e tente novamente.';

  @override
  String get announcementsAudienceTeacher => 'professor';

  @override
  String get announcementsAudienceAccount => 'conta';

  @override
  String get announcementsAudienceTeacherWorkspace =>
      'espaço de trabalho do professor';

  @override
  String get announcementsLoadFailedTitle =>
      'Não conseguimos carregar os anúncios';

  @override
  String get announcementsLoadFailedHint =>
      'Puxe para atualizar depois que a conexão estiver estável.';

  @override
  String announcementsHeroSubtitle(Object audience) {
    return 'Anúncios publicados da escola, professor e sistema disponíveis para $audience.';
  }

  @override
  String get announcementsLatestSourceLabel => 'Última fonte';

  @override
  String get announcementsNone => 'Nenhum';

  @override
  String announcementsUnreadCountTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anúncios não lidos',
      one: '1 anúncio não lido',
    );
    return '$_temp0';
  }

  @override
  String get announcementsAllReadTitle => 'Tudo foi lido';

  @override
  String announcementsEmptyForAudience(Object audience) {
    return 'Nenhum anúncio foi publicado para $audience ainda.';
  }

  @override
  String announcementsLatestBody(Object title) {
    return 'Mais recente: $title. Toque para ler o conteúdo completo.';
  }

  @override
  String get announcementsFiltersSubtitle =>
      'Reduza a caixa de entrada por fonte ou por estado de leitura para que você possa se concentrar no que ainda precisa de atenção.';

  @override
  String get announcementsAllAnnouncements => 'Todos os anúncios';

  @override
  String get announcementsSearchStatesHint => 'Não lido / Lido';

  @override
  String announcementsSummarySourceSegment(Object source) {
    return ' de $source';
  }

  @override
  String announcementsSummaryStateSegment(Object state) {
    return ' em $state';
  }

  @override
  String announcementsShowingSummary(
    Object shown,
    Object total,
    Object sourceSegment,
    Object stateSegment,
  ) {
    return 'Mostrando $shown de $total anúncios$sourceSegment$stateSegment.';
  }

  @override
  String get announcementsNoMatchTitle =>
      'Nenhum anúncio corresponde a esses filtros';

  @override
  String get announcementsNoPublishedTitle => 'Nenhum anúncio publicado ainda';

  @override
  String get announcementsNoMatchSubtitle =>
      'Tente uma fonte diferente ou volte para todos os anúncios para trazer mais itens para a visualização.';

  @override
  String get announcementsClearFiltersHint =>
      'Limpe os filtros para ver tudo novamente.';

  @override
  String get announcementsPullToRefreshHint =>
      'Puxe para atualizar após a publicação de uma nova atividade escolar.';

  @override
  String get announcementsInboxTitle => 'Caixa de entrada';

  @override
  String get announcementsInboxSubtitle =>
      'Apenas títulos aparecem aqui para uma verificação rápida. Toque em qualquer item para abrir o conteúdo completo do anúncio.';

  @override
  String get meetingsLoadError =>
      'Não foi possível carregar as reuniões agora. Puxe para atualizar ou tente novamente.';

  @override
  String get meetingsLoadTimeout =>
      'As reuniões estão demorando muito para carregar. Puxe para atualizar ou tente novamente em um momento.';

  @override
  String get meetingsLoadNetwork =>
      'Não foi possível conectar às reuniões agora. Verifique sua conexão e tente novamente.';

  @override
  String get meetingsHeroSubtitle =>
      'Todas as reuniões de sala de aula em uma visualização limpa, com links anexados e uma página de detalhes em tela cheia quando você precisa de contexto.';

  @override
  String get meetingsJoinReadyMetric => 'Pronto para participar';

  @override
  String get meetingsNoLinkMetric => 'Sem link';

  @override
  String get meetingsNoPostedTitle => 'Nenhuma reunião postada ainda';

  @override
  String get meetingsEmptyForAccount =>
      'Nenhuma reunião de sala de aula está disponível para esta conta de aluno agora.';

  @override
  String meetingsLatestBody(Object title, Object updatedAt) {
    return '$title foi atualizado $updatedAt. Abra-o para o link anexado e o contexto da sala de aula.';
  }

  @override
  String get meetingsPullToRefreshHint =>
      'Puxe para baixo para verificar novamente.';

  @override
  String get meetingsFiltersSubtitle =>
      'Refine a lista por assunto ou se a reunião já inclui um link que você pode abrir.';

  @override
  String get meetingsAccessLabel => 'Acesso';

  @override
  String get meetingsAllMeetings => 'Todas as reuniões';

  @override
  String get meetingsAccessReady => 'Pronto para participar';

  @override
  String get meetingsAccessNoLink => 'Sem link';

  @override
  String get meetingsAccessNoLinkYet => 'Sem link ainda';

  @override
  String get meetingsAccessSearchHint =>
      'Pronto para participar / Sem link ainda';

  @override
  String meetingsSummarySubjectSegment(Object subject) {
    return ' para $subject';
  }

  @override
  String meetingsSummaryAccessSegment(Object state) {
    return ' em $state';
  }

  @override
  String meetingsShowingSummary(
    Object shown,
    Object total,
    Object subjectSegment,
    Object accessSegment,
  ) {
    return 'Exibindo $shown de $total reuniões$subjectSegment$accessSegment.';
  }

  @override
  String get meetingsNoMatchTitle =>
      'Nenhuma reunião corresponde a esses filtros';

  @override
  String get meetingsNoMatchSubtitle =>
      'Tente todas as disciplinas ou inclua reuniões sem links para trazer mais resultados para a lista.';

  @override
  String get meetingsListSubtitle =>
      'Toque em qualquer reunião para abrir a visualização de detalhes em tela cheia e pular para seu link anexado quando disponível.';

  @override
  String meetingsDateTimeValue(Object date, Object time) {
    return '$date • $time';
  }

  @override
  String meetingsSharedByValue(Object name) {
    return 'Compartilhado por $name';
  }

  @override
  String get meetingsPreviewFallback =>
      'Abra esta reunião para ver o link anexado e os detalhes mais recentes da sala de aula.';

  @override
  String get meetingsNoValidLinkAttached =>
      'Nenhum link de reunião válido está anexado ainda.';

  @override
  String get meetingsCouldNotOpenLink =>
      'Não foi possível abrir o link da reunião.';

  @override
  String get meetingsNoLinkToCopy =>
      'Nenhum link de reunião para copiar ainda.';

  @override
  String get meetingsLinkCopied => 'Link da reunião copiado.';

  @override
  String get meetingsUnavailableTitle => 'Reunião indisponível';

  @override
  String get meetingsUnavailableSubtitle =>
      'Esta reunião não foi encontrada no feed atual. Pode ter sido removida ou não está disponível offline.';

  @override
  String get meetingsUnavailableHint => 'Volte e atualize a lista de reuniões.';

  @override
  String get meetingsNoLinkAttachedYet => 'Nenhum link anexado ainda';

  @override
  String get meetingsAttachedLinkTitle => 'Link de reunião anexado';

  @override
  String get meetingsAttachedLinkMissingBody =>
      'Esta reunião está visível no seu feed de sala de aula, mas nenhuma URL válida está anexada na carga atual do aluno.';

  @override
  String get meetingsDetailsTitle => 'Detalhes da reunião';

  @override
  String get meetingsDetailsSubtitle =>
      'Tudo o que é relevante para o aluno e está disponível no payload da reunião da sala de aula.';

  @override
  String get meetingsDetailClassroomLabel => 'Sala de aula';

  @override
  String get meetingsSharedByLabel => 'Compartilhado por';

  @override
  String get meetingsIdLabel => 'ID da reunião';

  @override
  String get meetingsAttachedLinkSubtitle =>
      'Use a URL anexada para participar ou copie o link da reunião quando sua sala de aula fornecer um.';

  @override
  String get meetingsOpening => 'Abrindo';

  @override
  String get meetingsOpenLink => 'Abrir link';

  @override
  String get meetingsCopyLink => 'Copiar link';

  @override
  String get meetingsAccessPanelTitle => 'Acesso à reunião';

  @override
  String get meetingsAccessPanelReadyBody =>
      'Abra a URL anexada no seu navegador ou aplicativo de reunião.';

  @override
  String get meetingsJoinAction => 'Participar';

  @override
  String get announcementsDetailLoadFailedHint =>
      'Volte e tente atualizar a caixa de entrada de anúncios.';

  @override
  String get announcementsUnavailableTitle => 'Anúncio indisponível';

  @override
  String announcementsUnavailableSubtitle(Object audience) {
    return 'Este anúncio não está mais disponível no feed publicado para $audience.';
  }

  @override
  String get announcementsUnavailableHint =>
      'Volte para a caixa de entrada para continuar.';

  @override
  String announcementsPublishedReadStateBody(Object audience) {
    return 'Este anúncio foi publicado para $audience e seu estado de leitura é armazenado localmente neste dispositivo.';
  }

  @override
  String get announcementsDetailsTitle => 'Detalhes do anúncio';

  @override
  String get announcementsDetailsSubtitle =>
      'Metadados publicados para este anúncio e seu estado de leitura atual.';

  @override
  String get announcementsSeverityLabel => 'Severidade';

  @override
  String get announcementsCreatedLabel => 'Criado';

  @override
  String get announcementsIdLabel => 'ID do anúncio';

  @override
  String get announcementsFullContentTitle => 'Conteúdo completo';

  @override
  String get announcementsFullContentSubtitle =>
      'O texto completo do anúncio aparece aqui depois que você abre o item na caixa de entrada.';

  @override
  String get announcementsReadStateTitle => 'Estado de leitura';

  @override
  String get announcementsReadStateBodyRead =>
      'Este anúncio está marcado como lido neste dispositivo.';

  @override
  String get announcementsReadStateBodyUnread =>
      'Este anúncio ainda não foi lido neste dispositivo.';

  @override
  String get alertsTitle => 'Alertas';

  @override
  String get alertsSubtitle =>
      'Esta é a página para o que precisa de atenção agora, não apenas atualizações gerais.';

  @override
  String get alertsAttendanceTitle => 'A frequência precisa de atenção';

  @override
  String alertsAttendanceBody(Object rate) {
    return 'Sua taxa de presença é $rate%. Algumas aulas perdidas podem crescer rápido.';
  }

  @override
  String get alertsWeakestSubjectTitle => 'Sinal da matéria mais fraca';

  @override
  String alertsWeakestSubjectBody(Object subject) {
    return '$subject precisa de mais atenção agora com base nas suas notas mais recentes.';
  }

  @override
  String get alertsPracticeWeakAreaTitle => 'Área fraca na prática';

  @override
  String alertsPracticeWeakAreaBody(Object topic, Object subject) {
    return '$topic em $subject é o ponto fraco mais claro agora.';
  }

  @override
  String get alertsPracticeTrendDroppedTitle => 'A tendência da prática caiu';

  @override
  String get alertsPracticeTrendDroppedBody =>
      'Seu desempenho em 7 dias está abaixo da sua linha de base de 30 dias. Vá com calma e revise os fundamentos antes de apertar mais.';

  @override
  String get alertsEmpty =>
      'Tudo está tranquilo agora. Quando algo precisar de atenção urgente, vai aparecer aqui.';

  @override
  String get student => 'Estudante';

  @override
  String get classroomDetailPhoto => 'Foto';

  @override
  String get classroomDetailVoiceNote => 'Nota de voz';

  @override
  String get classroomDetailVideo => 'Vídeo';

  @override
  String get classroomDetailFile => 'Arquivo';

  @override
  String get classroomDetailEmptyValue => '(vazio)';

  @override
  String get classroomDetailAttachmentUnavailable => 'Anexo indisponível.';

  @override
  String get classroomDetailAudioUnavailable => 'Áudio indisponível.';

  @override
  String get classroomDetailCouldNotOpenAttachment =>
      'Não foi possível abrir o anexo.';

  @override
  String get classroomDetailVoiceMessage => 'Mensagem de voz';

  @override
  String get classroomDetailVideoFile => 'Arquivo de vídeo';

  @override
  String get classroomDetailAttachedFile => 'Arquivo anexado';

  @override
  String get classroomDetailAttachment => 'Anexo';

  @override
  String get classroomDetailPinAction => 'Fixar';

  @override
  String get classroomDetailUnpinAction => 'Desafixar';

  @override
  String get classroomDetailMessageInfoTitle => 'Informações da mensagem';

  @override
  String get classroomDetailForwardedSingle => 'Encaminhado';

  @override
  String classroomDetailForwardedMultiple(Object count) {
    return '$count mensagens encaminhadas';
  }

  @override
  String get classroomDetailCannotForwardPending =>
      'Não é possível encaminhar para um chat de solicitação até ser aprovado';

  @override
  String get classroomDetailCouldNotForwardSelected =>
      'Não foi possível encaminhar as mensagens selecionadas';

  @override
  String classroomDetailSelectedCount(Object count) {
    return '$count selecionadas';
  }

  @override
  String classroomDetailDeleteCount(Object count) {
    return 'Excluir ($count)';
  }

  @override
  String get classroomDetailSelectAllTooltip => 'Selecionar tudo';

  @override
  String get classroomDetailCancelTooltip => 'Cancelar';

  @override
  String get classroomDetailMicrophoneAccessTitle =>
      'Acesso ao microfone necessário';

  @override
  String get classroomDetailMicrophoneAccessBody =>
      'Permita o acesso ao microfone em Ajustes -> ClassMate para enviar notas de voz.';

  @override
  String get classroomDetailOpenSettingsAction => 'Abrir ajustes';

  @override
  String classroomDetailForwardTargetNext(Object label) {
    return 'Próximo destino do encaminhamento: $label';
  }

  @override
  String get classroomDetailEditMessageTitle => 'Editar mensagem';

  @override
  String get classroomDetailEditMessageHint => 'Edite sua mensagem...';

  @override
  String get classroomDetailLeaveClassroomTitle => 'Sair da turma?';

  @override
  String get classroomDetailLeaveClassroomBody =>
      'Você será removido desta turma.';

  @override
  String get classroomDetailLeaveAction => 'Sair';

  @override
  String get classroomDetailNoAssignmentsTitle => 'Ainda não há tarefas';

  @override
  String get classroomDetailNoAssignmentsSubtitle =>
      'Esta turma não tem tarefas no momento.';

  @override
  String get classroomDetailAssignmentFallback => 'Tarefa';

  @override
  String get classroomDetailNoMaterialsTitle => 'Ainda não há materiais';

  @override
  String get classroomDetailNoMaterialsSubtitle =>
      'Esta turma não tem materiais no momento.';

  @override
  String get classroomDetailMaterialFallback => 'Material';

  @override
  String get classroomDetailNoMeetingsTitle => 'Ainda não há reuniões';

  @override
  String get classroomDetailNoMeetingsSubtitle =>
      'Esta turma não tem reuniões no momento.';

  @override
  String get classroomDetailMeetingFallback => 'Reunião';

  @override
  String get classroomDetailCouldNotLoadPeople =>
      'Não foi possível carregar as pessoas';

  @override
  String get classroomDetailNoPeopleTitle => 'Ainda não há pessoas';

  @override
  String get classroomDetailNoPeopleSubtitle =>
      'Ninguém está visível nesta turma ainda.';

  @override
  String get classroomDetailTabChat => 'Chat';

  @override
  String get classroomDetailTabMaterials => 'Materiais';

  @override
  String get classroomDetailTabPeople => 'Pessoas';

  @override
  String get classroomChatMediaSendPhoto => 'Enviar foto';

  @override
  String get classroomChatMediaSendPhotoSubtitle =>
      'Compartilhe uma imagem no chat da turma';

  @override
  String get classroomChatMediaSendVoiceMessage => 'Enviar mensagem de voz';

  @override
  String get classroomChatMediaSendVoiceMessageSubtitle =>
      'Grave e envie uma nota de voz';

  @override
  String get classroomDetailCouldNotLoadTab =>
      'Não foi possível carregar a aba';

  @override
  String get classroomDetailDeletedByYou => 'Você excluiu esta mensagem';

  @override
  String get classroomDetailDeletedMessage => 'Esta mensagem foi excluída';

  @override
  String get practiceSetupDifficultyEasy => 'Fácil';

  @override
  String get practiceSetupDifficultyMedium => 'Médio';

  @override
  String get practiceSetupDifficultyHard => 'Difícil';

  @override
  String get practiceSetupDifficultyOlympiad => 'Olimpíada';

  @override
  String get practiceSetupDifficultyAdaptive => 'Adaptativo';

  @override
  String get practiceSetupModeLabelPractice => 'Prática';

  @override
  String get practiceSetupModeLabelFlashcards => 'Flashcards';

  @override
  String get practiceSetupModeLabelSpeedRound => 'Rodada rápida';

  @override
  String get practiceSetupModeLabelExamPrep => 'Preparação para prova';

  @override
  String get practiceSetupModeLabelConceptBuilder => 'Construtor de conceitos';

  @override
  String get practiceSetupModeLabelAdaptive => 'Adaptativo';

  @override
  String get practiceSetupModeLabelBagrut => 'Bagrut';

  @override
  String get practiceSetupModeSubtitlePractice => 'Prática diária equilibrada';

  @override
  String get practiceSetupModeSubtitleFlashcards => 'Revelar e lembrar sozinho';

  @override
  String get practiceSetupModeSubtitleSpeedRound => 'Treino rápido sob pressão';

  @override
  String get practiceSetupModeSubtitleExamPrep => 'Fluxo calmo de estilo prova';

  @override
  String get practiceSetupModeSubtitleConceptBuilder =>
      'Conceito primeiro, resolver depois';

  @override
  String get practiceSetupModeSubtitleAdaptive => 'A dificuldade muda ao vivo';

  @override
  String get practiceSetupModeSubtitleBagrut => 'Estilo oficial rigoroso';

  @override
  String get practiceSetupModeHelpPractice =>
      'Modo equilibrado: resolva, confira, explique e continue.';

  @override
  String get practiceSetupModeHelpFlashcards =>
      'Os flashcards funcionam melhor quando você tenta lembrar antes de revelar.';

  @override
  String get practiceSetupModeHelpSpeedRound =>
      'A rodada rápida treina recuperação veloz. Vá rápido e confie nos bons instintos.';

  @override
  String get practiceSetupModeHelpExamPrep =>
      'A preparação para prova é mais calma e formal, como uma sessão escolar real.';

  @override
  String get practiceSetupModeHelpConceptBuilder =>
      'O construtor de conceitos ensina a ideia primeiro e depois pede que você a aplique.';

  @override
  String get practiceSetupModeHelpAdaptive =>
      'O modo adaptativo muda o nível de desafio com base no seu desempenho.';

  @override
  String get practiceSetupModeHelpBagrut =>
      'O modo Bagrut foca em resolução e revisão rígidas no estilo de prova.';

  @override
  String get practiceSetupModeInfoTitle => 'Como cada modo funciona';

  @override
  String get practiceSetupHeroTitle => 'Iniciar uma sessão';

  @override
  String get practiceSetupHeroSubtitle =>
      'Escolha um modo, tempo e dificuldade.';

  @override
  String get practiceSetupInfiniteLives => 'Vidas infinitas';

  @override
  String practiceSetupLivesCount(Object count) {
    return '$count vidas';
  }

  @override
  String get practiceSetupAiTiming => 'Tempo por IA';

  @override
  String practiceSetupSecondsShort(Object seconds) {
    return '${seconds}s';
  }

  @override
  String practiceSetupQuestionsCount(Object count) {
    return '$count perguntas';
  }

  @override
  String practiceSetupSummarySubject(Object subject) {
    return 'Matéria: $subject';
  }

  @override
  String practiceSetupSummaryTopic(Object topic) {
    return 'Tópico: $topic';
  }

  @override
  String practiceSetupSummaryMode(Object mode) {
    return 'Modo: $mode';
  }

  @override
  String practiceSetupSummaryDifficulty(Object difficulty) {
    return 'Dificuldade: $difficulty';
  }

  @override
  String practiceSetupSummaryQuestions(Object count) {
    return 'Perguntas: $count';
  }

  @override
  String practiceSetupSummaryTiming(Object timing) {
    return 'Tempo: $timing';
  }

  @override
  String practiceSetupSummaryLives(Object lives) {
    return 'Vidas: $lives';
  }

  @override
  String get practiceSetupSectionSubjectTopic => 'Matéria e tópico';

  @override
  String get practiceSetupFieldSubject => 'Matéria';

  @override
  String get practiceSetupFieldSubjectHint => 'Escolha a matéria';

  @override
  String get practiceSetupChooseSubject => 'Escolher matéria';

  @override
  String get practiceSetupFieldCustomSubject => 'Matéria personalizada';

  @override
  String get practiceSetupFieldCustomSubjectHint =>
      'Digite sua própria matéria';

  @override
  String get practiceSetupDialogCustomSubjectTitle => 'Matéria personalizada';

  @override
  String get practiceSetupDialogEnterSubject => 'Digite a matéria';

  @override
  String get practiceSetupUseAction => 'Usar';

  @override
  String get practiceSetupFieldTopic => 'Tópico';

  @override
  String get practiceSetupFieldTopicHint => 'Escolha um subtópico';

  @override
  String get practiceSetupChooseTopic => 'Escolher tópico';

  @override
  String get practiceSetupFieldCustomTopic => 'Tópico personalizado';

  @override
  String get practiceSetupFieldCustomTopicHint => 'Digite seu próprio tópico';

  @override
  String get practiceSetupDialogCustomTopicTitle => 'Tópico personalizado';

  @override
  String get practiceSetupDialogEnterTopic => 'Digite o tópico';

  @override
  String get practiceSubjectMath => 'Matemática';

  @override
  String get practiceSubjectPhysics => 'Física';

  @override
  String get practiceSubjectComputerScience => 'Ciência da Computação';

  @override
  String get practiceSubjectChemistry => 'Química';

  @override
  String get practiceSubjectBiology => 'Biologia';

  @override
  String get practiceSubjectEnglish => 'Inglês';

  @override
  String get practiceSubjectArabic => 'Árabe';

  @override
  String get practiceSubjectHebrew => 'Hebraico';

  @override
  String get practiceSubjectGeneralKnowledge => 'Cultura geral';

  @override
  String get practiceTopicAllTopics => 'Todos os tópicos';

  @override
  String get practiceTopicAlgebra => 'Álgebra';

  @override
  String get practiceTopicLinearEquations => 'Equações lineares';

  @override
  String get practiceTopicQuadraticEquations => 'Equações quadráticas';

  @override
  String get practiceTopicFunctions => 'Funções';

  @override
  String get practiceTopicGeometry => 'Geometria';

  @override
  String get practiceTopicTriangles => 'Triângulos';

  @override
  String get practiceTopicCircles => 'Círculos';

  @override
  String get practiceTopicAnalyticGeometry => 'Geometria analítica';

  @override
  String get practiceTopicTrigonometry => 'Trigonometria';

  @override
  String get practiceTopicProbability => 'Probabilidade';

  @override
  String get practiceTopicStatistics => 'Estatística';

  @override
  String get practiceTopicSequences => 'Sequências';

  @override
  String get practiceTopicCalculus => 'Cálculo';

  @override
  String get practiceTopicLimits => 'Limites';

  @override
  String get practiceTopicDerivatives => 'Derivadas';

  @override
  String get practiceTopicMechanics => 'Mecânica';

  @override
  String get practiceTopicKinematics => 'Cinemática';

  @override
  String get practiceTopicNewtonLaws => 'Leis de Newton';

  @override
  String get practiceTopicForces => 'Forças';

  @override
  String get practiceTopicEnergy => 'Energia';

  @override
  String get practiceTopicMomentum => 'Momento';

  @override
  String get practiceTopicElectricity => 'Eletricidade';

  @override
  String get practiceTopicElectricField => 'Campo elétrico';

  @override
  String get practiceTopicCircuits => 'Circuitos';

  @override
  String get practiceTopicWaves => 'Ondas';

  @override
  String get practiceTopicOptics => 'Ótica';

  @override
  String get practiceTopicThermodynamics => 'Termodinâmica';

  @override
  String get practiceTopicConditions => 'Condições';

  @override
  String get practiceTopicBooleanLogic => 'Lógica booleana';

  @override
  String get practiceTopicIfElse => 'Se / Senão';

  @override
  String get practiceTopicNestedConditions => 'Condições aninhadas';

  @override
  String get practiceTopicLoops => 'Laços';

  @override
  String get practiceTopicVariables => 'Variáveis';

  @override
  String get practiceTopicArrays => 'Arrays';

  @override
  String get practiceTopicStrings => 'Cadeias de texto';

  @override
  String get practiceTopicAlgorithms => 'Algoritmos';

  @override
  String get practiceTopicComplexity => 'Complexidade';

  @override
  String get practiceTopicRecursion => 'Recursão';

  @override
  String get practiceTopicAtoms => 'Átomos';

  @override
  String get practiceTopicPeriodicTable => 'Tabela periódica';

  @override
  String get practiceTopicChemicalBonds => 'Ligações químicas';

  @override
  String get practiceTopicReactions => 'Reações';

  @override
  String get practiceTopicStoichiometry => 'Estequiometria';

  @override
  String get practiceTopicAcidsAndBases => 'Ácidos e bases';

  @override
  String get practiceTopicOrganicChemistry => 'Química orgânica';

  @override
  String get practiceTopicCells => 'Células';

  @override
  String get practiceTopicGenetics => 'Genética';

  @override
  String get practiceTopicHumanBody => 'Corpo humano';

  @override
  String get practiceTopicEcology => 'Ecologia';

  @override
  String get practiceTopicEvolution => 'Evolução';

  @override
  String get practiceTopicSystems => 'Sistemas';

  @override
  String get practiceTopicGrammar => 'Gramática';

  @override
  String get practiceTopicReadingComprehension => 'Compreensão de leitura';

  @override
  String get practiceTopicVocabulary => 'Vocabulário';

  @override
  String get practiceTopicTenses => 'Tempos verbais';

  @override
  String get practiceTopicWriting => 'Escrita';

  @override
  String get practiceTopicRhetoric => 'Retórica';

  @override
  String get practiceSetupSectionMode => 'Modo';

  @override
  String get practiceSetupSectionDifficulty => 'Dificuldade';

  @override
  String get practiceSetupSectionControls => 'Controles da sessão';

  @override
  String get practiceSetupQuestionsTitle => 'Perguntas';

  @override
  String get practiceSetupQuestionsCaption =>
      'Quantas perguntas geradas incluir';

  @override
  String get practiceSetupTimingTitle => 'Tempo';

  @override
  String get practiceSetupTimingCaption =>
      'Escolha primeiro o escopo, depois IA, seu tempo ou infinito.';

  @override
  String get practiceSetupTimingScopePerQuestion => 'Por pergunta';

  @override
  String get practiceSetupTimingScopeWholeQuiz => 'Quiz inteiro';

  @override
  String get practiceSetupTimingModeAi => 'IA';

  @override
  String get practiceSetupTimingModeMyTime => 'Meu tempo';

  @override
  String get practiceSetupTimingModeInfinite => 'Infinito';

  @override
  String get practiceSetupTimingCustomPerQuestionTitle =>
      'Segundos por pergunta';

  @override
  String get practiceSetupTimingCustomPerQuestionCaption =>
      'Seu próprio cronômetro para cada pergunta';

  @override
  String get practiceSetupTimingCustomQuizMinutesTitle => 'Minutos do quiz';

  @override
  String get practiceSetupTimingCustomQuizMinutesCaption =>
      'Seu próprio cronômetro para o quiz inteiro';

  @override
  String get practiceSetupInfiniteLivesTitle => 'Vidas infinitas';

  @override
  String get practiceSetupInfiniteLivesSubtitle =>
      'Nunca termine a sessão por causa de respostas erradas';

  @override
  String get practiceSetupLivesTitle => 'Vidas';

  @override
  String get practiceSetupLivesCaption =>
      'Erros permitidos antes do fim da sessão';

  @override
  String get practiceSetupTooltipHistory => 'Histórico de prática';

  @override
  String get practiceHistoryTitle => 'Histórico de prática';

  @override
  String get practiceHistoryClearTooltip => 'Limpar histórico';

  @override
  String get practiceHistoryClearConfirmTitle => 'Limpar histórico de prática?';

  @override
  String get practiceHistoryClearConfirmBody =>
      'Isto remove todas as sessões de prática guardadas neste dispositivo.';

  @override
  String get practiceHistoryLoadError =>
      'Não foi possível carregar o histórico de prática neste momento.';

  @override
  String get practiceHistoryErrorPrefix => 'Erro:';

  @override
  String get practiceHistoryEmpty => 'Nenhuma sessão de prática ainda.';

  @override
  String get practiceHistoryDeleteConfirmTitle => 'Eliminar esta sessão?';

  @override
  String get practiceHistoryDeleteConfirmBody =>
      'Isto remove apenas esta sessão de prática guardada.';

  @override
  String get practiceHistoryOpenReview => 'Abrir revisão';

  @override
  String get practiceHistoryDeleteSession => 'Eliminar sessão';

  @override
  String get practiceHistoryDebugTitle => 'Depuração do histórico de prática';

  @override
  String get practiceAnalyticsTitle => 'Análises de prática';

  @override
  String get practiceAnalyticsSectionOverall => 'Geral';

  @override
  String get practiceAnalyticsRecentSessionsTitle => 'Sessões recentes';

  @override
  String practiceAnalyticsRecentSessionsSummary(
    Object sessions,
    Object correct,
    Object answered,
    Object accuracy,
    Object xp,
  ) {
    return '$sessions sessões • $correct/$answered corretas • $accuracy% • XP $xp';
  }

  @override
  String get practiceAnalyticsSectionWeakestTopics => 'Tópicos mais fracos';

  @override
  String get practiceAnalyticsSectionStrongestTopics => 'Tópicos mais fortes';

  @override
  String get practiceAnalyticsSectionModePerformance => 'Desempenho por modo';

  @override
  String get practiceAnalyticsNoTopicData => 'Ainda não há dados de tópicos';

  @override
  String get practiceAnalyticsNoModeData => 'Ainda não há dados de modo';

  @override
  String get savedQuestionsTopSubjectNone => 'Nada ainda';

  @override
  String get savedQuestionsHeroSubtitle =>
      'As questões que você salvou durante a prática devem ser fáceis de revisitar. Esta página é o hub de tentativa limpa para elas.';

  @override
  String get savedQuestionsSavedMetric => 'Salvo';

  @override
  String get savedQuestionsTopSubjectMetric => 'Principais assuntos';

  @override
  String get savedQuestionsQuickActionsSubtitle =>
      'Volte direto à prática ou procure soluções da comunidade.';

  @override
  String get savedQuestionsOpenPractice => 'Abrir prática';

  @override
  String get savedQuestionsOpenPracticeSubtitle =>
      'Inicie uma nova sessão e continue construindo impulso';

  @override
  String get savedQuestionsOpenSolutions => 'Abrir soluções';

  @override
  String get savedQuestionsOpenSolutionsSubtitle =>
      'Procure soluções enviadas por assunto, livro, página e questão';

  @override
  String get savedQuestionsQueueTitle => 'Sua fila salva';

  @override
  String get savedQuestionsQueueSubtitle =>
      'As questões que você salva na prática aparecem aqui para que você possa reabri-las rapidamente e continuar trabalhando seus pontos fracos.';

  @override
  String get savedQuestionsEmptyTitle => 'Nenhuma questão salva ainda';

  @override
  String get savedQuestionsEmptySubtitle =>
      'Salve uma questão da prática para revisitá-la mais tarde, abra soluções relacionadas e acompanhe os assuntos que ainda precisam de trabalho.';

  @override
  String get savedQuestionsClearAction => 'Limpar questões salvas';

  @override
  String get savedQuestionsWhyItWorks => 'Por que funciona';

  @override
  String savedQuestionsHoursTarget(Object count) {
    return '$count h meta';
  }

  @override
  String savedQuestionsMinutesTarget(Object count) {
    return '$count min meta';
  }

  @override
  String savedQuestionsSecondsTarget(Object count) {
    return '$count seg meta';
  }

  @override
  String get practiceSetupTooltipAnalytics => 'Análises de prática';

  @override
  String get practiceSetupStopGenerating => 'Parar geração';

  @override
  String get practiceSetupGenerating => 'Gerando...';

  @override
  String get practiceSetupStartSession => 'Iniciar sessão';

  @override
  String get practiceSetupSearchHint => 'Pesquisar...';

  @override
  String get practiceSessionModeDescriptionPractice =>
      'Resolução equilibrada com verificação e feedback instantâneos.';

  @override
  String get practiceSessionModeDescriptionFlashcards =>
      'Modo focado em memória para recordação rápida e retenção.';

  @override
  String get practiceSessionModeDescriptionSpeedRound =>
      'Repetições rápidas, leves e cronometradas sob pressão.';

  @override
  String get practiceSessionModeDescriptionExamPrep =>
      'Resolução com clima formal de prova e menos gamificação.';

  @override
  String get practiceSessionModeDescriptionConceptBuilder =>
      'Entenda a ideia primeiro e depois resolva com contexto.';

  @override
  String get practiceSessionModeDescriptionAdaptive =>
      'A dificuldade muda conforme seu desempenho.';

  @override
  String get practiceSessionModeDescriptionBagrut =>
      'Fluxo formal de Bagrut com uma única questão.';

  @override
  String get practiceSessionLoadingPractice => 'Montando sua sessão de prática';

  @override
  String get practiceSessionLoadingFlashcards => 'Embaralhando seus flashcards';

  @override
  String get practiceSessionLoadingSpeedRound => 'Iniciando a rodada rápida';

  @override
  String get practiceSessionLoadingExamPrep => 'Preparando sua sessão de prova';

  @override
  String get practiceSessionLoadingConceptBuilder =>
      'Carregando o coach de conceitos';

  @override
  String get practiceSessionLoadingAdaptive => 'Personalizando seu desafio';

  @override
  String get practiceSessionLoadingBagrut =>
      'Preparando seu conjunto de Bagrut';

  @override
  String get practiceSessionLoadingDefault => 'Preparando sua sessão';

  @override
  String practiceSessionCompleteTitle(Object mode) {
    return '$mode concluído';
  }

  @override
  String get practiceSessionMetricAnswered => 'Respondidas';

  @override
  String get practiceSessionMetricCorrect => 'Corretas';

  @override
  String get practiceSessionMetricWrong => 'Erradas';

  @override
  String get practiceSessionMetricAccuracy => 'Precisão';

  @override
  String get practiceSessionMetricTotal => 'Total';

  @override
  String get practiceSessionMetricXp => 'XP';

  @override
  String get practiceSessionMetricStreak => 'Sequência';

  @override
  String get practiceSessionReviewLayoutStacked => 'Empilhado';

  @override
  String get practiceSessionReviewLayoutFocus => 'Foco';

  @override
  String get practiceSessionFilterAll => 'Todas';

  @override
  String get practiceSessionFilterWrong => 'Erradas';

  @override
  String get practiceSessionFilterCorrect => 'Corretas';

  @override
  String get practiceSessionReviewTitle => 'Revisão da sessão';

  @override
  String get practiceSessionNoQuestionsForFilter =>
      'Nenhuma pergunta corresponde a este filtro ainda.';

  @override
  String get practiceSessionNoAnswer => 'Sem resposta';

  @override
  String get practiceSessionUnknownAnswer => 'Desconhecida';

  @override
  String get practiceSessionReflectionTitle => 'Reflexão';

  @override
  String get practiceSessionReflectionKnewIt => 'Eu sabia';

  @override
  String get practiceSessionReflectionReviewAgain => 'Rever novamente';

  @override
  String get practiceSessionBackOfCard => 'Verso do cartão';

  @override
  String get practiceSessionYourAnswer => 'Sua resposta';

  @override
  String get practiceSessionCorrectAnswer => 'Resposta correta';

  @override
  String get practiceSessionExplanation => 'Explicação';

  @override
  String get practiceSessionBackToSetup => 'Voltar à configuração';

  @override
  String get practiceSessionGeneralTopic => 'Geral';

  @override
  String practiceSessionQuestionProgress(Object current, Object total) {
    return 'Pergunta $current de $total';
  }

  @override
  String get practiceSessionMetricTime => 'Tempo';

  @override
  String practiceSessionMatchmakingDifficulty(Object difficulty) {
    return 'Dificuldade: $difficulty';
  }

  @override
  String get practiceModeActionPrevious => 'Anterior';

  @override
  String get practiceModeActionCheckAnswer => 'Verificar resposta';

  @override
  String get practiceModeActionNext => 'Seguinte';

  @override
  String get practiceModeActionNextQuestion => 'Próxima pergunta';

  @override
  String get practiceModeActionEndSession => 'Terminar sessão';

  @override
  String get practiceModeActionEndQuestion => 'Terminar pergunta';

  @override
  String get practiceModeActionEndExam => 'Terminar exame';

  @override
  String get practiceModeActionNovaHint => 'Dica NOVA';

  @override
  String get practiceModeActionReveal => 'Revelar';

  @override
  String get practiceModeActionShowSolution => 'Mostrar solução';

  @override
  String get practiceModeActionHideSolution => 'Ocultar solução';

  @override
  String get practiceModeActionLockIn => 'Confirmar';

  @override
  String get practiceModeActionCheckAdapt => 'Verificar e adaptar';

  @override
  String get practiceModeActionContinue => 'Continuar';

  @override
  String get practiceModeActionSolveIt => 'Resolver';

  @override
  String get practiceModeActionNextConcept => 'Próximo conceito';

  @override
  String get practiceModeCardFront => 'Frente do cartão';

  @override
  String get practiceModeRecallSummary => 'Resumo de recordação';

  @override
  String get practiceModeFeelingPrompt => 'Como isso pareceu?';

  @override
  String get practiceModeFeelingAgain => 'De novo';

  @override
  String get practiceModeFeelingHard => 'Difícil';

  @override
  String get practiceModeFeelingGood => 'Bom';

  @override
  String get practiceModeFeelingEasy => 'Fácil';

  @override
  String get practiceModeSpeedRoundBanner =>
      'Rodada rápida · decisões rápidas, impulso imediato';

  @override
  String get practiceModeFastFeedback => 'Feedback rápido';

  @override
  String get practiceModeExamPrepBanner =>
      'Preparação para exame · layout mais calmo, respostas revistas após avançar';

  @override
  String get practiceModeReview => 'Revisão';

  @override
  String get practiceModeBagrutBanner =>
      'Modo Bagrut · fluxo em estilo de prova oficial';

  @override
  String get practiceModeOfficialSolution => 'Solução em estilo oficial';

  @override
  String get practiceModeAdaptiveWarmup => 'Dificuldade de aquecimento';

  @override
  String get practiceModeAdaptiveTrendingUp => 'Dificuldade aumentando';

  @override
  String get practiceModeAdaptiveEasingDown => 'Dificuldade diminuindo';

  @override
  String get practiceModeAdaptiveSteady => 'Dificuldade estável';

  @override
  String get practiceModeAdaptiveFeedback => 'Feedback adaptativo';

  @override
  String get practiceModeConceptFirst => 'Conceito primeiro';

  @override
  String get practiceModeNowSolveIt => 'Agora resolva';

  @override
  String get practiceModeConceptTitle => 'Conceito';

  @override
  String get practiceModeFeedbackCorrect => 'Correto';

  @override
  String get practiceModeFeedbackNotQuite => 'Ainda não';

  @override
  String get practiceModeFallbackQuestion => 'Pergunta';

  @override
  String get practiceModeNoExplanationYet =>
      'Ainda não há explicação disponível.';

  @override
  String get teacherGradesAssessmentCreated => 'Avaliação criada';

  @override
  String get teacherGradesEditAssessmentTitle => 'Editar avaliação';

  @override
  String get teacherGradesFieldTitle => 'Título';

  @override
  String get teacherGradesFieldDate => 'Data (YYYY-MM-DD)';

  @override
  String get teacherGradesFieldMaxGrade => 'Nota máxima';

  @override
  String get teacherGradesAssessmentUpdated => 'Avaliação atualizada';

  @override
  String get teacherGradesDeleteAssessmentTitle => 'Excluir avaliação?';

  @override
  String teacherGradesDeleteAssessmentBody(Object title) {
    return 'Isso removerá $title e seu registro de notas do espaço do professor.';
  }

  @override
  String get teacherGradesDeleteAction => 'Excluir';

  @override
  String get teacherGradesAssessmentDeleted => 'Avaliação excluída';

  @override
  String get teacherGradesRosterLinkError =>
      'Esta avaliação não está vinculada a uma lista da turma.';

  @override
  String get teacherGradesSaved => 'Notas salvas';

  @override
  String get teacherGradesSubtitle =>
      'Crie avaliações e salve notas usando a lista de turma ao vivo.';

  @override
  String get teacherGradesCreateAssessmentTitle => 'Criar avaliação';

  @override
  String get teacherGradesFieldCourse => 'Curso';

  @override
  String get teacherGradesCreateAction => 'Criar';

  @override
  String get teacherGradesNoStudentsLoaded =>
      'Nenhum aluno carregado para esta avaliação.';

  @override
  String get teacherGradesFieldGrade => 'Nota';

  @override
  String teacherGradesMaxHint(Object grade) {
    return 'Máx. $grade';
  }

  @override
  String get teacherGradesSaving => 'Salvando…';

  @override
  String teacherGradesSaveCount(Object count) {
    return 'Salvar $count notas';
  }

  @override
  String get assignmentsNoDueDate => 'Sem prazo';

  @override
  String get assignmentsLoadError =>
      'Não conseguimos carregar as tarefas agora. Puxe para atualizar ou tente novamente.';

  @override
  String get assignmentsLoadTimeout =>
      'As tarefas estão demorando muito para carregar. Puxe para atualizar ou tente novamente em um momento.';

  @override
  String get assignmentsLoadNetwork =>
      'Não foi possível conectar as tarefas agora. Verifique sua conexão e tente novamente.';

  @override
  String get assignmentsStatusOverdue => 'Atrasado';

  @override
  String get assignmentsStatusDueSoon => 'Vence em breve';

  @override
  String get assignmentsStatusUpcoming => 'Próximo';

  @override
  String get assignmentsPreviewFallback =>
      'Abra esta tarefa para ver as instruções completas e preparar seu trabalho.';

  @override
  String get assignmentsSubmissionPrepEmpty =>
      'Coloque sua anotação ou arquivos aqui.';

  @override
  String assignmentsSubmissionPrepCount(Object count) {
    return '$count arquivo(s) anexado(s) localmente.';
  }

  @override
  String get assignmentsHeroSubtitle =>
      'Todas as tarefas da sala de aula em uma única visualização clara, com uma página de detalhes em tela inteira e um local dedicado para preparar seu trabalho.';

  @override
  String get assignmentsSubjectsMetric => 'Disciplinas';

  @override
  String get assignmentsNothingAssignedYet => 'Nada atribuído ainda';

  @override
  String get assignmentsNoAssignmentsForAccount =>
      'Nenhuma tarefa de sala de aula está disponível para esta conta de aluno no momento.';

  @override
  String assignmentsNextThingBody(Object title, Object due) {
    return '$title é a próxima coisa a considerar. $due.';
  }

  @override
  String get assignmentsPullToCheckAgain =>
      'Puxe para baixo para verificar novamente.';

  @override
  String get assignmentsFiltersSubtitle =>
      'Restrinja a lista por disciplina ou urgência para se concentrar no que importa em primeiro lugar.';

  @override
  String get assignmentsSubjectLabel => 'Disciplina';

  @override
  String get assignmentsAllSubjects => 'Todas as disciplinas';

  @override
  String get assignmentsSearchSubjects => 'Pesquisar disciplinas';

  @override
  String get assignmentsStatusLabel => 'Status';

  @override
  String get assignmentsAllStatuses => 'Todos os status';

  @override
  String get assignmentsSearchStatuses => 'Pesquisar status';

  @override
  String assignmentsShowingSummary(Object shown, Object total) {
    return 'Mostrando $shown de $total tarefas.';
  }

  @override
  String get assignmentsNoFilterMatchesTitle =>
      'Nenhuma tarefa corresponde a esses filtros';

  @override
  String get assignmentsNoFilterMatchesSubtitle =>
      'Tente todas as disciplinas ou uma visualização de status mais ampla para trazer mais tarefas de volta à lista.';

  @override
  String get assignmentsClearFiltersHint =>
      'Limpe os filtros para ver tudo novamente.';

  @override
  String get assignmentsListSubtitle =>
      'Toque em qualquer tarefa para abrir a visualização de detalhes em tela inteira e preparar seu trabalho.';

  @override
  String get assignmentsAddNoteBeforePrepare =>
      'Adicione uma anotação ou anexe um arquivo antes de preparar seu trabalho.';

  @override
  String get assignmentsWorkDraftPrepared => 'Rascunho de trabalho preparado.';

  @override
  String get assignmentsWorkDraftPreparedWithFiles =>
      'Rascunho de trabalho preparado. Os arquivos anexados são salvos neste dispositivo.';

  @override
  String get assignmentsUnavailableTitle => 'Tarefa indisponível';

  @override
  String get assignmentsUnavailableSubtitle =>
      'Esta tarefa não pôde ser encontrada no feed atual. Pode ter sido removida ou não está disponível offline.';

  @override
  String get assignmentsUnavailableHint =>
      'Volte e atualize a lista de tarefas.';

  @override
  String get assignmentsOverdueBannerBody =>
      'Esta tarefa passou da data de vencimento. Abra sua área de trabalho abaixo para preparar o que você quer enviar.';

  @override
  String get assignmentsWorkAreaBannerBody =>
      'Use a área de trabalho abaixo para organizar arquivos, escrever uma anotação e manter tudo pronto em um único local.';

  @override
  String get assignmentsDetailsSectionTitle => 'Detalhes da tarefa';

  @override
  String get assignmentsDetailsSectionSubtitle =>
      'Tudo que é relevante para o aluno e atualmente disponível na carga da tarefa da sala de aula.';

  @override
  String get assignmentsDetailDueLabel => 'Vencimento';

  @override
  String get assignmentsDetailClassroomLabel => 'Sala de aula';

  @override
  String get assignmentsDetailTeacherLabel => 'Professor';

  @override
  String get assignmentsDetailPostedByLabel => 'Postado por';

  @override
  String get assignmentsDetailPublishedLabel => 'Publicado';

  @override
  String get assignmentsDetailUpdatedLabel => 'Atualizado';

  @override
  String get assignmentsDetailIdLabel => 'ID da tarefa';

  @override
  String get assignmentsInstructionsTitle => 'Instruções';

  @override
  String get assignmentsInstructionsSubtitle =>
      'Texto completo da tarefa do feed da sala de aula, com a redação original preservada.';

  @override
  String get assignmentsYourWorkTitle => 'Seu trabalho';

  @override
  String get assignmentsYourWorkSubtitle =>
      'Organize uma anotação, anexe arquivos ou documentos e mantenha sua preparação de envio em um espaço focado.';

  @override
  String get assignmentsPrivateNoteLabel => 'Anotação de trabalho privada';

  @override
  String get assignmentsPrivateNoteHint =>
      'Adicione o que você planeja enviar, lembretes para si mesmo ou um resumo de documento/link.';

  @override
  String get assignmentsAddFiles => 'Adicionar arquivos ou documentos';

  @override
  String get assignmentsClearFiles => 'Limpar arquivos';

  @override
  String get assignmentsStagedDeviceHint =>
      'Os arquivos são organizados neste dispositivo. O envio de arquivo de tarefa não está disponível neste aplicativo.';

  @override
  String assignmentsLastPrepared(Object time) {
    return 'Preparado pela última vez $time.';
  }

  @override
  String get assignmentsSubmissionPrepTitle => 'Preparação de envio';

  @override
  String get assignmentsPreparing => 'Preparando';

  @override
  String get assignmentsPrepareWork => 'Preparar trabalho';

  @override
  String get assignmentsLoadingSubtitle =>
      'Carregando suas tarefas de sala de aula.';

  @override
  String get assignmentsPullToRefreshRetry =>
      'Puxe para atualizar ou tente novamente abaixo.';

  @override
  String get assignmentsFileSizeUnknown => 'Arquivo';

  @override
  String get assignmentsRemoveAttachment => 'Remover anexo';

  @override
  String get attendanceUndated => 'Sem data';

  @override
  String get attendanceLoadError =>
      'Não conseguimos carregar a presença agora. Puxe para atualizar ou tente novamente.';

  @override
  String get attendanceLoadTimeout =>
      'A presença está demorando muito para carregar. Puxe para atualizar ou tente novamente em um momento.';

  @override
  String get attendanceLoadNetwork =>
      'A presença não conseguiu se conectar agora. Verifique sua conexão e tente novamente.';

  @override
  String get attendanceConsistencyBuilding => 'Ainda em construção';

  @override
  String get attendanceConsistencyExcellent => 'Excelente consistência';

  @override
  String get attendanceConsistencySteady => 'Principalmente consistente';

  @override
  String get attendanceConsistencyNeedsAttention => 'Precisa de atenção';

  @override
  String get attendanceConsistencyRisk => 'Risco de presença';

  @override
  String get attendanceWatchRecentAbsences => 'Ausências recentes';

  @override
  String get attendanceWatchRepeatedLateness => 'Atrasos repetidos';

  @override
  String get attendanceWatchExcusedAddingUp =>
      'Tempo justificado se acumulando';

  @override
  String get attendanceWatchNoFlags => 'Sem sinalizadores atuais';

  @override
  String get attendanceAllSubjectsLowercase => 'todas as disciplinas';

  @override
  String attendanceShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return 'Mostrando $shown de $total marcas para $subject em $range.';
  }

  @override
  String get attendanceDayToneAbsent => 'Dia de ausência';

  @override
  String get attendanceDayToneLate => 'Sinal de atraso';

  @override
  String get attendanceDayToneExcused => 'Presença justificada';

  @override
  String get attendanceDayToneClean => 'Dia limpo';

  @override
  String get attendanceLoadingSubtitle =>
      'Carregando seu resumo de presença mais recente.';

  @override
  String get attendanceUnavailableTitle => 'Presença indisponível';

  @override
  String get attendanceHeroSubtitle =>
      'Uma leitura clara de sua taxa de presença, aulas recentes e qualquer coisa que precise de atenção.';

  @override
  String get attendanceMetricRate => 'Taxa';

  @override
  String get attendanceMetricPresent => 'Marcas de presença';

  @override
  String get attendanceMetricLate => 'Marcas de atraso';

  @override
  String get attendanceMetricAbsent => 'Marcas de ausência';

  @override
  String attendanceHeroSignalBody(Object flag) {
    return '$flag. A pressão de presença pode se acumular silenciosamente, então esta visualização se concentra no que mudou mais recentemente.';
  }

  @override
  String get attendanceNoSummary =>
      'Nenhum resumo de presença está disponível para esta conta de aluno ainda.';

  @override
  String get attendanceEmptyTitle => 'Nenhum registro de presença ainda';

  @override
  String get attendanceEmptySubtitle =>
      'Nenhum registro de presença foi publicado para esta conta de aluno ainda.';

  @override
  String get attendanceFiltersSubtitle =>
      'Use o mesmo estilo de seletor pesquisável como em configurações para estreitar a visualização de presença por disciplina ou período.';

  @override
  String get attendanceTimeRangeLabel => 'Período';

  @override
  String get attendanceSearchRanges =>
      'Todo o tempo / 7 dias / 30 dias / 90 dias';

  @override
  String get attendanceNoFilteredMarksTitle =>
      'Nenhuma marca corresponde a esses filtros';

  @override
  String get attendanceNoFilteredMarksSubtitle =>
      'Tente todas as disciplinas ou um período maior para trazer mais marcas de presença de volta à visualização.';

  @override
  String get attendanceQuickReadTitle => 'Leitura rápida';

  @override
  String get attendanceQuickReadSubtitleFiltered =>
      'Um resumo rápido das marcas de presença filtradas mostradas abaixo.';

  @override
  String get attendanceQuickReadSubtitleAll =>
      'Um resumo rápido com base nos registros de presença mais recentes disponíveis.';

  @override
  String get attendanceSummaryConsistency => 'Consistência';

  @override
  String get attendanceSummaryWatchFor => 'Observe';

  @override
  String get attendanceSummaryExcused => 'Marcas justificadas';

  @override
  String get attendanceSummaryMarksInView => 'Marcas em visualização';

  @override
  String get attendanceSummaryRateInView => 'Taxa em visualização';

  @override
  String get attendanceRecentDaysTitle => 'Dias recentes';

  @override
  String get attendanceRecentDaysSubtitleFiltered =>
      'Agrupado por dia das marcas filtradas atualmente em visualização.';

  @override
  String get attendanceRecentDaysSubtitleAll =>
      'Agrupado por dia para que você possa detectar padrões de ausência ou atraso mais rapidamente.';

  @override
  String get attendanceLessonCountSingle => '1 aula';

  @override
  String attendanceLessonCount(Object count) {
    return '$count aulas';
  }

  @override
  String get attendanceStatusPresent => 'Presente';

  @override
  String get attendanceStatusLate => 'Atrasado';

  @override
  String get attendanceStatusAbsent => 'Ausente';

  @override
  String get attendanceStatusExcused => 'Justificado';

  @override
  String get attendanceStatusRecorded => 'Gravado';

  @override
  String get attendanceLessonFallback => 'Aula';

  @override
  String get attendanceRangeAll => 'Todo o tempo';

  @override
  String get attendanceRange7 => 'Últimos 7 dias';

  @override
  String get attendanceRange30 => 'Últimos 30 dias';

  @override
  String get attendanceRange90 => 'Últimos 90 dias';

  @override
  String get attendanceRangeAllShort => 'Todo o tempo';

  @override
  String get attendanceRange7Short => '7 dias';

  @override
  String get attendanceRange30Short => '30 dias';

  @override
  String get attendanceRange90Short => '90 dias';

  @override
  String get gradesLoadError =>
      'Não foi possível carregar as notas agora. Puxe para atualizar ou tente novamente.';

  @override
  String get gradesLoadTimeout =>
      'As notas estão demorando muito para carregar. Puxe para atualizar ou tente novamente em um momento.';

  @override
  String get gradesLoadNetwork =>
      'As notas não conseguiram conectar agora. Verifique sua conexão e tente novamente.';

  @override
  String get gradesGeneralSubject => 'Geral';

  @override
  String get gradesBandBuilding => 'Ainda em construção';

  @override
  String get gradesBandExcellent => 'Excelente';

  @override
  String get gradesBandStrong => 'Forte';

  @override
  String get gradesBandOkay => 'OK';

  @override
  String get gradesBandNeedsAttention => 'Precisa de atenção';

  @override
  String get gradesBandRisk => 'Em risco';

  @override
  String get gradesTrendRising => 'Crescente';

  @override
  String get gradesTrendDropping => 'Decrescente';

  @override
  String get gradesTrendStable => 'Estável';

  @override
  String gradesShowingSummary(
    Object shown,
    Object total,
    Object subject,
    Object range,
  ) {
    return 'Mostrando $shown de $total notas registradas para $subject em $range.';
  }

  @override
  String get gradesLoadingSubtitle =>
      'Carregando seus resultados acadêmicos mais recentes.';

  @override
  String get gradesUnavailableTitle => 'Notas indisponíveis';

  @override
  String get gradesHeroSubtitle =>
      'Uma visão clara da sua média, avaliações recentes e quais disciplinas precisam de proteção ou recuperação.';

  @override
  String get gradesMetricAverage => 'Média';

  @override
  String get gradesMetricRecorded => 'Registrado';

  @override
  String get gradesMetricBestSubject => 'Melhor disciplina';

  @override
  String get gradesMetricNeedsWork => 'Precisa de trabalho';

  @override
  String gradesLatestSignalBody(
    Object assessment,
    Object subject,
    Object grade,
    Object band,
  ) {
    return '$assessment em $subject recebeu $grade. $band agora.';
  }

  @override
  String get gradesSummaryAvailableNoRecent =>
      'Um resumo de notas está disponível, mas nenhuma avaliação recente é visível nesta visualização ainda.';

  @override
  String get gradesEmptyTitle => 'Nenhuma nota ainda';

  @override
  String get gradesEmptySubtitle =>
      'Nenhuma nota foi publicada para esta conta de aluno ainda.';

  @override
  String get gradesFiltersSubtitle =>
      'Use o mesmo seletor pesquisável como nas configurações para filtrar notas por disciplina ou período.';

  @override
  String get gradesNoFilteredTitle =>
      'Nenhuma nota corresponde a estes filtros';

  @override
  String get gradesNoFilteredSubtitle =>
      'Tente todas as disciplinas ou um período mais amplo para trazer mais notas registradas de volta.';

  @override
  String get gradesQuickReadTitle => 'Leitura rápida';

  @override
  String get gradesQuickReadSubtitleFiltered =>
      'Um resumo rápido das notas atualmente em exibição.';

  @override
  String get gradesQuickReadSubtitleAll =>
      'A leitura mais rápida do que proteger e o que recuperar.';

  @override
  String get gradesWeakSpotLabel => 'Ponto fraco atual';

  @override
  String get gradesNoWeakSignal => 'Sem sinal de disciplina fraca ainda';

  @override
  String gradesWeakSpotValue(Object subject) {
    return '$subject precisa do primeiro bloco de recuperação.';
  }

  @override
  String get gradesStrengthLabel => 'Força atual';

  @override
  String get gradesNoStrengthSignal => 'Sem sinal de disciplina forte ainda';

  @override
  String gradesStrengthValue(Object subject) {
    return '$subject é sua âncora de confiança agora.';
  }

  @override
  String get gradesBandLabel => 'Faixa';

  @override
  String get gradesInViewLabel => 'Em visualização';

  @override
  String gradesInViewCount(Object count) {
    return '$count notas registradas neste filtro.';
  }

  @override
  String gradesInViewAverage(Object count, Object average) {
    return '$count notas registradas com média de $average.';
  }

  @override
  String get gradesLatestAssessmentsTitle => 'Avaliações recentes';

  @override
  String get gradesLatestAssessmentsSubtitleFiltered =>
      'Notas registradas mais recentes na visualização filtrada atual.';

  @override
  String get gradesLatestAssessmentsSubtitleAll =>
      'Notas registradas mais recentes em ordem cronológica.';

  @override
  String get gradesSubjectDrilldownTitle => 'Detalhamento por disciplina';

  @override
  String get gradesSubjectDrilldownSubtitleFiltered =>
      'Agrupado por disciplina para as notas atualmente em exibição.';

  @override
  String get gradesSubjectDrilldownSubtitleAll =>
      'Agrupado por disciplina para que tendência e pressão se destaquem mais rápido.';

  @override
  String get gradesAssessmentFallback => 'Avaliação';

  @override
  String get gradesChipBest => 'Melhor';

  @override
  String get gradesNoAverageYet => 'Sem média ainda';

  @override
  String gradesRecentAverage(Object average) {
    return 'Média recente: $average';
  }
}

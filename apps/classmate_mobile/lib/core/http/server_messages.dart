import '../../l10n/app_localizations.dart';

/// The API answers errors with English developer wording in
/// `{ "message": "…" }`. This maps every message a person can reach from the
/// UI to the app's own string, in the app's language.
///
/// Returns `null` for text the app doesn't know (validation wording like
/// "studentId is required", internal endpoints). Callers decide what to show
/// then — [CMApiException] shows the raw text only in an English UI and a
/// status-based message everywhere else.
String? localizeServerMessage(String raw, AppLocalizations l) {
  final text = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (text.isEmpty) return null;

  // ── Messages that carry a value ──────────────────────────────────────────
  final wait = RegExp(r'^please wait (\d+)s before requesting another code',
          caseSensitive: false)
      .firstMatch(text);
  if (wait != null) {
    return l.errSrvWaitBeforeCode(int.parse(wait.group(1)!));
  }
  final book = RegExp(r'^cannot delete a book that still has (\d+) solution',
          caseSensitive: false)
      .firstMatch(text);
  if (book != null) return l.errSrvBookHasSolutions(int.parse(book.group(1)!));
  final pw = RegExp(r'^password must be at least (\d+) character',
          caseSensitive: false)
      .firstMatch(text);
  if (pw != null) return l.errSrvPasswordTooShort(int.parse(pw.group(1)!));
  final label = RegExp(r'^invalid grade label "(.+?)" for this scale',
          caseSensitive: false)
      .firstMatch(text);
  if (label != null) return l.errSrvInvalidGradeLabel(label.group(1)!);
  final email = RegExp(r'^a user with email "(.+?)" already exists',
          caseSensitive: false)
      .firstMatch(text);
  if (email != null) return l.errSrvEmailOtherSchool(email.group(1)!);
  final user = RegExp(r'^username "(.+?)" is already taken',
          caseSensitive: false)
      .firstMatch(text);
  if (user != null) return l.errSrvUsernameTaken(user.group(1)!);

  final n = text.toLowerCase().replaceAll(RegExp(r'[.!]+$'), '').trim();

  // ── Families recognised by prefix ────────────────────────────────────────
  if (n.startsWith('invalid grade range')) return l.errSrvInvalidGradeRange;
  if (n.startsWith('invalid semester') || n.startsWith('semester months must')) {
    return l.errSrvInvalidSemester;
  }
  if (n.startsWith('semester weights must sum')) return l.errSrvSemesterWeights;
  if (n.startsWith('variant ')) return l.errSrvVariantIncomplete;
  if (n.startsWith('invalid date')) return l.errSrvInvalidDate;
  if (n.startsWith('file type ')) return l.errSrvFileTypeNotAllowed;
  if (n.startsWith('provide at least one grade range')) return l.errSrvAddGradeRange;
  if (n.startsWith('phone must be in e.164') || n == 'newvalue must be in e.164 format') {
    return l.errSrvInvalidPhone;
  }
  if (n.startsWith('ministry sign-in is not enabled')) return l.errSrvMinistryDisabled;
  if (n.startsWith('ministry sign-in') ||
      n.startsWith('ministry profile missing') ||
      n == 'invalid or expired sso state' ||
      n == 'missing code or state') {
    return l.errSrvMinistrySignIn;
  }
  if (n.startsWith('schoolid required')) return l.errSrvNoSchool;
  if (n.startsWith('this endpoint is removed')) return null;

  // ── Exact matches ────────────────────────────────────────────────────────
  switch (n) {
    // school link
    case 'no school associated with this account':
    case 'no school associated with this admin':
    case 'no school is associated with this account':
    case 'no school on account':
    case 'no school context':
    case 'no school':
    case 'your account is not attached to a school':
    case 'admin account is not linked to a school':
      return l.errSrvNoSchool;

    // sign-in
    case 'auth required':
    case 'not authenticated':
    case 'sign-in required':
    case 'missing authenticated user':
    case 'missing user':
    case 'no user':
    case 'missing student identity':
    case 'account no longer exists':
    case 'account not found':
    case 'session expired — please sign in again':
    case 'session expired - please sign in again':
      return l.errSrvSignInRequired;
    case 'student not onboarded':
    case 'student profile not found':
      return l.errSrvNotOnboarded;

    // permissions
    case 'admin only':
    case 'admins only':
    case 'admin or secretary only':
    case 'admin/secretary only':
    case 'admin or teacher only':
    case 'admin/secretary/teacher only':
    case 'staff only':
    case 'teacher only':
    case 'student only':
    case 'parent only':
    case 'only admins can change passwords':
    case 'only admins can export passwords':
    case 'only admins can promote grades':
    case 'only admins can reset cohorts':
    case 'only admins can reset the schedule':
    case 'only an admin can change a role':
    case 'only an admin can change principal settings':
    case 'only teachers and admins can manage books':
    case 'only the platform manager can delete a school':
    case 'schools are provisioned by the platform manager':
    case 'secretaries cannot create user accounts':
    case 'secretaries have read-only access to certificates':
    case 'you can only create student accounts':
    case 'you can only delete student accounts':
    case 'you can only edit student accounts':
    case 'you can only manage your own school':
    case 'not authorized for this cohort':
    case 'teacher not authorized for this cohort':
    case 'not your assessment':
    case 'not your classroom':
    case 'not your cohort':
    case 'not your slot':
    case 'not your notebook':
    case 'not your shelf':
    case 'you can only compute your own averages':
    case 'you can only delete your own averages':
    case 'you can only edit your own averages':
    case 'you can only manage certificates for your homeroom class':
    case 'you can only remove material you added':
    case 'child not linked':
    case 'not linked':
    case 'not linked to this child':
    case 'that period is not in your schedule':
      return l.errSrvNotAllowed;
    case 'cross-school access denied':
    case 'that cohort does not belong to your school':
    case 'that cohort is not in your school':
    case 'this group belongs to a different school':
    case 'this report does not involve your school':
    case 'that period is not in your school':
      return l.errSrvOtherSchool;
    case 'that user already belongs to another school':
    case 'that user does not belong to your school':
    case 'student does not belong to your school':
    case 'none of the specified students belong to your school':
    case 'cannot add users from a different school':
    case 'cannot message users from a different school':
    case 'cannot view profile from another school':
      return l.errSrvUserOtherSchool;

    // codes
    case 'invalid or expired code':
    case 'invalid join code':
    case 'invalid or expired invite code':
    case 'invalid code format':
    case 'this code is not for a group':
    case 'code is required':
    case 'joincode is required':
      return l.errSrvInvalidCode;
    case 'incorrect code':
      return l.errSrvIncorrectCode;
    case 'too many wrong attempts. request a new code':
      return l.errSrvTooManyAttempts;
    case 'no active verification code. request a new one':
      return l.errSrvNoActiveCode;
    case 'new value is the same as the current one':
      return l.errSrvSameValue;
    case 'that email is already in use by another account':
      return l.errSrvEmailInUse;
    case 'newvalue does not match the value this code was issued for':
      return l.errSrvCodeMismatch;
    case 'target is not a valid email address':
    case 'newvalue is not a valid email address':
    case 'email must be a valid email address':
    case 'enter a valid email address':
    case 'valid email required':
      return l.errSrvInvalidEmail;

    // not found
    case 'assignment not found':
    case 'assignment not found or not yours':
      return l.errSrvAssignmentNotFound;
    case 'exam not found':
      return l.errSrvExamNotFound;
    case 'form not found':
      return l.errSrvFormNotFound;
    case 'mail not found':
      return l.errSrvMailNotFound;
    case 'material not found':
      return l.errSrvMaterialNotFound;
    case 'meeting not found':
      return l.errSrvMeetingNotFound;
    case 'message not found':
      return l.errSrvMessageNotFound;
    case 'thread not found':
      return l.errSrvThreadNotFound;
    case 'classroom not found':
    case 'invalid classroom id':
      return l.errSrvClassroomNotFound;
    case 'cohort not found':
    case 'cohort not found for this school':
    case 'homeroom class not found in this school':
    case 'invalid cohortid':
      return l.errSrvCohortNotFound;
    case 'student not found':
    case 'student not found in your school':
    case 'studentid is invalid':
      return l.errSrvStudentNotFound;
    case 'student not in cohort':
      return l.errSrvStudentNotInCohort;
    case 'user not found':
      return l.errSrvUserNotFound;
    case 'school not found':
      return l.errSrvSchoolNotFound;
    case 'certificate not found':
      return l.errSrvCertificateNotFound;
    case 'note not found':
    case 'no such notebook':
      return l.errSrvNoteNotFound;
    case 'report not found':
      return l.errSrvReportNotFound;
    case 'solution not found':
      return l.errSrvSolutionNotFound;
    case 'period not found':
      return l.errSrvPeriodNotFound;
    case 'not found':
    case 'average not found':
    case 'submission not found':
    case 'grade scale not found':
    case 'session not found':
    case 'invalid assessment id':
    case 'invalid assessmentid':
    case 'invalid gradescaleid':
      return l.errSrvNotFound;

    // messaging
    case 'cannot message yourself':
      return l.errSrvMessageYourself;
    case 'cannot report your own message':
      return l.errSrvReportOwnMessage;
    case 'a group needs at least 2 other members':
      return l.errSrvGroupNeedsMembers;
    case 'cannot forward into a non-approved thread':
    case 'request is not approved yet':
      return l.errSrvRequestNotApproved;
    case 'editing media messages is not supported':
      return l.errSrvEditMediaMessage;
    case 'only direct threads can be blocked here':
    case 'only direct threads can be unblocked here':
      return l.errSrvOnlyDirectBlock;
    case 'only group admins can pin messages':
      return l.errSrvOnlyGroupAdminsPin;
    case 'only group threads can be left':
      return l.errSrvOnlyGroupsLeave;
    case 'only group threads can have their title updated':
      return l.errSrvOnlyGroupsRename;
    case 'only groups have invite codes':
      return l.errSrvOnlyGroupsInvite;
    case 'only the receiver can block this request':
      return l.errSrvOnlyReceiverBlock;
    case 'only the sender can delete a message for everyone':
    case 'only the sender can delete for everyone':
      return l.errSrvOnlySenderDelete;
    case 'only the sender can edit this message':
      return l.errSrvOnlySenderEdit;
    case 'only the sender can view recipients':
      return l.errSrvOnlySenderRecipients;
    case 'only your own direct messages can be pinned':
      return l.errSrvOnlyOwnDmPin;
    case 'this user is blocked from the group':
      return l.errSrvBlockedFromGroup;
    case 'thread is blocked':
      return l.errSrvThreadBlocked;
    case 'thread is not a pending request':
      return l.errSrvNotPendingRequest;
    case 'you have been removed from this group':
      return l.errSrvRemovedFromGroup;
    case 'not a member of this thread':
    case 'no access to this thread':
      return l.errSrvNoThreadAccess;
    case 'not a member of this classroom':
      return l.errSrvNotClassroomMember;
    case 'parents can only message their own children':
      return l.errSrvParentsOwnChildren;
    case 'students can only message their own parents':
      return l.errSrvStudentsOwnParents;

    // forms / mail / announcements
    case 'you have already submitted this form':
      return l.errSrvFormAlreadySubmitted;
    case 'pick at least one class':
    case 'pick at least one grade':
    case 'pick at least one person':
      return l.errSrvPickRecipients;
    case 'this audience has no recipients':
      return l.errSrvNoRecipients;
    case 'expiresat must be after publishat':
      return l.errSrvExpiryBeforePublish;
    case 'date is required (yyyy-mm-dd)':
    case 'date cannot be null/empty':
    case 'cohortid and date are required':
      return l.errSrvInvalidDate;

    // teacher / admin data
    case 'grade cannot be negative':
      return l.errSrvGradeNegative;
    case 'add at least one semester':
      return l.errSrvAddSemester;
    case 'add at least two labels (e.g. a, b)':
      return l.errSrvAddTwoLabels;
    case 'at least one valid grade range is required':
      return l.errSrvAddGradeRange;
    case 'at least one variant is required':
      return l.errSrvVariantIncomplete;
    case 'nothing to update':
      return l.errSrvNothingToUpdate;
    case 'no students specified':
    case 'studentids[] is required':
      return l.errSrvNoStudents;
    case 'that class already has a homeroom teacher':
      return l.errSrvHomeroomTaken;
    case 'classroom does not belong to the selected teacher':
      return l.errSrvClassroomNotTeachers;
    case 'link must be a valid url (include https://)':
    case 'url must be a valid url (include https://)':
      return l.errSrvInvalidUrl;
    case 'url or at least one attachment is required':
    case 'title and link are required':
      return l.errSrvLinkOrAttachment;
    case 'at least one file is required':
    case 'at least one file required':
    case 'file is required':
    case 'attachments must be uploaded files':
      return l.errSrvFileRequired;
    case 'only image files are allowed':
    case 'only image uploads are allowed':
      return l.errSrvImagesOnly;
    case 'only image/pdf allowed':
      return l.errSrvImagesOrPdfOnly;
    case 'this file type is not allowed':
      return l.errSrvFileTypeNotAllowed;
    case 'the csv file is empty':
      return l.errSrvCsvEmpty;
    case 'selected book does not exist for this subject':
      return l.errSrvBookNotFound;
    case 'pagenumber must be positive':
    case 'pages must be positive':
      return l.errSrvPagesPositive;

    // accounts
    case 'email already registered':
    case 'that email already has a classnotes account':
      return l.errSrvEmailRegistered;
    case 'incorrect password':
    case 'that is not your current password':
    case 'wrong_password':
      return l.errSrvWrongPassword;
    case 'incorrect email/username or password':
    case 'incorrect email or password':
      return l.errSrvWrongCredentials;
    case 'grade level is required for students':
      return l.errSrvStudentGradeRequired;
    case 'a name is required':
    case 'enter a name':
    case 'name cannot be empty':
    case 'name is required':
    case 'name required':
    case 'full name is required for a new manager':
      return l.errSrvNameRequired;
    case 'email or username is required':
    case 'identifier (email or username) required':
    case 'identifier is required':
    case 'user identifier required':
    case 'email or userid required':
    case 'userid or email required':
      return l.errSrvIdentifierRequired;
    case 'password required':
      return l.errSrvPasswordRequired;
    case 'the platform owner cannot be removed as a manager':
      return l.errSrvOwnerImmutable;
    case 'title is required':
    case 'title required':
    case 'title cannot be empty':
    case 'subject + title required':
      return l.errSrvTitleRequired;
    case 'subject is required':
    case 'subject required':
    case 'subject cannot be empty':
      return l.errSrvSubjectRequired;
    case 'body is required':
    case 'text is required':
    case 'text required':
    case 'missing text':
    case 'content required for text messages':
    case 'text or mediaurl is required':
    case 'no user message':
      return l.errSrvTextRequired;
    case 'a valid year is required':
      return l.errSrvYearRequired;
    case 'period must be 1..20':
    case 'period is required':
      return l.errSrvPeriodInvalid;
    case 'that reset link has expired or already been used':
      return l.errSrvResetLinkExpired;
    case 'model did not return valid json':
      return l.errSrvNovaBadReply;
    case 'nova is not available right now':
    case 'nova is temporarily unavailable':
    case 'support assistant is not available':
      return l.errSrvNovaUnavailable;
  }
  return null;
}

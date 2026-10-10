import 'dart:ui' show Locale;

import 'package:classmate_mobile/core/http/cm_api.dart';
import 'package:classmate_mobile/core/http/server_messages.dart';
import 'package:classmate_mobile/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final he = lookupAppLocalizations(const Locale('he'));

  group('localizeServerMessage', () {
    test('exact text, any case or trailing period', () {
      expect(localizeServerMessage('Student not onboarded', he), he.errSrvNotOnboarded);
      expect(localizeServerMessage('  student NOT onboarded.  ', he), he.errSrvNotOnboarded);
      expect(localizeServerMessage('Invalid or expired code', en), en.errSrvInvalidCode);
    });

    test('families collapse to one message', () {
      for (final raw in [
        'No school associated with this account',
        'No school on account',
        'No school context.',
        'schoolId required — ensure your account is linked to a school',
      ]) {
        expect(localizeServerMessage(raw, he), he.errSrvNoSchool, reason: raw);
      }
      expect(localizeServerMessage('Invalid grade range 3–1. Grades must be 1..20.', he),
          he.errSrvInvalidGradeRange);
    });

    test('values are carried over', () {
      expect(localizeServerMessage('Please wait 30s before requesting another code.', en),
          en.errSrvWaitBeforeCode(30));
      expect(localizeServerMessage('Cannot delete a book that still has 1 solution(s)', en),
          en.errSrvBookHasSolutions(1));
      expect(localizeServerMessage('Password must be at least 8 characters.', en),
          en.errSrvPasswordTooShort(8));
      expect(localizeServerMessage('Invalid grade label "Z" for this scale', en),
          en.errSrvInvalidGradeLabel('Z'));
      expect(
          localizeServerMessage(
              'Username "tony" is already taken by a user in another school. Choose a different username.',
              en),
          en.errSrvUsernameTaken('tony'));
    });

    test('unknown text is not translated', () {
      expect(localizeServerMessage('studentId is required', he), isNull);
      expect(localizeServerMessage('This endpoint is removed. Use /api/parent/notifications', he),
          isNull);
      expect(localizeServerMessage('', he), isNull);
    });
  });

  group('CMApiException.friendlyMessage', () {
    tearDown(() => CMApiException.uiLocale = null);

    CMApiException ex(String message, {int status = 400}) => CMApiException(
          statusCode: status,
          uri: Uri(path: '/x'),
          body: '{"statusCode":$status,"message":"$message"}',
        );

    test('known server text comes out in the UI language', () {
      CMApiException.uiLocale = const Locale('he');
      expect(ex('Student not onboarded').friendlyMessage, he.errSrvNotOnboarded);
      expect(ex('WRONG_PASSWORD').friendlyMessage, he.errSrvWrongPassword);
    });

    test('unknown server text: raw in English, status-based elsewhere', () {
      CMApiException.uiLocale = const Locale('en');
      expect(ex('studentId is required').friendlyMessage, 'studentId is required');
      CMApiException.uiLocale = const Locale('he');
      expect(ex('studentId is required').friendlyMessage, he.errApiBadRequest);
      expect(ex('Nope', status: 404).friendlyMessage, he.errApiNotFound);
    });

    test('technical text never shows, in any language', () {
      CMApiException.uiLocale = const Locale('en');
      expect(ex('Unauthorized', status: 401).friendlyMessage, en.errApiSessionExpired);
      expect(ex('ThrottlerException: Too Many Requests', status: 429).friendlyMessage,
          en.errApiTooManyRequests);
    });
  });
}

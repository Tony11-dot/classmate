import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:classmate_mobile/l10n/app_localizations.dart';

/// Russian has four plural forms, and its "one" form also covers 21, 31, 41…
/// A string written as `=1{1 урок}` therefore showed "1 урок" for 31 lessons.
void main() {
  final l = lookupAppLocalizations(const Locale('ru'));

  test('lesson counts follow Russian grammar', () {
    expect([1, 2, 5, 11, 21, 22, 25, 31].map(l.scheduleClassCount).toList(), [
      '1 урок',
      '2 урока',
      '5 уроков',
      '11 уроков',
      '21 урок',
      '22 урока',
      '25 уроков',
      '31 урок',
    ]);
  });

  test('student counts never print a fixed "1"', () {
    expect(l.gradesHubStudentCount(21), '21 ученик');
    expect(l.gradesHubStudentCount(3), '3 ученика');
    expect(l.messagesPeopleCount(41), '41 человек');
  });

  test('a zero case still reads as words', () {
    expect(l.certCertificateCount(0), 'Нет табелей');
    expect(l.certCertificateCount(24), '24 табеля');
  });

  test('French singular covers zero with the real number', () {
    final fr = lookupAppLocalizations(const Locale('fr'));
    expect(fr.solutionsBookCount(0), '0 livre');
    expect(fr.solutionsBookCount(1), '1 livre');
    expect(fr.solutionsBookCount(3), '3 livres');
  });

  test('form counts agree with the number', () {
    expect(l.teacherFormsCount(1), '1 форма');
    expect(l.teacherFormsCount(3), '3 формы');
    expect(l.teacherFormsCount(5), '5 форм');
  });
}

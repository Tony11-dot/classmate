import 'package:classmate_mobile/core/util/short_name.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('first word of a plain name', () {
    expect(shortName('Noa Shalev'), 'Noa');
    expect(shortName('  Maya  Cohen '), 'Maya');
    expect(shortName('נועה שלו'), 'נועה');
  });

  test('a title keeps the next word', () {
    expect(shortName('Ms. Golan'), 'Ms. Golan');
    expect(shortName('Dr. Mizrahi Avi'), 'Dr. Mizrahi');
  });

  test('edge cases', () {
    expect(shortName(''), '');
    expect(shortName('Mr.'), 'Mr.');
  });
}

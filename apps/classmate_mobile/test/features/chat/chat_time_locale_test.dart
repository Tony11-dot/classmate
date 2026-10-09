import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:classmate_mobile/core/util/bidi.dart';
import 'package:classmate_mobile/features/chat_core/utils/chat_time.dart';

/// Hebrew users saw chat times as "AM 9:07" (English 12-hour, then flipped by
/// the RTL layout) and English messages with the punctuation in front.
void main() {
  final t = DateTime(2026, 10, 9, 9, 7);

  test('English keeps the 12-hour clock, other languages use 24-hour', () {
    expect(formatChatClock(t, locale: 'en'), '9:07 AM');
    expect(formatChatClock(t, locale: 'en_US'), '9:07 AM');
    expect(formatChatClock(t, locale: 'he'), '09:07');
    expect(formatChatClock(t, locale: 'ar'), '09:07');
    expect(formatChatClock(DateTime(2026, 10, 9, 21, 30), locale: 'ru'), '21:30');
  });

  test('a message reads in the direction of its first letter', () {
    expect(firstStrongDirection('Great, see you!', TextDirection.rtl), TextDirection.ltr);
    expect(firstStrongDirection('שלום, מה נשמע?', TextDirection.ltr), TextDirection.rtl);
    expect(firstStrongDirection('مرحبا', TextDirection.ltr), TextDirection.rtl);
    expect(firstStrongDirection('Привет', TextDirection.rtl), TextDirection.ltr);
    expect(firstStrongDirection('12:30 👍', TextDirection.rtl), TextDirection.rtl);
  });

  test('time ranges are isolated left-to-right', () {
    expect(ltrIsolate('08:00–08:45'), '\u{2066}08:00–08:45\u{2069}');
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:classmate_mobile/features/chat_core/ui/chat_message_bubble.dart';
import 'package:classmate_mobile/l10n/app_localizations.dart';

/// The bubble used to strip every comma from the message ("Yes, see you" →
/// "Yes see you") — in classrooms, DMs, NOVA prompts and reply quotes.
void main() {
  testWidgets('message text keeps its commas, reply quote too', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ChatMessageBubble(
              contextForNavigation: context,
              rawText: 'Yes, limits, and derivatives.',
              mediaUrl: '',
              isMine: false,
              showName: true,
              senderLabel: 'Levi, Dan',
              timeLabel: '8:14',
              edited: false,
              reaction: '',
              forwarded: false,
              deleteState: '',
              replySender: 'Cohen, Maya',
              replySnippet: 'Is it due Sunday, or Monday?',
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.textContaining('Yes, limits, and derivatives.', findRichText: true), findsOneWidget);
    expect(find.textContaining('Sunday, or Monday?', findRichText: true), findsOneWidget);
  });
}

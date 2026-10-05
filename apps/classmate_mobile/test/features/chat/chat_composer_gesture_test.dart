import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:classmate_mobile/features/chat_core/ui/chat_composer.dart';
import 'package:classmate_mobile/l10n/app_localizations.dart';

/// Guards the composer's pointer plumbing — the part that broke once already
/// (a visual pill wrapper killed tap-mic → hands-free lock and the classroom
/// composer). The host below mirrors how ChatThreadView drives the composer:
/// finger-down on the mic flips `isRecording` (so the idle row is swapped for
/// the recording HUD MID-gesture) and the composer-level Listener must still
/// deliver the finger-up as `onActiveHoldRelease`, which the thread view turns
/// into "quick tap = lock hands-free".
class _Host extends StatefulWidget {
  const _Host({required this.log});
  final List<String> log;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  final ctrl = TextEditingController();
  final focus = FocusNode();
  bool recording = false;
  bool locked = false;

  @override
  void dispose() {
    ctrl.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final log = widget.log;
    return Scaffold(
      body: Column(
        children: [
          const Expanded(child: SizedBox()),
          ChatComposer(
            controller: ctrl,
            focusNode: focus,
            isRecording: recording,
            isVoiceLocked: locked,
            onSend: () => log.add('send'),
            onCamera: () => log.add('camera'),
            onAttach: () => log.add('attach'),
            onGallery: () => log.add('gallery'),
            onVideo: () => log.add('video'),
            onMic: () => log.add('micTap'),
            onMicPressStart: (_) {
              log.add('pressStart');
              setState(() => recording = true);
            },
            onActiveHoldMove: (_) => log.add('move'),
            onActiveHoldRelease: () {
              log.add('release');
              if (recording) setState(() => locked = true);
            },
            onActiveHoldCancel: () => log.add('cancel'),
          ),
        ],
      ),
    );
  }
}

Future<List<String>> _pumpHost(WidgetTester tester) async {
  final log = <String>[];
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _Host(log: log),
    ),
  );
  await tester.pumpAndSettle();
  return log;
}

/// The recording HUD animates forever (live waveform + pulse dot), so
/// pumpAndSettle would never return — advance a fixed amount instead.
Future<void> _settleHud(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Finder get _mic => find.byIcon(Icons.mic_none_rounded);

void main() {
  testWidgets('quick tap on mic → press start, then release reaches the host',
      (tester) async {
    final log = await _pumpHost(tester);
    expect(_mic, findsOneWidget);

    final g = await tester.startGesture(tester.getCenter(_mic));
    await tester.pump(); // host flips isRecording → HUD swaps in mid-gesture
    await tester.pump(const Duration(milliseconds: 80));
    await g.up();
    await _settleHud(tester);

    expect(log, containsAllInOrder(['pressStart', 'release']));
    expect(log.where((e) => e == 'release'), hasLength(1));
  });

  testWidgets('quick tap on mic ends in the locked (hands-free) HUD',
      (tester) async {
    await _pumpHost(tester);
    final g = await tester.startGesture(tester.getCenter(_mic));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    await g.up();
    await _settleHud(tester);

    // Locked HUD = trash + timer + send. The idle mic is gone.
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    expect(_mic, findsNothing);
  });

  testWidgets('hold + drag on mic streams move events to the host',
      (tester) async {
    final log = await _pumpHost(tester);
    final g = await tester.startGesture(tester.getCenter(_mic));
    await tester.pump();
    await g.moveBy(const Offset(0, -30));
    await tester.pump();
    await g.moveBy(const Offset(-40, 0));
    await tester.pump();
    await g.up();
    await _settleHud(tester);

    expect(log, containsAllInOrder(['pressStart', 'move', 'release']));
  });

  testWidgets('tapping the input focuses it (composer "opens")',
      (tester) async {
    await _pumpHost(tester);
    final field = find.byType(TextField);
    expect(field, findsOneWidget);
    await tester.tap(field);
    await tester.pumpAndSettle();
    final state = tester.state<_HostState>(find.byType(_Host));
    expect(state.focus.hasFocus, isTrue);
  });

  testWidgets('typing swaps mic for send, and send fires', (tester) async {
    final log = await _pumpHost(tester);
    await tester.enterText(find.byType(TextField), 'hello');
    await tester.pumpAndSettle();
    expect(_mic, findsNothing);
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();
    expect(log, contains('send'));
  });

  testWidgets('camera is one tap (Instagram-style leading button)',
      (tester) async {
    final log = await _pumpHost(tester);
    await tester.tap(find.byIcon(Icons.photo_camera_rounded));
    await tester.pumpAndSettle();
    expect(log, contains('camera'));
  });

  testWidgets('+ opens the inline tray (album · camera · files)',
      (tester) async {
    final log = await _pumpHost(tester);
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    final l = AppLocalizations.of(tester.element(find.byType(_Host)))!;
    expect(find.text(l.chatCameraGalleryAction), findsOneWidget);
    expect(find.text(l.commonFiles), findsOneWidget);
    // ⊕ turned into a keyboard key while the tray is open.
    expect(find.byIcon(Icons.keyboard_rounded), findsOneWidget);
    await tester.tap(find.text(l.chatCameraGalleryAction));
    await tester.pumpAndSettle();
    expect(log, contains('gallery'));
    // Picking an action folds the tray away.
    expect(find.text(l.commonFiles), findsNothing);
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.commonFiles));
    await tester.pumpAndSettle();
    expect(log, contains('attach'));
  });

  testWidgets('keyboard key closes the tray', (tester) async {
    await _pumpHost(tester);
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.keyboard_rounded));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    final l = AppLocalizations.of(tester.element(find.byType(_Host)))!;
    expect(find.text(l.commonFiles), findsNothing);
  });

  testWidgets('typing hides the quick actions; clearing brings them back',
      (tester) async {
    await _pumpHost(tester);
    await tester.enterText(find.byType(TextField), 'hi');
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.add_rounded), findsNothing);
    expect(find.byIcon(Icons.photo_camera_rounded), findsOneWidget);
    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    expect(_mic, findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });
}

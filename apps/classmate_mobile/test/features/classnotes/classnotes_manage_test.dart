import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:classmate_mobile/core/config/env.dart';

import 'package:classmate_mobile/features/classnotes/classnotes_export.dart';
import 'package:classmate_mobile/features/classnotes/classnotes_models.dart';
import 'package:classmate_mobile/features/classnotes/classnotes_repository.dart';
import 'package:classmate_mobile/features/classnotes/classnotes_screen.dart';

/// Managing the library from the ClassNotes tab: the covers have to offer the
/// actions, arrange mode has to let you drag, and an export has to produce a real
/// file rather than a promise.
void main() {
  setUpAll(Env.init);

  setUp(() {
    // The tab shows a spinner until auth has restored, so the fake session needs
    // a token — otherwise every pumpAndSettle waits on that animation forever.
    SharedPreferences.setMockInitialValues({'auth_token_v2': 'test-token'});
  });

  CnNotebook book(String id, String title, {String? shelfId, int pages = 3}) =>
      CnNotebook(
        id: id,
        title: title,
        coverColor: const Color(0xFF416835),
        template: CnTemplate.ruled,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 7, 1),
        shelfId: shelfId,
        pageCount: pages,
      );

  final library = CnLibrary(
    shelves: [
      CnShelf(
        id: 's1',
        name: 'Biology',
        color: const Color(0xFF416835),
        icon: Icons.science_outlined,
        sortIndex: 0,
        symbolName: 'flask',
        createdAt: DateTime(2026, 1, 1),
      ),
    ],
    notebooks: [
      book('n1', 'Cell Biology', shelfId: 's1'),
      book('n2', 'Calculus II'),
      book('n3', 'Sketchbook'),
    ],
  );

  Widget harness() => ProviderScope(
        overrides: [
          classNotesLibraryProvider.overrideWith((ref) async => library),
        ],
        child: const MaterialApp(home: Scaffold(body: ClassNotesScreen())),
      );

  testWidgets('every cover offers the manage menu', (tester) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    // One ⋮ per notebook, and the hint that says what it does. (Keyed, because
    // the hint strip carries the same glyph.)
    for (final id in ['n1', 'n2', 'n3']) {
      expect(find.byKey(ValueKey('cn-manage-$id')), findsOneWidget);
    }
    expect(find.textContaining('rename, download or delete'), findsOneWidget);
  });

  testWidgets('the manage menu offers rename, shelf, both exports and delete',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('cn-manage-n1')));
    await tester.pumpAndSettle();

    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Rename'), findsOneWidget);
    expect(find.text('Move to shelf'), findsOneWidget);
    expect(find.text('Download as PDF'), findsOneWidget);
    expect(find.textContaining('PNG'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    // The delete row says plainly that it isn't local to this device.
    expect(find.textContaining('all your devices'), findsOneWidget);
  });

  testWidgets('deleting asks first, and cancelling changes nothing',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('cn-manage-n1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete this notebook?'), findsOneWidget);
    expect(find.textContaining('cannot be undone'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this notebook?'), findsNothing);
  });

  testWidgets('arrange mode turns the grid into a draggable list',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    expect(find.byType(ReorderableListView), findsNothing);
    await tester.tap(find.text('Arrange'));
    await tester.pumpAndSettle();

    expect(find.byType(ReorderableListView), findsOneWidget);
    expect(find.byIcon(Icons.drag_handle_rounded), findsNWidgets(3));
    expect(find.textContaining('Drag to reorder'), findsOneWidget);
    // And back out again.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.byType(ReorderableListView), findsNothing);
  });

  testWidgets('a shelf chip can be long-pressed to manage the shelf',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness());
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Biology'));
    await tester.pumpAndSettle();

    expect(find.text('Rename shelf'), findsOneWidget);
    expect(find.text('Delete shelf'), findsOneWidget);
    // Deleting a shelf must never read as deleting its books.
    expect(find.textContaining('Its notebooks stay'), findsOneWidget);
  });

  group('CnExport', () {
    /// A real 2×2 PNG, so the PDF builder has something it can actually decode
    /// and measure.
    const pngBase64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAEElEQVR4nGP4z8AARAwQCgAf7gP9i18U1AAAAABJRU5ErkJggg==';

    test('builds a PDF with one page per rendered page', () async {
      final pages = [
        const CnPage(pageIndex: 0, dataUrl: 'data:image/png;base64,$pngBase64'),
        const CnPage(pageIndex: 1, dataUrl: 'data:image/png;base64,$pngBase64'),
      ];
      final bytes = await CnExport.buildPdf(pages);
      expect(bytes, isA<Uint8List>());
      expect(bytes.length, greaterThan(400));
      // A real PDF, not an empty buffer.
      expect(utf8.decode(bytes.take(5).toList()), '%PDF-');
    });

    test('a page whose render is missing is skipped, not fatal', () async {
      final pages = [
        const CnPage(pageIndex: 0, dataUrl: ''),
        const CnPage(pageIndex: 1, dataUrl: 'data:image/png;base64,$pngBase64'),
      ];
      final bytes = await CnExport.buildPdf(pages);
      expect(utf8.decode(bytes.take(5).toList()), '%PDF-');
    });

    test('filenames are safe to write and never empty', () {
      expect(CnExport.fileStem('Cell Biology'), 'Cell_Biology');
      expect(CnExport.fileStem('Notes: 2026/07 <draft>'), 'Notes_202607_draft');
      expect(CnExport.fileStem('   '), 'ClassNotes');
      expect(CnExport.fileStem('***'), 'ClassNotes');
    });
  });
}

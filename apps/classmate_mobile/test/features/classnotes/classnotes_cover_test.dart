import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:classmate_mobile/core/config/env.dart';
import 'package:classmate_mobile/features/classnotes/classnotes_models.dart';
import 'package:classmate_mobile/features/classnotes/classnotes_repository.dart';
import 'package:classmate_mobile/features/classnotes/classnotes_screen.dart';

/// The cover a notebook shows here has to be the cover the iPad shows: once the
/// app has rendered its cover page, that render is the tile. Notebooks synced
/// before cover pages existed keep the drawn cover, so nothing goes blank.
void main() {
  setUpAll(Env.init);

  setUp(() {
    SharedPreferences.setMockInitialValues({'auth_token_v2': 'test-token'});
  });

  /// A real (1×1, transparent) PNG, so the decoder has something valid to chew.
  const pngBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAE'
      'hQGAhKmMIQAAAABJRU5ErkJggg==';

  CnNotebook book(String id, String title, {String? coverImage}) => CnNotebook(
        id: id,
        title: title,
        coverColor: const Color(0xFF416835),
        template: CnTemplate.ruled,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 7, 1),
        coverImage: coverImage,
      );

  Widget harness(CnLibrary library) => ProviderScope(
        overrides: [
          classNotesLibraryProvider.overrideWith((ref) async => library),
        ],
        child: const MaterialApp(home: Scaffold(body: ClassNotesScreen())),
      );

  group('CnNotebook cover render', () {
    test('decodes the PNG the iPad synced', () {
      final notebook = book('n1', 'Bio', coverImage: 'data:image/png;base64,$pngBase64');
      final bytes = notebook.coverImageBytes;
      expect(bytes, isNotNull);
      expect(bytes, equals(base64Decode(pngBase64)));
    });

    test('is null when the notebook never synced one', () {
      expect(book('n1', 'Bio').coverImageBytes, isNull);
    });

    test('is null rather than fatal when the payload is unusable', () {
      expect(book('n1', 'Bio', coverImage: 'data:image/png;base64,%%%').coverImageBytes,
          isNull);
      expect(book('n1', 'Bio', coverImage: '').coverImageBytes, isNull);
    });
  });

  testWidgets('a notebook with a render shows it instead of the drawn cover',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness(CnLibrary(
      shelves: const [],
      notebooks: [
        book('n1', 'Cell Biology', coverImage: 'data:image/png;base64,$pngBase64'),
      ],
    )));
    await tester.pumpAndSettle();

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.fit, BoxFit.cover);
    // The title lives inside the artwork now, so it's spoken, not drawn twice.
    expect(image.semanticLabel, 'Cell Biology');
    expect(find.text('Cell Biology'), findsNothing);
  });

  testWidgets('a notebook synced before cover pages keeps the drawn cover',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness(CnLibrary(
      shelves: const [],
      notebooks: [book('n1', 'Calculus II')],
    )));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNothing);
    expect(find.text('Calculus II'), findsOneWidget);
  });
}

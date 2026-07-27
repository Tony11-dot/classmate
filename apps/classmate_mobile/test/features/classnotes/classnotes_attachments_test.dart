import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:classmate_mobile/features/classnotes/classnotes_models.dart';

void main() {
  group('decodeDataUrl', () {
    test('decodes the payload of a data URL', () {
      final payload = base64Encode(utf8.encode('hello notes'));
      final bytes = decodeDataUrl('data:audio/m4a;base64,$payload');
      expect(bytes, isNotNull);
      expect(utf8.decode(bytes!), 'hello notes');
    });

    test('returns null for anything missing or corrupt, so a bad payload degrades',
        () {
      expect(decodeDataUrl(null), isNull);
      expect(decodeDataUrl(''), isNull);
      expect(decodeDataUrl('data:audio/m4a;base64,'), isNull);
      expect(decodeDataUrl('data:audio/m4a;base64,!!!not base64!!!'), isNull);
    });

    test('accepts a bare base64 body with no data: prefix', () {
      final payload = base64Encode(<int>[1, 2, 3]);
      expect(decodeDataUrl(payload), <int>[1, 2, 3]);
    });
  });

  group('CnAttachment', () {
    test('a voice note is playable and openable once it has a payload', () {
      final audio = CnAttachment(
        kind: CnAttachmentKind.audio,
        name: 'Lecture',
        durationSeconds: 42,
        dataUrl: 'data:audio/m4a;base64,${base64Encode(<int>[9, 9])}',
      );
      expect(audio.isPlayable, isTrue);
      expect(audio.isOpenable, isTrue);
      expect(audio.mimeType, 'audio/m4a');
      expect(audio.fileExtension, 'm4a');
      expect(audio.bytes, isNotNull);
    });

    test('a voice note with no payload is neither playable nor openable', () {
      const audio = CnAttachment(kind: CnAttachmentKind.audio, name: 'Empty');
      expect(audio.isPlayable, isFalse);
      expect(audio.isOpenable, isFalse);
      expect(audio.bytes, isNull);
    });

    test('a link is openable from its url, never from a payload', () {
      const link = CnAttachment(
        kind: CnAttachmentKind.link,
        name: 'Revision guide',
        url: 'https://example.com/guide',
      );
      expect(link.isOpenable, isTrue);
      expect(link.isPlayable, isFalse);
      expect(link.bytes, isNull);

      const empty = CnAttachment(kind: CnAttachmentKind.link, name: 'Nowhere');
      expect(empty.isOpenable, isFalse);
    });

    test('file extensions follow the declared MIME type', () {
      String extensionFor(String mime) => CnAttachment(
            kind: CnAttachmentKind.file,
            name: 'f',
            dataUrl: 'data:$mime;base64,${base64Encode(<int>[1])}',
          ).fileExtension;

      expect(extensionFor('application/pdf'), 'pdf');
      expect(extensionFor('image/jpeg'), 'jpg');
      expect(extensionFor('text/csv'), 'csv');
      expect(extensionFor('audio/mpeg'), 'mp3');
      // An unknown type still opens — the system viewer decides what to do.
      expect(extensionFor('application/x-unheard-of'), 'dat');
    });

    test('a malformed data URL falls back to octet-stream', () {
      const broken = CnAttachment(
        kind: CnAttachmentKind.file,
        name: 'f',
        dataUrl: 'not-a-data-url',
      );
      expect(broken.mimeType, 'application/octet-stream');
      expect(broken.fileExtension, 'dat');
    });
  });

  group('CnPage', () {
    test('a page defaults to no attachments, so older syncs still render', () {
      const page = CnPage(pageIndex: 0, dataUrl: 'data:image/png;base64,AA==');
      expect(page.attachments, isEmpty);
    });
  });
}

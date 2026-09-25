import 'dart:typed_data';

/// Mobile/desktop: no browser download. Returns false so callers fall back to
/// their native temp-file + share path.
Future<bool> downloadBytesWeb(
  String filename,
  Uint8List bytes,
  String mime,
) async =>
    false;

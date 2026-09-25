import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Web: build a Blob from [bytes] and click a hidden anchor to trigger the
/// browser's own "Save As" with the given [filename]. Used by the export
/// screens (CSV/PDF) where there is no filesystem to write to.
Future<bool> downloadBytesWeb(
  String filename,
  Uint8List bytes,
  String mime,
) async {
  final parts = <JSAny>[bytes.toJS].toJS;
  final blob = web.Blob(parts, web.BlobPropertyBag(type: mime));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename
    ..style.display = 'none';
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
  return true;
}

/// Triggers a browser "Save As" download of in-memory [bytes] on web.
///
/// Mobile/desktop have a temp dir + native share sheet, so the export screens
/// write a file and hand it to share_plus. Web has neither `dart:io` nor a
/// native share sheet — `getTemporaryDirectory()` throws MissingPluginException
/// (web QA #60/#61), so exports must go straight to a Blob download instead.
///
/// The real implementation lives in `web_download_web.dart` (package:web Blob +
/// anchor click); the mobile stub returns false so callers keep their native
/// path untouched.
library;

export 'web_download_stub.dart'
    if (dart.library.js_interop) 'web_download_web.dart';

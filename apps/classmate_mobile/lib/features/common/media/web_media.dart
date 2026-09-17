import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Web has no temp directory, no native share sheet, and no `dart:io` File —
/// so the mobile "fetch → write temp file → share/open" download path throws
/// on web (MissingPluginException / "Download Failed"). On web the browser is
/// the right tool: opening the asset URL in a new tab lets the user view it
/// inline and use the browser's own Save. This helper returns true only when
/// it handled the request (web); on mobile it returns false so callers keep
/// their existing native path untouched.
Future<bool> openMediaInBrowserOnWeb(String url) async {
  if (!kIsWeb) return false;
  final uri = Uri.tryParse(url.trim());
  if (uri == null || uri.toString().isEmpty) return false;
  // webOnlyWindowName '_blank' opens a new tab; the browser then shows the
  // image/PDF/doc inline with its own download control.
  await launchUrl(uri, webOnlyWindowName: '_blank');
  return true;
}

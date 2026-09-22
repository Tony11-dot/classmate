import 'dart:io';
import 'dart:typed_data';

/// A single piece of media queued to send in a chat.
///
/// Mobile/desktop carry a real filesystem [path]; Flutter **web** carries
/// in-memory [bytes] instead, because `dart:io File` cannot read a browser
/// blob — the whole File-based media pipeline used to throw the moment a
/// picker returned on web (web QA #1–8/#10/#12/#22–30). The upload layer
/// picks `MultipartFile.fromBytes` vs `fromPath` off [hasBytes].
///
/// [previewUrl] renders the optimistic local bubble/draft thumbnail: a file
/// path on mobile (`Image.file`) or a `blob:`/data URL on web (`Image.network`
/// / `Image.memory`).
class OutgoingMedia {
  const OutgoingMedia({
    required this.name,
    this.path,
    this.bytes,
    this.mime,
    this.previewUrl,
  });

  /// Filename used for the multipart upload and for display.
  final String name;

  /// Native filesystem path (mobile). Null on web.
  final String? path;

  /// In-memory bytes (web). Null on mobile.
  final Uint8List? bytes;

  /// MIME type, if known.
  final String? mime;

  /// URL/path for an optimistic local preview before the CDN URL is known.
  final String? previewUrl;

  bool get hasBytes => bytes != null;

  /// Wraps a mobile [File]. Never called on web (no filesystem there).
  factory OutgoingMedia.fromFile(File file, {String? mime}) {
    final p = file.path;
    return OutgoingMedia(
      name: p.split('/').last,
      path: p,
      mime: mime,
      previewUrl: p,
    );
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'classnotes_models.dart';

/// Taking a notebook out of ClassNotes: one PDF of every page, or the pages as
/// PNG images.
///
/// The pages arrive as `data:image/png;base64,…` renders (that's what the iPad
/// uploads), so both exports are assembled here on the client — nothing new is
/// asked of the server.
class CnExport {
  /// A filesystem-safe stem for the notebook's files.
  static String fileStem(String title) {
    final slug = title
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9 _-]+'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return slug.isEmpty ? 'ClassNotes' : slug;
  }

  /// One PDF, one page per notebook page, each sized to its own image so nothing
  /// is cropped or letterboxed.
  static Future<Uint8List> buildPdf(List<CnPage> pages) async {
    final doc = pw.Document();
    for (final page in pages) {
      final bytes = decodeDataUrl(page.dataUrl);
      if (bytes == null || bytes.isEmpty) continue;
      final image = pw.MemoryImage(bytes);
      // Fit each page to the image's aspect ratio at A4 width, so a landscape
      // page comes out landscape. The decoded size is nullable (the PNG header is
      // parsed lazily) — an unreadable one falls back to plain A4 rather than
      // dropping the page.
      final pixelWidth = image.width ?? 0;
      final pixelHeight = image.height ?? 0;
      final width = PdfPageFormat.a4.width;
      final height = pixelWidth > 0 && pixelHeight > 0
          ? width * (pixelHeight / pixelWidth)
          : PdfPageFormat.a4.height;
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(width, height),
          build: (_) => pw.Image(image, fit: pw.BoxFit.contain),
        ),
      );
    }
    return doc.save();
  }

  /// Share / download the notebook as a PDF. `Printing.sharePdf` is the one path
  /// that behaves everywhere: the OS share sheet on iOS/Android, a real file
  /// download in a browser.
  static Future<void> sharePdf({
    required List<CnPage> pages,
    required String title,
    Rect? origin,
  }) async {
    final bytes = await buildPdf(pages);
    await Printing.sharePdf(
      bytes: bytes,
      filename: '${fileStem(title)}.pdf',
      bounds: origin,
    );
  }

  /// Share / download the pages as PNGs.
  ///
  /// On a phone or tablet they go out as files through the share sheet. The web
  /// has no share sheet for arbitrary files in every browser, so each page opens
  /// as an image the viewer can save — and that's why the caller labels this
  /// "Open pages as PNG" on web.
  static Future<void> sharePng({
    required List<CnPage> pages,
    required String title,
    Rect? origin,
  }) async {
    final stem = fileStem(title);
    if (kIsWeb) {
      for (final page in pages) {
        if (page.dataUrl.isEmpty) continue;
        await launchUrl(Uri.parse(page.dataUrl), webOnlyWindowName: '_blank');
      }
      return;
    }
    final dir = await getTemporaryDirectory();
    final files = <XFile>[];
    for (var i = 0; i < pages.length; i++) {
      final bytes = decodeDataUrl(pages[i].dataUrl);
      if (bytes == null || bytes.isEmpty) continue;
      final file = File('${dir.path}/${stem}_${i + 1}.png');
      await file.writeAsBytes(bytes, flush: true);
      files.add(XFile(file.path, mimeType: 'image/png'));
    }
    if (files.isEmpty) return;
    await Share.shareXFiles(files, subject: title, sharePositionOrigin: origin);
  }

  /// The share sheet needs somewhere to point on iPad; without it, iOS throws.
  static Rect? originOf(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    final size = MediaQuery.sizeOf(context);
    return Rect.fromLTWH(size.width / 2, size.height / 2, 1, 1);
  }
}

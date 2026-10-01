import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

/// Fonts for generated PDFs (exports, certificates), bundled in
/// `assets/pdf_fonts/` (SIL OFL 1.1). They used to come from
/// `PdfGoogleFonts`, which downloads them from Google at runtime — sending the
/// user's IP to Google and failing offline. Each face is loaded once and cached.
class PdfFonts {
  PdfFonts._();

  static final Map<String, Future<pw.Font>> _cache = {};

  static Future<pw.Font> _load(String name) => _cache[name] ??= rootBundle
      .load('assets/pdf_fonts/$name.ttf')
      .then((data) => pw.Font.ttf(data));

  static Future<pw.Font> ibmPlexSansRegular() => _load('IBMPlexSans-Regular');
  static Future<pw.Font> ibmPlexSansSemiBold() => _load('IBMPlexSans-SemiBold');
  static Future<pw.Font> ibmPlexSansArabicRegular() => _load('IBMPlexSansArabic-Regular');
  static Future<pw.Font> ibmPlexSansArabicSemiBold() => _load('IBMPlexSansArabic-SemiBold');
  static Future<pw.Font> notoSansRegular() => _load('NotoSans-Regular');
  static Future<pw.Font> notoSansBold() => _load('NotoSans-Bold');
  static Future<pw.Font> notoSansArabicRegular() => _load('NotoSansArabic-Regular');
  static Future<pw.Font> notoSansHebrewRegular() => _load('NotoSansHebrew-Regular');
  static Future<pw.Font> notoSansHebrewBold() => _load('NotoSansHebrew-Bold');
}

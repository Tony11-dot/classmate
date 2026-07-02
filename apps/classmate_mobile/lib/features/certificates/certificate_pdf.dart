import 'dart:typed_data';
import 'dart:ui' show Locale;

import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../l10n/app_localizations.dart';
import 'data/certificates_repository.dart';

/// Everything the certificate PDF needs. Built from the form + prefill data.
class CertificatePdfData {
  CertificatePdfData({
    required this.language,
    required this.schoolName,
    required this.schoolLogoUrl,
    required this.schoolYear,
    required this.studentName,
    required this.nationalId,
    required this.cohortName,
    required this.homeroomTeacher,
    required this.principalName,
    required this.publisherNote,
    required this.subjects,
    required this.overall,
    required this.absences,
    required this.lates,
    required this.semesterCount,
    required this.dateLabel,
    this.semesterOnly = 0,
    this.roundWhole = true,
  });

  final String language; // 'en','ar','he','fr','ru','ps'
  final String schoolName;
  final String? schoolLogoUrl;
  final String schoolYear;
  final String studentName;
  final String nationalId;
  final String cohortName;
  final String homeroomTeacher;
  final String principalName;
  final String publisherNote;
  final List<CertSubjectRow> subjects;
  final double? overall;
  final int absences;
  final int lates;
  final int semesterCount;
  final String dateLabel;

  /// 0 = annual (all semesters). 1..N = an end-of-semester diploma showing only
  /// that semester's column (the others are left blank).
  final int semesterOnly;

  /// true → round-half-up to a whole number; false → two decimals.
  final bool roundWhole;
}

bool _isRtlLang(String lang) => lang == 'ar' || lang == 'he' || lang == 'ps';

Locale _localeFor(String lang) {
  switch (lang) {
    case 'ar':
    case 'he':
    case 'fr':
    case 'ru':
    case 'ps':
    case 'en':
      return Locale(lang);
    default:
      return const Locale('en');
  }
}

/// Build the certificate PDF bytes. Renders fully in [data.language] with the
/// correct direction, multi-script glyph shaping, embedded logos and a rounded,
/// modern layout that spotlights the school.
Future<Uint8List> buildCertificatePdf(CertificatePdfData data) async {
  final l = lookupAppLocalizations(_localeFor(data.language));
  final rtl = _isRtlLang(data.language);

  // Premium, modern type: IBM Plex Sans (Latin) + IBM Plex Sans Arabic, with a
  // lighter SemiBold used as the "bold" weight so headings read clean, not heavy.
  // The base font follows the certificate language so the primary script SHAPES
  // correctly (a fallback-only Arabic font renders detached/reversed glyphs).
  final latin = await PdfGoogleFonts.iBMPlexSansRegular();
  final latinSemi = await PdfGoogleFonts.iBMPlexSansSemiBold();
  final arabicReg = await PdfGoogleFonts.iBMPlexSansArabicRegular();
  final arabicSemi = await PdfGoogleFonts.iBMPlexSansArabicSemiBold();
  final hebrewReg = await PdfGoogleFonts.notoSansHebrewRegular();
  final hebrewBold = await PdfGoogleFonts.notoSansHebrewBold();

  final cmLogo = pw.MemoryImage(
    (await rootBundle.load('assets/images/icon_light.png')).buffer.asUint8List(),
  );

  pw.MemoryImage? schoolLogo;
  final logoUrl = (data.schoolLogoUrl ?? '').trim();
  if (logoUrl.isNotEmpty) {
    try {
      final res = await http.get(Uri.parse(logoUrl)).timeout(const Duration(seconds: 12));
      if (res.statusCode >= 200 && res.statusCode < 300 && res.bodyBytes.isNotEmpty) {
        schoolLogo = pw.MemoryImage(res.bodyBytes);
      }
    } catch (_) {
      schoolLogo = null;
    }
  }

  final pw.Font baseFont, boldFont;
  final List<pw.Font> fontFallback;
  if (data.language == 'ar') {
    baseFont = arabicReg;
    boldFont = arabicSemi;
    fontFallback = [latin, latinSemi, hebrewReg, hebrewBold];
  } else if (data.language == 'he') {
    baseFont = hebrewReg;
    boldFont = hebrewBold;
    fontFallback = [latin, latinSemi, arabicReg, arabicSemi];
  } else {
    baseFont = latin;
    boldFont = latinSemi;
    fontFallback = [arabicReg, arabicSemi, hebrewReg, hebrewBold];
  }

  final theme = pw.ThemeData.withFont(
    base: baseFont,
    bold: boldFont,
    fontFallback: fontFallback,
  );
  final doc = pw.Document(theme: theme);

  const brandBlue = PdfColor.fromInt(0xFF2563EB);
  const brandDeep = PdfColor.fromInt(0xFF1E3A5F);
  const line = PdfColor.fromInt(0xFFE2E8F0);
  const softBg = PdfColor.fromInt(0xFFF9FBFF);
  const headerBg = PdfColor.fromInt(0xFFEFF4FF);
  const radius = pw.Radius.circular(18);

  // ── Number formatting per the rounding toggle ──────────────────────────────
  String fmt(double? v) {
    if (v == null) return '—';
    if (data.roundWhole) {
      // Round-half-up: <.5 down, ≥.5 up.
      return (v + 0.5).floor().toString();
    }
    return v.toStringAsFixed(2);
  }

  // Unified certificate — no annual vs. semester distinction. Always render
  // every semester column plus the final; cells with no grade stay empty ("—").
  final semIndexes = List<int>.generate(data.semesterCount, (i) => i);

  double? subjectFinal(CertSubjectRow s) => s.finalAvg;

  double? overall() => data.overall;

  final title = l.certPdfAnnualCertificate;

  // ── Sections ───────────────────────────────────────────────────────────────
  pw.Widget roundedBox({required pw.Widget child, PdfColor? color, PdfColor? border, pw.EdgeInsets? padding}) {
    return pw.Container(
      width: double.infinity,
      padding: padding ?? const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.all(radius),
        border: border != null ? pw.Border.all(color: border, width: 0.8) : null,
      ),
      child: child,
    );
  }

  // Clean, white, diploma-style masthead: the school logo and name sit side by
  // side, centred, on top — then a slim brand rule and the certificate title.
  // No letterSpacing anywhere (it breaks Arabic letter-joining).
  pw.Widget header() {
    final logo = schoolLogo;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (logo != null) ...[
              pw.SizedBox(width: 70, height: 70, child: pw.Image(logo, fit: pw.BoxFit.contain)),
              pw.SizedBox(width: 16),
            ],
            pw.Flexible(
              child: pw.Text(
                data.schoolName,
                style: pw.TextStyle(fontSize: 29, fontWeight: pw.FontWeight.bold, color: brandDeep),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 14),
        pw.Container(width: 130, height: 2, color: brandBlue),
        pw.SizedBox(height: 12),
        pw.Text(
          '$title  ·  ${data.schoolYear}',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(fontSize: 13, color: brandBlue, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget infoCell(String label, String value) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9, color: brandBlue, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 2),
          pw.Text(value.isEmpty ? '—' : value, style: const pw.TextStyle(fontSize: 11)),
        ],
      );

  pw.Widget studentBlock() {
    final cells = <pw.Widget>[
      pw.Expanded(child: infoCell(l.certPdfName, data.studentName)),
      pw.Expanded(child: infoCell(l.certPdfClass, data.cohortName)),
      if (data.nationalId.trim().isNotEmpty) pw.Expanded(child: infoCell(l.certPdfNationalId, data.nationalId)),
      pw.Expanded(child: infoCell(l.certPdfDate, data.dateLabel)),
    ];
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 14),
      child: roundedBox(color: softBg, border: line, child: pw.Row(children: cells)),
    );
  }

  // Grades table with rounded outer corners (clipped).
  pw.Widget gradesTable() {
    pw.Widget th(String t, {pw.TextAlign align = pw.TextAlign.center}) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: pw.Text(t,
              textAlign: align,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: brandDeep)),
        );
    pw.Widget td(String t, {pw.TextAlign align = pw.TextAlign.center, bool bold = false}) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          child: pw.Text(t,
              textAlign: align,
              style: pw.TextStyle(fontSize: 10, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        );

    final startAlign = rtl ? pw.TextAlign.right : pw.TextAlign.left;
    final header = pw.TableRow(
      decoration: const pw.BoxDecoration(color: headerBg),
      children: [
        th(l.certPdfSubject, align: startAlign),
        th(l.certPdfTeacher, align: startAlign),
        for (final i in semIndexes) th(l.adminSchoolSemesterN('${i + 1}')),
        th(l.certPdfFinal),
      ],
    );
    final rows = <pw.TableRow>[header];
    var striped = false;
    for (final s in data.subjects) {
      striped = !striped;
      rows.add(pw.TableRow(
        decoration: pw.BoxDecoration(color: striped ? softBg : PdfColors.white),
        children: [
          td(s.display(data.language), align: startAlign, bold: true),
          td(s.teachers.join(rtl ? '، ' : ', '), align: startAlign),
          for (final i in semIndexes) td(i < s.semesters.length ? fmt(s.semesters[i]) : '—'),
          td(fmt(subjectFinal(s)), bold: true),
        ],
      ));
    }
    rows.add(pw.TableRow(
      decoration: const pw.BoxDecoration(color: headerBg),
      children: [
        td(l.certPdfOverall, align: startAlign, bold: true),
        td(''),
        for (final _ in semIndexes) td(''),
        td(fmt(overall()), bold: true),
      ],
    ));

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16),
      decoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(radius),
        border: pw.Border.all(color: line, width: 0.8),
      ),
      child: pw.ClipRRect(
        horizontalRadius: 18,
        verticalRadius: 18,
        child: pw.Table(
          border: pw.TableBorder(
            horizontalInside: const pw.BorderSide(color: line, width: 0.6),
            verticalInside: const pw.BorderSide(color: line, width: 0.6),
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(2.4),
            1: const pw.FlexColumnWidth(2.0),
            for (int i = 2; i <= semIndexes.length + 2; i++) i: const pw.FlexColumnWidth(1.1),
          },
          children: rows,
        ),
      ),
    );
  }

  pw.Widget attendanceRow() {
    pw.Widget stat(String label, String value) => pw.Expanded(
          child: pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 4),
            padding: const pw.EdgeInsets.symmetric(vertical: 12),
            decoration: pw.BoxDecoration(
              color: softBg,
              borderRadius: const pw.BorderRadius.all(radius),
              border: pw.Border.all(color: line, width: 0.8),
            ),
            child: pw.Column(children: [
              pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: brandDeep)),
              pw.SizedBox(height: 2),
              pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
            ]),
          ),
        );
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16),
      child: pw.Row(children: [
        stat(l.certPdfAbsences, '${data.absences}'),
        stat(l.certPdfLateness, '${data.lates}'),
      ]),
    );
  }

  pw.Widget remarks() => pw.Container(
        margin: const pw.EdgeInsets.only(top: 16),
        child: roundedBox(
          color: softBg,
          border: line,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(l.certPdfRemarks,
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: brandBlue)),
              pw.SizedBox(height: 4),
              pw.Text(data.publisherNote, style: const pw.TextStyle(fontSize: 11)),
            ],
          ),
        ),
      );

  pw.Widget signatures() {
    pw.Widget sig(String role, String name) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(width: 140, height: 0.8, color: brandDeep),
            pw.SizedBox(height: 4),
            pw.Text(name.isEmpty ? '—' : name, style: const pw.TextStyle(fontSize: 11)),
            pw.Text(role, style: pw.TextStyle(fontSize: 9, color: brandBlue)),
          ],
        );
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 34),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          sig(l.certPdfHomeroomTeacher, data.homeroomTeacher),
          sig(l.certPdfPrincipal, data.principalName),
        ],
      ),
    );
  }

  pw.Widget footer() => pw.Container(
        margin: const pw.EdgeInsets.only(top: 18),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // No italic: IBM Plex Sans Arabic has no italic face, so italic
            // Arabic renders as tofu boxes. Keep it upright.
            pw.Text(l.certPdfGeneratedBy, style: pw.TextStyle(fontSize: 8, color: brandBlue)),
            pw.SizedBox(width: 6),
            pw.SizedBox(width: 13, height: 13, child: pw.Image(cmLogo, fit: pw.BoxFit.contain)),
            pw.SizedBox(width: 4),
            pw.Text('ClassMate', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: brandBlue)),
          ],
        ),
      );

  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(38, 34, 38, 34),
        textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        theme: theme,
        // Thin rounded diploma frame around the whole (white) page.
        buildBackground: (context) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: brandBlue, width: 1.4),
                borderRadius: pw.BorderRadius.circular(24),
              ),
            ),
          ),
        ),
      ),
      build: (context) => [
        header(),
        studentBlock(),
        gradesTable(),
        attendanceRow(),
        if (data.publisherNote.trim().isNotEmpty) remarks(),
        signatures(),
        footer(),
      ],
    ),
  );

  return doc.save();
}

/// Preview / share / print the certificate.
Future<void> shareCertificatePdf(Uint8List bytes, String filename) async {
  await Printing.sharePdf(bytes: bytes, filename: filename);
}

Future<void> printCertificatePdf(Uint8List bytes) async {
  await Printing.layoutPdf(onLayout: (_) async => bytes);
}

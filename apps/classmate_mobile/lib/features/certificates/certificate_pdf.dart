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

  // Fonts: Latin/Cyrillic base + Arabic + Hebrew, regular AND bold, so mixed
  // scripts and bold headings all render with no tofu boxes.
  final baseFont = await PdfGoogleFonts.notoSansRegular();
  final baseBold = await PdfGoogleFonts.notoSansBold();
  final arabicReg = await PdfGoogleFonts.notoSansArabicRegular();
  final arabicBold = await PdfGoogleFonts.notoSansArabicBold();
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

  final doc = pw.Document(
    theme: pw.ThemeData.withFont(
      base: baseFont,
      bold: baseBold,
      fontFallback: [arabicReg, arabicBold, hebrewReg, hebrewBold],
    ),
  );

  const brandBlue = PdfColor.fromInt(0xFF2563EB);
  const brandDeep = PdfColor.fromInt(0xFF1E3A5F);
  const line = PdfColor.fromInt(0xFFE2E8F0);
  const softBg = PdfColor.fromInt(0xFFF6F9FF);
  const headerBg = PdfColor.fromInt(0xFFEFF4FF);
  const radius = pw.Radius.circular(14);

  // ── Number formatting per the rounding toggle ──────────────────────────────
  String fmt(double? v) {
    if (v == null) return '—';
    if (data.roundWhole) {
      // Round-half-up: <.5 down, ≥.5 up.
      return (v + 0.5).floor().toString();
    }
    return v.toStringAsFixed(2);
  }

  final annual = data.semesterOnly == 0;
  // Which semester columns to render (0-based). Semester diploma → just one.
  final semIndexes = annual
      ? List<int>.generate(data.semesterCount, (i) => i)
      : <int>[data.semesterOnly - 1];

  // Effective per-subject "final" for the chosen mode.
  double? subjectFinal(CertSubjectRow s) {
    if (annual) return s.finalAvg;
    final idx = data.semesterOnly - 1;
    return idx >= 0 && idx < s.semesters.length ? s.semesters[idx] : null;
  }

  // Overall for the chosen mode.
  double? overall() {
    if (annual) return data.overall;
    final vals = data.subjects.map(subjectFinal).whereType<double>().toList();
    if (vals.isEmpty) return null;
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  final title = annual
      ? l.certPdfAnnualCertificate
      : l.certPdfSemesterCertificate(l.adminSchoolSemesterN('${data.semesterOnly}'));

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

  pw.Widget header() {
    final logo = schoolLogo;
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      decoration: const pw.BoxDecoration(
        color: headerBg,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(18)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (logo != null) pw.SizedBox(height: 64, child: pw.Image(logo, fit: pw.BoxFit.contain)),
          if (logo != null) pw.SizedBox(height: 10),
          pw.Text(
            data.schoolName,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: brandDeep),
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: pw.BoxDecoration(
              color: brandBlue,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(999)),
            ),
            child: pw.Text(
              '$title  ·  ${data.schoolYear}',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.white, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
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
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
        );
    pw.Widget td(String t, {pw.TextAlign align = pw.TextAlign.center, bool bold = false}) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          child: pw.Text(t,
              textAlign: align,
              style: pw.TextStyle(fontSize: 10, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        );

    final startAlign = rtl ? pw.TextAlign.right : pw.TextAlign.left;
    final header = pw.TableRow(
      decoration: const pw.BoxDecoration(color: brandDeep),
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
        horizontalRadius: 14,
        verticalRadius: 14,
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
            pw.Text(l.certPdfGeneratedBy, style: pw.TextStyle(fontSize: 8, color: brandBlue, fontStyle: pw.FontStyle.italic)),
            pw.SizedBox(width: 6),
            pw.SizedBox(width: 13, height: 13, child: pw.Image(cmLogo, fit: pw.BoxFit.contain)),
            pw.SizedBox(width: 4),
            pw.Text('ClassMate', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: brandBlue)),
          ],
        ),
      );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(30, 26, 30, 26),
      textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
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

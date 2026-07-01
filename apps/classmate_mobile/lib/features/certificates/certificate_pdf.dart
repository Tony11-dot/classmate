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
  final int? overall;
  final int absences;
  final int lates;
  final int semesterCount;
  final String dateLabel;
}

bool _isRtlLang(String lang) => lang == 'ar' || lang == 'he' || lang == 'ps';

/// Build the certificate PDF bytes. Renders fully in [data.language] with the
/// correct direction, multi-script glyph shaping, embedded logos and a bar chart.
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

  // ClassMate brand monogram (renders reliably; the wide wordmark does not).
  final cmLogo = pw.MemoryImage(
    (await rootBundle.load('assets/images/icon_light.png')).buffer.asUint8List(),
  );

  // School logo (best-effort network fetch).
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
  const lineColor = PdfColor.fromInt(0xFFCBD5E1);
  const headerBg = PdfColor.fromInt(0xFFEFF4FF);

  pw.Widget header() {
    final logo = schoolLogo;
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: const pw.BoxDecoration(color: headerBg),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (logo != null) pw.SizedBox(height: 56, child: pw.Image(logo, fit: pw.BoxFit.contain)),
          if (logo != null) pw.SizedBox(height: 8),
          pw.Text(
            data.schoolName,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: brandDeep),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '${l.certPdfAnnualCertificate} · ${data.schoolYear}',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 13, color: brandBlue, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.Text('$label: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 11))),
        ],
      ),
    );
  }

  pw.Widget studentBlock() {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(top: 16),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: lineColor),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          infoRow(l.certPdfName, data.studentName),
          if (data.nationalId.trim().isNotEmpty) infoRow(l.certPdfNationalId, data.nationalId),
          infoRow(l.certPdfClass, data.cohortName),
          infoRow(l.certPdfDate, data.dateLabel),
        ],
      ),
    );
  }

  // Grades table — Subject | Sem 1..N | Final. Direction handled by the page's
  // Directionality (RTL reverses the visual column order automatically).
  pw.Widget gradesTable() {
    final headerCells = <pw.Widget>[
      _th(l.certPdfSubject, align: rtl ? pw.TextAlign.right : pw.TextAlign.left),
      _th(l.certPdfTeacher, align: rtl ? pw.TextAlign.right : pw.TextAlign.left),
      for (int i = 0; i < data.semesterCount; i++) _th(l.adminSchoolSemesterN('${i + 1}')),
      _th(l.certPdfFinal),
    ];
    final rows = <pw.TableRow>[
      pw.TableRow(decoration: const pw.BoxDecoration(color: brandDeep), children: headerCells),
    ];
    for (final s in data.subjects) {
      rows.add(pw.TableRow(children: [
        _td(s.display(data.language), align: rtl ? pw.TextAlign.right : pw.TextAlign.left, bold: true),
        _td(s.teachers.join('، '), align: rtl ? pw.TextAlign.right : pw.TextAlign.left),
        for (int i = 0; i < data.semesterCount; i++)
          _td(i < s.semesters.length && s.semesters[i] != null ? '${s.semesters[i]}' : '—'),
        _td(s.finalAvg != null ? '${s.finalAvg}' : '—', bold: true),
      ]));
    }
    // Overall row.
    rows.add(pw.TableRow(
      decoration: const pw.BoxDecoration(color: headerBg),
      children: [
        _td(l.certPdfOverall, align: rtl ? pw.TextAlign.right : pw.TextAlign.left, bold: true),
        _td(''),
        for (int i = 0; i < data.semesterCount; i++) _td(''),
        _td(data.overall != null ? '${data.overall}' : '—', bold: true),
      ],
    ));

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 16),
      child: pw.Table(
        border: pw.TableBorder.all(color: lineColor, width: 0.6),
        columnWidths: {
          0: const pw.FlexColumnWidth(2.4),
          1: const pw.FlexColumnWidth(2.0),
          for (int i = 2; i <= data.semesterCount + 2; i++) i: const pw.FlexColumnWidth(1.1),
        },
        children: rows,
      ),
    );
  }

  // Bar chart of per-subject final averages (manual bars, 0..100 scale).
  pw.Widget barChart() {
    final bars = data.subjects.where((s) => s.finalAvg != null).toList();
    if (bars.isEmpty) return pw.SizedBox();
    const chartHeight = 120.0;
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 22),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(l.certPdfAverage, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: brandDeep)),
          pw.SizedBox(height: 8),
          pw.Container(
            height: chartHeight + 34,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: bars.map((s) {
                final v = (s.finalAvg ?? 0).clamp(0, 100);
                final h = chartHeight * (v / 100.0);
                return pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 3),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Text('$v', style: const pw.TextStyle(fontSize: 8)),
                        pw.SizedBox(height: 2),
                        pw.Container(
                          height: h,
                          decoration: pw.BoxDecoration(
                            color: brandBlue,
                            borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(2)),
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.SizedBox(
                          height: 22,
                          child: pw.Text(
                            s.display(data.language),
                            maxLines: 2,
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(fontSize: 6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget attendanceBlock() {
    pw.Widget stat(String label, String value) => pw.Expanded(
          child: pw.Container(
            margin: const pw.EdgeInsets.symmetric(horizontal: 4),
            padding: const pw.EdgeInsets.symmetric(vertical: 10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: lineColor),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(children: [
              pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: brandDeep)),
              pw.SizedBox(height: 2),
              pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
            ]),
          ),
        );
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 18),
      child: pw.Row(children: [
        stat(l.certPdfAbsences, '${data.absences}'),
        stat(l.certPdfLateness, '${data.lates}'),
      ]),
    );
  }

  pw.Widget signatures() {
    pw.Widget sig(String role, String name) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Container(width: 130, height: 0.8, color: brandDeep),
            pw.SizedBox(height: 4),
            pw.Text(name, style: const pw.TextStyle(fontSize: 11)),
            pw.Text(role, style: pw.TextStyle(fontSize: 9, color: brandBlue)),
          ],
        );
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 30),
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
            pw.SizedBox(width: 14, height: 14, child: pw.Image(cmLogo, fit: pw.BoxFit.contain)),
            pw.SizedBox(width: 4),
            pw.Text('ClassMate', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: brandBlue)),
          ],
        ),
      );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(28, 24, 28, 24),
      textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      build: (context) => [
        header(),
        studentBlock(),
        gradesTable(),
        barChart(),
        attendanceBlock(),
        if (data.publisherNote.trim().isNotEmpty)
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 18),
            child: pw.Text(data.publisherNote, style: const pw.TextStyle(fontSize: 11)),
          ),
        signatures(),
        footer(),
      ],
    ),
  );

  return doc.save();
}

pw.Widget _th(String text, {pw.TextAlign align = pw.TextAlign.center}) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      ),
    );

pw.Widget _td(String text, {pw.TextAlign align = pw.TextAlign.center, bool bold = false}) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(fontSize: 10, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
      ),
    );

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

/// Preview / share / print the certificate.
Future<void> shareCertificatePdf(Uint8List bytes, String filename) async {
  await Printing.sharePdf(bytes: bytes, filename: filename);
}

Future<void> printCertificatePdf(Uint8List bytes) async {
  await Printing.layoutPdf(onLayout: (_) async => bytes);
}
